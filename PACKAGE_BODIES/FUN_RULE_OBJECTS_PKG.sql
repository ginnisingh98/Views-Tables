--------------------------------------------------------
--  DDL for Package Body FUN_RULE_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_OBJECTS_PKG" AS
/*$Header: FUNXTMRULROBTBB.pls 120.11.12010000.2 2008/08/06 07:44:51 makansal ship $ */

PROCEDURE INSERT_ROW (
  X_ROWID 			IN OUT NOCOPY VARCHAR2,
  X_RULE_OBJECT_ID 		IN NUMBER,
  X_APPLICATION_ID 		IN NUMBER,
  X_RULE_OBJECT_NAME 		IN VARCHAR2,
  X_RESULT_TYPE 		IN VARCHAR2,
  X_REQUIRED_FLAG 		IN VARCHAR2,
  X_USE_DEFAULT_VALUE_FLAG      IN VARCHAR2,
  X_DEFAULT_APPLICATION_ID 	IN NUMBER,
  X_DEFAULT_VALUE 		IN VARCHAR2,
  X_FLEX_VALUE_SET_ID 		IN NUMBER,
  X_FLEXFIELD_NAME              IN VARCHAR2,
  X_FLEXFIELD_APP_SHORT_NAME    IN VARCHAR2,
  X_MULTI_RULE_RESULT_FLAG      IN VARCHAR2,
  X_CREATED_BY_MODULE 		IN VARCHAR2,
  X_USER_RULE_OBJECT_NAME 	IN VARCHAR2,
  X_DESCRIPTION 		IN VARCHAR2,
  X_USE_INSTANCE_FLAG           IN VARCHAR2 DEFAULT NULL,
  X_INSTANCE_LABEL              IN VARCHAR2 DEFAULT NULL,
  X_PARENT_RULE_OBJECT_ID       IN NUMBER   DEFAULT NULL,
  X_ORG_ID                      IN NUMBER   DEFAULT NULL,
  X_CREATION_DATE               IN DATE DEFAULT NULL,
  X_CREATED_BY                  IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_DATE            IN DATE DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) IS
  l_roa_rowid varchar2(64);
  l_seq_val                FUN_RULE_OBJECTS_B.RULE_OBJECT_ID%TYPE;
begin

  --
  --Always derive the RULE_OBJECT_ID here else in INSERT_ROW proc for
  --FUN_RULE_OBJ_ATTRIBUTES table, it will be hard to derive the RULE_OBJECT_ID
  --For the current Rule Object from RULE_OBJECT_NAME. Because, Rule Object Instances
  --will share the same Rule Object Name as of the Parent Rule Object Id.

  IF X_RULE_OBJECT_ID IS NULL THEN
     select FUN_RULE_OBJECTS_S.NEXTVAL into l_seq_val from dual;
  END IF;


  INSERT_ROW(X_ROWID,
             NVL(X_RULE_OBJECT_ID,l_seq_val),
             X_APPLICATION_ID,
             X_RULE_OBJECT_NAME,
             X_RESULT_TYPE,
             X_REQUIRED_FLAG,
             X_USE_DEFAULT_VALUE_FLAG,
             X_FLEX_VALUE_SET_ID,
             X_FLEXFIELD_NAME,
             X_FLEXFIELD_APP_SHORT_NAME,
             X_MULTI_RULE_RESULT_FLAG,
             X_CREATED_BY_MODULE,
             X_USER_RULE_OBJECT_NAME,
             X_DESCRIPTION,
             NVL(X_USE_INSTANCE_FLAG,'N'),   --override internally to N
             X_INSTANCE_LABEL,
             X_PARENT_RULE_OBJECT_ID,
             X_ORG_ID,
	     X_CREATION_DATE,
             X_CREATED_BY,
             X_LAST_UPDATE_DATE,
             X_LAST_UPDATED_BY,
             X_LAST_UPDATE_LOGIN
	     );

  INSERT_ROW(l_roa_rowid,
             NVL(X_RULE_OBJECT_ID,l_seq_val),
             X_APPLICATION_ID,
             X_RULE_OBJECT_NAME,
             X_DEFAULT_APPLICATION_ID,
             X_DEFAULT_VALUE,
	     X_CREATION_DATE,
             X_CREATED_BY,
             X_LAST_UPDATE_DATE,
             X_LAST_UPDATED_BY,
             X_LAST_UPDATE_LOGIN
	     );
end INSERT_ROW;

PROCEDURE INSERT_ROW (
  X_ROWID 			IN OUT NOCOPY VARCHAR2,
  X_RULE_OBJECT_ID 		IN NUMBER,
  X_APPLICATION_ID 		IN NUMBER,
  X_RULE_OBJECT_NAME 		IN VARCHAR2,
  X_RESULT_TYPE 		IN VARCHAR2,
  X_REQUIRED_FLAG 		IN VARCHAR2,
  X_USE_DEFAULT_VALUE_FLAG        IN VARCHAR2,
  X_FLEX_VALUE_SET_ID 		IN NUMBER,
  X_FLEXFIELD_NAME              IN VARCHAR2,
  X_FLEXFIELD_APP_SHORT_NAME    IN VARCHAR2,
  X_MULTI_RULE_RESULT_FLAG      IN VARCHAR2,
  X_CREATED_BY_MODULE 		IN VARCHAR2,
  X_USER_RULE_OBJECT_NAME 	IN VARCHAR2,
  X_DESCRIPTION 		IN VARCHAR2,
  X_USE_INSTANCE_FLAG           IN VARCHAR2 DEFAULT NULL,
  X_INSTANCE_LABEL              IN VARCHAR2 DEFAULT NULL,
  X_PARENT_RULE_OBJECT_ID       IN NUMBER   DEFAULT NULL,
  X_ORG_ID                      IN NUMBER   DEFAULT NULL,
  X_CREATION_DATE               IN DATE DEFAULT NULL,
  X_CREATED_BY                  IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_DATE            IN DATE DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) IS

  cursor C(id number) is select ROWID from FUN_RULE_OBJECTS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and RULE_OBJECT_ID = id
    ;

  l_orig_rule_object_name  FUN_RULE_OBJECTS_B.RULE_OBJECT_NAME%TYPE;
  l_parent_rule_object_id  FUN_RULE_OBJECTS_B.PARENT_RULE_OBJECT_ID%TYPE := NULL;

BEGIN

  --Derive the parent_rule_object_id if the X_INSTANCE_LABEL is NOT NULL
  --or ORG_ID is NOT NULL.

  BEGIN
     IF (X_INSTANCE_LABEL IS NOT NULL OR X_ORG_ID IS NOT NULL) THEN
        SELECT RULE_OBJECT_ID INTO l_parent_rule_object_id
        FROM FUN_RULE_OBJECTS_B
        WHERE RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
	AND   UPPER(USE_INSTANCE_FLAG) = 'Y'
	AND   INSTANCE_LABEL IS NULL
	AND   ORG_ID   IS NULL
	AND   PARENT_RULE_OBJECT_ID  IS NULL;

     END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       -- Since this should never happen if the code flow has reached till here.
       -- Throwing an exception with hard coded message text
       app_exception.raise_exception(exception_text=>'Invalid rule object name - '||X_RULE_OBJECT_NAME);
  END ;

  insert into FUN_RULE_OBJECTS_B (
    RULE_OBJECT_ID,
    APPLICATION_ID,
    RULE_OBJECT_NAME,
    RESULT_TYPE,
    REQUIRED_FLAG,
    USE_DEFAULT_VALUE_FLAG,
    FLEX_VALUE_SET_ID,
    FLEXFIELD_NAME,
    FLEXFIELD_APP_SHORT_NAME,
    MULTI_RULE_RESULT_FLAG,
    OBJECT_VERSION_NUMBER,
    USE_INSTANCE_FLAG,
    INSTANCE_LABEL,
    PARENT_RULE_OBJECT_ID,
    ORG_ID,
    CREATED_BY_MODULE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values (
    X_RULE_OBJECT_ID,
    X_APPLICATION_ID,
    X_RULE_OBJECT_NAME,
    X_RESULT_TYPE,
    X_REQUIRED_FLAG,
    X_USE_DEFAULT_VALUE_FLAG,
    X_FLEX_VALUE_SET_ID,
    X_FLEXFIELD_NAME,
    X_FLEXFIELD_APP_SHORT_NAME,
    X_MULTI_RULE_RESULT_FLAG,
    1,
    NVL(X_USE_INSTANCE_FLAG,'N'),   --override internally to N
    X_INSTANCE_LABEL,
    NVL(X_PARENT_RULE_OBJECT_ID,l_parent_rule_object_id),
    X_ORG_ID,
    X_CREATED_BY_MODULE,
    NVL(X_CREATED_BY,FUN_RULE_UTILITY_PKG.CREATED_BY),
    NVL(X_CREATION_DATE,FUN_RULE_UTILITY_PKG.CREATION_DATE),
    NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN),
    NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY)
  )RETURNING ROWID INTO X_ROWID;


  insert into FUN_RULE_OBJECTS_TL (
    RULE_OBJECT_ID,
    USER_RULE_OBJECT_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RULE_OBJECT_ID,
    X_USER_RULE_OBJECT_NAME,
    X_DESCRIPTION,
    NVL(X_CREATED_BY,FUN_RULE_UTILITY_PKG.CREATED_BY),
    NVL(X_CREATION_DATE,FUN_RULE_UTILITY_PKG.CREATION_DATE),
    NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN),
    NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY),
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FUN_RULE_OBJECTS_TL T
    where T.RULE_OBJECT_ID = X_RULE_OBJECT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c(X_RULE_OBJECT_ID);
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
END INSERT_ROW;

PROCEDURE INSERT_ROW (
  X_ROWID 			IN OUT NOCOPY VARCHAR2,
  X_RULE_OBJECT_ID 		IN NUMBER,
  X_APPLICATION_ID 		IN NUMBER,
  X_RULE_OBJECT_NAME 		IN VARCHAR2,
  X_DEFAULT_APPLICATION_ID 	IN NUMBER,
  X_DEFAULT_VALUE 		IN VARCHAR2,
  X_CREATION_DATE               IN DATE DEFAULT NULL,
  X_CREATED_BY                  IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_DATE            IN DATE DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) IS

  cursor C(id number) is select ROWID from FUN_RULE_OBJ_ATTRIBUTES
    where RULE_OBJECT_ID = id
    ;


BEGIN

  insert into FUN_RULE_OBJ_ATTRIBUTES (
    RULE_OBJECT_ID,
    DEFAULT_APPLICATION_ID,
    DEFAULT_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  )
 values (
    X_RULE_OBJECT_ID,
    X_DEFAULT_APPLICATION_ID,
    X_DEFAULT_VALUE,
    NVL(X_CREATED_BY,FUN_RULE_UTILITY_PKG.CREATED_BY),
    NVL(X_CREATION_DATE,FUN_RULE_UTILITY_PKG.CREATION_DATE),
    NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN),
    NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY)
);

  open c(X_RULE_OBJECT_ID);
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
END INSERT_ROW;


PROCEDURE LOCK_ROW (
  X_RULE_OBJECT_ID 		IN NUMBER,
  X_OBJECT_VERSION_NUMBER 	IN NUMBER
) IS
  cursor c is select
      OBJECT_VERSION_NUMBER
    from FUN_RULE_OBJECTS_B
    where RULE_OBJECT_ID = X_RULE_OBJECT_ID
    for update of RULE_OBJECT_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_RULE_OBJECT_ID 		IN NUMBER,
  X_APPLICATION_ID 		IN NUMBER,
  X_RULE_OBJECT_NAME 		IN VARCHAR2,
  X_RESULT_TYPE 		IN VARCHAR2,
  X_REQUIRED_FLAG 		IN VARCHAR2,
  X_USE_DEFAULT_VALUE_FLAG        IN VARCHAR2,
  X_DEFAULT_APPLICATION_ID 	IN NUMBER,
  X_DEFAULT_VALUE 		IN VARCHAR2,
  X_FLEX_VALUE_SET_ID 		IN NUMBER,
  X_FLEXFIELD_NAME              IN VARCHAR2,
  X_FLEXFIELD_APP_SHORT_NAME    IN VARCHAR2,
  X_MULTI_RULE_RESULT_FLAG      IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER 	IN NUMBER,
  X_CREATED_BY_MODULE 		IN VARCHAR2,
  X_USER_RULE_OBJECT_NAME 	IN VARCHAR2,
  X_DESCRIPTION 		IN VARCHAR2,
  X_USE_INSTANCE_FLAG           IN VARCHAR2 DEFAULT NULL,
  X_INSTANCE_LABEL              IN VARCHAR2 DEFAULT NULL,
  X_PARENT_RULE_OBJECT_ID       IN NUMBER DEFAULT NULL,
  X_ORG_ID                      IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_DATE            IN DATE       DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER     DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) IS
begin

  update_row(X_APPLICATION_ID,
             X_RULE_OBJECT_ID,
             X_RULE_OBJECT_NAME,
             X_RESULT_TYPE,
             X_REQUIRED_FLAG,
             X_USE_DEFAULT_VALUE_FLAG,
             X_FLEX_VALUE_SET_ID,
             X_FLEXFIELD_NAME,
             X_FLEXFIELD_APP_SHORT_NAME,
             X_MULTI_RULE_RESULT_FLAG,
             X_CREATED_BY_MODULE,
             X_USER_RULE_OBJECT_NAME,
             X_DESCRIPTION,
             X_USE_INSTANCE_FLAG,
             X_INSTANCE_LABEL,
             X_PARENT_RULE_OBJECT_ID,
             X_ORG_ID,
             X_LAST_UPDATE_DATE,
             X_LAST_UPDATED_BY,
             X_LAST_UPDATE_LOGIN
	     );

  update_row(X_APPLICATION_ID,
             X_RULE_OBJECT_ID,
             X_DEFAULT_APPLICATION_ID,
             X_DEFAULT_VALUE,
             X_LAST_UPDATE_DATE,
             X_LAST_UPDATED_BY,
             X_LAST_UPDATE_LOGIN
	     );

end UPDATE_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_RULE_OBJECT_ID in NUMBER,
  X_RULE_OBJECT_NAME in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_USE_DEFAULT_VALUE_FLAG  IN VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_FLEXFIELD_NAME in VARCHAR2,
  X_FLEXFIELD_APP_SHORT_NAME in VARCHAR2,
  X_MULTI_RULE_RESULT_FLAG in VARCHAR2,
  X_CREATED_BY_MODULE in VARCHAR2,
  X_USER_RULE_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USE_INSTANCE_FLAG           IN VARCHAR2 DEFAULT NULL,
  X_INSTANCE_LABEL              IN VARCHAR2 DEFAULT NULL,
  X_PARENT_RULE_OBJECT_ID       IN NUMBER DEFAULT NULL,
  X_ORG_ID                      IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_DATE            IN DATE DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) is
begin

  update FUN_RULE_OBJECTS_B set
    RULE_OBJECT_NAME             = X_RULE_OBJECT_NAME,
    RESULT_TYPE                  = X_RESULT_TYPE,
    REQUIRED_FLAG                = X_REQUIRED_FLAG,
    USE_DEFAULT_VALUE_FLAG       = X_USE_DEFAULT_VALUE_FLAG,
    FLEX_VALUE_SET_ID            = X_FLEX_VALUE_SET_ID,
    FLEXFIELD_NAME               = X_FLEXFIELD_NAME,
    FLEXFIELD_APP_SHORT_NAME     = X_FLEXFIELD_APP_SHORT_NAME,
    MULTI_RULE_RESULT_FLAG       = X_MULTI_RULE_RESULT_FLAG,
    OBJECT_VERSION_NUMBER        = OBJECT_VERSION_NUMBER + 1,
    CREATED_BY_MODULE            = X_CREATED_BY_MODULE,
    USE_INSTANCE_FLAG            = NVL(X_USE_INSTANCE_FLAG,'N'),
    INSTANCE_LABEL               = X_INSTANCE_LABEL,
    PARENT_RULE_OBJECT_ID        = X_PARENT_RULE_OBJECT_ID,
    ORG_ID                       = X_ORG_ID,
    LAST_UPDATE_DATE             = NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    LAST_UPDATED_BY              = NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN            = NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN)
  where RULE_OBJECT_ID = X_RULE_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FUN_RULE_OBJECTS_TL set
    USER_RULE_OBJECT_NAME = X_USER_RULE_OBJECT_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN),
    SOURCE_LANG = userenv('LANG')
  where RULE_OBJECT_ID = X_RULE_OBJECT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_RULE_OBJECT_ID in NUMBER,
  X_DEFAULT_APPLICATION_ID in NUMBER,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE            IN DATE DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) is
begin
  update FUN_RULE_OBJ_ATTRIBUTES set
    DEFAULT_APPLICATION_ID = X_DEFAULT_APPLICATION_ID,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN)
  where RULE_OBJECT_ID = X_RULE_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

PROCEDURE DELETE_ROW (
   X_RULE_OBJECT_NAME                     IN VARCHAR2,
   X_APPLICATION_ID                       IN NUMBER

) IS
begin

  delete from FUN_RULE_OBJ_ATTRIBUTES
  where RULE_OBJECT_ID in (select RULE_OBJECT_ID
                           from FUN_RULE_OBJECTS_B
                           where RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
                           AND   APPLICATION_ID = X_APPLICATION_ID
                           );

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FUN_RULE_OBJECTS_TL
  where RULE_OBJECT_ID in (select RULE_OBJECT_ID
                           from FUN_RULE_OBJECTS_B
                           where RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
                           AND   APPLICATION_ID = X_APPLICATION_ID
                           );

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FUN_RULE_OBJECTS_B
  where RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
  AND   APPLICATION_ID = X_APPLICATION_ID;


  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


PROCEDURE DELETE_ROW (
   X_RULE_OBJECT_NAME                     IN VARCHAR2,
   X_APPLICATION_ID                       IN NUMBER,
   X_INSTANCE_LABEL                       IN VARCHAR2,
   X_ORG_ID                               IN NUMBER
) IS
begin

  delete from FUN_RULE_OBJECTS_B
  where RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
  AND   APPLICATION_ID = X_APPLICATION_ID
  AND
     ( (INSTANCE_LABEL IS NULL AND X_INSTANCE_LABEL IS NULL) OR
       (INSTANCE_LABEL IS NOT NULL AND X_INSTANCE_LABEL IS NOT NULL AND INSTANCE_LABEL = X_INSTANCE_LABEL))
  AND
     ( (ORG_ID IS NULL AND X_ORG_ID IS NULL) OR
       (ORG_ID IS NOT NULL AND X_ORG_ID IS NOT NULL AND ORG_ID = X_ORG_ID))
  AND PARENT_RULE_OBJECT_ID IS NOT NULL;


  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE DELETE_ROW (
   X_RULE_OBJECT_ID                     IN NUMBER
) IS
begin
  delete from FUN_RULE_OBJECTS_TL
  where RULE_OBJECT_ID = X_RULE_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FUN_RULE_OBJECTS_B
  where RULE_OBJECT_ID = X_RULE_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FUN_RULE_OBJ_ATTRIBUTES
  where RULE_OBJECT_ID = X_RULE_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


PROCEDURE Select_Row (
    X_RULE_OBJECT_NAME		    	    IN  OUT NOCOPY   VARCHAR2,
    X_RULE_OBJECT_ID                        OUT NOCOPY     NUMBER,
    X_APPLICATION_ID		            IN  OUT NOCOPY     NUMBER,
    X_USER_RULE_OBJECT_NAME		    OUT NOCOPY     VARCHAR2,
    X_DESCRIPTION			    OUT NOCOPY     VARCHAR2,
    X_RESULT_TYPE			    OUT NOCOPY     VARCHAR2,
    X_REQUIRED_FLAG			    OUT NOCOPY     VARCHAR2,
    X_USE_DEFAULT_VALUE_FLAG                OUT NOCOPY     VARCHAR2,
    X_DEFAULT_APPLICATION_ID		    OUT NOCOPY     NUMBER,
    X_DEFAULT_VALUE			    OUT NOCOPY     VARCHAR2,
    X_FLEX_VALUE_SET_ID                     OUT NOCOPY     NUMBER,
    X_FLEXFIELD_NAME                        OUT NOCOPY     VARCHAR2,
    X_FLEXFIELD_APP_SHORT_NAME              OUT NOCOPY     VARCHAR2,
    X_MULTI_RULE_RESULT_FLAG                OUT NOCOPY     VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY     VARCHAR2,
    X_USE_INSTANCE_FLAG                     OUT NOCOPY     VARCHAR2,
    X_INSTANCE_LABEL                        OUT NOCOPY     VARCHAR2,
    X_PARENT_RULE_OBJECT_ID                 OUT NOCOPY     NUMBER,
    X_ORG_ID                                OUT NOCOPY     NUMBER
) IS

l_count      NUMBER;
BEGIN

-- If INSTANCE_LABEL IS NULL and ORG_ID is NULL , then we want the parent rule object
-- to be returned to public api. otherwiase we will return the record
-- with the instance label passed from the public api.

IF(X_INSTANCE_LABEL IS NULL AND X_ORG_ID IS NULL) THEN
   SELECT
        RULE_OBJECT_NAME,
        RULE_OBJECT_ID,
        APPLICATION_ID,
        USER_RULE_OBJECT_NAME,
        DESCRIPTION,
        RESULT_TYPE,
        REQUIRED_FLAG,
        USE_DEFAULT_VALUE_FLAG,
        DEFAULT_APPLICATION_ID,
        DEFAULT_VALUE,
        FLEX_VALUE_SET_ID,
        FLEXFIELD_NAME,
        FLEXFIELD_APP_SHORT_NAME,
        MULTI_RULE_RESULT_FLAG,
        CREATED_BY_MODULE,
        USE_INSTANCE_FLAG ,
        INSTANCE_LABEL ,
        PARENT_RULE_OBJECT_ID ,
        ORG_ID
    INTO
	X_RULE_OBJECT_NAME,
        X_RULE_OBJECT_ID,
        X_APPLICATION_ID,
        X_USER_RULE_OBJECT_NAME,
        X_DESCRIPTION,
        X_RESULT_TYPE,
        X_REQUIRED_FLAG,
        X_USE_DEFAULT_VALUE_FLAG,
        X_DEFAULT_APPLICATION_ID,
        X_DEFAULT_VALUE,
        X_FLEX_VALUE_SET_ID,
        X_FLEXFIELD_NAME,
        X_FLEXFIELD_APP_SHORT_NAME,
        X_MULTI_RULE_RESULT_FLAG,
        X_CREATED_BY_MODULE,
        X_USE_INSTANCE_FLAG,
        X_INSTANCE_LABEL,
        X_PARENT_RULE_OBJECT_ID,
        X_ORG_ID
    FROM FUN_RULE_OBJECTS_VL
    WHERE RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
    AND   APPLICATION_ID = X_APPLICATION_ID
    AND   INSTANCE_LABEL IS NULL
    AND   ORG_ID IS NULL;
ELSE
   SELECT
        RULE_OBJECT_NAME,
        RULE_OBJECT_ID,
        APPLICATION_ID,
        USER_RULE_OBJECT_NAME,
        DESCRIPTION,
        RESULT_TYPE,
        REQUIRED_FLAG,
        USE_DEFAULT_VALUE_FLAG,
        DEFAULT_APPLICATION_ID,
        DEFAULT_VALUE,
        FLEX_VALUE_SET_ID,
        FLEXFIELD_NAME,
        FLEXFIELD_APP_SHORT_NAME,
        MULTI_RULE_RESULT_FLAG,
        CREATED_BY_MODULE,
        USE_INSTANCE_FLAG ,
        INSTANCE_LABEL ,
        PARENT_RULE_OBJECT_ID ,
        ORG_ID
    INTO
	X_RULE_OBJECT_NAME,
        X_RULE_OBJECT_ID,
        X_APPLICATION_ID,
        X_USER_RULE_OBJECT_NAME,
        X_DESCRIPTION,
        X_RESULT_TYPE,
        X_REQUIRED_FLAG,
        X_USE_DEFAULT_VALUE_FLAG,
        X_DEFAULT_APPLICATION_ID,
        X_DEFAULT_VALUE,
        X_FLEX_VALUE_SET_ID,
        X_FLEXFIELD_NAME,
        X_FLEXFIELD_APP_SHORT_NAME,
        X_MULTI_RULE_RESULT_FLAG,
        X_CREATED_BY_MODULE,
        X_USE_INSTANCE_FLAG,
        X_INSTANCE_LABEL,
        X_PARENT_RULE_OBJECT_ID,
        X_ORG_ID
    FROM FUN_RULE_OBJECTS_VL
    WHERE RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
    AND   APPLICATION_ID = X_APPLICATION_ID
    AND
     ( (INSTANCE_LABEL IS NULL AND X_INSTANCE_LABEL IS NULL) OR
       (INSTANCE_LABEL IS NOT NULL AND X_INSTANCE_LABEL IS NOT NULL AND INSTANCE_LABEL = X_INSTANCE_LABEL))
    AND
     ( (ORG_ID IS NULL AND X_ORG_ID IS NULL) OR
       (ORG_ID IS NOT NULL AND X_ORG_ID IS NOT NULL AND ORG_ID = X_ORG_ID))
    AND   PARENT_RULE_OBJECT_ID  IS NOT NULL;
END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'p_rule_objects_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', X_RULE_OBJECT_NAME );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END Select_Row;

/*Overloaded procedure to select Rule Objects record based on the RULE_OBJECT_ID passed*/

PROCEDURE Select_Row_Rob_Id (
    X_RULE_OBJECT_NAME		            OUT NOCOPY   VARCHAR2,
    X_RULE_OBJECT_ID                        IN  OUT NOCOPY          NUMBER,
    X_APPLICATION_ID		            OUT NOCOPY     NUMBER,
    X_USER_RULE_OBJECT_NAME		    OUT NOCOPY     VARCHAR2,
    X_DESCRIPTION			    OUT NOCOPY     VARCHAR2,
    X_RESULT_TYPE			    OUT NOCOPY     VARCHAR2,
    X_REQUIRED_FLAG			    OUT NOCOPY     VARCHAR2,
    X_USE_DEFAULT_VALUE_FLAG                OUT NOCOPY     VARCHAR2,
    X_DEFAULT_APPLICATION_ID		    OUT NOCOPY     NUMBER,
    X_DEFAULT_VALUE			    OUT NOCOPY     VARCHAR2,
    X_FLEX_VALUE_SET_ID                     OUT NOCOPY     NUMBER,
    X_FLEXFIELD_NAME                        OUT NOCOPY     VARCHAR2,
    X_FLEXFIELD_APP_SHORT_NAME              OUT NOCOPY     VARCHAR2,
    X_MULTI_RULE_RESULT_FLAG                OUT NOCOPY     VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY     VARCHAR2,
    X_USE_INSTANCE_FLAG                     OUT NOCOPY     VARCHAR2,
    X_INSTANCE_LABEL                        OUT NOCOPY     VARCHAR2,
    X_PARENT_RULE_OBJECT_ID                 OUT NOCOPY     NUMBER,
    X_ORG_ID                                OUT NOCOPY     NUMBER
) IS

l_count      NUMBER;
BEGIN

   SELECT
        RULE_OBJECT_NAME,
        RULE_OBJECT_ID,
        APPLICATION_ID,
        USER_RULE_OBJECT_NAME,
        DESCRIPTION,
        RESULT_TYPE,
        REQUIRED_FLAG,
        USE_DEFAULT_VALUE_FLAG,
        DEFAULT_APPLICATION_ID,
        DEFAULT_VALUE,
        FLEX_VALUE_SET_ID,
        FLEXFIELD_NAME,
        FLEXFIELD_APP_SHORT_NAME,
        MULTI_RULE_RESULT_FLAG,
        CREATED_BY_MODULE,
        USE_INSTANCE_FLAG ,
        INSTANCE_LABEL ,
        PARENT_RULE_OBJECT_ID ,
        ORG_ID
    INTO
	X_RULE_OBJECT_NAME,
        X_RULE_OBJECT_ID,
        X_APPLICATION_ID,
        X_USER_RULE_OBJECT_NAME,
        X_DESCRIPTION,
        X_RESULT_TYPE,
        X_REQUIRED_FLAG,
        X_USE_DEFAULT_VALUE_FLAG,
        X_DEFAULT_APPLICATION_ID,
        X_DEFAULT_VALUE,
        X_FLEX_VALUE_SET_ID,
        X_FLEXFIELD_NAME,
        X_FLEXFIELD_APP_SHORT_NAME,
        X_MULTI_RULE_RESULT_FLAG,
        X_CREATED_BY_MODULE,
        X_USE_INSTANCE_FLAG,
        X_INSTANCE_LABEL,
        X_PARENT_RULE_OBJECT_ID,
        X_ORG_ID
    FROM FUN_RULE_OBJECTS_VL
    WHERE RULE_OBJECT_ID = X_RULE_OBJECT_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'p_rule_objects_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', X_RULE_OBJECT_NAME );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END Select_Row_Rob_Id;

procedure ADD_LANGUAGE
is
begin
  delete from FUN_RULE_OBJECTS_TL T
  where not exists
    (select NULL
    from FUN_RULE_OBJECTS_B B
    where B.RULE_OBJECT_ID = T.RULE_OBJECT_ID
    );

  update FUN_RULE_OBJECTS_TL T set (
      USER_RULE_OBJECT_NAME,
      DESCRIPTION
    ) = (select
      B.USER_RULE_OBJECT_NAME,
      B.DESCRIPTION
    from FUN_RULE_OBJECTS_TL B
    where B.RULE_OBJECT_ID = T.RULE_OBJECT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_OBJECT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_OBJECT_ID,
      SUBT.LANGUAGE
    from FUN_RULE_OBJECTS_TL SUBB, FUN_RULE_OBJECTS_TL SUBT
    where SUBB.RULE_OBJECT_ID = SUBT.RULE_OBJECT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_RULE_OBJECT_NAME <> SUBT.USER_RULE_OBJECT_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));


  insert into FUN_RULE_OBJECTS_TL (
    RULE_OBJECT_ID,
    USER_RULE_OBJECT_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RULE_OBJECT_ID,
    B.USER_RULE_OBJECT_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FUN_RULE_OBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FUN_RULE_OBJECTS_TL T
    where T.RULE_OBJECT_ID = B.RULE_OBJECT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



PROCEDURE TRANSLATE_ROW(
  X_APP_SHORT_NAME in VARCHAR2,
  X_RULE_OBJECT_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_USER_RULE_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
)
IS
  appid number;
  roid number;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
BEGIN

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

 BEGIN
  SELECT application_id INTO appid
  FROM fnd_application
  WHERE application_short_name = X_APP_SHORT_NAME;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
      app_exception.raise_exception(exception_text=>'Invalid application short name - '||X_APP_SHORT_NAME);
 END;

 BEGIN
  select RULE_OBJECT_ID
  into roid
  from FUN_RULE_OBJECTS_B
  where APPLICATION_ID = appid
  and RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
  AND PARENT_RULE_OBJECT_ID IS NULL;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Invalid rule object name - '||x_rule_object_name);
 END;

 BEGIN
  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FUN_RULE_OBJECTS_TL
  where rule_object_id = roid
  and language = userenv('LANG');
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Unable to find translation row for rule object - '||x_rule_object_name||','||userenv('LANG'));
 END;

  -- c. owners are the same, and file_date > db_date
  if (fnd_load_util.UPLOAD_TEST(
             p_file_id     => f_luby,
             p_file_lud    => f_ludate,
             p_db_id       => db_luby,
             p_db_lud      => db_ludate,
             p_custom_mode => x_custom_mode))
  then
    update FUN_RULE_OBJECTS_TL
    set user_rule_object_name = nvl(x_user_rule_object_name, user_rule_object_name),
        description = nvl(x_description, description),
	source_lang = userenv('LANG')
    where rule_object_id = roid
    and userenv('LANG') in (language, source_lang);
  end if;
END TRANSLATE_ROW;


/* Currently we are not supporting the seeding of Rule Object Instances.
   Only if the USE_INSTANCE_FLAG is Y and update mode, then we will propagate
   the changes to all the instances. */

procedure LOAD_ROW (
  X_APP_SHORT_NAME in VARCHAR2,
  X_RULE_OBJECT_NAME in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_USE_DEFAULT_VALUE_FLAG IN VARCHAR2,
  X_DEFAULT_APP_SHORT_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_FLEX_VALUE_SET_NAME in VARCHAR2,
  X_FLEXFIELD_NAME in VARCHAR2,
  X_FLEXFIELD_APP_SHORT_NAME in VARCHAR2,
  X_MULTI_RULE_RESULT_FLAG in VARCHAR2,
  X_USER_RULE_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USE_INSTANCE_FLAG           IN VARCHAR2 DEFAULT NULL,
  X_OWNER                       IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN VARCHAR2,
  X_ATT_OWNER                   IN VARCHAR2,
  X_ATT_LAST_UPDATE_DATE        IN VARCHAR2,
  X_CUSTOM_MODE                 IN VARCHAR2)
is
begin
  LOAD_ROW(X_APP_SHORT_NAME,
           X_RULE_OBJECT_NAME,
           X_RESULT_TYPE,
           X_REQUIRED_FLAG,
           X_USE_DEFAULT_VALUE_FLAG,
           X_FLEX_VALUE_SET_NAME,
           X_FLEXFIELD_NAME,
           X_FLEXFIELD_APP_SHORT_NAME,
           X_MULTI_RULE_RESULT_FLAG,
           X_USER_RULE_OBJECT_NAME,
           X_DESCRIPTION,
           NVL(X_USE_INSTANCE_FLAG, 'N'),
           X_OWNER,
           X_LAST_UPDATE_DATE,
           X_CUSTOM_MODE);

  LOAD_ROW(X_APP_SHORT_NAME,
           X_RULE_OBJECT_NAME,
           X_DEFAULT_APP_SHORT_NAME,
           X_DEFAULT_VALUE,
           X_OWNER,
           X_LAST_UPDATE_DATE,
           X_CUSTOM_MODE);
end LOAD_ROW;

procedure LOAD_ROW (
  X_APP_SHORT_NAME in VARCHAR2,
  X_RULE_OBJECT_NAME in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_USE_DEFAULT_VALUE_FLAG  IN VARCHAR2,
  X_FLEX_VALUE_SET_NAME in VARCHAR2,
  X_FLEXFIELD_NAME in VARCHAR2,
  X_FLEXFIELD_APP_SHORT_NAME in VARCHAR2,
  X_MULTI_RULE_RESULT_FLAG in VARCHAR2,
  X_USER_RULE_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_USE_INSTANCE_FLAG           IN VARCHAR2  DEFAULT NULL,
  X_OWNER                       IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN VARCHAR2,
  X_CUSTOM_MODE                 IN VARCHAR2)
is
   appid number := null;
   vsid number := null;

  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  l_use_instance_flag   VARCHAR2(1);
  l_parent_rule_object_id   fun_rule_objects_b.parent_rule_object_id%type;

  roid number;

  --For restoring the original values related to INSTANCE information.

    CURSOR FUN_RULE_OBJECTS_CUR(p_rule_object_id NUMBER) IS
    SELECT
      B.RULE_OBJECT_ID,
      B.USE_INSTANCE_FLAG,
      B.INSTANCE_LABEL,
      B.PARENT_RULE_OBJECT_ID,
      B.ORG_ID
    FROM FUN_RULE_OBJECTS_B B
    WHERE B.PARENT_RULE_OBJECT_ID = p_rule_object_id;

begin
   --
   -- Get the APPLICATION_ID. Required
  begin
    SELECT application_id INTO appid
    FROM fnd_application
    WHERE application_short_name = X_APP_SHORT_NAME;
  exception
     WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
      app_exception.raise_exception(exception_text=>'Invalid application short name - '||X_APP_SHORT_NAME);
  end;

  --
  -- Get the FLEX_VALUE_SET_ID. Required only if name is not null
  IF x_flex_value_set_name IS NOT NULL THEN
    begin
      select flex_value_set_id into vsid
      from fnd_flex_value_sets
      where flex_value_set_name = X_FLEX_VALUE_SET_NAME;
    exception
      WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
        app_exception.raise_exception(exception_text=>'Invalid value set name - '||x_flex_value_set_name);
    end;
   ELSE
    vsid := NULL;
  END IF;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  --
  -- Get the RULE_OBJECT_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
  --
  -- Allow the SELECT to raise NO_DATA_FOUND so that it is caught and we
  -- go through the INSERT routine.

  select RULE_OBJECT_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE , USE_INSTANCE_FLAG
  into roid, db_luby, db_ludate, l_use_instance_flag
  from FUN_RULE_OBJECTS_B
  where APPLICATION_ID = appid
  and RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
  AND PARENT_RULE_OBJECT_ID IS NULL;

  --Raise an internal error, if developer wants to update the USE_INSTANCE_FLAG from Y to N.
  --Else, if the flag is NULL and NULL is passed, then make it as N
  if (  l_use_instance_flag  = 'Y' AND X_USE_INSTANCE_FLAG = 'N') then
    app_exception.raise_exception(exception_text=>'Cannot update USE_INSTANCE_FLAG from Y to N. Please use the upgrdae script for this');
  elsif ( l_use_instance_flag IS NULL AND  X_USE_INSTANCE_FLAG IS NULL) then
    l_use_instance_flag := 'N';
  else
    l_use_instance_flag := X_USE_INSTANCE_FLAG;
  end if;


  if (fnd_load_util.UPLOAD_TEST(
      p_file_id     => f_luby,
      p_file_lud    => f_ludate,
      p_db_id       => db_luby,
      p_db_lud      => db_ludate,
      p_custom_mode => x_custom_mode))

  then
    /*For Parent Rule Object, dont allow the users to Update the USE_INSTANCE_FLAG.
      Also, for these rule objects, INSTANCE_LABEL, PARENT_RULE_OBJECT_ID, ORG_ID
      should always be NULL. */

    UPDATE_ROW (
      appid,
      roid,
      X_RULE_OBJECT_NAME,
      X_RESULT_TYPE,
      X_REQUIRED_FLAG,
      X_USE_DEFAULT_VALUE_FLAG,
      vsid,
      X_FLEXFIELD_NAME,
      X_FLEXFIELD_APP_SHORT_NAME,
      X_MULTI_RULE_RESULT_FLAG,
      'ORACLE',
      X_USER_RULE_OBJECT_NAME,
      X_DESCRIPTION,
      l_use_instance_flag,
      null,           --INSTANCE_LABEL,
      null,           --PARENT_RULE_OBJECT_ID,
      null,           --ORG_ID,
      f_ludate,
      f_luby,
      0);

     --After successful Update to Parent Rule Object,
     --we should check if any Rule Object Instances exists or not . If exists,
     --then propagate the changes from Parent Rule Object's non Instance information
     --to Rule Object Instances.

     BEGIN
       IF(upper(l_use_instance_flag) = 'Y') THEN
          FOR C_REC IN FUN_RULE_OBJECTS_CUR(roid) LOOP

             UPDATE_ROW (
                    appid,
                    C_REC.RULE_OBJECT_ID,
                    X_RULE_OBJECT_NAME,
                    X_RESULT_TYPE,
                    X_REQUIRED_FLAG,
                    X_USE_DEFAULT_VALUE_FLAG,
                    vsid,
                    X_FLEXFIELD_NAME,
                    X_FLEXFIELD_APP_SHORT_NAME,
                    X_MULTI_RULE_RESULT_FLAG,
                   'ORACLE',
                    X_USER_RULE_OBJECT_NAME,
                    X_DESCRIPTION,
                    C_REC.USE_INSTANCE_FLAG,
                    C_REC.INSTANCE_LABEL,
                    C_REC.PARENT_RULE_OBJECT_ID,
                    C_REC.ORG_ID,
                    f_ludate,
                    f_luby,
                    0);

	  END LOOP;
       END IF;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
	   NULL;
     END;
     --End of Rule Object Instance changes propagation for UPDATE Mode.
  end if;

EXCEPTION

WHEN NO_DATA_FOUND THEN
  SELECT fun_rule_objects_s.nextval into roid from dual;

  --Pass NULL values for INSTANCE_LABEL, PARENT_RULE_OBJECT_ID, ORG_ID
  --for Rule Object Instances because we dont support seeding of the
  --Rule Object Instance. may be we need it later.

  INSERT_ROW (
    row_id,
    roid,
    appid,
    X_RULE_OBJECT_NAME,
    X_RESULT_TYPE,
    X_REQUIRED_FLAG,
    X_USE_DEFAULT_VALUE_FLAG,
    vsid,
    X_FLEXFIELD_NAME,
    X_FLEXFIELD_APP_SHORT_NAME,
    X_MULTI_RULE_RESULT_FLAG,
    'ORACLE',
    X_USER_RULE_OBJECT_NAME,
    X_DESCRIPTION,
    X_USE_INSTANCE_FLAG,
    null,   --INSTANCE_LABEL
    null,   --PARENT_RULE_OBJECT_ID
    null,   --ORG_ID
    f_ludate,
    f_luby,
    f_ludate,
    f_luby,
    0);

end LOAD_ROW;


procedure LOAD_ROW (
  X_APP_SHORT_NAME in VARCHAR2,
  X_RULE_OBJECT_NAME in VARCHAR2,
  X_DEFAULT_APP_SHORT_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_OWNER                       IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN VARCHAR2,
  X_CUSTOM_MODE                 IN VARCHAR2)
is
   appid number;
   default_appid number;

  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  roid number;
begin

 BEGIN
  SELECT application_id INTO appid
  FROM fnd_application
  WHERE application_short_name = X_APP_SHORT_NAME;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
      app_exception.raise_exception(exception_text=>'Invalid application short name - '||X_APP_SHORT_NAME);
 END;

  if (X_DEFAULT_APP_SHORT_NAME IS NOT NULL) then
    SELECT application_id INTO default_appid
    FROM fnd_application
    WHERE application_short_name = X_DEFAULT_APP_SHORT_NAME;
  else
    default_appid := null;
  end if;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

 BEGIN
  SELECT RULE_OBJECT_ID
  into roid
  FROM FUN_RULE_OBJECTS_B
  WHERE application_id = appid
  AND   rule_object_name = X_RULE_OBJECT_NAME
  AND   parent_rule_object_id IS NULL;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Invalid rule object name - '||x_rule_object_name);
 END;


  BEGIN
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FUN_RULE_OBJ_ATTRIBUTES
    where RULE_OBJECT_ID = roid;

    if (fnd_load_util.UPLOAD_TEST(
        p_file_id     => f_luby,
        p_file_lud    => f_ludate,
        p_db_id       => db_luby,
        p_db_lud      => db_ludate,
        p_custom_mode => x_custom_mode))
    then
      UPDATE_ROW (
        appid,
        roid,
        default_appid,
        X_DEFAULT_VALUE,
        f_ludate,
        f_luby,
        0);
    end if;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    INSERT_ROW (row_id,
                roid,
                appid,
                X_RULE_OBJECT_NAME,
                default_appid,
                X_DEFAULT_VALUE,
                f_ludate,
                f_luby,
                f_ludate,
                f_luby,
                0);

  END;
end LOAD_ROW;

END FUN_RULE_OBJECTS_PKG;

/
