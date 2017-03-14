#include <stdlib.h>
#include "lex.yy.c"
#include "token.h"

/* yyline = 1 for numbering lines 1 to n */
int yyline = 1;
int yycolumn = 0;
int yylength = 0;
int yylval = 0;

/* the string table is one block separated by null terminators
 * an int array stores the index of each string
 * access the strings with pointer arithmetic */
char *stringTable;
int stringTableIndices[LIMIT2];
int nStringsStored = 0;
int nCharsStored = 0;

int main(int argc, char *argv[])
{
    int lexReturn;
    int i;
    
    /* initialize string table */
    stringTable = (char *) malloc(LIMIT1 + 1);
    strcpy(stringTable,"");
    
    printf("Line      Column      Token         Index in String Table\n");
    
    /* get tokens and print table */
    do {
        
        lexReturn = yylex();
        
        /* printing line and column here so the switch cases are less wordy */
        if (lexReturn != EOFnum) {
            printf("%-8d  %-12d", yyline, yycolumn);
        }
        
        switch (lexReturn) {
            case ANDnum:
                printf("%-8s\n","ANDnum");
                break;
            case ASSGNnum:
                printf("%-8s\n","ASSGNnum");
                break;
            case DECLARATIONSnum:
                printf("%-8s\n","DECLARATIONSnum");
                break;
            case DOTnum:
                printf("%-8s\n","DOTnum");
                break;
            case ENDDECLARATIONSnum:
                printf("%-8s\n","ENDDECLARATIONSnum");
                break;
            case EQUALnum:
                printf("%-8s\n","EQUALnum");
                break;
            case GTnum:
                printf("%-8s\n","GTnum");
                break;
            case IDnum:
                printf("%-8s      %d\n","IDnum", yylval);
                break;
            case INTnum:
                printf("%-8s\n","INTnum");
                break;
            case LBRACnum:
                printf("%-8s\n","LBRACnum");
                break;
            case LPARENnum:
                printf("%-8s\n","LPARENnum");
                break;
            case METHODnum:
                printf("%-8s\n","METHODnum");
                break;
            case NEnum:
                printf("%-8s\n","NEnum");
                break;
            case ORnum:
                printf("%-8s\n","ORnum");
                break;
            case PROGRAMnum:
                printf("%-8s\n","PROGRAMnum");
                break;
            case RBRACnum:
                printf("%-8s\n","RBRACnum");
                break;
            case RPARENnum:
                printf("%-8s\n","RPARENnum");
                break;
            case SEMInum:
                printf("%-8s\n","SEMInum");
                break;
            case VALnum:
                printf("%-8s\n","VALnum");
                break;
            case WHILEnum:
                printf("%-8s\n","WHILEnum");
                break;
            case CLASSnum:
                printf("%-8s\n","CLASSnum");
                break;
            case COMMAnum:
                printf("%-8s\n","COMMAnum");
                break;
            case DIVIDEnum:
                printf("%-8s\n","DIVIDEnum");
                break;
            case ELSEnum:
                printf("%-8s\n","ELSEnum");
                break;
            case EQnum:
                printf("%-8s\n","EQnum");
                break;
            case GEnum:
                printf("%-8s\n","GEnum");
                break;
            case ICONSTnum:
                printf("%-8s\n","ICONSTnum");
                break;
            case IFnum:
                printf("%-8s\n","IFnum");
                break;
            case LBRACEnum:
                printf("%-8s\n","LBRACEnum");
                break;
            case LEnum:
                printf("%-8s\n","LEnum");
                break;
            case LTnum:
                printf("%-8s\n","LTnum");
                break;
            case MINUSnum:
                printf("%-8s\n","MINUSnum");
                break;
            case NOTnum:
                printf("%-8s\n","NOTnum");
                break;
            case PLUSnum:
                printf("%-8s\n","PLUSnum");
                break;
            case RBRACEnum:
                printf("%-8s\n","RBRACEnum");
                break;
            case RETURNnum:
                printf("%-8s\n","RETURNnum");
                break;
            case SCONSTnum:
                printf("%-8s     %d\n", "SCONSTnum", yylval);
                break;
            case TIMESnum:
                printf("%-8s\n","TIMESnum");
                break;
            case VOIDnum:
                printf("%-8s\n","VOIDnum");
                break;
            case EOFnum:
                printf("%28s\n","EOFnum");
                break;
            default:
                printf("%-8s\n","bad token");
        }

    } while (lexReturn != 0);
    
    /* retrieving string table */
    printf("\nString Table: ");
    if (nCharsStored > 0) {
        for (i=0;i<nStringsStored;i++) {
            printf("%s ",stringTable + stringTableIndices[i]);
        }
    }
    
    printf("\n\nEnd of File\n");
    
    free(stringTable);

return 0;
}
