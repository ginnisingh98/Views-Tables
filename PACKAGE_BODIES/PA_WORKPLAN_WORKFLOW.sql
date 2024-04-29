--------------------------------------------------------
--  DDL for Package Body PA_WORKPLAN_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKPLAN_WORKFLOW" as
/*$Header: PAXSTWWB.pls 120.7.12010000.2 2008/08/22 16:18:28 mumohan ship $*/

g_module_name VARCHAR2(100) := 'pa.plsql.pa_workplan_workflow';

  procedure START_WORKFLOW
  (
    p_item_type              IN  VARCHAR2
   ,p_process_name           IN  VARCHAR2
   ,p_structure_version_id   IN  NUMBER
   ,p_responsibility_id      IN  NUMBER
   ,p_user_id                IN  NUMBER
   ,x_item_key               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_item_key NUMBER;
  BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    select pa_workflow_itemkey_s.nextval
      into l_item_key
      from dual;

    x_item_key := to_char(l_item_key);

    wf_engine.createProcess(p_item_type,
                            x_item_key,
                            p_process_name);

    pa_workplan_workflow_client.start_workflow(p_item_type,
                                               x_item_key,
                                               p_process_name,
                                               p_structure_version_id,
                                               p_responsibility_id,
                                               p_user_id,
                                               x_msg_count,
                                               x_msg_data,
                                               x_return_status
    );


    IF x_return_status = FND_API.g_ret_sts_success THEN
      WF_ENGINE.startProcess(p_item_type,
                             x_item_key);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_msg_count :=1;
      x_msg_data:= substrb(SQLERRM, 1, 2000); -- 4537865 : Replaced substr with substrb
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_item_key := NULL ; -- 4537865
  END START_WORKFLOW;


  procedure cancel_workflow
  (
    p_item_type              IN  VARCHAR2
   ,p_item_key               IN  VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    WF_ENGINE.ABORTPROCESS(p_item_type,
                           p_item_key);
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_count :=1;
      x_msg_data:= substrb(SQLERRM, 1, 2000); -- 4537865 : Replaced substr with substrb
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CANCEL_WORKFLOW;


  procedure check_workplan_status
  (
    itemtype       IN   VARCHAR2
   ,itemkey        IN   VARCHAR2
   ,actid          IN   NUMBER
   ,funcmode       IN   VARCHAR2
   ,resultout      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_project_id             NUMBER;
    l_structure_version_id   NUMBER;
    l_status                 VARCHAR2(30);
    l_ret                    VARCHAR2(240);

    cursor getWorkplanStatus IS
      select STATUS_CODE
        from pa_proj_elem_ver_structure
       where project_id = l_project_id
         and element_version_id = l_structure_version_id;

    cursor get_working_ver(c_structure_version_id NUMBER) IS
      select a.element_version_id
        from pa_proj_elem_ver_structure a,
             pa_proj_element_versions b
       where b.project_id = a.project_id
         and b.proj_element_id = a.proj_element_id
         and a.status_code = 'STRUCTURE_WORKING'
         and b.element_version_id = c_structure_version_id;
    l_working_ver_id            NUMBER;

  BEGIN
    l_project_id := wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'PROJECT_ID');

    l_structure_version_id := wf_engine.GetItemAttrNumber(
                                          itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'STRUCTURE_VER_ID');

    OPEN getWorkplanStatus;
    FETCH getWorkplanStatus into l_status;
    CLOSE getWorkplanStatus;

    IF l_status = 'STRUCTURE_APPROVED' THEN
      resultout := wf_engine.eng_completed||':'||'APPROVED';
    ELSIF l_status = 'STRUCTURE_PUBLISHED' THEN
      OPEN get_working_ver(l_structure_version_id);
      FETCH get_working_ver into l_working_ver_id;
      CLOSE get_working_ver;

      wf_engine.SetItemAttrText(itemtype, itemkey,
                                'STRUCTURE_VER_ID_T',to_char(l_working_ver_id));
      resultout := wf_engine.eng_completed||':'||'PUBLISHED';
    ELSIF l_status = 'STRUCTURE_REJECTED' THEN
      resultout := wf_engine.eng_completed||':'||'REJECTED';
    END IF;

    pa_workplan_workflow_client.set_notification_party
    (
      itemtype,
      itemkey,
      l_status,
      actid,
      funcmode,
      l_ret
    );
 -- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
     resultout := wf_engine.eng_null ; -- This is a Non existent value : 4537865
         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_workplan_workflow','check_workplan_status',itemtype,itemkey,to_char(actid),funcmode);
         RAISE ;
  END check_workplan_status;

  procedure change_status_working
  (
    itemtype     IN  VARCHAR2
   ,itemkey      IN  VARCHAR2
   ,actid        IN  NUMBER
   ,funcmode     IN  VARCHAR2
   ,resultout    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_project_id            NUMBER;
    l_structure_version_id  NUMBER;
    l_record_version_num    NUMBER;

  BEGIN
    --nofity party already set in start_workflow
    --change status to working

    l_project_id := wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'PROJECT_ID');

    l_structure_version_id := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'STRUCTURE_VER_ID');

    l_record_version_num   := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'RECORD_VERSION_NUMBER');

    update pa_proj_elem_ver_structure
    set status_code = 'STRUCTURE_WORKING',
        record_version_number = l_record_version_num + 1
    where project_id = l_project_id
    and element_version_id = l_structure_version_id;
 -- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
         -- I havent reset value of resultout as this param is not assigned value anywhere in this API.
         -- The Workflow function (Change Status to Working) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_workplan_workflow','change_status_working',itemtype,itemkey,to_char(actid),funcmode);
         RAISE;
  END change_status_working;

  procedure change_status_rejected
  (
    itemtype     IN  VARCHAR2
   ,itemkey      IN  VARCHAR2
   ,actid        IN  NUMBER
   ,funcmode     IN  VARCHAR2
   ,resultout    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_project_id            NUMBER;
    l_structure_version_id  NUMBER;
    l_record_version_num    NUMBER;

    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(300);
  BEGIN
    l_project_id := wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'PROJECT_ID');

    l_structure_version_id := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'STRUCTURE_VER_ID');

    l_record_version_num   := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'RECORD_VERSION_NUMBER');


    --call PA_PROJECT_STRUCTURE_PVT1.change_workplan_status
    PA_PROJECT_STRUCTURE_PVT1.change_workplan_status
    (
      p_project_id              => l_project_id
     ,p_structure_version_id    => l_structure_version_id
     ,p_status_code             => 'STRUCTURE_REJECTED'
     ,p_record_version_number   => l_record_version_num
     ,x_return_status           => l_return_status
     ,x_msg_count               => l_msg_count
     ,x_msg_data                => l_msg_data
    );
  -- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
         -- I havent reset value of resultout as this param is not assigned value anywhere in this API.
         -- The Workflow function (Change Status to Rejected) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_workplan_workflow','change_status_rejected',itemtype,itemkey,to_char(actid),funcmode);
         RAISE;
  END change_status_rejected;

  procedure change_status_approved
  (
    itemtype     IN  VARCHAR2
   ,itemkey      IN  VARCHAR2
   ,actid        IN  NUMBER
   ,funcmode     IN  VARCHAR2
   ,resultout    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_project_id            NUMBER;
    l_structure_version_id  NUMBER;
    l_structure_version_name VARCHAR2(240);
    l_structure_version_desc VARCHAR2(250);
    l_responsibility_id     NUMBER;
    l_user_id               NUMBER;
    l_record_version_num    NUMBER;
    l_dummy                 VARCHAR2(1);
    l_auto_publish_flag     VARCHAR2(1);
    l_published_struc_ver_id NUMBER;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(300);

    CURSOR Is_auto_published IS
      SELECT 'Y'
        from pa_proj_workplan_attr
       where project_id = l_project_id
         and WP_AUTO_PUBLISH_FLAG = 'Y';

    -- 4609421 : Following three variables
    l_debug_mode  VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
    l_msg_index_out NUMBER;
    l_data              VARCHAR2(300);

  BEGIN
    l_project_id := wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'PROJECT_ID');

    l_structure_version_id := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'STRUCTURE_VER_ID');

    l_record_version_num   := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'RECORD_VERSION_NUMBER');

     -- 4609421 : Added debug messages
      IF l_debug_mode = 'Y' THEN
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED Start', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_project_id='||l_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_structure_version_id='||l_structure_version_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_record_version_num='||l_record_version_num, x_Log_Level=> 3);
      END IF;

    OPEN is_auto_published;
    FETCH is_auto_published into l_dummy;
    IF is_auto_published%NOTFOUND THEN
      l_auto_publish_flag := 'N';
    ELSE
      l_auto_publish_flag := 'Y';
    END IF;
    CLOSE is_auto_published;

    IF l_debug_mode = 'Y' THEN
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_auto_publish_flag='||l_auto_publish_flag, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'Calling change_workplan_status', x_Log_Level=> 3);
    END IF;


    PA_PROJECT_STRUCTURE_PVT1.change_workplan_status
    (
      p_project_id              => l_project_id
     ,p_structure_version_id    => l_structure_version_id
     ,p_status_code             => 'STRUCTURE_APPROVED'
     ,p_record_version_number   => l_record_version_num
     ,x_return_status           => l_return_status
     ,x_msg_count               => l_msg_count
     ,x_msg_data                => l_msg_data
    );

    IF l_debug_mode = 'Y' THEN
       pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_return_status='||l_return_status, x_Log_Level=> 3);
    END IF;


    IF (l_return_status = FND_API.g_ret_sts_success) THEN
      wf_engine.SetItemAttrNumber(itemtype, itemkey,
                                  'RECORD_VERSION_NUMBER',l_record_version_num+1);
    END IF;

      l_record_version_num   := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'RECORD_VERSION_NUMBER');


    IF l_auto_publish_flag = 'Y' THEN
      l_structure_version_name := wf_engine.getItemAttrText(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'STRUCTURE_VER_NAME');

      l_structure_version_desc := wf_engine.getItemAttrText(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'STRUCTURE_VER_DESC');

      l_record_version_num   := wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'RECORD_VERSION_NUMBER');

      l_responsibility_id :=  wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'RESPONSIBILITY_ID');

      l_user_id           :=  wf_engine.getItemAttrNumber(
                                itemtype  => itemtype
                               ,itemkey   => itemkey
                               ,aname     => 'USER_ID');

    IF l_debug_mode = 'Y' THEN
      pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_structure_version_name='||l_structure_version_name, x_Log_Level=> 3);
      pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_structure_version_desc='||l_structure_version_desc, x_Log_Level=> 3);
      pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_record_version_num='||l_record_version_num, x_Log_Level=> 3);
      pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_responsibility_id='||l_responsibility_id, x_Log_Level=> 3);
      pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_user_id='||l_user_id, x_Log_Level=> 3);
      pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'Calling set global Info', x_Log_Level=> 3);
    END IF;

    -- 4609421 : Added call of Set_Global_Info
        -- Bug 6786278 - Changed l_msg_count to l_msg_data for parameter p_msg_data
        PA_INTERFACE_UTILS_PUB.Set_Global_Info
        (  p_api_version_number => 1.0
        , p_responsibility_id  => l_responsibility_id
        ,p_user_id            => l_user_id
        ,p_msg_count          => l_msg_count
        ,p_msg_data           => l_msg_data
        ,p_return_status      => l_return_status);


      IF l_debug_mode = 'Y' THEN
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_return_status='||l_return_status, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'Calling Publish_Structure', x_Log_Level=> 3);
      END IF;

      --call publish api
      PA_PROJECT_STRUCTURE_PUB1.Publish_Structure(
      p_responsibility_id                => l_responsibility_id
     ,p_user_id                          => l_user_id
     ,p_structure_version_id             => l_structure_version_id
     ,p_publish_structure_ver_name       => l_structure_version_name
     ,p_structure_ver_desc               => l_structure_version_desc
     ,p_effective_date                   => TRUNC(SYSDATE)
     ,p_current_baseline_flag            => 'N'
     ,x_published_struct_ver_id          => l_published_struc_ver_id
     ,x_return_status                    => l_return_status
     ,x_msg_count                        => l_msg_count
     ,x_msg_data                         => l_msg_data
      );

      IF l_debug_mode = 'Y' THEN
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'l_return_status='||l_return_status, x_Log_Level=> 3);
        for i in 1..fnd_msg_pub.count_msg loop
        pa_interface_utils_pub.get_messages (
                        p_encoded        => Fnd_Api.G_FALSE
                       ,p_data           => l_data
                       ,p_msg_index      => i
                       ,p_msg_count      => l_msg_count
                       ,p_msg_data       => l_msg_data
                       ,p_msg_index_out  => l_msg_index_out );
        pa_debug.write(x_Module=>'PA_WORKPLAN_WORKFLOW.CHANGE_STATUS_APPROVED', x_Msg => 'Error='||l_data, x_Log_Level=> 3);
        end loop;
      END IF;

      --set structure_ver_id
      wf_engine.SetItemAttrNumber(itemtype, itemkey,
                                  'STRUCTURE_VER_ID',l_published_struc_ver_id);
      wf_engine.SetItemAttrText(itemtype, itemkey,
                                  'STRUCTURE_VER_ID_T',to_char(l_published_struc_ver_id));
      --call PA_PROJECT_STRUCTURE_PVT1.change_workplan_status
    END IF;
  -- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
         -- I havent reset value of resultout as this param is not assigned value anywhere in this API.
         -- The Workflow function (Change Status to Approved) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_workplan_workflow','change_status_approved',itemtype,itemkey,to_char(actid),funcmode);
         RAISE;
  END change_status_approved;


  procedure SELECT_ERROR_RECEIVER
  (
    p_item_type          IN  VARCHAR2
   ,p_item_key           IN  VARCHAR2
   ,actid                IN  NUMBER
   ,funcmode             IN  VARCHAR2
   ,resultout            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_project_id   NUMBER;

    --get all project member who has edit privileges
    CURSOR getProjMemberEditPerson IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 101
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_source_id = fu.employee_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR')
              and f2.function_id = f1.function_id)
         UNION /*Added this clause for 4482957 */
            select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf
       where fu.user_id =  fnd_global.USER_ID
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1) ;

    --get all project member who has edit privileges

    -- 4586987 customer_id is changed to person_party_id
    /*
    CURSOR getProjMemberEditParty IS
       select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 112
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_id = fu.customer_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR')
             and f2.function_id = f1.function_id);
    */

    CURSOR getProjMemberEditParty IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 112
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_id = fu.person_party_id -- customer_id is changed to person_party_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR')
              and f2.function_id = f1.function_id);
    -- 4586987 end

    l_structure_version_id    NUMBER;
    l_error_role           VARCHAR2(30);
    l_error_role_user      VARCHAR2(300);

    display_name VARCHAR2(2000);
    email_address VARCHAR2(2000);
    notification_preference VARCHAR2(2000);
    language VARCHAR2(2000);
    territory VARCHAR2(2000);
  BEGIN
    l_project_id           := wf_engine.GetItemAttrNumber(
                                          itemtype => p_item_type,
                                          itemkey  => p_item_key,
                                          aname    => 'PROJECT_ID');

    l_structure_version_id := wf_engine.GetItemAttrNumber(
                                          itemtype => p_item_type,
                                          itemkey  => p_item_key,
                                          aname    => 'STRUCTURE_VER_ID');

    l_error_role := 'APRJ_'||p_item_type||p_item_key;
    WF_DIRECTORY.CREATEADHOCROLE(role_name => l_error_role
                                 ,role_display_name => l_error_role
                                 ,expiration_date => sysdate+1); -- Set expiration_date for bug#5962401

    l_error_role_user := NULL;
    FOR v_1 IN getProjMemberEditPerson LOOP
      IF (l_error_role_user IS NOT NULL) THEN
        l_error_role_user := l_error_role_user||',';
      END IF;
      WF_DIRECTORY.GetRoleInfo(v_1.user_name,
                               display_name,
                               email_address,
                               notification_preference,
                               language,
                               territory);

      IF display_name IS NULL THEN
        wf_directory.createadhocuser( name => v_1.user_name
                                     ,display_name => v_1.person_name
                                     ,email_address => v_1.email_address);
      END IF;
      l_error_role_user := l_error_role_user||v_1.user_name;
    END LOOP;

    FOR v_1 IN getProjMemberEditParty LOOP
      IF (l_error_role_user IS NOT NULL) THEN
        l_error_role_user := l_error_role_user||',';
      END IF;
      WF_DIRECTORY.GetRoleInfo(v_1.user_name,
                               display_name,
                               email_address,
                               notification_preference,
                               language,
                               territory);

      IF display_name IS NULL THEN
        wf_directory.createadhocuser( name => v_1.user_name
                                     ,display_name => v_1.person_name
                                     ,email_address => v_1.email_address);
      END IF;
      l_error_role_user := l_error_role_user||v_1.user_name;
    END LOOP;

    IF (l_error_role_user IS NOT NULL) THEN
      wf_directory.adduserstoadhocRole(l_error_role
                                      ,l_error_role_user);
      wf_engine.setitemattrtext(p_item_type
                               ,p_item_key
                               ,'WORKPLAN_ERR_RECEIVER'
                               ,l_error_role);
    END IF;
  -- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
         -- I havent reset value of resultout as this param is not assigned value anywhere in this API.
         -- The Workflow function (Select Error Receiver) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_workplan_workflow','SELECT_ERROR_RECEIVER',p_item_type,p_item_key,to_char(actid),funcmode);
         RAISE;
  END SELECT_ERROR_RECEIVER;


  procedure SHOW_WORKPLAN_PUB_ERR
  (document_id IN VARCHAR2,
   display_type IN VARCHAR2,
   document IN OUT NOCOPY clob, --File.Sql.39 bug 4440895
   document_type IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
    l_content clob;

    CURSOR get_error_info IS
      SELECT page_content
        FROM PA_PAGE_CONTENTS
       WHERE pk1_value = document_id
         AND object_type = 'PA_STRUCTURES'
         AND pk2_value = 1;

    l_size number;

    l_chunk_size  pls_integer:=10000;
    l_copy_size int;
    l_pos int := 0;

    l_line varchar2(10000) := '' ;
    -- Bug 3861540
    l_return_status varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  BEGIN

    open get_error_info;
    fetch get_error_info into l_content;
    IF (get_error_info%FOUND) THEN
      close get_error_info;

      -- parse the retrieved clob data
      l_size := dbms_lob.getlength(l_content);


      l_pos := 1;
      l_copy_size := 0;

      while (l_copy_size < l_size) loop

        dbms_lob.read(l_content,l_chunk_size,l_pos,l_line);

        dbms_lob.write(document,l_chunk_size,l_pos,l_line);
        l_copy_size := l_copy_size + l_chunk_size;
        l_pos := l_pos + l_chunk_size;
      end loop;

      --Bug 3861540

      pa_workflow_utils.modify_wf_clob_content(
                p_document                     =>      document
                ,x_return_status               =>  l_return_status
                ,x_msg_count                   =>  l_msg_count
                ,x_msg_data                    =>  l_msg_data
                                              );

      if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
              WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
              dbms_lob.writeappend(document, 255, substr(Sqlerrm, 255));
      end if;


      --End of Changes Bug 3861540
    ELSE
      close get_error_info;
    END IF;

    document_type := 'text/html';

  EXCEPTION
    WHEN OTHERS THEN
      WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
      dbms_lob.writeappend(document, 255, substr(Sqlerrm, 255));
    NULL;
  END SHOW_WORKPLAN_PUB_ERR;

-- FP M : Project Execution Workflow
PROCEDURE START_PROJECT_EXECUTION_WF
  (
    p_project_id    IN  pa_projects_all.project_id%TYPE  --changed type from varchar to column type 3619185  Satish
   ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
IS
     l_item_key     NUMBER;
     l_item_type    VARCHAR2(30) := 'PAPRJEX' ;
     l_process_name VARCHAR2(30) := 'PA_PROJ_EXECUTION_PROCESS';
     l_wf_enabled   VARCHAR2(1) ;

     l_err_code NUMBER;
     l_err_stage VARCHAR2(30);
     l_err_stack VARCHAR2(240);
     l_debug_mode VARCHAR2(1) ;

     CURSOR proj_number
     IS
     SELECT segment1
       from pa_projects_all
       where project_id = p_project_id ;

     -- 5369295 for pqe bug5366726 , added to_char function call for p_project_id passed parameter
     CURSOR is_wf_running
     IS
     SELECT 'Y' from pa_wf_processes where item_key= to_char(p_project_id) and item_type = 'PAPRJEX' ;

    proj_number_rec proj_number%ROWTYPE ;
    is_wf_running_rec   is_wf_running%ROWTYPE ;

BEGIN
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

  IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'START_PROJECT_EXECUTION_WF',
                                   p_debug_mode => l_debug_mode );
  END IF;

 OPEN is_wf_running;
 FETCH is_wf_running INTO is_wf_running_rec;
 IF is_wf_running%FOUND THEN
     CLOSE is_wf_running ;
     RETURN ;
 END IF ;
 CLOSE is_wf_running ;  /*5369295 for pqe bug5366726*/

 -- Check whether WF is enabled for structure
 l_wf_enabled := PA_PROJ_STRUCTURE_UTILS.IS_WF_ENABLED_FOR_STRUCTURE(
                    p_project_id        => p_project_id
                   ,p_structure_type    => 'WORKPLAN'
                   );

 IF nvl(l_wf_enabled,'N') = 'N' THEN
      -- Stop further processing and return .
--      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
--                           p_msg_name => 'PA_PS_CREATE_WF_FAILED');
--      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN ;
 END IF ;


 IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'START_PROJECT_EXECUTION_WF : Calling wf_engine.createprocess';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
 END IF ;

 OPEN proj_number;
 FETCH proj_number INTO proj_number_rec;
 CLOSE proj_number ;

 wf_engine.createprocess(itemtype  => l_item_type,
                          itemkey   => to_char(p_project_id),
                          process   => l_process_name
                          );

 IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'START_PROJECT_EXECUTION_WF : Setting project Id';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
 END IF ;

 -- Set attribute Project Id
 wf_engine.SetItemAttrNumber
          (itemtype => l_item_type
          ,itemkey  => to_char(p_project_id)
          ,aname     => 'PROJECT_ID'
          ,avalue    => p_project_id
          );

 -- Set attribute Project Number
 wf_engine.SetItemAttrText
          (itemtype => l_item_type
          ,itemkey  => to_char(p_project_id)
          ,aname     => 'PROJECT_NUMBER'
          ,avalue    => proj_number_rec.segment1
          );

 -- Set User Key
 wf_engine.SetItemUserKey
     (itemtype => l_item_type ,
      itemkey   => to_char(p_project_id) ,
      userkey   => proj_number_rec.segment1
     );

 IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'START_PROJECT_EXECUTION_WF : Calling wf_engine.startprocess';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
 END IF ;

 wf_engine.startprocess(l_item_type
                       ,to_char(p_project_id));

 IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        --update pa_wf_process_table
       PA_WORKFLOW_UTILS.INSERT_WF_PROCESSES
        (
           p_wf_type_code =>      'PROJECT'
          ,p_item_type    =>      l_item_type
          ,p_item_key     =>      to_char(p_project_id)
          ,p_entity_key1  =>      to_char(p_project_id)
          ,p_entity_key2  =>      to_char(p_project_id)
          ,p_description  =>      NULL
          ,p_err_code     =>      l_err_code
          ,p_err_stage    =>      l_err_stage
          ,p_err_stack    =>      l_err_stack
        );

       IF (l_err_code <> 0) THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_CREATE_WF_FAILED');
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

  ELSE
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_PS_CREATE_WF_FAILED');
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION
WHEN OTHERS THEN
      x_msg_count :=1;
      x_msg_data:= substrb(SQLERRM, 1, 2000); -- 4537865 : Replaced substr with substrb
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      /* 5369295 -- Added fnd_msg_pub.add_exc_msg() for bug 5366726 */
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_WORKPLAN_WORKFLOW',
                              p_procedure_name => 'START_PROJECT_EXECUTION_WF',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));

END START_PROJECT_EXECUTION_WF ;

PROCEDURE CANCEL_PROJECT_EXECUTION_WF
  (
    p_project_id    IN  pa_projects_all.project_id%TYPE  --changed type from varchar to column type 3619185  Satish
   ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
IS

  l_item_type    VARCHAR2(30) := 'PAPRJEX' ;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  WF_ENGINE.AbortProcess(l_item_type
                       , to_char(p_project_id)
                        );
  --Bug#3693248
  --Added item_type join as part of performance fix.

  DELETE FROM PA_WF_PROCESSES
        WHERE item_key = to_char(p_project_id)
          AND item_type = 'PAPRJEX' ;

EXCEPTION
WHEN OTHERS THEN
      x_msg_count :=1;
      x_msg_data:= substrb(SQLERRM, 1, 2000);  -- 4537865 : Replaced substr with substrb
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END CANCEL_PROJECT_EXECUTION_WF ;

PROCEDURE START_TASK_EXECUTION_WF
     ( itemtype  in varchar2
      ,itemkey   in varchar2
      ,actid     in number
      ,funcmode  in varchar2
      ,resultout out NOCOPY varchar2  --File.Sql.39 bug 4440895
      )
IS
  l_item_key     NUMBER;
  l_item_type    VARCHAR2(30) ;
  l_process_name VARCHAR2(30);
  l_lead_days    NUMBER;
  l_project_id   NUMBER ;
  l_project_number VARCHAR2(25) ;
  l_versioned    VARCHAR2(1) ;
  l_structure_version_id NUMBER ;
  l_err_code   NUMBER;
  l_err_stage  VARCHAR2(30);
  l_err_stack  VARCHAR2(240);
  l_start_date DATE ;
  l_debug_mode VARCHAR2(1) ;


-- Cursor to get the WP structure version id in version disabled case
--

    CURSOR get_struct_version_id
    IS
    SELECT pev.element_version_id
      FROM pa_proj_element_versions pev ,
           pa_proj_structure_types pst
     WHERE pev.project_id = l_project_id
       AND pev.object_type = 'PA_STRUCTURES'
       AND pev.proj_element_id = pst.proj_element_id
       AND pst.structure_type_id = 1; -- WORKPLAN

-- Bug#3693248 : Performace fix
-- Modified the joins , icluded project_id join between
-- pev and pevs.
    CURSOR get_all_tasks(c_parent_struct_ver_id IN NUMBER)
    IS
    SELECT ppe.proj_element_id
          ,pevs.scheduled_start_date
          ,ppe.wf_item_type
          ,ppe.wf_process
          ,ppe.wf_start_lead_days
          ,element_number
      FROM pa_proj_elem_ver_schedule pevs ,
           pa_proj_element_versions pev,
           pa_proj_elements ppe
     WHERE pev.parent_structure_version_id = c_parent_struct_ver_id
       AND pev.object_type = 'PA_TASKS'
       AND ppe.object_type = 'PA_TASKS'
       AND pev.proj_element_id = ppe.proj_element_id
       AND pev.project_id = ppe.project_id
       AND nvl(ppe.enable_wf_flag,'N')= 'Y'
       AND pevs.element_version_id = pev.element_version_id
       AND pev.project_id = pevs.project_id
       AND pev.proj_element_id = pevs.proj_element_id ;

     get_all_tasks_rec get_all_tasks%ROWTYPE ;

BEGIN

  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

  IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'START_TASK_EXECUTION_WF',
                                   p_debug_mode => l_debug_mode );
  END IF;

  -- Return if WF Not Running
  IF (funcmode <> wf_engine.eng_run) THEN
      resultout := wf_engine.eng_null;
      RETURN;
  END IF;

 IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'START_TASK_EXECUTION_WF : Get Project Id';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
 END IF ;

 l_project_id := wf_engine.GetItemAttrNumber
                    (itemtype => itemtype
                    ,itemkey  => itemkey
                    ,aname    => 'PROJECT_ID') ;

 l_project_number := wf_engine.GetItemAttrText
                    (itemtype => itemtype
                    ,itemkey  => itemkey
                    ,aname    => 'PROJECT_NUMBER') ;

 IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'START_TASK_EXECUTION_WF : Get the latest published version';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
 END IF ;

 -- Check whether versioning is enabled
 l_versioned := PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(l_project_id);

 -- Get the latest published structure version
 -- id for versioning enabled case and only version
 -- for versioning disbled case .

 IF nvl(l_versioned,'N') = 'Y' then
      l_structure_version_id := PA_PROJ_ELEMENTS_UTILS.LATEST_PUBLISHED_VER_ID(l_project_id,'WORKPLAN');
 ELSE
      OPEN get_struct_version_id ;
      FETCH get_struct_version_id INTO l_structure_version_id ;
      CLOSE get_struct_version_id ;
 END IF ;

 IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'START_TASK_EXECUTION_WF : Get all the tasks ';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
 END IF ;

-- For all the tasks for which WP is enabled loop.
FOR get_all_tasks_rec IN get_all_tasks(l_structure_version_id) LOOP

-- Check is Task Execution Process is already
-- running for the task. Proceed if its not.

--Bug#3619754 : Added nvl as the API returns null in case WF is not running.
     IF (nvl(PA_PROJ_ELEMENTS_UTILS.GET_ELEMENT_WF_STATUS(get_all_tasks_rec.proj_element_id,l_project_id,'TASK_EXECUTION'),'X') <> 'ACTIVE') THEN

          -- The task execution workflow will be started on the date
          -- when the schedule start date minus the Task execution Lead Time

          PA_WORKPLAN_WORKFLOW_CLIENT.SET_LEAD_DAYS(
                   p_item_type      => get_all_tasks_rec.wf_item_type
                  ,p_task_number    => get_all_tasks_rec.element_number
                  ,p_project_number => l_project_number
                  ,x_lead_days      => l_lead_days
                 ) ;
          l_start_date := trunc((nvl(get_all_tasks_rec.scheduled_start_date,sysdate) - nvl(l_lead_days,0) )) ;
          IF l_start_date <= trunc(SYSDATE) THEN -- Bug : 4089623 Included 'less than' condition also

               l_item_key := null ;
               SELECT pa_workflow_itemkey_s.nextval
                 INTO l_item_key
                 FROM dual;

                IF l_debug_mode = 'Y' THEN
                      Pa_Debug.g_err_stage:= 'START_PROJECT_EXECUTION_WF : Create Process';
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
                END IF ;

                wf_engine.createprocess(itemtype  => get_all_tasks_rec.wf_item_type,
                                        itemkey   => to_char(l_item_key),
                                        process   => get_all_tasks_rec.wf_process
                                         );


                 wf_engine.setItemParent(itemtype        => get_all_tasks_rec.wf_item_type,
                                         itemkey         => to_char(l_item_key),
                                         parent_itemtype => itemtype,
                                         parent_itemkey  => itemkey,
                                         parent_context  => null);

                IF l_debug_mode = 'Y' THEN
                      Pa_Debug.g_err_stage:= 'START_PROJECT_EXECUTION_WF : Calling wf_engine.startprocess';
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
                END IF ;

                wf_engine.startprocess(get_all_tasks_rec.wf_item_type
                                       ,to_char(l_item_key));


                --update pa_wf_process_table
                PA_WORKFLOW_UTILS.INSERT_WF_PROCESSES
                       (
                          p_wf_type_code =>  'TASK_EXECUTION'
                         ,p_item_type    =>  get_all_tasks_rec.wf_item_type
                         ,p_item_key     =>  to_char(l_item_key)
                         ,p_entity_key1  =>  to_char(l_project_id)
                         ,p_entity_key2  =>  to_char(get_all_tasks_rec.proj_element_id)
                         ,p_description  =>  NULL
                         ,p_err_code     =>  l_err_code
                         ,p_err_stage    =>  l_err_stage
                         ,p_err_stack    =>  l_err_stack
                       );

         END IF ;
     END IF ;
END LOOP ;
EXCEPTION
WHEN OTHERS THEN
    resultout := wf_engine.eng_null;
    Wf_Core.Context('pa_workplan_workflow','START_TASK_EXECUTION_WF',itemtype,itemkey,to_char(actid),funcmode);
     RAISE ;
END START_TASK_EXECUTION_WF ;


PROCEDURE RESTART_TASK_EXECUTION_WF
     ( p_task_id        IN NUMBER
      ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      )
IS

  CURSOR task_info
  IS
  SELECT enable_wf_flag
        ,wf_item_type
        ,wf_process
        ,wf_start_lead_days
        ,project_id
   FROM pa_proj_elements
  WHERE proj_element_id = p_task_id ;

  l_err_code   NUMBER;
  l_err_stage  VARCHAR2(30);
  l_err_stack  VARCHAR2(240);
  l_start_date DATE ;
  l_debug_mode VARCHAR2(1) ;
  l_item_key   NUMBER ;

  task_info_rec task_info%ROWTYPE ;

BEGIN

  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

  IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'RESTART_TASK_EXECUTION_WF',
                                   p_debug_mode => l_debug_mode );
  END IF;


  IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'RESTART_TASK_EXECUTION_WF : Open Cursor task_info';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
  END IF ;

  OPEN  task_info ;
  FETCH task_info INTO task_info_rec ;
  CLOSE task_info ;

  IF nvl(task_info_rec.enable_wf_flag,'N') = 'N' THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_WF_IS_NOT_ENABLED_TASK');
     RETURN ;
  END IF ;



  -- Check is Task Execution Process is already
  -- running for the task. Proceed if its not.

--Bug#3619754 : Added nvl as the API returns null in case WF is not running.
  IF (nvl(PA_PROJ_ELEMENTS_UTILS.GET_ELEMENT_WF_STATUS(p_task_id,task_info_rec.project_id,'TASK_EXECUTION'),'X') <> 'ACTIVE') THEN

          -- Not performing the lead days validation as
          -- this API is explicitly called to restart the
          -- task execution WF after cancelling it.

          -- The restart option will be available in the
          -- task details page for which the WF is in cancelled status.

               l_item_key := null ;
               SELECT pa_workflow_itemkey_s.nextval
                 INTO l_item_key
                 FROM dual;

                IF l_debug_mode = 'Y' THEN
                      Pa_Debug.g_err_stage:= 'RESTART_TASK_EXECUTION_WF : Create Process';
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
                END IF ;

                wf_engine.createprocess(itemtype  => task_info_rec.wf_item_type,
                                        itemkey   => to_char(l_item_key),
                                        process   => task_info_rec.wf_process
                                         );


                wf_engine.setItemParent(itemtype        => task_info_rec.wf_item_type ,
                                         itemkey         => to_char(l_item_key),
                                         parent_itemtype => 'PAPRJEX' ,
                                         parent_itemkey  => to_char(task_info_rec.project_id),
                                         parent_context  => null);

                IF l_debug_mode = 'Y' THEN
                      Pa_Debug.g_err_stage:= 'RESTART_TASK_EXECUTION_WF : Calling wf_engine.startprocess';
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
                END IF ;

                wf_engine.startprocess(task_info_rec.wf_item_type
                                      ,to_char(l_item_key));


                --update pa_wf_process_table
                PA_WORKFLOW_UTILS.INSERT_WF_PROCESSES
                       (
                          p_wf_type_code => 'TASK_EXECUTION'
                         ,p_item_type    => task_info_rec.wf_item_type
                         ,p_item_key     => to_char(l_item_key)
                         ,p_entity_key1  => to_char(task_info_rec.project_id)
                         ,p_entity_key2  => to_char(p_task_id)
                         ,p_description  => NULL
                         ,p_err_code     => l_err_code
                         ,p_err_stage    => l_err_stage
                         ,p_err_stack    => l_err_stack
                       );

  END IF ;
EXCEPTION
WHEN OTHERS THEN
     x_msg_count := 1; -- 4537865
     x_msg_data := SUBSTRB(SQLERRM,1,240); -- 4537865
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ; -- 4537865
     RAISE ;
END RESTART_TASK_EXECUTION_WF ;


PROCEDURE CANCEL_TASK_EXECUTION_WF
  (
    p_task_id       IN  VARCHAR2
   ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
IS

  l_item_key     NUMBER;
  l_item_type    VARCHAR2(30) ;

  l_err_code NUMBER;
  l_err_stage VARCHAR2(30);
  l_err_stack VARCHAR2(240);
  l_debug_mode VARCHAR2(1) ;

  Cursor get_item_type IS
  Select enable_wf_flag
        ,wf_item_type
        ,project_id
    from pa_proj_elements
   where proj_element_id = p_task_id ;

   get_item_type_rec get_item_type%ROWTYPE ;

BEGIN

  x_return_status := FND_API.g_ret_sts_success;
  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

  IF l_debug_mode = 'Y' THEN
     Pa_Debug.g_err_stage:= 'CANCEL_TASK_EXECUTION_WF : Cancel Task Execution Workflow';
     Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
  END IF ;

  OPEN get_item_type ;
  FETCH get_item_type INTO get_item_type_rec ;
  CLOSE get_item_type ;

  -- Cancel only if its running.
  IF nvl(get_item_type_rec.enable_wf_flag,'N') = 'Y' THEN
       IF nvl(PA_PROJ_ELEMENTS_UTILS.GET_ELEMENT_WF_STATUS(p_task_id,get_item_type_rec.project_id,'TASK_EXECUTION'),'X') = 'ACTIVE' THEN
             l_item_key := PA_PROJ_ELEMENTS_UTILS.GET_ELEMENT_WF_ITEMKEY
                                             (p_proj_element_id => p_task_id
                                             ,p_project_id      => get_item_type_rec.project_id
                                             ,p_wf_type_code    =>'TASK_EXECUTION'
                                             );

              WF_ENGINE.AbortProcess
                       (get_item_type_rec.wf_item_type
                       ,to_char(l_item_key)
                        );
        END IF ;
  END IF ;
EXCEPTION
WHEN OTHERS THEN
      x_msg_count :=1;
      x_msg_data:= substrb(SQLERRM, 1, 2000);  -- 4537865 : Replaced substr with substrb
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END CANCEL_TASK_EXECUTION_WF ;


PROCEDURE IS_PROJECT_CLOSED
     ( itemtype  in varchar2
      ,itemkey   in varchar2
      ,actid     in number
      ,funcmode  in varchar2
      ,resultout out NOCOPY varchar2  --File.Sql.39 bug 4440895
      )
IS
CURSOR proj_status_cur(c_project_id in number)
IS
SELECT pst.project_system_status_code
  FROM pa_projects_all pa ,
       pa_project_statuses pst
 WHERE pa.project_id = c_project_id
   AND pa.project_status_code = pst.project_status_code;

 l_project_id NUMBER ;
 l_debug_mode VARCHAR2(1) ;
 proj_status_cur_rec proj_status_cur%ROWTYPE ;

BEGIN

  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

  IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'IS_PROJECT_CLOSED',
                                   p_debug_mode => l_debug_mode );
  END IF;

  -- Return if WF Not Running
  IF (funcmode <> wf_engine.eng_run) THEN
      resultout := wf_engine.eng_null;
      RETURN;
  END IF;

  IF l_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'IS_PROJECT_CLOSED : Get Project Id';
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,3);
  END IF ;

  l_project_id := wf_engine.GetItemAttrNumber
                    (itemtype => itemtype
                    ,itemkey  => itemkey
                    ,aname    => 'PROJECT_ID') ;

  OPEN proj_status_cur(l_project_id);
  FETCH proj_status_cur INTO proj_status_cur_rec ;
  CLOSE proj_status_cur ;

  IF proj_status_cur_rec.project_system_status_code = 'CLOSED' THEN
      resultout := wf_engine.eng_completed||':'||'Y';
  ELSE
      resultout := wf_engine.eng_completed||':'||'N';
  END IF ;
  -- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
     resultout := wf_engine.eng_null;

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_workplan_workflow','SELECT_ERROR_RECEIVER',itemtype,itemkey,to_char(actid),funcmode);
         RAISE;
END IS_PROJECT_CLOSED ;
-- FP M : Project Execution Workflow

END PA_WORKPLAN_WORKFLOW;

/
