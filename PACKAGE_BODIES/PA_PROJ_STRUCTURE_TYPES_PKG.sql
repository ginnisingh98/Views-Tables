--------------------------------------------------------
--  DDL for Package Body PA_PROJ_STRUCTURE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_STRUCTURE_TYPES_PKG" as
/*$Header: PAXPSTTB.pls 120.1 2005/08/19 17:18:23 mwasowic noship $*/

-- API name                      : insert_row
-- Type                          : Table Handlers
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure insert_row
  (
     X_ROWID                                  IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    , X_PROJ_STRUCTURE_TYPE_ID                   IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    , X_PROJ_ELEMENT_ID                          NUMBER
    , X_STRUCTURE_TYPE_ID                        NUMBER
    , X_RECORD_VERSION_NUMBER                    NUMBER
    , X_ATTRIBUTE_CATEGORY                       VARCHAR2
    , X_ATTRIBUTE1                               VARCHAR2
    , X_ATTRIBUTE2                               VARCHAR2
    , X_ATTRIBUTE3                               VARCHAR2
    , X_ATTRIBUTE4                               VARCHAR2
    , X_ATTRIBUTE5                               VARCHAR2
    , X_ATTRIBUTE6                               VARCHAR2
    , X_ATTRIBUTE7                               VARCHAR2
    , X_ATTRIBUTE8                               VARCHAR2
    , X_ATTRIBUTE9                               VARCHAR2
    , X_ATTRIBUTE10                              VARCHAR2
    , X_ATTRIBUTE11                              VARCHAR2
    , X_ATTRIBUTE12                              VARCHAR2
    , X_ATTRIBUTE13                              VARCHAR2
    , X_ATTRIBUTE14                              VARCHAR2
    , X_ATTRIBUTE15                              VARCHAR2
  )
  IS
     cursor c is select rowid from pa_proj_structure_types
                  where proj_structure_type_id = X_PROJ_STRUCTURE_TYPE_ID;
     cursor c2 is select pa_proj_structure_types_s.nextval from sys.dual;
  BEGIN
     if (X_PROJ_STRUCTURE_TYPE_ID IS NULL) then
       open c2;
       fetch c2 into X_PROJ_STRUCTURE_TYPE_ID;
       close c2;
     end if;

     INSERT INTO PA_PROJ_STRUCTURE_TYPES(
       PROJ_STRUCTURE_TYPE_ID
      ,PROJ_ELEMENT_ID
      ,STRUCTURE_TYPE_ID
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,RECORD_VERSION_NUMBER
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
           ) VALUES (
      X_PROJ_STRUCTURE_TYPE_ID
    , X_PROJ_ELEMENT_ID
    , X_STRUCTURE_TYPE_ID
    , sysdate
    , FND_GLOBAL.USER_ID
    , sysdate
    , FND_GLOBAL.USER_ID
    , FND_GLOBAL.LOGIN_ID
    , X_RECORD_VERSION_NUMBER
    , X_ATTRIBUTE_CATEGORY
    , X_ATTRIBUTE1
    , X_ATTRIBUTE2
    , X_ATTRIBUTE3
    , X_ATTRIBUTE4
    , X_ATTRIBUTE5
    , X_ATTRIBUTE6
    , X_ATTRIBUTE7
    , X_ATTRIBUTE8
    , X_ATTRIBUTE9
    , X_ATTRIBUTE10
    , X_ATTRIBUTE11
    , X_ATTRIBUTE12
    , X_ATTRIBUTE13
    , X_ATTRIBUTE14
    , X_ATTRIBUTE15
    );

    OPEN c;
    FETCH c INTO X_ROWID;
    if (C%NOTFOUND) then
      CLOSE c;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE c;

  END;



-- API name                      : update_row
-- Type                          : Table Handler
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure update_row
  (
     X_ROWID                                  VARCHAR2
    , X_PROJ_STRUCTURE_TYPE_ID                   NUMBER
    , X_PROJ_ELEMENT_ID                          NUMBER
    , X_STRUCTURE_TYPE_ID                        NUMBER
    , X_RECORD_VERSION_NUMBER                    NUMBER
    , X_ATTRIBUTE_CATEGORY                       VARCHAR2
    , X_ATTRIBUTE1                               VARCHAR2
    , X_ATTRIBUTE2                               VARCHAR2
    , X_ATTRIBUTE3                               VARCHAR2
    , X_ATTRIBUTE4                               VARCHAR2
    , X_ATTRIBUTE5                               VARCHAR2
    , X_ATTRIBUTE6                               VARCHAR2
    , X_ATTRIBUTE7                               VARCHAR2
    , X_ATTRIBUTE8                               VARCHAR2
    , X_ATTRIBUTE9                               VARCHAR2
    , X_ATTRIBUTE10                              VARCHAR2
    , X_ATTRIBUTE11                              VARCHAR2
    , X_ATTRIBUTE12                              VARCHAR2
    , X_ATTRIBUTE13                              VARCHAR2
    , X_ATTRIBUTE14                              VARCHAR2
    , X_ATTRIBUTE15                              VARCHAR2
  )
  IS
  BEGIN
    UPDATE PA_PROJ_STRUCTURE_TYPES
    SET
      PROJ_STRUCTURE_TYPE_ID = X_PROJ_STRUCTURE_TYPE_ID
    , PROJ_ELEMENT_ID        = X_PROJ_ELEMENT_ID
    , STRUCTURE_TYPE_ID      = X_STRUCTURE_TYPE_ID
    , LAST_UPDATE_DATE       = SYSDATE
    , LAST_UPDATED_BY        = FND_GLOBAL.USER_ID
    , LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID
    , RECORD_VERSION_NUMBER  = NVL(X_RECORD_VERSION_NUMBER,0) + 1
    , ATTRIBUTE_CATEGORY     = X_ATTRIBUTE_CATEGORY
    , ATTRIBUTE1             = X_ATTRIBUTE1
    , ATTRIBUTE2             = X_ATTRIBUTE2
    , ATTRIBUTE3             = X_ATTRIBUTE3
    , ATTRIBUTE4             = X_ATTRIBUTE4
    , ATTRIBUTE5             = X_ATTRIBUTE5
    , ATTRIBUTE6             = X_ATTRIBUTE6
    , ATTRIBUTE7             = X_ATTRIBUTE7
    , ATTRIBUTE8             = X_ATTRIBUTE8
    , ATTRIBUTE9             = X_ATTRIBUTE9
    , ATTRIBUTE10            = X_ATTRIBUTE10
    , ATTRIBUTE11            = X_ATTRIBUTE11
    , ATTRIBUTE12            = X_ATTRIBUTE12
    , ATTRIBUTE13            = X_ATTRIBUTE13
    , ATTRIBUTE14            = X_ATTRIBUTE14
    , ATTRIBUTE15            = X_ATTRIBUTE15
    WHERE rowid = X_ROWID;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END;


-- API name                      : delete_row
-- Type                          : Table Handler
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure delete_row
  (
    X_ROWID                                    VARCHAR2
  )
  IS
  BEGIN
    DELETE FROM PA_PROJ_STRUCTURE_TYPES
    WHERE ROWID = X_ROWID;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END;


end PA_PROJ_STRUCTURE_TYPES_PKG;

/
