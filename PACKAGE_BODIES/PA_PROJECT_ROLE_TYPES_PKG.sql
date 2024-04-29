--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_ROLE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_ROLE_TYPES_PKG" AS
 /* $Header: PAXPRRTB.pls 115.12 2003/06/13 18:06:16 ramurthy ship $ */
-- INSERT ROW -----------------------------------------

PROCEDURE INSERT_ROW (
 X_ROWID                        IN OUT NOCOPY    VARCHAR2,
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_PROJECT_ROLE_TYPE            IN         VARCHAR2,
 X_MEANING                      IN         VARCHAR2,
 X_QUERY_LABOR_COST_FLAG        IN         VARCHAR2,
 X_START_DATE_ACTIVE            IN         DATE,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_END_DATE_ACTIVE              IN         DATE,
 X_DESCRIPTION                  IN	   VARCHAR2,
 X_DEFAULT_MIN_JOB_LEVEL        IN         NUMBER,
 X_DEFAULT_MAX_JOB_LEVEL        IN         NUMBER,
 X_MENU_ID                      IN	   NUMBER,
 X_DEFAULT_JOB_ID 		IN	   NUMBER,
 X_FREEZE_RULES_FLAG            IN         VARCHAR2,
 X_ATTRIBUTE_CATEGORY           IN         VARCHAR2,
 X_ATTRIBUTE1                   IN         VARCHAR2,
 X_ATTRIBUTE2                   IN         VARCHAR2,
 X_ATTRIBUTE3                   IN         VARCHAR2,
 X_ATTRIBUTE4                   IN         VARCHAR2,
 X_ATTRIBUTE5                   IN         VARCHAR2,
 X_ATTRIBUTE6                   IN         VARCHAR2,
 X_ATTRIBUTE7                   IN         VARCHAR2,
 X_ATTRIBUTE8                   IN         VARCHAR2,
 X_ATTRIBUTE9                   IN         VARCHAR2,
 X_ATTRIBUTE10                  IN         VARCHAR2,
 X_ATTRIBUTE11                  IN         VARCHAR2,
 X_ATTRIBUTE12                  IN         VARCHAR2,
 X_ATTRIBUTE13                  IN         VARCHAR2,
 X_ATTRIBUTE14                  IN         VARCHAR2,
 X_ATTRIBUTE15                  IN         VARCHAR2,
 X_DEFAULT_ACCESS_LEVEL         IN         VARCHAR2,
 X_ROLE_PARTY_CLASS             IN         VARCHAR2,
 X_STATUS_LEVEL                 IN         VARCHAR2
) IS


    cursor C is select ROWID from PA_PROJECT_ROLE_TYPES_B
    where PROJECT_ROLE_ID = X_PROJECT_ROLE_ID
      ;



BEGIN

  insert into PA_PROJECT_ROLE_TYPES_B (
    PROJECT_ROLE_TYPE,
    QUERY_LABOR_COST_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
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
    PROJECT_ROLE_ID,
    MENU_ID,
    DEFAULT_JOB_ID,
    DEFAULT_MIN_JOB_LEVEL,
    DEFAULT_MAX_JOB_LEVEL,
    RECORD_VERSION_NUMBER,
    FREEZE_RULES_FLAG,
    DEFAULT_ACCESS_LEVEL,
    ROLE_PARTY_CLASS,
    STATUS_LEVEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROJECT_ROLE_TYPE,
    X_QUERY_LABOR_COST_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_PROJECT_ROLE_ID,
    X_MENU_ID,
    X_DEFAULT_JOB_ID,
    X_DEFAULT_MIN_JOB_LEVEL,
    X_DEFAULT_MAX_JOB_LEVEL,
    1,
    X_FREEZE_RULES_FLAG,
    X_DEFAULT_ACCESS_LEVEL,
    X_ROLE_PARTY_CLASS,
    nvl(X_STATUS_LEVEL, 'SYSTEM'),
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
	    );

  insert into PA_PROJECT_ROLE_TYPES_TL (
    PROJECT_ROLE_ID,
    MEANING,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PROJECT_ROLE_ID,
    X_MEANING,
    nvl(X_DESCRIPTION, x_meaning),
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PA_PROJECT_ROLE_TYPES_TL T
    where T.PROJECT_ROLE_ID = X_PROJECT_ROLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


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
 X_ROWID                        IN OUT NOCOPY    VARCHAR2,
 X_RECORD_VERSION_NUMBER        IN         NUMBER
) IS

	CURSOR c
	IS
        SELECT *
        FROM   pa_project_role_types_b
        WHERE  rowid = X_Rowid
        FOR UPDATE OF project_role_id NOWAIT;

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

-- record version number
-- rowid

-- UPDATE ROW -----------------------------------------
PROCEDURE UPDATE_ROW (
 X_ROWID                        IN OUT NOCOPY    VARCHAR2,
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_PROJECT_ROLE_TYPE            IN         VARCHAR2,
 X_MEANING                      IN         VARCHAR2,
 X_QUERY_LABOR_COST_FLAG        IN         VARCHAR2,
 X_START_DATE_ACTIVE            IN         DATE,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_END_DATE_ACTIVE              IN         DATE,
 X_DESCRIPTION                  IN	   VARCHAR2,
 X_DEFAULT_MIN_JOB_LEVEL        IN         NUMBER,
 X_DEFAULT_MAX_JOB_LEVEL        IN         NUMBER,
 X_MENU_ID                      IN	   NUMBER,
 X_DEFAULT_JOB_ID 		IN	   NUMBER,
 X_FREEZE_RULES_FLAG            IN         VARCHAR2,
 X_ATTRIBUTE_CATEGORY           IN         VARCHAR2,
 X_ATTRIBUTE1                   IN         VARCHAR2,
 X_ATTRIBUTE2                   IN         VARCHAR2,
 X_ATTRIBUTE3                   IN         VARCHAR2,
 X_ATTRIBUTE4                   IN         VARCHAR2,
 X_ATTRIBUTE5                   IN         VARCHAR2,
 X_ATTRIBUTE6                   IN         VARCHAR2,
 X_ATTRIBUTE7                   IN         VARCHAR2,
 X_ATTRIBUTE8                   IN         VARCHAR2,
 X_ATTRIBUTE9                   IN         VARCHAR2,
 X_ATTRIBUTE10                  IN         VARCHAR2,
 X_ATTRIBUTE11                  IN         VARCHAR2,
 X_ATTRIBUTE12                  IN         VARCHAR2,
 X_ATTRIBUTE13                  IN         VARCHAR2,
 X_ATTRIBUTE14                  IN         VARCHAR2,
 X_ATTRIBUTE15                  IN         VARCHAR2,
 X_DEFAULT_ACCESS_LEVEL         IN         VARCHAR2,
 X_ROLE_PARTY_CLASS             IN         VARCHAR2,
 X_STATUS_LEVEL                 IN         VARCHAR2
) IS


BEGIN
--dbms_output.put_line('check 100');
    update PA_PROJECT_ROLE_TYPES_B set
    PROJECT_ROLE_TYPE = X_PROJECT_ROLE_TYPE,
    QUERY_LABOR_COST_FLAG = X_QUERY_LABOR_COST_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    MENU_ID = X_MENU_ID,
    DEFAULT_JOB_ID = X_DEFAULT_JOB_ID,
    DEFAULT_MIN_JOB_LEVEL = X_DEFAULT_MIN_JOB_LEVEL,
    DEFAULT_MAX_JOB_LEVEL = X_DEFAULT_MAX_JOB_LEVEL,
    RECORD_VERSION_NUMBER = (RECORD_VERSION_NUMBER + 1),
    FREEZE_RULES_FLAG = X_FREEZE_RULES_FLAG,
    DEFAULT_ACCESS_LEVEL = X_DEFAULT_ACCESS_LEVEL,
    ROLE_PARTY_CLASS = X_ROLE_PARTY_CLASS,
    STATUS_LEVEL = nvl(X_STATUS_LEVEL, 'SYSTEM'),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE project_role_id = X_project_role_id;

--dbms_output.put_line('check 101');
    IF (SQL%NOTFOUND)
      THEN
       RAISE NO_DATA_FOUND;
    END IF;
--dbms_output.put_line('check 102');
  update PA_PROJECT_ROLE_TYPES_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROJECT_ROLE_ID = X_PROJECT_ROLE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
--dbms_output.put_line('check 103');
  if (sql%notfound) then
    raise no_data_found;
  end if;
--dbms_output.put_line('check 104');

END UPDATE_ROW;


-- DELETE ROW -----------------------------------------
PROCEDURE DELETE_ROW (X_Rowid VARCHAR2)
  IS
     x_project_role_id NUMBER;

BEGIN

   SELECT project_role_id INTO x_project_role_id
     FROM pa_project_role_types_b
     WHERE ROWID = x_rowid;


  delete from PA_PROJECT_ROLE_TYPES_TL
  where PROJECT_ROLE_ID = X_PROJECT_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PA_PROJECT_ROLE_TYPES_B
  where PROJECT_ROLE_ID = X_PROJECT_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


END Delete_Row;


procedure ADD_LANGUAGE
is
begin
  delete from PA_PROJECT_ROLE_TYPES_TL T
  where not exists
    (select NULL
    from PA_PROJECT_ROLE_TYPES_B B
    where B.PROJECT_ROLE_ID = T.PROJECT_ROLE_ID
    );

  update PA_PROJECT_ROLE_TYPES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from PA_PROJECT_ROLE_TYPES_TL B
    where B.PROJECT_ROLE_ID = T.PROJECT_ROLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROJECT_ROLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PROJECT_ROLE_ID,
      SUBT.LANGUAGE
    from PA_PROJECT_ROLE_TYPES_TL SUBB, PA_PROJECT_ROLE_TYPES_TL SUBT
    where SUBB.PROJECT_ROLE_ID = SUBT.PROJECT_ROLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PA_PROJECT_ROLE_TYPES_TL (
    PROJECT_ROLE_ID,
    MEANING,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PROJECT_ROLE_ID,
    B.MEANING,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_PROJECT_ROLE_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_PROJECT_ROLE_TYPES_TL T
    where T.PROJECT_ROLE_ID = B.PROJECT_ROLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


END pa_project_role_types_pkg;

/
