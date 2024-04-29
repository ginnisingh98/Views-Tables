--------------------------------------------------------
--  DDL for Package Body FND_OAM_KBF_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_KBF_SUBS" AS
/* $Header: AFOAMSBB.pls 120.1.12010000.6 2017/03/22 20:03:38 tshort ship $ */


  --Common constants
  procedure fdebug(msg in varchar2);

---------------------------------------------------------------------------------
--Private Functions
---------------------------------------------------------------------------------
  FUNCTION HAS_NOTIFIED(
      pSubID      IN   FND_OAM_BIZEX_SUBSCRIP.SUBSCRIPTION_ID%TYPE
    , pUniqueExId IN   FND_LOG_EXCEPTIONS.UNIQUE_EXCEPTION_ID%TYPE
    )
     RETURN BOOLEAN
  IS
    l_retu BOOLEAN;
    l_count NUMBER;
  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.HAS_NOTIFIED');
    fdebug('pSubID:' || pSubID);
    fdebug('pUniqueExId:' || pUniqueExId);

    select count(*) into l_count
    from FND_OAM_BIZEX_SENT_NOTIF
    where
        UNIQUE_EXCEPTION_ID = pUniqueExId
    and SUBSCRIPTION_ID = pSubID
    ;

    IF l_count > 0 THEN
      fdebug('TRUE');
      l_retu := TRUE;
    ELSE
      fdebug('FALSE');
      l_retu := FALSE;
    END IF;

    fdebug('Out:FND_OAM_KBF_SUBS.SHALL_ADD_SUBS');
    RETURN (l_retu);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (FALSE);
  END HAS_NOTIFIED;
--------------------------------------------------------------------------------
  FUNCTION SHALL_ADD_SUBS
    (pItemSub IN VARCHAR2, pItemException IN VARCHAR2)
     RETURN BOOLEAN
  IS
    l_retu BOOLEAN;
  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.SHALL_ADD_SUBS');
  fdebug('pItemSub:' || pItemSub);
  fdebug('pItemException:' || pItemException);

    IF TRIM(pItemSub) IS NULL THEN
--      fdebug('In:Null');
      l_retu := TRUE;
    ELSIF TRIM(pItemSub) = 'ANY' THEN
      l_retu := TRUE;
    ELSIF TRIM(pItemSub) =  TRIM(pItemException) THEN
      l_retu := TRUE;
    ELSE
--      fdebug('In:Else');
      l_retu := FALSE;
    END IF;

    IF l_retu = FALSE THEN
     fdebug('Return=' || 'False');
    ELSE
     fdebug('Return=' || 'TRUE');
    END IF;
    fdebug('Out:FND_OAM_KBF_SUBS.SHALL_ADD_SUBS');
    RETURN (l_retu);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (FALSE);
  END SHALL_ADD_SUBS;
--------------------------------------------------------------------------------

/* 6874184
 * There are 4 severities that can be subscribed to in OAM:
 * CRITICAL
 * ERROR
 * WARNING
 * ANY
 *
 * These are stored in FND_OAM_BIZEX_SUBSCRIP and are passed in to the
 * function below as pItemSub.
 *
 *
 *
 * A message in the message dictionary will have a severity of:
 * CRITICAL
 * ERROR
 * WARNING
 *
 * pItemException comes from fnd_log_unique_exceptions which is ultimately
 * from the message dictionary.
 *
 *
 * Below logic should be:
 *
 * if setup to get a notification for ANY return true
 *
 * if setup to get a notification for WARNING return true (because that is the
 * lowest level in the message dictionary).
 *
 * if setup to get a notification for ERROR return true if the severity in
 * fnd_log_unique_exceptions is ERROR or CRITICAL.
 *
 * if setup to only get CRITICAL notifications only return true if
 * fnd_log_unique_exceptions has a CRITICAL severity.
 *
 * */



  FUNCTION SHALL_ADD_SUBS_SEVERITY
    (pItemSub IN VARCHAR2, pItemException IN VARCHAR2)
     RETURN BOOLEAN
  IS
    l_retu BOOLEAN;
  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.SHALL_ADD_SUBS_SEVERITY');
    fdebug('pItemSub:' || pItemSub);
    fdebug('pItemException:' || pItemException);

    IF TRIM(pItemSub) IS NULL THEN
      fdebug('In:Null');
      l_retu := TRUE;
    ELSIF TRIM(pItemSub) =  TRIM(pItemException) THEN
      l_retu := TRUE;
    ELSIF TRIM(pItemSub) =  'ANY' THEN
      l_retu := TRUE;
    ELSIF TRIM(pItemSub) =  'WARNING' THEN
      l_retu := TRUE;
    --6874184, modified logic below
    ELSIF TRIM(pItemSub) =  'ERROR' THEN
       fdebug('In:ERROR');
       IF TRIM(pItemException) = 'CRITICAL' THEN
          l_retu := TRUE;
       ELSE
          l_retu := FALSE;
       END IF;
    ELSE
--      fdebug('In:Else');
      l_retu := FALSE;
    END IF;


--For debug
    IF l_retu = FALSE THEN
     fdebug('Return=' || 'False');
    ELSE
     fdebug('Return=' || 'TRUE');
    END IF;

    fdebug('Out:FND_OAM_KBF_SUBS.SHALL_ADD_SUBS_SEVERITY');
    RETURN (l_retu);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (FALSE);
  END SHALL_ADD_SUBS_SEVERITY;


-------------------------------------------------------------------------------
  procedure retriveComponentInfo(app_id in number,
                            comp_type in varchar2,
				    comp_id in number,
                            comp_name out NOCOPY varchar2,
                            comp_display_name out NOCOPY varchar2)
 IS
  l_comp_name   FND_APP_COMPONENTS_VL.COMPONENT_NAME%TYPE;
  l_comp_display_name   FND_APP_COMPONENTS_VL.DISPLAY_NAME%TYPE;
  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.retriveComponentInfo');
    fdebug('app_id=' || app_id || ' comp_type=' || comp_type || ' comp_id=' || comp_id );

    IF (comp_type = 'CONCURRENT_PROGRAM') THEN
	SELECT
         b.CONCURRENT_PROGRAM_NAME, t.USER_CONCURRENT_PROGRAM_NAME
      INTO
         l_comp_name, l_comp_display_name
         --, b.APPLICATION_ID, b.CONCURRENT_PROGRAM_ID, t.DESCRIPTION
      FROM
         FND_CONCURRENT_PROGRAMS B,FND_CONCURRENT_PROGRAMS_TL t
      WHERE
             b.application_id = app_id
         and b.concurrent_program_id   = comp_id
         and b.application_id = t.application_id
         and b.concurrent_program_id = t.concurrent_program_id
         and t.language = userenv('LANG');

    ELSIF(comp_type = 'FORM') THEN
	SELECT
         b.FORM_NAME, t.USER_FORM_NAME
      INTO
         l_comp_name, l_comp_display_name
         --, b.APPLICATION_ID, b.FORM_ID, t.DESCRIPTION
      FROM
         FND_FORM B, FND_FORM_TL t
      WHERE
             b.application_id = app_id
         and b.form_id   = comp_id
         and b.application_id = t.application_id
         and b.form_id = t.form_id
         and t.language = userenv('LANG');

    ELSIF(comp_type = 'SERVICE_INSTANCE') THEN
	SELECT
         b.CONCURRENT_QUEUE_NAME, t.USER_CONCURRENT_QUEUE_NAME
      INTO
         l_comp_name, l_comp_display_name
         --, b.APPLICATION_ID, b.concurrent_queue_id , t.DESCRIPTION
      FROM
         FND_CONCURRENT_QUEUES b, FND_CONCURRENT_QUEUES_TL t
      WHERE
             b.application_id = app_id
         and b.concurrent_queue_id   = comp_id
	   and b.application_id = t.application_id
   	   and b.concurrent_queue_id = t.concurrent_queue_id
         and t.language = userenv('LANG');

    ELSIF(comp_type = 'FUNCTION') THEN

      --10254432
      begin
	SELECT
           b.function_name, t.user_function_name
        INTO
           l_comp_name, l_comp_display_name
           --, b.APPLICATION_ID, b.function_id, t.DESCRIPTION
        FROM
           FND_FORM_FUNCTIONS b, FND_FORM_FUNCTIONS_TL t
        WHERE
           b.function_id   = comp_id
   	   and b.function_id = t.function_id
           and t.language = userenv('LANG');
      exception when others then
        l_comp_name := 'UNKNOWN';
        l_comp_display_name := 'UNKNOWN';
      end;

    END IF;


    comp_name :=l_comp_name;
    comp_display_name :=l_comp_display_name;

    fdebug('Component Name=' || l_comp_name || ' Component Display Name=' ||  l_comp_display_name);

    fdebug('OUT:FND_OAM_KBF_SUBS.retriveComponentInfo');
  END retriveComponentInfo;

--------------------------------------------------------------------------------
 procedure setWFAttributes(itemtype in varchar2,
      itemkey in varchar2)
  IS
    l_app_sn    FND_APPLICATION_VL.APPLICATION_SHORT_NAME%TYPE;
    l_comp_sn   FND_APP_COMPONENTS_VL.COMPONENT_NAME%TYPE;
    l_comp_fn   FND_APP_COMPONENTS_VL.DISPLAY_NAME%TYPE;
    l_severity  FND_LOG_EXCEPTIONS.SEVERITY%TYPE;
    l_system VARCHAR2(200);
    l_app_id    FND_LOG_TRANSACTION_CONTEXT.COMPONENT_APPL_ID%TYPE;
    l_comp_id   FND_LOG_TRANSACTION_CONTEXT.COMPONENT_ID%TYPE;
    l_comp_type   FND_LOG_TRANSACTION_CONTEXT.COMPONENT_TYPE%TYPE;
  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.setWFAttributes');

      SELECT  fa.application_short_name
         , flue.severity, fltc.component_appl_id, fltc.component_type
         , fltc.component_id
      INTO
        l_app_sn, l_severity, l_app_id, l_comp_type, l_comp_id
      FROM 	fnd_log_transaction_context fltc,
     	  fnd_log_messages flm,
     	  fnd_log_exceptions fle,
     	  FND_LOG_UNIQUE_EXCEPTIONS flue,
     	  fnd_application fa
     WHERE
        flm.log_sequence = to_number(itemkey)
        and	flm.log_sequence = fle.log_sequence
        and fle.UNIQUE_EXCEPTION_ID = flue.UNIQUE_EXCEPTION_ID
 	  and fltc.transaction_context_id = flm.transaction_context_id
	  and fltc.component_appl_id = fa.application_id (+);

    retriveComponentInfo(l_app_id, l_comp_type, l_comp_id, l_comp_sn, l_comp_fn);
    select sys_context('userenv','db_name') into l_system from dual;

    fdebug('l_app_id=' || l_app_id);
    fdebug('l_app_sn=' || l_app_sn);
    fdebug('l_comp_type=' || l_comp_type);
    fdebug('l_comp_id=' || l_comp_id);
    fdebug('l_comp_sn=' || l_comp_sn);
    fdebug('l_comp_fn=' || l_comp_fn);
    fdebug('l_severity=' || l_severity);


    WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'SYSTEM', l_system);
    WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'APP_SHORT_NAME', l_app_sn);
    WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'COMP_SHORT_NAME', l_comp_sn);
    WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'SEVERITY', l_severity);

    fdebug('Out:FND_OAM_KBF_SUBS.setWFAttributes');
  END setWFAttributes;
--------------------------------------------------------------------------------
 PROCEDURE createSubList(itemtype in varchar2,
      itemkey in varchar2,
      actid in number,
      funcmode in varchar2,
      resultout out NOCOPY varchar2)
 IS
  l_unique_ex_id 		FND_LOG_EXCEPTIONS.UNIQUE_EXCEPTION_ID%TYPE;
  l_msg_id 		FND_LOG_EXCEPTIONS.LOG_SEQUENCE%TYPE;
  l_app_id 		FND_LOG_TRANSACTION_CONTEXT.COMPONENT_APPL_ID%TYPE;
  l_comp_type 	FND_LOG_TRANSACTION_CONTEXT.COMPONENT_TYPE%TYPE;
  l_comp_type_s 	FND_LOG_TRANSACTION_CONTEXT.COMPONENT_TYPE%TYPE;
  l_comp_id		FND_LOG_TRANSACTION_CONTEXT.COMPONENT_ID%TYPE;
--  l_biz_flow_id	FND_LOG_EXCEPTION_CONTEXT.LOG_SEQUENCE%TYPE;
  l_category	FND_LOG_EXCEPTIONS.CATEGORY%TYPE;
  l_severity	FND_LOG_EXCEPTIONS.SEVERITY%TYPE;

  l_sub_list  VARCHAR2(32000);
  l_role_name VARCHAR2(2000);
  l_display_name VARCHAR2(100);

  err_num NUMBER;
  err_msg VARCHAR2(100);
  l_BE_SUBJECT VARCHAR2(100);
  l_BE_MESSAGE1 VARCHAR2(100);
  l_BE_MESSAGE2 VARCHAR2(100);
  l_role_users  wf_directory.userTable;
  l_ii NUMBER;


  CURSOR subs_cur is
     SELECT subscription_id, role_id, component_type, severity, category, component_id
     FROM FND_OAM_BIZEX_SUBSCRIP
     WHERE
        (application_id = l_app_id)
      OR(application_id IS NULL)
      ;

  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.CreateSubList');
    fdebug('itemkey:' || itemkey);

    SELECT fltc.COMPONENT_APPL_ID, fltc.COMPONENT_TYPE
       ,flue.CATEGORY, flue.SEVERITY
       ,fltc.component_id, fle.UNIQUE_EXCEPTION_ID
    INTO
       l_app_id, l_comp_type
      ,l_category, l_severity
      ,l_comp_id, l_unique_ex_id
    FROM FND_LOG_MESSAGES flm
      ,FND_LOG_TRANSACTION_CONTEXT fltc
      ,FND_LOG_EXCEPTIONS fle
      ,FND_LOG_UNIQUE_EXCEPTIONS flue
    WHERE
        flm.LOG_SEQUENCE = TO_NUMBER(itemkey)
    AND fle.LOG_SEQUENCE = flm.LOG_SEQUENCE
    AND fltc.TRANSACTION_CONTEXT_ID = flm.TRANSACTION_CONTEXT_ID
    AND fle.UNIQUE_EXCEPTION_ID = flue.UNIQUE_EXCEPTION_ID;

    l_ii := 0;
    FOR subs_record in subs_cur LOOP
       l_comp_type_s := subs_record.component_type;

       --Check if Notification is already send.
       IF (HAS_NOTIFIED(subs_record.subscription_id, l_unique_ex_id) = TRUE) THEN
          GOTO next_record;
       END IF;

       IF (
            (l_comp_type_s = COMP_TYPE_UNKNOWN)
        AND (
                 (l_app_id IS NULL)
               OR(l_app_id = -1)
               OR(l_comp_type IS NULL)
               OR(l_comp_id IS NULL)
               OR(l_comp_id = -1)
            )
          ) THEN
         --UnKnown Type
         IF (SHALL_ADD_SUBS(subs_record.CATEGORY, l_category) = FALSE) THEN
            GOTO next_record;
         END IF;
         IF (SHALL_ADD_SUBS_SEVERITY(subs_record.severity, l_severity) = FALSE) THEN
            GOTO next_record;
         END IF;  --For Unknown
       ELSE----------------------------------Known Types
         IF (SHALL_ADD_SUBS(subs_record.component_type, l_comp_type) = FALSE) THEN
            GOTO next_record;
         END IF;
         IF (SHALL_ADD_SUBS(subs_record.CATEGORY, l_category) = FALSE) THEN
            GOTO next_record;
         END IF;
         IF (SHALL_ADD_SUBS_SEVERITY(subs_record.severity, l_severity) = FALSE) THEN
            GOTO next_record;
         END IF;
         IF (SHALL_ADD_SUBS(subs_record.component_id, l_comp_id) = FALSE) THEN
            GOTO next_record;
         END IF;

       END IF;  --Else (known Types)

       --Check If already Added to List
       IF (instr(l_sub_list, subs_record.role_id) > 0) THEN
          fdebug('Skip role already added=' || subs_record.role_id);
          GOTO next_record;
       END IF;


       --Add to List
       l_ii := l_ii + 1;
       l_role_users(l_ii) := subs_record.role_id;
       IF l_sub_list IS NULL THEN
          l_sub_list := subs_record.role_id;
       ELSE
          l_sub_list := l_sub_list || ','|| subs_record.role_id;
       END IF;
       insert into FND_OAM_BIZEX_SENT_NOTIF(UNIQUE_EXCEPTION_ID,  SUBSCRIPTION_ID, SENT) values
        (l_unique_ex_id, subs_record.SUBSCRIPTION_ID, sysdate);

       ---fdebug('l_sub_list=' || l_sub_list);

        <<next_record>>  --Go to next record
        fdebug('Skip role(no match)=' || subs_record.role_id);
        NULL;
    END LOOP;  --subs_cur

    fdebug('l_sub_list=' || l_sub_list);


--- This is for test
---    l_sub_list := 'RMOHAN2';

    IF l_sub_list IS NOT NULL  THEN
      fdebug('Valid List: Calling CreateAdHocRole');
      WF_DIRECTORY.CreateAdHocRole2(role_name=>l_role_name
        , role_display_name=>l_display_name, ROLE_USERS=>l_role_users);
      WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'ADHC_ROLE_NAME'
       , l_role_name);

      --Sets other attributes as app short name severity etc.
      setWFAttributes(itemtype, itemkey);

      l_BE_SUBJECT := 'plsql:FND_OAM_KBF_SUBS.createSubject/' || itemkey;
      fdebug('l_BE_SUBJECT=' || l_BE_SUBJECT);
      WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'BE_MAIL_SUBJECT'
         , l_BE_SUBJECT);

      l_BE_MESSAGE1 := 'plsql:FND_OAM_KBF_SUBS.createBusExcepDoc/' || itemkey;
      fdebug('l_BE_MESSAGE1=' || l_BE_MESSAGE1);
      WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'BE_MESSAGE1'
         , l_BE_MESSAGE1);

      l_BE_MESSAGE2 := 'plsql:FND_OAM_KBF_SUBS.createBusExcepDocPart1/' || itemkey;
      fdebug('l_BE_MESSAGE2=' || l_BE_MESSAGE2);
      WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'EMAIL_BODY_PART1'
         , l_BE_MESSAGE2);

    ELSE
       l_sub_list := 'NULL';
----This is for test due to wf bug
---      WF_ENGINE.SetItemAttrtext(itemtype, itemkey, 'ADHC_ROLE_NAME'
---       , l_sub_list);
    END IF;



    resultout := l_sub_list;

    fdebug('Out:FND_OAM_KBF_SUBS.CreateSubList');
---  EXCEPTION
---    WHEN OTHERS THEN
---       err_num := SQLCODE;
---       err_msg := SUBSTR(SQLERRM, 1, 1000);
---       fdebug('Error:FND_OAM_KBF_SUBS.CreateSubList.');
---       fdebug('Error Num: ' || err_num);
---       fdebug('Error Msg: ' || err_msg);

---       raise;

  END createSubList;
---------------------------------------------------------------------------------


 procedure createSubject(document_id in varchar2,
                        display_type in varchar2,
                        document in out NOCOPY varchar2,
                        document_type in out NOCOPY varchar2)
  IS
    l_app_sn    FND_APPLICATION_VL.APPLICATION_SHORT_NAME%TYPE;
    l_comp_sn   FND_APP_COMPONENTS_VL.COMPONENT_NAME%TYPE;
    l_severity  fnd_lookups.MEANING%TYPE;  --FND_LOG_EXCEPTIONS.SEVERITY%TYPE;
    l_system VARCHAR2(200);

    l_app_id    FND_LOG_TRANSACTION_CONTEXT.COMPONENT_APPL_ID%TYPE;
    l_comp_id   FND_LOG_TRANSACTION_CONTEXT.COMPONENT_ID%TYPE;
    l_comp_type FND_LOG_TRANSACTION_CONTEXT.COMPONENT_TYPE%TYPE;
    l_comp_fn   FND_APP_COMPONENTS_VL.DISPLAY_NAME%TYPE;
  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.createBusExcepDocSubject');

      SELECT
        fa.application_short_name, fl.meaning,
	  fltc.component_appl_id, fltc.component_type, fltc.component_id
      INTO
        l_app_sn, l_severity, l_app_id, l_comp_type, l_comp_id
      FROM 	fnd_log_transaction_context fltc,
     	  fnd_log_messages flm,
     	  fnd_log_exceptions fle,
     	  FND_LOG_UNIQUE_EXCEPTIONS flue,
     	  fnd_application_vl fa,
        fnd_lookups fl
     WHERE
        flm.log_sequence = document_id
            and flm.log_sequence = fle.log_sequence
            and fle.UNIQUE_EXCEPTION_ID = flue.UNIQUE_EXCEPTION_ID
		and fltc.transaction_context_id = flm.transaction_context_id
	      and fltc.component_appl_id = fa.application_id (+)
	      and flue.severity = fl.lookup_code (+)
	      and fl.lookup_type = 'FND_KBF_SEVERITY'
	      and	flm.log_sequence = document_id;

    retriveComponentInfo(l_app_id, l_comp_type, l_comp_id, l_comp_sn, l_comp_fn);
    select sys_context('userenv','db_name') into l_system from dual;

    FND_MESSAGE.CLEAR;
    FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_SUB');
    FND_MESSAGE.SET_TOKEN(token=>'SYSTEM', value=>l_system);
    FND_MESSAGE.SET_TOKEN(token=>'SEVERITY', value=>l_severity);
    FND_MESSAGE.SET_TOKEN(token=>'APP', value=>l_app_sn);
    FND_MESSAGE.SET_TOKEN(token=>'COMP', value=>l_comp_sn);
    document := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;

    fdebug('Subject:'|| document);
    fdebug('Out:FND_OAM_KBF_SUBS.createBusExcepDocSubject');
/*
  EXCEPTION
    WHEN OTHERS THEN
       fdebug('Error:FND_OAM_KBF_SUBS.createBusExcepDocSubject.');
       raise;
*/
  END createSubject;




 procedure createBusExcepDoc(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY varchar2,
                            document_type in out NOCOPY varchar2)
 IS
  l_msg_id 		FND_LOG_EXCEPTIONS.LOG_SEQUENCE%TYPE;
  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.createBusExcepDoc');

    l_msg_id := TO_NUMBER(document_id);
    document := FND_LOG.GET_TEXT(l_msg_id);
    --document := 'Rm test:document_id '|| document_id ;
    document_type := 'text/plain';
    fdebug('document' || document);

    fdebug('Out:FND_OAM_KBF_SUBS.createBusExcepDoc');
  END createBusExcepDoc;




 procedure createBusExcepDocPart1(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY varchar2,
                            document_type in out NOCOPY varchar2)
 IS
  l_msg_id 		FND_LOG_EXCEPTIONS.LOG_SEQUENCE%TYPE;
  l_subject 		VARCHAR2(200);

  l_app_sn    FND_APPLICATION_VL.APPLICATION_SHORT_NAME%TYPE;
  l_app_fn    FND_APPLICATION_VL.APPLICATION_NAME%TYPE;

  l_comp_sn   FND_APP_COMPONENTS_VL.COMPONENT_NAME%TYPE;

--  l_biz_flow_id	FND_LOG_EXCEPTION_CONTEXT.LOG_SEQUENCE%TYPE;
  l_comp_type_d 	fnd_lookups.MEANING%TYPE;

  l_app_id    FND_LOG_TRANSACTION_CONTEXT.COMPONENT_APPL_ID%TYPE;
  l_comp_id   FND_LOG_TRANSACTION_CONTEXT.COMPONENT_ID%TYPE;
  l_comp_type   FND_LOG_TRANSACTION_CONTEXT.COMPONENT_TYPE%TYPE;
  l_comp_fn   FND_APP_COMPONENTS_VL.DISPLAY_NAME%TYPE;

  BEGIN
    fdebug('In:FND_OAM_KBF_SUBS.createBusExcepDocPart1');
    ---Set up the Subject
    --10254432, added decode in the where clause.  The row in fnd_log_transaction_context is
    --created in fnd_log_repository.INIT_TRANS_INT_WITH_CONTEXT and from what I can see there is
    --no ICX_APP_MODULE there.  But the lookups are seeded this way.  It may be safest to just use
    --a decode here in case anyone else is using 'FUNCTION' instead of changing the way the record is logged.
      SELECT  fa.application_short_name, fa.application_name
         , flu.meaning, fltc.component_appl_id, fltc.component_type
         , fltc.component_id
      INTO
        l_app_sn, l_app_fn, l_comp_type_d, l_app_id, l_comp_type, l_comp_id
      FROM 	fnd_log_transaction_context fltc,
     	  fnd_log_messages flm,
     	  fnd_application_vl fa,
        fnd_lookups flu
     WHERE
                  flm.log_sequence = document_id
   	      and   fltc.transaction_context_id = flm.transaction_context_id
	      and 	fltc.component_appl_id = fa.application_id (+)
     and decode(fltc.component_type,'FUNCTION','ICX_APP_MODULE',fltc.component_type) = flu.lookup_code (+)
            and   flu.lookup_type = 'FND_COMPONENT_TYPE';

    document_type := 'text/plain';
    retriveComponentInfo(l_app_id, l_comp_type, l_comp_id, l_comp_sn, l_comp_fn);

    --Documnet other Part
    FND_MESSAGE.clear;
    FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_CTX');
    document := FND_MESSAGE.GET;
    ---fdebug('document' || document);

    FND_MESSAGE.clear;
    FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_ALERT_ID');
    FND_MESSAGE.SET_TOKEN(token=>'ID', value=>document_id);
    document := document || WF_CORE.NEWLINE || FND_MESSAGE.GET;
    ---fdebug('document' || document);

    FND_MESSAGE.clear;
    FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_APP');
    FND_MESSAGE.SET_TOKEN(token=>'APP_FULL_NAME', value=>l_app_fn);
    FND_MESSAGE.SET_TOKEN(token=>'APP_SN', value=>l_app_sn);
    document := document || WF_CORE.NEWLINE || FND_MESSAGE.GET;
    ---fdebug('document' || document);

    FND_MESSAGE.clear;
    FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_COMP_TYPE');
    FND_MESSAGE.SET_TOKEN(token=>'COMP_TYPE', value=>l_comp_type);
    document := document || WF_CORE.NEWLINE || FND_MESSAGE.GET;
    --fdebug('document' || document);

    --10254432
    if (l_comp_fn<>'UNKNOWN') then
      FND_MESSAGE.clear;
      FND_MESSAGE.SET_NAME(application=>'FND', name=>'AF_OAM_BE_COMP');
      FND_MESSAGE.SET_TOKEN(token=>'COMP_FULL_NAME', value=>l_comp_fn);
      FND_MESSAGE.SET_TOKEN(token=>'COMP_SN', value=>l_comp_sn);
      document := document || WF_CORE.NEWLINE || FND_MESSAGE.GET;
    --fdebug('document' || document);
    end if;

    fdebug('Out:FND_OAM_KBF_SUBS.createBusExcepDocPart1');
  END createBusExcepDocPart1;






--------------------------------------------------------------------------------
-------------DEBUG METHODS
--------------------------------------------------------------------------------
  procedure fdebug(msg in varchar2)
  IS
  l_msg 		VARCHAR2(1);
  BEGIN
       ---dbms_output.put_line(msg);
       l_msg := null;
  END fdebug;


  FUNCTION  raise_oamEvent
    (v_comm   IN   VARCHAR2)
    RETURN VARCHAR2
  IS
    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
  BEGIN
fdebug('In:FND_OAM_KBF_SUBS.raise_oamEvent');


  	wf_event.AddParameterToList(p_name=>'ORG_ID', p_value=>'Rm Org Id', p_parameterlist=>l_parameter_list);

 	wf_event.AddParameterToList(p_name=>'PM1',
	  	p_value=>'PM1Val',
		  p_parameterlist=>l_parameter_list);

fdebug('Before Raise');
  	wf_event.raise( p_event_name => 'oracle.apps.fnd.system.exception',
	  	p_event_key => v_comm,
		  p_parameters => l_parameter_list);
	    l_parameter_list.DELETE;
    commit;
fdebug('Out:FND_OAM_KBF_SUBS.raise_oamEvent');

    return v_comm || ' success ';
--  END;
	exception
		when others then
       fdebug('Error:Unable to raise event');
       fdebug('Error Num: ' || SQLCODE);
       fdebug('Error Msg: ' || SQLERRM);
		RAISE_APPLICATION_ERROR(-20202,'Unable to raise event');
  END raise_oamEvent;

--------------------------------------------------------------------------------







--End Functions
END FND_OAM_KBF_SUBS;

/
