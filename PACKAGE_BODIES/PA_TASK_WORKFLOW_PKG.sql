--------------------------------------------------------
--  DDL for Package Body PA_TASK_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_WORKFLOW_PKG" as
/* $Header: PATSKWFB.pls 120.4.12010000.2 2009/08/11 07:25:53 anuragar noship $ */

  p_debug_mode    VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  g_error_message VARCHAR2(1000) :='';
  g_error_stack   VARCHAR2(500) :='';
  g_error_stage   VARCHAR2(100) :='';

  -- This procedure is for logging debug messages so as to debug the code
  -- in case of any unknown issues that occur during the entire cycle of
  -- a deduction request.

  PROCEDURE log_message (p_log_msg IN VARCHAR2, debug_level IN NUMBER) IS
  BEGIN
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write('log_message: ' || 'PA PWP Notification: ', 'log: ' || p_log_msg, debug_level);
    END IF;
  END log_message;

  -- This procedure is to initiate Task Approval Workflow

  PROCEDURE Start_Task_Aprv_Wf (p_item_type            IN VARCHAR2
                               ,p_process              IN VARCHAR2
                               ,p_project_id           IN NUMBER
                               ,p_task_id              IN NUMBER
                               ,p_parent_struc_ver     IN NUMBER
                               ,p_approver_user_id     IN NUMBER
                               ,p_ci_id                IN NUMBER
                               ,x_err_stack IN OUT NOCOPY VARCHAR2
                               ,x_err_stage IN OUT NOCOPY VARCHAR2
                               ,x_err_code OUT NOCOPY NUMBER
                              ) IS

    -- Cursor to get the user name of the provided user_id
    CURSOR c_starter_name(l_starter_user_id NUMBER) IS
      SELECT  user_name
        FROM  FND_USER
        WHERE user_id = l_starter_user_id;

    -- Cursor to get full name of the user
    CURSOR c_starter_full_name(l_starter_user_id NUMBER) IS
      SELECT  e.first_name||' '||e.last_name
        FROM  FND_USER f, PER_ALL_PEOPLE_F e
        WHERE f.user_id = l_starter_user_id
        AND   f.employee_id = e.person_id
        AND   e.effective_end_date = ( SELECT MAX(papf.effective_end_date)
                                       FROM per_all_people_f papf
                                       WHERE papf.person_id = e.person_id);
    CURSOR c_wf_started_date IS
      SELECT SYSDATE FROM SYS.DUAL;

    -- Cursor to fetch the complete change document information.
    CURSOR c_ci_info IS
        SELECT ci_id,
               summary,
               pci.description,
               pctb.short_name||' ('||pci.ci_number||')' ci_number,
               ci_type_class_code,
               pci.created_by created_by,
               pci.creation_date creation_date
        FROM   PA_CONTROL_ITEMS pci,
               PA_CI_TYPES_vl pctb
        WHERE  ci_id = p_ci_id
        AND    pctb.ci_type_id = pci.ci_type_id;

    l_proj_info_rec                 c_proj_info%ROWTYPE;

    itemkey                         VARCHAR2(30);
    l_wf_started_date               DATE;
    l_workflow_started_by_id        NUMBER;
    l_user_full_name                VARCHAR(400);
    l_user_name                     VARCHAR(240);
    l_resp_id                       NUMBER;
    l_err_code                      NUMBER := 0;
    l_err_stack                     VARCHAR2(2000);
    l_err_stage                     VARCHAR2(2000);
    l_content_id                    NUMBER;

    itemtype         CONSTANT        VARCHAR2(15) := p_item_type;--'PATASKWF';
    l_process        CONSTANT        VARCHAR2(20) := p_process;--'PA_TASK_APPROVAL_WF';

    c_task_info_rec c_task_info%ROWTYPE;
    c_ci_info_rec   c_ci_info%ROWTYPE;

  BEGIN

    log_message('Inside the procedure Start_Task_Aprv_Wf',3);
    l_content_id := 0;

    --b6694902_debug.debug('In Start_Task_Aprv_Wf ');

    log_message('Before fetching the task info',3);
    -- Fetch Task Info
    OPEN c_task_info(p_project_id, p_task_id);
    FETCH c_task_info INTO c_task_info_rec;
    IF c_task_info%NOTFOUND THEN
        log_message('Cursor failed to fetch the task information',3);
        x_err_code  := 100;
        x_err_stage := 10;
        x_err_stack := 'PA_TASK_NOT_EXISTS';
        CLOSE c_task_info;
        return;
    END IF;
    CLOSE c_task_info;

    log_message('Opening the cursor for fetching change document info',3);
    OPEN c_ci_info;
    FETCH c_ci_info INTO c_ci_info_rec;
    CLOSE c_ci_info;

    x_err_code := 0;
    --get the unique identifier for this specific workflow
    SELECT pa_workflow_itemkey_s.nextval
    INTO   itemkey
    FROM   DUAL;

    log_message('Initializing the variables',3);
    -- Need this to populate the attribute information in Workflow

    l_workflow_started_by_id := c_task_info_rec.created_by;
    l_resp_id := FND_GLOBAL.resp_id;

    log_message('Calling workflow engine to create the process',3);
    -- Create a new Wf process
    --b6694902_debug.debug('Before calling createprocess ');
    WF_ENGINE.CreateProcess( itemtype => itemtype,
                             itemkey  => itemkey,
                             process  => l_process);


    -- Fetch all required info to populate Wf Attributes
    OPEN  c_starter_name(l_workflow_started_by_id );
    FETCH c_starter_name INTO l_user_name;
    IF c_starter_name%NOTFOUND THEN
          x_err_code  := 100;
          x_err_stage := 20;
    END IF;
    CLOSE c_starter_name;

    OPEN  c_starter_full_name(l_workflow_started_by_id );
    FETCH c_starter_full_name INTO l_user_full_name;
    IF c_starter_full_name%NOTFOUND THEN
         x_err_code := 100;
         x_err_stage:= 30;
    END IF;
    CLOSE c_starter_full_name;

    OPEN c_wf_started_date;
    FETCH c_wf_started_date INTO l_wf_started_date;
    CLOSE c_wf_started_date;

    log_message('Fetching the project info',3);
    OPEN  c_proj_info(p_project_id);
    FETCH c_proj_info INTO l_proj_info_rec;
    IF c_proj_info%NOTFOUND THEN
        x_err_code := 100;
        x_err_stage:= 40;
    END IF;
    CLOSE c_proj_info;

    log_message('Assinging the workflow attributes',3);

    log_message('Project Id ['||l_proj_info_rec.project_id||'], '||
                'Project Number ['||l_proj_info_rec.project_number||'], '||
                'Project Name ['||l_proj_info_rec.project_name||'], '||
                'Project Org ['||l_proj_info_rec.organization_id||'] ,'||
                'Change Document Num ['||c_ci_info_rec.ci_number||'], '||
                'Change Document Id ['||p_ci_id||']'
                 ,3);

    IF l_proj_info_rec.project_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'PROJECT_ID'
                                     ,avalue     => l_proj_info_rec.project_id
                                     );
    END IF;

    IF l_proj_info_rec.project_number IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'PROJECT_NUMBER'
                                   ,avalue     => l_proj_info_rec.project_number
                                   );
    END IF;

    IF c_ci_info_rec.ci_number IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'CONTROL_ITEM_NUMBER'
                                   ,avalue     => c_ci_info_rec.ci_number
                                   );
    END IF;

    IF l_proj_info_rec.project_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'PROJECT_NAME'
                                   ,avalue     => l_proj_info_rec.project_name
                                    );
    END IF;

    IF l_proj_info_rec.organization_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'PROJ_ORG_ID'
                                     ,avalue     => l_proj_info_rec.organization_id
                                     );
    END IF;

    log_message('Task Id ['||c_task_info_rec.task_id||'], '||
                'Task Number ['||c_task_info_rec.task_number||'], '||
                'Task Name ['||c_task_info_rec.task_name||'], '||
                'Parent Task ['||c_task_info_rec.parent_task_id||'] ,'||
                'Parent Task Num ['||c_task_info_rec.parent_task_number||'], '||
                'Task Start Date ['||c_task_info_rec.scheduled_start_date||'], '||
                'Task End Date ['||c_task_info_rec.scheduled_end_date||']'
                 ,3);

    IF c_task_info_rec.parent_task_number IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'PARENT_TASK_NUMBER'
                                   ,avalue     => c_task_info_rec.parent_task_number
                                    );
    END IF;

    IF c_task_info_rec.parent_task_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'PARENT_TASK_ID'
                                   ,avalue     => c_task_info_rec.parent_task_id
                                    );
    END IF;

    IF c_task_info_rec.task_number IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'TASK_NUMBER'
                                     ,avalue     => c_task_info_rec.task_number
                                    );
    END IF;

    IF c_task_info_rec.task_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'TASK_NAME'
                                     ,avalue     => c_task_info_rec.task_number
                                    );
    END IF;

    IF c_task_info_rec.task_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'TASK_ID'
                                   ,avalue       => c_task_info_rec.task_id
                                   );
    END IF;

    IF c_task_info_rec.scheduled_start_date IS NOT NULL THEN
         WF_ENGINE.SetItemAttrDate (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'TASK_ST_DATE'
                                   ,avalue       => c_task_info_rec.scheduled_start_date
                                   );
    END IF;

    IF c_task_info_rec.scheduled_end_date IS NOT NULL THEN
         WF_ENGINE.SetItemAttrDate (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'TASK_END_DATE'
                                   ,avalue       => c_task_info_rec.scheduled_end_date
                                   );
    END IF;

    IF p_ci_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'CI_ID'
                                     ,avalue     => p_ci_id
                                     );
    END IF;

    log_message('Content Id ['||l_content_id||'], '||
                'Workflow started by ['||l_user_full_name||']'
                 ,3);

    IF l_content_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                     ,itemkey      => itemkey
                                     ,aname        => 'CONTENT_ID'
                                     ,avalue       => l_content_id
                                      );
    END IF;

    IF l_workflow_started_by_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'SUBMITTED_BY_ID'
                                     ,avalue     => l_workflow_started_by_id
                                      );
    END IF;

    IF l_user_full_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'SUBMITTED_BY'
                                   ,avalue       => l_user_full_name
                                   );
    END IF;

    IF l_workflow_started_by_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'WORKFLOW_STARTED_BY_ID'
                                     ,avalue     => l_workflow_started_by_id
                                      );
    END IF;

    IF l_user_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'WORKFLOW_STARTED_BY_NAME'
                                   ,avalue       => l_user_name
                                   );
    END IF;

    IF l_user_full_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'WORKFLOW_STARTED_BY_FULL_NAME'
                                   ,avalue       => l_user_full_name
                                    );
    END IF;

    IF l_resp_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'RESPONSIBILITY_ID'
                                     ,avalue     => l_resp_id
                                      );
    END IF;

    IF l_wf_started_date IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'WF_STARTED_DATE'
                                   ,avalue       => l_wf_started_date
            );
    END IF;

    IF p_approver_user_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'TASK_APPROVER_ID'
                                   ,avalue       => p_approver_user_id
            );
    END IF;

    OPEN  c_starter_name(p_approver_user_id );
    FETCH c_starter_name INTO l_user_full_name;
    IF c_starter_name%NOTFOUND THEN
         x_err_code := 100;
         x_err_stage:= 30;
    END IF;
    CLOSE c_starter_name;

    log_message('Task approver id ['||p_approver_user_id||'], '||
                'Task approver ['||l_user_full_name||']'
                 ,3);

    IF l_user_full_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'TASK_APPROVER_NAME'
                                   ,avalue       => l_user_full_name
            );
    END IF;

    l_user_full_name :='';
    OPEN  c_starter_full_name(p_approver_user_id );
    FETCH c_starter_full_name INTO l_user_full_name;
    IF c_starter_full_name%NOTFOUND THEN
         x_err_code := 100;
         x_err_stage:= 30;
    END IF;
    CLOSE c_starter_full_name;

    IF l_user_full_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'TASK_APPROVER_FULLNAME'
                                   ,avalue       => l_user_full_name
            );
    END IF;

    IF p_parent_struc_ver IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'PARENT_STRUC_VER_ID'
                                   ,avalue       => p_parent_struc_ver
            );
    END IF;

    WF_ENGINE.StartProcess (itemtype        => itemtype
                           ,itemkey         => itemkey
                            );

    IF x_err_code = 0 THEN
        PA_WORKFLOW_UTILS.Insert_WF_Processes (p_wf_type_code  => 'PATASKWF'
                                              ,p_item_type     => ItemType
                                              ,p_item_key      => ItemKey
                                              ,p_entity_key1   => c_task_info_rec.task_id
                                              ,p_description   => c_task_info_rec.task_number
                                              ,p_err_code      => l_err_code
                                              ,p_err_stage     => l_err_stage
                                              ,p_err_stack     => l_err_stack
                                              );
    END IF;

    IF l_err_code <> 0 THEN
       x_err_code := l_err_code;
       x_err_stage := l_err_stage;
       x_err_stack := l_err_stack;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_APPROVAL_WF ','Start_Task_Aprv_Wf');
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_err_code := SQLCODE;
        WF_CORE.CONTEXT('PA_TASK_APPROVAL_WF','Start_Task_Aprv_Wf');
        RAISE;
    WHEN OTHERS THEN
        --b6694902_debug.debug('In Others Exception ');
        --wf_engine.threshold := l_save_threshold;
        --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'PA_TASK_APPROVAL_PKG'
			,  p_procedure_name	=> 'Start_Task_Aprv_Wf'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
  END Start_Task_Aprv_Wf;

  -- Procedure to generate the task approval notificaiton
  PROCEDURE Generate_Task_Aprv_Notify
                              (p_item_type IN VARCHAR2
                              ,p_item_key  IN VARCHAR2
                              ,p_project_id IN NUMBER
                              ,p_org_id    IN NUMBER
                              ,p_task_id   IN NUMBER
                              ,p_parent_struc_ver IN NUMBER
                              ,p_ci_id     IN NUMBER
                              ,p_cd_yn     IN VARCHAR2 := 'Y'
                              ,x_content_id OUT NOCOPY NUMBER) IS

    -- Cursor to fetch the name of the organization for the inputted organization_id
    CURSOR c_orgz_info (p_carrying_out_organization_id NUMBER) IS
      SELECT  name organization_name
        FROM  HR_ORGANIZATION_UNITS
        WHERE organization_id = p_carrying_out_organization_id;

    -- Cursor to fetch the change document information for the respective change document id
    CURSOR c_ci_info IS
        SELECT ci_id,
               summary,
               pci.description,
               pctb.short_name||' ('||pci.ci_number||')' ci_number,
               ci_type_class_code,
               pci.created_by created_by,
               pci.creation_date creation_date
        FROM   PA_CONTROL_ITEMS pci,
               PA_CI_TYPES_vl pctb
        WHERE  ci_id = p_ci_id
        AND    pctb.ci_type_id = pci.ci_type_id;

    l_orgz_info_rec         c_orgz_info%ROWTYPE;
    l_project_number        pa_projects_all.segment1%TYPE;

    l_clob                  CLOB;
    l_text                  VARCHAR2(32767);
    l_index                 NUMBER;
    x_return_status         VARCHAR2(1);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(250);

    l_err_code              NUMBER := 0;
    l_err_stack             VARCHAR2(630);
    l_err_stage             VARCHAR2(80);

    l_page_content_id       NUMBER :=0;

    l_ci_type_class_code    VARCHAR2(15);
    l_ci_description        PA_CONTROL_ITEMS.description%TYPE;
    l_ci_created_by         VARCHAR2(300);
    l_ci_creation_date      DATE;
    l_ci_number             pa_control_items.ci_number%TYPE;

    l_mgr_name              VARCHAR2(1000);

    c_task_info_rec c_task_info%ROWTYPE;
    c_ci_info_rec   c_ci_info%ROWTYPE;
    c_user_info_rec c_user_info%ROWTYPE;

    PRAGMA AUTONOMOUS_TRANSACTION;


  BEGIN

    log_message('Inside the procedure Generate_Task_Aprv_Notify',3);

    log_message('Opening cursor for fetching the organization name' ,3);
    OPEN c_orgz_info(p_org_id);
    FETCH c_orgz_info INTO l_orgz_info_rec;
    CLOSE c_orgz_info;

    log_message('Opening cursor for fetching the task info',3);
    OPEN c_task_info(p_project_id, p_task_id);
    FETCH c_task_info INTO c_task_info_rec;
    IF c_task_info%NOTFOUND THEN
        CLOSE c_task_info;
        return;
    END IF;
    CLOSE c_task_info;


    log_message('Opening cursor for fetching task organization information',3);

    OPEN c_orgz_info(c_task_info_rec.organization);
    FETCH c_orgz_info INTO l_orgz_info_rec;
    CLOSE c_orgz_info;

    log_message('Fetching Task Manager name',3);
    BEGIN
       SELECT e.first_name||' '||e.last_name
       INTO   l_mgr_name
       FROM   PA_EMPLOYEES e
       WHERE  person_id = c_task_info_rec.manager_person_id;

       log_message('Task Manager ['||l_mgr_name||']',3);

    EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;

    log_message('Fetching the Change document information',3);
    OPEN c_ci_info;
    FETCH c_ci_info INTO c_ci_info_rec;
    CLOSE c_ci_info;

    open c_user_info(c_ci_info_rec.created_by);
    fetch c_user_info into c_user_info_rec;
    close c_user_info;

    l_ci_created_by := c_user_info_rec.full_name;

    x_content_id := 0;

    log_message('Creating the page content' ,3);

    -- Creating new page content in pa_page_contents.
    log_message('Before calling PA_PAGE_CONTENTS_PUB.create_page_contents' ,3);
    PA_PAGE_CONTENTS_PUB.Create_Page_Contents(p_init_msg_list   => fnd_api.g_false
                                             ,p_validate_only   => fnd_api.g_false
                                             ,p_object_type     => 'PA_TASK_APPROVAL_WF'
                                             ,p_pk1_value       => p_task_id
                                             ,p_pk2_value       => NULL
                                             ,x_page_content_id => l_page_content_id
                                             ,x_return_status   => x_return_status
                                             ,x_msg_count       => x_msg_count
                                             ,x_msg_data        => x_msg_data);

    x_content_id := l_page_content_id;

    BEGIN
        SELECT  page_content
          INTO  l_clob
          FROM  PA_PAGE_CONTENTS
          WHERE page_content_id = l_page_content_id FOR UPDATE NOWAIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE;
    END;

    l_text := '';

    log_message('Creating the page content dynamically',3);

    --Starting the page content
    l_text :=  '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- START : Task Information Section
    l_text :=  '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Heading
    l_text :=  '<tr><td height="12"><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);">';
    l_text := l_text || '<tr><td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
    l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Task Information</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '<tr><td height="8" bgcolor="#EAEFF5"></td></tr><tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Task Number
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Task Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || c_task_info_rec.task_number || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td>';
    l_text := l_text || '</tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Task Name
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Task Name</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || c_task_info_rec.task_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- Task Manager
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Task Manager</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_mgr_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Transaction Start
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Transaction Start</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || c_task_info_rec.scheduled_start_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project Number
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Number';
    l_text := l_text || '</font></td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || c_task_info_rec.project_number || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="5" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project Name
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Name</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || c_task_info_rec.project_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Organization
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Organization</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_orgz_info_rec.organization_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Task finish date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Transaction End</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || c_task_info_rec.scheduled_end_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td></tr></table></td></tr></table></td></tr><tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- END : Task Information Section

    IF p_cd_yn = 'Y' THEN

    l_text :=  '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Heading
    l_text :=  '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);"><tr>';
    l_text := l_text || '<td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px solid #aabed5">';
    l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Change Document Information</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '<tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Summary
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Summary</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || c_ci_info_rec.summary || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Description
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Description</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || c_ci_info_rec.description || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    IF c_ci_info_rec.ci_type_class_code = 'CHANGE_ORDER' THEN
       l_ci_type_class_code := 'Change Order';
    ELSE
        l_ci_type_class_code := 'Change Request';
    END IF;

    -- Document Type
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Change Document Type</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || l_ci_type_class_code || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    l_text := l_text || '<tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Number
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Number</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || c_ci_info_rec.ci_number|| '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr>';
    l_text := l_text || '<td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --System Number
    l_text := '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">System Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || to_char(c_ci_info_rec.ci_id) || '</b></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Created By
    l_text := '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Created By</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_ci_created_by || '</b></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Creation Date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Creation Date</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || to_char(c_ci_info_rec.creation_date,'DD-MON-YYYY') || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --This cell is Empty
    l_text :=  '<tr><td height="3"></td><td></td><td></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td></tr></table></td></tr></table></td></tr><tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    END IF;

    --START : References Section
    l_text := '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Header
    l_text := '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);">';
    l_text := l_text || '<tr><td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
    l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>References</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --URL Section to view change order request
    l_text := '<tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td> <div><div><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr>';
    l_text := l_text || '<td bgcolor="#EAEFF5"><table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td>';
    l_text := l_text || '<td valign="top"><table border="0" cellspacing="0" cellpadding="0"><tr><td align="right" valign="top" nowrap="nowrap"><span align="right">';
    l_text := l_text || '<img src="/OA_MEDIA/fwkhp_formsfunc.gif" alt="Change Document" width="16" height="16" border="0"></span></td><td width="12">';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
    l_text := l_text || '<a href="OA.jsp?_rc=PA_CI_CI_REVIEW_LAYOUT&addBreadCrumb=RP&_ri=275&paProjectId=' || p_project_id || '&paCiId=' ||c_ci_info_rec.ci_id|| '&paCITypeClassCode='||c_ci_info_rec.ci_type_class_code||'">Change Document </a>';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="5" /></font></td></tr><tr>';
    l_text := l_text || '<td height="3"></td><td></td><td></td></tr></table></tr></table></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text := '<tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
    --END : References Section

    --Closing the page content
    l_text :=  '</td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    COMMIT;
    l_text := '';

  EXCEPTION
    WHEN OTHERS THEN
    RAISE;
  END Generate_Task_Aprv_Notify;

  -- This is being called from the workflow to display the notification generated in html format
  PROCEDURE SHOW_TASK_NOTIFY_PREVIEW(document_id      IN VARCHAR2
                                   ,display_type     IN VARCHAR2
                                   ,document         IN OUT NOCOPY CLOB
                                   ,document_type    IN OUT NOCOPY VARCHAR2) IS

  l_content CLOB;

  CURSOR c_pwp_preview_info IS
   SELECT  page_content
     FROM  PA_PAGE_CONTENTS
     WHERE page_content_id =document_id
     AND   object_type = 'PA_TASK_APPROVAL_WF'
     AND   pk2_value IS NULL;

  l_size             number;
  l_chunk_size      PLS_INTEGER:=10000;
  l_copy_size     INT;
  l_pos             INT := 0;
  l_line             VARCHAR2(30000) := '';
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);


  BEGIN

  log_message('Inside the procedure SHOW_TASK_NOTIFY_PREVIEW',3);

  OPEN c_pwp_preview_info;
  FETCH c_pwp_preview_info INTO l_content;
  IF (c_pwp_preview_info%FOUND) THEN
      IF c_pwp_preview_info%ISOPEN THEN
          CLOSE c_pwp_preview_info;
      END IF;
      l_size := dbms_lob.getlength(l_content);
      l_pos := 1;
      l_copy_size := 0;
      WHILE (l_copy_size < l_size) LOOP
          DBMS_LOB.READ(l_content,l_chunk_size,l_pos,l_line);
          DBMS_LOB.WRITE(document,l_chunk_size,l_pos,l_line);
          l_copy_size := l_copy_size + l_chunk_size;
          l_pos := l_pos + l_chunk_size;
      END LOOP;

      log_message('Before calling PA_WORKFLOW_UTILS.modify_wf_clob_content',3);

      PA_WORKFLOW_UTILS.modify_wf_clob_content(p_document       =>  document
                                              ,x_return_status  =>  l_return_status
                                              ,x_msg_count      =>  l_msg_count
                                              ,x_msg_data       =>  l_msg_data);

      IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
          WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
          DBMS_LOB.writeappend(document, 255, SUBSTR(l_msg_data, 255));
      END IF;
  ELSE
      IF c_pwp_preview_info%ISOPEN THEN
          CLOSE c_pwp_preview_info;
      END IF;
  END IF;

  document_type := 'text/html';

  EXCEPTION
      WHEN OTHERS THEN
        WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
        dbms_lob.writeappend(document, 255, substrb('Testing', 255));
      NULL;
  END SHOW_TASK_NOTIFY_PREVIEW;

  -- Procedure to add content to the CLOB column
  PROCEDURE APPEND_VARCHAR_TO_CLOB(p_varchar IN varchar2
                                  ,p_clob    IN OUT NOCOPY CLOB) IS

  l_chunkSize   INTEGER;
  v_offset      INTEGER := 0;
  l_clob        clob;
  l_length      INTEGER;

  v_size        NUMBER;
  v_text        VARCHAR2(3000);

  BEGIN

  l_chunksize := length(p_varchar);
  l_length := dbms_lob.getlength(p_clob);

  DBMS_LOB.write(p_clob
                ,l_chunksize
                ,l_length+1
                ,p_varchar);
  v_size := 1000;
  DBMS_LOB.read(p_clob, v_size, 1, v_text);

  END APPEND_VARCHAR_TO_CLOB;

  FUNCTION show_error(p_error_stack   IN VARCHAR2,
                      p_error_stage   IN VARCHAR2,
                      p_error_message IN VARCHAR2,
                      p_arg1          IN VARCHAR2 DEFAULT null,
                      p_arg2          IN VARCHAR2 DEFAULT null) RETURN VARCHAR2 IS

  l_result FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN
     g_error_message := nvl(p_error_message,SUBSTRB(SQLERRM,1,1000));

     fnd_message.set_name('PA','PA_WF_FATAL_ERROR');
     fnd_message.set_token('ERROR_STACK',p_error_stack);
     fnd_message.set_token('ERROR_STAGE',p_error_stage);
     fnd_message.set_token('ERROR_MESSAGE',g_error_message);
     fnd_message.set_token('ERROR_ARG1',p_arg1);
     fnd_message.set_token('ERROR_ARG2',p_arg2);

     l_result  := fnd_message.get_encoded;

     g_error_message := NULL;

     RETURN l_result;
  EXCEPTION WHEN OTHERS
  THEN
     raise;
  END show_error;

  -- This is to verify if the submitted task is root task or a child task
  PROCEDURE Is_Child_Task (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2) IS

        l_project_id       NUMBER;
        l_proj_element     NUMBER;
        l_parent_struc_ver NUMBER;
        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(4000);
        l_return_status    VARCHAR2(1);
        l_proj_org         NUMBER;
        l_ci_id            NUMBER;
        l_content_id       NUMBER;
  BEGIN

      log_message('Inside Is_Child_Task',3);

      l_project_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJECT_ID');
      l_proj_element  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_ID');
      l_parent_struc_ver  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PARENT_STRUC_VER_ID');
      l_proj_org  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJ_ORG_ID');
      l_ci_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'CI_ID');

      log_message('Before calling PA_TASK_APPROVAL_PKG.Is_Child_Task',3);

      IF PA_TASK_APPROVAL_PKG.Is_Child_Task (
                                 l_project_id
                                ,l_proj_element
                                ,l_parent_struc_ver
                                ,l_msg_count
                                ,l_msg_data
                                ,l_return_status   ) THEN
        log_message('Task '||l_proj_element||' is a child task',3);
        resultout := wf_engine.eng_completed||':'||'T';
      ELSE
         log_message('Generating notification for task approval',3);
         Generate_Task_Aprv_Notify(p_item_type      => itemtype
                                ,p_item_key         => itemkey
                                ,p_task_id          => l_proj_element
                                ,p_project_id       => l_project_id
                                ,p_org_id           => l_proj_org
                                ,p_parent_struc_ver => l_parent_struc_ver
                                ,p_ci_id            => l_ci_id
                                ,x_content_id       => l_content_id
                                );

         IF l_content_id IS NOT NULL THEN
             WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                         ,itemkey      => itemkey
                                         ,aname        => 'CONTENT_ID'
                                         ,avalue       => l_content_id
                                          );
         END IF;

         UPDATE PA_PROJ_ELEMENTS
         SET    task_status = 'SUBMITTED'
         WHERE  proj_element_id = l_proj_element;

         resultout := wf_engine.eng_completed||':'||'F';
         log_message('Task '||l_proj_element||' is a top/root task',3);
      END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Child_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Child_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Child_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
  END Is_Child_Task;

  -- If the task, which is submitted for Approval is a child task, this procedure verifies if its parent
  -- task is approved or not. If the parent task is not approved, it will send a notification to the
  PROCEDURE Is_Parent_Task_Approved
                          (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2) IS
        l_project_id       NUMBER;
        l_proj_element     NUMBER;
        l_parent_task_id   NUMBER;
        l_parent_struc_ver NUMBER;
        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(4000);
        l_return_status    VARCHAR2(1);
        l_proj_org         NUMBER;
        l_content_id       NUMBER;
        l_ci_id            NUMBER;
  BEGIN
      log_message('Inside the procedure Is_Parent_Task_Approved',3);

      l_project_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJECT_ID');

      l_proj_element  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_ID');

      l_parent_task_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PARENT_TASK_ID');
      l_parent_struc_ver  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PARENT_STRUC_VER_ID');

      l_proj_org  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJ_ORG_ID');

      l_ci_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'CI_ID');

      IF PA_TASK_APPROVAL_PKG.Is_Parent_Task_Approved (
                                 l_project_id
                                ,l_parent_task_id
                                ,l_proj_element
                                ,l_parent_struc_ver
                                ,l_msg_count
                                ,l_msg_data
                                ,l_return_status   ) THEN

         Generate_Task_Aprv_Notify(p_item_type       => itemtype
                                  ,p_item_key         => itemkey
                                  ,p_task_id          => l_proj_element
                                  ,p_project_id       => l_project_id
                                  ,p_org_id           => l_proj_org
                                  ,p_parent_struc_ver => l_parent_struc_ver
                                  ,p_ci_id            => l_ci_id
                                  ,x_content_id       => l_content_id
                                  );
         IF l_content_id IS NOT NULL THEN
             WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                         ,itemkey      => itemkey
                                         ,aname        => 'CONTENT_ID'
                                         ,avalue       => l_content_id
                                          );
         END IF;

         log_message('Parent Task '||l_parent_task_id||' of task '||l_proj_element||' is approved',3);
         log_message('Updating the task status to Submitted',3);

         UPDATE PA_PROJ_ELEMENTS
         SET    task_status = 'SUBMITTED'
         WHERE  proj_element_id = l_proj_element;

        resultout := wf_engine.eng_completed||':'||'T';
     ELSE
        log_message('Parent Task '||l_parent_task_id||' of task '||l_proj_element||' is not yet approved',3);
        resultout := wf_engine.eng_completed||':'||'F';
     END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Parent_Task_Approved',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Parent_Task_Approved',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Parent_Task_Approved',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
  END Is_Parent_Task_Approved;

  -- This procedure calls PA_TASKS_MAINT_PUB.CREATE_TASK API that populates pa_tasks.
  -- This is being called from Task approval workflow on approving the task from Approval Notification.
  PROCEDURE Post_Task (itemtype IN VARCHAR2
                      ,itemkey IN VARCHAR2
                      ,actid IN NUMBER
                      ,funcmode IN VARCHAR2
                      ,resultout OUT NOCOPY VARCHAR2) IS

    l_project_id        NUMBER;
    l_parent_task_id    NUMBER;
    l_task_number       VARCHAR2(30);
    l_task_name         VARCHAR2(240);
    l_task_st_date      DATE;
    l_task_end_date     DATE;

    l_task_id           NUMBER;
    l_org_id            NUMBER;
    l_ci_id             NUMBER;
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(4000);

    l_result            VARCHAR2(30);

    l_billable_flag     VARCHAR2(1);
    l_chargeable_flag   VARCHAR2(1);
    x_err_stack         VARCHAR2(2000);
    x_err_stage         VARCHAR2(100);
    x_err_code          NUMBER;
    l_item_key              pa_wf_processes.item_key%TYPE;

    -- Cursor to fetch the element version id and parent structure version id for
    -- a specific task.
    CURSOR C1(p_proj_elemt_id NUMBER) IS
       SELECT ppe.proj_element_id,
              ppev.element_version_id,
              ppev.parent_structure_version_id
       FROM   PA_PROJ_ELEMENTS ppe,
              PA_PROJ_ELEMENT_VERSIONS ppev
       WHERE  ppev.proj_element_id = ppe.proj_element_id
       AND    ppe.proj_element_id = p_proj_elemt_id;

    -- Cursor to find out all the immediate child tasks of a task which are in
    -- PENDING status.
    CURSOR C2(p_element_version_id NUMBER,p_project_id NUMBER) IS
       SELECT  ppe.proj_element_Id task_id,
	           ppe.record_version_number,
		       ppev.parent_structure_version_id,
		       ppe.task_approver_id task_app_chg_id
	   FROM    PA_PROJ_ELEMENTS PPE, PA_OBJECT_RELATIONSHIPS POR, PA_PROJ_ELEMENT_VERSIONS PPEV
	   WHERE   ppe.project_id = p_project_id
	   AND     ppev.proj_element_id = ppe.proj_element_id
       AND     ppev.financial_task_flag = 'Y'
	   AND     por.object_id_to1 = ppev.element_version_id
	   AND     por.relationship_type = 'S'
       AND     por.relationship_subtype = 'TASK_TO_TASK'
	   AND     por.object_id_from1 = p_element_version_id
       AND     ppe.link_task_flag = 'Y'
       AND     ppe.task_status ='PENDING';

    -- Cursor is to pickup all the Change Documents that have referred this TASK
    -- and are in SUBMITTED status.
    CURSOR C3(p_project_id NUMBER, p_task_id NUMBER) IS
       SELECT pci.ci_id,
              pcia.ci_action_id action_id
       FROM   pa_control_items pci, pa_ci_actions pcia
       WHERE  pci.project_id = p_project_id
       AND    pcia.ci_id(+) = pci.ci_id
       AND    pcia.ci_action_number(+) = pci.open_action_num
       AND EXISTS (SELECT 1 FROM pa_budget_versions pbv, pa_resource_assignments pra
                   WHERE  pbv.project_id = pci.project_Id
                   AND    pbv.ci_id = pci.ci_id
                   AND    pra.budget_version_id = pbv.budget_version_id
                   AND    pra.project_id = p_project_id
                   AND    pra.task_id = p_task_id)
       AND   pci.status_code in ('CI_SUBMITTED');


  BEGIN

          log_message('Inside procedure POST_TASK ',3);
          l_project_id      :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJECT_ID');
          l_parent_task_id  :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PARENT_TASK_ID');
          l_task_number     :=    WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_NUMBER');
          l_task_name       :=    WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_NAME');
          l_task_id         :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_ID');
          l_task_st_date    :=    WF_ENGINE.GetItemAttrDate(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_ST_DATE');
          l_task_end_date   :=    WF_ENGINE.GetItemAttrDate(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_END_DATE');
          l_org_id          :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJ_ORG_ID');
          l_ci_id           :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'CI_ID');
          l_result          :=   WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'RESULT');


          IF l_parent_task_id  = l_task_id THEN
             l_parent_task_id := '';
          END IF;

         --b6694902_debug.debug('l_result '||l_result);
         log_message('l_result ['||l_result||']',3);
         /*  l_result :
                 CANDB -> Chargeable and Billable
                     C -> Chargeable only
                     B -> Billable only
         */
         IF l_result = 'CANDB' THEN
             l_billable_flag := 'Y';
             l_chargeable_flag :=  'Y';
         ELSIF l_result = 'C' THEN
             l_billable_flag := 'N';
             l_chargeable_flag :=  'Y';
         ELSIF l_result = 'B' THEN
             l_billable_flag := 'Y';
             l_chargeable_flag :=  'N';
         END IF;

          log_message('Before calling PA_TASKS_MAINT_PUB.CREATE_TASK',3);
          PA_TASKS_MAINT_PUB.CREATE_TASK
               (
                 p_calling_module         => 'SELF_SERVICE'
                ,p_init_msg_list          => FND_API.G_FALSE
                ,p_debug_mode             => 'Y'
                ,p_project_id             => l_project_id
                ,p_reference_task_id      => l_parent_task_id
                ,p_peer_or_sub            => 'SUB'
                ,p_task_number            => l_task_number
                ,p_task_name              => l_task_name
                ,p_task_id                => l_task_id
                ,p_chargeable_flag        => l_chargeable_flag
                ,p_billable_flag          => l_billable_flag
                ,p_task_start_date       => l_task_st_date
                ,p_task_completion_date  => l_task_end_date
                ,p_wbs_record_version_number => 1
                ,p_carrying_out_organization_id => l_org_id
                ,x_return_status          =>x_return_status
                ,x_msg_count              =>x_msg_count
                ,x_msg_data               =>x_msg_data
            );
	   --b6694902_debug.debug('Inside POST_TASK for task '||l_task_id||' Status:'||x_return_status);
	   --b6694902_debug.debug('Inside POST_TASK for task '||l_task_id||' x_msg_data:'||x_msg_data);

     IF x_return_status <> 'S' THEN
        log_message('Call to PA_TASKS_MAINT_PUB.CREATE_TASK is errored out',3);
        resultout := wf_engine.eng_completed||':'||'F';
     ELSE
        log_message('Create Task is successful',3);
        UPDATE PA_PROJ_ELEMENTS SET link_task_flag = 'N', task_status = ''
        WHERE proj_element_id = l_task_id;

        log_message('Raising notification for all child tasks in pending status',3);
        -- This is to raise notification for all child tasks which are in submitted status when the parent task is approved.
        FOR parent_task IN C1(l_task_id) LOOP
            FOR child_task IN C2(parent_task.element_version_id, l_project_id) LOOP

                      PA_TASK_WORKFLOW_PKG.Start_Task_Aprv_Wf (
                                'PATASKWF'
                               ,'PA_TASK_APPROVAL_WF'
                               ,l_project_id
                               ,child_task.task_id
                               ,child_task.parent_structure_version_id
                               ,child_task.task_app_chg_id
                               ,l_ci_id
                               ,x_err_stack
                               ,x_err_stage
                               ,x_err_code
                              );
            END LOOP;

            -- This is to raise notification for all Change Documents which are in CI_SUBMITTED status
            -- We raise notification for CD only in case if the task submitted is the last task which is referred in this CD.
            log_message('Raising notification for all Change Documents in Submitted status',3);
            FOR ci_info IN C3(l_project_id, l_task_id) LOOP

                  PA_TASK_APPROVAL_PKG.Check_UsedTask_Status
                           (ci_info.ci_id
                           ,x_msg_count
                           ,x_msg_data
                           ,x_return_status);

                 IF x_return_status = 'S' THEN
                    /*PA_CONTROL_ITEMS_WORKFLOW.START_NOTIFICATION_WF
                       (  p_item_type		=> 'PAWFCISC'
	                     ,p_process_name	=> 'PA_CI_PROCESS_APPROVAL'
	                     ,p_ci_id		    => ci_info.ci_id
	                     ,p_action_id		=> ci_info.action_id
                         ,x_item_key		=> l_item_key
                         ,x_return_status   => x_return_status
                         ,x_msg_count       => x_msg_count
                         ,x_msg_data        => x_msg_data    );*/
					PA_CONTROL_ITEMS_WORKFLOW.start_workflow
					(p_item_type		=> 'PAWFCISC'
	                     ,p_process_name	=> 'PA_CI_PROCESS_APPROVAL'
	                     ,p_ci_id		    => ci_info.ci_id
						 ,x_item_key		=> l_item_key
                         ,x_return_status   => x_return_status
                         ,x_msg_count       => x_msg_count
                         ,x_msg_data        => x_msg_data
					);
                 END IF;

            END LOOP;

        END LOOP;
        resultout := wf_engine.eng_completed||':'||'T';
     END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Post_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Post_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Post_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
  END Post_Task;

  -- This is to update the task status to 'Pending' in case if the submitted task has
  -- unapproved parent task.

  PROCEDURE Update_Task_Status(itemtype  IN VARCHAR2
                              ,itemkey   IN VARCHAR2
                              ,actid     IN NUMBER
                              ,funcmode  IN VARCHAR2
                              ,resultout OUT NOCOPY VARCHAR2) IS

    l_aprv_user_id     NUMBER;
    l_proj_element_id  NUMBER;
    l_ci_id            NUMBER;
    l_project_id       NUMBER;
    l_parent_struc_ver NUMBER;
    l_task_id          NUMBER;
    l_org_id           NUMBER;
    x_return_status    VARCHAR2(1);
    x_msg_count        NUMBER;
    x_msg_data         VARCHAR2(4000);
    l_content_id       NUMBER;
  BEGIN
         log_message('Inside Update_Task_Status Procedure',3);

         log_message('Fetching all the workflow attribute values required',3);

         l_project_id      :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJECT_ID');
         l_task_id         :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_ID');
         l_org_id          :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJ_ORG_ID');

         l_parent_struc_ver  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PARENT_STRUC_VER_ID');

         l_aprv_user_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                   ,itemkey  => itemkey
                                                   ,aname    => 'TASK_APPROVER_ID');

         l_proj_element_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                   ,itemkey  => itemkey
                                                   ,aname    => 'TASK_ID');

         l_ci_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                   ,itemkey  => itemkey
                                                   ,aname    => 'CI_ID');

         log_message('Marking task status to pending for its parent tasks approval',3);
         UPDATE PA_PROJ_ELEMENTS SET task_status = 'PENDING',
                                     task_approver_id = l_aprv_user_id
         WHERE  proj_element_id = l_proj_element_id;

         log_message('Calling generate_task_aprv_notify to generate the notification',3);
         Generate_Task_Aprv_Notify(p_item_type      => itemtype
                                  ,p_item_key         => itemkey
                                  ,p_task_id          => l_task_id
                                  ,p_project_id       => l_project_id
                                  ,p_org_id         => l_org_id
                                  ,p_parent_struc_ver => l_parent_struc_ver
                                  ,p_ci_id            => l_ci_id
                                  ,p_cd_yn            => 'N'
                                  ,x_content_id       => l_content_id
                                  );
         IF l_content_id IS NOT NULL THEN
             WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                         ,itemkey      => itemkey
                                         ,aname        => 'CONTENT_ID'
                                         ,avalue       => l_content_id
                                          );
         END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Update_Task_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Update_Task_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Update_Task_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

  END Update_Task_Status;

  -- This procedure is to delete all the references of the submitted task when it is rejected by the
  -- approver.

  PROCEDURE Delete_Task(itemtype  IN VARCHAR2
                       ,itemkey   IN VARCHAR2
                       ,actid     IN NUMBER
                       ,funcmode  IN VARCHAR2
                       ,resultout OUT NOCOPY VARCHAR2) IS

    -- Cursor to fetch the element version id and parent structure version id of a given task
    CURSOR C1(p_proj_elemt_id NUMBER) IS
       SELECT ppe.proj_element_id,
              ppev.element_version_id,
              ppev.parent_structure_version_id
       FROM   PA_PROJ_ELEMENTS ppe,
              PA_PROJ_ELEMENT_VERSIONS ppev
       WHERE  ppev.proj_element_id = ppe.proj_element_id
       AND    ppe.proj_element_id = p_proj_elemt_id;

    -- Cursor to fetch the TASK provided along with all of it's child tasks which are
    -- in unapproved status.
    CURSOR C2 (p_project_id NUMBER, p_element_version_id NUMBER, p_task_id NUMBER) IS
       SELECT  ppe.proj_element_Id task_id,
	           ppe.record_version_number,
		       ppev.parent_structure_version_id,
		       ppev.element_version_id
	   FROM    PA_PROJ_ELEMENTS PPE,
			   PA_PROJ_ELEMENT_VERSIONS PPEV
	   WHERE   ppe.project_id = p_project_id
	   AND     ppev.proj_element_id = ppe.proj_element_id
       AND     ppev.financial_task_flag = 'Y'
       AND     ppe.task_status IN ('NEW','SUBMITTED','PENDING')
	   AND     ppev.element_version_id in (
	   SELECT object_id_to1
              FROM pa_object_relationships
             WHERE relationship_type = 'S'
			 AND relationship_subtype = 'TASK_TO_TASK'
        START WITH object_id_from1 = p_element_version_id
		AND relationship_type = 'S'
        CONNECT BY object_id_from1 = PRIOR object_id_to1
		AND relationship_type = prior relationship_type AND relationship_type = 'S'
		) UNION ALL
        SELECT  ppe.proj_element_Id task_id,
	           ppe.record_version_number,
		       ppev.parent_structure_version_id,
		       ppev.element_version_id
	   FROM    PA_PROJ_ELEMENTS PPE,
			   PA_PROJ_ELEMENT_VERSIONS PPEV
	   WHERE   ppe.project_id = p_project_id
	   AND     ppe.proj_element_id = ppev.proj_element_id
	   AND     ppe.proj_element_id =p_task_id;

    l_ci_id              NUMBER;
    l_proj_element_id    NUMBER;
    l_project_id         NUMBER;
    l_parent_struc_ver   NUMBER;
    l_task_id            NUMBER;
    x_return_status      VARCHAR2(1);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(4000);
    l_loop_ctr           NUMBER :=1;
    l_aprv_user_id       NUMBER;
  BEGIN

          log_message('Inside Delete_Task Procedure',3);

          l_ci_id           :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'CI_ID');
          l_project_id      :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJECT_ID');
          l_task_id         :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'TASK_ID');

          l_aprv_user_id    :=    WF_ENGINE.GetItemAttrNumber
                                                 (itemtype     => itemtype
                                                  ,itemkey      => itemkey
                                                  ,aname        => 'TASK_APPROVER_ID'
                                                 );
          g_del_taskrec.delete;
          log_message('Storing the task details into pl/sql table and we delete the data
                       furtherly in is_last_task procedure',3);
          FOR parent_task IN C1(l_task_id) LOOP
              FOR child_task IN C2(l_project_id, parent_task.element_version_id, l_task_id) LOOP
                 --IF child_task.task_id <> l_task_id THEN
                  g_del_taskrec(l_loop_ctr).project_id := l_project_id;
                  g_del_taskrec(l_loop_ctr).task_id := child_task.task_id;
                  g_del_taskrec(l_loop_ctr).elem_ver_id  :=    child_task.element_version_id;
                  g_del_taskrec(l_loop_ctr).rec_ver_num  :=    child_task.record_version_number;
                  g_del_taskrec(l_loop_ctr).parent_struc_ver :=child_task.parent_structure_version_id ;
                  l_loop_ctr := l_loop_ctr +1;
                 --END IF;
              END LOOP;
          END LOOP;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Delete_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Delete_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Delete_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

  END Delete_Task;

  -- This is to verify task status in change order workflow. If all tasks used in Change Document
  -- are approved we raise notification for Change document for its approval. If an unapproved task is
  -- used in multiple Change documents and if any of such Change document is submitted for approval,
  -- a notification will be raised for this task with respect to the change document submitted for approval.

  PROCEDURE Verify_Task_Status
                          (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2) IS

    l_ci_id              NUMBER;
    l_project_id         NUMBER;
    x_return_status      VARCHAR2(1);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(4000);
    x_err_stack         VARCHAR2(2000);
    x_err_stage         VARCHAR2(100);
    x_err_code          NUMBER;

   -- Cursor to find out all unapproved tasks referred in one particular Change Document.
   CURSOR C1 IS
   Select distinct task_id from
          pa_resource_assignments pra where
          budget_version_id in (
           select budget_version_id from pa_budget_versions where ci_id = l_ci_id )
        and exists (select 1
                  from pa_proj_elements ppe,
                       pa_proj_element_versions ppev,
                       pa_object_relationships por
                  where ppe.proj_element_id = pra.task_id
                  and ppe.project_id = pra.project_id
                  and ppe.link_task_flag = 'Y'
                  and ppe.type_id = 1
                  and ppev.proj_element_id = ppe.proj_element_id
                  and por.object_id_to1 = ppev.element_version_id
                  and por.object_type_to = 'PA_TASKS'
                  and por.relationship_type = 'S'
                  and ppev.financial_task_flag = 'Y')
        and not exists (select 1 from pa_tasks where task_id = pra.task_id and project_id = pra.project_id);

    l_unapproved_task_cnt NUMBER :=0;
    c_task_rec c_task_info%ROWTYPE;
    l_max_notification_id  WF_NOTIFICATIONS.notification_id%TYPE;
  BEGIN
         log_message('Inside Verify_Task_Status',3);
         x_return_status := 'S';

         l_ci_id      :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                       ,itemkey  => itemkey
                                                       ,aname    => 'CI_ID');

         l_project_id :=   WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                       ,itemkey  => itemkey
                                                       ,aname    => 'PROJECT_ID');
        log_message('Closing any earlier notifications of task and raising new notification',3);
        FOR TaskId in C1 LOOP
           l_unapproved_task_cnt := l_unapproved_task_cnt+1;
           l_max_notification_id := '';

           OPEN c_task_info(l_project_id, TaskId.Task_Id);
           FETCH c_task_info INTO c_task_rec;
           CLOSE c_task_info;

           IF c_task_rec.task_status = 'SUBMITTED' THEN
             BEGIN
               SELECT max(notification_id)
               INTO   l_max_notification_id
               FROM   WF_NOTIFICATIONS WFN
	           WHERE  message_type = 'PATASKWF'
               AND    status = 'OPEN'
               AND    EXISTS (
                          SELECT 1
                          FROM   WF_NOTIFICATION_ATTRIBUTES
                          WHERE  notification_id = wfn.notification_id
                          AND    name = 'TASK_NUMBER'
                          AND    text_value like c_task_rec.task_number
                             )
               AND    EXISTS (
                          SELECT 1
                          FROM   WF_NOTIFICATION_ATTRIBUTES
                          WHERE  notification_id = wfn.notification_id
                          AND    name = 'PROJECT_NUMBER'
                          AND    text_value like c_task_rec.project_number
                             );
             EXCEPTION
                WHEN OTHERS THEN
                   NULL;
             END;
             IF l_max_notification_id IS NOT NULL THEN
                UPDATE WF_NOTIFICATIONS
                SET status = 'CLOSED'
                WHERE notification_id = l_max_notification_id;
                PA_TASK_WORKFLOW_PKG.Start_Task_Aprv_Wf (
                                       'PATASKWF'
                                      ,'PA_TASK_APPROVAL_WF'
                                      ,l_project_id
                                      ,c_task_rec.task_id
                                      ,c_task_rec.parent_structure_version_id
                                      ,c_task_rec.task_app_chg_id
                                      ,l_ci_id
                                      ,x_err_stack
                                      ,x_err_stage
                                      ,x_err_code
                                                     );
             END IF;
           END IF;
        END LOOP;

        IF l_unapproved_task_cnt >0  THEN
           log_message('There are '||l_unapproved_task_cnt||' unapproved tasks for this Change Document',3);
           resultout := wf_engine.eng_completed||':'||'F';
        ELSE
           log_message('There is no task pending for Approval, which is used in this Change document',3);
           resultout := wf_engine.eng_completed||':'||'T';
        END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Verify_Task_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Verify_Task_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Verify_Task_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
  END Verify_Task_Status;

  -- In case the change document is submitted for approval, we mark the change document to 'CI_SUBMITTED'
  -- if any of the task referred in this change document is not yet approved.
  PROCEDURE Mark_CO_Status
                          (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2) IS

    x_return_status      VARCHAR2(1);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(4000);
    l_ci_id              NUMBER;
  BEGIN
      log_message('Inside MARK_CO_STATUS',3);
      x_return_status := 'S';

      l_ci_id      :=    WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                             ,itemkey  => itemkey
                                             ,aname    => 'CI_ID');
      log_message('Marking change document status to CI_SUBMITTED',3);
      PA_TASK_APPROVAL_PKG.Mark_CO_Status(
                           l_ci_id
                          ,x_msg_count
                          ,x_msg_data
                          ,x_return_status);
      IF x_return_status = 'E' THEN
          resultout := wf_engine.eng_completed||':'||'F';
      ELSE
          resultout := wf_engine.eng_completed||':'||'T';
      END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Mark_CO_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Mark_CO_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Mark_CO_Status',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
  END Mark_CO_Status;

  -- This procedure is being called from Task Approval workflow when the Approver chooses
  -- reject the task. We are supposed to delete all the child tasks of the task which is selected
  -- for deletion and raise a FYI notification to the user created the task.

  PROCEDURE Is_Last_Task (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2) IS

        l_project_id       NUMBER;
        l_proj_element     NUMBER;

        l_proj_org         NUMBER;
        l_ci_id            NUMBER;
        l_content_id       NUMBER;

        l_elem_ver_id            NUMBER(15);
        l_rec_ver_num            NUMBER(15);
        l_parent_struc_ver       NUMBER(15);

        l_user_full_name                VARCHAR(400);
        l_user_name                     VARCHAR(240);

        x_return_status      VARCHAR2(1);
        x_msg_count          NUMBER;
        x_msg_data           VARCHAR2(4000);

    CURSOR c_starter_name(l_starter_user_id NUMBER) IS
      SELECT  user_name
        FROM  FND_USER
        WHERE user_id = l_starter_user_id;

    CURSOR c_starter_full_name(l_starter_user_id NUMBER) IS
      SELECT  e.first_name||' '||e.last_name
        FROM  FND_USER f, PER_ALL_PEOPLE_F e
        WHERE f.user_id = l_starter_user_id
        AND   f.employee_id = e.person_id
        AND   e.effective_end_date = ( SELECT MAX(papf.effective_end_date)
                                       FROM per_all_people_f papf
                                       WHERE papf.person_id = e.person_id);
    c_task_info_rec c_task_info%ROWTYPE;
  BEGIN

    log_message('Inside Is_Last_Task Procedure ',3);

    -- If the Pl/sql table has records, we proceed to delete the task data.
    IF g_del_taskrec.COUNT >0 THEN

      log_message('Deleting the task :'||g_del_taskrec(g_del_taskrec.FIRST).task_id,3);

      l_elem_ver_id     := g_del_taskrec(g_del_taskrec.FIRST).elem_ver_id;
      l_rec_ver_num     := g_del_taskrec(g_del_taskrec.FIRST).rec_ver_num;
      l_parent_struc_ver:= g_del_taskrec(g_del_taskrec.FIRST).parent_struc_ver;

      -- Fetch Task Info
      OPEN c_task_info(g_del_taskrec(g_del_taskrec.FIRST).project_id,
                       g_del_taskrec(g_del_taskrec.FIRST).task_id);
      FETCH c_task_info INTO c_task_info_rec;
      CLOSE c_task_info;

      OPEN c_starter_name (c_task_info_rec.created_by);
      FETCH c_starter_name INTO l_user_name;
      CLOSE c_starter_name;

      OPEN c_starter_full_name (c_task_info_rec.created_by);
      FETCH c_starter_full_name INTO l_user_full_name;
      CLOSE c_starter_full_name;

      log_message('Setting the item attributes to reflect the respective task data',3);
      IF c_task_info_rec.parent_task_number IS NOT NULL THEN
           WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'PARENT_TASK_NUMBER'
                                     ,avalue     => c_task_info_rec.parent_task_number
                                      );
      END IF;

      IF c_task_info_rec.parent_task_id IS NOT NULL THEN
           WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                       ,itemkey    => itemkey
                                       ,aname      => 'PARENT_TASK_ID'
                                       ,avalue     => c_task_info_rec.parent_task_id
                                        );
      END IF;

      IF c_task_info_rec.task_number IS NOT NULL THEN
           WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                     ,itemkey  => itemkey
                                     ,aname    => 'TASK_NUMBER'
                                     ,avalue   => c_task_info_rec.task_number
                                     );
      END IF;

      IF c_task_info_rec.task_name IS NOT NULL THEN
           WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'TASK_NAME'
                                     ,avalue     => c_task_info_rec.task_number
                                    );
      END IF;

      IF c_task_info_rec.task_id IS NOT NULL THEN
           WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                       ,itemkey      => itemkey
                                       ,aname        => 'TASK_ID'
                                       ,avalue       => c_task_info_rec.task_id
                                       );
      END IF;

      IF c_task_info_rec.created_by IS NOT NULL THEN
           WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                       ,itemkey    => itemkey
                                       ,aname      => 'SUBMITTED_BY_ID'
                                       ,avalue     => c_task_info_rec.created_by
                                        );
      END IF;

      IF l_user_full_name IS NOT NULL THEN
           WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                     ,itemkey      => itemkey
                                     ,aname        => 'SUBMITTED_BY'
                                     ,avalue       => l_user_full_name
                                     );
      END IF;

      IF c_task_info_rec.created_by IS NOT NULL THEN
           WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                       ,itemkey    => itemkey
                                       ,aname      => 'WORKFLOW_STARTED_BY_ID'
                                       ,avalue     => c_task_info_rec.created_by
                                        );
      END IF;

      IF l_user_name IS NOT NULL THEN
           WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                     ,itemkey      => itemkey
                                     ,aname        => 'WORKFLOW_STARTED_BY_NAME'
                                     ,avalue       => l_user_name
                                     );
      END IF;

      l_project_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJECT_ID');

      l_proj_org  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJ_ORG_ID');
      l_ci_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'CI_ID');

         log_message('Calling generate_task_aprv_notify to generate notification',3);
         Generate_Task_Aprv_Notify(p_item_type      => itemtype
                                ,p_item_key         => itemkey
                                ,p_task_id          => c_task_info_rec.task_id
                                ,p_project_id       => l_project_id
                                ,p_org_id           => l_proj_org
                                ,p_parent_struc_ver => l_parent_struc_ver
                                ,p_ci_id            => l_ci_id
                                ,x_content_id       => l_content_id
                                );

         IF l_content_id IS NOT NULL THEN
             WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                         ,itemkey      => itemkey
                                         ,aname        => 'CONTENT_ID'
                                         ,avalue       => l_content_id
                                          );
         END IF;

        DELETE FROM PA_RESOURCE_ASSIGNMENTS
        WHERE  project_id = l_project_id
        AND    task_id = c_task_info_rec.task_id;

        log_message('Before calling PA_TASK_PUB1.Delete_Task_Version',3);
        PA_TASK_PUB1.Delete_Task_Version
                            ( p_task_version_id         =>   l_elem_ver_id
                             ,p_record_version_number   =>   l_rec_ver_num
                             ,p_structure_version_id    =>   l_parent_struc_ver
                             ,x_return_status           =>   x_return_status
                             ,x_msg_count               =>   x_msg_count
                             ,x_msg_data                =>   x_msg_data    ) ;

        DELETE FROM PA_PROJ_ELEM_VER_SCHEDULE
        WHERE element_version_id = l_elem_ver_id;

        IF g_del_taskrec.COUNT > 0 THEN
            resultout := wf_engine.eng_completed||':'||'F';
        ELSE
            resultout := wf_engine.eng_completed||':'||'T';
        END IF;
        g_del_taskrec.delete(g_del_taskrec.FIRST,g_del_taskrec.FIRST);
    ELSE
        resultout := wf_engine.eng_completed||':'||'T';
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Last_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Last_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

    WHEN OTHERS THEN
        WF_CORE.CONTEXT('PA_TASK_WORKFLOW_PKG','Is_Last_Task',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
  END Is_Last_Task;

END PA_TASK_WORKFLOW_PKG;

/
