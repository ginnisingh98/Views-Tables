--------------------------------------------------------
--  DDL for Package Body GL_CI_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CI_WORKFLOW_PKG" AS
/* $Header: gluciwfb.pls 120.5 2005/05/05 01:37:19 kvora noship $ */
NOTIFICATION_PROCESS_STARTED  Number :=  0;
NOTFICATION_NOT_REQUIRED      Number :=  1;
FATAL_EXCEPTION               Number := -1;
TRANSACTION_NOT_EXIST         Number := -2;
INVALID_ACTION                Number := -3;
CONTACT_INFO_NOT_FOUND        Number := -4;
EMAIL_CONTACT_NOT_SET         Number := -5;
GLOBAL_ERROR                  exception;
applSysSchema                 varchar2(30);
--+ ****************************************************************************
--+ Private procedure: Display diagnostic message
--+ ****************************************************************************
PROCEDURE diagn_msg( message_string   IN  VARCHAR2) IS
BEGIN
  IF diagn_msg_flag THEN
    null;
--+    dbms_output.put_line (message_string);
  ELSE
    null;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END diagn_msg;
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --+ to fix bug#2630145, do not hardcoded the apps schema name
  --+ it could be anything at customer's site
  --+ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  PROCEDURE Get_Schema_Name (l_dblink  IN varchar2)
  is
    dummy1        varchar2(30);
    dummy2        varchar2(30);
    result        varchar2(150);
    v_SQL         varchar2(1000);
    l_flag        varchar2(1);
    l_oracle_id   number;
BEGIN
    l_oracle_id := 900;
    l_flag := 'U';
/***    select oracle_username
    into applSysSchema
    from fnd_oracle_userid
    where read_only_flag = 'U'
    and oracle_id = 900;
****/
    v_SQL := 'select oracle_username from fnd_oracle_userid@' || l_dblink ||
              ' where read_only_flag = :flag' ||
              ' and oracle_id = :or_id';
    EXECUTE IMMEDIATE v_SQL INTO applSysSchema USING l_flag, l_oracle_id;
/**
    IF (NOT fnd_installation.get_app_info('SQLGL',
              dummy1,dummy2,applSysSchema)) THEN
      RAISE GLOBAL_ERROR;
    END IF;
***/
    IF (applSysSchema IS NULL) THEN
      RAISE GLOBAL_ERROR;
    END IF;
  exception
  when GLOBAL_ERROR then
    rollback;
    result := SUBSTR(SQLERRM, 1, 200);
    FND_MESSAGE.set_name('SQLGL', 'gl_us_ci_others_fail');
    FND_MESSAGE.set_token('RESULT', result);
    app_exception.raise_exception;
--    return result;
END Get_Schema_Name;
PROCEDURE SEND_CIT_WF_NTF (
   p_cons_request_id           IN  number,  --+consolidation request id
   p_Action                    IN  VARCHAR2,
   p_dblink                    IN  varchar2,
   p_batch_name                IN  varchar2,  --+100 CHARS
   p_source_database_name      IN  varchar2,
   p_target_ledger_name  IN  varchar2,
   p_interface_table_name      IN  varchar2,
   p_interface_run_id          IN  number,
   p_posting_run_id            IN  number,
   p_request_id                IN  number,
   p_group_id                  IN  number,
   p_send_to                   IN  varchar2,
   p_sender_name               IN  varchar2,
   p_message_name              IN  varchar2,
   p_send_from                 IN  varchar2,
   p_source_ledger_id             IN  number,
   p_import_message_body       IN  varchar2,
   p_post_request_id           IN  varchar2,
   p_Return_Code               OUT NOCOPY NUMBER
) IS
   l_item_key                   Number;
   l_item_type                  VARCHAR2(10) := 'GLCITNTF';
   l_source_database_name       VARCHAR2(30);
   l_period_name                VARCHAR2(15);  --++15 CHARS
   l_interface_table_name       VARCHAR2(30);
   l_interface_run_id           number;
   l_posting_run_id             number;
   l_group_id                   number;
   l_send_to                    VARCHAR2(30);
   l_sender_name                VARCHAR2(30);
   l_message_name               varchar2(30);
   l_send_from                  VARCHAR2(30);
   v_SQL                        varchar2(500);
   v_user_name                  fnd_user.user_name%type;
   l_consolidation_id           number;
   l_consolidation_set_id       number;
   l_from_period_name           varchar2(15);
   l_to_period_name             varchar2(15);
   l_application_name           VARCHAR2(30);
   l_responsibility_name        VARCHAR2(100);
   l_user_name                  VARCHAR2(30);
   l_target_database_name       VARCHAR2(30);
   Cursor cons_data IS
    Select
       consolidation_id,
       consolidation_set_id,
       from_period_name,
       to_period_name,
       target_resp_name,
       target_user_name,
       target_database_name
    From GL_CONSOLIDATION_HISTORY
    Where REQUEST_ID = p_cons_request_Id;
   l_source_ledger_id              number;
   l_source_ledger_name   VARCHAR2(30);
   l_mapping_rule_name          VARCHAR2(33);
   l_journal_source_name        VARCHAR2(25);  --+25 chars
        user_name      varchar2(100):=null;
        user_display_name   varchar2(100):=null;
        language                varchar2(100):=userenv('LANG');
        territory               varchar2(100):='America';
        description     varchar2(100):=NULL;
        notification_preference varchar2(100):='MAILTEXT';
        email_address   varchar2(100):=NULL;
        fax                     varchar2(100):=NULL;
        status          varchar2(100):='ACTIVE';
        expiration_date varchar2(100):=NULL;
        role_name               varchar2(100):=NULL;
        role_display_name       varchar2(100):=NULL;
        role_description        varchar2(100):=NULL;
        wf_id           Number;
        due_date date:=NULL;
        callback varchar2(100):=NULL;
    context varchar2(100):=NULL;
    send_comment varchar2(100):=NULL;
    priority  number:=NULL;
   duplicate_user_or_role       exception;
   PRAGMA       EXCEPTION_INIT (duplicate_user_or_role, -20002);
   l_domainName    VARCHAR2(150);
   dblink          VARCHAR2(30);
   l_user_je_source_name  varchar2(25);
   l_adb_je_source        varchar2(25):= 'Average Consolidation';
   l_je_source            varchar2(25):= 'Consolidation';
Begin
   diagn_msg('Starting SEND_CIT_WF_NTF');
   p_return_code := NOTIFICATION_PROCESS_STARTED;
/*GET ALL INPUT INFORMATION FROM SOME TABLES*/
   l_application_name := 'Oracle General Ledger';
   Open cons_data;
   Fetch cons_data into
       l_consolidation_id,
       l_consolidation_set_id,
       l_from_period_name,
       l_to_period_name,
       l_responsibility_name,
       l_user_name,
       l_target_database_name;
   Close cons_data;
   l_user_name := fnd_global.USER_NAME; --bug#2543150, remove username from login
   IF (l_consolidation_id IS NULL) AND (l_consolidation_set_id is NULL) THEN
      p_return_code := TRANSACTION_NOT_EXIST;
      return;
   END IF;
   IF l_consolidation_id IS NOT NULL THEN
      v_SQL := 'select name from gl_consolidation' ||
            ' where consolidation_id = :id';
      EXECUTE IMMEDIATE v_SQL INTO l_mapping_rule_name USING l_consolidation_id;
   END IF;
   IF l_consolidation_set_id IS NOT NULL THEN
      v_SQL := 'select name from gl_consolidation_sets' ||
            ' where consolidation_set_id = :id';
      EXECUTE IMMEDIATE v_SQL INTO l_mapping_rule_name USING l_consolidation_set_id;
   END IF;
   l_period_name := l_to_period_name;
   v_SQL := 'select name from gl_ledgers' ||
            ' where ledger_id = :id';
   EXECUTE IMMEDIATE v_SQL INTO l_source_ledger_name USING p_source_ledger_id;
   --+bug#2712006, cannot use hardcoded domain name
   v_SQL := 'select domain_name ' ||
              'from rg_database_links ' ||
              'where name = :pd';
   EXECUTE IMMEDIATE v_SQL INTO l_domainName USING p_dblink;
   dblink := p_dblink || '.' || l_domainName;
   Get_Schema_Name(dblink);  --+bug#2630145, no hardcoded apps schema name
   v_SQL := 'select user_je_source_name from gl_je_sources ' ||
               'WHERE je_source_name = :s_name';
   EXECUTE IMMEDIATE v_SQL INTO l_user_je_source_name USING l_je_source;
--+   l_journal_source_name := 'Consolidation';
   FND_PROFILE.GET('GL_GLCCIT_EMAIL_CONTACT', v_user_name);
   IF v_user_name IS NOT NULL THEN
      v_SQL := 'BEGIN '||' :a := ' || applSysSchema ||'.GL_CI_REMOTE_INVOKE_PKG.Get_email_address@' || dblink ||
               '(:user_name)' ||';'||' END;';
      EXECUTE IMMEDIATE v_SQL USING OUT l_send_to, IN v_user_name;
   --+bug2750898, add more user friendly error message
   IF (l_send_to = 'GETFAILURE') THEN
      p_return_code := EMAIL_CONTACT_NOT_SET;
      v_user_name := NULL;
      l_send_to := NULL;
--      return;
   END IF;
/***
      v_SQL := 'select email_address from fnd_user@' || p_dblink || '.world' ||
            ' where user_name = :name';
      EXECUTE IMMEDIATE v_SQL INTO l_send_to USING v_user_name;
      COMMIT;
***/
   ELSE
      --+consolidation email contact is not set at all
      p_return_code := CONTACT_INFO_NOT_FOUND;
      l_send_to := NULL;
--      return;
   END IF;
   --++get source database name
   v_SQL := 'select name from v$database';
   EXECUTE IMMEDIATE v_SQL INTO l_source_database_name;
   --commit;
        /*Create a role for ad hoc user if none exist*/
--   v_user_name := v_user_name || 'CONS';
   role_name:= v_user_name;
   role_display_name:=role_name || 'Dis';
   email_address:=l_send_to;
   begin
      WF_Directory.CreateAdHocRole (role_name, role_display_name,
      language, territory,  role_description, notification_preference,
      user_name, email_address, fax, status, expiration_date);
      exception
         when duplicate_user_or_role then
            WF_Directory.SetAdHocRoleAttr (role_name, role_display_name,
            notification_preference, language, territory, email_address, fax);
           /*dbms_output.put_line ('Messagge' || role_name || ' is already in */
        /*the database Change Attributes'); */
   end;
   commit;
        /*Create a role for ad hoc user if none exist*/
        /*bug 2543150, so that the From: field can be populated with the
          source database name*/
--   v_user_name := l_source_database_name;
   role_name:= l_source_database_name;
   role_display_name:=role_name;
   email_address:=l_send_to;
   begin
        WF_Directory.CreateAdHocRole (role_name, role_display_name,
        language, territory,  role_description, notification_preference,
        user_name, email_address, fax, status, expiration_date);
        exception
            when duplicate_user_or_role then
                WF_Directory.SetAdHocRoleAttr (role_name, role_display_name,
                notification_preference, language, territory, email_address, fax);
                /*dbms_output.put_line ('Messagge' || role_name || ' is already in */
        /*the database Change Attributes'); */
   end;
   commit;
   If p_action In ( 'DATA_TRANSFER_DONE') THEN
      l_message_name := 'DATA_TRANSFER_DONE';
      diagn_msg('Workflow notification for data transfer complete');
   ElsIf p_action In  ( 'JOURNAL_IMPORTED') THEN
      l_message_name := 'JOURNAL_IMPORTED';
      diagn_msg('Workflow notification for journal imported');
   ELSIf p_action In ( 'JOURNAL_POSTED') THEN
      l_message_name := 'JOURNAL_POSTED';
      diagn_msg('Workflow notification for journal posted');
   Else
      diagn_msg('Invalid Action '||p_action);
      p_return_code := INVALID_ACTION;
      return;
   End If;
   l_item_key := get_unique_id;
   wf_engine.CreateProcess(  itemtype => l_item_type
                             ,itemkey  => l_item_key
                             ,process  => 'GL_CIT_PROCESS' );
   commit;
   diagn_msg('Created workflow item key = '||to_char(l_item_key));
   set_wf_variables (
                    l_item_type,
                    l_item_key,
                    l_application_name,
                    l_responsibility_name,
                    l_user_name,
                    l_mapping_rule_name,
                    p_batch_name,  --+100 CHARS
                    l_source_database_name,
                    l_target_database_name,
                    l_source_ledger_name,
                    p_target_ledger_name,
                    l_period_name,  --+15 CHARS
                    l_user_je_source_name,  --+25 chars
                    p_interface_table_name,
                    p_interface_run_id,
                    p_posting_run_id,
                    p_request_id,
                    p_group_id,
                    v_user_name,
                   --++ email_address,
                    p_sender_name,
                    l_message_name,
                    p_send_from,
                    p_import_message_body,
                    p_post_request_id);
    commit;
--    p_return_code := NOTIFICATION_PROCESS_STARTED ;
    diagn_msg('Starting CIT Workflow Process');
    wf_engine.StartProcess( itemtype => l_item_type,
                            itemkey  => l_item_key );
    commit;
    diagn_msg('After Starting CIT Workflow Process');
    Return;
 EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('GL_CI_WORKFLOW_PKG',
                      'SEND_CIT_WF_NTF', l_item_type, l_item_key);
        p_return_code := FATAL_EXCEPTION;
       diagn_msg('Exception in CIT workflow process');
      Raise;
End SEND_CIT_WF_NTF;
Procedure set_wf_variables (
   l_item_type                  IN VARCHAR2,
   l_item_key                   IN NUMBER,
   l_application_name           IN VARCHAR2,
   l_responsibility_name        IN VARCHAR2,
   l_user_name                  IN VARCHAR2,
   l_mapping_rule_name          IN VARCHAR2,
   l_batch_name                 IN VARChar2,  --+100 CHARS
   l_source_database_name       IN VARCHAR2,
   l_target_database_name       IN VARCHAR2,
   l_source_ledger_name         IN VARCHAR2,
   l_target_ledger_name         IN VARCHAR2,
   l_period_name                IN VARCHAR2,  --+15 CHARS
   l_journal_source_name        IN VARCHAR2,  --+25 chars
   l_interface_table_name       IN VARCHAR2,
   l_interface_run_id           IN number,
   l_posting_run_id             IN number,
   l_request_id                 IN number,
   l_group_id                   IN number,
   l_send_to                    IN VARCHAR2,
   l_sender_name                IN VARCHAR2,
   l_message_name               IN varchar2,
   l_send_from                  IN VARCHAR2,
   l_import_message_body        IN VARCHAR2,
   l_post_request_id            IN varchar2
) IS
   l_user_id                    number;
   fnd_user_name                fnd_user.user_name%type;
   Cursor f_user_name IS
   SELECT user_name
   FROM fnd_user
   WHERE user_id = l_user_id;
   l_monitor_url                      VARCHAR2(500);
Begin
   --+ Set the process owner
   wf_engine.SetItemOwner( itemtype => l_item_type,
                           itemkey  => l_item_key,
                            owner   => l_user_name );
   wf_engine.SetItemUserKey( itemtype => l_item_type,
                            itemkey  => l_item_key,
                            userkey  => to_char(l_request_id)||'-'||to_char(l_item_key) );
   diagn_msg('Request ID = '||l_request_id);
   wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey   => l_item_key,
                              aname     => 'ITEM_KEY',
                              avalue    => l_item_key );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'APPLICATION_NAME',
                            avalue    => l_application_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'RESPONSIBILITY_NAME',
                            avalue    => l_responsibility_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'USER_NAME',
                            avalue    => l_user_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'SOURCE_DATABASE_NAME',
                            avalue    => l_source_database_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'TARGET_DATABASE_NAME',
                            avalue    => l_target_database_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'SOURCE_LEDGER_NAME',
                            avalue    => l_source_ledger_name );
   diagn_msg('Source ledger Name = '||l_source_ledger_name);
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'TARGET_LEDGER_NAME',
                            avalue    => l_target_ledger_name );
   diagn_msg('Target ledger Name = '||l_target_ledger_name);
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'JOURNAL_SOURCE_NAME',
                            avalue    => l_journal_source_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'PERIOD_NAME',
                            avalue    => l_period_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'MAPPING_RULE_NAME',
                            avalue    => l_mapping_rule_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'BATCH_NAME',
                            avalue    => l_batch_name );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'INTERFACE_TABLE_NAME',
                            avalue    => l_interface_table_name );
   wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey   => l_item_key,
                              aname     => 'REQUEST_ID',
                              avalue    => l_request_id );
   wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey   => l_item_key,
                              aname     => 'INTERFACE_RUN_ID',
                              avalue    => l_interface_run_id );
   wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey   => l_item_key,
                              aname     => 'POSTING_RUN_ID',
                              avalue    => l_posting_run_id );
   wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey   => l_item_key,
                              aname     => 'GROUP_ID',
                              avalue    => l_group_id );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'SEND_TO',
                            avalue    => l_send_to );
   diagn_msg('Send To = '||l_send_to);
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'SENDER_NAME',
                            avalue    => l_sender_name );
   diagn_msg('Sender Name = '||l_sender_name);
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'MESSAGE_NAME',
                            avalue    => l_message_name );
   diagn_msg('Message Name = '||l_message_name);
   wf_engine.SetItemAttrText(itemtype  => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'SEND_FROM',
                            avalue    => l_send_From );
   diagn_msg('Send From  = '||l_send_From);
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'IMPORT_MESSAGE_BODY',
                            avalue    => l_import_message_body );
   wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey   => l_item_key,
                            aname     => 'POST_REQUEST_ID',
                            avalue    => l_post_request_id );
  --+ Get the monitor URL
   begin
      l_monitor_url :=
              wf_monitor.GetUrl(wf_core.translate('WF_WEB_AGENT'),
                                l_item_type, l_item_key,'YES');
      Exception
         When others then
            l_monitor_url := 'Invalid URL';
   end;
   wf_engine.SetItemAttrText( itemtype        => l_item_type,
                              itemkey         => l_item_key,
                              aname           => 'MONITOR_URL',
                              avalue          => l_monitor_url);
End set_wf_variables;
FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_cit_notify_s.NEXTVAL
      FROM dual;
    new_id number;
 BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;
    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_CIT_NOTIFY_S');
      app_exception.raise_exception;
    END IF;
 EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_CI_WORKFLOW_PKG.GET_UNIQUE_ID');
      RAISE;
 END get_unique_id;
Procedure Get_Action_Type (
   p_item_type      IN VARCHAR2,
   p_item_key       IN VARCHAR2,
   p_actid          IN NUMBER,
   p_funcmode       IN VARCHAR2,
   p_result         OUT NOCOPY VARCHAR2
) IS
   l_message_name      VARCHAR2(100);
Begin
If p_funcmode = 'RUN' THEN
   diagn_msg('Starting Get_Action_Type');
   l_message_name := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'MESSAGE_NAME');
   diagn_msg('Message_Name = '||l_message_name);
   If l_message_name = 'DATA_TRANSFER_DONE' Then
      p_result := 'COMPLETE:DATA_TRANSFER_DONE';
   ElsIf l_message_name = 'JOURNAL_IMPORTED' Then
      p_result := 'COMPLETE:JOURNAL_IMPORTED';
   ElsIf l_message_name = 'JOURNAL_POSTED' Then
      p_result := 'COMPLETE:JOURNAL_POSTED';
   End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('GL_CI_WORKFLOW_PKG', 'Get_Action_Type', p_item_type, p_item_key);
     Raise;
End Get_Action_Type;
End gl_ci_workflow_pkg;

/
