--------------------------------------------------------
--  DDL for Package Body PQH_SS_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SS_WORKFLOW" as
/* $Header: pqwftswi.pkb 120.16.12010000.10 2010/05/25 08:11:07 gpurohit ship $*/


--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
/*
PRF_DT_RULE_FUTUR_CHANGE_FOUND VARCHAR2(30) := 'PQH_DT_RULE_FUTUR_CHANGE_FOUND';
PRF_ALLOW_TRANSACTION_REFRESH  VARCHAR2(30) := 'PQH_ALLOW_TRANSACTION_REFRESH';
PRF_ALLOW_CONCURRENT_TXN       VARCHAR2(30) := 'PQH_ALLOW_CONCURRENT_TXN';
PRF_ALLOW_INELIGIBLE_ACTIONS   VARCHAR2(30) := 'PQH_ENABLE_INELIGIBLE_ACTIONS';
*/

-- Global variables
g_date_format  constant varchar2(12)  DEFAULT 'RRRR-MM-DD';
g_package      constant varchar2(100) DEFAULT 'pqh_ss_workflow';
g_OA_HTML      constant varchar2(100) DEFAULT fnd_web_config.jsp_agent;
g_OA_MEDIA     constant varchar2(100) DEFAULT fnd_web_config.web_server||'OA_MEDIA/';
--
--
/* **************************************************************
    UPDATE_TXN_CURRENT_VALUES
    Private procedure to update current values to previous values in
    hr_api_transaction_values table
  *************************************************************** */
  PROCEDURE update_txn_current_values ( p_transactionId NUMBER) IS
  BEGIN
        IF ( p_transactionId IS NULL ) THEN
             RETURN;
        END IF;
        --
        UPDATE  hr_api_transaction_values
        SET     varchar2_value    = previous_varchar2_value,
                number_value      = previous_number_value,
                date_value        = previous_date_value
        WHERE   transaction_step_id    IN    (
                SELECT  transaction_step_id
                FROM    hr_api_transaction_steps
                WHERE   transaction_id    =  p_transactionId
                --AND     api_name         <> 'HR_SUPERVISOR_SS.PROCESS_API');
                AND    api_name  NOT in ('HR_SUPERVISOR_SS.PROCESS_API'
                                        ,'HR_PROCESS_SIT_SS.PROCESS_API'
                                        ,'HR_QUA_AWARDS_UTIL_SS.PROCESS_API'
                                        ,'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API'
                                        ,'HR_PROCESS_ADDRESS_SS.PROCESS_API'
                                        ,'HR_PROCESS_CONTACT_SS.PROCESS_API'
                                        ,'HR_PROCESS_PERSON_SS.PROCESS_API'
                                        ,'HR_COMP_PROFILE_SS.PROCESS_API')
                );


-- ns 08-May-2003: Bug 2927679: On Cancel the changes and the review activity ids were mismatching
-- causing the issue
--        AND     name NOT IN ('P_REVIEW_PROC_CALL','P_REVIEW_ACTID');
-- end 08-May-2003

        -- For supervisor step only:
        -- Copy the previously saved values from history to
        -- the current transaction
        PQH_SS_HISTORY.copy_value_from_history(p_transactionId);
  --
  EXCEPTION
      WHEN OTHERS THEN
           -- raise it so that calling procedure can track it
           raise;
  --
  END;
/* **************************************************************
    UPDATE_TXN_PREVIOUS_VALUES
    Private procedure to update previous values to current values in
    hr_api_transaction_values table
  *************************************************************** */
   --
  PROCEDURE update_txn_previous_values ( p_transactionId NUMBER) IS
  --
  BEGIN
      --
      IF ( p_transactionId IS NULL ) THEN
            RETURN;
      END IF;
      --
      UPDATE  hr_api_transaction_values
      SET     previous_varchar2_value   = varchar2_value,
              previous_date_value       = date_value,
              previous_number_value     = number_value
      WHERE   transaction_step_id IN (
              SELECT transaction_step_id
              FROM   hr_api_transaction_steps
              WHERE  transaction_id     = p_transactionId
              --AND     api_name         <> 'HR_SUPERVISOR_SS.PROCESS_API');
              AND    api_name  NOT in ('HR_SUPERVISOR_SS.PROCESS_API'
                                        ,'HR_PROCESS_SIT_SS.PROCESS_API'
                                        ,'HR_QUA_AWARDS_UTIL_SS.PROCESS_API'
                                        ,'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API'
                                        ,'HR_PROCESS_ADDRESS_SS.PROCESS_API'
                                        ,'HR_PROCESS_CONTACT_SS.PROCESS_API'
                                        ,'HR_PROCESS_PERSON_SS.PROCESS_API'
                                        ,'HR_COMP_PROFILE_SS.PROCESS_API')
             );


        -- For supervisor step only:
        -- Store the saved/submitted values to history tables
      PQH_SS_HISTORY.copy_value_to_history ( p_transactionId);
  --
  EXCEPTION
      WHEN OTHERS THEN
           -- raise it so that calling procedure can track it
           raise;
  --
  END;

/*  *****************************************
--  Private Procedure to
--  Update the transaction with original values from history
--  pick the 0th record and below from approval history
--  which maintains the original values that was saved (SFL) or submitted (APPROVE_EDIT & SUBMIT)
--  ******************************************/
PROCEDURE reset_original_values (
    p_itemType IN VARCHAR2
   ,p_itemKey  IN VARCHAR2
   ,p_txnId    IN NUMBER ) IS
--
      CURSOR cur_orig IS
      SELECT step_history_id, datatype, name, value
      FROM   pqh_ss_value_history
      WHERE (step_history_id,approval_history_id) IN (
             SELECT sh.step_history_id, ah.approval_history_id
             FROM   pqh_ss_step_history sh,
                    pqh_ss_approval_history ah
             WHERE  ah.transaction_history_id = sh.transaction_history_id
             AND    sh.api_name               = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API'
             AND    ah.transaction_history_id = p_txnId
             AND    ah.approval_history_id    = 0);
--
--
      l_step_history_id NUMBER(15);
      l_datatype        VARCHAR(20);
      l_name            VARCHAR(35);
      l_originalValue   VARCHAR2(2000);
      l_dateOption      VARCHAR2(10);
      l_effectiveDate   DATE;
      l_dt_update_mode  VARCHAR2(50);
--
BEGIN
--
        IF ( cur_orig%ISOPEN ) THEN
             CLOSE cur_orig;
        END IF;
        --
        OPEN  cur_orig;
        LOOP

           FETCH cur_orig INTO l_step_history_id, l_datatype, l_name, l_originalValue;
           EXIT  WHEN cur_orig%NOTFOUND;
           --
           IF ( l_datatype = 'NUMBER') THEN
             HR_TRANSACTION_API.set_number_value (
                p_transaction_step_id => l_step_history_id
               ,p_person_id           => null
               ,p_name                => l_name
               ,p_value               => hr_api.g_number
               ,p_original_value      => l_originalValue
                );
           ELSIF ( l_datatype = 'DATE') THEN
             HR_TRANSACTION_API.set_date_value (
                p_transaction_step_id => l_step_history_id
               ,p_person_id           => null
               ,p_name                => l_name
               ,p_value               => hr_api.g_date
               ,p_original_value      => fnd_date.canonical_to_date(l_originalValue)
                );
           ELSE
             HR_TRANSACTION_API.set_varchar2_value (
                p_transaction_step_id => l_step_history_id
               ,p_person_id           => null
               ,p_name                => l_name
               ,p_value               => hr_api.g_varchar2
               ,p_original_value      => l_originalValue
                );
           END IF;
        END LOOP;
        CLOSE cur_orig;

        IF ( l_step_history_id IS NOT NULL) THEN
           -- Fetch the effective date and date option from transaction Values
           -- table and set it to the appropriate columns in transaction (header) table
           l_dateOption  := HR_TRANSACTION_API.get_varchar2_value (
                               p_transaction_step_id => l_step_history_id
                              ,p_name                => 'P_EFFECTIVE_DATE_OPTION' );
           --
           IF (NVL(l_dateOption,'X') = 'E') THEN
                l_effectiveDate  := HR_TRANSACTION_API.get_date_value (
                                   p_transaction_step_id => l_step_history_id
                                  ,p_name                => 'P_EFFECTIVE_DATE' );
           --
           ELSE
                l_effectiveDate := sysdate;
           END IF;
           --
           HR_TRANSACTION_API.update_transaction (
                p_transaction_id               => p_txnId
               ,p_transaction_effective_date   => l_effectiveDate
               ,p_effective_date_option        => NVL(l_dateOption,'E')  );
           --
           wf_engine.setItemAttrText (
                itemtype => p_itemType
               ,itemkey  => p_itemKey
               ,aname    => 'P_EFFECTIVE_DATE'
               ,avalue   => TO_CHAR(l_effectiveDate,g_date_format) );
           --
           --
      END IF;
      --
--COMMIT;
--
  --
  EXCEPTION
      WHEN OTHERS THEN
           raise;
  --
END reset_original_values;

  PROCEDURE get_item_type_and_key (
              p_ntfId       IN NUMBER
             ,p_itemType   OUT NOCOPY VARCHAR2
             ,p_itemKey    OUT NOCOPY VARCHAR2 ) IS

  CURSOR cur_ias IS
    SELECT item_type, item_key
    FROM   wf_item_activity_statuses
    WHERE  notification_id   = p_ntfId;

  CURSOR cur_not IS
    SELECT SUBSTR(context,1,INSTR(context,':',1)-1)
          ,SUBSTR(context,INSTR(context,':')+1, ( INSTR(context,':',INSTR(context,':')+1 ) - INSTR(context,':')-1) )
    FROM   wf_notifications
    WHERE  notification_id   = p_ntfId;
  BEGIN
        IF ( cur_ias%ISOPEN ) THEN
             CLOSE cur_ias;
        END IF;
        --

        OPEN cur_ias;
        FETCH cur_ias  INTO p_itemType, p_itemKey;

        IF ( cur_ias%NOTFOUND ) THEN
             IF ( cur_not%ISOPEN ) THEN
                  CLOSE cur_not;
             END IF;
             --
             OPEN cur_not;
             FETCH cur_not INTO p_itemType, p_itemKey;
             CLOSE cur_not;
        END IF;

        CLOSE cur_ias;
  --
  EXCEPTION
      WHEN OTHERS THEN
           raise;
  --
  END;
/* **************************************************************
  -- Public function to Get Transaction Id from transaction table
  -- using Item Type and Item Key info
  --
  *************************************************************** */
  FUNCTION get_transaction_id (
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2 ) RETURN NUMBER IS
    CURSOR cur_txn IS
    SELECT  transaction_id
    FROM    hr_api_transactions
    WHERE   item_type     = p_itemType
    AND     item_key      = p_itemKey;
    l_transactionId  NUMBER;
  BEGIN
    IF ( cur_txn%ISOPEN ) THEN
         CLOSE cur_txn;
    END IF;
    --
    OPEN  cur_txn;
    FETCH cur_txn INTO l_transactionId;
    CLOSE cur_txn;
    RETURN  l_transactionId;
  --
  EXCEPTION
      WHEN OTHERS THEN
           raise;
  --
  END get_transaction_id;
--
FUNCTION get_notification_id (
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2
       ) RETURN NUMBER IS
--
l_ntfId     NUMBER;
--
  CURSOR cur_ntf IS
    SELECT ias.notification_id
    FROM   WF_ITEM_ACTIVITY_STATUSES IAS
    WHERE ias.item_type        = p_itemType
    and   ias.item_key         = p_itemKey
    and   IAS.ACTIVITY_STATUS  = 'NOTIFIED'
    and   notification_id is not null
    and   rownum < 2;
--
BEGIN
--
    IF ( cur_ntf%ISOPEN ) THEN
         CLOSE cur_ntf;
    END IF;
    --
    OPEN cur_ntf;
    FETCH cur_ntf INTO l_ntfId;
    CLOSE cur_ntf;
    RETURN l_ntfId;
  --
  EXCEPTION
      WHEN OTHERS THEN
           raise;
  --
END;
--

FUNCTION isHrRepNtf(
    p_itemType IN VARCHAR2,
    p_itemKey  IN VARCHAR2) RETURN Boolean IS

l_ntf_name VARCHAR2(100);
l_ntfId    NUMBER;

BEGIN
   l_ntfId    := get_notification_id(p_itemType,p_itemKey);
   l_ntf_name := WF_NOTIFICATION.getattrtext(l_ntfId,'HR_NTF_IDENTIFIER');

   IF (l_ntf_name = 'HR_EMBED_ON_APPR_NTFY_HR_REP') THEN
    RETURN true;
   END IF;

   RETURN false;

   EXCEPTION WHEN OTHERS THEN
      RETURN false;
END isHrRepNtf;

--
FUNCTION get_notified_activity (
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2
       ,p_ntfId         IN VARCHAR2
       ) RETURN NUMBER IS
--
l_activityId   NUMBER;
--
  CURSOR cur_wf IS
    SELECT process_activity
    FROM   WF_ITEM_ACTIVITY_STATUSES IAS
    WHERE ias.item_type        = p_itemType
    and   ias.item_key         = p_itemKey
    AND   ias.notification_id IS NULL
    and   IAS.ACTIVITY_STATUS  = 'NOTIFIED'
    and rownum < 2;
  --
  CURSOR cur_wf_ntfId(p_ntfId VARCHAR2) IS
    SELECT process_activity
    FROM   WF_ITEM_ACTIVITY_STATUSES IAS
    WHERE ias.item_type        = p_itemType
    and   ias.item_key         = p_itemKey
    and   ias.notification_id  = p_ntfId
    and   IAS.ACTIVITY_STATUS  = 'NOTIFIED'
    and   rownum < 2;
--
  BEGIN
    IF (p_ntfId is null) THEN
       IF ( cur_wf%ISOPEN ) THEN
         CLOSE cur_wf;
       END IF;
       --
       OPEN  cur_wf;
       FETCH cur_wf  INTO l_activityId;
       CLOSE cur_wf;
       --
    ELSE
       IF ( cur_wf_ntfId%ISOPEN ) THEN
         CLOSE cur_wf_ntfId;
       END IF;
       --
       OPEN  cur_wf_ntfId(p_ntfId);
       FETCH cur_wf_ntfId  INTO l_activityId;
       CLOSE cur_wf_ntfId;
       --
    END IF;
    --
    return l_activityId;
    --
  --
  EXCEPTION
      WHEN OTHERS THEN
           raise;
  --
  END get_notified_activity;
--
--
FUNCTION get_notified_activity (
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2
       ) RETURN NUMBER IS
--
l_activityId   NUMBER;
--
  CURSOR cur_wf IS
    -- Fix for bug 3719338
    /*SELECT ias.process_activity
    FROM   wf_item_activity_statuses ias
    WHERE  ias.item_type          = p_itemType
    and    ias.item_key           = p_itemKey
    and    ias.activity_status    = 'NOTIFIED'
    and    ias.process_activity   in (
           select  pa.instance_id
           FROM    wf_process_activities     PA,
                   wf_activity_attributes    AA,
                   wf_activities             WA,
                   wf_items                  WI
           WHERE   pa.process_item_type   = ias.item_type
           and     wa.item_type           = pa.process_item_type
           and     wa.name                = pa.activity_name
           and     wi.item_type           = ias.item_type
           and     wi.item_key            = ias.item_key
           and     wi.begin_date         >= wa.begin_date
           and     wi.begin_date         <  nvl(wa.end_date,wi.begin_date+1)
           and     aa.activity_item_type  = wa.item_type
           and     aa.activity_name       = wa.name
           and     aa.activity_version    = wa.version
           and     aa.type                = 'FORM'
           )
   order by Decode(ias.activity_result_code,'#NULL',1,2);
  */
    SELECT process_activity
       from
           (select process_activity
            FROM   WF_ITEM_ACTIVITY_STATUSES IAS
             WHERE  ias.item_type          = p_itemType
               and    ias.item_key           = p_itemKey
               and    ias.activity_status    = 'NOTIFIED'
               and    ias.process_activity   in (
                                                 select  wpa.instance_id
                                                 FROM    WF_PROCESS_ACTIVITIES     WPA,
                                                         WF_ACTIVITY_ATTRIBUTES    WAA,
                                                         WF_ACTIVITIES             WA,
                                                         WF_ITEMS                  WI
                                                 WHERE   wpa.process_item_type   = ias.item_type
                                                 and     wa.item_type           = wpa.process_item_type
                                                 and     wa.name                = wpa.activity_name
                                                 and     wi.item_type           = ias.item_type
                                                 and     wi.item_key            = ias.item_key
                                                 and     wi.begin_date         >= wa.begin_date
                                                 and     wi.begin_date         <  nvl(wa.end_date,wi.begin_date+1)
                                                 and     waa.activity_item_type  = wa.item_type
                                                 and     waa.activity_name       = wa.name
                                                 and     waa.activity_version    = wa.version
                                                 and     waa.type                = 'FORM'
                                               )
            order by begin_date desc)
      where rownum<=1;

--
  BEGIN
       IF ( cur_wf%ISOPEN ) THEN
         CLOSE cur_wf;
       END IF;
       --
       OPEN  cur_wf;
       FETCH cur_wf  INTO l_activityId;
       CLOSE cur_wf;
       return l_activityId;
  --
  EXCEPTION
      WHEN OTHERS THEN
           raise;
  --
  END get_notified_activity;

/* ******************************************************
  -- Complete Workflow Activity
  --
  ******************************************************* */
  PROCEDURE complete_wf_activity (
	p_itemType    IN VARCHAR2,
	p_itemKey     IN VARCHAR2,
        p_activity    IN NUMBER,
        p_otherAct    IN VARCHAR2,
	p_resultCode  IN VARCHAR2,
        p_commitFlag  IN VARCHAR2  DEFAULT 'N' ) IS
--
-- PRAGMA AUTONOMOUS_TRANSACTION;
l_activity  Number;

actdate date;               -- Active date
acttype varchar2(8);        -- Activity type
notid pls_integer;       -- Notification group id
user varchar2(320);      -- Notification assigned user


  CURSOR c_wf IS
    SELECT instance_label,ias.process_activity actvityId, ias.notification_id ntfId
    FROM  WF_ITEM_ACTIVITY_STATUSES IAS,
          WF_PROCESS_ACTIVITIES PA
    WHERE IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
    AND ias.item_type = pa.process_item_type
    and ias.item_type = p_itemType
    and ias.item_key = p_itemKey
    and ias.activity_status = 'NOTIFIED'
    and ias.process_activity <> p_activity
    and not exists (select 'e'
                    from WF_ACTIVITIES wa, WF_ACTIVITY_ATTRIBUTES waa, WF_ITEMS wi
                    where wa.item_type = pa.process_item_type
                    and wa.name = pa.activity_name
                    and wi.item_type = ias.item_type
                    and wi.item_key = ias.item_key
                    and wi.begin_date between wa.begin_date and nvl(wa.end_date,wi.begin_date)
                    and waa.activity_item_type  = wa.item_type
                    and waa.activity_name = wa.name
                    and waa.activity_version = wa.version
                    and waa.type = 'FORM');

/*
    and   ( (p_otherAct = 'OTHER' AND ias.process_activity <> p_activity) OR  -- Activity other than the passed one
            (p_otherAct = 'CURR'  AND ias.process_activity = l_activity ) OR  -- Fetch current first and complete that
            (p_otherAct = 'THIS'  AND ias.process_activity = p_activity ) ) ; -- Notification to be completed.
--
p_OtherAct  = yes'OTHER'   - Complete the activity other than the passed one
p_OtherAct  = no 'CURR'    - Activity not available, fetch current activity firs
t, and then complete that.
p_OtherAct  = NTF 'THIS'    - Complete the passed activity
*/
  l_activity_name	  VARCHAR2(100);
--
--
  BEGIN
--
    IF ( p_otherAct IN ('CURR','THIS'))  THEN
      IF ( p_otherAct = 'CURR') THEN
          l_activity   := get_notified_activity(p_itemType,p_itemKey);
           if(l_activity is null ) then
           return;
           end if;
      ELSIF ( p_otherAct = 'THIS') THEN
          l_activity   := p_activity;
      END IF;
      --
      l_activity_name  := wf_engine.getActivityLabel(l_activity);

       begin
	 actdate := Wf_Item.Active_Date(p_itemType, p_itemKey);
         acttype := Wf_Activity.Instance_Type(l_activity, actdate);

         if (acttype = wf_engine.eng_notification) then
             -- Get notification id
          Wf_Item_Activity_Status.Notification_Status(p_itemType, p_itemKey, l_activity,
                                                      notid, user);
        end if;
      exception
      when others then
        null;
      end;
      --
    ELSIF ( p_otherAct = 'OTHER') THEN
      --
       IF ( c_wf%ISOPEN ) THEN
         CLOSE c_wf;
       END IF;
       --
      OPEN c_wf;
      FETCH c_wf into l_activity_name,l_activity,notid;
      CLOSE c_wf;
    END IF;
--
--
     if l_activity_name is not null then
 	if (notid is not null) then
	        wf_notification.setattrtext(
       			notid
       		       ,'RESULT'
       		       ,p_resultCode);
        wf_notification.respond(
        			notid
      		       ,null
      		       ,fnd_global.user_name
      		       ,null);
      else
     	wf_engine.CompleteActivity(
                   p_itemType
                 , p_itemKey
                 , l_activity_name
                 , p_resultCode)  ;
      end if;
    end if;
-- Removing commit as Pragma Autonomous_Transaction is added;
--   if ( p_commitFlag = 'Y' ) then
       commit;
--   end if;
--
--
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.complete_wf_activity : ' || sqlerrm);
           Wf_Core.Context(g_package, 'complete_wf_activity', p_itemType, p_itemKey);
           raise;
  --
  END complete_wf_activity;
--
PROCEDURE start_approval_wf (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
--
l_initialSFL VARCHAR2(30);
l_NtfId     NUMBER;
l_result    VARCHAR2(30) := 'RESUBMIT'; -- Default result

CURSOR cur_sfl IS
SELECT nvl(decode(wav.text_value, null, hat.status,
            decode(hat.status,'S','SUBMIT',hat.status)),'N')
FROM   hr_api_transactions       hat,
        wf_item_attribute_values wav
WHERE  hat.item_type  = wav.item_Type
AND    hat.item_key   = wav.item_Key
AND    wav.item_type  = itemType
AND    wav.item_key   = itemKey
AND    wav.name       = 'SAVED_ACTIVITY_ID';


BEGIN
--
  IF (funcmode = wf_engine.eng_run) THEN

    -- fix for bug 4454439
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>itemtype
                                          ,p_item_key=>itemKey);
    exception
    when others then
      null;
    end;


       IF ( cur_sfl%ISOPEN ) THEN
         CLOSE cur_sfl;
       END IF;
       --
      OPEN  cur_sfl;
      FETCH cur_sfl into l_initialSFL;
      CLOSE cur_sfl;

   --If initial save for later then result is APPROVED, else it is RESUBMIT
   --This is used to ignore two history records for initial SFL & Submit
   IF  ( l_initialSFL =  'SUBMIT') THEN
      l_result := 'APPROVED';
   ELSIF (l_initialSFL = 'Y') THEN

         l_NtfId := get_notification_id(itemtype, itemKey);

         wf_notification.setattrtext(
                           l_NtfId
                          ,'WF_NOTE'
                          ,wf_engine.GetItemAttrText(
                                   itemtype
                                  ,itemkey
                                  ,'APPROVAL_COMMENT_COPY'));
         wf_engine.setitemattrtext(
                        itemtype
                       ,itemkey
                       ,'APPROVAL_COMMENT_COPY'
                       ,null);
   ELSE
         wf_notification.propagatehistory(
                               itemtype
                              ,itemkey
                              ,'APPROVAL_NOTIFICATION'
                              ,fnd_global.user_name
                              ,'WF_SYSTEM'
                              --,hr_workflow_ss.getNextApproverForHist(itemtype, itemkey)
                              ,'RESUBMIT'
                              ,null
                              ,wf_engine.GetItemAttrText(
                               	        itemtype
                               	       ,itemkey
                                       ,'APPROVAL_COMMENT_COPY'));
   END IF;

   --Set transaction status to pending
   --Bug 3018784: This call is moved from set_txn_submit_status
   set_transaction_status (
        p_itemType  => itemType
       ,p_itemKey   => itemKey
       ,p_action    => 'SUBMIT'
       ,p_result    => result );

   --Complete the Activity in approval flow with Approved (if new or SFL txn)
   --Or Resubmit if pending or RFC transactions.
   complete_wf_activity (
            p_itemType    => itemtype,
            p_itemKey     => itemkey,
            p_activity    => actid,
            p_otherAct    => 'OTHER',
            p_commitFlag  => 'Y',
            p_resultCode  => l_result ) ;
  END IF;
--
  result := 'COMPLETE:NEXT';
--
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.start_approval_wf : ' || sqlerrm);
           Wf_Core.Context(g_package, 'start_approval_wf', itemType, itemKey);
           raise;
  --
END start_approval_wf;
--
--
PROCEDURE get_transaction_info (
    p_itemType       IN VARCHAR2
   ,p_itemKey        IN VARCHAR2
   ,p_loginPerson    IN VARCHAR2
   ,p_whatchecks     IN VARCHAR2 DEFAULT 'EPIG'
   ,p_calledFrom     IN VARCHAR2 DEFAULT 'REQUEST'
   ,p_personId      OUT NOCOPY VARCHAR2
   ,p_assignmentId  OUT NOCOPY VARCHAR2
   ,p_state         OUT NOCOPY VARCHAR2
   ,p_status        OUT NOCOPY VARCHAR2
   ,p_txnId         OUT NOCOPY VARCHAR2
   ,p_businessGrpId OUT NOCOPY VARCHAR2
   ,p_editAllowed   OUT NOCOPY VARCHAR2
   ,p_futureChange  OUT NOCOPY VARCHAR2
   ,p_pendingTxn    OUT NOCOPY VARCHAR2
   ,p_interAction   OUT NOCOPY VARCHAR2
   ,p_effDateOption IN OUT NOCOPY VARCHAR2
   ,p_effectiveDate IN OUT NOCOPY VARCHAR2
   ,p_isPersonElig  OUT NOCOPY VARCHAR2
   ,p_rptgGrpId     OUT NOCOPY VARCHAR2
   ,p_planId        OUT NOCOPY VARCHAR2
   ,p_processName   OUT NOCOPY VARCHAR2
   ,p_dateParmExist OUT NOCOPY VARCHAR2
   ,p_rateParmExist OUT NOCOPY VARCHAR2
   ,p_slryParmExist OUT NOCOPY VARCHAR2
   ,p_rateMessage   OUT NOCOPY VARCHAR2
   ,p_terminateFlag OUT NOCOPY VARCHAR2 ) IS
--
l_effDate          DATE;
l_changeDate       DATE;
l_terminationDate  VARCHAR2(30);
l_effDateOption    VARCHAR2(10);
l_functionId       NUMBER(15);
l_parameter        fnd_form_functions.parameters%TYPE;
dummy              VARCHAR2(10);
l_flowName         VARCHAR2(100);
l_version          VARCHAR2(10);
l_asg_tx          VARCHAR2(1) := 'N';

-- Fetch transaction information
CURSOR cur_txn IS
   SELECT   transaction_id, status, transaction_state, NVL(transaction_effective_date,sysdate),
            assignment_id, effective_date_option, plan_id, rptg_grp_id,
            NVL(selected_person_id,-1), process_name,function_id
   FROM     hr_api_transactions
   WHERE    item_type   = p_itemType
   AND      item_key    = p_itemKey;
--
-- Bug 2969312: 21-May-2003: ns
-- check to see if assignment is terminated
-- if so flag is set
-- Check if the transaction is on an assignment
CURSOR cur_chk_asg (c_txnId NUMBER) IS
SELECT 'X'
FROM   hr_api_transaction_steps
WHERE  transaction_id  = c_txnId
AND    api_name  IN (
       'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API',
       'HR_SUPERVISOR_SS.PROCESS_API',
       'HR_TERMINATION_SS.PROCESS_API',
       'HR_PAY_RATE_SS.PROCESS_API',
       'PER_SSHR_CHANGE_PAY.PROCESS_API' );
--
-- Check if the assignment is terminated
CURSOR cur_term_asg (c_asgnId NUMBER, c_effective_date DATE) IS
SELECT 'X'
FROM   per_all_assignments_f
WHERE  assignment_id       = c_asgnId
AND    effective_end_date <= trunc(c_effective_date)
AND    assignment_status_type_id in (
       SELECT assignment_status_type_id
       FROM   per_assignment_status_types
       WHERE  per_system_status in ('TERM_ASSIGN', 'END'));
--
-- Check if assignment is terminated in future
CURSOR cur_fut_term_asg (c_asgnId NUMBER, c_effective_date DATE) IS
SELECT to_char(ser.actual_termination_date,g_date_format)
FROM   per_periods_of_service ser,
       per_all_assignments_f ass
where  ass.period_of_service_id = ser.period_of_service_id
AND    ass.assignment_id        = c_asgnId
AND    TRUNC(c_effective_date) between ass.effective_start_date AND ass.effective_end_date ;

-- For Employee transactions check if the person is terminated
CURSOR cur_term_emp (c_personId NUMBER, c_effective_date DATE) IS
SELECT 'X'
FROM   per_all_people_f
WHERE  nvl(current_employee_flag,'N') <> 'Y'
AND  nvl(current_applicant_flag,'N') <> 'Y'
AND    nvl(current_npw_flag,'N') <> 'Y'
AND    TRUNC(c_effective_date) BETWEEN effective_start_date AND effective_end_date
AND    person_id = c_personId;
--
CURSOR  cur_fn (c_functionId NUMBER) IS
SELECT  parameters
FROM    fnd_form_functions
WHERE   function_id         = c_functionId;
--
-- Bug 3003754: check to see if pay rate changes exist on the same date as the transaction effective date
CURSOR cur_pay ( c_assignmentId NUMBER, c_bgId NUMBER) IS
SELECT change_date
FROM   per_pay_proposals
WHERE  assignment_id     = c_assignmentId
AND    business_group_id = c_bgId
ORDER  BY change_date desc ;

l_rehire_flow varchar2(25) default null;

BEGIN
--
/*  p_WhatChecks can be
     E- Edit privilege
     F- Future dated check alone
     P- Pending Transaction Check
     I- Intervening Action and future dated checks
     G- Eligibility
*/
    IF ( p_whatChecks IS NULL ) THEN RETURN; END IF;
    IF ( cur_txn%ISOPEN ) THEN
       CLOSE cur_txn;
    END IF;
    --
    OPEN  cur_txn ;
    FETCH cur_txn INTO p_txnId, p_status, p_state, l_effDate , p_assignmentId, l_effDateOption,
	               p_planId, p_rptgGrpId, p_personId, p_processName, l_functionId;
    CLOSE cur_txn;

    -- If effective date is passed, validate information as of the
    -- passed effective date
    -- else validate against the transaction effective date.
    IF ( p_effectiveDate IS NOT NULL ) THEN
        l_effDate := TO_DATE(p_effectiveDate, g_date_format );
    ELSE
        p_effectiveDate := TO_CHAR(l_effDate, g_date_format);
    END IF;
    --
    IF (p_effDateOption IS NOT NULL ) THEN
        l_effDateOption := p_effDateOption;
    ELSE
        p_effDateOption := l_effDateOption;
    END IF;
    --
    --
    -- Bug 2969312: 21-May-2003: ns
    -- Check if the transaction is assignment related
    -- if so, check if assignment is terminated, else
    -- check if person is terminated.
    -- if either is terminated, set appropriate flag
    p_terminateFlag := 'NO'; -- reset flag before use.

    IF ( cur_fut_term_asg%ISOPEN ) THEN
       CLOSE cur_fut_term_asg;
    END IF;
    --
    OPEN  cur_chk_asg(p_txnId );
    FETCH cur_chk_asg INTO dummy;

    IF cur_chk_asg%FOUND THEN -- Assignment related transaction
        l_asg_tx := 'Y';
    END IF;
    CLOSE cur_chk_asg;

 -- do not perform termination check for non assignment
 -- related transaction.
 IF l_asg_tx = 'Y' THEN

    --
    OPEN  cur_fut_term_asg(p_assignmentId, TO_DATE(p_effectiveDate, g_date_format ));
    FETCH cur_fut_term_asg INTO l_terminationDate;
    CLOSE cur_fut_term_asg;

    IF ( l_terminationDate IS NOT NULL ) THEN
         --
         IF ( to_date(l_terminationDate,g_date_format) <= trunc(sysdate)) THEN
              p_terminateFlag := 'ASGN'; -- set flag
         ELSE
              p_terminateFlag := l_terminationDate;
         END IF;
         --
    ELSE
         --
         IF ( cur_term_emp%ISOPEN ) THEN
            CLOSE cur_term_emp;
         END IF;
         --
         OPEN  cur_term_emp(p_personId, TO_DATE(p_effectiveDate, g_date_format ));
         FETCH cur_term_emp INTO dummy;
         --
         if p_itemType is not null and p_itemKey is not null then
    		l_rehire_flow := wf_engine.GetItemAttrText(p_itemType,p_itemKey,'HR_FLOW_IDENTIFIER',true);
         end if;
     If nvl(l_rehire_flow,'N') <> 'EX_EMP'  AND nvl(l_rehire_flow,'N') <> 'REVERSE_TERMINATION' then
        IF cur_term_emp%FOUND THEN -- Person is found to be terminated
            --
            p_terminateFlag := 'PRSN'; -- set flag for person termination
            --
         ELSE
            --
             IF ( cur_term_asg%ISOPEN ) THEN
                CLOSE cur_term_asg;
             END IF;
             --
            OPEN  cur_term_asg (p_assignmentId, TO_DATE(p_effectiveDate, g_date_format ));
            FETCH cur_term_asg INTO dummy;
            --
            IF cur_term_asg%FOUND THEN -- Assignment is found to be terminated
               p_terminateFlag := 'ASGN'; -- set flag
            END IF;
            --
            CLOSE cur_term_asg;
            --
         END IF;
      End if;
         --
         CLOSE cur_term_emp;
         --
    END IF;
 END IF;
    --
    --
    -- Check if effective Date parameter exist for the function
    IF ( cur_fn%ISOPEN ) THEN
         CLOSE cur_fn;
    END IF;
    --
    OPEN  cur_fn (l_functionId);
    FETCH cur_fn INTO l_parameter;
    CLOSE cur_fn;

    IF ( INSTR(l_parameter,'pEffectiveDate') > 0 ) THEN
        p_dateParmExist := 'Y';
    END IF;

    IF ( INSTR(l_parameter,'pPayRate') > 0 ) THEN
        p_rateParmExist := 'Y';
    END IF;

    IF ( INSTR(l_parameter,'pSalChange') > 0 ) THEN
        p_slryParmExist := 'Y';
    END IF;

    -- if date option is as of approval, take current date for processing.
    IF (l_effDateOption = 'A' OR p_dateParmExist = 'N') THEN
       l_effDate := TRUNC( Sysdate);
    END IF;

    -- ========================================
    -- if termination flag is set, then return
    -- without any further checks.
    IF ( NVL(p_terminateFlag,'NO') <> 'NO') THEN
         return;
    END IF;
    -- ========================================

    p_businessGrpId := PQH_SS_UTILITY.get_business_group_id (
                            p_personId      => p_personId
                           ,p_effectiveDate => l_effDate );
    --
    -- check salary changes
    IF ( p_assignmentId IS NOT NULL AND p_businessGrpId IS NOT NULL
         AND p_rateParmExist = 'Y') THEN
       IF ( cur_pay%ISOPEN ) THEN
         CLOSE cur_pay;
       END IF;
       --
       OPEN  cur_pay (p_assignmentId, p_businessGrpId);
       FETCH cur_pay INTO l_changeDate;
       --
       IF  cur_pay%FOUND THEN
           IF l_changeDate   = l_effDate THEN
              p_rateMessage := 'PQH_SS_PAYRATE_SAMEDAY_ERR';
           ELSIF l_changeDate > l_effDate THEN
              p_rateMessage := 'PQH_SS_PAYRATE_FUTURE_ERR';
           END IF;
       END IF;
       --
       CLOSE cur_pay;
    END IF;

    IF ( p_processName IS NULL ) THEN
        p_processName   :=  wf_engine.GetItemAttrText(
                            itemtype    => p_itemType
                           ,itemkey     => p_itemKey
                           ,aname       => 'PROCESS_NAME');
    END IF;
    --
    BEGIN
       l_flowName := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
				 aname    => 'HR_FLOW_NAME_ATTR');
    EXCEPTION
       WHEN OTHERS THEN
            NULL; -- if attribute not found then continue w/out error
    END;

    p_editAllowed   := 'N';

    -- Bug 3025523: Check access to selected employee's record via secured view
    -- Secure access is not checked in case of New Hire as there
    -- will be no record in hr tables.
    IF ( NVL(l_flowName,'x') <> 'HrCommonInsertOab' AND
         NVL(l_flowName, 'x') <> 'CWKPlacement'  AND
         p_personid <> -1) THEN
    BEGIN
        select 'x'
        into   dummy
        from   per_people_f
        where  person_id  = p_personId
        and    l_effDate between effective_start_date and effective_end_date;
        --
        dummy := null;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           p_editAllowed := 'NS'; --No access to emp record
           -- ========================================================
           -- No need to perform all the validations, if manager does not have
           -- secure access to the selected person's record.
           -- ========================================================
           Return;
    END;
    END IF;

    IF ( INSTR(p_whatChecks,'E') > 0) THEN
      --
      IF ( INSTR(p_status,'S') >0 OR p_status = 'RI' ) THEN
           p_editAllowed := 'Y';
      ELSE
      --
        PQH_SS_UTILITY.check_edit_privilege (
          p_personId        => p_loginPerson
         ,p_businessGroupId => p_businessGrpId
         ,p_editAllowed     => p_editAllowed );
      --
     END IF;
   END IF;

   -- ========================================================
   -- After evaluating the edit privilege, there is no need
   -- to perform all the validations, if in new hire flow
   -- ========================================================
   IF ( NVL(l_flowName,'x') = 'HrCommonInsertOab' OR
        NVL(l_flowName, 'x') = 'CWKPlacement' ) THEN
      if p_effDateOption IS NULL then
         p_effDateOption := 'E';
      end if;

      RETURN;
   END IF;

   -- ========================================================
   -- Perform other validations only if the user has Edit privilege
   -- these checks are irrelevant if user cannot edit.
   -- Either Edit priv was not checked or checked and found eligible
   -- ========================================================
   IF ( INSTR(p_whatChecks,'E')=0 OR p_editAllowed = 'Y' ) THEN

    IF ( INSTR(p_whatChecks,'P') > 0)  THEN
     p_pendingTxn := PQH_SS_UTILITY.check_pending_Transaction (
                      p_txnId       => p_txnId
                     ,p_itemType    => p_itemType
                     ,p_personId    => p_personId
  		     ,p_assignId    => p_assignmentId   ) ;
    END IF;
     --
     p_futureChange := 'N';
     p_interAction  := 'N';
     --Perform date track validations only if the transaction has
     --date associated with it.
     IF ( p_dateParmExist <> 'N') THEN
       --
       l_version :=  PQH_SS_UTILITY.get_approval_process_version(
                       p_itemType => p_itemType,
                       p_itemKey  => p_itemKey );
       --
       -- ========================================================
       -- For V4 approval process, compare the OVN of assignment and the transaction
       -- If they do not match return appropriate flag
       -- ========================================================
       IF ( l_version IS NULL OR l_version <> 'V5') THEN
          Declare
           --
           CURSOR cur_asg_step IS
           SELECT transaction_step_id
           FROM   hr_api_transaction_steps
           WHERE  transaction_id          = p_txnId
           AND    api_name                = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API';
           --
           --
           CURSOR cur_match_ovn (c_txn_step_id NUMBER, c_effDate DATE) IS
           SELECT 'X'
           FROM   hr_api_transaction_values  tv,
                  per_assignments_f          af
           WHERE  af.assignment_id        = p_assignmentId
           AND    tv.transaction_step_id  = c_txn_step_id
           AND    tv.name                 = 'P_OBJECT_VERSION_NUMBER'
           AND    c_effDate BETWEEN af.effective_start_date AND af.effective_end_date
           AND    NVL(original_number_value,number_value) = af.object_version_number;
           --
           l_txn_step_id   NUMBER;
           --
         Begin
           --
           Open  cur_asg_step;
           Fetch cur_asg_step INTO l_txn_step_id;

           -- ==================================================
           -- Assignment step exists, check if the ovns match
           -- If assginment step does not exist then do nothing
           -- ==================================================
           IF cur_asg_step%FOUND THEN
              --
              Open  cur_match_ovn (l_txn_step_id, l_effDate);
              Fetch cur_match_ovn INTO Dummy;
              -- If matching ovns are not found -Intervening action -Set flag to throw error
              IF cur_match_ovn%NOTFOUND  THEN
                 p_interAction := 'YV4';
              END IF;
              Close cur_match_ovn;
              --
           END IF;
           --
           Close cur_asg_step;
           --
         End;
         --
       ELSE
         --
         IF ( INSTR(p_whatChecks,'I') > 0 OR  INSTR(p_whatChecks,'F') > 0)  THEN
           --
           p_futureChange := PQH_SS_UTILITY.check_future_Change (
                          p_txnId           => p_txnId
                         ,p_assignmentId    => p_assignmentId
                         ,p_effectiveDate   => l_effDate
                         ,p_calledFrom      => p_calledFrom );
           --
         END IF;  -- future/intervening

         IF ( INSTR(p_whatChecks,'I') > 0)  THEN
           --
           p_interAction := PQH_SS_UTILITY.check_intervening_Action (
                             p_txnId             => p_txnId
                            ,p_assignmentId      => p_assignmentId
                            ,p_effectiveDate     => l_effDate
                            ,p_futureChange      => p_futureChange ) ;
           --
         END IF;  -- intervening
         --
       END IF; -- End if Approval version
       --
     END IF; --dateParamExist
     --
     IF ( INSTR(p_whatChecks,'G') > 0 ) THEN
     --
      p_isPersonElig :=  PQH_SS_UTILITY.check_eligibility (
                       p_planId    => p_planId
                      ,p_personId  => p_personId
                      ,p_effectiveDate  => l_effDate ) ;
    --
    END IF;
   END IF;
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.get_transaction_info : ' || sqlerrm);
           raise;
  --
END get_transaction_info;
--


PROCEDURE revert_to_last_save (
    p_txnId         IN NUMBER
   ,p_itemType      IN VARCHAR2
   ,p_itemKey       IN VARCHAR2
   ,p_status        IN VARCHAR2
   ,p_state         IN VARCHAR2
   ,p_revertFlag    IN VARCHAR2      ) IS
--
l_applicationId NUMBER(15);
l_regionCode    VARCHAR2(30);
l_newState      VARCHAR2(5);
l_activityLabel VARCHAR2(240);
l_savedStatus   BOOLEAN   := INSTR(p_status,'S') > 0;
l_activityId    NUMBER(15);
l_currentActivityId    NUMBER(15);
l_savedActivityId    NUMBER(15);
--
BEGIN


--  Handle WF Transitions
--  if the txn is in sfl status AND if either unsaved changes found that user wanted to revert or  txn is in transient state
--  transition back to saved activity
    IF ( l_savedStatus AND ( (p_state='T') OR (p_state = 'W' AND p_revertFlag = 'Y') ) )THEN
                --
                l_savedActivityId  :=    wf_engine.GetItemAttrText(
                                          itemtype => p_itemType,
                                          itemkey  => p_itemKey,
                                          aname    => 'SAVED_ACTIVITY_ID');
                --
                --
                l_currentActivityId := get_notified_activity(
                                            p_itemType  => p_itemType
                                           ,p_itemKey   => p_itemKey);

                IF (l_savedActivityId <> l_currentActivityId ) THEN

                -- handle error to go back to the saved activity
                    l_activityLabel  :=  WF_ENGINE.GetActivityLabel(l_savedActivityId);
                    --
                    --possibility of the method closing the notification
                    -- instead of the form activity.
                    if(l_activityLabel is not null) then
                    WF_ENGINE.handleError(
                        itemType => p_itemType
                       ,itemKey  => p_itemKey
                       ,activity => l_activityLabel
                       ,command  => 'RETRY' ) ;
                    end if;

                -- Bug 2962973:ns complete the current activity
                -- so that only SFL activity is left notified
                   -- NO DML Operations directly on FND schema.
                   -- Fix for bug#3578646
                   /*
                    UPDATE wf_item_activity_statuses
                     SET   activity_status  = 'COMPLETE',
                           activity_result_code ='#NULL'
                     WHERE item_type        = p_itemType
                     AND   item_key         = p_itemKey
                     AND   process_activity = l_currentActivityId;
                   */

                END IF;
        -- if  unsave changes found and user does not want to revert
        -- if (savedStatus and (p_state IS NULL OR p_state='W' and revert=N)) OR
        --    ( otherThanSavedStatus AND p_state='W' and revert=N) ) THEN do nothing
   ELSIF ( l_savedStatus OR (p_state ='W' and p_revertFlag='N') or (p_status = 'W' and (p_state is null or p_state = 'T' or p_state = 'W')) ) THEN
        NULL;
   -- if txn not in sfl status OR if state is null
   ELSE --i.e  IF p_state is NULL (redo needed in this cause coz it could be the blocked activity)
        -- if  (p_state = 'W' AND p_revertFlag='Y' and status = NOT SAVED)
        -- Find the current activity
        -- if p_state is not null, Complete WF with RESULT=REDO to go to the first page of the transaction,
        -- Since this method is called when Edit is clicked from a notification,
        -- Notification is always one of the notified activity,
        -- Fetching activity other than that of Ntf will give the notified activity of the txn thread.
           l_activityId    := get_notified_activity(
                            p_itemType  => p_itemType
                           ,p_itemKey   => p_itemKey);
        --

           -- In case of a txn send to approval and try to update we get null from
           -- get_notified_activity(p_itemType,p_itemKey), as it is a HR Block Activity
           -- and we r searching for Page Activities with FORM as value.
           -- We are calling overloaded call to get the blocked activity.
           if(l_activityId is null ) then
		l_activityId := get_notified_activity(
                                        p_itemType => p_itemType,
                                        p_itemKey  => p_itemKey,
                                        p_ntfId => null);
           end if;


        -- Notified activity which must be completed to
        -- go the first page of the transaction and fetch it's activity id.
           if(l_activityId is not null) then
            complete_wf_activity (
                    p_itemType      => p_itemType,
                    p_itemKey       => p_itemKey,
                    p_activity      => l_activityId,
                    p_otherAct      => 'THIS',
                    p_resultCode    => 'REDO' );
           end if;
        --
        -- END IF;
  --
  END IF;

    -- **********************************************
    -- Update transaction state : START
    IF (p_state = 'W' ) THEN
       if (p_revertFlag = 'Y' ) then
            l_newState := 'T' ;  -- not null because on edit state is transient.
       else
            l_newState := p_state;
       end if;
    ELSE -- (if p_state is null or p_state = 'T')
      l_newState := 'T';
    END IF;
    --
    IF (p_state = 'W' AND p_revertFlag = 'Y' ) THEN
        --
       -- update_txn_current_values(p_txnId );
       -- cancel the user previous action and revert the data to
       -- previous good state
       hr_trans_history_api.cancel_action(p_txnId);
        --
    elsIF ( l_newState <> NVL(p_state,'**') ) THEN
      --
      -- update only if no revert is made
      hr_transaction_api.update_transaction(
               p_transaction_id    => p_txnId,
               p_status            => p_status,
               p_transaction_state => l_newState );
    END IF;


    -- Update transaction status : END
    -- **********************************************
--
--COMMIT;

  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.revert_to_last_save : ' || sqlerrm);
           raise;
  --
  END revert_to_last_save;


/* ******************************************************
  -- Get Transaction Information
  -- This procedure is called from CompleteWorkflowCO, called when Edit
  -- link/button is pressed on the notification
  -- It should set appropriate Transient transaction status.
  ******************************************************* */
PROCEDURE get_url_for_edit (
    p_itemType      IN VARCHAR2
   ,p_itemKey       IN VARCHAR2
   ,p_activityId   OUT NOCOPY VARCHAR2
   ,p_functionName OUT NOCOPY VARCHAR2
   ,p_url          OUT NOCOPY VARCHAR2 ) IS
--
l_applicationId NUMBER;
l_regionCode    VARCHAR2(30);
l_newState      VARCHAR2(5);
l_activityLabel VARCHAR2(240);
--l_savedStatus   BOOLEAN   := INSTR(p_status,'S') > 0;
--
BEGIN
  --
    -- fetch the current activity, from which the url will be built.
/*
    p_activityId    := get_notified_activity(
                        p_itemType  => p_itemType
                       ,p_itemKey   => p_itemKey
                       ,p_ntfId     => null);
*/
    p_activityId    := get_notified_activity(
                        p_itemType  => p_itemType
                       ,p_itemKey   => p_itemKey);
    -- If attribute is not found, means the transaction was submitted and thus current activity is BLOCK
    -- Complete this activity with RESULT=REDO and fetch the attribute value from the current activity.
    l_regionCode    :=  wf_engine.GetActivityAttrText(
                            itemtype    => p_itemType
                           ,itemkey     => p_itemKey
                           ,actid       => p_activityId
                           ,aname       => 'HR_ACTIVITY_TYPE_VALUE' );
          --
    DECLARE
         activity_attr_doesnot_exist exception;
         pragma exception_init(activity_attr_doesnot_exist, -20002);
    BEGIN
       l_applicationId :=  wf_engine.GetActivityAttrText(
                            itemtype    => p_itemType
                           ,itemkey     => p_itemKey
                           ,actid       => p_activityId
                           ,aname       => 'APPLICATION_ID' );
       IF l_applicationId IS NULL THEN
            l_applicationId := '800';
       END IF;
    EXCEPTION
       WHEN activity_attr_doesnot_exist THEN  -- if APPLICATION_ID is not defined for the jsp page, set it to 800 by default
             l_applicationId := '800';
         WHEN OTHERS THEN
             raise;
    END;
--
    p_functionName   :=  wf_engine.GetItemAttrText(
                            itemtype    => p_itemType
                           ,itemkey     => p_itemKey
                           ,aname       => 'P_CALLED_FROM');
--
    p_url  := 'OA.jsp?akRegionApplicationId='||l_applicationId||'&akRegionCode='||l_regionCode||'&retainAM=Y&OAFunc='||p_functionName;
--
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.get_url_for_edit : ' || sqlerrm);
          raise;
  --
END get_url_for_edit;
--
--
/* **************************************************************
  -- Set transaction Status
  --
  *************************************************************** */

PROCEDURE set_transaction_status (
      p_itemtype         IN     VARCHAR2,
      p_itemkey          IN     VARCHAR2,
      p_activityId       IN     VARCHAR2 DEFAULT NULL,
      p_action           IN     VARCHAR2,
      p_result           OUT NOCOPY    VARCHAR2 )  IS
--
--Pragma Autonomous_Transaction;

l_ReturnToUser  VARCHAR2(340);
l_CreatorUser   VARCHAR2(340);
l_transactionId NUMBER;
l_status        VARCHAR2(10);
l_state         VARCHAR2(5);
l_newState      VARCHAR2(5);
l_newStatus      VARCHAR2(10);
--
   CURSOR cur_txn_status IS
   SELECT   transaction_id, status, transaction_state
   FROM     hr_api_transactions
   WHERE    item_type   = p_itemType
   AND      item_key    = p_itemKey;
   --
BEGIN
--
   IF ( cur_txn_status%ISOPEN ) THEN
      CLOSE cur_txn_status;
   END IF;
       --
   OPEN  cur_txn_status;
   FETCH cur_txn_status INTO l_transactionId, l_status, l_state;
   CLOSE cur_txn_status;
   --
   -- fix for bug 4886788
   -- need to close sfl ntf with new SFL model by default.
    IF l_transactionId is not null THEN
      hr_sflutil_ss.closeopensflnotification(l_transactionId);
   END IF;

   IF (p_action = 'SFL') THEN
      -- If saving Supervisor page, then put add value history with step_id =0, no approval_history record

      IF l_transactionId is null THEN
 	p_result := 'COMPLETE:SUCCESS';
        RETURN;
      END IF;

      -- Copy current values to previous values so they can be used to revert later (if needed)
      /* update_txn_previous_values (l_transactionId); */ -- ##history
      --
      -- Update original value in history table (LATEST_ORIGINAL_VALUE) -- ##history
      /* PQH_SS_HISTORY.track_original_value
        ( p_ItemType        => p_itemType
        , p_itemKey         => p_itemKey
        , p_action          => 'SFL'
        , p_username        => null
        , p_transactionId   => l_transactionId); */
      --
      l_newState   := null; -- New state will be null.
      IF ( l_status IN ('W','C','N','S')) THEN
           l_newStatus := 'S';
      ELSIF ( INSTR(l_status,'S') > 0 ) THEN -- If already saved txn then no change in status
           l_newStatus := l_status;
      ELSE
           l_newStatus := l_status||'S';
      END IF;



     hr_transaction_api.update_transaction(
               p_transaction_id    => l_transactionId,
               p_status            => l_newStatus,
               p_transaction_state => l_newState );

      hr_trans_history_api.archive_sfl(l_transactionId
                                       ,null
                                       ,FND_GLOBAL.user_name);


      --
      IF (l_status in ('Y','RI','RO')) THEN
         l_newStatus := wf_engine.eng_null;
      ELSE
         l_newStatus := 'SFL';
      END IF;
      complete_wf_activity (
               	p_itemType    => p_itemType
               ,p_itemKey     => p_itemKey
               ,p_activity    => p_activityId
               ,p_otherAct    => 'OTHER'
               ,p_resultCode  => l_newStatus);
      --
   ELSE
   -- Get new Transaction Status
   IF (p_action  = 'SUBMIT' ) THEN
      -- Copy current values to previous values so they can be used to revert later (if needed)
   --   update_txn_previous_values (l_transactionId); -- ##history



      --
      l_newState   := null; -- New state will be null.
      -- If transaction submitted or Edited and Submitted then set to Y
      l_newStatus := 'Y';
       hr_transaction_api.update_transaction(
               p_transaction_id    => l_transactionId,
               p_status            => l_newStatus,
               p_transaction_state => l_newState );

       -- Note:- Initial submit archive is handled in the flow
       -- need to handle archive of resubmit
       if(l_status not in ('W','S')) then
          -- approver edit or rfc edit submit case
        hr_trans_history_api.archive_resubmit(l_transactionId,
                                                 null,
                                                 fnd_global.user_name,
                                                 wf_engine.getitemattrtext(p_itemType,
                                                                      p_itemKey,
                                                                      'APPROVAL_COMMENT_COPY')
                                                );

         end if;

   ELSIF (p_action = 'APPROVE') THEN
       l_newStatus  := 'Y';
       l_newState   := null;

              hr_transaction_api.update_transaction(
               p_transaction_id    => l_transactionId,
               p_status            => l_newStatus,
               p_transaction_state => l_newState );

       --
       --
       hr_trans_history_api.archive_approve(l_transactionId,
                                            null,
                                            fnd_global.user_name,
                                            null); -- comments ??


       IF ( l_state IN ('T','W') ) THEN -- REDO only if transient or WIP
          IF (l_state = 'W') THEN
          -- ##history
            /*update_txn_current_values( l_transactionId );
            --
            reset_original_values (
               p_itemType  => p_itemType
              ,p_itemKey   => p_itemKey
              ,p_txnId     => l_transactionId);*/
              null;
            --
          END IF;
          complete_wf_activity (
            p_itemType    => p_itemType
           ,p_itemKey     => p_itemKey
           ,p_activity    => p_activityId   -- not used because current act is fetched
           ,p_otherAct    => 'CURR'
           ,p_commitFlag  => 'Y'
           ,p_resultCode  => 'REDO' );
        --
       END IF;
       --
   ELSIF (p_action = 'RFC' ) THEN
       -- Fetch the Return to Username and Creator User Name from WF
       BEGIN
       l_ReturnToUser   :=
              wf_engine.GetItemAttrText(
                  itemtype => p_itemType,
                  itemkey  => p_itemKey,
                  aname    => 'RETURN_TO_USERNAME');
       EXCEPTION
         WHEN OTHERS THEN -- if attributes are not found then don't do anything
             null;
       END;

       IF (l_ReturnToUSer IS NULL ) THEN
            --For customized processes still using the old approval process
            --the status is set to C, so that they are listed in
            --in pending actions table.
            l_newStatus := 'C';
            -- Bug 3031918: TRAN_SUBMIT need to be set to C for v4 processes
            -- on Return for Correction
            wf_engine.SetItemAttrText(
                    itemtype    => p_itemType,
                    itemkey     => p_itemKey,
                    aname       => 'TRAN_SUBMIT',
                    avalue      => l_newStatus );

       ELSE
           l_CreatorUser    :=
               wf_engine.GetItemAttrText(
                  itemtype => p_itemType,
                  itemkey  => p_itemKey,
                  aname    => 'CREATOR_PERSON_USERNAME');
       --
           IF (l_ReturnToUSer = l_CreatorUser ) THEN -- Return for correction to initiator
            l_newStatus := 'RI';
           ELSE -- Returned for Correction to other manager
            l_newStatus := 'RO';
           END IF;
       END IF;
           l_newState  := null; -- no change to state.
            hr_transaction_api.update_transaction(
               p_transaction_id    => l_transactionId,
               p_status            => l_newStatus,
               p_transaction_state => l_newState );
          -- update the transaction state table too
         pqh_tsh_upd.upd(p_transaction_history_id=>l_transactionId,
                         p_approval_history_id=>hr_trans_history_api.gettransstatesequence(l_transactionId),
                         p_status=>l_newStatus,
                         p_transaction_state=>l_newState);

   END IF;
   --
    /*hr_transaction_api.update_transaction(
               p_transaction_id    => l_transactionId,
               p_status            => l_newStatus,
               p_transaction_state => l_newState );*/
   wf_engine.SetItemAttrText(
                    itemtype    => p_itemType,
                    itemkey     => p_itemKey,
                    aname       => 'TRAN_SUBMIT',
                    avalue      => l_newStatus );
   --
   END IF;
   p_result := 'COMPLETE:SUCCESS';
--
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.set_transaction_status : ' || sqlerrm);
          raise;
  --
END set_transaction_status;

--
--
-- Bug 3018784: This procedure is nullified in ver115.34 (hrssa.wft must be 115.196 and above)
-- as it is no longer called from the workflow process.
PROCEDURE set_txn_submit_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
--
BEGIN
--
   result := 'COMPLETE:SUCCESS';
--
END set_txn_submit_status;
--
--
PROCEDURE set_txn_approve_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
--
BEGIN
--
  IF (funcmode = wf_engine.eng_run) THEN
  --
     set_transaction_status (
        p_itemType  => itemType
       ,p_itemKey   => itemKey
       ,p_action    => 'APPROVE'
       ,p_result    => result );
  --
  END IF;
--
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.set_txn_approve_status : ' || sqlerrm);
          Wf_Core.Context(g_package, 'set_txn_approve_status', itemType, itemKey);
          raise;
  --
END set_txn_approve_status;
--
--
PROCEDURE set_txn_rfc_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
--
BEGIN
--
  IF (funcmode = wf_engine.eng_run) THEN
  --
     set_transaction_status (
        p_itemType  => itemType
       ,p_itemKey   => itemKey
       ,p_action    => 'RFC'
       ,p_result    => result );
  --
  END IF;

EXCEPTION
   WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.set_txn_rfc_status : ' || sqlerrm);
          Wf_Core.Context(g_package, 'set_txn_rfc_status', itemType, itemKey);
          raise;
--
END set_txn_rfc_status;
--
PROCEDURE set_txn_sfl_status (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
--
BEGIN
--
  IF (funcmode = wf_engine.eng_run) THEN
  --
  /* Fix for bug# 3389563
     The calls will be part of Java calls.
     This procedure should not be invoked from with in any Workflow process.
     set_transaction_status (
        p_itemType  => itemType
       ,p_itemKey   => itemKey
       ,p_activityId=> actId
       ,p_action    => 'SFL'
       ,p_result    => result );
  */
   result:= wf_engine.eng_trans_default;
  --
  END IF;

EXCEPTION
   WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.set_txn_sfl_status : ' || sqlerrm);
          Wf_Core.Context(g_package, 'set_txn_sfl_status', itemType, itemKey);
          raise;
END set_txn_sfl_status;
--

--
-- This procedure sets the effective date and date option in transaction table
-- as well as the transaction_values table.
PROCEDURE  set_effective_date_and_option (
           p_txnId               IN VARCHAR2
          ,p_effectiveDate       IN DATE
          ,p_effectiveDateOption IN VARCHAR2 ) IS
--
  CURSOR cur_asgn IS
  SELECT api_name,transaction_step_id
  FROM   hr_api_transaction_steps
  WHERE  transaction_id       = p_txnId;
--
--  AND    api_name             = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API';
  --
  l_txnStepId      NUMBER(15);
  l_apiName        VARCHAR2(300);
  l_effectiveDate  DATE   := p_effectiveDate;
BEGIN
--
    IF ( NVL(p_effectiveDateOption,'E') = 'A') THEN
         l_effectiveDate  := sysdate;
    END IF;

    HR_TRANSACTION_API.update_transaction (
         p_transaction_id               => p_txnId
        ,p_transaction_effective_date   => l_effectiveDate
        ,p_effective_date_option        => NVL(p_effectiveDateOption,'E')  );
--

    FOR  I IN cur_asgn
    LOOP
       IF (I.api_name = 'HR_SUPERVISOR_SS.PROCESS_API' ) THEN
         HR_TRANSACTION_API.set_date_value (
            p_transaction_step_id => I.transaction_step_id
           ,p_person_id           => null
           ,p_name                => 'P_PASSED_EFFECTIVE_DATE'
           ,p_value               => l_effectiveDate );

/*
         -- ====================================================================
         -- Also set the effective dates to system date if date option is
         -- as of approval for following attributes
         -- P_PASSED_EFFECTIVE_DATE : for selected person's reassign date
         -- P_EFFECTIVE_DATE_<n>    : for reassigned employees (n is 1,2,3..)
         -- P_EMP_DATE_<n>          : for newly assigned employees(n is 1,2,3..)
         -- P_SINGLE_EFFECTIVE_DATE : ????
         -- Note: Termination step may also have to be added in case the
         -- Notification date is to be set to as of approval date
         -- ====================================================================
         IF ( NVL(p_effectiveDateOption,'E') = 'A' ) THEN
           UPDATE  hr_api_transaction_values
           SET     date_value          = l_effectiveDate
           WHERE   transaction_step_id = I.transaction_step_id
           AND     name             like 'P%DATE%';
         END IF;
         --
*/
       ELSE
    --
    --
      HR_TRANSACTION_API.set_date_value (
         p_transaction_step_id => I.transaction_step_id
        ,p_person_id           => null -- used to validate, no other usage
        ,p_name                => 'P_EFFECTIVE_DATE'
        ,p_value               => p_effectiveDate );
   --
      HR_TRANSACTION_API.set_varchar2_value (
         p_transaction_step_id => I.transaction_step_id
        ,p_person_id           => null -- used to validate, no other usage
        ,p_name                => 'P_EFFECTIVE_DATE_OPTION'
        ,p_value               => NVL(p_effectiveDateOption,'E') );

      END IF;
    END LOOP;
   --
   --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.set_effective_date_and_option : ' || sqlerrm);
          raise;
  --
END set_effective_date_and_option;
--
--
-- Called from Workflow Cancel Activity
PROCEDURE reset_txn_current_values (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 )  IS
--
      l_transactionId   NUMBER(15);
      l_ntfId           NUMBER(15);
      l_activityLabel   VARCHAR2(240);
      l_status          VARCHAR2(10);
      l_step_id         NUMBER(15);
--
--      CURSOR cur_status IS
--      SELECT  status
--      FROM    hr_api_transactions
--      WHERE   transaction_id  = l_transactionId;
BEGIN
  IF (funcmode <> wf_engine.eng_run) THEN
    result := wf_engine.eng_null;
    RETURN;
  END IF;

  l_transactionId  :=  get_transaction_id (
                   p_itemType   => itemType
                  ,p_itemKey    => itemKey );

--   if transactionid is null, nothing is saved yet
--   no action needed, just complete the current workflow activity.
  IF (l_transactionId IS NOT null ) THEN
     l_ntfId    := get_notification_id(
                        p_itemType  => itemType
                       ,p_itemKey   => itemKey);


   -- need to check status too
    begin
       select status into l_status
       from hr_api_transactions
       where transaction_id=l_transactionId;
    exception
     when others then
      null;
    end;
   --

 --  Remove transaction if it's a new one, else revert back to previous values
     IF ( l_ntfId IS NULL and l_status='W' ) THEN
        hr_transaction_api.rollback_transaction
                 (p_transaction_id => l_transactionId  );

	--3099089 change starts
        --need to remove transaction_id from wf_item_attribute_values also
        wf_engine.setitemattrnumber
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'TRANSACTION_ID'
        ,avalue   => null);
	--3099089 change ends

        result := 'COMPLETE:CANCELLED';
        RETURN;
     ELSE
--        IF ( cur_status%ISOPEN ) THEN
--           CLOSE cur_status;
--        END IF;
       --
--        OPEN  cur_status;
--        FETCH cur_status INTO l_status;
--        CLOSE cur_status;


        -- add new call to archive api to revert to last save
        hr_trans_history_api.cancel_action(l_transactionId);
        --
        --
        --vegopala fix for bug 5436747.Commenting as it is not
        -- reqd to set to T.
        -- Set the state to T once the activities are completed.
        --
       /*  hr_transaction_api.update_transaction (
               p_transaction_id     => l_transactionId
              ,p_transaction_state  => 'T' );
        */
        --
        result := 'COMPLETE:ACCEPTED';
        RETURN;
      END IF; -- notification not null
   END IF;      -- txn not null
   -- default result
   result := 'COMPLETE:CANCELLED';
   --
   --
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.reset_txn_current_values : ' || sqlerrm);
          Wf_Core.Context(g_package, 'reset_txn_current_values', itemType, itemKey);
          raise;
  --
END reset_txn_current_values;


--
--
PROCEDURE check_initial_save_for_later (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
   --
   -- ItemType aNd ItemKey are for the approval wf process
    CURSOR cur_txn IS
    SELECT NVL(status,'N')
    FROM   hr_api_transactions
    WHERE  item_type  = itemType
    AND    item_key   = itemKey;
    l_status   VARCHAR2(10);
--
    BEGIN
--
       IF (funcmode = wf_engine.eng_run ) THEN

/*
07-May-2003 ns moved to approval_block
          -- Set the Approval process version to distinguish it
          -- it from old approval process.
	     wf_engine.SetItemAttrText(
		 itemtype => itemType
	       , itemkey  => itemKey
	       , aname    => 'HR_APPROVAL_PRC_VERSION'
	       , avalue   => 'V5' );
	       --
*/
           IF ( cur_txn%ISOPEN ) THEN
              CLOSE cur_txn;
           END IF;
           --
           OPEN  cur_txn;
           FETCH cur_txn INTO l_status;
           CLOSE cur_txn;
--
           IF l_status in ('S') THEN -- Saved for Later (not yet Submitted)
            result := 'COMPLETE:T';
           ELSE
            result := 'COMPLETE:F';
           END IF;
--
       END IF;
--
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.check_initial_save_for_later : ' || sqlerrm);
          Wf_Core.Context(g_package, 'check_initial_save_for_later', itemType, itemKey);
          raise;
  --
    END check_initial_save_for_later;
--
--
/* Return_For_Correction to the user passed by the calling method returnForCorrection
 * in ReturnForCorrectionAMImpl
 * Parameters:
 * p_userName - Used to set FROM_ROLE attribute of the notification
 * p_userDisplayName - Used in FYI notification send to initiator when RFC to
 *                     other than Initiator
 * p_approverIndex - Selected users index in the approval chain, to set wf attribute
 * p_txnId - To fetch last default approver before the approver who is performing RFC
 */
  PROCEDURE return_for_correction (
       p_itemType        IN VARCHAR2
     , p_itemKey         IN VARCHAR2
     , p_userId          IN VARCHAR2  -- NOTE: not really userid, it is the personId
     , p_userName        IN VARCHAR2
     , p_userDisplayName IN VARCHAR2
     , p_ntfId           IN VARCHAR2
     , p_note            IN VARCHAR2
     , p_approverIndex   IN NUMBER
     , p_txnId           IN VARCHAR2) IS
--
  l_activity    NUMBER;
  l_itemType    VARCHAR2(30);
  l_itemKey     VARCHAR2(30);
  l_userName    FND_USER.user_name%Type;
  l_ntfId       NUMBER;
  l_lastDefaultApprover NUMBER;
  dummy  varchar2(10);

-- Cursor to find if the person (selected for RFC) is an additional approver
   CURSOR cur_add_appr IS
   SELECT 'X'
     FROM wf_item_attribute_values
    WHERE item_type = p_itemType
      AND item_key  = p_itemKey
      AND name      like 'ADDITIONAL_APPROVER_%'
      AND number_value = p_userId;
--
-- Cursor to fetch the last default approver below the person performing
-- RFC. It is used only in case of NON-AME approvals.
--
  CURSOR  cur_appr  IS
  SELECT pth.employee_id
    FROM pqh_ss_approval_history pah,
         fnd_user pth
   WHERE pah.user_name = pth.user_name
     AND pah.transaction_history_id = p_txnId
     AND approval_history_id = (
      SELECT MAX(approval_history_id)
        FROM pqh_ss_approval_history  pah1,
             fnd_user pth1
       WHERE pah1.user_name = pth1.user_name
         AND pah1.transaction_history_id = pah.transaction_history_id
         AND pth1.employee_id IN (
           SELECT pth2.employee_id --, pth2.user_name, approval_history_id
             FROM pqh_ss_approval_history pah2,
                  fnd_user                pth2
            WHERE pah2.user_name = pth2.user_name
              AND pah2.transaction_history_id = pah.transaction_history_id
              AND approval_history_id < (
               SELECT MIN(approval_history_id)
                 FROM pqh_ss_approval_history
                WHERE transaction_history_id = pah.transaction_history_id
                  AND user_name = p_userName
                  AND approval_history_id > 0
               )
           and approval_history_id > 0
           MINUS
           SELECT number_value
             FROM wf_item_attribute_values
            WHERE item_type = p_itemType
              AND item_key  = p_itemKey
              AND name      like 'ADDITIONAL_APPROVER_%'
      )
    );
--
  BEGIN
--
     Rollback; -- Needed in case of New Hire and CWK to that the changes are not committed.

   -- fix for bug 4454439
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>p_itemType
                                          ,p_item_key=>p_itemKey);
    exception
    when others then
      null;
    end;

     IF ( p_itemType IS NULL OR p_itemKey IS NULL OR p_userName IS NULL ) THEN
          get_item_type_and_key (
                p_ntfId    => p_ntfId
               ,p_itemType => l_itemType
               ,p_itemKey  => l_itemKey );

	  -- fix for bug 4454439
    begin
      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>l_itemType
                                          ,p_item_key=>l_itemKey);
    exception
    when others then
      null;
    end;


          l_userName  :=  wf_engine.GetItemAttrText(
                             itemtype => l_itemType
                           , itemkey  => l_itemKey
                           , aname    => 'CREATOR_PERSON_USERNAME');
     ELSE
           l_itemType   := p_itemType;
           l_itemKey    := p_itemKey;
           --l_userName   := p_userName; -- fix for bug 4481775
           if(p_userId is not null) then
             select user_name
             into l_userName
             from  fnd_user
             where employee_id=p_userId;
            end if;

     END IF;

     -- Set the item attribute for the return to user name.
     wf_engine.SetItemAttrText(
         itemtype => l_itemType
       , itemkey  => l_itemKey
       , aname    => 'RETURN_TO_USERNAME'
       , avalue   => l_userName );
     --
     hr_approval_wf.create_item_attrib_if_notexist(
         p_item_type  => l_itemtype
        ,p_item_key   => l_itemkey
        ,p_name       => 'RETURN_TO_PERSON_DISPLAY_NAME');

     wf_engine.SetItemAttrText(
         itemtype => l_itemType
       , itemkey  => l_itemKey
       , aname    => 'RETURN_TO_PERSON_DISPLAY_NAME'
       , avalue   => p_userDisplayName );
     --
     -- Fetch the activity id of notification to be completed
     l_activity   := get_notified_activity(
                        p_itemType      => l_itemType
                       ,p_itemKey       => l_itemKey
                       ,p_ntfId         => p_ntfId );
     --
     -- Set the notes for RFC notification.
       wf_engine.setItemAttrText (
            itemtype => l_itemType
           ,itemkey  => l_itemKey
           ,aname    => 'NOTE_FROM_APPR'
           ,avalue   => p_note );

       wf_engine.setItemAttrText (
            itemtype => l_itemType
           ,itemkey  => l_itemKey
           ,aname    => 'WF_NOTE'
           ,avalue   => NULL );


       wf_notification.setattrtext(
       			p_ntfId
       		       ,'RESULT'
       		       ,'RETURNEDFORCORRECTION');
       BEGIN
           wf_notification.setattrtext(
       			p_ntfId
       		       ,'WF_NOTE'
       		       ,p_note);
        EXCEPTION WHEN OTHERS THEN
           -- RFC from SFL Other
           wf_notification.propagatehistory(
                               l_itemType
                              ,l_itemKey
                              ,'APPROVAL_NOTIFICATION'
                              ,fnd_global.user_name
                              ,l_userName
                              ,'RETURNEDFORCORRECTION'
                              ,null
                              ,p_note);
       END;

     -- Send Notification

      wf_notification.respond(
      			p_ntfId
      		       ,null
      		       ,fnd_global.user_name
      		       ,null);

     -- Fetch the id for RFC notification.
     l_ntfId    := get_notification_id(
                        p_itemType  => l_itemType
                       ,p_itemKey   => l_itemKey);


     -- Set the from attribute for RFC notification.
     wf_notification.setAttrText(
           nid           => l_ntfId
          ,aname         => '#FROM_ROLE'
          ,avalue        => fnd_global.user_name );

     -- Set the two workflow attributes for Non-AME approval process
     IF (wf_engine.GetItemAttrText(itemtype => l_itemType ,
                                   itemkey  => l_itemKey,
                                   aname    => 'HR_AME_TRAN_TYPE_ATTR') IS NULL) THEN
       -- CURRENT_APPROVER_INDEX
       begin
       -- set the attribute value to null
        wf_engine.SetItemAttrNumber(
                 itemtype => l_itemType ,
                 itemkey  => l_itemKey,
                 aname    => 'CURRENT_APPROVER_INDEX',
                 avalue   => p_approverIndex);
       exception
        when others then null;
       end;

       -- Set LAST_DEFAULT_APPROVER
       begin

        --
        -- If the selected person (for RFC) is additional approver
        -- then fetch the last default approver from history
        -- else selected person is the last default approver
        IF ( cur_add_appr%ISOPEN ) THEN
              CLOSE cur_add_appr;
        END IF;
         --
        OPEN  cur_add_appr;
        FETCH cur_add_appr INTO dummy;
          if cur_add_appr%found then
             --
             IF ( cur_appr%ISOPEN ) THEN
              CLOSE cur_appr;
             END IF;
             --
             OPEN  cur_appr;
             FETCH cur_appr INTO l_lastDefaultApprover;
             CLOSE cur_appr;
             --
          else
              l_lastDefaultApprover := p_userId;
          end if;

        CLOSE cur_add_appr;

        IF ( l_lastDefaultApprover IS NOT NULL ) THEN
           wf_engine.SetItemAttrNumber(
                 itemtype => l_itemType ,
                 itemkey  => l_itemKey,
                 aname    => 'LAST_DEFAULT_APPROVER',
                 avalue   => l_lastDefaultApprover);
        END IF;
       exception
        when others then null;
       end;
     END IF; -- Non-AME approval

   --Commit is needed otherwise from role and notes will not appear for the notification.
   COMMIT;
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.return_for_correction : ' || sqlerrm);
          raise;
  --
   END return_for_correction;
--
-- Local function to return the message_name for the notification
FUNCTION get_message_attr_name(
      p_ntfId    in number
     ,p_itemType in varchar2) return varchar2 IS
  --
  CURSOR cur_ntf IS
  SELECT wma.display_name
  FROM   wf_notifications  wn, wf_message_attributes_vl  wma
  WHERE  wn.notification_id  = p_ntfId
  AND    wn.message_name     = wma.message_name
  AND    wma.message_type    = p_itemType
  AND    wma.name            = 'EDIT_TXN_URL';
 --
  l_messageAttr  varchar2(4000);
BEGIN
 --
  IF ( cur_ntf%ISOPEN ) THEN
      CLOSE cur_ntf;
  END IF;
  --
  OPEN  cur_ntf;
  FETCH cur_ntf INTO l_messageAttr;
  CLOSE cur_ntf ;
 --
  RETURN l_messageAttr;
 --
END get_message_attr_name;
--
--
PROCEDURE get_edit_link(
      document_id   in     varchar2,
      display_type  in     varchar2,
      document      in out nocopy varchar2,
      document_type in out nocopy varchar2) IS
  --
  --
   l_profileValue   VARCHAR2(1);
--   l_profileName    VARCHAR2(30);
   l_ntfId          NUMBER(15);
   l_itemType       VARCHAR2(30);
   l_itemKey        VARCHAR2(30);
--   l_effectiveDate  VARCHAR2(20);
--   l_personId       VARCHAR2(15);
--   l_assignmentId   VARCHAR2(15);
   l_editUrl        VARCHAR2(400);
   l_urlLabel       VARCHAR2(80);
   l_checkProfile   VARCHAR2(10);
   l_status         VARCHAR2(10);
 --
   CURSOR cur_txn (c_itemType VARCHAR2, c_itemKey VARCHAR2) IS
   SELECT   -- to_char(NVL(transaction_effective_date,sysdate),g_date_format),
            -- assignment_id, selected_person_id,
            NVL(status,'N'), NVL(fnd_profile.value('PQH_ALLOW_APPROVER_TO_EDIT_TXN'),'N')
   FROM     hr_api_transactions
   WHERE    item_type   = c_itemType
   AND      item_key    = c_itemKey;
 --
 BEGIN
     document_type  := wf_notification.doc_html;
     l_ntfId        := document_id;

--     l_ntfId        := SUBSTR(document_id,1,INSTR(document_id,':')-1);
--     l_checkProfile := SUBSTR(document_id,INSTR(document_id,':')+1);

--     IF (l_checkProfile = 'Y' ) THEN
--         l_profileValue := NVL(fnd_profile.value(l_profileName),'N');
--     END IF;

--dbms_output.put_line('NtfId: '||l_ntfId);

        get_item_type_and_key (
                p_ntfId    => l_ntfId
               ,p_itemType => l_itemType
               ,p_itemKey  => l_itemKey );
        --
--dbms_output.put_line('itemType: '||l_itemType||'  itemKey: '||l_itemKey);
        IF ( cur_txn%ISOPEN ) THEN
          CLOSE cur_txn;
        END IF;
        --
        OPEN  cur_txn (l_itemType, l_itemKey);
        FETCH cur_txn INTO  l_status, l_profileValue;
--        FETCH cur_txn INTO l_effectiveDate, l_assignmentId, l_personId, l_status, l_profileValue;
        CLOSE cur_txn;
        --
        --
     -- No need to check profile option (i.e. must render edit link)
     -- in following cases
     IF (INSTR(l_status,'S') > 0 OR l_status IN ('RI','N','C','W') ) THEN
         l_checkProfile := 'N';
     END IF;

     IF (l_checkProfile = 'N' OR l_profileValue ='Y' ) THEN
        l_urlLabel   := get_message_attr_name (
                         p_ntfId    => l_ntfId
                        ,p_itemType => l_itemType );


        l_editUrl    := '<a href='||g_OA_HTML||
           'OA.jsp?page=/oracle/apps/pqh/selfservice/common/webui/EffectiveDatePG&retainAM=Y&NtfId=&#NID>'||
                          l_urlLabel||'</a>';
        document :=
            '<tr><td> '||
            '<IMG SRC="'||g_OA_MEDIA||'afedit.gif"/>'||
            '</td><td>'||
              l_editUrl||
            '</td></tr> ';

     ELSE
        document := null;
     END IF;
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.get_edit_link : ' || sqlerrm);
          raise;
  --
 END get_edit_link;
--
--
-- This procedure will  check if the date option is A - As of final approval
-- it will set the effective date to the system date.
PROCEDURE set_date_if_as_of_approval (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 )  IS
--
      CURSOR cur_txn IS
      SELECT transaction_id, NVL(effective_date_option,'X')
      FROM   hr_api_transactions
      WHERE  item_type     = itemType
      AND    item_key      = itemKey;
--
   l_txnId         NUMBER(15);
   l_effDateOption VARCHAR2(10);
   l_effectiveDate DATE;
   --
BEGIN
--
      IF ( cur_txn%ISOPEN ) THEN
       CLOSE cur_txn;
      END IF;
      --
      OPEN  cur_txn;
      FETCH cur_txn INTO l_txnId, l_effDateOption;
      CLOSE cur_txn;

      IF ( l_effDateOption = 'A' ) THEN
           l_effectiveDate := sysdate;

           HR_TRANSACTION_API.update_transaction (
             p_transaction_id               => l_txnId
            ,p_transaction_effective_date   => l_effectiveDate );
           --
           wf_engine.setItemAttrText
                          (itemtype => itemType
                          ,itemkey  => itemKey
                          ,aname    => 'P_EFFECTIVE_DATE'
                          ,avalue   => TO_CHAR(l_effectiveDate,g_date_format) );
-- Bug 4243314 starts.
           wf_engine.setItemAttrDate
                          (itemtype => itemType
                          ,itemkey  => itemKey
                          ,aname    => 'CURRENT_EFFECTIVE_DATE'
                          ,avalue   =>l_effectiveDate);
-- Bug 4243314 ends.
           --
           --
           -- ==================================================================
           -- Bug 3044048: On final approval set sysdate as, As Of Approval Date
           -- If it is decided that reassigned and newly assigned reports are to
           -- have current date if as of approval is chosen, then use the where
           -- clause name like 'P%DATE%'.
           -- If it is decided that notified date must be as of approval then
           -- then add the where clause api_name = 'HR_TERMINATION_SS.PROCESS_API'
           -- ==================================================================
           UPDATE  hr_api_transaction_values
           SET     date_value          = l_effectiveDate
           WHERE   datatype            = 'DATE'
           AND     name                = 'P_PASSED_EFFECTIVE_DATE'
           AND     transaction_step_id = (
                   SELECT transaction_step_id
                   FROM   hr_api_transaction_steps
                   WHERE  transaction_id = l_txnId
                   AND    api_name       = 'HR_SUPERVISOR_SS.PROCESS_API' );
           --
      END IF;
      --
  --
  EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace(' exception in  '||g_package||'.set_date_if_as_of_approval : ' || sqlerrm);
          Wf_Core.Context(g_package, 'set_date_if_as_of_approval', itemType, itemKey);
          raise;
  --
END set_date_if_as_of_approval;
--
FUNCTION add_message (
	 p_message_type    IN VARCHAR2
        ,p_apps_short_name IN VARCHAR2
        ,p_message_name    IN VARCHAR2
        ,p_called_from     IN VARCHAR2
        ,p_addToPub        IN VARCHAR2 DEFAULT 'NO'
        ,p_token_name      IN VARCHAR2 DEFAULT NULL
        ,p_token_value     IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
--
l_message   VARCHAR2(4000);
l_text      VARCHAR2(8000);
l_icon	    VARCHAR2(40);
l_css       VARCHAR2(40);
ln_app_id   fnd_application.application_id%type;
cursor c1  is
     select fa.application_id
     from   fnd_application  fa
     where  fa.application_short_name = p_apps_short_name ;

BEGIN
--
     fnd_message.set_name(p_apps_short_name,p_message_name);
--     l_message  := fnd_message.get_string(p_apps_short_name,p_message_name);
     IF (p_token_name IS NOT NULL AND p_token_value IS NOT NULL ) THEN
         fnd_message.set_token(p_token_name,p_token_value);
     END IF;
     l_message  := fnd_message.get;
     --
     -- No need to format the message if called from final validation
     IF (NVL(p_called_from,'X') = 'FINAL_VALIDATION') THEN
         return l_message;
     END IF;

     IF (p_message_type = 'ERR') THEN
        l_icon	:= 'erroricon_active.gif';
        l_css   := 'OraErrorText';
     ELSE
	l_icon	:= 'warningicons_active.gif';
        l_css   := 'OraTipText';
     END IF;

     l_text     := '<tr><td> '||
                   '<IMG SRC="'||g_OA_MEDIA||l_icon||'"/>'||
                   '</td><td>'||
                   '<a class='||l_css||'>'||l_message||'</a>'||
                   '</td></tr> ';

     IF (p_addToPub <> 'NO') THEN
        open c1 ;
        fetch c1 into ln_app_id ;
        close c1 ;
        hr_utility.set_message(ln_app_id,p_message_name);
        IF (p_token_name IS NOT NULL AND p_token_value IS NOT NULL ) THEN
            hr_utility.set_message_token(p_token_name,p_token_value);
        END IF;
        IF ( p_message_type = 'ERR') THEN
            hr_multi_message.add( p_message_type => hr_multi_message.G_ERROR_MSG);
        ELSE
            hr_multi_message.add( p_message_type => hr_multi_message.G_WARNING_MSG);
        END IF;
     END IF;

     return l_text;
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.add_message : ' || sqlerrm);
           raise;
  --
END add_message;
--

FUNCTION get_errors_and_warnings (
      p_itemType     IN        VARCHAR2,
      p_itemKey      IN        VARCHAR2,
      p_calledFrom   IN        VARCHAR2  DEFAULT NULL,
      p_addToPub     IN        VARCHAR2  DEFAULT 'NO',
      p_sendToHr    OUT NOCOPY VARCHAR2,
      p_hasErrors   OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
--
l_state           VARCHAR2(10);
l_status          VARCHAR2(10);
l_terminationDate DATE;
--
l_stepId          NUMBER(15);
l_txnId           NUMBER(15);
l_bgId            NUMBER(15);
l_rptgGrpId       NUMBER(15);
l_planId          NUMBER(15);
l_personId        VARCHAR2(15);
l_assignmentId    VARCHAR2(15);
l_cpersonId       VARCHAR2(15);
--
l_editAllowed     VARCHAR2(10);
l_futureChange    VARCHAR2(10);
l_pendingTxn      VARCHAR2(10);
l_interAction     VARCHAR2(10);
l_isPersonElig    VARCHAR2(10);
l_dtParmFound     VARCHAR2(10);
l_rtParmFound     VARCHAR2(10);
l_slParmFound     VARCHAR2(10);
l_terminateFlag   VARCHAR2(30);
--
l_effDateOption   VARCHAR2(20);
l_effectiveDate   VARCHAR2(20);
--
l_profileValue    VARCHAR2(100);
l_processName     VARCHAR2(200);
--
l_rateMsg         VARCHAR2(100)  ;
l_errorWarnings   VARCHAR2(20000);
l_errorMsg        VARCHAR2(10000)  := '';
l_warningMsg      VARCHAR2(10000)  := '';
--
l_whatChecks      VARCHAR2(10);
lb_istxnowner     boolean;

--
BEGIN
--
     -- By default check Intervening/Future, Pending and Eligibility
     l_whatChecks      := 'IPG';
     p_sendToHr		:= 'N';
     p_hasErrors	:= 'N';

     IF (p_addToPub = 'YES') THEN
        hr_multi_message.enable_message_list;
        p_hasErrors := set_developer_ntf_msg(p_itemType, p_itemKey);
     END IF;

     -- If non-approval process and final_validation is being performed,
     -- then only check for future dated changes.
     IF (NVL(p_calledFrom,'X') = 'FINAL_VALIDATION' ) THEN
        BEGIN
        IF wf_engine.GetItemAttrText(
             itemtype => p_itemType,
             itemkey  => p_itemKey,
             aname    => 'HR_RUNTIME_APPROVAL_REQ_FLAG')
                              NOT IN ('YES','YES_DYNAMIC') THEN
            l_whatChecks    := 'F';
        END IF;
        EXCEPTION
          WHEN OTHERS THEN -- if wf attribute is not found
            l_whatChecks    := 'F';
        END;
     END IF;
     --

     l_effectiveDate := NVL( wf_engine.getItemAttrText (
                            itemtype => p_itemType
                           ,itemkey  => p_itemKey
                           ,aname    => 'P_EFFECTIVE_DATE'),to_char(sysdate,g_date_format));

     get_transaction_info (
        p_itemType       => p_itemType
       ,p_itemKey        => p_itemKey
       ,p_loginPerson    => l_personId
       ,p_whatchecks     => l_whatChecks
       ,p_personId       => l_personId
       ,p_assignmentId   => l_assignmentId
       ,p_state          => l_state
       ,p_status         => l_status
       ,p_txnId          => l_txnId
       ,p_businessGrpId  => l_bgId
       ,p_editAllowed    => l_editAllowed
       ,p_futureChange   => l_futureChange
       ,p_pendingTxn     => l_pendingTxn
       ,p_interAction    => l_interAction
       ,p_effDateOption  => l_effDateOption
       ,p_effectiveDate  => l_effectiveDate
       ,p_isPersonElig   => l_isPersonElig
       ,p_rptgGrpId      => l_rptgGrpId
       ,p_planId         => l_planId
       ,p_processName    => l_processName
       ,p_dateParmExist  => l_dtParmFound
       ,p_rateParmExist  => l_rtParmFound
       ,p_slryParmExist  => l_slParmFound
       ,p_rateMessage    => l_rateMsg
       ,p_terminateFlag  => l_terminateFlag);

        --fix for the bug 7640649
        l_cpersonId := NVL( wf_engine.getItemAttrText (
                            itemtype => p_itemType
                           ,itemkey  => p_itemKey
                           ,aname    => 'CREATOR_PERSON_ID'),-1);

        if hr_multi_tenancy_pkg.is_multi_tenant_system then
          hr_multi_tenancy_pkg.set_context_for_person(l_cpersonId);
        end if;

       begin
       lb_istxnowner := nvl(hr_transaction_swi.istxnowner(l_txnId,null),false);
       exception
       when others then
          lb_istxnowner := false;
       end;

       -- Bug 3025523: If the logged in manager does not secured access to the selected person
       -- then display appropriate message, no other message will be displayed in this
       -- case
        IF ( l_editAllowed = 'NS' ) THEN
            --
            p_hasErrors  := 'Y';
            l_errorMsg   := l_errorMsg||add_message('ERR','PQH','PQH_SS_ACCESS_TO_EMP_REC_ERR',p_calledFrom,p_addToPub);
            --
        END IF;
        --
        IF (    l_futureChange = 'Y' OR
		l_interAction  = 'Y' OR
		l_interAction  = 'YC' OR
		l_pendingTxn   = 'Y' OR
		l_editAllowed  = 'NS' OR
		l_terminateFlag <> 'NO' OR
                l_rateMsg IS NOT NULL OR
		l_isPersonElig = 'N' ) THEN

         -- Termination Check
         IF ( l_terminateFlag IN ('ASGN','PRSN') ) THEN
            --
            p_hasErrors  := 'Y';
--          l_errorMsg   := l_errorMsg||add_message('ERR','PER','HR_HR_MESG38_WEB',p_calledFrom);
            l_errorMsg   := l_errorMsg||add_message('ERR','PQH','PQH_SS_PRSN_TERMINATED_NTF_ERR',p_calledFrom,p_addToPub);
            --
         --If termination date is returned then, check if current or future termination
         ELSIF ( NVL(l_terminateFlag,'NO')<> 'NO' ) THEN
            --
          BEGIN
            l_terminationDate := to_date(l_terminateFlag,g_date_format);
            --
            -- if future termination then check profile and set error or warning
           IF ( l_terminationDate > trunc(sysdate) ) THEN
              p_sendToHr     := 'Y'; -- so that it is send to hr rep
              l_profileValue := NVL(fnd_profile.value('PQH_DT_RULE_FUTUR_CHANGE_FOUND'),'ERROR');
              --
              IF ( l_profileValue = 'ERROR' OR l_slParmFound= 'Y' ) THEN
                 p_hasErrors := 'Y';  -- To send error notification
                 l_errorMsg  := l_errorMsg||add_message('ERR','PQH','PQH_SS_FUT_TERM_EXISTS_ERR',
                                            p_calledFrom,p_addToPub,'TERM_DATE',l_terminationDate);
              ELSE
                 l_errorMsg  := l_errorMsg||add_message('WRN','PQH','PQH_SS_FUT_TERM_EXISTS_WRN',
                                            p_calledFrom,p_addToPub,'TERM_DATE',l_terminationDate);
              END IF;
              --
            END IF;
            --
          EXCEPTION
             -- In case a termination date is not returned, some value other than
             -- NO, ASGN or PRSN is returned
             WHEN OTHERS THEN Null;
          END;
         END IF;

         --Bug 3003754 Salary Change
         IF ( l_rtParmFound = 'Y' AND l_rateMsg IS NOT NULL) THEN
            --
            l_stepId := pqh_ss_utility.get_transaction_step_id (
                        p_itemType          => p_itemType
                      , p_itemKey           => p_itemKey
                      , p_apiName           => 'HR_PAY_RATE_SS.PROCESS_API' );
            --
            -- Display message only if the payrate step exists
            if ( l_stepId IS NULL ) THEN
                l_rateMsg := null;
            else
                l_errorMsg := l_errorMsg||add_message('ERR','PQH',l_rateMsg,p_calledFrom,p_addToPub);
            end if;
            --
         END IF;

         IF ( l_interAction in ('YC', 'Y') ) THEN
            -- In case of approving, an intervening action is always an error.
            -- so no need to check the profile in that case
            p_hasErrors     := 'Y';

            IF (p_calledFrom = 'FINAL_VALIDATION') THEN
              l_errorMsg := l_errorMsg||add_message('ERR','PQH','PQH_SS_INTRVN_ACTN_NTF_ERR',p_calledFrom,p_addToPub);
            ELSE
              l_profileValue  := NVL(fnd_profile.value('PQH_ALLOW_TRANSACTION_REFRESH'),'N');
              --
              IF (l_profileValue = 'N') THEN

                l_errorMsg := l_errorMsg||
					add_message('ERR','PQH','PQH_SS_INTRVN_ACTN_NTF_ERR',p_calledFrom,p_addToPub);
              ELSE
                  -- check if the login user is initiator or approver
                if(lb_istxnowner) then
                 l_warningMsg := l_warningMsg||
				 add_message('WRN','PQH','PQH_SS_INTRVN_ACTN_NTF_WRN',p_calledFrom,p_addToPub);
				 else
				  -- check the profile if the system is configured for approvers editing
                  --IF ( nvl(fnd_profile.value('PQH_ALLOW_APPROVER_TO_EDIT_TXN'),'N') = 'Y' AND l_editAllowed='Y') THEN
                    IF ( nvl(fnd_profile.value('PQH_ALLOW_APPROVER_TO_EDIT_TXN'),'N') = 'Y' ) THEN
				     l_warningMsg := l_warningMsg||
  				    add_message('WRN','PER','HR_INTRVN_ACTN_NTF_WRN_AE',p_calledFrom,p_addToPub);
  				   null;
                  else
				    l_warningMsg := l_warningMsg||
  				    add_message('WRN','PER','HR_INTRVN_ACTN_NTF_WRN_ANE',p_calledFrom,p_addToPub);
  				   null;
                  end if;-- edit profile check.
   	        end if;
              END IF;
            END IF;
	      --
         END IF;
         --
         IF ( l_futureChange = 'Y' ) THEN
                l_profileValue  := NVL(fnd_profile.value('PQH_DT_RULE_FUTUR_CHANGE_FOUND'),'ERROR');
                if (l_profileValue = 'APPROVE_ONLY' AND NVL(l_slParmFound,'X') <> 'Y' ) THEN
                   -- if it's final validation and intervening changes are found, then the txn will
                   -- not be routed to HR Rep, intead Transaction error notification will be sent
                   -- When that happens no need to show the warning "Future change exist, txn will
                   -- be routed to HR Rep".
                   IF ( p_calledFrom = 'FINAL_VALIDATION' AND l_interAction in ('YC','Y')) THEN
 	               p_hasErrors := 'Y';
                   ELSIF (NOT isHrRepNtf(p_itemType, p_itemKey)) THEN
                      p_sendToHr   := 'Y';
                      if(lb_istxnowner) then
                       l_warningMsg := l_warningMsg||
				  add_message('WRN','PQH','PQH_SS_FUTURE_CHNG_EXIST_WRN',p_calledFrom,p_addToPub);
		      else
		        l_warningMsg := l_warningMsg||
				   add_message('WRN','PER','HR_FUTURE_CHNG_EXIST_WRN_APR',p_calledFrom,p_addToPub);
		      end if;
                   END IF;
                ELSE
 	           p_hasErrors := 'Y';
                   if(lb_istxnowner) then
                    l_errorMsg := l_errorMsg||
					add_message('ERR','PQH','PQH_SS_FUTURE_CHNG_EXIST_ERR',p_calledFrom,p_addToPub);
                   else
         	    l_errorMsg := l_errorMsg||
 					 add_message('ERR','PER','HR_FUTURE_CHNG_EXIST_ERR_APR',p_calledFrom,p_addToPub);
  		   end if;
                END IF;
          --
         END IF;
         -- Pending Transaction Found
         IF ( l_pendingTxn = 'Y' ) THEN
              l_profileValue  := NVL(fnd_profile.value('PQH_ALLOW_CONCURRENT_TXN'),'N');
              IF (l_profileValue = 'N') THEN
		            p_hasErrors     := 'Y';
                l_errorMsg := l_errorMsg||
					add_message('ERR','PQH','PQH_SS_PENDING_TXN_NTF_ERR',p_calledFrom,p_addToPub);
              ELSE
                l_warningMsg  := l_warningMsg ||
					add_message('WRN','PQH','PQH_SS_PENDING_TXN_NTF_WRN',p_calledFrom,p_addToPub);
              END IF;
         END IF;
         -- Person is Ineligible
         IF ( l_isPersonElig = 'N' ) THEN -- Person Ineligible
              l_profileValue := NVL(fnd_profile.value('PQH_ENABLE_INELIGIBLE_ACTIONS'),'N');
              IF (l_profileValue = 'N') THEN
		        p_hasErrors     := 'Y';
                l_errorMsg := l_errorMsg||
					add_message('ERR','PQH','PQH_SS_PERSON_INELIG_NTF_ERR',p_calledFrom,p_addToPub);
              ELSE
                l_warningMsg  := l_warningMsg ||
					add_message('WRN','PQH','PQH_SS_PERSON_INELIG_NTF_WRN',p_calledFrom,p_addToPub);
              END IF;
         END IF;
         --
         -- Concatinate Errors first and then Warnings
         -- They are kept in separate variable, for future use.
         l_errorWarnings := l_errorWarnings||l_errorMsg||l_warningMsg;

            --No formatting if called from final validation
            IF (l_errorWarnings IS NOT NULL AND NVL(p_calledFrom,'X') <> 'FINAL_VALIDATION') THEN
               l_errorWarnings :=  '<TABLE border=0> '||l_errorWarnings||'</TABLE>';
            END IF;

         ELSE
          l_errorWarnings := NULL;
        END IF;
	IF (p_addToPub = 'YES' AND l_errorWarnings is NOT NULL AND length(l_errorWarnings) >0) THEN
            p_hasErrors := 'Y';
        END IF;
        IF (p_addToPub = 'YES') THEN
            hr_multi_message.disable_message_list;
        END IF;
        RETURN l_errorWarnings;
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.get_errors_and_warnings : ' || sqlerrm);
           raise;
  --
END  get_errors_and_warnings;

--
--
PROCEDURE validation_on_final_approval (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 )  IS
--
l_errorWarnings   VARCHAR2(20000);
l_hasErrors	  VARCHAR2(5);
l_sendToHr 	  VARCHAR2(5);
l_txnId           NUMBER;
BEGIN
--
/*
 * 1. Get another flag which tells whethar intervening action has taken place
 * 2. Based on the flag see if the error flag is not set (no change if set)
 * 3. Sent out a different result if InterveningFlag=Y and ErrorFlag = N
 */
     l_errorWarnings :=
	     get_errors_and_warnings (
			p_itemType  => itemType
		       ,p_itemKey   => itemKey
                       ,p_calledFrom=> 'FINAL_VALIDATION'
		       ,p_hasErrors => l_hasErrors
		       ,p_sendToHr  => l_sendToHr );
     --
     IF ( l_errorWarnings IS NULL OR l_hasErrors <> 'Y') THEN -- If no messages or only warnings
        result := 'COMPLETE:SUCCESS';
     ELSE  -- if errors are found

     -- Bug 3035702: Allow starting new transaction if existing transaction is in error
     -- Set transaction status to 'E - Error' so that it does not block any other transaction
     -- and can be picked up for cleanup.
        hr_transaction_api.update_transaction(
               p_transaction_id    => get_transaction_id(itemType,itemKey),
               p_status            => 'E');

-- Fix for bug 8334527 :

    wf_engine.setitemattrtext
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname    => 'TRAN_SUBMIT'
      ,avalue   => 'E');

        result := 'COMPLETE:FAILURE';
        wf_engine.SetItemAttrText(
                 itemtype => itemType
               , itemkey  => itemKey
               , aname    => 'ERROR_MESSAGE'  -- Bug 2962967: changed from ERROR_MESSAGE_TEXT
               , avalue   => l_errorWarnings );
     END IF;
     --
     -- Set send to HR rep attribute
     wf_engine.SetItemAttrText(
                 itemtype => itemType
               , itemkey  => itemKey
               , aname    => 'SEND_TO_HR_REP'
               , avalue   => l_sendToHr );
--
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.validation_on_final_approval : ' || sqlerrm);
           Wf_Core.Context(g_package, 'validation_on_final_approval', itemType, itemKey);
           raise;
  --
END validation_on_final_approval;
--
--
PROCEDURE check_for_warning_error (
      document_id   in     varchar2,
      display_type  in     varchar2,
      document      in out nocopy varchar2,
      document_type in out nocopy varchar2) IS
--
l_itemType        VARCHAR2(30);
l_itemKey         VARCHAR2(30);
--
l_errorWarnings   VARCHAR2(20000);
l_hasErrors	  VARCHAR2(5);
l_sendToHr 	  VARCHAR2(5);
BEGIN
--
     -- No need to check for errors if notification is closed.
     if ( is_notification_closed(document_id) = 'Y') then
        return;
     end if;
     --
     document_type  := wf_notification.doc_html;

     -- Document will only have the notification id
     -- fetch the wf itemType and key from notification
     get_item_type_and_key (
                p_ntfId    => document_id
               ,p_itemType => l_itemType
               ,p_itemKey  => l_itemKey );
     --
     l_errorWarnings :=
	     get_errors_and_warnings (
			p_itemType  => l_itemType
		       ,p_itemKey   => l_itemKey
		       ,p_hasErrors => l_hasErrors
		       ,p_sendToHr  => l_sendToHr );
     --
     document   := l_errorWarnings;
     --
EXCEPTION
  WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.check_for_warning_error : ' || sqlerrm);
           document  := '<a class=OraErrorText>Exception in  '||g_package||'.check_for_warning_error : '||
                sqlerrm||'</a>';
--
END check_for_warning_error ;
--
--
FUNCTION is_notification_closed (
      p_ntfId        IN VARCHAR2 ) RETURN VARCHAR2 IS
--
l_isClosed  VARCHAR2(10) := 'N';
lv_ntf_role      WF_NOTIFICATIONS.RECIPIENT_ROLE%type;
lv_ntf_msg_typ   WF_NOTIFICATIONS.MESSAGE_TYPE%type;
lv_ntf_msg_name  WF_NOTIFICATIONS.MESSAGE_NAME%type;
lv_ntf_prior     WF_NOTIFICATIONS.PRIORITY%type;
lv_ntf_due       WF_NOTIFICATIONS.DUE_DATE%type;
lv_ntf_status    WF_NOTIFICATIONS.STATUS%type;
--
BEGIN
   --
   -- Get notification recipient and status
  Wf_Notification.GetInfo(p_ntfId, lv_ntf_role, lv_ntf_msg_typ, lv_ntf_msg_name, lv_ntf_prior, lv_ntf_due, lv_ntf_status);
  if (lv_ntf_status <> 'OPEN') then
   l_isClosed := 'Y';
  else
   l_isClosed := 'N';
  end if;

  return  l_isClosed;
--
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.is_notification_closed : ' || sqlerrm);
           raise;
  --
END is_notification_closed;
--

FUNCTION complete_custom_rfc (
      p_ntfId  IN VARCHAR2 ) RETURN VARCHAR2 IS
--
l_isCustomRFC   VARCHAR2(5);
l_itemType      VARCHAR2(30);
l_itemKey       VARCHAR2(240);
l_activityId    NUMBER;
BEGIN
   get_item_type_and_key (
                p_ntfId    => p_ntfId
               ,p_itemType => l_itemType
               ,p_itemKey  => l_itemKey );

   l_isCustomRFC   :=
          wf_engine.GetItemAttrText(
                itemtype    => l_itemType
               ,itemkey     => l_itemKey
               ,aname       => 'HR_CUSTOM_RETURN_FOR_CORR');

   IF (l_isCustomRFC = 'Y' ) THEN
       l_activityId      :=
             get_notified_activity(
                p_itemType  => l_itemType
               ,p_itemKey   => l_itemKey
               ,p_ntfId     => p_ntfId   );

       complete_wf_activity (
          	p_itemType    => l_itemtype,
           	p_itemKey     => l_itemkey,
            p_activity    => l_activityId,
            p_otherAct    => 'THIS',
           	p_resultCode  => 'RETURNEDFORCORRECTION' ) ;
   END IF;

   RETURN l_isCustomRFC;
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.complete_custom_rfc : ' || sqlerrm);
           raise;
  --
END complete_custom_rfc;
--
--
procedure delete_txn_notification(
        p_itemType      IN VARCHAR2
       ,p_itemKey       IN VARCHAR2
       ,p_transactionId IN VARCHAR2
       ) is
l_activity_id number;
l_notificationId number;
begin
  --
  l_notificationId  := get_notification_id (
        p_itemType      => p_itemType
       ,p_itemKey       => p_itemKey
       );
  --
  if l_notificationId is not null then
    l_activity_id := get_notified_activity (
        p_itemType      => p_itemType
       ,p_itemKey       => p_itemKey
       ,p_ntfId         => l_notificationId
       );
  --
  complete_wf_activity (
        p_itemType    => p_itemType,
        p_itemKey     => p_itemKey,
        p_activity    => l_activity_id,
        p_otherAct    => 'THIS',
        p_resultCode  => 'DEL' );
  elsif p_transactionId is not null then
    hr_transaction_api.rollback_transaction(p_transactionId);
  end if;
  --
/*
  exception
    when others then
     hr_transaction_api.rollback_transaction
                 (p_transaction_id => p_transactionid);
*/
end;
--
PROCEDURE set_hr_rep_role (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 )  IS

l_roleType    PQH_ROLES.role_type_cd%TYPE   := 'HR_REP';
l_PersonId    NUMBER(15);
l_bgId        NUMBER(15);
l_flag        VARCHAR2(1);
l_roleId      NUMBER(15);
l_roleName    PQH_ROLES.role_name%TYPE;

 CURSOR cur_wfrole  (p_role_id NUMBER) IS
 SELECT name
 FROM   wf_roles
 WHERE  orig_system    = 'PQH_ROLE'
 AND    orig_system_id = p_role_id ;

BEGIN

    l_personId     := wf_engine.GetItemAttrText(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'CURRENT_PERSON_ID');

    l_bgId         := PQH_SS_UTILITY.get_business_group_id ( l_PersonId, sysdate);

    PQH_SS_UTILITY.get_Role_Info (
        p_roleTypeCd       => l_roleType
       ,p_businessGroupId  => l_bgId
       ,p_globalRoleFlag   => l_flag
       ,p_roleName         => l_roleName
       ,p_roleId           => l_roleId  );

/*    if l_roleName is null then
       Wf_Core.Token('TYPE', itemtype);
       Wf_Core.Token('ACTID', to_char(actid));
       Wf_Core.Raise('WFENG_NOTIFICATION_PERFORMER');
    end if;
*/
    IF ( l_roleId IS NULL ) THEN
      --
      result := 'COMPLETE:FAILURE';
      --
    ELSE  -- Role id is not null
      --
      IF ( cur_wfrole%ISOPEN ) THEN
          CLOSE cur_wfrole;
      END IF;
      --
      OPEN  cur_wfrole (l_roleId) ;
      FETCH cur_wfrole INTO l_roleName ;
      CLOSE cur_wfrole;
      --
      IF ( l_roleName IS NULL ) THEN
         --
         result := 'COMPLETE:FAILURE';
         --
      ELSE
         --
         wf_engine.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'HR_REP_ROLE',
              avalue   => l_roleName);
        --
        result := 'COMPLETE:SUCCESS';
        --
      END IF;
      --
   END IF;
   --
   IF ( result = 'COMPLETE:FAILURE') THEN
     --
     -- Bug 3035702: Allow starting new transaction if existing transaction is in error
     -- Set transaction status to 'E - Error' so that it does not block any other transaction
     -- and can be picked up for cleanup.
     hr_transaction_api.update_transaction(
               p_transaction_id    => get_transaction_id(itemType,itemKey),
               p_status            => 'E');
  END IF;
  --
  EXCEPTION
      WHEN OTHERS THEN
           hr_utility.trace(' exception in  '||g_package||'.set_hr_rep_role : ' || sqlerrm);
           Wf_Core.Context(g_package, 'set_hr_rep_role', itemType, itemKey);
           raise;

END set_hr_rep_role;

procedure approval_block(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2)
is
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- Set the Approval process version to distinguish it
  -- it from old approval process.
  wf_engine.SetItemAttrText(
         itemtype => itemType
       , itemkey  => itemKey
       , aname    => 'HR_APPROVAL_PRC_VERSION'
       , avalue   => 'V5' );
               --
  resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
exception
  when others then
           hr_utility.trace(' exception in  '||g_package||'.approval_block : ' || sqlerrm);
           Wf_Core.Context(g_package, 'approval_block', itemType, itemKey);
           raise;
end approval_block;
--


/* ============== APPROVAL HISTORY ==========================
 * Procedure to build the notification history, that is added
 * to the bottom of approval notifications. It also considers
 * RFC notifications and includes the record in building the
 * Workflow History.
 * This procedure internally uses two procedures copied from
 * WF_notifications package with some modifications to cater
 * to our specific need
 */
PROCEDURE approval_history (
      document_id   in     varchar2,
      display_type  in     varchar2,
      document      in out nocopy varchar2,
      document_type in out nocopy varchar2) IS

--
-- Wf_Ntf_History
--   Construct a history table for a notification activity.
-- NOTE
--   Consist of three sections:
--   1. Current Notification
--   2. Past Notifications in the history table
--   3. The owner role as the submitter and begin date for such item
--


l_x  varchar2(32000);
type tdType is table of varchar2(4005) index by binary_integer;

table_width        varchar2(8)  := '100%';
table_border       varchar2(2)  := '0';
table_cellpadding  varchar2(2)  := '3';
table_cellspacing  varchar2(2)  := '1';
table_bgcolor      varchar2(7)  := 'white';
th_bgcolor         varchar2(7)  := '#cccc99';
th_fontcolor       varchar2(7)  := '#336699';
th_fontface        varchar2(80) := 'Arial, Helvetica, Geneva, sans-serif';
th_fontsize        varchar2(2)  := '2';
td_bgcolor         varchar2(7)  := '#f7f7e7';
td_fontcolor       varchar2(7)  := 'black';
td_fontface        varchar2(80) := 'Arial, Helvetica, Geneva, sans-serif';
td_fontsize        varchar2(2)  := '2';



procedure NTF_Table(cells in tdType,
                    col   in pls_integer,
                    type  in varchar2,  -- 'V'ertical or 'H'orizontal
                    rs    in out nocopy varchar2)
is
  i pls_integer;
  colon pls_integer;
  modv pls_integer;
  alignv   varchar2(1);
  l_align  varchar2(8);
  l_width  varchar2(3);
  l_text   varchar2(4000);
  l_type   varchar2(1);
  l_dir    varchar2(1);
  l_dirAttr varchar2(10);

  -- Define a local set and initialize with the default
  l_table_width  varchar2(8) := table_width;
  l_table_border varchar2(2) := table_border;
  l_table_cellpadding varchar2(2) := table_cellpadding;
  l_table_cellspacing varchar2(2) := table_cellspacing;
  l_table_bgcolor varchar2(7) := table_bgcolor;
  l_th_bgcolor varchar2(7) := th_bgcolor;
  l_th_fontcolor varchar2(7) := th_fontcolor;
  l_th_fontface varchar2(80) := th_fontface;
  l_th_fontsize varchar2(2) := th_fontsize;
  l_td_bgcolor varchar2(7) := td_bgcolor;
  l_td_fontcolor varchar2(7) := td_fontcolor;
  l_td_fontface varchar2(80) := td_fontface;
  l_td_fontsize varchar2(2) := td_fontsize;

begin
  if length(type) > 1 then
     l_type := substrb(type, 1, 1);
     l_dir := substrb(type,2, 1);
  else
     l_type := type;
     l_dir := 'L';
  end if;

  if l_dir = 'L' then
     l_dirAttr := NULL;
  else
     l_dirAttr := 'dir="RTL"';
  end if;

  if (l_type = 'N') then
     -- Notification format. Alter the default colors.
     l_table_bgcolor := '#FFFFFF';
     l_th_bgcolor := '#FFFFFF';
     l_th_fontcolor := '#000000';
     l_td_bgcolor := '#FFFFFF';
     l_td_fontcolor := '#000000';
     l_table_cellpadding := '1';
     l_table_cellspacing := '1';
  end if;

  if (cells.COUNT = 0) then
    rs := null;
    return;
  end if;
  rs := '<table width=100% border=0 cellpadding=0 cellspacing=0 '||l_dirAttr||
        '><tr><td>';
  rs := rs||wf_core.newline||'<table sumarry="" width='||l_table_width||
            ' border='||l_table_border||
            ' cellpadding='||l_table_cellpadding||
            ' cellspacing='||l_table_cellspacing||
            ' bgcolor='||l_table_bgcolor||' '||l_dirAttr||'>';

-- ### implement as generic log in the future
--  if (wf_notification.debug) then
--    dbms_output.put_line(to_char(cells.LAST));
--  end if;

  for i in 1..cells.LAST loop
--    if (wf_notification.debug) then
--      dbms_output.put_line(substrb('('||to_char(i)||')='||cells(i),1,254));
--    end if;
    modv := mod(i, col);
    if (modv = 1) then
      rs := rs||wf_core.newline||'<tr>';
    end if;

    alignv := substrb(cells(i), 1, 1);
    if (alignv = 'R') then
      l_align := 'RIGHT';
    elsif (alignv = 'L') then
      l_align := 'LEFT';
    elsif (alignv = 'S') then
      if (l_dir = 'L') then
         l_align := 'LEFT';
      else
         l_align := 'RIGHT';
      end if;
    elsif (alignv = 'E') then
      if (l_dir = 'L') then
         l_align := 'RIGHT';
      else
         l_align := 'LEFT';
      end if;
    else
      l_align := 'CENTER';
    end if;

--    if (wf_notification.debug) then
--      dbms_output.put_line('modv = '||to_char(modv));
--    end if;

    colon := instrb(cells(i),':');
    l_width := substrb(cells(i), 2, colon-2);
    l_text  := substrb(cells(i), colon+1);   -- what is after the colon

    if ((l_type = 'V' and modv = 1) or (l_type = 'N' and modv = 1)
        or  (l_type = 'H' and i <= col)) then
      if (l_type = 'N') then
         rs := rs||wf_core.newline||'<td';
      else
         -- this is a header
         rs := rs||wf_core.newline||'<th';
      end if;
      if (l_type = 'V') then
         rs := rs||' scope=row';
      else
         rs := rs||' scope=col';
      end if;

      if (l_width is not null) then
        rs := rs||' width='||l_width;
      end if;
      rs := rs||' align='||l_align||' valign=baseline bgcolor='||
              l_th_bgcolor||'>';
      rs := rs||'<font color='||l_th_fontcolor||' face="'||l_th_fontface||'"'
              ||' size='||l_th_fontsize||'>';
      rs := rs||l_text||'</font>';
      if (l_type = 'N') then
        rs := rs||'</td>';
      else
        rs := rs||'</th>';
      end if;
    else
      -- this is regular data
      rs := rs||wf_core.newline||'<td';
      if (l_width is not null) then
        rs := rs||' width='||l_width;
      end if;
      rs := rs||' align='||l_align||' valign=baseline bgcolor='||
              l_td_bgcolor||'>';
      rs := rs||'<font color='||td_fontcolor||' face="'||l_td_fontface||'"'
              ||' size='||l_td_fontsize||'>';
      if (l_type = 'N') then
        rs := rs||'<b>'||l_text||'</b></font></td>';
      else
        rs := rs||l_text||'</font></td>';
      end if;
    end if;
    if (modv = 0) then
      rs := rs||wf_core.newline||'</tr>';
    end if;
  end loop;
  rs := rs||wf_core.newline||'</table>'||wf_core.newline||'</td></tr></table>';

exception
  when OTHERS then
    wf_core.context('Wf_Notification', 'NTF_Table',to_char(col),l_type);
    raise;
end NTF_Table;


function wf_ntf_history(nid      in number,
                        disptype in varchar2)
return varchar2
is
  -- current notification
  cursor hist0c(x_item_type varchar2, x_item_key varchar2, x_actid number) is
select * from (
  select IAS.NOTIFICATION_ID, IAS.ASSIGNED_USER,
         A.RESULT_TYPE, IAS.ACTIVITY_RESULT_CODE,
         IAS.BEGIN_DATE, IAS.EXECUTION_TIME
    from WF_ITEM_ACTIVITY_STATUSES IAS,
         WF_ACTIVITIES A,
         WF_PROCESS_ACTIVITIES PA,
         WF_ITEM_TYPES IT,
         WF_ITEMS I
   where IAS.ITEM_TYPE        = x_item_type
     and IAS.ITEM_KEY         = x_item_key
     and IAS.NOTIFICATION_ID  is not null
     and nvl(RESULT_TYPE,'*') NOT IN ( '*','HR_DONE')
     and IAS.ITEM_TYPE        = I.ITEM_TYPE
     and IAS.ITEM_KEY         = I.ITEM_KEY
     and I.BEGIN_DATE between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
     and I.ITEM_TYPE          = IT.NAME
     and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
     and PA.ACTIVITY_NAME     = A.NAME
     and PA.ACTIVITY_ITEM_TYPE= A.ITEM_TYPE
     and (IAS.ACTIVITY_RESULT_CODE is null or IAS.ACTIVITY_RESULT_CODE not in ('SFL','#NULL'))
UNION
  select IAS.NOTIFICATION_ID, IAS.ASSIGNED_USER,
         A.RESULT_TYPE, IAS.ACTIVITY_RESULT_CODE,
         IAS.BEGIN_DATE, IAS.EXECUTION_TIME
    from WF_ITEM_ACTIVITY_STATUSES_H IAS,
         WF_ACTIVITIES A,
         WF_PROCESS_ACTIVITIES PA,
         WF_ITEM_TYPES IT,
         WF_ITEMS I
   where IAS.ITEM_TYPE        = x_item_type
     and IAS.ITEM_KEY         = x_item_key
     and IAS.NOTIFICATION_ID  is not null
     and (IAS.ACTIVITY_RESULT_CODE is null or IAS.ACTIVITY_RESULT_CODE not in ('SFL','#NULL'))
     and nvl(RESULT_TYPE,'*') NOT IN ( '*','HR_DONE')
     and IAS.ITEM_TYPE        = I.ITEM_TYPE
     and IAS.ITEM_KEY         = I.ITEM_KEY
     and I.BEGIN_DATE between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
     and I.ITEM_TYPE          = IT.NAME
     and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
     and PA.ACTIVITY_NAME     = A.NAME
     and PA.ACTIVITY_ITEM_TYPE= A.ITEM_TYPE
)
  order by BEGIN_DATE desc , EXECUTION_TIME desc;

  l_itype varchar2(30);
  l_ikey  varchar2(240);
  l_actid number;
  l_result_type varchar2(30);
  l_result_code varchar2(30);
  l_action varchar2(80);
  l_owner_role  varchar2(320);
  l_owner       varchar2(320);
  l_begin_date  date;
  i pls_integer;
  j pls_integer;
  role_info_tbl wf_directory.wf_local_roles_tbl_type;

  l_delim     varchar2(1) := ':';
  cells       tdType;
  result      varchar2(32000) := '';
begin
  begin
    select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
      into l_itype, l_ikey, l_actid
      from WF_ITEM_ACTIVITY_STATUSES
     where notification_id = nid;
  exception
    when NO_DATA_FOUND then
      begin
        select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
          into l_itype, l_ikey, l_actid
          from WF_ITEM_ACTIVITY_STATUSES_H
         where notification_id = nid;
      exception
        when NO_DATA_FOUND then
          null;  -- raise a notification not exist message
      end;
  end;

  j := 1;
  -- title
  cells(j) := wf_core.translate('SEQUENCE');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L10%:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('WHO');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('ACTION');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('DATE');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:'||cells(j);
  end if;
  j := j+1;
  cells(j) := wf_core.translate('NOTE');
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:'||cells(j);
  end if;
  j := j+1;

  begin
    select OWNER_ROLE, BEGIN_DATE
      into l_owner_role, l_begin_date
      from WF_ITEMS
     where ITEM_TYPE = l_itype
       and ITEM_KEY = l_ikey;
  exception
    when OTHERS then
      raise;
  end;

  i := 0;
  for histr in hist0c(l_itype, l_ikey, l_actid) loop

   -- skip if first record was sfl and submitted
   if NOT ( histr.assigned_user = l_owner_role and NVL(histr.activity_result_code,'X') = 'APPROVED') then

    cells(j) := to_char(histr.notification_id);
    j := j+1;
    wf_directory.GetRoleInfo2(histr.assigned_user, role_info_tbl);
    if (disptype = wf_notification.doc_html) then
      cells(j) := 'L:'||role_info_tbl(1).display_name;
    else
      cells(j) := role_info_tbl(1).display_name;
    end if;
    j := j+1;
    if (l_result_type is null or l_result_code is null or
        histr.result_type <> l_result_type or
        histr.activity_result_code <> l_result_code) then
      l_result_type := histr.result_type;
      l_result_code := histr.activity_result_code;
      l_action := wf_core.activity_result(l_result_type, l_result_code);
    end if;
    if (disptype = wf_notification.doc_html) then
      if (l_action is null) then
        cells(j) := 'L:&nbsp;';
      else
        cells(j) := 'L:'||l_action;
      end if;
    else
      cells(j) := l_action;
    end if;
    j := j+1;
    if (disptype = wf_notification.doc_html) then
      cells(j) := 'L:'||to_char(histr.begin_date);
    else
      cells(j) := to_char(histr.begin_date);
    end if;
    j := j+1;
    begin
      cells(j) := Wf_Notification.GetAttrText(histr.notification_id,'WF_NOTE');
    exception
      when OTHERS then
        cells(j) := null;
        wf_core.clear;
    end;
    if (disptype = wf_notification.doc_html) then
      if (cells(j) is null) then
        cells(j) := 'L:&nbsp;';
      else
        cells(j) := 'L:'||cells(j);
      end if;
    end if;
    j := j+1;

    i := i+1;
  end if;
  end loop;

  -- submit row
  cells(j) := '0';
  j := j+1;
  wf_directory.GetRoleInfo2(l_owner_role, role_info_tbl);
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:'||role_info_tbl(1).display_name;
  else
    cells(j) := role_info_tbl(1).display_name;
  end if;
  j := j+1;
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:'||wf_core.translate('SUBMIT');
  else
    cells(j) := wf_core.translate('SUBMIT');
  end if;
  j := j+1;
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:'||to_char(l_begin_date);
  else
    cells(j) := to_char(l_begin_date);
  end if;
  j := j+1;
  if (disptype = wf_notification.doc_html) then
    cells(j) := 'L:&nbsp;';
  else
    cells(j) := null;
  end if;

-- ### implement as generic log in the future
--  if (wf_notification.debug) then
--    dbms_output.put_line('j = '||to_char(j));
--    dbms_output.put_line(substrb('last cell = '||cells(j),1,254));
--  end if;

  -- calculate the sequence
  -- Only after we know the number of rows, then we can put the squence
  -- number on for each row.
  for k in 0..i loop
    if (disptype = wf_notification.doc_html) then
      cells((k+1)*5+1) := 'C:'||to_char(i-k);
    else
      cells((k+1)*5+1) := to_char(i-k);
    end if;
  end loop;

  if (disptype = wf_notification.doc_html) then
    table_width := '100%';

    NTF_Table(
              cells  => cells,
              col    => 5,
              type   => 'H',
              rs     => result  );
  else
    for k in 1..cells.LAST loop
      if (mod(k, 5) <> 0) then
        result := result||cells(k)||' '||l_delim||' ';
      else
        result := result||cells(k)||wf_core.newline;
      end if;
    end loop;
  end if;

  return(result);
exception
  when OTHERS then
    wf_core.context('Wf_Notification', 'Wf_NTF_History', to_char(nid));
    raise;
end wf_ntf_history;


BEGIN
  --
  document_type  := wf_notification.doc_html;
  document       := wf_ntf_history(document_id, document_type);
  --
END approval_history;
--
--

PROCEDURE reset_process_section_attr (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
BEGIN
      wf_engine.SetItemAttrText(
            itemtype => itemType
          , itemkey  => itemKey
          , aname    => 'HR_PERINFO_PROCESS_SECTION'
          , avalue   => NULL );
END reset_process_section_attr ;
--
--
PROCEDURE set_image_source (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funcmode        IN     VARCHAR2,
      result          OUT NOCOPY    VARCHAR2 ) IS
--
l_viewImage    VARCHAR2(100);
l_rfcImage     VARCHAR2(100);
--
BEGIN
  --
  l_viewImage    :=  wf_engine.GetActivityAttrText(
                            itemtype    => itemType
                           ,itemkey     => itemKey
                           ,actid       => actId
                           ,aname       => 'VIEW_IMAGE_NAME' );
  if ( l_viewImage IS NULL ) then
       l_viewImage := 'previewscreen_enabled.gif';
  end if;
  --
  l_rfcImage     :=  wf_engine.GetActivityAttrText(
                            itemtype    => itemType
                           ,itemkey     => itemKey
                           ,actid       => actId
                           ,aname       => 'RFC_IMAGE_NAME' );
  --
  if ( l_rfcImage IS NULL ) then
       l_rfcImage := 'backarro.gif';
  end if;
  --
  --
  wf_engine.SetItemAttrText(
       itemtype => itemType
     , itemkey  => itemKey
     , aname    => 'IMG_VIEW_ACTION'
     , avalue   => g_OA_MEDIA||l_viewImage
  );
  --
  --
  wf_engine.SetItemAttrText(
       itemtype => itemType
     , itemkey  => itemKey
     , aname    => 'IMG_RFC_ACTION'
     , avalue   => g_OA_MEDIA||l_rfcImage
  );
  --
  result := 'COMPLETE:SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
     null;
END set_image_source;


FUNCTION set_developer_ntf_msg(
	p_itemType    IN VARCHAR2,
	p_itemKey     IN VARCHAR2) RETURN VARCHAR IS
l_ntfId     NUMBER;
l_ntf_identifier VARCHAR2(100) := 'HR_NTF_IDENTIFIER';
l_ntf_name VARCHAR2(100);
l_error_message VARCHAR2(2000);
l_sal_basis_change_token VARCHAR2(100);
l_current_person_display_name VARCHAR2(100);
l_process_display_name VARCHAR2(100);
l_note_from_requestor VARCHAR2(2000);
l_note_from_approver VARCHAR2(2000);
l_errors VARCHAR2(100);
l_ntf_err_text VARCHAR2(20000);
BEGIN
  l_ntfId := get_notification_id(p_itemType,p_itemKey);
  BEGIN
    l_ntf_name := WF_NOTIFICATION.getattrtext(l_ntfId,l_ntf_identifier);
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  -- For Commit system errors this item attribute gets populated
  BEGIN
    l_ntf_err_text := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
                                 aname    => 'ERROR_MESSAGE_TEXT');
    EXCEPTION
    WHEN OTHERS THEN
        NULL;
  END;
  l_errors := 'N';
  IF (l_ntf_err_text is not NULL)
  THEN
    l_errors := 'Y';
    hr_utility.set_message(800, 'HRSSA_TXN_ERROR_MSG');
    hr_utility.set_message_token('ERROR_MESSAGE', l_ntf_err_text);
    hr_multi_message.add( p_message_type => hr_multi_message.G_ERROR_MSG);
  END IF;
  IF (l_ntf_name = 'HR_EMBED_NTF_PAY_CONTACT_MSG')
  THEN
    l_sal_basis_change_token := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
                                 aname    => 'HR_SALARY_BASIS_CHANGE_TOKEN');
    l_current_person_display_name := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
                                 aname    => 'CURRENT_PERSON_DISPLAY_NAME');
    l_process_display_name := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
                                 aname    => 'PROCESS_DISPLAY_NAME');
    l_note_from_requestor := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
                                 aname    => 'APPROVAL_COMMENT_COPY');

    hr_utility.set_message(800, 'HRSSA_MID_PAY_PERIOD_MSG');
    hr_utility.set_message_token('SALARY_BASIS_CHANGE_TOKEN', l_sal_basis_change_token);
    hr_utility.set_message_token('CURRENT_PERSON_DISPLAY_NAME', l_current_person_display_name);
    hr_utility.set_message_token('PROCESS_DISPLAY_NAME',l_process_display_name);
    hr_multi_message.add( p_message_type => hr_multi_message.G_INFORMATION_MSG);

    hr_utility.set_message(800, 'HRSSA_NOTE_FROM_REQUESTOR');
    hr_utility.set_message_token('NOTE_FROM_REQUESTOR', l_note_from_requestor);
    hr_multi_message.add( p_message_type => hr_multi_message.G_INFORMATION_MSG);
    l_errors := 'Y';
  ELSIF (l_ntf_name = 'HR_EMBED_ON_APPR_NTFY_HR_REP')
  THEN
    hr_utility.set_message(800, 'HRSSA_INTRVN_ACTION_MSG');
    hr_multi_message.add( p_message_type => hr_multi_message.G_INFORMATION_MSG);
    hr_utility.set_message(800, 'HRSSA_CANCEL_ACTION_MSG');
    hr_multi_message.add( p_message_type => hr_multi_message.G_INFORMATION_MSG);
    l_errors := 'Y';
  ELSIF (l_ntf_name = 'HR_EMBED_V5_RFC_OTHER' or l_ntf_name = 'HR_EMBED_V5_RFC_INITIATOR')
  THEN
    l_note_from_approver := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
                                 aname    => 'NOTE_FROM_APPR');
    hr_utility.set_message(800, 'HRSSA_NOTE_FROM_APPR');
    hr_utility.set_message_token('NOTE_FROM_APPR', l_note_from_approver);
    hr_multi_message.add( p_message_type => hr_multi_message.G_INFORMATION_MSG);
    l_errors := 'Y';
  ELSIF (l_ntf_name = 'HR_EMBED_TXN_ERROR_MSG')
  THEN
    l_error_message := wf_engine.GetItemAttrText(
                                 itemtype => p_itemType,
                                 itemkey  => p_itemKey,
                                 aname    => 'ERROR_MESSAGE');
    hr_utility.set_message(800, 'HRSSA_TXN_ERROR_MSG');
    hr_utility.set_message_token('ERROR_MESSAGE', l_error_message);
    hr_multi_message.add( p_message_type => hr_multi_message.G_ERROR_MSG);
    hr_utility.set_message(800, 'HRSSA_CANCEL_ACTION_MSG');
    hr_multi_message.add( p_message_type => hr_multi_message.G_INFORMATION_MSG);
    l_errors := 'Y';
  END IF;

  hr_approval_ss.checktransactionstate(wf_engine.getitemattrnumber
                                            (itemtype => p_itemType
                                            ,itemkey  => p_itemKey
                                          ,aname    => 'TRANSACTION_ID'));

  if(hr_utility.check_warning) Then
   l_errors := 'Y';
   hr_utility.clear_warning;
  end if;

  RETURN l_errors;
END set_developer_ntf_msg;
END; -- Package Body PQH_SS_WORKFLOW;

/
