--------------------------------------------------------
--  DDL for Package ECX_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_DEBUG" AUTHID CURRENT_USER AS
-- $Header: ECXDEBGS.pls 120.6 2006/05/24 16:44:14 susaha ship $

   TYPE prg_msg_stack_record IS RECORD(
      message_text   VARCHAR2(32000));

   TYPE pl_stack_msg IS TABLE OF prg_msg_stack_record
      INDEX BY BINARY_INTEGER;

   g_debug_level       PLS_INTEGER   := 0;
   g_file_name         VARCHAR2(80);
   g_file_path         VARCHAR2(80);
 g_sqlprefix             VARCHAR2(200)    := 'ecx.plsql.';
  g_aflog_module_name         VARCHAR2(2000) ;
  g_message_stack     pl_stack_msg;
   g_separator         VARCHAR2(3)   := '==>';
   g_use_cmanager_flag BOOLEAN       := FALSE;
   g_write_file_flag   BOOLEAN       := FALSE;
   g_instlmode         VARCHAR2(100);
   g_procedure         PLS_INTEGER;
   g_statement         PLS_INTEGER;
   g_unexpected        PLS_INTEGER;
   g_procedureEnabled   boolean;
   g_statementEnabled   boolean;
   g_unexpectedEnabled  boolean;
   g_v_module_name varchar2(240) :='ecx.plsql.';
   PROCEDURE enable_debug(i_level IN VARCHAR2 DEFAULT 0);

   PROCEDURE enable_debug_new(p_level IN VARCHAR2 DEFAULT 0);

   PROCEDURE enable_debug_new(
      p_level     IN VARCHAR2 DEFAULT 0,
      p_file_path IN VARCHAR2,
      p_file_name IN VARCHAR2,
      p_aflog_module_name IN VARCHAR2);

   PROCEDURE disable_debug;


--This procedure is for Inbound logging.This will be called after assigning all the respective global varables.
   PROCEDURE  module_enabled;
--This procedure is for Outbound logging. In Ecx_Outbound.Getxml this procedure will be called first to create the global virtual module name.
   PROCEDURE  module_enabled(p_message_standard IN VARCHAR2 ,p_transaction_type IN VARCHAR2,p_transaction_subtype IN VARCHAR2,p_document_id IN VARCHAR2);
--This procedure is for ecx_document.send and senddirect
 PROCEDURE  module_enabled(p_transaction_type IN VARCHAR2,p_transaction_subtype IN VARCHAR2,p_document_id IN VARCHAR2);
   PROCEDURE split(i_string IN VARCHAR2);

   PROCEDURE push(i_program_name IN VARCHAR2);

   PROCEDURE pop(i_program_name IN VARCHAR2);

   FUNCTION indent_text(i_main IN PLS_INTEGER DEFAULT 0) RETURN VARCHAR2;
--Stubbed versions of pl for bug 5055659
 PROCEDURE pl(
      i_level          IN PLS_INTEGER DEFAULT 0,
      i_app_short_name IN VARCHAR2,
      i_message_name   IN VARCHAR2,
      i_token1         IN VARCHAR2    ,
      i_value1         IN VARCHAR2    DEFAULT NULL,
      i_token2         IN VARCHAR2    DEFAULT NULL,
      i_value2         IN VARCHAR2    DEFAULT NULL,
      i_token3         IN VARCHAR2    DEFAULT NULL,
      i_value3         IN VARCHAR2    DEFAULT NULL,
      i_token4         IN VARCHAR2    DEFAULT NULL,
      i_value4         IN VARCHAR2    DEFAULT NULL,
      i_token5         IN VARCHAR2    DEFAULT NULL,
      i_value5         IN VARCHAR2    DEFAULT NULL,
      i_token6         IN VARCHAR2    DEFAULT NULL,
      i_value6         IN VARCHAR2    DEFAULT NULL);

PROCEDURE pl(i_level IN PLS_INTEGER,i_string IN VARCHAR2);

PROCEDURE pl(
      i_level          IN PLS_INTEGER,
      i_variable_name  IN VARCHAR2,
      i_variable_value IN DATE);

   PROCEDURE pl(
     i_level          IN PLS_INTEGER,
     i_variable_name  IN VARCHAR2,
     i_variable_value IN NUMBER );

    PROCEDURE pl(
      i_level          IN PLS_INTEGER,
      i_variable_name  IN VARCHAR2,
      i_variable_value IN VARCHAR2);

   PROCEDURE pl(
     i_level          IN PLS_INTEGER,
     i_variable_name  IN VARCHAR2,
     i_variable_value IN BOOLEAN);
   PROCEDURE pl(
     i_level          IN PLS_INTEGER,
     i_variable_name  IN VARCHAR2,
     i_variable_value IN CLOB);

--End of stubbed versions

   PROCEDURE log(
      i_level          IN PLS_INTEGER DEFAULT 0,
      i_app_short_name IN VARCHAR2,
      i_message_name   IN VARCHAR2,
      i_program_name   IN VARCHAR2,
      i_token1         IN VARCHAR2    ,
      i_value1         IN VARCHAR2    DEFAULT NULL,
      i_token2         IN VARCHAR2    DEFAULT NULL,
      i_value2         IN VARCHAR2    DEFAULT NULL,
      i_token3         IN VARCHAR2    DEFAULT NULL,
      i_value3         IN VARCHAR2    DEFAULT NULL,
      i_token4         IN VARCHAR2    DEFAULT NULL,
      i_value4         IN VARCHAR2    DEFAULT NULL,
      i_token5         IN VARCHAR2    DEFAULT NULL,
      i_value5         IN VARCHAR2    DEFAULT NULL,
      i_token6         IN VARCHAR2    DEFAULT NULL,
      i_value6         IN VARCHAR2    DEFAULT NULL);


   PROCEDURE log(i_level IN PLS_INTEGER,i_string IN VARCHAR2,
                i_program_name   IN VARCHAR2);

   PROCEDURE log(
      i_level          IN PLS_INTEGER,
      i_variable_name  IN VARCHAR2,
      i_variable_value IN DATE,
      i_program_name   IN VARCHAR2  );

   PROCEDURE log(
     i_level          IN PLS_INTEGER,
     i_variable_name  IN VARCHAR2,
     i_variable_value IN NUMBER,
     i_program_name   IN VARCHAR2 );

   PROCEDURE log(
      i_level          IN PLS_INTEGER,
      i_variable_name  IN VARCHAR2,
      i_variable_value IN VARCHAR2,
      i_program_name   IN VARCHAR2);

   PROCEDURE log(
     i_level          IN PLS_INTEGER,
     i_variable_name  IN VARCHAR2,
     i_variable_value IN BOOLEAN,
     i_program_name   IN VARCHAR2 );

   PROCEDURE log(
     i_level          IN PLS_INTEGER,
     i_variable_name  IN VARCHAR2,
     i_variable_value IN CLOB,
     i_program_name   IN VARCHAR2 );

   PROCEDURE print_log;

   PROCEDURE head(
      p_output    OUT NOCOPY VARCHAR2,
      p_lines     IN  PLS_INTEGER DEFAULT 5,
      p_delimiter IN  VARCHAR2    DEFAULT ';');

   PROCEDURE tail(
      p_output    OUT NOCOPY VARCHAR2,
      p_lines     IN  PLS_INTEGER DEFAULT 5,
      p_delimiter IN  VARCHAR2    DEFAULT ';');

   FUNCTION getTranslatedMessage(
      i_message_name     IN   VARCHAR2,
      i_token1           IN   VARCHAR2 DEFAULT NULL,
      i_value1           IN   VARCHAR2 DEFAULT NULL,
      i_token2           IN   VARCHAR2 DEFAULT NULL,
      i_value2           IN   VARCHAR2 DEFAULT NULL,
      i_token3           IN   VARCHAR2 DEFAULT NULL,
      i_value3           IN   VARCHAR2 DEFAULT NULL,
      i_token4           IN   VARCHAR2 DEFAULT NULL,
      i_value4           IN   VARCHAR2 DEFAULT NULL,
      i_token5           IN   VARCHAR2 DEFAULT NULL,
      i_value5           IN   VARCHAR2 DEFAULT NULL,
      i_token6           IN   VARCHAR2 DEFAULT NULL,
      i_value6           IN   VARCHAR2 DEFAULT NULL,
      i_token7           IN   VARCHAR2 DEFAULT NULL,
      i_value7           IN   VARCHAR2 DEFAULT NULL,
      i_token8           IN   VARCHAR2 DEFAULT NULL,
      i_value8           IN   VARCHAR2 DEFAULT NULL,
      i_token9           IN   VARCHAR2 DEFAULT NULL,
      i_value9           IN   VARCHAR2 DEFAULT NULL,
      i_token10          IN   VARCHAR2 DEFAULT NULL,
      i_value10          IN   VARCHAR2 DEFAULT NULL) return varchar2;


  /* sets ecx_utils.i_errbuf and the message parameters and values associated*/
  /* with the message in ecx_utils.i_errbuf */
  procedure setMessage(
                        p_message_name in varchar2,
                        p_token1       in varchar2 default null,
                        p_value1       in varchar2 default null,
                        p_token2       in varchar2 default null,
                        p_value2       in varchar2 default null,
                        p_token3       in varchar2 default null,
                        p_value3       in varchar2 default null,
                        p_token4       in varchar2 default null,
                        p_value4       in varchar2 default null,
                        p_token5       in varchar2 default null,
                        p_value5       in varchar2 default null,
                        p_token6       in varchar2 default null,
                        p_value6       in varchar2 default null,
                        p_token7       in varchar2 default null,
                        p_value7       in varchar2 default null,
                        p_token8       in varchar2 default null,
                        p_value8       in varchar2 default null,
                        p_token9       in varchar2 default null,
                        p_value9       in varchar2 default null,
                        p_token10      in varchar2 default null,
                        p_value10      in varchar2 default null);

  /* sets the global variables: ecx_utils.error_type, ecx_utils.i_ret_code, */
  /* ecx_utils.i_errbuf and the message parameters and values associated    */
  /* with the message in ecx_utils.i_errbuf */

  procedure setErrorInfo(
                          p_error_code   in pls_integer,
                          p_error_type   in pls_integer,
                          p_errmsg_name  in varchar2,
                          p_token1       in varchar2 default null,
                          p_value1       in varchar2 default null,
                          p_token2       in varchar2 default null,
                          p_value2       in varchar2 default null,
                          p_token3       in varchar2 default null,
                          p_value3       in varchar2 default null,
                          p_token4       in varchar2 default null,
                          p_value4       in varchar2 default null,
                          p_token5       in varchar2 default null,
                          p_value5       in varchar2 default null,
                          p_token6       in varchar2 default null,
                          p_value6       in varchar2 default null,
                          p_token7       in varchar2 default null,
                          p_value7       in varchar2 default null,
                          p_token8       in varchar2 default null,
                          p_value8       in varchar2 default null,
                          p_token9       in varchar2 default null,
                          p_value9       in varchar2 default null,
                          p_token10      in varchar2 default null,
                          p_value10      in varchar2 default null);

  /* Returns translated message based on current userenv('LANG') */
  FUNCTION getMessage(
      p_message_name     IN   VARCHAR2,
      p_message_params   IN   VARCHAR2	default null) return varchar2;


  PROCEDURE getDebugLevels(l_statement OUT NOCOPY integer,l_procedure OUT NOCOPY integer);

  PROCEDURE print_debug_spool(p_debug_array IN ECX_DBG_ARRAY_TYPE);

END ECX_DEBUG;


 

/
