--------------------------------------------------------
--  DDL for Package Body WIP_REPETITIVE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REPETITIVE_UTILITIES" AS
/* $Header: wipreutb.pls 115.15 2003/06/11 11:29:05 panagara ship $ */

/*============================================================================
| SPLIT_SCHEDULE
|  This procedure split a schedule into two consecutive schedules.
|  A new schedule is created and the new schedule id is returned.
|
| PARAMETERS
|       p_sched_id      Id of the schedule to be split
|       p_org_id        Organization Id
|       p_new_sched_id  Id of the new schedule that was split from the old
|                       schedule
=============================================================================*/

PROCEDURE
  split_schedule (p_sched_id      	IN NUMBER,
                  p_org_id        	IN NUMBER,
		  p_new_sched_id  	IN OUT NOCOPY NUMBER) IS
  x_cal_code        VARCHAR2(11);
  x_excp_set_id     NUMBER;
  x_wip_id          NUMBER;
  x_rnd_proc_days   NUMBER;
  x_rnd_days_ran    NUMBER;
  x_rnd_days_left   NUMBER;
  x_fusd            NUMBER;
  x_fucd            NUMBER;
  x_lusd            NUMBER;
  x_lucd            NUMBER;
  x_first_op        NUMBER;
  x_user_id         NUMBER;
  x_login_id        NUMBER;
  x_request_id      NUMBER;
  x_appl_id         NUMBER;
  x_program_id      NUMBER;
  x_rate            NUMBER;
  x_qty_completed   NUMBER;
  x_act_proc_days   NUMBER;
  x_act_days_left   NUMBER;
  x_found	    BOOLEAN;
  x_class_code      VARCHAR2(11);
  x_line_id	    NUMBER;
  err_msg	    VARCHAR2(100);

  CURSOR cal is
  SELECT CALENDAR_CODE,
         CALENDAR_EXCEPTION_SET_ID
    FROM MTL_PARAMETERS
   WHERE ORGANIZATION_ID = p_org_id;

  CURSOR gen_info IS
  SELECT WRS.WIP_ENTITY_ID,
         WRS.DAILY_PRODUCTION_RATE,
         WRS.PROCESSING_WORK_DAYS,
         CEIL(WRS.PROCESSING_WORK_DAYS),
         WRS.QUANTITY_COMPLETED,
         CD1.NEXT_SEQ_NUM,
         CD2.NEXT_SEQ_NUM,
         CD3.PRIOR_SEQ_NUM,
         CD4.PRIOR_SEQ_NUM
    FROM BOM_CALENDAR_DATES CD1,
         BOM_CALENDAR_DATES CD2,
         BOM_CALENDAR_DATES CD3,
         BOM_CALENDAR_DATES CD4,
	 WIP_REPETITIVE_SCHEDULES WRS
   WHERE WRS.ORGANIZATION_ID        = p_org_id
     AND WRS.REPETITIVE_SCHEDULE_ID = p_sched_id
     AND CD1.CALENDAR_CODE          = x_cal_code
     AND CD1.EXCEPTION_SET_ID       = x_excp_set_id
     AND CD1.CALENDAR_DATE          = TRUNC(WRS.FIRST_UNIT_START_DATE)
     AND CD2.CALENDAR_CODE          = x_cal_code
     AND CD2.EXCEPTION_SET_ID       = x_excp_set_id
     AND CD2.CALENDAR_DATE          = TRUNC(WRS.FIRST_UNIT_COMPLETION_DATE)
     AND CD3.CALENDAR_CODE          = x_cal_code
     AND CD3.EXCEPTION_SET_ID       = x_excp_set_id
     AND CD3.CALENDAR_DATE          = TRUNC(WRS.LAST_UNIT_START_DATE)
     AND CD4.CALENDAR_CODE          = x_cal_code
     AND CD4.EXCEPTION_SET_ID       = x_excp_set_id
     AND CD4.CALENDAR_DATE          = TRUNC(WRS.LAST_UNIT_COMPLETION_DATE);

  CURSOR first_op IS
  SELECT NVL(MIN(OPERATION_SEQ_NUM), -1)
    FROM WIP_OPERATIONS
   WHERE ORGANIZATION_ID = p_org_id
     AND WIP_ENTITY_ID = x_wip_id
     AND REPETITIVE_SCHEDULE_ID = p_sched_id;

  CURSOR qty_completed IS
  SELECT QUANTITY_RUNNING + QUANTITY_COMPLETED
    FROM WIP_OPERATIONS
   WHERE ORGANIZATION_ID = p_org_id
     AND WIP_ENTITY_ID = x_wip_id
     AND OPERATION_SEQ_NUM = x_first_op
     AND REPETITIVE_SCHEDULE_ID = p_sched_id;

  CURSOR nu_sched_id IS
  SELECT WIP_REPETITIVE_SCHEDULES_S.NEXTVAL
    FROM DUAL;

  CURSOR per_bal IS
  SELECT WRS.line_id, WRI.class_code
    FROM WIP_REPETITIVE_ITEMS WRI, WIP_REPETITIVE_SCHEDULES WRS
   WHERE WRS.REPETITIVE_SCHEDULE_ID  	= p_new_sched_id
     AND WRS.ORGANIZATION_ID		= p_org_id
     AND WRS.WIP_ENTITY_ID 		= x_wip_id
     AND WRI.WIP_ENTITY_ID 		= x_wip_id
     AND WRI.LINE_ID			= wrs.line_id;

  CURSOR wip_op_inst IS
  SELECT distinct pk2_value
    FROM fnd_attached_documents
   WHERE pk1_value = to_char(x_wip_id)
     AND pk3_value = to_char(p_org_id)
     AND pk4_value = to_char(p_sched_id)
     AND entity_name = 'WIP_REPETITIVE_OPERATIONS';


BEGIN

  x_user_id    := FND_GLOBAL.USER_ID;
  x_request_id := FND_GLOBAL.CONC_REQUEST_ID;
  x_login_id   := FND_GLOBAL.LOGIN_ID;
  x_appl_id    := FND_GLOBAL.PROG_APPL_ID;
  x_program_id := FND_GLOBAL.CONC_PROGRAM_ID;

  open cal;
  fetch cal into x_cal_code, x_excp_set_id;
  x_found := cal%NOTFOUND;
  close cal;

  if x_found then
	fnd_message.set_name('WIP', 'WIP_DEFINE_INV_PARAMETERS');
	app_exception.raise_exception;
  end if;

  -- get the next working fusd, fucd, lusd, lucd as well as other info

  open gen_info;
  FETCH gen_info INTO x_wip_id, x_rate, x_act_proc_days,
			x_rnd_proc_days, x_qty_completed, x_fusd,
         		x_fucd, x_lusd, x_lucd;
  close gen_info;

  -- getting first operation in the schedule --

  open first_op;
  fetch first_op INTO x_first_op;
  close first_op;

  IF (x_first_op <> -1) THEN
   	open qty_completed;
 	fetch qty_completed into x_qty_completed;
	close qty_completed;
  END IF;

  x_rnd_days_ran := ceil(x_qty_completed / x_rate);
  x_rnd_days_left := x_rnd_proc_days - x_rnd_days_ran;
  x_act_days_left := x_act_proc_days - x_rnd_days_ran;

  IF (x_rnd_days_ran < x_rnd_proc_days) THEN
    IF (x_rnd_days_ran <> 0) THEN
      open nu_sched_id;
      fetch nu_sched_id into p_new_sched_id;
      close nu_sched_id;

-- inserting new schedule
      INSERT INTO WIP_REPETITIVE_SCHEDULES
            (REPETITIVE_SCHEDULE_ID, ORGANIZATION_ID,
             LAST_UPDATE_DATE, LAST_UPDATED_BY,
             CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
             REQUEST_ID, PROGRAM_APPLICATION_ID,
             PROGRAM_ID, PROGRAM_UPDATE_DATE,
             WIP_ENTITY_ID, LINE_ID,
             DAILY_PRODUCTION_RATE, PROCESSING_WORK_DAYS,
             STATUS_TYPE, FIRM_PLANNED_FLAG,
             ALTERNATE_BOM_DESIGNATOR, COMMON_BOM_SEQUENCE_ID,
             BOM_REVISION, BOM_REVISION_DATE,
             ALTERNATE_ROUTING_DESIGNATOR, COMMON_ROUTING_SEQUENCE_ID,
             ROUTING_REVISION, ROUTING_REVISION_DATE,
             FIRST_UNIT_START_DATE, FIRST_UNIT_COMPLETION_DATE,
             LAST_UNIT_START_DATE, LAST_UNIT_COMPLETION_DATE,
             DATE_RELEASED, DATE_CLOSED,
             QUANTITY_COMPLETED, DESCRIPTION,
             DEMAND_CLASS, MATERIAL_ACCOUNT,
             MATERIAL_OVERHEAD_ACCOUNT, MATERIAL_VARIANCE_ACCOUNT,
             OUTSIDE_PROCESSING_ACCOUNT, OUTSIDE_PROC_VARIANCE_ACCOUNT,
             OVERHEAD_ACCOUNT, OVERHEAD_VARIANCE_ACCOUNT,
             RESOURCE_ACCOUNT, RESOURCE_VARIANCE_ACCOUNT,
             ATTRIBUTE_CATEGORY, ATTRIBUTE1,
             ATTRIBUTE2, ATTRIBUTE3,
             ATTRIBUTE4, ATTRIBUTE5,
             ATTRIBUTE6, ATTRIBUTE7,
             ATTRIBUTE8, ATTRIBUTE9,
             ATTRIBUTE10, ATTRIBUTE11,
             ATTRIBUTE12, ATTRIBUTE13,
             ATTRIBUTE14, ATTRIBUTE15)
      SELECT p_new_sched_id, WRS.ORGANIZATION_ID,
             SYSDATE, x_user_id,
             SYSDATE, x_user_id, x_login_id,
             DECODE(x_request_id, 0, '', x_request_id),
             DECODE(x_appl_id, 0, '', x_appl_id),
             DECODE(x_program_id, 0, '', x_program_id),
             DECODE(x_program_id, 0, '', SYSDATE),
             WRS.WIP_ENTITY_ID, WRS.LINE_ID,
             x_rate, x_act_days_left,
             WRS.STATUS_TYPE, WRS.FIRM_PLANNED_FLAG,
             WRS.ALTERNATE_BOM_DESIGNATOR, WRS.COMMON_BOM_SEQUENCE_ID,
             WRS.BOM_REVISION, WRS.BOM_REVISION_DATE,
             WRS.ALTERNATE_ROUTING_DESIGNATOR,
             WRS.COMMON_ROUTING_SEQUENCE_ID,
             WRS.ROUTING_REVISION, WRS.ROUTING_REVISION_DATE,
             TO_DATE(TO_CHAR(CD1.CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                     TO_CHAR(WRS.FIRST_UNIT_START_DATE, WIP_CONSTANTS.TIMESEC_FMT),
                     WIP_CONSTANTS.DATETIME_FMT),
             TO_DATE(TO_CHAR(CD2.CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                     TO_CHAR(WRS.FIRST_UNIT_COMPLETION_DATE, WIP_CONSTANTS.TIMESEC_FMT),
                     WIP_CONSTANTS.DATETIME_FMT),
             WRS.LAST_UNIT_START_DATE, WRS.LAST_UNIT_COMPLETION_DATE,
             SYSDATE, WRS.DATE_CLOSED,
             0, WRS.DESCRIPTION,
             WRS.DEMAND_CLASS, WRS.MATERIAL_ACCOUNT,
             WRS.MATERIAL_OVERHEAD_ACCOUNT,
             WRS.MATERIAL_VARIANCE_ACCOUNT,
             WRS.OUTSIDE_PROCESSING_ACCOUNT,
             WRS.OUTSIDE_PROC_VARIANCE_ACCOUNT,
             WRS.OVERHEAD_ACCOUNT, WRS.OVERHEAD_VARIANCE_ACCOUNT,
             WRS.RESOURCE_ACCOUNT, WRS.RESOURCE_VARIANCE_ACCOUNT,
             WRS.ATTRIBUTE_CATEGORY, WRS.ATTRIBUTE1,
             WRS.ATTRIBUTE2, WRS.ATTRIBUTE3,
             WRS.ATTRIBUTE4, WRS.ATTRIBUTE5,
             WRS.ATTRIBUTE6, WRS.ATTRIBUTE7,
             WRS.ATTRIBUTE8, WRS.ATTRIBUTE9,
             WRS.ATTRIBUTE10, WRS.ATTRIBUTE11,
             WRS.ATTRIBUTE12, WRS.ATTRIBUTE13,
             WRS.ATTRIBUTE14, WRS.ATTRIBUTE15
        FROM BOM_CALENDAR_DATES CD1,
             BOM_CALENDAR_DATES CD2,
	     WIP_REPETITIVE_SCHEDULES WRS
       WHERE WRS.ORGANIZATION_ID        = p_org_id
         AND WRS.REPETITIVE_SCHEDULE_ID = p_sched_id
         AND CD1.CALENDAR_CODE          = x_cal_code
         AND CD1.EXCEPTION_SET_ID       = x_excp_set_id
         AND CD1.SEQ_NUM                = x_fusd + x_rnd_days_ran
         AND CD2.CALENDAR_CODE          = x_cal_code
         AND CD2.EXCEPTION_SET_ID       = x_excp_set_id
         AND CD2.SEQ_NUM                = x_fucd + x_rnd_days_ran;

      --- get line_id and class_code for insert period balances (11/94)
      open per_bal;
      fetch per_bal INTO x_line_id, x_class_code;
      close per_bal;

      wip_change_status.insert_period_balances(x_wip_id, p_org_id,
						p_new_sched_id, x_line_id,
				          	x_class_code);

      -- set processed days, lusd, lucd of the old schedule to reflect days the
      -- schedule actually ran

      UPDATE WIP_REPETITIVE_SCHEDULES
         SET PROCESSING_WORK_DAYS = x_rnd_days_ran,
             LAST_UNIT_START_DATE =
               (SELECT TO_DATE(TO_CHAR(CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                               TO_CHAR(LAST_UNIT_START_DATE, WIP_CONSTANTS.TIMESEC_FMT),
                               WIP_CONSTANTS.DATETIME_FMT)
                  FROM BOM_CALENDAR_DATES
                 WHERE CALENDAR_CODE = x_cal_code
                   AND EXCEPTION_SET_ID = x_excp_set_id
                   AND SEQ_NUM = x_lusd - x_rnd_days_left),
             LAST_UNIT_COMPLETION_DATE =
              (SELECT TO_DATE(TO_CHAR(CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                               TO_CHAR(LAST_UNIT_COMPLETION_DATE,
                                       WIP_CONSTANTS.TIMESEC_FMT),
                               WIP_CONSTANTS.DATETIME_FMT)
                 FROM BOM_CALENDAR_DATES
                WHERE CALENDAR_CODE = x_cal_code
                  AND EXCEPTION_SET_ID = x_excp_set_id
                  AND SEQ_NUM = x_lucd - x_rnd_days_left),
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = x_user_id,
             REQUEST_ID =
                DECODE(x_request_id, 0, REQUEST_ID, x_request_id),
             PROGRAM_APPLICATION_ID =
                DECODE(x_appl_id, 0, PROGRAM_APPLICATION_ID, x_appl_id),
             PROGRAM_ID =
                DECODE(x_program_id, 0, PROGRAM_ID, x_program_id),
             PROGRAM_UPDATE_DATE =
                DECODE(x_program_id, 0, PROGRAM_UPDATE_DATE, SYSDATE)
       WHERE ORGANIZATION_ID = p_org_id
         AND REPETITIVE_SCHEDULE_ID = p_sched_id;

      -- copy ops from old schedule for new schedule

      INSERT INTO WIP_OPERATIONS
            (WIP_ENTITY_ID, OPERATION_SEQ_NUM,
             ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID,
             LAST_UPDATE_DATE, LAST_UPDATED_BY,
             CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
             REQUEST_ID, PROGRAM_APPLICATION_ID,
             PROGRAM_ID, PROGRAM_UPDATE_DATE,
             OPERATION_SEQUENCE_ID, STANDARD_OPERATION_ID,
             DEPARTMENT_ID, DESCRIPTION,
             SCHEDULED_QUANTITY, QUANTITY_IN_QUEUE,
             QUANTITY_RUNNING, QUANTITY_WAITING_TO_MOVE,
             QUANTITY_REJECTED, QUANTITY_SCRAPPED,
             QUANTITY_COMPLETED, DATE_LAST_MOVED,
             CUMULATIVE_SCRAP_QUANTITY,                           /* Enh#2864382*/
             FIRST_UNIT_START_DATE, FIRST_UNIT_COMPLETION_DATE,
             LAST_UNIT_START_DATE, LAST_UNIT_COMPLETION_DATE,
             PREVIOUS_OPERATION_SEQ_NUM, NEXT_OPERATION_SEQ_NUM,
             COUNT_POINT_TYPE, BACKFLUSH_FLAG,
             MINIMUM_TRANSFER_QUANTITY, LONG_DESCRIPTION,
             ATTRIBUTE_CATEGORY, ATTRIBUTE1,
             ATTRIBUTE2, ATTRIBUTE3,
             ATTRIBUTE4, ATTRIBUTE5,
             ATTRIBUTE6, ATTRIBUTE7,
             ATTRIBUTE8, ATTRIBUTE9,
             ATTRIBUTE10, ATTRIBUTE11,
             ATTRIBUTE12, ATTRIBUTE13,
             ATTRIBUTE14, ATTRIBUTE15)
      SELECT OPS.WIP_ENTITY_ID, OPS.OPERATION_SEQ_NUM,
             OPS.ORGANIZATION_ID, p_new_sched_id,
             SYSDATE, x_user_id,
             SYSDATE, x_user_id, x_login_id,
             DECODE(x_request_id, 0, '', x_request_id),
             DECODE(x_appl_id, 0, '', x_appl_id),
             DECODE(x_program_id, 0, '', x_program_id),
             DECODE(x_program_id, 0, '', SYSDATE),
             OPS.OPERATION_SEQUENCE_ID, OPS.STANDARD_OPERATION_ID,
             OPS.DEPARTMENT_ID, OPS.DESCRIPTION,
             x_rate * x_act_days_left,
             DECODE(OPS.OPERATION_SEQ_NUM,
                    x_first_op, x_rate * x_act_days_left, 0),
             0, 0,
             0, 0,
             0, '',0,
             TO_DATE(TO_CHAR(CD1.CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                     TO_CHAR(OPS.FIRST_UNIT_START_DATE, WIP_CONSTANTS.TIMESEC_FMT),
                     WIP_CONSTANTS.DATETIME_FMT),
             TO_DATE(TO_CHAR(CD2.CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                     TO_CHAR(OPS.FIRST_UNIT_COMPLETION_DATE, WIP_CONSTANTS.TIMESEC_FMT),
                     WIP_CONSTANTS.DATETIME_FMT),
             OPS.LAST_UNIT_START_DATE, OPS.LAST_UNIT_COMPLETION_DATE,
             OPS.PREVIOUS_OPERATION_SEQ_NUM, OPS.NEXT_OPERATION_SEQ_NUM,
             OPS.COUNT_POINT_TYPE, OPS.BACKFLUSH_FLAG,
             OPS.MINIMUM_TRANSFER_QUANTITY, OPS.LONG_DESCRIPTION,
             OPS.ATTRIBUTE_CATEGORY, OPS.ATTRIBUTE1,
             OPS.ATTRIBUTE2, OPS.ATTRIBUTE3,
             OPS.ATTRIBUTE4, OPS.ATTRIBUTE5,
             OPS.ATTRIBUTE6, OPS.ATTRIBUTE7,
             OPS.ATTRIBUTE8, OPS.ATTRIBUTE9,
             OPS.ATTRIBUTE10, OPS.ATTRIBUTE11,
             OPS.ATTRIBUTE12, OPS.ATTRIBUTE13,
             OPS.ATTRIBUTE14, OPS.ATTRIBUTE15
        FROM BOM_CALENDAR_DATES CD1,
             BOM_CALENDAR_DATES CD2,
             WIP_OPERATIONS OPS
       WHERE OPS.ORGANIZATION_ID = p_org_id
         AND OPS.WIP_ENTITY_ID = x_wip_id
         AND OPS.REPETITIVE_SCHEDULE_ID = p_sched_id
         AND CD1.CALENDAR_CODE = x_cal_code
         AND CD1.EXCEPTION_SET_ID = x_excp_set_id
         AND CD1.SEQ_NUM =
               (SELECT NEXT_SEQ_NUM + x_rnd_days_ran
                  FROM BOM_CALENDAR_DATES
                 WHERE CALENDAR_CODE = x_cal_code
                   AND EXCEPTION_SET_ID = x_excp_set_id
                   AND CALENDAR_DATE =
                       TRUNC(OPS.FIRST_UNIT_START_DATE))
         AND CD2.CALENDAR_CODE = x_cal_code
         AND CD2.EXCEPTION_SET_ID = x_excp_set_id
         AND CD2.SEQ_NUM =
               (SELECT NEXT_SEQ_NUM + x_rnd_days_ran
                  FROM BOM_CALENDAR_DATES
                 WHERE CALENDAR_CODE = x_cal_code
                   AND EXCEPTION_SET_ID = x_excp_set_id
                   AND CALENDAR_DATE =
                       TRUNC(OPS.FIRST_UNIT_COMPLETION_DATE));

      -- set the quantity in the queue to quantity not complete
      -- and update lusd, lucd for the wip_operations table

      UPDATE WIP_OPERATIONS OPS
         SET QUANTITY_IN_QUEUE =
               DECODE(OPERATION_SEQ_NUM,
                      x_first_op,
                      QUANTITY_IN_QUEUE - x_act_days_left * x_rate,
                      QUANTITY_IN_QUEUE),
             SCHEDULED_QUANTITY = x_rate * x_rnd_days_ran,
             LAST_UNIT_START_DATE =
               (SELECT TO_DATE(TO_CHAR(CD2.CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                               TO_CHAR(OPS.LAST_UNIT_START_DATE,
                                       WIP_CONSTANTS.TIMESEC_FMT),
                               WIP_CONSTANTS.DATETIME_FMT)
                  FROM BOM_CALENDAR_DATES CD1,
                       BOM_CALENDAR_DATES CD2
                 WHERE CD1.CALENDAR_CODE = x_cal_code
                   AND CD1.EXCEPTION_SET_ID = x_excp_set_id
                   AND CD1.CALENDAR_DATE =
                       TRUNC(OPS.LAST_UNIT_START_DATE)
                   AND CD2.CALENDAR_CODE = x_cal_code
                   AND CD2.EXCEPTION_SET_ID = x_excp_set_id
                   AND CD2.SEQ_NUM = CD1.PRIOR_SEQ_NUM - x_rnd_days_left),
             LAST_UNIT_COMPLETION_DATE =
               (SELECT TO_DATE(TO_CHAR(CD2.CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                               TO_CHAR(OPS.LAST_UNIT_COMPLETION_DATE,
                                      WIP_CONSTANTS.TIMESEC_FMT),
                               WIP_CONSTANTS.DATETIME_FMT)
                  FROM BOM_CALENDAR_DATES CD1,
                       BOM_CALENDAR_DATES CD2
                 WHERE CD1.CALENDAR_CODE = x_cal_code
                   AND CD1.EXCEPTION_SET_ID = x_excp_set_id
                   AND CD1.CALENDAR_DATE =
                       TRUNC(OPS.LAST_UNIT_COMPLETION_DATE)
                   AND CD2.CALENDAR_CODE = x_cal_code
                   AND CD2.EXCEPTION_SET_ID = x_excp_set_id
                   AND CD2.SEQ_NUM = CD1.PRIOR_SEQ_NUM - x_rnd_days_left),
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = x_user_id,
             REQUEST_ID =
                  DECODE(x_request_id, 0, REQUEST_ID, x_request_id),
             PROGRAM_APPLICATION_ID =
                  DECODE(x_appl_id, 0, PROGRAM_APPLICATION_ID, x_appl_id),
             PROGRAM_ID =
                  DECODE(x_program_id, 0, PROGRAM_ID, x_program_id),
             PROGRAM_UPDATE_DATE =
                  DECODE(x_program_id, 0, PROGRAM_UPDATE_DATE, SYSDATE)
       WHERE ORGANIZATION_ID = p_org_id
         AND WIP_ENTITY_ID = x_wip_id
         AND REPETITIVE_SCHEDULE_ID = p_sched_id;

      INSERT INTO WIP_OPERATION_RESOURCES
            (WIP_ENTITY_ID, OPERATION_SEQ_NUM,
             RESOURCE_SEQ_NUM, ORGANIZATION_ID,
             REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
             LAST_UPDATED_BY, CREATION_DATE,
             CREATED_BY, LAST_UPDATE_LOGIN,
             REQUEST_ID, PROGRAM_APPLICATION_ID,
             PROGRAM_ID, PROGRAM_UPDATE_DATE,
             RESOURCE_ID, UOM_CODE, BASIS_TYPE,
             USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
             SCHEDULED_FLAG, ASSIGNED_UNITS,
             AUTOCHARGE_TYPE, STANDARD_RATE_FLAG,
             APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
             START_DATE, COMPLETION_DATE,
             ATTRIBUTE_CATEGORY, ATTRIBUTE1,
             ATTRIBUTE2, ATTRIBUTE3,
             ATTRIBUTE4, ATTRIBUTE5,
             ATTRIBUTE6, ATTRIBUTE7,
             ATTRIBUTE8, ATTRIBUTE9,
             ATTRIBUTE10, ATTRIBUTE11,
             ATTRIBUTE12, ATTRIBUTE13,
             ATTRIBUTE14, ATTRIBUTE15)
       SELECT R.WIP_ENTITY_ID, R.OPERATION_SEQ_NUM,
              R.RESOURCE_SEQ_NUM, R.ORGANIZATION_ID,
              p_new_sched_id, SYSDATE,
              x_user_id, SYSDATE,
              x_user_id, x_login_id,
              DECODE(x_request_id, 0, '', x_request_id),
              DECODE(x_appl_id, 0, '', x_appl_id),
              DECODE(x_program_id, 0, '', x_program_id),
              DECODE(x_program_id, 0, '', SYSDATE),
              R.RESOURCE_ID, R.UOM_CODE, R.BASIS_TYPE,
              R.USAGE_RATE_OR_AMOUNT, R.ACTIVITY_ID,
              R.SCHEDULED_FLAG, R.ASSIGNED_UNITS,
              R.AUTOCHARGE_TYPE, R.STANDARD_RATE_FLAG,
              0, 0,
              O.FIRST_UNIT_START_DATE, O.LAST_UNIT_COMPLETION_DATE,
              R.ATTRIBUTE_CATEGORY, R.ATTRIBUTE1,
              R.ATTRIBUTE2, R.ATTRIBUTE3,
              R.ATTRIBUTE4, R.ATTRIBUTE5,
              R.ATTRIBUTE6, R.ATTRIBUTE7,
              R.ATTRIBUTE8, R.ATTRIBUTE9,
              R.ATTRIBUTE10, R.ATTRIBUTE11,
              R.ATTRIBUTE12, R.ATTRIBUTE13,
              R.ATTRIBUTE14, R.ATTRIBUTE15
         FROM WIP_OPERATION_RESOURCES R,
              WIP_OPERATIONS O
        WHERE R.WIP_ENTITY_ID = x_wip_id
          AND R.ORGANIZATION_ID = p_org_id
          AND R.REPETITIVE_SCHEDULE_ID = p_sched_id
          AND O.WIP_ENTITY_ID = x_wip_id
          AND O.ORGANIZATION_ID = p_org_id
          AND O.REPETITIVE_SCHEDULE_ID = p_new_sched_id
          AND R.OPERATION_SEQ_NUM = O.OPERATION_SEQ_NUM;

      UPDATE WIP_OPERATION_RESOURCES OPS
         SET COMPLETION_DATE =
               (SELECT TO_DATE(TO_CHAR(CD2.CALENDAR_DATE, WIP_CONSTANTS.DATE_FMT) || ' ' ||
                               TO_CHAR(OPS.COMPLETION_DATE,
                                      WIP_CONSTANTS.TIMESEC_FMT),
                               WIP_CONSTANTS.DATETIME_FMT)
                  FROM BOM_CALENDAR_DATES CD1,
                       BOM_CALENDAR_DATES CD2
                 WHERE CD1.CALENDAR_CODE = x_cal_code
                   AND CD1.EXCEPTION_SET_ID = x_excp_set_id
                   AND CD1.CALENDAR_DATE =
                       TRUNC(OPS.COMPLETION_DATE)
                   AND CD2.CALENDAR_CODE = x_cal_code
                   AND CD2.EXCEPTION_SET_ID = x_excp_set_id
                   AND CD2.SEQ_NUM = CD1.PRIOR_SEQ_NUM - x_rnd_days_left),
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = x_user_id,
             REQUEST_ID =
                  DECODE(x_request_id, 0, REQUEST_ID, x_request_id),
             PROGRAM_APPLICATION_ID =
                  DECODE(x_appl_id, 0, PROGRAM_APPLICATION_ID, x_appl_id),
             PROGRAM_ID =
                  DECODE(x_program_id, 0, PROGRAM_ID, x_program_id),
             PROGRAM_UPDATE_DATE =
                  DECODE(x_program_id, 0, PROGRAM_UPDATE_DATE, SYSDATE)
       WHERE ORGANIZATION_ID = p_org_id
         AND WIP_ENTITY_ID = x_wip_id
         AND REPETITIVE_SCHEDULE_ID = p_sched_id;

/* jkent->lyao: Self-referential insertion? Hmm...
       INSERT INTO WIP_OPERATION_INSTRUCTIONS
             (WIP_ENTITY_ID, OPERATION_SEQ_NUM,
              OPERATION_DESCRIPTION_CODE, ORGANIZATION_ID,
              REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
              LAST_UPDATED_BY, CREATION_DATE,
              CREATED_BY, LAST_UPDATE_LOGIN,
              REQUEST_ID, PROGRAM_APPLICATION_ID,
              PROGRAM_ID, PROGRAM_UPDATE_DATE,
              ATTRIBUTE_CATEGORY, ATTRIBUTE1,
		. . .
              ATTRIBUTE14, ATTRIBUTE15)
       SELECT WIP_ENTITY_ID, OPERATION_SEQ_NUM,
              OPERATION_DESCRIPTION_CODE, ORGANIZATION_ID,
              p_new_sched_id, SYSDATE,
              x_user_id, SYSDATE,
              x_user_id, x_login_id,
              DECODE(x_request_id, 0, '', x_request_id),
              DECODE(x_appl_id, 0, '', x_appl_id),
              DECODE(x_program_id, 0, '', x_program_id),
              DECODE(x_program_id, 0, '', SYSDATE),
              ATTRIBUTE_CATEGORY, ATTRIBUTE1,
		. . .
              ATTRIBUTE14, ATTRIBUTE15
         FROM WIP_OPERATION_INSTRUCTIONS
        WHERE WIP_ENTITY_ID = x_wip_id
          AND ORGANIZATION_ID = p_org_id
          AND REPETITIVE_SCHEDULE_ID = p_sched_id;
*/
    FOR cur_rec IN wip_op_inst LOOP
       FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
        X_FROM_ENTITY_NAME => 'WIP_REPETITIVE_OPERATIONS',
        X_FROM_PK1_VALUE   => to_char(x_wip_id),
        X_FROM_PK2_VALUE   => cur_rec.pk2_value,
	X_FROM_PK3_VALUE   => to_char(p_org_id ),
        X_FROM_PK4_VALUE   => to_char(p_sched_id),
        X_TO_ENTITY_NAME   => 'WIP_REPETITIVE_OPERATIONS',
        X_TO_PK1_VALUE   => to_char(x_wip_id),
        X_TO_PK2_VALUE   => cur_rec.pk2_value,
        X_TO_PK3_VALUE   => to_char(p_org_id),
        X_TO_PK4_VALUE   => to_char(p_new_sched_id),
        X_CREATED_BY     => x_user_id,
        X_LAST_UPDATE_LOGIN => x_login_id,
	X_PROGRAM_APPLICATION_ID  => x_appl_id,
	X_PROGRAM_ID	=> x_program_id,
	X_REQUEST_ID	=> x_request_id);
    END LOOP;


      UPDATE WIP_REQUIREMENT_OPERATIONS R
         SET REQUIRED_QUANTITY = QUANTITY_PER_ASSEMBLY *
                                 x_rate * x_rnd_days_ran,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = x_user_id,
             REQUEST_ID =
                DECODE(x_request_id, 0, REQUEST_ID, x_request_id),
             PROGRAM_APPLICATION_ID =
                DECODE(x_appl_id, 0, PROGRAM_APPLICATION_ID, x_appl_id),
             PROGRAM_ID =
                DECODE(x_program_id, 0, PROGRAM_ID, x_program_id),
             PROGRAM_UPDATE_DATE =
                DECODE(x_program_id, 0, PROGRAM_UPDATE_DATE, SYSDATE)
       WHERE WIP_ENTITY_ID = x_wip_id
         AND ORGANIZATION_ID = p_org_id
         AND REPETITIVE_SCHEDULE_ID = p_sched_id
         AND REQUIRED_QUANTITY > 0;

    -- x_rnd_days_ran = 0
    ELSE

      UPDATE WIP_OPERATIONS
         SET QUANTITY_IN_QUEUE =
               DECODE(OPERATION_SEQ_NUM,
                      x_first_op, x_rate * x_act_days_left,
                      QUANTITY_IN_QUEUE),
             SCHEDULED_QUANTITY = x_rate * x_act_days_left,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = x_user_id,
             REQUEST_ID =
                  DECODE(x_request_id, 0, REQUEST_ID, x_request_id),
             PROGRAM_APPLICATION_ID =
                  DECODE(x_appl_id, 0, PROGRAM_APPLICATION_ID, x_appl_id),
             PROGRAM_ID =
                  DECODE(x_program_id, 0, PROGRAM_ID, x_program_id),
             PROGRAM_UPDATE_DATE =
                  DECODE(x_program_id, 0, PROGRAM_UPDATE_DATE, SYSDATE)
       WHERE ORGANIZATION_ID = p_org_id
         AND WIP_ENTITY_ID = x_wip_id
         AND REPETITIVE_SCHEDULE_ID = p_sched_id;

    END IF;

  END IF;

END split_schedule;

/*==========================================================================+
|
| Roll_Forward
|      Roll forward schedule
|
| PARAMETERS
|       x_closed_sched_id       Id of closed schedule
|       x_rollfwd_sched_id      Id of schedule being roll forward
|       x_rollfwd_type          roll forward types:
|                               ROLL_EC_IMP, ROLL_COMPLETE, ROLL_CANCEL
|       x_org_id                Org Id
|       x_update_status         True if want status to be updated
|       x_class_code            Class code
*===========================================================================*/

PROCEDURE roll_forward
                  (p_closed_sched_id    IN     NUMBER,
                   p_rollfwd_sched_id   IN OUT NOCOPY NUMBER,
                   p_rollfwd_type       IN     NUMBER,
                   p_org_id             IN     NUMBER,
                   p_update_status      IN     BOOLEAN) IS

x_date_reqd		DATE;
x_wip_id		NUMBER;
x_line_id		NUMBER;
x_class_code		VARCHAR2(11);
x_closed_status_type	NUMBER;
x_rollfwd_status_type	NUMBER;
x_rollfwd_first_op	NUMBER;
x_user_id		NUMBER;
x_login_id		NUMBER;
x_request_id		NUMBER;
x_appl_id		NUMBER;
x_program_id		NUMBER;
x_qty_completed		NUMBER;
x_rollfwd_qty		NUMBER;
x_found_next_sched	BOOLEAN := TRUE;

-- Constants --
NUM_DAYS_IN_10_YEARS	CONSTANT	NUMBER	:= 3650;

CURSOR gen_info IS
  SELECT wrs.wip_entity_id,
         wrs.line_id,
         decode(p_rollfwd_type,
		WIP_CONSTANTS.ROLL_EC_IMP,
		0, wrs.quantity_completed)
  FROM wip_repetitive_schedules wrs
  WHERE wrs.organization_id = p_org_id
  AND wrs.repetitive_schedule_id  =
      decode(p_rollfwd_type, WIP_CONSTANTS.ROLL_EC_IMP, p_rollfwd_sched_id,
                                          p_closed_sched_id);

CURSOR get_nxt is
    SELECT r1.repetitive_schedule_id,
           r1.status_type,
           r1.daily_production_rate * r1.processing_work_days,
           r1.first_unit_start_date
    FROM wip_repetitive_schedules r1,
         wip_repetitive_schedules r2,
         wip_parameters p
    WHERE r1.organization_id = p_org_id
    AND r2.organization_id = p_org_id
    AND p.organization_id = p_org_id
    AND r2.repetitive_schedule_id = p_closed_sched_id
    AND r1.wip_entity_id = x_wip_id
    AND r1.line_id = x_line_id
    AND r1.status_type IN (WIP_CONSTANTS.UNRELEASED, WIP_CONSTANTS.RELEASED,
                           WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD)
    AND r1.first_unit_start_date > r2.last_unit_start_date
    AND r1.first_unit_start_date <= SYSDATE +
             decode(r1.status_type, WIP_CONSTANTS.UNRELEASED,
		p.autorelease_days,NUM_DAYS_IN_10_YEARS)
    ORDER BY r1.first_unit_start_date;

CURSOR roll_ec IS
    SELECT wrs.status_type,
           wrs.daily_production_rate * wrs.processing_work_days,
           wrs.first_unit_start_date
    FROM wip_repetitive_schedules wrs
    WHERE wrs.organization_id = p_org_id
    AND wrs.repetitive_schedule_id = p_rollfwd_sched_id;

CURSOR nxt_fstop IS
    SELECT nvl(min(wo.operation_seq_num), 1)
    FROM wip_operations wo
    WHERE wo.organization_id = p_org_id
    AND wo.wip_entity_id = x_wip_id
    AND wo.repetitive_schedule_id = p_rollfwd_sched_id;

CURSOR per_bal IS
      SELECT WRI.class_code
      FROM WIP_REPETITIVE_ITEMS WRI
      WHERE WRI.ORGANIZATION_ID		= p_org_id
        AND WRI.WIP_ENTITY_ID 		= x_wip_id
	AND WRI.LINE_ID			= x_line_id;

x_dummy boolean;
x_rel VARCHAR2(100);
x_info VARCHAR2(100);

BEGIN

  -- populate who columns --
  x_user_id := fnd_global.user_id;
  x_login_id := fnd_global.login_id;
  x_request_id := fnd_global.conc_request_id;
  x_appl_id := fnd_global.prog_appl_id;
  x_program_id := fnd_global.conc_program_id;

  -- get the assembly and line id of the closed schedule --
  open gen_info;
  fetch gen_info INTO x_wip_id, x_line_id, x_qty_completed;
  close gen_info;

  IF ((p_rollfwd_type = WIP_CONSTANTS.ROLL_COMPLETE) OR
      (p_rollfwd_type = WIP_CONSTANTS.ROLL_CANCEL)) THEN

    	-- get the next schedule with start date after the last unit date of
	-- the closed schedule
    	open get_nxt;
    	fetch get_nxt INTO p_rollfwd_sched_id, x_rollfwd_status_type,
         			x_rollfwd_qty, x_date_reqd;
    	if get_nxt%NOTFOUND then
		x_found_next_sched := FALSE;
   	end if;
    	close get_nxt;

    	IF ((x_found_next_sched) AND
            (x_rollfwd_status_type = WIP_CONSTANTS.UNRELEASED)) THEN

    		wip_change_status.check_repetitive_routing(x_wip_id,
							p_org_id,
							p_rollfwd_sched_id,
							x_line_id);
    	END IF;

    	IF (p_rollfwd_type = WIP_CONSTANTS.ROLL_COMPLETE) THEN
      		IF (x_found_next_sched) THEN
        		x_closed_status_type := WIP_CONSTANTS.COMP_NOCHRG;
      		ELSE
        		x_closed_status_type := WIP_CONSTANTS.COMP_CHRG;
      		END IF;
    	ELSIF (p_rollfwd_type = WIP_CONSTANTS.ROLL_CANCEL) THEN
      		x_closed_status_type := WIP_CONSTANTS.CANCELLED;
    	END IF;

  ELSIF (p_rollfwd_type = WIP_CONSTANTS.ROLL_EC_IMP) THEN
    	open roll_ec;
    	fetch roll_ec INTO x_rollfwd_status_type, x_rollfwd_qty,
         			x_date_reqd;
    	if roll_ec%NOTFOUND then
      		x_found_next_sched := FALSE;
   	end if;
   	close roll_ec;
  END IF;

  IF (x_found_next_sched) THEN

    	-- get the first operation of the next schedule

    	open nxt_fstop;
    	fetch nxt_fstop INTO x_rollfwd_first_op;
    	close nxt_fstop;

    	-- set the quantity issued as well as others info for the next
	-- shedule in wip_requirement operation
    	UPDATE wip_requirement_operations new
   	SET new.quantity_issued =
       		(SELECT new.quantity_issued +
                  nvl(max(wro.quantity_issued -
                            (x_qty_completed * wro.quantity_per_assembly)), 0)
        FROM wip_requirement_operations wro
        WHERE wro.organization_id = p_org_id
        AND wro.wip_entity_id = x_wip_id
        AND wro.repetitive_schedule_id = p_closed_sched_id
        AND new.inventory_item_id = wro.inventory_item_id
        AND new.operation_seq_num = wro.operation_seq_num
        AND wro.quantity_issued >
                    x_qty_completed * wro.quantity_per_assembly
        AND wro.required_quantity >
                       decode(p_rollfwd_type,
				WIP_CONSTANTS.ROLL_EC_IMP, -1, 0)),
    	new.last_updated_by = x_user_id,
    	new.last_update_date = SYSDATE,
   	 new.request_id =
        	decode(x_request_id, 0, new.request_id, x_request_id),
    	new.program_application_id =
        	decode(x_appl_id, 0, new.program_application_id, x_appl_id),
    	new.program_id =
        	decode(x_program_id, 0, new.program_id, x_program_id),
    	new.program_update_date =
        	decode(x_program_id, 0, new.program_update_date, SYSDATE)
    	WHERE new.organization_id = p_org_id
    	AND new.wip_entity_id = x_wip_id
    	AND new.repetitive_schedule_id = p_rollfwd_sched_id;

    	-- insert into wip_requirement_operations

    	INSERT INTO wip_requirement_operations
      		(inventory_item_id, organization_id,
       		wip_entity_id, operation_seq_num,
       		repetitive_schedule_id, last_update_date,
       		last_updated_by, creation_date,
       		created_by, last_update_login,
       		request_id, program_application_id,
       		program_id, program_update_date,
       		component_sequence_id, department_id,
       		wip_supply_type, date_required,
       		required_quantity, quantity_issued,
       		quantity_per_assembly, comments,
       		supply_subinventory, supply_locator_id,
       		mrp_net_flag, mps_date_required,
       		mps_required_quantity,
       		segment1, segment2, segment3, segment4,
       		segment5, segment6, segment7, segment8,
       		segment9, segment10, segment11, segment12,
       		segment13, segment14, segment15, segment16,
       		segment17, segment18, segment19, segment20,
      		attribute_category, attribute1, attribute2,
       		attribute3, attribute4, attribute5,
       		attribute6, attribute7, attribute8,
       		attribute9, attribute10, attribute11,
       		attribute12, attribute13, attribute14,
       		attribute15)
     	SELECT wro.inventory_item_id, wro.organization_id,
            wro.wip_entity_id, wro.operation_seq_num,
            p_rollfwd_sched_id, SYSDATE,
            x_user_id, SYSDATE,
            x_user_id, x_login_id,
            DECODE(x_request_id, 0, '', x_request_id),
            DECODE(x_appl_id, 0, '', x_appl_id),
            DECODE(x_program_id, 0, '', x_program_id),
            DECODE(x_program_id, 0, '', SYSDATE),
            wro.component_sequence_id, wo.department_id,
            wro.wip_supply_type,
            nvl(wo.first_unit_start_date, x_date_reqd),
            0, wro.quantity_issued -
                            (x_qty_completed * wro.quantity_per_assembly),
            0, wro.comments,
            wro.supply_subinventory, wro.supply_locator_id,
            wro.mrp_net_flag, wro.mps_date_required,
            wro.mps_required_quantity,
            wro.segment1, wro.segment2, wro.segment3, wro.segment4,
            wro.segment5, wro.segment6, wro.segment7, wro.segment8,
            wro.segment9, wro.segment10, wro.segment11, wro.segment12,
            wro.segment13, wro.segment14, wro.segment15, wro.segment16,
            wro.segment17, wro.segment18, wro.segment19, wro.segment20,
            wro.attribute_category, wro.attribute1, wro.attribute2,
            wro.attribute3, wro.attribute4, wro.attribute5,
            wro.attribute6, wro.attribute7, wro.attribute8,
            wro.attribute9, wro.attribute10, wro.attribute11,
            wro.attribute12, wro.attribute13, wro.attribute14,
            wro.attribute15
     	FROM wip_requirement_operations wro,
          	wip_operations wo
     	WHERE wro.organization_id = p_org_id
     	AND wo.organization_id (+) = p_org_id
     	AND wro.wip_entity_id = x_wip_id
     	AND wo.wip_entity_id (+) = x_wip_id
     	AND wro.repetitive_schedule_id = p_closed_sched_id
     	AND wo.repetitive_schedule_id (+) = p_rollfwd_sched_id
     	AND wro.operation_seq_num = wo.operation_seq_num (+)
     	AND wro.quantity_issued > x_qty_completed *
                                   wro.quantity_per_assembly
     	AND wro.required_quantity > decode(p_rollfwd_type,
                                          WIP_CONSTANTS.ROLL_EC_IMP, -1, 0)
     	AND NOT EXISTS
         	(SELECT 'does the requirement already exist?'
          	FROM wip_requirement_operations wro1
          	WHERE wro1.inventory_item_id = wro.inventory_item_id
          	AND wro1.operation_seq_num = wro.operation_seq_num
          	AND wro1.organization_id = p_org_id
          	AND wro1.wip_entity_id = x_wip_id
          	AND wro1.repetitive_schedule_id = p_rollfwd_sched_id);

    	-- update closed schedule in wip_requirement_operations

    	UPDATE wip_requirement_operations wro
       	SET wro.quantity_issued = x_qty_completed * wro.quantity_per_assembly,
           	wro.last_update_date = SYSDATE,
          	wro.last_updated_by = x_user_id,
           	wro.request_id = DECODE(x_request_id, 0, wro.request_id,
                                   x_request_id),
           	wro.program_application_id =
               decode(x_appl_id, 0, wro.program_application_id, x_appl_id),
           	wro.program_id = decode(x_program_id, 0, wro.program_id,
                                   x_program_id),
           	wro.program_update_date =
               decode(x_program_id, 0, wro.program_update_date, SYSDATE)
     	WHERE wro.organization_id = p_org_id
       	AND wro.wip_entity_id = x_wip_id
       	AND wro.repetitive_schedule_id = p_closed_sched_id
       	AND wro.quantity_issued > x_qty_completed * wro.quantity_per_assembly
       	AND wro.required_quantity > DECODE(p_rollfwd_type,
                                	WIP_CONSTANTS.ROLL_EC_IMP, -1, 0);

  END IF;

  IF (p_update_status) THEN
    	IF ((p_rollfwd_type = WIP_CONSTANTS.ROLL_COMPLETE) OR
            (p_rollfwd_type = WIP_CONSTANTS.ROLL_CANCEL)) THEN

      		-- set the closed status of closed schedule
      		UPDATE wip_repetitive_schedules wrs
         	SET wrs.status_type = x_closed_status_type,
             	wrs.date_closed =
			decode(x_closed_status_type,
				WIP_CONSTANTS.COMP_CHRG,
                                wrs.date_closed, SYSDATE),
             	wrs.last_updated_by = x_user_id,
             	wrs.last_update_date = SYSDATE,
             	wrs.request_id = decode(x_request_id, 0, wrs.request_id,
                                     x_request_id),
             	wrs.program_application_id =
                 	decode(x_appl_id, 0, wrs.program_application_id,
			x_appl_id),
             	wrs.program_id = decode(x_program_id, 0, wrs.program_id,
                                     x_program_id),
             	wrs.program_update_date =
                 	decode(x_program_id, 0, wrs.program_update_date,
				SYSDATE)
       		WHERE wrs.organization_id = p_org_id
         	AND wrs.repetitive_schedule_id = p_closed_sched_id;

    	END IF;
  END IF;

  IF (x_rollfwd_status_type = WIP_CONSTANTS.UNRELEASED) THEN

    	-- release next schedule
    	UPDATE wip_repetitive_schedules wrs
      	 SET wrs.status_type = WIP_CONSTANTS.RELEASED,
           wrs.date_released = SYSDATE,
           wrs.last_update_date = SYSDATE,
           wrs.last_updated_by = x_user_id,
           wrs.request_id = decode(x_request_id, 0, wrs.request_id,
                                   x_request_id),
           wrs.program_application_id =
               decode(x_appl_id, 0, wrs.program_application_id, x_appl_id),
           wrs.program_id = decode(x_program_id, 0, wrs.program_id,
                                   x_program_id),
           wrs.program_update_date =
               decode(x_program_id, 0, wrs.program_update_date, SYSDATE)
    	 WHERE wrs.organization_id = p_org_id
      	 AND wrs.repetitive_schedule_id = p_rollfwd_sched_id;

    	--- 12/94 get class code for wipipb
    	open per_bal;
    	fetch per_bal INTO x_class_code;
    	close per_bal;

    	wip_change_status.insert_period_balances(x_wip_id,
					p_org_id, p_rollfwd_sched_id,
                               		x_line_id, x_class_code);

	x_dummy := fnd_release.get_release(x_rel, x_info);

        if instr(x_info, 'SC') <> 0 then
           wip_osp.release_validation(x_wip_id, p_org_id, p_rollfwd_sched_id);
	end if;

    	-- set quantity in the queue

    	UPDATE wip_operations wo
      	 SET wo.quantity_in_queue = x_rollfwd_qty,
           wo.last_update_date = SYSDATE,
           wo.last_updated_by = x_user_id,
           wo.request_id = decode(x_request_id, 0, wo.request_id,
                                  x_request_id),
           wo.program_application_id =
              decode(x_appl_id, 0, wo.program_application_id, x_appl_id),
           wo.program_id = decode(x_program_id, 0, wo.program_id,
                                  x_program_id),
           wo.program_update_date =
              decode(x_program_id, 0, wo.program_update_date, SYSDATE)
    	 WHERE wo.organization_id = p_org_id
      	 AND wo.wip_entity_id = x_wip_id
      	 AND wo.repetitive_schedule_id = p_rollfwd_sched_id
      	 AND wo.operation_seq_num = x_rollfwd_first_op;

  END IF;

END ROLL_FORWARD;

PROCEDURE ROLL_FORWARD_COVER
                  (p_closed_sched_id    IN     NUMBER,
                   p_rollfwd_sched_id   IN     NUMBER,
                   p_rollfwd_type       IN     NUMBER,
                   p_org_id             IN     NUMBER,
                   p_update_status      IN     NUMBER,
		   p_success_flag       OUT    NOCOPY NUMBER,
		   p_error_msg	 	OUT    NOCOPY VARCHAR2) IS
x_sched NUMBER := p_rollfwd_sched_id;
x_update_status BOOLEAN;
BEGIN

IF p_update_status = 1 THEN
	x_update_status := TRUE;
ELSE
	x_update_status := FALSE;
END IF;

ROLL_FORWARD(p_closed_sched_id,
	     x_sched,
	     p_rollfwd_type,
	     p_org_id,
	     x_update_status);

p_success_flag := 1;

EXCEPTION

	WHEN OTHERS THEN
		p_success_flag := 0;
		p_error_msg := FND_MESSAGE.get;

END ROLL_FORWARD_COVER;

PROCEDURE get_first_last_sched
	( p_wip_entity_id	IN 	NUMBER,
	  p_org_id		IN	NUMBER,
	  p_line_id		IN 	NUMBER,
	  x_first_sched_id	OUT	NOCOPY NUMBER,
	  x_last_sched_id 	OUT	NOCOPY NUMBER,
	  x_error_mesg		OUT	NOCOPY VARCHAR2) is
CURSOR first_sched IS
        select wrs.repetitive_schedule_id
        from wip_repetitive_schedules wrs
        where wrs.organization_id = p_org_id
          and wrs.wip_entity_id = p_wip_entity_id
          and wrs.line_id = p_line_id
          and wrs.status_type in (3,4)
        order by wrs.LAST_UNIT_START_DATE asc;

CURSOR last_sched IS
        select wrs.repetitive_schedule_id
        from wip_repetitive_schedules wrs
        where wrs.organization_id = p_org_id
          and wrs.wip_entity_id = p_wip_entity_id
          and wrs.line_id = p_line_id
          and wrs.status_type in (3,4)
        order by wrs.LAST_UNIT_START_DATE desc;

BEGIN
	x_first_sched_id := NULL;
        x_last_sched_id := NULL;

	x_error_mesg := NULL;

   	OPEN first_sched;
	FETCH first_sched into x_first_sched_id;

	IF( first_sched%NOTFOUND) then
		fnd_message.set_name('WIP', 'WIP_INT_ERROR_NO_SCHED ');
		fnd_message.set_token('ROUTINE','get_first_last_sched');
		x_error_mesg := fnd_message.get ;
                CLOSE first_sched;
		return;
	END IF;

   	OPEN last_sched;--if first schedule exists, last exists
	FETCH last_sched into x_last_sched_id;

        CLOSE first_sched;
        CLOSE last_sched;
END get_first_last_sched ;

FUNCTION get_line_id
	( p_rep_sched_id	IN	NUMBER,
	  p_org_id		IN	NUMBER) RETURN NUMBER IS

    l_line_id  number;
    cursor get_line (c_rep_sched_id number,
		     c_org_id number) is
	select line_id
	from wip_repetitive_schedules wrs
	where wrs.repetitive_schedule_id = p_rep_sched_id
	and  wrs.organization_id = p_org_id;

BEGIN
	if p_rep_sched_id = NULL then
		return NULL;
	end if;

	open get_line(p_rep_sched_id, p_org_id);
	fetch get_line into l_line_id;

	if (get_line%NOTFOUND) then
	   l_line_id := NULL;
	end if;

	CLOSE get_line;
	return l_line_id;

END get_line_id;


END WIP_REPETITIVE_UTILITIES;

/
