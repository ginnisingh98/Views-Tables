--------------------------------------------------------
--  DDL for Package EGO_REPORT_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_REPORT_WF_UTIL" AUTHID CURRENT_USER AS
/* $Header: EGORWKFS.pls 115.4 2004/01/07 02:12:26 mkimizuk noship $ */
--
--  Constant Variables : GetWorkflowMonitorURL
--

   -- None Return Status
   G_RET_STS_NONE   CONSTANT    VARCHAR2(1) :=  'N';

   -- Seeded OCD Workflow Item Types
   G_STD_ITEM_TYPE                  CONSTANT VARCHAR2(8)  := 'ENGWFSTD';
   G_SEND_REPORT_ITEM_TYPE        CONSTANT VARCHAR2(8)  := 'EGOSREP';


   -- Seeded Eng Worklfow Block Abort Activity
   G_BLOCK_ABORT_ACTIVITY CONSTANT VARCHAR2(30)  := 'BLOCK_ABORT';

  -- Eng Change Object Name
   G_ENG_CHANGE                CONSTANT VARCHAR2(10)  := 'ENG_CHANGE' ;

   -- Workflow Adhoc Role Pre-Fix
   -- ':', '#' or '/' should not be included
   --
   G_ADHOC_PARTY_ROLE   CONSTANT VARCHAR2(20)     := 'EGO_ADHOC,';
   G_OWNER_ROLE         CONSTANT VARCHAR2(20)     := 'EGO_OWNER,';

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


   -- FND Lookup Type: ENG_ROUTE_ASSIGNEE_TYPES
   -- Used for Change Route People's Assignee Type
   --          ENG_CHANGE_ROUTE_PEOPLE.ASSIGNEE_TYPE_CODE
   G_PERSON            CONSTANT VARCHAR2(30) := 'PERSON' ; -- Person
   G_GROUP             CONSTANT VARCHAR2(30) := 'GROUP' ; -- Group
   G_ROLE              CONSTANT VARCHAR2(30) := 'ROLE' ; -- Role


   -- WFSTD_VOTING_OPTION: Standard Voting Option Lookup Codes
   G_WAIT_FOR_ALL_VOTES    CONSTANT VARCHAR2(30) := 'WAIT_FOR_ALL_VOTES' ;
   G_REQUIRE_ALL_VOTES     CONSTANT VARCHAR2(30) := 'REQUIRE_ALL_VOTES' ;
   G_TALLY_ON_EVERY_VOTE   CONSTANT VARCHAR2(30) := 'TALLY_ON_EVERY_VOTE' ;

   -- Monitor URL Types for GetWorkflowMonitorURL
   G_MONITOR_ACCESSKEY         CONSTANT VARCHAR2(15)      := 'ACCESSKEY';
   G_MONITOR_DIAGRAM           CONSTANT VARCHAR2(15)      := 'DIAGRAM';
   G_MONITOR_ENVELOPE          CONSTANT VARCHAR2(15)      := 'ENVELOPE';
   G_MONITOR_ADVANCED_ENVELOPE CONSTANT VARCHAR2(20)      := 'ADVANCED_ENVELOPE';



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


FUNCTION GetUserName
( p_user_id      IN   NUMBER)
 RETURN VARCHAR2;


--  API name   : GetMessageTextBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf text message body
--  Parameters : p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
PROCEDURE GetMessageTextBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY  CLOB
 , document_type  IN OUT  NOCOPY  VARCHAR2
) ;


--  API name   : GetMessageHTMLBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf HTML message body
--  Parameters : p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
PROCEDURE GetMessageHTMLBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
) ;

/*
-- Get Ntf Message PL/SQL Document API Info
PROCEDURE GetNtfMessageDocumentAPI
(   p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  x_message_text_body OUT NOCOPY VARCHAR2
 ,  x_message_html_body OUT NOCOPY VARCHAR2
);
*/



PROCEDURE SetAttributes
(   x_return_status      OUT NOCOPY VARCHAR2
 ,  x_msg_count          OUT NOCOPY NUMBER
 ,  x_msg_data           OUT NOCOPY VARCHAR2
 ,  p_item_type          IN  VARCHAR2
 ,  p_item_key           IN  VARCHAR2
 ,  p_process_name       IN  VARCHAR2
 ,  p_report_url         IN  VARCHAR2
 ,  p_subject            IN  VARCHAR2
 ,  p_message            IN  VARCHAR2
 ,  p_wf_user_id         IN  NUMBER
 ,  p_wf_user_name       IN  VARCHAR2  := NULL
 ,  p_adhoc_party_list   IN  VARCHAR2  := NULL
 ,  p_report_fwk_region  IN  VARCHAR2  := NULL
 ,  p_report_custom_code IN  VARCHAR2  := NULL
 ,  p_browse_mode        IN  VARCHAR2  := NULL
 ,  p_report_org_id      IN  NUMBER    := NULL
) ;


PROCEDURE SetAdhocPartyRole
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_adhoc_party_list  IN  VARCHAR2
) ;


PROCEDURE DeleteAdhocRolesAndUsers
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
) ;




--  API name   : StartWorkflow
--  Type       : Public
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
 ,  p_report_url         IN  VARCHAR2    := NULL
 ,  p_subject            IN  VARCHAR2    := NULL
 ,  p_message            IN  VARCHAR2    := NULL
 ,  p_wf_user_id         IN  NUMBER
 ,  p_adhoc_party_list   IN  VARCHAR2    := NULL
 ,  p_report_fwk_region  IN  VARCHAR2    := NULL
 ,  p_report_custom_code IN  VARCHAR2    := NULL
 ,  p_browse_mode        IN  VARCHAR2    := NULL -- EGO_SUMMARY or EGO_SEQUENTIAL
 ,  p_report_org_id      IN  NUMBER      := NULL
 ,  p_debug              IN  VARCHAR2    := FND_API.G_FALSE
 ,  p_output_dir         IN  VARCHAR2    := NULL
 ,  p_debug_filename     IN  VARCHAR2    := 'EgoReportStartWf.log'
) ;

-- PROCEDURE SELECT_ADHOC_PARTY
--
-- Select Adhoc Party and Set users to Adhoc Role
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE
--           activity has completed
--       - COMPLETE:NONE
--           activity could not find any adhoc parties
PROCEDURE SELECT_ADHOC_PARTY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY  varchar2);


-- PROCEDURE DELETE_ADHOC_ROLES_AND_USERS
--
-- Delete Workflow Adhoc Role and Local Users
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE
--           activity has completed
PROCEDURE DELETE_ADHOC_ROLES_AND_USERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);


END EGO_REPORT_WF_UTIL ;

 

/
