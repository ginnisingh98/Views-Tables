--------------------------------------------------------
--  DDL for Package Body IEU_WR_CON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WR_CON_PVT" AS
/* $Header: IEUVWRCB.pls 120.6 2006/04/19 21:45:03 msathyan noship $ */

PROCEDURE PURGE_WR_DATA
 (
  ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2,
  P_WS_CODE IN VARCHAR2 DEFAULT NULL,
  P_LAST_UPDATE_DATE IN DATE DEFAULT NULL
 )
  IS
--** This cursor represents the Associate work items that are closed and purged **--
--** Here work items whose parents are not open are picked **--
/*Cursor c1_purge_assct_wi(p_ws_id IN NUMBER,p_parent_ws_id IN NUMBER) is
Select workitem_pk_id, workitem_obj_code, source_object_id, source_object_type_code,
       owner_id, owner_type, assignee_id, assignee_type, status_id, priority_id, due_date,
       reschedule_time, distribution_status_id,work_item_number, work_item_id
from ieu_uwqm_items child
where  ws_id = p_ws_id
and    status_id in (3, 4)
and   ( to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') )
and not exists
	(select 1
	 from ieu_uwqm_items parent
	 where ws_id = p_parent_ws_id
         and status_id in (0,5)
         and parent.workitem_pk_id = child.source_object_id
	 and parent.workitem_obj_code = child.source_object_type_code);
  */

--** This cursor represents the Associate work items that are closed and have open parent work items **--
--** Here work items which have parents in open status are picked **--
Cursor C1_open_parent_assct_Wi(p_ws_id IN NUMBER,p_parent_ws_id IN NUMBER) is
Select workitem_pk_id, workitem_obj_code, source_object_id, source_object_type_code
from ieu_uwqm_items
where  ws_id = p_ws_id
and    status_id in (3, 4)
and   ( to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') )
and (source_object_id, source_object_type_code) IN
				(select workitem_pk_id, workitem_obj_code
				 from ieu_uwqm_items
				 where ws_id = p_parent_ws_id
				 and status_id in (0,5) );


--** This cursor represents Primary Work items that are closed and purged **--
--** The parent records are purged if the child records are not open **--
/*Cursor C2_purge_primary_wi(p_ws_id IN NUMBER,p_child_ws_id IN NUMBER) is
Select workitem_pk_id, workitem_obj_code, source_object_id, source_object_type_code,
       owner_id, owner_type, assignee_id, assignee_type, status_id, priority_id, due_date,
       reschedule_time, distribution_status_id,work_item_number,work_item_id
from ieu_uwqm_items parent
where  ws_id = p_ws_id
and    status_id in (3, 4)
and   ( to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') )
and   not exists
 	(select source_object_id, source_object_type_code
         from ieu_uwqm_items child
	 where ws_id = p_child_ws_id
	 and status_id in (0,5)
         and child.workitem_pk_id = parent.source_object_id
	 and child.workitem_obj_code = parent.source_object_type_code);
*/
--** This cursor represents the Primary work items that are closed and have open child work items **--
Cursor C2_open_child_primary_wi(p_ws_id IN NUMBER,p_child_ws_id IN NUMBER) is
/*Select workitem_pk_id, workitem_obj_code, source_object_id, source_object_type_code
from ieu_uwqm_items
where  ws_id = p_ws_id
and    status_id in (3, 4)
and   ( to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') )
and (workitem_pk_id, workitem_obj_code) in
				(select source_object_id, source_object_type_code
				 from ieu_uwqm_items
				 where ws_id = p_child_ws_id
				 and status_id in (0,5) );*/

Select parent.workitem_pk_id, parent.workitem_obj_code, child.workitem_pk_id, child.workitem_obj_code
from ieu_uwqm_items parent , ieu_uwqm_items child
where  parent.ws_id = p_ws_id
and    parent.status_id in (3, 4)
and   ( to_date(trunc(parent.last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') )
and   parent.workitem_pk_id =  child.source_object_id
and   parent.workitem_obj_code = child.source_object_type_code
and   child.ws_id = p_child_ws_id
and   child.status_id in (0,5) ;

--** This cursor represents all remaining closed work items **--
/*Cursor C3_purge_wi(p_ws_id IN NUMBER) is
Select workitem_pk_id, workitem_obj_code, source_object_id, source_object_type_code,
       owner_id, owner_type, assignee_id, assignee_type, status_id, priority_id, due_date,
       reschedule_time, distribution_status_id,work_item_number,work_item_id
from ieu_uwqm_items
where status_id in(3,4)
and ws_id = p_ws_id
and to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') ;
*/

TYPE NUMBER_TBL   is TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_TBL is TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
TYPE task_details_rec IS RECORD
  (
	  l_workitem_pk_id_list           VARCHAR2_TBL,
	  l_workitem_obj_code_list        VARCHAR2_TBL,
	  l_source_object_id_list         VARCHAR2_TBL,
	  l_source_object_type_code_list  VARCHAR2_TBL,
          l_owner_id_list VARCHAR2_TBL,
          l_owner_type_list VARCHAR2_TBL,
          l_assignee_id_list VARCHAR2_TBL,
          l_assignee_type_list VARCHAR2_TBL,
          l_status_id_list VARCHAR2_TBL,
          l_priority_id_list VARCHAR2_TBL,
          l_due_date_list VARCHAR2_TBL,
          l_reschedule_time_list VARCHAR2_TBL,
          l_distribution_status_id_list VARCHAR2_TBL,
          l_work_item_number_list VARCHAR2_TBL,
          l_work_item_id_list VARCHAR2_TBL
                    );

l_task_det_rec task_details_rec;

l_wi_exists		     	NUMBER := 0;
l_ws_type			VARCHAR2(50) := null;
l_ws_id				NUMBER := null;
l_dist_st_based_on_parent	VARCHAR2(10):= null;
l_assct_ws_id			NUMBER := null;
l_parent_ws_id			NUMBER := null;
l_child_ws_id			NUMBER := null;
l_parent_wi_pk_id		NUMBER := -9999;
l_parent_wi_obj_code		VARCHAR2(30):= null;
l_child_wi_pk_id		NUMBER := -9999;
l_child_wi_obj_code		VARCHAR2(30) := null;
l_message			VARCHAR2(4000);
l_parent_ws_code		VARCHAR2(30);
l_api_name              VARCHAR2(30);
l_audit_trail_rec       SYSTEM.WR_AUDIT_TRAIL_NST;
l_audit_log_val         VARCHAR2(100);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_return_status VARCHAR2(5);
l_temp_count number;
x_msg_count    NUMBER;
x_msg_data     VARCHAR2(4000);


--Audit
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);
l_closed_item_exists NUMBER;

dml_errors EXCEPTION;
PRAGMA exception_init(dml_errors, -24381);


BEGIN

  l_api_name      := 'PURGE_WR_ITEM';
  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_PURGE_INP_PARAMS');
  FND_MESSAGE.SET_TOKEN('WS_CODE', p_ws_code);
  FND_MESSAGE.SET_TOKEN('LU_DATE', p_last_update_date);
  l_message := FND_MESSAGE.GET;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

   BEGIN

       SELECT WS_B.WS_ID, WS_B.WS_TYPE, WS_A.DIST_ST_BASED_ON_PARENT_FLAG,
                     WS_A.PARENT_WS_ID, WS_A.CHILD_WS_ID
       INTO   l_ws_id, l_ws_type, l_dist_st_based_on_parent, l_parent_ws_id, l_child_ws_id
       FROM   IEU_UWQM_WORK_SOURCES_B WS_B, IEU_UWQM_WS_ASSCT_PROPS WS_A
       WHERE  ws_b.ws_code = p_ws_code
       AND    ws_b.not_valid_flag = 'N'
       AND    ws_b.ws_id = ws_a.ws_id(+);

   EXCEPTION
    WHEN OTHERS THEN
      l_ws_type := null;
      l_ws_id := null;
      l_dist_st_based_on_parent := null;
      l_assct_ws_id := null;
      l_parent_ws_id := null;
      l_child_ws_id := null;
   END;


   --** Purge Association Work Items **--
   --** Check if all the parent work items are purged. **--
   --** If the parent work items are still present, give appropriate message.**--
   --** If parent work items are purged, then purge association work items. **--
   if (l_ws_type = 'ASSOCIATION')
   then



       --** Check if any closed Parent Work Item exists with last update date <= p_last_update date **--
          BEGIN
             l_closed_item_exists := 0;
             select count(*)
             into l_closed_item_exists
             from ieu_uwqm_items
	     where ws_id = l_parent_ws_id
	     and   status_id in (3, 4)
	     and    to_date(trunc(last_update_date), 'dd-mm-rrrr')
                                                            <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') ;
          EXCEPTION
            WHEN OTHERS THEN
             l_closed_item_exists := 0;
          END;

          l_wi_exists := 0;
        --** if closed parent work items exist check for closed child work items **--
          IF l_closed_item_exists > 0 then
	  BEGIN


             select count(*)
             into l_wi_exists
             from   ieu_uwqm_items main
             where   status_id in (3,4)
             and ws_id = l_parent_ws_id
             and ( workitem_pk_id, workitem_obj_code) in
                                (Select source_object_id,source_object_type_code
                                 from ieu_uwqm_items
                                 where status_id in (3, 4)
                                 and    to_date(trunc(last_update_date), 'dd-mm-rrrr')
                                   <=  to_date(trunc(sysdate), 'dd-mm-rrrr') )
             and not exists (select 1 from ieu_uwqm_items
                             where status_id in (0,5)
                             and source_object_id = main.workitem_pk_id
                             and source_object_type_code = main.workitem_obj_code
                             and    to_date(trunc(last_update_date), 'dd-mm-rrrr')
                                   <=  to_date(trunc(sysdate), 'dd-mm-rrrr')) ;


	  EXCEPTION
	     WHEN OTHERS THEN
	       l_wi_exists := 0;
	  END;

          END IF; --l_closed_item_exists check


	   --**  if there are closed child work items for closed parent, then it means that the parent work items **--
           --**  are  not purged. **--
	   --**  Give the message to purge parent work items	**--
	  IF (l_wi_exists > 0)
	  THEN
	     RETCODE := 2;
	     BEGIN
		select ws_code
		into   l_parent_ws_code
		from   ieu_uwqm_work_sources_b
		where  ws_id = l_parent_ws_id;
	     EXCEPTION
	        WHEN OTHERS THEN
	            l_parent_ws_code := null;
	     END;

             FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_PURGE_PARENT_WI');
             FND_MESSAGE.SET_TOKEN('WS_CODE', l_parent_ws_code);
             l_message := FND_MESSAGE.GET;
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

             RAISE fnd_api.g_exc_error;
           END IF;


        --** If parents work items have been purged, then purge child work items **--
	   --** This code has been commented as audit logs are not required -- bug #4638378 **--
          IF (l_wi_exists = 0)  THEN

         /*  OPEN c1_purge_assct_wi(l_ws_id,l_parent_ws_id);
             FETCH c1_purge_assct_wi BULK COLLECT INTO
		l_task_det_rec.l_workitem_pk_id_list,
		l_task_det_rec.l_workitem_obj_code_list,
		l_task_det_rec.l_source_object_id_list,
		l_task_det_rec.l_source_object_type_code_list,
                l_task_det_rec.l_owner_id_list ,
                l_task_det_rec.l_owner_type_list,
                l_task_det_rec.l_assignee_id_list,
                l_task_det_rec.l_assignee_type_list,
                l_task_det_rec.l_status_id_list ,
                l_task_det_rec.l_priority_id_list ,
                l_task_det_rec.l_due_date_list ,
                l_task_det_rec.l_reschedule_time_list,
                l_task_det_rec.l_distribution_status_id_list,
                l_task_det_rec.l_work_item_number_list,
                l_task_det_rec.l_work_item_id_list;
             CLOSE c1_purge_assct_wi; */
        /*     FOR i IN 1..l_task_det_rec.l_workitem_pk_id_list.COUNT loop
    	         FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_PURGED_WI_DETAILS');
	         FND_MESSAGE.SET_TOKEN('WI_PK_ID', l_task_det_rec.l_workitem_pk_id_list(i));
	         l_message := FND_MESSAGE.GET;
	         FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
             END LOOP;*/
     /*    		 --** Audit logging starts here ** --
               l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
               l_action_key := 'WORKITEM_PURGE';
  	       l_event_key := 'PURGE_WR_ITEM';
 	       l_module := 'IEU_WR_PUB.PURGE_WR_ITEM';
               IF (l_audit_log_val = 'DETAILED')
               THEN
                  l_workitem_comment_code1 := 'WORKITEM_PURGE';
                  l_workitem_comment_code2 := null;
                  l_workitem_comment_code3 := null;
                  l_workitem_comment_code4 := null;
                  l_workitem_comment_code5 := null;
               ELSE
	          l_workitem_comment_code1 := null;
	          l_workitem_comment_code2 := null;
	          l_workitem_comment_code3 := null;
	          l_workitem_comment_code4 := null;
	          l_workitem_comment_code5 := null;
               END IF;
               IF (l_audit_log_val = 'MINIMAL')
               THEN
       		   l_event_key := null;
               END IF;
               IF ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
               THEN
                   l_event_key := 'PURGE_WR_ITEM';
               END IF;


               IF ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
                  ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL)
                   OR (l_action_key = 'WORKITEM_PURGE')) )                                                                                  THEN
               BEGIN
               FORALL i in 1..l_task_det_rec.l_work_item_id_list.count SAVE EXCEPTIONS
               insert into IEU_UWQM_AUDIT_LOG
	       (AUDIT_LOG_ID,
       		OBJECT_VERSION_NUMBER,
       		CREATED_BY,
       		CREATION_DATE,
       		LAST_UPDATED_BY,
       		LAST_UPDATE_DATE,
       		LAST_UPDATE_LOGIN,
       		ACTION_KEY,
       		EVENT_KEY,
		MODULE,
       		WS_CODE,
       		APPLICATION_ID,
       		WORKITEM_PK_ID,
       		WORKITEM_OBJ_CODE,
       		WORK_ITEM_NUMBER,
       		WORKITEM_STATUS_ID_PREV,
       		WORKITEM_STATUS_ID_CURR,
       		OWNER_ID_PREV,
       		OWNER_ID_CURR,
       		OWNER_TYPE_PREV,
       		OWNER_TYPE_CURR,
       		ASSIGNEE_ID_PREV,
       		ASSIGNEE_ID_CURR,
       		ASSIGNEE_TYPE_PREV,
       		ASSIGNEE_TYPE_CURR,
       		SOURCE_OBJECT_ID_PREV,
       		SOURCE_OBJECT_ID_CURR,
       		SOURCE_OBJECT_TYPE_CODE_PREV,
       		SOURCE_OBJECT_TYPE_CODE_CURR,
       		PARENT_WORKITEM_STATUS_ID_PREV,
	        PARENT_WORKITEM_STATUS_ID_CURR,
       		PARENT_DIST_STATUS_ID_PREV,
       		PARENT_DIST_STATUS_ID_CURR,
       		WORKITEM_DIST_STATUS_ID_PREV,
       		WORKITEM_DIST_STATUS_ID_CURR,
       		PRIORITY_ID_PREV,
       		PRIORITY_ID_CURR,
       		DUE_DATE_PREV,
       		DUE_DATE_CURR,
       		RESCHEDULE_TIME_PREV,
       		RESCHEDULE_TIME_CURR,
       		IEU_COMMENT_CODE1,
       		IEU_COMMENT_CODE2,
       		IEU_COMMENT_CODE3,
       		IEU_COMMENT_CODE4,
       		IEU_COMMENT_CODE5,
       		WORKITEM_COMMENT_CODE1,
       		WORKITEM_COMMENT_CODE2,
       		WORKITEM_COMMENT_CODE3,
       		WORKITEM_COMMENT_CODE4,
       		WORKITEM_COMMENT_CODE5,
	        RETURN_STATUS,
       		ERROR_CODE,
       		LOGGING_LEVEL)
		values
       		(
       		IEU_UWQM_AUDIT_LOG_S1.NEXTVAL,
                1,
                FND_GLOBAL.USER_ID,
       		SYSDATE,
       		FND_GLOBAL.USER_ID,
       		SYSDATE,
       		FND_GLOBAL.LOGIN_ID,
                l_action_key,
                l_event_key,
                l_module,
                P_WS_CODE,
                690,
                l_task_det_rec.l_workitem_pk_id_list(i),
                l_task_det_rec.l_workitem_obj_code_list(i),
                l_task_det_rec.l_work_item_number_list(i),
                l_task_det_rec.l_status_id_list(i),
                l_task_det_rec.l_status_id_list(i),
                l_task_det_rec.l_owner_id_list(i),
                l_task_det_rec.l_owner_id_list(i),
                l_task_det_rec.l_owner_type_list(i),
                l_task_det_rec.l_owner_type_list(i),
                l_task_det_rec.l_assignee_id_list(i),
                l_task_det_rec.l_assignee_id_list(i),
                l_task_det_rec.l_assignee_type_list(i),
                l_task_det_rec.l_assignee_type_list(i),
                l_task_det_rec.l_source_object_id_list(i),
                l_task_det_rec.l_source_object_id_list(i),
       	        l_task_det_rec.l_source_object_type_code_list(i),
       		l_task_det_rec.l_source_object_type_code_list(i),
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		l_task_det_rec.l_distribution_status_id_list(i),
       		l_task_det_rec.l_distribution_status_id_list(i),
       		l_task_det_rec.l_priority_id_list(i),
      		l_task_det_rec.l_priority_id_list(i),
       		l_task_det_rec.l_due_date_list(i),
       		l_task_det_rec.l_due_date_list(i),
       		l_task_det_rec.l_reschedule_time_list(i),
       		l_task_det_rec.l_reschedule_time_list(i),
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		l_workitem_comment_code1,
       		l_workitem_comment_code2,
       		l_workitem_comment_code3,
       		l_workitem_comment_code4,
       		l_workitem_comment_code5,
       		fnd_api.g_ret_sts_success,
       		NULL,
       		FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG'));
                EXCEPTION
		  WHEN dml_errors THEN
                  null;
                END;

             END IF;
                        */ -- bug #4638378


        --** Open parents work items existing for this work item **--
              OPEN c1_open_parent_assct_Wi(l_ws_id,l_parent_ws_id);
              FETCH c1_open_parent_assct_Wi BULK COLLECT INTO
		l_task_det_rec.l_workitem_pk_id_list,
		l_task_det_rec.l_workitem_obj_code_list,
		l_task_det_rec.l_source_object_id_list,
		l_task_det_rec.l_source_object_type_code_list;
             CLOSE c1_open_parent_assct_Wi;
             FOR i IN 1..l_task_det_rec.l_workitem_pk_id_list.COUNT LOOP
       		 FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_NOT_PURGED_PARENT_WI');
		 FND_MESSAGE.SET_TOKEN('WI_PK_ID', l_task_det_rec.l_workitem_pk_id_list(i));
		 FND_MESSAGE.SET_TOKEN('PARENT_WI_PK_ID', l_task_det_rec.l_source_object_id_list(i));
		 FND_MESSAGE.SET_TOKEN('PARENT_WI_OBJ_CODE',l_task_det_rec.l_source_object_type_code_list(i));
		 l_message := FND_MESSAGE.GET;
 		 FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
             END LOOP;

            --** delete all associate work items where parent work items are closed **--
              delete
	      from ieu_uwqm_items child
	      where  ws_id = l_ws_id
	      and    status_id in (3, 4)
	      and    to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr')
	      and    not exists
 				(select 1
 				from ieu_uwqm_items parent
				where ws_id = l_parent_ws_id
 				and status_id in (0,5)
                                and parent.workitem_pk_id = child.source_object_id
			        and parent.workitem_obj_code = child.source_object_type_code);





	END IF; /* l_wi_exists <> 0 */

    END IF; /*** l_ws_type = 'ASSOCIATION'***/

    IF (l_ws_type = 'PRIMARY')
    THEN

      BEGIN
         l_child_ws_id := null;
	 SELECT WS_A.WS_ASSOCIATION_PROP_ID,WS_A.WS_ID
	 INTO   l_assct_ws_id,l_child_ws_id
	 FROM   IEU_UWQM_WS_ASSCT_PROPS WS_A
	 WHERE  parent_ws_id = l_ws_id;

      EXCEPTION
	 WHEN OTHERS THEN
	      l_assct_ws_id := null;
	      l_child_ws_id := null;
     END;
     --** Open child Work Item does not exist. Hence the parent work item should be purged. **--
	--** This code has been commented as audit logs are not required **--
     IF l_assct_ws_id is not null THEN
/*   OPEN c2_purge_primary_wi(l_ws_id,l_child_ws_id);
     FETCH c2_purge_primary_wi BULK COLLECT INTO
		l_task_det_rec.l_workitem_pk_id_list,
		l_task_det_rec.l_workitem_obj_code_list,
		l_task_det_rec.l_source_object_id_list,
		l_task_det_rec.l_source_object_type_code_list,
		l_task_det_rec.l_owner_id_list ,
                l_task_det_rec.l_owner_type_list,
                l_task_det_rec.l_assignee_id_list,
                l_task_det_rec.l_assignee_type_list,
                l_task_det_rec.l_status_id_list ,
                l_task_det_rec.l_priority_id_list ,
                l_task_det_rec.l_due_date_list ,
                l_task_det_rec.l_reschedule_time_list,
                l_task_det_rec.l_distribution_status_id_list,
                l_task_det_rec.l_work_item_number_list,
                l_task_det_rec.l_work_item_id_list;
     CLOSE c2_purge_primary_wi; */

/*     FOR i IN 1..l_task_det_rec.l_workitem_pk_id_list.COUNT LOOP

         FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_PURGED_WI_DETAILS');
         FND_MESSAGE.SET_TOKEN('WI_PK_ID', l_task_det_rec.l_workitem_pk_id_list(i));
	    l_message := FND_MESSAGE.GET;
         FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

     END LOOP;*/

/*       --** Audit logging starts here ** --
               l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
               l_action_key := 'WORKITEM_PURGE';
  	       l_event_key := 'PURGE_WR_ITEM';
 	       l_module := 'IEU_WR_PUB.PURGE_WR_ITEM';
               IF (l_audit_log_val = 'DETAILED')
               THEN
                  l_workitem_comment_code1 := 'WORKITEM_PURGE';
                  l_workitem_comment_code2 := null;
                  l_workitem_comment_code3 := null;
                  l_workitem_comment_code4 := null;
                  l_workitem_comment_code5 := null;
               ELSE
	          l_workitem_comment_code1 := null;
	          l_workitem_comment_code2 := null;
	          l_workitem_comment_code3 := null;
	          l_workitem_comment_code4 := null;
	          l_workitem_comment_code5 := null;
               END IF;
               IF (l_audit_log_val = 'MINIMAL')
               THEN
       		   l_event_key := null;
               END IF;
               IF ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
               THEN
                   l_event_key := 'PURGE_WR_ITEM';
               END IF;
               IF ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
                  ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL)
                   OR (l_action_key = 'WORKITEM_PURGE')) )                                                                                  THEN
               BEGIN
               FORALL i in 1..l_task_det_rec.l_work_item_id_list.count SAVE EXCEPTIONS
               insert into IEU_UWQM_AUDIT_LOG
	       (AUDIT_LOG_ID,
       		OBJECT_VERSION_NUMBER,
       		CREATED_BY,
       		CREATION_DATE,
       		LAST_UPDATED_BY,
       		LAST_UPDATE_DATE,
       		LAST_UPDATE_LOGIN,
       		ACTION_KEY,
       		EVENT_KEY,
		MODULE,
       		WS_CODE,
       		APPLICATION_ID,
       		WORKITEM_PK_ID,
       		WORKITEM_OBJ_CODE,
       		WORK_ITEM_NUMBER,
       		WORKITEM_STATUS_ID_PREV,
       		WORKITEM_STATUS_ID_CURR,
       		OWNER_ID_PREV,
       		OWNER_ID_CURR,
       		OWNER_TYPE_PREV,
       		OWNER_TYPE_CURR,
       		ASSIGNEE_ID_PREV,
       		ASSIGNEE_ID_CURR,
       		ASSIGNEE_TYPE_PREV,
       		ASSIGNEE_TYPE_CURR,
       		SOURCE_OBJECT_ID_PREV,
       		SOURCE_OBJECT_ID_CURR,
       		SOURCE_OBJECT_TYPE_CODE_PREV,
       		SOURCE_OBJECT_TYPE_CODE_CURR,
       		PARENT_WORKITEM_STATUS_ID_PREV,
	        PARENT_WORKITEM_STATUS_ID_CURR,
       		PARENT_DIST_STATUS_ID_PREV,
       		PARENT_DIST_STATUS_ID_CURR,
       		WORKITEM_DIST_STATUS_ID_PREV,
       		WORKITEM_DIST_STATUS_ID_CURR,
       		PRIORITY_ID_PREV,
       		PRIORITY_ID_CURR,
       		DUE_DATE_PREV,
       		DUE_DATE_CURR,
       		RESCHEDULE_TIME_PREV,
       		RESCHEDULE_TIME_CURR,
       		IEU_COMMENT_CODE1,
       		IEU_COMMENT_CODE2,
       		IEU_COMMENT_CODE3,
       		IEU_COMMENT_CODE4,
       		IEU_COMMENT_CODE5,
       		WORKITEM_COMMENT_CODE1,
       		WORKITEM_COMMENT_CODE2,
       		WORKITEM_COMMENT_CODE3,
       		WORKITEM_COMMENT_CODE4,
       		WORKITEM_COMMENT_CODE5,
	        RETURN_STATUS,
       		ERROR_CODE,
       		LOGGING_LEVEL)
		values
       		(
       		IEU_UWQM_AUDIT_LOG_S1.NEXTVAL,
                1,
                FND_GLOBAL.USER_ID,
       		SYSDATE,
       		FND_GLOBAL.USER_ID,
       		SYSDATE,
       		FND_GLOBAL.LOGIN_ID,
                l_action_key,
                l_event_key,
                l_module,
                P_WS_CODE,
                690,
                l_task_det_rec.l_workitem_pk_id_list(i),
                l_task_det_rec.l_workitem_obj_code_list(i),
                l_task_det_rec.l_work_item_number_list(i),
                l_task_det_rec.l_status_id_list(i),
                l_task_det_rec.l_status_id_list(i),
                l_task_det_rec.l_owner_id_list(i),
                l_task_det_rec.l_owner_id_list(i),
                l_task_det_rec.l_owner_type_list(i),
                l_task_det_rec.l_owner_type_list(i),
                l_task_det_rec.l_assignee_id_list(i),
                l_task_det_rec.l_assignee_id_list(i),
                l_task_det_rec.l_assignee_type_list(i),
                l_task_det_rec.l_assignee_type_list(i),
                l_task_det_rec.l_source_object_id_list(i),
                l_task_det_rec.l_source_object_id_list(i),
       	        l_task_det_rec.l_source_object_type_code_list(i),
       		l_task_det_rec.l_source_object_type_code_list(i),
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		l_task_det_rec.l_distribution_status_id_list(i),
       		l_task_det_rec.l_distribution_status_id_list(i),
       		l_task_det_rec.l_priority_id_list(i),
      		l_task_det_rec.l_priority_id_list(i),
       		l_task_det_rec.l_due_date_list(i),
       		l_task_det_rec.l_due_date_list(i),
       		l_task_det_rec.l_reschedule_time_list(i),
       		l_task_det_rec.l_reschedule_time_list(i),
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		l_workitem_comment_code1,
       		l_workitem_comment_code2,
       		l_workitem_comment_code3,
       		l_workitem_comment_code4,
       		l_workitem_comment_code5,
       		fnd_api.g_ret_sts_success,
       		NULL,
       		FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG'));
                EXCEPTION
		  WHEN dml_errors THEN
                  null;
                END;

             END IF; */

     --** Open child Work Item exist. Hence the parent work item should not be purged. **--
     OPEN c2_open_child_primary_wi(l_ws_id,l_child_ws_id);
     FETCH c2_open_child_primary_wi BULK COLLECT INTO
		l_task_det_rec.l_workitem_pk_id_list,
		l_task_det_rec.l_workitem_obj_code_list,
		l_task_det_rec.l_source_object_id_list,
		l_task_det_rec.l_source_object_type_code_list;
     close c2_open_child_primary_wi;


     FOR i IN 1..l_task_det_rec.l_workitem_pk_id_list.COUNT LOOP
	    FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_NOT_PURGED_CHILD_WI');
  	    FND_MESSAGE.SET_TOKEN('WI_PK_ID', l_task_det_rec.l_workitem_pk_id_list(i));
  	    FND_MESSAGE.SET_TOKEN('CHILD_WI_PK_ID', l_task_det_rec.l_source_object_id_list(i));
  	    FND_MESSAGE.SET_TOKEN('CHILD_WI_OBJ_CODE', l_task_det_rec.l_source_object_type_Code_list(i));
	    l_message := FND_MESSAGE.GET;
	    FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
     END LOOP;
     END IF; -- l_assct_ws_id

     IF (l_assct_ws_id is not null)
     THEN
    --** Open child Work Item does not exist. Hence the parent work item should be purged. **--
     delete
     from ieu_uwqm_items parent
     where  ws_id = l_ws_id
     and    status_id in (3, 4)
     and    to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr')
     and    not exists
                   (select 1
                    from ieu_uwqm_items child
                    where ws_id = l_child_ws_id
		    and status_id in (0,5)
		    and child.source_object_id = parent.workitem_pk_id
                    and child.source_object_type_code = parent.workitem_obj_code );



    ELSE

/*        OPEN c3_purge_wi(l_ws_id);
        FETCH c3_purge_wi BULK COLLECT INTO
		l_task_det_rec.l_workitem_pk_id_list,
		l_task_det_rec.l_workitem_obj_code_list,
		l_task_det_rec.l_source_object_id_list,
		l_task_det_rec.l_source_object_type_code_list,
		l_task_det_rec.l_owner_id_list ,
                l_task_det_rec.l_owner_type_list,
                l_task_det_rec.l_assignee_id_list,
                l_task_det_rec.l_assignee_type_list,
                l_task_det_rec.l_status_id_list ,
                l_task_det_rec.l_priority_id_list ,
                l_task_det_rec.l_due_date_list ,
                l_task_det_rec.l_reschedule_time_list,
                l_task_det_rec.l_distribution_status_id_list,
                l_task_det_rec.l_work_item_number_list,
                l_task_det_rec.l_work_item_id_list;
        CLOSE c3_purge_wi; */ -- bug #4438378


/*        FOR i in 1..l_task_det_rec.l_workitem_pk_id_list.COUNT LOOP

            FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_PURGED_WI_DETAILS');
  	    FND_MESSAGE.SET_TOKEN('WI_PK_ID', l_task_det_rec.l_workitem_pk_id_list(i));
	    l_message := FND_MESSAGE.GET;
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
        END LOOP;*/

	/*	 --** Audit logging starts here ** --
               l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
               l_action_key := 'WORKITEM_PURGE';
  	       l_event_key := 'PURGE_WR_ITEM';
 	       l_module := 'IEU_WR_PUB.PURGE_WR_ITEM';
               IF (l_audit_log_val = 'DETAILED')
               THEN
                  l_workitem_comment_code1 := 'WORKITEM_PURGE';
                  l_workitem_comment_code2 := null;
                  l_workitem_comment_code3 := null;
                  l_workitem_comment_code4 := null;
                  l_workitem_comment_code5 := null;
               ELSE
	          l_workitem_comment_code1 := null;
	          l_workitem_comment_code2 := null;
	          l_workitem_comment_code3 := null;
	          l_workitem_comment_code4 := null;
	          l_workitem_comment_code5 := null;
               END IF;
               IF (l_audit_log_val = 'MINIMAL')
               THEN
       		   l_event_key := null;
               END IF;
               IF ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
               THEN
                   l_event_key := 'PURGE_WR_ITEM';
               END IF;

               IF ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
                  ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL)
                   OR (l_action_key = 'WORKITEM_PURGE')) )                                                                                  THEN
               BEGIN
               FORALL i in 1..l_task_det_rec.l_work_item_id_list.count SAVE EXCEPTIONS
               insert into IEU_UWQM_AUDIT_LOG
	       (AUDIT_LOG_ID,
       		OBJECT_VERSION_NUMBER,
       		CREATED_BY,
       		CREATION_DATE,
       		LAST_UPDATED_BY,
       		LAST_UPDATE_DATE,
       		LAST_UPDATE_LOGIN,
       		ACTION_KEY,
       		EVENT_KEY,
		MODULE,
       		WS_CODE,
       		APPLICATION_ID,
       		WORKITEM_PK_ID,
       		WORKITEM_OBJ_CODE,
       		WORK_ITEM_NUMBER,
       		WORKITEM_STATUS_ID_PREV,
       		WORKITEM_STATUS_ID_CURR,
       		OWNER_ID_PREV,
       		OWNER_ID_CURR,
       		OWNER_TYPE_PREV,
       		OWNER_TYPE_CURR,
       		ASSIGNEE_ID_PREV,
       		ASSIGNEE_ID_CURR,
       		ASSIGNEE_TYPE_PREV,
       		ASSIGNEE_TYPE_CURR,
       		SOURCE_OBJECT_ID_PREV,
       		SOURCE_OBJECT_ID_CURR,
       		SOURCE_OBJECT_TYPE_CODE_PREV,
       		SOURCE_OBJECT_TYPE_CODE_CURR,
       		PARENT_WORKITEM_STATUS_ID_PREV,
	        PARENT_WORKITEM_STATUS_ID_CURR,
       		PARENT_DIST_STATUS_ID_PREV,
       		PARENT_DIST_STATUS_ID_CURR,
       		WORKITEM_DIST_STATUS_ID_PREV,
       		WORKITEM_DIST_STATUS_ID_CURR,
       		PRIORITY_ID_PREV,
       		PRIORITY_ID_CURR,
       		DUE_DATE_PREV,
       		DUE_DATE_CURR,
       		RESCHEDULE_TIME_PREV,
       		RESCHEDULE_TIME_CURR,
       		IEU_COMMENT_CODE1,
       		IEU_COMMENT_CODE2,
       		IEU_COMMENT_CODE3,
       		IEU_COMMENT_CODE4,
       		IEU_COMMENT_CODE5,
       		WORKITEM_COMMENT_CODE1,
       		WORKITEM_COMMENT_CODE2,
       		WORKITEM_COMMENT_CODE3,
       		WORKITEM_COMMENT_CODE4,
       		WORKITEM_COMMENT_CODE5,
	        RETURN_STATUS,
       		ERROR_CODE,
       		LOGGING_LEVEL)
		values
       		(
       		IEU_UWQM_AUDIT_LOG_S1.NEXTVAL,
                1,
                FND_GLOBAL.USER_ID,
       		SYSDATE,
       		FND_GLOBAL.USER_ID,
       		SYSDATE,
       		FND_GLOBAL.LOGIN_ID,
                l_action_key,
                l_event_key,
                l_module,
                P_WS_CODE,
                690,
                l_task_det_rec.l_workitem_pk_id_list(i),
                l_task_det_rec.l_workitem_obj_code_list(i),
                l_task_det_rec.l_work_item_number_list(i),
                l_task_det_rec.l_status_id_list(i),
                l_task_det_rec.l_status_id_list(i),
                l_task_det_rec.l_owner_id_list(i),
                l_task_det_rec.l_owner_id_list(i),
                l_task_det_rec.l_owner_type_list(i),
                l_task_det_rec.l_owner_type_list(i),
                l_task_det_rec.l_assignee_id_list(i),
                l_task_det_rec.l_assignee_id_list(i),
                l_task_det_rec.l_assignee_type_list(i),
                l_task_det_rec.l_assignee_type_list(i),
                l_task_det_rec.l_source_object_id_list(i),
                l_task_det_rec.l_source_object_id_list(i),
       	        l_task_det_rec.l_source_object_type_code_list(i),
       		l_task_det_rec.l_source_object_type_code_list(i),
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		l_task_det_rec.l_distribution_status_id_list(i),
       		l_task_det_rec.l_distribution_status_id_list(i),
       		l_task_det_rec.l_priority_id_list(i),
      		l_task_det_rec.l_priority_id_list(i),
       		l_task_det_rec.l_due_date_list(i),
       		l_task_det_rec.l_due_date_list(i),
       		l_task_det_rec.l_reschedule_time_list(i),
       		l_task_det_rec.l_reschedule_time_list(i),
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		NULL,
       		l_workitem_comment_code1,
       		l_workitem_comment_code2,
       		l_workitem_comment_code3,
       		l_workitem_comment_code4,
       		l_workitem_comment_code5,
       		fnd_api.g_ret_sts_success,
       		NULL,
       		FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG'));
                EXCEPTION
		  WHEN dml_errors THEN
                  null;
                END;

             END IF;       */



        delete from ieu_uwqm_items
        where  status_id in (3,4)
        and ws_id = l_ws_id
        and   ( to_date(trunc(last_update_date), 'dd-mm-rrrr') <=  to_date(trunc(p_last_update_date), 'dd-mm-rrrr') );

   END IF; /* l_assct_ws_id is not null */

END IF; /*** l_ws_type = 'PRIMARY' ***/
commit;

EXCEPTION
 WHEN fnd_api.g_exc_error THEN

         retcode := 2;
fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );
  errbuf :=x_msg_Data;


 WHEN OTHERS THEN
       errbuf := sqlcode||' '||sqlerrm;
	  l_message := sqlcode||' '||sqlerrm;
	  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
       retcode := 2;

END PURGE_WR_DATA;

PROCEDURE PURGE_WR_AUDIT_DATA
 (
  ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2,
  P_OBJ_CODE IN VARCHAR2 DEFAULT NULL,
  P_CREATION_DATE IN DATE DEFAULT NULL
 )
  IS

l_true NUMBER := 0;
l_message VARCHAR2(4000);

BEGIN

  FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_AUDIT_PURGE_INP_PARAMS');
  FND_MESSAGE.SET_TOKEN('OBJECT_CODE', p_obj_code);
  FND_MESSAGE.SET_TOKEN('CR_DATE', p_creation_date);
  l_message := FND_MESSAGE.GET;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  IF ( (p_creation_date IS not null) AND (p_obj_code IS not null) )
  THEN

     delete
     from ieu_uwqm_audit_log
     where workitem_pk_id in (select workitem_pk_id
                              from   ieu_uwqm_audit_log
                              where  trunc(to_date(creation_date, 'dd-mm-rrrr')) <=
                                                    trunc(to_date(p_creation_date, 'dd-mm-rrrr'))
                              and    ((workitem_status_id_curr = 3) or (workitem_status_id_curr = 4)))
                              and   workitem_obj_code = p_obj_code;
      commit;
  END IF;



EXCEPTION
  WHEN OTHERS THEN

       errbuf := sqlcode||' '||sqlerrm;
       retcode := 2;
       l_message := sqlcode || ' '||sqlerrm;
       FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

END PURGE_WR_AUDIT_DATA;

END IEU_WR_CON_PVT;


/
