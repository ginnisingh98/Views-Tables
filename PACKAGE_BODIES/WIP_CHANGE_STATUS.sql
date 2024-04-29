--------------------------------------------------------
--  DDL for Package Body WIP_CHANGE_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CHANGE_STATUS" AS
 /* $Header: wippcstb.pls 120.5.12010000.4 2010/02/05 05:38:12 hliew ship $ */


  PROCEDURE LOAD_QUEUE
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_repetitive_schedule_id NUMBER,
     P_routing_exists OUT NOCOPY NUMBER) IS

    X_user_id NUMBER := FND_GLOBAL.USER_ID;
    X_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

  BEGIN
    IF (P_repetitive_schedule_id IS NULL) THEN
      UPDATE WIP_OPERATIONS
         SET QUANTITY_IN_QUEUE =
               SCHEDULED_QUANTITY -
                  (QUANTITY_IN_QUEUE + QUANTITY_RUNNING + QUANTITY_COMPLETED),
             LAST_UPDATED_BY = X_user_id,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATE_LOGIN = X_login_id
       WHERE WIP_ENTITY_ID = P_wip_entity_id
         AND ORGANIZATION_ID = P_organization_id
         AND REPETITIVE_SCHEDULE_ID IS NULL
         AND PREVIOUS_OPERATION_SEQ_NUM IS NULL;
    ELSE
      UPDATE WIP_OPERATIONS
         SET QUANTITY_IN_QUEUE =
               SCHEDULED_QUANTITY -
                  (QUANTITY_IN_QUEUE + QUANTITY_RUNNING + QUANTITY_COMPLETED),
             LAST_UPDATED_BY = X_user_id,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATE_LOGIN = X_login_id
       WHERE WIP_ENTITY_ID = P_wip_entity_id
         AND ORGANIZATION_ID = P_organization_id
         AND REPETITIVE_SCHEDULE_ID  = P_repetitive_schedule_id
         AND PREVIOUS_OPERATION_SEQ_NUM IS NULL;
      END IF;
    IF SQL%NOTFOUND THEN
      P_routing_exists := WIP_CONSTANTS.NO;
    ELSE
      P_routing_exists := WIP_CONSTANTS.YES;
      END IF;
  END LOAD_QUEUE;


  PROCEDURE INSERT_PERIOD_BALANCES
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_repetitive_schedule_id NUMBER,
     P_line_id NUMBER,
     P_class_code VARCHAR2,
     P_release_date DATE DEFAULT SYSDATE) IS

    X_user_id NUMBER := FND_GLOBAL.USER_ID;
    X_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

  BEGIN
    IF P_repetitive_schedule_id IS NULL THEN
      INSERT INTO WIP_PERIOD_BALANCES
        (ACCT_PERIOD_ID, WIP_ENTITY_ID,
	 LAST_UPDATE_DATE, LAST_UPDATED_BY,
	 CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
	 ORGANIZATION_ID, CLASS_TYPE,
	 TL_RESOURCE_IN, TL_OVERHEAD_IN,
         TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
         PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
 	 PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
 	 TL_MATERIAL_OUT, TL_RESOURCE_OUT,
         TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
 	 PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
 	 PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
         PL_OUTSIDE_PROCESSING_OUT, PL_MATERIAL_OVERHEAD_VAR,
         PL_MATERIAL_VAR, PL_OUTSIDE_PROCESSING_VAR,
         PL_OVERHEAD_VAR, PL_RESOURCE_VAR,
 	 TL_MATERIAL_VAR, TL_OUTSIDE_PROCESSING_VAR,
         TL_OVERHEAD_VAR, TL_RESOURCE_VAR,
         TL_MATERIAL_OVERHEAD_OUT, TL_MATERIAL_OVERHEAD_VAR)
        SELECT OAP.ACCT_PERIOD_ID, P_wip_entity_id,
               SYSDATE, X_user_id,
               SYSDATE, X_user_id, X_login_id,
               P_organization_id, WC.CLASS_TYPE,
               0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0
          FROM ORG_ACCT_PERIODS OAP,
               WIP_ACCOUNTING_CLASSES WC
         WHERE WC.CLASS_CODE = P_class_code
           AND WC.ORGANIZATION_ID = P_organization_id
           AND OAP.ORGANIZATION_ID = P_organization_id
           AND OAP.SCHEDULE_CLOSE_DATE >=
                 TRUNC(INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(P_release_date,
                                                               P_organization_id))
           AND OAP.PERIOD_CLOSE_DATE IS NULL
	   AND NOT EXISTS
		(SELECT 'balance record already there'
		   FROM WIP_PERIOD_BALANCES WPB
		  WHERE WPB.WIP_ENTITY_ID = P_wip_entity_id
	            AND WPB.ACCT_PERIOD_ID = OAP.ACCT_PERIOD_ID
		    AND WPB.ORGANIZATION_ID = OAP.ORGANIZATION_ID);
    ELSE
      INSERT INTO WIP_PERIOD_BALANCES
        (ACCT_PERIOD_ID, WIP_ENTITY_ID, REPETITIVE_SCHEDULE_ID,
	 LAST_UPDATE_DATE, LAST_UPDATED_BY,
	 CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
	 ORGANIZATION_ID, CLASS_TYPE,
	 TL_RESOURCE_IN, TL_OVERHEAD_IN,
         TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
         PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
 	 PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
 	 TL_MATERIAL_OUT, TL_RESOURCE_OUT,
         TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
 	 PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
 	 PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
         PL_OUTSIDE_PROCESSING_OUT, PL_MATERIAL_OVERHEAD_VAR,
         PL_MATERIAL_VAR, PL_OUTSIDE_PROCESSING_VAR,
         PL_OVERHEAD_VAR, PL_RESOURCE_VAR,
 	 TL_MATERIAL_VAR, TL_OUTSIDE_PROCESSING_VAR,
         TL_OVERHEAD_VAR, TL_RESOURCE_VAR,
         TL_MATERIAL_OVERHEAD_OUT, TL_MATERIAL_OVERHEAD_VAR)
        SELECT OAP.ACCT_PERIOD_ID, P_wip_entity_id, P_repetitive_schedule_id,
               SYSDATE, X_user_id,
               SYSDATE, X_user_id, X_login_id,
               P_organization_id, WC.CLASS_TYPE,
               0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0
          FROM ORG_ACCT_PERIODS OAP,
               WIP_ACCOUNTING_CLASSES WC
         WHERE WC.CLASS_CODE = P_class_code
           AND WC.ORGANIZATION_ID = P_organization_id
           AND OAP.ORGANIZATION_ID = P_organization_id
           AND OAP.PERIOD_CLOSE_DATE IS NULL
           AND OAP.SCHEDULE_CLOSE_DATE >=
	       (SELECT NVL(MIN(
                   TRUNC(INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(DATE_RELEASED,
                                                                 P_organization_id))),
                   TRUNC(INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(P_RELEASE_DATE,
                                                                 P_organization_id)))
	          FROM WIP_REPETITIVE_SCHEDULES
	         WHERE WIP_ENTITY_ID = P_wip_entity_id
                   AND ORGANIZATION_ID = P_organization_id
	           AND LINE_ID = P_line_id
   	           AND STATUS_TYPE IN (WIP_CONSTANTS.RELEASED,
                                       WIP_CONSTANTS.COMP_CHRG,
                                       WIP_CONSTANTS.HOLD));
        END IF;

/* It is possible that no records can be inserted in discrete
   even if there is an open accounting period.  This can happen when
   reexploding jobs of Status failed load that were defined as released.
   It can also happen if you unclose a job that was released in the current
   accounting period.
   The explicit rollback is needed by the Define Discrete form to roll
   back other commit logic that we dont want to be executed again if
   the user tries to recommit in the same session.
 */

    IF SQL%NOTFOUND THEN
	IF P_repetitive_schedule_id IS NOT NULL THEN
             FND_MESSAGE.SET_NAME('WIP', 'WIP_NO_ACCT_PERIOD');
             ROLLBACK;
             APP_EXCEPTION.RAISE_EXCEPTION;

	ELSE
	    DECLARE
		CURSOR C1 IS
		    SELECT 'x'
		    FROM   ORG_ACCT_PERIODS
		    WHERE  ORGANIZATION_ID = P_Organization_Id
		    AND    TRUNC(INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                              P_RELEASE_DATE,P_Organization_Id))
                       BETWEEN PERIOD_START_DATE AND SCHEDULE_CLOSE_DATE
		    AND    PERIOD_CLOSE_DATE IS NULL;
		dummy VARCHAR2(2);
	    BEGIN
		OPEN C1;
		FETCH C1 INTO dummy;
		IF C1%NOTFOUND THEN
		    CLOSE C1;
             FND_MESSAGE.SET_NAME('WIP', 'WIP_NO_ACCT_PERIOD');
             ROLLBACK;
             APP_EXCEPTION.RAISE_EXCEPTION;

		END IF;
		CLOSE C1;
	    END;
        END IF;
    END IF;

  END INSERT_PERIOD_BALANCES;


  PROCEDURE CHECK_REPETITIVE_ROUTING
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_repetitive_schedule_id NUMBER,
     P_line_id NUMBER) IS

    X_dummy VARCHAR2(30) := 'different routing';
    X_diff_routing BOOLEAN := FALSE;

    CURSOR check_routing IS
    SELECT 'identical routing'
      FROM wip_operations wo1,
           wip_operations wo2,
           wip_repetitive_schedules wrs
     WHERE wrs.organization_id = P_organization_id
       AND wo1.organization_id = P_organization_id
       AND wo2.organization_id = P_organization_id
       AND wrs.wip_entity_id = P_wip_entity_id
       AND wo1.wip_entity_id = P_wip_entity_id
       AND wo2.wip_entity_id = P_wip_entity_id
       AND wo1.repetitive_schedule_id = P_repetitive_schedule_id
       AND wrs.repetitive_schedule_id = wo2.repetitive_schedule_id
       AND wrs.line_id = P_line_id
       AND wrs.status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG,
                               WIP_CONSTANTS.HOLD)
       AND wo1.operation_seq_num = wo2.operation_seq_num
       AND wo1.department_id = wo2.department_id
       AND wo1.count_point_type = wo2.count_point_type
       AND wo1.backflush_flag = wo2.backflush_flag
    HAVING count(*) =
       (SELECT count(*)
          FROM wip_operations O,
               wip_repetitive_schedules S
         WHERE O.organization_id = P_organization_id
           AND S.organization_id = P_organization_id
           AND O.wip_entity_id = P_wip_entity_id
           AND S.wip_entity_id = P_wip_entity_id
           AND S.line_id = P_line_id
           AND S.status_type in (WIP_CONSTANTS.RELEASED,
                                 WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD)
           AND O.repetitive_schedule_id = P_repetitive_schedule_id)
       AND count(*) =
       (SELECT count(*)
          FROM wip_operations O,
               wip_repetitive_schedules S
         WHERE O.organization_id = P_organization_id
           AND S.organization_id = P_organization_id
           AND O.wip_entity_id = P_wip_entity_id
           AND S.wip_entity_id = P_wip_entity_id
           AND S.line_id = P_line_id
           AND S.status_type in (WIP_CONSTANTS.RELEASED,
                                 WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD)
           AND O.repetitive_schedule_id = S.repetitive_schedule_id);

  BEGIN
    LOCK TABLE WIP_VALID_INTRAOPERATION_STEPS IN EXCLUSIVE MODE;
    OPEN check_routing;
    FETCH check_routing INTO X_dummy;
    X_diff_routing := check_routing%NOTFOUND;
    CLOSE check_routing;
    IF X_diff_routing THEN
      FND_MESSAGE.SET_NAME('WIP', 'WIP_SAME_ROUTING');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END CHECK_REPETITIVE_ROUTING;


  PROCEDURE RELEASE
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_repetitive_schedule_id NUMBER,
     P_line_id NUMBER,
     P_class_code VARCHAR2,
     P_old_status_type NUMBER,
     P_new_status_type NUMBER,
     P_routing_exists OUT NOCOPY NUMBER,
     P_release_date DATE DEFAULT SYSDATE) IS /* fix for bug 2424987 */

     X_tot_op_qty number; /* For Bug 5859224 */

  BEGIN
    /* Bug 4955616. Removed WIP_CONSTANTS.CANCELLED from new status list and old status list*/
    IF (P_new_status_type IN (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG,
                              WIP_CONSTANTS.HOLD) AND
        P_old_status_type NOT IN (WIP_CONSTANTS.RELEASED,
                                  WIP_CONSTANTS.COMP_CHRG,
                                  WIP_CONSTANTS.HOLD)) THEN

      INSERT_PERIOD_BALANCES (P_wip_entity_id, P_organization_id,
                              P_repetitive_schedule_id, P_line_id,
                              P_class_code, P_Release_Date); /* fix for bug 2424987 */

      /*
         Fix bug#2034660. Commented following call to wip_osp.release_validation.
         Now wilmlx.ppc would be calling this procedure after processing rows in wip_job_dtls_interface



      WIP_OSP.RELEASE_VALIDATION(P_Wip_Entity_Id,
                              P_Organization_Id,
                              P_Repetitive_Schedule_Id);

       */

	/* For Bug 5859224: load_queue API would be called only if the sum of quantity_in_queue,quantity_running
	   and quantity_completed of first operation is zero */
       BEGIN
	SELECT  (nvl(QUANTITY_IN_QUEUE,0) + nvl(QUANTITY_RUNNING,0) + nvl(QUANTITY_COMPLETED,0))
	 INTO x_tot_op_qty FROM WIP_OPERATIONS
	 WHERE WIP_ENTITY_ID = P_wip_entity_id
	 AND ORGANIZATION_ID = P_organization_id
	 AND nvl(REPETITIVE_SCHEDULE_ID, 0) = nvl(p_repetitive_schedule_id, 0) --Bug 8670946
         AND ROWNUM = 1 --Bug 6052835: EAM Work orders can have multiple start (independant) operations
	 AND PREVIOUS_OPERATION_SEQ_NUM IS NULL
   for update nowait; /*Fix Bug 8977276 (FP 8946106)*/

   /*For Bug 7511261:
 	      Previously, when QUANTITY_IN_QUEUE, QUANTITY_RUNNING, QUANTITY_COMPLETED is not 0, the P_routing_exists
 	      flag was not being set properly and is equal to NULL and resulted into the issue in bug 7304606.
 	      If the sql SELECT  (nvl(QUANTITY_IN_QUEUE,0) + nvl(QUANTITY_RUNNING,0) + nvl(QUANTITY_COMPLETED,0))
 	            INTO x_tot_op_qty FROM WIP_OPERATIONS does not throw exception it implies that there is a routing exists
 	      in WIP_OPERATIONS and so the P_routing_exists flag should be 1(WIP_CONSTANTS.YES). If it throws exception,
 	      LOAD_QUEUE will handle the P_routing_exists flag
 	    */
 	    P_routing_exists := WIP_CONSTANTS.YES;


       EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		P_routing_exists := WIP_CONSTANTS.NO;
       END;



	 IF (x_tot_op_qty = 0 AND P_routing_exists = WIP_CONSTANTS.YES)then
	  LOAD_QUEUE (P_wip_entity_id, P_organization_id,
                  P_repetitive_schedule_id, P_routing_exists);
	END IF;

      IF P_repetitive_schedule_id IS NOT NULL THEN
        IF (P_new_status_type IN (WIP_CONSTANTS.RELEASED,
                                  WIP_CONSTANTS.COMP_CHRG,
                                  WIP_CONSTANTS.HOLD) AND
            P_old_status_type NOT IN (WIP_CONSTANTS.RELEASED,
                                      WIP_CONSTANTS.COMP_CHRG,
                                      WIP_CONSTANTS.HOLD)) THEN
          CHECK_REPETITIVE_ROUTING (P_wip_entity_id, P_organization_id,
                                    P_repetitive_schedule_id, P_line_id);
        END IF;
      END IF;
    END IF;

    /*Fix Bug 8977276 (FP 8946106)*/
    EXCEPTION
          WHEN wip_constants.records_locked THEN
          fnd_message.set_name('WIP', 'WIP_LOCKED_ROW_ALREADY_LOCKED');
    FND_MESSAGE.raise_error;

  END RELEASE;


  PROCEDURE PUT_JOB_ON_HOLD
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER) IS

    CURSOR disc_info IS
    SELECT STATUS_TYPE,
           CLASS_CODE
      FROM WIP_DISCRETE_JOBS
     WHERE WIP_ENTITY_ID = P_wip_entity_id
       AND ORGANIZATION_ID = P_organization_id
       AND STATUS_TYPE IN (WIP_CONSTANTS.UNRELEASED, WIP_CONSTANTS.RELEASED,
                           WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD,
                           WIP_CONSTANTS.PEND_SCHED);

    X_status_type NUMBER;
    X_class_code VARCHAR2(10) := '';
    X_valid_job BOOLEAN;
    X_routing_exists NUMBER;
    X_user_id NUMBER := FND_GLOBAL.USER_ID;
    X_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

  BEGIN
    OPEN disc_info;
    FETCH disc_info INTO X_status_type, X_class_code;
    X_valid_job := disc_info%FOUND;
    CLOSE disc_info;

    IF NOT X_valid_job THEN
      FND_MESSAGE.SET_NAME('WIP', 'WIP_QA_ACTION_NO_HOLD');
      APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    RELEASE (P_wip_entity_id, P_organization_id, '', '',
             X_class_code, X_status_type, WIP_CONSTANTS.HOLD,
             X_routing_exists, SYSDATE); /* fix for bug 2424987 */

    /* Fix for Bug#2034660 .Calling wip_osp.release_validation since release is not calling this procedure */

    if   x_status_type NOT IN    (WIP_CONSTANTS.RELEASED,
                                  WIP_CONSTANTS.COMP_CHRG,
                                  WIP_CONSTANTS.HOLD,
                                  WIP_CONSTANTS.CANCELLED) THEN
        wip_osp.release_validation ( P_wip_entity_id, P_organization_id, '') ;

    end if ;

    UPDATE WIP_DISCRETE_JOBS
       SET STATUS_TYPE = WIP_CONSTANTS.HOLD,
           DATE_RELEASED = NVL(DATE_RELEASED, SYSDATE),
           LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = X_user_id,
           LAST_UPDATE_LOGIN = X_login_id
     WHERE WIP_ENTITY_ID = P_wip_entity_id
       AND ORGANIZATION_ID = P_organization_id;
  END PUT_JOB_ON_HOLD;


  PROCEDURE PUT_LINE_ON_HOLD
    (P_wip_entity_id NUMBER,
     P_line_id NUMBER,
     P_organization_id NUMBER) IS

    X_valid_schedule BOOLEAN := TRUE;
    X_user_id NUMBER := FND_GLOBAL.USER_ID;
    X_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

  BEGIN
    UPDATE WIP_REPETITIVE_SCHEDULES
       SET STATUS_TYPE = WIP_CONSTANTS.HOLD,
           LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = X_user_id,
           LAST_UPDATE_LOGIN = X_login_id
     WHERE LINE_ID = P_line_id
       AND WIP_ENTITY_ID = P_wip_entity_id
       AND ORGANIZATION_ID = P_organization_id
       AND STATUS_TYPE IN (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG,
                           WIP_CONSTANTS.HOLD);
  END PUT_LINE_ON_HOLD;

 PROCEDURE RELEASE_MES_WRAPPER
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER ) IS

    CURSOR disc_info IS
    SELECT STATUS_TYPE,
           CLASS_CODE
     FROM WIP_DISCRETE_JOBS
     WHERE WIP_ENTITY_ID = P_wip_entity_id
     AND ORGANIZATION_ID = P_organization_id;


    X_status_type NUMBER;
    X_class_code VARCHAR2(10) := '';
    X_valid_job BOOLEAN;
    X_routing_exists NUMBER;
    X_user_id NUMBER := FND_GLOBAL.USER_ID;
    X_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

 BEGIN
    OPEN disc_info;
    FETCH disc_info INTO X_status_type, X_class_code;
    X_valid_job := disc_info%FOUND;
    CLOSE disc_info;

    IF NOT X_valid_job THEN
      FND_MESSAGE.SET_NAME('WIP', 'WIP_QA_ACTION_NO_HOLD');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    RELEASE (P_wip_entity_id, P_organization_id, '', '',
             X_class_code, X_status_type, WIP_CONSTANTS.RELEASED,
             X_routing_exists, SYSDATE);


    UPDATE WIP_DISCRETE_JOBS
       SET STATUS_TYPE = WIP_CONSTANTS.RELEASED,
           DATE_RELEASED = NVL(DATE_RELEASED, SYSDATE),
           LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = X_user_id,
           LAST_UPDATE_LOGIN = X_login_id
     WHERE WIP_ENTITY_ID = P_wip_entity_id
       AND ORGANIZATION_ID = P_organization_id;

 END RELEASE_MES_WRAPPER;


END WIP_CHANGE_STATUS;

/
