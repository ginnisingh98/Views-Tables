--------------------------------------------------------
--  DDL for Package Body AMS_CLIK_THRU_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CLIK_THRU_ACT_PKG" as
/* $Header: amslctab.pls 115.5 2003/10/30 20:53:54 rrajesh noship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_SERVER_URL in VARCHAR2,
  X_PROFILE_FOR_SERVER_URL in VARCHAR2,
  X_DEPENDS_ON_APP in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_APPLICABLE_FOR in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DYNAMIC_PARAMS_FLAG in VARCHAR2,
  X_ADHOC_PARAMS_FLAG in VARCHAR2,
  X_JAVA_CLASS_NAME in VARCHAR2,
  X_NEW_JAVA_CLASS_NAME in VARCHAR2,
  X_ACTION_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select ROWID from AMS_CLIK_THRU_ACTIONS_B
    where ACTION_ID = X_ACTION_ID
    ;
  cursor ctl is select ROWID from AMS_CLIK_THRU_ACTIONS_TL
    where ACTION_ID = X_ACTION_ID
    ;
begin
	insert into AMS_CLIK_THRU_ACTIONS_B (
		ACTION_ID
		,ACTION_CODE
		,EXECUTABLE_NAME
		,SERVER_URL
		,PROFILE_FOR_SERVER_URL
		,DEPENDS_ON_APP
		,APPLICATION_ID
		,APPLICABLE_FOR
		,TRACK_FLAG
		,ENABLED_FLAG
		,DYNAMIC_PARAMS_FLAG
		,ADHOC_PARAMS_FLAG
		,JAVA_CLASS_NAME
		,NEW_JAVA_CLASS_NAME
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		,OBJECT_VERSION_NUMBER
	) values (
		X_ACTION_ID
		,X_ACTION_CODE
		,X_EXECUTABLE_NAME
		,X_SERVER_URL
		,X_PROFILE_FOR_SERVER_URL
		,X_DEPENDS_ON_APP
		,X_APPLICATION_ID
		,X_APPLICABLE_FOR
		,X_TRACK_FLAG
		,X_ENABLED_FLAG
		,X_DYNAMIC_PARAMS_FLAG
		,X_ADHOC_PARAMS_FLAG
		,X_JAVA_CLASS_NAME
		,X_NEW_JAVA_CLASS_NAME
		,DECODE(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_LAST_UPDATE_DATE)
		,DECODE(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATED_BY)
		,DECODE(X_CREATION_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_CREATION_DATE)
		,DECODE(X_CREATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_CREATED_BY)
		,DECODE(X_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATE_LOGIN)
		,X_OBJECT_VERSION_NUMBER
	);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

	insert into AMS_CLIK_THRU_ACTIONS_TL (
		ACTION_ID
		,ACTION_CODE_MEANING
		,DESCRIPTION
		,LANGUAGE
		,SOURCE_LANG
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
	)
	SELECT
     X_ACTION_ID
    ,X_ACTION_CODE_MEANING
    ,DECODE(X_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,X_DESCRIPTION)
    ,l.language_code
    ,USERENV('lang')
    ,DECODE(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_LAST_UPDATE_DATE)
    ,DECODE(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATED_BY)
    ,DECODE(X_CREATION_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_CREATION_DATE)
    ,DECODE(X_CREATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_CREATED_BY)
    ,DECODE(X_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATE_LOGIN)
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM AMS_CLIK_THRU_ACTIONS_TL T
    WHERE T.ACTION_ID = X_ACTION_ID
    AND T.LANGUAGE = l.language_code);

  open ctl;
  fetch ctl into X_ROWID;
  if (ctl%notfound) then
    close ctl;
    raise no_data_found;
  end if;
  close ctl;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ACTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_SERVER_URL in VARCHAR2,
  X_PROFILE_FOR_SERVER_URL in VARCHAR2,
  X_DEPENDS_ON_APP in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_APPLICABLE_FOR in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DYNAMIC_PARAMS_FLAG in VARCHAR2,
  X_ADHOC_PARAMS_FLAG in VARCHAR2,
  X_JAVA_CLASS_NAME in VARCHAR2,
  X_NEW_JAVA_CLASS_NAME in VARCHAR2,
  X_ACTION_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
     OBJECT_VERSION_NUMBER
		,ACTION_CODE
		,EXECUTABLE_NAME
		,SERVER_URL
		,PROFILE_FOR_SERVER_URL
		,DEPENDS_ON_APP
		,APPLICATION_ID
		,APPLICABLE_FOR
		,TRACK_FLAG
		,ENABLED_FLAG
		,DYNAMIC_PARAMS_FLAG
		,ADHOC_PARAMS_FLAG
		,JAVA_CLASS_NAME
		,NEW_JAVA_CLASS_NAME
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
    from AMS_CLIK_THRU_ACTIONS_B
    where ACTION_ID = X_ACTION_ID
    for update of ACTION_ID nowait;
  recinfo c%rowtype;

  /*
  cursor ctl is select
		ACTION_ID
		,ACTION_CODE_MEANING
		,DESCRIPTION
		,LANGUAGE
		,SOURCE_LANG
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
    from AMS_CLIK_THRU_ACTIONS_TL
    where ACTION_ID = X_ACTION_ID
    for update of ACTION_ID nowait;
  tlrecinfo ctl%rowtype;
  */

  CURSOR ctl IS SELECT
      ACTION_CODE_MEANING,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('lang'), 'y', 'n') baselang
    FROM AMS_CLIK_THRU_ACTIONS_TL
    WHERE ACTION_ID = X_ACTION_ID
    AND USERENV('lang') IN (LANGUAGE, source_lang)
    FOR UPDATE OF ACTION_ID NOWAIT;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.ACTION_CODE = X_ACTION_CODE)
           OR ((recinfo.ACTION_CODE is null) AND (X_ACTION_CODE is null)))
      AND ((recinfo.EXECUTABLE_NAME = X_EXECUTABLE_NAME)
           OR ((recinfo.EXECUTABLE_NAME is null) AND (X_EXECUTABLE_NAME is null)))
      AND ((recinfo.SERVER_URL = X_SERVER_URL)
           OR ((recinfo.SERVER_URL is null) AND (X_SERVER_URL is null)))
      AND ((recinfo.PROFILE_FOR_SERVER_URL = X_PROFILE_FOR_SERVER_URL)
           OR ((recinfo.PROFILE_FOR_SERVER_URL is null) AND (X_PROFILE_FOR_SERVER_URL is null)))
      AND ((recinfo.DEPENDS_ON_APP = X_DEPENDS_ON_APP)
           OR ((recinfo.DEPENDS_ON_APP is null) AND (X_DEPENDS_ON_APP is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.APPLICABLE_FOR = X_APPLICABLE_FOR)
           OR ((recinfo.APPLICABLE_FOR is null) AND (X_APPLICABLE_FOR is null)))
      AND ((recinfo.TRACK_FLAG = X_TRACK_FLAG)
           OR ((recinfo.TRACK_FLAG is null) AND (X_TRACK_FLAG is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.DYNAMIC_PARAMS_FLAG = X_DYNAMIC_PARAMS_FLAG)
           OR ((recinfo.DYNAMIC_PARAMS_FLAG is null) AND (X_DYNAMIC_PARAMS_FLAG is null)))
      AND ((recinfo.ADHOC_PARAMS_FLAG = X_ADHOC_PARAMS_FLAG)
           OR ((recinfo.ADHOC_PARAMS_FLAG is null) AND (X_ADHOC_PARAMS_FLAG is null)))
      AND ((recinfo.JAVA_CLASS_NAME = X_JAVA_CLASS_NAME)
           OR ((recinfo.JAVA_CLASS_NAME is null) AND (X_JAVA_CLASS_NAME is null)))
      AND ((recinfo.NEW_JAVA_CLASS_NAME = X_NEW_JAVA_CLASS_NAME)
           OR ((recinfo.NEW_JAVA_CLASS_NAME is null) AND (X_NEW_JAVA_CLASS_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  FOR tlinfo IN ctl LOOP
  IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.ACTION_CODE_MEANING = X_ACTION_CODE_MEANING)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION IS NULL) AND (X_DESCRIPTION IS NULL)))
      ) THEN
        NULL;
      ELSE
        Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
        App_Exception.raise_exception;
      END IF;
    END IF;
  END LOOP;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ACTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_SERVER_URL in VARCHAR2,
  X_PROFILE_FOR_SERVER_URL in VARCHAR2,
  X_DEPENDS_ON_APP in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_APPLICABLE_FOR in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DYNAMIC_PARAMS_FLAG in VARCHAR2,
  X_ADHOC_PARAMS_FLAG in VARCHAR2,
  X_JAVA_CLASS_NAME in VARCHAR2,
  X_NEW_JAVA_CLASS_NAME in VARCHAR2,
  X_ACTION_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_CLIK_THRU_ACTIONS_B set
		OBJECT_VERSION_NUMBER	= X_OBJECT_VERSION_NUMBER
		,ACTION_CODE				= X_ACTION_CODE
		,EXECUTABLE_NAME			= X_EXECUTABLE_NAME
		,SERVER_URL					= X_SERVER_URL
		,PROFILE_FOR_SERVER_URL = X_PROFILE_FOR_SERVER_URL
		,DEPENDS_ON_APP			= X_DEPENDS_ON_APP
		,APPLICATION_ID			= X_APPLICATION_ID
		,APPLICABLE_FOR			= X_APPLICABLE_FOR
		,TRACK_FLAG					= X_TRACK_FLAG
		,ENABLED_FLAG				= X_ENABLED_FLAG
		,DYNAMIC_PARAMS_FLAG		= X_DYNAMIC_PARAMS_FLAG
		,ADHOC_PARAMS_FLAG		= X_ADHOC_PARAMS_FLAG
		,JAVA_CLASS_NAME			= X_JAVA_CLASS_NAME
		,NEW_JAVA_CLASS_NAME			= X_NEW_JAVA_CLASS_NAME
		,LAST_UPDATE_DATE			= X_LAST_UPDATE_DATE
		,LAST_UPDATED_BY			= X_LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN		= X_LAST_UPDATE_LOGIN
  where ACTION_ID           = X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_CLIK_THRU_ACTIONS_TL set
    ACTION_CODE_MEANING = X_ACTION_CODE_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = USERENV('LANG')
  where ACTION_ID = X_ACTION_ID
  and USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTION_ID in NUMBER
) is
begin
  delete from AMS_CLIK_THRU_ACTIONS_TL
  where ACTION_ID = X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_CLIK_THRU_ACTIONS_B
  where ACTION_ID = X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure  LOAD_ROW(
  X_ACTION_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_SERVER_URL in VARCHAR2,
  X_PROFILE_FOR_SERVER_URL in VARCHAR2,
  X_DEPENDS_ON_APP in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_APPLICABLE_FOR in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DYNAMIC_PARAMS_FLAG in VARCHAR2,
  X_ADHOC_PARAMS_FLAG in VARCHAR2,
  X_JAVA_CLASS_NAME in VARCHAR2,
  X_NEW_JAVA_CLASS_NAME in VARCHAR2,
  X_ACTION_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in  VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

l_user_id   number := 0;
l_last_updated_by number;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

cursor c_obj_verno is
  select OBJECT_VERSION_NUMBER,
	 last_updated_by
  from   AMS_CLIK_THRU_ACTIONS_B
  where  ACTION_ID =  X_ACTION_ID;

cursor c_chk_cta_exists is
  select 'x'
  from   AMS_CLIK_THRU_ACTIONS_B
  where  ACTION_ID = X_ACTION_ID;

cursor ctl_chk_cta_exists is
  select 'x'
  from   AMS_CLIK_THRU_ACTIONS_TL
  where  ACTION_ID = X_ACTION_ID;

BEGIN

 if X_OWNER = 'SEED' then
     l_user_id := 1;
 elsif X_OWNER = 'ORACLE' then
     l_user_id := 2;
 elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
 end if;

 open c_chk_cta_exists;
 fetch c_chk_cta_exists into l_dummy_char;
 if c_chk_cta_exists%notfound
 then
    close c_chk_cta_exists;

    l_obj_verno := 1;

    AMS_CLIK_THRU_ACT_PKG.INSERT_ROW(
		  X_ROWID							=> l_row_id
		  ,X_ACTION_ID						=> X_ACTION_ID
		  ,X_ACTION_CODE					=> X_ACTION_CODE
		  ,X_EXECUTABLE_NAME				=> X_EXECUTABLE_NAME
		  ,X_SERVER_URL					=> X_SERVER_URL
		  ,X_PROFILE_FOR_SERVER_URL	=> X_PROFILE_FOR_SERVER_URL
		  ,X_DEPENDS_ON_APP				=> X_DEPENDS_ON_APP
		  ,X_APPLICATION_ID				=> X_APPLICATION_ID
		  ,X_APPLICABLE_FOR				=> X_APPLICABLE_FOR
		  ,X_TRACK_FLAG					=> X_TRACK_FLAG
		  ,X_ENABLED_FLAG					=> X_ENABLED_FLAG
		  ,X_DYNAMIC_PARAMS_FLAG		=> X_DYNAMIC_PARAMS_FLAG
		  ,X_ADHOC_PARAMS_FLAG			=> X_ADHOC_PARAMS_FLAG
		  ,X_JAVA_CLASS_NAME				=> X_JAVA_CLASS_NAME
		  ,X_NEW_JAVA_CLASS_NAME				=> X_NEW_JAVA_CLASS_NAME
		  ,X_ACTION_CODE_MEANING		=> X_ACTION_CODE_MEANING
		  ,X_DESCRIPTION					=> X_DESCRIPTION
		  ,X_LAST_UPDATE_DATE			=> SYSDATE
		  ,X_LAST_UPDATED_BY				=> l_user_id
		  ,X_CREATION_DATE				=> SYSDATE
		  ,X_CREATED_BY					=> l_user_id
		  ,X_LAST_UPDATE_LOGIN			=> 0
		  ,X_OBJECT_VERSION_NUMBER		=> l_obj_verno
    );
else
   close c_chk_cta_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno,l_last_updated_by;
   close c_obj_verno;

   if (l_last_updated_by in (1,2,0) OR
       NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

       AMS_CLIK_THRU_ACT_PKG.UPDATE_ROW(
		X_ACTION_ID               =>    X_ACTION_ID,
		X_ACTION_CODE				  =>	  X_ACTION_CODE,
		X_EXECUTABLE_NAME			  =>	  X_EXECUTABLE_NAME,
		X_SERVER_URL				  =>	  X_SERVER_URL,
		X_PROFILE_FOR_SERVER_URL  =>	  X_PROFILE_FOR_SERVER_URL,
		X_DEPENDS_ON_APP			  =>	  X_DEPENDS_ON_APP,
		X_APPLICATION_ID			  =>	  X_APPLICATION_ID,
		X_APPLICABLE_FOR			  =>	  X_APPLICABLE_FOR,
		X_TRACK_FLAG				  =>	  X_TRACK_FLAG,
		X_ENABLED_FLAG				  =>	  X_ENABLED_FLAG,
		X_DYNAMIC_PARAMS_FLAG	  =>	  X_DYNAMIC_PARAMS_FLAG,
		X_ADHOC_PARAMS_FLAG		  =>	  X_ADHOC_PARAMS_FLAG,
		X_JAVA_CLASS_NAME			  =>	  X_JAVA_CLASS_NAME,
		X_NEW_JAVA_CLASS_NAME			  =>	  X_NEW_JAVA_CLASS_NAME,
		X_ACTION_CODE_MEANING	  =>	  X_ACTION_CODE_MEANING,
		X_DESCRIPTION				  =>	  X_DESCRIPTION,
		X_LAST_UPDATE_DATE        =>    SYSDATE,
		X_LAST_UPDATED_BY         =>    l_user_id,
		X_LAST_UPDATE_LOGIN       =>    0,
		X_OBJECT_VERSION_NUMBER   =>    l_obj_verno + 1
         );
    end if;
end if;

END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
	  X_ACTION_ID IN NUMBER
	, X_ACTION_CODE_MEANING IN VARCHAR2
	, X_DESCRIPTION IN VARCHAR2
	, X_OWNER IN VARCHAR2
	, X_CUSTOM_MODE IN VARCHAR2
) IS
    cursor c_last_updated_by is
    select last_updated_by
    from AMS_CLIK_THRU_ACTIONS_TL
    where ACTION_ID = X_ACTION_ID
    and  USERENV('LANG') = LANGUAGE;

    l_last_updated_by number;

BEGIN

  open c_last_updated_by;
  fetch c_last_updated_by into l_last_updated_by;
  close c_last_updated_by;


  if (l_last_updated_by in (1,2,0) OR
       NVL(x_custom_mode,'PRESERVE')='FORCE') THEN
  -- Only update rows which have not been altered by user

     UPDATE AMS_CLIK_THRU_ACTIONS_TL
     SET description = X_DESCRIPTION,
      action_code_meaning = X_ACTION_CODE_MEANING,
      source_lang = USERENV('LANG'),
      last_update_date = SYSDATE,
      last_updated_by = DECODE(X_OWNER, 'SEED', 1,
			       'ORACLE',2,
			       'SYSADMIN',0 , -1),
      last_update_login = 0
    WHERE ACTION_ID = X_ACTION_ID
    AND USERENV('LANG') IN (LANGUAGE, source_lang);

  end if;

END TRANSLATE_ROW;

PROCEDURE add_language
IS
BEGIN
  DELETE FROM AMS_CLIK_THRU_ACTIONS_TL T
  WHERE NOT EXISTS
    (SELECT NULL
     FROM AMS_CLIK_THRU_ACTIONS_B B
     WHERE B.ACTION_ID = T.ACTION_ID
    );

  UPDATE AMS_CLIK_THRU_ACTIONS_TL T SET (
      ACTION_CODE_MEANING,
      DESCRIPTION
    ) =
	 (SELECT
      T1.ACTION_CODE_MEANING,
      T1.DESCRIPTION
    FROM AMS_CLIK_THRU_ACTIONS_TL T1
    WHERE T1.ACTION_ID = T.ACTION_ID
    AND T1.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.ACTION_ID,
      T.LANGUAGE
   ) IN
   (SELECT
      subt.ACTION_ID,
      subt.LANGUAGE
    FROM AMS_CLIK_THRU_ACTIONS_TL subb, AMS_CLIK_THRU_ACTIONS_TL subt
    WHERE subb.ACTION_ID = subt.ACTION_ID
    AND subb.LANGUAGE = subt.SOURCE_LANG
    AND (subb.ACTION_CODE_MEANING <> subt.ACTION_CODE_MEANING
      OR subb.DESCRIPTION <> subt.DESCRIPTION
      OR (subb.DESCRIPTION IS NULL AND subt.DESCRIPTION IS NOT NULL)
      OR (subb.DESCRIPTION IS NOT NULL AND subt.DESCRIPTION IS NULL)
  ));

  INSERT INTO AMS_CLIK_THRU_ACTIONS_TL (
    action_id,
    action_code_meaning,
    description,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    LANGUAGE,
    source_lang
  ) SELECT /*+ ordered */
    b.action_id,
    b.action_code_meaning,
    b.description,
    b.created_by,
    b.creation_date,
    b.last_updated_by,
    b.last_update_date,
    b.last_update_login,
    l.language_code,
    b.source_lang
  FROM ams_clik_thru_actions_tl b, fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND b.LANGUAGE = USERENV('lang')
  AND NOT EXISTS
    (SELECT NULL
    FROM ams_clik_thru_actions_tl T
    WHERE T.action_id = b.action_id
    AND T.LANGUAGE = l.language_code);
END add_language;


end AMS_CLIK_THRU_ACT_PKG;

/
