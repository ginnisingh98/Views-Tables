--------------------------------------------------------
--  DDL for Package Body ECX_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_DEBUG" AS
-- $Header: ECXDEBGB.pls 120.9 2006/05/25 08:38:29 susaha ship $

   g_split_threshold   PLS_INTEGER := 120;
   g_depth             PLS_INTEGER := 0;

   pv_MsgParamSeparator     VARCHAR2(10)    := '#WF#';
   pv_MsgParamSeparatorSize NUMBER  := LENGTH(pv_MsgParamSeparator);
   pv_NameValueSeparator    VARCHAR2(10)    := '=';

   pv_CustMsgSeparator     VARCHAR2(20)    := '#CUST#';
   pv_CustMsgSeparatorSize NUMBER  := LENGTH(pv_CustMsgSeparator);

   -- This variable is used to decide at what log level we finally write the BLOB into the fnd tables.
   pv_LevelToLog  NUMBER;

   --This procedure will enable debug messages. ie.  the log file or the report
   --file of the concurrent request will have detailed messages to help the user
   --to trouble shoot the problems encountered
   PROCEDURE enable_debug(i_level IN VARCHAR2 ) IS

      BEGIN
       g_instlmode := wf_core.translate('WF_INSTALL');

         g_debug_level := i_level;
         g_use_cmanager_flag := TRUE;
         g_depth := 0;
	 g_procedure  := 2;
	 g_statement  := 3;
	 g_unexpected := 0;
	 g_procedureEnabled  := g_debug_level >= g_procedure;
	 g_statementEnabled   := g_debug_level >= g_statement;
	 g_unexpectedEnabled  := g_debug_level >= g_unexpected;

       IF g_instlmode = 'EMBEDDED' THEN
		 g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
		 g_procedure  := FND_LOG.LEVEL_PROCEDURE;
		 g_statement  := FND_LOG.LEVEL_STATEMENT;
		 g_unexpected := FND_LOG.LEVEL_UNEXPECTED;
		 g_procedureEnabled  := g_procedure >= g_debug_level;
		 g_statementEnabled  := g_statement >= g_debug_level;
		 g_unexpectedEnabled := g_unexpected >= g_debug_level;
       END IF;

      END enable_debug;

   PROCEDURE enable_debug_new(
      p_level     IN VARCHAR2 ) IS

      BEGIN
        g_instlmode := wf_core.translate('WF_INSTALL');

         g_debug_level := p_level;
         g_use_cmanager_flag := FALSE;
         g_write_file_flag := FALSE;
         g_depth := 0;
	 g_procedure  := 2;
	 g_statement  := 3;
	 g_unexpected := 0;
	 g_procedureEnabled   := g_debug_level >= g_procedure;
	 g_statementEnabled   := g_debug_level >= g_statement;
	 g_unexpectedEnabled  := g_debug_level >= g_unexpected;
        IF g_instlmode = 'EMBEDDED' THEN
           g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	   g_procedure  := FND_LOG.LEVEL_PROCEDURE;
	   g_statement  := FND_LOG.LEVEL_STATEMENT;
	   g_unexpected := FND_LOG.LEVEL_UNEXPECTED;
	   g_procedureEnabled  := g_procedure >= g_debug_level;
	   g_statementEnabled  := g_statement >= g_debug_level;
	   g_unexpectedEnabled := g_unexpected >= g_debug_level;
           pv_LevelToLog := fnd_log.g_current_runtime_level;
       END IF;

      END enable_debug_new;

   PROCEDURE enable_debug_new(
      p_level     IN VARCHAR2 ,
      p_file_path IN VARCHAR2,
      p_file_name IN VARCHAR2,
      p_aflog_module_name IN VARCHAR2) IS

      BEGIN

         g_use_cmanager_flag := FALSE;
         g_depth := 0;
         IF NOT (g_write_file_flag) THEN
            IF p_file_path IS NOT NULL AND
               p_file_name IS NOT NULL THEN
               g_write_file_flag := TRUE;
               g_file_path := p_file_path;
               g_file_name := p_file_name;
	       g_aflog_module_name := g_sqlprefix || p_aflog_module_name;
            ELSE
               g_write_file_flag := FALSE;
            END IF;
         END IF;

         g_debug_level := p_level;
         g_procedure  := 2;
	 g_statement  := 3;
	 g_unexpected := 0;
	 g_procedureEnabled  := g_debug_level >= g_procedure;
	 g_statementEnabled   := g_debug_level >= g_statement;
	 g_unexpectedEnabled  := g_debug_level >= g_unexpected;

       g_instlmode := wf_core.translate('WF_INSTALL');
       IF g_instlmode = 'EMBEDDED'  THEN
           g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	   g_procedure  := FND_LOG.LEVEL_PROCEDURE;
	   g_statement  := FND_LOG.LEVEL_STATEMENT;
	   g_unexpected := FND_LOG.LEVEL_UNEXPECTED;
	   g_procedureEnabled  := g_procedure >= g_debug_level;
	   g_statementEnabled  := g_statement >= g_debug_level;
	   g_unexpectedEnabled := g_unexpected >= g_debug_level;
           ecx_utils.g_logfile := g_aflog_module_name;
       	   pv_LevelToLog := fnd_log.g_current_runtime_level;
       END IF;
      END enable_debug_new;

   --This procedure will disable debug messages. i.e. the log file or the report
   --file of the concurrent request will not have detailed debug messages
   PROCEDURE disable_debug IS
      BEGIN
--       IF g_instlmode = 'EMBEDDED' THEN
           g_debug_level := 0;
           g_procedureEnabled  := false;
           g_statementEnabled  := false;
           g_unexpectedEnabled := false;
  --         return;
--       ELSE
--         g_debug_level := 0;
         g_file_name := NULL;
         g_aflog_module_name := NULL;
         g_file_path := NULL;
         g_message_stack.DELETE;
         g_use_cmanager_flag := FALSE;
         g_write_file_flag := FALSE;
--      END IF;
      END disable_debug;
PROCEDURE module_enabled IS
      l_standard_code  ecx_standards.standard_code%type;
   begin
    g_v_module_name:=rtrim(g_v_module_name,'.');
    select  standard_code
    into l_standard_code
    from ecx_standards
    where   standard_id = ecx_utils.g_standard_id
    and     standard_type = 'XML';
if l_standard_code is not null then
  g_v_module_name:=g_v_module_name||'.'||l_standard_code;
end if;
if ecx_utils.g_direction is not null then
 g_v_module_name:=g_v_module_name||'.'||ecx_utils.g_direction;
end if;
if ecx_utils.g_transaction_type is not null then
g_v_module_name :=g_v_module_name||'.'||ecx_utils.g_transaction_type;
end if;
if ecx_utils.g_transaction_subtype is not null then
g_v_module_name :=g_v_module_name||'.'||ecx_utils.g_transaction_subtype;
end if;
if ecx_utils.g_document_id is not null then
g_v_module_name:=g_v_module_name||'.'||ecx_utils.g_document_id;
end if;
end;


PROCEDURE module_enabled(p_message_standard IN VARCHAR2 ,p_transaction_type IN VARCHAR2,p_transaction_subtype IN VARCHAR2,p_document_id IN VARCHAR2) IS
   begin
    g_v_module_name:=rtrim(g_v_module_name,'.');
if p_message_standard is not null then
  g_v_module_name:=g_v_module_name||'.'||p_message_standard;
end if;
   g_v_module_name :=g_v_module_name||'.'||'out';
if p_transaction_type is not null then
  g_v_module_name :=g_v_module_name||'.'||p_transaction_type;
end if;
if p_transaction_subtype is not null then
 g_v_module_name :=g_v_module_name||'.'||p_transaction_subtype;
end if;
if p_document_id is not null then
 g_v_module_name:=g_v_module_name||'.'||p_document_id;
end if;
end;
PROCEDURE module_enabled(p_transaction_type IN VARCHAR2,p_transaction_subtype IN VARCHAR2,p_document_id IN VARCHAR2) IS
   begin
    g_v_module_name:=rtrim(g_v_module_name,'.');
   g_v_module_name :=g_v_module_name||'.'||'trig';
if p_transaction_type is not null then
  g_v_module_name :=g_v_module_name||'.'||p_transaction_type;
end if;
if p_transaction_subtype is not null then
 g_v_module_name :=g_v_module_name||'.'||p_transaction_subtype;
end if;
if p_document_id is not null then
 g_v_module_name:=g_v_module_name||'.'||p_document_id;
end if;
end;

   --This procedure will split the message into 80 character chunks and prints
   --it to the log or report file.
   PROCEDURE split(i_string IN VARCHAR2) IS

      stemp       VARCHAR2(32000);
      nlength     PLS_INTEGER  := 1;
      slength     PLS_INTEGER  := 0;
      nmsg_count  PLS_INTEGER;

      BEGIN

         slength := LENGTH(i_string);
         IF (slength > g_split_threshold) THEN
            WHILE (LENGTH(i_string) >= nlength) LOOP
               stemp := SUBSTRB(i_string,nlength,g_split_threshold);

               IF g_use_cmanager_flag THEN   --Use the Concurrent Manager
		  null;
               ELSE                          --Don't use the Concurrent Manager
                  nmsg_count := g_message_stack.COUNT + 1;
                  g_message_stack(nmsg_count).message_text := indent_text(0) || stemp;
               END IF;

               nlength := nlength + g_split_threshold;
            END LOOP;
         ELSE
            IF g_use_cmanager_flag THEN   --Use the Concurrent Manager
	       null;
            ELSE                          --Don't use the Concurrent Manager
               nmsg_count := g_message_stack.COUNT + 1;
               g_message_stack(nmsg_count).message_text := indent_text(0) || i_string;
            END IF;
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,
                        30,
                        ecx_utils.i_errbuf || '- ECX_DEBUG.SPLIT: ' || SQLERRM );
            raise ecx_utils.program_exit;

      END split;

   --This procedure populates the stack table with the program name and the
   --time it started processing.
   PROCEDURE push(i_program_name IN VARCHAR2) IS

      nmsg_count  PLS_INTEGER;

      BEGIN
/*       IF g_instlmode = 'EMBEDDED' THEN
         fnd_log.string(ecx_debug.g_procedure, g_sqlprefix ||i_program_name||'.begin','Enter '|| i_program_name);
       ELSE*/
            g_depth := g_depth + 1;
            IF g_use_cmanager_flag THEN   --Use the Concurrent Manager
	       null;
            ELSE                          --Don't use the Concurrent Manager
               nmsg_count := g_message_stack.COUNT + 1;
               g_message_stack(nmsg_count).message_text := indent_text(1) || 'Enter ' || UPPER(i_program_name);
            END IF;
--         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2, 30, ecx_utils.i_errbuf || '- ECX_DEBUG.PUSH: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END push;

   --This procedure extracts data from the stack table and also provides the time
   --a program took to complete processing.
   PROCEDURE pop(i_program_name IN VARCHAR2) IS

      nmsg_count  PLS_INTEGER;

      BEGIN
/*       IF g_instlmode = 'EMBEDDED' THEN
         fnd_log.string(ecx_debug.g_procedure, g_sqlprefix ||i_program_name||'.end','Exit '||i_program_name);
       ELSE*/
            IF g_use_cmanager_flag THEN   --Use the Concurrent Manager
	       null;
            ELSE
               nmsg_count := g_message_stack.COUNT + 1;
               g_message_stack(nmsg_count).message_text := indent_text(1) || 'Exit ' || i_program_name;
            END IF;
            g_depth := g_depth - 1;
--         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.POP: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END pop;

   --This function beautifies the output written to the log/report by adding the
   --appropriate indentation.
   FUNCTION indent_text(i_main IN PLS_INTEGER ) RETURN VARCHAR2 IS

      vtemp_space   VARCHAR2(500);

      BEGIN
         vtemp_space := RPAD(' ',2 * (g_depth - 1),' ');

         IF i_main = 0 AND
            g_depth > 0 THEN
            vtemp_space := vtemp_space || '  ';
         END IF;

         RETURN (vtemp_space);

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.INDENT_TEXT: ' || SQLERRM);
            raise ecx_utils.program_exit;
      END indent_text;
--This is an overloaded procedure to set the tokens and retrieve the
   --message and print it to the appropriate log/report file.
  --Stubbed versions of pl for bug 5055659
  PROCEDURE pl(
      i_level            IN   PLS_INTEGER ,
      i_app_short_name   IN   VARCHAR2,
      i_message_name     IN   VARCHAR2,
      i_token1           IN   VARCHAR2 ,
      i_value1           IN   VARCHAR2 ,
      i_token2           IN   VARCHAR2 ,
      i_value2           IN   VARCHAR2 ,
      i_token3           IN   VARCHAR2 ,
      i_value3           IN   VARCHAR2 ,
      i_token4           IN   VARCHAR2 ,
      i_value4           IN   VARCHAR2 ,
      i_token5           IN   VARCHAR2 ,
      i_value5           IN   VARCHAR2 ,
      i_token6           IN   VARCHAR2 ,
      i_value6           IN   VARCHAR2 ) IS

      nmsg_count  PLS_INTEGER;

      BEGIN
         IF g_debug_level >= i_level THEN
                null;

            IF i_token1 IS NOT NULL AND
               i_value1 IS NOT NULL THEN
                wf_core.token(i_token1,i_value1);

               IF i_token2 IS NOT NULL AND
                  i_value2 IS NOT NULL THEN
                  wf_core.token(i_token2,i_value2);

                  IF i_token3 IS NOT NULL AND
                     i_value3 IS NOT NULL THEN
                     wf_core.token(i_token3,i_value3);

                     IF i_token4 IS NOT NULL AND
                      i_value4 IS NOT NULL THEN
wf_core.token(i_token4,i_value4);

                        IF i_token5 IS NOT NULL AND
                           i_value5 IS NOT NULL THEN
                           wf_core.token(i_token5,i_value5);

                           IF i_token6 IS NOT NULL AND
                              i_value6 IS NOT NULL THEN
                              wf_core.token(i_token5,i_value5);
                           END IF; -- i_token6
                        END IF; -- i_token5
                     END IF; -- i_token4
                  END IF; -- i_token3
               END IF; -- i_token2
            END IF; -- i_token1

            IF g_use_cmanager_flag THEN   --Use the Concurrent Manager
               null;
            ELSE                          --Don't use the Concurrent Manager
               nmsg_count := g_message_stack.COUNT + 1;
               g_message_stack(nmsg_count).message_text := indent_text(0) || wf_core.translate(i_message_name);
            END IF;
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.PL: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END pl;
  --This is an overloaded procedure to split a message string into 132 character
   --strings.
   PROCEDURE pl(i_level IN PLS_INTEGER,i_string IN VARCHAR2) IS

      BEGIN
         IF (g_debug_level >= i_level) THEN
            split(i_string);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.PL: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END pl;

   --This is an overloaded procedure to concatenate a given variable name and
   --the date value.
   PROCEDURE pl(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   DATE) IS

      BEGIN
         IF (g_debug_level >= i_level) THEN
            split(i_variable_name || g_separator || TO_CHAR(i_variable_value,'DD-MON-YYYY HH24:MI:SS'));
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.PL: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END pl;
--This is an overloaded procedure to concatenate a given variable name and
   --the number value.
   PROCEDURE pl(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   NUMBER) IS

      BEGIN
         IF (g_debug_level >= i_level) THEN
            split(i_variable_name || g_separator || TO_CHAR(i_variable_value));
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.PL: ' || SQLERRM);
            raise ecx_utils.program_exit;
 END pl;
   --This is an overloaded procedure to concatenate a given variable name and
   --the string value.
/*commenting  this pl because it is conflicting with anothe overloaded version having the
  arguments of the same datatype in the same order */
   PROCEDURE pl(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   VARCHAR2) IS

      BEGIN
         IF (g_debug_level >= i_level) THEN
            split(i_variable_name || g_separator || i_variable_value);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.PL: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END pl;
/**Change required for Clob Support -- 2263729 ***/
   --This is an overloaded procedure to concatenate a given variable name and
   --the clob value.
   PROCEDURE pl(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   CLOB) IS

      ctemp              varchar2(32767);
      clength            pls_integer;
      offset            pls_integer := 1;
      g_varmaxlength     pls_integer := 1999;
      BEGIN

         IF (g_debug_level >= i_level) THEN
               clength := dbms_lob.getlength(i_variable_value);
               while  clength >= offset LOOP
                     ctemp :=  dbms_lob.substr(i_variable_value,g_varmaxlength,offset);
 split(i_variable_name || g_separator ||ctemp);
                     offset := offset + g_varmaxlength;
               End Loop;
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.PL: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END pl;
--This is an overloaded procedure to concatenate a given variable name and
   --the boolean value.
   PROCEDURE pl(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   BOOLEAN) IS

      vtemp   VARCHAR2(10) := 'FALSE';

      BEGIN
         IF (g_debug_level >= i_level) THEN
            IF (i_variable_value) THEN
               vtemp := 'TRUE';
            ELSE
               vtemp := 'FALSE';
            END IF;

            split(i_variable_name || g_separator || vtemp);
        END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.PL: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END pl;


   --This is an overloaded procedure to set the tokens and retrieve the
   --message and print it to the appropriate log/report file.
   PROCEDURE log(
      i_level            IN   PLS_INTEGER ,
      i_app_short_name   IN   VARCHAR2,
      i_message_name     IN   VARCHAR2,
      i_program_name     IN   VARCHAR2,
      i_token1           IN   VARCHAR2 ,
      i_value1           IN   VARCHAR2 ,
      i_token2           IN   VARCHAR2 ,
      i_value2           IN   VARCHAR2 ,
      i_token3           IN   VARCHAR2 ,
      i_value3           IN   VARCHAR2 ,
      i_token4           IN   VARCHAR2 ,
      i_value4           IN   VARCHAR2 ,
      i_token5           IN   VARCHAR2 ,
      i_value5           IN   VARCHAR2 ,
      i_token6           IN   VARCHAR2 ,
      i_value6           IN   VARCHAR2
      ) IS

      nmsg_count  PLS_INTEGER;

      BEGIN
	if(i_level = g_unexpected and pv_LevelToLog<g_unexpected) then
	 pv_LevelToLog := g_unexpected;
	end if;

            IF i_token1 IS NOT NULL AND
               i_value1 IS NOT NULL THEN
        	wf_core.token(i_token1,i_value1);

               IF i_token2 IS NOT NULL AND
                  i_value2 IS NOT NULL THEN
        	  wf_core.token(i_token2,i_value2);

                  IF i_token3 IS NOT NULL AND
                     i_value3 IS NOT NULL THEN
        	     wf_core.token(i_token3,i_value3);

                     IF i_token4 IS NOT NULL AND
                        i_value4 IS NOT NULL THEN
        	        wf_core.token(i_token4,i_value4);

                        IF i_token5 IS NOT NULL AND
                           i_value5 IS NOT NULL THEN
        	           wf_core.token(i_token5,i_value5);

                           IF i_token6 IS NOT NULL AND
                              i_value6 IS NOT NULL THEN
        	              wf_core.token(i_token5,i_value5);
                           END IF; -- i_token6
                        END IF; -- i_token5
                     END IF; -- i_token4
                  END IF; -- i_token3
               END IF; -- i_token2
            END IF; -- i_token1
/*           IF g_instlmode = 'EMBEDDED' THEN
                  fnd_log.string(i_level, g_sqlprefix ||i_program_name||'.'||i_message_name,
	                         wf_core.translate(i_message_name));
           ELSE*/
            IF g_use_cmanager_flag THEN   --Use the Concurrent Manager
	       null;
            ELSE                          --Don't use the Concurrent Manager
               nmsg_count := g_message_stack.COUNT + 1;
               g_message_stack(nmsg_count).message_text := indent_text(0) || wf_core.translate(i_message_name);
            END IF;
--         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.LOG: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END log;

   --This is an overloaded procedure to split a message string into 132 character
   --strings.
   PROCEDURE log(i_level IN PLS_INTEGER,i_string IN VARCHAR2,
                i_program_name     IN   VARCHAR2) IS

      BEGIN
	if(i_level = g_unexpected and pv_LevelToLog<g_unexpected) then
	 pv_LevelToLog := g_unexpected;
	end if;
/*         IF g_instlmode = 'EMBEDDED' THEN
	    fnd_log.string(i_level, g_sqlprefix ||i_program_name,
	                   i_string);
         ELSE */
            split(i_string);
--         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.LOG: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END log;

   --This is an overloaded procedure to concatenate a given variable name and
   --the date value.
   PROCEDURE log(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   DATE,
      i_program_name     IN   VARCHAR2) IS

      BEGIN
        if(i_level = g_unexpected and pv_LevelToLog<g_unexpected) then
	 pv_LevelToLog := g_unexpected;
	end if;
/*        IF g_instlmode = 'EMBEDDED' THEN
         fnd_log.string(i_level, g_sqlprefix ||i_program_name||'.'||i_variable_name,
	                i_variable_name||g_separator||TO_CHAR(i_variable_value,'DD-MON-YYYY HH24:MI:SS'));
        ELSE */
         split(i_variable_name || g_separator ||
               TO_CHAR(i_variable_value,'DD-MON-YYYY HH24:MI:SS'));
--         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.LOG: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END log;

   --This is an overloaded procedure to concatenate a given variable name and
   --the number value.
   PROCEDURE log(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   NUMBER,
      i_program_name     IN   VARCHAR2) IS

      BEGIN
        if(i_level = g_unexpected and pv_LevelToLog<g_unexpected) then
	 pv_LevelToLog := g_unexpected;
	end if;
/*        IF g_instlmode = 'EMBEDDED' THEN
         fnd_log.string(i_level, g_sqlprefix ||i_program_name||'.'||i_variable_name,
	                i_variable_name || g_separator || TO_CHAR(i_variable_value));
        ELSE */
            split(i_variable_name || g_separator || TO_CHAR(i_variable_value));
--         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.LOG: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END log;

   --This is an overloaded procedure to concatenate a given variable name and
   --the string value.
   PROCEDURE log(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   VARCHAR2,
      i_program_name     IN   VARCHAR2) IS

      BEGIN
        if(i_level = g_unexpected and pv_LevelToLog<g_unexpected) then
	 pv_LevelToLog := g_unexpected;
	end if;
/*        IF g_instlmode = 'EMBEDDED' THEN
         fnd_log.string(i_level, g_sqlprefix ||i_program_name||'.'||i_variable_name,
	               i_variable_name || g_separator || i_variable_value);
        ELSE */
            split(i_variable_name || g_separator || i_variable_value);
--         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.LOG: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END log;

     /**Change required for Clob Support -- 2263729 ***/
   --This is an overloaded procedure to concatenate a given variable name and
   --the clob value.
   PROCEDURE log(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   CLOB,
      i_program_name     IN   VARCHAR2) IS

      ctemp              varchar2(32767);
      clength            pls_integer;
      offset            pls_integer := 1;
      g_varmaxlength     pls_integer := 1999;
      BEGIN
	if(i_level = g_unexpected and pv_LevelToLog<g_unexpected) then
	 pv_LevelToLog := g_unexpected;
	end if;
/*        IF g_instlmode = 'EMBEDDED' THEN
         return;
        ELSE*/
               clength := dbms_lob.getlength(i_variable_value);
               while  clength >= offset LOOP
                     ctemp :=  dbms_lob.substr(i_variable_value,g_varmaxlength,offset);
                     split(i_variable_name || g_separator ||ctemp);
                     offset := offset + g_varmaxlength;
               End Loop;
--         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.LOG: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END log;

   --This is an overloaded procedure to concatenate a given variable name and
   --the boolean value.
   PROCEDURE log(
      i_level            IN   PLS_INTEGER,
      i_variable_name    IN   VARCHAR2,
      i_variable_value   IN   BOOLEAN,
      i_program_name     IN   VARCHAR2) IS

      vtemp   VARCHAR2(10) := 'FALSE';

      BEGIN
        if(i_level = g_unexpected and pv_LevelToLog<g_unexpected) then
	 pv_LevelToLog := g_unexpected;
	end if;
            IF (i_variable_value) THEN
               vtemp := 'TRUE';
            ELSE
               vtemp := 'FALSE';
            END IF;

/*         IF g_instlmode = 'EMBEDDED' THEN
             fnd_log.string(i_level, g_sqlprefix ||i_program_name||'.'||i_variable_name,
	               i_variable_name || g_separator || vtemp);
         ELSE */
            split(i_variable_name || g_separator || vtemp);
--        END IF;

      EXCEPTION
         WHEN OTHERS THEN
            setErrorInfo(2,30,ecx_utils.i_errbuf || ' ECX_DEBUG.LOG: ' || SQLERRM);
            raise ecx_utils.program_exit;

      END log;


   PROCEDURE print_log IS
      uFile_type              utl_file.file_type;
	attachment_id pls_integer;
      BEGIN
/*      IF g_instlmode = 'EMBEDDED' THEN
             return;
      ELSE */
	/** Check for the Data in the buffer. If empty do not even open a file **/
	if g_message_stack.count = 0
	then
		return;
	elsif g_message_stack.count = 1
	then
		if g_message_stack(1).message_text is null
		then
			return;
		end if;
	end if;

         IF (g_write_file_flag) AND          --Write the file...
		    (NOT g_use_cmanager_flag) AND    --Concurrent Manager is not being used...
		    (g_file_path IS NOT NULL) AND    --Path is not NULL...
		    (g_file_name IS NOT NULL) THEN   --Name is not NULL...
		    --Open the table
		    if ( g_file_path is null or g_file_name is null )   then
			return;
		    else
			IF g_instlmode = 'EMBEDDED' THEN
				fnd_message.set_name('ecx', 'Log File');
				attachment_id := fnd_log.message_with_attachment(pv_LevelToLog, g_aflog_module_name, TRUE);
				if(attachment_id <> -1) then
					FOR loop_count IN 1..g_message_stack.COUNT LOOP
						fnd_log_attachment.writeln(attachment_id, RTRIM(g_message_stack(loop_count).message_text));
					END LOOP;
					fnd_log_attachment.close(attachment_id);
				end if;
			g_aflog_module_name:=null;
			else
				uFile_type := utl_file.fopen(g_file_path,g_file_name,'W');
				FOR loop_count IN 1..g_message_stack.COUNT LOOP
				utl_file.put_line(uFile_type,
					 RTRIM(g_message_stack(loop_count).message_text));
				END LOOP;
				utl_file.fclose(uFile_type);
		        end if;
		    end if;
         END IF;
      EXCEPTION
         WHEN utl_file.write_error THEN
            if (utl_file.is_open(uFile_type)) then
               utl_file.fclose(uFile_type);
            end if;
            setErrorInfo(2,30,'ECX_UTL_WRITE_ERROR' || '- ECX_DEBUG.PRINT_LOG');
            raise ecx_utils.program_exit;

         WHEN utl_file.invalid_path THEN
            setErrorInfo(2,30,
                         'ECX_UTL_INVALID_PATH' || ' - ECX_DEBUG.PRINT_LOG');
            raise ecx_utils.program_exit;

         WHEN utl_file.invalid_operation THEN
            setErrorInfo(2,30,
                          'ECX_UTL_INVALID_OPERATION' || ' - ECX_DEBUG.PRINT_LOG');
            raise ecx_utils.program_exit;

         WHEN OTHERS THEN
            if (utl_file.is_open(uFile_type)) then
               utl_file.fclose(uFile_type);
            end if;
            setErrorInfo(2,30,
                         SQLERRM || ' - ECX_DEBUG.PRINT_LOG');
            raise ecx_utils.program_exit;

      END print_log;

   PROCEDURE head(
      p_output    OUT NOCOPY VARCHAR2,
      p_lines     IN  PLS_INTEGER ,
      p_delimiter IN  VARCHAR2    ) IS

      BEGIN
         IF (g_use_cmanager_flag) THEN
            p_output := NULL;

         ELSE
            p_output := g_message_stack(1).message_text;

            FOR loop_count IN 2..p_lines LOOP
               p_output := p_output || p_delimiter || g_message_stack(loop_count).message_text;
            END LOOP;
         END IF;
      END head;

   PROCEDURE tail(
      p_output    OUT NOCOPY VARCHAR2,
      p_lines     IN  PLS_INTEGER ,
      p_delimiter IN  VARCHAR2    ) IS

      nmsg_count  PLS_INTEGER;

      BEGIN
         IF (g_use_cmanager_flag) THEN
            p_output := NULL;
         ELSE
            nmsg_count := g_message_stack.COUNT;

            p_output := g_message_stack(nmsg_count - p_lines + 1).message_text;

            FOR loop_count IN (nmsg_count - p_lines + 2)..nmsg_count LOOP
               p_output := p_output || p_delimiter || g_message_stack(loop_count).message_text;
            END LOOP;
         END IF;
      END tail;


   --This function sets the tokens and retrieves the translated message.

   FUNCTION getTranslatedMessage(
      i_message_name     IN   VARCHAR2,
      i_token1           IN   VARCHAR2 ,
      i_value1           IN   VARCHAR2 ,
      i_token2           IN   VARCHAR2 ,
      i_value2           IN   VARCHAR2 ,
      i_token3           IN   VARCHAR2 ,
      i_value3           IN   VARCHAR2 ,
      i_token4           IN   VARCHAR2 ,
      i_value4           IN   VARCHAR2 ,
      i_token5           IN   VARCHAR2 ,
      i_value5           IN   VARCHAR2 ,
      i_token6           IN   VARCHAR2 ,
      i_value6           IN   VARCHAR2 ,
      i_token7           IN   VARCHAR2 ,
      i_value7           IN   VARCHAR2 ,
      i_token8           IN   VARCHAR2 ,
      i_value8           IN   VARCHAR2 ,
      i_token9           IN   VARCHAR2 ,
      i_value9           IN   VARCHAR2 ,
      i_token10          IN   VARCHAR2 ,
      i_value10          IN   VARCHAR2 ) return varchar2 IS

      BEGIN

       IF i_token1 IS NOT NULL THEN
        wf_core.token(i_token1,i_value1);

        IF i_token2 IS NOT NULL THEN
         wf_core.token(i_token2,i_value2);

         IF i_token3 IS NOT NULL THEN
          wf_core.token(i_token3,i_value3);

          IF i_token4 IS NOT NULL THEN
           wf_core.token(i_token4,i_value4);

           IF i_token5 IS NOT NULL THEN
            wf_core.token(i_token5,i_value5);

            IF i_token6 IS NOT NULL THEN
             wf_core.token(i_token6,i_value6);

             IF i_token7 IS NOT NULL THEN
              wf_core.token(i_token7,i_value7);

              IF i_token8 IS NOT NULL THEN
               wf_core.token(i_token8,i_value8);

               IF i_token9 IS NOT NULL THEN
                wf_core.token(i_token9,i_value9);

                IF i_token10 IS NOT NULL THEN
                 wf_core.token(i_token10,i_value10);
                END IF; -- i_token10
               END IF; -- i_token9
              END IF; -- i_token8
             END IF; -- i_token7
            END IF; -- i_token6
           END IF; -- i_token5
          END IF; -- i_token4
         END IF; -- i_token3
        END IF; -- i_token2
       END IF; -- i_token1

            return wf_core.translate(i_message_name);


      EXCEPTION
         WHEN OTHERS THEN
           return (i_message_name);
      END getTranslatedMessage;

    /* sets ecx_utils.i_errbuf and the message parameters and values associated*/
    /* with the message in ecx_utils.i_errbuf */
    PROCEDURE setMessage(
                        p_message_name in varchar2,
                        p_token1       in varchar2,
                        p_value1       in varchar2,
                        p_token2       in varchar2,
                        p_value2       in varchar2,
                        p_token3       in varchar2,
                        p_value3       in varchar2,
                        p_token4       in varchar2,
                        p_value4       in varchar2,
                        p_token5       in varchar2,
                        p_value5       in varchar2,
                        p_token6       in varchar2,
                        p_value6       in varchar2,
                        p_token7       in varchar2,
                        p_value7       in varchar2,
                        p_token8       in varchar2,
                        p_value8       in varchar2,
                        p_token9       in varchar2,
                        p_value9       in varchar2,
                        p_token10      in varchar2,
                        p_value10      in varchar2) is

   BEGIN
        if (p_message_name is NULL) then
                return;
        end if;

        if (ecx_utils.g_cust_msg_code is not null) then
           ecx_utils.i_errbuf := ecx_utils.g_cust_msg_code || pv_CustMsgSeparator
                                 || p_message_name;
        else
           ecx_utils.i_errbuf := p_message_name;

        end if;
        ecx_utils.g_cust_msg_code := null;
        ecx_utils.i_errparams := null;

        IF p_token1 IS NOT NULL THEN
        ecx_utils.i_errparams := p_token1 || pv_NameValueSeparator ||
                                 p_value1 || pv_MsgParamSeparator;

        IF p_token2 IS NOT NULL THEN
        ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                 p_token2 || pv_NameValueSeparator ||
                                 p_value2 || pv_MsgParamSeparator ;

         IF p_token3 IS NOT NULL THEN
         ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                  p_token3 || pv_NameValueSeparator ||
                                  p_value3 || pv_MsgParamSeparator ;

          IF p_token4 IS NOT NULL THEN
           ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                    p_token4 || pv_NameValueSeparator ||
                                    p_value4 || pv_MsgParamSeparator ;

           IF p_token5 IS NOT NULL THEN
            ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                     p_token5 || pv_NameValueSeparator ||
                                     p_value5 || pv_MsgParamSeparator;

            IF p_token6 IS NOT NULL THEN
             ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                      p_token6 || pv_NameValueSeparator ||
                                      p_value6 || pv_MsgParamSeparator;
             IF p_token7 IS NOT NULL THEN
              ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                       p_token7 || pv_NameValueSeparator ||
                                       p_value7 || pv_MsgParamSeparator;

              IF p_token8 IS NOT NULL THEN
               ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                        p_token8 || pv_NameValueSeparator ||
                                        p_value8 || pv_MsgParamSeparator ;
               IF p_token9 IS NOT NULL THEN
                ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                        p_token9 || pv_NameValueSeparator ||
                                        p_value9 || pv_MsgParamSeparator ;

                IF p_token10 IS NOT NULL THEN
                 ecx_utils.i_errparams := ecx_utils.i_errparams ||
                                        p_token10 || pv_NameValueSeparator ||
                                        p_value10 || pv_MsgParamSeparator ;
                 END IF; -- p_token10
               END IF; -- p_token9
              END IF; -- p_token8
             END IF; -- p_token7
            END IF; -- p_token6
           END IF; -- p_token5
          END IF; -- p_token4
         END IF; -- p_token3
        END IF; -- p_token2
       END IF; -- p_token1


   EXCEPTION
    when others then
      ecx_utils.i_errbuf := p_message_name;
   END setMessage;

   PROCEDURE setErrorInfo(
                          p_error_code   in pls_integer,
                          p_error_type   in pls_integer,
                          p_errmsg_name  in varchar2,
                          p_token1       in varchar2,
                          p_value1       in varchar2,
                          p_token2       in varchar2,
                          p_value2       in varchar2,
                          p_token3       in varchar2,
                          p_value3       in varchar2,
                          p_token4       in varchar2,
                          p_value4       in varchar2,
                          p_token5       in varchar2,
                          p_value5       in varchar2,
                          p_token6       in varchar2,
                          p_value6       in varchar2,
                          p_token7       in varchar2,
                          p_value7       in varchar2,
                          p_token8       in varchar2,
                          p_value8       in varchar2,
                          p_token9       in varchar2,
                          p_value9       in varchar2,
                          p_token10      in varchar2,
                          p_value10      in varchar2)
    is
    BEGIN
      ecx_utils.i_ret_code := p_error_code;
      ecx_utils.error_type := p_error_type;
      setMessage(p_errmsg_name,p_token1, p_value1,
                 p_token2, p_value2, p_token3, p_value3,
                 p_token4, p_value4, p_token5, p_value5,
                 p_token6, p_value6, p_token7, p_value7,
                 p_token8, p_value8, p_token9, p_value9,
                 p_token10, p_value10);
    EXCEPTION
      when others then
        setErrorInfo(2,30,'ECX_ERROR_NOT_SET');
    END setErrorInfo;


    PROCEDURE parseErrorParams(
      p_message        in varchar2,
      p_message_params in varchar2,
      o_trans_msg      out nocopy varchar2)
    is
    l_temp_1        ecx_error_msgs.message_parameters%TYPE;
    l_temp_2        ecx_error_msgs.message_parameters%TYPE;
    l_name          ecx_error_msgs.message_parameters%TYPE;
    l_value         ecx_error_msgs.message_parameters%TYPE;
    l_offset        NUMBER;
    l_offset1       NUMBER;
    l_last_offset   NUMBER;
    l_custom_msg    boolean := false;
    l_product_code  varchar2(20);
    l_message       varchar2(2000) := null;
    l_message_code  varchar2(2000) := null;

    begin
       if ((p_message not like 'ECX%') and (p_message not like 'WF%')) then
          if(wf_core.translate('WF_INSTALL') = 'EMBEDDED') then
            l_product_code := substr(p_message, 1,
                                     (instr(p_message, pv_CustMsgSeparator) - 1));
            if l_product_code is null then
            o_trans_msg:=p_message;
            return;
            end if;
            l_custom_msg := true;
            l_message := substr(p_message,
                    instr(p_message, pv_CustMsgSeparator)+ pv_CustMsgSeparatorSize);

	/* We are shipping spec for standalone */

	/* bug 3348967 l_message should be substr to length 30 as second parameter of set_name procedure
	is asssigned to a variable which is defined as varchar2(30) */
	l_message_code := substr(l_message, 1,30);
            fnd_message.set_name(l_product_code, l_message_code);
          end if;
       end if;

       if p_message_params is not null then
                -- p_errparame should be of format:
                -- 'MAP_ID=25#WF#MAP_CODE=ECX_TEST#WF#'
                l_last_offset := 1;
                l_temp_1 := p_message_params;

                for i in 1..10 loop
                  l_offset := INSTR (l_temp_1, pv_MsgParamSeparator, 1, i);
                  if (l_offset <> 0) then
                     l_temp_2 := substr (l_temp_1, l_last_offset,
                                         l_offset-l_last_offset);
                     l_offset1 := INSTR (l_temp_2, pv_NameValueSeparator);
                     if (l_offset1 <> 0) then
                         l_name := substr (l_temp_2, 1, l_offset1-1);
                         l_value := substr (l_temp_2, l_offset1+1);
                         if (l_custom_msg) then
                            fnd_message.set_token(l_name,l_value);
                         else
                            wf_core.token (l_name, l_value);
                         end if;
                     else
                         -- error, = missing between name, value
                         exit;
                     end if;
                     l_last_offset := l_offset+pv_MsgParamSeparatorSize;
                  else
                     -- No more tags
                     exit;
                  end if;
                end loop;
        end if;

        if (l_custom_msg) then
           o_trans_msg := fnd_message.get();

           -- if the fnd_message.get returns the same as the message code
           -- passed in, then the message code is not defined in fnd
           -- messages and we have to return back the original
           -- message as the output.
           if o_trans_msg = l_message_code then
              o_trans_msg := l_message;
           end if;
        else
           o_trans_msg := wf_core.translate(p_message);
        end if;
    end parseErrorParams;

    FUNCTION getMessage(
      p_message_name     IN   VARCHAR2,
      p_message_params   IN   VARCHAR2
    ) return varchar2
     is
      l_message_text varchar2(4000) := null;
     begin
        parseErrorParams(p_message_name, p_message_params, l_message_text);
        return l_message_text;
     end getMessage;

     PROCEDURE getdebugLevels(
       l_statement OUT NOCOPY integer,
       l_procedure OUT NOCOPY integer
     )
     is
     begin
      l_statement := g_statement;
      l_procedure := g_procedure;
     end getdebugLevels;

     PROCEDURE print_debug_spool(p_debug_array IN ECX_DBG_ARRAY_TYPE)
     is
       l_array_val varchar2(2000);
       l_message varchar2(2000);
       l_temp varchar2(100);
       l_pgm_name varchar2(100);
       l_idx number;
       l_idx1 number;
     begin
       for i in 1 .. p_debug_array.count
       loop
         l_array_val := p_debug_array(i);
         l_idx := instr(l_array_val,'#');
         l_temp := substr(l_array_val,1,l_idx-1);
	 if(l_temp = 'STMT') then
	    l_idx := l_idx + 1;
	    l_idx1 := instr(l_array_val,'#',1,2);
	    l_pgm_name := substr(l_array_val,l_idx,(l_idx1-l_idx));
	    l_idx1 := l_idx1 + 1;
	    l_message := substr(l_array_val,l_idx1);
	    log(g_statement,l_message,l_pgm_name);
	 end if;
	 if(l_temp = 'PUSH') then
	    l_idx := l_idx + 1;
	    l_pgm_name := substr(l_array_val,l_idx);
	    push(l_pgm_name);
	 end if;
	 if(l_temp = 'POP') then
	    l_idx := l_idx + 1;
	    l_pgm_name := substr(l_array_val,l_idx);
	    pop(l_pgm_name);
	 end if;
       end loop;
    end print_debug_spool;

END ECX_DEBUG;



/
