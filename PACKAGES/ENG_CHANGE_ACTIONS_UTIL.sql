--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ACTIONS_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUCCMS.pls 120.3 2005/12/22 04:25:34 lkasturi noship $ */

  -- Global constants
  G_ENG_APPR_TIME_OUT     CONSTANT NUMBER        := 8;  -- Approval time out
  -- Change action types
  G_ACT_SUBMIT            CONSTANT VARCHAR2(30)  := 'SUBMIT';


  G_ACT_IMP_FAILED        CONSTANT VARCHAR2(30)  := 'IMPLEMENTATION_FAILED';
  G_ACT_IMP_IN_PROGRESS   CONSTANT VARCHAR2(30)  := 'IMPLEMENT_IN_PROGRESS';
  G_ACT_PROPAGATE         CONSTANT VARCHAR2(30)  := 'PROPAGATE_ECO';

  G_ACT_WF_STARTED        CONSTANT VARCHAR2(30)  := 'WF_STARTED';
  G_ACT_WF_COMPLETED      CONSTANT VARCHAR2(30)  := 'WF_COMPLETED';
  G_ACT_WF_APPROVED       CONSTANT VARCHAR2(30)  := 'WF_APPROVED';
  G_ACT_WF_REJECTED       CONSTANT VARCHAR2(30)  := 'WF_REJECTED';
  G_ACT_WF_ABORTED        CONSTANT VARCHAR2(30)  := 'WF_ABORTED';
  G_ACT_WF_TIME_OUT       CONSTANT VARCHAR2(30)  := 'WF_TIME_OUT';
  G_ACT_WF_TRANSFERRED    CONSTANT VARCHAR2(30)  := 'WF_TRANSFERRED';
  G_ACT_WF_DELEGATED      CONSTANT VARCHAR2(30)  := 'WF_DELEGATED';


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


  /**
   * Create new action row in the ENG_CHANGE_ACTIONS and its TL table
   */
  PROCEDURE Create_Change_Action
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := NULL                   --
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_action_type               IN   VARCHAR2                           --
   ,p_object_name               IN   VARCHAR2                           --
   ,p_object_id1                IN   NUMBER                             --
   ,p_object_id2                IN   NUMBER     DEFAULT  NULL           --
   ,p_object_id3                IN   NUMBER     DEFAULT  NULL           --
   ,p_object_id4                IN   NUMBER     DEFAULT  NULL           --
   ,p_object_id5                IN   NUMBER     DEFAULT  NULL           --
   ,p_parent_action_id          IN   NUMBER     DEFAULT  -1             --
   ,p_status_code               IN   NUMBER     DEFAULT  NULL           --
   ,p_priority_code             IN   VARCHAR2   DEFAULT  NULL           --
   ,p_assignee_id               IN   NUMBER     DEFAULT  NULL           --
   ,p_response_by_date          IN   DATE       DEFAULT  NULL           --
   ,p_party_id_list             IN   VARCHAR2   DEFAULT  NULL           --
   ,p_parent_status_code        IN   NUMBER     DEFAULT  NULL           --
   ,p_workflow_item_type        IN   VARCHAR2   DEFAULT  NULL           --
   ,p_workflow_item_key         IN   VARCHAR2   DEFAULT  NULL           --
   ,p_route_id                  IN   NUMBER     DEFAULT  NULL           --
   ,p_action_date               IN   DATE       DEFAULT  SYSDATE        --
   ,p_change_description        IN   VARCHAR2   DEFAULT  NULL           --
   ,p_user_id                   IN   NUMBER     DEFAULT  NULL           --
   ,p_api_caller                IN   VARCHAR2   DEFAULT  NULL           --
   ,p_raise_event_flag          IN   VARCHAR2 := FND_API.G_FALSE        -- R12
   ,p_local_organization_id     IN   NUMBER     DEFAULT  NULL           --Bug 4704384
   ,x_change_action_id          OUT  NOCOPY  NUMBER                     --
  );


  /**
   * Called right after creating action and submitting workflow
   * to update the workflow-related columns value given the change_action_id
   */
  PROCEDURE Update_Workflow_Info
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/nfs/log/bis_top/utl/plm115dv/log'                   --
   ,p_debug_filename            IN   VARCHAR2 := 'eng.chgmt.action.wf.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_action_id          IN   NUMBER                             --
   ,p_workflow_item_type        IN   VARCHAR2   DEFAULT  NULL           --
   ,p_workflow_item_key         IN   VARCHAR2   DEFAULT  NULL           --
  );


  /**
   * If the responder is on the comment request party list, this procedure
   * updates the workflow notification with the response comment, and returns
   * the corresponding notification id;
   * otherwise no update is performed and notification_id is returned as null
   */
  PROCEDURE Respond_Notification
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/nfs/log/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2 := 'eng.chgmt.action.respNotif.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_parent_action_id          IN   NUMBER                             --
   ,p_comment                   IN   VARCHAR2   DEFAULT  NULL           --
   ,p_fnd_user_name             IN   VARCHAR2                           --
   ,x_processed_ntf_id            OUT  NOCOPY  NUMBER                     --
  );


  /**
   * -- Workflow Utility Function
   * Get notification id given workflow item type, workflow item key,
   * and current logon user name, returns null if id doesn't exist
   */
  /*
  FUNCTION Get_Workflow_Notif_Id
  (
    p_workflow_item_type        IN   VARCHAR2                           --
   ,p_workflow_item_key         IN   VARCHAR2                           --
   ,p_username                  IN   VARCHAR2                           --
  ) RETURN NUMBER;                                                      --
  */

  /**
   * Called when a line is deleted
   * to delete all the action log entries associated with that line
   */
  PROCEDURE Delete_Line_Actions
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/nfs/log/bis_top/utl/plm115dv/log'                   --
   ,p_debug_filename            IN   VARCHAR2 := 'eng.chgmt.action.line.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER
   ,p_change_line_id            IN   NUMBER
  );

END ENG_CHANGE_ACTIONS_UTIL;


 

/
