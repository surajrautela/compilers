%{

	#include <iostream>
	#include <cstdio>
	#include<cstdlib>
	#include <cstring>
	#include <bits/stdc++.h>
	using namespace std;
	extern FILE *yyin; 
	extern int yyparse(void);
	extern int yylex();
	extern int mylineno ;
	extern char* yytext ;
	extern int yyleng;
	void yyerror(char*);
	struct node {
		string code;
		vector<node*> v;
		string id;
		string datatype;
	};
	
	node* root;
	union utype {
		node* Node;
		char* s;
	};
	#define YYSTYPE utype
	
%}

%token IDENTIFIER SEMI INT FLOAT BOOL LP RP COMMA  LCB RCB WHILE FOR IF IFX ELSE EQUALS PLUS MINUS DOUBLE_EQ GREATER GREATER_EQ LESS LESS_EQ NOT_EQ MULT DIV NUMBER BREAK RETURN INCR DECR AND OR NOT MAIN TRUE FALSE FLOAT_NUM VOID INPUT OUTPUT
%start START_CODE 
%%

START_CODE		: 		global main LP parameters_list RP Compound_statements
						{
							node* tempnode = new node;
							tempnode->code = "START_CODE";
							root = tempnode;
							$$.Node = tempnode;
							(tempnode->v).push_back($1.Node);
							(tempnode->v).push_back($2.Node);
							(tempnode->v).push_back($4.Node);
							(tempnode->v).push_back($6.Node);
						}
  				;
main :			MAIN {
							node *tempnode = new node;
							tempnode->code = "MAIN";
							tempnode->id = string(yytext,strlen(yytext));
							$$.Node = tempnode;
						}
				;

global  		: 			declaration_list			
				|			{
									node* tempnode = new node;
									tempnode->code = "global";
									$$.Node = tempnode;
							}
				;			
declaration_list		:		declaration_list declaration		
						|		declaration							
						;
						
declaration			:		variable_declaration				
				|		function_declaration					
				;

variable_declaration		:		type_specifier ss  SEMI
									{
										node* tempnode = new node;
										tempnode->code = "variable declaration";
										(tempnode->v).push_back($1.Node);
										(tempnode->v).push_back($2.Node);
										$$.Node = tempnode;
									}
				|					type_specifier IDENTIFIER  error 
				;
ss				:		IDENTIFIER	
						{
							node *tempnode = new node;
							tempnode->code = "IDENTIFIER";
							tempnode->id = string(yytext,strlen(yytext));
							$$.Node = tempnode;
						}
				;
type_specifier			:		INT
								{
									node *tempnode = new node;
									tempnode->code = "DATATYPE";
									tempnode->datatype = "integer";
									tempnode->id = string(yytext,yyleng);
									$$.Node = tempnode;
								}
				|		FLOAT
				|		BOOL
				|		VOID
				| 		error
				;
									
function_declaration		: 		type_specifier IDENTIFIER LP parameters_list RP Compound_statements		
				;


parameters_list			:               parameters_list COMMA parameters
				|		parameters
				|		{
									node* tempnode = new node;
									tempnode->code = "parameterlist";
									$$.Node = tempnode;
							}
				;
							
parameters			:		type_specifier	IDENTIFIER
				;

Statement_list			:		Statement_list	Statements	
								{
									node *tempnode = new node;
									tempnode->code = "Statements list";
									(tempnode->v).push_back($1.Node);
									(tempnode->v).push_back($2.Node);
									$$.Node = tempnode;
								}				
				| 			{
									node* tempnode = new node;
									tempnode->code = "Statement_list";
									$$.Node = tempnode;
							}										
				;	

Statements			:			Output_statements
						{
									node *tempnode = new node;
									tempnode->code = "Output Statements";
									(tempnode->v).push_back($1.Node);
									$$.Node = tempnode;
								}
				|		Function_call_statements
				|		Input_statements		
				|		Compound_statements
				|		Loop_statements
				|		Condition_statements
				|		Expression_statements 
				|		Break_statement
				|		Return_statement
				;



Function_call_statements	:		IDENTIFIER EQUALS IDENTIFIER LP Identifier_list RP SEMI
				| 					IDENTIFIER EQUALS IDENTIFIER LP Identifier_list RP error
				|					IDENTIFIER LP Identifier_list RP SEMI
				| 					IDENTIFIER LP Identifier_list RP error
				;
				
Identifier_list			:		Identifier_list COMMA IDENTIFIER
						|		IDENTIFIER
						|
						;

Output_statements:		OUTPUT LP type_specifier COMMA ss RP SEMI
							{
									node *tempnode = new node;
									tempnode->code = "Print statement";
									
									(tempnode->v).push_back($3.Node);
									(tempnode->v).push_back($5.Node);
									$$.Node = tempnode;
								}
			;			
			
Input_statements:		INPUT LP type_specifier COMMA ss RP SEMI
			;			

Compound_statements		:		LCB local_declaration Statement_list RCB
								{
									node *tempnode = new node;
									tempnode->code = "Compound Statements";
									(tempnode->v).push_back($2.Node);
									(tempnode->v).push_back($3.Node);
									$$.Node = tempnode;
								}
						;
						
local_declaration		:		local_declaration variable_declaration
								{
									node* tempnode = new node;
									tempnode->code = "Local declaration";
									(tempnode->v).push_back($1.Node);
									(tempnode->v).push_back($2.Node);
									$$.Node = tempnode;
								}						
						| 		{
									node* tempnode = new node;
									tempnode->code = "local empty";
									$$.Node = tempnode;
							}											
						;
				
											



Loop_statements			:		WHILE LP expression RP 	Compound_statements		
				|				WHILE LP error RP 
				|				WHILE LP expression RP  error '\n' 
				|				FOR LP Expression_statements expression SEMI Expression_statements RP 	Compound_statements	
				|				FOR LP error RP
				;



Condition_statements		:		IF LP expression RP Compound_statements	
				|		IFX LP expression RP Compound_statements	 ELSE Compound_statements	
				|   	IF LP error RP 	
				| 		IF LP expression RP error '\n'
				|		IFX LP error RP 
				|		IFX LP expression RP Compound_statements error RCB {printf("dnf\n");}
				;


Expression_statements		:		IDENTIFIER EQUALS expression SEMI
				|					IDENTIFIER EQUALS expression error
				|					IDENTIFIER INCR	SEMI
				|					IDENTIFIER INCR	error
				|					IDENTIFIER DECR	SEMI
				|					IDENTIFIER DECR	error
				|					INCR IDENTIFIER SEMI
				|					INCR IDENTIFIER error
				|					DECR IDENTIFIER	SEMI
				|					DECR IDENTIFIER	error
				|					expression	SEMI
				|					expression	error
				;		


expression			:		expression   operators_bitwise   expression_relation
				|			expression_relation
				;

expression_relation		:		expression_relation operators_relation expression_addsub
				|		expression_addsub
				;

						
expression_addsub		: 		expression_addsub  operators_addsub expression_multdiv						
				|		expression_multdiv
				;

						
expression_multdiv		:		expression_multdiv operators_multdiv expression_simple
				|		expression_simple
				;

						
expression_simple		:		LP expression RP
				|		NOT expression_simple
				|		operators_addsub expression_simple
				|		NUMBER
				|		TRUE
				|		FALSE
				|		FLOAT_NUM
				|		IDENTIFIER
				;

																									


Break_statement			:		BREAK SEMI
						|		BREAK error
				;



Return_statement		:		RETURN expression SEMI
				|				RETURN expression error
				|		RETURN SEMI
				|		RETURN error
				;													
			


operators_bitwise		:		AND
				|		OR
				;

operators_relation		:		DOUBLE_EQ
				|		GREATER_EQ
				|		GREATER
				|		LESS_EQ
				|		LESS
				|		NOT_EQ
				;
						
operators_addsub		:		PLUS
				|		MINUS
						;

operators_multdiv		:		MULT
				|		DIV
				;
 	
%%

void printSpace(int cnt)
{
	for(int i=0;i<cnt;i++) cout<<"\t";
}
void dfs(node *n,int cnt)
{

	printSpace(cnt);
	if(n==NULL){
		cout<<"NULL\n";
		return;
	}
	//cout<<"hello\n";
	cout <<n->code<<" "<<(n->v).size()<<endl;
	for (int i = 1; i <= (n->v).size(); ++i)
	{
		//cout<<"hello1\n";
		dfs((n->v)[i-1],cnt+1);
		//cout<<"hello2\n";
	}
}
int main()
{
	yyparse();
	dfs(root,0);
}
void yyerror (char *s) { printf("Error in line: %d, text: %s \n", mylineno, yytext);}



 					
