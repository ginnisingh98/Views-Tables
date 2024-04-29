--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ACTIONS_UTIL" AS
/* $Header: ENGUCCMB.pls 120.3.12010000.2 2009/11/04 07:33:07 maychen ship $ */

  -- Global variables and constants
  -- ---------------------------------------------------------------------------
     G_PKG_NAME                VARCHAR2(30) := 'ENG_CHANGE_ACTIONS_UTIL';

  -- Global cursors
  -- ---------------------------------------------------------------------------

  -- For Debug
  g_debug_file      UTL_FILE.FILE_TYPE ;
  g_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
  g_output_dir      VARCHAR2(80) := NULL ;
  g_debug_filename  VARCHAR2(30) := 'eng.chgmt.action.log' ;
  g_debug_errmesg   VARCHAR2(240);

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
  )
  IS
       l_found NUMBER := 0;
       l_utl_file_dir    VARCHAR2(2000);

  BEGIN

       IF p_output_dir IS NOT NULL THEN
          g_output_dir := p_output_dir ;

       END IF ;

       IF p_file_name IS NOT NULL THEN
          g_debug_filename := p_file_name ;
       END IF ;

       IF g_output_dir IS NULL
       THEN

           g_output_dir := FND_PROFILE.VALUE('ECX_UTL_LOG_DIR') ;

       END IF;

       select  value
       INTO l_utl_file_dir
       FROM v$parameter
       WHERE name = 'utl_file_dir';

       l_found := INSTR(l_utl_file_dir, g_output_dir);

       IF l_found = 0
       THEN
            RETURN;
       END IF;

       g_debug_file := utl_file.fopen(  g_output_dir
                                      , g_debug_filename
                                      , 'w');
       g_debug_flag := TRUE ;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;

  END Open_Debug_Session ;

  -- Close Debug_Session
  PROCEDURE Close_Debug_Session
  IS
  BEGIN
      IF utl_file.is_open(g_debug_file)
      THEN
        utl_file.fclose(g_debug_file);
      END IF ;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;

  END Close_Debug_Session ;

  -- Test Debug
  PROCEDURE Write_Debug
  (  p_debug_message      IN  VARCHAR2 )
  IS
  BEGIN

      IF utl_file.is_open(g_debug_file)
      THEN
       utl_file.put_line(g_debug_file, p_debug_message);
      END IF ;

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;

  END Write_Debug;

  PROCEDURE Get_Debug_Mode
  (   p_item_type         IN  VARCHAR2
   ,  p_item_key          IN  VARCHAR2
   ,  x_debug_flag        OUT NOCOPY BOOLEAN
   ,  x_output_dir        OUT NOCOPY VARCHAR2
   ,  x_debug_filename    OUT NOCOPY VARCHAR2
  )
  IS

      l_debug_flag VARCHAR2(1) ;

  BEGIN

      -- Get Debug Flag
      l_debug_flag := WF_ENGINE.GetItemAttrText
                              (  p_item_type
                               , p_item_key
                               , '.DEBUG_FLAG'
                               );

      IF FND_API.to_Boolean( l_debug_flag ) THEN
         x_debug_flag := TRUE ;
      END IF ;


      -- Get Debug Output Directory
      x_output_dir  := WF_ENGINE.GetItemAttrText
                              (  p_item_type
                               , p_item_key
                               , '.DEBUG_OUTPUT_DIR'
                               );


      -- Get Debug File Name
      x_debug_filename := WF_ENGINE.GetItemAttrText
                              (  p_item_type
                               , p_item_key
                               , '.DEBUG_FILE_NAME'
                               );

  EXCEPTION
      WHEN OTHERS THEN
         g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
         g_debug_flag := FALSE;


  END Get_Debug_Mode ;




  /********************************************************************
  * API Type      : Local APIs
  * Purpose       : Those APIs are private
  *********************************************************************/

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
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'Create_Change_Action';
    l_api_version        CONSTANT NUMBER := 1.0;

    -- General variables
    l_new_action_id      NUMBER;
    l_parent_action_id   NUMBER;
    l_fnd_user_id        NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
    l_fnd_login_id       NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));
    l_language           VARCHAR2(4) := userenv('LANG');
    l_rowid              ROWID;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Change_Action;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    -- Bug 8921326, init message list if any msg in msg_list before ENG_CHANGE_ACTIONS_PKG.INSERT_ROW
    IF FND_API.to_Boolean( p_init_msg_list )  OR  (FND_MSG_PUB.Count_Msg >0) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;



-- Write debug message if debug mode is on
IF g_debug_flag THEN
   Write_Debug('Eng_Change_Action_Util.Create_Change_Action log');
   Write_Debug('-----------------------------------------------------');
   Write_Debug('p_action_type       : ' || p_action_type );
   Write_Debug('p_object_name       : ' || p_object_name );
   Write_Debug('p_object_id1        : ' || p_object_id1 );
   Write_Debug('p_parent_action_id  : ' || p_parent_action_id );
   Write_Debug('p_status_code       : ' || p_status_code );
   Write_Debug('p_priority_code     : ' || p_priority_code );
   Write_Debug('p_assignee_id       : ' || p_assignee_id );
   Write_Debug('p_response_by_date  : ' || p_response_by_date );
   Write_Debug('p_party_id_list     : ' || p_party_id_list );
   Write_Debug('p_workflow_item_type: ' || p_workflow_item_type );
   Write_Debug('p_workflow_item_key : ' || p_workflow_item_key );
   Write_Debug('p_route_id          : ' || p_workflow_item_key );
   Write_Debug('p_action_date       : ' || p_workflow_item_key );
   Write_Debug('p_change_description: ' || p_workflow_item_key );
   Write_Debug('p_user_id           : ' || p_workflow_item_key );
   Write_Debug('p_api_caller        : ' || p_api_caller );
   Write_Debug('p_local_organization: ' || p_local_organization_id );
   Write_Debug('-----------------------------------------------------');
   Write_Debug('Initializing return status... ' );
END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real code starts here
    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values
    IF ( p_api_caller = 'WF' OR p_api_caller = 'CP' )
    THEN
      l_fnd_user_id := p_user_id;
      l_fnd_login_id := '';
    END IF;

    SELECT eng_change_actions_s.nextval into l_new_action_id
    FROM DUAL;

    -- make sure it is called
    IF ( p_parent_action_id IS NULL)
    THEN
      l_parent_action_id := -1;
    ELSE
      l_parent_action_id := p_parent_action_id;
    END IF;

    ENG_CHANGE_ACTIONS_PKG.INSERT_ROW(
      X_ROWID                     => l_rowid,                -- rowid  (in/out)
      X_ACTION_ID                 => l_new_action_id,        -- action_id
      X_ORIGINAL_SYSTEM_REFERENCE => null,                   -- original_system_reference
      X_WORKFLOW_ITEM_KEY         => p_workflow_item_key,    -- workflow_item_key
      X_REQUEST_ID                => null,                   -- request_id
      X_STATUS_CODE               => p_status_code,          -- status_code
      X_PRIORITY_CODE             => p_priority_code,        -- priority_code
      X_ASSIGNEE_ID               => p_assignee_id,          -- assignee_id
      X_RESPONSE_BY_DATE          => p_response_by_date,     -- response_by_date
      X_PARTY_ID_LIST             => p_party_id_list,        -- party_id_list
      X_PARENT_STATUS_CODE        => p_parent_status_code,   -- parent_status_code
      X_WORKFLOW_ITEM_TYPE        => p_workflow_item_type,   -- workflow_item_type
      X_ROUTE_ID                  => p_route_id,             -- route_id for approval routing
      X_PARENT_ACTION_ID          => l_parent_action_id,     -- parent_action_id
      X_ACTION_TYPE               => p_action_type,          -- action_type
      X_OBJECT_NAME               => p_object_name,          -- object_name
      X_OBJECT_ID1                => p_object_id1,
      X_OBJECT_ID2                => p_object_id2,
      X_OBJECT_ID3                => p_object_id3,
      X_OBJECT_ID4                => p_object_id4,
      X_OBJECT_ID5                => p_object_id5,
      X_DESCRIPTION               => p_change_description,   -- description
      X_PROGRAM_ID                => null,                   -- program_id
      X_PROGRAM_APPLICATION_ID    => null,                   -- program_application_id
      X_PROGRAM_UPDATE_DATE       => null,                   -- program_update_date
      X_CREATION_DATE             => p_action_date,          -- creation_date
      X_CREATED_BY                => l_fnd_user_id,          -- created_by
      X_LAST_UPDATE_DATE          => p_action_date,          -- last_update_date
      X_LAST_UPDATED_BY           => l_fnd_user_id,          -- last_updated_by
      X_LAST_UPDATE_LOGIN         => l_fnd_login_id          -- last_update_login
      -- X_IMPLEMENTATION_REQ_ID     => NULL
      ,X_LOCAL_ORGANIZATION_ID    => p_local_organization_id  --Bug 4704384
    ) ;

    x_change_action_id := l_new_action_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF g_debug_flag THEN
   Write_Debug('Action row inserted successfully... ' );
   Write_Debug('  x_change_action_id   : ' || x_change_action_id );
END IF ;

    --
    -- R12 Added
    -- Raise Business Event in ACTION_TYPE is "REPLIED"
    -- in case that REPLIED action is recorded by Workflow
    -- response.
    -- In case of UI, it will be handled by ChangeActionAMImpl
    --
    --
    IF FND_API.to_Boolean( p_raise_event_flag )
    THEN

IF g_debug_flag THEN
   Write_Debug('p_raise_event_flag is True... ' );
END IF ;

        IF p_action_type = G_ACT_REPLIED
        THEN

            ENG_CHANGE_BES_UTIL.Raise_Post_Comment_Event
            ( p_change_id         => p_object_id1
             ,p_action_type       => p_action_type
             ,p_action_id         => l_new_action_id
            );

IF g_debug_flag THEN
   Write_Debug('After calling ENG_CHANGE_BES_UTIL.Raise_Post_Comment_Event. ..  ' );
END IF ;


        END IF ;

    END IF ; -- p_raise_event_flag is true





    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );


IF g_debug_flag THEN
  Write_Debug('Finish. Eng Of Proc') ;
  Close_Debug_Session ;
END IF ;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Change_Action;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Change_Action;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Create_Change_Action;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;

  END Create_Change_Action;



  /**
   * Called right after creating comment row and submitting workflow
   * to update the workflow-related columns value given the action_id
   */
  PROCEDURE Update_Workflow_Info
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2                           --
   ,p_commit                    IN   VARCHAR2                           --
   ,p_validation_level          IN   NUMBER                             --
   ,p_debug                     IN   VARCHAR2                           --
   ,p_output_dir                IN   VARCHAR2 := '/nfs/log/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2                           --
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_action_id          IN   NUMBER                             --
   ,p_workflow_item_type        IN   VARCHAR2                           --
   ,p_workflow_item_key         IN   VARCHAR2                           --
  )
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Update_Workflow_Info';
    l_api_version     CONSTANT NUMBER := 1.0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Update_Workflow_Info_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('Eng_Change_Action_Util.Update_Workflow_Info log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Action Id         : ' || p_change_action_id );
       Write_Debug('Workflow Item Type: ' || p_workflow_item_type );
       Write_Debug('Workflow Item Key : ' || p_workflow_item_key );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Update the comment table
    UPDATE Eng_Change_Actions
    SET  workflow_item_type = p_workflow_item_type
        ,workflow_item_key = p_workflow_item_key
    WHERE action_id = p_change_action_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_flag THEN
       Write_Debug('Action row updated successfully... ' );
    END IF ;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. Eng Of Proc') ;
      Close_Debug_Session ;
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Workflow_Info_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Workflow_Info_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Update_Workflow_Info_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;

  END Update_Workflow_Info;


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
   ,p_output_dir                IN   VARCHAR2 := '/nfs/log/bis_top/utl/plm115dv/log'                   --
   ,p_debug_filename            IN   VARCHAR2 := 'eng.chgmt.action.respNotif.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_parent_action_id          IN   NUMBER                             --
   ,p_comment                   IN   VARCHAR2   DEFAULT  NULL           --
   ,p_fnd_user_name             IN   VARCHAR2                           --
   ,x_processed_ntf_id          OUT  NOCOPY  NUMBER                     --
  )
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Respond_Notification';
    l_api_version     CONSTANT NUMBER := 1.0;

    l_action_type     VARCHAR2(30);
    l_wf_item_type    VARCHAR2(8);
    l_wf_item_key     VARCHAR2(240);

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Respond_Notification_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('Eng_Change_Action_Util.Respond_Notification log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_parent_action_id : ' || p_parent_action_id );
       Write_Debug('p_comment          : ' || p_comment );
       Write_Debug('p_fnd_user_name    : ' || p_fnd_user_name );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- look up parent action's action type, workflow item type and item key
    SELECT action_type, workflow_item_type, workflow_item_key
      INTO l_action_type, l_wf_item_type, l_wf_item_key
      FROM eng_change_actions
      where action_id = p_parent_action_id;

    ENG_WORKFLOW_UTIL.RespondToActReqCommentFromUI
    ( x_return_status     => l_return_status
     ,x_msg_count         => l_msg_count
     ,x_msg_data          => l_msg_data
     ,x_processed_ntf_id  => x_processed_ntf_id
     ,p_item_type         => l_wf_item_type
     ,p_item_key          => l_wf_item_key
     ,p_responder         => p_fnd_user_name
     ,p_response_comment  => p_comment
     ,p_action_source     => NULL
     );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
    THEN
      x_return_status := l_return_status;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      --#FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_WF_API');
      --#FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF g_debug_flag THEN
      Write_Debug('Successful: Calling ENG_WORKFLOW_UTIL.RespondToActReqCommentFromUI');
    END IF;


    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. Eng Of Proc') ;
      Close_Debug_Session ;
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Respond_Notification_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Respond_Notification_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Respond_Notification_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;

  END Respond_Notification;


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
  ) RETURN NUMBER
  IS
    l_ntf_id number ;
    CURSOR c_waiting_ntf ( p_workflow_item_type varchar2,
                           p_workflow_item_key  varchar2,
                           p_username  varchar2 )
    IS
      SELECT ntf.notification_id
      FROM wf_item_activity_statuses ias,
           wf_notifications ntf
      WHERE ias.item_type = p_workflow_item_type
        AND ias.item_key = p_workflow_item_key
        AND ias.notification_id IS NOT NULL
        AND ias.notification_id = ntf.group_id
        AND ntf.recipient_role = p_username
        AND ntf.status = 'OPEN'
        AND ( EXISTS
              ( SELECT NULL
                FROM WF_MESSAGE_ATTRIBUTES WMA
                WHERE WMA.MESSAGE_NAME = ntf.MESSAGE_NAME
                  AND WMA.MESSAGE_TYPE = ntf.MESSAGE_TYPE
                  AND WMA.MESSAGE_NAME <> 'ENG_STATUS_REVIEW'
                  AND WMA.SUBTYPE = 'RESPOND' )
            );
  BEGIN
    IF p_workflow_item_type IS NOT NULL AND
       p_workflow_item_key IS NOT NULL AND
       p_username IS NOT NULL
    THEN
      FOR l_rec IN c_waiting_ntf ( p_workflow_item_type,
                                   p_workflow_item_key,
                                   p_username )
      LOOP
        l_ntf_id :=  l_rec.notification_id ;
      END LOOP ;
    END IF ;

    return l_ntf_id ;

  END Get_Workflow_Notif_Id;
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
  )
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Delete_Line_Actions';
    l_api_version     CONSTANT NUMBER := 1.0;


    l_action_id       ENG_CHANGE_ACTIONS.ACTION_ID%TYPE;
    CURSOR ECACursor IS
      SELECT ACTION_ID
      FROM ENG_CHANGE_ACTIONS
      WHERE OBJECT_ID1 = p_change_id
        AND OBJECT_ID2 = p_change_line_id
      FOR UPDATE;

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Delete_Line_Actions_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        Open_Debug_Session(p_output_dir, p_debug_filename ) ;
    END IF ;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('Eng_Change_Action_Util.Delete_Line_Actions log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Change_Id         : ' || p_change_id );
       Write_Debug('Change_Line_Id    : ' || p_change_line_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete all the action log records for the line
    OPEN ECACursor;
    LOOP
      FETCH ECACursor INTO l_action_id;
      EXIT WHEN ECACursor%NOTFOUND;
      ENG_CHANGE_ACTIONS_PKG.DELETE_ROW( l_action_id );
    END LOOP;
    CLOSE ECACursor;
    -- End of Delete

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_flag THEN
       Write_Debug('Action rows deleted successfully... ' );
    END IF ;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. Eng Of Proc') ;
      Close_Debug_Session ;
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Line_Actions_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Line_Actions_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Line_Actions_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unxepcted error.') ;
        Close_Debug_Session ;
      END IF ;

  END Delete_Line_Actions;


END ENG_CHANGE_ACTIONS_UTIL;


/
