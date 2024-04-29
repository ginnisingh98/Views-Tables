--------------------------------------------------------
--  DDL for Package Body AHL_WORKORDER_SEARCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_WORKORDER_SEARCH_PUB" AS
/* $Header: AHLPWSOB.pls 120.0.12010000.5 2009/03/04 00:04:54 sikumar noship $ */

G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_WORKORDER_SEARCH_PUB';

G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
G_LOG_PREFIX        CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_WORKORDER_SEARCH_PUB';


-- Assigned Work Order Query---------------------------

PROCEDURE get_wo_search_results(
				p_api_version											  IN					NUMBER,
				p_init_msg_list										  IN				  VARCHAR2 := FND_API.G_TRUE,
				p_commit													  IN				  VARCHAR2 := FND_API.G_FALSE,
				p_validation_level									IN				  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
				p_module_type												IN				  VARCHAR2,
				p_userid                            IN VARCHAR2 := NULL,
				x_return_status											OUT NOCOPY	VARCHAR2,
				x_msg_count													OUT NOCOPY	NUMBER,
				x_msg_data													OUT NOCOPY	VARCHAR2,
				p_workorders_search_rec							    IN 			WORKORDERS_SEARCH_REC_TYPE,
				x_work_order_results								    OUT NOCOPY	WORK_ORDERS_TYPE
																			  )
IS
        l_api_version          CONSTANT NUMBER := 1.0;
		    l_api_name             CONSTANT VARCHAR2(30) := 'get_workorder_search_results';
				l_msg_data             VARCHAR2(2000);
        l_model                VARCHAR2(30) := 'Model' ;
        l_ata_code             VARCHAR2(30) := 'ATA';
        l_tail_number          VARCHAR2(30);
        l_user_name            VARCHAR2(40);
        l_user_lang            VARCHAR2(40);
        l_doc_id               VARCHAR2(80) :='docid';
				l_query_string				 VARCHAR2(30000) := NULL;

				l_bind_index					 NUMBER;
				i											 NUMBER;
				j											 NUMBER;
				l_search_wo_csr				 AHL_OSP_UTIL_PKG.ahl_search_csr;
				l_bind_value_tbl			 AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
				l_work_order_rec			 WORK_ORDER_REC_TYPE;

BEGIN


  SAVEPOINT Search_Work_Orders;

  IF(p_module_type = 'BPEL') THEN
           x_return_status := AHL_PRD_WO_PUB.init_user_and_role(p_userid);
          IF(x_return_status <> Fnd_Api.G_RET_STS_SUCCESS)THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
   END IF;



   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;


   --  Initialize API return status to success
    --x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    x_work_order_results.WORK_ORDERS(0).WORKORDER_ID := NULL;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,'AHL_WORKORDER_SEARCH_PUB')
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

	 IF (p_workorders_search_rec.SEARCH_TABLE_INDEX = 1) THEN

	 l_query_string := 'SELECT DISTINCT '||
												'wo.workorder_id workorder_id, '||
												'wo.object_version_number object_version_number, '||
												'Wo.Job_Number workorder_number, '||
												'wo.Job_Description Description, '||
												'wo.job_status_code status_code, '||
												'Wo.Job_Status_Meaning status, '||
												'Wo.Visit_Number visit_number, '||
												'Wo.Unit_Name unit_name, '||
												'Wo.Scheduled_Start_Date assigned_start_date, '||
                        'Wo.Confirm_Failure_flag is_complete_enabled, '||
												'Wo.Confirm_Failure_flag is_update_enabled, '||
												'Wo.Confirm_Failure_flag is_res_txn_enabled     '||
										'FROM '||
												'ahl_Search_Workorders_V Wo , '||
												'wip_discrete_jobs widj, '||
												'ahl_Workorder_Operations Wop, '||
												'ahl_Operation_Resources Opr, '||
												'ahl_Work_Assignments Wass, '||
												'per_People_F Pf, '||
												'per_Person_Types Pt, '||
												'Fnd_User fnd '||
										'WHERE '||
												'fnd.USER_ID = FND_GLOBAL.USER_ID and '||
												'fnd.employee_id = pf.PERSON_ID and '||
							          'wass.employee_id = pf.PERSON_ID and '||
							         ' pt.Person_Type_Id  = Pf.Person_Type_Id And '||
				                'pt.system_person_type =''EMP'' AND '||
												'( Trunc(Sysdate) Between Pf.Effective_Start_Date And '||
												'Pf.Effective_End_Date) and '||
												'wass.Operation_Resource_Id = Opr.Operation_Resource_Id And '||
												'opr.Workorder_Operation_Id = Wop.Workorder_Operation_Id And '||
												'wop.Workorder_Id = Wo.Workorder_Id and '||
												'wo.JOB_STATUS_CODE not in (1, 17, 22) and '||
												'wo.wip_entity_id = widj.wip_entity_id and '||
												'widj.date_released is not null';

 	 ELSIF (p_workorders_search_rec.SEARCH_TABLE_INDEX = 2) THEN

		 l_query_string := 'SELECT '||
				'wo.workorder_id workorder_id, '||
				'wo.object_version_number object_version_number, '||
				'Wo.Job_Number workorder_number, '||
				'wo.Job_Description Description, '||
				'wo.job_status_code status_code, '||
				'Wo.Job_Status_Meaning status, '||
				'Wo.Visit_Number visit_number, '||
				'Wo.Unit_Name unit_name, '||
				'Wo.Scheduled_Start_Date assigned_start_date, '||
			  'Wo.Confirm_Failure_flag is_complete_enabled, '||
				'Wo.Confirm_Failure_flag is_update_enabled, '||
				'Wo.Confirm_Failure_flag is_res_txn_enabled '||
			'FROM( '||
						'SELECT DISTINCT '||
								'wod.workorder_id , '||
								'Wod.Job_Number , '||
				        'wod.job_status_code , '||
								'Wod.Job_Status_Meaning , '||
				        'Wod.Visit_Number , '||
				        'wod.VISIT_ID , '||
				        'Wod.Incident_Number , '||
								'wod.INCIDENT_ID , '||
				        'nvl(wod.ACtual_START_DATE, wod.SCHEDULED_START_DATE) scheduled_start_date, '||
				        'wod.JOB_DESCRIPTION , '||
				        'wod.class_code class_code, '||
				        'wod.Visit_Task_number, '||
								'wod.project_name , '||
				        'wod.Project_Task_name , '||
				        'wod.Mr_Title, '||
				        'wod.wo_part_number , '||
				        'wod.Serial_Number, '||
				       ' wod.Organization_name , '||
				        'wod.department_name , '||
				        'wod.UNIT_NAME, '||
								'NVL(WOd.ACTUAL_END_DATE, WOd.SCHEDULED_END_DATE)  scheduled_end_date, '||
				       ' wod.department_class_code, '||
								'wod.visit_task_id, '||
				        'wod.object_version_number, '||
					'wod.Confirm_Failure_flag, '||
					'wod.priority_meaning priority, '||
					'wod.wo_type_meaning '||
             'FROM '||
               ' ahl_search_workorders_v wod, '||
                'wip_discrete_jobs widj, '||
                'per_people_f pf, '||
                'bom_resource_employees bre, '||
                'PER_PERSON_TYPES PEPT, '||
                'ahl_pp_requirement_v aprv, '||
                'Fnd_User fnd '||
             'WHERE '||
                'fnd.USER_ID = FND_GLOBAL.USER_ID and '||
                'fnd.employee_id = pf.PERSON_ID and '||
								' NVL(pf.CURRENT_EMPLOYEE_FLAG, ''X'') = ''Y'' AND '||
                'PEPT.PERSON_TYPE_ID  = pf.PERSON_TYPE_ID AND '||
                'PEPT.SYSTEM_PERSON_TYPE =''EMP'' AND '||
                '( TRUNC(SYSDATE) BETWEEN PF.EFFECTIVE_START_DATE AND PF.EFFECTIVE_END_DATE ) and '||
                'pf.person_id = bre.person_id and '||
                'bre.resource_id = aprv.RESOURCE_ID and '||
                'wod.workorder_id not in ( '||
                     'SELECT DISTINCT '||
                          'wo1.workorder_id '||
                     'FROM '||
                          'ahl_Workorders Wo1, '||
                          'wip_discrete_jobs widj1, '||
                          'ahl_Workorder_Operations Wop, '||
                          'ahl_Operation_Resources Opr, '||
                          'ahl_Work_Assignments Wass, '||
                          'Fnd_User fnd '||
                     'WHERE '||
                           'fnd.USER_ID = FND_GLOBAL.USER_ID and '||
                           'fnd.employee_id = pf.PERSON_ID and '||
                           'NVL(pf.CURRENT_EMPLOYEE_FLAG, ''X'') = ''Y'' AND '||
                           'PEPT.PERSON_TYPE_ID  = pf.PERSON_TYPE_ID AND '||
                           'PEPT.SYSTEM_PERSON_TYPE =''EMP'' AND '||
                          '( TRUNC(SYSDATE) BETWEEN PF.EFFECTIVE_START_DATE AND PF.EFFECTIVE_END_DATE ) and '||
                           'wass.Employee_Id = pf.person_id And '||
                           'wass.Operation_Resource_Id = Opr.Operation_Resource_Id       And '||
                           'opr.Workorder_Operation_Id = Wop.Workorder_Operation_Id And '||
                           'wop.Workorder_Id = Wo1.Workorder_Id and '||
                           'wo1.STATUS_CODE not in (1, 17, 22) and '||
                           'wo1.wip_entity_id = widj1.wip_entity_id and '||
                           'widj1.date_released is not null '||
                         ' ) and '||
                'aprv.job_id = wod.workorder_id and '||
                'wod.JOB_STATUS_CODE not in (1, 17, 22) and '||
                'wod.wip_entity_id = widj.wip_entity_id and '||
                'widj.date_released is not null '||

'	UNION '||

						'SELECT DISTINCT '||
								'wod.workorder_id , '||
								'Wod.Job_Number , '||
				        'wod.job_status_code , '||
								'Wod.Job_Status_Meaning , '||
				        'Wod.Visit_Number , '||
				        'wod.VISIT_ID , '||
				        'Wod.Incident_Number , '||
								'wod.INCIDENT_ID , '||
				        'nvl(wod.ACtual_START_DATE, wod.SCHEDULED_START_DATE) scheduled_start_date, '||
				        'wod.JOB_DESCRIPTION , '||
				        'wod.class_code class_code, '||
				        'wod.Visit_Task_number, '||
								'wod.project_name , '||
				        'wod.Project_Task_name , '||
				        'wod.Mr_Title, '||
				        'wod.wo_part_number , '||
				        'wod.Serial_Number, '||
				       ' wod.Organization_name , '||
				        'wod.department_name , '||
				        'wod.UNIT_NAME, '||
								'NVL(WOd.ACTUAL_END_DATE, WOd.SCHEDULED_END_DATE)  scheduled_end_date, '||
				       ' wod.department_class_code, '||
								'wod.visit_task_id, '||
				        'wod.object_version_number, '||
								'wod.Confirm_Failure_flag, '||
					'wod.priority_meaning priority, '||
					'wod.wo_type_meaning '||
' FROM '||
        'ahl_search_workorders_v wod, '||
        'wip_discrete_jobs widj '||
' WHERE '||
        'wod.workorder_id not in (select job_id from ahl_pp_requirement_v where resource_type_code = 2) and wod.JOB_STATUS_CODE not in (1, 17, 22) and '||
        'wod.wip_entity_id = widj.wip_entity_id and '||
        'widj.date_released is not null) wo where 1=1';

	ELSE
			  RAISE FND_API.G_EXC_ERROR;
	END IF;

 	l_bind_index :=1;

	IF p_workorders_search_rec.workorder_number IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.job_number like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.workorder_number;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.status_code IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.job_status_code = :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.status_code;
        l_bind_index := l_bind_index + 1;
  END IF;
  	IF p_workorders_search_rec.status IS NOT NULL THEN
        l_query_string := l_query_string || ' AND upper(wo.Job_Status_Meaning) like upper(:'||l_bind_index ||')';
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.status;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.description IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.job_description like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.description;
        l_bind_index := l_bind_index + 1;
  END IF;
  IF p_workorders_search_rec.non_routine_number IS NOT NULL THEN
        l_query_string := l_query_string || ' AND Wo.Incident_Number like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.non_routine_number;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.visit_number IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.visit_number = :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.visit_number;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.project IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.project_name like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.project;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.project_task IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.project_task_name like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.project_task;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.item IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.wo_part_number like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.item;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.unit_name IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.unit_name like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.unit_name;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.department IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.department_name like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.department;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.organization IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.organization_name like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.organization;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.department_class_code IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.department_class_code like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.department_class_code;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.maintenance_requirement_title IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.mr_title like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.maintenance_requirement_title;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.accounting_class IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.CLASS_CODE like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.accounting_class;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.confirmed_failure_flag IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.Confirm_Failure_flag like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.confirmed_failure_flag;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.priority IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.PRIORITY like :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.priority;
        l_bind_index := l_bind_index + 1;
  END IF;
	IF p_workorders_search_rec.visit_task_number IS NOT NULL THEN
        l_query_string := l_query_string || ' AND wo.VISIT_TASK_NUMBER = :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.visit_task_number;
        l_bind_index := l_bind_index + 1;
  END IF;
  IF p_workorders_search_rec.workorder_type IS NOT NULL THEN
          l_query_string := l_query_string || ' AND wo.wo_type_meaning like :'||l_bind_index;
          l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.workorder_type;
          l_bind_index := l_bind_index + 1;
  END IF;
  IF p_workorders_search_rec.employee IS NOT NULL THEN
     l_query_string := l_query_string || 'AND wo.WORKORDER_ID in (select wop.workorder_id from per_people_f pf, ahl_work_assignments wass, ahl_operation_resources opr, ahl_workorder_operations wop where ';
     l_query_string := l_query_string || ' wop.workorder_operation_id = opr.workorder_operation_id and opr.operation_resource_id = wass.operation_resource_id ';
     l_query_string := l_query_string || ' and wass.employee_id = pf.person_id and upper(pf.full_name) like upper(:' ||l_bind_index ||'))';
     l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.employee;
     l_bind_index := l_bind_index + 1;
  END IF;

  l_query_string := l_query_string || ' AND exists ( SELECT ''x'' FROM AHL_WORKORDER_OPERATIONS_V WOP where WOP.workorder_id = WO.workorder_id';
  IF p_workorders_search_rec.OPERATION_CODE IS NOT NULL THEN
				l_query_string := l_query_string || ' AND upper(WOP.OPERATION_CODE) like upper(:' ||l_bind_index ||')';
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.OPERATION_CODE;
        l_bind_index := l_bind_index + 1;
  END IF;

  IF p_workorders_search_rec.operation_description IS NOT NULL THEN
	l_query_string := l_query_string || ' AND upper(WOP.DESCRIPTION) like upper(:' ||l_bind_index ||')';
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.operation_description;
        l_bind_index := l_bind_index + 1;
  END IF;
  l_query_string := l_query_string || ')';

  IF p_workorders_search_rec.bom_resource IS NOT NULL THEN
		l_query_string := l_query_string || ' AND exists ( SELECT ''x'' FROM AHL_PP_REQUIREMENT_V RES where RES.job_id = WO.workorder_id and upper(RES.RESOURCE_CODE) like upper(:' ||l_bind_index ||'))';
        l_bind_value_tbl(l_bind_index) := p_workorders_search_rec.bom_resource;
        l_bind_index := l_bind_index + 1;
  END IF;
  IF p_workorders_search_rec.SCHEDULED_START_DATE IS NOT NULL AND p_workorders_search_rec.SCHEDULED_END_DATE IS NOT NULL THEN
		l_query_string := l_query_string || ' AND ((wo.SCHEDULED_START_DATE >= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS'')';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_start_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
        l_query_string := l_query_string || ' AND wo.SCHEDULED_START_DATE <= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS''))';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_end_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
		l_query_string := l_query_string || ' OR ( wo.SCHEDULED_END_DATE >= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS'')';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_start_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
        l_query_string := l_query_string || ' AND wo.SCHEDULED_END_DATE <= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS''))';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_end_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
		l_query_string := l_query_string || ' OR ( wo.SCHEDULED_START_DATE <= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS'')';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_start_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
        l_query_string := l_query_string || ' AND wo.SCHEDULED_END_DATE >= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS'')' || '))';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_end_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
  ELSIF p_workorders_search_rec.SCHEDULED_START_DATE IS NOT NULL THEN
		l_query_string := l_query_string || ' AND wo.SCHEDULED_END_DATE >= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS'')';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_start_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
  ELSIF p_workorders_search_rec.SCHEDULED_END_DATE IS NOT NULL THEN
		l_query_string := l_query_string || ' AND wo.SCHEDULED_START_DATE <= to_date(:'||l_bind_index||',''DD-MON-RRRR HH24:MI:SS'')';
        l_bind_value_tbl(l_bind_index) := to_char(p_workorders_search_rec.scheduled_end_date, 'DD-MON-RRRR HH24:MI:SS');
        l_bind_index := l_bind_index + 1;
  END IF;

    --OPEN l_search_wo_csr FOR l_query_string
  AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_search_wo_csr, l_bind_value_tbl, l_query_string);
  i := 0;
	j := 0;
		LOOP
        --Get search results
			  FETCH l_search_wo_csr INTO l_work_order_rec.WORKORDER_ID,
				                           l_work_order_rec.OBJECT_VERSION_NUMBER,
																	 l_work_order_rec.WORKORDER_NUMBER,
																	 l_work_order_rec.DESCRIPTION,
																	 l_work_order_rec.STATUS_CODE,
																	 l_work_order_rec.STATUS,
																	 l_work_order_rec.VISIT_NUMBER,
																	 l_work_order_rec.UNIT_NAME,
																	 l_work_order_rec.ASSIGNED_START_DATE,
																	 l_work_order_rec.IS_COMPLETE_ENABLED,
																	 l_work_order_rec.IS_UPDATE_ENABLED,
																	 l_work_order_rec.IS_RES_TXN_ENABLED;

			  EXIT WHEN l_search_wo_csr%NOTFOUND;
				i := i + 1;
				AHL_ENIGMA_UTIL_PKG.get_enigma_url_params('WO',
	   											l_work_order_rec.WORKORDER_ID,
													l_work_order_rec.WORKORDER_ID,
													x_model					 => l_model,
													x_ata_code       => l_ata_code,
													x_tail_number    => l_tail_number,
													x_user_name      => l_user_name,
													x_user_lang      => l_user_lang,
													x_doc_id         => l_doc_id
													);

				IF (i > NVL(p_workorders_search_rec.start_row_index,0) AND i <= NVL(p_workorders_search_rec.start_row_index + p_workorders_search_rec.number_of_rows,1000)) THEN
			  x_work_order_results.WORK_ORDERS(j).WORKORDER_ID						:=	l_work_order_rec.WORKORDER_ID;
			  x_work_order_results.WORK_ORDERS(j).OBJECT_VERSION_NUMBER	:=	l_work_order_rec.OBJECT_VERSION_NUMBER;
			  x_work_order_results.WORK_ORDERS(j).WORKORDER_NUMBER				:=	l_work_order_rec.WORKORDER_NUMBER;
              x_work_order_results.WORK_ORDERS(j).DESCRIPTION						:=	l_work_order_rec.DESCRIPTION;
			  x_work_order_results.WORK_ORDERS(j).STATUS_CODE						:=	l_work_order_rec.STATUS_CODE;
			  x_work_order_results.WORK_ORDERS(j).STATUS									:=	l_work_order_rec.STATUS;
			  x_work_order_results.WORK_ORDERS(j).VISIT_NUMBER						:=	l_work_order_rec.VISIT_NUMBER;
			  x_work_order_results.WORK_ORDERS(j).UNIT_NAME							:=	l_work_order_rec.UNIT_NAME;
			  x_work_order_results.WORK_ORDERS(j).MODEL									:=	l_model;
			  x_work_order_results.WORK_ORDERS(j).ATA_CODE								:=	l_ata_code;
			  x_work_order_results.WORK_ORDERS(j).ENIGMA_DOCUMENT_ID			:=	l_doc_id;
			  x_work_order_results.WORK_ORDERS(j).ASSIGNED_START_DATE		:=	l_work_order_rec.ASSIGNED_START_DATE;

              x_work_order_results.WORK_ORDERS(j).IS_COMPLETE_ENABLED		:=	AHL_COMPLETIONS_PVT.Is_Complete_Enabled(l_work_order_rec.WORKORDER_ID, NULL, NULL, 'T');
              IF(l_work_order_rec.STATUS_CODE IN ('22','7','12','1','7') OR AHL_PRD_UTIL_PKG.is_wo_updatable(l_work_order_rec.WORKORDER_ID,'T') = 'F')THEN

x_work_order_results.WORK_ORDERS(j).IS_UPDATE_ENABLED := 'F';
              ELSE
                    x_work_order_results.WORK_ORDERS(j).IS_UPDATE_ENABLED := 'T';
              END IF;

			  x_work_order_results.WORK_ORDERS(j).IS_RES_TXN_ENABLED := AHL_PRD_UTIL_PKG.Is_ResTxn_Allowed(l_work_order_rec.WORKORDER_ID,'T');
			  j := j + 1;
			  END IF;
			END LOOP;
	CLOSE l_search_wo_csr;
	x_work_order_results.start_row_index := NVL(p_workorders_search_rec.start_row_index,0);
	x_work_order_results.NUMBER_OF_ROWS  := j;

	EXCEPTION
		 WHEN Fnd_Api.G_EXC_ERROR THEN
	       ROLLBACK TO Search_Work_Orders;
				 x_return_status := Fnd_Api.G_RET_STS_ERROR;
				 Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
								                    p_data    => x_msg_data,
											              p_encoded => Fnd_Api.g_false);

	 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	       ROLLBACK TO Search_Work_Orders;
			   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
			   Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
						                        p_data    => x_msg_data,
									                  p_encoded => Fnd_Api.g_false);

		 WHEN OTHERS THEN
					-- dbms_output.put_line(' OTHERS	');
					ROLLBACK TO Search_Work_Orders;
					x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
			    Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => 'AHL_WORKORDER_SEARCH_PUB',
									                 p_procedure_name => 'Get_Workorder_Search_Results',
						                       p_error_text     => SQLERRM);

			    Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
						                         p_data    => x_msg_data,
									                   p_encoded => Fnd_Api.g_false);

END get_wo_search_results;

END AHL_WORKORDER_SEARCH_PUB;

/
