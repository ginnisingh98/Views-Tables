--------------------------------------------------------
--  DDL for Package Body GMD_PARAMETERS_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_PARAMETERS_HDR_PKG" AS
/* $Header: GMDPRHDB.pls 120.1 2006/02/20 04:51:50 kshukla noship $ */

 /*======================================================================
 --  PROCEDURE :
 --   INSERT_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure insert rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
PROCEDURE INSERT_ROW (
  X_ROWID               IN OUT NOCOPY VARCHAR2,
  X_PARAMETER_ID        IN NUMBER,
  X_ORGANIZATION_ID     IN NUMBER,
  X_LAB_IND             IN NUMBER,
  X_PLANT_IND           IN NUMBER,
  X_CREATION_DATE       IN DATE,
  X_CREATED_BY          IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER
) IS

CURSOR C IS
  SELECT ROWID
  FROM GMD_PARAMETERS_HDR
  WHERE PARAMETER_ID = X_PARAMETER_ID;

BEGIN
  INSERT INTO GMD_PARAMETERS_HDR (
    ORGANIZATION_ID,
    LAB_IND,
    PLANT_IND,
    PARAMETER_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ORGANIZATION_ID,
    X_LAB_IND,
    X_PLANT_IND,
    X_PARAMETER_ID,
    SYSDATE,
    X_LAST_UPDATED_BY,
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

END INSERT_ROW;

 /*======================================================================
 --  PROCEDURE :
 --   LOCK_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure lock rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
PROCEDURE LOCK_ROW (
  X_PARAMETER_ID        IN NUMBER,
  X_ORGANIZATION_ID     IN NUMBER,
  X_LAB_IND             IN NUMBER,
  X_PLANT_IND           IN NUMBER
 ) IS

  CURSOR C IS SELECT
      ORGANIZATION_ID,
      LAB_IND,
      PLANT_IND,
      PARAMETER_ID
    FROM GMD_PARAMETERS_HDR
    WHERE PARAMETER_ID = X_PARAMETER_ID
    FOR UPDATE OF PARAMETER_ID NOWAIT;

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

  IF (((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
      AND ((recinfo.LAB_IND = X_LAB_IND)
           OR ((recinfo.LAB_IND is null) AND (X_LAB_IND is null)))
      AND ((recinfo.PLANT_IND = X_PLANT_IND)
           OR ((recinfo.PLANT_IND is null) AND (X_PLANT_IND is null)))
      AND ((recinfo.PARAMETER_ID = X_PARAMETER_ID)
           OR ((recinfo.PARAMETER_ID is null) AND (X_PARAMETER_ID is null)))
      ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;
END LOCK_ROW;

 /*======================================================================
 --  PROCEDURE :
 --   UPDATE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure update rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
PROCEDURE UPDATE_ROW (
  X_PARAMETER_ID        IN NUMBER,
  X_ORGANIZATION_ID     IN NUMBER,
  X_LAB_IND             IN NUMBER,
  X_PLANT_IND           IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER
) IS

BEGIN
  UPDATE GMD_PARAMETERS_HDR SET
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    LAB_IND = X_LAB_IND,
    PLANT_IND = X_PLANT_IND,
    PARAMETER_ID = X_PARAMETER_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE PARAMETER_ID = X_PARAMETER_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

 /*======================================================================
 --  PROCEDURE :
 --   DELETE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure delete rows in header table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
PROCEDURE DELETE_ROW (
  X_PARAMETER_ID IN NUMBER
) IS

BEGIN

  DELETE FROM GMD_PARAMETERS_HDR
  WHERE PARAMETER_ID = X_PARAMETER_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_ROW;

END GMD_PARAMETERS_HDR_PKG;

/
