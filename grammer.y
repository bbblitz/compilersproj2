/*The grammer for the minijava language, should be run though yacc
	$yacc grammar.y
TODO:Finish
TODO:Test
*/
%{/*definition*/
#include "proj2.h"
#include <stdio.h>
%}
%token <intg> PROGRAMnum IDnum SCONSTnum
/*Try to keep this alphabetical to make it easy to find things*/
%type <tptr> ArrayInitializer ArrayCreationExpression
%type <tptr> ClassDecl ClassDecl_l
%type <tptr> Decls 
%type <tptr> Expression Expression_l 
%type <tptr> FieldDecl, FieldDecl_l FieldDecl_chunk
%type <tptr> MethodDecl MethodDecl_l
%type <tptr> VariableInit Variable VariableDeclId VariableInitializer VariableInitializer_l 
%type <tptr> Program SimpleExpression Comp op
ClassBody
%% /*yacc specification */
Program : PROGRAMnum IDnum SEMInum ClassDecl_l{
	$$ = MakeTree(ProgramOp, $4, MakeLeaf(IDNode, $2));
	printtree($$,0);
};

/*May be a list of class delcerations*/
ClassDecl_l : ClassDecl{
	    	$$ = MakeTree(ClassOp, NullExp(), $1);
	    }
	    | ClassDecl_l ClassDecl{
	    	$$ = MakeTree(ClassOp, $1, $2);
	    };

ClassDecl : CLASSnum IDnum ClassBody{
	$$ = MakeTree(ClassDefOp, $3, MakeLeaf(IDNode, $2));
	printtree($$,0);
};

ClassBody : LBRACEnum RBRACEnum{
	  	/*Empty TODO:Is this correct?*/
		$$ = MakeTree(BodyOp,NullExp(),NullExp());
	  }
	  | RBRACEnum Decls LBRACEnum{
	  	$$ = MakeTree(BodyOp,$2,NullExp());
	  }
	  | RBRACEnum MethodDecl_l LBRACEnum{
	  	$$ = MakeTree(BodyOp,NullExp(),$2);
	  }
	  /*TODO: This is wrong, fix it*/
	  | RBRACEnum Decls MethodDecl_l LBRACEnum{
	  	/*Make the tree with all the methods*/
		tree* mtree = $3;
		/*Now that the tree is made, find it's leftmost leaf*/
		tree* cursor = mtree;
		while(LeftChild(cursor)->NodeKind != DUMMYNode){
			cursor = LeftChild(cursor);
		}
		/*And set it to the decls tree*/
		SetLeftChild(cursor,$2);
	  	$$ = mtree;
	  };

MethodDecl_l : MethodDecl {
	     	$$ = MakeTree(BodyOp,NullExp(),$1);
	     }
	     | MethodDecl_l MethodDecl{
	     	$$ = MakeTree(BodyOp,$1,$2);
	     };

Decls : DELCLARATIONSnum FieldDecl_l ENDDECLARATIONSnum{
	$$ = MakeTree(BodyOp,$2,
      }
      | DELCLARATIONSnum ENDDECLARATIONSnum{

      };

FieldDecl_l : FieldDecl{
	    	$$ = MakeTree(BodyOp,NullExp(),$1);
	    }
	    | FieldDecl_l FieldDecl{
	    	$$ = MakeTree(BodyOp,$1,$2);
	    };

FieldDecl : Type FieldDecl_chunk SEMInum{
	  	$$ = $2;
	  };

/*TODO:Fill this one in*/
FieldDecl_chunk : VariableDecId{
			$$ = NullExp();
		}
		| VariableDecId COMMAnum FieldDecl_chunk{
			$$ = NullExp();
		}
		| VaribleInit{
			$$ = NullExp();
		}
		| VariableInit COMMAnum FieldDecl_chunk{
			$$ = NullExp();
		};
/*TODO:This one too*/
VariableInit : VariableDecId EQUALSnum VaribleInitalizer{
	     	$$ = NullExp();
	};

VariableDeclId : IDENTIFIERnum {
	       	$$ = MakeTree(IDNode,NullExp(),NullExp());
	       }
	       | IDENTIFIERnum BracSet{
	       	$$ = MakeTree(IDNode,NullExp(),NullExp());
	       };

/*Don't do anything for these I guess*/
BracSet : LBRACnum RBRACnum
	| LBRACnum RBRACnum BracSet;

VariableInitializer : Expression{
			$$ = $1;
		   }
		   | ArrayInitializer{
			$$ = $1;
		   }
		   | ArrayCreationExpression{
			$$ = $1;
		   };

/*I think the specification for this dosen't make sense, what the "Subtree for Type"? What is that type?*/
ArrayInitializer : LBRACEnum VariableInitializer_l RBRACEnum{
	$$ = MakeTree(ArrayTypeOp,$2,NullExp());
};

VariableInitializer_l : VariableInitializer{
			$$ = MakeTree(CommaOp,NullExp(),$1);
		      }
		      | VariableInitializer DOTnum VariableInitializer_l{
			$$ = MakeTree(CommaOp,$3,$1);
		      };

/*What is INTEGERT? (right subtree of the root for ArrayCreationExpressions)*/
ArrayCreationExpression : INTnum Expression_l {
				$$ = MakeTree(ArrayTypeOp,$2,MakeLeaf(IntegerOp,$1));
			};

Expression_l : LBRACnum Expression RBRACnum{
		$$ = MakeTree(BoundOp,NullExp(),$2);
	     }
	     | LBRACnum Expression RBRACnum Expression_l{
		$$ = MakeTree(BoundOp,$4,$2);
	     };

/*TODO:Pick up here*/
MethodDecl : 

/*other rules*/
Expresssion : SimpleExpression {$$ = $1;}
	    | SimpleExpression Comp op SimpleExpression
	    	{MkLeftC($1,$2); $$ = MkRightC($3, $2);}
%%
int yycolumn yyline;
FILE* treelst;
main() {
	treelst = stdout;
	yyparse();
}

yyerror(char* str) {
	printf("yyerror: %s at line %d\n",str,yyline);
}
#include "lex.yy.c"
