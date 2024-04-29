--------------------------------------------------------
--  DDL for Package Body IEU_TASKS_WR_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_TASKS_WR_MIG_PVT" AS
/* $Header: IEUVTWRB.pls 120.7 2006/08/18 05:03:33 msathyan noship $ */

l_not_valid_flag VARCHAR2(1);
l_workitem_obj_code VARCHAR2(30);
l_owner_type_actual VARCHAR2(30);

l_assignee_role        VARCHAR2(30);
l_resource_type_code_1 VARCHAR2(30);
l_resource_type_code_2 VARCHAR2(30);
l_delete_flag          VARCHAR2(1);
l_closed_flag          VARCHAR2(1);
l_completed_flag       VARCHAR2(1);
l_cancelled_flag       VARCHAR2(1);
l_rejected_flag        VARCHAR2(1);
l_rownum               NUMBER(1);

PROCEDURE IEU_SYNCH_WR_DIST_STATUS(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2) IS

  l_assignee_id  number;
  l_assignee_type varchar2(25);
  l_task_priority_id number;
  l_date_selected   varchar2(1);
  l_task_status varchar2(10);
  l_return_status varchar2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_work_item_id NUMBER;
  l_count number;
  l_err_msg varchar2(4000);

  -- Reqd for Distribution Rules
  l_ws_id1            NUMBER;
  l_ws_id2            NUMBER := null;
  l_association_ws_id NUMBER;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;

  l_uwqm_count number := 0;
  l_uwqm_open_count number := 0;
  l_task_open_count number := 0;
  l_task_dist_count number := 0;
  l_run_script_flag varchar2(1);
  l_orig_grp_owner  number;
  l_tasks_rules_func varchar2(256);
  l_tasks_data_list  SYSTEM.WR_TASKS_DATA_NST;
  l_def_data_list    SYSTEM.DEF_WR_DATA_NST;

  l_child_ws_id       NUMBER;
  l_object_code_match varchar2(1);
  l_failed_counter NUMBER := 0;
  l_success_counter NUMBER := 0;
  l_ws_act_failed_msg Varchar2(4000);
  l_message varchar2(4000);
  l_ws_act_success_msg varchar2(4000);
  l_workitem_fail_msg varchar2(4000);
  l_workitem_sum_msg varchar2(4000);
  l_obj_code_lst VARCHAR2(1000);
  x_msg_count    NUMBER;
  x_msg_data     VARCHAR2(4000);
  err_flag       VARCHAR2(1);


  type t_task_details_1 is ref cursor;

  c_task_details_1 t_task_details_1;
  v_task_details_1 varchar2(4000) ;
  v_task_details_2 varchar2(4000) ;
  v_task_details_3 varchar2(4000) ;

--	and   tb.source_object_type_code not in ('SR');
   l_c_task_details_1_var varchar2(100);

  CURSOR c_task_asg_det IS
    SELECT resource_id, task_id, resource_type_code
    from (SELECT  /*+ parallel(TASKS) parallel(ASG) pq_distribute(ASG hash,hash) */
                  tasks.task_id, TASKS.owner_id,
                  tasks.owner_type_code, asg.resource_id, asg.resource_type_code, asg.task_assignment_id,
                  max(asg.last_update_date) over (partition by asg.task_id) max_update_date, asg.last_update_date
                 FROM JTF_TASKS_B TASKS , JTF_TASK_ASSIGNMENTS ASG
                 WHERE TASKS.TASK_ID = ASG.TASK_ID
                 AND NVL(TASKS.DELETED_FLAG,'N') = 'N'
                 AND TASKS.OPEN_FLAG = 'Y'
                 AND TASKS.entity = 'TASK'
                 and tasks.owner_type_code = 'RS_GROUP'
                 and asg.resource_type_code not in ('RS_GROUP', 'RS_TEAM')
                 and asg.assignee_role = 'ASSIGNEE'
                 and exists
                 (SELECT /*+ index(a,JTF_RS_GROUP_MEMBERS_N1) */ null
                    FROM JTF_RS_GROUP_MEMBERS a
                   WHERE a.group_id=tasks.owner_id
                   and a.RESOURCE_ID = asg.resource_id
                   AND NVL(DELETE_FLAG,'N') <> 'Y' )
                 and exists
                 (select  1
                  from jtf_task_statuses_b sts
                  where sts.task_status_id = asg.assignment_status_id
                  and (nvl(sts.closed_flag, 'N') = 'N'
                  and nvl(sts.completed_flag, 'N') = 'N'
                  and nvl(sts.cancelled_flag, 'N') = 'N'
                  and nvl(sts.rejected_flag, 'N') = 'N'))) a
      where a.last_update_date = a.max_update_date;

CURSOR c_task_due_date IS
 SELECT booking_end_date, task_id
 FROM   JTF_TASK_ALL_ASSIGNMENTS
 WHERE  assignee_role = 'OWNER';

CURSOR c_task_status IS
 SELECT TASK_ID,
        DECODE(DELETED_FLAG, 'Y', 4, 3) "STATUS_ID"
 FROM JTF_TASKS_B
 WHERE ((OPEN_FLAG = 'N' AND DELETED_FLAG = 'N') OR (DELETED_FLAG = 'Y'))
 AND ENTITY = 'TASK';

/**      select resource_id, task_id, resource_type_code
      from
	(
	SELECT  tasks.task_id, TASKS.owner_id, tasks.owner_type_code, asg.resource_id, asg.resource_type_code, asg.task_assignment_id,
			  max(asg.last_update_date) over (partition by asg.task_id) max_update_date, asg.last_update_date
			  FROM JTF_TASK_ASSIGNMENTS ASG, JTF_TASKS_B TASKS
			  WHERE TASKS.TASK_ID = ASG.TASK_ID
			  AND NVL(TASKS.DELETED_FLAG,'N') = 'N'
			  AND TASKS.OPEN_FLAG = 'Y'
			  AND TASKS.entity = 'TASK'
			  and tasks.owner_type_code = 'RS_GROUP'
			  and asg.resource_type_code not in ('RS_GROUP', 'RS_TEAM')
			  and asg.assignee_role = 'ASSIGNEE'
			  and exists
			  (SELECT null
			     FROM JTF_RS_GROUP_MEMBERS
			    WHERE group_id=tasks.owner_id
			    and RESOURCE_ID = asg.resource_id
			    AND NVL(DELETE_FLAG,'N') <> 'Y' )
			  and exists
			  (select 1
			   from jtf_task_statuses_b sts
			   where sts.task_status_id = asg.assignment_status_id
			   and (nvl(sts.closed_flag, 'N') = 'N'
			   and nvl(sts.completed_flag, 'N') = 'N'
			   and nvl(sts.cancelled_flag, 'N') = 'N'
			   and nvl(sts.rejected_flag, 'N') = 'N') )
	--and tasks.task_id = 17234
	) a
      where a.last_update_date = a.max_update_date;
***/

  TYPE NUMBER_TBL   is TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
  TYPE DATE_TBL     is TABLE OF DATE          INDEX BY BINARY_INTEGER;
  TYPE VARCHAR2_TBL is TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;

  TYPE task_details_rec IS RECORD
  (
	  l_task_id_list                 NUMBER_TBL,
	  l_task_number_list             VARCHAR2_TBL,
	  l_customer_id_list             NUMBER_TBL,
	  l_owner_id_list                NUMBER_TBL,
	  l_owner_type_code_list         VARCHAR2_TBL,
	  l_owner_type_actual_list       VARCHAR2_TBL,
	  l_source_object_id_list        NUMBER_TBL,
	  l_source_object_type_code_list VARCHAR2_TBL,
--	  l_due_date_list                DATE_TBL,
	  l_planned_start_date_list      DATE_TBL,
	  l_planned_end_date_list        DATE_TBL,
	  l_actual_start_date_list       DATE_TBL,
	  l_actual_end_date_list         DATE_TBL,
	  l_scheduled_start_date_list    DATE_TBL,
	  l_scheduled_end_date_list      DATE_TBL,
	  l_task_type_id_list            NUMBER_TBL,
	  l_task_name_list               VARCHAR2_TBL,
	  l_importance_level_list        NUMBER_TBL,
	  l_priority_code_list           VARCHAR2_TBL,
	  l_pty_id_list			 VARCHAR2_TBL,
	  l_pty_level_list		 VARCHAR2_TBL,
	  l_dist_sts_id			 NUMBER_TBL,
  	  l_task_status_id_list          NUMBER_TBL,
	  l_ins_flag			 NUMBER_TBL

  );

  l_task_det_rec task_details_rec;

  TYPE task_asg_rec is RECORD
  (
	  l_asg_id_list			 NUMBER_TBL,
	  l_asg_task_id_list		 NUMBER_TBL,
	  l_asg_type_act_list		 VARCHAR2_TBL
  );

  l_task_asg_rec task_asg_rec;

  TYPE due_date_rec is RECORD
  (
	  l_due_date_list		DATE_TBL,
	  l_task_id_list		NUMBER_TBL
  );

  l_task_duedate_rec due_date_rec;

  TYPE status_rec is RECORD
  (
	  l_task_id_list		NUMBER_TBL,
	  l_status_id_list		NUMBER_TBL
  );

  l_task_status_rec status_rec;

  l_array_size			 NUMBER;
  l_ws_id			 NUMBER;
  l_total			 NUMBER;
  l_cnt				 NUMBER;
  l_ctr_list			 NUMBER_TBL;

  dml_errors EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  errors NUMBER;

  l_entity             VARCHAR2(10);
  l_deleted_flag       VARCHAR2(1);
  l_task_priority_id_1 NUMBER(1);
  l_open_flag          VARCHAR2(1);
  l_object_code        VARCHAR2(10);

  cursor c1(p_child_ws_id IN NUMBER) is
  select ''''||object_code||'''' object_code
  from ieu_uwqm_work_sources_b
  where ws_id in ( select assct_props.parent_ws_id
                   from   ieu_uwqm_work_sources_b ws, ieu_uwqm_ws_assct_props assct_props
                   where  ws.ws_id = assct_props.ws_id
                   and    assct_props.child_ws_id = p_child_ws_id
                   and    nvl(ws.not_valid_flag,'N') = 'N');

  l_sql_stmt VARCHAR2(4000);
  l_ws_exists    VARCHAR2(10);

  l_done	BOOLEAN;
  l_cur_name	VARCHAR2(100);
  l_null_val	VARCHAR2(20);

  l_user_id	NUMBER;
  l_login_id	NUMBER;
  l_assct_ws_cnt NUMBER;
  l_error_count  NUMBER;


begin

	  l_error_count := 0;
	  l_dist_from := 'GROUP_OWNED';
	  l_dist_to   := 'INDIVIDUAL_ASSIGNED';
	  l_object_code := 'TASK';

	  l_user_id := FND_GLOBAL.USER_ID;
	  l_login_id := FND_GLOBAL.LOGIN_ID;
	  l_array_size := 2000;
	 -- l_ws_id := 10000;
          l_null_val  := '''NONE''';
          v_task_details_1 :=   'select  /*+ ordered parallel(tb) parallel(tt) use_nl(tp,ip,sts_b)*/
        tb.task_id
      , tb.task_number work_item_number
      , tb.customer_id
      , tb.owner_id
      , decode(tb.owner_type_code, '||''''||'RS_GROUP'||''''||','||''''||'RS_GROUP'||''''||','||''''||'RS_TEAM'||''''||','||
        ''''||'RS_TEAM'||''''||','||''''|| 'RS_INDIVIDUAL'||''''||')'||' owner_type_code
      , tb.owner_type_code owner_type_actual
      , tb.source_object_id
      , tb.source_object_type_code
--      , decode(tb.date_selected,'||''''||'P'||''''||', tb.planned_end_date, '||''''||'A'||''''||', tb.actual_end_date, '||''''||'S'||''''||', tb.scheduled_end_date, null, tb.scheduled_end_date) due_date
      , tb.planned_start_date
      , tb.planned_end_date
      , tb.actual_start_date
      , tb.actual_end_date
      , tb.scheduled_start_date
      , tb.scheduled_end_date
      , tb.task_type_id
      , substr(tt.task_name,1,1990) TITLE
      , tp.importance_level
      , ip.priority_code
      , ip.priority_id
      , ip.priority_level
      , decode(NVL(tb.owner_type_code,'||''''||'NULL'||''''||'), '||''''||'RS_GROUP'||''''||', 1, 0) distribution_status_id
      , decode(nvl(sts_b.on_hold_flag, '||''''||'N'||''''||'),'||''''||'Y'||''''||', 5, 0) uwq_status_id
      , 1 ins_flag
   from  jtf_tasks_b tb
     , jtf_tasks_tl tt
     , jtf_task_priorities_b tp
     , ieu_uwqm_priorities_b ip
     , jtf_task_statuses_b sts_b
   where tb.entity = '||''''||'TASK'||''''||'
	and   nvl(tb.deleted_flag, '||''''||'N'||''''||') = '||''''||'N'||''''||'
	and   tb.task_id = tt.task_id
	and   tt.language =  userenv('||''''||'LANG'||''''||')
	and   tp.task_priority_id = nvl(tb.task_priority_id, 4)
	and   least(tp.importance_level, 4) = ip.priority_level
	and   open_flag = '||''''||'Y'||''''||'
	and   tb.task_status_id = sts_b.task_status_id';

        l_c_task_details_1_var := ' and   tb.source_object_type_code not in (';
	  begin
	      l_object_code := 'TASK';
	      l_not_valid_flag := 'N';
	      select ws_id
	      into l_ws_id
	      from ieu_uwqm_work_sources_b
	      where object_code = l_object_code
	      and nvl(not_valid_flag, 'N') = l_not_valid_flag;
	      exception
	      when others then
		       errbuf := 'Work Source does not exist';
		       retcode := 2;
		       l_message := errbuf;
--		       dbms_output.put_line('err msg: '||l_message);
		       FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
		       raise;
	  end;

	  BEGIN
                 l_assct_ws_cnt := 0;
                 l_ws_exists := 'N';

		 select count(*)
		 into   l_assct_ws_cnt
		 from   ieu_uwqm_work_sources_b ws, ieu_uwqm_ws_assct_props assct_props
		 where  ws.ws_id = assct_props.ws_id
		 and    assct_props.child_ws_id = l_ws_id
		 and    nvl(ws.not_valid_flag,'N') = 'N';

                 if nvl(l_assct_ws_cnt, 0) > 0 then
                   l_ws_exists := 'Y';
                 else
                   l_ws_exists := 'N';
                 end if;

	  EXCEPTION
	    WHEN OTHERS THEN
	        l_ws_exists := 'N';
	  END;

--	  dbms_output.put_line('l_ws_exists: '||l_ws_exists);

          if (l_ws_exists = 'Y')
	  then
		  for cur_rec in c1(l_ws_id)
		  loop
			if l_obj_code_lst is null
			then
			   l_obj_code_lst := cur_rec.object_code;
			else
			   l_obj_code_lst := l_obj_code_lst || ', '||  cur_rec.object_code;
			end if;
		  end loop;
          else
	     l_obj_code_lst := l_null_val;
	  end if;
          l_obj_code_lst := NVL(l_obj_code_lst, l_null_val);

--	  dbms_output.put_line('Obj Code List: '||l_obj_code_lst);
	  --l_total := 0;
          l_failed_counter := 0;

	 -- open c_task_details_1;
          v_task_details_1 := v_task_details_1||l_c_task_details_1_var||l_obj_code_lst||')';
          open c_task_details_1 for v_task_details_1;
	  loop

	     FETCH c_task_details_1
  	     BULK COLLECT INTO
		l_task_det_rec.l_task_id_list,
		l_task_det_rec.l_task_number_list,
		l_task_det_rec.l_customer_id_list,
		l_task_det_rec.l_owner_id_list,
		l_task_det_rec.l_owner_type_code_list,
		l_task_det_rec.l_owner_type_actual_list,
		l_task_det_rec.l_source_object_id_list,
		l_task_det_rec.l_source_object_type_code_list,
		--l_task_det_rec.l_due_date_list,
		l_task_det_rec.l_planned_start_date_list,
		l_task_det_rec.l_planned_end_date_list,
		l_task_det_rec.l_actual_start_date_list,
		l_task_det_rec.l_actual_end_date_list,
		l_task_det_rec.l_scheduled_start_date_list,
		l_task_det_rec.l_scheduled_end_date_list,
		l_task_det_rec.l_task_type_id_list,
		l_task_det_rec.l_task_name_list,
		l_task_det_rec.l_importance_level_list,
		l_task_det_rec.l_priority_code_list,
		l_task_det_rec.l_pty_id_list,
		l_task_det_rec.l_pty_level_list,
		l_task_det_rec.l_dist_sts_id,
		l_task_det_rec.l_task_status_id_list,
		l_task_det_rec.l_ins_flag
	    LIMIT l_array_size;

            l_done := c_task_details_1%NOTFOUND;

	    if ( (l_total is not null) and (l_task_det_rec.l_task_id_list.COUNT is not NULL))
	    then
		l_total := l_total + l_task_det_rec.l_task_id_list.COUNT;
	    elsif (l_task_det_rec.l_task_id_list.COUNT is not NULL)
	    then
	        l_total := l_task_det_rec.l_task_id_list.COUNT;
	    end if;

	    BEGIN
		FORALL i in 1..l_task_det_rec.l_task_id_list.COUNT SAVE EXCEPTIONS
		 insert into ieu_uwqm_items
			( WORK_ITEM_ID,
			 OBJECT_VERSION_NUMBER,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 SECURITY_GROUP_ID,
			 WORKITEM_OBJ_CODE,
			 WORKITEM_PK_ID,
			 STATUS_ID,
			 PRIORITY_ID,
			 PRIORITY_LEVEL,
			-- DUE_DATE,
			 TITLE,
			 PARTY_ID,
			 OWNER_TYPE,
			 OWNER_ID,
			 OWNER_TYPE_ACTUAL,
			 SOURCE_OBJECT_ID,
			 SOURCE_OBJECT_TYPE_CODE,
			 APPLICATION_ID,
			 IEU_ENUM_TYPE_UUID,
			 STATUS_UPDATE_USER_ID,
			 WORK_ITEM_NUMBER,
			 RESCHEDULE_TIME,
			 WS_ID,
			 DISTRIBUTION_STATUS_ID )
		values  (
			IEU_UWQM_ITEMS_S1.NEXTVAL,
			0,
			l_user_id,
			SYSDATE,
			l_user_id,
			SYSDATE,
			l_login_id,
			0,
			'TASK',
			l_task_det_rec.l_task_id_list(i),
			l_task_det_rec.l_task_status_id_list(i),
			l_task_det_rec.l_pty_id_list(i),
			l_task_det_rec.l_pty_level_list(i),
			--l_task_det_rec.l_due_date_list(i),
			l_task_det_rec.l_task_name_list(i),
			l_task_det_rec.l_customer_id_list(i),
			l_task_det_rec.l_owner_type_code_list(i),
			l_task_det_rec.l_owner_id_list(i),
			l_task_det_rec.l_owner_type_actual_list(i),
			l_task_det_rec.l_source_object_id_list(i),
			l_task_det_rec.l_source_object_type_code_list(i),
			690,
			'TASKS',
			l_user_id,
			l_task_det_rec.l_task_number_list(i),
			sysdate,
			l_ws_id,
			l_task_det_rec.l_dist_sts_id(i));

	     EXCEPTION
		    WHEN dml_errors THEN
                   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   --fnd_file.put_line(FND_FILE.LOG,'insert failed..');
		   FOR i IN 1..errors LOOP
		      l_task_det_rec.l_ins_flag(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) := 0;
                      --dbms_output.put_line(SQLERRM(-1*SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      If SQL%BULK_EXCEPTIONS(i).ERROR_CODE <> 1 then
                         l_error_count := l_error_count + 1;
                      --** checking for error threshold **--
                      IF l_error_count > 1000 THEN
                         FND_MESSAGE.SET_NAME('IEU', 'IEU_ERROR_THRESHOLD');
                         FND_MESSAGE.SET_TOKEN('ERROR_COUNT', '1000');
                         FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                         fnd_msg_pub.ADD;
                         fnd_msg_pub.Count_and_Get
                         (
                         p_count   =>   x_msg_count,
                         p_data    =>   x_msg_data
                         );

                        RAISE fnd_api.g_exc_error;
                      END IF;

                         err_flag := 'Y';
                         fnd_file.new_line(FND_FILE.LOG, 1);
                         FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_UWQM_ITEM_FAILED');
                         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_TASKS_WR_MIG_PVT');
                         FND_MESSAGE.SET_TOKEN('DETAILS', 'WORKITEM_PK_ID:'||l_task_det_rec.l_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                     fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                     fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                     fnd_msg_pub.ADD;
                     fnd_msg_pub.Count_and_Get
                         (
                         p_count   =>   x_msg_count,
                         p_data    =>   x_msg_data
                         );
                    END IF;
		   END LOOP;

                   IF err_flag = 'Y' THEN

                      FND_MESSAGE.SET_NAME('IEU', 'IEU_WS_ACTIVATE_FAILED');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   -- RAISE fnd_api.g_exc_error;
                   END IF;
	    END;




	   -- fnd_file.put_line(FND_FILE.LOG,' errors: '||errors);
	    if (errors > 0)
	    then
	     -- fnd_file.put_line(FND_FILE.LOG,'begin update');
	      BEGIN
		FORALL i in 1..l_task_det_rec.l_task_id_list.COUNT SAVE EXCEPTIONS
		    UPDATE IEU_UWQM_ITEMS
		    set
			OBJECT_VERSION_NUMBER  = OBJECT_VERSION_NUMBER + 1,
--			CREATED_BY             = l_user_id,
--			CREATION_DATE          = SYSDATE,
			LAST_UPDATED_BY        = l_user_id,
			LAST_UPDATE_DATE       = SYSDATE,
			LAST_UPDATE_LOGIN      = l_login_id,
			STATUS_ID              = l_task_det_rec.l_task_status_id_list(i),
			PRIORITY_ID            = l_task_det_rec.l_pty_id_list(i),
			PRIORITY_LEVEL         = l_task_det_rec.l_pty_level_list(i),
			--DUE_DATE               = l_task_det_rec.l_due_date_list(i),
			TITLE                  = l_task_det_rec.l_task_name_list(i),
			PARTY_ID               = l_task_det_rec.l_customer_id_list(i),
			OWNER_TYPE             = l_task_det_rec.l_owner_type_code_list(i),
			OWNER_ID               = l_task_det_rec.l_owner_id_list(i),
			SOURCE_OBJECT_ID       = l_task_det_rec.l_source_object_id_list(i),
			SOURCE_OBJECT_TYPE_CODE = l_task_det_rec.l_source_object_type_code_list(i),
			OWNER_TYPE_ACTUAL      = l_task_det_rec.l_owner_type_actual_list(i),
			APPLICATION_ID         = 690,
			IEU_ENUM_TYPE_UUID     = 'TASKS',
			STATUS_UPDATE_USER_ID  = l_user_id,
			WORK_ITEM_NUMBER       = l_task_det_rec.l_task_number_list(i),
			RESCHEDULE_TIME        = sysdate,
			WS_ID                  = l_ws_id,
			DISTRIBUTION_STATUS_ID = l_task_det_rec.l_dist_sts_id(i)
		     where workitem_obj_code = 'TASK'
			 and workitem_pk_id = l_task_det_rec.l_task_id_list(i)
			 and l_task_det_rec.l_ins_flag(i) = 0;
	       EXCEPTION
		    WHEN dml_errors THEN
 		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   l_failed_counter := SQL%BULK_EXCEPTIONS.COUNT;
                   l_success_counter := l_task_det_rec.l_task_id_list.COUNT - l_failed_counter;


		   FOR i IN 1..errors LOOP
		     --** checking for error threshold **--

                   l_error_count := l_error_count + 1;
                   IF l_error_count > 1000 THEN
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_ERROR_THRESHOLD');
                      FND_MESSAGE.SET_TOKEN('ERROR_COUNT', '1000');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   RAISE fnd_api.g_exc_error;
                   END IF;

                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_TASKS_WR_MIG_PVT');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_det_rec.l_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                    END LOOP;

                      FND_MESSAGE.SET_NAME('IEU', 'IEU_WS_ACTIVATE_FAILED');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   -- RAISE fnd_api.g_exc_error;



	       END;
	    end if;

	    COMMIT;

		l_task_det_rec.l_task_id_list.DELETE;
		l_task_det_rec.l_task_number_list.DELETE;
		l_task_det_rec.l_customer_id_list.DELETE;
		l_task_det_rec.l_owner_id_list.DELETE;
		l_task_det_rec.l_owner_type_code_list.DELETE;
		l_task_det_rec.l_owner_type_actual_list.DELETE;
		l_task_det_rec.l_source_object_id_list.DELETE;
		l_task_det_rec.l_source_object_type_code_list.DELETE;
		--l_task_det_rec.l_due_date_list.DELETE;
		l_task_det_rec.l_planned_start_date_list.DELETE;
		l_task_det_rec.l_planned_end_date_list.DELETE;
		l_task_det_rec.l_actual_start_date_list.DELETE;
		l_task_det_rec.l_actual_end_date_list.DELETE;
		l_task_det_rec.l_scheduled_start_date_list.DELETE;
		l_task_det_rec.l_scheduled_end_date_list.DELETE;
		l_task_det_rec.l_task_type_id_list.DELETE;
		l_task_det_rec.l_task_name_list.DELETE;
		l_task_det_rec.l_importance_level_list.DELETE;
		l_task_det_rec.l_priority_code_list.DELETE;
		l_task_det_rec.l_pty_id_list.DELETE;
		l_task_det_rec.l_pty_level_list.DELETE;
		l_task_det_rec.l_dist_sts_id.DELETE;
		l_task_det_rec.l_task_status_id_list.DELETE;
		l_task_det_rec.l_ins_flag.DELETE;

    	    EXIT WHEN (l_done);

	  end loop;
	  close c_task_details_1;

	    DBMS_STATS.DELETE_TABLE_STATS (
		   ownname         => 'IEU',
		   tabname         => 'IEU_UWQM_ITEMS');

	    DBMS_STATS.GATHER_TABLE_STATS (
		   ownname         => 'IEU',
		   tabname         => 'IEU_UWQM_ITEMS',
		   degree	   => 8,
		   cascade         => TRUE);


          -- Update Due Date based on Booking End Date

	  open c_task_due_date;
	  loop

	     FETCH c_task_due_date
	     BULK COLLECT INTO
	          l_task_duedate_rec.l_due_date_list,
		  l_task_duedate_rec.l_task_id_list
             LIMIT l_array_size;

	     fnd_file.put_line(FND_FILE.LOG,'due date task id cnt: '||l_task_duedate_rec.l_task_id_list.COUNT);
	     l_done := c_task_due_date%NOTFOUND;

	     BEGIN
	--	fnd_file.put_line(FND_FILE.LOG,'Begin update');
		     FORALL i in 1..l_task_duedate_rec.l_task_id_list.COUNT SAVE EXCEPTIONS
			update IEU_UWQM_ITEMS
			set	due_date = l_task_duedate_rec.l_due_date_list(i)
			where   workitem_pk_id = l_task_duedate_rec.l_task_id_list(i)
			and	workitem_obj_code = 'TASK'
			and     ws_id = l_ws_id;
	     EXCEPTION
		  WHEN dml_errors THEN
		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   FOR i IN 1..errors LOOP
		  /*    fnd_file.put_line(FND_FILE.LOG,'Error ' || i || ' occurred during '||
			 'assignee update for workitem_pk_id ' || l_task_asg_rec.l_asg_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||
		         'Oracle error is ' ||
			 SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE)); */

                    --** checking for error threshold **--

                   l_error_count := l_error_count +1;
                   IF l_error_count > 1000 THEN
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_ERROR_THRESHOLD');
                      FND_MESSAGE.SET_TOKEN('ERROR_COUNT', '1000');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   RAISE fnd_api.g_exc_error;
                   END IF;

                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_TASKS_WR_MIG_PVT');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_duedate_rec.l_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );
                    END LOOP;
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_WS_ACTIVATE_FAILED');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data);

                 --   RAISE fnd_api.g_exc_error;



	     END;

	     COMMIT;

             l_task_duedate_rec.l_due_date_list.DELETE;
             l_task_duedate_rec.l_task_id_list.DELETE;

	     exit when (l_done);

	   end loop;

	   close c_task_due_date;


          -- Update Close and Delete Statuses

	  open c_task_status;
	  loop

	     FETCH c_task_status
	     BULK COLLECT INTO
		  l_task_status_rec.l_task_id_list,
		  l_task_status_rec.l_status_id_list
             LIMIT l_array_size;

	     fnd_file.put_line(FND_FILE.LOG,'status task id cnt: '||l_task_status_rec.l_task_id_list.COUNT);
	     l_done := c_task_status%NOTFOUND;

	     BEGIN
	--	fnd_file.put_line(FND_FILE.LOG,'Begin update');
		     FORALL i in 1..l_task_status_rec.l_task_id_list.COUNT SAVE EXCEPTIONS
			update IEU_UWQM_ITEMS
			set	status_id = l_task_status_rec.l_status_id_list(i),
         			LAST_UPDATED_BY        = l_user_id,
	        		LAST_UPDATE_DATE       = SYSDATE,
		        	LAST_UPDATE_LOGIN      = l_login_id
			where   workitem_obj_code = 'TASK'
                        and     workitem_pk_id = l_task_status_rec.l_task_id_list(i)
			and     ws_id = l_ws_id;
	     EXCEPTION
		  WHEN dml_errors THEN
		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   FOR i IN 1..errors LOOP

                 --** checking for error threshold **--

                   l_error_count := l_error_count + 1;
                   IF l_error_count > 1000 THEN
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_ERROR_THRESHOLD');
                      FND_MESSAGE.SET_TOKEN('ERROR_COUNT', '1000');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   RAISE fnd_api.g_exc_error;
                   END IF;

                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_TASKS_WR_MIG_PVT');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_status_rec.l_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );
                    END LOOP;
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_WS_ACTIVATE_FAILED');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data);

                  --  RAISE fnd_api.g_exc_error;


	     END;

	     COMMIT;

             l_task_status_rec.l_task_id_list.DELETE;
             l_task_status_rec.l_status_id_list.DELETE;

	     exit when (l_done);

	   end loop;

	   close c_task_status;

          -- Update Assignees

	  open c_task_asg_det;
	  loop

	     FETCH c_task_asg_det
  	     BULK COLLECT INTO
		  l_task_asg_rec.l_asg_id_list,
		  l_task_asg_rec.l_asg_task_id_list,
		  l_task_asg_rec.l_asg_type_act_list
	     LIMIT l_array_size;

	     fnd_file.put_line(FND_FILE.LOG,'asg task id cnt: '||l_task_asg_rec.l_asg_task_id_list.COUNT||
				' asg id cnt: '||l_task_asg_rec.l_asg_id_list.COUNT|| ' asg type cnt: '||l_task_asg_rec.l_asg_type_act_list.COUNT );
	     l_done := c_task_asg_det%NOTFOUND;

	     BEGIN
	--	fnd_file.put_line(FND_FILE.LOG,'Begin update');
		     FORALL i in 1..l_task_asg_rec.l_asg_task_id_list.COUNT SAVE EXCEPTIONS
			update IEU_UWQM_ITEMS
			set	assignee_id = l_task_asg_rec.l_asg_id_list(i),
				assignee_type = 'RS_INDIVIDUAL',
				assignee_type_actual = l_task_asg_rec.l_asg_type_act_list(i),
				DISTRIBUTION_STATUS_ID = 3
			where   workitem_pk_id = l_task_asg_rec.l_asg_task_id_list(i)
			and	workitem_obj_code = 'TASK'
			and	ws_id = l_ws_id;
	     EXCEPTION
		  WHEN dml_errors THEN
		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   FOR i IN 1..errors LOOP
		  /*    fnd_file.put_line(FND_FILE.LOG,'Error ' || i || ' occurred during '||
			 'assignee update for workitem_pk_id ' || l_task_asg_rec.l_asg_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||
		         'Oracle error is ' ||
			 SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE)); */

                   --** checking for error threshold **--

                   l_error_count := l_error_count + 1;
                   IF l_error_count > 1000 THEN
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_ERROR_THRESHOLD');
                      FND_MESSAGE.SET_TOKEN('ERROR_COUNT', '1000');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   RAISE fnd_api.g_exc_error;
                   END IF;


                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_TASKS_WR_MIG_PVT');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_asg_rec.l_asg_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );
                    END LOOP;
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_WS_ACTIVATE_FAILED');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data);

                --    RAISE fnd_api.g_exc_error;



	     END;

	     COMMIT;

	     l_task_asg_rec.l_asg_id_list.DELETE;
	     l_task_asg_rec.l_asg_task_id_list.DELETE;
	     l_task_asg_rec.l_asg_type_act_list.DELETE;

	     exit when (l_done);

	   end loop;

	   close c_task_asg_det;

	    l_msg_count := null;
	    l_msg_data := null;
	    l_return_status := null;

	    if (l_failed_counter = 0)
	    then
		IEU_WR_PUB.ACTIVATE_WS
			     (p_api_version => 1,
			      p_init_msg_list => 'T',
			      p_commit => 'T',
			      p_ws_code => 'TASK',
			      x_msg_count => l_msg_count,
			      x_msg_data => l_msg_data,
			      x_return_status => l_return_status);
          else
   	           IEU_WR_PUB.DEACTIVATE_WS
			     (p_api_version => 1,
			      p_init_msg_list => 'T',
			      p_commit => 'T',
			      p_ws_code => 'TASK',
			      x_msg_count => l_msg_count,
			      x_msg_data => l_msg_data,
			      x_return_status => l_return_status);
	    end if;

	    fnd_file.new_line(FND_FILE.LOG, 1);

	    if (l_failed_counter = 0) and (l_return_status = 'S') then

	       FND_MESSAGE.SET_NAME('IEU', 'IEU_WS_ACTIVATED');
	       FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
	       l_ws_act_success_msg := FND_MESSAGE.GET;
	       fnd_file.put_line(FND_FILE.LOG, l_ws_act_success_msg);
--	       dbms_output.put_line(l_ws_act_success_msg);

	    else
	       FND_MESSAGE.SET_NAME('IEU', 'IEU_WS_ACTIVATE_FAILED');
	       FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
	       l_ws_act_failed_msg := FND_MESSAGE.GET;

	       l_ws_act_failed_msg := l_ws_act_failed_msg||' '||l_msg_data;
	       fnd_file.put_line(FND_FILE.LOG, l_ws_act_failed_msg);
               RAISE fnd_api.g_exc_error;

--	       dbms_output.put_line(l_ws_act_failed_msg);
	    end if;

	    fnd_file.new_line(FND_FILE.LOG, 1);
	    FND_MESSAGE.SET_NAME('IEU', 'IEU_SYNCH_WR_DIST_STATUS_SUM');
	    FND_MESSAGE.SET_TOKEN('SUCCESS_COUNT', (l_total - l_failed_counter));
	    FND_MESSAGE.SET_TOKEN('FAILED_COUNT', l_failed_counter);
	    FND_MESSAGE.SET_TOKEN('TOTAL_COUNT', l_total );

--	    dbms_output.put_line('SUCCESS_COUNT'|| (l_total - l_failed_counter));
--	    dbms_output.put_line('FAILED_COUNT'||l_failed_counter);
--	    dbms_output.put_line('TOTAL_COUNT'|| l_total );

	    l_workitem_sum_msg := FND_MESSAGE.GET;

	    fnd_file.put_line(FND_FILE.LOG, l_workitem_sum_msg);
--	    dbms_output.put_line(l_workitem_sum_msg);

	    DBMS_STATS.DELETE_TABLE_STATS (
		   ownname         => 'IEU',
		   tabname         => 'IEU_UWQM_ITEMS');

	    DBMS_STATS.GATHER_TABLE_STATS (
		   ownname         => 'IEU',
		   tabname         => 'IEU_UWQM_ITEMS',
		   degree	   => 8,
		   cascade         => TRUE);

EXCEPTION
  WHEN fnd_api.g_exc_error THEN

       IEU_WR_PUB.DEACTIVATE_WS
			     (p_api_version => 1,
			      p_init_msg_list => 'T',
			      p_commit => 'T',
			      p_ws_code => 'TASK',
			      x_msg_count => l_msg_count,
			      x_msg_data => l_msg_data,
			      x_return_status => l_return_status);
  retcode := 2;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );
  errbuf :=x_msg_Data;

WHEN fnd_api.g_exc_unexpected_error THEN

--  errbuf := sqlcode||' '||sqlerrm;
    IEU_WR_PUB.DEACTIVATE_WS
			     (p_api_version => 1,
			      p_init_msg_list => 'T',
			      p_commit => 'T',
			      p_ws_code => 'TASK',
			      x_msg_count => l_msg_count,
			      x_msg_data => l_msg_data,
			      x_return_status => l_return_status);
  retcode := 2;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );
  errbuf :=x_msg_Data;

  WHEN OTHERS THEN

       IEU_WR_PUB.DEACTIVATE_WS
			     (p_api_version => 1,
			      p_init_msg_list => 'T',
			      p_commit => 'T',
			      p_ws_code => 'TASK',
			      x_msg_count => l_msg_count,
			      x_msg_data => l_msg_data,
			      x_return_status => l_return_status);

       errbuf := sqlcode||' '||sqlerrm;
       retcode := 2;
       l_message := sqlcode || ' '||sqlerrm;
       FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
       IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN

       fnd_msg_pub.Count_and_Get
       (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
       );
       errbuf := x_msg_data;
      END IF;


END IEU_SYNCH_WR_DIST_STATUS;

END IEU_TASKS_WR_MIG_PVT;

/
