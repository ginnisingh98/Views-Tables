--------------------------------------------------------
--  DDL for Package Body EC_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_DEBUG" as
/* $Header: ECDEBUGB.pls 120.2 2005/09/28 11:13:11 arsriniv ship $      */

/* This procedure will enable debug messages. ie.  the log file or the report
file of the concurrent request will have detailed messages to help the user
to trouble shoot the problems encountered */

PROCEDURE ENABLE_DEBUG
         (
         i_level               IN   VARCHAR2 DEFAULT 0
         ) is

begin
       G_debug_level := i_level;
end ENABLE_DEBUG;

/* This procedure will disable debug messages. ie.  the log file or the report
file of the concurrent request will not have detailed debug messages */

PROCEDURE DISABLE_DEBUG is
begin
      G_debug_level := 0;
      G_program_stack.DELETE;
end DISABLE_DEBUG;


/* This procedure will split the message into 132 character chunks and prints
it to the log or report file. */

PROCEDURE SPLIT
        (
        i_string                IN      VARCHAR2
        ) is

stemp                           VARCHAR2(80);
nlength                         NUMBER := 1;
begin
       while(length(i_string) >= nlength)
       loop
           stemp := substrb(i_string, nlength, 80);
           fnd_file.put_line(FND_FILE.LOG, INDENT_TEXT(0)||stemp);
           nlength := (nlength + 80);
       end loop;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end SPLIT;

/* This procedure populates the stack table with the program name and the
time it started processing. */

PROCEDURE PUSH
        (
        i_program_name          IN      VARCHAR2
        ) is
ntbl_count               NUMBER;
begin

/* Bug 1853627 - Added the following check to suppress the debug message */

       if G_debug_level >= 2 then
       	ntbl_count := G_program_stack.COUNT + 1;
       	G_program_stack(ntbl_count).program_name := upper(i_program_name);
       	G_program_stack(ntbl_count).timestamp := sysdate;
          fnd_file.put_line(FND_FILE.LOG, INDENT_TEXT(1)|| 'Enter '||i_program_name||'->'||to_char(G_program_stack(ntbl_count).timestamp,  'DD-MON-YYYY HH24:MI:SS'));
       end if;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end PUSH;

/* This procedure extracts data from the stack table and also provides the time
a program took to complete processing. */

PROCEDURE POP
       (
       i_program_name           IN      VARCHAR2
       ) is
nposition                NUMBER;
ntime_taken              NUMBER;
begin
/* Bug 1853627 - Added the following check to suppress the debug message */

       if G_debug_level >= 2
       then
       	  FIND_POS(G_program_stack, i_program_name, nposition);
          ntime_taken := (sysdate - G_program_stack(nposition).timestamp)*(24*60*60);
          fnd_file.put_line(FND_FILE.LOG, INDENT_TEXT(1)|| 'Exit '||G_program_stack(nposition).program_name||'->'||to_char(sysdate,  'DD-MON-YYYY HH24:MI:SS'));
          fnd_file.put_line(FND_FILE.LOG, INDENT_TEXT(1)||'Time Taken '|| round(ntime_taken, 2) || ' seconds' );
       	  G_program_stack.DELETE(nposition);
       end if;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end POP;

/* This function beautifies the output written to the log/report by adding the
appropriate indentation. */

FUNCTION INDENT_TEXT
       (
       i_main                   IN      NUMBER DEFAULT 0
       )
RETURN VARCHAR2 is
vtemp_space    VARCHAR2(500);
begin
   vtemp_space  := rpad(' ', 2*(G_program_stack.COUNT - 1), ' ');
   if i_main = 0 and G_program_stack.COUNT > 0 then
      vtemp_space := vtemp_space || '  ';
   end if;
   return(vtemp_space);

exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end INDENT_TEXT;

/* This is an overloaded procedure to set the tokens and retrieve the fnd
message and print it to the appropriate log/report file. */

PROCEDURE PL
        (
        i_level                 IN      NUMBER default 0,
        i_app_short_name        IN      VARCHAR2,
        i_message_name          IN      VARCHAR2,
        i_token1                IN      VARCHAR2,
        i_value1                IN      VARCHAR2 DEFAULT NULL,
        i_token2                IN      VARCHAR2 DEFAULT NULL,
        i_value2                IN      VARCHAR2 DEFAULT NULL,
        i_token3                IN      VARCHAR2 DEFAULT NULL,
        i_value3                IN      VARCHAR2 DEFAULT NULL,
        i_token4                IN      VARCHAR2 DEFAULT NULL,
        i_value4                IN      VARCHAR2 DEFAULT NULL,
        i_token5                IN      VARCHAR2 DEFAULT NULL,
        i_value5                IN      VARCHAR2 DEFAULT NULL,
        i_token6                IN      VARCHAR2 DEFAULT NULL,
        i_value6                IN      VARCHAR2 DEFAULT NULL
        ) is

begin

    if G_debug_level >= i_level then
        fnd_message.set_name(i_app_short_name,i_message_name);

        if ( i_token1 is not null ) and ( i_value1 is not null ) then
           fnd_message.set_token(i_token1,i_value1);
        end if;
        if ( i_token2 is not null ) and ( i_value2 is not null ) then
           fnd_message.set_token(i_token2,i_value2);
        end if;
        if ( i_token3 is not null ) and ( i_value3 is not null ) then
           fnd_message.set_token(i_token3,i_value3);
        end if;
        if ( i_token4 is not null ) and ( i_value4 is not null ) then
           fnd_message.set_token(i_token4,i_value4);
        end if;
        if ( i_token5 is not null ) and ( i_value5 is not null ) then
           fnd_message.set_token(i_token5,i_value5);
        end if;
        if ( i_token6 is not null ) and ( i_value6 is not null ) then
           fnd_message.set_token(i_token6,i_value6);
        end if;

        fnd_file.put_line(FND_FILE.LOG, INDENT_TEXT(0)||fnd_message.get);
    end if;

exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
END PL;

/* This is an overloaded procedure to split a message string into 132 character
strings. */

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_string                IN      VARCHAR2
        ) is

begin
     if ( G_debug_level >= i_level ) then
        SPLIT(i_string);
     end if;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
END PL;


/* This is an overloaded procedure to concatenate a given variable name and
the date value. */
PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      DATE
        ) is

begin
       if ( G_debug_level >= i_level ) then
          SPLIT(i_variable_name || G_separator || to_char(i_variable_value,
                                                  'DD-MON-YYYY HH24:MI:SS'));
       end if;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end PL;

/* This is an overloaded procedure to concatenate a given variable name and
the number value. */

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      NUMBER
        ) is
begin
       if ( G_debug_level >= i_level ) then
          SPLIT(i_variable_name || G_separator || to_char(i_variable_value));
       end if;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end PL;

/* This is an overloaded procedure to concatenate a given variable name and
the string value. */

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      VARCHAR2
        ) is
begin
       if ( G_debug_level >= i_level ) then
          SPLIT(i_variable_name || G_separator || i_variable_value);
       end if;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end PL;

/* This is an overloaded procedure to concatenate a given variable name and
the boolean value. */

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      BOOLEAN
        ) is
vtemp          VARCHAR2(10) := 'false';
begin
       if ( G_debug_level >= i_level ) then
          if ( i_variable_value ) then
             vtemp := 'true';
          else
             vtemp := 'false';
          end if;
          SPLIT(i_variable_name || G_separator || vtemp);
       end if;
exception
when others then
     EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
     EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
end PL;

/* This procedure finds a program_name in the stack table. */
PROCEDURE FIND_POS
        (
        i_stack_tbl             IN      pl_stack,
        i_search_text           IN      varchar2,
        o_position              IN OUT NOCOPY NUMBER
        )
IS
        cIn_String       VARCHAR2(1000) := UPPER(i_search_text);
        nColumn_count    NUMBER := i_stack_tbl.COUNT;
        bFound           BOOLEAN := FALSE;
        PROG_NOT_FOUND   EXCEPTION;
BEGIN
    for loop_count in reverse 1..nColumn_count
    loop
        if (upper(i_stack_tbl(loop_count).PROGRAM_NAME) = cIn_String) then
           o_position := loop_count;
           bFound := TRUE;
           exit;
        end if;
    end loop;
    if not bFound then
        raise PROG_NOT_FOUND;
    end if;

EXCEPTION
        WHEN PROG_NOT_FOUND THEN
               EC_DEBUG.PL(0,'EC','ECE_PLSQL_PROG_NAME','PROG_NAME', 'cIn_string');
               app_exception.raise_exception;

        WHEN OTHERS THEN
               EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_DEBUG.FIND_POS');
               EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
               EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
               app_exception.raise_exception;

END FIND_POS;

end EC_DEBUG;

/
