--------------------------------------------------------
--  DDL for Package Body EAM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DRT_PKG" AS
  /* $Header: eamdrtpb.pls 120.0.12010000.9 2018/05/17 05:02:56 shengywa noship $ */
  --
  -- Package Variables
  --
  L_PACKAGE VARCHAR2(33) DEFAULT 'EAM_DRT_PKG.';

  PROCEDURE EAM_HR_DRC(PERSON_ID  IN NUMBER,
                       RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS

    L_PROC         VARCHAR2(72);
    L_PERSON_ID    NUMBER := PERSON_ID;
    L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE;
    L_CASE_MATCHES VARCHAR2(1) := 'N';
    L_RESULT_TBL   PER_DRT_PKG.RESULT_TBL_TYPE;
    L_USER_ID      NUMBER;

  BEGIN

    L_PROC := L_PACKAGE || 'EAM_HR_DRC';

    IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, 'Entering: ' || L_PROC);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Checking constraints for PERSON_ID:' || L_PERSON_ID);
    END IF;

    -- case ALM-EAM-01 (txn part), ALM-EAM-02: open wo with cost txn:
    L_CASE_MATCHES := 'N';

    BEGIN
      SELECT 'Y'
        INTO L_CASE_MATCHES
        FROM DUAL
       WHERE EXISTS (SELECT WCTI.TRANSACTION_ID
                FROM WIP_COST_TXN_INTERFACE WCTI
               WHERE WCTI.PROCESS_STATUS IN (1, 3) -- 1: pending 3: error
                 AND WCTI.EMPLOYEE_ID = L_PERSON_ID);

      PER_DRT_PKG.add_to_results(person_id   => L_PERSON_ID,
                                 entity_type => EAM_DRT_PKG.ENTITY_TYPE_HR,
                                 status      => 'E',
                                 msgcode     => 'EAM_DRC_OPEN_CST_TXN',
                                 msgaplid    => EAM_DRT_PKG.EAM_APPL_ID,
                                 result_tbl  => L_RESULT_TBL);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_CASE_MATCHES := 'N';
      WHEN OTHERS THEN
        L_CASE_MATCHES := 'N';
    END; -- End case ALM-EAM-01 (txn part), ALM-EAM-02

    -- case ALM-EAM-06, ALM-EAM-01 (part of): has instance assignment for open wo
    L_CASE_MATCHES := 'N';

    BEGIN
      SELECT 'Y'
        INTO L_CASE_MATCHES
        FROM DUAL
       WHERE EXISTS (SELECT WIV.INSTANCE_ID, BRE.Person_Id
                FROM WIP_ENTITIES                WE,
                     BOM_RESOURCE_EMPLOYEES      BRE,
                     WIP_OP_RESOURCE_INSTANCES_V WIV,
                     WIP_DISCRETE_JOBS           WDJ
               WHERE BRE.INSTANCE_ID = WIV.INSTANCE_ID
                 AND BRE.Organization_Id = WIV.organization_id
                 AND WE.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
                 AND WIV.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
                 AND WDJ.MAINTENANCE_OBJECT_TYPE = 3
                 AND WDJ.MAINTENANCE_OBJECT_SOURCE <> 2
                 AND NVL(WDJ.STATUS_TYPE, 3) IN (17, 1, 3, 6)
                 AND BRE.Person_Id = L_PERSON_ID);

      PER_DRT_PKG.add_to_results(person_id   => L_PERSON_ID,
                                 entity_type => EAM_DRT_PKG.ENTITY_TYPE_HR,
                                 status      => 'E',
                                 msgcode     => 'EAM_DRC_OPEN_WO',
                                 msgaplid    => EAM_DRT_PKG.EAM_APPL_ID,
                                 result_tbl  => L_RESULT_TBL);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_CASE_MATCHES := 'N';
      WHEN OTHERS THEN
        L_CASE_MATCHES := 'N';
    END; -- End case ALM-EAM-06, ALM-EAM-01 (part of)

    -- case ALM-EAM-08: active resources instances with employee
    L_CASE_MATCHES := 'N';

    BEGIN
      SELECT 'Y'
        INTO L_CASE_MATCHES
        FROM DUAL
       WHERE EXISTS (SELECT BRE.INSTANCE_ID
                FROM BOM_RESOURCE_EMPLOYEES   BRE,
                     BOM_DEPT_RES_INSTANCES   BDRI,
                     BOM_DEPARTMENT_RESOURCES BDR,
                     BOM_DEPARTMENTS          BD
               WHERE BRE.PERSON_ID = L_PERSON_ID
                 AND BRE.EFFECTIVE_START_DATE <= SYSDATE
                 AND NVL(BRE.EFFECTIVE_END_DATE, SYSDATE + 1) >= SYSDATE
                 AND BD.DEPARTMENT_ID = BDR.DEPARTMENT_ID
                 AND BDRI.INSTANCE_ID = BRE.INSTANCE_ID
                 AND (BDRI.DEPARTMENT_ID = BDR.DEPARTMENT_ID OR
                     BDRI.DEPARTMENT_ID = BDR.SHARE_FROM_DEPT_ID)
                 AND BDR.RESOURCE_ID = BDRI.RESOURCE_ID);

      PER_DRT_PKG.add_to_results(person_id   => L_PERSON_ID,
                                 entity_type => EAM_DRT_PKG.ENTITY_TYPE_HR,
                                 status      => 'W',
                                 msgcode     => 'EAM_DRC_RES_INS_ASSIGNED',
                                 msgaplid    => EAM_DRT_PKG.EAM_APPL_ID,
                                 result_tbl  => L_RESULT_TBL);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_CASE_MATCHES := 'N';
      WHEN OTHERS THEN
      L_CASE_MATCHES := 'N';
    END; -- End case ALM-EAM-08

    /* For bug 28026644: Remove this validation since this is duplicate with ALM-EAM-06
    -- case ALM-EAM-07: open work orders with employee lov
    L_CASE_MATCHES := 'N';

    BEGIN
      SELECT 'Y'
        INTO L_CASE_MATCHES
        FROM DUAL
       WHERE EXISTS (SELECT BRE.PERSON_ID
                FROM WIP_OPERATION_RESOURCE_USAGE WORU,
                     WIP_DISCRETE_JOBS            WDJ,
                     EAM_WORK_ORDER_DETAILS       EWOD,
                     BOM_RESOURCE_EMPLOYEES       BRE
               WHERE BRE.PERSON_ID = L_PERSON_ID
                 AND BRE.EFFECTIVE_START_DATE <= SYSDATE
                 AND NVL(BRE.EFFECTIVE_END_DATE, SYSDATE + 1) >= SYSDATE
                 AND WORU.INSTANCE_ID = BRE.INSTANCE_ID
                 AND WDJ.WIP_ENTITY_ID = WORU.WIP_ENTITY_ID
                 AND WDJ.ORGANIZATION_ID = WORU.ORGANIZATION_ID
                 AND WDJ.WIP_ENTITY_ID = EWOD.WIP_ENTITY_ID
                 AND WDJ.ORGANIZATION_ID = EWOD.ORGANIZATION_ID
                 AND NVL(WDJ.STATUS_TYPE, 3) IN (17, 1, 3, 6)
                 AND WORU.INSTANCE_ID IS NOT NULL);

      PER_DRT_PKG.add_to_results(person_id   => L_PERSON_ID,
                                 entity_type => EAM_DRT_PKG.ENTITY_TYPE_HR,
                                 status      => 'W',
                                 msgcode     => 'EAM_DRC_CREW_ASSIGNED',
                                 msgaplid    => EAM_DRT_PKG.EAM_APPL_ID,
                                 result_tbl  => L_RESULT_TBL);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_CASE_MATCHES := 'N';
      WHEN OTHERS THEN
        L_CASE_MATCHES := 'N';
    END; -- End case ALM-EAM-07
    */

    -- cases ALM-EAM-09 and ALM-EAM-11: Both cases uses user_id but displays person name, so we'll put both case in HR check
    BEGIN
      SELECT USER_ID
        INTO L_USER_ID
        FROM FND_USER FU
       WHERE FU.EMPLOYEE_ID = L_PERSON_ID;

      -- case ALM-EAM-09: Active PM Schedules with reviewer assignment
      BEGIN
        SELECT 'Y'
          INTO L_CASE_MATCHES
          FROM DUAL
         WHERE EXISTS
         (SELECT EPS.PM_SCHEDULE_ID
                  FROM EAM_PM_SCHEDULINGS EPS
                 WHERE NVL(EPS.TO_EFFECTIVE_DATE, SYSDATE + 1) >= SYSDATE
                   AND EPS.LAST_REVIEWED_BY = L_USER_ID);

        PER_DRT_PKG.ADD_TO_RESULTS(PERSON_ID   => L_PERSON_ID,
                                   ENTITY_TYPE => EAM_DRT_PKG.ENTITY_TYPE_HR,
                                   STATUS      => 'W',
                                   MSGCODE     => 'EAM_DRC_PM_REVIEWER',
                                   MSGAPLID    => EAM_DRT_PKG.EAM_APPL_ID,
                                   RESULT_TBL  => L_RESULT_TBL);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END; -- End case ALM-EAM-09

      -- case ALM-EAM-11: Asset Operatonal Log - Assign to another employee - Asset Check In/Out For User;Asset Operatonal Log
      BEGIN
        SELECT 'Y'
          INTO L_CASE_MATCHES
          FROM DUAL
         WHERE EXISTS
         (SELECT EAOT.USER_ID
                  FROM EAM_ASSET_OPERATION_TXN EAOT, CSI_ITEM_INSTANCES CII
                 WHERE EAOT.INSTANCE_ID = CII.INSTANCE_ID
                   AND EAOT.USER_ID = L_USER_ID)
            OR EXISTS (SELECT EAL.CREATED_BY
                  FROM EAM_ASSET_LOG EAL
                 WHERE EAL.CREATED_BY = L_USER_ID);

        PER_DRT_PKG.ADD_TO_RESULTS(PERSON_ID   => L_PERSON_ID,
                                   ENTITY_TYPE => EAM_DRT_PKG.ENTITY_TYPE_HR,
                                   STATUS      => 'W',
                                   MSGCODE     => 'EAM_DRC_ASSET_LOG',
                                   MSGAPLID    => EAM_DRT_PKG.EAM_APPL_ID,
                                   RESULT_TBL  => L_RESULT_TBL);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END; -- End case ALM-EAM-11

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
    END; -- End cases ALM-EAM-09 and ALM-EAM-11

    RESULT_TBL := L_RESULT_TBL;

  EXCEPTION
    WHEN OTHERS THEN
      RESULT_TBL := L_RESULT_TBL;

  END EAM_HR_DRC;

  PROCEDURE EAM_FND_DRC(PERSON_ID  IN NUMBER,
                        RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS

    L_PROC         VARCHAR2(72);
    L_USER_NAME    FND_USER.USER_NAME%TYPE;
    L_PERSON_ID    NUMBER := PERSON_ID;
    L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE;
    L_RESULT_TBL   PER_DRT_PKG.RESULT_TBL_TYPE;
    L_CASE_MATCHES VARCHAR2(1) := 'N';

  BEGIN

    L_PROC := L_PACKAGE || 'EAM_FND_DRC';

    IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, 'Entering: ' || L_PROC);
    END IF;

    -- check user_name for person_id
    BEGIN
      SELECT USER_NAME
        INTO L_USER_NAME
        FROM FND_USER
       WHERE USER_ID = L_PERSON_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF L_DEBUG THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: No user info for user_id = ' || L_PERSON_ID);
        END IF;
        RETURN;
      WHEN OTHERS THEN
        IF L_DEBUG THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: No user info for user_id = ' || L_PERSON_ID);
        END IF;
        RETURN;
    END;

    IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Checking constraints for user_id = ' || L_PERSON_ID);
    END IF;

    -- case ALM-EAM-03, ALM-EAM-04, ALM-EAM-05: has pending AME?
    -- Removed: Upstream product WF will handle this.

    -- case ALM-EAM-10: open wr for created_for:
    L_CASE_MATCHES := 'N';

    BEGIN
      SELECT 'Y'
        INTO L_CASE_MATCHES
        FROM DUAL
       WHERE EXISTS (SELECT WEWR.CREATED_FOR
                FROM WIP_EAM_WORK_REQUESTS WEWR
               WHERE WEWR.MAINTENANCE_OBJECT_TYPE = 3
                 AND (WEWR.CREATED_FOR = L_PERSON_ID OR
                     WEWR.CREATED_BY = L_PERSON_ID)
                 AND NVL(WEWR.WORK_REQUEST_STATUS_ID, 1) IN (1, 2, 3, 4));

      PER_DRT_PKG.add_to_results(person_id   => L_PERSON_ID,
                                 entity_type => EAM_DRT_PKG.ENTITY_TYPE_FND,
                                 status      => 'W',
                                 msgcode     => 'EAM_DRC_OPEN_WR',
                                 msgaplid    => EAM_DRT_PKG.EAM_APPL_ID,
                                 result_tbl  => L_RESULT_TBL);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_CASE_MATCHES := 'N';
      WHEN OTHERS THEN
        L_CASE_MATCHES := 'N';
    END; -- End case ALM-EAM-10

    RESULT_TBL := L_RESULT_TBL;

  EXCEPTION
    WHEN OTHERS THEN
      RESULT_TBL := L_RESULT_TBL;

  END EAM_FND_DRC;

END EAM_DRT_PKG;

/
