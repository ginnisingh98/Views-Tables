--------------------------------------------------------
--  DDL for Package Body AMS_CLIK_THRU_ACT_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CLIK_THRU_ACT_PARAM_PKG" as
/* $Header: amslctpb.pls 115.8 2003/11/26 06:46:25 mayjain noship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_ACTION_PARAM_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_PARAM_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_ENCRYPT_FLAG in VARCHAR2,
  X_LOV in VARCHAR2,
  X_ACTION_PARAM_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
)
is
  cursor c is select ROWID from AMS_CLIK_THRU_ACT_PARAMS_B
    where ACTION_PARAM_ID = X_ACTION_PARAM_ID
    ;
  cursor ctl is select ROWID from AMS_CLIK_THRU_ACT_PARAMS_TL
    where ACTION_PARAM_ID = X_ACTION_PARAM_ID
    ;
begin

	insert into AMS_CLIK_THRU_ACT_PARAMS_B (
		ACTION_PARAM_ID
		,ACTION_ID
		,ACTION_CODE
		,ACTION_PARAM_CODE
		,ENABLED_FLAG
		,TRACK_FLAG
		,MANDATORY_FLAG
		,ENCRYPT_FLAG
		,LOV
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		,OBJECT_VERSION_NUMBER
	) values (
		X_ACTION_PARAM_ID
		,X_ACTION_ID
		,X_ACTION_CODE
		,X_ACTION_PARAM_CODE
		,X_ENABLED_FLAG
		,X_TRACK_FLAG
		,X_MANDATORY_FLAG
		,X_ENCRYPT_FLAG
		,X_LOV
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

	insert into AMS_CLIK_THRU_ACT_PARAMS_TL (
		ACTION_PARAM_ID
		,ACTION_PARAM_CODE_MEANING
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
     X_ACTION_PARAM_ID
    ,X_ACTION_PARAM_CODE_MEANING
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
    FROM AMS_CLIK_THRU_ACT_PARAMS_TL T
    WHERE T.ACTION_PARAM_ID = X_ACTION_PARAM_ID
    AND T.LANGUAGE = l.language_code);

  open ctl;
  fetch ctl into X_ROWID;
  if (ctl%notfound) then
    close ctl;
    raise no_data_found;
  end if;
  close ctl;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
	RAISE FND_API.g_exc_error;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ACTION_PARAM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_PARAM_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_ENCRYPT_FLAG in VARCHAR2,
  X_LOV in VARCHAR2,
  X_ACTION_PARAM_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
)is
  cursor c is select
     OBJECT_VERSION_NUMBER
		,ACTION_ID
		,ACTION_CODE
		,ACTION_PARAM_CODE
		,ENABLED_FLAG
		,TRACK_FLAG
		,MANDATORY_FLAG
		,ENCRYPT_FLAG
		,LOV		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
    from AMS_CLIK_THRU_ACT_PARAMS_B
    where ACTION_PARAM_ID = X_ACTION_PARAM_ID
    for update of ACTION_PARAM_ID nowait;
  recinfo c%rowtype;

  CURSOR ctl IS SELECT
      ACTION_PARAM_CODE_MEANING,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('lang'), 'y', 'n') baselang
    FROM AMS_CLIK_THRU_ACT_PARAMS_TL
    WHERE ACTION_PARAM_ID = X_ACTION_PARAM_ID
    AND USERENV('lang') IN (LANGUAGE, source_lang)
    FOR UPDATE OF ACTION_PARAM_ID NOWAIT;

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
      AND ((recinfo.ACTION_ID = X_ACTION_ID)
           OR ((recinfo.ACTION_ID is null) AND (X_ACTION_ID is null)))
      AND ((recinfo.ACTION_CODE= X_ACTION_CODE)
           OR ((recinfo.ACTION_CODE is null) AND (X_ACTION_CODE is null)))
      AND ((recinfo.ACTION_PARAM_CODE = X_ACTION_PARAM_CODE)
           OR ((recinfo.ACTION_PARAM_CODE is null) AND (X_ACTION_PARAM_CODE is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.TRACK_FLAG = X_TRACK_FLAG)
           OR ((recinfo.TRACK_FLAG is null) AND (X_TRACK_FLAG is null)))
      AND ((recinfo.MANDATORY_FLAG = X_MANDATORY_FLAG)
           OR ((recinfo.MANDATORY_FLAG is null) AND (X_MANDATORY_FLAG is null)))
      AND ((recinfo.ENCRYPT_FLAG = X_ENCRYPT_FLAG)
           OR ((recinfo.ENCRYPT_FLAG is null) AND (X_ENCRYPT_FLAG is null)))
      AND ((recinfo.LOV = X_LOV)
           OR ((recinfo.LOV is null) AND (X_LOV is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  FOR tlinfo IN ctl LOOP
  IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.ACTION_PARAM_CODE_MEANING = X_ACTION_PARAM_CODE_MEANING)
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
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
	RAISE FND_API.g_exc_error;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ACTION_PARAM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_PARAM_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_ENCRYPT_FLAG in VARCHAR2,
  X_LOV in VARCHAR2,
  X_ACTION_PARAM_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)
is
begin


  update AMS_CLIK_THRU_ACT_PARAMS_B set
		OBJECT_VERSION_NUMBER	= X_OBJECT_VERSION_NUMBER
		,ACTION_ID					= X_ACTION_ID
		,ACTION_CODE				= X_ACTION_CODE
		,ACTION_PARAM_CODE		= X_ACTION_PARAM_CODE
		,ENABLED_FLAG				= X_ENABLED_FLAG
		,TRACK_FLAG					= X_TRACK_FLAG
		,MANDATORY_FLAG			= X_MANDATORY_FLAG
		,ENCRYPT_FLAG				= X_ENCRYPT_FLAG
		,LOV							= X_LOV
		,LAST_UPDATE_DATE			= X_LAST_UPDATE_DATE
		,LAST_UPDATED_BY			= X_LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN		= X_LAST_UPDATE_LOGIN
  where ACTION_PARAM_ID       = X_ACTION_PARAM_ID
    and ACTION_ID					= X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_CLIK_THRU_ACT_PARAMS_TL set
    ACTION_PARAM_CODE_MEANING = X_ACTION_PARAM_CODE_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = USERENV('LANG')
  where ACTION_PARAM_ID = X_ACTION_PARAM_ID
  and USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTION_PARAM_ID in NUMBER
)
is
begin
  delete from AMS_CLIK_THRU_ACT_PARAMS_TL
  where ACTION_PARAM_ID = X_ACTION_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_CLIK_THRU_ACT_PARAMS_B
  where ACTION_PARAM_ID = X_ACTION_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
	RAISE FND_API.g_exc_error;
end DELETE_ROW;

procedure  LOAD_ROW(
  X_ACTION_PARAM_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_PARAM_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TRACK_FLAG in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_ENCRYPT_FLAG in VARCHAR2,
  X_LOV in VARCHAR2,
  X_ACTION_PARAM_CODE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in  VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
)
is
    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    l_obj_verno  number;
    l_last_updated_by number;
    l_dummy_char  varchar2(1);

    cursor c_obj_verno is
	select OBJECT_VERSION_NUMBER, last_updated_by
	from   AMS_CLIK_THRU_ACT_PARAMS_B
	where  ACTION_PARAM_ID =  X_ACTION_PARAM_ID;

    cursor c_ctp_exists is
	select 'x'
	from   AMS_CLIK_THRU_ACT_PARAMS_B
	where  ACTION_PARAM_ID =  X_ACTION_PARAM_ID;

BEGIN

 IF (X_OWNER = 'SEED') THEN
	l_user_id := 1;
 elsif X_OWNER = 'ORACLE' then
     l_user_id := 2;
 elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
 END IF;

   open c_ctp_exists;
   fetch c_ctp_exists into l_dummy_char;

   if c_ctp_exists%notfound
   then
	close c_ctp_exists;

	AMS_CLIK_THRU_ACT_PARAM_PKG.INSERT_ROW(
		  X_ROWID								=> l_row_id
		  ,X_ACTION_PARAM_ID					=> X_ACTION_PARAM_ID
		  ,X_ACTION_ID							=> X_ACTION_ID
		  ,X_ACTION_CODE						=> X_ACTION_CODE
		  ,X_ACTION_PARAM_CODE				=> X_ACTION_PARAM_CODE
		  ,X_ENABLED_FLAG						=> X_ENABLED_FLAG
		  ,X_TRACK_FLAG						=> X_TRACK_FLAG
		  ,X_MANDATORY_FLAG					=> X_MANDATORY_FLAG
		  ,X_ENCRYPT_FLAG						=> X_ENCRYPT_FLAG
		  ,X_LOV									=> X_LOV
		  ,X_ACTION_PARAM_CODE_MEANING	=> X_ACTION_PARAM_CODE_MEANING
		  ,X_DESCRIPTION						=> X_DESCRIPTION
		  ,X_LAST_UPDATE_DATE				=> SYSDATE
		  ,X_LAST_UPDATED_BY					=> l_user_id
		  ,X_CREATION_DATE					=> SYSDATE
		  ,X_CREATED_BY						=> l_user_id
		  ,X_LAST_UPDATE_LOGIN				=> 0
		  ,X_OBJECT_VERSION_NUMBER			=> 1
	);
   else
	close c_ctp_exists;

	open c_obj_verno;
	fetch c_obj_verno into l_obj_verno,l_last_updated_by;
	close c_obj_verno;

	if (l_last_updated_by in (1,2,0) OR
	       NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

	       AMS_CLIK_THRU_ACT_PARAM_PKG.UPDATE_ROW(
			X_ACTION_PARAM_ID             =>   X_ACTION_PARAM_ID,
			X_ACTION_ID	=>   X_ACTION_ID,
			X_ACTION_CODE	=>	  X_ACTION_CODE,
			X_ACTION_PARAM_CODE=>	  X_ACTION_PARAM_CODE,
			X_ENABLED_FLAG	=>	  X_ENABLED_FLAG,
			X_TRACK_FLAG	=>	  X_TRACK_FLAG,
			X_MANDATORY_FLAG=>	  X_MANDATORY_FLAG,
			X_ENCRYPT_FLAG	=>	  X_ENCRYPT_FLAG,
			X_LOV		=>	  X_LOV,
			X_ACTION_PARAM_CODE_MEANING	=>  X_ACTION_PARAM_CODE_MEANING,
			X_DESCRIPTION	=>	  X_DESCRIPTION,
			X_LAST_UPDATE_DATE =>   SYSDATE,
			X_LAST_UPDATED_BY =>   l_user_id,
			X_LAST_UPDATE_LOGIN =>   0,
			X_OBJECT_VERSION_NUMBER =>   l_obj_verno + 1
		 );
	end if;
    end if;

END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
	  X_ACTION_PARAM_ID IN NUMBER
	, X_ACTION_PARAM_CODE_MEANING IN VARCHAR2
	, X_DESCRIPTION IN VARCHAR2
	, X_OWNER IN VARCHAR2
	,X_CUSTOM_MODE IN VARCHAR2
)
IS
    cursor c_last_updated_by is
	      select last_updated_by
	      FROM AMS_CLIK_THRU_ACT_PARAMS_TL
              where  ACTION_PARAM_ID =  X_ACTION_PARAM_ID
	      and  USERENV('LANG') = LANGUAGE;

    l_last_updated_by number;

BEGIN

  open c_last_updated_by;
  fetch c_last_updated_by into l_last_updated_by;
  close c_last_updated_by;

  if (l_last_updated_by in (1,2,0) OR
	 NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

     -- Only update rows which have not been altered by user
     UPDATE AMS_CLIK_THRU_ACT_PARAMS_TL
     SET description = X_DESCRIPTION,
      action_param_code_meaning = X_ACTION_PARAM_CODE_MEANING,
      source_lang = USERENV('LANG'),
      last_update_date = SYSDATE,
      last_updated_by = DECODE(X_OWNER, 'SEED', 1,
			       'ORACLE',2,
			       'SYSADMIN',0, -1),
      last_update_login = 0
      WHERE ACTION_PARAM_ID = X_ACTION_PARAM_ID
      AND USERENV('LANG') IN (LANGUAGE, source_lang);

   end if;

END TRANSLATE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM AMS_CLIK_THRU_ACT_PARAMS_TL T
  WHERE NOT EXISTS
    (SELECT NULL
     FROM AMS_CLIK_THRU_ACT_PARAMS_B B
     WHERE B.ACTION_PARAM_ID = T.ACTION_PARAM_ID
    );

  UPDATE AMS_CLIK_THRU_ACT_PARAMS_TL T SET (
      ACTION_PARAM_CODE_MEANING,
      DESCRIPTION
    ) =
	 (SELECT
      T1.ACTION_PARAM_CODE_MEANING,
      T1.DESCRIPTION
    FROM AMS_CLIK_THRU_ACT_PARAMS_TL T1
    WHERE T1.ACTION_PARAM_ID = T.ACTION_PARAM_ID
    AND T1.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.ACTION_PARAM_ID,
      T.LANGUAGE
   ) IN
   (SELECT
      subt.ACTION_PARAM_ID,
      subt.LANGUAGE
    FROM AMS_CLIK_THRU_ACT_PARAMS_TL subb, AMS_CLIK_THRU_ACT_PARAMS_TL subt
    WHERE subb.ACTION_PARAM_ID = subt.ACTION_PARAM_ID
    AND subb.LANGUAGE = subt.SOURCE_LANG
    AND (subb.ACTION_PARAM_CODE_MEANING <> subt.ACTION_PARAM_CODE_MEANING
      OR subb.DESCRIPTION <> subt.DESCRIPTION
      OR (subb.DESCRIPTION IS NULL AND subt.DESCRIPTION IS NOT NULL)
      OR (subb.DESCRIPTION IS NOT NULL AND subt.DESCRIPTION IS NULL)
  ));

  INSERT INTO AMS_CLIK_THRU_ACT_PARAMS_TL (
    action_param_id,
    action_param_code_meaning,
    description,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    LANGUAGE,
    source_lang
  ) SELECT /*+ ordered */
    b.action_param_id,
    b.action_param_code_meaning,
    b.description,
    b.created_by,
    b.creation_date,
    b.last_updated_by,
    b.last_update_date,
    b.last_update_login,
    l.language_code,
    b.source_lang
  FROM AMS_CLIK_THRU_ACT_PARAMS_TL b, fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND b.LANGUAGE = USERENV('lang')
  AND NOT EXISTS
    (SELECT NULL
    FROM AMS_CLIK_THRU_ACT_PARAMS_TL T
    WHERE T.action_param_id = b.action_param_id
    AND T.LANGUAGE = l.language_code);
END add_language;


end AMS_CLIK_THRU_ACT_PARAM_PKG;

/
