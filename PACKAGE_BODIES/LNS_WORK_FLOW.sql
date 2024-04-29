--------------------------------------------------------
--  DDL for Package Body LNS_WORK_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_WORK_FLOW" as
/* $Header: LNS_WORK_FLOW_B.pls 120.11.12010000.5 2009/10/09 01:20:16 mbolli ship $ */

 /*========================================================================
 | PUBLIC PROCEDURE SELECT_WF_PROCESS
 |
 | DESCRIPTION
 |      This process selects the process to run.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_PARAM1                    IN          Standard in parameter
 |      X_PARAM2                    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 |
 *=======================================================================*/


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_FUNDING_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;
    g_org_id                        number;



/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
   IF (p_msg_level >= G_MSG_LEVEL) then

       FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);

   END IF;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;


/*========================================================================
 | PRIVATE PROCEDURE PROCESS_LOAN_STATUS_CHANGE
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_loan_id       IN      Loan Id
 |      p_from_status   IN      Old loan status
 |      p_to_status     IN      New Loan Status
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 |
 *=======================================================================*/

PROCEDURE PROCESS_LOAN_STATUS_CHANGE( p_loan_id               IN  NUMBER
                                     ,p_from_status           IN  VARCHAR2
                                     ,p_to_status             IN  VARCHAR2) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_LOAN_STATUS_CHANGE';
   l_api_version       CONSTANT NUMBER := 1.0;
   l_event_name                 VARCHAR2(250);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   IF p_to_status = 'PENDING' then
         l_event_name := 'LOAN_APPROVAL_PENDING';
   ELSIF p_to_status = 'APPROVED' then
         l_event_name := 'LOAN_APPROVAL_APPROVED';
   ELSIF p_to_status = 'REJECTED' then
         l_event_name := 'LOAN_APPROVAL_REJECTED';
   ELSIF p_to_status = 'INCOMPLETE' then
         l_event_name := 'LOAN_APPROVAL_NEEDINFO';
   ELSIF p_to_status = 'DEFAULT' then
         l_event_name := 'LOAN_DEFAULT';
   ELSIF p_to_status = 'DELINQUENT' then
         l_event_name := 'LOAN_DELINQUENT';
   ELSIF p_to_status = 'PAIDOFF' then
         l_event_name := 'LOAN_PAIDOFF';
   ELSIF p_to_status = 'IN_FUNDING' then
         l_event_name := 'LOAN_FUNDING_PENDING';
   ELSIF p_from_status = 'IN_FUNDING'
         AND p_to_status = 'ACTIVE' then
         l_event_name := 'LOAN_FUNDING_SUCCESSFUL';
   ELSIF p_from_status = 'IN_FUNDING'
         AND p_to_status = 'FUNDING_ERROR' then
         l_event_name := 'LOAN_FUNDING_ERROR';
   ELSIF p_from_status in ('DEFAULT','DELINQUENT','PAIDOFF')
         AND p_to_status = 'ACTIVE' then
         l_event_name := 'LOAN_ACTIVE_AGAIN';
   ELSIF p_to_status = 'PENDING_CANCELLATION' then
         l_event_name := 'LOAN_DISB_CANCEL_PENDING';
   END IF;
   IF l_event_name is NOT NULL THEN
      raise_event(p_event_name => l_event_name
              ,p_loan_id    => p_loan_id
	      ,p_from_status=> p_from_status);
   END IF;
   /* Commenting out this code since this is going to be moved to approval.
   IF p_to_status = 'ACTIVE'
   AND p_from_status NOT IN ('DEFAULT','DELINQUENT','PAIDOFF')
   THEN
     LNS_REP_UTILS.store_loan_agreement(p_loan_id => p_loan_id);
   END IF;
   */

   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      RAISE;
END PROCESS_LOAN_STATUS_CHANGE;
PROCEDURE PROCESS_STATUS_CHANGE( p_loan_id               IN  NUMBER
                                ,p_column_name           IN  VARCHAR2
                                ,p_from_status           IN  VARCHAR2
                                ,p_to_status             IN  VARCHAR2) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_STATUS_CHANGE';
   l_api_version       CONSTANT NUMBER := 1.0;
   l_event_name                 VARCHAR2(250);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   IF p_column_name = 'LOAN_STATUS' then
       process_loan_status_change(p_loan_id     => p_loan_id
                                 ,p_from_status => p_from_status
				 ,p_to_status   => p_to_status);
   ELSIF p_column_name = 'SECONDARY_STATUS' then

       process_sec_status_change(p_loan_id     => p_loan_id
                                 ,p_from_status => p_from_status
				 ,p_to_status   => p_to_status);
   ELSE null;
   END IF;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      RAISE;
END PROCESS_STATUS_CHANGE;
PROCEDURE PROCESS_SEC_STATUS_CHANGE(  p_loan_id               IN  NUMBER
                                     ,p_from_status           IN  VARCHAR2
                                     ,p_to_status             IN  VARCHAR2) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name             CONSTANT VARCHAR2(30) := 'PROCESS_SEC_STATUS_CHANGE';
   l_api_version          CONSTANT NUMBER := 1.0;
   l_event_name           VARCHAR2(250);
   l_open_to_term_flag    lns_loan_headers_all.open_to_term_flag%TYPE;
   l_open_to_term_event   lns_loan_headers_all.open_to_term_event%TYPE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
   CURSOR csr_loan_details IS
   SELECT open_to_term_flag
         ,open_to_term_event
   FROM   lns_loan_headers_all
   WHERE  loan_id = p_loan_id;

BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   OPEN  csr_loan_details;
   FETCH csr_loan_details
   INTO  l_open_to_term_flag
        ,l_open_to_term_event;
   CLOSE csr_loan_details;
   IF p_to_status = 'PENDING_CANCELLATION' then
         l_event_name := 'LOAN_DISB_CANCEL_PENDING';
   ELSIF p_to_status IN ('ALL_DISB_CANCELLED', 'REMAINING_DISB_CANCELLED') then
         l_event_name := 'LOAN_DISB_CANCEL_APPROVED';
   ELSIF p_to_status = 'MORE_INFO_REQUESTED'
         AND p_from_status = 'PENDING_CANCELLATION' then
         l_event_name := 'LOAN_DISB_CANCEL_INCOMPLETE';
   ELSIF p_to_status NOT IN ('ALL_DISB_CANCELLED', 'REMAINING_DISB_CANCELLED')
         AND p_from_status = 'PENDING_CANCELLATION' then
         l_event_name := 'LOAN_DISB_CANCEL_REJECTED';
   ELSIF p_to_status = 'FULLY_FUNDED'
         AND l_open_to_term_flag = 'Y'
	 AND l_open_to_term_event <> 'AUTO_FINAL_DISBURSEMENT' then
         l_event_name := 'LOAN_TERM_CONVERT_REQUIRED';
   ELSIF p_to_status = 'PENDING_CONVERSION' then
         l_event_name := 'LOAN_TERM_CONVERT_PENDING';
   ELSIF p_to_status = 'CONVERTED_TO_TERM_PHASE'
         AND l_open_to_term_flag = 'Y'
	 AND l_open_to_term_event = 'AUTO_FINAL_DISBURSEMENT' then
         l_event_name := 'LOAN_TERM_AUTOCONVERT';
   ELSIF p_to_status = 'CONVERTED_TO_TERM_PHASE' then
         l_event_name := 'LOAN_TERM_CONVERT_APPROVED';
   ELSIF p_to_status = 'MORE_INFO_REQUESTED'
         AND p_from_status = 'PENDING_CONVERSION' then
         l_event_name := 'LOAN_TERM_CONVERT_INCOMPLETE';
   ELSIF p_to_status <> 'CONVERTED_TO_TERM_PHASE'
         AND p_from_status = 'PENDING_CONVERSION' then
         l_event_name := 'LOAN_TERM_CONVERT_REJECTED';
   ELSIF p_to_status = 'IN_FUNDING' then
         l_event_name := 'LOAN_FUNDING_PENDING';
   ELSIF p_to_status IN ('PARTIALLY_FUNDED','FULLY_FUNDED')  then
         l_event_name := 'LOAN_FUNDING_SUCCESSFUL';
   ELSIF p_to_status = 'FUNDING_ERROR' then
         l_event_name := 'LOAN_FUNDING_ERROR';
   END IF;
   IF l_event_name is NOT NULL THEN
      raise_event(p_event_name => l_event_name
              ,p_loan_id    => p_loan_id
	      ,p_from_status=> p_from_status);
   END IF;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      RAISE;
END PROCESS_SEC_STATUS_CHANGE;
/*========================================================================
 | PRIVATE PROCEDURE RAISE_EVENT
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_loan_id       IN      Loan Id
 |      p_loan_status   IN      Loan Status
 |      x_error_code    OUT     Error Code
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 |
 *=======================================================================*/

PROCEDURE RAISE_EVENT (    p_loan_id               IN  NUMBER
                          ,p_event_name            IN  VARCHAR2
			  ,p_from_status           IN  VARCHAR2 DEFAULT NULL) IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name                      CONSTANT VARCHAR2(30) := 'RAISE_EVENT';
   l_api_version                   CONSTANT NUMBER := 1.0;
   l_loan_number                   lns_loan_headers_all.loan_number%TYPE;
   l_requested_amount              lns_loan_headers_all.requested_amount%TYPE;
   l_loan_description              lns_loan_headers_all.loan_description%TYPE;
   l_loan_class_code               lns_loan_headers_all.loan_class_code%TYPE;
   l_loan_type                     lns_loan_types.loan_type_name%TYPE;
   l_loan_type_id                  lns_loan_types.loan_type_id%TYPE;
   l_current_user_id               lns_loan_headers_all.created_by%TYPE;
   l_loan_formatted_amount	   VARCHAR2(50);
   l_loan_undisbursed_amount	   VARCHAR2(50);
   l_function_name          	   VARCHAR2(50);
   ItemType                        VARCHAR2(30) ;
   ItemKey                         NUMBER;
   l_list                          WF_PARAMETER_LIST_T;
   l_param                         WF_PARAMETER_T;
   l_wf_event_name                    VARCHAR2(240);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
   CURSOR csr_loan_event_details IS
   SELECT wf_business_event
         ,lh.loan_number
	 ,lh.requested_amount
	 ,lh.loan_description
         ,lh.loan_class_code
	 ,lh.loan_type_id
         ,lt.loan_type_name
         ,to_char(lh.requested_amount,
	          FND_CURRENCY.SAFE_GET_FORMAT_MASK(lh.LOAN_CURRENCY,50))
		    || ' ' || lh.loan_currency loan_formatted_amount
         ,to_char(nvl(lh.requested_amount,0)-nvl(lh.funded_amount,0),
	          FND_CURRENCY.SAFE_GET_FORMAT_MASK(lh.LOAN_CURRENCY,50))
		    || ' ' || lh.loan_currency loan_undisbursed_amount
         ,decode(lh.loan_class_code,'ERS','LNS_ERS_CONTEXT_HOMEPAGE_MENU',
	         'LNS_LOAN_CONTEXT_HOMEPAGE_MENU') function_name
	 ,lh.last_updated_by current_user_id
   FROM   lns_events le, lns_loan_headers_all_vl lh, lns_loan_types_vl lt
   WHERE  lh.loan_class_code = le.loan_class_code
   AND    le.enabled_flag = 'Y'
   AND    le.event_name = p_event_name
   AND    lt.loan_type_id = lh.loan_type_id
   AND    lh.loan_id = p_loan_id;
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   ItemType := 'LNSWF';

   SELECT lns_workflow_itemkey_s.nextval
   INTO   ItemKey
   FROM   dual;

   OPEN csr_loan_event_details;
   FETCH csr_loan_event_details
   INTO   l_wf_event_name
         ,l_loan_number
         ,l_requested_amount
         ,l_loan_description
         ,l_loan_class_code
         ,l_loan_type_id
         ,l_loan_type
	 ,l_loan_formatted_amount
	 ,l_loan_undisbursed_amount
	 ,l_function_name
	 ,l_current_user_id;
   IF csr_loan_event_details%NOTFOUND THEN
      return;
   END IF;
   CLOSE csr_loan_event_details;
   -- initialization of object variables
   l_list := WF_PARAMETER_LIST_T();

   wf_event.AddParameterToList(p_name          => 'LNS_LOAN_ID',
	                       p_value         => p_loan_id,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_LOAN_NUMBER',
                               p_value         => l_loan_number,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_LOAN_DESCRIPTION',
                               p_value         => l_loan_description,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_REQUESTED_AMOUNT',
                               p_value         => l_requested_amount,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_FORMATTED_AMOUNT',
                               p_value         => l_loan_formatted_amount,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_LOAN_UNDISBURSED_AMOUNT',
                               p_value         => l_loan_undisbursed_amount,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_WF_INIT_DATE',
                               p_value         => SYSDATE,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_OLD_LOAN_STATUS',
                               p_value         => p_from_status,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_LOAN_CLASS_CODE',
                               p_value         => l_loan_class_code,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_LOAN_TYPE_ID',
	                       p_value         => l_loan_type_id,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_CURRENT_USER_ID',
	                       p_value         => l_current_user_id,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_LOAN_TYPE',
                               p_value         => l_loan_type,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_EVENT_NAME',
                               p_value         => p_event_name,
			       p_parameterlist => l_list);
   wf_event.AddParameterToList(p_name          => 'LNS_ERS_FUNCTION_NAME',
                               p_value         => l_function_name,
			       p_parameterlist => l_list);
   wf_event.raise (p_event_name   =>  l_wf_event_name,
                  p_event_key    =>  itemkey,
	          p_parameters   =>  l_list);
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
   WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('LNSWF',l_wf_event_name, itemkey);
        RAISE;
END RAISE_EVENT;
/*========================================================================
 | PRIVATE PROCEDURE LOG_EVENT_HISTORY
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      itemtype        in      Item Type
 |      itemkey         in      Item Key
 |      actid           in      Action Id
 |      funcmode        in      Function Mode
 |      resultout       out     Result Out
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE LOG_EVENT_HISTORY(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 ) IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name        CONSTANT VARCHAR2(30) := 'LOG_EVENT_HISTORY';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_loan_id         LNS_LOAN_HEADERS_ALL.LOAN_ID%TYPE;
   l_event_action_id LNS_EVT_ACTION_HISTORY_H.EVENT_ACTION_ID%TYPE;
   l_ev_action_hist_id LNS_EVT_ACTION_HISTORY_H.EVENT_ACTION_HISTORY_ID%TYPE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   IF (funcmode <> wf_engine.eng_run) THEN
      resultout := wf_engine.eng_null;
      return;
   END IF;
   l_loan_id := wf_engine.GetItemAttrNumber
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_ID');
   l_event_action_id := wf_engine.GetItemAttrNumber
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_EVENT_ACTION_ID');
   LNS_EVT_ACTION_HISTORY_H_PKG.Insert_Row (
   X_EVENT_ACTION_HISTORY_ID => l_ev_action_hist_id
  ,P_EVENT_ACTION_ID => l_event_action_id
  ,P_LOAN_ID => l_loan_id
  ,P_WF_ITEMKEY => itemkey
  ,P_WF_ITEMTYPE => itemtype
  ,P_ACTIVITY_DATE => sysdate);
   LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      wf_core.context('LNSWF', 'LOG_EVENT_HISTORY', itemtype, itemkey,
                                                      to_char(actid), funcmode);      RAISE;
END LOG_EVENT_HISTORY;

/*========================================================================
 | PRIVATE FUNCTION has_user_org_access
 |
 | DESCRIPTION
 |      This procedure checks if a user has access to an org (OU)
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      l_user_id        in     Unique Identifier for the User
 |      l_org_id         in     the OU to check access for
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-Mar-2006           KARAMACH          Created
   --Modified the query with case when construct for loan_amount and loan_formatted_amount to fix bug5126957 --karamach
 |
 *=======================================================================*/
FUNCTION  has_user_org_access (l_user_id in  Number,
			       l_org_id in Number)
RETURN BOOLEAN IS

l_has_org_access BOOLEAN;
l_resp_id NUMBER;
l_appl_id NUMBER;
--Get all valid lns responsibilities for the user_id
CURSOR C_GET_USER_RESPS(p_user_id NUMBER,p_appl_id NUMBER) IS
SELECT usr_resp.responsibility_id
FROM fnd_user_resp_groups usr_resp
WHERE usr_resp.responsibility_application_id = p_appl_id
AND trunc(sysdate) between trunc(nvl(usr_resp.start_date, sysdate)) and trunc(nvl(usr_resp.end_date, sysdate))
-- AND usr_resp.start_date < sysdate AND nvl(usr_resp.end_date,sysdate-1) > sysdate  -- Bug#8247186
AND usr_resp.user_id = p_user_id;

BEGIN
      --if no access to org_id with any lns responsibility, return false
      l_has_org_access := FALSE;
      l_appl_id := 206;

      if (l_user_id is null OR l_org_id is null) then
	RETURN l_has_org_access;
      end if;
      -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'In has_user_org_acc, the l_user_id is '||l_user_id);
      -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'In has_user_org_acc, the l_appl_id is '||l_appl_id);
      OPEN c_get_user_resps(l_user_id,l_appl_id);
      <<USER_RESPS_LOOP>> LOOP
         FETCH c_get_user_resps
         INTO l_resp_id;
         EXIT USER_RESPS_LOOP WHEN c_get_user_resps%NOTFOUND;
	 --initialize the session context with the user and resp info
	 fnd_global.apps_initialize(l_user_id, l_resp_id, l_appl_id);
	 --begin R12 specific
	 MO_GLOBAL.INIT('LNS');
	 -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'In has_user_org_acc, the l_org_id is '||l_org_id);
	 if (mo_global.check_access(l_org_id) = 'Y') then
	 --end R12 specific
	 --begin 11i specific
      	 --if (fnd_profile.value('ORG_ID') = to_char(l_org_id)) then
	 --end 11i specific
          l_has_org_access := TRUE;
	  EXIT USER_RESPS_LOOP;
         end if;
      END LOOP USER_RESPS_LOOP;
      CLOSE c_get_user_resps;

      RETURN l_has_org_access;

END has_user_org_access;

/*========================================================================
 | PRIVATE PROCEDURE CREATE_NOTIFICATION_DETAILS
 |
 | DESCRIPTION
 |      This procedure gets approvers for a Loan
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      itemtype        in      Item Type
 |      itemkey         in      Item Key
 |      actid           in      Action Id
 |      funcmode        in      Function Mode
 |      resultout       out     Result Out
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 | 29-Mar-2006           KARAMACH          Modified the query for cursor csr_loan_details1 with case when construct for loan_amount and loan_formatted_amount to fix bug5126957
 |
 *=======================================================================*/
FUNCTION  CREATE_NOTIFICATION_DETAILS (   itemtype                in  varchar2,
                                itemkey                 in  varchar2,
                                p_event_name            in  varchar2,
                                p_loan_id               in  NUMBER,
                                p_loan_class_code       in  varchar2,
                                p_loan_type             in  varchar2,
				p_loan_type_id          in  number,
				p_current_user_id       in  number)
                                RETURN VARCHAR2 IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name                      CONSTANT VARCHAR2(30)
                                      := 'CREATE_NOTIFICATION_DETAILS';
   l_api_version                   CONSTANT NUMBER := 1.0;
   l_user_roles                     VARCHAR2(32000);
   l_user_name                    FND_USER.user_name%TYPE;
   l_role_name                     VARCHAR2(100);
   l_loan_number                  LNS_LOAN_HEADERS.LOAN_NUMBER%TYPE;
   l_primary_recipient_type    lns_event_actions.primary_recipient_type%TYPE;
   l_primary_recipient_name  lns_event_actions.primary_recipient_name%TYPE;
   l_priority_num                   lns_event_actions.priority_num%TYPE;
   l_active_for_num              lns_event_actions.active_for_num%TYPE;
   l_delivery_method             lns_event_actions.delivery_method%TYPE;
   l_loan_assigned_name      jtf_rs_resource_extns.source_name%TYPE;
   l_loan_assigned_user        fnd_user.user_name%TYPE;
   l_current_user                   fnd_user.user_name%TYPE;
   l_borrower_name              hz_parties.party_name%TYPE;
   l_loan_class                      lns_lookups.meaning%TYPE;
   l_loan_type                       lns_loan_types.loan_type_name%TYPE;
   l_loan_purpose                  lns_lookups.meaning%TYPE;
   l_loan_subtype                  lns_loan_headers_all.loan_subtype%TYPE;
   l_collateral_percent            VARCHAR2(10);
   l_loan_amount                   lns_pay_sum_v.total_principal_balance%TYPE;
   l_loan_formatted_amount   VARCHAR2(30);
   l_loan_start_date               lns_loan_headers_all.loan_start_date%TYPE;
   l_term                               VARCHAR2(15);
   l_loan_maturity_date         lns_loan_headers_all.loan_maturity_date%TYPE;
   l_interest_rate                   VARCHAR2(30);
   l_overdue_amount             VARCHAR2(30);
   l_overdue_num                  lns_pay_sum_overdue_v.number_overdue_bills%TYPE;
   l_event_action_id               LNS_EVENT_ACTIONS.EVENT_ACTION_ID%TYPE;
   l_org_id 		                   NUMBER;
   l_user_id 		           NUMBER;


/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
   CURSOR csr_notification_details IS
   SELECT primary_recipient_type
        , primary_recipient_name
	, priority_num
        , nvl(active_for_num,0)*24*60 -- This has to be converted into minutes
	, delivery_method
	, event_action_id
   FROM   lns_events le, lns_event_actions lea
   WHERE  le.event_name = p_event_name
   AND    le.enabled_flag = 'Y'
   AND    le.loan_class_code = p_loan_class_code
   AND    lea.event_id = le.event_id
   AND    lea.EVENT_ACTION_NAME = 'NOTIFICATION'
   AND    lea.enabled_flag = 'Y'
   AND    lea.loan_type_id = p_loan_type_id;
   CURSOR csr_current_user IS
   SELECT fndu.user_name
   FROM   fnd_user fndu
   WHERE  fndu.user_id = p_current_user_id;

   CURSOR csr_loan_role_users IS
   SELECT fndu.user_name
	  ,fndu.user_id
   FROM    jtf_rs_role_relations rel
          ,jtf_rs_roles_b rol
          ,jtf_rs_resource_extns res
          ,fnd_user fndu
   WHERE  rel.role_id = rol.role_id
   AND    rel.delete_flag <> 'Y'
   AND    SYSDATE BETWEEN NVL(rel.start_date_active,sysdate)
                  AND     NVL(rel.end_date_active,sysdate)
   AND    rol.role_type_code = 'LOANS'
   AND    rol.role_code = l_primary_recipient_name
   AND    rol.active_flag = 'Y'
   AND    rel.role_resource_id = res.resource_id
   AND    res.category = 'EMPLOYEE'
   AND    res.start_date_active <= SYSDATE
   AND    (res.end_date_active is null or res.end_date_active >= SYSDATE)
   AND    fndu.user_id = res.user_id;

   CURSOR csr_loan_details IS
   SELECT hp.party_name borrower_name
          ,fnd.user_name
          ,res.source_name
          ,llklc.meaning loan_class
          ,llklt.loan_type_name loan_type
	  ,llkst.meaning loan_subtype
          ,to_char(nvl(llh.collateral_percent,0)) || '%' collateral_percent
          ,llh.loan_start_date
          ,llh.loan_term || ' ' || llktt.meaning term
          ,llh.loan_maturity_date
          ,LNS_FINANCIALS.getActiveRate(llh.LOAN_ID) interest_rate
          ,llkp.meaning loan_purpose
	  ,llh.org_id
   FROM   lns_loan_headers_all_vl llh, hz_parties hp,
          jtf_rs_resource_extns res, fnd_user fnd,
          lns_payments_summary_v ps,
          lns_lookups llktt,
          lns_lookups llklc,
          lns_loan_types_vl llklt,
          lns_lookups llkp,
	  lns_lookups llkst
   WHERE  llh.primary_borrower_id = hp.party_id
   AND    llh.loan_assigned_to = res.resource_id
   AND    res.category = 'EMPLOYEE'
   AND    fnd.user_id = res.user_id
   AND    llktt.lookup_code = llh.loan_term_period
   AND    llktt.lookup_type = 'PERIOD'
   AND    llklc.lookup_code = llh.loan_class_code
   AND    llklc.lookup_type = 'LOAN_CLASS'
   AND    llklt.loan_type_id = llh.loan_type_id
   AND    llkp.lookup_code (+) = llh.loan_purpose_code
   AND    llkp.lookup_type (+) = 'LOAN_PURPOSE'
   AND    llkst.lookup_code (+) = llh.loan_subtype
   AND    llkst.lookup_type (+) = 'LOAN_SUBTYPE'
   AND    llh.loan_id = p_loan_id;

   --Modified the query with case when construct for loan_amount and loan_formatted_amount to fix bug5126957 --karamach
   CURSOR csr_loan_details1 IS
   SELECT
	(CASE WHEN llh.loan_status in ('INCOMPLETE','REJECTED','DELETED','PENDING','APPROVED','IN_FUNDING','FUNDING_ERROR','CANCELLED') OR llh.FUNDED_AMOUNT = 0 THEN llh.requested_amount
        ELSE ps.total_principal_balance END) loan_amount
	,to_char((CASE WHEN llh.loan_status in ('INCOMPLETE','REJECTED','DELETED','PENDING','APPROVED','IN_FUNDING','FUNDING_ERROR','CANCELLED') OR llh.FUNDED_AMOUNT = 0 THEN llh.requested_amount
        ELSE ps.total_principal_balance END),
                  FND_CURRENCY.SAFE_GET_FORMAT_MASK(llh.LOAN_CURRENCY,50))
                    || ' ' || llh.loan_currency loan_formatted_amount
   FROM   lns_loan_headers_all llh
         ,lns_pay_sum_v ps
   WHERE  llh.loan_id = p_loan_id
   AND    ps.loan_id  = llh.loan_id;

   CURSOR csr_loan_details2 IS
   SELECT to_char(ps.total_overdue,
                  FND_CURRENCY.SAFE_GET_FORMAT_MASK(llh.LOAN_CURRENCY,50))
                    || ' ' || llh.loan_currency overdue_amount
         ,ps.number_overdue_bills overdue_num
   FROM   lns_loan_headers_all llh
         ,lns_pay_sum_overdue_v ps
   WHERE  llh.loan_id = p_loan_id
   AND    ps.loan_id  = llh.loan_id;

BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   OPEN csr_notification_details;
   FETCH csr_notification_details
   INTO  l_primary_recipient_type
      ,  l_primary_recipient_name
      ,  l_priority_num
      ,  l_active_for_num
      ,  l_delivery_method
      ,  l_event_action_id;
   IF   csr_notification_details%NOTFOUND THEN
      RETURN 'N';
   END IF;

   CLOSE csr_notification_details;

   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_event_action_id is '||l_event_action_id);

   OPEN csr_loan_details;
   FETCH csr_loan_details
   INTO  l_borrower_name
      ,  l_loan_assigned_user
      ,  l_loan_assigned_name
      ,  l_loan_class
      ,  l_loan_type
      ,  l_loan_subtype
      ,  l_collateral_percent
      ,  l_loan_start_date
      ,  l_term
      ,  l_loan_maturity_date
      ,  l_interest_rate
      ,  l_loan_purpose
      ,  l_org_id;
   CLOSE csr_loan_details;
   OPEN csr_loan_details1;
   FETCH csr_loan_details1
   INTO  l_loan_amount
      ,  l_loan_formatted_amount;
   CLOSE csr_loan_details1;
   OPEN csr_loan_details2;
   FETCH csr_loan_details2
   INTO  l_overdue_amount
      ,  l_overdue_num;
   CLOSE csr_loan_details2;
   OPEN  csr_current_user;
   FETCH csr_current_user
   INTO l_current_user;
   CLOSE csr_current_user;

   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_current_user is '||l_current_user);

   l_loan_number := wf_engine.GetItemAttrText
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_NUMBER');

   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_primary_recipient_type is '||l_primary_recipient_type);

   IF l_primary_recipient_type = 'ROLE' THEN
      OPEN csr_loan_role_users;
      FETCH csr_loan_role_users
      INTO  l_user_name,l_user_id;
      IF csr_loan_role_users%NOTFOUND THEN
         LogMessage(FND_LOG.LEVEL_PROCEDURE, 'cursor csr_loan_role_users returns 0 rows');
         RETURN 'N';
      END IF;
      -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_user_name is '||l_user_name);
      -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_user_id is '||l_user_id);
      if (has_user_org_access(l_user_id,l_org_id)) then
      	l_user_roles := l_user_roles||','||l_user_name;
	-- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_user_roles is '||l_user_roles);
      end if;
      LOOP
         FETCH csr_loan_role_users
         INTO  l_user_name,l_user_id;
         EXIT  WHEN csr_loan_role_users%NOTFOUND;
         -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_user_name is '||l_user_name);
         -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'The l_user_id is '||l_user_id);
      	 if (has_user_org_access(l_user_id,l_org_id)) then
          l_user_roles := l_user_roles||','||l_user_name;
         end if;
      END LOOP;
      CLOSE csr_loan_role_users;
      IF substr(l_user_roles,1,1) = ','
      THEN
         l_user_roles := substr(l_user_roles, 2, (length(l_user_roles) - 1));
      END IF;

      LogMessage(FND_LOG.LEVEL_PROCEDURE, 'For the Role, l_user_roles is '||l_user_roles);

      if (nvl(length(l_user_roles),0) < 3) then
	RETURN 'N';
      end if;
      l_role_name := 'Loan Managers'|| '(' ||l_loan_number || '-' || ItemKey
                                    || ')';

     -- Bug#8709307 - Added Expiration Date to the new adhoc role
     wf_directory.CreateAdhocRole(
                                role_name => l_role_name,
                                role_display_name => l_role_name,
                                notification_preference => 'MAILHTM2',
				expiration_date => (sysdate+90)
                                        );
     wf_directory.AddUsersToAdhocRole(role_name => l_role_name,
                                                 role_users => l_user_roles);

     wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_PRIMARY_ROLE',
                              avalue   =>  l_role_name);

   ELSIF l_primary_recipient_type = 'INDIVIDUAL' AND l_primary_recipient_name =
   'LOAN_ASSIGNED_TO' THEN

     -- l_user_roles := l_loan_assigned_user;
     -- l_role_name :=l_loan_assigned_name || '(' ||l_loan_number || '-'|| ItemKey || ')'

     -- Bug#8709307 - Instead of creating Adhoc Role, directly sending notification
     --  to the user (FND_USER)
     l_role_name := l_loan_assigned_user;

      wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_PRIMARY_ROLE',
                              avalue   =>  l_role_name);

   END IF;

   -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'At last, l_user_roles is '||l_user_roles);
   -- LogMessage(FND_LOG.LEVEL_PROCEDURE, 'At last, l_role_name is '||l_role_name);

   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_BORROWER_NAME',
                              avalue   =>  l_borrower_name);

   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_PRIORITY',
                               avalue   => l_priority_num);
   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_EVENT_ACTION_ID',
                               avalue   => l_event_action_id);
   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_TIMEOUT',
                               avalue   => l_active_for_num);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_LOAN_ASSIGNED_USER',
                              avalue   =>  l_loan_assigned_user);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_LOAN_ASSIGNED_NAME',
                              avalue   =>  l_loan_assigned_name);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_CURRENT_USER',
                              avalue   =>  l_current_user);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_LOAN_CLASS',
                              avalue   =>  l_loan_class);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_LOAN_TYPE',
                              avalue   =>  l_loan_type);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_LOAN_SUBTYPE',
                              avalue   =>  l_loan_subtype);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_COLLATERAL_PERCENT',
                              avalue   =>  l_collateral_percent);
   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_LOAN_AMOUNT',
                               avalue   => l_loan_amount);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_FORMATTED_AMOUNT',
                              avalue   =>  l_loan_formatted_amount);
   wf_engine.SetItemAttrDate (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_LOAN_START_DATE',
                              avalue   =>  l_loan_start_date);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_TERM',
                              avalue   =>  l_term);
   wf_engine.SetItemAttrDate (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LNS_LOAN_MATURITY_DATE',
                              avalue   =>  l_loan_maturity_date);
   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_INTEREST_RATE',
                               avalue   => l_interest_rate);
   wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_OVERDUE_AMOUNT',
                               avalue   => l_overdue_amount);
   wf_engine.SetItemAttrNumber(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_OVERDUE_NUM',
                               avalue   => l_overdue_num);
   wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'LNS_LOAN_PURPOSE',
                               avalue   => l_loan_purpose);
   return 'Y';
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      RAISE;
END CREATE_NOTIFICATION_DETAILS;
/*========================================================================
 | PRIVATE PROCEDURE PROCESS_EVENT
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      itemtype        in      Item Type
 |      itemkey         in      Item Key
 |      actid           in      Action Id
 |      funcmode        in      Function Mode
 |      resultout       out     Result Out
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE PROCESS_EVENT(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 ) IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_EVENT';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_loan_id         LNS_LOAN_HEADERS_ALL.LOAN_ID%TYPE;
   l_loan_class_code LNS_LOAN_HEADERS_ALL.LOAN_CLASS_CODE%TYPE;
   l_loan_type       LNS_LOAN_TYPES.LOAN_TYPE_NAME%TYPE;
   l_loan_type_id    LNS_LOAN_TYPES.LOAN_TYPE_ID%TYPE;
   l_current_user_id LNS_LOAN_HEADERS_ALL.CREATED_BY%TYPE;
   l_event_name      LNS_EVENTS.EVENT_NAME%TYPE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   IF (funcmode <> wf_engine.eng_run) THEN
      resultout := wf_engine.eng_null;
      return;
   END IF;

   l_loan_id := wf_engine.GetItemAttrNumber
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_ID');
   l_loan_class_code := wf_engine.GetItemAttrText
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_CLASS_CODE');
   l_loan_type := wf_engine.GetItemAttrText
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_TYPE');
   l_loan_type_id := wf_engine.GetItemAttrNumber
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_TYPE_ID');
   l_current_user_id := wf_engine.GetItemAttrNumber
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_CURRENT_USER_ID');
   l_event_name := wf_engine.GetItemAttrText
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_EVENT_NAME');

   resultout := 'COMPLETE:' || create_notification_details(itemkey => itemkey
                                          ,itemtype => itemtype
                                   ,p_event_name      => l_event_name
                                   ,p_loan_id         => l_loan_id
                                   ,p_loan_class_code => l_loan_class_code
                                   ,p_loan_type       => l_loan_type
				   ,p_loan_type_id    => l_loan_type_id
				   ,p_current_user_id => l_current_user_id
				   );
   LogMessage(FND_LOG.LEVEL_PROCEDURE, 'PROCESS_EVENT - resultOut is '||resultout);
EXCEPTION
   WHEN OTHERS THEN
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      wf_core.context('LNSWF', 'PROCESS_EVENT', itemtype, itemkey,
                                                      to_char(actid), funcmode);      RAISE;
END PROCESS_EVENT;

/*========================================================================
 | PRIVATE PROCEDURE PROCESS_LOAN_APPROVAL
 |
 | DESCRIPTION
 |      This procedure insters/updates the Loan  Approval Status in LNS_APPROVAL_ACTIONS table.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      itemtype        in      Item Type
 |      itemkey         in      Item Key
 |      actid           in      Action Id
 |      funcmode        in      Function Mode
 |      resultout       out     Result Out
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
 | 23-Aug-2009           avepati    bug 8764310 - Loan Notification Missing Approve and Reject Buttons
 |
 *=======================================================================*/
PROCEDURE PROCESS_LOAN_APPROVAL(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 ) IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_LOAN_APPROVAL';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_loan_id         LNS_LOAN_HEADERS_ALL.LOAN_ID%TYPE;
   l_loan_approval_action_rec  LNS_APPROVAL_ACTION_PUB.APPROVAL_ACTION_REC_TYPE;
   l_RETURN_STATUS  LNS_LOAN_PRODUCTS_ALL.LOAN_APPR_REQ_FLAG%TYPE;
   l_action_id  NUMBER;
   l_MSG_DATA VARCHAR2(60);
   l_MSG_COUNT NUMBER;



/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   IF (funcmode <> wf_engine.eng_run) THEN
      resultout := 'COMPLETE:' || 'N';
      return;
   END IF;
   l_loan_id := wf_engine.GetItemAttrNumber
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_ID');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'In PROCESS_LOAN_APPROVAL l_loan_id : ' || l_loan_id);

    select LNS_APPROVAL_ACTIONS_S.NEXTVAL into l_loan_approval_action_rec.action_id from dual;
    l_loan_approval_action_rec.created_by := LNS_UTILITY_PUB.CREATED_BY;
    l_loan_approval_action_rec.creation_date := LNS_UTILITY_PUB.CREATION_DATE;
    l_loan_approval_action_rec.last_updated_by := LNS_UTILITY_PUB.LAST_UPDATED_BY;
    l_loan_approval_action_rec.last_update_date := LNS_UTILITY_PUB.LAST_UPDATE_DATE;
    l_loan_approval_action_rec.last_update_login := LNS_UTILITY_PUB.LAST_UPDATE_LOGIN;
    l_loan_approval_action_rec.object_version_number := l_api_version;
    l_loan_approval_action_rec.loan_id := l_loan_id;
    l_loan_approval_action_rec.action_type := 'APPROVE';
    l_loan_approval_action_rec.amount := null;
    l_loan_approval_action_rec.reason_code := null;
    l_loan_approval_action_rec.attribute_category := null;
    l_loan_approval_action_rec.attribute1 := null;
    l_loan_approval_action_rec.attribute2 := null;
    l_loan_approval_action_rec.attribute3 := null;
    l_loan_approval_action_rec.attribute4 := null;
    l_loan_approval_action_rec.attribute5 := null;
    l_loan_approval_action_rec.attribute6 := null;
    l_loan_approval_action_rec.attribute7 := null;
    l_loan_approval_action_rec.attribute8 := null;
    l_loan_approval_action_rec.attribute9 := null;
    l_loan_approval_action_rec.attribute10 := null;
    l_loan_approval_action_rec.attribute11 := null;
    l_loan_approval_action_rec.attribute12 := null;
    l_loan_approval_action_rec.attribute13 := null;
    l_loan_approval_action_rec.attribute14 := null;
    l_loan_approval_action_rec.attribute15 := null;
    l_loan_approval_action_rec.attribute16 := null;
    l_loan_approval_action_rec.attribute17 := null;
    l_loan_approval_action_rec.attribute18 := null;
    l_loan_approval_action_rec.attribute19 := null;
    l_loan_approval_action_rec.attribute20 := null;


LNS_APPROVAL_ACTION_PUB.create_approval_action (p_init_msg_list => FND_API.G_TRUE,
                                                p_approval_action_rec => l_loan_approval_action_rec,
                                                x_action_id => l_action_id,
                                                X_RETURN_STATUS => l_RETURN_STATUS,
                                                X_MSG_COUNT => l_MSG_COUNT,
                                                X_MSG_DATA => l_MSG_DATA  );

 LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
   LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_action_id : ' || l_action_id);
      LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_RETURN_STATUS : ' || l_RETURN_STATUS);
         LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MSG_COUNT : ' || l_MSG_COUNT);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MSG_DATA : ' || l_MSG_DATA);

  resultout := 'COMPLETE:' || 'Y';

EXCEPTION
   WHEN OTHERS THEN
      resultout := 'COMPLETE:' || 'N';
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      wf_core.context('LNSWF', 'PROCESS_LOAN_APPROVAL', itemtype, itemkey,
                                                      to_char(actid), funcmode);      RAISE;
END PROCESS_LOAN_APPROVAL;

/*========================================================================
 | PRIVATE PROCEDURE PROCESS_LOAN_REJECTION
 |
 | DESCRIPTION
 |      This procedure insters/updates the Loan  Rejection Status in LNS_APPROVAL_ACTIONS table.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      itemtype        in      Item Type
 |      itemkey         in      Item Key
 |      actid           in      Action Id
 |      funcmode        in      Function Mode
 |      resultout       out     Result Out
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2005           GBELLARY          Created
| 23-Aug-2009           avepati    bug 8764310 - Loan Notification Missing Approve and Reject Buttons
 |
 *=======================================================================*/
PROCEDURE PROCESS_LOAN_REJECTION(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 ) IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_LOAN_REJECTION';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_loan_id         LNS_LOAN_HEADERS_ALL.LOAN_ID%TYPE;
   l_loan_approval_action_rec  LNS_APPROVAL_ACTION_PUB.APPROVAL_ACTION_REC_TYPE;
   l_RETURN_STATUS  LNS_LOAN_PRODUCTS_ALL.LOAN_APPR_REQ_FLAG%TYPE;
   l_action_id  NUMBER;
   l_MSG_DATA VARCHAR2(60);
   l_MSG_COUNT NUMBER;



/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   IF (funcmode <> wf_engine.eng_run) THEN
      resultout := 'COMPLETE:' || 'N';
      return;
   END IF;
   l_loan_id := wf_engine.GetItemAttrNumber
                                        ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LNS_LOAN_ID');
   LogMessage(FND_LOG.LEVEL_STATEMENT, 'In PROCESS_LOAN_APPROVAL l_loan_id : ' || l_loan_id);

    select LNS_APPROVAL_ACTIONS_S.NEXTVAL into l_loan_approval_action_rec.action_id from dual;
    l_loan_approval_action_rec.created_by := LNS_UTILITY_PUB.CREATED_BY;
    l_loan_approval_action_rec.creation_date := LNS_UTILITY_PUB.CREATION_DATE;
    l_loan_approval_action_rec.last_updated_by := LNS_UTILITY_PUB.LAST_UPDATED_BY;
    l_loan_approval_action_rec.last_update_date := LNS_UTILITY_PUB.LAST_UPDATE_DATE;
    l_loan_approval_action_rec.last_update_login := LNS_UTILITY_PUB.LAST_UPDATE_LOGIN;
    l_loan_approval_action_rec.object_version_number := l_api_version;
    l_loan_approval_action_rec.loan_id := l_loan_id;
    l_loan_approval_action_rec.action_type := 'REJECT';
    l_loan_approval_action_rec.amount := null;
    l_loan_approval_action_rec.reason_code := null;
    l_loan_approval_action_rec.attribute_category := null;
    l_loan_approval_action_rec.attribute1 := null;
    l_loan_approval_action_rec.attribute2 := null;
    l_loan_approval_action_rec.attribute3 := null;
    l_loan_approval_action_rec.attribute4 := null;
    l_loan_approval_action_rec.attribute5 := null;
    l_loan_approval_action_rec.attribute6 := null;
    l_loan_approval_action_rec.attribute7 := null;
    l_loan_approval_action_rec.attribute8 := null;
    l_loan_approval_action_rec.attribute9 := null;
    l_loan_approval_action_rec.attribute10 := null;
    l_loan_approval_action_rec.attribute11 := null;
    l_loan_approval_action_rec.attribute12 := null;
    l_loan_approval_action_rec.attribute13 := null;
    l_loan_approval_action_rec.attribute14 := null;
    l_loan_approval_action_rec.attribute15 := null;
    l_loan_approval_action_rec.attribute16 := null;
    l_loan_approval_action_rec.attribute17 := null;
    l_loan_approval_action_rec.attribute18 := null;
    l_loan_approval_action_rec.attribute19 := null;
    l_loan_approval_action_rec.attribute20 := null;


LNS_APPROVAL_ACTION_PUB.create_approval_action (p_init_msg_list => FND_API.G_TRUE,
                                                p_approval_action_rec => l_loan_approval_action_rec,
                                                x_action_id => l_action_id,
                                                X_RETURN_STATUS => l_RETURN_STATUS,
                                                X_MSG_COUNT => l_MSG_COUNT,
                                                X_MSG_DATA => l_MSG_DATA  );

 LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
   LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_action_id : ' || l_action_id);
      LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_RETURN_STATUS : ' || l_RETURN_STATUS);
         LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MSG_COUNT : ' || l_MSG_COUNT);
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MSG_DATA : ' || l_MSG_DATA);

  resultout := 'COMPLETE:' || 'Y';

EXCEPTION
   WHEN OTHERS THEN
      resultout := 'COMPLETE:' || 'N';
      LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name
                                                                     || ' Exception -');
      wf_core.context('LNSWF', 'PROCESS_LOAN_APPROVAL', itemtype, itemkey,
                                                      to_char(actid), funcmode);      RAISE;
END PROCESS_LOAN_REJECTION;

 /*========================================================================
 | PUBLIC PROCEDURE SYNCH_EVENT_ACTIONS
 |
 | DESCRIPTION
 |      This procedure adds event actions for newly created user extensible
 |      Loan Types.
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      NONE.
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 23-Feb-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE SYNCH_EVENT_ACTIONS IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name        CONSTANT VARCHAR2(30) := 'SYNCH_EVENT_ACTIONS';
   l_api_version     CONSTANT NUMBER       := 1.0;
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
   insert into lns_event_actions (
     EVENT_ACTION_ID
   , EVENT_ID
   , EVENT_ACTION_NAME
   , DESCRIPTION
   , LOAN_TYPE_ID
   , ACTION_TYPE
   , ENABLED_FLAG
   , API_NAME
   , NOTIFICATION_TYPE
   , SETUP_TYPE
   , PRIMARY_RECIPIENT_TYPE
   , PRIMARY_RECIPIENT_NAME
   , SECONDARY_RECIPIENT_TYPE
   , SECONDARY_RECIPIENT_NAME
   , PRIORITY_NUM
   , DAYS_PRIOR_NUM
   , ACTIVE_FOR_NUM
   , DELIVERY_METHOD
   , OBJECT_VERSION_NUMBER
   , CREATION_DATE
   , CREATED_BY
   , LAST_UPDATE_DATE
   , LAST_UPDATED_BY
   , LAST_UPDATE_LOGIN )
   select   LNS_EVENT_ACTIONS_S.nextval --event_action_id
   , ea.EVENT_ID
   , ea.EVENT_ACTION_NAME
   , ea.DESCRIPTION
   , missingvalues.LOAN_TYPE_ID
   , ea.ACTION_TYPE
   , 'Y' --enabled_flag
   , ea.API_NAME
   , ea.NOTIFICATION_TYPE
   , ea.SETUP_TYPE
   , ea.PRIMARY_RECIPIENT_TYPE
   , ea.PRIMARY_RECIPIENT_NAME
   , ea.SECONDARY_RECIPIENT_TYPE
   , ea.SECONDARY_RECIPIENT_NAME
   , ea.PRIORITY_NUM
   , ea.DAYS_PRIOR_NUM
   , ea.ACTIVE_FOR_NUM
   , ea.DELIVERY_METHOD
   , ea.OBJECT_VERSION_NUMBER
   , sysdate
   , LNS_UTILITY_PUB.CREATED_BY
   , sysdate
   , LNS_UTILITY_PUB.LAST_UPDATED_BY
   , LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
   from lns_event_actions ea, lns_events ev,
   (select loan_class_code, loan_type_id
   from   lns_loan_types_vl
   minus
   select ev.loan_class_code loan_class_code, ea.loan_type_id loan_type_id
   from   lns_events ev, lns_event_actions ea
   where  ea.event_id = ev.event_id
   and    ea.event_action_name = 'NOTIFICATION') missingvalues
   where  ev.loan_class_code = missingvalues.loan_class_code
   and    ea.event_id = ev.event_id
   and    ea.loan_type = decode(ev.loan_class_code,'ERS','ERS','BUSINESS')
   and    ea.event_action_name = 'NOTIFICATION';
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Error in synch event actions: ' || sqlerrm);
	/* This error message needs to be seeded in the future */
	FND_MESSAGE.SET_NAME('LNS', 'LNS_ERROR_SYNCH_EVTS');
	FND_MSG_PUB.ADD;
	raise;
END;

/*========================================================================
 | PUBLIC PROCEDURE DELETE_LNS_EVENT_ACTIONS
 |
 | DESCRIPTION
 |      This procedure deletes the event action records from the table
 |       lns_event_actions table for the provided loanType.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_loan_type_id              IN          Standard in parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author       Description of Changes
 | 16-Mar-2009           MBOLLI       Created
 |
 *=======================================================================*/
PROCEDURE DELETE_LNS_EVENT_ACTIONS  ( p_loan_type_id IN  NUMBER) IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name        CONSTANT VARCHAR2(30) := 'DELETE_LNS_EVENT_ACTIONS';
   l_api_version     CONSTANT NUMBER       := 1.0;
BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   DELETE FROM lns_event_actions
   WHERE loan_type_id = p_loan_type_id;

   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Error in delete_lns_event_actions: ' || sqlerrm);
	/* This error message needs to be seeded in the future */
	FND_MESSAGE.SET_NAME('LNS', 'LNS_ERR_DEL_EVNT_ACTION');
	FND_MSG_PUB.ADD;
	raise;
END;

BEGIN
   G_LOG_ENABLED := 'N';
   G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

   /* getting msg logging info */
   G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
   IF (G_LOG_ENABLED = 'N') then
      G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
   ELSE
      G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
   END IF;
END LNS_WORK_FLOW;

/
