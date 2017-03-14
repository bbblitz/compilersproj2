%{
#include <stdlib.h>
#include "token.h"

extern int yycolumn, yylength, yyline, yylval;

extern char *stringTable;
extern int stringTableIndices[];
extern int nStringsStored;
extern int nCharsStored;

/* functions */
void ReportError(char *, int, int);
int getStrTableIndex(char *, int, int);
void RemoveQuotes(char *);

%}

/* regular definitions */

id            ([a-zA-Z])+
delim         [ \t]
ws            {delim}+
newline       [\n]

%%
{newline}                                                           {yyline++; yycolumn=0;}
{ws}                                                                {yycolumn+=yyleng;}
"/*"([^*]|[ \t\n]|(\*+([^*/]|[ \t\n])))*                            {ReportError("comment doesn't terminate",yyline,yycolumn);}
"/*"([^*]|[ \t\n]|(\*+([^*/]|[ \t\n])))*"*"+"/"                     {yycolumn+=yyleng;};

"&&"                                                                {yycolumn+=yyleng; return (ANDnum);}
":="                                                                {yycolumn+=yyleng; return (ASSGNnum);}
[dD][eE][cC][lL][aA][rR][aA][tT][iI][oO][nN][sS]                    {yycolumn+=yyleng; return (DECLARATIONSnum);}
"."                                                                 {yycolumn+=yyleng; return (DOTnum);}
[eE][nN][dD][dD][eE][cC][lL][aA][rR][aA][tT][iI][oO][nN][sS]        {yycolumn+=yyleng; return (ENDDECLARATIONSnum);}
"="                                                                 {yycolumn+=yyleng; return (EQUALnum);}
">"                               {yycolumn+=yyleng; return (GTnum);}
[iI][nN][tT]                      {yycolumn+=yyleng; return (INTnum);}
"["                               {yycolumn+=yyleng; return (LBRACnum);}
"("                               {yycolumn+=yyleng; return (LPARENnum);}
[mM][eE][tT][hH][oO][dD]          {yycolumn+=yyleng; return (METHODnum);}
"!="                              {yycolumn+=yyleng; return (NEnum);}
"||"                              {yycolumn+=yyleng; return (ORnum);}
[pP][rR][oO][gG][rR][aA][mM]      {yycolumn+=yyleng; return (PROGRAMnum);}
"]"                               {yycolumn+=yyleng; return (RBRACnum);}
")"                               {yycolumn+=yyleng; return (RPARENnum);}
";"                               {yycolumn+=yyleng; return (SEMInum);}
[vV][aA][lL]                      {yycolumn+=yyleng; return (VALnum);}
[wW][hH][iI][lL][eE]              {yycolumn+=yyleng; return (WHILEnum);}
[cC][lL][aA][sS][sS]              {yycolumn+=yyleng; return (CLASSnum);}
","                               {yycolumn+=yyleng; return (COMMAnum);}
"/"                               {yycolumn+=yyleng; return (DIVIDEnum);}
[eE][lL][sS][eE]                  {yycolumn+=yyleng; return (ELSEnum);}
"=="                              {yycolumn+=yyleng; return (EQnum);}
">="                              {yycolumn+=yyleng; return (GEnum);}
[iI][fF]                          {yycolumn+=yyleng; return (IFnum);}
"{"                               {yycolumn+=yyleng; return (LBRACEnum);}
"<="                              {yycolumn+=yyleng; return (LEnum);}
"<"                               {yycolumn+=yyleng; return (LTnum);}
"-"                               {yycolumn+=yyleng; return (MINUSnum);}
"!"                               {yycolumn+=yyleng; return (NOTnum);}
"+"                               {yycolumn+=yyleng; return (PLUSnum);}
"}"                               {yycolumn+=yyleng; return (RBRACEnum);}
[rR][eE][tT][uU][rR][nN]          {yycolumn+=yyleng; return (RETURNnum);}
"*"                               {yycolumn+=yyleng; return (TIMESnum);}
[vV][oO][iI][dD]                  {yycolumn+=yyleng; return (VOIDnum);}

'(.|[ \t])*'                      {RemoveQuotes(yytext); yylval = getStrTableIndex(yytext,yyline,yycolumn); yycolumn+=yyleng; return (SCONSTnum);}
'(.|[ \t\n])*'                    {ReportError("string constant crosses line boundary",yyline,yycolumn); yyline++; yycolumn=0;}
[1-9][0-9]*                       {yylval = atoi(yytext); yycolumn+=yyleng; return (ICONSTnum);}
[0-9][a-zA-Z0-9]*                 {ReportError("identifier starting with a digit",yyline,yycolumn); yycolumn+=yyleng;}
[a-zA-Z][a-zA-Z0-9]*              {yylval = getStrTableIndex(yytext,yyline,yycolumn); yycolumn+=yyleng; return (IDnum);}


%%

void ReportError(char *message,int line, int column) {
    fprintf( stderr, "\nError at line %d, column %d (first char): %s\n\n", line, column, message);
    return;
}

int getStrTableIndex(char *string, int line, int column) {
    int i;
    
    /* use index array to search table for string*/
    for (i=0; i < nStringsStored; i++) {
        /* return index if found */
        if (strcmp(string, stringTable + stringTableIndices[i]) == 0) {
            return stringTableIndices[i];
        }
    }
    
    /* error if string table is full */
    if (nStringsStored == LIMIT1) {
        ReportError("can't add string to string table: max character count.",line, column);
        return -1;
    }
    
    /* error if index table is full */
    if (nStringsStored == LIMIT2) {
        ReportError("can't add string to string table: max number of unique strings",line, column);
        return -1;
    }
    
    /* add string to table if not full and return index */
    stringTableIndices[i] = nCharsStored;
    memcpy(stringTable + stringTableIndices[i],string,strlen(string)+1);
    nCharsStored+=strlen(string)+1;
    nStringsStored++;
    
    return stringTableIndices[i];
}

/* this lexer detects string constants by their quotes, so yytext includes them
 * even though they aren't really part of the string 
 * so this removes them */
void RemoveQuotes(char *string) {
    memmove(string, string+1, strlen(string));
    string[strlen(string) - 1] = '\0';
    
    return;
}
