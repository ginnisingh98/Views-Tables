--------------------------------------------------------
--  DDL for Package Body ENG_ATTACHMENT_IMPLEMENTATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ATTACHMENT_IMPLEMENTATION" as
/*$Header: ENGUATTB.pls 120.22.12010000.2 2010/02/03 08:02:06 maychen ship $ */
--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) :=
                              'ENG_ATTACHMENT_IMPLEMENTATION' ;
-- For Debug
  g_debug_file      UTL_FILE.FILE_TYPE ;
  g_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
  g_output_dir      VARCHAR2(80) := NULL ;
  g_debug_filename  VARCHAR2(30) := 'eng.chgmt.attachment.log' ;
  g_debug_errmesg   VARCHAR2(240);
  -- Seeded approval_status_type for change header
  G_ENG_NOT_SUBMITTED    CONSTANT NUMBER        := 1;  -- Not submitted for approval
  G_ENG_READY_TO_APPR    CONSTANT NUMBER        := 2;  -- Ready for approval
  G_ENG_APPR_REQUESTED   CONSTANT NUMBER        := 3;  -- Approval requested
  G_ENG_APPR_REJECTED    CONSTANT NUMBER        := 4;  -- Approval rejected
  G_ENG_APPR_APPROVED    CONSTANT NUMBER        := 5;  -- Approval approved
  G_ENG_APPR_NO_NEED     CONSTANT NUMBER        := 6;  -- Approval not needed
  G_ENG_APPR_PROC_ERR    CONSTANT NUMBER        := 7;  -- Approval process error
  G_ENG_APPR_TIME_OUT    CONSTANT NUMBER        := 8;  -- Approval time out
  --- Seeded phase level workflow status codes
  G_RT_TIME_OUT          CONSTANT VARCHAR2(30)  := 'TIME_OUT' ; -- Time Out
  G_RT_ABORTED           CONSTANT VARCHAR2(30)  := 'ABORTED' ;  -- Aborted
  --- Seeded Attachment Status
  G_SUBMITTED_FOR_APPROVAL  CONSTANT VARCHAR2(30) := 'SUBMITTED_FOR_APPROVAL';
  G_SUBMITTED_FOR_REVIEW    CONSTANT VARCHAR2(30) := 'SUBMITTED_FOR_REVIEW';
  G_PENDING_CHANGE          CONSTANT VARCHAR2(30) := 'PENDING_CHANGE';
  G_APPROVED                CONSTANT VARCHAR2(30) := 'APPROVED';
  G_REJECTED                CONSTANT VARCHAR2(30) := 'REJECTED';
  G_REVIEWED        CONSTANT VARCHAR2(30) := 'REVIEWED';
  /********************************************************************
  * Debug APIs    : Open_Debug_Session, Close_Debug_Session,
  *                 Write_Debug
  * Parameters IN :
  * Parameters OUT:
  * Purpose       : These procedures are for test and debug
  *********************************************************************/
  -- Open_Debug_Session
  Procedure Open_Debug_Session
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
  Procedure Close_Debug_Session
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
  Procedure Write_Debug
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


/* This procedure will be called when a workflow is cancelled at any stage
   of its lifecycle. When a document review/ approval is cancelled the
   status of the document should be reverted to its previous state, the
   state it was in, before it was submitted for review/ approval resp.
*/
Procedure Cancel_Review_Approval(
    p_api_version               IN NUMBER
   ,p_change_id                 IN NUMBER
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
)
IS
cursor C IS
   select attachment_id, previous_status,
          decode(datatype_id, 8, family_id, source_document_id) document_id,
          repository_id, created_by
   from eng_attachment_changes
   where change_id = p_change_id;

l_attachment_id                NUMBER;
l_prev_status                  VARCHAR2(100);
l_document_id                  NUMBER;
l_repository_id                NUMBER;
l_created_by                   NUMBER;
l_fnd_user_id                  NUMBER ;
l_fnd_login_id                 NUMBER ;


BEGIN
  -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 l_fnd_user_id   :=TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
 l_fnd_login_id  :=TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

 OPEN C;
     LOOP
        FETCH C INTO l_attachment_id, l_prev_status,
                     l_document_id, l_repository_id, l_created_by;
        EXIT WHEN C%NOTFOUND;

        dom_attachment_util_pkg.Change_Status(
          p_Attached_document_id   => l_attachment_id
        , p_Document_id            => l_document_id
        , p_Repository_id          => l_repository_id
        , p_Status                 => l_prev_status
        , p_submitted_by           => l_created_by
        , p_last_updated_by        => l_fnd_user_id
       , p_last_update_login       => l_fnd_login_id
        );

        --UPDATE fnd_attached_documents
        --SET status = l_prev_status,
        --    last_update_date = sysdate,
        --    last_updated_by = l_fnd_user_id,
        --    last_update_login = l_fnd_login_id
        --WHERE attached_document_id = l_attachment_id;

     END LOOP;
  CLOSE C;

  EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

END Cancel_Review_Approval;


Procedure Update_Attachment_Status
(
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Update_Attachment_Status.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_workflow_status   IN   VARCHAR2             -- workflow status
   ,p_approval_status           IN   NUMBER                             -- approval status
   ,p_api_caller                IN   VARCHAR2 DEFAULT 'UI'
)
IS

l_attachment_id   number;
l_prev_status     VARCHAR2(30);
l_attach_status   VARCHAR2(30);
l_source_document_id NUMBER;
l_repository_id      NUMBER;
l_category_id        NUMBER;
l_dm_document_id     NUMBER;
l_source_media_id    NUMBER;
l_file_name          VARCHAR2(2048);
l_datatype_id        NUMBER;
l_created_by         NUMBER;
l_fnd_user_id        NUMBER :=TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
l_fnd_login_id       NUMBER :=TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));
l_doc_id             NUMBER;

cursor C IS
   select attachment_id, previous_status, source_document_id, repository_id,
          category_id, family_id, source_media_id, file_name,
          datatype_id, created_by
   from eng_attachment_changes
   where change_id = p_change_id;


l_api_name               CONSTANT VARCHAR2(30)  := 'Update_Attachment_Status';
l_api_version            CONSTANT NUMBER := 1.0;
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_update_approval_status BOOLEAN;

BEGIN
    -- Standard Start of API savepoint
       SAVEPOINT   Update_Attachment_Status;

    -- insert into swarb values(2, 'API caller ', p_api_caller);
    -- commit;

    -- following temp code to test the debug messages
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

    -- insert into swarb values(0, 'FND_USER', to_char(l_fnd_user_id));
    -- commit;

    -- Write debug message if debug mode is on
    IF g_debug_flag THEN
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Update_Attachment_Status log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_approval_status   : ' || p_approval_status );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real code starts here -----------------------------------
    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values

    -- insert into swarb values(1, to_char(p_change_id), p_workflow_status);
    -- commit;

   -- FND_PROFILE package is not available for workflow (WF),
   -- therefore manually set WHO column values

   IF p_api_caller = 'WF' THEN
       l_fnd_user_id := G_ENG_WF_USER_ID;
       l_fnd_login_id := G_ENG_WF_LOGIN_ID;
   ELSIF p_api_caller = 'CP' THEN
       l_fnd_user_id := G_ENG_CP_USER_ID;
       l_fnd_login_id := G_ENG_CP_LOGIN_ID;
   END IF;

     --insert into swarb values(3, 'FND User', to_char(l_fnd_user_id));
     --commit;

   /* Bug: 4187851
      When workflow is aborted, the status should remain as
      Submitted For Approval. Removed code for abort/ time out
      since this code since the code was changing the status
      to previous status which is no longer true.
      Status will only be changed to previous status when the
      workflow in cancelled.

   */ -- Bug: 4187851


   Get_Attachment_Status(p_change_id, p_approval_status, l_attach_status);

    -- insert into swarb values(4, 'After get attachment', l_attach_status);
    -- commit;

   IF g_debug_flag THEN
      Write_Debug('p_approval_status:'||p_approval_status);
      Write_Debug('l_attach_status:'||l_attach_status);
   END IF ;

   OPEN C;
   LOOP
   FETCH C INTO l_attachment_id, l_prev_status,
                l_source_document_id, l_repository_id,
                l_category_id, l_dm_document_id,
                l_source_media_id, l_file_name,
                l_datatype_id, l_created_by;
   EXIT WHEN C%NOTFOUND;

   --  insert into swarb values(5, to_char(l_attachment_id), l_prev_status);
   --  commit;

   l_update_approval_status:=false;

   -- Only change the status when the approval status is "Approved"
   --  or rejected.
   -- If status is "Approvel Requested", document att. status = "Submitted
   --                                                         For Approval"
   -- If status is "Approved", document attachment status = Approved
   -- If status is "Rejected", document attachment status = "Rejected"
   -- If workflow Status is "Promoted/ Demoted" then do not change the
   -- attachment status

   --insert into swarb values(.1, 'Approval_status', p_approval_status);
   --commit;

   IF (p_approval_status=''||G_ENG_APPR_APPROVED
       OR p_approval_status =''|| G_ENG_APPR_REJECTED
       OR p_approval_status =''|| G_ENG_APPR_REQUESTED) THEN

      IF (l_attach_status is not null OR length(l_attach_status)>0) THEN

         --insert into swarb values(.2, 'In approval status',to_char(l_attach_status));
         --commit;

         l_update_approval_status:=true;
      END IF;

   END IF; --  IF (p_approval_status=''||G_ENG_APPR_APPROVED

   --insert into swarb values(.1, 'After Approval_status', null);
   --commit;

   IF (l_update_approval_status) THEN

     -- If it is a webservices file, then pass the dm_document_id
     -- else fnd_document_id
     if (l_datatype_id = 8) then
        l_doc_id := l_dm_document_id;
     else
        l_doc_id := l_source_document_id;
     end if;

     dom_attachment_util_pkg.Change_Status(
         p_Attached_document_id   => l_attachment_id
       , p_Document_id            => l_doc_id
       , p_Repository_id          => l_repository_id
       , p_Status                 => l_attach_status
       , p_submitted_by           => l_created_by
       , p_last_updated_by        => l_fnd_user_id
       , p_last_update_login      => l_fnd_login_id
     );

    END IF;  --  IF (l_update_approval_status) THEN
   END LOOP;
   CLOSE C;


   Project_deliverable_tracking(P_CHANGE_ID => p_change_id,
                                 P_ATTACHMENT_ID => l_attachment_id,
                                 P_DOCUMENT_ID => l_source_document_id,
                                 P_ATTACH_STATUS => l_attach_status,
                                 P_CATEGORY_ID => l_category_id,
                                 P_REPOSITORY_ID => l_repository_id,
                                 P_DM_DOCUMENT_ID => l_dm_document_id,
                                 P_SOURCE_MEDIA_ID => l_source_media_id,
                                 P_FILE_NAME => l_file_name,
                                 P_CREATED_BY => l_created_by,
                                 X_RETURN_STATUS => x_return_status,
                                 X_MSG_COUNT => x_msg_count,
                                 X_MSG_DATA => x_msg_data
                                );



    -- insert into swarb values(100, 'After project call', null);
    -- commit;

    -- Standard ending code ------------------------------------------------

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Msg Data' || x_msg_data);
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
    END IF ;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Update_Attachment_Status;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Msg Data' || x_msg_data);
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Update_Attachment_Status;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Msg Data' || x_msg_data);
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
          ROLLBACK TO Update_Attachment_Status;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Msg Data' || x_msg_data);
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;

END Update_Attachment_Status;


Procedure Project_deliverable_tracking(
    p_change_id                 IN   NUMBER
   ,p_attachment_id             IN   NUMBER
   ,p_document_id               IN   NUMBER
   ,p_attach_status             IN   VARCHAR2
   ,p_category_id               IN   NUMBER
   ,p_repository_id             IN   NUMBER
   ,p_dm_document_id            IN   NUMBER
   ,p_source_media_id           IN   NUMBER
   ,p_file_name                 IN   VARCHAR2
   ,p_created_by                IN   NUMBER
   ,x_return_status             OUT  NOCOPY  VARCHAR2
   ,x_msg_count                 OUT  NOCOPY  NUMBER
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
)
IS

  cursor c_get_change_project_info IS
   select project_id, task_id, organization_id
   from eng_engineering_changes
   where change_id = p_change_id;

   cursor c_get_curr_oper_unit_id(p_orgid NUMBER) IS
   SELECT OPERATING_UNIT
   FROM ORG_ORGANIZATION_DEFINITIONS
   WHERE ORGANIZATION_ID = p_orgid;

  l_project_id                 NUMBER;
  l_task_id                    NUMBER;
  l_base_change_mgmt_type_code VARCHAR2(30);
  l_existing_comp_percent      NUMBER;
  l_percent_complete           NUMBER;
  l_task_status                VARCHAR2(10);
  l_fnd_user_id                NUMBER;
  l_responsibility_id          NUMBER;
  l_fnd_login_id               NUMBER;
  l_new_attached_doc_id        NUMBER;
  l_org_id           NUMBER;
  l_operating_unit_id          NUMBER;

BEGIN

  --    insert into swarb values(7.0, 'In project deliverable', to_char(p_change_id));
  --   commit;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Cursor to get project and task based on the change_id
   OPEN c_get_change_project_info;
   FETCH c_get_change_project_info into l_project_id, l_task_id, l_org_id;
   CLOSE c_get_change_project_info;

   --  insert into swarb values(7, to_char(l_project_id), to_char(l_task_id));
   --  commit;

   IF g_debug_flag THEN
      Write_Debug('l_task_id:'||to_char(l_task_id));
   END IF ;

   -- Execute following only for  attachment approval
   SELECT ecot.base_change_mgmt_type_code INTO l_base_change_mgmt_type_code
   FROM   eng_engineering_changes eec,eng_change_order_types ecot
   WHERE eec.change_id = p_change_id
   AND ecot.change_order_type_id = eec.change_order_type_id;

   --  insert into swarb values(8, 'change orde type', l_base_change_mgmt_type_code);
   --  commit;


   IF (l_base_change_mgmt_type_code = 'ATTACHMENT_APPROVAL') THEN

     IF ( l_task_id IS NOT NULL) THEN

       IF g_debug_flag THEN
         Write_Debug('l_task_id is not null..');
       END IF ;

       l_fnd_user_id := fnd_global.user_id;
       IF g_debug_flag THEN
         Write_Debug('l_fnd_user_id:'|| to_char(l_fnd_user_id));
       END IF ;

       BEGIN

          --  insert into swarb values(8.7, 'Inside begin', null);
          --  commit;

          SELECT max(completed_percentage) into l_existing_comp_percent
            FROM PA_TASK_PROGRESS_AMG_V
           WHERE project_id = l_project_id and task_id = l_task_id ;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_existing_comp_percent := 0;
       END;

       --  insert into swarb values(9, 'Completed %', to_char(l_existing_comp_percent));
       --  commit;

       IF g_debug_flag THEN
        Write_Debug('completed_percentage:'|| to_char(l_existing_comp_percent));
       END IF ;

       -- Commenting out the sql since a guest user from workflow
       --may not have Project Super User responsibility

       -- SELECT responsibility_id INTO l_responsibility_id
       --   FROM pa_user_resp_v
       --  WHERE user_id=l_fnd_user_id
       --    AND responsibility_name = 'Project Super User';

      SELECT responsibility_id INTO l_responsibility_id
        FROM fnd_responsibility
       WHERE responsibility_key = 'PA_PRM_PROJ_SU';

      -- insert into swarb values(10, 'Responsibility id', l_responsibility_id);
      -- commit;

       IF g_debug_flag THEN
          Write_Debug('l_responsibility_id:'||to_char(l_responsibility_id));
          Write_Debug('p_attachment_id:'||to_char(p_attachment_id));
          Write_Debug('p_attach_status:'||p_attach_status);
       END IF ;

       IF(p_attach_status = G_SUBMITTED_FOR_APPROVAL
           AND p_attachment_id IS NOT NULL) THEN

         IF g_debug_flag THEN
            Write_Debug('submitted for approval!');
         END IF ;

         l_fnd_login_id := fnd_global.login_id;

         IF g_debug_flag THEN
            Write_Debug('p_document_id:'||to_char(p_document_id));
            Write_Debug('l_fnd_login_id:'||to_char(l_fnd_login_id));
         END IF ;

         -- First creating a record in fnd_attached_documents with the
         -- task id

         dom_attachment_util_pkg.Create_Attachment(
                   x_Attached_document_id  => l_new_attached_doc_id
                   , p_Document_id         => p_document_id
                   , p_Entity_name         => 'PA_TASKS'
                   , p_Pk1_value           => l_task_id
                   , p_category_id         => p_category_id
                   , p_repository_id       => p_repository_id
                   , p_version_id          => p_dm_document_id
                   , p_family_id           => p_source_media_id
                   , p_file_name           => p_file_name
                   , p_created_by          => l_fnd_user_id
                   , p_last_update_login   => l_fnd_login_id
               );

         -- Then changing the status of the attachment

         Dom_Attachment_util_pkg.Change_Status(
                   p_Attached_document_id   => l_new_attached_doc_id
                   , p_Document_id          => p_document_id
                   , p_Repository_id        => p_repository_id
                   , p_Status               => p_attach_status
                   , p_submitted_by         => p_created_by
                   , p_last_updated_by      => l_fnd_user_id
                   , p_last_update_login    => l_fnd_login_id
                 );

         --  insert into swarb values(12, 'After DOM API', to_char(l_new_attached_doc_id));
         --  commit;

       l_percent_complete := 50;
       l_task_status := '125';

     ELSIF(p_attach_status = G_REJECTED AND p_attachment_id IS NOT NULL) THEN

       l_percent_complete := l_existing_comp_percent;
       l_task_status := '125';

     ELSIF(p_attach_status = G_APPROVED AND p_attachment_id IS NOT NULL) THEN

       l_percent_complete := 100;
       l_task_status := '127';

     END IF; -- IF (p_attach_status = G_SUBMITTED...)
--bug 5365842 fix begins
     -- following PA API call to change the task status to In progress
/* commented out and replaced with PA_MOAC_UTILS.MO_INIT_SET_CONTEXT for bug 5365842
     PA_INTERFACE_UTILS_PUB.SET_GLOBAL_INFO(
          P_API_VERSION_NUMBER => 1,
          P_RESPONSIBILITY_ID => l_responsibility_id ,
          P_USER_ID => l_fnd_user_id,
          P_RETURN_STATUS => x_return_status,
          P_MSG_COUNT => x_msg_count,
          P_MSG_DATA => x_msg_data);*/

     OPEN c_get_curr_oper_unit_id(l_org_id);
     FETCH c_get_curr_oper_unit_id INTO l_operating_unit_id;
     CLOSE c_get_curr_oper_unit_id;

    /*as per the base bug 5372737 we should pass operating unit id for orgid
    and product_code as PA*/
     PA_MOAC_UTILS.MO_INIT_SET_CONTEXT
     (
      p_org_id => l_operating_unit_id ,
      p_product_code => 'PA',
      p_msg_count => x_msg_count,
      p_msg_data => x_msg_data,
      p_return_status => x_return_status
     );
--bug 5365842 fix ends
     PA_STATUS_PUB.UPDATE_PROGRESS(
          P_API_VERSION_NUMBER => 1 ,
          P_RETURN_STATUS => x_return_status,
          P_MSG_COUNT => x_msg_count,
          P_MSG_DATA => x_msg_data,
          P_PROJECT_ID => l_project_id,
          P_TASK_ID => l_task_id,
          P_AS_OF_DATE => sysdate,
          P_STRUCTURE_TYPE => 'WORKPLAN',
          P_PERCENT_COMPLETE => l_percent_complete,
          p_task_status => l_task_status);


      -- insert into swarb values(17, 'After PA APIs - Approved', x_return_status);
      -- commit;

   END IF; -- if Task is not null , means task is assigned to the approval
 END IF; -- if base change mgmt type code is attachment approval

 EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       Write_Debug('Msg Data' || x_msg_data);

END Project_Deliverable_Tracking;




Procedure Implement_Attachment_Change
(
     p_api_version                  IN   NUMBER                             --
       ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
       ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_output_dir                IN   VARCHAR2 := NULL                   --
       ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Implement_Attachment_Change.log'
       ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
       ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
       ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
       ,p_change_id                 IN   NUMBER                             -- header's change_id
       ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
       ,p_approval_status           IN   NUMBER                             -- approval status

)
IS
l_action_type         varchar2(30);
l_attachment_id       number;
l_source_document_id  NUMBER;
l_entity_name         VARCHAR2(40);
l_pk1_value           VARCHAR2(100);
l_pk2_value           VARCHAR2(100);
l_pk3_value           VARCHAR2(100);
l_pk4_value           VARCHAR2(100);
l_pk5_value           VARCHAR2(100);
l_category_id         NUMBER;
l_file_name           VARCHAR2(255);
l_dest_document_id    NUMBER;
l_dest_version_label  VARCHAR2(255);
l_dest_path           VARCHAR2(1000);
l_new_file_name       VARCHAR2(255);
l_new_description     VARCHAR2(255);
l_new_category_id     NUMBER;

l_fnd_user_id         NUMBER;
l_fnd_login_id        NUMBER;

l_document_id         NUMBER;
l_row_id              VARCHAR2(2000);
l_attach_status       VARCHAR2(30);
l_datatype_id         NUMBER;
l_attach_doc_id       NUMBER;
l_media_id            NUMBER;
l_created_by          NUMBER;
l_last_update_login   NUMBER;
l_repository_id       NUMBER;
l_dm_document_id      NUMBER;
l_family_id           NUMBER;
l_dm_type             VARCHAR2(30);
l_protocol            VARCHAR2(30);

cursor C IS
   select a.action_type, a.attachment_id, a.source_document_id,
          a.entity_name, a.pk1_value, a.pk2_value, a.pk3_value,
          a.pk4_value, a.pk5_value, a.category_id, a.dest_version_label,
          a.file_name, a.new_file_name, a.new_description,
          a.new_category_id, a.created_by, a.last_update_login,
          a.repository_id,
          decode(b.protocol, 'WEBDAV', -1, a.family_id) family_id,
          a.dm_type, b.protocol
   from   eng_attachment_changes a, dom_repositories b
   where  change_id = p_change_id
   and    revised_item_sequence_id = p_rev_item_seq_id
   and    a.repository_id = b.id;


l_api_name           CONSTANT VARCHAR2(30)  := 'Implement_Attachment_Change';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_message            VARCHAR2(4000);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Implement_Attachment_Change;

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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Implement_Attachment_Change log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_rev_item_seq_id   : ' || p_rev_item_seq_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real code starts here -----------------------------------------------

    -- get values for fnd_user and fnd_login
    SELECT fnd_global.user_id, fnd_global.login_id
      INTO l_fnd_user_id, l_fnd_login_id
      FROM dual;

   -- First check if there are floating versions in the CO to be implemented.
   -- if there are flaoting version, check its change policy and ensure that
   -- it is not under CO Required. If it is CO required, the implementation
   -- should fail.

    Validate_floating_version (
       p_api_version     => 1
      ,p_change_id       => p_change_id
      ,p_rev_item_seq_id => p_rev_item_seq_id
      , x_return_status  => x_return_status
      , x_msg_count      => x_msg_count
      , x_msg_data       => x_msg_data
    );


   -- insert into swarb values(0, 'After fnd_user', to_char(p_approval_status));
   -- commit;

   Get_Attachment_Status(p_change_id, p_approval_status, l_attach_status);

   -- insert into swarb values(-1, 'After get_attachment_status', l_attach_status);
   -- commit;

    OPEN C;
       LOOP

       FETCH C
       INTO l_action_type, l_attachment_id, l_source_document_id, l_entity_name,
            l_pk1_value, l_pk2_value, l_pk3_value, l_pk4_value, l_pk5_value,
            l_category_id, l_dest_version_label, l_file_name, l_new_file_name,
            l_new_description, l_new_category_id, l_created_by,
            l_last_update_login, l_repository_id, l_family_id, l_dm_type,
            l_protocol;

       EXIT WHEN C%NOTFOUND;

            -- insert into swarb values(1, 'Inside loop ->', to_char(l_source_document_id));
            --  commit;

         -- Get the document_id for the attachment
         SELECT document_id INTO l_document_id
           FROM fnd_documents
          WHERE document_id = l_source_document_id;

         -- insert into swarb values(1, 'attachment not null->', to_char(l_document_id));
        -- commit;

        IF l_document_id IS NULL THEN
           l_message := 'ENG_DETACH_IMP_ERROR';
           FND_MESSAGE.Set_Name('ENG', l_message);
           FND_MESSAGE.Set_Token('FILE_NAME', l_file_name);
           FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


       IF l_action_type = 'ATTACH' THEN

           -- Swarnali - no longer needed with the new DOM package

           -- select fnd_attached_documents_s.nextval
           --   into l_attachment_id from dual;

            -- insert into swarb values(2, 'inside attach ->', to_char(l_attachment_id));
            -- commit;

            dom_attachment_util_pkg.Attach(
                   x_Attached_document_id  => l_attachment_id
                   , p_Document_id         => l_source_document_id
                   , p_Entity_name         => l_entity_name
                   , p_Pk1_value           => l_pk1_value
                   , p_Pk2_value           => l_pk2_value
                   , p_Pk3_value           => l_pk3_value
                   , p_Pk4_value           => l_pk4_value
                   , p_Pk5_value           => l_pk5_value
                   , p_category_id         => l_category_id
                   , p_created_by          => l_created_by
                   , p_last_update_login   => l_last_update_login
             );

       elsif l_action_type = 'DETACH' then

            -- Call DOM API to Detach attachments
            dom_attachment_util_pkg.Detach(
                  p_Attached_document_id  => l_attachment_id
            );

       elsif l_action_type = 'CHANGE_VERSION_LABEL' then

              dom_attachment_util_pkg.Change_Version(
                   p_Attached_document_id  => l_attachment_id
                   , p_Document_id         => l_source_document_id
                   , p_last_updated_by     => l_created_by
                   , p_last_update_login   => l_last_update_login
              );

        -- In modify action, you can change values for file_name,
        -- desc and category
        elsif l_action_type = 'MODIFY' then

              dom_attachment_util_pkg.Update_Document(
                   p_Attached_document_id  => l_attachment_id
                   , p_FileName            => l_new_file_name
                   , p_Description         => l_new_description
                   , p_Category            => l_new_category_id
                   , p_last_updated_by     => l_created_by
                   , p_last_update_login   => l_last_update_login
               );

         end if;

         -- Updating the status of the attached document

         -- If it is a floating version file then do not change its status
         -- l_family_id stores the dm_document_id information. If l_family_id
         -- = 0, that means it is a floating version

         if (l_action_type <> 'DETACH' or l_dm_type <> 'FOLDER') then
           if (l_family_id <> 0) then -- <> 0 is not a floating version

              -- If protocol is WEBSERVICES then pass the DM_DOCUMENT_ID instead
              -- of FND_DOCUMENT_ID which is stored in source_document_id

              if (l_protocol = 'WEBSERVICES') then
                 l_source_document_id := l_family_id;
              end if;

              dom_attachment_util_pkg.Change_Status(
                  p_attached_document_id => l_attachment_id
                , p_document_id          => l_source_document_id
                , p_repository_id        => l_repository_id
                , p_status               => l_attach_status
                , p_submitted_by         => l_created_by
                , p_last_updated_by      => l_fnd_user_id
                , p_last_update_login    => l_fnd_login_id
              );
           end if;
         end if;

      end loop;
   close C;

  -- Standard ending code ------------------------------------------------
    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Implement_Attachment_Change;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Implement_Attachment_Change;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
          ROLLBACK TO Implement_Attachment_Change;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;

END Implement_Attachment_Change;


-- This API is DEPRICATED. Please use DOM_ATTACHMENT_UTIL_PKG.copy_attachments
Procedure Copy_Attachment (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Copy_Attachment.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,x_new_attachment_id         OUT  NOCOPY  NUMBER
   ,p_source_attachment_id       IN   NUMBER                             -- source attached document id
   ,p_source_status              IN   VARCHAR2                           -- source attachment status
   ,p_dest_entity_name     IN   VARCHAR2                           -- destination entity name
   ,p_dest_pk1_value             IN   VARCHAR2                           -- destination pk1 value
   ,p_dest_pk2_value             IN   VARCHAR2                           -- destination pk2 value
   ,p_dest_pk3_value             IN   VARCHAR2                           -- destination pk3 value
   ,p_dest_pk4_value             IN   VARCHAR2                           -- destination pk4 value
   ,p_dest_pk5_value             IN   VARCHAR2                           -- destination pk5 value
)
IS
l_datatype_id     NUMBER;
l_category_id     NUMBER;
l_source_doc_id     NUMBER;
l_file_name       VARCHAR2(255);
l_language        VARCHAR2(30);
l_description     VARCHAR2(255);
l_media_id        NUMBER;
l_dm_node         NUMBER;
l_dm_folder_path  VARCHAR2(1000);
l_dm_type         VARCHAR2(30);
l_dm_document_id  VARCHAR2(255);
l_dm_version_number VARCHAR2(4000);
l_row_id            varchar2(2000);
l_seq_num           number := 1;
l_auto_add_flag     varchar2(1)    := 'N';
l_attached_doc_id   number;
l_doc_id            NUMBER;
l_security_type     number         := 1;
l_security_id       number;
l_publish_flag      varchar2(1)    := 'Y';
l_usage_type        varchar2(1)    := 'O';
l_fnd_user_id        NUMBER :=TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
l_fnd_login_id       NUMBER :=TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));
l_api_name           CONSTANT VARCHAR2(30)  := 'Copy_Attachment';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT   Copy_Attachment;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Implement_Attachment_Change log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_source_attachment_id         : ' || p_source_attachment_id );
       Write_Debug('p_source_status                : ' || p_source_status );
       Write_Debug('p_dest_entity_name             : ' || p_dest_entity_name );
       Write_Debug('p_dest_pk1_value               : ' || p_dest_pk1_value );
       Write_Debug('p_dest_pk2_value               : ' || p_dest_pk2_value );
       Write_Debug('p_dest_pk3_value               : ' || p_dest_pk3_value );
       Write_Debug('p_dest_pk4_value               : ' || p_dest_pk4_value );
       Write_Debug('p_dest_pk5_value               : ' || p_dest_pk5_value );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Real code starts here -----------------------------------------------
   l_fnd_user_id := fnd_global.user_id; -- -1; -- Bug 3700111
   l_fnd_login_id := fnd_global.login_id; -- ''; -- Bug 3700111
   select userenv('LANG') into l_language from dual;
   select category_id, document_id into l_category_id, l_source_doc_id from fnd_attached_documents where attached_document_id = p_source_attachment_id;
   select datatype_id, security_type, dm_node, dm_folder_path, dm_type, dm_document_id, dm_version_number
   into l_datatype_id, l_security_type, l_dm_node, l_dm_folder_path, l_dm_type, l_dm_document_id, l_dm_version_number
   from fnd_documents where document_id = l_source_doc_id;
   select file_name, description, media_id into l_file_name, l_description, l_media_id from fnd_documents_tl where document_id = l_source_doc_id and language = userenv('LANG');
   select fnd_attached_documents_s.nextval
   into   l_attached_doc_id
   from   dual;
   fnd_attached_documents_pkg.Insert_Row(
                     X_Rowid                      => l_row_id,
                     X_attached_document_id       => l_attached_doc_id,
                     X_document_id                => l_doc_id,
                     X_creation_date              => sysdate,
                     X_created_by                 => l_fnd_user_id,
                     X_last_update_date           => sysdate,
                     X_last_updated_by            => l_fnd_user_id,
                     X_last_update_login          => l_fnd_login_id,
                     X_seq_num                    => l_seq_num,
                     X_entity_name                => p_dest_entity_name,
                     X_column1                    => null,
                     X_pk1_value                  => p_dest_pk1_value,
                     X_pk2_value                  => p_dest_pk2_value,
                     X_pk3_value                  => p_dest_pk3_value,
                     X_pk4_value                  => p_dest_pk4_value,
                     X_pk5_value                  => p_dest_pk5_value,
                  X_automatically_added_flag      => l_auto_add_flag,
                      X_datatype_id               => l_datatype_id,
                  X_category_id                   => l_category_id,
                  X_security_type                 => l_security_type,
                  X_publish_flag                  => l_publish_flag,
                  X_usage_type                    => l_usage_type,
                  X_language                      => l_language,
                  X_description                   => l_description,
                  X_file_name                     => l_file_name,
                  X_media_id                      => l_media_id,
                  X_doc_attribute_Category        => null,
                  X_doc_attribute1                => null,
                  X_doc_attribute2                => null,
                  X_doc_attribute3                => null,
                  X_doc_attribute4                => null,
                  X_doc_attribute5                => null,
                  X_doc_attribute6                => null,
                  X_doc_attribute7                => null,
                  X_doc_attribute8                => null,
                  X_doc_attribute9                => null,
                  X_doc_attribute10               => null,
                  X_doc_attribute11               => null,
                  X_doc_attribute12               => null,
                  X_doc_attribute13               => null,
                  X_doc_attribute14               => null,
                  X_doc_attribute15               => null,
                  X_create_doc                    => 'Y' -- Fix for 3762710
                   );
     update fnd_attached_documents set category_id = l_category_id, status = p_source_status where attached_document_id = l_attached_doc_id;
     update fnd_documents set dm_node = l_dm_node, dm_folder_path = l_dm_folder_path, dm_type = l_dm_type, dm_document_id = l_dm_document_id, dm_version_number = l_dm_version_number where document_id = l_doc_id;
   x_new_attachment_id := l_attached_doc_id;

     -- Standard ending code ------------------------------------------------
    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Copy_Attachment;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Copy_Attachment;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
          ROLLBACK TO Copy_Attachment;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;

END Copy_Attachment;

Procedure Get_Attachment_Status (
    p_change_id                 IN   NUMBER
   ,p_header_status       IN   NUMBER
   ,x_attachment_status         OUT  NOCOPY VARCHAR2
)
IS
l_change_order_type_id      number;
l_base_change_mgmt_type_code    varchar2(30);
BEGIN
    select change_order_type_id into l_change_order_type_id
  from   eng_engineering_changes
  where  change_id = p_change_id;
  select base_change_mgmt_type_code into l_base_change_mgmt_type_code
  from   eng_change_order_types
  where  change_order_type_id = l_change_order_type_id;
  if(l_base_change_mgmt_type_code = 'ATTACHMENT_APPROVAL') then
    if(p_header_status = G_ENG_APPR_REQUESTED) then
      x_attachment_status := G_SUBMITTED_FOR_APPROVAL;
    return;
    elsif(p_header_status = G_ENG_APPR_APPROVED) then
      x_attachment_status := G_APPROVED;
    return;
    elsif(p_header_status = G_ENG_APPR_REJECTED) then
      x_attachment_status := G_REJECTED;
    return;
    end if;
  elsif(l_base_change_mgmt_type_code = 'ATTACHMENT_REVIEW') then
    if(p_header_status = G_ENG_APPR_REQUESTED) then
      x_attachment_status := G_SUBMITTED_FOR_REVIEW;
    return;
    elsif(p_header_status = G_ENG_APPR_APPROVED) then
      x_attachment_status := G_REVIEWED;
    return;
    end if;
  elsif(l_base_change_mgmt_type_code = 'CHANGE_ORDER') then
    if(p_header_status = G_ENG_NOT_SUBMITTED) then
       x_attachment_status := G_APPROVED;       -- x_attachment_status := G_PENDING_CHANGE;
           -- vamohan: Fix for 3471772: commented out previous line since for a CO, once att changes are implemented, approval status in FND_ATTACHED_DOCUMENTS should be nulled out
    return;
    elsif(p_header_status = G_ENG_APPR_APPROVED) then
      x_attachment_status := G_APPROVED;
    return;
    elsif(p_header_status = G_ENG_APPR_REJECTED) then
      x_attachment_status := G_REJECTED;
    return;
    end if;
  end if;
END Get_Attachment_Status;

Procedure Complete_Attachment_Approval
(
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Complete_Attachment_Approval.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_approval_status           IN   VARCHAR2                           -- approval status
)
IS
l_attachment_id   number;
l_fnd_user_id     number;
l_fnd_login_id    number;
cursor C IS
   select attachment_id
   from eng_attachment_changes
   where change_id = p_change_id;
l_api_name           CONSTANT VARCHAR2(30)  := 'Complete_Attachment_Approval';
l_api_version        CONSTANT NUMBER := 1.0;

l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Complete_Attachment_Approval;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Complete_Attachment_Approval log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id         : ' || p_change_id );
       Write_Debug('p_approval_status   : ' || p_approval_status );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real code starts here -----------------------------------
    -- FND_PROFILE package is not available for workflow (WF),
    -- therefore manually set WHO column values

   l_fnd_user_id := -1;
   l_fnd_login_id := '';

   open C;
   loop
      fetch C into l_attachment_id;
      EXIT WHEN C%NOTFOUND;
      update fnd_attached_documents
      set status = p_approval_status, last_update_date = sysdate,
      last_updated_by = l_fnd_user_id,
      last_update_login = l_fnd_login_id
      where attached_document_id = l_attachment_id;
   end loop;
   close C;

  -- Standard ending code ------------------------------------------------
    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Complete_Attachment_Approval;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Complete_Attachment_Approval;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
          ROLLBACK TO Complete_Attachment_Approval;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;

END Complete_Attachment_Approval;

Procedure Copy_Attachments_And_Changes (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Copy_Attachments_And_Changes.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                           -- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
   ,p_org_id          IN   VARCHAR2
   ,p_inv_item_id       IN   VARCHAR2
   ,p_curr_rev_id       IN   VARCHAR2
   ,p_new_rev_id                IN   VARCHAR2
)
IS

   cursor C IS
   select attached_document_id, status
   from fnd_attached_documents
   where entity_name='MTL_ITEM_REVISIONS'
     and pk1_value = p_org_id
     and pk2_value = p_inv_item_id
     and pk3_value = p_curr_rev_id;


l_api_name           CONSTANT VARCHAR2(30)  := 'Copy_Attachments_And_Changes';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_attachment_id      NUMBER;
l_new_attachment_id  NUMBER;
l_status             VARCHAR(30);
l_count        NUMBER;
BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT   Copy_Attachments_And_Changes;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.COpy_Attachments_And_Changes log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id                : ' || p_change_id );
       Write_Debug('p_rev_item_seq_id              : ' || p_rev_item_seq_id );
       Write_Debug('p_org_id                       : ' || p_org_id );
       Write_Debug('p_inv_item_id                  : ' || p_inv_item_id );
       Write_Debug('p_curr_rev_id                  : ' || p_curr_rev_id );
       Write_Debug('p_new_rev_id                   : ' || p_new_rev_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Real code starts here -----------------------------------------------

   -- Copying attachment
   -- Step 1: If attachment exists for new revision (possible?), return

   select count(*)
   into l_count
   from fnd_attached_documents
   where entity_name='MTL_ITEM_REVISIONS'
     and pk1_value = p_org_id
     and pk2_value = p_inv_item_id
     and pk3_value = p_new_rev_id;

   if(l_count>0)
   then
     return;
   end if;

   -- Step 2: Iterate through revision level attachments for the existing revision
   open C;
   loop
     fetch C into l_attachment_id, l_status;
     EXIT WHEN C%NOTFOUND;

     if(l_status is NULL or l_status <> 'PENDING_CHANGE')
     then
   -- Step 3: Copying all attachments other than the pending ones
       DOM_ATTACHMENT_UTIL_PKG.COPY_ATTACHMENTS(x_from_entity_name            => 'MTL_ITEM_REVISIONS',
                                              x_from_pk1_value              => p_org_id,
                                              x_from_pk2_value              => p_inv_item_id,
                                              x_from_pk3_value              => p_curr_rev_id,
                                              x_from_pk4_value              => '',
                                              x_from_pk5_value              => '',
                                              X_from_attachment_id          => l_attachment_id,
                                              x_to_entity_name              => 'MTL_ITEM_REVISIONS',
                                              x_to_pk1_value                => p_org_id,
                                              x_to_pk2_value                => p_inv_item_id,
                                              x_to_pk3_value                => p_new_rev_id,
                                              x_to_pk4_value                => '',
                                              x_to_pk5_value                => '',
                                              X_to_attachment_id            => l_new_attachment_id,
                                              x_created_by                  => fnd_global.user_id,
                                              x_last_update_login           => fnd_global.login_id,
                                              x_program_application_id      => '',
                                              x_program_id                  => fnd_global.conc_program_id,
                                              x_request_id                  => fnd_global.conc_request_id
                                              );
   -- Step 4: Moving attachment changes (only Detach) from source revision to new revision
       update eng_attachment_changes
       set attachment_id = l_new_attachment_id
       where change_id = p_change_id
       and revised_item_sequence_id = p_rev_item_seq_id
       and attachment_id = l_attachment_id
       and action_type = 'DETACH';

     else
       update fnd_attached_documents
       set pk3_value = p_new_rev_id
       where  attached_document_id = l_attachment_id
       and exists
           (select change_document_id
            from   eng_attachment_changes
            where  change_id = p_change_id
            and    revised_item_sequence_id = p_rev_item_seq_id
            and    attachment_id = l_attachment_id);
     end if;
   end loop;
   close C;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      IF g_debug_flag THEN
         Write_Debug('Do Commit.') ;
    END IF ;
      COMMIT WORK;
   END IF;
   -- Standard ending code ------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   ( p_count        =>      x_msg_count,
     p_data         =>      x_msg_data );

   IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
   END IF ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Copy_Attachments_And_Changes;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Copy_Attachments_And_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Copy_Attachments_And_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;
END Copy_Attachments_And_Changes;

------------------------------
/*************Added for bug 8329527 ****************/
Procedure Migrate_Attachment_And_Change (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Migrate_Attachment_And_Change.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                            -- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
   ,p_org_id          IN   VARCHAR2
   ,p_inv_item_id        IN   VARCHAR2
   ,p_curr_rev_id        IN   VARCHAR2
   ,p_new_rev_id                IN   VARCHAR2
)
IS
cursor C IS
   select attached_document_id, status
   from   fnd_attached_documents
   where  pk1_value = p_org_id
   and    pk2_value = p_inv_item_id
   and    pk3_value = p_curr_rev_id;

l_api_name           CONSTANT VARCHAR2(30)  := 'Migrate_Attachment_And_Change';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_attachment_id      NUMBER;
l_new_attachment_id  NUMBER;
l_status             VARCHAR(30);
l_count         NUMBER;
BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT   Migrate_Attachment_And_Change;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Migrate_Attachment_And_Change log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id                : ' || p_change_id );
       Write_Debug('p_rev_item_seq_id              : ' || p_rev_item_seq_id );
       Write_Debug('p_org_id                       : ' || p_org_id );
       Write_Debug('p_inv_item_id                  : ' || p_inv_item_id );
       Write_Debug('p_curr_rev_id                  : ' || p_curr_rev_id );
       Write_Debug('p_new_rev_id                   : ' || p_new_rev_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Real code starts here -----------------------------------------------
   select  count(*)
   into    l_count
   from    fnd_attached_documents
   where   pk1_value = p_org_id
   and     pk2_value = p_inv_item_id
   and     pk3_value = p_new_rev_id;
   if(l_count>0) then
         return;
   end if;
   open C;
   loop
      fetch C into l_attachment_id, l_status;
      EXIT WHEN C%NOTFOUND;
      if(l_status is NULL or l_status <> 'PENDING_CHANGE') then
      /*Copy implemented attachments from 'FROM Revision' to 'New Revision'
      * migrate DETACH attachment change lines to NEW REVISION
      */
        DOM_ATTACHMENT_UTIL_PKG.COPY_ATTACHMENTS(x_from_entity_name         => 'MTL_ITEM_REVISIONS',
                                              x_from_pk1_value              => p_org_id,
                                              x_from_pk2_value              => p_inv_item_id,
                                              x_from_pk3_value              => p_curr_rev_id,
                                              x_from_pk4_value              => '',
                                              x_from_pk5_value              => '',
                                              X_from_attachment_id          => l_attachment_id,
                                              x_to_entity_name              => 'MTL_ITEM_REVISIONS',
                                              x_to_pk1_value                => p_org_id,
                                              x_to_pk2_value                => p_inv_item_id,
                                              x_to_pk3_value                => p_new_rev_id,
                                              x_to_pk4_value                => '',
                                              x_to_pk5_value                => '',
                                              X_to_attachment_id            => l_new_attachment_id,
                                              x_created_by                  => fnd_global.user_id,
                                              x_last_update_login           => fnd_global.login_id,
                                              x_program_application_id      => '',
                                              x_program_id                  => fnd_global.conc_program_id,
                                              x_request_id                  => fnd_global.conc_request_id
                                              );

         update eng_attachment_changes
         set attachment_id      = l_new_attachment_id,
             source_document_id = (select document_id
                                     from fnd_attached_documents
                                    where attached_document_id =
                                          l_new_attachment_id),
             pk3_value          = p_new_rev_id
       where change_id = p_change_id
         and revised_item_sequence_id = p_rev_item_seq_id
         and attachment_id = l_attachment_id
         and action_type = 'DETACH';
             if(l_status is not null) then
                  update fnd_attached_documents
                  set    status = null
                  where  attached_document_id = l_new_attachment_id;
              end if;
    else
      update fnd_attached_documents
      set    pk3_value = p_new_rev_id
      where  attached_document_id = l_attachment_id
      and    exists
             (select change_document_id
            from   eng_attachment_changes
            where  change_id = p_change_id
            and    revised_item_sequence_id = p_rev_item_seq_id
            and    attachment_id = l_attachment_id);
    end if;
   end loop;
   close C;

   /* Update pk3_value(rev_id) from 'From Revision' to 'New Revision' for 'ATTACH'  change lines */

   update eng_attachment_changes set pk3_value = p_new_rev_id
   where change_id = p_change_id
   and revised_item_sequence_id = p_rev_item_seq_id
   and action_type = 'ATTACH'
   and pk3_value = p_curr_rev_id  ;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       IF g_debug_flag THEN
          Write_Debug('Do Commit.') ;
    END IF ;
      COMMIT WORK;
   END IF;
   -- Standard ending code ------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   ( p_count        =>      x_msg_count,
     p_data         =>      x_msg_data );

   IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
   END IF ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Migrate_Attachment_And_Change;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Migrate_Attachment_And_Change;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Migrate_Attachment_And_Change;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;
END Migrate_Attachment_And_Change;


------------------------------
Procedure Delete_Attachments_And_Changes (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachments_And_Changes.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                           -- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
   ,p_org_id          IN   VARCHAR2
   ,p_inv_item_id       IN   VARCHAR2
   ,p_revision_id               IN   VARCHAR2
)
IS
cursor C IS
   select attached_document_id, document_id
   from   fnd_attached_documents
   where  pk1_value = p_org_id
   and    pk2_value = p_inv_item_id
--   and    (
--           pk3_value = p_revision_id
--           or
--           (pk3_value is null and p_revision_id is null)
--          ) -- commenting this out so that item level changes also get deleted when rev item is removed
-- this is ok since attached_document_id is only pk anyway
   and attached_document_id in
   (select attachment_id
    from eng_attachment_changes
    where change_id = p_change_id
    and revised_item_sequence_id = p_rev_item_seq_id
    and action_type = 'ATTACH');  -- fix for 3771466
l_api_name           CONSTANT VARCHAR2(30)  := 'Delete_Attachments_And_Changes';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_attachment_id      NUMBER;
l_document_id      NUMBER;
l_datatype_id    NUMBER;

BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT   Delete_Attachments_And_Changes;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Delete_Attachments_And_Changes log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id                : ' || p_change_id );
       Write_Debug('p_rev_item_seq_id              : ' || p_rev_item_seq_id );
       Write_Debug('p_org_id                       : ' || p_org_id );
       Write_Debug('p_inv_item_id                  : ' || p_inv_item_id );
       Write_Debug('p_revision_id                  : ' || p_revision_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Real code starts here -----------------------------------------------
   open C;
   loop
      fetch C into l_attachment_id, l_document_id;
      EXIT WHEN C%NOTFOUND;
    select datatype_id into l_datatype_id from fnd_documents where document_id = l_document_id;
      fnd_documents_pkg.delete_row(l_document_id, l_datatype_id, 'Y');
   end loop;
   close C;
   delete from eng_attachment_changes
   where  change_id = p_change_id
   and    revised_item_sequence_id = p_rev_item_seq_id;
   -- Standard ending code ------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   ( p_count        =>      x_msg_count,
     p_data         =>      x_msg_data );

   IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
   END IF ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Delete_Attachments_And_Changes;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Delete_Attachments_And_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Attachments_And_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;
END Delete_Attachments_And_Changes;

Procedure Delete_Attachments_For_Curr_CO (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachments_For_Curr_CO.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                           -- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
)
IS
Cursor C IS
     select source_document_id
     from   eng_attachment_changes
     where  change_id = p_change_id
     and    revised_item_sequence_id = p_rev_item_seq_id
     and    action_type = 'ATTACH';
l_api_name           CONSTANT VARCHAR2(30)  := 'Delete_Attachments_For_Curr_CO';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_document_id        NUMBER;
l_datatype_id      NUMBER;
l_document_exists    NUMBER;
BEGIN
  null;
   /*
   -- Standard Start of API savepoint
    SAVEPOINT   Delete_Attachments_For_Curr_CO;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Delete_Attachment_For_Curr_CO log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id                : ' || p_change_id );
       Write_Debug('p_rev_item_seq_id              : ' || p_rev_item_seq_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Real code starts here -----------------------------------------------
   open C;
   loop
      fetch C into l_document_id;
      EXIT WHEN C%NOTFOUND;
    -- select document_id into l_document_id from fnd_attached_documents
          --  where attached_document_id = l_attachment_id;
    select datatype_id into l_datatype_id
            from fnd_documents
           where document_id = l_document_id;

          -- Temporarily deleting the attachment from fnd_attached_document
          -- instead of deleting from the fnd_documents table
          -- until the fnd_documents_pkg is fixed

          -- Check if the document exists as part of any other change order
         SELECT count(*) into l_document_exists
          FROM eng_attachment_changes
          WHERE source_document_id = l_document_id
          AND  change_id <> p_change_id
          AND  revised_item_sequence_id <> p_rev_item_seq_id;

         IF l_document_exists > 0 THEN
            fnd_documents_pkg.delete_row(l_document_id, l_datatype_id, 'N');
         END IF;
   end loop;
   close C;

   -- Standard ending code ------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   ( p_count        =>      x_msg_count,
     p_data         =>      x_msg_data );

   IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
   END IF ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Delete_Attachments_For_Curr_CO;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Delete_Attachments_For_Curr_CO;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Attachments_For_Curr_CO;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;
    */
END Delete_Attachments_For_Curr_CO;

Procedure Delete_Attachments (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachments.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_org_id          IN   VARCHAR2
   ,p_inv_item_id       IN   VARCHAR2
   ,p_revision_id               IN   VARCHAR2
)
IS
cursor C IS
   select attached_document_id, document_id
   from   fnd_attached_documents
   where  pk1_value = p_org_id
   and    pk2_value = p_inv_item_id
   and    pk3_value = p_revision_id;
l_api_name           CONSTANT VARCHAR2(30)  := 'Delete_Attachments';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_attachment_id      NUMBER;
l_document_id      NUMBER;
l_datatype_id    NUMBER;
BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT   Delete_Attachments;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Delete_Attachments log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_org_id                       : ' || p_org_id );
       Write_Debug('p_inv_item_id                  : ' || p_inv_item_id );
       Write_Debug('p_revision_id                  : ' || p_revision_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Real code starts here -----------------------------------------------
   open C;
   loop
      fetch C into l_attachment_id, l_document_id;
      EXIT WHEN C%NOTFOUND;
    select datatype_id into l_datatype_id from fnd_documents where document_id = l_document_id;
      fnd_documents_pkg.delete_row(l_document_id, l_datatype_id, 'Y');
   end loop;
   close C;
      -- Standard ending code ------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   ( p_count        =>      x_msg_count,
     p_data         =>      x_msg_data );

   IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
   END IF ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Delete_Attachments;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Delete_Attachments;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Attachments;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;
END Delete_Attachments;

Procedure Delete_Attachment (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachment.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_attachment_id   IN   NUMBER
)
IS
l_api_name           CONSTANT VARCHAR2(30)  := 'Delete_Attachment';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_document_id      NUMBER;
l_datatype_id    NUMBER;
BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT   Delete_Attachment;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Delete_Attachment log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_attachment_id                  : ' || p_attachment_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Real code starts here -----------------------------------------------
   begin
         select document_id into l_document_id
     from   fnd_attached_documents
     where  attached_document_id = p_attachment_id;
       select datatype_id into l_datatype_id
       from   fnd_documents
       where  document_id = l_document_id;
       fnd_documents_pkg.delete_row(l_document_id, l_datatype_id, 'Y');
   exception
         when NO_DATA_FOUND then
     return;
   end;
   -- Standard ending code ------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   ( p_count        =>      x_msg_count,
     p_data         =>      x_msg_data );

   IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
   END IF ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Delete_Attachment;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Delete_Attachment;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Attachment;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;
END Delete_Attachment;

Procedure Delete_Changes (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Changes.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                           -- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
)
IS
l_api_name           CONSTANT VARCHAR2(30)  := 'Delete_Changes';
l_api_version        CONSTANT NUMBER := 1.0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT   Delete_Changes;
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
       Write_Debug('ENG_ATTACHMENT_IMPLEMENTATION.Delete_Changes log');
       Write_Debug('-----------------------------------------------------');
       Write_Debug('p_change_id                : ' || p_change_id );
       Write_Debug('p_rev_item_seq_id              : ' || p_rev_item_seq_id );
       Write_Debug('-----------------------------------------------------');
       Write_Debug('Initializing return status... ' );
    END IF ;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Real code starts here -----------------------------------------------
   delete from eng_attachment_changes
   where  change_id = p_change_id
   and    revised_item_sequence_id = p_rev_item_seq_id;
   -- Standard ending code ------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   ( p_count        =>      x_msg_count,
     p_data         =>      x_msg_data );

   IF g_debug_flag THEN
      Write_Debug('Finish. End Of Proc') ;
      Close_Debug_Session ;
   END IF ;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Delete_Changes;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with expected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Delete_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
        Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Changes;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
        Close_Debug_Session ;
      END IF ;
END Delete_Changes;

Procedure Validate_floating_version (
    p_api_version               IN   NUMBER                             --
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER
   ,p_rev_item_seq_id           IN   NUMBER  := NULL
)
IS
   Cursor get_floating_attachments(l_change_id NUMBER,
                                   l_revised_item_seq_id NUMBER) is
   select change_id, revised_item_sequence_id,
          category_id, file_name, source_path,
          pk1_value, pk2_value, pk3_value
     from eng_attachment_changes a
    where a.change_id = l_change_id
      and datatype_id = 8                   -- only webservices files
      and family_id = 0                     -- for floating version files
      and action_type in ('ATTACH','CHANGE_REVISION','CHANGE_VERSION_LABEL')
      and revised_item_sequence_id in (select decode(l_revised_item_seq_id,null,                                       (select revised_item_sequence_id
                                          from eng_revised_items
                                         where change_id = a.change_id),
                                             l_revised_item_seq_id)  from dual);

   l_change_id           NUMBER;
   l_revised_item_seq_id NUMBER;
   l_change_policy       VARCHAR2(100);
   l_api_name            VARCHAR2(100) := 'Validate_floating_version';

   change_policy_defined EXCEPTION;


BEGIN

   SAVEPOINT  Implement_Attachment_Change;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_change_id := p_change_id;
   l_revised_item_seq_id := p_rev_item_seq_id;

   FOR c2 in get_floating_attachments(l_change_id, l_revised_item_seq_id)
   LOOP

     BEGIN

     -- The foll. SQL checks if the category passed has changepolicy defined
     -- on it or not
     SELECT ecp.policy_char_value INTO l_change_policy
       FROM
    (select nvl(mirb.lifecycle_id, msi.lifecycle_id) as lifecycle_id,
       nvl(mirb.current_phase_id , msi.current_phase_id) as phase_id,
       msi.item_catalog_group_id item_catalog_group_id,
       msi.inventory_item_id, msi.organization_id , mirb.revision_id
     from mtl_item_revisions_b mirb,
          MTL_SYSTEM_ITEMS msi
     where mirb.INVENTORY_ITEM_ID(+) = msi.INVENTORY_ITEM_ID
       and mirb.ORGANIZATION_ID(+)= msi.ORGANIZATION_ID
       and mirb.revision_id(+) = c2.pk3_value
       and msi.INVENTORY_ITEM_ID = c2.pk2_value
       and msi.ORGANIZATION_ID = c2.pk1_value) ITEM_DTLS,
      ENG_CHANGE_POLICIES_V ECP
    WHERE
     ecp.policy_object_pk1_value =
         (SELECT TO_CHAR(ic.item_catalog_group_id)
            FROM mtl_item_catalog_groups_b ic
           WHERE EXISTS (SELECT olc.object_classification_code CatalogId
                           FROM EGO_OBJ_TYPE_LIFECYCLES olc
                          WHERE olc.object_id = (SELECT OBJECT_ID
                                                   FROM fnd_objects
                                                  WHERE obj_name = 'EGO_ITEM')
                            AND  olc.lifecycle_id = ITEM_DTLS.lifecycle_id
                            AND olc.object_classification_code = ic.item_catalog_group_id
                         )
            AND ROWNUM = 1
            CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
            START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
     AND ecp.policy_object_pk2_value = ITEM_DTLS.lifecycle_id
     AND ecp.policy_object_pk3_value = ITEM_DTLS.phase_id
     and ecp.policy_object_name = 'CATALOG_LIFECYCLE_PHASE'
     and ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
     and ecp.attribute_code = 'ATTACHMENT'
     and attribute_number_value = c2.category_id;

     IF l_change_policy = 'CHANGE_ORDER_REQUIRED' THEN
        RAISE change_policy_defined;
        ROLLBACK TO Implement_Attachment_Change;
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN -- no data found means there are no change
                               -- policy defined for the category
         null;
     END;

   END LOOP;

   EXCEPTION
   WHEN change_policy_defined THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Error: This Change Order has floating version attachments that are under change required change policy. Such CO cannot be implemented';
        RAISE FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

END Validate_floating_version;


END ENG_ATTACHMENT_IMPLEMENTATION;

/
