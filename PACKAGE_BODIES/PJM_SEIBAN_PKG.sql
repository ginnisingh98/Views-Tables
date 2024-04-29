--------------------------------------------------------
--  DDL for Package Body PJM_SEIBAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_SEIBAN_PKG" as
/* $Header: PJMSEBNB.pls 120.1 2005/11/23 14:16:44 yliou noship $ */

--
-- Procedure Name : project_number_dup
--
-- Checks for the project_number if it already exists in PJM_PROJECTS_ALL_V
--
PROCEDURE project_number_dup
( X_project_number      IN         VARCHAR2
, X_dup_number_flag     OUT NOCOPY VARCHAR2
) IS
BEGIN
  X_dup_number_flag := check_dup_project_num( X_project_number , null );
END project_number_dup;


--
-- Procedure Name : project_name_dup
--
-- Checks for the project_name if it already exists in PJM_PROJECTS_ALL_V
--
PROCEDURE project_name_dup
( X_project_name        IN         VARCHAR2
, X_dup_name_flag       OUT NOCOPY VARCHAR2
) IS
BEGIN
  X_dup_name_flag := check_dup_project_name( X_project_name , null );
END project_name_dup;


FUNCTION check_dup_project_num
( X_project_number      IN  VARCHAR2
, X_project_id          IN  NUMBER
) RETURN VARCHAR2
IS

CURSOR c IS
  select project_id
  from   pa_projects_all
  where  segment1 = X_project_number
  and    ( X_project_id is null or project_id <> X_project_id )
  union all
  select project_id
  from   pjm_seiban_numbers
  where  project_number = X_project_number
  and    ( X_project_id is null or project_id <> X_project_id );
crec c%rowtype;

BEGIN

  if ( X_project_number is null ) then
    return('N');
  end if;

  open c;
  fetch c into crec;
  if c%notfound then
    close c;
    return('N');
  else
    close c;
    return('Y');
  end if;

EXCEPTION
WHEN OTHERS THEN
  return('E');
END check_dup_project_num;


FUNCTION check_dup_project_name
( X_project_name        IN  VARCHAR2
, X_project_id          IN  NUMBER
) RETURN VARCHAR2
IS

CURSOR c IS
  select project_id
  from   pa_projects_all
  where  name = X_project_name
  and    ( X_project_id is null or project_id <> X_project_id )
  union all
  select project_id
  from   pjm_seiban_numbers
  where  project_name = X_project_name
  and    ( X_project_id is null or project_id <> X_project_id );
crec c%rowtype;

BEGIN

  if ( X_project_name is null ) then
    return('N');
  end if;

  open c;
  fetch c into crec;
  if c%notfound then
    close c;
    return('N');
  else
    close c;
    return('Y');
  end if;

EXCEPTION
WHEN OTHERS THEN
  return('E');
END check_dup_project_name;


--
-- Private procedure to get messages from AMG
--
FUNCTION get_messages
( X_msg_count             IN  NUMBER
, X_msg_data              IN  VARCHAR2
) RETURN VARCHAR2 IS

  msgtxt      varchar2(2000);
  msgbuf      varchar2(32000);
  msgidxout   number;

BEGIN

  msgbuf := null;
  for i in 1..X_msg_count loop
    pa_interface_utils_pub.get_messages
    ( p_msg_index         => i
    , p_msg_count         => X_msg_count
    , p_msg_data          => X_msg_data
    , p_data              => msgtxt
    , p_msg_index_out     => msgidxout
    );
    if ( msgbuf is null ) then
      msgbuf := msgtxt;
    else
      msgbuf := msgbuf || fnd_global.newline || msgtxt;
    end if;
  end loop;
  return( msgbuf );

EXCEPTION
  WHEN OTHERS THEN
    return( msgbuf );
END get_messages;


--
-- Create_amg_project procedure can be used to create a project in
-- Oracle Projects. This uses AMG's API named create_project.
--
-- This procedure accepts the following parameters:
--
--        Project_created_from    source (template) project_id
--        Project_number          target project_number
--        Project_name            target project_name
--        start_date              start date for the new project
--        end_date                end date for the new project
--        Submit_Workflow         'Y' or 'N'
--        Project_id              ID of the target project
--        Return_status           status of the project creation.
--
PROCEDURE create_amg_project
( X_project_created_from  IN         NUMBER
, X_project_number        IN         VARCHAR2
, X_project_name          IN         VARCHAR2
, X_start_date            IN         DATE
, X_end_date              IN         DATE
, X_submit_workflow       IN         VARCHAR2
, X_project_id            OUT NOCOPY NUMBER
, X_return_status         OUT NOCOPY VARCHAR2
) IS

  l_api_version_number          NUMBER      := 1.0;
  l_commit                      VARCHAR2(1) := 'F';
  l_pm_product_code             VARCHAR2(10):= 'PJM';
  l_init_msg_list               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_errbuf                      VARCHAR2(20000);
  l_return_status               VARCHAR2(1);
  l_Submit_Workflow             VARCHAR2(1);
  API_ERROR                     EXCEPTION;
--
-- Variables needed for project specific parameters
--
  l_project_in_rec              pa_project_pub.project_in_rec_type;
  l_project_out_rec             pa_project_pub.project_out_rec_type;
  l_key_member_tbl              pa_project_pub.project_role_tbl_type;
  l_class_category_tbl          pa_project_pub.class_category_tbl_type;
  l_tasks_out                   pa_project_pub.task_out_tbl_type;
  l_tasks_in                    pa_project_pub.task_in_tbl_type;
 -- bug 4731449
 l_resp_id            NUMBER := 0;
 l_user_id            NUMBER := 0;
 l_resp_appl_id       NUMBER := 0;
 l_org_id             NUMBER := 0;

BEGIN

  l_project_in_rec.pm_project_reference    := X_project_number;
  l_project_in_rec.project_name            := X_project_name;
  l_project_in_rec.created_from_project_id := X_project_created_from;
  l_project_in_rec.description             := X_project_name;
  l_project_in_rec.public_sector_flag      := 'N';
  l_project_in_rec.start_date              := X_start_date;
  l_project_in_rec.completion_date         := X_end_date;

 -- bug 4731449
 l_resp_id := FND_GLOBAL.Resp_id;
 l_user_id := FND_GLOBAL.User_id;
 select org_id into l_org_id
 from pa_projects_all
 where project_id = X_project_created_from;
 select application_id into l_resp_appl_id
 from fnd_responsibility where responsibility_id = l_resp_id;

  PA_INTERFACE_UTILS_PUB.set_global_info
  ( p_api_version_number => l_api_version_number
  , p_responsibility_id  => l_resp_id
  , p_user_id            => l_user_id
  , p_resp_appl_id       => l_resp_appl_id
  , p_operating_unit_id  => l_org_id
  , p_msg_count          => l_msg_count
  , p_msg_data           => l_msg_data
  , p_return_status      => l_return_status
  );

  X_return_status := l_return_status;
  if l_return_status <> 'S' then
    raise API_ERROR;
  else
    pa_project_pub.create_project
                ( p_api_version_number => l_api_version_number
                , p_commit             => l_commit
                , p_init_msg_list      => l_init_msg_list
                , p_msg_count          => l_msg_count
                , p_msg_data           => l_msg_data
                , p_return_status      => l_return_status
                , p_workflow_started   => l_Submit_Workflow
                , p_pm_product_code    => l_pm_product_code
                , p_project_in         => l_project_in_rec
                , p_project_out        => l_project_out_rec
                , p_key_members        => l_key_member_tbl
                , p_class_categories   => l_class_category_tbl
                , p_tasks_in           => l_tasks_in
                , p_tasks_out          => l_tasks_out
                );

    X_project_id := l_project_out_rec.pa_project_id;
    X_return_status := l_return_status;
    if l_return_status <> 'S' then
      raise API_ERROR;
    end if;
  end if;

EXCEPTION
  WHEN API_ERROR THEN
    l_errbuf := get_messages( X_msg_count => l_msg_count , X_msg_data => l_msg_data );
    fnd_message.set_name('PJM','SEIB-AMG PROJECT ERROR');
    fnd_message.set_token('DETAIL', l_errbuf);

  WHEN OTHERS THEN
    l_errbuf := get_messages( X_msg_count => l_msg_count , X_msg_data => l_msg_data );
    fnd_message.set_name('PJM','SEIB-AMG PROJECT ERROR');
    fnd_message.set_token('DETAIL', l_errbuf);

END create_amg_project;


--
-- Procedure Name : create_amg_task
--
-- Create_amg_task procedure can be used to create a task in
-- Oracle projects. This uses AMG's API named add_task.
--
-- This procedure accepts the following parameters:
--
--        Project_id              project_id of project under which the task
--                                needs to be created
--        Project_number          Corresponding project_number for the above
--                                project
--        Task_number             Task number for the task to be created
--        Task_id                 ID of the task that has been created
--        Return_status           status of the Task creation
--
procedure create_amg_task
( X_project_id            IN         NUMBER
, X_project_number        IN         VARCHAR2
, X_task_number           IN         VARCHAR2
, X_task_id               OUT NOCOPY NUMBER
, X_return_status         OUT NOCOPY VARCHAR2
) IS

  l_api_version_number          NUMBER      := 1.0;
  l_commit                      VARCHAR2(1) := 'F';
  l_return_status               VARCHAR2(1);
  l_init_msg_list               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_errbuf                      VARCHAR2(20000);
--
-- Variables needed for project specific parameters
--
  l_pm_product_code             VARCHAR2(10);
  l_pa_project_id_out           NUMBER(15);
  l_pa_project_number_out       VARCHAR2(25);
  l_task_id                     NUMBER(15);
  API_ERROR                     EXCEPTION;

BEGIN

  l_pm_product_code := 'PJM';

  --
  -- Temporarily setting the Cross Project responsibility to Yes to
  -- bypass PA security check
  --
  fnd_profile.put('PA_SUPER_PROJECT' , 'Y');

  pa_project_pub.add_task
                ( p_api_version_number    => l_api_version_number
                , p_commit                => l_commit
                , p_init_msg_list         => l_init_msg_list
                , p_msg_count             => l_msg_count
                , p_msg_data              => l_msg_data
                , p_return_status         => l_return_status
                , p_pm_product_code       => l_pm_product_code
                , p_pm_project_reference  => X_project_number
                , p_pa_project_id         => X_project_id
                , p_pm_task_reference     => X_task_number
                , p_pa_task_number        => X_task_number
                , p_task_name             => X_task_number
                , p_task_description      => X_task_number
                , p_pa_project_id_out     => l_pa_project_id_out
                , p_pa_project_number_out => l_pa_project_number_out
                , p_task_id               => l_task_id
                );

  X_task_id := l_task_id;
  X_return_status := l_return_status;

  if l_return_status <> 'S' then
        Raise API_ERROR;
  end if;

EXCEPTION
  WHEN API_ERROR THEN
    l_errbuf := get_messages( X_msg_count => l_msg_count , X_msg_data => l_msg_data );
    fnd_message.set_name('PJM','SEIB-AMG TASK ERROR');
    fnd_message.set_token('DETAIL', l_errbuf);

  WHEN OTHERS THEN
    l_errbuf := get_messages( X_msg_count => l_msg_count , X_msg_data => l_msg_data );
    fnd_message.set_name('PJM','SEIB-AMG TASK ERROR');
    fnd_message.set_token('DETAIL', l_errbuf);

END create_amg_task;


PROCEDURE Conc_Create
( ERRBUF                  OUT NOCOPY    VARCHAR2
, RETCODE                 OUT NOCOPY    NUMBER
, X_Create_or_Add         IN            NUMBER
, X_Project_Template      IN            NUMBER
, X_Project_Number        IN            VARCHAR2
, X_Project_Name          IN            VARCHAR2
, X_start_date            IN            VARCHAR2
, X_end_date              IN            VARCHAR2
, X_submit_workflow       IN            VARCHAR2
, X_Project_ID            IN            NUMBER
, X_Prefix                IN            VARCHAR2
, X_Suffix                IN            VARCHAR2
, X_From_Task             IN            NUMBER
, X_To_Task               IN            NUMBER
, X_Increment_By          IN            NUMBER
, X_numeric_width         IN            NUMBER
) IS

  L_Project_ID        NUMBER       := NULL;
  L_Project_Num       VARCHAR2(25) := NULL;
  L_Task_ID           NUMBER       := NULL;
  L_Task_Num          VARCHAR2(20) := NULL;
  L_Return_Status     VARCHAR2(1)  := NULL;
  i                   NUMBER;

  CREATE_NEW_PROJECT  CONSTANT NUMBER := 1;
  ADD_TO_NEW_PROJECT  CONSTANT NUMBER := 2;
  Proj_Creation_Error EXCEPTION;
  Task_Creation_Error EXCEPTION;

  --
  -- The following variables are used for Project Approval Workflow
  --
  l_err_code               number;
  l_err_stage              varchar2(80);
  l_err_stack              varchar2(630);
  l_wf_status_code         varchar2(30);

  CURSOR get_wf_status (C_project_id IN NUMBER) IS
  SELECT wf_status_code
  FROM   pa_projects
  WHERE  project_id = C_project_id;

BEGIN

  if ( X_Create_or_Add = CREATE_NEW_PROJECT ) then
    --
    --  If the project number is a duplicate then raise error.
    --
    project_number_dup(X_project_number, L_Return_Status);

    if ( L_Return_Status = 'Y' ) then
      fnd_message.set_name('PJM', 'FORM-DUPLICATE PROJECT NUM');
      pjm_conc.put_line( fnd_message.get );
      Raise Proj_Creation_Error;
    end if;

    --
    --  If the project name is a duplicate then raise error
    --
    project_name_dup(X_project_name, L_Return_Status);

    if ( L_Return_Status = 'Y' ) then
      fnd_message.set_name('PJM', 'FORM-DUPLICATE PROJECT NAME');
      pjm_conc.put_line( fnd_message.get );
      Raise Proj_Creation_Error;
    end if;

    Create_AMG_Project( X_Project_Template
                      , X_Project_Number
                      , X_Project_Name
                      , fnd_date.canonical_to_date(X_start_date)
                      , fnd_date.canonical_to_date(X_end_date)
                      , X_submit_workflow
                      , L_Project_ID
                      , L_Return_Status );

    pjm_conc.put_line('Project_Number    = ' || X_Project_Number);
    pjm_conc.put_line('Project_Name      = ' || X_Project_Name);
    pjm_conc.put_line('Project_ID        = ' || to_char(L_Project_ID));
    pjm_conc.put_line('AMG return_status = ' || L_Return_Status);
    pjm_conc.new_line(1);

    if ( L_Return_Status <> 'S' ) then
      pjm_conc.put_line( fnd_message.get );
      Raise Proj_Creation_Error;
    end if;

    --
    -- The project number is needed for task creation as the
    -- project number is used as the AMG reference to the
    -- project
    --
    L_Project_Num := X_Project_Number;

    commit;

  else
    --
    -- User wants to add to existing project
    --
    L_Project_ID := X_Project_ID;

    SELECT segment1
    INTO   L_Project_Num
    FROM   PA_Projects
    WHERE  Project_ID = L_Project_ID;

  end if;

  --
  -- Task Creation
  --
  i := X_From_Task;

  WHILE ( i<= X_To_Task ) LOOP
    if ( X_numeric_width is not null ) then
      --
      -- User wants zero padding
      --
      L_Task_Num := rtrim(X_Prefix) ||
                    lpad(to_char(i), X_numeric_width, '0') ||
                    rtrim(X_suffix);
    else
      --
      -- User does not want zero padding
      --
      L_Task_Num := rtrim(X_Prefix) ||
                    to_char(i) ||
                    rtrim(X_suffix);
    end if;

    --
    -- Check for duplicates
    --
    BEGIN
      SELECT task_id
      INTO   L_Task_ID
      FROM   PA_Tasks
      WHERE  Project_ID = L_Project_ID
      AND (  Task_Number = L_Task_Num
          OR Task_Name   = L_Task_num )
      AND    rownum = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_Task_ID := NULL;
      WHEN OTHERS THEN
        pjm_conc.put_line( sqlerrm );
        Raise Task_Creation_Error;
    END;

    if ( L_Task_ID is null ) then

      Create_AMG_Task( L_Project_ID
                     , L_Project_Num
                     , L_Task_Num
                     , L_Task_ID
                     , L_Return_Status );

      pjm_conc.put_line(
              'Task_Number = ' || L_Task_Num || '  ' ||
              'Task_ID = ' || to_char(L_Task_ID) || '  ' ||
              'AMG return_status = ' || L_Return_Status);

      if ( L_Return_Status <> 'S' ) then
        pjm_conc.new_line(1);
        pjm_conc.put_line( fnd_message.get );
        Raise Task_Creation_Error;
      end if;

      commit;

      i := i + X_Increment_By;

    end if;

  END LOOP;

  if ( X_submit_workflow = 'Y' ) then

    OPEN  get_wf_status ( l_project_id );
    FETCH get_wf_status INTO l_wf_status_code;
    CLOSE get_wf_status;

    if ( l_wf_status_code <> 'IN_ROUTE' ) then
      --
      -- Workflow has not been submitted
      --
      PA_PROJECT_WF.start_project_wf
                   ( l_project_id
                   , l_err_stack
                   , l_err_stage
                   , l_err_code );

      if ( l_err_code <> 0 ) then
        fnd_message.set_name('PA', l_err_stage);
        errbuf := fnd_message.get;
        pjm_conc.put_line( errbuf );
        commit;
        retcode := PJM_CONC.G_conc_warning;
      end if;

      commit;

    end if; /* l_wf_status_code */

  end if; /* X_submit_workflow */

  retcode := PJM_CONC.G_conc_success;

EXCEPTION
  WHEN Proj_Creation_Error THEN
    fnd_message.set_name('PJM', 'SEIB-PROJ CREATION FAILED');
    errbuf := fnd_message.get;
    pjm_conc.put_line( errbuf );
    retcode := PJM_CONC.G_conc_failure;

  WHEN Task_Creation_Error THEN
    fnd_message.set_name('PJM', 'SEIB-TASK CREATION FAILED');
    errbuf := fnd_message.get;
    pjm_conc.put_line( errbuf );
    retcode := PJM_CONC.G_conc_failure;

  WHEN OTHERS THEN
    errbuf := sqlerrm;
    pjm_conc.put_line( sqlerrm );
    retcode := PJM_CONC.G_conc_failure;

END Conc_Create;

END pjm_seiban_pkg;

/
