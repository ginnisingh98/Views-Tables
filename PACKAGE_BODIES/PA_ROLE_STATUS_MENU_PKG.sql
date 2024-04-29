--------------------------------------------------------
--  DDL for Package Body PA_ROLE_STATUS_MENU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_STATUS_MENU_PKG" AS
 /* $Header: PAXRSMTB.pls 120.1 2005/08/19 17:19:26 mwasowic noship $ */
-- INSERT ROW -----------------------------------------

PROCEDURE INSERT_ROW (
 -- P_ROWID                        IN OUT     VARCHAR2,
 P_ROLE_STATUS_MENU_ID          OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
) IS

BEGIN

  -- Initialize object version number.
  p_object_version_number := 1;

  -- Get the next sequence number for the primary key.
  select PA_ROLE_STATUS_MENU_MAP_S.nextval
    into P_ROLE_STATUS_MENU_ID
    from sys.dual;

  insert into pa_role_status_menu_map (
    ROLE_STATUS_MENU_ID,
    ROLE_ID,
    STATUS_TYPE,
    STATUS_CODE,
    MENU_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ROLE_STATUS_MENU_ID,
    P_ROLE_ID,
    P_STATUS_TYPE,
    P_STATUS_CODE,
    P_MENU_ID,
    P_OBJECT_VERSION_NUMBER,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
	    );

END INSERT_ROW;


-- LOCK ROW ------------------------------------------
PROCEDURE LOCK_ROW (
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER
) IS

	CURSOR c
	IS
        SELECT *
        FROM   pa_role_status_menu_map
        WHERE  ROLE_STATUS_MENU_ID = P_ROLE_STATUS_MENU_ID
        FOR UPDATE NOWAIT;

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


        IF ( ( (Recinfo.OBJECT_VERSION_NUMBER  = P_OBJECT_VERSION_NUMBER)
            OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
             AND (P_OBJECT_VERSION_NUMBER IS NULL)))
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
 -- P_ROWID                        IN OUT     VARCHAR2,
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
) IS


BEGIN
   -- Lock the row for update.
   LOCK_ROW (
        P_ROLE_STATUS_MENU_ID,
        P_OBJECT_VERSION_NUMBER
        );

    -- Increment the object version number.
    p_object_version_number := p_object_version_number + 1;

    update pa_role_status_menu_map
    set
    STATUS_CODE = P_STATUS_CODE,
    MENU_ID = P_MENU_ID,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
    WHERE role_status_menu_id = p_role_status_menu_id;

    IF (SQL%NOTFOUND)
      THEN
       RAISE NO_DATA_FOUND;
    END IF;
  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;


-- DELETE ROW -----------------------------------------
PROCEDURE DELETE_ROW (
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER) IS

BEGIN

LOCK_ROW (
        P_ROLE_STATUS_MENU_ID,
        P_OBJECT_VERSION_NUMBER
        );

  delete from pa_role_status_menu_map
  where role_status_menu_id = p_role_status_menu_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Delete_Row;

END pa_role_status_menu_pkg;

/
