--------------------------------------------------------
--  DDL for Package ENG_CHANGE_LIFECYCLE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_LIFECYCLE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGULCMS.pls 120.6 2007/07/04 10:58:09 sdarbha ship $ */

  -- Global constants --
  -- change objects, subjects
  G_ENG_CHANGE            CONSTANT VARCHAR2(30)  := 'ENG_CHANGE';
  G_ENG_CHG_LINE          CONSTANT VARCHAR2(30)  := 'ENG_CHANGE_LINE';
  G_ENG_REVISED_ITEM      CONSTANT VARCHAR2(30)  := 'ENG_REVISED_ITEM';

  -- change types
  G_ENG_ECO               CONSTANT VARCHAR2(30)  := 'CHANGE_ORDER';
  G_ENG_ATTACHMENT_APPR   CONSTANT VARCHAR2(30)  := 'ATTACHMENT_APPROVAL';
  G_ENG_ATTACHMENT_REVW   CONSTANT VARCHAR2(30)  := 'ATTACHMENT_REVIEW';
  G_ENG_NEW_ITEM_REQ      CONSTANT VARCHAR2(30)  := 'NEW_ITEM_REQUEST';
  G_ENG_ISSUE             CONSTANT VARCHAR2(30)  := 'ISSUE';

  G_ENG_PROMOTE           CONSTANT VARCHAR2(30)  := 'PROMOTE';
  G_ENG_DEMOTE            CONSTANT VARCHAR2(30)  := 'DEMOTE';

  --- Seeded status_type
  G_ENG_DRAFT             CONSTANT NUMBER        := 0;
  G_ENG_OPEN              CONSTANT NUMBER        := 1;
  G_ENG_HOLD              CONSTANT NUMBER        := 2;
  G_ENG_CANCELLED         CONSTANT NUMBER        := 5;
  G_ENG_IMPLEMENTED       CONSTANT NUMBER        := 6;
  G_ENG_APPROVED          CONSTANT NUMBER        := 8;
  G_ENG_IMP_IN_PROGRESS   CONSTANT NUMBER        := 9;
  G_ENG_IMP_FAILED        CONSTANT NUMBER        := 10;
  G_ENG_COMPLETED         CONSTANT NUMBER        := 11;
  G_ENG_REVIEWED          CONSTANT NUMBER        := 12;

  -- line status types
  G_LINE_OPEN             CONSTANT VARCHAR2(30)  := '1';
  G_LINE_CANCELLED        CONSTANT VARCHAR2(30)  := '5';
  G_LINE_COMPLETED        CONSTANT VARCHAR2(30)  := '11';

  -- Seeded approval_status_type for change header
  G_ENG_NOT_SUBMITTED     CONSTANT NUMBER        := 1;  -- Not submitted for approval
  G_ENG_READY_TO_APPR     CONSTANT NUMBER        := 2;  -- Ready for approval
  G_ENG_APPR_REQUESTED    CONSTANT NUMBER        := 3;  -- Approval requested
  G_ENG_APPR_REJECTED     CONSTANT NUMBER        := 4;  -- Approval rejected
  G_ENG_APPR_APPROVED     CONSTANT NUMBER        := 5;  -- Approval approved
  G_ENG_APPR_NO_NEED      CONSTANT NUMBER        := 6;  -- Approval not needed
  G_ENG_APPR_PROC_ERR     CONSTANT NUMBER        := 7;  -- Approval process error
  G_ENG_APPR_TIME_OUT     CONSTANT NUMBER        := 8;  -- Approval time out


  -- Workflow related
  G_ENG_WF_USER_ID        CONSTANT NUMBER        := -10000;
  G_ENG_WF_LOGIN_ID       CONSTANT NUMBER        := '';
  -- Concurrent Program, right now set it to be the same as workflow
  G_ENG_CP_USER_ID        CONSTANT NUMBER        := -10000;
  G_ENG_CP_LOGIN_ID       CONSTANT NUMBER        := '';

  --- Seeded phase level workflow status codes
  -- in Package: ENG_WORKFLOW_UTIL
  -- G_RT_NOT_STARTED       CONSTANT VARCHAR2(30)  := 'NOT_STARTED' ; -- Not Started
  -- G_RT_IN_PROGRESS       CONSTANT VARCHAR2(30)  := 'IN_PROGRESS' ; -- In Progress
  -- G_RT_APPROVED          CONSTANT VARCHAR2(30)  := 'APPROVED' ; -- Approved
  -- G_RT_REJECTED          CONSTANT VARCHAR2(30)  := 'REJECTED' ; -- Rejected
  -- G_RT_TIME_OUT          CONSTANT VARCHAR2(30)  := 'TIME_OUT' ; -- Time Out
  -- G_RT_ABORTED           CONSTANT VARCHAR2(30)  := 'ABORTED' ; -- Aborted
  -- G_RT_COMPLETED         CONSTANT VARCHAR2(30)  := 'COMPLETED' ; -- Completed
  -- G_RT_REPLIED           CONSTANT VARCHAR2(30)  := 'REPLIED' ; -- Replied


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



  -- Internal procedure to raise cm status change events
  /*
  PROCEDURE Raise_Status_Change_Event
  (
    p_change_id                 IN   NUMBER
   ,p_base_cm_type_code         IN   VARCHAR2
   ,p_status_code               IN   NUMBER
   ,p_action_type               IN   VARCHAR2
   ,p_action_id                 IN   NUMBER
  );
  */



  -- Special internal utility procedure to updateBug
  -- Note that the bugDB API may or may not exist so the call must be dynamic
  /*
  PROCEDURE Update_Bug
  (
    p_change_id                 IN   NUMBER               -- header's change_id
   ,p_action_type               IN   VARCHAR2
   ,p_description               IN   VARCHAR2
  );
  */


  -- Internal utility procedure to check if the header is CO and on its last
  -- implement phase
  /*
  PROCEDURE Is_CO_On_Last_Imp_Phase
  (
    p_change_id                 IN   NUMBER
   ,p_api_caller                IN   VARCHAR2
   ,x_is_co_last_phase          OUT  NOCOPY  VARCHAR2
   --,x_curr_status_code          OUT  NOCOPY  NUMBER
   --,x_last_status_code          OUT  NOCOPY  NUMBER
   ,x_auto_demote_status        OUT  NOCOPY  NUMBER
  );
  */


  -- Internal utility procedure to check if the header is CO and its last
  -- implement phase has been used
  /*
  PROCEDURE Is_CO_Last_Imp_Phase_Used
  (
    p_change_id                 IN   NUMBER
   ,x_is_used                   OUT  NOCOPY  VARCHAR2
   ,x_last_status_type          OUT  NOCOPY  NUMBER
   ,x_last_status_code          OUT  NOCOPY  NUMBER
  );
  */


  -- Internal procedure to return if a co has active revised items
  -- active revised items are defined as those with status other than
  -- 5(cancelled) or 6(implemented)
  /*
  PROCEDURE Has_Active_RevItem
  (
    p_change_id                 IN   NUMBER
   ,x_found                     OUT  NOCOPY VARCHAR2
  );
  */



  -- Internal utility procedure to update header approval status
  -- together with launching associated workflow
  /*
  PROCEDURE Update_Header_Appr_Status
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER
   ,p_appr_status               IN   NUMBER                             -- header approval status
   ,p_route_status              IN   VARCHAR2                           -- workflow routing status (for document types)
   ,p_api_caller                IN   VARCHAR2 := 'UI'                   -- must
   ,p_bypass                    IN   VARCHAR2 := 'N'                    -- flag to bypass phase type check
  );
  */






  -- Internal procedure to automatically launch workflow if necessary
  -- (i.e., when start_workflow_flag is set to 'Y') for the specified phase
  -- Note that this procedure may also submit the concurrent program for
  -- implementing ECO as well!!!
  /*
  PROCEDURE Start_WF_OnlyIf_Necessary
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_status_type               IN   NUMBER                             -- new phase type
   ,p_sequence_number           IN   NUMBER                             -- new phase sequence number
   ,p_imp_eco_flag              IN   VARCHAR2 := 'N'                    -- flag for implementECO
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
   ,p_action_type               IN   VARCHAR2 := NULL                   -- or PROMOTE, DEMOTE
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
   ,p_skip_wf                   IN   VARCHAR2 := 'N'                    -- used for eco's last implement phase
  );
  */

  -- Internal procedure for promotion of change header (inc. revItems)
  /*
  PROCEDURE Promote_Header
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
  );
  */

  -- Internal procedure for demotion of change header (inc. revItems)
  -- Note that even though this procedure shares the same argument list
  -- as Promote_Header procedure, the internal logic is quite different,
  -- so it is written as a seperate procedure for easier understanding.
  /*
  PROCEDURE Demote_Header
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  );
  */

  -- Internal procedure for promotion of a revised item
  /*
  PROCEDURE Promote_Revised_Item
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER                             -- revised item sequence id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  );
  */

  -- Internal procedure for demotion of change header (inc. revItems)
  /*
  PROCEDURE Demote_Revised_Item
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER                             -- revised item sequence id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  );
  */

  -- Interface procedure for combining promotion/demotion procedures
  -- Note that this procedure can ONLY be called directly from UI
  PROCEDURE Change_Phase
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_object_name               IN   VARCHAR2 := 'ENG_CHANGE'
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER   := NULL                   -- revised item seq id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := 'UI'                   -- must
   ,p_action_type               IN   VARCHAR2 := G_ENG_PROMOTE          -- promote/demote
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
   ,x_sfa_line_items_exists     OUT NOCOPY VARCHAR2
  );

  PROCEDURE Change_Phase
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_object_name               IN   VARCHAR2 := 'ENG_CHANGE'
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_object_id2                IN   NUMBER   := NULL                   -- revised item seq id
   ,p_status_code               IN   NUMBER                             -- new phase
   ,p_update_ri_flag            IN   VARCHAR2 := 'Y'                    -- can also be 'N'
   ,p_api_caller                IN   VARCHAR2 := 'UI'                   -- must
   ,p_action_type               IN   VARCHAR2 := G_ENG_PROMOTE          -- promote/demote
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
  );

  -- Procedure to be called by WF to update lifecycle states of the change header,
  -- revised items, tasks and lines lifecycle states
  PROCEDURE Update_Lifecycle_States
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER
   ,p_status_code               IN   NUMBER   := NULL                   -- passed only by workflow call for p_route_status = IN_PROGRESS
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- or 'WF'
   ,p_wf_route_id               IN   NUMBER
   ,p_route_status              IN   VARCHAR2
   ,p_comment                   IN   VARCHAR2 := NULL                   -- only used for co promote-to-implement action
  );


  -- Procedure to refresh the route_id of the currently active phase of a particular
  -- change header, called by WF only
  PROCEDURE Refresh_WF_Route
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER
   ,p_status_code               IN   NUMBER
   ,p_wf_route_id               IN   NUMBER
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- or 'WF'
  );


  -- Procedure to automatically initialize lifecycles for a new change header
  -- It also takes care of automatically launching the workflow if nedded
  -- Note that this procedure can ONLY be called directly from UI
  PROCEDURE Init_Lifecycle
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_api_caller                IN   VARCHAR2 := 'UI'                   -- must
   ,p_init_status_code          IN   NUMBER   := NULL                   -- R12
   ,p_init_option               IN   VARCHAR2 := NULL                   -- R12
  );


  -- Procedure to be called by revised item implementation concurrent
  -- program to set its status_type
  PROCEDURE Update_RevItem_Lifecycle
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_rev_item_seq_id           IN   NUMBER
   ,p_status_type               IN   NUMBER                             -- say 10 for imp_failed
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- 'CP'
  );

  -- Reset Phase
  -- R12B
  -- Called when Reset Workflow button pressed in Workflow UI
  -- to reset Dcoument Status
  PROCEDURE Reset_Phase
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_status_code               IN   NUMBER   := NULL                   -- reset phase/status code
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- can also be 'WF'
  ) ;

  -- Sync_LC_Phase_Setup
  -- R12B Sync Workflow Statuses/Lifecycle Phases
  -- If a phase is added or removed in an existing lifecycle setup which is already being used by
  -- some change objects including document lc change objects  then the lifecycles of the change object
  -- would be reflected
  PROCEDURE Sync_LC_Phase_Setup
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_type_id            IN   NUMBER                             -- header's change_type_id
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Future Use
  ) ;


END ENG_CHANGE_LIFECYCLE_UTIL;


/
