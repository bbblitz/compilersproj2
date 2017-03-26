%{
#include  "proj2.h"
#include  <stdio.h>

  tree type_record, type_method, argtype, bractemp, type_tree; 

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

%type  <tptr>  ArrayInitializer ArrayInitializer_l BracSet
%type  <tptr>  ArrayCreationExpression ArrayCreationExpression_l 
%type  <tptr>  ArrayExpression AssignmentStatement MethodCallStatement
%type  <tptr>  Expression Factor UnsignedConstant SimpleExpression
%type  <tptr>  Program ClassDecl_l ClassDecl ClassBody MethodDecl_l 
%type  <tptr>  MaybeMethodDecl MethodDecl Type Type_l FormalParameterList 
%type  <tptr>  FormalParameterList_l FormalParameter 
%type  <tptr>  FormalParameter_l Block StatementList StatementList_l
%type  <tptr>  Statement Decls FieldDecl_l FieldDecl FieldDecl_l
%type  <tptr>  FieldDecl_Id VariableDeclId BracSet VariableInitializer 
%type  <tptr>  ParameterList ReturnStatement IfStatement WhileStatement
%type  <tptr>  SimpleExpression_l_l SimpleExpression_l Term Term_l_l
%type  <tptr>  Term_l Variable Variable_l Field Index Index_l



%%/* yacc specification*/
Program	: PROGRAMnum IDnum SEMInum ClassDecl_l{ 
        $$ = MakeTree(ProgramOp, $4, MakeLeaf(IDNode, $2)); 
        printtree($$, 0);
	};

ClassDecl_l : ClassDecl                       {
	    $$ = MakeTree(ClassOp, NullExp(), $1);
	  } | ClassDecl_l ClassDecl{
	    $$ = MakeTree(ClassOp, $1, $2);
	  };

ClassDecl : CLASSnum IDnum ClassBody{
	  $$ = MakeTree(ClassDefOp, $3, MakeLeaf(IDNode, $2));
	};

ClassBody : LBRACEnum Decls MethodDecl_l RBRACEnum{
		if ($3 == NullExp()) {
			$$ = $2;
		}else{
			$$ = MkLeftC($2, $3);
		}
	};

MethodDecl_l : MaybeMethodDecl{
	     $$ = $1;
	   } | MethodDecl_l MethodDecl{
	     $$ = MakeTree(BodyOp, $1, $2);
	   };

MaybeMethodDecl : /* Empty */{
		$$ = NullExp();
	      } | MethodDecl {
		$$ = MakeTree(BodyOp, NullExp(), $1);
	      };

MethodDecl : METHODnum Type IDnum LPARENnum FormalParameterList RPARENnum Block{
	   $$ = MakeTree(MethodOp,
	   		 MakeTree(HeadOp,
			 	  MakeLeaf(IDNode, $3), 
				  $5
			 ),
			 $7
		);
	 } | METHODnum VOIDnum {type_tree = NullExp();} IDnum LPARENnum FormalParameterList RPARENnum Block {
	   $$ = MakeTree(MethodOp,
	   		 MakeTree(HeadOp, 
			 	  MakeLeaf(IDNode, $4),
				  $6
			 ),
			 $8);
	 };

Type : IDnum Type_l{
     $$ = type_tree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2);
   } | INTnum Type_l {
     $$ = type_tree = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, $1), $2);
   } | IDnum Type_l DOTnum Type {
	tree typeTree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2);
     $$ = type_tree = MkRightC(
				  MakeTree(FieldOp, $4, NullExp()),
				  MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2)
		              ); 
   } | INTnum Type_l DOTnum Type {
				tree typeTree = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, $1), $2);
				/* This code creates a tree that looks like the assignment pdf */
				tree fieldTree = MakeTree(FieldOp, $4, NullExp());
      $$ = type_tree = MkRightC(MakeTree(FieldOp, $4, NullExp()), 
				MakeTree(TypeIdOp,
					 MakeLeaf(INTEGERTNode, $1),
					 $2)
			       );
   };

Type_l : /* Empty */{
       $$ = type_tree = NullExp();
     } | LBRACnum RBRACnum {
       $$ = type_tree = MakeTree(IndexOp, NullExp(), NullExp());
     } | Type_l LBRACnum RBRACnum {
       $$ = type_tree = MakeTree(IndexOp, NullExp(), $1);
     };

FormalParameterList : /* Empty */{
		    $$ = MakeTree(SpecOp, NullExp(), type_tree);
		  } | FormalParameterList_l{
		    $$ = MakeTree(SpecOp, $1, type_tree);
		  };

FormalParameterList_l : FormalParameter{
		      $$ = $1;
		    } | FormalParameter SEMInum FormalParameterList_l{
		      $$ = MkRightC($3, $1);
		    };	

FormalParameter : VALnum INTnum FormalParameter_l {
		$$ = MakeVal($3);
	      }	| INTnum FormalParameter_l {
		$$ = $2;
	      };

FormalParameter_l : IDnum{
				tree idTree = MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0));
		  $$ = MakeTree(RArgTypeOp, 
		  		MakeTree(CommaOp,
					 MakeLeaf(IDNode, $1),
					 MakeLeaf(INTEGERTNode, 0)
				), 
				NullExp()
			       );
		} | IDnum COMMAnum FormalParameter_l{
				tree idTree = MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0));
				tree formalParameter = MakeTree(RArgTypeOp, idTree, NullExp());
		  $$ = MkRightC($3,
				MakeTree(RArgTypeOp,
					 MakeTree(CommaOp,
					 	  MakeLeaf(IDNode, $1),
						  MakeLeaf(INTEGERTNode, 0)
					 ),
					 NullExp()
				)
		       );
		};

Block : StatementList {
      $$ = MakeTree(BodyOp, NullExp(), $1);
    } | Decls StatementList {
      $$ = MakeTree(BodyOp, $1, $2);
    };

StatementList : LBRACEnum StatementList_l RBRACEnum{
	      $$ = $2;
	    };

StatementList_l : Statement {	
		$$ = MakeTree(StmtOp, NullExp(), $1);
	      } | StatementList_l SEMInum Statement {	
		if ($3 == NullExp()) $$ = $1;
		else $$ = MakeTree(StmtOp, $1, $3);
	      };

Statement : /* Empty */{
	  $$ = NullExp();
	} | AssignmentStatement{
	  $$ = $1;
	} | MethodCallStatement{
	  $$ = $1;
	} | ReturnStatement{
	  $$ = $1;
	} | IfStatement{
	  $$ = $1;
	} | WhileStatement{
	  $$ = $1;
	};

Decls : /* Empty */ {
      $$ = NullExp();
    } | DECLARATIONSnum FieldDecl_l ENDDECLARATIONSnum {
      $$ = $2;
    };

FieldDecl_l : /* Empty */{
	    $$ = NullExp();
	  } | FieldDecl {
	    $$ = MakeTree(BodyOp, NullExp(), $1);
	  } | FieldDecl_l FieldDecl{
	    $$ = MakeTree(BodyOp, $1, $2);
	  };

FieldDecl : Type FieldDecl_l SEMInum{
	  $$ = $2;
	};

FieldDecl_l : FieldDecl_Id{
	    $$ = MakeTree(DeclOp, NullExp(), $1);
	  } | FieldDecl_l COMMAnum FieldDecl_Id {
	    $$ = MakeTree(DeclOp, $1, $3);
	  };

FieldDecl_Id : VariableDeclId{
	     $$ = MakeTree(CommaOp, $1,MakeTree(CommaOp, type_tree, NullExp()));
	   } | VariableDeclId EQUALnum VariableInitializer {
	     $$ = MakeTree(CommaOp, $1,MakeTree(CommaOp, type_tree, $3));
	   };

VariableDeclId : IDnum {
	       $$ = MakeLeaf(IDNode, $1);
	     } | IDnum BracSet {
	       $$ = MakeLeaf(IDNode, $1);
	     };

BracSet : LBRACnum RBRACnum{
	    $$ = $$;
	  } | BracSet LBRACnum RBRACnum {
	    $$ = $$;
	  };

VariableInitializer : Expression{
		    $$ = $1;
		  } | ArrayInitializer{
		    $$ = $1;
		  } | ArrayCreationExpression{
		    $$ = $1;
		  };

ArrayInitializer : LBRACEnum ArrayInitializer_l RBRACEnum{
		 $$ = MakeTree(ArrayTypeOp, $2, type_tree);
	       };

ArrayInitializer_l : Expression {
		   $$ = MakeTree(CommaOp, NullExp(), $1);
		 } | ArrayInitializer_l COMMAnum Expression{
		   $$ = MakeTree(CommaOp, $1, $3);
		 };

ArrayCreationExpression : INTnum ArrayCreationExpression_l{
			$$ = MakeTree(ArrayTypeOp,
				      $2,
				      MakeLeaf(INTEGERTNode, $1)
			     );
			};

ArrayCreationExpression_l : ArrayExpression{
			  $$ = MakeTree(BoundOp, NullExp(), $1);
			} | ArrayCreationExpression_l ArrayExpression{
			  $$ = MakeTree(BoundOp, $1, $2);
			};

ArrayExpression : LBRACnum Expression RBRACnum{
		$$ = $2;
	      };

AssignmentStatement : Variable ASSGNnum Expression{
				tree assignOp = MakeTree(AssignOp, NullExp(), $1);
		    $$ = MakeTree(AssignOp,
		    		  MakeTree(AssignOp, NullExp(), $1),
				  $3
			 );
		  };

MethodCallStatement : Variable LPARENnum ParameterList RPARENnum{
		    $$ = MakeTree(RoutineCallOp, $1, $3);
		  };

ParameterList : /* Empty */{
	      $$ = NullExp();
	    } | Expression {
	      $$ = MakeTree(CommaOp, $1, NullExp());
	    } | Expression COMMAnum ParameterList {
	      $$ = MakeTree(CommaOp, $1, $3);
	    };

ReturnStatement : RETURNnum{
		$$ = MakeTree(ReturnOp, NullExp(), NullExp());
	      } | RETURNnum Expression {
		$$ = MakeTree(ReturnOp, $2, NullExp());
	      };

IfStatement : IFnum Expression StatementList{
				tree commaTree = MakeTree(CommaOp, $2, $3);
	    $$ = MakeTree(IfElseOp, NullExp(), MakeTree(CommaOp, $2, $3));
	  } | IFnum Expression StatementList ELSEnum StatementList{
	     $$ = MakeTree(IfElseOp,
	     		   MakeTree(IfElseOp,
			   	    NullExp(),
				    MakeTree(CommaOp, $2, $3)),
			   $5);	
	  };

WhileStatement : WHILEnum Expression StatementList{
	       $$ = MakeTree(LoopOp, $2, $3);
	     };

Expression : SimpleExpression{
	   $$ = $1;
	 } | SimpleExpression LTnum SimpleExpression {
	   $$ = MakeTree(LTOp, $1, $3);
	 } | SimpleExpression LEnum SimpleExpression {
	   $$ = MakeTree(LEOp, $1, $3);
	 } | SimpleExpression EQnum SimpleExpression {
	   $$ = MakeTree(EQOp, $1, $3);
	 } | SimpleExpression NEnum SimpleExpression {
	   $$ = MakeTree(NEOp, $1, $3);
	 } | SimpleExpression GEnum SimpleExpression {
	   $$ = MakeTree(GEOp, $1, $3);
	 } | SimpleExpression GTnum SimpleExpression {
	   $$ = MakeTree(GTOp, $1, $3);
	 };

Factor : UnsignedConstant {
       $$ = $1;
     } | Variable {
       $$ = $1;
     } | MethodCallStatement {
       $$ = $1;
     } | LPARENnum Expression RPARENnum {
       $$ = $2;
     } | NOTnum Factor {
       $$ = MakeTree(NotOp, $2, NullExp());
     };

UnsignedConstant : ICONSTnum {
		 $$ = MakeLeaf(NUMNode, $1);
	       } | SCONSTnum {
		 $$ = MakeLeaf(STRINGNode, $1);
	       };

SimpleExpression : Term SimpleExpression_l_l {
		   if ($2 == NullExp()) $$ = $1;
		   else  $$ = MkLeftC($1, $2);
				
	       } | PLUSnum Term SimpleExpression_l_l {
		   if ($3 == NullExp()) $$ = $2;
		   else $$ = MkLeftC($2, $3);
	       } | MINUSnum Term SimpleExpression_l_l {
		   if ($3 == NullExp()) $$ = MakeTree(UnaryNegOp, $2, NullExp());
		   else $$ = MkLeftC(neg, $3);
	       };

SimpleExpression_l_l : /* Empty */{
		     $$ = NullExp();
		   } | SimpleExpression_l SimpleExpression_l_l {
		       if ($2 == NullExp()) $$ = $1;
		       else $$ = MkLeftC($1, $2);
		   };

SimpleExpression_l : PLUSnum Term{
		   $$ = MakeTree(AddOp, NullExp(), $2);
		 } | MINUSnum Term{
		   $$ = MakeTree(SubOp, NullExp(), $2);
		 } | ORnum Term {
		   $$ = MakeTree(OrOp, NullExp(), $2);
		 };

Term : Factor Term_l_l{
       if ($2 == NullExp()) $$ = $1;
       else $$ = MkLeftC($1, $2);
    };

Term_l_l : /* Empty */{
	 $$ = NullExp();
       } | Term_l Term_l_l {
	   if ($2 == NullExp()) $$ = $1;
	   else $$ = MkLeftC($1, $2);
       };

Term_l : TIMESnum Factor{
       $$ = MakeTree(MultOp, NullExp(), $2);
     } | DIVIDEnum Factor{
       $$ = MakeTree(DivOp, NullExp(), $2);
     } | ANDnum Factor{
       $$ = MakeTree(AndOp, NullExp(), $2);
     };

Variable : IDnum Variable_l{
	 $$ = MakeTree(VarOp, MakeLeaf(IDNode, $1), $2);
       };

Variable_l : /* Empty */{
	   $$ = NullExp();
	 } | Index Variable_l{
	   $$ = MakeTree(SelectOp, $1, $2);
	 } | Field Variable_l {
	   $$ = MakeTree(SelectOp, $1, $2);
	 };

Field : DOTnum IDnum{
      $$ = MakeTree(FieldOp, MakeLeaf(IDNode, $2), NullExp());
    };

Index : LBRACnum Index_l RBRACnum{
      $$ = $2;
    };

Index_l : Expression{
	$$ = MakeTree(IndexOp, $1, NullExp());
      } | Expression COMMAnum Index_l {
	$$ = MakeTree(IndexOp, $1, $3);
      };
%%

int yycolumn, yyline;

FILE *treelst;

main()
{
  treelst = stdout;
  yyparse();
}

yyerror(char *str)
{
  printf("yyerror: %s at line %d\n", str, yyline);
}

#include "lex.yy.c"

