--------------------------------------------------------
--  DDL for Package Body WIP_FIX_REQ_OPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FIX_REQ_OPS_PKG" AS
/* $Header: wiprqfxb.pls 115.7 2002/12/12 15:52:21 rmahidha ship $ */

  PROCEDURE Fix(X_Wip_Entity_Id          NUMBER,
                X_Organization_Id        NUMBER,
                X_Repetitive_Schedule_Id NUMBER,
                X_Entity_Start_Date      DATE) IS
  CURSOR Cdisc IS
	SELECT	DISTINCT ABS(OPERATION_SEQ_NUM) OPERATION_SEQ_NUM
	FROM	WIP_REQUIREMENT_OPERATIONS WRO
	WHERE	WRO.WIP_ENTITY_ID = X_Wip_Entity_Id
	AND	WRO.ORGANIZATION_ID = X_Organization_Id
	AND     NOT EXISTS
		(SELECT 'op exists'
		   FROM WIP_OPERATIONS WO
		  WHERE WO.WIP_ENTITY_ID = WRO.WIP_ENTITY_ID
		    AND WO.ORGANIZATION_ID = WRO.ORGANIZATION_ID
		    AND WO.OPERATION_SEQ_NUM = ABS(WRO.OPERATION_SEQ_NUM));
		    /* Bug fix 1304144*/
  CURSOR Crep IS
	SELECT	DISTINCT OPERATION_SEQ_NUM
	FROM	WIP_REQUIREMENT_OPERATIONS WRO
	WHERE	WRO.WIP_ENTITY_ID = X_Wip_Entity_Id
	AND	WRO.ORGANIZATION_ID = X_Organization_Id
	AND	WRO.REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
	AND     NOT EXISTS
		(SELECT 'op exists'
		   FROM WIP_OPERATIONS WO
		  WHERE WO.WIP_ENTITY_ID = WRO.WIP_ENTITY_ID
		    AND WO.ORGANIZATION_ID = WRO.ORGANIZATION_ID
		    AND WO.REPETITIVE_SCHEDULE_ID = WRO.REPETITIVE_SCHEDULE_ID
		    AND WO.OPERATION_SEQ_NUM = WRO.OPERATION_SEQ_NUM);

  BEGIN
	IF X_Repetitive_Schedule_Id IS NULL THEN
		/* Just update the department and date_required if the op exists */

		UPDATE WIP_REQUIREMENT_OPERATIONS WRO
		   SET (WRO.DEPARTMENT_ID, WRO.DATE_REQUIRED) =
			(SELECT DEPARTMENT_ID, FIRST_UNIT_START_DATE
			   FROM WIP_OPERATIONS WO
			  WHERE WO.WIP_ENTITY_ID = WRO.WIP_ENTITY_ID
			    AND WO.OPERATION_SEQ_NUM = WRO.OPERATION_SEQ_NUM
			    AND WO.ORGANIZATION_ID = WRO.ORGANIZATION_ID)
		 WHERE  WRO.WIP_ENTITY_ID = X_Wip_Entity_Id
		   AND	WRO.ORGANIZATION_ID = X_Organization_Id
		   AND EXISTS
                        (SELECT 'operation exists'
                           FROM WIP_OPERATIONS WO
                          WHERE WO.WIP_ENTITY_ID = WRO.WIP_ENTITY_ID
                            AND WO.OPERATION_SEQ_NUM = WRO.OPERATION_SEQ_NUM
                            AND WO.ORGANIZATION_ID = WRO.ORGANIZATION_ID);

		/* Otherwise treat the same as a deleted operation */

		FOR C1 IN Cdisc LOOP
			WIP_OPERATIONS_UTILITIES.Check_Requirements(
			X_Wip_Entity_Id,
			X_Organization_Id,
			C1.operation_seq_num,
			X_Repetitive_Schedule_Id,
			X_Entity_Start_Date
			);
		END LOOP;
	ELSE
		UPDATE WIP_REQUIREMENT_OPERATIONS WRO
		   SET (WRO.DEPARTMENT_ID, WRO.DATE_REQUIRED) =
			(SELECT DEPARTMENT_ID, FIRST_UNIT_START_DATE
			   FROM WIP_OPERATIONS WO
			  WHERE WO.WIP_ENTITY_ID = WRO.WIP_ENTITY_ID
			    AND WO.OPERATION_SEQ_NUM = WRO.OPERATION_SEQ_NUM
			    AND WO.REPETITIVE_SCHEDULE_ID = WRO.REPETITIVE_SCHEDULE_ID
			    AND WO.ORGANIZATION_ID = WRO.ORGANIZATION_ID)
		 WHERE  WRO.WIP_ENTITY_ID = X_Wip_Entity_Id
		   AND	WRO.ORGANIZATION_ID = X_Organization_Id
		   AND  WRO.REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
		   AND EXISTS
                        (SELECT 'operation exists'
                           FROM WIP_OPERATIONS WO
                          WHERE WO.WIP_ENTITY_ID = WRO.WIP_ENTITY_ID
                            AND WO.OPERATION_SEQ_NUM = WRO.OPERATION_SEQ_NUM
			    AND WO.REPETITIVE_SCHEDULE_ID = WRO.REPETITIVE_SCHEDULE_ID
                            AND WO.ORGANIZATION_ID = WRO.ORGANIZATION_ID);

		FOR C1 IN Crep LOOP
			WIP_OPERATIONS_UTILITIES.Check_Requirements(
			X_Wip_Entity_Id,
			X_Organization_Id,
			C1.operation_seq_num,
			X_Repetitive_Schedule_Id,
			X_Entity_Start_Date
			);
		END LOOP;
	END IF;
  END;

END WIP_FIX_REQ_OPS_PKG;

/
