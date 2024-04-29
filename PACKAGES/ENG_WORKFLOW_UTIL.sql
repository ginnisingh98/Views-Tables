--------------------------------------------------------
--  DDL for Package ENG_WORKFLOW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_WORKFLOW_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUWKFS.pls 120.5 2006/04/11 17:57:28 mkimizuk noship $ */
--
--  Constant Variables : GetWorkflowMonitorURL
--

   -- Api Caller WF
   G_WF_CALL                        VARCHAR2(30) := 'WF' ;

   -- None Return Status
   G_RET_STS_NONE   CONSTANT    VARCHAR2(1) :=  'N';

   -- Seeded Eng Worklfow Item Type
   G_STD_ITEM_TYPE                  CONSTANT VARCHAR2(8)  := 'ENGWFSTD';
   G_CHANGE_ACTION_ITEM_TYPE        CONSTANT VARCHAR2(8)  := 'ENGCACT';
   G_CHANGE_LINE_ACTION_ITEM_TYPE   CONSTANT VARCHAR2(8)  := 'ENGCLACT';
   G_CHANGE_ROUTE_ITEM_TYPE         CONSTANT VARCHAR2(8)  := 'ENGCRT' ;
   G_CHANGE_ROUTE_STEP_ITEM_TYPE    CONSTANT VARCHAR2(8)  := 'ENGCSTEP' ;
   G_CHANGE_ROUTE_DOC_STEP_TYPE     CONSTANT VARCHAR2(8)  := 'ENGDSTEP' ;
   G_CHANGE_ROUTE_LINE_STEP_TYPE    CONSTANT VARCHAR2(8)  := 'ENGLSTEP' ;


   -- Seeded Eng Worklfow Process
   G_CL_INITIATE_CHANGE_PROC        CONSTANT VARCHAR2(30)  := 'INITIATE_CHANGE';
   G_RESPONSE_FYI_PROC              CONSTANT VARCHAR2(30)  := 'RESPONSE_FYI';
   G_APPROVAL_STATUS_CHANGE_PROC    CONSTANT VARCHAR2(30)  := 'APPROVAL_STATUS_CHANGE' ;
   G_VALIDATE_DEFINITION_PROC       CONSTANT VARCHAR2(30)  := 'VALIDATE_DEFINITION' ;
   G_STATUS_CHANGE_PROC             CONSTANT VARCHAR2(30)  := 'STATUS_CHANGE' ;
   G_ROUTE_AGENT_PROC               CONSTANT VARCHAR2(30)  := 'ROUTE_AGENT' ;


   -- Seeded Eng Worklfow Block Abort Activity
   G_BLOCK_ABORT_ACTIVITY CONSTANT VARCHAR2(30)  := 'BLOCK_ABORT';


   -- Eng Change Object Name
   G_ENG_CHANGE                CONSTANT VARCHAR2(30)  := 'ENG_CHANGE' ;
   G_ENG_CHANGE_LINE           CONSTANT VARCHAR2(30)  := 'ENG_CHANGE_LINE' ;


   -- R12B DOM Document Support
   G_OCS_FILE                 CONSTANT VARCHAR2(30)  := ENG_DOCUMENT_UTIL.G_OCS_FILE;
   G_DOM_DOCUMENT_REVISION    CONSTANT VARCHAR2(30)  := ENG_DOCUMENT_UTIL.G_DOM_DOCUMENT_REVISION;


   -- Workflow Adhoc Role Pre-Fix
   -- ':', '#' or '/' should not be included
   --
   G_ADHOC_PARTY_ROLE   CONSTANT VARCHAR2(20)     := 'ENG_ADHOC,';
   G_REV_ROLE           CONSTANT VARCHAR2(20)     := 'ENG_REV,';
   G_ASSIGNEE_ROLE      CONSTANT VARCHAR2(20)     := 'ENG_ASSIGNEE,';
   G_LINE_REV_ROLE      CONSTANT VARCHAR2(20)     := 'ENG_LINE_REV,';
   G_LINE_ASSIGNEE_ROLE CONSTANT VARCHAR2(20)     := 'ENG_LINE_ASSIGNEE,';
   G_OWNER_ROLE         CONSTANT VARCHAR2(20)     := 'ENG_OWNER,';
   G_ROUTE_PEOPLE_ROLE  CONSTANT VARCHAR2(20)     := 'ENG_ROUTE_PEOPLE,' ;
   G_STEP_PEOPLE_ROLE   CONSTANT VARCHAR2(20)     := 'ENG_STEP_PEOPLE,';

   -- Action Types
   G_ACT_COMMENT          CONSTANT VARCHAR2(30) := 'COMMENT' ;
   G_ACT_REPLIED          CONSTANT VARCHAR2(30) := 'REPLIED' ;   -- user response
   G_ACT_APPROVED         CONSTANT VARCHAR2(30) := 'APPROVED' ;  -- user response
   G_ACT_COMPLETED        CONSTANT VARCHAR2(30) := 'COMPLETED' ; -- user response
   G_ACT_REJECTED         CONSTANT VARCHAR2(30) := 'REJECTED' ;  -- user response
   G_ACT_PROMOTE          CONSTANT VARCHAR2(30) := 'PROMOTE' ;
   G_ACT_DEMOTE           CONSTANT VARCHAR2(30) := 'DEMOTE' ;

   G_ACT_DELEGATED        CONSTANT VARCHAR2(30) := 'DELEGATED' ;  -- user response for ntf proxy
   G_ACT_TRANSFERRED      CONSTANT VARCHAR2(30) := 'TRANSFERRED' ; -- user response for ntf proxy

   G_ACT_WF_STARTED       CONSTANT VARCHAR2(30) := 'WF_STARTED' ; -- Wf started
   G_ACT_WF_COMPLETED     CONSTANT VARCHAR2(30) := 'WF_COMPLETED' ; -- wf completed
   G_ACT_WF_APPROVED      CONSTANT VARCHAR2(30) := 'WF_APPROVED' ; -- wf approved
   G_ACT_WF_REJECTED      CONSTANT VARCHAR2(30) := 'WF_REJECTED' ; -- wf rejected
   G_ACT_WF_ABORTED       CONSTANT VARCHAR2(30) := 'WF_ABORTED' ; -- wf aborted
   G_ACT_WF_TIME_OUT      CONSTANT VARCHAR2(30) := 'WF_TIME_OUT' ; -- wf timed out
   G_ACT_WF_PROCESS_ERROR CONSTANT VARCHAR2(30) := 'WF_PROCESS_ERROR' ; -- wf process error

   G_ACT_ABORTED          CONSTANT VARCHAR2(30) := 'ABORTED' ;   -- obsolete in 115.10
   G_ACT_REQUEST_APPROVAL CONSTANT VARCHAR2(30) := 'REQUEST_APPROVAL' ; -- obsolete in 115.10
   G_ACT_TIMEOUT_WF       CONSTANT VARCHAR2(30) := 'TIMEOUT_WF' ; -- obsolete in 115.10

   -- R12B
   G_LINE_ACT_CHG_STATUS  CONSTANT VARCHAR2(30) := 'CHANGE_STATUS' ; -- Line Status Change Action
   G_ACT_DECLINED         CONSTANT VARCHAR2(30) := 'DECLINED' ; -- obsolete in 115.10
   G_ACT_RECEIVED         CONSTANT VARCHAR2(30) := 'RECEIVED' ; -- obsolete in 115.10

   -- Action System Party ID
   G_ACT_SYSTEM_USER_ID   CONSTANT NUMBER := -10000 ;

   -- Workflow Seeded Internal Status
   G_WF_NOTIFIED       CONSTANT VARCHAR2(8) := 'NOTIFIED'  ;
   G_WF_ACTIVIE        CONSTANT VARCHAR2(8) := 'ACTIVE' ;
   G_WF_COMPLETE       CONSTANT VARCHAR2(8) := 'COMPLETE' ;
   G_WF_ERROR          CONSTANT VARCHAR2(8) := 'ERROR' ;
   G_WF_SUSPEND        CONSTANT VARCHAR2(8) := 'SUSPEND' ;
   G_WF_DEFERRED       CONSTANT VARCHAR2(8) := 'DEFERRED' ;
   G_WF_WAITING        CONSTANT VARCHAR2(8) := 'WAITING' ;
   G_WF_TRANSFER       CONSTANT VARCHAR2(8) := 'TRANSFER' ;
   G_WF_FORWARD        CONSTANT VARCHAR2(8) := 'FORWARD' ;

   -- MFG Lookup Type: ENG_ECN_APPROVAL_STATUS
   -- Used for Change Object's Approval Status
   --          ENG_ENGINEERING_CHANGES.APPROVAL_STATUS_TYPE
   G_NOT_SUBMITTED     CONSTANT NUMBER := 1 ; -- Not submitted for approval
   G_READY             CONSTANT NUMBER := 2 ; -- Ready to approve
   G_REQUESTED         CONSTANT NUMBER := 3 ; -- Approval requested
   G_REJECTED          CONSTANT NUMBER := 4 ; -- Rejected
   G_APPROVED          CONSTANT NUMBER := 5 ; -- Approved
   G_NO_APPR_NEEDED    CONSTANT NUMBER := 6 ; -- No approval needed
   G_ERROR             CONSTANT NUMBER := 7 ; -- Processing error
   G_TIME_OUT          CONSTANT NUMBER := 8 ; -- Time out


   -- Old MFG Lookup Type: ECG_ECN_STATUS
   -- New status table : ENG_CHANGE_STATUSES
   -- Used for Change Object's Status Type
   --          ENG_ENGINEERING_CHANGES.STATUS_TYPE
   G_CHG_OPEN          CONSTANT NUMBER := 1 ; -- Open
   G_CHG_HOLD          CONSTANT NUMBER := 2 ; -- Hold
   G_CHG_SCHEDULED     CONSTANT NUMBER := 4 ; -- Scheduled
   G_CHG_CANCELLED     CONSTANT NUMBER := 5 ; -- Cancelled
   G_CHG_IMPLEMENTED   CONSTANT NUMBER := 6 ; -- Implemented
   G_CHG_RELEASED      CONSTANT NUMBER := 7 ; -- Released
   G_CHG_ANALYSIS      CONSTANT NUMBER := 8 ; -- Analysis
   G_CHG_PENDING       CONSTANT NUMBER := 9 ; -- Pending Response
   G_CHG_IN_PROGRESS   CONSTANT NUMBER := 10 ; -- In Progress
   G_CHG_COMPLETED     CONSTANT NUMBER := 11 ; -- Completed


   -- Fnd Lookup Type: ENG_CHANGE_LINE_STATUSES
   -- Used for Chagne Line Object's Status Code
   --          ENG_CHANGE_LINES.STATUS_CODE
   --
   G_CL_OPEN          CONSTANT VARCHAR2(30) := '1' ; -- Open
   G_CL_CANCELLED     CONSTANT VARCHAR2(30) := '5' ; -- Cancelled
   G_CL_COMPLETED     CONSTANT VARCHAR2(30) := '11'; -- Completed

   -- Fnd Lookup Type: ENG_DIST_LINE_STATUSES
   -- Used for Chagne Distribution Line Object's Status Code
   -- if "Notification" type Line Workflow is attached on the Line
   --          ENG_CHANGE_LINES.STATUS_CODE
   --
   G_DIST_CL_NOT_DISTRIBUTED      CONSTANT VARCHAR2(30) := '1'; -- Not Distributed
   G_DIST_CL_CANCELLED            CONSTANT VARCHAR2(30) := '5'; -- Cancelled
   G_DIST_CL_DIST_IN_PROGRESS     CONSTANT VARCHAR2(30) := '9'; -- Distribution in Progress
   G_DIST_CL_DISTRIBUTED          CONSTANT VARCHAR2(30) := '11'; -- Distributed


   -- Route Template Flag Internal Code
   G_RT_INSTANCE     CONSTANT VARCHAR2(1) := 'N' ; -- Instance
   G_RT_TEMPLATE     CONSTANT VARCHAR2(1) := 'Y' ; -- Template
   G_RT_HISTORY      CONSTANT VARCHAR2(1) := 'H' ; -- History

   -- FND Lookup Type: ENG_CHANGE_ROUTE_STATUSES
   -- Used for Change Route's Status
   --          ENG_CHANGE_ROUTES.STATUS_CODE
   -- Used for Change Route's Status
   --          ENG_CHANGE_ROUTE_STEPS.STEP_STATUS_CODE
   -- Used for Change Route People's Response Code
   --          ENG_CHANGE_ROUTE_PEOPLE.RESPONSE_CODE
   --
   G_RT_NOT_STARTED  CONSTANT VARCHAR2(30) := 'NOT_STARTED' ; -- Not Started
   G_RT_IN_PROGRESS  CONSTANT VARCHAR2(30) := 'IN_PROGRESS' ; -- In Progress
   G_RT_APPROVED     CONSTANT VARCHAR2(30) := 'APPROVED' ; -- Approved
   G_RT_REJECTED     CONSTANT VARCHAR2(30) := 'REJECTED' ; -- Rejected
   G_RT_TIME_OUT     CONSTANT VARCHAR2(30) := 'TIME_OUT' ; -- Time Out
   G_RT_ABORTED      CONSTANT VARCHAR2(30) := 'ABORTED' ; -- Aborted
   G_RT_COMPLETED    CONSTANT VARCHAR2(30) := 'COMPLETED' ; -- Completed
   G_RT_REPLIED      CONSTANT VARCHAR2(30) := 'REPLIED' ; -- Replied
   G_RT_ERROR        CONSTANT VARCHAR2(30) := 'ERROR' ; -- Failed (Future)
   G_RT_SUBMITTED    CONSTANT VARCHAR2(30) := 'SUBMITTED' ; -- Submitted
   G_RT_TRANSFERRED  CONSTANT VARCHAR2(30) := 'TRANSFERED' ; -- Transferred
   G_RT_FORWARDED    CONSTANT VARCHAR2(30) := 'FORWARDED' ; -- Forwarded

   -- R12B Line Workflow Specific Status
   G_RT_RECEIVED     CONSTANT VARCHAR2(30) := 'RECEIVED' ; -- Received
   G_RT_DECLINED     CONSTANT VARCHAR2(30) := 'DECLINED' ; -- Declined
   G_RT_NOT_RECEIVED CONSTANT VARCHAR2(30) := 'NOT_RECEIVED' ; -- Not Received


   -- FND Lookup Type: ENG_ROUTE_ASSIGNEE_TYPES
   -- Used for Change Route People's Assignee Type
   --          ENG_CHANGE_ROUTE_PEOPLE.ASSIGNEE_TYPE_CODE
   G_PERSON            CONSTANT VARCHAR2(30) := 'PERSON' ; -- Person
   G_GROUP             CONSTANT VARCHAR2(30) := 'GROUP' ; -- Group
   G_ROLE              CONSTANT VARCHAR2(30) := 'ROLE' ; -- Role


   -- FND Lookup Type: ENG_CHANGE_ROUTE_CONDITIONS
   -- Used for Change Route Step's Condition
   --          ENG_CHANGE_ROUTE_STEPS.STEP_STATUS_CODE
   G_ONE              CONSTANT VARCHAR2(30) := 'ONE' ; -- One Can Approve
   G_ALL              CONSTANT VARCHAR2(30) := 'ALL' ; -- All Must Approve
   G_PEOPLE           CONSTANT VARCHAR2(30) := 'PEOPLE' ; -- Assignee Level

   -- FND Lookup Type: ENG_ROUTE_RESP_CONDITIONS
   -- Used for Change Route Step Assignee's Response Condition
   --          ENG_CHANGE_ROUTE_STEPS.STEP_STATUS_CODE
   G_MANDATORY        CONSTANT VARCHAR2(30) := 'MANDATORY' ; -- Mandatory
   G_OPTIONAL         CONSTANT VARCHAR2(30) := 'OPTIONAL' ; -- Optional

   -- FND Lookup Type: ENG_ROUTE_TYPE_CODES
   -- Used for Change Route TYpe Codes
   --          ENG_CHANGE_ROUTES.ROUTE_TYPE_CODE
   G_RT_TYPE_APPROVAL            CONSTANT VARCHAR2(30) := 'APPROVAL' ;
   G_RT_TYPE_DEFINITION          CONSTANT VARCHAR2(30) := 'DEFINITION' ;
   G_RT_TYPE_DEFINITION_APPROVAL CONSTANT VARCHAR2(30) := 'DEFINITION_APPROVAL' ;
   G_RT_TYPE_GENERIC             CONSTANT VARCHAR2(30) := 'GENERIC' ;



   -- FND Lookup Type: ENG_LINE_ROUTE_TYPE_CODES
   -- Used for Change Route TYpe Codes
   --          ENG_CHANGE_ROUTES.ROUTE_TYPE_CODE
   G_LINE_RT_TYPE_NOTIFICATION CONSTANT VARCHAR2(30) := 'NOTIFICATION' ;
   G_LINE_RT_TYPE_GENERIC      CONSTANT VARCHAR2(30) := 'GENERIC' ;


   -- FND Lookup Type: ENG_DOC_ROUTE_TYPE_CODES
   -- Used for Change Route TYpe Codes
   --          ENG_CHANGE_ROUTES.ROUTE_TYPE_CODE
   G_DOC_RT_TYPE_APPROVAL       CONSTANT VARCHAR2(30) := 'APPROVAL' ;
   G_DOC_RT_TYPE_GENERIC        CONSTANT VARCHAR2(30) := 'GENERIC' ;



   -- WFSTD_VOTING_OPTION: Standard Voting Option Lookup Codes
   G_WAIT_FOR_ALL_VOTES    CONSTANT VARCHAR2(30) := 'WAIT_FOR_ALL_VOTES' ;
   G_REQUIRE_ALL_VOTES     CONSTANT VARCHAR2(30) := 'REQUIRE_ALL_VOTES' ;
   G_TALLY_ON_EVERY_VOTE   CONSTANT VARCHAR2(30) := 'TALLY_ON_EVERY_VOTE' ;


   -- WFSTD_SIGNATURE_POLICY: Signature Policy Lookup Codes
   G_SIG_POLICY_DEFAULT    CONSTANT VARCHAR2(30) := 'DEFAULT' ;
   G_SIG_POLICY_PSIG_ONLY  CONSTANT VARCHAR2(30) := 'PSIG_ONLY' ;
   G_SIG_POLICY_PKCS7X509_ONLY  CONSTANT VARCHAR2(30) := 'PKCS7X509_ONLY' ;

   -- Monitor URL Types for GetWorkflowMonitorURL
   G_MONITOR_ACCESSKEY         CONSTANT VARCHAR2(15)      := 'ACCESSKEY';
   G_MONITOR_DIAGRAM           CONSTANT VARCHAR2(15)      := 'DIAGRAM';
   G_MONITOR_ENVELOPE          CONSTANT VARCHAR2(15)      := 'ENVELOPE';
   G_MONITOR_ADVANCED_ENVELOPE CONSTANT VARCHAR2(20)      := 'ADVANCED_ENVELOPE';


   -- ENGWFSTD_REQ_COMMENT_RESULT: Eng Request Comment Result Lookup Codes
   G_REPLY                     CONSTANT VARCHAR2(30) := 'REPLY' ;

   --
   -- R12B
   -- Grant/Revoke API Options
   --
   G_REVOKE_ALL     CONSTANT VARCHAR2(30) := 'REVOKE_ALL' ;
   G_REVOKE_HEADER  CONSTANT VARCHAR2(30) := 'REVOKE_HEADER' ;
   G_REVOKE_LINE    CONSTANT VARCHAR2(30) := 'REVOKE_LINE' ;

   --
   -- R12B
   -- Reserved Attribute Name used for the special logic
   --
   G_ATTR_AUTO_REVOKE_RESPONSE  CONSTANT VARCHAR2(30) := 'AUTO_REVOKE_RESPONSE' ;


   --
   -- R12B
   -- Notification Mandatory Response: Special Case
   --
   G_MANDATORY_RESP_ANY CONSTANT VARCHAR2(30) := 'ANY' ;

   -- Bug5136260 Support
   G_MRP_FLAG_YES   CONSTANT NUMBER := 1 ; -- Yes: Active
   G_MRP_FLAG_NO    CONSTANT NUMBER := 2 ; -- No: Inactive






/********************************************************************
* Debug APIs    : Open_Debug_Session, Close_Debug_Session,
*                 Write_Debug
* Parameters IN :
* Parameters OUT:
* Purpose       : These procedures are for test and debug
*********************************************************************/
-- Open_Debug_Session
PROCEDURE Open_Debug_Session
(  p_output_dir IN VARCHAR2 := NULL
,  p_file_name  IN VARCHAR2 := NULL
);

-- Close Debug_Session
PROCEDURE Close_Debug_Session ;

-- Write Debug Message
PROCEDURE Write_Debug
(  p_debug_message      IN  VARCHAR2 ) ;

-- Write Debug Mode from Workflow Function Activities
PROCEDURE Get_Debug_Mode
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_debug_flag        OUT NOCOPY BOOLEAN
 ,  x_output_dir        OUT NOCOPY VARCHAR2
 ,  x_debug_filename    OUT NOCOPY VARCHAR2
);

/********************************************************************
* API Type      : Private APIs
* Purpose       : Those APIs are private
*********************************************************************/
FUNCTION GetBaseChangeMgmtTypeCode
( p_change_id         IN     NUMBER)
RETURN VARCHAR2 ;


FUNCTION GetNewItemKey
RETURN VARCHAR2 ;


PROCEDURE GetChangeObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_change_id         OUT NOCOPY NUMBER
) ;

PROCEDURE GetChangeObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_change_id         OUT NOCOPY NUMBER
 ,  x_change_notice     OUT NOCOPY VARCHAR2
 ,  x_organization_id   OUT NOCOPY NUMBER
) ;

-- Get Organization Info
PROCEDURE GetOrgInfo
(  p_organization_id   IN  NUMBER
 , x_organization_code OUT NOCOPY VARCHAR2
 , x_organization_name OUT NOCOPY VARCHAR2
) ;

PROCEDURE GetChangeLineObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_change_line_id    OUT NOCOPY NUMBER
) ;

-- Get Change Object Item Subject Info
PROCEDURE GetChangeItemSubjectInfo
(  p_change_id               IN  NUMBER
 , x_organization_id         OUT NOCOPY NUMBER
 , x_item_id                 OUT NOCOPY NUMBER
 , x_item_name               OUT NOCOPY VARCHAR2
 , x_item_revision_id        OUT NOCOPY NUMBER
 , x_item_revision           OUT NOCOPY VARCHAR2
 , x_item_revision_label     OUT NOCOPY VARCHAR2
) ;

-- Get Change Line Item Subject Info
PROCEDURE GetChangeLineItemSubjectInfo
(  p_change_id               IN  NUMBER
 , p_change_line_id          IN  NUMBER
 , x_organization_id         OUT NOCOPY NUMBER
 , x_item_id                 OUT NOCOPY NUMBER
 , x_item_name               OUT NOCOPY VARCHAR2
 , x_item_revision_id        OUT NOCOPY NUMBER
 , x_item_revision           OUT NOCOPY VARCHAR2
 , x_item_revision_label     OUT NOCOPY VARCHAR2
) ;


PROCEDURE GetHostURL
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_host_url          OUT NOCOPY VARCHAR2
) ;

FUNCTION GetFrameWorkAgentURL
RETURN VARCHAR2 ;



PROCEDURE GetStyleSheet
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_style_sheet       OUT NOCOPY VARCHAR2
) ;

PROCEDURE GetActionId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_action_id         OUT NOCOPY NUMBER
) ;

PROCEDURE GetWFUserId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_wf_user_id        OUT NOCOPY NUMBER
) ;

PROCEDURE GetRouteId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_route_id          OUT NOCOPY NUMBER
) ;


PROCEDURE GetRouteObject
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_route_object      OUT NOCOPY VARCHAR2
) ;

PROCEDURE GetRouteTypeCode
(   p_route_id          IN  NUMBER
 ,  x_route_type_code   OUT NOCOPY VARCHAR2
) ;


PROCEDURE GetRouteComplStatusCode
(   p_route_id                IN  NUMBER
 ,  p_route_type_code         IN  VARCHAR2 := NULL
 ,  x_route_compl_status_code OUT NOCOPY VARCHAR2
) ;


PROCEDURE GetRouteStepId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_route_step_id     OUT NOCOPY NUMBER
) ;

PROCEDURE SetRouteStepId
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_route_step_id     IN  NUMBER
) ;


PROCEDURE GetNtfResponseTimeOut
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  x_timeout_min       OUT NOCOPY NUMBER
) ;


PROCEDURE SetNtfResponseTimeOut
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_response_by_date  IN  DATE
) ;

PROCEDURE SetNtfResponseTimeOut
(   p_item_type              IN  VARCHAR2
 ,  p_item_key               IN  VARCHAR2
 ,  p_required_relative_days IN  NUMBER
) ;

PROCEDURE SetStepActVotingOption
(   p_item_type           IN  VARCHAR2
 ,  p_item_key            IN  VARCHAR2
 ,  p_condition_type_code IN  VARCHAR2
) ;


/*
-- OBSOLETE in 115.10
PROCEDURE SetChangeApprovalStatus
(   x_return_status        OUT NOCOPY VARCHAR2
 ,  x_msg_count            OUT NOCOPY NUMBER
 ,  x_msg_data             OUT NOCOPY VARCHAR2
 ,  p_item_type            IN  VARCHAR2 := NULL
 ,  p_item_key             IN  VARCHAR2 := NULL
 ,  p_change_id            IN  NUMBER
 ,  p_change_line_id       IN  NUMBER   := NULL
 ,  p_sync_lines           IN  NUMBER   := NULL -- Yes: greater than 0
 ,  p_wf_user_id           IN  NUMBER
 ,  p_new_appr_status_type IN  NUMBER
) ;
*/

/*
-- OBSOLETE in 115.10
PROCEDURE SyncLineApprovalStatus
(   x_return_status           OUT NOCOPY VARCHAR2
 ,  x_msg_count               OUT NOCOPY NUMBER
 ,  x_msg_data                OUT NOCOPY VARCHAR2
 ,  p_change_id               IN  NUMBER
 ,  p_wf_user_id              IN  NUMBER
 ,  p_header_appr_status_type IN  NUMBER
) ;
*/


PROCEDURE SetRouteStatus
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_wf_user_id        IN  NUMBER
 ,  p_route_id          IN  NUMBER
 ,  p_new_status_code   IN  VARCHAR2
 ,  p_init_route        IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_change_id         IN  NUMBER   := NULL
 ,  p_change_line_id    IN  NUMBER   := NULL   -- R12B. Added

) ;

PROCEDURE SetRouteStepStatus
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_wf_user_id        IN  NUMBER
 ,  p_route_id          IN  NUMBER
 ,  p_route_step_id     IN  NUMBER
 ,  p_new_status_code   IN  VARCHAR2
) ;


PROCEDURE GetRouteStepStatus
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_route_step_id     IN  NUMBER
 ,  x_status_code       OUT NOCOPY VARCHAR2
) ;


-- Get Change Object Info
PROCEDURE GetChangeObjectInfo
(  p_change_id               IN  NUMBER
 , x_change_notice           OUT NOCOPY VARCHAR2
 , x_organization_id         OUT NOCOPY NUMBER
 , x_change_name             OUT NOCOPY VARCHAR2
 , x_description             OUT NOCOPY VARCHAR2
 , x_change_status           OUT NOCOPY VARCHAR2
 , x_change_lc_phase         OUT NOCOPY VARCHAR2
 , x_approval_status         OUT NOCOPY VARCHAR2
 , x_priority                OUT NOCOPY VARCHAR2
 , x_reason                  OUT NOCOPY VARCHAR2
 , x_change_managemtent_type OUT NOCOPY VARCHAR2
 , x_change_order_type       OUT NOCOPY VARCHAR2
 , x_eco_department          OUT NOCOPY VARCHAR2
 , x_assignee                OUT NOCOPY VARCHAR2
 , x_assignee_company        OUT NOCOPY VARCHAR2
) ;

-- Get Change Line Object Info
PROCEDURE GetChangeLineObjectInfo
(  p_change_line_id        IN  NUMBER
 , x_change_id             OUT NOCOPY NUMBER
 , x_line_sequence_number  OUT NOCOPY NUMBER
 , x_line_name             OUT NOCOPY VARCHAR2
 , x_line_description      OUT NOCOPY VARCHAR2
 , x_line_status           OUT NOCOPY VARCHAR2
 , x_line_approval_status  OUT NOCOPY VARCHAR2
 , x_line_assignee         OUT NOCOPY VARCHAR2
 , x_line_assignee_company OUT NOCOPY VARCHAR2
) ;


-- Get Workflow Change Object Info
PROCEDURE GetWFChangeObjectInfo
(  p_item_type               IN  VARCHAR2
 , p_item_key                IN  VARCHAR2
 , x_change_name             OUT NOCOPY VARCHAR2
 , x_description             OUT NOCOPY VARCHAR2
 , x_change_status           OUT NOCOPY VARCHAR2
 , x_approval_status         OUT NOCOPY VARCHAR2
 , x_priority                OUT NOCOPY VARCHAR2
 , x_reason                  OUT NOCOPY VARCHAR2
 , x_change_managemtent_type OUT NOCOPY VARCHAR2
 , x_change_order_type       OUT NOCOPY VARCHAR2
 , x_eco_department          OUT NOCOPY VARCHAR2
 , x_assignee                OUT NOCOPY VARCHAR2
 , x_assignee_company        OUT NOCOPY VARCHAR2
) ;

PROCEDURE GetWFChangeLineObjectInfo
(  p_item_type             IN  VARCHAR2
 , p_item_key              IN  VARCHAR2
 , x_line_sequence_number  OUT NOCOPY NUMBER
 , x_line_name             OUT NOCOPY VARCHAR2
 , x_line_description      OUT NOCOPY VARCHAR2
 , x_line_status           OUT NOCOPY VARCHAR2
 , x_line_assignee         OUT NOCOPY VARCHAR2
 , x_line_assignee_company OUT NOCOPY VARCHAR2
) ;


PROCEDURE GetActionInfo
(  p_action_id                 IN   NUMBER
 , x_action_desc               OUT  NOCOPY VARCHAR2
 , x_action_party_id           OUT  NOCOPY VARCHAR2
 , x_action_party_name         OUT  NOCOPY VARCHAR2
 , x_action_party_company_name OUT  NOCOPY VARCHAR2
) ;


PROCEDURE GetRouteStepInfo
(  p_route_step_id             IN  NUMBER
 , x_step_seq_num              OUT NOCOPY NUMBER
 , x_required_date             OUT NOCOPY DATE
 , x_condition_type            OUT NOCOPY VARCHAR2
 , x_step_instrunction         OUT NOCOPY VARCHAR2
) ;


PROCEDURE ValidateProcess
(   p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_adhoc_party_list  IN  VARCHAR2  := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
 ,  p_parent_item_type  IN  VARCHAR2  := NULL
 ,  p_parent_item_key   IN  VARCHAR2  := NULL
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
) ;

PROCEDURE SetAttributes
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_id         IN OUT NOCOPY  NUMBER
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_wf_user_role      IN  VARCHAR2  := NULL
 ,  p_host_url          IN  VARCHAR2
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_adhoc_party_list  IN  VARCHAR2  := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
 ,  p_parent_item_type  IN  VARCHAR2  := NULL
 ,  p_parent_item_key   IN  VARCHAR2  := NULL
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
) ;



PROCEDURE SetAdhocPartyRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_adhoc_party_list  IN  VARCHAR2
) ;


--  API name   : SetAssigneeRole
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Assignee Role
PROCEDURE SetAssigneeRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
) ;


--  API name   : SetReviewersRole
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Reviewers Role
--  Parameters : p_reviewer_type  IN  VARCHAR2 Optional
--                                    Default = STD
--                                    In case that you don't want to
--                                    inlcude Assingee to Reviewers
--                                    Role, set 'NO_ASSIGNEE'
PROCEDURE SetReviewersRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_reviewer_type     IN  VARCHAR2 := 'STD'
) ;

--  API name   : StartAllLineWorkflows
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Start p_line_item, p_line_process Workflows
--               for the Lines
--  Parameters : p_item_type         IN VARCHAR2 Required
--               p_item_key          IN VARCHAR2 Required
--               p_change_id         IN NUMBER Required
--               p_wf_user_id        IN NUMBER Required
--               p_host_url          IN VARCHAR2 Optional
--               p_line_item_type    IN VARCHAR2 Required
--               p_line_process_name IN VARCHAR2 Required
--
--
PROCEDURE StartAllLineWorkflows
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2 := NULL
 ,  p_line_item_type    IN  VARCHAR2
 ,  p_line_process_name IN  VARCHAR2
) ;



--  API name   : SetLineAssigneeRole
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Line Assignee Role
PROCEDURE SetLineAssigneeRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
) ;


--  API name   : SetLineReviewersRole
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Line Reviewers Role
--  Parameters : p_reviewer_type  IN  VARCHAR2 Optional
--                                    Default = STD
--                                    In case that you don't want to
--                                    inlcude Line Assingee to Reviewers
--                                    Role, set 'NO_ASSIGNEE'
PROCEDURE SetLineReviewersRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_reviewer_type     IN  VARCHAR2 := 'STD'
) ;

--  API name   : SetRoutePeopleRole
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Assignee Role
PROCEDURE SetRoutePeopleRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_option            IN  VARCHAR2 := NULL
) ;



--  API name   : SetStepPeopleRole
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Assignee Role
PROCEDURE SetStepPeopleRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
) ;


PROCEDURE DeleteAdhocRolesAndUsers
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
) ;


PROCEDURE CreateAction
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_notification_id   IN  NUMBER
 ,  p_action_type       IN  VARCHAR2
 ,  p_comment           IN  VARCHAR2 := NULL
 ,  x_action_id         OUT NOCOPY NUMBER
 ,  p_assignee_id       IN  NUMBER :=NULL
 ,  p_raise_event_flag  IN  VARCHAR2 := FND_API.G_FALSE -- R12
 ) ;

PROCEDURE CreateRouteAction
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_change_id         IN  NUMBER   := NULL
 ,  p_change_line_id    IN  NUMBER   := NULL
 ,  p_action_type       IN  VARCHAR2
 ,  p_user_id           IN  NUMBER
 ,  p_parent_action_id  IN  NUMBER   := NULL
 ,  p_route_id          IN  NUMBER   := NULL
 ,  p_comment           IN  VARCHAR2 := NULL
 ,  x_action_id         OUT NOCOPY NUMBER
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
 ,  p_raise_event_flag  IN  VARCHAR2 := FND_API.G_FALSE -- R12
 ) ;


PROCEDURE SyncChangeLCPhase
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_route_id          IN  NUMBER
 ,  p_api_caller        IN  VARCHAR2 := NULL -- or G_WF_CALL:'WF'
) ;


PROCEDURE SetRouteResponse
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_notification_id   IN  NUMBER
 ,  p_response_code     IN  VARCHAR2
 ,  p_comment           IN  VARCHAR2 := NULL
 ,  p_actid             IN  NUMBER   := NULL  -- added in R12B
 ,  p_funcmode          IN  VARCHAR2 := NULL  -- added in R12B
) ;


PROCEDURE FindNextRouteStep
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_route_id          IN  NUMBER
 ,  x_step_id           OUT NOCOPY NUMBER
 ,  x_step_item_type    OUT NOCOPY VARCHAR2
 ,  x_step_process_name OUT NOCOPY VARCHAR2
 ) ;


PROCEDURE StartNextRouteStep
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_route_item_type   IN  VARCHAR2
 ,  p_route_item_key    IN  VARCHAR2
 ,  p_route_id          IN  NUMBER
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2
 ,  x_step_id           OUT NOCOPY NUMBER
 ,  x_step_item_type    OUT NOCOPY VARCHAR2
 ,  x_step_item_key     OUT NOCOPY VARCHAR2
 ,  p_object_name       IN  VARCHAR2  := NULL
 ,  p_object_id1        IN  NUMBER    := NULL
 ,  p_object_id2        IN  NUMBER    := NULL
 ,  p_object_id3        IN  NUMBER    := NULL
 ,  p_object_id4        IN  NUMBER    := NULL
 ,  p_object_id5        IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2 := NULL
 ,  p_parent_object_id1  IN  NUMBER   := NULL
 ,  p_route_action_id   IN  NUMBER    := NULL
 ) ;


PROCEDURE GrantChangeRoleToParty
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_role_name         IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_party_id          IN  NUMBER
 ,  p_start_date        IN  DATE
 ,  p_end_date          IN  DATE := NULL
 ) ;



PROCEDURE GrantChangeRoleToStepPeople
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_step_id           IN  NUMBER
) ;

PROCEDURE StartLineRoutes
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2 := NULL
) ;

PROCEDURE CheckAllLineApproved
(   x_return_status        OUT NOCOPY VARCHAR2
 ,  x_msg_count            OUT NOCOPY NUMBER
 ,  x_msg_data             OUT NOCOPY VARCHAR2
 ,  p_change_id            IN  NUMBER
 ,  x_line_approval_status OUT NOCOPY NUMBER
) ;

FUNCTION GetFunctionWebHTMLCall(p_function_name IN VARCHAR2)
RETURN VARCHAR2  ;


FUNCTION CheckRouteStepRequiredDate(p_route_id IN NUMBER )
RETURN BOOLEAN ;

PROCEDURE RouteStepVoteForResultType
(   itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY varchar2) ;


PROCEDURE ContinueHeaderRoute
(   x_return_status           OUT NOCOPY VARCHAR2
 ,  x_msg_count               OUT NOCOPY NUMBER
 ,  x_msg_data                OUT NOCOPY VARCHAR2
 ,  p_item_type               IN  VARCHAR2
 ,  p_item_key                IN  VARCHAR2
 ,  p_actid                   IN  NUMBER
 ,  p_waiting_activity        IN  VARCHAR2
 ,  p_waiting_flow_type       IN  VARCHAR2
 ,  x_resultout               IN OUT NOCOPY VARCHAR2
) ;



PROCEDURE WaitForLineRoute
(   x_return_status           OUT NOCOPY VARCHAR2
 ,  x_msg_count               OUT NOCOPY NUMBER
 ,  x_msg_data                OUT NOCOPY VARCHAR2
 ,  p_item_type               IN  VARCHAR2
 ,  p_item_key                IN  VARCHAR2
 ,  p_actid                   IN  NUMBER
 ,  p_continuation_activity   IN  VARCHAR2
 ,  p_continuation_flow_type  IN  VARCHAR2
 ,  x_resultout               IN OUT NOCOPY VARCHAR2
) ;


--  API name   : START_RESPONSE_FYI_PROCESS
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : START RESPONSE FYI PROCESS
--  Parameters :p_itemtype                IN  VARCHAR2  Item type of the Request Process
--              p_itemkey                 IN  VARCHAR2  Item Key for the Request Process
--              p_orig_response_option    IN  VARCHAR2  := NULL  -- ALL or ONE
--              p_responded_ntf_id        IN  NUMBER    The notification id for the request notification
--              p_responded_comment_id    IN  NUMBER    := NULL   The created Action id while responding
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--              x_return_status           OUT VARCHAR2
--

PROCEDURE  START_RESPONSE_FYI_PROCESS
( p_itemtype                IN   VARCHAR2
, p_itemkey                 IN   VARCHAR2
, p_orig_response_option    IN   VARCHAR2  := NULL  -- ALL or ONE
, p_responded_ntf_id        IN   NUMBER
, p_responded_comment_id    IN   NUMBER    := NULL
, x_msg_count               OUT  NOCOPY  NUMBER
, x_msg_data                OUT  NOCOPY VARCHAR2
, x_return_status           OUT  NOCOPY VARCHAR2
) ;


--
--  API name   : StartValidateDefProcess
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Start Validate Definition Process
--  Parameters :p_step_item_type          IN  VARCHAR2  Item type of the Step Process
--              p_step_item_key           IN  VARCHAR2  Item Key for the Step Process
--              p_responded_ntf_id        IN  NUMBER    The notification id for the request notification
--              p_route_id                IN  NUMBER    Route Id
--              p_route_step_id           IN  NUMBER    Route Step Id
--              p_val_def_item_type       IN  VARCHAR2  Validate Definition WF Item Type
--              p_val_def_process_name    IN  VARCHAR2  Validate Definition WF Process Name
--              p_orig_response           IN  VARCHAR2  := NULL  Original Response Code for Definition Request
--              p_host_url                IN  VARCHAR2  := NULL  Host URL
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--              x_return_status           OUT VARCHAR2
--              x_val_def_item_key        OUT NOCOPY VARCHAR2 Start Definition WF Item Key
--
PROCEDURE  StartValidateDefProcess
(   x_msg_count              OUT  NOCOPY  NUMBER
 ,  x_msg_data               OUT  NOCOPY  VARCHAR2
 ,  x_return_status          OUT  NOCOPY  VARCHAR2
 ,  x_val_def_item_key       OUT  NOCOPY VARCHAR2
 ,  p_step_item_type         IN   VARCHAR2
 ,  p_step_item_key          IN   VARCHAR2
 ,  p_responded_ntf_id       IN   NUMBER
 ,  p_route_id               IN   NUMBER
 ,  p_route_step_id          IN   NUMBER
 ,  p_val_def_item_type      IN   VARCHAR2
 ,  p_val_def_process_name   IN   VARCHAR2
 ,  p_orig_response          IN   VARCHAR2  := NULL
 ,  p_host_url               IN   VARCHAR2  := NULL
) ;



FUNCTION ConvertRouteStatusToActionType
( p_route_status_code IN   VARCHAR2
, p_convert_type      IN   VARCHAR2 := 'RESPONSE' -- 'RESPONSE' or 'WF_PROCESS'
)
RETURN VARCHAR2 ;

-- R12B. Added
FUNCTION ConvNtfWFStatToDistLNStat
( p_route_status_code IN   VARCHAR2
, p_convert_type      IN   VARCHAR2 := NULL -- Future use, 'WF_PROCESS'
)
RETURN VARCHAR2  ;



PROCEDURE reassignRoutePeople(   x_return_status     OUT NOCOPY VARCHAR2
                              ,  x_msg_count         OUT NOCOPY NUMBER
                              ,  x_msg_data          OUT NOCOPY VARCHAR2
                              ,  p_item_type         IN  VARCHAR2
                              ,  p_item_key          IN  VARCHAR2
                              ,  p_notification_id   IN NUMBER
                              ,  p_reassign_mode     IN VARCHAR2) ;




--
--  API name   : RespondToActReqCommentFromUI
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Respond to Action Reqeust Comment from other UI
--               e.g Change Action Reply Page other than Ntf Detal Page
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--              x_processed_ntf_id        OUT NUMBER    processed notification id --                                                      if there is no ntf processed, return 0
--              p_item_type               IN  VARCHAR2  Item Type for the Action Workflow
--              p_item_key                IN  VARCHAR2  Item Key for the Action Workflow
--              p_responder               IN  VARCHAR2  Responder: FND_USER name
--              p_response_comment        IN  VARCHAR2  Response Comment := NULL
--              p_action_source           IN  VARCHAR2  For future use: one of the params
--                                                      in WF_NOTIFICATION.RESPOND API
--
PROCEDURE RespondToActReqCommentFromUI
(   x_return_status     OUT  NOCOPY VARCHAR2
 ,  x_msg_count         OUT  NOCOPY NUMBER
 ,  x_msg_data          OUT  NOCOPY VARCHAR2
 ,  x_processed_ntf_id  OUT  NOCOPY NUMBER
 ,  p_item_type         IN   VARCHAR2
 ,  p_item_key          IN   VARCHAR2
 ,  p_responder         IN   VARCHAR2
 ,  p_response_comment  IN   VARCHAR2  := NULL
 ,  p_action_source     IN   VARCHAR2  := NULL
) ;


--
--  R12B
--  API name   : GrantObjectRoles
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Grant Change Header/Line Subject Object Roles
--               and OFO Roles on Attachment for Header/Line to WF Assignees
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
PROCEDURE GrantObjectRoles
(   p_api_version               IN   NUMBER
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2
 ,  x_msg_count                 OUT  NOCOPY  NUMBER
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2
 ,  p_change_id                 IN   NUMBER
 ,  p_change_line_id            IN   NUMBER
 ,  p_route_id                  IN   NUMBER
 ,  p_step_id                   IN   NUMBER
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_grant_option              IN   VARCHAR2  := NULL                   -- Optionnal
) ;


--
--  R12B
--  API name   : RevokeObjectRoles
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Revoke Change Header/Line Subject Object Roles
--               and OFO Roles on Attachment for Header/Line from WF Assignees
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
--              p_revoke_option   G_REVOKE_ALL will reovked object roles for Header and Lines
--                                G_REVOKE_HEADER will reovked object roles for Header
--                                G_REVOKE_LINE will reovked object roles for Line
--                                p_revoke_option default G_REVOKE_LINE
--
PROCEDURE RevokeObjectRoles
(   p_api_version               IN   NUMBER                             --
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2                   --
 ,  x_msg_count                 OUT  NOCOPY  NUMBER                     --
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
 ,  p_change_id                 IN   NUMBER                             -- Change Id
 ,  p_change_line_id            IN   NUMBER                             -- Change Line Id
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_revoke_option             IN   VARCHAR2  := NULL                  -- Optionnal: G_REVOKE_ALL
 )  ;


PROCEDURE RevokeObjectRoles
(   p_api_version               IN   NUMBER                             --
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2                   --
 ,  x_msg_count                 OUT  NOCOPY  NUMBER                     --
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
 ,  p_change_id                 IN   NUMBER                             -- Change Id
 ,  p_change_line_id            IN   NUMBER                             -- Change Line Id
 ,  p_route_id                  IN   NUMBER
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_revoke_option             IN   VARCHAR2  := NULL                  -- Optionnal
 )  ;

--
--  R12B
--  API name   : RevokeObjectRoles
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Revoke Change Header/Line Subject Object Roles
--               and OFO Roles on Attachment for Header/Line from WF Assignees
--  Parameters :
--              x_return_status           OUT VARCHAR2
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
PROCEDURE RevokeObjectRoles
(   p_api_version               IN   NUMBER                             --
 ,  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
 ,  p_output_dir                IN   VARCHAR2 := NULL
 ,  p_debug_filename            IN   VARCHAR2 := NULL
 ,  x_return_status             OUT  NOCOPY  VARCHAR2                   --
 ,  x_msg_count                 OUT  NOCOPY  NUMBER                     --
 ,  x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
 ,  p_change_id                 IN   NUMBER                             -- Change Id
 ,  p_change_line_id            IN   NUMBER                             -- Change Line Id
 ,  p_route_id                  IN   NUMBER
 ,  p_step_id                   IN   NUMBER
 ,  p_person_ids                IN   FND_TABLE_OF_NUMBER       := NULL
 ,  p_target_objects            IN   FND_TABLE_OF_VARCHAR2_30  := NULL
 ,  p_api_caller                IN   VARCHAR2  := NULL
 ,  p_revoke_option             IN   VARCHAR2  := NULL                  -- Optionnal
) ;


--
--  Bug5136260
--  API name   : SetChangeOrderMRPFlag
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Set Change Order MFP Flag
--  Parameters :p_change_id               IN  NUMBER    Change Id
--              p_mrp_flag                IN  NUMBER    1: Yes G_MRP_FLAG_YES
--                                                      2: No  G_MRP_FLAG_NO
--              p_wf_user_id              IN  NUMBER   := NULL
--              p_api_caller              IN  VARCHAR2 := NULL -- or G_WF_CALL:'WF'
--              x_msg_count               OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--              x_return_status           OUT VARCHAR2
--
PROCEDURE SetChangeOrderMRPFlag
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_change_id         IN  NUMBER
 ,  p_mrp_flag          IN  NUMBER
 ,  p_wf_user_id        IN  NUMBER   := NULL
 ,  p_api_caller        IN  VARCHAR2 := NULL -- or G_WF_CALL:'WF'
) ;




/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/
--  API name   : GetWorkflowMonitorURL
--  Type       : Public
--  Pre-reqs   : None.
--  Function   : Get Workflow Monitor URL based on given p_url_type
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = FND_API.G_VALID_LEVEL_FULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_item_type         IN  VARCHAR2 Required
--                                       Identifies workflow item type
--               p_item_key          IN  VARCHAR2 Required
--                                       Identifies workflow item key
--               p_url_type          IN  VARCHAR2 Optional
--                                       Default = Eng_Workflow_Util.G_MONITOR_DIAGRAM
--                                       Identifies workflow monitor url type
--                                       refer to Monitor URL Type constant variables
--               p_admin_mode        IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--                                       Identifies workflow monitor url is 'ADMIN' or
--                                       'USER' mode
--               p_option            IN  VARCHAR2     Optional
--                                       Default = Null
--                                       In case of p_url_type with G_MONITOR_ADVANCED_ENVELOPE
--                                       Specify 'All' if you wish to return a URL that
--                                       displays the Activities List with all filtering options
--                                       displays checked. If you leave this argument null, then a
--                                       displays URL that displays the Activities List with no
--                                       displays filtering options checked, is returned. This allows
--                                       displays you to append any specific options if you wish.
--                                       displays The default is null.
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--               x_url               OUT NOCOPY VARCHAR2(2000)
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
--      Notes           : Note text
--
PROCEDURE GetWorkflowMonitorURL
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_url_type          IN  VARCHAR2 := Eng_Workflow_Util.G_MONITOR_DIAGRAM
 ,  p_admin_mode        IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_option            IN  VARCHAR2 := NULL
 ,  x_url               OUT NOCOPY VARCHAR2
) ;


--  API name   : StartWorkflow
--  Type       : Public
--  Pre-reqs   : None.
--  Function   : Create and Start Workflow Process
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = FND_API.G_VALID_LEVEL_FULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_item_type         IN  VARCHAR2     Required
--                                       Identifies workflow item type
--               p_process_name      IN  VARCHAR2     Required
--                                       Identifies workflow process name
--               p_change_id         IN  NUMBER       Required
--                                       Identifies Change Object
--               p_change_line_id    IN  NUMBER       Conditionally Required
--                                       Identifies Change Line Object
--                                      (seeded p_item_type except 'ENGCLACT' )
--               p_wf_user_id        IN  NUMBER       Conditionally Required
--                                       Identifies Workflow Owner
--               p_host_url          IN  VARCHAR2     Optional
--                                       Identifies Host URL for OA Page
--               p_action_id         IN  NUMBER       Optional
--                                       Identifies Action for Workflow
--               p_adhoc_party_list  IN  VARCHAR2     Optional
--                                       Identifies paties being assigned to a task for Workflow
--                                       e.g Comment Request wf process will send request ntf to them
--               p_route_id          IN  NUMBER       Optional
--                                       Identifies Route for Approval Routing
--               p_route_step_id     IN  NUMBER       Optional
--                                       Identifies Route Step for Approval Routing
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      IN OUT :
--               x_item_key          IN OUT NOCOPY  VARCHAR2
--                                       Identifies workflow item key
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
--      Notes           : Note text
--
PROCEDURE StartWorkflow
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  x_item_key          IN OUT NOCOPY VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_host_url          IN  VARCHAR2  := NULL
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_adhoc_party_list  IN  VARCHAR2  := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
 ,  p_parent_item_type  IN  VARCHAR2  := NULL
 ,  p_parent_item_key   IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := 'Eng_ChangeWF_Start.log'
) ;

--  API name   : StartWorkflow
--  Type       : Public
--  Pre-reqs   : None.
--  Function   : Create and Start Workflow Process
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = FND_API.G_VALID_LEVEL_FULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_item_type         IN  VARCHAR2     Required
--                                       Identifies workflow item type
--               p_process_name      IN  VARCHAR2     Required
--                                       Identifies workflow process name
--               p_object_name       IN  VARCHAR2     Required
--                                       Identifies Object Name
--               p_object_id1        IN  NUMBER       Required
--                                       Identifies Object
--               p_object_id2        IN  NUMBER       Optional
--                                       Identifies Object
--               p_object_id3        IN  NUMBER       Optional
--                                       Identifies Object
--               p_object_id4        IN  NUMBER       Optional
--                                       Identifies Object
--               p_object_id5        IN  NUMBER       Optional
--                                       Identifies Object
--               p_parent_object_name IN  VARCHAR2    Optional
--                                       Identifies Parent Object Name
--               p_parent_object_id1  IN  NUMBER      Optional
--                                       Identifies Parent Object
--               p_wf_user_id        IN  NUMBER       Conditionally Required
--                                       Identifies Workflow Owner
--               p_host_url          IN  VARCHAR2     Optional
--                                       Identifies Host URL for OA Page
--               p_action_id         IN  NUMBER       Optional
--                                       Identifies Action for Workflow
--               p_adhoc_party_list  IN  VARCHAR2     Optional
--                                       Identifies paties being assigned to a task for Workflow
--                                       e.g Comment Request wf process will send request ntf to them
--               p_route_id          IN  NUMBER       Optional
--                                       Identifies Route for Approval Routing
--               p_route_step_id     IN  NUMBER       Optional
--                                       Identifies Route Step for Approval Routing
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      IN OUT :
--               x_item_key          IN OUT NOCOPY  VARCHAR2
--                                       Identifies workflow item key
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
--      Notes           : Note text
--
PROCEDURE StartWorkflow
(   p_api_version        IN  NUMBER
 ,  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit             IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status      OUT NOCOPY VARCHAR2
 ,  x_msg_count          OUT NOCOPY NUMBER
 ,  x_msg_data           OUT NOCOPY VARCHAR2
 ,  p_item_type          IN  VARCHAR2
 ,  x_item_key           IN OUT NOCOPY VARCHAR2
 ,  p_process_name       IN  VARCHAR2
 ,  p_object_name        IN  VARCHAR2
 ,  p_object_id1         IN  NUMBER
 ,  p_object_id2         IN  NUMBER    := NULL
 ,  p_object_id3         IN  NUMBER    := NULL
 ,  p_object_id4         IN  NUMBER    := NULL
 ,  p_object_id5         IN  NUMBER    := NULL
 ,  p_parent_object_name IN  VARCHAR2  := NULL
 ,  p_parent_object_id1  IN  NUMBER    := NULL
 ,  p_wf_user_id         IN  NUMBER
 ,  p_host_url           IN  VARCHAR2  := NULL
 ,  p_action_id          IN  NUMBER    := NULL
 ,  p_adhoc_party_list   IN  VARCHAR2  := NULL
 ,  p_route_id           IN  NUMBER    := NULL
 ,  p_route_step_id      IN  NUMBER    := NULL
 ,  p_parent_item_type   IN  VARCHAR2  := NULL
 ,  p_parent_item_key    IN  VARCHAR2  := NULL
 ,  p_debug              IN  VARCHAR2  := FND_API.G_FALSE
 ,  p_output_dir         IN  VARCHAR2  := NULL
 ,  p_debug_filename     IN  VARCHAR2  := 'Eng_ChangeWF_Start.log'
) ;


--  API name   : AbortWorkflow
--  Type       : Public
--  Pre-reqs   : None.
--  Function   : Abort Workflow Process
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required

--  API name   : AbortWorkflow
--  Type       : Public
--  Pre-reqs   : None.
--  Function   : Abort Workflow Process
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = FND_API.G_FALSE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = FND_API.G_VALID_LEVEL_FULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_item_type         IN  VARCHAR2     Required
--                                       Identifies workflow item type
--               p_item_key          IN  VARCHAR2     Required
--                                       Identifies workflow item key
--               p_process_name      IN  VARCHAR2     Optional
--                                       Identifies workflow process name
--               p_wf_user_id        IN  NUMBER       Required
--                                       Identifies Workflow Owner
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
--      Notes           : Note text
--
PROCEDURE AbortWorkflow
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2  := NULL
 ,  p_wf_user_id        IN  NUMBER
 ,  p_debug             IN  VARCHAR2  := FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := 'Eng_ChangeWF_Abort.log'
) ;



END Eng_Workflow_Util ;

 

/
