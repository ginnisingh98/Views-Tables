--------------------------------------------------------
--  DDL for Package Body FND_LOG_REPOSITORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOG_REPOSITORY" as
/* $Header: AFUTLGRB.pls 120.12.12010000.6 2016/02/27 01:19:01 emiranda ship $ */

   --
   -- PRIVATE TYPES, VARIABLES
   --

   /*
   **  For INIT Procedure
   */
   type MODULE_TAB_TYPE   is table of varchar2(255) index by binary_integer;

   MODULE_TAB         MODULE_TAB_TYPE;
   TABLE_SIZE         binary_integer := 0;  /* the size of above tables*/

   AFLOG_ENABLED_X   BOOLEAN         := TRUE;/* default should never be used.*/
   AFLOG_FILENAME_X  VARCHAR2(255)   := NULL;
   AFLOG_LEVEL_X     NUMBER          := 6;/* default should never be used.*/
   AFLOG_MODULE_X    VARCHAR2(2000)  := NULL;
   AFLOG_BUFFER_SIZE_X      NUMBER   := 1000;
   AFLOG_BUFFER_MODE_X      NUMBER   := 0;
   SESSION_ID_X      NUMBER          := NULL;
   USER_ID_X         NUMBER          := NULL;

   SELF_INITED_X     BOOLEAN         := FALSE;

   TXN_SESSION	     NUMBER	     := NULL;
   TXN_MACHINE	     VARCHAR2(64)    := NULL;
   TXN_PROCESS       VARCHAR2(9)     := NULL;
   TXN_PROGRAM       VARCHAR2(48)    := NULL;
   TXN_INSTANCE      VARCHAR2(16)  := NULL;

   /* For Buffered Mode */
   G_BUFFER_POS	     NUMBER        := 1;
   MODULE_TABLE FND_TABLE_OF_VARCHAR2_255;
   LOG_LEVEL_TABLE FND_TABLE_OF_NUMBER;
   MESSAGE_TEXT_TABLE FND_TABLE_OF_VARCHAR2_4000;
   SESSION_ID_TABLE FND_TABLE_OF_NUMBER;
   USER_ID_TABLE FND_TABLE_OF_NUMBER;
   TIMESTAMP_TABLE FND_TABLE_OF_DATE;
   LOG_SEQUENCE_TABLE FND_TABLE_OF_NUMBER;
   ENCODED_TABLE FND_TABLE_OF_VARCHAR2_1;
   NODE_TABLE varchar2(60) := NULL;
   NODE_IP_ADDRESS_TABLE varchar2(30) := NULL;
   PROCESS_ID_TABLE varchar2(120) := NULL;
   JVM_ID_TABLE varchar2(120) := NULL;
   THREAD_ID_TABLE FND_TABLE_OF_VARCHAR2_120;
   AUDSID_TABLE FND_TABLE_OF_NUMBER;
   DB_INSTANCE_TABLE FND_TABLE_OF_NUMBER;
   TRANSACTION_CONTEXT_ID_TABLE FND_TABLE_OF_NUMBER;

   /*
   **  For GET_CONTEXT Function
   **     Types for storing context info before calling autonomous
   **     logging procedures, like
   **     FND_LOG_REPOSITORY.String_Unchecked_Internal2
   */
   type CONTEXT_REC is record (
           a_col   varchar2(30),
           a_val    varchar2(4000) );
   type CONTEXT_ARRAY is table of CONTEXT_REC
         index by binary_integer;

   /* For Proxy Alerting */
   G_PRX_CHILD_TRANS_CONTEXT_ID NUMBER;
   G_PRX_SESSION_ID fnd_log_messages.session_id%TYPE;
   G_PRX_USER_ID fnd_log_messages.user_id%TYPE;
   G_PRX_SESSION_MODULE fnd_log_exceptions.session_module%TYPE;
   G_PRX_SESSION_ACTION fnd_log_exceptions.session_action%TYPE;
   G_PRX_MODULE fnd_log_messages.module%TYPE;
   G_PRX_NODE fnd_log_messages.node%TYPE;
   G_PRX_NODE_IP_ADDRESS fnd_log_messages.node_ip_address%TYPE;
   G_PRX_PROCESS_ID fnd_log_messages.process_id%TYPE;
   G_PRX_JVM_ID fnd_log_messages.jvm_id%TYPE;
   G_PRX_THREAD_ID fnd_log_messages.thread_id%TYPE;
   G_PRX_AUDSID fnd_log_messages.audsid%TYPE;
   G_PRX_DB_INSTANCE fnd_log_messages.db_instance%TYPE;

   /*
    * For Proxy Alerting: Index values to use within CONTEXT_ARRAY.
    * This is mostly for code readability in order to avoid passing
    * many separate parameters.
    *
    * Procedure INIT_CHILD_CONTEXT will look for different context
    * values from the context array as follows:
    *
    * E.g. for child context user id:
    * l_user_id := p_context_array(CCI_USER_ID).a_val;
    */
   CCI_USER_ID CONSTANT NUMBER := 1;
   CCI_RESP_APPL_ID CONSTANT NUMBER := 2;
   CCI_RESPONSIBILITY_ID CONSTANT NUMBER := 3;
   CCI_SECURITY_GROUP_ID CONSTANT NUMBER := 4;
   CCI_COMPONENT_TYPE CONSTANT NUMBER := 5;
   CCI_COMPONENT_APPL_ID CONSTANT NUMBER := 6;
   CCI_COMPONENT_ID CONSTANT NUMBER := 7;
   CCI_SESSION_ID CONSTANT NUMBER := 8;
   CCI_SESSION_ACTION CONSTANT NUMBER := 9;
   CCI_SESSION_MODULE CONSTANT NUMBER := 10;
   CCI_MODULE CONSTANT NUMBER := 11;
   CCI_NODE CONSTANT NUMBER := 12;
   CCI_NODE_IP_ADDRESS CONSTANT NUMBER := 13;
   CCI_PROCESS_ID CONSTANT NUMBER := 14;
   CCI_JVM_ID CONSTANT NUMBER := 15;
   CCI_THREAD_ID CONSTANT NUMBER := 16;
   CCI_AUDSID CONSTANT NUMBER := 17;
   CCI_DB_INSTANCE CONSTANT NUMBER := 18;

   /* fnd_log_enabled_tracing BOOLEAN := FALSE; */

/***For debugging purpose */
 PROCEDURE DEBUG(p_msg IN VARCHAR2) is
 l_num number;
  l_msg 		VARCHAR2(100);
 --config_file UTL_FILE.FILE_TYPE;
 begin
    ------Debug using file system
    --config_file := UTL_FILE.FOPEN ('/slot03/oracle/oam12devdb/9.2.0/appsutil/outbound/oam12dev', 'debugFC.txt', 'A');
    --l_msg  := dbms_utility.get_time || '   ' || p_msg;
    --UTL_FILE.PUT_LINE(config_file, l_msg);
    --UTL_FILE.fclose(config_file);

    ------Debug using DB
    --insert into DEBUG_FND_LOG_REPOSITORY(MSG) values(p_msg);
    --commit;
    --dbms_output.put_line(p_msg);
    l_msg := null;
 end DEBUG;



   /**
    *  Private function for checking if alerting is enabled.
    *  This method checks if Alerting is enabled at severity level defined by
    *   input parameter p_msg_sev. If not, it returns false.
    *         If yes, it checks if limit for maximum number of alerts has
    *  been reached. If yes - it returns false
    *
    *  Argeuments
    *      p_msg_sev  Raised Alert severity.
    */
   FUNCTION IS_ALERTING_ENABLED(p_msg_sev IN VARCHAR2) return boolean is
      l_retu boolean;
      l_sys_al_level varchar2(80);  /*fnd_profile_options.PROFILE_OPTION_NAME%TYPE*/
      l_alertCount number;
      l_pr_al_count number;
   begin
      l_retu := FALSE;
	if (p_msg_sev IS NULL)THEN
           return l_retu;
      end if;

      l_sys_al_level := fnd_profile.value('OAM_ENABLE_SYSTEM_ALERT');
      DEBUG('IS_ALERTING_ENABLED::l_sys_al_level' || l_sys_al_level || ' p_msg_sev' || p_msg_sev );
      --Check Valid profile value
	if ((l_sys_al_level <> '00_NONE')  AND (l_sys_al_level <> '10_CRITICAL')
       AND(l_sys_al_level <> '20_ERROR') AND (l_sys_al_level <> '30_WARNING'))THEN
           return l_retu;
      end if;



	if (l_sys_al_level = '00_NONE')THEN
           return l_retu;
      end if;

      l_sys_al_level := substr(l_sys_al_level, 4);
      DEBUG('IS_ALERTING_ENABLED: Pr OAM_ENABLE_SYSTEM_ALERT enable. Next Check :sys_al_level' || l_sys_al_level);
      DEBUG('IS_ALERTING_ENABLED::p_msg_sev' || p_msg_sev);


	if (l_sys_al_level >= p_msg_sev)THEN
        l_pr_al_count := fnd_profile.value('OAM_MAX_SYSTEM_ALERT');
        select count(*) into l_alertCount from FND_LOG_UNIQUE_EXCEPTIONS
            where STATUS = 'N';
        DEBUG('IS_ALERTING_ENABLED: can log msg Sevrity lower Next chek:l_pr_al_count' || l_pr_al_count);
        DEBUG('IS_ALERTING_ENABLED::l_alertCount' || l_alertCount);
        if (l_alertCount < l_pr_al_count)  then
           l_retu := TRUE;
        end if;
      end if;

        if(l_retu = true) then
           DEBUG('IS_ALERTING_ENABLED:Can log :return true');
        else
           DEBUG('IS_ALERTING_ENABLED:Can Not log:return false');
        end if;
      return l_retu;
   end IS_ALERTING_ENABLED;


   /*
   ** FND_LOG_REPOSITORY.INIT_TRANSACTION_INTERNAL
   **
   ** Description:
   ** Initializes a log transaction.  A log transaction
   ** corresponds to an instance or invocation of a single
   ** component.  (e.g. A concurrent request, service process,
   ** open form, ICX function)
   **
   */

   PROCEDURE INIT_TRANSACTION_INTERNAL(
               P_TRANSACTION_TYPE            IN VARCHAR2 DEFAULT NULL,
               P_TRANSACTION_ID              IN NUMBER   DEFAULT NULL,
               P_COMPONENT_TYPE              IN VARCHAR2 DEFAULT NULL,
               P_COMPONENT_APPL_ID           IN VARCHAR2 DEFAULT NULL,
               P_COMPONENT_ID                IN NUMBER   DEFAULT NULL,
               P_SESSION_ID                  IN NUMBER   DEFAULT NULL,
               P_USER_ID                     IN NUMBER   DEFAULT NULL,
               P_RESP_APPL_ID                IN NUMBER   DEFAULT NULL,
               P_RESPONSIBILITY_ID           IN NUMBER   DEFAULT NULL,
               P_SECURITY_GROUP_ID           IN NUMBER   DEFAULT NULL,
	       P_PARENT_CONTEXT_ID	     IN NUMBER 	 DEFAULT NULL)  is
   pragma AUTONOMOUS_TRANSACTION;
	l_transaction_context_id number;
     begin
       insert into FND_LOG_TRANSACTION_CONTEXT
         (TRANSACTION_CONTEXT_ID,
          SESSION_ID,
          TRANSACTION_TYPE,
          TRANSACTION_ID,
          USER_ID,
          RESP_APPL_ID,
          RESPONSIBILITY_ID,
          SECURITY_GROUP_ID,
          COMPONENT_TYPE,
          COMPONENT_APPL_ID,
          COMPONENT_ID,
          CREATION_DATE,
	  PARENT_CONTEXT_ID
         ) values
	 (FND_LOG_TRANSACTION_CTX_ID_S.nextval,
          nvl(P_SESSION_ID, -1),
          P_TRANSACTION_TYPE,
          nvl(P_TRANSACTION_ID, -1),
          nvl(P_USER_ID, -1),
          nvl(P_RESP_APPL_ID, -1),
          nvl(P_RESPONSIBILITY_ID, -1),
          nvl(P_SECURITY_GROUP_ID, -1),
          P_COMPONENT_TYPE,
          nvl(P_COMPONENT_APPL_ID, -1),
          nvl(P_COMPONENT_ID, -1),
          sysdate,
	  P_PARENT_CONTEXT_ID
         ) RETURNING TRANSACTION_CONTEXT_ID into l_transaction_context_id;

       if (p_parent_context_id is null) then
	 FND_LOG.G_TRANSACTION_CONTEXT_ID := l_transaction_context_id;
       else
	 -- called for a proxy so set the child transaction context id
	 G_PRX_CHILD_TRANS_CONTEXT_ID := l_transaction_context_id;
       end if;

       commit;
     end INIT_TRANSACTION_INTERNAL;


   /*
   **   GET_CONTEXT- Gathers context info within the session,
   **   before calling autonomous logging procedures, like
   **   FND_LOG_REPOSITORY.String_Unchecked_Internal2
   */
   PROCEDURE GET_CONTEXT (SESSION_ID    IN NUMBER DEFAULT NULL,
                 USER_ID         IN NUMBER   DEFAULT NULL,
                 NODE            IN VARCHAR2 DEFAULT NULL,
                 NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
                 PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
                 JVM_ID          IN VARCHAR2 DEFAULT NULL,
                 THREAD_ID       IN VARCHAR2 DEFAULT NULL,
                 AUDSID          IN NUMBER   DEFAULT NULL,
                 DB_INSTANCE     IN NUMBER   DEFAULT NULL,
		 CONTEXT_OUT     OUT NOCOPY  CONTEXT_ARRAY) is
   begin
      -- Populate l_context column names
      -- Not really used right now, except to clarify.  May be helpful if
      -- Get_Context becomes public.
/*
      CONTEXT_OUT(1).a_col := 'SESSION_ID';
      CONTEXT_OUT(2).a_col := 'USER_ID';
      CONTEXT_OUT(3).a_col := 'NODE';
      CONTEXT_OUT(4).a_col := 'NODE_IP_ADDRESS';
      CONTEXT_OUT(5).a_col := 'PROCESS_ID';
      CONTEXT_OUT(6).a_col := 'JVM_ID';
      CONTEXT_OUT(7).a_col := 'THREAD_ID';
      CONTEXT_OUT(8).a_col := 'AUDSID';
      CONTEXT_OUT(9).a_col := 'DB_INSTANCE';
      CONTEXT_OUT(10).a_col := 'TRANSACTION_CONTEXT_ID';
      CONTEXT_OUT(11).a_col := 'SESSION_MODULE';
      CONTEXT_OUT(12).a_col := 'SESSION_ACTION';
*/

      if (TXN_SESSION is NULL) then
        TXN_SESSION := userenv('SESSIONID');
        TXN_INSTANCE := userenv('INSTANCE');
        begin
          select substrb(machine,1,60), process, program
            into TXN_MACHINE, TXN_PROCESS, TXN_PROGRAM
            from v$session
            where audsid = TXN_SESSION;
        exception
        when others then
          null;
        end;
      end if;

      /* 1. SESSION_ID */
      if (SESSION_ID IS NULL) then
        if SELF_INITED_X then
          CONTEXT_OUT(1).a_val := SESSION_ID_X;
        else
          CONTEXT_OUT(1).a_val := icx_sec.g_session_id;
        end if;
      else
        CONTEXT_OUT(1).a_val := SESSION_ID;
      end if;

      /* 2. USER_ID */
      if (USER_ID IS NULL) then
        if SELF_INITED_X then
          CONTEXT_OUT(2).a_val := USER_ID_X;
        else
          CONTEXT_OUT(2).a_val := fnd_profile.value('USER_ID');
        end if;
      else
        CONTEXT_OUT(2).a_val := USER_ID;
      end if;

      /* 3. NODE */
      if (NODE IS NULL) then
         CONTEXT_OUT(3).a_val := TXN_MACHINE;
      else
         CONTEXT_OUT(3).a_val := NODE;
      end if;

      /* 4. NODE_IP_ADDRESS */
      if (NODE_IP_ADDRESS IS NULL) then
         CONTEXT_OUT(4).a_val := null;
      else
         CONTEXT_OUT(4).a_val := NODE_IP_ADDRESS;
      end if;


      /* 5. PROCESS_ID */
      if (PROCESS_ID IS NULL) then
         CONTEXT_OUT(5).a_val := TXN_PROCESS;
      else
         CONTEXT_OUT(5).a_val := PROCESS_ID;
      end if;

      /* 6. JVM_ID */
      if (JVM_ID IS NULL) then
         if ( (INSTR(LOWER(TXN_PROGRAM), 'java') <> 0) OR
              (INSTR(LOWER(TXN_PROGRAM),  'jre') <> 0) ) then
            CONTEXT_OUT(6).a_val := TXN_PROCESS;
         else
            CONTEXT_OUT(6).a_val := null;
         end if;
      else
         CONTEXT_OUT(6).a_val := JVM_ID;
      end if;

      /* 7. THREAD_ID */
      if (THREAD_ID IS NULL) then
         CONTEXT_OUT(7).a_val := null;
      else
         CONTEXT_OUT(7).a_val := THREAD_ID;
      end if;

      /* 8. AUDSID */
      if (AUDSID IS NULL) then
         CONTEXT_OUT(8).a_val := TXN_SESSION;
      else
         CONTEXT_OUT(8).a_val := AUDSID;
      end if;

      /* 9. DB_INSTANCE */
      if (DB_INSTANCE IS NULL) then
         CONTEXT_OUT(9).a_val := TXN_INSTANCE;
      else
         CONTEXT_OUT(9).a_val := DB_INSTANCE;
      end if;

      /* 10. TRANSACTION_CONTEXT_ID */
      if (FND_LOG.G_TRANSACTION_CONTEXT_ID is NULL) THEN

        /* create a new transaction context on the fly */
        FND_LOG.G_TRANSACTION_CONTEXT_ID := init_trans_int_with_context(
                                                fnd_global.conc_request_id,
                                                fnd_global.form_id,
                                                fnd_global.form_appl_id,
                                                fnd_global.conc_process_id,
                                                fnd_global.conc_queue_id,
                                                fnd_global.queue_appl_id,
                                                icx_sec.g_session_id,
                                                fnd_global.user_id,
                                                fnd_global.resp_appl_id,
                                                fnd_global.resp_id,
                                                fnd_global.security_group_id
                                                );


      end if;

      CONTEXT_OUT(10).a_val := FND_LOG.G_TRANSACTION_CONTEXT_ID;

   end GET_CONTEXT;

   /*
   **   GET_TRANSACTION_CONTEXT- Gathers transaction context info within
   **   the session, before calling autonomous procedures, like
   **   FND_LOG_REPOSITORY.Init_Transaction_Internal
   */
   PROCEDURE GET_TRANSACTION_CONTEXT ( SESSION_ID   IN NUMBER   DEFAULT NULL,
                 USER_ID                     IN NUMBER   DEFAULT NULL,
                 RESP_APPL_ID                IN NUMBER   DEFAULT NULL,
                 RESPONSIBILITY_ID           IN NUMBER   DEFAULT NULL,
                 SECURITY_GROUP_ID           IN NUMBER   DEFAULT NULL,
		 CONTEXT_OUT		     OUT NOCOPY  CONTEXT_ARRAY) is
   begin
      -- Populate CONTEXT_OUT column names
      -- Not really used right now, except to clarify.  May be helpful if
      -- Get_Transaction_Context becomes public.
/*
      CONTEXT_OUT(1).a_col := 'SESSION_ID';
      CONTEXT_OUT(2).a_col := 'USER_ID';
      CONTEXT_OUT(3).a_col := 'RESP_APPL_ID';
      CONTEXT_OUT(4).a_col := 'RESPONSIBILITY_ID';
      CONTEXT_OUT(5).a_col := 'SECURITY_GROUP_ID';
*/
      /* 1. SESSION_ID */
      if (SESSION_ID is NOT NULL) then
        CONTEXT_OUT(1).a_val := SESSION_ID;
      elsif ((SESSION_ID_X is NOT NULL) and
          (SESSION_ID_X <> -1 )) then
        CONTEXT_OUT(1).a_val := SESSION_ID_X;
      else
        CONTEXT_OUT(1).a_val := icx_sec.g_session_id;
      end if;


      /* 2. USER_ID */
      if (USER_ID is NOT NULL) then
        CONTEXT_OUT(2).a_val := USER_ID;
      elsif ((USER_ID_X is NOT NULL) and
             (USER_ID_X <> -1)) then
        CONTEXT_OUT(2).a_val := USER_ID_X;
      elsif (FND_GLOBAL.user_id is NOT NULL) then
        CONTEXT_OUT(2).a_val := FND_GLOBAL.user_id;
      else
        CONTEXT_OUT(2).a_val := -1;
      end if;

      /* 3. RESP_APPL_ID */
      if (RESP_APPL_ID is NOT NULL) then
        CONTEXT_OUT(3).a_val := RESP_APPL_ID;
      else
         CONTEXT_OUT(3).a_val := FND_GLOBAL.resp_appl_id;
      end if;

      /* 4. RESP_ID */
      if (RESPONSIBILITY_ID is NOT NULL) then
        CONTEXT_OUT(4).a_val := RESPONSIBILITY_ID;
      else
        CONTEXT_OUT(4).a_val := FND_GLOBAL.resp_id;
      end if;

      /* 5. SECURITY_GROUP_ID */
      if (SECURITY_GROUP_ID is NOT NULL) then
        CONTEXT_OUT(5).a_val := SECURITY_GROUP_ID;
      else
        CONTEXT_OUT(5).a_val := FND_GLOBAL.security_group_id;
      end if;

   end GET_TRANSACTION_CONTEXT;

   /*
   ** SELF_INIT- Initialize the logging system automatically.  Note that
   ** in the case of Forms initialization, this routine does not obviate the
   ** need for the INIT routine to be called by AOL, because when the
   ** code is self inited, the user/resp context may not exist (so only site
   ** level profiles would exist).  This self initialization will allow the
   ** site level profiles to be acted upon, and later the actual
   ** INIT call will allow the user level profiles to control logging.
   */
   PROCEDURE SELF_INIT  is
   begin
      INIT;
      SELF_INITED_X := TRUE;
   end;

   /*
   ** NOPASS - This is no longer depends on the java code AppsLog.nopass()
   ** to filter passwords from log entries.
   ** It is re-write to use in PLSQL
   **
   */
   FUNCTION NOPASS(MESSAGE_TEXT IN VARCHAR2) RETURN VARCHAR2 AS
      l_rtn     VARCHAR2(32767);
      /*
      --
      -- The Original regex created by Renato in JAVA (AppsLog.nopass)
      --
      --  m.replaceAll("(?imu)(passw(?:[^=](?!=|&|:))*.)(=|&|:)((?:.(?!($|&)))*.)(?:$|&)", "$1$2*****$4")
      --
      -- it can be translated into PLSQL as
      --  regexp_replace( value, '(pass(word)??)([=:])([^ $&&]*)','\1\3*****' ,1,0,'inm' )
      --
      --   Thanks Renato
      */
      l_filter1 VARCHAR2(80) := '(pass(word)??)([=:])([^ $&&]*)' ;
   BEGIN
     -- Filter with PLSQL functions first that is faster then
     -- REGEXP in plsql, since 99% of the lines will not have the
     -- string PASS on it.
     --
     IF ( MESSAGE_TEXT IS NULL
         OR instr(upper( MESSAGE_TEXT ),'PASS') < 1 ) THEN
        --
        -- EXIT (nothing to replace) :
        --   If the original-string is not valid:  it is NULL or
        --        it does not contains the string PASS upper or lowercase
        --  then it returns the original-string
        --
        RETURN MESSAGE_TEXT;
     END IF;

     --
     -- Search with more details into the string using the REGEXP
     --
     l_rtn := regexp_replace( MESSAGE_TEXT ,
                              l_filter1 ,
                              '\1\3*****' ,1,0,'inm');
     RETURN l_rtn;

   END NOPASS;

   /*
   **  Determines whether logging is enabled or disabled for this module
   **  and level.
   */
   function CHECK_ACCESS_INTERNAL(MODULE_IN IN VARCHAR2,
                                  LEVEL_IN  IN NUMBER) return BOOLEAN is
   begin
      if(NOT SELF_INITED_X) then
         SELF_INIT;
      end if;

      if (NOT AFLOG_ENABLED_X) then
         return FALSE;
      end if;
      if (LEVEL_IN < AFLOG_LEVEL_X) then
         return FALSE;
      end if;
      if(TABLE_SIZE = 0) then
         return TRUE;  /* If no module is specified, log for all modules*/
      end if;
      for IDX in 1..TABLE_SIZE loop
         if UPPER(MODULE_IN) like MODULE_TAB(IDX)  then
            return TRUE;
         end if;
      end loop;
      return FALSE;
   end;

   /*
   **  Private - for ATG only.
   **  POST_EXCEPTION
   **  Description:
   **  Inserts extended exception information into FND_LOG_EXCEPTIONS and
   **  posts the exception / unexpected error to the Business Event System
   **
   **  Arguments:
   **      Module      - Module name (See FND_LOG standards)
   **      Message_Id  - The unique identifier of the message from
   **                    FND_LOG_MESSAGES.Log_Sequence
   */
   FUNCTION POST_EXCEPTION ( P_MODULE                 IN VARCHAR2,
                             P_LOG_SEQUENCE           IN NUMBER,
                             P_MESSAGE_APP            IN VARCHAR2 DEFAULT NULL,
                             P_MESSAGE_NAME           IN VARCHAR2 DEFAULT NULL)
                                                        return BOOLEAN is
       l_msg_text           varchar2(2000);
       l_enc_msg            varchar2(2000) := null;
       l_msg_app            varchar2(50);
       l_msg_name           varchar2(30);
       l_base_lang          varchar2(4);  -- Base language_code for install
       l_msg_cat            varchar2(10); -- Message category
       l_msg_sev            varchar2(10); -- Message severity
       l_cur_lang           varchar2(64);
       l_cur_date_lang      varchar2(64);
       l_cur_sort           varchar2(64);
       l_ex_id              number;
       l_txn_id             number;
       l_session_action     varchar2(32);
       l_session_module     varchar2(48);
       l_is_new_alert       boolean := false;
       l_occ_count         number;
       l_max_occ_count     number;
       l_transaction_type varchar2(30);

   pragma AUTONOMOUS_TRANSACTION;

   begin

        select MESSAGE_TEXT, TRANSACTION_CONTEXT_ID
            into l_enc_msg, l_txn_id
            from FND_LOG_MESSAGES
            where LOG_SEQUENCE = P_LOG_SEQUENCE;



        --8609702
        begin
          select transaction_type
          into l_transaction_type
          from fnd_log_transaction_context
          where transaction_context_id = l_txn_id;

          if (l_transaction_type = 'UNKNOWN') then
            return false;
          end if;

        exception
          when others then return false;
        end;






        if ((P_MESSAGE_APP IS NOT NULL) and
            (P_MESSAGE_NAME IS NOT NULL)) then
            l_msg_app := P_MESSAGE_APP;
            l_msg_name := P_MESSAGE_NAME;
        else
          FND_MESSAGE.PARSE_ENCODED(l_enc_msg,
                                    l_msg_app,
                                    l_msg_name);
        end if;

		l_msg_name := UPPER(l_msg_name);

        select LANGUAGE_CODE
          into l_base_lang
          from FND_LANGUAGES
          where INSTALLED_FLAG = 'B';

        /**
         * Added Check for Proxy Alerting. If child context is set use
         * sesion module and action for child instead of current session.
         */
        if (G_PRX_CHILD_TRANS_CONTEXT_ID is null) then
          select module, action
            into l_session_module, l_session_action
            from v$session
	    where audsid = userenv('SESSIONID');
	else
	  l_session_module := G_PRX_SESSION_MODULE;
	  l_session_action := G_PRX_SESSION_ACTION;
      	end if;

        begin
          select CATEGORY, SEVERITY
            into l_msg_cat, l_msg_sev
            from FND_NEW_MESSAGES fnm,
                 FND_APPLICATION  fa
           where fnm.APPLICATION_ID = fa.APPLICATION_ID
             and fa.APPLICATION_SHORT_NAME = l_msg_app
             and fnm.MESSAGE_NAME = l_msg_name
             and fnm.LANGUAGE_CODE = l_base_lang;
        exception
          when others then
             FND_MESSAGE.SET_NAME ('FND', 'SQL-Generic error');
             FND_MESSAGE.SET_TOKEN ('ERRNO', sqlcode, FALSE);
             FND_MESSAGE.SET_TOKEN ('REASON', sqlerrm, FALSE);
             FND_MESSAGE.SET_TOKEN ('ROUTINE',
                                'FND_LOG_REPOSITORY.POST_EXCEPTION', FALSE);

             rollback;
             return FALSE;
        end;

	if ((l_msg_cat IS NULL) or (l_msg_sev IS NULL) or (IS_ALERTING_ENABLED(l_msg_sev) = FALSE)) THEN
           rollback;
           return FALSE;
        end if;


        /* Here we need to  insert the translated message text into MESSAGE_TEXT        */
        /* First we will save the current language, then switch our session to English, */
        /* retrieve the English message text, then switch back to the original language */
        select value
         into l_cur_lang
         from v$nls_parameters
         where parameter = 'NLS_LANGUAGE';
        select value
         into l_cur_date_lang
         from v$nls_parameters
         where parameter = 'NLS_DATE_LANGUAGE';
        select value
         into l_cur_sort
         from v$nls_parameters
         where parameter = 'NLS_SORT';

        dbms_session.set_nls('NLS_LANGUAGE', 'AMERICAN');

        fnd_message.set_encoded(l_enc_msg);

        l_msg_text := fnd_message.get;

        dbms_session.set_nls('NLS_LANGUAGE', '"' || l_cur_lang || '"');
        dbms_session.set_nls('NLS_DATE_LANGUAGE', '"' || l_cur_date_lang || '"');
        dbms_session.set_nls('NLS_SORT', '"' || l_cur_sort || '"');


        /* Unique exception enhancement: Check fnd_log_unique_exceptions table for a row */
        /* with this same message. If one exists already, increment the exception count  */
        /* If this is the first one, insert a new row into fnd_log_unique_exceptions     */
        begin
          l_is_new_alert := false;
          select unique_exception_id, count
            into l_ex_id, l_occ_count
            from fnd_log_unique_exceptions
            where encoded_message = l_enc_msg
            and status in ('N', 'O');

          /** Check if limit for occrrences has been reached **/
          l_max_occ_count := fnd_profile.value('OAM_MAX_OCCURRENCES_PER_ALERT');
          if(l_occ_count >= l_max_occ_count) then
             rollback;
             DEBUG('Not Logging occ l_occ_count = l_max_occ_count'|| l_max_occ_count);
             return FALSE;
          end if;

          update fnd_log_unique_exceptions flue
             set flue.count = flue.count + 1
             where flue.unique_exception_id = l_ex_id;

        exception
          when no_data_found then
            select fnd_log_unique_exception_s.nextval
              into l_ex_id
              from dual;

		insert into fnd_log_unique_exceptions (
		  UNIQUE_EXCEPTION_ID,
		  ENCODED_MESSAGE,
		  ENGLISH_MESSAGE,
		  STATUS,
		  COUNT,
		  SEVERITY,
		  CATEGORY,
		  CREATED_BY,
		  CREATION_DATE,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  LAST_UPDATE_LOGIN
		 )
           values (
              l_ex_id,
              l_enc_msg,
              NOPASS(l_msg_text),
              'N',
              1,
              l_msg_sev,
              l_msg_cat,
              USER_ID_X,
              sysdate,
              USER_ID_X,
              sysdate,
              USER_ID_X);
          l_is_new_alert := true;
           DEBUG('Logged Alert'|| l_ex_id);

        end;


        /* Log extended exception information in FND_LOG_EXCEPTIONS */
        insert into FND_LOG_EXCEPTIONS (
           LOG_SEQUENCE,
           SESSION_MODULE,
           SESSION_ACTION,
           UNIQUE_EXCEPTION_ID,
           ACKNOWLEDGED,
	       MESSAGE_TEXT,
	       TRANSACTION_CONTEXT_ID
        ) values
        (
           P_LOG_SEQUENCE,
           substrb(l_session_module,1,48),
           substrb(l_session_action,1,32),
           l_ex_id,
           'N',
	       NOPASS(l_msg_text),
	       l_txn_id
        );

        DEBUG('Logging occ P_LOG_SEQUENCE' || P_LOG_SEQUENCE);

        /* Always Post exception to Business Event System */
        WF_EVENT.RAISE('oracle.apps.fnd.system.exception',
                         to_char(P_LOG_SEQUENCE) );

        commit;
        return TRUE;


   exception
          when others then
             FND_MESSAGE.SET_NAME ('FND', 'SQL-Generic error');
             FND_MESSAGE.SET_TOKEN ('ERRNO', sqlcode, FALSE);
             FND_MESSAGE.SET_TOKEN ('REASON', sqlerrm, FALSE);
             FND_MESSAGE.SET_TOKEN ('ROUTINE',
                                 'FND_LOG_REPOSITORY.POST_EXCEPTION', FALSE);
         rollback;
         return FALSE;

   end POST_EXCEPTION;

   /*
   **  Writes the message to the log file for the spec'd level and module
   **  without checking if logging is enabled at this level.  This
   **  routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **  If the SESSION_ID and/or USER_ID is not passed, it defaults to the
   **  value that was passed upon INIT.
   */
   PROCEDURE STRING_UNCHECKED_INTERNAL(LOG_LEVEL IN NUMBER,
                    MODULE        IN VARCHAR2,
                    MESSAGE_TEXT  IN VARCHAR2,
                    SESSION_ID    IN NUMBER   DEFAULT NULL,
                    USER_ID       IN NUMBER   DEFAULT NULL,
                    CALL_STACK    IN VARCHAR2 DEFAULT NULL,
                    ERR_STACK     IN VARCHAR2 DEFAULT NULL) is

      SESSION_ID_Z  NUMBER;
      USER_ID_Z     NUMBER;

   pragma AUTONOMOUS_TRANSACTION;
   begin
      if(NOT SELF_INITED_X) then
         SELF_INIT;
      end if;

      if (SESSION_ID is not NULL) then
         SESSION_ID_Z := SESSION_ID;
      else
         SESSION_ID_Z := SESSION_ID_X;
      end if;

      if (USER_ID is not NULL) then
         USER_ID_Z := USER_ID;
      else
         USER_ID_Z := USER_ID_X;
      end if;

      if (AFLOG_FILENAME_X is not NULL) then
         null; /* Eventually we will want to add code that will log to a */
               /* file if they set the filename, but for now we will just */
	       /* log to table */
      end if;


      INSERT INTO FND_LOG_MESSAGES (
           ECID_ID,
           ECID_SEQ,
           CALLSTACK,
           ERRORSTACK,
           MODULE,
           LOG_LEVEL,
           MESSAGE_TEXT,
           SESSION_ID,
           USER_ID,
           TIMESTAMP,
           LOG_SEQUENCE
      ) values
      (
           SYS_CONTEXT('USERENV', 'ECID_ID'),
           SYS_CONTEXT('USERENV', 'ECID_SEQ'),
           CALL_STACK,
           ERR_STACK,
           SUBSTRB(MODULE,1,255),
           LOG_LEVEL,
           SUBSTRB(NOPASS(MESSAGE_TEXT), 1, 4000),
           SESSION_ID_Z,
           USER_ID_Z,
           SYSDATE,
           FND_LOG_MESSAGES_S.NEXTVAL
      );

      commit;
   end;

   /* Clears in memory buffered messages */
   PROCEDURE DELETE_BUFFERED_TABLES is
   begin
           TIMESTAMP_TABLE.delete;
           LOG_SEQUENCE_TABLE.delete;
           MODULE_TABLE.delete;
           LOG_LEVEL_TABLE.delete;
           MESSAGE_TEXT_TABLE.delete;
           SESSION_ID_TABLE.delete;
           USER_ID_TABLE.delete;
           ENCODED_TABLE.delete;
           THREAD_ID_TABLE.delete;
           AUDSID_TABLE.delete;
           DB_INSTANCE_TABLE.delete;
           TRANSACTION_CONTEXT_ID_TABLE.delete;
   end;

   /* Flushes any buffered messages */
   FUNCTION FLUSH return NUMBER is
   l_log_seq NUMBER := NULL;
   begin
       if (G_BUFFER_POS > 1) then
           l_log_seq := BULK_INSERT_PVT(MODULE_TABLE,
                                LOG_LEVEL_TABLE,
                                MESSAGE_TEXT_TABLE,
                                SESSION_ID_TABLE,
                                USER_ID_TABLE,
                                TIMESTAMP_TABLE,
                                LOG_SEQUENCE_TABLE,
                                ENCODED_TABLE,
                                NODE_TABLE,
                                NODE_IP_ADDRESS_TABLE,
                                PROCESS_ID_TABLE,
                                JVM_ID_TABLE,
                                THREAD_ID_TABLE,
                                AUDSID_TABLE,
                                DB_INSTANCE_TABLE,
                                TRANSACTION_CONTEXT_ID_TABLE,
                                (G_BUFFER_POS - 1) );

           l_log_seq := LOG_SEQUENCE_TABLE(G_BUFFER_POS - 1);

           DELETE_BUFFERED_TABLES;
           G_BUFFER_POS := 1;
        end if;
           return l_log_seq;
        exception
          when others then
            AFLOG_BUFFER_MODE_X := 0;
            G_BUFFER_POS := 1;
            DELETE_BUFFERED_TABLES;
            STR_UNCHKED_INT_WITH_CONTEXT(6, 'fnd.plsql.fnd_log_repository', 'Buffered Logging Failed! ' ||
                                            'Please report to Oracle Development. sqlcode=' || sqlcode ||
                                            '; sqlerrm=' || sqlerrm);
        return l_log_seq;
   end FLUSH;

   /*
   ** Private- Flushes any buffered messages, and resets to non-buffered mode
   */
   PROCEDURE RESET_BUFFERED_MODE is
     l_count NUMBER := 0;
   begin
     l_count := FLUSH;
     AFLOG_BUFFER_MODE_X := 0;
   end RESET_BUFFERED_MODE;

   /*
   ** Enables buffered mode based on AFLOG_BUFFER_MODE Profile
   */
   PROCEDURE SET_BUFFERED_MODE is
     l_buffer_size NUMBER := NULL;
     l_buffer_mode NUMBER := NULL;
   begin

    if ( AFLOG_ENABLED_X = TRUE) then

      l_buffer_size := TO_NUMBER(FND_PROFILE.VALUE('AFLOG_BUFFER_SIZE'));
      l_buffer_mode := TO_NUMBER(FND_PROFILE.VALUE('AFLOG_BUFFER_MODE'));

      if ( l_buffer_size > -1 ) then
         AFLOG_BUFFER_SIZE_X := l_buffer_size;
      end if;

      if ( l_buffer_mode > -1 ) then
         AFLOG_BUFFER_MODE_X := l_buffer_mode;
      end if;

      if ( AFLOG_BUFFER_MODE_X > 0 ) then
	MODULE_TABLE := FND_TABLE_OF_VARCHAR2_255();
	LOG_LEVEL_TABLE := FND_TABLE_OF_NUMBER();
	MESSAGE_TEXT_TABLE := FND_TABLE_OF_VARCHAR2_4000();
	SESSION_ID_TABLE := FND_TABLE_OF_NUMBER();
	USER_ID_TABLE := FND_TABLE_OF_NUMBER();
	TIMESTAMP_TABLE := FND_TABLE_OF_DATE();
	LOG_SEQUENCE_TABLE := FND_TABLE_OF_NUMBER();
	ENCODED_TABLE := FND_TABLE_OF_VARCHAR2_1();
	THREAD_ID_TABLE := FND_TABLE_OF_VARCHAR2_120();
	AUDSID_TABLE := FND_TABLE_OF_NUMBER();
	DB_INSTANCE_TABLE := FND_TABLE_OF_NUMBER();
	TRANSACTION_CONTEXT_ID_TABLE := FND_TABLE_OF_NUMBER();
      end if;

    end if;
   end SET_BUFFERED_MODE;

   /*
   **  Private -- Should only be called by STR_UNCHKED_INT_WITH_CONTEXT
   **  Writes the message to the log file for the spec'd level and module
   **  without checking if logging is enabled at this level.
   */
   FUNCTION STRING_UNCHECKED_INTERNAL2(LOG_LEVEL IN NUMBER,
                    MODULE          IN VARCHAR2,
                    MESSAGE_TEXT    IN VARCHAR2,
                    LOG_SEQUENCE    IN NUMBER,
                    ENCODED         IN VARCHAR2 DEFAULT 'N',
                    SESSION_ID      IN NUMBER   DEFAULT NULL,
                    USER_ID         IN NUMBER,
                    NODE            IN VARCHAR2 DEFAULT NULL,
                    NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
                    PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
                    JVM_ID          IN VARCHAR2 DEFAULT NULL,
                    THREAD_ID       IN VARCHAR2 DEFAULT NULL,
                    AUDSID          IN NUMBER   DEFAULT NULL,
                    DB_INSTANCE     IN NUMBER   DEFAULT NULL,
                    TRANSACTION_CONTEXT_ID IN NUMBER DEFAULT NULL,
                    CALL_STACK      IN VARCHAR2 DEFAULT NULL,
                    ERR_STACK       IN VARCHAR2 DEFAULT NULL) return NUMBER is
   pragma AUTONOMOUS_TRANSACTION;
   l_log_seq NUMBER := NULL;
   cur_time DATE := NULL;
   first_buf_time DATE := NULL;

   begin

   /* Only buffer log_level < 4 message, i.e. no error messages */
   if (AFLOG_BUFFER_MODE_X > 0 and LOG_LEVEL < 4) then

     if (G_BUFFER_POS > TIMESTAMP_TABLE.COUNT) then
       TIMESTAMP_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       LOG_SEQUENCE_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       MODULE_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       LOG_LEVEL_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       MESSAGE_TEXT_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       SESSION_ID_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       USER_ID_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       ENCODED_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       THREAD_ID_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       AUDSID_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       DB_INSTANCE_TABLE.extend(AFLOG_BUFFER_SIZE_X);
       TRANSACTION_CONTEXT_ID_TABLE.extend(AFLOG_BUFFER_SIZE_X);
     end if;

     /* This is the default Sequenced mode for AFLOG_BUFFER_MODE */
     /* if ( AFLOG_BUFFER_MODE_X = 2 ) then */
     -- Better to always do this so log_level>=4 messages are in sequence
          select FND_LOG_MESSAGES_S.NEXTVAL
            into  LOG_SEQUENCE_TABLE(G_BUFFER_POS)
            from dual;
     /* end if; */

       TIMESTAMP_TABLE(G_BUFFER_POS) := SYSDATE;
       MODULE_TABLE(G_BUFFER_POS) := MODULE;
       LOG_LEVEL_TABLE(G_BUFFER_POS) := LOG_LEVEL;
       MESSAGE_TEXT_TABLE(G_BUFFER_POS) := MESSAGE_TEXT;
       SESSION_ID_TABLE(G_BUFFER_POS) := SESSION_ID;
       USER_ID_TABLE(G_BUFFER_POS) := USER_ID;
       ENCODED_TABLE(G_BUFFER_POS) := ENCODED;

       NODE_TABLE := NODE;
       NODE_IP_ADDRESS_TABLE := NODE_IP_ADDRESS;
       PROCESS_ID_TABLE := PROCESS_ID;
       JVM_ID_TABLE := JVM_ID;

       THREAD_ID_TABLE(G_BUFFER_POS) := THREAD_ID;
       AUDSID_TABLE(G_BUFFER_POS) := AUDSID;
       DB_INSTANCE_TABLE(G_BUFFER_POS) := DB_INSTANCE;
       TRANSACTION_CONTEXT_ID_TABLE(G_BUFFER_POS) := TRANSACTION_CONTEXT_ID;
       G_BUFFER_POS := G_BUFFER_POS + 1;

       /* Flush if buffering for > 5 mins
       if (G_BUFFER_POS > 1) then
         cur_time := SYSDATE;
         first_buf_time := TIMESTAMP_TABLE(1);
	 if ( ((cur_time - first_buf_time)*24*60) > 5) then
	   l_log_seq := FLUSH;
         end if;
       end if;
       */

       /* Flush if buffer >  AFLOG_BUFFER_SIZE_X */
       if (G_BUFFER_POS > AFLOG_BUFFER_SIZE_X) then
   	   l_log_seq := FLUSH;
       end if;
   else


      INSERT INTO FND_LOG_MESSAGES (
	 ECID_ID,
         ECID_SEQ,
         CALLSTACK,
         ERRORSTACK,
         MODULE,
         LOG_LEVEL,
         MESSAGE_TEXT,
         SESSION_ID,
         USER_ID,
	 TIMESTAMP,
         LOG_SEQUENCE,
         ENCODED,
         NODE,
         NODE_IP_ADDRESS,
         PROCESS_ID,
         JVM_ID,
         THREAD_ID,
         AUDSID,
         DB_INSTANCE,
         TRANSACTION_CONTEXT_ID
      ) values
      (
	 SYS_CONTEXT('USERENV', 'ECID_ID'),
         SYS_CONTEXT('USERENV', 'ECID_SEQ'),
         CALL_STACK,
	 ERR_STACK,
         SUBSTRB(MODULE,1,255),
         LOG_LEVEL,
         SUBSTRB(NOPASS(MESSAGE_TEXT), 1, 4000),
         SESSION_ID,
         nvl(USER_ID, -1),
	 SYSDATE,
         FND_LOG_MESSAGES_S.NEXTVAL,
         ENCODED,
         substrb(NODE,1,60),
         substrb(NODE_IP_ADDRESS,1,30),
         substrb(PROCESS_ID,1,120),
         substrb(JVM_ID,1,120),
         substrb(THREAD_ID,1,120),
         AUDSID,
         DB_INSTANCE,
         TRANSACTION_CONTEXT_ID
      ) returning log_sequence into l_log_seq;
      commit;
   end if;
      return l_log_seq;
   end;

   /*
   **  Gathers context information within the same session, then
   **  calls the private, autonmous procedure STRING_UNCHECKED_INTERNAL2,
   **  passing context information to be logged in AFLOG tables
   **
   **  A wrapper API that calls String_Unchecked_Internal2 using the
   **  context values from internal cache of the context values.
   **  This routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **  If the SESSION_ID and/or USER_ID is not passed, it defaults to the
   **  value that was passed upon INIT.
   **  (NOTE: Recommend use FUNCTION STR_UNCHKED_INT_WITH_CONTEXT(..) instead
   */
   PROCEDURE STR_UNCHKED_INT_WITH_CONTEXT(LOG_LEVEL IN NUMBER,
                    MODULE          IN VARCHAR2,
                    MESSAGE_TEXT    IN VARCHAR2,
                    ENCODED         IN VARCHAR2 DEFAULT 'N',
                    SESSION_ID      IN NUMBER   DEFAULT NULL,
                    USER_ID         IN NUMBER   DEFAULT NULL,
                    NODE            IN VARCHAR2 DEFAULT NULL,
                    NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
                    PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
                    JVM_ID          IN VARCHAR2 DEFAULT NULL,
                    THREAD_ID       IN VARCHAR2 DEFAULT NULL,
                    AUDSID          IN NUMBER   DEFAULT NULL,
                    DB_INSTANCE     IN NUMBER   DEFAULT NULL,
                    CALL_STACK      IN VARCHAR2 DEFAULT NULL,
                    ERR_STACK       IN VARCHAR2 DEFAULT NULL) is
     l_seq NUMBER;
   begin
     l_seq := STR_UNCHKED_INT_WITH_CONTEXT(LOG_LEVEL,
                    MODULE,
                    MESSAGE_TEXT,
                    ENCODED,
                    SESSION_ID,
                    USER_ID,
                    NODE,
                    NODE_IP_ADDRESS,
                    PROCESS_ID,
                    JVM_ID,
                    THREAD_ID,
                    AUDSID,
                    DB_INSTANCE,
                    CALL_STACK,
                    ERR_STACK
	      );
   end;

   /*
   **  Gathers context information within the same session, then
   **  calls the private, autonmous procedure STRING_UNCHECKED_INTERNAL2,
   **  passing context information to be logged in AFLOG tables
   **
   **  A wrapper API that calls String_Unchecked_Internal2 using the
   **  context values from internal cache of the context values.
   **  This routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **  If the SESSION_ID and/or USER_ID is not passed, it defaults to the
   **  value that was passed upon INIT.
   **
   **  Returns the log_sequence of the logged message- needed for Attachments
   */
   FUNCTION STR_UNCHKED_INT_WITH_CONTEXT(LOG_LEVEL IN NUMBER,
                    MODULE          IN VARCHAR2,
                    MESSAGE_TEXT    IN VARCHAR2,
                    ENCODED         IN VARCHAR2 DEFAULT 'N',
                    SESSION_ID      IN NUMBER   DEFAULT NULL,
                    USER_ID         IN NUMBER   DEFAULT NULL,
                    NODE            IN VARCHAR2 DEFAULT NULL,
                    NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
                    PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
                    JVM_ID          IN VARCHAR2 DEFAULT NULL,
                    THREAD_ID       IN VARCHAR2 DEFAULT NULL,
                    AUDSID          IN NUMBER   DEFAULT NULL,
                    DB_INSTANCE     IN NUMBER   DEFAULT NULL,
                    CALL_STACK      IN VARCHAR2 DEFAULT NULL,
                    ERR_STACK       IN VARCHAR2 DEFAULT NULL) RETURN NUMBER is
      l_context  CONTEXT_ARRAY;
      l_encoded  VARCHAR2(1) := null;
      l_log_sequence  number;
      l_posted        boolean := FALSE;
      l_module   varchar2(256);
   begin

      /* check for null values */
      if message_text is null then
         return -1;
      end if;

      if module is null then
         l_module := 'MODULE_UNKNOWN';
      else
         l_module := MODULE;
      end if;

      if log_level is null then
        return -1;
      end if;


      if(NOT SELF_INITED_X) then
         SELF_INIT;
      end if;

      GET_CONTEXT (
                   SESSION_ID      => SESSION_ID,
                   USER_ID         => USER_ID,
                   NODE            => NODE,
                   NODE_IP_ADDRESS => NODE_IP_ADDRESS,
                   PROCESS_ID      => PROCESS_ID,
                   JVM_ID          => JVM_ID,
                   THREAD_ID       => THREAD_ID,
                   AUDSID          => AUDSID,
                   DB_INSTANCE     => DB_INSTANCE,
		   CONTEXT_OUT     => l_context);

      if (upper(ENCODED) in ('Y', 'N')) then
         l_encoded := ENCODED;
      else
         l_encoded := 'N';
      end if;

      if (AFLOG_FILENAME_X is not NULL) then
         null; /* Eventually we will want to add code that will log to a */
               /* file if they set the filename, but for now we will just */
               /* log to table */
      end if;

      /**
       * Added for proxy alerting. Check if child context is set. If yes,
       * use the child transaction context Id.
       */
      if (G_PRX_CHILD_TRANS_CONTEXT_ID is not null) then
	if G_PRX_MODULE is null then
          l_module := 'MODULE_UNKNOWN';
        else
          l_module := G_PRX_MODULE;
        end if;
        l_context(1).a_val := G_PRX_SESSION_ID;
        l_context(2).a_val := G_PRX_USER_ID;
	l_context(3).a_val := G_PRX_NODE;
        l_context(4).a_val := G_PRX_NODE_IP_ADDRESS;
        l_context(5).a_val := G_PRX_PROCESS_ID;
        l_context(6).a_val := G_PRX_JVM_ID;
        l_context(7).a_val := G_PRX_THREAD_ID;
	if (G_PRX_AUDSID is null) then
	  l_context(8).a_val := -1;
	else
  	  l_context(8).a_val := G_PRX_AUDSID;
	end if;
        l_context(9).a_val := G_PRX_DB_INSTANCE;
	l_context(10).a_val := G_PRX_CHILD_TRANS_CONTEXT_ID;
      end if;

      l_log_sequence := STRING_UNCHECKED_INTERNAL2(LOG_LEVEL => LOG_LEVEL,
                    MODULE          => l_module,
                    MESSAGE_TEXT    => MESSAGE_TEXT,
                    LOG_SEQUENCE    => l_log_sequence,
                    ENCODED         => l_encoded,
                    SESSION_ID      => to_number(l_context(1).a_val),
                    USER_ID         => to_number(l_context(2).a_val),
                    NODE            => l_context(3).a_val,
                    NODE_IP_ADDRESS => l_context(4).a_val,
                    PROCESS_ID      => l_context(5).a_val,
                    JVM_ID          => l_context(6).a_val,
                    THREAD_ID       => l_context(7).a_val,
                    AUDSID          => l_context(8).a_val,
                    DB_INSTANCE     => l_context(9).a_val,
                    TRANSACTION_CONTEXT_ID => l_context(10).a_val,
                    CALL_STACK      => CALL_STACK,
                    ERR_STACK       => ERR_STACK);

      /* Unexpected errors are posted as exceptions */
      if (l_encoded = 'Y') and (LOG_LEVEL = FND_LOG.LEVEL_UNEXPECTED) then
         l_posted :=  POST_EXCEPTION(P_MODULE         => l_module,
                                     P_LOG_SEQUENCE   => l_log_sequence);
      end if;

      return l_log_sequence;

      end;

   /**
    * Inserts a empty BLOB for the P_LOG_SEQUENCE
    */
   PROCEDURE INSERT_BLOB(P_LOG_SEQUENCE IN NUMBER, PCHARSET IN VARCHAR2,
		PMIMETYPE IN VARCHAR2, PENCODING IN VARCHAR2, PLANG IN VARCHAR2,
		PFILE_EXTN IN VARCHAR2, PDESC IN VARCHAR2) is
   pragma AUTONOMOUS_TRANSACTION;
     begin
          INSERT INTO FND_LOG_ATTACHMENTS fla
          (
                LOG_SEQUENCE,
		CHARSET,
		MIMETYPE,
		ENCODING,
		LANGUAGE,
		FILE_EXTN,
		DESCRIPTION,
                CONTENT
          ) values
          (
                P_LOG_SEQUENCE,
		PCHARSET,
		PMIMETYPE,
		PENCODING,
		PLANG,
		PFILE_EXTN,
		PDESC,
                EMPTY_BLOB()
          );
          commit;
     end;

   /**
    * For AOL/J Internal use ONLY!
    * Returns a BLOB for the P_LOG_SEQUENCE
    *
    * Called from Client and Server PL/SQL
    */
   PROCEDURE GET_BLOB_INTERNAL(P_LOG_SEQUENCE IN NUMBER,
                        LOG_BLOB OUT NOCOPY BLOB,
                        P_CHARSET IN VARCHAR2 DEFAULT 'ascii',
                        P_MIMETYPE IN VARCHAR2 DEFAULT 'text/html',
                        P_ENCODING IN VARCHAR2 DEFAULT NULL,
                        P_LANG IN VARCHAR2 DEFAULT NULL,
                        P_FILE_EXTN IN VARCHAR2 DEFAULT 'txt',
			P_DESC IN VARCHAR2 DEFAULT NULL) is
      l_log_sequence NUMBER := -1;
   begin
      if ( P_LOG_SEQUENCE is NULL or P_LOG_SEQUENCE < 0 ) then
         LOG_BLOB := NULL;
         return;
      end if;

      select content
        into LOG_BLOB
        from FND_LOG_ATTACHMENTS fla
        where fla.log_sequence = P_LOG_SEQUENCE for UPDATE;
      return;

      EXCEPTION
  	WHEN NO_DATA_FOUND THEN
        begin
	  select flm.log_sequence
            into l_log_sequence
            from fnd_log_messages flm
            where flm.log_sequence = P_LOG_SEQUENCE;

	  -- If log_sequence does not exist in fnd_log_messages
          -- its an invalid log_sequence, return NULL
	  EXCEPTION
            WHEN NO_DATA_FOUND THEN
	      LOG_BLOB := NULL;
	      return;
        END;

	-- If log_sequence exists create attachment
	INSERT_BLOB(P_LOG_SEQUENCE, P_CHARSET, P_MIMETYPE, P_ENCODING, P_LANG, P_FILE_EXTN, P_DESC);

        select content
          into LOG_BLOB
          from FND_LOG_ATTACHMENTS fla
          where fla.log_sequence = P_LOG_SEQUENCE for UPDATE;
      end GET_BLOB_INTERNAL;

   /*
   ** FND_LOG_REPOSITORY.METRIC_INTERNAL
   ** Description:
   **  Private -- Should only be called by METRIC_INTERNAL_WITH_CONTEXT
   **  Writes a metric value out to the FND tables in an autonomous
   **  transaction.
   */
   PROCEDURE METRIC_INTERNAL(MODULE        IN VARCHAR2,
                    METRIC_CODE            IN VARCHAR2,
                    METRIC_SEQUENCE        IN NUMBER,
                    TYPE                   IN VARCHAR2,
                    STRING_VALUE           IN VARCHAR2,
                    NUMBER_VALUE           IN NUMBER,
                    DATE_VALUE             IN DATE,
                    TRANSACTION_CONTEXT_ID IN NUMBER,
                    SESSION_MODULE         IN VARCHAR2,
                    SESSION_ACTION         IN VARCHAR2,
                    NODE                   IN VARCHAR2,
                    NODE_IP_ADDRESS        IN VARCHAR2,
                    PROCESS_ID             IN VARCHAR2,
                    JVM_ID                 IN VARCHAR2,
                    THREAD_ID              IN VARCHAR2,
                    AUDSID                 IN VARCHAR2,
                    DB_INSTANCE            IN VARCHAR2) is
   pragma AUTONOMOUS_TRANSACTION;
     begin
       insert into FND_LOG_METRICS
        (MODULE,
         METRIC_CODE,
         METRIC_SEQUENCE,
         TYPE,
         STRING_VALUE,
         NUMBER_VALUE,
         DATE_VALUE,
         TIME,
         EVENT_KEY,
         TRANSACTION_CONTEXT_ID,
         SESSION_MODULE,
         SESSION_ACTION,
         NODE,
         NODE_IP_ADDRESS,
         PROCESS_ID,
         JVM_ID,
         THREAD_ID,
         AUDSID,
         DB_INSTANCE
        ) values
        (SUBSTRB(MODULE,1,255),
         METRIC_CODE,
         METRIC_SEQUENCE,
         TYPE,
         STRING_VALUE,
         NUMBER_VALUE,
         DATE_VALUE,
         SYSDATE,
         null,
         TRANSACTION_CONTEXT_ID,
         substrb(SESSION_MODULE,1,48),
         substrb(SESSION_ACTION,1,32),
         substrb(NODE,1,60),
         substrb(NODE_IP_ADDRESS,1,30),
         substrb(PROCESS_ID,1,120),
         substrb(JVM_ID,1,120),
         substrb(THREAD_ID,1,120),
         AUDSID,
         DB_INSTANCE
         );
       commit;
     end METRIC_INTERNAL;


   /*
   **  Convert the string into date format, store in global variable
   */
   PROCEDURE METRIC_STRING_TO_DATE(DATE_VC IN VARCHAR2 DEFAULT NULL) is
   begin

      if (DATE_VC IS NOT NULL) then
         FND_LOG_REPOSITORY.G_METRIC_DATE := FND_CONC_DATE.STRING_TO_DATE(DATE_VC);
         if (FND_LOG_REPOSITORY.G_METRIC_DATE IS NULL) then
            select SYSDATE
            into FND_LOG_REPOSITORY.G_METRIC_DATE
            from dual;
         end if;
      else
         select SYSDATE
         into FND_LOG_REPOSITORY.G_METRIC_DATE
         from dual;
      end if;

   end METRIC_STRING_TO_DATE;


   /*
   **  Gathers context information within the same session, then
   **  calls the private, autonmous procedure METRIC_INTERNAL,
   **  passing context information to be logged in AFLOG tables
   **
   **  A wrapper API that calls Metric_Internal using the
   **  context values from internal cache of the context values.
   **  This routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **  If the SESSION_ID is not passed, it defaults to the value that
   **  was passed upon INIT.
   */
   PROCEDURE METRIC_INTERNAL_WITH_CONTEXT(MODULE IN VARCHAR2,
                    METRIC_CODE            IN VARCHAR2,
                    METRIC_VALUE_STRING    IN VARCHAR2 DEFAULT NULL,
                    METRIC_VALUE_NUMBER    IN NUMBER   DEFAULT NULL,
                    METRIC_VALUE_DATE      IN DATE     DEFAULT NULL,
                    SESSION_ID             IN NUMBER   DEFAULT NULL,
                    NODE                   IN VARCHAR2 DEFAULT NULL,
                    NODE_IP_ADDRESS        IN VARCHAR2 DEFAULT NULL,
                    PROCESS_ID             IN VARCHAR2 DEFAULT NULL,
                    JVM_ID                 IN VARCHAR2 DEFAULT NULL,
                    THREAD_ID              IN VARCHAR2 DEFAULT NULL,
                    AUDSID                 IN NUMBER   DEFAULT NULL,
                    DB_INSTANCE            IN NUMBER   DEFAULT NULL) is
      l_context          CONTEXT_ARRAY;
      l_metric_sequence  number;
      l_type             varchar2(1);
      l_metric_value_date date;

      begin
      if(NOT SELF_INITED_X) then
         SELF_INIT;
      end if;

      GET_CONTEXT (
                   SESSION_ID      => SESSION_ID,
                   USER_ID         => -1,
                   NODE            => NODE,
                   NODE_IP_ADDRESS => NODE_IP_ADDRESS,
                   PROCESS_ID      => PROCESS_ID,
                   JVM_ID          => JVM_ID,
                   THREAD_ID       => THREAD_ID,
                   AUDSID          => AUDSID,
                   DB_INSTANCE     => DB_INSTANCE,
		   CONTEXT_OUT     => l_context);

      select module, action
          into l_context(11).a_val, l_context(12).a_val
          from v$session
          where audsid = TXN_SESSION;

      select FND_LOG_METRICS_S.NEXTVAL
        into l_metric_sequence
        from dual;

      if (METRIC_VALUE_STRING is NOT NULL) then
        l_type := 'S';
      elsif (METRIC_VALUE_NUMBER is NOT NULL) then
        l_type := 'N';
      else
        l_type := 'D';
        if (METRIC_VALUE_DATE is NULL) then
           l_metric_value_date := FND_LOG_REPOSITORY.G_METRIC_DATE;
        else
           l_metric_value_date := METRIC_VALUE_DATE;
        end if;

      end if;

      if (AFLOG_FILENAME_X is not NULL) then
         null; /* Eventually we will want to add code that will log to a */
               /* file if they set the filename, but for now we will just */
               /* log to table */
      end if;

      METRIC_INTERNAL(MODULE               => MODULE,
                    METRIC_CODE            => METRIC_CODE,
                    METRIC_SEQUENCE        => l_metric_sequence,
                    TYPE                   => l_type,
                    STRING_VALUE           => METRIC_VALUE_STRING,
                    NUMBER_VALUE           => METRIC_VALUE_NUMBER,
                    DATE_VALUE             => l_metric_value_date,
                    TRANSACTION_CONTEXT_ID => l_context(10).a_val,
                    SESSION_MODULE         => l_context(11).a_val,
                    SESSION_ACTION         => l_context(12).a_val,
                    NODE                   => l_context(3).a_val,
                    NODE_IP_ADDRESS        => l_context(4).a_val,
                    PROCESS_ID             => l_context(5).a_val,
                    JVM_ID                 => l_context(6).a_val,
                    THREAD_ID              => l_context(7).a_val,
                    AUDSID                 => l_context(8).a_val,
                    DB_INSTANCE            => l_context(9).a_val);

      end METRIC_INTERNAL_WITH_CONTEXT;

   /*
   ** FND_LOG_REPOSITORY.METRICS_EVENT_INTERNAL
   ** Description:
   **  Private -- Should only be called by METRICS_EVENT_INT_WITH_CONTEXT
   **  Posts the pending metrics for the current component
   **  session to the Business Event system and updates the pending
   **  metrics with the event key in an autonomous transaction. The
   **  metrics will be bundled in an XML message included in the
   **  event.  The event will be named:
   **  "oracle.apps.fnd.system.metrics"
   **
   ** Arguments:
   **     CONTEXT_ID - Context id to post metrics for
   */

   PROCEDURE METRICS_EVENT_INTERNAL(CONTEXT_ID IN NUMBER) IS
      l_event_key number;
      pragma AUTONOMOUS_TRANSACTION;

   cnt    number;

   begin

      /*
         2983052: Check for rows in FND_LOG_METRICS
         If no metrics actually logged, don't raise an event.
      */
      select count(1)
        into cnt
        from FND_LOG_METRICS
        where TRANSACTION_CONTEXT_ID = CONTEXT_ID;

      if cnt = 0 then
        return;
      end if;

      select FND_METRICS_EVENT_KEY_S.nextval
        into l_event_key
        from dual;

      update FND_LOG_METRICS
         set EVENT_KEY = l_event_key
       where EVENT_KEY is NULL
         and TRANSACTION_CONTEXT_ID = CONTEXT_ID;

      begin
         WF_EVENT.RAISE('oracle.apps.fnd.system.metrics',
                        to_char(l_event_key) );
         commit;
      exception
         when others then
            FND_MESSAGE.SET_NAME ('FND', 'SQL-Generic error');
            FND_MESSAGE.SET_TOKEN ('ERRNO', sqlcode, FALSE);
            FND_MESSAGE.SET_TOKEN ('REASON', sqlerrm, FALSE);
            FND_MESSAGE.SET_TOKEN ('ROUTINE',
                                    'FND_LOG_REPOSITORY.METRIC_EVENT_INTERNAL', FALSE);
            rollback;
      end;

   end METRICS_EVENT_INTERNAL;

   /*
   ** FND_LOG_REPOSITORY.METRICS_EVENT_INT_WITH_CONTEXT
   ** Description:
   **  A wrapper API that calls Metrics_Event_Internal using the
   **  context values from internal cache of the context values.
   **  This routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **
   ** Arguments:
   **     CONTEXT_ID - Context id to post metrics for
   */
   PROCEDURE METRICS_EVENT_INT_WITH_CONTEXT (CONTEXT_ID IN NUMBER DEFAULT NULL)IS
      l_context_id number;

   begin
      if CONTEXT_ID is NOT NULL then
         l_context_id := CONTEXT_ID;
      else
         l_context_id := FND_LOG.G_TRANSACTION_CONTEXT_ID;
      end if;

      METRICS_EVENT_INTERNAL(l_context_id);

   end METRICS_EVENT_INT_WITH_CONTEXT;



   /*
   ** FND_LOG_REPOSITORY.INIT_TRANS_INT_WITH_CONTEXT
   ** Description:
   ** A wrapper API that calls Init_Transaction_Internal using the
   ** context values from internal cache of the context values.
   ** This routine is only to be called from the AOL implementations of
   ** the AFLOG interface, in languages like JAVA or C.
   ** If the SESSION_ID and/or USER_ID is not passed, it defaults to the
   ** value that was passed upon INIT.
   **
   ** Initializes a log transaction.  A log transaction
   ** corresponds to an instance or invocation of a single
   ** component.  (e.g. A concurrent request, service process,
   ** open form, ICX function)
   **
   ** This routine should be called only after
   ** FND_GLOBAL.INITIALIZE, since some of the context information
   ** is retrieved from FND_GLOBAL.
   **
   ** Arguments:
   **   CONC_REQUEST_ID       - Concurrent request id
   **   FORM_ID               - Form id
   **   FORM_APPLICATION_ID   - Form application id
   **   CONCURRENT_PROCESS_ID - Service process id
   **   CONCURRENT_QUEUE_ID   - Service queue id
   **   QUEUE_APPLICATION_ID  - Service queue application id
   **   SOA_INSTANCE_ID       - SOA instance id
   **
   ** Use only the arguments that apply to the caller.
   ** Any argument that does not apply should be passed as NULL
   ** i.e. when calling from a form, pass in FORM_ID and FORM_APPLICATION_ID
   ** and leave all other parameters NULL.
   **
   ** Returns:
   **   ID of the log transaction context
   **
   */
   FUNCTION INIT_TRANS_INT_WITH_CONTEXT (CONC_REQUEST_ID             IN NUMBER DEFAULT NULL,
                                         FORM_ID                     IN NUMBER DEFAULT NULL,
                                         FORM_APPLICATION_ID         IN NUMBER DEFAULT NULL,
                                         CONCURRENT_PROCESS_ID       IN NUMBER DEFAULT NULL,
                                         CONCURRENT_QUEUE_ID         IN NUMBER DEFAULT NULL,
                                         QUEUE_APPLICATION_ID        IN NUMBER DEFAULT NULL,
                                         SESSION_ID                  IN NUMBER DEFAULT NULL,
                                         USER_ID                     IN NUMBER DEFAULT NULL,
                                         RESP_APPL_ID                IN NUMBER DEFAULT NULL,
                                         RESPONSIBILITY_ID           IN NUMBER DEFAULT NULL,
                                         SECURITY_GROUP_ID           IN NUMBER DEFAULT NULL,
					 SOA_INSTANCE_ID             IN NUMBER DEFAULT NULL)
                                                          return NUMBER is

      l_context                 context_array;
      l_transaction_type        varchar2(30);
      l_transaction_id          number;
      l_component_appl_id       number;
      l_component_type          varchar2(30);
      l_component_id            number;
      l_transaction_context_id  number;
      l_form_id                 number;
      l_form_application_id     number;

      begin
      if(NOT SELF_INITED_X) then
         SELF_INIT;
      end if;

      GET_TRANSACTION_CONTEXT (
                     SESSION_ID          => SESSION_ID,
                     USER_ID             => USER_ID,
                     RESP_APPL_ID        => RESP_APPL_ID,
                     RESPONSIBILITY_ID   => RESPONSIBILITY_ID,
                     SECURITY_GROUP_ID   => SECURITY_GROUP_ID,
		     CONTEXT_OUT	 => l_context);

      -- concurrent processes
      -- order is important here, must check for a concurrent process before
      -- a concurrent request.
      if concurrent_process_id is not null and
             (concurrent_process_id > 0 or concurrent_process_id = -999) then

        -- ignore this value, the real value will be along soon...
        if  concurrent_process_id = -999 then
            return null;
        end if;

        -- see if a transaction context exists for this process
        begin
          select transaction_context_id
            into l_transaction_context_id
            from fnd_log_transaction_context
            where transaction_type = 'SERVICE'
            and transaction_id = concurrent_process_id;

          return l_transaction_context_id;

        exception
             when no_data_found then
               -- create a new transaction context
               l_transaction_type  := 'SERVICE';
               l_transaction_id    := concurrent_process_id;
               l_component_id      := concurrent_queue_id;
               l_component_appl_id := queue_application_id;
               l_component_type    := 'SERVICE_INSTANCE';
        end;

      -- concurrent requests
      elsif conc_request_id is not null and conc_request_id > 0 then

        -- see if a transaction context exists for this request
        begin
          select transaction_context_id
            into l_transaction_context_id
            from fnd_log_transaction_context
            where transaction_type = 'REQUEST'
            and transaction_id = conc_request_id;

          return l_transaction_context_id;

        exception
             when no_data_found then
               -- create a new transaction context
               l_transaction_type  := 'REQUEST';
               l_transaction_id    := conc_request_id;
               l_component_id      := FND_GLOBAL.conc_program_id;
               l_component_appl_id := FND_GLOBAL.prog_appl_id;
               l_component_type    := 'CONCURRENT_PROGRAM';
        end;

      -- forms
      elsif form_id is not null and (form_id > 0 or form_id = -999) then

        l_transaction_id := TXN_SESSION; -- using AUDSID as the transaction_id

         if form_id = -999 then
            l_form_id := null;
            l_form_application_id := null;
         else
            l_form_id := form_id;
            l_form_application_id := form_application_id;
         end if;

        -- see if a transaction context exists for this form
        begin
          select transaction_context_id
            into l_transaction_context_id
            from fnd_log_transaction_context
            where transaction_type = 'FORM'
            and transaction_id = l_transaction_id;

          return l_transaction_context_id;

        exception
             when no_data_found then
               -- create a new transaction context for this form
               l_transaction_type  := 'FORM';
               l_component_id      := l_form_id;
               l_component_appl_id := l_form_application_id;
               l_component_type    := 'FORM';
        end;


      -- SOA instance
      elsif soa_instance_id is not null and soa_instance_id > 0 then

        -- see if a transaction context exists for this instance
        begin
          select transaction_context_id
            into l_transaction_context_id
            from fnd_log_transaction_context
            where transaction_type = 'SOA_INSTANCE'
            and transaction_id = soa_instance_id;

          return l_transaction_context_id;

        exception
             when no_data_found then
               -- create a new transaction context
               l_transaction_type  := 'SOA_INSTANCE';
               l_transaction_id    := soa_instance_id;
               l_component_id      := null;
               l_component_appl_id := null;
               l_component_type    := 'SOA_INSTANCE';
        end;


      -- ICX sessions, ICX transactions
      elsif icx_sec.g_session_id is not null and icx_sec.g_session_id > 0 then

        -- see if a transaction context exists for this session
        begin
          l_component_id := null;

	  -- Check for finer ICX Transaction
          if icx_sec.g_transaction_id is not null and icx_sec.g_transaction_id > 0 then
	    begin
          	select transaction_context_id
            	  into l_transaction_context_id
            	  from fnd_log_transaction_context
            	  where transaction_type = 'ICX'
            	  and transaction_id = icx_sec.g_transaction_id
		  and session_id = icx_sec.g_session_id
		  and user_id = to_number(l_context(2).a_val)
		  and resp_appl_id = to_number(l_context(3).a_val)
		  and responsibility_id = to_number(l_context(4).a_val)
		  and security_group_id = to_number(l_context(5).a_val)
	          and rownum = 1; -- there maybe previous duplicate rows
          	return l_transaction_context_id;

        	exception
             	  when no_data_found then
               	  -- create a new transaction context
		  null;
         /*
               	  begin
                    select function_id
                      into l_component_id
                      from icx_transactions
                      where transaction_id = icx_sec.g_transaction_id;
                    exception
                      when others then
                        l_component_id := null;
                  end;
	  */
            end;

	  else
	  -- Check for coarser ICX Session
            begin
                select transaction_context_id
                  into l_transaction_context_id
                  from fnd_log_transaction_context
                  where transaction_type = 'ICX'
                  and session_id = icx_sec.g_session_id
		  and transaction_id = -1
                  and user_id = to_number(l_context(2).a_val)
                  and resp_appl_id = to_number(l_context(3).a_val)
                  and responsibility_id = to_number(l_context(4).a_val)
                  and security_group_id = to_number(l_context(5).a_val)
	          and rownum = 1; -- there maybe previous duplicate rows
                return l_transaction_context_id;

                exception
                  when no_data_found then
                  -- create a new transaction context
		  null;
	  /*
                  begin
                    select function_id
                      into l_component_id
                      from icx_sessions
                      where session_id = icx_sec.g_session_id;
                    exception
                      when others then
                        l_component_id := null;
                  end;
	  */
            end;
          end if;

          l_transaction_type  := 'ICX';
          l_transaction_id    := icx_sec.g_transaction_id;
          l_component_appl_id := null;
          l_component_type    := 'FUNCTION';
        end;

      -- if none of the above, check for 'UNKNOWN' context
      else

        begin
          select transaction_context_id
            into l_transaction_context_id
            from fnd_log_transaction_context
            where transaction_type = 'UNKNOWN'
            and session_id = -1
            and transaction_id = -1
            and user_id = to_number(l_context(2).a_val)
            and resp_appl_id = to_number(l_context(3).a_val)
            and responsibility_id = to_number(l_context(4).a_val)
            and security_group_id = to_number(l_context(5).a_val)
	    and rownum = 1; -- there maybe previous duplicate rows
          return l_transaction_context_id;
        exception
          when no_data_found then
            l_transaction_type := 'UNKNOWN';
            l_transaction_id := -1;
            l_component_type := null;
            l_component_appl_id := -1;
            l_component_id := -1;
	end;

      end if;


     INIT_TRANSACTION_INTERNAL(
               P_TRANSACTION_TYPE            => l_transaction_type,
               P_TRANSACTION_ID              => l_transaction_id,
               P_COMPONENT_TYPE              => l_component_type,
               P_COMPONENT_APPL_ID           => l_component_appl_id,
               P_COMPONENT_ID                => l_component_id,
               P_SESSION_ID                  => to_number(l_context(1).a_val),
               P_USER_ID                     => to_number(l_context(2).a_val),
               P_RESP_APPL_ID                => to_number(l_context(3).a_val),
               P_RESPONSIBILITY_ID           => to_number(l_context(4).a_val),
               P_SECURITY_GROUP_ID           => to_number(l_context(5).a_val));

   return FND_LOG.G_TRANSACTION_CONTEXT_ID;

   end INIT_TRANS_INT_WITH_CONTEXT;


   /*
   ** Internal- This routine initializes the logging system from the
   ** profiles.  AOL will normally call this routine to initialize the
   ** system so the API consumer should not need to call it.
   ** The SESSION_ID is a unique identifier (like the ICX_SESSION id)
   ** The USER_ID is the name of the apps user.
   */
   PROCEDURE INIT(SESSION_ID   IN NUMBER default NULL,
                  USER_ID      IN NUMBER default NULL) is
        POS       NUMBER;
        NEXTPOS   NUMBER;
		DATA_SIZE NUMBER;

   begin
      if(SESSION_ID is NULL) then
         SESSION_ID_X := icx_sec.g_session_id;
      else
         SESSION_ID_X := SESSION_ID;
      end if;

      if(USER_ID is NULL) then
         USER_ID_X    := to_number(FND_PROFILE.VALUE('USER_ID'));
      else
         USER_ID_X := USER_ID;
      end if;

      if(USER_ID_X is NULL) then
         USER_ID_X    := -1;
      end if;


      if (SUBSTR(FND_PROFILE.VALUE('AFLOG_ENABLED'), 1, 1) = 'Y') then
         AFLOG_ENABLED_X     := TRUE;
         AFLOG_FILENAME_X    := SUBSTR(FND_PROFILE.VALUE('AFLOG_FILENAME'), 1,
                                 255);
         AFLOG_LEVEL_X       := TO_NUMBER(FND_PROFILE.VALUE('AFLOG_LEVEL'));
         AFLOG_MODULE_X      := UPPER(SUBSTR(
                                   FND_PROFILE.VALUE('AFLOG_MODULE'),
                                   1, 2000));
      else
         AFLOG_ENABLED_X     := FALSE;
         AFLOG_FILENAME_X    := NULL;
         AFLOG_LEVEL_X       := NULL;
         AFLOG_MODULE_X      := NULL;
      end if;

      /* Set up the global level in the log package so it won't have */
      /* to call through in order to find out whether logging is */
      /* enabled at this level. */
      if (AFLOG_ENABLED_X) then
		FND_LOG.G_CURRENT_RUNTIME_LEVEL := AFLOG_LEVEL_X;

		/* Tracing disabled for initial 12.0 release
        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
          DBMS_TRACE.SET_PLSQL_TRACE(DBMS_TRACE.trace_all_exceptions);
          fnd_log_enabled_tracing := true;
        elsif (fnd_log_enabled_tracing) then
          DBMS_TRACE.CLEAR_PLSQL_TRACE;
          fnd_log_enabled_tracing := false;
		end if;
		*/
      else
		FND_LOG.G_CURRENT_RUNTIME_LEVEL := 99999;
		/*
	    if (fnd_log_enabled_tracing) then
          DBMS_TRACE.CLEAR_PLSQL_TRACE;
          fnd_log_enabled_tracing := false;
		end if;
		*/
      end if;

      /* Store away the module list in the module table */
      if(AFLOG_MODULE_X is null) then
         TABLE_SIZE := 0;
      else
         POS := 1;
         TABLE_SIZE := 0;
         DATA_SIZE := LENGTH(AFLOG_MODULE_X);
         while POS <= DATA_SIZE loop
            NEXTPOS := INSTR(AFLOG_MODULE_X, ',', POS);
            if(NEXTPOS = 0) then
               NEXTPOS := DATA_SIZE + 1;
            end if;
            TABLE_SIZE := TABLE_SIZE + 1;
            MODULE_TAB(TABLE_SIZE) := UPPER(LTRIM(RTRIM(
                SUBSTR(AFLOG_MODULE_X, POS, NEXTPOS - POS))))||'%';
            POS := NEXTPOS+1; /* Advance past the comma */
         end loop;
      end if;

      SELF_INITED_X := TRUE;

      /* Deferred Init: All initialization is now deferred to GET_CONTEXT */
      FND_LOG.G_TRANSACTION_CONTEXT_ID := null;

   exception
     when OTHERS then
        /* Make sure that an exception here does not stop Apps initialization */
        null;
   end;

   /**
    *  Private procedure called from AppsLog.java if buffering messages
    *  for Bulk logging. AppsLog.java can buffer (if setAsynchMode is enabled)
    *  messages with the context returned from this procedure (to preserve
    *  the context and sequence) and periodically flushes by calling BULK_INSERT_PVT().
    */
   PROCEDURE GET_BULK_CONTEXT_PVT (
                                LOG_SEQUENCE_OUT OUT NOCOPY NUMBER,
                                TIMESTAMP_OUT    OUT NOCOPY DATE,
                                DBSESSIONID_OUT  OUT NOCOPY NUMBER,
                                DBINSTANCE_OUT   OUT NOCOPY NUMBER,
                                TXN_ID_OUT       OUT NOCOPY NUMBER
                                ) is
     l_context  CONTEXT_ARRAY;
   begin

     if(NOT SELF_INITED_X) then
       SELF_INIT;
       if(FND_LOG.G_TRANSACTION_CONTEXT_ID is null) then
	  GET_CONTEXT(CONTEXT_OUT => l_context);
       end if;
     end if;

     select FND_LOG_MESSAGES_S.NEXTVAL
	into LOG_SEQUENCE_OUT
	from dual;

     TIMESTAMP_OUT := sysdate;
     DBSESSIONID_OUT := TXN_SESSION;
     DBINSTANCE_OUT := TXN_INSTANCE;
     TXN_ID_OUT := FND_LOG.G_TRANSACTION_CONTEXT_ID;

   end GET_BULK_CONTEXT_PVT;

   /**
    *  Private function for Bulk logging messages
    */
   FUNCTION BULK_INSERT_PVT(MODULE_IN IN FND_TABLE_OF_VARCHAR2_255,
                        LOG_LEVEL_IN IN FND_TABLE_OF_NUMBER,
                        MESSAGE_TEXT_IN IN FND_TABLE_OF_VARCHAR2_4000,
                        SESSION_ID_IN IN FND_TABLE_OF_NUMBER,
                        USER_ID_IN IN FND_TABLE_OF_NUMBER,
                        TIMESTAMP_IN IN FND_TABLE_OF_DATE,
                        LOG_SEQUENCE_IN IN FND_TABLE_OF_NUMBER,
                        ENCODED_IN IN FND_TABLE_OF_VARCHAR2_1,
                        NODE_IN IN varchar2,
                        NODE_IP_ADDRESS_IN IN varchar2,
                        PROCESS_ID_IN IN varchar2,
                        JVM_ID_IN IN varchar2,
                        THREAD_ID_IN IN FND_TABLE_OF_VARCHAR2_120,
                        AUDSID_IN IN FND_TABLE_OF_NUMBER,
                        DB_INSTANCE_IN IN FND_TABLE_OF_NUMBER,
			TRANSACTION_CONTEXT_ID_IN IN FND_TABLE_OF_NUMBER,
			SIZE_IN IN NUMBER) RETURN NUMBER is
  pragma AUTONOMOUS_TRANSACTION;
      l_node     varchar2(60);
      l_node_ip_address varchar2(30);
      l_process_id varchar2(120);
      l_jvm_id   varchar2(120);
      l_posted   boolean := FALSE;
      i          NUMBER;
  begin

    if(NOT SELF_INITED_X) then
       SELF_INIT;
    end if;

    l_node := substrb(NODE_IN,1,60);
    l_node_ip_address := substrb(NODE_IP_ADDRESS_IN,1,30);
    l_process_id := substrb(nvl(PROCESS_ID_IN, TXN_PROCESS),1,120);
    l_jvm_id := substrb(JVM_ID_IN,1,120);

    FORALL i IN 1..SIZE_IN
      INSERT INTO FND_LOG_MESSAGES (
         MODULE,
         LOG_LEVEL,
         MESSAGE_TEXT,
         SESSION_ID,
         USER_ID,
         TIMESTAMP,
         LOG_SEQUENCE,
         ENCODED,
         NODE,
         NODE_IP_ADDRESS,
         PROCESS_ID,
         JVM_ID,
         THREAD_ID,
         AUDSID,
         DB_INSTANCE,
         TRANSACTION_CONTEXT_ID
      ) values
      (
         MODULE_IN(i),
         LOG_LEVEL_IN(i),
         NOPASS(MESSAGE_TEXT_IN(i)),
         SESSION_ID_IN(i),
         nvl(USER_ID_IN(i), -1),
         nvl(TIMESTAMP_IN(i), sysdate),
         nvl(LOG_SEQUENCE_IN(i), FND_LOG_MESSAGES_S.NEXTVAL),
         ENCODED_IN(i),
         l_node,
         l_node_ip_address,
         l_process_id,
         l_jvm_id,
         substrb(THREAD_ID_IN(i),1,120),
         AUDSID_IN(i),
         DB_INSTANCE_IN(i),
         TRANSACTION_CONTEXT_ID_IN(i)
      );

    commit;


    /* Typically there won't be any UNEXPECTED messages logged using this Function */
    /* Unexpected errors are posted as exceptions */
/*
    FOR i IN 1..SIZE_IN LOOP
      if (ENCODED_IN(i) = 'Y') and (LOG_LEVEL_IN(i) = FND_LOG.LEVEL_UNEXPECTED) then
         l_posted :=  POST_EXCEPTION(P_MODULE         => MODULE_IN(i),
                                     P_LOG_SEQUENCE   => LOG_SEQUENCE_IN(i),
                                     P_SESSION_MODULE => NULL,
                                     P_SESSION_ACTION => NULL);
      end if;
    END LOOP;
*/
    return SIZE_IN;
  end BULK_INSERT_PVT;

/*============================================================================
 * Proxy Alerting related Procedures - Start
 *===========================================================================*/
 /** For Debugging Only
 PROCEDURE DUMP_CC is

 BEGIN
   DEBUG('=============================================');
   DEBUG('G_PRX_CHILD_TRANS_CONTEXT_ID: ' || G_PRX_CHILD_TRANS_CONTEXT_ID);
   DEBUG('G_PRX_SESSION_ID: ' || G_PRX_SESSION_ID);
   DEBUG('G_PRX_USER_ID: ' || G_PRX_USER_ID);
   DEBUG('G_PRX_SESSION_MODULE: ' || G_PRX_SESSION_MODULE);
   DEBUG('G_PRX_SESSION_ACTION: ' || G_PRX_SESSION_ACTION);
   DEBUG('G_PRX_MODULE: ' || G_PRX_MODULE);
   DEBUG('G_PRX_NODE: ' || G_PRX_NODE);
   DEBUG('G_PRX_NODE_IP_ADDRESS: ' || G_PRX_NODE_IP_ADDRESS);
   DEBUG('G_PRX_PROCESS_ID: ' || G_PRX_PROCESS_ID);
   DEBUG('G_PRX_JVM_ID: ' || G_PRX_JVM_ID);
   DEBUG('G_PRX_THREAD_ID: ' || G_PRX_THREAD_ID);
   DEBUG('G_PRX_AUDSID: ' || G_PRX_AUDSID);
   DEBUG('G_PRX_DB_INSTANCE: ' || G_PRX_DB_INSTANCE);
 END DUMP_CC;
 */

 /**
  * Fetches context information for the given concurrent request ID and
  * places them in the given CONTEXT_ARRAY output variable.
  */
 PROCEDURE FETCH_CONTEXT_FOR_CONC_REQ(
	p_request_id IN NUMBER,
	p_info_type IN VARCHAR2 DEFAULT 'ALL',
	p_context_array OUT NOCOPY CONTEXT_ARRAY) is

 BEGIN
   --
   -- Fetch basic transaction context information for the given request id
   --
   if (p_info_type = 'ALL') then
     begin
       	select fcr.requested_by, fcr.responsibility_application_id,
	       fcr.responsibility_id, fcr.security_group_id,
	       'CONCURRENT_PROGRAM', fcr.program_application_id,
	       fcr.concurrent_program_id
	  into
	    p_context_array(CCI_USER_ID).a_val,
	    p_context_array(CCI_RESP_APPL_ID).a_val,
	    p_context_array(CCI_RESPONSIBILITY_ID).a_val,
	    p_context_array(CCI_SECURITY_GROUP_ID).a_val,
	    p_context_array(CCI_COMPONENT_TYPE).a_val,
	    p_context_array(CCI_COMPONENT_APPL_ID).a_val,
	    p_context_array(CCI_COMPONENT_ID).a_val
	  from fnd_concurrent_requests fcr
	  where fcr.request_id = p_request_id;
     exception
	when no_data_found then
	    p_context_array(CCI_USER_ID).a_val := null;
	    p_context_array(CCI_RESP_APPL_ID).a_val := null;
	    p_context_array(CCI_RESPONSIBILITY_ID).a_val := null;
	    p_context_array(CCI_SECURITY_GROUP_ID).a_val := null;
	    p_context_array(CCI_COMPONENT_TYPE).a_val := null;
	    p_context_array(CCI_COMPONENT_APPL_ID).a_val := null;
	    p_context_array(CCI_COMPONENT_ID).a_val := null;
     end;
   end if;
   --
   -- Attempt to fetch additional info that we might be able to get
   --
   if (p_info_type = 'ALL' or p_info_type = 'ADDITIONAL') then
     begin
	select fcr.requested_by, fcr.oracle_session_id, fcr.os_process_id,
		gv.module, gv.action, '-1'
	  into
	    p_context_array(CCI_USER_ID).a_val,
	    p_context_array(CCI_AUDSID).a_val,
	    p_context_array(CCI_PROCESS_ID).a_val,
	    p_context_array(CCI_SESSION_MODULE).a_val,
	    p_context_array(CCI_SESSION_ACTION).a_val,
	    p_context_array(CCI_SESSION_ID).a_val
	  from fnd_concurrent_requests fcr,
	       gv$session gv
	  where fcr.request_id = p_request_id
		and fcr.oracle_session_id = gv.audsid (+);
     exception
	when no_data_found then
	   p_context_array(CCI_USER_ID).a_val := null;
	   p_context_array(CCI_AUDSID).a_val := null;
	   p_context_array(CCI_PROCESS_ID).a_val := null;
	   p_context_array(CCI_SESSION_MODULE).a_val := null;
	   p_context_array(CCI_SESSION_ACTION).a_val := null;
	   p_context_array(CCI_SESSION_ID).a_val := null;
     end;
   end if;
   --
   -- Also set some additional variables that we won't be able to fetch
   --
   p_context_array(CCI_MODULE).a_val := null;
   p_context_array(CCI_NODE).a_val := null;
   p_context_array(CCI_NODE_IP_ADDRESS).a_val := null;
   p_context_array(CCI_JVM_ID).a_val := null;
   p_context_array(CCI_THREAD_ID).a_val := null;
   p_context_array(CCI_DB_INSTANCE).a_val := null;

 END FETCH_CONTEXT_FOR_CONC_REQ;

  /**
   * Initializes a child transaction context using the given information.
   *
   * If p_transaction_id and p_transaction_type are provided, the procedure
   * attempts to fetch additional transaction context.
   *
   * Otherwise, Procedure INIT_CHILD_CONTEXT will look for transaction context
   * values from the context array as follows:
   *
   * E.g. for child context user id:
   * l_user_id := p_child_context_array(CCI_USER_ID).a_val;
   */
  PROCEDURE INIT_CHILD_CONTEXT (
	p_parent_context_id IN NUMBER,
	p_transaction_id IN NUMBER DEFAULT NULL,
	p_transaction_type IN VARCHAR2 DEFAULT NULL
	--p_child_context_array IN CONTEXT_ARRAY
	) is
    l_child_context_exists boolean := TRUE;
    l_context_array CONTEXT_ARRAY;
    l_child_context_fetched_all boolean := FALSE;
  BEGIN
    --
    -- Initialize child transaction context if necessary
    --
    if (p_transaction_id is not null and p_transaction_type is not null) then
      begin
        --
        -- Check if child context already exists
        --
        select transaction_context_id into G_PRX_CHILD_TRANS_CONTEXT_ID
	  from fnd_log_transaction_context
	  where transaction_id = p_transaction_id
	  and transaction_type = p_transaction_type
	  and parent_context_id = p_parent_context_id;
      exception
	when no_data_found then
	  l_child_context_exists := FALSE;
      end;

      if (l_child_context_exists = FALSE) then
	--
	-- Today we only have a usecase for REQUEST but we can
        -- plug-in for other transaction types in the future
        -- as we understand more use cases
	--
	if (p_transaction_type = 'REQUEST') then
	  fetch_context_for_conc_req(
		p_request_id => p_transaction_id,
		p_info_type => 'ALL',
		p_context_array => l_context_array);
	  l_child_context_fetched_all := TRUE;
	end if;

	--
	-- Here, call init_transaction_internal to create a new
	-- row for child context in fnd_log_transaction_context
	--
	init_transaction_internal(
	  p_transaction_type => p_transaction_type,
	  p_transaction_id => p_transaction_id,
	  p_component_type => l_context_array(CCI_COMPONENT_TYPE).a_val,
	  p_component_appl_id => to_number(l_context_array(CCI_COMPONENT_APPL_ID).a_val),
	  p_component_id => to_number(l_context_array(CCI_COMPONENT_ID).a_val),
	  p_session_id => to_number(l_context_array(CCI_SESSION_ID).a_val),
	  p_user_id => to_number(l_context_array(CCI_USER_ID).a_val),
	  p_resp_appl_id => to_number(l_context_array(CCI_RESP_APPL_ID).a_val),
	  p_responsibility_id => to_number(l_context_array(CCI_RESPONSIBILITY_ID).a_val),
	  p_security_group_id => to_number(l_context_array(CCI_SECURITY_GROUP_ID).a_val),
	  p_parent_context_id => p_parent_context_id);
      end if;
/*
    elsif (p_child_context_array is not null) then
	--
	-- Transaction Id and type were not provided, so we simply
	-- initialize a new transaction context based on the
	-- information provided.
	--
	init_transaction_internal(
	  p_transaction_type => 'UNKNOWN',
	  p_transaction_id => -1,
	  p_component_type => p_child_context_array(CCI_COMPONENT_TYPE),
	  p_component_appl_id => to_number(p_child_context_array(CCI_COMPONENT_APPL_ID).a_val),
	  p_component_id => to_number(p_child_context_array(CCI_COMPONENT_ID).a_val),
	  p_session_id => to_number(p_child_context_array(CCI_SESSION_ID).a_val),
	  p_user_id => to_number(p_child_context_array(CCI_USER_ID).a_val),
	  p_resp_appl_id => to_number(p_child_context_array(CCI_RESP_APPL_ID).a_val),
	  p_responsibility_id => to_number(p_child_context_array(CCI_RESPONSIBILITY_ID).a_val),
	  p_security_group_id => to_number(p_child_context_array(CCI_SECURITY_GROUP_ID).a_val),
	  p_parent_context_id => p_parent_context_id);
*/
    end if;

    --
    -- Now fetch additional context context such as
    -- session_action, session_module, etc if we already havent done so
    --
    if (p_transaction_type = 'REQUEST' and
	l_child_context_fetched_all = FALSE) then
	fetch_context_for_conc_req(
		p_request_id => p_transaction_id,
		p_info_type => 'ADDITIONAL',
		p_context_array => l_context_array);
    end if;

    --
    -- Set the globals for the additional context information
    -- if available.
    --
    if (p_transaction_type is not null and p_transaction_id is not null) then
      G_PRX_SESSION_ID := to_number(l_context_array(CCI_SESSION_ID).a_val);
      G_PRX_USER_ID := to_number(l_context_array(CCI_USER_ID).a_val);
      G_PRX_SESSION_MODULE := l_context_array(CCI_SESSION_MODULE).a_val;
      G_PRX_SESSION_ACTION := l_context_array(CCI_SESSION_ACTION).a_val;
      G_PRX_MODULE := l_context_array(CCI_MODULE).a_val;
      G_PRX_NODE := l_context_array(CCI_NODE).a_val;
      G_PRX_NODE_IP_ADDRESS := l_context_array(CCI_NODE_IP_ADDRESS).a_val;
      G_PRX_PROCESS_ID := l_context_array(CCI_PROCESS_ID).a_val;
      G_PRX_JVM_ID := l_context_array(CCI_JVM_ID).a_val;
      G_PRX_THREAD_ID := l_context_array(CCI_THREAD_ID).a_val;
      G_PRX_AUDSID := to_number(l_context_array(CCI_AUDSID).a_val);
      G_PRX_DB_INSTANCE := to_number(l_context_array(CCI_DB_INSTANCE).a_val);
/*
    elsif (p_child_context_array is not null) then
      G_PRX_SESSION_ID := to_number(p_child_context_array(CCI_SESSION_ID).a_val);
      G_PRX_USER_ID := to_number(p_child_context_array(CCI_USER_ID).a_val);
      G_PRX_SESSION_MODULE := p_child_context_array(CCI_SESSION_MODULE).a_val;
      G_PRX_SESSION_ACTION := p_child_context_array(CCI_SESSION_ACTION).a_val;
      G_PRX_MODULE := p_child_context_array(CCI_MODULE).a_val;
      G_PRX_NODE := l_context_array(CCI_NODE).a_val;
      G_PRX_NODE_IP_ADDRESS := p_child_context_array(CCI_NODE_IP_ADDRESS).a_val;
      G_PRX_PROCESS_ID := p_child_context_array(CCI_PROCESS_ID).a_val;
      G_PRX_JVM_ID := p_child_context_array(CCI_JVM_ID).a_val;
      G_PRX_THREAD_ID := p_child_context_array(CCI_THREAD_ID).a_val;
      G_PRX_AUDSID := to_number(p_child_context_array(CCI_AUDSID).a_val);
      G_PRX_DB_INSTANCE := to_number(p_child_context_array(CCI_DB_INSTANCE).a_val);
*/
    end if;
  END INIT_CHILD_CONTEXT;


  /**
   * API for setting a child context (for proxy alerting) for the given
   * concurrent request ID.
   *
   * This API will first initialize the proxy context (i.e. the current
   * transaction context) if not already initialized. It will then
   * initialize the child transaction context for the given concurrent
   * request ID if it has not been initialized already.
   */
  PROCEDURE SET_CHILD_CONTEXT_FOR_CONC_REQ (
	p_request_id IN NUMBER ) is
    l_context CONTEXT_ARRAY;
  BEGIN
    -- Initialize the parent (current) transaction context if not
    -- already initialized.
    if(NOT SELF_INITED_X) then
      SELF_INIT;
    end if;

    if(FND_LOG.G_TRANSACTION_CONTEXT_ID is null) then
      GET_CONTEXT(CONTEXT_OUT => l_context);
    end if;


    -- Now, initialize the child transaction context if not already
    -- initialized.
    if (G_PRX_CHILD_TRANS_CONTEXT_ID is null) then
      INIT_CHILD_CONTEXT(
	p_parent_context_id => fnd_log.g_transaction_context_id,
	p_transaction_id => p_request_id,
	p_transaction_type => 'REQUEST');
    end if;

    --DUMP_CC;
  END SET_CHILD_CONTEXT_FOR_CONC_REQ;

  /**
   * This API clears the G_CHILD_TRANSACTION_CONTEXT_ID variable
   * along with any other globals associated with the child
   * context for proxy alerting.
   */
  PROCEDURE CLEAR_CHILD_CONTEXT is

  BEGIN
    G_PRX_CHILD_TRANS_CONTEXT_ID := null;
    G_PRX_SESSION_MODULE := null;
    G_PRX_SESSION_ACTION := null;
    G_PRX_MODULE := null;
    G_PRX_NODE := null;
    G_PRX_NODE_IP_ADDRESS := null;
    G_PRX_PROCESS_ID := null;
    G_PRX_JVM_ID := null;
    G_PRX_THREAD_ID := null;
    G_PRX_AUDSID := null;
    G_PRX_DB_INSTANCE := null;
    G_PRX_SESSION_ID := null;
    G_PRX_USER_ID := null;

    --DUMP_CC;
  END CLEAR_CHILD_CONTEXT;

/*============================================================================
 * Proxy Alerting related Procedures - End
 *===========================================================================*/



/**
 * Log a message directly without checking if logging is enabled.
 * Requires a transaction_context_id of a transaction_context that
 * has already been created. This allows messages to be logged
 * to multiple contexts within the same session.
 *
 * This function should only be called by internal ATG procedures.
 *
 */
FUNCTION STRING_UNCHECKED_TO_CONTEXT(LOG_LEVEL       IN NUMBER,
				     MODULE          IN VARCHAR2,
				     MESSAGE_TEXT    IN VARCHAR2,
				     TRANSACTION_CONTEXT_ID IN NUMBER,
				     ENCODED         IN VARCHAR2 DEFAULT 'N',
				     SESSION_ID      IN NUMBER   DEFAULT NULL,
				     USER_ID         IN NUMBER   DEFAULT NULL,
				     NODE            IN VARCHAR2 DEFAULT NULL,
				     NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
				     PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
				     JVM_ID          IN VARCHAR2 DEFAULT NULL,
				     THREAD_ID       IN VARCHAR2 DEFAULT NULL,
				     AUDSID          IN NUMBER   DEFAULT NULL,
				     DB_INSTANCE     IN NUMBER   DEFAULT NULL,
				     CALL_STACK      IN VARCHAR2 DEFAULT NULL,
				     ERR_STACK       IN VARCHAR2 DEFAULT NULL) return NUMBER is

      l_log_sequence  number;
      saved_context   number;

    begin

      if transaction_context_id is null then
         return -1;
      end if;

      if(NOT SELF_INITED_X) then
         SELF_INIT;
      end if;

      saved_context := FND_LOG.G_TRANSACTION_CONTEXT_ID;
      FND_LOG.G_TRANSACTION_CONTEXT_ID := TRANSACTION_CONTEXT_ID;


      l_log_sequence := STR_UNCHKED_INT_WITH_CONTEXT(LOG_LEVEL       => LOG_LEVEL,
						     MODULE          => MODULE,
						     MESSAGE_TEXT    => MESSAGE_TEXT,
						     ENCODED         => ENCODED,
						     SESSION_ID      => SESSION_ID,
						     USER_ID         => USER_ID,
						     NODE            => NODE,
						     NODE_IP_ADDRESS => NODE_IP_ADDRESS,
						     PROCESS_ID      => PROCESS_ID,
						     JVM_ID          => JVM_ID,
						     THREAD_ID       => THREAD_ID,
						     AUDSID          => AUDSID,
						     DB_INSTANCE     => DB_INSTANCE,
						     CALL_STACK      => CALL_STACK,
						     ERR_STACK       => ERR_STACK);


      FND_LOG.G_TRANSACTION_CONTEXT_ID := saved_context;

      return l_log_sequence;

      end;



end FND_LOG_REPOSITORY;

/
