--------------------------------------------------------
--  DDL for Package Body GMD_FORMULATION_SPECS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULATION_SPECS_PKG" AS
/* $Header: GMDFSTHB.pls 120.3 2006/02/07 02:50:48 srsriran noship $ */

/* Formulation Specification - Table Handlers */

PROCEDURE INSERT_FORMULATION_SPEC(
  X_ROWID			OUT NOCOPY VARCHAR2	,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_VERS			IN NUMBER		,
  X_PRODUCT_ID			IN NUMBER		,
  X_OWNER_ORGANIZATION_ID	IN NUMBER		,
  X_SPEC_STATUS			IN VARCHAR2		,
  X_STD_QTY			IN NUMBER		,
  X_STD_UOM			IN VARCHAR2		,
  X_PROCESS_LOSS		IN NUMBER		,
  X_START_DATE			IN DATE			,
  X_END_DATE			IN DATE			,
  X_MIN_INGREDS			IN NUMBER		,
  X_MAX_INGREDS			IN NUMBER		,
  X_INGRED_PICK_BASE_IND	IN VARCHAR2		,
  X_PICK_LOT_STRATEGY		IN VARCHAR2		,
  X_TECH_PARM_ID		IN NUMBER		,
  X_OBJECTIVE_IND		IN NUMBER		,
  X_ROUTING_ID			IN NUMBER		,
  X_SPEC_NAME			IN VARCHAR2		,
  X_TEXT_CODE			IN VARCHAR2		,
  X_DELETE_MARK			IN NUMBER		,
  X_CREATION_DATE		IN DATE			,
  X_CREATED_BY			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

  CURSOR C IS
   SELECT ROWID
   FROM GMD_FORMULATION_SPECS
   WHERE FORMULATION_SPEC_ID = X_FORMULATION_SPEC_ID;

BEGIN
  INSERT INTO GMD_FORMULATION_SPECS (
    FORMULATION_SPEC_ID,
    SPEC_VERS,
    SPEC_NAME,
    PRODUCT_ID,
    OWNER_ORGANIZATION_ID,
    SPEC_STATUS,
    STD_QTY,
    STD_UOM,
    PROCESS_LOSS,
    START_DATE,
    END_DATE,
    MIN_INGREDS,
    MAX_INGREDS,
    INGRED_PICK_BASE_IND,
    PICK_LOT_STRATEGY,
    TECH_PARM_ID,
    OBJECTIVE_IND,
    ROUTING_ID,
    TEXT_CODE,
    DELETE_MARK,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_FORMULATION_SPEC_ID,
    X_SPEC_VERS,
    X_SPEC_NAME,
    X_PRODUCT_ID,
    X_OWNER_ORGANIZATION_ID,
    X_SPEC_STATUS,
    X_STD_QTY,
    X_STD_UOM,
    X_PROCESS_LOSS,
    X_START_DATE,
    X_END_DATE,
    X_MIN_INGREDS,
    X_MAX_INGREDS,
    X_INGRED_PICK_BASE_IND,
    X_PICK_LOT_STRATEGY,
    X_TECH_PARM_ID,
    X_OBJECTIVE_IND,
    X_ROUTING_ID,
    X_TEXT_CODE,
    X_DELETE_MARK,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END INSERT_FORMULATION_SPEC;


PROCEDURE LOCK_FORMULATION_SPEC (
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_VERS			IN NUMBER		,
  X_PRODUCT_ID			IN NUMBER		,
  X_OWNER_ORGANIZATION_ID	IN NUMBER		,
  X_SPEC_STATUS			IN VARCHAR2		,
  X_STD_QTY			IN NUMBER		,
  X_STD_UOM			IN VARCHAR2		,
  X_PROCESS_LOSS		IN NUMBER		,
  X_START_DATE			IN DATE			,
  X_END_DATE			IN DATE			,
  X_MIN_INGREDS			IN NUMBER		,
  X_MAX_INGREDS			IN NUMBER		,
  X_INGRED_PICK_BASE_IND	IN VARCHAR2		,
  X_PICK_LOT_STRATEGY		IN VARCHAR2		,
  X_TECH_PARM_ID		IN NUMBER		,
  X_OBJECTIVE_IND		IN NUMBER		,
  X_TEXT_CODE			IN VARCHAR2		,
  X_DELETE_MARK			IN NUMBER		,
  X_SPEC_NAME			IN VARCHAR2
) IS
  CURSOR C IS
   SELECT
      SPEC_VERS,
      PRODUCT_ID,
      OWNER_ORGANIZATION_ID,
      SPEC_STATUS,
      STD_QTY,
      STD_UOM,
      PROCESS_LOSS,
      START_DATE,
      END_DATE,
      MIN_INGREDS,
      MAX_INGREDS,
      INGRED_PICK_BASE_IND,
      PICK_LOT_STRATEGY,
      TECH_PARM_ID,
      OBJECTIVE_IND,
      TEXT_CODE,
      DELETE_MARK
    FROM GMD_FORMULATION_SPECS
    WHERE FORMULATION_SPEC_ID = X_FORMULATION_SPEC_ID
    FOR UPDATE OF FORMULATION_SPEC_ID NOWAIT;
  RECINFO C%ROWTYPE;

BEGIN

  OPEN C;
  FETCH C INTO RECINFO;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;
  IF (    (RECINFO.SPEC_VERS = X_SPEC_VERS)
      AND (RECINFO.PRODUCT_ID = X_PRODUCT_ID)
      AND (RECINFO.OWNER_ORGANIZATION_ID = X_OWNER_ORGANIZATION_ID)
      AND (RECINFO.SPEC_STATUS = X_SPEC_STATUS)
      AND (RECINFO.STD_QTY = X_STD_QTY)
      AND (RECINFO.STD_UOM = X_STD_UOM)
      AND ((RECINFO.PROCESS_LOSS = X_PROCESS_LOSS)
           OR ((RECINFO.PROCESS_LOSS IS NULL) AND (X_PROCESS_LOSS IS NULL)))
      AND (RECINFO.START_DATE = X_START_DATE)
      AND ((RECINFO.END_DATE = X_END_DATE)
           OR ((RECINFO.END_DATE IS NULL) AND (X_END_DATE IS NULL)))
      AND ((RECINFO.MIN_INGREDS = X_MIN_INGREDS)
           OR ((RECINFO.MIN_INGREDS IS NULL) AND (X_MIN_INGREDS IS NULL)))
      AND ((RECINFO.MAX_INGREDS = X_MAX_INGREDS)
           OR ((RECINFO.MAX_INGREDS IS NULL) AND (X_MAX_INGREDS IS NULL)))
      AND (RECINFO.INGRED_PICK_BASE_IND = X_INGRED_PICK_BASE_IND)
      AND ((RECINFO.PICK_LOT_STRATEGY = X_PICK_LOT_STRATEGY)
           OR ((RECINFO.PICK_LOT_STRATEGY IS NULL) AND (X_PICK_LOT_STRATEGY IS NULL)))
      AND ((RECINFO.DELETE_MARK = X_DELETE_MARK)
           OR ((RECINFO.DELETE_MARK IS NULL) AND (X_DELETE_MARK IS NULL)))
      AND ((RECINFO.TEXT_CODE = X_TEXT_CODE)
           OR ((RECINFO.TEXT_CODE IS NULL) AND (X_TEXT_CODE IS NULL)))
      AND (RECINFO.TECH_PARM_ID = X_TECH_PARM_ID)
      AND (RECINFO.OBJECTIVE_IND = X_OBJECTIVE_IND)
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  RETURN;
END LOCK_FORMULATION_SPEC;

PROCEDURE UPDATE_FORMULATION_SPEC (
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_PRODUCT_ID			IN NUMBER		,
  X_OWNER_ORGANIZATION_ID	IN NUMBER		,
  X_SPEC_STATUS			IN VARCHAR2		,
  X_STD_QTY			IN NUMBER		,
  X_STD_UOM			IN VARCHAR2		,
  X_PROCESS_LOSS		IN NUMBER		,
  X_START_DATE			IN DATE			,
  X_END_DATE			IN DATE			,
  X_MIN_INGREDS			IN NUMBER		,
  X_MAX_INGREDS			IN NUMBER		,
  X_INGRED_PICK_BASE_IND	IN VARCHAR2		,
  X_PICK_LOT_STRATEGY		IN VARCHAR2		,
  X_TECH_PARM_ID		IN NUMBER		,
  X_OBJECTIVE_IND		IN NUMBER		,
  X_TEXT_CODE			IN VARCHAR2		,
  X_DELETE_MARK			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

BEGIN

  UPDATE GMD_FORMULATION_SPECS
  SET
    PRODUCT_ID			= X_PRODUCT_ID,
    OWNER_ORGANIZATION_ID	= X_OWNER_ORGANIZATION_ID,
    SPEC_STATUS			= X_SPEC_STATUS,
    STD_QTY			= X_STD_QTY,
    STD_UOM			= X_STD_UOM,
    PROCESS_LOSS		= X_PROCESS_LOSS,
    START_DATE			= X_START_DATE,
    END_DATE			= X_END_DATE,
    MIN_INGREDS			= X_MIN_INGREDS,
    MAX_INGREDS			= X_MAX_INGREDS,
    INGRED_PICK_BASE_IND	= X_INGRED_PICK_BASE_IND,
    PICK_LOT_STRATEGY		= X_PICK_LOT_STRATEGY,
    TECH_PARM_ID		= X_TECH_PARM_ID,
    OBJECTIVE_IND		= X_OBJECTIVE_IND,
    DELETE_MARK			= X_DELETE_MARK,
    TEXT_CODE			= X_TEXT_CODE,
    LAST_UPDATE_DATE		= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY		= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN		= X_LAST_UPDATE_LOGIN
  WHERE FORMULATION_SPEC_ID	= X_FORMULATION_SPEC_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_FORMULATION_SPEC;

PROCEDURE DELETE_FORMULATION_SPEC (
  X_FORMULATION_SPEC_ID		IN NUMBER
) IS
BEGIN

  DELETE FROM GMD_FORMULATION_SPECS
  WHERE FORMULATION_SPEC_ID = X_FORMULATION_SPEC_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_FORMULATION_SPEC;

/* END - Formulation Specification - Table Handlers */


/* Material Req - Table Handlers */

PROCEDURE INSERT_MATERIAL_REQ (
  X_ROWID			OUT NOCOPY VARCHAR2	,
  X_MATL_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_LINE_NO			IN NUMBER		,
  X_INVENTORY_ITEM_ID		IN NUMBER		,
  X_ITEM_UOM			IN VARCHAR2		,
  X_MIN_QTY			IN NUMBER		,
  X_MAX_QTY			IN NUMBER		,
  X_RANGE_TYPE			IN NUMBER		,
  X_CREATION_DATE		IN DATE			,
  X_CREATED_BY			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

  CURSOR C IS
   SELECT ROWID
   FROM GMD_MATERIAL_REQS
   WHERE MATL_REQ_ID = X_MATL_REQ_ID;

BEGIN

  INSERT INTO GMD_MATERIAL_REQS (
    FORMULATION_SPEC_ID,
    MATL_REQ_ID,
    SPEC_ATTRIBUTE_ID,
    LINE_NO,
    INVENTORY_ITEM_ID,
    ITEM_UOM,
    MIN_QTY,
    MAX_QTY,
    RANGE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_FORMULATION_SPEC_ID,
    X_MATL_REQ_ID,
    X_SPEC_ATTRIBUTE_ID,
    X_LINE_NO,
    X_INVENTORY_ITEM_ID,
    X_ITEM_UOM,
    X_MIN_QTY,
    X_MAX_QTY,
    X_RANGE_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END INSERT_MATERIAL_REQ;

PROCEDURE LOCK_MATERIAL_REQ (
  X_MATL_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_LINE_NO			IN NUMBER		,
  X_INVENTORY_ITEM_ID		IN NUMBER		,
  X_ITEM_UOM			IN VARCHAR2		,
  X_MIN_QTY			IN NUMBER		,
  X_MAX_QTY			IN NUMBER		,
  X_RANGE_TYPE			IN NUMBER
) IS

  CURSOR C IS
   SELECT
      FORMULATION_SPEC_ID,
      SPEC_ATTRIBUTE_ID,
      LINE_NO,
      INVENTORY_ITEM_ID,
      ITEM_UOM,
      MIN_QTY,
      MAX_QTY
    FROM GMD_MATERIAL_REQS
    WHERE MATL_REQ_ID = X_MATL_REQ_ID
    FOR UPDATE OF MATL_REQ_ID NOWAIT;
  RECINFO C%ROWTYPE;

BEGIN

  OPEN C;
  FETCH C INTO RECINFO;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;
  IF (    (RECINFO.FORMULATION_SPEC_ID = X_FORMULATION_SPEC_ID)
      AND (RECINFO.SPEC_ATTRIBUTE_ID = X_SPEC_ATTRIBUTE_ID)
      AND (RECINFO.LINE_NO = X_LINE_NO)
      AND (RECINFO.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID)
      AND ((RECINFO.ITEM_UOM = X_ITEM_UOM)
           OR ((RECINFO.ITEM_UOM IS NULL) AND (X_ITEM_UOM IS NULL)))
      AND ((RECINFO.MIN_QTY = X_MIN_QTY)
           OR ((RECINFO.MIN_QTY IS NULL) AND (X_MIN_QTY IS NULL)))
      AND ((RECINFO.MAX_QTY = X_MAX_QTY)
           OR ((RECINFO.MAX_QTY IS NULL) AND (X_MAX_QTY IS NULL)))
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;
END LOCK_MATERIAL_REQ;

PROCEDURE UPDATE_MATERIAL_REQ (
  X_MATL_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_LINE_NO			IN NUMBER		,
  X_INVENTORY_ITEM_ID		IN NUMBER		,
  X_ITEM_UOM			IN VARCHAR2		,
  X_MIN_QTY			IN NUMBER		,
  X_MAX_QTY			IN NUMBER		,
  X_RANGE_TYPE			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

BEGIN

  UPDATE GMD_MATERIAL_REQS
  SET
    FORMULATION_SPEC_ID	= X_FORMULATION_SPEC_ID		,
    SPEC_ATTRIBUTE_ID	= X_SPEC_ATTRIBUTE_ID		,
    LINE_NO		= X_LINE_NO			,
    INVENTORY_ITEM_ID	= X_INVENTORY_ITEM_ID		,
    ITEM_UOM		= X_ITEM_UOM			,
    MIN_QTY		= X_MIN_QTY			,
    MAX_QTY		= X_MAX_QTY			,
    LAST_UPDATE_DATE	= X_LAST_UPDATE_DATE		,
    LAST_UPDATED_BY	= X_LAST_UPDATED_BY		,
    LAST_UPDATE_LOGIN	= X_LAST_UPDATE_LOGIN
  WHERE MATL_REQ_ID	= X_MATL_REQ_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_MATERIAL_REQ;

PROCEDURE DELETE_MATERIAL_REQ (
  X_MATL_REQ_ID			IN NUMBER
) IS
BEGIN

  DELETE FROM GMD_MATERIAL_REQS
  WHERE MATL_REQ_ID = X_MATL_REQ_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_MATERIAL_REQ;

/* END - Material Req - Table Handlers */


/* Compositional Req - Table Handlers */

PROCEDURE INSERT_COMPOSITIONAL_REQ (
  X_ROWID			OUT NOCOPY VARCHAR2	,
  X_COMP_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_MIN_PCT			IN NUMBER		,
  X_MAX_PCT			IN NUMBER		,
  X_CATEGORY_SET_ID		IN NUMBER		,
  X_CATEGORY_ID			IN NUMBER		,
  X_PLANNED_PCT			IN NUMBER		,
  X_ORDER_NO			IN NUMBER		,
  X_CREATION_DATE		IN DATE			,
  X_CREATED_BY			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

  CURSOR C IS
   SELECT ROWID
   FROM GMD_COMPOSITIONAL_REQS
   WHERE COMP_REQ_ID = X_COMP_REQ_ID;

BEGIN
  INSERT INTO GMD_COMPOSITIONAL_REQS (
    FORMULATION_SPEC_ID,
    COMP_REQ_ID,
    SPEC_ATTRIBUTE_ID,
    ORDER_NO,
    MIN_PCT,
    MAX_PCT,
    CATEGORY_SET_ID,
    CATEGORY_ID,
    PLANNED_PCT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_FORMULATION_SPEC_ID,
    X_COMP_REQ_ID,
    X_SPEC_ATTRIBUTE_ID,
    X_ORDER_NO,
    X_MIN_PCT,
    X_MAX_PCT,
    X_CATEGORY_SET_ID,
    X_CATEGORY_ID,
    X_PLANNED_PCT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END INSERT_COMPOSITIONAL_REQ;

PROCEDURE LOCK_COMPOSITIONAL_REQ (
  X_COMP_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_MIN_PCT			IN NUMBER		,
  X_MAX_PCT			IN NUMBER		,
  X_CATEGORY_SET_ID		IN NUMBER		,
  X_CATEGORY_ID			IN NUMBER		,
  X_PLANNED_PCT			IN NUMBER		,
  X_ORDER_NO			IN NUMBER
) IS
  CURSOR C IS SELECT
      FORMULATION_SPEC_ID,
      SPEC_ATTRIBUTE_ID,
      MIN_PCT,
      MAX_PCT,
      CATEGORY_SET_ID,
      CATEGORY_ID,
      PLANNED_PCT
    FROM GMD_COMPOSITIONAL_REQS
    WHERE COMP_REQ_ID = X_COMP_REQ_ID
    FOR UPDATE OF COMP_REQ_ID NOWAIT;
  RECINFO C%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO RECINFO;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;
  IF (    (RECINFO.FORMULATION_SPEC_ID = X_FORMULATION_SPEC_ID)
      AND (RECINFO.SPEC_ATTRIBUTE_ID = X_SPEC_ATTRIBUTE_ID)
      AND ((RECINFO.MIN_PCT = X_MIN_PCT)
           OR ((RECINFO.MIN_PCT IS NULL) AND (X_MIN_PCT IS NULL)))
      AND ((RECINFO.MAX_PCT = X_MAX_PCT)
           OR ((RECINFO.MAX_PCT IS NULL) AND (X_MAX_PCT IS NULL)))
      AND (RECINFO.CATEGORY_SET_ID = X_CATEGORY_SET_ID)
      AND (RECINFO.CATEGORY_ID = X_CATEGORY_ID)
      AND ((RECINFO.PLANNED_PCT = X_PLANNED_PCT)
           OR ((RECINFO.PLANNED_PCT IS NULL) AND (X_PLANNED_PCT IS NULL)))
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;
END LOCK_COMPOSITIONAL_REQ;

PROCEDURE UPDATE_COMPOSITIONAL_REQ (
  X_COMP_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_MIN_PCT			IN NUMBER		,
  X_MAX_PCT			IN NUMBER		,
  X_CATEGORY_SET_ID		IN NUMBER		,
  X_CATEGORY_ID			IN NUMBER		,
  X_PLANNED_PCT			IN NUMBER		,
  X_ORDER_NO			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

BEGIN

  UPDATE GMD_COMPOSITIONAL_REQS SET
    FORMULATION_SPEC_ID	= X_FORMULATION_SPEC_ID		,
    SPEC_ATTRIBUTE_ID	= X_SPEC_ATTRIBUTE_ID		,
    MIN_PCT		= X_MIN_PCT			,
    MAX_PCT		= X_MAX_PCT			,
    CATEGORY_SET_ID	= X_CATEGORY_SET_ID		,
    CATEGORY_ID		= X_CATEGORY_ID			,
    PLANNED_PCT		= X_PLANNED_PCT			,
    LAST_UPDATE_DATE	= X_LAST_UPDATE_DATE		,
    LAST_UPDATED_BY	= X_LAST_UPDATED_BY		,
    LAST_UPDATE_LOGIN	= X_LAST_UPDATE_LOGIN
  WHERE COMP_REQ_ID	= X_COMP_REQ_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_COMPOSITIONAL_REQ;

PROCEDURE DELETE_COMPOSITIONAL_REQ (
  X_COMP_REQ_ID			IN NUMBER
) IS
BEGIN

  DELETE FROM GMD_COMPOSITIONAL_REQS
  WHERE COMP_REQ_ID = X_COMP_REQ_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_COMPOSITIONAL_REQ;

/* END - Compositional Req - Table Handlers */


/* Technical Req - Table Handlers */

PROCEDURE INSERT_TECHNICAL_REQ (
  X_ROWID			OUT NOCOPY VARCHAR2	,
  X_TECH_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_TECH_PARM_ID		IN NUMBER		,
  X_MIN_VALUE			IN NUMBER		,
  X_MAX_VALUE			IN NUMBER		,
  X_CREATION_DATE		IN DATE			,
  X_CREATED_BY			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

  CURSOR C IS
   SELECT ROWID
   FROM GMD_TECHNICAL_REQS
   WHERE TECH_REQ_ID = X_TECH_REQ_ID;

BEGIN

  INSERT INTO GMD_TECHNICAL_REQS (
    FORMULATION_SPEC_ID,
    SPEC_ATTRIBUTE_ID,
    TECH_PARM_ID,
    TECH_REQ_ID,
    MIN_VALUE,
    MAX_VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_FORMULATION_SPEC_ID,
    X_SPEC_ATTRIBUTE_ID,
    X_TECH_PARM_ID,
    X_TECH_REQ_ID,
    X_MIN_VALUE,
    X_MAX_VALUE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END INSERT_TECHNICAL_REQ;


PROCEDURE LOCK_TECHNICAL_REQ (
  X_TECH_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_TECH_PARM_ID		IN NUMBER		,
  X_MIN_VALUE			IN NUMBER		,
  X_MAX_VALUE			IN NUMBER
) IS
  CURSOR C IS SELECT
      FORMULATION_SPEC_ID,
      SPEC_ATTRIBUTE_ID,
      TECH_PARM_ID,
      MIN_VALUE,
      MAX_VALUE
    FROM GMD_TECHNICAL_REQS
    WHERE TECH_REQ_ID = X_TECH_REQ_ID
    FOR UPDATE OF TECH_REQ_ID NOWAIT;
  RECINFO C%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO RECINFO;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;
  IF (    (RECINFO.FORMULATION_SPEC_ID = X_FORMULATION_SPEC_ID)
      AND (RECINFO.SPEC_ATTRIBUTE_ID = X_SPEC_ATTRIBUTE_ID)
      AND (RECINFO.TECH_PARM_ID = X_TECH_PARM_ID)
      AND ((RECINFO.MIN_VALUE = X_MIN_VALUE)
           OR ((RECINFO.MIN_VALUE IS NULL) AND (X_MIN_VALUE IS NULL)))
      AND ((RECINFO.MAX_VALUE = X_MAX_VALUE)
           OR ((RECINFO.MAX_VALUE IS NULL) AND (X_MAX_VALUE IS NULL)))
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;
END LOCK_TECHNICAL_REQ;

PROCEDURE UPDATE_TECHNICAL_REQ (
  X_TECH_REQ_ID			IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_TECH_PARM_ID		IN NUMBER		,
  X_MIN_VALUE			IN NUMBER		,
  X_MAX_VALUE			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER
) IS

BEGIN

  UPDATE GMD_TECHNICAL_REQS
  SET
    FORMULATION_SPEC_ID = X_FORMULATION_SPEC_ID		,
    SPEC_ATTRIBUTE_ID	= X_SPEC_ATTRIBUTE_ID		,
    TECH_PARM_ID	= X_TECH_PARM_ID		,
    MIN_VALUE		= X_MIN_VALUE			,
    MAX_VALUE		= X_MAX_VALUE			,
    LAST_UPDATE_DATE	= X_LAST_UPDATE_DATE		,
    LAST_UPDATED_BY	= X_LAST_UPDATED_BY		,
    LAST_UPDATE_LOGIN	= X_LAST_UPDATE_LOGIN
  WHERE TECH_REQ_ID	= X_TECH_REQ_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_TECHNICAL_REQ;

PROCEDURE DELETE_TECHNICAL_REQ (
  X_TECH_REQ_ID			IN NUMBER
) IS
BEGIN

  DELETE FROM GMD_TECHNICAL_REQS
  WHERE TECH_REQ_ID = X_TECH_REQ_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_TECHNICAL_REQ;

/* END - Technical Req - Table Handlers */


/* Specification Attributes - Table Handlers */

PROCEDURE INSERT_SPEC_ATTRIBUTE (
  X_ROWID			OUT NOCOPY VARCHAR2	,
  X_SPEC_ATTRIBUTE_ID		IN NUMBER		,
  X_FORMULATION_SPEC_ID		IN NUMBER		,
  X_LOOKUP_TYPE			IN VARCHAR2		,
  X_LOOKUP_CODE			IN VARCHAR2		,
  X_CREATION_DATE		IN DATE			,
  X_CREATED_BY			IN NUMBER		,
  X_LAST_UPDATE_DATE		IN DATE			,
  X_LAST_UPDATED_BY		IN NUMBER		,
  X_LAST_UPDATE_LOGIN		IN NUMBER) IS

  CURSOR C IS
   SELECT ROWID
   FROM GMD_SPECIFICATION_ATTRIBUTES
   WHERE SPEC_ATTRIBUTE_ID = X_SPEC_ATTRIBUTE_ID;

BEGIN

  INSERT INTO GMD_SPECIFICATION_ATTRIBUTES (
    FORMULATION_SPEC_ID,
    SPEC_ATTRIBUTE_ID,
    LOOKUP_TYPE,
    LOOKUP_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_FORMULATION_SPEC_ID,
    X_SPEC_ATTRIBUTE_ID,
    X_LOOKUP_TYPE,
    X_LOOKUP_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
   );

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END INSERT_SPEC_ATTRIBUTE;

PROCEDURE DELETE_SPEC_ATTRIBUTE (
  X_SPEC_ATTRIBUTE_ID		IN NUMBER
) IS

BEGIN

  DELETE FROM GMD_SPECIFICATION_ATTRIBUTES
  WHERE SPEC_ATTRIBUTE_ID = X_SPEC_ATTRIBUTE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_SPEC_ATTRIBUTE;

/* END - Specification Attributes - Table Handlers */


/*-------------------------------------------------------------------
-- NAME
--    Get_specifications
--
-- SYNOPSIS
--    Procedure Get_specifications
--
-- DESCRIPTION
--    This procedure is called to fetch specifications based on search
-- condition passed to the API
--
--
-- HISTORY
--    Sriram    9/05/2005     Created for LCF Build
--------------------------------------------------------------------*/

PROCEDURE Get_specifications(	     p_spec_no           IN VARCHAR2	DEFAULT NULL ,
	                             p_spec_vers         IN NUMBER	DEFAULT NULL ,
	                             p_spec_status       IN NUMBER	DEFAULT NULL ,
	                             p_product           IN VARCHAR2	DEFAULT NULL ,
				     p_product_id        IN NUMBER	DEFAULT NULL ,
                                     p_routing           IN VARCHAR2	DEFAULT NULL ,
                                     p_routing_id        IN NUMBER	DEFAULT NULL ,
                                     p_tech_parm_name    IN VARCHAR2	DEFAULT NULL ,
                                     p_tech_parm_id      IN NUMBER	DEFAULT NULL ,
                                     p_spec_organization IN VARCHAR2	DEFAULT NULL ,
                                     p_start_date        IN VARCHAR2	DEFAULT NULL ,
                                     p_end_date          IN VARCHAR2	DEFAULT NULL ,
                                     p_min_ingreds       IN NUMBER	DEFAULT NULL ,
                                     p_max_ingreds       IN NUMBER	DEFAULT NULL ,
                                     p_process_loss      IN NUMBER	DEFAULT NULL ,
                                     p_obj_ind           IN NUMBER	DEFAULT NULL ,
                                     p_ingr_pick_base    IN VARCHAR2	DEFAULT NULL ,
                                     p_lot_pick_strategy IN VARCHAR2	DEFAULT NULL ,
                                     p_std_qty           IN NUMBER	DEFAULT NULL ,
                                     p_std_uom           IN VARCHAR2	DEFAULT NULL ,
				     x_search_clause	 IN OUT NOCOPY	VARCHAR2     ,
				     x_spec_rec		 OUT NOCOPY	GMD_FORMULATION_SPECS_PKG.l_spec_table
                                     ) IS


   TYPE dyn_cursor IS REF CURSOR;
   Cur_get_spec dyn_cursor;

   l_where VARCHAR2(3000) := ' 1 = 1 ';

   i NUMBER;

BEGIN

-- Assign the where clause passed to the local where clause being built here
l_where := l_where || x_search_clause;

 /* Construct the WHERE clause */
 IF p_spec_no IS NOT NULL THEN
     IF INSTRB(p_spec_no,'%') > 0 THEN
       l_where := l_where || ' AND fs.SPEC_NAME like '''|| p_spec_no||'''';
     ELSE
       l_where := l_where || ' AND fs.SPEC_NAME = '''||p_spec_no||'''';
     END IF;
 END IF;

 IF p_spec_vers IS NOT NULL THEN
     l_where := l_where || ' AND fs.SPEC_VERS = '||p_spec_vers;
 END IF;

 IF p_spec_status IS NOT NULL THEN
     l_where := l_where || ' AND fs.SPEC_STATUS = '||p_spec_status;
 END IF;

 IF (p_product IS NOT NULL) THEN
   IF INSTRB(p_product,'%') > 0 THEN
	l_where :=  l_where || ' and PRODUCT_ID  in '
                      ||'(select i.inventory_item_id from mtl_system_items_kfv i '
		      ||' where i.organization_id = fs.owner_organization_id and '
                      ||' i.concatenated_segments like '''||p_product|| ''''||' )';
   ELSE
	l_where :=  l_where || ' and PRODUCT_ID  in '
                      ||'(select i.inventory_item_id from mtl_system_items_kfv i '
		      ||' where i.organization_id = fs.owner_organization_id and '
                      ||' i.concatenated_segments = '''||p_product||''''||' )';
   END IF;
 END IF;

 IF (p_start_date IS NOT NULL) THEN
   IF INSTR(p_start_date, ' ', -1) = 0 THEN
        l_where := l_where || ' AND NVL(TRUNC(fs.START_DATE),TRUNC(TO_DATE('''||p_start_date||''',''DD-MON-YYYY''))) >= TRUNC(TO_DATE('''||p_start_date||''',''DD-MON-YYYY''))';
     NULL;
   ELSE
        l_where := l_where || ' AND NVL(TRUNC(fs.START_DATE),TRUNC(TO_DATE('''||p_start_date||''',''DD-MON-YYYY''))) >= TRUNC(TO_DATE('''||p_start_date||''',''DD-MON-YYYY''))';
     NULL;
   END IF;
 END IF;

 IF (p_end_date IS NOT NULL) THEN
   IF INSTR(p_end_date, ' ', -1) = 0 THEN
	l_where := l_where || ' AND NVL(TRUNC(fs.END_DATE),TRUNC(TO_DATE('''||p_end_date||''',''DD-MON-YYYY''))) <= TRUNC(TO_DATE('''||p_end_date||''',''DD-MON-YYYY''))';

   ELSE
        l_where := l_where || ' AND NVL(TRUNC(fs.END_DATE),TRUNC(TO_DATE('''||p_end_date||''',''DD-MON-YYYY''))) <= TRUNC(TO_DATE('''||p_end_date||''', ''DD-MON-YYYY''))';
     NULL;
   END IF;
 END IF;

 IF p_obj_ind IS NOT NULL THEN
     l_where := l_where || ' AND fs.OBJECTIVE_IND = '||p_obj_ind;
 END IF;

 IF p_ingr_pick_base IS NOT NULL THEN
     IF INSTRB(p_ingr_pick_base,'%') > 0 THEN
       l_where := l_where || ' AND fs.INGRED_PICK_BASE_IND like '''|| p_ingr_pick_base||'''';
     ELSE
       l_where := l_where || ' AND fs.INGRED_PICK_BASE_IND = '''||p_ingr_pick_base||'''';
     END IF;
 END IF;

 IF p_lot_pick_strategy IS NOT NULL THEN
     IF INSTRB(p_lot_pick_strategy,'%') > 0 THEN
       l_where := l_where || ' AND fs.PICK_LOT_STRATEGY like '''|| p_lot_pick_strategy||'''';
     ELSE
       l_where := l_where || ' AND fs.PICK_LOT_STRATEGY = '''||p_lot_pick_strategy||'''';
     END IF;
 END IF;

 IF p_std_qty IS NOT NULL THEN
    IF INSTRB(p_std_qty,'%') > 0 THEN
      l_where := l_where || ' AND fs.std_qty like '||p_std_qty;
    ELSE
      l_where := l_where || ' AND fs.std_qty = '||p_std_qty;
    END IF;
 END IF;


 IF p_std_uom IS NOT NULL THEN
    IF INSTRB(p_std_uom,'%') > 0 THEN
      l_where := l_where || ' AND Upper(fs.std_uom) like '''||p_std_uom||'''';
    ELSE
      l_where := l_where || ' AND Upper(fs.std_uom) = '''||p_std_uom||'''';
    END IF;
 END IF;

 IF p_max_ingreds IS NOT NULL THEN
   IF INSTRB(p_max_ingreds,'%') > 0 THEN
     l_where := l_where || ' AND fs.max_ingreds like '||p_max_ingreds;
   ELSE
     l_where := l_where || ' AND fs.max_ingreds = '||p_max_ingreds;
   END IF;
 END IF;

 IF p_min_ingreds IS NOT NULL THEN
   IF INSTRB(p_min_ingreds,'%') > 0 THEN
     l_where := l_where || ' AND fs.min_ingreds like '||p_min_ingreds;
   ELSE
     l_where := l_where || ' AND fs.min_ingreds = '||p_min_ingreds;
   END IF;
 END IF;

 IF (p_spec_organization IS NOT NULL) THEN
   IF (instr(p_spec_organization,'%') > 0) THEN
         l_where := l_where||' AND fs.owner_organization_id IN ' || '(SELECT organization_id FROM  ORG_ACCESS_VIEW '||
                                                                    'WHERE ORGANIZATION_CODE  LIKE '||''''||p_spec_organization||''''||' )';
   ELSE
        l_where := l_where||' AND fs.owner_organization_id IN ' || '(SELECT organization_id FROM  ORG_ACCESS_VIEW '||
								   'WHERE ORGANIZATION_CODE  = '||''''||p_spec_organization||''''||')';
   END IF;
 END IF;

 IF p_process_loss IS NOT NULL THEN
   IF INSTRB(p_process_loss,'%') > 0 THEN
     l_where := l_where || ' AND fs.process_loss like '||p_process_loss;
   ELSE
     l_where := l_where || ' AND fs.process_loss = '||p_process_loss;
   END IF;
 END IF;

 /* Fetch the specifications */
 OPEN Cur_get_spec FOR
    'SELECT *
     FROM gmd_formulation_specs fs
     WHERE ' || NVL (l_where, '1 = 1');

 i := 1;
 LOOP
    FETCH Cur_get_spec INTO x_spec_rec(i);
    i := i + 1;
    EXIT WHEN Cur_get_spec%NOTFOUND;
 END LOOP;

 CLOSE Cur_get_spec;

 /* Return the WHERE clause so that it can be used to create shortcuts on the WB if
 the user wants to save the search condition */
 x_search_clause := 'SELECT * FROM gmd_formulation_specs fs WHERE ' || NVL (l_where, '1 = 1') || ' ORDER BY spec_name, spec_vers';

END Get_specifications;

END GMD_FORMULATION_SPECS_PKG;


/
