--------------------------------------------------------
--  DDL for Package Body PA_PERF_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_NOTIFICATION_PKG" AS
/* $Header: PAPFNTFB.pls 120.2.12000000.2 2007/04/26 17:15:05 vvjoshi ship $ */

/*====================================================================
This API starts the WorkFlow to send e-mail Notification for exception
reporting.
=====================================================================*/
PROCEDURE START_PERF_NOTIFICATION_WF(
             p_item_type	In	VARCHAR2
	    ,p_process_name	In	VARCHAR2
	    ,p_project_id	In	pa_projects_all.project_id%TYPE
	    ,x_item_key	        Out	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	    ,x_return_status	Out     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	    ,x_msg_count 	Out     NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data 	Out     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_item_key                      NUMBER;
l_wf_type_code                  pa_wf_processes.wf_type_code%TYPE;
l_entity_key1                   pa_wf_processes.entity_key1%TYPE;
l_entity_key2                   pa_wf_processes.entity_key2%TYPE;

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(30);
l_err_stack                     VARCHAR2(240);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.START_PERF_NOTIFICATION_WF';
Invalid_Arg_Exc_CI              Exception;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'START_PERF_NOTIFICATION_WF',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_item_type = '|| p_item_type;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_process_name = '|| p_process_name;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF (p_item_type IS NULL) OR
        (p_process_name IS NULL) OR
        (p_project_id IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_CI;
     END IF;

     l_wf_type_code := 'PERF_NOTIFICATION';
     l_entity_key1  := p_project_id;
     l_entity_key2  := -99;

     -- Get the item key from sequence.
     SELECT pa_workflow_itemkey_s.nextval
     INTO l_item_key
     FROM dual;

     x_item_key := To_char(l_item_key);


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'x_item_key = '|| x_item_key;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     -- create the workflow process
     WF_ENGINE.CreateProcess( itemtype => p_item_type
	                     ,itemkey  => x_item_key
	                     ,process  => p_process_name);


     -- The following API will set all the required attributes for the workflow to function.
     set_perf_notify_wf_attributes(
                p_item_type         => p_item_type
               ,p_process_name      => p_process_name
               ,p_project_id        => p_project_id
               ,p_item_key          => x_item_key
               ,x_return_status     => x_return_status
               ,x_msg_count         => x_msg_count
               ,x_msg_data          => x_msg_data
     );

     IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Error calling SET_PERF_NOTIFY_WF_ATTRIBUTES';
             pa_debug.write('START_PERF_NOTIFICATION_WF: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);

             PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
          END IF;
          RAISE Invalid_Arg_Exc_CI;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'returned from set_perf_notify_wf_attributes';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;


     WF_ENGINE.StartProcess(itemtype => p_item_type
	                   ,itemkey  => x_item_key);

     PA_WORKFLOW_UTILS.Insert_WF_Processes(
                     p_wf_type_code           => l_wf_type_code
                    ,p_item_type              => p_item_type
                    ,p_item_key               => l_item_key
                    ,p_entity_key1            => l_entity_key1
                    ,p_entity_key2            => l_entity_key2
                    ,p_description            => p_process_name
                    ,p_err_code               => l_err_code
                    ,p_err_stage              => l_err_stage
                    ,p_err_stack              => l_err_stack
                    );
     IF l_err_code <> 0 THEN
	WF_ENGINE.AbortProcess(itemtype => p_Item_Type
       	                      ,itemkey  => l_Item_Key);

        --Log an error message and go to exception section.
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
 		             ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
	x_return_status := FND_API.G_RET_STS_ERROR;
        Raise Invalid_Arg_Exc_CI;
     END IF;


     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Exiting START_PERF_NOTIFICATION_WF';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        pa_debug.reset_curr_function;
     END IF;

EXCEPTION

WHEN Invalid_Arg_Exc_CI THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_PERF_EXCEPTION_PKG'
                    ,p_procedure_name  => 'START_PERF_NOTIFICATION_WF'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END START_PERF_NOTIFICATION_WF;



/*==================================================================
   The required arguments for the workflow are set in this API. This
   API also identifies to whom the notification has to be sent to.
 =================================================================*/
PROCEDURE SET_PERF_NOTIFY_WF_ATTRIBUTES
      (  p_item_type	    In		VARCHAR2
	,p_process_name	    In		VARCHAR2
	,p_project_id	    In		pa_projects_all.project_id%TYPE
	,p_item_key	    In		NUMBER
        ,x_return_status    Out		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count	    Out		NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data	    Out		NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(30);
l_err_stack                     VARCHAR2(240);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.set_perf_notify_wf_attributes';
Invalid_Arg_Exc_CI              Exception;

l_project_name                  pa_projects_all.name%TYPE;
l_project_number                pa_projects_all.segment1%TYPE;
l_role                          varchar2(30) := NULL;
l_role_display_name             varchar2(30) := NULL; -- Bug 4565156.
l_role_users                    varchar2(30000) := NULL;
display_name                    VARCHAR2(2000);
email_address                   VARCHAR2(2000);
notification_preference         VARCHAR2(2000);
language                        VARCHAR2(2000);
territory                       VARCHAR2(2000);
l_priority_name                 pa_lookups.meaning%TYPE;
l_object_page_layout_id         NUMBER;
l_user_names                    pa_distribution_list_utils.pa_vc_1000_150 := null;
l_full_names                    pa_distribution_list_utils.pa_vc_1000_150 := null;
l_email_addresses               pa_distribution_list_utils.pa_vc_1000_150 := null;

-- This Cursor gets the Pageid and PageType associated with the Automatic Report Type for the Project
CURSOR get_page( c_object_id  NUMBER)
IS
  SELECT object_page_layout_id,
         object_id,
         object_type,
         page_name,
         page_id,
         page_type_code,
	 report_name
  FROM pa_progress_report_setup_v
  WHERE object_id = c_object_id
  AND object_type = 'PA_PROJECTS'
  AND page_type_code='PPR'
  AND generation_method='AUTOMATIC';



BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'set_perf_notify_wf_attributes',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_item_type = '|| p_item_type;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.g_err_stage:= 'p_process_name = '|| p_process_name;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
     END IF;

     IF (p_item_type IS NULL) OR
        (p_process_name IS NULL) OR
        (p_project_id IS NULL)
     THEN

          PA_UTILS.ADD_MESSAGE
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_CI;
     END IF;

     SELECT name, segment1 INTO l_project_name, l_project_number
     FROM pa_projects_all
     WHERE project_id=p_project_id;

     FOR page_var in get_page(p_project_id)
     LOOP
        l_object_page_layout_id := page_var.object_page_layout_id;
        -- Set the workflow attributes.
        wf_engine.SetItemAttrNumber( p_item_type
                                  ,p_item_key
                                  ,'CONF_OBJECT_ID'
                                  ,p_project_id);


        wf_engine.SetItemAttrText( p_item_type
                                  ,p_item_key
                                  ,'CONF_OBJECT_TYPE'
                                  ,page_var.object_type);


        wf_engine.SetItemAttrNumber( p_item_type
                                  ,p_item_key
                                  ,'CONF_PAGE_ID'
                                  ,page_var.page_id);

        wf_engine.SetItemAttrText( p_item_type
                                  ,p_item_key
                                  ,'CONF_PAGE_TYPE'
                                  ,page_var.page_type_code);

        wf_engine.SetItemAttrText( p_item_type
                                  ,p_item_key
                                  ,'OBJECT_NAME'
                                  ,l_project_name);

        wf_engine.SetItemAttrText( p_item_type
                                  ,p_item_key
                                  ,'REPORT_TYPE'
                                  ,page_var.report_name);

        wf_engine.SetItemAttrDate( p_item_type
                                  ,p_item_key
                                  ,'REP_GEN_DATE'
                                  ,sysdate);

        wf_engine.SetItemAttrText( p_item_type
                                  ,p_item_key
                                  ,'PROJECT_NUMBER'
                                  ,l_project_number);

     END LOOP;



     PA_DISTRIBUTION_LIST_UTILS.get_dist_list(
		   p_object_type => 'PA_OBJECT_PAGE_LAYOUT',
		   p_object_id   => l_object_page_layout_id,
		   p_access_level => 1,  -- view priv
		   x_user_names => l_user_names,
		   x_full_names => l_full_names,
		   x_email_addresses => l_email_addresses,
		   x_return_status => x_return_status,
		   x_msg_count => l_msg_count,
		   x_msg_data => l_msg_data
		   );

     IF (x_return_status = 'S') THEN
        IF l_user_names is not null THEN
          l_role := 'NOTIFY_' ||p_item_type ||p_item_key;
	  l_role_display_name := l_role; -- Bug 4565156.

          WF_DIRECTORY.CreateAdHocRole( role_name         => l_role
                                     ,role_display_name => l_role_display_name -- Bug 4565156.
                                     ,expiration_date   => sysdate+1); -- Set expiration_date for bug#5962401

          FOR i in l_user_names.First..l_user_names.LAST
          LOOP
            IF l_user_names(i) IS NULL THEN
	      l_user_names(i) := Upper(l_email_addresses(i));
	      l_full_names(i) := l_email_addresses(i);
	    END IF;

	    IF (l_role_users is not null) THEN
	       l_role_users := l_role_users || ',';
            END IF;

   	    wf_directory.getroleinfo(Upper(l_user_names(i)),
                                     display_name,
                                     email_address,
                                     notification_preference,
                                     language,
                                     territory);
	    IF display_name is null THEN
	       WF_DIRECTORY.CreateAdHocUser( name => l_user_names(i)
	 	                           , display_name => l_full_names(i)
		 			   , EMAIL_ADDRESS =>l_email_addresses(i));
	    END IF;
	    l_role_users := l_role_users || l_user_names(i);
          END LOOP;
        ELSE
	    pa_debug.write_file('LOG','The notification access list do not have any receipients defined to send the performance status notification for the Project with project Id:'||p_project_id);
        END IF;
     END IF;

     IF (l_role_users is NOT NULL) THEN
         WF_DIRECTORY.AddUsersToAdHocRole( l_role,
	 	                           l_role_users);

	 wf_engine.SetItemAttrText(  p_item_type
	  	                   , p_item_key
				   , 'PERFORMER'
				   , l_role);
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting set_perf_notify_wf_attributes';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Invalid_Arg_Exc_CI THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_PERF_EXCEPTION_PKG'
                    ,p_procedure_name  => 'set_perf_notify_wf_attributes'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END set_perf_notify_wf_attributes;

END PA_PERF_NOTIFICATION_PKG;

/
