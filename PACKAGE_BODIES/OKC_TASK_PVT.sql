--------------------------------------------------------
--  DDL for Package Body OKC_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TASK_PVT" AS
/* $Header: OKCRTSKB.pls 120.0 2005/05/26 09:25:47 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
----------------------------------------------------------------------------------
	-- Start of comments
    	-- Procedure Name  : create_task
    	-- Description     : Procedure to create a task for a resolved timevalue
    	-- Version         : 1.0
    	-- End of comments
----------------------------------------------------------------------------------
  	PROCEDURE create_task(p_api_version 		IN NUMBER
			     ,p_init_msg_list 	IN VARCHAR2
			     ,p_resolved_time_id	IN NUMBER
			     ,p_timezone_id		IN NUMBER
			     ,p_timezone_name    IN VARCHAR2
			     ,p_tve_id			IN NUMBER
			     ,p_planned_end_date	IN DATE
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2
			     ,x_task_id		OUT NOCOPY NUMBER) IS
          l_api_name               CONSTANT VARCHAR2(30) := 'create_task';
		l_task_id			     jtf_tasks_b.task_id%TYPE;
		l_task_name			jtf_tasks_tl.task_name%TYPE;
		l_task_type_id			jtf_task_types_b.task_type_id%TYPE;
		l_task_type_name		jtf_task_types_tl.name%TYPE;
		l_status_id			jtf_task_statuses_b.task_status_id%type;
		l_status_name			jtf_task_statuses_tl.name%type;
		l_owner_type_code		jtf_objects_b.object_code%TYPE;
		l_source_object_code	jtf_objects_b.object_code%TYPE;
		l_source_object_name	jtf_tasks_b.source_object_name%TYPE;
		l_private_flag			jtf_tasks_b.private_flag%TYPE;
		l_notification_flag		jtf_tasks_b.notification_flag%TYPE;
		l_notification_period	jtf_tasks_b.notification_period%TYPE;
		l_notification_period_uom   jtf_tasks_b.notification_period_uom%TYPE;
		l_escalate_days		jtf_tasks_b.alarm_start%TYPE;
		l_alarm_start			jtf_tasks_b.alarm_start%TYPE;
		l_alarm_start_uom		jtf_tasks_b.alarm_start_uom%TYPE;
		l_alarm_count			jtf_tasks_b.alarm_count%TYPE;
		l_alarm_interval		jtf_tasks_b.alarm_interval%TYPE;
		l_alarm_interval_uom	jtf_tasks_b.alarm_interval_uom%TYPE;
		l_deleted_flag			jtf_tasks_b.deleted_flag%TYPE;
		l_resource_id			jtf_rs_resource_extns.resource_id%TYPE;
		l_resource_number		jtf_rs_resource_extns.resource_number%TYPE;
		l_resolved_time_id		VARCHAR2(300);
		l_day_uom VARCHAR2(30);

         -- Defined for bug 1652537
		TYPE rules_cur_type is REF CURSOR;
		rules_cur rules_cur_type;


		--Select the rule details
/*		Cursor rules_cur(p_tve_id IN NUMBER) is
		select rule_information1 task_name
		      ,rule_information3 notification_period
		      ,rule_information4 resource_id
		      ,rule_information5 escalate_days
		from okc_rules_v
		where rule_information_category = 'NTN'
		and rule_information2 = p_tve_id;
		rules_rec  rules_cur%ROWTYPE;
*/
-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
-- Read OKCSCHRULE - Contract Schedule Rule
		--Select the task_type
		Cursor task_cur is
		select task_type_id, name
		from jtf_task_types_vl
		where task_type_id = 23;
--		where name = 'OKCSCHRULE';

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
		--Select the task status
		Cursor status_cur is
		select task_status_id, name
		from jtf_task_statuses_vl
		where task_status_id = 10;
		--where name = 'Open';

		--Select the object code
		Cursor object_cur is
		select object_code
		from jtf_objects_vl
		where object_code = 'OKC_RESTIME'
		and  object_code in (select object_code
				   from jtf_object_usages
				   where object_user_code = 'TASK');

		--Select the owner type code
		Cursor owner_type_cur is
		select object_code
  		from jtf_objects_vl
  		where object_code = 'OKX_TASKRES'
  		and  object_code in (select object_code
       				   from jtf_object_usages
       				   where object_user_code = 'RESOURCES');

		CURSOR day_cur is
		SELECT UOM_CODE FROM OKC_TIME_CODE_UNITS_B
		where tce_code = 'DAY'
		and rownum < 2;

		l_notfound BOOLEAN;
		l_app_id                 NUMBER;
		l_rule_df_name           VARCHAR2(40);
		l_list_of_rules          VARCHAR2(4000);
		l_list_of_rules1         VARCHAR2(4000);
		l_sql_string             VARCHAR2(4000);

             -- bug 1757364
                l_k_number             okc_k_headers_b.contract_number%TYPE := '';

	BEGIN
        --Start : Modified for better error handling - Bug 1652537

	-- Select the rule details

        -- Resolve all values related to contracts
        -- Get the application_id and rule definition names
	   l_app_id := OKC_TIME_UTIL_PUB.get_app_id;
		  if l_app_id is null then
		   return;
		  end if;

	   l_rule_df_name := OKC_TIME_UTIL_PUB.get_rule_df_name;
		  if l_rule_df_name is null then
             return;
		  end if;

  -- Get all the rule types (e.g. NTN)  from metadata which are related to timevalues.
  -- Get all the rule types (e.g. NTN)  from metadata which are related to tasks.

    l_list_of_rules  := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TIMEVALUES');
    l_list_of_rules1 := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TASK_RS');

    x_return_status     := OKC_API.G_RET_STS_SUCCESS;
  -- For these rules, get relevant information using tve_id.

/* Changed the rules cursor in the following query from okc_rules_v to okc_rules_b for performance
  Also using explicit to_char conversion on tveid in the following query .
  These changes are done to enhance performance */
     l_sql_string := 'select r.rule_information1 task_name,r.rule_information3 notification_period,rule_information4 resource_id,rule_information5 escalate_days ' ||
	          	 'from okc_rules_b r '||
		           'where r.rule_information2 = to_char(:p_tve_id) ' ||
				 'and r.rule_information_category in '|| l_list_of_rules ||
			      'and r.rule_information_category in '|| l_list_of_rules1 ;
          OPEN rules_cur for l_sql_string using p_tve_id;
		FETCH rules_cur into l_task_name, l_notification_period, l_resource_id, l_escalate_days;
		l_notfound := rules_cur%NOTFOUND;
		CLOSE rules_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_RULE_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

	--End : Modified for better error handling - bug 1652537
--------------------------------------------------------------------------------------------------
	     OPEN day_cur;
		FETCH day_cur INTO l_day_uom;
		l_notfound := day_cur%NOTFOUND;
		CLOSE day_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_TIME_CODE_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;
	/*
		OPEN rules_cur(p_tve_id);
		FETCH rules_cur into l_task_name, l_notification_period, l_resource_id, l_escalate_days;
		l_notfound := rules_cur%NOTFOUND;
		CLOSE rules_cur;
		if l_notfound THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;
		*/

		OPEN task_cur;
		FETCH task_cur into l_task_type_id, l_task_type_name;
		l_notfound := task_cur%NOTFOUND;
		CLOSE task_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_TASK_TYPE_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

		OPEN status_cur;
		FETCH status_cur into l_status_id, l_status_name;
		l_notfound := status_cur%NOTFOUND;
		CLOSE status_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_TASK_STATUS_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

		OPEN object_cur;
		FETCH object_cur into l_source_object_code;
		l_notfound := object_cur%NOTFOUND;
		CLOSE object_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_OBJECT_CODE_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

		OPEN owner_type_cur;
		FETCH owner_type_cur into l_owner_type_code;
		l_notfound := owner_type_cur%NOTFOUND;
		CLOSE owner_type_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_TASK_OWNER_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

		l_private_flag := 'N';
		l_notification_flag := 'N';
		l_notification_period_uom := l_day_uom;
		l_resolved_time_id := to_char(p_resolved_time_id);

             -- bug 1757364
                 l_k_number :=  OKC_QUERY.Get_Contract_Number(p_resolved_time_id);
                 l_k_number :=  SUBSTR(l_k_number,1,80);

             -- end bug 1757364

		IF l_escalate_days IS NOT NULL THEN
			l_alarm_start := l_escalate_days;
			l_alarm_start_uom := l_day_uom;
			l_alarm_count := 2;
			l_alarm_interval := l_escalate_days;
			l_alarm_interval_uom :=  l_day_uom;
		--Call the public API JTF_TASKS_PUB to create a Task
		jtf_tasks_pub.create_task(p_api_version 		=> p_api_version
					          ,p_init_msg_list 		=> p_init_msg_list
					          ,p_task_id			=> l_task_id
			                    ,p_task_name 			=> l_task_name
					          ,p_task_type_name		=> l_task_type_name
			                    ,p_task_type_id 		=> l_task_type_id
					          ,p_task_status_name		=> l_status_name
					          ,p_task_status_id 		=> l_status_id
					          ,p_owner_type_code		=> l_owner_type_code
					          ,p_owner_id			=> l_resource_id
					          ,p_planned_end_date 	=> p_planned_end_date
					          ,p_timezone_id 		=> p_timezone_id
					          ,p_timezone_name		=> p_timezone_name
					          ,p_source_object_type_code 	=> l_source_object_code
				               ,p_source_object_id 	=> p_resolved_time_id
					          ,p_source_object_name 	=> l_k_number
					          ,p_private_flag		=> l_private_flag
					          ,p_notification_flag	=> l_notification_flag
					          ,p_notification_period	=> l_notification_period
					          ,p_notification_period_uom     => l_notification_period_uom
					          ,p_alarm_start			=> l_alarm_start
					          ,p_alarm_start_uom		=> l_alarm_start_uom
					          ,p_alarm_on			=> 'Y'
				               ,p_alarm_count           => l_alarm_count
					          ,p_alarm_interval        => l_alarm_interval
					          ,p_alarm_interval_uom    => l_alarm_interval_uom
					          ,x_return_status 		=> x_return_status
					          ,x_msg_count 			=> x_msg_count
					          ,x_msg_data			=> x_msg_data
					          ,x_task_id 			=> x_task_id);
		ELSIF l_escalate_days IS NULL THEN
			--Call the public API JTF_TASKS_PUB to create a Task
		jtf_tasks_pub.create_task(p_api_version 		=> p_api_version
					          ,p_init_msg_list 		=> p_init_msg_list
					          ,p_task_id			=> l_task_id
			                    ,p_task_name 			=> l_task_name
					          ,p_task_type_name		=> l_task_type_name
			                    ,p_task_type_id 		=> l_task_type_id
					          ,p_task_status_name		=> l_status_name
					          ,p_task_status_id 		=> l_status_id
					          ,p_owner_type_code		=> l_owner_type_code
					          ,p_owner_id			=> l_resource_id
					          ,p_planned_end_date 	=> p_planned_end_date
					          ,p_timezone_id 		=> p_timezone_id
					          ,p_timezone_name		=> p_timezone_name
					          ,p_source_object_type_code 	=> l_source_object_code
				               ,p_source_object_id 	=> p_resolved_time_id
					          ,p_source_object_name 	=> l_k_number
					          ,p_private_flag		=> l_private_flag
					          ,p_notification_flag	=> l_notification_flag
					          ,p_notification_period	=> l_notification_period
					          ,p_notification_period_uom     => l_notification_period_uom
					          ,x_return_status 		=> x_return_status
					          ,x_msg_count 			=> x_msg_count
					          ,x_msg_data			=> x_msg_data
					          ,x_task_id 			=> x_task_id);
		END IF;

		IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
		   raise OKC_API.G_EXCEPTION_ERROR;
          END IF;
     EXCEPTION
		WHEN OKC_API.G_EXCEPTION_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_ERROR';
		 NULL;
		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_UNEXP_ERROR';
		 NULL;
		WHEN OTHERS THEN
		 OKC_API.set_message(p_app_name => g_app_name,
		                     p_msg_name => g_unexpected_error,
		                     p_token1   => g_sqlcode_token,
		                     p_token1_value => sqlcode,
		                     p_token2   => g_sqlerrm_token,
		                     p_token2_value => sqlerrm);
		 x_return_status :=  OKC_API.G_RET_STS_UNEXP_ERROR;
	END create_task;

-------------------------------------------------------------------------------------
	-- Start of comments
    	-- Procedure Name  : create_condition_task
    	-- Description     : Procedure to create a Task for a condition occurrence
    	-- Version         : 1.0
    	-- End of comments
-------------------------------------------------------------------------------------
	PROCEDURE create_condition_task(p_api_version 	IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_cond_occr_id		IN NUMBER
			     ,p_condition_name		IN VARCHAR2
			     ,p_task_owner_id		IN NUMBER
			     ,p_actual_end_date		IN DATE
			     ,x_return_status   	     OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	     OUT NOCOPY NUMBER
    			     ,x_msg_data        	     OUT NOCOPY VARCHAR2
			     ,x_task_id			OUT NOCOPY NUMBER) IS
          l_api_name               CONSTANT VARCHAR2(30) := 'create_condition_task';
		l_task_id			     jtf_tasks_b.task_id%TYPE;
		l_task_type_id			jtf_task_types_b.task_type_id%TYPE;
		l_task_type_name		jtf_task_types_tl.name%TYPE;
		l_status_id			jtf_task_statuses_b.task_status_id%type;
		l_status_name			jtf_task_statuses_tl.name%type;
		l_source_object_code	jtf_objects_b.object_code%TYPE;
		l_private_flag			jtf_tasks_b.private_flag%TYPE;
		l_deleted_flag			jtf_tasks_b.deleted_flag%TYPE;
		l_source_object_name	jtf_tasks_b.source_object_name%TYPE;
		l_owner_type_code		jtf_objects_b.object_code%TYPE;
		l_owner_id			jtf_tasks_b.owner_id%TYPE;

      l_source_doc_number	    VARCHAR2(200);

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
-- Read OKCCONDITION - Contract Condition
		--Select task_type
		Cursor task_cur is
		select task_type_id, name
		from jtf_task_types_vl
		where task_type_id = 18;
		--where name = 'OKCCONDITION';

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
		--Select task status
		Cursor status_cur is
		select task_status_id, name
		from jtf_task_statuses_vl
		where task_status_id = 9;
		--where name = 'Closed';

		--Select object code
		Cursor object_cur is
		select object_code
		from jtf_objects_vl
		where object_code = 'OKC_COND_OCCR'
		and  object_code in (select object_code
				   from jtf_object_usages
				   where object_user_code = 'TASK');

		--Select the owner type code
		Cursor owner_type_cur is
		select object_code
  		from jtf_objects_vl
  		where object_code = 'OKX_TASKRES'
  		and  object_code in (select object_code
       				   from jtf_object_usages
       				   where object_user_code = 'RESOURCES');

		l_notfound BOOLEAN;
	BEGIN
		l_private_flag := 'N';

		OPEN task_cur;
		FETCH task_cur into l_task_type_id, l_task_type_name;
		l_notfound := task_cur%NOTFOUND;
		CLOSE task_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_TASK_TYPE_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

		OPEN status_cur;
		FETCH status_cur into l_status_id, l_status_name;
		l_notfound := status_cur%NOTFOUND;
		CLOSE status_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_TASK_STATUS_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

		OPEN object_cur;
		FETCH object_cur into l_source_object_code;
		l_notfound := object_cur%NOTFOUND;
		CLOSE object_cur;
		if l_notfound THEN
		OKC_API.set_message(G_APP_NAME,'OKC_OBJECT_CODE_NOT_FOUND');
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
          end if;

		OPEN owner_type_cur;
		FETCH owner_type_cur into l_owner_type_code;
		l_notfound := owner_type_cur%NOTFOUND;
		CLOSE owner_type_cur;
		if l_notfound THEN
		   OKC_API.set_message(G_APP_NAME,'OKC_TASK_OWNER_NOT_FOUND');
         x_return_status := OKC_API.G_RET_STS_ERROR;
		  return;
      end if;

      -- get the source document number (to be displayed in tasks window)
      -- bug 1757364
      l_source_doc_number :=  OKC_QUERY.Get_Source_Doc_Number(p_cond_occr_id);
      l_source_doc_number :=  SUBSTR(l_source_doc_number,1,80);

		--Call to the procedure of the public API JTF_TASKS_PUB to create a Task
		jtf_tasks_pub.create_task(p_api_version 	=> p_api_version
					 ,p_init_msg_list 	     => p_init_msg_list
					 ,p_task_id		     => l_task_id
			       ,p_task_name 			=> p_condition_name
					 ,p_task_type_name	     => l_task_type_name
			       ,p_task_type_id 	     => l_task_type_id
					 ,p_task_status_name     => l_status_name
					 ,p_task_status_id 		=> l_status_id
					 ,p_actual_end_date 	=> p_actual_end_date
					 ,p_source_object_type_code 	=> l_source_object_code
					 ,p_source_object_name   => l_source_doc_number
				    ,p_source_object_id 	=> p_cond_occr_id
					 ,p_owner_id			=> p_task_owner_id
					 ,p_owner_type_code      => l_owner_type_code
					 ,p_private_flag		=> l_private_flag
					 ,x_return_status 		=> x_return_status
					 ,x_msg_count 			=> x_msg_count
					 ,x_msg_data			=> x_msg_data
					 ,x_task_id 			=> x_task_id);

		IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
		   raise OKC_API.G_EXCEPTION_ERROR;
          END IF;
     EXCEPTION
		WHEN OKC_API.G_EXCEPTION_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_ERROR';
		 NULL;
		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_UNEXP_ERROR';
		 NULL;
		WHEN OTHERS THEN
		 x_return_status := OKC_API.HANDLE_EXCEPTIONS
		 (l_api_name,
		  G_PKG_NAME,
		  'OTHERS',
		  x_msg_count,
		  x_msg_data,
		  '_PROCESS');

	END create_condition_task;

	-- Start of comments
    	-- Procedure Name  : create_contingent_task
    	-- Description     : Procedure to create a Task for a contingent event
    	-- Version         : 1.0
    	-- End of comments
	PROCEDURE create_contingent_task(p_api_version 	IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_contract_id		     IN NUMBER
			     ,p_contract_number		IN VARCHAR2
			     ,p_contingent_name		IN VARCHAR2
			     ,p_task_owner_id		IN NUMBER
			     ,p_actual_end_date		IN DATE
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2
			     ,x_task_id			OUT NOCOPY NUMBER) IS
          l_api_name               CONSTANT VARCHAR2(30) := 'create_contingent_task';
		l_task_id			     jtf_tasks_b.task_id%TYPE;
		l_task_type_id			jtf_task_types_b.task_type_id%TYPE;
		l_task_type_name		jtf_task_types_tl.name%TYPE;
		l_status_id			jtf_task_statuses_b.task_status_id%type;
		l_status_name			jtf_task_statuses_tl.name%type;
		l_source_object_code	jtf_objects_b.object_code%TYPE;
		l_private_flag			jtf_tasks_b.private_flag%TYPE;
		l_deleted_flag			jtf_tasks_b.deleted_flag%TYPE;
		l_source_object_name	jtf_tasks_b.source_object_name%TYPE;
		l_owner_type_code		jtf_objects_b.object_code%TYPE;
		l_owner_id			jtf_tasks_b.owner_id%TYPE;

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
-- Read OKCCONTINGENT - Contract Contingent Event
		--Select task_type
		Cursor task_cur is
		select task_type_id, name
		from jtf_task_types_vl
		where task_type_id = 24;
		--where name = 'OKCCONTINGENT';

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
		--Select task status
		Cursor status_cur is
		select task_status_id, name
		from jtf_task_statuses_vl
		where task_status_id = 9;
		--where name = 'Closed';

		--Select object code
		Cursor object_cur is
		select object_code
		from jtf_objects_vl
		where object_code = 'OKC_K_HEADER'
		and  object_code in (select object_code
				   from jtf_object_usages
				   where object_user_code = 'TASK');

		--Select the owner type code
		Cursor owner_type_cur is
		select object_code
  		from jtf_objects_vl
  		where object_code = 'OKX_TASKRES'
  		and  object_code in (select object_code
       				   from jtf_object_usages
       				   where object_user_code = 'RESOURCES');

		l_notfound BOOLEAN;

	BEGIN
		l_private_flag := 'N';

		OPEN task_cur;
		FETCH task_cur into l_task_type_id, l_task_type_name;
		l_notfound := task_cur%NOTFOUND;
		CLOSE task_cur;
		if l_notfound THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
		OKC_API.set_message(G_APP_NAME,'OKC_TASK_TYPE_NOT_FOUND');
		  return;
          end if;

		OPEN status_cur;
		FETCH status_cur into l_status_id, l_status_name;
		l_notfound := status_cur%NOTFOUND;
		CLOSE status_cur;
		if l_notfound THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
		OKC_API.set_message(G_APP_NAME,'OKC_TASK_STATUS_NOT_FOUND');
		  return;
          end if;

		OPEN object_cur;
		FETCH object_cur into l_source_object_code;
		l_notfound := object_cur%NOTFOUND;
		CLOSE object_cur;
		if l_notfound THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  OKC_API.set_message(G_APP_NAME,'OKC_OBJECT_CODE_NOT_FOUND');
		  return;
          end if;

		OPEN owner_type_cur;
		FETCH owner_type_cur into l_owner_type_code;
		l_notfound := owner_type_cur%NOTFOUND;
		CLOSE owner_type_cur;
		if l_notfound THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
		  OKC_API.set_message(G_APP_NAME,'OKC_TASK_OWNER_NOT_FOUND');
		  return;
          end if;

		--Call to the procedure of the public API JTF_TASKS_PUB to create a Task
		jtf_tasks_pub.create_task(p_api_version 		=> p_api_version
					          ,p_init_msg_list 		=> p_init_msg_list
					          ,p_task_id			=> l_task_id
			                    ,p_task_name 			=> p_contingent_name
					          ,p_task_type_name		=> l_task_type_name
			                    ,p_task_type_id 		=> l_task_type_id
			         		     ,p_task_status_name		=> l_status_name
					          ,p_task_status_id 		=> l_status_id
					          ,p_actual_end_date 		=> p_actual_end_date
					          ,p_source_object_type_code 	=> l_source_object_code
					          ,p_source_object_name    => p_contract_number
				               ,p_source_object_id  	=> p_contract_id
					          ,p_owner_id			=> p_task_owner_id
					          ,p_owner_type_code       => l_owner_type_code
					          ,p_private_flag		=> l_private_flag
					          ,x_return_status 		=> x_return_status
					          ,x_msg_count 			=> x_msg_count
					          ,x_msg_data			=> x_msg_data
					          ,x_task_id 			=> x_task_id);

		IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
		   raise OKC_API.G_EXCEPTION_ERROR;
          END IF;
     EXCEPTION
		WHEN OKC_API.G_EXCEPTION_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_ERROR';
		 NULL;
		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_UNEXP_ERROR';
		 NULL;
		WHEN OTHERS THEN
		 x_return_status := OKC_API.HANDLE_EXCEPTIONS
		 (l_api_name,
		  G_PKG_NAME,
		  'OTHERS',
		  x_msg_count,
		  x_msg_data,
		  '_PROCESS');

	END create_contingent_task;

	-- Start of comments
    	-- Procedure Name  : update_task
    	-- Description     : Procedure to update a Task
    	-- Version         : 1.0
    	-- End of comments
	PROCEDURE update_task(p_api_version 		IN NUMBER
			     ,p_init_msg_list 		     IN VARCHAR2
			     ,p_object_version_number      IN OUT NOCOPY NUMBER
			     ,p_task_id			     IN NUMBER
			     ,p_task_number		          IN NUMBER
			     ,p_workflow_process_id	     IN NUMBER
			     ,p_actual_end_date       	IN DATE
			     ,p_alarm_fired_count          IN NUMBER
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2) IS
          l_api_name          CONSTANT VARCHAR2(30) := 'update_task';
		l_task_status_name	jtf_tasks_v.task_status%TYPE;
		l_task_status_id	jtf_tasks_v.task_status_id%TYPE;
		l_close_status_id	jtf_tasks_v.task_status_id%TYPE;
		l_open_status_id	jtf_tasks_v.task_status_id%TYPE;
		l_close_status_name	jtf_tasks_v.task_status%TYPE;
		l_open_status_name	jtf_tasks_v.task_status%TYPE;
      l_source_object_id  jtf_tasks_b.source_object_id%TYPE;
      l_source_object_name jtf_tasks_b.source_object_name%TYPE;

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
		--Select task status
		Cursor update_status_cur is
		select task_status_id, name
		from jtf_task_statuses_vl
		where task_status_id = 9;
		--where name = 'Closed';

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
		--Select task_status
		Cursor status_cur is
		select task_status_id, name
		from jtf_task_statuses_vl
		where task_status_id = 10;
		--where name = 'Open';

      -- Get source Object Details
      Cursor source_obj_details IS
      Select SOURCE_OBJECT_ID
            ,SOURCE_OBJECT_NAME
      From   jtf_tasks_b
      Where  task_id = p_task_id;

		l_notfound BOOLEAN;

	BEGIN
		--If the actual date is not null then update the status to Closed
		IF p_actual_end_date IS NOT NULL THEN
		    OPEN  update_status_cur;
		    FETCH  update_status_cur into l_close_status_id, l_close_status_name;
		    l_notfound := update_status_cur%NOTFOUND;
		    CLOSE update_status_cur;
		if l_notfound THEN
             x_return_status := OKC_API.G_RET_STS_ERROR;
		   OKC_API.set_message(G_APP_NAME,'OKC_TASK_STATUS_NOT_FOUND');
		   return;
          end if;
			l_task_status_name := l_close_status_name;
			l_task_status_id := l_close_status_id;
		ELSIF p_actual_end_date IS NULL THEN
		    OPEN  status_cur;
		    FETCH status_cur into l_open_status_id, l_open_status_name;
		    l_notfound := status_cur%NOTFOUND;
		    CLOSE status_cur;
		if l_notfound THEN
             x_return_status := OKC_API.G_RET_STS_ERROR;
		   OKC_API.set_message(G_APP_NAME,'OKC_TASK_STATUS_NOT_FOUND');
		   return;
          end if;
		     l_task_status_name := l_open_status_name;
			l_task_status_id := l_open_status_id;
		END IF;

      -- Get the source object id and name
      OPEN  source_obj_details;
      FETCH source_obj_details INTO l_source_object_id, l_source_object_name;
      IF    source_obj_details%NOTFOUND THEN
            OKC_API.set_message(G_APP_NAME,'OKC_TASK_SOURCE_NOT_FOUND');
            return;
      END IF;
      CLOSE source_obj_details;

		--Call to the procedure of public API JTF_TASKS_PUB to update a task
		jtf_tasks_pub.update_task(p_api_version  => p_api_version
			     		     ,p_init_msg_list 	     => p_init_msg_list
					        ,p_object_version_number => p_object_version_number
			     		     ,p_task_id		        => p_task_id
					        ,p_task_number		     => p_task_number
					        ,p_workflow_process_id  => p_workflow_process_id
			     		     ,p_actual_end_date      => p_actual_end_date
					        ,p_alarm_fired_count    => p_alarm_fired_count
					        ,p_task_status_id       => l_task_status_id
				           ,p_task_status_name	  => l_task_status_name
                       ,p_source_object_id     => l_source_object_id
                       ,p_source_object_name   => l_source_object_name
			     		     ,x_return_status   	  => x_return_status
    			     		  ,x_msg_count       	  => x_msg_count
    			     		  ,x_msg_data        	  => x_msg_data);

		IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
		   raise OKC_API.G_EXCEPTION_ERROR;
          END IF;
     EXCEPTION
		WHEN OKC_API.G_EXCEPTION_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_ERROR';
		 NULL;
		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_UNEXP_ERROR';
		 NULL;
		WHEN OTHERS THEN
		 OKC_API.set_message(p_app_name => g_app_name,
		                     p_msg_name => g_unexpected_error,
		                     p_token1   => g_sqlcode_token,
		                     p_token1_value => sqlcode,
		                     p_token2   => g_sqlerrm_token,
		                     p_token2_value => sqlerrm);
		 x_return_status :=  OKC_API.G_RET_STS_UNEXP_ERROR;

	END update_task;

	-- Start of comments
    	-- Procedure Name  : delete_task
    	-- Description     : Procedure to delete a Task/s
    	-- Version         : 1.0
    	-- End of comments
	--Pass the p_tve_id(Time value ID) to delete multiple tasks(ex: When a rule is deleted)
	--Pass the p_rtv_id(Resolved Time ID) to delete a single task(ex: When a contract is terminated)
	PROCEDURE delete_task(p_api_version 		IN NUMBER
			     ,p_init_msg_list 	IN VARCHAR2
			     ,p_tve_id			IN NUMBER
			     ,p_rtv_id			IN NUMBER
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2) IS

				l_api_name CONSTANT VARCHAR2(30) := 'delete_task';

		--Select task for a given resolved timevalue id
		Cursor delete_tasks_cur(p_rtv_id IN NUMBER, p_status_id IN NUMBER) IS
		select jtf.task_id, jtf.task_number, jtf.object_version_number
		from jtf_tasks_b jtf
		where jtf.source_object_id = p_rtv_id
		and jtf.source_object_type_code = 'OKC_RESTIME'
		and jtf.task_status_id = p_status_id;

-- Replaced name with seeded ids to avoid translation issues - Bug 1683539
		--Select task status
		Cursor delete_status_cur is
		select task_status_id
		from jtf_task_statuses_vl
		where task_status_id = 10;
		--where name = 'Open';

		--Select all the resolved time values for a given timevalue id
		Cursor delete_rule_cur(p_tve_id IN NUMBER) IS
		select rtv.id
		from okc_resolved_timevalues rtv
		where rtv.tve_id = p_tve_id;

		TYPE delete_rec_type IS RECORD(
		  task_id      		jtf_tasks_b.task_id%TYPE,
		  task_number  		jtf_tasks_b.task_number%TYPE,
		  object_version_number	jtf_tasks_b.object_version_number%TYPE);
		TYPE delete_tasks_tbl_type IS TABLE OF delete_rec_type
		INDEX BY BINARY_INTEGER;
		delete_tasks_tbl  delete_tasks_tbl_type;

		delete_ctr	NUMBER := 0;
		i			NUMBER := 0;
		l_status_id	jtf_tasks_b.task_status_id%TYPE;
	     l_task_id		jtf_tasks_b.task_id%TYPE;
		l_task_number	jtf_tasks_b.task_number%TYPE;
		l_object_version_number	jtf_tasks_b.object_version_number%TYPE;
	BEGIN
	   --If the timevalue ID is not null then delete all the tasks for a rule with status = 'Open'
	   IF p_tve_id IS NOT NULL THEN
	     OPEN delete_status_cur;
	     FETCH delete_status_cur into l_status_id;
	     CLOSE delete_status_cur;

	     FOR delete_rule_rec in delete_rule_cur(p_tve_id) LOOP
		FOR delete_tasks_rec in delete_tasks_cur(p_rtv_id => delete_rule_rec.id,
							 p_status_id => l_status_id) LOOP
			delete_ctr := delete_ctr + 1;
			delete_tasks_tbl (delete_ctr).task_id := delete_tasks_rec.task_id;
			delete_tasks_tbl (delete_ctr).task_number := delete_tasks_rec.task_number;
			delete_tasks_tbl (delete_ctr).object_version_number := delete_tasks_rec.object_version_number;
		END LOOP;
	     END LOOP;

	    IF delete_tasks_tbl.COUNT > 0 THEN
	    i := delete_tasks_tbl.FIRST;
	    LOOP
		--Call the procedure of public API JTF_TASKS_PUB to delete tasks
		jtf_tasks_pub.delete_task(p_api_version    	  => p_api_version
			     		     ,p_init_msg_list  	  => p_init_msg_list
					          ,p_object_version_number => delete_tasks_tbl(i).object_version_number
			     		     ,p_task_id        	  => delete_tasks_tbl(i).task_id
					          ,p_task_number	   	  => delete_tasks_tbl(i).task_number
			     		     ,x_return_status  	  => x_return_status
    			     		     ,x_msg_count      	  => x_msg_count
    			     		     ,x_msg_data       	  => x_msg_data);
		EXIT WHEN (i = delete_tasks_tbl.LAST);
		i := delete_tasks_tbl.NEXT(i);
	   END LOOP;
	   END IF;
	 END IF;

	 --If the resolved timevalue id is not null then delete a single task
	 -- where source_object_id(JTF_TASKS_B) = p_rtv_id(resolved timevalue ID)
	 -- and the status is OKCOPEN
	 IF p_rtv_id IS NOT NULL THEN
	     OPEN delete_status_cur;
	     FETCH delete_status_cur into l_status_id;
	     CLOSE delete_status_cur;
		FOR delete_tasks_rec in delete_tasks_cur(p_rtv_id => p_rtv_id, p_status_id => l_status_id) LOOP
	         	delete_ctr := delete_ctr + 1;
			delete_tasks_tbl (delete_ctr).task_id := delete_tasks_rec.task_id;
			delete_tasks_tbl (delete_ctr).task_number := delete_tasks_rec.task_number;
			delete_tasks_tbl (delete_ctr).object_version_number := delete_tasks_rec.object_version_number;
	     END LOOP;

	    IF delete_tasks_tbl.COUNT > 0 THEN
	    i := delete_tasks_tbl.FIRST;
	    LOOP
		--Call to the procedure of public API JTF_TASKS_PUB to delete tasks
		jtf_tasks_pub.delete_task(p_api_version    	  => p_api_version
			     		     ,p_init_msg_list  	  => p_init_msg_list
					          ,p_object_version_number => delete_tasks_tbl(i).object_version_number
			     		     ,p_task_id        	  => delete_tasks_tbl(i).task_id
					          ,p_task_number	   	  => delete_tasks_tbl(i).task_number
			     		     ,x_return_status  	  => x_return_status
    			     		     ,x_msg_count      	  => x_msg_count
    			     		     ,x_msg_data       	  => x_msg_data);
		EXIT WHEN (i = delete_tasks_tbl.LAST);
		i := delete_tasks_tbl.NEXT(i);
	   END LOOP;
	   END IF;
   	 END IF;

		IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
		   raise OKC_API.G_EXCEPTION_ERROR;
          END IF;
     EXCEPTION
		WHEN OKC_API.G_EXCEPTION_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_ERROR';
		 NULL;
		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		 x_return_status := 'OKC_API.G_RET_STS_UNEXP_ERROR';
		 NULL;
		WHEN OTHERS THEN
		 OKC_API.set_message(p_app_name => g_app_name,
		                     p_msg_name => g_unexpected_error,
		                     p_token1   => g_sqlcode_token,
		                     p_token1_value => sqlcode,
		                     p_token2   => g_sqlerrm_token,
		                     p_token2_value => sqlerrm);
		 x_return_status :=  OKC_API.G_RET_STS_UNEXP_ERROR;


	END delete_task;
END OKC_TASK_PVT;

/
