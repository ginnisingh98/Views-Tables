--------------------------------------------------------
--  DDL for Package Body WIP_WS_EXCEPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_EXCEPTIONS" as
/* $Header: wipvexcb.pls 120.2 2005/11/21 03:43:47 amgarg noship $ */


 /*
  * Close all exceptions for a Job
  */
  FUNCTION CLOSE_EXCEPTION_JOB
  (
    P_WIP_ENTITY_ID NUMBER,
    P_ORGANIZATION_ID NUMBER
  ) RETURN BOOLEAN
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    UPDATE
      WIP_EXCEPTIONS
    SET
      STATUS_TYPE = 2,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      STATUS_TYPE = 1;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END CLOSE_EXCEPTION_JOB;


 /*
  * Close exception for a Job Op combination
  */
  FUNCTION close_exception_jobop
  (
    p_wip_entity_id number,
    P_OPERATION_SEQ_NUM NUMBER,
    P_ORGANIZATION_ID NUMBER
  ) RETURN BOOLEAN
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    UPDATE
      WIP_EXCEPTIONS
    SET
      STATUS_TYPE = 2,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      STATUS_TYPE = 1;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exception_jobop;

 /*
  * Close exception for a Job Op combination
  * check if department changed, close exception.
  */
  FUNCTION CLOSE_EXCEPTION_JOBOP
  (
    P_WIP_ENTITY_ID NUMBER,
    P_OPERATION_SEQ_NUM NUMBER,
    P_DEPARTMENT_ID NUMBER,
    P_ORGANIZATION_ID NUMBER
  ) RETURN BOOLEAN
  IS
    RETURN_STATUS BOOLEAN := TRUE;
    L_ROW_COUNT NUMBER := 0;
  BEGIN

    SAVEPOINT WIPVEXC;

    --Select row, if deptt id has changed.
    SELECT COUNT(*) INTO L_ROW_COUNT FROM
      WIP_OPERATIONS
    WHERE
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      NVL(DEPARTMENT_ID, '-9999') <> NVL(P_DEPARTMENT_ID, '-9999');

    /* CLOSE EXCEPTION ONLY IF DEPTT ID CHANGED */
    IF (L_ROW_COUNT > 0) THEN
      UPDATE
        WIP_EXCEPTIONS
      SET
        STATUS_TYPE = 2,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID
      WHERE
        ORGANIZATION_ID = P_ORGANIZATION_ID AND
        WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
        OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
        STATUS_TYPE = 1;
     END IF;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END CLOSE_EXCEPTION_JOBOP;


 /*
  * Close exception for a Job,Op,Res combination
  */
  function close_exception_jobop_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    UPDATE
      WIP_EXCEPTIONS
    SET
      STATUS_TYPE = 2,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      RESOURCE_SEQ_NUM = P_RESOURCE_SEQ_NUM AND
      STATUS_TYPE = 1;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exception_jobop_res;

 /*
  * Close exception for a Job,Op,Res combination.
  * Check if Resource Id changed, only then close exceptions.
  */
  function close_exception_jobop_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
    L_ROW_COUNT NUMBER := 0;
  BEGIN

    SAVEPOINT WIPVEXC;

    --Select row, if RESOURCE id has changed.
    SELECT COUNT(*) INTO L_ROW_COUNT FROM
      WIP_OPERATION_RESOURCES
    WHERE
      WIP_ENTITY_ID     = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      RESOURCE_SEQ_NUM  = P_RESOURCE_SEQ_NUM AND
      ORGANIZATION_ID   = P_ORGANIZATION_ID AND
      RESOURCE_ID <> P_RESOURCE_ID;

    /* CLOSE EXCEPTION ONLY IF RESOURCE ID CHANGED */
    IF (L_ROW_COUNT > 0) THEN
      UPDATE
        WIP_EXCEPTIONS
      SET
        STATUS_TYPE = 2,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID
      WHERE
        ORGANIZATION_ID = P_ORGANIZATION_ID AND
        WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
        OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
        RESOURCE_SEQ_NUM = P_RESOURCE_SEQ_NUM AND
        STATUS_TYPE = 1;
    END IF;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exception_jobop_res;

 /*
  * Close exception for a Job,Op,Res combination
  * Check if either resource_id changed or department_id changed, close exceptions
  */
  function close_exception_jobop_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_department_code varchar2,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
    L_ROW_COUNT NUMBER := 0;
  BEGIN

    SAVEPOINT WIPVEXC;

    --Select row, if RESOURCE ID OR DEPTT ID has changed.
    --SINCE WE HAVE DEPTT CODE, WE NEED DEPTT ID FROM BOM_DEPTT
    SELECT COUNT(*) INTO L_ROW_COUNT FROM
      WIP_OPERATION_RESOURCES
    WHERE
      WIP_ENTITY_ID     = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      RESOURCE_SEQ_NUM  = P_RESOURCE_SEQ_NUM AND
      ORGANIZATION_ID   = P_ORGANIZATION_ID AND
        (RESOURCE_ID      <> P_RESOURCE_ID
        OR DEPARTMENT_ID  <>
              (SELECT DEPARTMENT_ID FROM BOM_DEPARTMENTS
                WHERE ORGANIZATION_ID = P_ORGANIZATION_ID AND
                DEPARTMENT_CODE = P_DEPARTMENT_CODE)
        );

    /* CLOSE EXCEPTION ONLY IF RESOURCE ID CHANGED */
    IF (L_ROW_COUNT > 0) THEN
      UPDATE
        WIP_EXCEPTIONS
      SET
        STATUS_TYPE = 2,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID
      WHERE
        ORGANIZATION_ID = P_ORGANIZATION_ID AND
        WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
        OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
        RESOURCE_SEQ_NUM = P_RESOURCE_SEQ_NUM AND
        STATUS_TYPE = 1;
    END IF;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exception_jobop_res;



 /*
  * Close exception for a Job,Op,Replacement Group Num combination
  * Resolves exception when altenates are assigned.
  */
  function close_exception_alt_res
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_substitute_group_num number,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    UPDATE
      WIP_EXCEPTIONS
    SET
      STATUS_TYPE = 2,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      STATUS_TYPE = 1 AND
      RESOURCE_SEQ_NUM IN
      (
        SELECT
          RESOURCE_SEQ_NUM
        FROM
          WIP_OPERATION_RESOURCES WOR
        WHERE
          WOR.ORGANIZATION_ID = P_ORGANIZATION_ID AND
          WOR.WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
          WOR.OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
          WOR.SUBSTITUTE_GROUP_NUM = P_SUBSTITUTE_GROUP_NUM
        UNION
        SELECT
          RESOURCE_SEQ_NUM
        FROM
          WIP_SUB_OPERATION_RESOURCES WSOR
        WHERE
          WSOR.ORGANIZATION_ID = P_ORGANIZATION_ID AND
          WSOR.WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
          WSOR.OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
          WSOR.SUBSTITUTE_GROUP_NUM = P_SUBSTITUTE_GROUP_NUM
      );

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exception_alt_res;


 /*
  * Close exception for a Job,Op,Res Instance combination
  * when doing a res Instance delete.
  * Serial Number field is ALSO used.
  * for any Machine Instance.
  */
  FUNCTION close_exception_res_instance
  (
    p_wip_entity_id number,
    P_OPERATION_SEQ_NUM NUMBER,
    P_RESOURCE_SEQ_NUM NUMBER,
    P_INSTANCE_ID NUMBER,
    P_SERIAL_NUMBER VARCHAR2,
    P_ORGANIZATION_ID NUMBER
  ) RETURN BOOLEAN
  IS
    RETURN_STATUS BOOLEAN := TRUE;
    L_EQUIP_ITEM_ID NUMBER;
  BEGIN

    SAVEPOINT WIPVEXC;

    SELECT INVENTORY_ITEM_ID
    INTO  L_EQUIP_ITEM_ID
    FROM BOM_RESOURCE_EQUIPMENTS
    WHERE INSTANCE_ID = P_INSTANCE_ID;

    /*Remember although, for Equipment type exceptions,
    * Serial number cannot be null, we still keep a check for it here.
    */
    UPDATE
      WIP_EXCEPTIONS
    SET
      STATUS_TYPE = 2,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      RESOURCE_SEQ_NUM = P_RESOURCE_SEQ_NUM AND
      EQUIPMENT_ITEM_ID = L_EQUIP_ITEM_ID AND
      NVL(SERIAL_NUMBER, '-9999') = NVL(P_SERIAL_NUMBER, '-9999') AND
      STATUS_TYPE = 1;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exception_res_instance;

 /*
  * Close exception for a Job,Op,Res Instance combination
  * Closes exception when a Res Instance is Updated.
  * Check if Serial_Number is changed, close exception.
  * Otherwise don't need to close.
  */
  function close_exp_res_instance_update
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_resource_seq_num number,
    p_instance_id number,
    p_serial_number varchar2,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
    L_EQUIP_ITEM_ID NUMBER;
    L_ROW_COUNT NUMBER := 0;
    L_SERIAL_NUMBER VARCHAR2(30);
  BEGIN

    SAVEPOINT WIPVEXC;

    SELECT COUNT(*) INTO L_ROW_COUNT
    FROM WIP_OP_RESOURCE_INSTANCES
    WHERE ORGANIZATION_ID = P_ORGANIZATION_ID AND
          WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
          OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
          RESOURCE_SEQ_NUM = P_RESOURCE_SEQ_NUM AND
          INSTANCE_ID = P_INSTANCE_ID AND
          SERIAL_NUMBER <> P_SERIAL_NUMBER;

    /*IF SERIAL NUMBER IS NOT SAME AS ORIGINAL SERIAL NUMBER,
    * WE CLOSE THE EXCEPTION, OTHERWISE NO ACTION.
    */
    IF (L_ROW_COUNT > 0) THEN

      /* Get inventory_item_id, since we don't have instance_id in wip_exceptions*/
      SELECT INVENTORY_ITEM_ID
      INTO  L_EQUIP_ITEM_ID
      FROM BOM_RESOURCE_EQUIPMENTS BRE
      WHERE INSTANCE_ID = P_INSTANCE_ID;

      SELECT SERIAL_NUMBER INTO L_SERIAL_NUMBER
      FROM WIP_OP_RESOURCE_INSTANCES
      WHERE ORGANIZATION_ID = P_ORGANIZATION_ID AND
            WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
            OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
            RESOURCE_SEQ_NUM = P_RESOURCE_SEQ_NUM AND
            INSTANCE_ID = P_INSTANCE_ID;

      UPDATE
        WIP_EXCEPTIONS
      SET
        STATUS_TYPE = 2,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID
      WHERE
        ORGANIZATION_ID = P_ORGANIZATION_ID AND
        WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
        OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
        RESOURCE_SEQ_NUM = P_RESOURCE_SEQ_NUM AND
        EQUIPMENT_ITEM_ID = L_EQUIP_ITEM_ID AND
        NVL(SERIAL_NUMBER, '@@@@@') = NVL(L_SERIAL_NUMBER, '@@@@@') AND
        STATUS_TYPE = 1;
    END IF;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exp_res_instance_update;


 /*
  * Close exception for a Job:Op component.
  * component_item_id is inventory_item_id from WRO.
  */
  function close_exception_component
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_component_item_id number,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    UPDATE
      WIP_EXCEPTIONS
    SET
      STATUS_TYPE = 2,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM AND
      COMPONENT_ITEM_ID = P_COMPONENT_ITEM_ID AND
      STATUS_TYPE = 1;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END close_exception_component;


 /*
  * Close exception for this exception_id.
  */
  function close_exception
  (
    P_exception_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    UPDATE
      WIP_EXCEPTIONS
    SET
      STATUS_TYPE = 2,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
    WHERE
      EXCEPTION_ID = P_EXCEPTION_ID AND
      STATUS_TYPE = 1;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END CLOSE_EXCEPTION;


 /*
  * Delete exception for a Job:Op combination.
  */
  function delete_exception_jobop
  (
    p_wip_entity_id number,
    p_operation_seq_num number,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    DELETE FROM
      WIP_EXCEPTIONS
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID AND
      OPERATION_SEQ_NUM = P_OPERATION_SEQ_NUM;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END delete_exception_jobop;


 /*
  * Delete all exceptions for a Job.
  */
  function delete_exception_job
  (
    p_wip_entity_id number,
    p_organization_id number
  ) return boolean
  IS
    RETURN_STATUS BOOLEAN := TRUE;
  BEGIN

    SAVEPOINT WIPVEXC;

    DELETE FROM
      WIP_EXCEPTIONS
    WHERE
      ORGANIZATION_ID = P_ORGANIZATION_ID AND
      WIP_ENTITY_ID = P_WIP_ENTITY_ID;

    RETURN RETURN_STATUS;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WIPVEXC;
        RETURN_STATUS := FALSE;
        RETURN RETURN_STATUS;

  END delete_exception_job;


END WIP_WS_EXCEPTIONS;


/
