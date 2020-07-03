%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(char *c);
int yylex(void);
%}

/* Teremos um token para cada tipo de operação, além dos parênteses que podem ser inserios,
	de forma a facilitar a codificação: apenas potenciacao não possui função própria em
	Assembly. Note que INT e EOS são tokens necessários para obtenção dos valores operados
	e para a finalização do programa, respectivamente.*/
%token '('')' INT SOMA DIVISAO MULTIPLICACAO POTENCIACAO EOS

/* Estabelecemos que as associações devem ser feitas à esquerda com %left. A ordem em que as definições são realizadas
	estão de acordo com as precedências das operações desejadas: no caso potência > divisão > multiplicação
	(nisso tanto faz, multiplicação > divisão também funciona) > soma. */
%left SOMA
%left MULTIPLICACAO
%left DIVISAO
%left POTENCIACAO

%%

/* Ao ser reconhecida a leitura de uma sentença, o programa finaliza com uma prévia do resultado
	esperado no registrador A ao ser implementado código impresso no simulador online de assembly */
DONE:
	SENTENCE {printf("; Seu registrador A deve conter o valor correspondente a %d\n", $1);}
	;
	
/* O digitado, no fundo, é uma única expressão cujo diferencial é acabar com '\n' */
SENTENCE:
	EXPRESSAO EOS {}
	;
	
/* Expressão pode ser definida como qualquer interação das operações com números 
   O detalhe para a ordem das definições de reconhecimento: em primeiro lugar temos
   	o reconhecimento de um número como uma expressão, em seguida o reconhecimento de uma
   	expressão em parênteses, para aí então partir para as operações possíveis entre expressões */
EXPRESSAO:
	INT {$$ = $1;} // É passado para expressao o próprio valor
	| '(' EXPRESSAO ')' {$$ = $2;} // É passada como expressão a expressão entre parênteses
	 /* Para as demais, é passado como expressão o valor referente ao resultado da operação realizada */
	 /* A respeito do código Assembly: notemos que podemos armazenar os valores utilizados em cada operaçaõ
	 	nos mesmos registradores sem medo, pois cada operação realizada entre duas expressões retorna 
	 	uma expressão nova. Desse modo, os valores resultantes vao sendo 'arrastados' da esquerda para a 
	 	direita conforme a leitura da sentença digitada, e ao registador A é atribuído o valor resultado 
	 	de cada expressão, seja ela um número, uma outra expressão em pareteses ou uma operação */
	| EXPRESSAO POTENCIACAO EXPRESSAO {
		//printf(";---\n");
		if ($3 > 1){ // Caso expoente >1:
			$$ = $1; // Possuímos um valor inicial que deve ser multiplicado pelo expoente n (n-1) vezes
			printf("MOV A, %d\nMOV B, %d\n", $1, $1);
			for (int i = 0; i < ($3 - 1); i++){
				printf("MUL B\n");
				$$ *= $1;
			}
		}else if($3 == 1){
			$$ = $1; // Caso expoente = 1: valor continua igual
			printf("MOV A, %d\n", $1);
		}else if($3 == 0){
			$$ = 1; // Caso expoente = 0: valor = 1
			printf("MOV A, 1\n");
		}
		//printf(";---> %d elevado a %d dá %d\n",$1, $3, $$);
		}
	
	| EXPRESSAO DIVISAO EXPRESSAO{$$ = $1 / $3;
				       //printf(";---\n");
				       printf("MOV A, %d\nMOV B, %d\nDIV B\n", $1, $3);
				       //printf(";---> Dividi %d por %d:\n", $1, $3);
				       }
	| EXPRESSAO MULTIPLICACAO EXPRESSAO{$$ = $1 * $3;
				             //printf(";---\n");
					     printf("MOV A, %d\nMOV B, %d\nMUL B\n", $1, $3);
					     //printf(";---> Multipliquei %d por %d:\n", $1, $3);
					     }
	| EXPRESSAO SOMA EXPRESSAO {$$ = $1 + $3;
			             //printf(";---\n");
				     printf("MOV A, %d\nMOV B, %d\nADD A, B\n", $1, $3);
				     //printf(";---> Somei %d com %d:\n",$1, $3);
				     }


%%

void yyerror(char *s){
  printf("Erro na expressão\n");
}

int main(){
  yyparse();
  return 0;
}
