--------------------------------------------------------
--  DDL for Package Body GCS_ADJ_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_ADJ_APPROVAL_WF_PKG" AS
/* $Header: gcsameintgb.pls 120.0 2007/11/21 18:09:37 hakumar ship $ */
--------------------------------------------------------------
--                    Global Variables                      --
--------------------------------------------------------------
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'GCS_INTG_APPROVALS_PKG.';
G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;


--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME              constant varchar2(30) := 'GCS_INTG_APPROVALS_PKG';

-- Item Type Constants
G_FCHAPPR               constant varchar2(30) := 'GCSADJ';
G_FCH_APPROVAL_PROCESS  constant varchar2(30) := 'MASTER';
G_FCH_APPLICATION_ID    constant number       := 266;

-- Workflow Directory Services Constants
G_PER                   constant varchar2(30) := 'PER';
G_FND_USR               constant varchar2(30) := 'FND_USR';

-- Types and constants representing all notification response values
G_APPROVE               constant varchar2(30) := 'APPROVED';
G_REJECT                constant varchar2(30) := 'REJECTED';
G_NO_RESPONSE           constant varchar2(30) := 'NO_RESPONSE';
G_SUCCESS               constant varchar2(30) := 'SUCCESS';
G_FAILURE               constant varchar2(30) := 'FAILURE';

-- Types and constants representing yes/no values
G_YES                   constant varchar2(1)  := 'Y';
G_NO                    constant varchar2(1)  := 'N';

-- Types and constants representing boolean values
G_TRUE                  constant varchar2(30) := 'TRUE';
G_FALSE                 constant varchar2(30) := 'FALSE';

-- Workflow
t_item_type             WF_ITEMS.item_type%TYPE;
t_item_key              WF_ITEMS.item_key%TYPE;

-- Oracle Applications
t_org_id                number;
t_user_id               FND_USER.user_id%TYPE;
t_user_name             FND_USER.user_name%TYPE;
t_responsibility_id     FND_RESPONSIBILITY.responsibility_id%TYPE;
t_application_id        FND_APPLICATION.application_id%TYPE;

-- Oracle Approval Management (AME)
  t_approval_status       varchar2(50);
  g_next_approvers        ame_util.approversTable2;
  g_next_approver         ame_util.approverRecord2;

-- Workflow Directory Services
t_id                    number;
t_name                  varchar2(30);
t_display_name          varchar2(80);
t_orig_system           varchar2(30);

-- API Error Messages
t_msg_count             number;
t_msg_data              varchar2(2000);

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE BuildErrorMsg (
   p_api_name            in          varchar2
  ,p_item_type          in          varchar2
  ,p_item_key           in          varchar2
  ,p_act_id             in          number);


--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------
PROCEDURE Fch_Check_Approvals (p_item_type IN VARCHAR2,
                               p_item_key      IN  varchar2,
                               p_act_id        IN NUMBER,
                               p_funcmode      IN VARCHAR2,
                               x_result_out    out nocopy  varchar2) IS

   l_api_name              constant varchar2(200) := 'fch_check_approvals';
   l_debug_info            VARCHAR2(2000);
   l_calling_sequence      VARCHAR2(2000);

  l_entry_id gcs_entry_headers.entry_id%type;

  l_user_name               t_user_name%TYPE;
  l_submitter_orig_system   t_orig_system%TYPE;
  l_submitter_id            t_id%TYPE;
  l_submitter_name          t_name%TYPE;
  l_submitter_display_name  t_display_name%TYPE;

  l_request_id	   NUMBER(15);
   l_entity_id 			gcs_entry_headers.entity_id%type;
BEGIN

   l_entry_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                             p_item_key,
                             'FCH_ENTRY_ID');

   l_entity_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                             p_item_key,
                             'FCH_ENTITY_ID');

   l_calling_sequence := l_api_name;
   WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'CALLING_SEQUENCE', l_calling_sequence);

   -- Set all the Submitter information on the Item Attributes
    l_user_name := WF_ENGINE.GetItemAttrText(p_item_type, p_item_key, 'USER_NAME');

   l_debug_info := 'Before Calling get Role Info ' || p_item_key ;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

    WF_DIRECTORY.GetRoleOrigSysInfo(
      l_user_name,
      l_submitter_orig_system,
      l_submitter_id);

    WF_DIRECTORY.GetRoleName(
      l_submitter_orig_system
      ,l_submitter_id
      ,l_submitter_name
      ,l_submitter_display_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, 'FCH_SUBMITTED_BY', l_submitter_id);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, 'FCH_SUBMITTER_NAME', l_submitter_name);

    WF_ENGINE.SetItemOwner(
      p_item_type, p_item_key, l_submitter_name);


    -- Set the Approval information on the Item Attributes
    WF_ENGINE.SetItemAttrDate(
      p_item_type, p_item_key, 'REQUEST_DATE', trunc(sysdate));

  l_debug_info := 'Before calling Update GCS Entry Headers, item_key: ' || p_item_key || 'Submitter Name '|| l_submitter_name;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

 --- By default adjustment is approved, and later if there are
 -- approvers on the list then gets changed to IN_PROGRESS

   UPDATE GCS_ENTRY_HEADERS
   SET    approval_status_code = 'IN_PROGRESS'
   WHERE  entry_id = p_item_key;

   -- Create PDF file to be attached to Notification
   l_request_id :=     fnd_request.submit_request(
                                       application     => 'GCS',
                                       program         => 'FCH_PDF_GEN',
                                       sub_request     => FALSE,
                                       argument1       => l_entry_id,
                                       argument2       => 'NA',
                                       argument3       => null);

  l_debug_info := 'Generate PDF request ID ' || to_char(l_request_id) ;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


    x_result_out := WF_ENGINE.eng_completed || ':' || G_YES;

  EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

end Fch_Check_approvals;


PROCEDURE create_gcsadj_process(p_entry_id IN NUMBER
                               ,p_user_id IN NUMBER
							   ,p_user_name IN VARCHAR2
							   ,p_orig_entry_id IN NUMBER
                               ,p_ledger_id IN NUMBER
                               ,p_cal_period_name IN VARCHAR2
                               ,p_conversion_type IN VARCHAR2
							   ,p_writeback_flag IN VARCHAR2
                               ,p_wfitemkey OUT NOCOPY VARCHAR2) IS
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

 CURSOR csr_gcs_entry_details IS
 SELECT ENTRY_ID
 ,      ENTRY_NAME
 ,      HIERARCHY_ID
 ,      ENTITY_ID
 ,      CURRENCY_CODE
 ,      BALANCE_TYPE_CODE
 ,      START_CAL_PERIOD_ID
 ,      END_CAL_PERIOD_ID
 ,      DESCRIPTION
 ,      ENTRY_TYPE_CODE
 ,      CATEGORY_CODE
 ,      CREATED_BY
 ,      WORKFLOW_KEY
 FROM GCS_ENTRY_HEADERS
 WHERE ENTRY_ID = p_entry_id;

 l_entry_id 			gcs_entry_headers.entry_id%type;
 l_entry_name 			gcs_entry_headers.entry_name%type;
 l_hierarchy_id 		gcs_entry_headers.hierarchy_id%type;
 l_entity_id 			gcs_entry_headers.entity_id%type;
 l_currency_code 		gcs_entry_headers.currency_code%type;
 l_balance_type_code 	gcs_entry_headers.balance_type_code%type;
 l_start_cal_period_id 	gcs_entry_headers.start_cal_period_id%type;
 l_end_cal_period_id 	gcs_entry_headers.end_cal_period_id%type;
 l_description  		gcs_entry_headers.description%type;
 l_entry_type_code 		gcs_entry_headers.entry_type_code%type;
 l_category_code 		gcs_entry_headers.category_code%type;
 l_submitted_by 		gcs_entry_headers.created_by%type;
 l_itemkey 				VARCHAR2(80);

 l_entity_name      fem_entities_tl.entity_name%type;
 l_hierarchy_name   gcs_hierarchies_tl.hierarchy_name%type;
 l_period_name      fem_cal_periods_tl.cal_period_name%type;

  Cursor c_entity_details IS
  Select Entity_name
  From fem_entities_tl
  where entity_id = l_entity_id
  and  language = userenv('LANG');

 Cursor c_hierarchy_details IS
  Select hierarchy_name
  From gcs_hierarchies_tl
  Where hierarchy_id = l_hierarchy_id
  and language = userenv('LANG');

 Cursor c_period_details IS
  Select fctl.cal_period_name
  From  fem_cal_periods_tl fctl
  Where fctl.cal_period_id = l_start_cal_period_id
  and    fctl.language = USERENV('LANG');


 l_api_name      CONSTANT VARCHAR2(200) := 'create_gcsadj_process';
 l_debug_info    VARCHAR2(2000);
 l_calling_sequence      VARCHAR2(2000);
 l_num NUMBER;

 l_message_text  Varchar2(1000);

BEGIN
   l_debug_info := 'Start Adjustment Approval Workflow Process';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


   l_debug_info := 'Before ame_api2.clearAllApprovals';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   ame_api2.clearAllApprovals( applicationidin => G_FCH_APPLICATION_ID,
                               transactiontypein => 'GCS_ADJUSTMENT',
                               transactionidin => to_char(p_entry_id));



   l_debug_info := 'Getting Attibutes values';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


   OPEN csr_gcs_entry_details;
   FETCH csr_gcs_entry_details INTO
   l_entry_id ,
   l_entry_name ,
   l_hierarchy_id ,
   l_entity_id ,
   l_currency_code ,
   l_balance_type_code ,
   l_start_cal_period_id ,
   l_end_cal_period_id ,
   l_description  ,
   l_entry_type_code ,
   l_category_code ,
   l_submitted_by ,
   l_itemkey;
   CLOSE csr_gcs_entry_details;


   Open c_entity_details;
   Fetch c_entity_details into l_entity_name;
   Close c_entity_details;

   Open c_hierarchy_details;
   Fetch c_hierarchy_details into l_hierarchy_name;
   Close c_hierarchy_details;

   Open  c_period_details;
   Fetch c_period_details into l_period_name;
   Close c_period_details;



   IF l_itemkey is not Null THEN
   --
   -- Abort previous workflow process
   Begin
      wf_engine.AbortProcess('GCSADJ', l_itemkey, 'MASTER', null);

     l_debug_info := 'Previous WF Process aborted';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
     END IF;


     EXCEPTION
     WHEN OTHERS THEN
     l_debug_info := 'Previous WF Process aborted error';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
     END IF;

   End;

	-- delete previous pdf.
    delete fnd_attached_documents
    where pk1_value = to_char(l_entry_id);

     l_debug_info := ' Deleted Doc :'|| to_char(l_entry_id) || '.pdf';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
     END IF;


   END IF;

   -- Setting the Workflow Item Key
   l_itemkey := to_char(p_entry_id) || to_char(sysdate, 'ddss');


   l_debug_info := 'Calling WF_ENGINE.createProcess(GCSADJ, ' || l_itemkey || ', MASTER);';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;


   wf_engine.createProcess('GCSADJ', l_itemkey, 'MASTER');

   l_debug_info := 'Before Update of Adjustments to Initiated';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   UPDATE GCS_ENTRY_HEADERS
   SET    approval_status_code = 'IN_PROGRESS' ,
          WORKFLOW_KEY = l_itemkey
   WHERE  entry_id = p_entry_id;


   l_debug_info := 'Before setting item attributes' ;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_calling_sequence := l_api_name;
   WF_ENGINE.SetItemAttrText('GCSADJ', l_itemkey, 'CALLING_SEQUENCE', l_calling_sequence);

   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'MASTERKEY',
                        p_entry_id);
   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'FCH_ENTRY_ID',
                        l_entry_id);
   WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_ENTRY_NAME',
                        l_entry_name);

   WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_ENTRY_DESCRIPTION',
                        l_description);

   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'FCH_HIERARCHY_ID',
                        l_hierarchy_id);
   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'FCH_ENTITY_ID',
                        l_entity_id);
   WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_CURRENCY_CODE',
                        l_currency_code);
   WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_BALANCE_TYPE',
                        l_balance_type_code);
   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'FCH_START_PERIOD',
                        l_start_cal_period_id);
   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'FCH_END_PERIOD',
                        l_end_cal_period_id);

   WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_CATEGORY_CODE',
                        l_category_code);

   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'USER_ID',
                        p_user_id);

   WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'USER_NAME',
                        p_user_name);

	WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_ENTITY_NAME',
                        l_entity_name);

	WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_HIERARCHY_NAME',
                        l_hierarchy_name);

	WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'FCH_PERIOD_NAME',
                        l_period_name);

	WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'WRITEBACK_FLAG',
                        p_writeback_flag);

   	WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'CAL_PERIOD_NAME',
                        p_cal_period_name);

	WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'CONVERSION_TYPE',
                        p_conversion_type);

   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'ORIG_ENTRY_ID',
                        p_orig_entry_id);

   WF_ENGINE.SetItemAttrNumber('GCSADJ',
                        l_itemkey,
                        'LEDGER_ID',
                        p_ledger_id);



   l_message_text:= 'An adjustment has been submitted for the hierarchy ' || L_HIERARCHY_NAME || ' , and the entity ' || L_ENTITY_NAME || ' on '||  L_PERIOD_NAME ||' that requires your approval';

	WF_ENGINE.SetItemAttrText('GCSADJ',
                        l_itemkey,
                        'MESSAGE_TEXT',
                        l_message_text);

   l_debug_info := 'Before Calling WF_ENGINE.startProcess(GCSADJ,'
                   || l_itemkey || ');';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   WF_ENGINE.startProcess('GCSADJ', l_itemkey);

   COMMIT;

   l_debug_info := 'After Calling WF_ENGINE.startProcess' ;
   p_wfitemkey := l_itemkey;
   l_debug_info := 'End';

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

  EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END create_gcsadj_process;

--
-- PROCEDURE
--   GetNextApprover
--
-- DESCRIPTION
--   Gets the next approver for the approval request.
--
-- IN
--   p_item_type    - The workflow item type (FEMAPPR)
--   p_item_key     - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--
-- USED BY ACTIVITIES
--   FEMAPPR     FEM_GET_NEXT_APPROVER
--
--------------------------------------------------------------------------------
PROCEDURE Get_Next_Approver (
           p_item_type IN VARCHAR2,
           p_item_key IN VARCHAR2,
           p_act_id   IN NUMBER,
           p_funcmode IN VARCHAR2,
           x_result_out          out nocopy  varchar2) IS

  l_entry_id                NUMBER(15);
  l_application_id          t_application_id%TYPE;
  l_approver_id             t_id%TYPE;
  l_approver_user_id        t_id%TYPE;
  l_approver_name           t_name%TYPE;
  l_approver_display_name   t_display_name%TYPE;
  l_approver_orig_system    t_orig_system%TYPE;

  l_role_name               t_name%TYPE;
  l_role_display_name       t_display_name%TYPE;

  l_next_approver_rec       AME_UTIL.approverRecord;

  l_next_approvers        ame_util.approversTable2;
  l_next_approver         ame_util.approverRecord2;
  l_complete              VARCHAR2(50);
  l_valid_approver        BOOLEAN;

   l_api_name      CONSTANT VARCHAR2(200) := 'get_next_approver';
   l_debug_info    VARCHAR2(2000);
   l_calling_sequence      VARCHAR2(2000);

    l_wf_region             VARCHAR2(200);
    l_attachment            VARCHAR2(200);

BEGIN

    -- Initialize API message list
     FND_MSG_PUB.Initialize;

   l_application_id := G_FCH_APPLICATION_ID;

   l_debug_info := 'Calling Get Next Approvers ' || p_item_key ;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_entry_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                             p_item_key,
                             'FCH_ENTRY_ID');


    AME_API2.GetNextApprovers4(
	   applicationIdIn    => l_application_id,
       transactionTypeIn => 'GCS_ADJUSTMENT',
       transactionIdIn   => to_char(l_entry_id),
       flagApproversAsNotifiedIn => ame_util.booleanFalse,
       approvalProcessCompleteYNOut => l_complete,
       nextApproversOut => l_next_approvers );

   l_debug_info := 'Approval Process Status ' || l_complete;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

  -- IF l_complete = ame_util.booleanFalse THEN	  -- there is a status of complete no approvers

    IF l_next_approvers.count < 1 THEN
       -- No more approvers
     l_debug_info := 'No more approvers ' || p_item_key ;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
     END IF;

     x_result_out := WF_ENGINE.eng_completed || ':' || G_NO;

   ELSE
     l_debug_info := 'New Approver ';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
     END IF;

     l_next_approver := l_next_approvers(1);
	 g_next_approver := l_next_approver;
	 l_valid_approver :=AME_API2.validateApprover(l_next_approver);

	 IF l_valid_approver = FALSE Then
	   l_debug_info := 'Invalid approver, does not have wf role';
  	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
	   END IF;

	 end if;

    if (l_next_approver.approval_status = AME_UTIL.exceptionStatus) then
	 l_debug_info := 'Next approver exception error';

	 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
	 END IF;

    end if;

	l_approver_id:=l_next_approver.ORIG_SYSTEM_ID;
	l_approver_orig_system:= l_next_approver.ORIG_SYSTEM;

    -- Setting all approver attributes
	        WF_DIRECTORY.GetRoleName(l_next_approver.ORIG_SYSTEM
	       ,l_next_approver.ORIG_SYSTEM_ID
		   ,l_role_name,l_role_display_name);

           WF_DIRECTORY.GetUserName(l_next_approver.ORIG_SYSTEM,
                           l_next_approver.ORIG_SYSTEM_ID,
                           l_approver_name,
                           l_approver_display_name);


   l_debug_info := 'Approver found, item: ' || p_item_key || 'Role: ' || l_role_name || ' ID:' || to_char(l_approver_id)  ||
                   ' Name: ' || l_approver_name;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

     WF_ENGINE.SetItemAttrNumber(
      p_item_type, p_item_key, 'APPROVER_ID', l_approver_id);

     WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, 'APPROVER', l_approver_name);


--    WF_ENGINE.SetItemAttrNumber(
--      p_item_type, p_item_key, G_APPROVER_USER_ID, l_approver_user_id);

--    WF_ENGINE.SetItemAttrText(
--      p_item_type, p_item_key, G_APPROVER_DISPLAY_NAME, l_approver_display_name);

     WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, 'ROLE_NAME', l_role_name);

    WF_ENGINE.SetItemAttrText(
      p_item_type, p_item_key, 'ORIG_SYSTEM', l_approver_orig_system);

	  -- set the workflow history region
	l_debug_info:='setting history region attribute information';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

  l_wf_region := 'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/per/ame/transactionhistory/webui/TransactionHistoryRN' || '&' || 'AMETxnID='|| TO_CHAR(l_entry_id) || '&' || 'AMETxnType=GCS_ADJUSTMENT'|| '&' || 'AMEFndAppID=266';

	l_debug_info:='setting attachment attribute information';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

     l_attachment := 'FND:entity=GCS_ENTRY_HEADERS'||'&'||'pk1name=ENTRY_ID'||'&'||'pk1value='||l_entry_id;

      WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'WFREGION', l_wf_region);
	  WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, '#ATTACHMENTS', l_attachment);

     x_result_out := WF_ENGINE.eng_completed || ':' || G_YES;

   END IF;
   --ELSE
     -- Process Complete
--     l_debug_info := 'Process Complete' || p_item_key ;
     -- IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       --   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
--                         l_api_name,l_debug_info);
--     END IF;
--        x_result_out := WF_ENGINE.eng_completed || ':' || G_NO;
--  END IF;

 EXCEPTION

  when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    BuildErrorMsg(l_api_name, p_item_type, p_item_key, p_act_id);
    raise;

END Get_Next_Approver;

PROCEDURE process_approval(p_item_type IN VARCHAR2,
                        p_item_key IN VARCHAR2,
                        p_actid   IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        x_result_out  OUT NOCOPY VARCHAR2 ) IS
   l_entry_id      NUMBER(15);
   l_comments      VARCHAR2(240);
   l_status        VARCHAR2(50);
   l_user_id       NUMBER(15);
   l_api_name      CONSTANT VARCHAR2(200) := 'process_approval';
   l_debug_info    VARCHAR2(2000);
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_approver_orig_system    t_orig_system%TYPE;
   l_role_name     VARCHAR2(150);
   l_calling_sequence      VARCHAR2(2000);

BEGIN

   l_debug_info := 'Start Process Approval';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_calling_sequence := l_api_name;
   WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'CALLING_SEQUENCE', l_calling_sequence);

   l_entry_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                             p_item_key,
                             'FCH_ENTRY_ID');

   l_comments := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'WF_NOTE');

   l_approver_name := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'APPROVER');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(p_item_type,
                             p_item_key,
                             'APPROVER_ID');

   l_role_name := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'ROLE_NAME');

   l_approver_orig_system:= WF_ENGINE.GETITEMATTRText(p_item_type,
                             p_item_key,
                             'ORIG_SYSTEM');

   l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);

   l_debug_info := 'Before calling AME Update Status, entry : ' || l_entry_id || ', Status' || AME_UTIL.approvedStatus || ' role name: '|| l_role_name || 'Approver id: ' || l_approver_id ;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_debug_info := 'AME relevant info, itemclass: ' ||ame_util.headerItemClassName ||',item id ' || l_entry_id ;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   g_next_approver.orig_system:= l_approver_orig_system;
   g_next_approver.orig_system_id:=l_approver_id;
   g_next_approver.name := l_role_name;

   g_next_approver.approval_status:=AME_UTIL.approvedStatus;
   g_next_approver.item_class:=ame_util.headerItemClassName;
   g_next_approver.item_id:=to_char(l_entry_id);


   AME_API2.updateApprovalStatus(applicationIdIn => G_FCH_APPLICATION_ID,
			 transactionTypeIn   => 'GCS_ADJUSTMENT',
			 transactionIdIn     => to_char(l_entry_id),
             approverIn          => g_next_approver);

/*
   AME_API2.updateApprovalStatus2(applicationIdIn => G_FCH_APPLICATION_ID,
			 transactionTypeIn   => 'GCS_ADJUSTMENT',
			 transactionIdIn     => to_char(l_entry_id),
             approvalStatusIn    => AME_UTIL.approvedStatus,
             approverNameIn      => l_role_name,
             itemClassIn         => ame_util.headerItemClassName,
             itemIdIn            => to_char(l_entry_id));
*/
   l_debug_info := 'Updated Approval status in AME records';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
   END IF;

  WF_ENGINE.SetItemAttrText('GCSADJ',
                            p_item_key,
                            'WF_NOTE',
                            null);

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
   END IF;
   x_result_out := wf_engine.eng_completed||':'|| AME_UTIL.approvedStatus;

 EXCEPTION
 WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('GCSADJ','process_approval',p_item_type,
                        p_item_key, to_char(p_actid), p_funcmode);
        RAISE;
END process_approval;


PROCEDURE process_rejected(p_item_type IN VARCHAR2,
                        p_item_key IN VARCHAR2,
                        p_actid   IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        x_result_out  OUT NOCOPY VARCHAR2 ) IS
   l_entry_id      NUMBER(15);
   l_comments      VARCHAR2(240);
   l_status        VARCHAR2(50);
   l_user_id       NUMBER(15);
   l_api_name      CONSTANT VARCHAR2(200) := 'process_rejected';
   l_debug_info    VARCHAR2(2000);
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_approver_orig_system    t_orig_system%TYPE;
   l_role_name     VARCHAR2(150);
   l_calling_sequence      VARCHAR2(2000);

BEGIN

   l_debug_info := 'Start Process Rejected';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_calling_sequence := l_api_name;
   WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'CALLING_SEQUENCE', l_calling_sequence);

   l_entry_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                             p_item_key,
                             'FCH_ENTRY_ID');

   l_comments := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'WF_NOTE');

   l_approver_name := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'APPROVER');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(p_item_type,
                             p_item_key,
                             'APPROVER_ID');

   l_role_name := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'ROLE_NAME');

   l_approver_orig_system:= WF_ENGINE.GETITEMATTRText(p_item_type,
                             p_item_key,
                             'ORIG_SYSTEM');

   l_debug_info := 'Before calling AME Update Status, entry : ' || l_entry_id || ', Status' || AME_UTIL.approvedStatus || ' role name '|| l_role_name || 'Approver id ' || l_approver_id ;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_debug_info := 'AME relevant info, itemclass: ' ||ame_util.headerItemClassName ||',item id ' || l_entry_id ;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   g_next_approver.orig_system:= l_approver_orig_system;
   g_next_approver.orig_system_id:=l_approver_id;
   g_next_approver.name := l_role_name;

   g_next_approver.approval_status:=AME_UTIL.rejectStatus;
   g_next_approver.item_class:=ame_util.headerItemClassName;
   g_next_approver.item_id:=to_char(l_entry_id);


   AME_API2.updateApprovalStatus(applicationIdIn => G_FCH_APPLICATION_ID,
			 transactionTypeIn   => 'GCS_ADJUSTMENT',
			 transactionIdIn     => to_char(l_entry_id),
             approverIn          => g_next_approver);

   /*
   AME_API2.updateApprovalStatus2(applicationIdIn => G_FCH_APPLICATION_ID,
			 transactionIdIn     => to_char(l_entry_id),
             approvalStatusIn    => AME_UTIL.rejectStatus,
             approverNameIn      => l_role_name,
             transactionTypeIn   =>  'GCS_ADJUSTMENT',
             itemClassIn         => ame_util.headerItemClassName,
             itemIdIn            => to_char(l_entry_id));
   */

   l_debug_info := 'Updated Approval status ';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
   END IF;

  WF_ENGINE.SetItemAttrText('GCSADJ',
                            p_item_key,
                            'WF_NOTE',
                            null);

   l_debug_info := 'End';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
   END IF;
   x_result_out := wf_engine.eng_completed||':'||AME_UTIL.approvedStatus;

 EXCEPTION
 WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('GCSADJ','process_rejected',p_item_type,
                        p_item_key, to_char(p_actid), p_funcmode);
        RAISE;
END process_rejected;

PROCEDURE update_adjustment(p_item_type IN VARCHAR2,
                        p_item_key IN VARCHAR2,
                        p_actid   IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        x_result_out  OUT NOCOPY VARCHAR2 ) IS
   l_entry_id      NUMBER(15);
   l_comments      VARCHAR2(240);
   l_status        VARCHAR2(50);
   l_user_id       NUMBER(15);
   l_api_name      CONSTANT VARCHAR2(200) := 'update_adjustment';
   l_debug_info    VARCHAR2(2000);
   l_approver_name VARCHAR2(150);
   l_approver_id   NUMBER;
   l_role_name     VARCHAR2(150);
   l_calling_sequence      VARCHAR2(2000);
   l_prev_calling_sequence      VARCHAR2(2000);

   l_event_name         VARCHAR2 (100) := 'oracle.apps.gcs.transaction.adjustment.update';
   l_event_key          VARCHAR2 (100) := NULL;
   l_parameter_list     wf_parameter_list_t;
   l_request_id         NUMBER(15);
   l_orig_entry_id      NUMBER (15);
   l_writeback          VARCHAR2(30);
   l_ledger_id          NUMBER(15);
   l_cal_period_name    VARCHAR2(80);
   l_conversion_type    VARCHAR2(80);


BEGIN

   l_debug_info := 'Start Update Adjustment';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_prev_calling_sequence := WF_ENGINE.GetItemAttrText(p_item_type, p_item_key, 'CALLING_SEQUENCE');

   l_debug_info := l_prev_calling_sequence;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                         l_api_name,l_debug_info);
   END IF;

   l_calling_sequence := l_api_name;
   WF_ENGINE.SetItemAttrText(p_item_type, p_item_key, 'CALLING_SEQUENCE', l_calling_sequence);

   l_entry_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                             p_item_key,
                             'FCH_ENTRY_ID');

   l_comments := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'WF_NOTE');

   l_approver_name := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'APPROVER');

   l_approver_id := WF_ENGINE.GETITEMATTRNumber(p_item_type,
                             p_item_key,
                            'APPROVER_ID');

   l_role_name := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'ROLE_NAME');

   l_debug_info := 'Before Updating GCS Entries, entry : ' || l_entry_id || ' calling sequence '|| l_prev_calling_sequence;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;


   if l_prev_calling_sequence = 'process_approval'  then
      l_status := G_APPROVE;

   elsif l_prev_calling_sequence = 'process_rejected' then
      l_status := G_REJECT;
   elsif l_prev_calling_sequence = 'fch_check_approvals'  then
    -- No rules found
	    l_status := G_APPROVE;
   else
        l_status :='ERROR';
   end if;

   UPDATE GCS_ENTRY_HEADERS
   SET    approval_status_code = l_status
   WHERE  entry_id = l_entry_id;

   COMMIT;

   l_debug_info := 'Updated GCS Entries with status : ' || nvl(l_status,'NULL');

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
   END IF;


   IF (l_prev_calling_sequence = 'process_approval'  OR l_prev_calling_sequence = 'fch_check_approvals' ) THEN

      l_debug_info := 'Preparing Consolidation Impact Event: ' || l_event_name;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

	 l_orig_entry_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                    p_item_key,
                                                    'ORIG_ENTRY_ID');


      wf_event.addparametertolist (p_name               => 'ENTRY_ID',
                                   p_value              => l_entry_id,
                                   p_parameterlist      => l_parameter_list
                                  );
     --Bugfix 6470903: Set l_orig_entry_id to NULL if it is the same as l_entry_id
      IF (l_orig_entry_id = l_entry_id) THEN
        l_orig_entry_id := NULL;
      END IF;

      wf_event.addparametertolist (p_name               => 'ORIG_ENTRY_ID',
                                   p_value              => l_orig_entry_id,
                                   p_parameterlist      => l_parameter_list
                                  );

      wf_event.RAISE (p_event_name      => l_event_name,
                      p_event_key       => l_event_key,
                      p_parameters      => l_parameter_list);

      l_debug_info := ' Event Raised';

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

     l_writeback := WF_ENGINE.GetItemAttrText(p_item_type,
                                              p_item_key,
                                              'WRITEBACK_FLAG');

     -- Call write back only once is approved
	 If l_writeback='Y' Then

       l_ledger_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                             p_item_key,
                             'LEDGER_ID');

       l_cal_period_name := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'CAL_PERIOD_NAME');


       l_conversion_type := WF_ENGINE.GetItemAttrText(p_item_type,
                             p_item_key,
                             'CONVERSION_TYPE');


       l_request_id :=   fnd_request.submit_request(
                                        application     => 'GCS',
                                        program         => 'FCH_ENTRY_WRITEBACK',
                                        sub_request     => FALSE,
                                        argument1       => l_entry_id,
                                        argument2       => l_entry_id,
                                        argument3       => l_ledger_id,
                                        argument4       => l_cal_period_name,
                                        argument5       => l_conversion_type );

        l_debug_info := ' Submitted Writeback request ID : ' || l_request_id;
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;

	 end if;
   end if;


   x_result_out := wf_engine.eng_completed||':'||'COMPLETED';

 EXCEPTION
 WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('GCSADJ','process_rejected',p_item_type,
                        p_item_key, to_char(p_actid), p_funcmode);
        RAISE;
END update_adjustment;

--
-- PROCEDURE
--   BuildErrorMsg
--
-- DESCRIPTION
--   Builds the Workflow Error Message by checking if there are any errors
--   in the FND_MSG_PUB message stack.
--
-- IN
--   p_api_name             - The PL/SQL Procedure or Function name.
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--   p_act_id               - The function activity
--
--------------------------------------------------------------------------------
PROCEDURE BuildErrorMsg (
  p_api_name            in          varchar2
  ,p_item_type          in          varchar2
  ,p_item_key           in          varchar2
  ,p_act_id             in          number
)
--------------------------------------------------------------------------------
IS

  l_msg_count       t_msg_count%TYPE;
  l_msg_data        t_msg_data%TYPE;

BEGIN

  FND_MSG_PUB.Count_And_Get(
    p_count   => l_msg_count
    ,p_data   => l_msg_data
  );

  if (l_msg_count > 1) then

    l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_FIRST);

  end if;

  WF_CORE.Context(
    G_PKG_NAME
    ,p_api_name
    ,p_item_type
    ,p_item_key
    ,to_char(p_act_id)
    ,l_msg_data
  );

END BuildErrorMsg;

END GCS_ADJ_APPROVAL_WF_PKG;

/
