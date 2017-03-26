%{
#include "proj2.h"
#include <stdio.h>


  tree type_record, type_method, argtype, bractemp, type_tree; /* globals used to store treenode pointers */
%}

%token <intg>ANDnum
%token <intg>ASSGNnum
%token <intg>DECLARATIONSnum		
%token <intg>DOTnum		
%token <intg>ENDDECLARATIONSnum	
%token <intg>EQUALnum		
%token <intg>GTnum			
%token <intg>IDnum			
%token <intg>INTnum		
%token <intg>LBRACnum		
%token <intg>LPARENnum		
%token <intg>METHODnum		
%token <intg>NEnum			
%token <intg>ORnum			
%token <intg>PROGRAMnum		
%token <intg>RBRACnum		
%token <intg>RPARENnum		
%token <intg>SEMInum			
%token <intg>VALnum			
%token <intg>WHILEnum		
%token <intg>CLASSnum		
%token <intg>COMMAnum		
%token <intg>DIVIDEnum		
%token <intg>ELSEnum			
%token <intg>EQnum			
%token <intg>GEnum			
%token <intg>ICONSTnum		
%token <intg>IFnum			
%token <intg>LBRACEnum		
%token <intg>LEnum			
%token <intg>LTnum			
%token <intg>MINUSnum		
%token <intg>NOTnum			
%token <intg>PLUSnum			
%token <intg>RBRACEnum		
%token <intg>RETURNnum		
%token <intg>SCONSTnum		
%token <intg>TIMESnum		
%token <intg>VOIDnum			
%token <intg>EOFnum 0
/*Why do we need to define these here?*/
%token <intg>IDNode 200



/*Try to keep this alphabetical to make it easy to find things*/
%type <tptr> ArrayCreationExpression ArrayCreationExpression_1 ArrayExpression ArrayInitializer ArrayCreationExpression ArrayInitializer_l
%type <tptr> AssignmentStatement
%type <tptr> Block
%type <tptr> ClassDecl ClassDecl_l ClassBody
%type <tptr> Decls 
%type <tptr> Expression Expression_s
%type <tptr> Factor
%type <tptr> FieldDecl FieldDecl_l FieldDecl_chunk FieldDecl_strand Field
%type <tptr> FormalParameterList FormalParameter_l FormalParameter FormalParameterList_l
%type <tptr> IfStatement Index Index_l
%type <tptr> MethodDecl MethodDecl_l MaybeMethodDecl
%type <tptr> MethodCallStatement
%type <tptr> Program
%type <tptr> ReturnStatement
%type <tptr> SimpleExpression SimpleExpression_l SimpleExpression_l_l
%type <tptr> StatementList Statement Statement_l
%type <tptr> Term Term_l Term_l_l Type Type_l
%type <tptr> UnassignedConstant
%type <tptr> Variable VariableDeclId VariableInitializer Variable_l
%type <tptr> WhileStatement

/*Edits to rules:
 *changed "IDENTIFIERnum" to "IDnum" assuming the former meant to say the latter
 *same deal with "ASSIGNnum" to "ASSGNnum"
 *and "DELCLARATIONSnum" to "DECLARATIONSnum"
 *"VariableDecId" to "VariableDeclId"
 *"VaribleInitalizer" to "VariableInitializer"
 *"VaribleInit" to "VariableInit"
 *"EQUALSnum" to "EQUALnum"*/

/* These were in the example
%type <tptr> Program SimpleExpression Comp op
ClassBody
*/
%% /*yacc specification */
/*TODO:The 0 in makeleaf should be idnum sumhow*/
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

	    	printf("Found classdecl\n");
	$$ = MakeTree(ClassDefOp, $3, MakeLeaf(IDNode, $2));
	printtree($$,0);
};

ClassBody : LBRACEnum Decls MethodDecl_l RBRACEnum{

	    	printf("Found classbody\n");
	  	if($3 == NullExp()){
			$$ = $2;
		}else{
			$$ = MkLeftC($2,$3);
		}
	  };

MethodDecl_l : MaybeMethodDecl {
	    	printf("Found methoddecl_l\n");

	     	$$ = MakeTree(BodyOp,NullExp(),$1);
	     }
	     | MethodDecl_l MethodDecl{
	     	$$ = MakeTree(BodyOp,$1,$2);
	     };

MaybeMethodDecl : /*Empty*/{
	     	$$ = NullExp();
	     	}
		| MethodDecl{
		$$ = MakeTree(BodyOp,NullExp(),$1);
		};

Decls : DECLARATIONSnum FieldDecl_l ENDDECLARATIONSnum{

	    	printf("Found Decls\n");
	$$ = $2;
      }
      | /*Empty*/{
	$$ = NullExp();
      };

FieldDecl_l : FieldDecl{
	    	$$ = MakeTree(BodyOp,NullExp(),$1);
	    }
	    | FieldDecl_l FieldDecl{
	    	$$ = MakeTree(BodyOp,$1,$2);
	    }
	    | /*Empty*/{
	    	$$ = NullExp();
	    };

FieldDecl : Type FieldDecl_chunk SEMInum{

	    	printf("Found FieldDecl\n");
	  	$$ = $2;
	  };

FieldDecl_chunk : FieldDecl_strand{
			$$ = MakeTree(DeclOp, NullExp(), $1);
		}
		| FieldDecl_chunk COMMAnum FieldDecl_strand{
		$$ = MakeTree(DeclOp,$1,$3);
		};

FieldDecl_strand : VariableDeclId{

	    	 printf("Found FieldDecl_strand\n");
		 $$ = MakeTree( CommaOp,
		 		$1,
				MakeTree(CommaOp,type_tree,NullExp())
		      		);
		 }
		 | VariableDeclId EQUALnum VariableInitializer{
		 $$ = MakeTree( CommaOp,
		 		$1,
				MakeTree(CommaOp, type_tree, $3)
				);
		 };

VariableDeclId : IDnum {

	    	 printf("Found VariableDeclId\n");
	       	$$ = MakeLeaf(IDNode,$1);
	       }
	       | IDnum BracSet{
	       	$$ = MakeLeaf(IDNode,$1);
	       };

/*Don't do anything for these I guess*/
BracSet : LBRACnum RBRACnum
	| LBRACnum RBRACnum BracSet;

VariableInitializer : Expression{

	    	 	printf("Found VariableInitializer\n");
			$$ = $1;
		   }
		   | ArrayInitializer{
			$$ = $1;
		   }
		   | ArrayCreationExpression{
			$$ = $1;
		   };

/*I think the specification for this dosen't make sense, what the "Subtree for Type"? What is that type?*/
ArrayInitializer : LBRACEnum ArrayInitializer_l RBRACEnum{

	    	 	printf("Found ArrayInitializer\n");
	$$ = MakeTree(ArrayTypeOp,$2,NullExp());
};

ArrayInitializer_l : Expression{
			$$ = MakeTree(CommaOp,NullExp(),$1);
		      }
		      | ArrayInitializer_l COMMAnum Expression{
			$$ = MakeTree(CommaOp,$1,$3);
		      };

/*What is INTEGERT? (right subtree of the root for ArrayCreationExpressions)*/
ArrayCreationExpression : INTnum ArrayCreationExpression_1{
			$$ = MakeTree( 	ArrayTypeOp,
					$2,
					MakeLeaf(INTEGERTNode,$1)
					);
			};

ArrayCreationExpression_1 : ArrayExpression{
			  $$ = MakeTree(BoundOp,NullExp(), $1);
			  }
			  | ArrayCreationExpression_1 ArrayExpression{
			  $$ = MakeTree(BoundOp,$1,$2);
			  };

ArrayExpression : LBRACnum Expression RBRACnum { $$ = $2;};

/*TODO:what should idnode be? How do we set type up?
The typetree bit sets a global so that we know what we should return
*/
MethodDecl : METHODnum VOIDnum {type_tree = NullExp();} IDnum LPARENnum FormalParameterList RPARENnum Block {
		$$ = MakeTree( 	MethodOp,
				MakeTree( 	HeadOp,
						MakeLeaf(IDNode,$4),
						$6
					),
				$8
				);
	}
	   | METHODnum Type IDnum LPARENnum FormalParameterList RPARENnum Block {
	   $$ = MakeTree( MethodOp,
	   			MakeTree( HeadOp,
					  MakeLeaf(IDNode,$3),
					  $5
					),
				$7
			);
}
	   | METHODnum VOIDnum IDnum LPARENnum RPARENnum Block{
	   $$ = MakeTree( 	MethodOp,
	   			MakeTree( HeadOp,
					  MakeLeaf(IDNode,0),
					  NullExp()
					),
				$6
			);
}
	   | METHODnum Type IDnum LPARENnum RPARENnum Block {
		$$ = MakeTree( 	MethodOp,
	   			MakeTree( HeadOp,
					  MakeLeaf(IDNode,0),
					  NullExp()
					),
				$6
			);
};

FormalParameterList : /*Empty*/{
		    $$ = MakeTree(SpecOp,NullExp(),type_tree); 
		    }
		    | FormalParameterList_l{
		    $$ = MakeTree(SpecOp,$1,type_tree);
		    };

FormalParameterList_l : FormalParameter {$$ = $1;}
		  | FormalParameter SEMInum FormalParameter_l {
		  	$$ = MkRightC($1, $3);
		  };

FormalParameter : VALnum INTnum FormalParameter_l{
		$$ = MakeVal($3);
		}
		| INTnum FormalParameter_l{
		$$ = $2;
		};

FormalParameter_l : IDnum{
		  $$ = MakeTree( 	RArgTypeOp,
		  			MakeTree(CommaOp,
						 MakeLeaf(IDNode,
						 	  $1),
						 MakeLeaf(INTEGERTNode,
							  0
						 )
					),
					NullExp()
		       );
		  }
		  | IDNode COMMAnum FormalParameter_l{
		  $$ = MkRightC($3,
		  		MakeTree(RArgTypeOp,
					 MakeTree(CommaOp,
					 	  MakeLeaf(IDNode, $1),
						  MakeLeaf(INTEGERTNode,0)
					 ),
					 NullExp()
				));
		  };

Block : Decls StatementList{
      	$$ = MakeTree(BodyOp,$1,$2);
      }
      | StatementList{
     	$$ = MakeTree(BodyOp,NullExp(),$1); 
      };

Type : IDnum Type_l{

	printf("Found Type\n");
     $$ = type_tree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2);
     }
     | INTnum Type_l{
     $$ = type_tree = MakeTree(TypeIdOp,MakeLeaf(INTEGERTNode, $1), $2);
     }
     | IDnum Type_l DOTnum Type{
     $$ = type_tree = MkRightC(
     				MakeTree(FieldOp,$4,NullExp()),
				MakeTree(TypeIdOp,
					 MakeLeaf(IDNode,$1),
					 $2)
				);
     }
     | INTnum Type_l DOTnum Type{
     $$ = type_tree = MkRightC( 
     				MakeTree(FieldOp, $4, NullExp()),
				MakeTree(TypeIdOp,
					 MakeLeaf(INTEGERTNode,$1),
					 $2)
				);
     };

Type_l : /*Empty*/{
       $$ = type_tree = NullExp();
       }
       | LBRACnum RBRACnum{
       $$ = type_tree = MakeTree(IndexOp,NullExp(),NullExp());
       }
       | Type_l LBRACnum RBRACnum{
       $$ = type_tree = MakeTree(IndexOp,NullExp(),$1);
       };

StatementList: LBRACEnum Statement_l RBRACEnum{
	     $$ = $2;
	     }

Statement_l : Statement{
	    $$ = MakeTree(StmtOp,NullExp(),$1);
	    }
	    | Statement_l SEMInum Statement{
	    	if($3 == NullExp()) $$ = $1;
		else $$ = MakeTree(StmtOp, $1, $3);
	    };

Statement : AssignmentStatement { $$ = $1;}
	  | MethodCallStatement { $$ = $1;}
	  | ReturnStatement 	{ $$ = $1;}
	  | IfStatement 	{ $$ = $1;}
	  | WhileStatement 	{ $$ = $1;}
	  | /*Empty*/ 		{ $$ = NullExp();};

AssignmentStatement : Variable ASSGNnum Expression{
		    $$ = MakeTree(AssignOp,MakeTree(AssignOp,NullExp(),$1),$3);
};

MethodCallStatement : Variable LPARENnum Expression_s RPARENnum{
		    $$ = MakeTree(RoutineCallOp,$1,$3);
		    };

Expression_s : Expression{
	     $$ = MakeTree(CommaOp,$1,NullExp());
	     }
	     | Expression DOTnum Expression_s{
	     $$ = MakeTree(CommaOp,$1,$3);
	     }
	     | /*Epsilon*/{
	     $$ = NullExp();
	     };

ReturnStatement : RETURNnum Expression{
		$$ = MakeTree(ReturnOp,$2,NullExp());
		}
		| RETURNnum{
		$$ = MakeTree(ReturnOp,NullExp(),NullExp());
		};

/*TODO:How in the world is this supposed to work? Where is  statmentlist go?*/
IfStatement : IFnum Expression StatementList {
	    $$ = MakeTree(IfElseOp, NullExp(),MakeTree(CommaOp,$2,$3));
	    }
	    | IFnum Expression StatementList ELSEnum StatementList{
	    $$ = MakeTree(IfElseOp,
	    		  MakeTree(IfElseOp,
			           NullExp(),
				   MakeTree(CommaOp,$2,$3)
				   ),
			  $5);
	    };

WhileStatement : WHILEnum Expression StatementList {
	       $$ = MakeTree(LoopOp,$2,$3);
	       };

/*TODO:What should LTnum be if we don't have a rhs?*/
Expression : SimpleExpression{
	   $$ = $1;
	   }
	   | SimpleExpression GTnum SimpleExpression{
	   $$ = MakeTree(GTOp,$1,$3);
	   }
	   | SimpleExpression GEnum SimpleExpression{
	   $$ = MakeTree(GEOp,$1,$3);
	   }
	   | SimpleExpression EQnum SimpleExpression{
	   $$ = MakeTree(EQOp,$1,$3);
	   }
	   | SimpleExpression NEnum SimpleExpression{
	   $$ = MakeTree(NEOp,$1,$3);
	   }
	   | SimpleExpression LEnum SimpleExpression{
	   $$ = MakeTree(LEOp,$1,$3);
	   }
	   | SimpleExpression LTnum SimpleExpression{
	   $$ = MakeTree(LTOp,$1,$3);
	   };

/*How do they fit into this tree? TODO:Complete this
I hope I don't have to do the same cursor thing I did before, that was a pain
*/
SimpleExpression : Term SimpleExpression_l{
		 	if($2 == NullExp()) $$ = $1;
			else $$ = MkLeftC($1,$2);
		 }
		 | PLUSnum Term SimpleExpression_l{
		 	if($3 == NullExp()) $$ = $2;
			else $$ = MkLeftC($2,$3);
		 };

SimpleExpression_l_l : SimpleExpression_l SimpleExpression_l_l{
		     	if($2 == NullExp()) $$ = $1;
			else $$ = MkLeftC($1,$2);
		     }
		     | /*Empty*/ { $$ = NullExp();};

SimpleExpression_l : PLUSnum Term{
		   $$ = MakeTree(AddOp, NullExp(), $2);
		   }
		   | MINUSnum Term{
		   $$ = MakeTree(SubOp, NullExp(), $2);
		   }
		   | ORnum Term{
		   $$ = MakeTree(OrOp, NullExp(), $2);
		   };

/*TODO:Same with this, do I have to build the three then set it's stuff up?*/
Term : Factor Term_l_l{
     	if($2 == NullExp()) $$ = $1;
	else $$ = MkLeftC($1,$2);
	};

Term_l_l : Term_l Term_l_l{
	 if($2 == NullExp()) $$ = $1;
	 else $$ = MkLeftC($1,$2);
	 }
	 |/*Empty*/{$$ = NullExp();};

Term_l : ANDnum Factor 		{$$ = MakeTree(AndOp, NullExp(), $2);}
       | TIMESnum Factor 	{$$ = MakeTree(MultOp,NullExp(), $2);}
       | DIVIDEnum Factor 	{$$ = MakeTree(DivOp, NullExp(), $2);};

Factor : UnassignedConstant 		{ $$ = $1; }
       | Variable 			{ $$ = $1; }
       | MethodCallStatement 		{ $$ = $1; }
       | LPARENnum Expression RPARENnum { $$ = $2; }
       | NOTnum Factor 			{
       $$ = MakeTree(NotOp, $2, NullExp());
       };

/*TODO:The documentation says that these are tokens, but then the tree should be a subtree? What?*/
UnassignedConstant : ICONSTnum {$$ = MakeLeaf(NUMNode,$1);}
		   | SCONSTnum {$$ = MakeLeaf(STRINGNode,$1);};

Variable : IDnum Variable_l{
	 $$ = MakeTree( 	VarOp,
	 			MakeLeaf(IDNode,$1),
				$2
			);
	 };

Variable_l : Index Variable_l 		{$$ = MakeTree(SelectOp,$1,$2);}
	   | Field Variable_l 		{$$ = MakeTree(SelectOp,$1,$2);}
	   | /*Empty*/ 			{$$ = NullExp();};

Field : DOTnum IDnum 	{
      $$ = MakeTree( 	FieldOp,
      			MakeLeaf(IDNode, $2),
			NullExp()
			);
      };

Index : LBRACnum Index_l RBRACnum {$$ = $2;};

Index_l : Expression {$$ = MakeTree(IndexOp, $1, NullExp());}
	| Expression COMMAnum Index_l {$$ = MakeTree(IndexOp,$1,$3);};


%%
int yycolumn;
int yyline;
FILE* treelst;
main() {
	printf("Let's parse!");
	treelst = stdout;
	yyparse();
}

yyerror(char* str) {
	printf("yyerror: %s at line %d\n",str,yyline);
}
#include "lex.yy.c"
