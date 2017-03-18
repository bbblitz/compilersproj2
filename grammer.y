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

/*TODO:what should idnode be? How do we set type up?*/
MethodDecl : METHODnum VOIDnum IDENTIFIERnum LPARENnum FormalParameterList RPARENnum Block {
		$$ = MakeTree( 	MethodOp,
				MakeTree( 	HeadOp,
						MakeLeaf(IDNode,0),
						$5
					),
				$8
				);
	}
	   | METHODnum Type IDENTIFIERnum LPARENnum FormalParameterList RPARENnum Block {
	   $$ = MakeTree( 	MethodOp,
	   			MakeTree( HeadOp,
					  MakeLeaf(IDNode,0),
					  $5,
					),
				$8
			);
}
	   | METHODnum VOIDnum IDENTIFIERnum LPARENnum RPARENnum Block{ 
	   $$ = MakeTree( 	MethodOp,
	   			MakeTree( HeadOp,
					  MakeLeaf(IDNode,0),
					  NullExp(),
					),
				$8
			);
}
	   | METHODnum Type IDENTIFIERnum LPARENnum RPARENnum Block {
		$$ = MakeTree( 	MethodOp,
	   			MakeTree( HeadOp,
					  MakeLeaf(IDNode,0),
					  NullExp(),
					),
				$8
			);
};

/*TODO:Make a global type so it can be used here*/
FormalParameterList : FormalParameter_l{
		    $$ = MakeTree(SpecOp,$1,global_type);
		    };
/*TODO:How do I know if it should be an r arg type or varg type?*/
FormalParameter_l : FormalParameter 
		  | FormalParameter SEMInum FormalParameter_l {
		  	$$ = MakeTree(RArgTypeOp, $1, $2);
};

FormalParameter : VALnum INTnum IDENTIFIERnum Identifier_l{
			$$ = MakeTree(CommaOp,IDNode,INTEGERT);
		}
		| INTnum IDENTIFIERnum Identifier_l{
			$$ = MakeTree(CommaOp, IDNode, INTEGERT);
		};

Identifier_l : COMMAnum IDENTIFIERnum
	     | Identifier_l COMMAnum IDENTIFIERnum

Block : Decls StatementList{
      	$$ = MakeTree(BodyOp,$1,$2);
      }
      | StatementList{
     	$$ = MakeTree(BodyOp,NullExp(),$2); 
      };

/*TODO:This is totally wrong, fix it*/
Type : IDENTIFIERnum
     | IDENTIFIERnum BracSet
     | INTnum 
     | INTnum BracSet 

StatementList: LBRACEnum Statement Statement_l RBRACEnum{
	     $$ = MakeTree(StmtOp,$3,$2);
	     }
	     | LBRACEnum Statement RBRACEnum{
	     $$ = MakeTree(StmtOp,NullExp(),$2);
	     };

Statement_l : Statement{
	    $$ = MakeTree(StmtOp,NullExp(),$1);
	    }
	    | Statement Statement_l{
	    $$ = MakeTree(StmtOp,$2,$1);
	    };

Statement : AssignmentStatement { $$ = $1;}
	  | MethodCallStatement { $$ = $1;}
	  | ReturnStatement 	{ $$ = $1;}
	  | IfStatement 	{ $$ = $1;}
	  | WhileStatement 	{ $$ = $1;}
	  | /*Empty*/ ;

AssignmentStatement : Variable ASSIGNnum Expression{
		    $$ = MakeTree( 	AssignOp,
		    			MakeTree(AssignOp,NullExp(),$1),
					$3);
};

MethodCallStatement : Variable LPARENnum Expression_s RPARENnum{
	$$ = MakeTree(RoutineCallOp,$1,$3);
		    }
		    | Variable LPARENnum RPARENnum{
		    $$ = MakeTree(RoutineCallOp,$1,NullExp());
		    };

Expression_s : Expression{
	     $$ = MakeTree(CommaOp,$1,NullExp());
	     | Expression DOTnum Expression_s{
	     $$ = MakeTree(CommaOp,$1,$3);
	     };

ReturnStatement : RETURNnum Expression{
		$$ = MakeTree(ReturnOp,$2,NullExp());
		| RETURNnum{
		$$ = MakeTree(ReturnOp,NullExp(),NullExp());
		};

/*TODO:How in the world is this supposed to work? Where is  statmentlist go?*/
IfStatement : IFnum Expression StatementList {
	    $$ = MakeTree(CommaOp,$2,$3);
	    }
	    | IFnum Expression StatementList ELSE StatementList{
	    $$ = MakeTree(IfElseOp,
	    		  MakeTree(IfElseOp,
			           NullExp()
				   MakeTree(CommaOp,$2,$3)
				   )
			  $5);
	    };
	    | IFnum Expression StatementList ELSE IfStatement{
	    $$ = MakeTree(IfElseOp,
	    		  $5,
			  MakeTree(CommaOp,$2,$3)
			  );
	    };

WhileStatement : WHILEnum Expression StatementList {
	       $$ = MakeTree(LoopOp,$2,$3);
	       };

/*TODO:What should LTnum be if we don't have a rhs?*/
Expression : SimpleExpression{
	   $$ = MakeTree(0,$1,NullExp());
	   }
	   | SimpleExpression GTnum SimpleExpression{
	   $$ = MakeTree(LTOp,$1,$3);
	   }
	   | SimpleExpression GEnum SimpleExpression{
	   $$ = MakeTree(LEOp,$1,$3);
	   }
	   | SimpleExpression EQnum SimpleExpression{
	   $$ = MakeTree(EQOp,$1,$3);
	   }
	   | SimpleExpression NEnum SimpleExpression{
	   $$ = MakeTree(NEOp,$1,$3);
	   }
	   | SimpleExpression GEnum SimpleExpression{
	   $$ = MakeTree(GEOp,$1,$3);
	   }
	   | SimpleExpression GTnum SimpleExpression{
	   $$ = MakeTree(GTOp,$1,$3);
	   };

/*How do they fit into this tree? TODO:Complete this
I hope I don't have to do the same cursor thing I did before, that was a pain
*/
SimpleExpression : Unary SEPost_l
		 | SEPre Term

Unary : PLUSnum Term{
      $$ = $2;
      }
      | MINUSnum Term{
      $$ = MakeTree(UnaryNegOp,$2,NullExp();
      }
      | Term{
      $$ = $1
      };
/*TODO:Same with this, do I have to build the three then set it's stuff up?*/
Term : Factor 

Factor : UnassignedConstant 		{ $$ = $1; }
       | Variable 			{ $$ = $1; }
       | MethodCallStatement 		{ $$ = $1; }
       | LPARENnum Expression RPARENnum { $$ = $1; }
       | NOTnum Factor 			{ $$ = $1; };

/*TODO:The documentation says that these are tokens, but then the tree should be a subtree? What?*/
UnassignedConstant : INTEGERT
		   | STRINGT

Variable : IDENTIFIERnum {
	 $$ = MakeTree(FieldOp,IDNode,NullExp());
	 }
	 | IDENTIFIERnum Variable_s_l{
	 $$ = MakeTree(VarOp,IDNode,$2);
	 };

Variable_s_l : Variable_s {
	     $$ = $1
	     }
	     | Variable_s Variable_s_l{
	     $$ = MakeTree(IndexOp,$1,$2);
	     };

Variable_s : Variable_expr 	{$$ = $1;}
	   | Variable_iden 	{$$ = $1;};

/*TODO: These are pobably wrong, but variables are confuseing :( */
Variable_expr : LBRACnum Expression_l RBRACnum { $$ = $2;};

Variable_iden : DOTnum IDENTIFIERnum { $$ = NullExp(); };
	 

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
