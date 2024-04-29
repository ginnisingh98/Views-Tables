--------------------------------------------------------
--  DDL for Package Body PA_ROLE_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_CONTROLS_PKG" AS
 /* $Header: PAXPRRCB.pls 120.1 2005/08/19 17:17:51 mwasowic noship $ */

-- INSERT ROW -----------------------------------------
PROCEDURE INSERT_ROW (
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_ROLE_CONTROL_CODE            IN         VARCHAR2,
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER
) IS

      CURSOR    c
      IS
      SELECT    rowid
      FROM      pa_role_controls
      WHERE     role_control_code = x_role_control_code
      AND       project_role_id  = x_project_role_id;



BEGIN

INSERT INTO pa_role_controls (
 ROLE_CONTROL_CODE,
 PROJECT_ROLE_ID,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY,
 LAST_UPDATE_LOGIN,
 RECORD_VERSION_NUMBER
) VALUES (
 X_ROLE_CONTROL_CODE,
 X_PROJECT_ROLE_ID,
 X_LAST_UPDATE_DATE,
 X_LAST_UPDATED_BY,
 X_CREATION_DATE,
 X_CREATED_BY,
 X_LAST_UPDATE_LOGIN,
 1
 );

  OPEN  c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;


-- LOCK ROW ------------------------------------------
PROCEDURE LOCK_ROW (
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_RECORD_VERSION_NUMBER        IN         NUMBER
) IS

	CURSOR c
	IS
        SELECT *
        FROM   pa_role_controls
        WHERE  rowid = X_Rowid
        FOR UPDATE OF role_control_code, project_role_id NOWAIT;

        Recinfo c%ROWTYPE;

BEGIN

        OPEN c;
        FETCH c INTO Recinfo;
        IF (c%NOTFOUND)
        THEN
            CLOSE c;
            FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
            APP_EXCEPTION.Raise_Exception;
        END IF;
        CLOSE c;


        IF ( ( (Recinfo.RECORD_VERSION_NUMBER  = X_RECORD_VERSION_NUMBER)
                      OR ( (Recinfo.RECORD_VERSION_NUMBER IS NULL)
                          AND (X_RECORD_VERSION_NUMBER IS NULL)))
           )
        THEN
              RETURN;
        ELSE
              FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
              APP_EXCEPTION.Raise_Exception;
        END IF;

END LOCK_ROW;


-- UPDATE ROW -----------------------------------------
PROCEDURE UPDATE_ROW (
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_ROLE_CONTROL_CODE            IN         VARCHAR2,
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER
) IS

BEGIN

        UPDATE pa_role_controls
        SET     ROLE_CONTROL_CODE      =X_ROLE_CONTROL_CODE,
                PROJECT_ROLE_ID        =X_PROJECT_ROLE_ID,
                LAST_UPDATE_DATE       =X_LAST_UPDATE_DATE,
                LAST_UPDATED_BY        =X_LAST_UPDATED_BY,
                CREATION_DATE          =X_CREATION_DATE,
                CREATED_BY             =X_CREATED_BY,
                LAST_UPDATE_LOGIN      =X_LAST_UPDATE_LOGIN,
                RECORD_VERSION_NUMBER  = (RECORD_VERSION_NUMBER +1)
        WHERE rowid = X_Rowid;

        IF (SQL%NOTFOUND)
        THEN
             RAISE NO_DATA_FOUND;
        END IF;

END UPDATE_ROW;


-- DELETE ROW -----------------------------------------
PROCEDURE DELETE_ROW (X_Rowid VARCHAR2)
IS
BEGIN

        DELETE FROM pa_role_controls
        WHERE rowid = X_Rowid;

        IF (SQL%NOTFOUND)
        THEN
              RAISE NO_DATA_FOUND;
        END IF;

END Delete_Row;


END pa_role_controls_pkg;

/
