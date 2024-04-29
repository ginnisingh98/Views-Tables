--------------------------------------------------------
--  DDL for Package Body FUN_RULE_CRIT_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_CRIT_PARAMS_PKG" AS
/*$Header: FUNXTMRULRCPTBB.pls 120.6.12010000.3 2009/05/05 06:49:45 rmanikan ship $ */

PROCEDURE INSERT_ROW (
  X_ROWID 			IN OUT NOCOPY VARCHAR2,
  X_CRITERIA_PARAM_ID 		IN NUMBER,
  X_RULE_OBJECT_ID 		IN NUMBER,
  X_PARAM_NAME 			IN VARCHAR2,
  X_DATA_TYPE 			IN VARCHAR2,
  X_FLEX_VALUE_SET_ID 		IN NUMBER,
  X_CREATED_BY_MODULE 		IN VARCHAR2,
  X_USER_PARAM_NAME 		IN VARCHAR2,
  X_DESCRIPTION 		IN VARCHAR2,
  X_TIP_TEXT 			IN VARCHAR2,
  X_CREATION_DATE               IN DATE DEFAULT NULL,
  X_CREATED_BY                  IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_DATE            IN DATE DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) IS

  l_seq_val    FUN_RULE_CRIT_PARAMS_B.CRITERIA_PARAM_ID%TYPE;

begin


  IF X_CRITERIA_PARAM_ID IS NULL THEN
     select FUN_RULE_CRITERIA_PARAMS_S.NEXTVAL into l_seq_val from dual;
  END IF;

  insert into FUN_RULE_CRIT_PARAMS_B (
    CRITERIA_PARAM_ID,
    RULE_OBJECT_ID,
    PARAM_NAME,
    DATA_TYPE,
    FLEX_VALUE_SET_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY_MODULE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values (
    NVL(X_CRITERIA_PARAM_ID,l_seq_val),
    X_RULE_OBJECT_ID,
    X_PARAM_NAME,
    X_DATA_TYPE,
    X_FLEX_VALUE_SET_ID,
    1,
    X_CREATED_BY_MODULE,
    NVL(X_CREATED_BY,FUN_RULE_UTILITY_PKG.CREATED_BY),
    NVL(X_CREATION_DATE,FUN_RULE_UTILITY_PKG.CREATION_DATE),
    NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN),
    NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY)
  )RETURNING ROWID INTO X_ROWID;


  insert into FUN_RULE_CRIT_PARAMS_TL (
    CRITERIA_PARAM_ID,
    USER_PARAM_NAME,
    DESCRIPTION,
    TIP_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    NVL(X_CRITERIA_PARAM_ID,l_seq_val),
    X_USER_PARAM_NAME,
    X_DESCRIPTION,
    X_TIP_TEXT,
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
    from FUN_RULE_CRIT_PARAMS_TL T
    where T.CRITERIA_PARAM_ID = NVL(X_CRITERIA_PARAM_ID,l_seq_val)
    and T.LANGUAGE = L.LANGUAGE_CODE);

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_CRITERIA_PARAM_ID 		IN NUMBER,
  X_OBJECT_VERSION_NUMBER 	IN NUMBER
) IS

  cursor c is select
      OBJECT_VERSION_NUMBER
    from FUN_RULE_CRIT_PARAMS_B
    where CRITERIA_PARAM_ID = X_CRITERIA_PARAM_ID
    for update of CRITERIA_PARAM_ID nowait;
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
  if (
    recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_CRITERIA_PARAM_ID 		IN NUMBER,
  X_RULE_OBJECT_ID 		IN NUMBER,
  X_PARAM_NAME 			IN VARCHAR2,
  X_DATA_TYPE 			IN VARCHAR2,
  X_FLEX_VALUE_SET_ID 		IN NUMBER,
  X_CREATED_BY_MODULE 		IN VARCHAR2,
  X_USER_PARAM_NAME 		IN VARCHAR2,
  X_DESCRIPTION 		IN VARCHAR2,
  X_TIP_TEXT 			IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN DATE DEFAULT NULL,
  X_LAST_UPDATED_BY             IN NUMBER DEFAULT NULL,
  X_LAST_UPDATE_LOGIN           IN NUMBER DEFAULT NULL
) IS

  l_rule_criteria_param_id  FUN_RULE_CRIT_PARAMS_B.CRITERIA_PARAM_ID%TYPE;

begin

  l_rule_criteria_param_id := X_CRITERIA_PARAM_ID;

  IF X_CRITERIA_PARAM_ID IS NULL THEN

	  SELECT CRITERIA_PARAM_ID INTO l_rule_criteria_param_id
	  FROM FUN_RULE_CRIT_PARAMS_B
	  WHERE PARAM_NAME = X_PARAM_NAME
	  AND   RULE_OBJECT_ID = X_RULE_OBJECT_ID;

  END IF;

  update FUN_RULE_CRIT_PARAMS_B set
    RULE_OBJECT_ID = X_RULE_OBJECT_ID,
    PARAM_NAME = X_PARAM_NAME,
    DATA_TYPE = X_DATA_TYPE,
    FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
    CREATED_BY_MODULE = X_CREATED_BY_MODULE,
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN),
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY)
  where CRITERIA_PARAM_ID = l_rule_criteria_param_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FUN_RULE_CRIT_PARAMS_TL set
    USER_PARAM_NAME = X_USER_PARAM_NAME,
    DESCRIPTION = X_DESCRIPTION,
    TIP_TEXT = X_TIP_TEXT,
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN),
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY),
    SOURCE_LANG = userenv('LANG')
  where CRITERIA_PARAM_ID = l_rule_criteria_param_id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


PROCEDURE Select_Row (
    X_CRITERIA_PARAM_ID         IN OUT NOCOPY  NUMBER,
    X_PARAM_NAME			    OUT NOCOPY     VARCHAR2,
    X_RULE_OBJECT_ID		    OUT NOCOPY     NUMBER,
    X_USER_PARAM_NAME			OUT NOCOPY     VARCHAR2,
    X_DESCRIPTION			    OUT NOCOPY     VARCHAR2,
    X_TIP_TEXT                  OUT NOCOPY     VARCHAR2,
    X_DATA_TYPE				    OUT NOCOPY     VARCHAR2,
    X_FLEX_VALUE_SET_ID         OUT NOCOPY     NUMBER,
    X_CREATED_BY_MODULE         OUT NOCOPY     VARCHAR2
) IS

BEGIN

    SELECT
        CRITERIA_PARAM_ID,
        PARAM_NAME,
        RULE_OBJECT_ID,
        USER_PARAM_NAME,
        DESCRIPTION,
        TIP_TEXT,
        DATA_TYPE,
        FLEX_VALUE_SET_ID,
        CREATED_BY_MODULE
    INTO
        X_CRITERIA_PARAM_ID,
        X_PARAM_NAME,
        X_RULE_OBJECT_ID,
        X_USER_PARAM_NAME,
        X_DESCRIPTION,
        X_TIP_TEXT,
        X_DATA_TYPE,
        X_FLEX_VALUE_SET_ID,
        X_CREATED_BY_MODULE
    FROM FUN_RULE_CRIT_PARAMS_VL
    WHERE CRITERIA_PARAM_ID = X_CRITERIA_PARAM_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'p_rule_crit_params_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', X_PARAM_NAME );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (X_CRITERIA_PARAM_ID IN NUMBER)
IS
BEGIN

    DELETE FUN_RULE_CRIT_PARAMS_B
    WHERE CRITERIA_PARAM_ID = X_CRITERIA_PARAM_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

    DELETE FROM FUN_RULE_CRIT_PARAMS_TL
    WHERE CRITERIA_PARAM_ID = X_CRITERIA_PARAM_ID;

    if (sql%notfound) then
      raise no_data_found;
    end if;


END Delete_Row;


procedure ADD_LANGUAGE
IS
BEGIN
  delete from FUN_RULE_CRIT_PARAMS_TL T
  where not exists
    (select NULL
    from FUN_RULE_CRIT_PARAMS_B B
    where B.CRITERIA_PARAM_ID = T.CRITERIA_PARAM_ID
    );

  update FUN_RULE_CRIT_PARAMS_TL T set (
      USER_PARAM_NAME,
      DESCRIPTION,
      TIP_TEXT
    ) = (select
      B.USER_PARAM_NAME,
      B.DESCRIPTION,
      B.TIP_TEXT
    from FUN_RULE_CRIT_PARAMS_TL B
    where B.CRITERIA_PARAM_ID = T.CRITERIA_PARAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CRITERIA_PARAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CRITERIA_PARAM_ID,
      SUBT.LANGUAGE
    from FUN_RULE_CRIT_PARAMS_TL SUBB, FUN_RULE_CRIT_PARAMS_TL SUBT
    where SUBB.CRITERIA_PARAM_ID = SUBT.CRITERIA_PARAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_PARAM_NAME <> SUBT.USER_PARAM_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.TIP_TEXT <> SUBT.TIP_TEXT
      or (SUBB.TIP_TEXT is null and SUBT.TIP_TEXT is not null)
      or (SUBB.TIP_TEXT is not null and SUBT.TIP_TEXT is null)
  ));

  insert into FUN_RULE_CRIT_PARAMS_TL (
    CRITERIA_PARAM_ID,
    USER_PARAM_NAME,
    DESCRIPTION,
    TIP_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CRITERIA_PARAM_ID,
    B.USER_PARAM_NAME,
    B.DESCRIPTION,
    B.TIP_TEXT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FUN_RULE_CRIT_PARAMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FUN_RULE_CRIT_PARAMS_TL T
    where T.CRITERIA_PARAM_ID = B.CRITERIA_PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;

procedure LOAD_ROW (
  X_APP_SHORT_NAME in VARCHAR2,
  X_RULE_OBJECT_NAME in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_DATA_TYPE 			IN VARCHAR2,
  X_FLEX_VALUE_SET_NAME     IN VARCHAR2,
  X_USER_PARAM_NAME 		IN VARCHAR2,
  X_DESCRIPTION 		IN VARCHAR2,
  X_TIP_TEXT 			IN VARCHAR2,
  X_OWNER                       IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN VARCHAR2,
  X_CUSTOM_MODE                 IN VARCHAR2)
IS
  appid number;
  roid number;
  vsid number;

  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  cpid number;
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

 BEGIN
  select RULE_OBJECT_ID
  into roid
  from FUN_RULE_OBJECTS_B
  where APPLICATION_ID = appid
  and RULE_OBJECT_NAME = X_RULE_OBJECT_NAME
  and parent_rule_object_id is null;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Invalid rule object name - '||x_rule_object_name);
 END;

 BEGIN
  select FLEX_VALUE_SET_ID
  into vsid
  from FND_FLEX_VALUE_SETS
  where FLEX_VALUE_SET_NAME = X_FLEX_VALUE_SET_NAME;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Invalid value set name - '||x_flex_value_set_name);
 END;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select CRITERIA_PARAM_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
  into cpid, db_luby, db_ludate
  from FUN_RULE_CRIT_PARAMS_B
  where RULE_OBJECT_ID = roid
  and PARAM_NAME = X_PARAM_NAME;

  if (fnd_load_util.UPLOAD_TEST(
      p_file_id     => f_luby,
      p_file_lud    => f_ludate,
      p_db_id       => db_luby,
      p_db_lud      => db_ludate,
      p_custom_mode => x_custom_mode))
 then
    UPDATE_ROW (
      cpid,
      roid,
      X_PARAM_NAME,
      X_DATA_TYPE,
      vsid,
      'ORACLE',
      X_USER_PARAM_NAME,
      X_DESCRIPTION,
      X_TIP_TEXT,
      f_ludate,
      f_luby,
      0);

 end if;

EXCEPTION

WHEN NO_DATA_FOUND THEN
  SELECT fun_rule_criteria_params_s.nextval into cpid from dual;

  INSERT_ROW (
    row_id,
    cpid,
    roid,
    X_PARAM_NAME,
    X_DATA_TYPE,
    vsid,
    'ORACLE',
    X_USER_PARAM_NAME,
    X_DESCRIPTION,
    X_TIP_TEXT,
    f_ludate,
    f_luby,
    f_ludate,
    f_luby,
    0);


end LOAD_ROW;

PROCEDURE TRANSLATE_ROW(
  X_APP_SHORT_NAME in VARCHAR2,
  X_RULE_OBJECT_NAME in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_USER_PARAM_NAME 		IN VARCHAR2,
  X_DESCRIPTION 		IN VARCHAR2,
  X_TIP_TEXT 			IN VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) IS
  appid number;
  roid number;
  cpid number;

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
  and parent_rule_object_id is null;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Invalid rule object name - '||x_rule_object_name);
 END;

 BEGIN
  select criteria_param_id
  into cpid
  from fun_rule_crit_params_b
  where rule_object_id = roid
  and param_name = X_PARAM_NAME;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Invalid parameter name - '||x_param_name);
 END;

 BEGIN
  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from fun_rule_crit_params_tl
  where criteria_param_id = cpid
  and language = userenv('LANG');
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- Since this should never happen, throwing an exception with hard coded message text
     app_exception.raise_exception(exception_text=>'Unable to find translation row for parameter - '||x_param_name||','||userenv('LANG'));
 END;

  -- c. owners are the same, and file_date > db_date
  if (fnd_load_util.UPLOAD_TEST(
             p_file_id     => f_luby,
             p_file_lud    => f_ludate,
             p_db_id       => db_luby,
             p_db_lud      => db_ludate,
             p_custom_mode => x_custom_mode))
  then
    update fun_rule_crit_params_tl
    set user_param_name = nvl(x_user_param_name, user_param_name),
        description = nvl(x_description, description),
        tip_text = nvl(x_tip_text, tip_text),
	source_lang = userenv('LANG')
    where criteria_param_id = cpid
    and userenv('LANG') in (language, source_lang);
  end if;
END TRANSLATE_ROW;


END FUN_RULE_CRIT_PARAMS_PKG;

/
