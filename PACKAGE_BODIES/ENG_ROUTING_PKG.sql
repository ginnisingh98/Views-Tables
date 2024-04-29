--------------------------------------------------------
--  DDL for Package Body ENG_ROUTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ROUTING_PKG" AS
/* $Header: ENGPRTRB.pls 120.4 2006/05/05 02:13:32 prgopala noship $ */

-- +--------------------------- ROUTING_UPDATE -------------------------------+
-- NAME
-- ROUTING_UPDATE

-- DESCRIPTION
-- Update Routings: Flip routing_type to 1 (manufacturing)

-- REQUIRES
-- org_id: organization id
-- eng_item_id: routing that requires routing type to be set to 1
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_rtg_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE ROUTING_UPDATE
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_rtg_designator		IN VARCHAR2,
X_effectivity_date		IN DATE
)
IS
  X_stmt_num	NUMBER;
BEGIN

  X_stmt_num := 500;
  UPDATE BOM_OPERATIONAL_ROUTINGS
  SET ROUTING_TYPE = 1
  WHERE ORGANIZATION_ID = X_org_id
  AND ASSEMBLY_ITEM_ID = X_eng_item_id
  AND ((X_designator_option = 2 AND
        ALTERNATE_ROUTING_DESIGNATOR IS NULL)
       OR
       (X_designator_option = 3 AND
        ALTERNATE_ROUTING_DESIGNATOR = X_alt_rtg_designator)
       OR
       X_designator_option = 1);

  IF ( X_transfer_option <> 1 ) THEN
    X_stmt_num := 501;
    DELETE FROM BOM_OPERATION_SEQUENCES BOS
    WHERE ((X_transfer_option = 2
            AND (BOS.EFFECTIVITY_DATE > X_effectivity_date
                 OR NVL(BOS.DISABLE_DATE, X_effectivity_date+1) <
		 X_effectivity_date))
        OR (X_transfer_option = 3
            AND NVL(BOS.DISABLE_DATE, X_effectivity_date + 1) <
		X_effectivity_date))
    AND EXISTS (SELECT 'X'
                FROM BOM_OPERATIONAL_ROUTINGS BOR
                WHERE ORGANIZATION_ID = X_org_id
                AND ASSEMBLY_ITEM_ID = X_eng_item_id
                AND ROUTING_TYPE = 1
                AND BOS.ROUTING_SEQUENCE_ID = BOR.ROUTING_SEQUENCE_ID
                AND ((X_designator_option = 2 AND ALTERNATE_ROUTING_DESIGNATOR IS NULL)
                  OR (X_designator_option = 3 AND ALTERNATE_ROUTING_DESIGNATOR = X_alt_rtg_designator)
                  OR (X_designator_option = 1)));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ROUTING_UPDATE',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);

END ROUTING_UPDATE;

-- +--------------------------- ROUTING_TRANSFER -----------------------------+
-- NAME
-- ROUTING_TRANSFER

-- DESCRIPTION
-- Transfer Routings

-- REQUIRES
-- org_id: organization id
-- eng_item_id
-- mfg_item_id
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- transfer option
--   1. all rows
--   2. current only
--   3. current and pending
-- alt_rtg_designator
-- effectivity_date
-- last_login_id  not used internally just kept to support already existing usage
-- ecn_name

-- OUTPUT

-- RETURNS
-- 1 SUCCESS
-- 2 FAILURE

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE ROUTING_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_rtg_designator		IN VARCHAR2,
X_effectivity_date		IN DATE,
X_last_login_id                 IN NUMBER,
X_ecn_name			IN VARCHAR2
)
IS
  X_stmt_num			NUMBER;
  X_from_rtg_sequence_id	NUMBER;

  CURSOR RTG_CURSOR IS
    SELECT ROUTING_SEQUENCE_ID, ALTERNATE_ROUTING_DESIGNATOR
    FROM BOM_OPERATIONAL_ROUTINGS
    WHERE ORGANIZATION_ID = X_org_id
    AND ASSEMBLY_ITEM_ID = X_mfg_item_id
    AND COMMON_ROUTING_SEQUENCE_ID = ROUTING_SEQUENCE_ID;

  -- BUG 3503220
  CURSOR RTG_COPIES IS
    SELECT ROUTING_SEQUENCE_ID, ALTERNATE_ROUTING_DESIGNATOR
    FROM BOM_OPERATIONAL_ROUTINGS BOR
    WHERE ORGANIZATION_ID = X_org_id
    AND ASSEMBLY_ITEM_ID = X_mfg_item_id
    AND COMMON_ROUTING_SEQUENCE_ID = ROUTING_SEQUENCE_ID
    AND ((X_designator_option = 2 AND
          BOR.ALTERNATE_ROUTING_DESIGNATOR IS NULL)
         OR
         (X_designator_option = 3 AND
          BOR.ALTERNATE_ROUTING_DESIGNATOR = X_alt_rtg_designator)
         OR
         X_designator_option = 1);
BEGIN

  X_stmt_num := 800;

  --- BOM_OPERATIONAL_ROUTINGS
  -- Bug 5104285 Added all columns in the insert. Otherwise flow routing was being
  -- copied as a normal routing.
  BEGIN
    INSERT INTO BOM_OPERATIONAL_ROUTINGS(
      ROUTING_SEQUENCE_ID,
      ASSEMBLY_ITEM_ID,
      ORGANIZATION_ID,
      ALTERNATE_ROUTING_DESIGNATOR,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      ROUTING_TYPE,
      COMMON_ASSEMBLY_ITEM_ID,
      COMMON_ROUTING_SEQUENCE_ID,
      ROUTING_COMMENT,
      COMPLETION_SUBINVENTORY,
      COMPLETION_LOCATOR_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      LINE_ID,
      CFM_ROUTING_FLAG,
      MIXED_MODEL_MAP_FLAG,
      PRIORITY,
      TOTAL_PRODUCT_CYCLE_TIME,
      CTP_FLAG,
      PROJECT_ID,
      TASK_ID,
      PENDING_FROM_ECN,
      ORIGINAL_SYSTEM_REFERENCE,
      SERIALIZATION_START_OP)
    SELECT
      BOM_OPERATIONAL_ROUTINGS_S.NEXTVAL,
      X_mfg_item_id,
      BOR.ORGANIZATION_ID,
      BOR.ALTERNATE_ROUTING_DESIGNATOR,
      SYSDATE,
      to_number(Fnd_Profile.Value('USER_ID')),
      SYSDATE,
      to_number(Fnd_Profile.Value('USER_ID')),
      to_number(Fnd_Profile.Value('LOGIN_ID')),
      1,
      BOR.COMMON_ASSEMBLY_ITEM_ID,
      DECODE(BOR.COMMON_ROUTING_SEQUENCE_ID,BOR.ROUTING_SEQUENCE_ID,BOM_OPERATIONAL_ROUTINGS_S.CURRVAL,BOR.COMMON_ROUTING_SEQUENCE_ID),
      BOR.ROUTING_COMMENT,
      BOR.COMPLETION_SUBINVENTORY,
      BOR.COMPLETION_LOCATOR_ID,
      BOR.ATTRIBUTE_CATEGORY,
      BOR.ATTRIBUTE1,
      BOR.ATTRIBUTE2,
      BOR.ATTRIBUTE3,
      BOR.ATTRIBUTE4,
      BOR.ATTRIBUTE5,
      BOR.ATTRIBUTE6,
      BOR.ATTRIBUTE7,
      BOR.ATTRIBUTE8,
      BOR.ATTRIBUTE9,
      BOR.ATTRIBUTE10,
      BOR.ATTRIBUTE11,
      BOR.ATTRIBUTE12,
      BOR.ATTRIBUTE13,
      BOR.ATTRIBUTE14,
      BOR.ATTRIBUTE15,
      LINE_ID,
      CFM_ROUTING_FLAG,
      MIXED_MODEL_MAP_FLAG,
      PRIORITY,
      TOTAL_PRODUCT_CYCLE_TIME,
      CTP_FLAG,
      PROJECT_ID,
      TASK_ID,
      PENDING_FROM_ECN,
      ORIGINAL_SYSTEM_REFERENCE,
      SERIALIZATION_START_OP
    FROM BOM_OPERATIONAL_ROUTINGS BOR
    WHERE ORGANIZATION_ID = X_org_id
    AND ASSEMBLY_ITEM_ID = X_eng_item_id
    AND ((X_designator_option = 2 AND
          BOR.ALTERNATE_ROUTING_DESIGNATOR IS NULL)
         OR
         (X_designator_option = 3 AND
          BOR.ALTERNATE_ROUTING_DESIGNATOR = X_alt_rtg_designator)
         OR
         X_designator_option = 1);
  EXCEPTION
    WHEN OTHERS THEN
      ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ROUTING_TRANSFER',
                                           stmt_num => X_stmt_num,
                                           message_name => 'ENG_ENUBRT_ERROR',
                                           token => SQLERRM);
  END;

  -- bug 3780577 : odaboval moved the ERES call after the LOOP
  --               in order to see the routing revisions:
  /* THIS ERES CALL IS NOT MOVED TO A PLACE BELOW.
  -- ERES BEGIN
  -- If there is a parent eRecord, log a child record to accompany it
  -- ================================================================
  IF ENG_BOM_RTG_TRANSFER_PKG.G_PARENT_ERECORD_ID is NOT NULL THEN
    FOR ROUTING IN RTG_COPIES LOOP
      ENG_BOM_RTG_TRANSFER_PKG.Process_Erecord
      ( p_event_name       =>'oracle.apps.bom.routingCreate'
      , p_event_key        =>to_char(ROUTING.routing_sequence_id)
      , p_user_key         =>ENG_BOM_RTG_TRANSFER_PKG.G_ITEM_NAME
                             ||'-'||ENG_BOM_RTG_TRANSFER_PKG.G_ORG_CODE||'-'||ROUTING.alternate_routing_designator
      , p_parent_event_key =>to_char(X_eng_item_id)||'-'||to_char(X_org_id)
                             ||'-'||to_char(X_mfg_item_id)
      );
    END LOOP;
  END IF;
  NOT USED ANYMORE. PLEASE SEE CALL BELOW. */
  -- ERES END
  -- ========

  FOR RTG IN RTG_CURSOR LOOP

    X_stmt_num := 801;
    BEGIN
      SELECT ROUTING_SEQUENCE_ID
      INTO X_from_rtg_sequence_id
      FROM BOM_OPERATIONAL_ROUTINGS
      WHERE ORGANIZATION_ID = X_org_id
      AND ASSEMBLY_ITEM_ID = X_eng_item_id
      AND NVL(ALTERNATE_ROUTING_DESIGNATOR,'NONE') = NVL(RTG.ALTERNATE_ROUTING_DESIGNATOR,'NONE');
    EXCEPTION
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ROUTING_TRANSFER',
                                             stmt_num => X_stmt_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);
    END;

    BOM_COPY_ROUTING.COPY_ROUTING(from_sequence_id => X_from_rtg_sequence_id,
                                  to_sequence_id => RTG.ROUTING_SEQUENCE_ID,
                                  from_org_id => X_org_id,
                                  to_org_id => X_org_id,
                                  display_option => X_transfer_option,
                                  user_id => to_number(Fnd_Profile.Value('USER_ID')),
                                  to_item_id => X_mfg_item_id,
                                  direction => 4,
                                  to_alternate => RTG.ALTERNATE_ROUTING_DESIGNATOR,
                                  rev_date => X_effectivity_date);

    IF (X_designator_option = 3 AND X_alt_rtg_designator IS NOT NULL) THEN -- bug 3570053
       UPDATE BOM_OPERATIONAL_ROUTINGS
       SET ALTERNATE_ROUTING_DESIGNATOR = NULL
       WHERE ROUTING_SEQUENCE_ID = RTG.ROUTING_SEQUENCE_ID;
    END IF;
  END LOOP;

  -- bug 3780577 : odaboval moved the ERES RoutingCreate here
  --               in order to get the routing revisions.
  -- ERES BEGIN
  -- If there is a parent eRecord, log a child record to accompany it
  -- ================================================================
  IF ENG_BOM_RTG_TRANSFER_PKG.G_PARENT_ERECORD_ID is NOT NULL THEN
    FOR ROUTING IN RTG_COPIES LOOP
      ENG_BOM_RTG_TRANSFER_PKG.Process_Erecord
      ( p_event_name       =>'oracle.apps.bom.routingCreate'
      , p_event_key        =>to_char(ROUTING.routing_sequence_id)
      , p_user_key         =>ENG_BOM_RTG_TRANSFER_PKG.G_ITEM_NAME
                             ||'-'||ENG_BOM_RTG_TRANSFER_PKG.G_ORG_CODE||'-'||ROUTING.alternate_routing_designator
      , p_parent_event_key =>to_char(X_eng_item_id)||'-'||to_char(X_org_id)
                             ||'-'||to_char(X_mfg_item_id)
      );
    END LOOP;
  END IF;
  -- ERES END
  -- ========
END ROUTING_TRANSFER;

END ENG_ROUTING_PKG;

/
