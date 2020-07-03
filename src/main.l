%{
#include <stdlib.h>
void yyerror(char *);

#include "y.tab.h"

%}


%%

\( {return '('; // parenteses possuem prioridade máxima sobre qualquer operação
    }

\) {return ')'; }

[0-9]+ {yylval = atoi(yytext); /* entrada é lida como int. Atribuição dos números é a segunda coisa a ser identificada
				   quando lida a sentença*/
	return INT;}

[\^] {return POTENCIACAO; }

[*] {return MULTIPLICACAO; }

[/] {return DIVISAO; }

[+] {return SOMA; }

[\n] {return EOS; }

.;



%%

int yywrap(){
  return 1;
}
