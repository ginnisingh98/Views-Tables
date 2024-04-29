--------------------------------------------------------
--  DDL for Package Body AMS_TCOP_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TCOP_PERIODS_PKG" as
/* $Header: amsltcpb.pls 115.1 2003/10/17 11:53:42 mayjain noship $ */
procedure INSERT_ROW (
	X_ROWID IN OUT NOCOPY VARCHAR2,
	X_PERIOD_ID IN NUMBER,
	X_NO_OF_DAYS IN NUMBER,
	X_ENABLED_FLAG IN VARCHAR2,
	X_PERIOD_NAME IN VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_CREATION_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER,
	X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select ROWID from AMS_TCOP_FR_PERIODS_B
    where PERIOD_ID = X_PERIOD_ID
    ;
  cursor ctl is select ROWID from AMS_TCOP_FR_PERIODS_TL
    where PERIOD_ID = X_PERIOD_ID
    ;
begin
	insert into AMS_TCOP_FR_PERIODS_B (
		PERIOD_ID,
		NO_OF_DAYS,
		ENABLED_FLAG,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER
	) values (
		X_PERIOD_ID,
		X_NO_OF_DAYS,
		X_ENABLED_FLAG,
		DECODE(X_LAST_UPDATE_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_LAST_UPDATE_DATE),
		DECODE(X_LAST_UPDATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATED_BY),
		DECODE(X_CREATION_DATE,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,X_CREATION_DATE),
		DECODE(X_CREATED_BY,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,X_CREATED_BY),
		DECODE(X_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,X_LAST_UPDATE_LOGIN),
		X_OBJECT_VERSION_NUMBER
	);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

	insert into AMS_TCOP_FR_PERIODS_TL (
		PERIOD_ID,
		PERIOD_NAME,
		DESCRIPTION,
		LANGUAGE,
		SOURCE_LANG,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
	)
	SELECT
	     X_PERIOD_ID
	    ,X_PERIOD_NAME
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
    FROM AMS_TCOP_FR_PERIODS_TL T
    WHERE T.PERIOD_ID = X_PERIOD_ID
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
	X_PERIOD_ID IN NUMBER,
	X_OBJECT_VERSION_NUMBER in NUMBER,
	X_NO_OF_DAYS IN NUMBER,
	X_ENABLED_FLAG IN VARCHAR2,
	X_PERIOD_NAME IN VARCHAR2,
	X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
		OBJECT_VERSION_NUMBER,
		NO_OF_DAYS,
		ENABLED_FLAG,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
    from AMS_TCOP_FR_PERIODS_B
    where PERIOD_ID = X_PERIOD_ID
    for update of PERIOD_ID nowait;
  recinfo c%rowtype;



  CURSOR ctl IS SELECT
      PERIOD_NAME,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('lang'), 'Y', 'N') baselang
    FROM AMS_TCOP_FR_PERIODS_TL
    WHERE PERIOD_ID = X_PERIOD_ID
    AND USERENV('lang') IN (LANGUAGE, source_lang)
    FOR UPDATE OF PERIOD_ID NOWAIT;

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
      AND ((recinfo.NO_OF_DAYS = X_NO_OF_DAYS)
           OR ((recinfo.NO_OF_DAYS is null) AND (X_NO_OF_DAYS is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  FOR tlinfo IN ctl LOOP
  IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.PERIOD_NAME = X_PERIOD_NAME)
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
	X_PERIOD_ID IN NUMBER,
	X_OBJECT_VERSION_NUMBER in NUMBER,
	X_NO_OF_DAYS IN NUMBER,
	X_ENABLED_FLAG IN VARCHAR2,
	X_PERIOD_NAME IN VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_TCOP_FR_PERIODS_B set
		OBJECT_VERSION_NUMBER	= X_OBJECT_VERSION_NUMBER
		,NO_OF_DAYS				= X_NO_OF_DAYS
		,ENABLED_FLAG				= X_ENABLED_FLAG
		,LAST_UPDATE_DATE			= X_LAST_UPDATE_DATE
		,LAST_UPDATED_BY			= X_LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN		= X_LAST_UPDATE_LOGIN
  where PERIOD_ID           = X_PERIOD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_TCOP_FR_PERIODS_TL set
    PERIOD_NAME = X_PERIOD_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = USERENV('LANG')
  where PERIOD_ID = X_PERIOD_ID
  and USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
	X_PERIOD_ID IN NUMBER
) is
begin
	delete from AMS_TCOP_FR_PERIODS_TL
	where PERIOD_ID = X_PERIOD_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;

	delete from AMS_TCOP_FR_PERIODS_B
		where PERIOD_ID = X_PERIOD_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;

end DELETE_ROW;



procedure  LOAD_ROW(
	X_PERIOD_ID IN NUMBER,
	X_NO_OF_DAYS IN NUMBER,
	X_ENABLED_FLAG IN VARCHAR2,
	X_PERIOD_NAME IN VARCHAR2,
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
  from   AMS_TCOP_FR_PERIODS_B
  where  PERIOD_ID =  X_PERIOD_ID;

cursor c_chk_prd_exists is
  select 'x'
  from   AMS_TCOP_FR_PERIODS_B
  where  PERIOD_ID = X_PERIOD_ID;

cursor ctl_chk_prd_exists is
  select 'x'
  from   AMS_TCOP_FR_PERIODS_TL
  where  PERIOD_ID = X_PERIOD_ID;

BEGIN

 if X_OWNER = 'SEED' then
     l_user_id := 1;
 elsif X_OWNER = 'ORACLE' then
     l_user_id := 2;
 elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
 end if;

 open c_chk_prd_exists;
 fetch c_chk_prd_exists into l_dummy_char;
 if c_chk_prd_exists%notfound
 then
    close c_chk_prd_exists;

    l_obj_verno := 1;

    AMS_TCOP_PERIODS_PKG.INSERT_ROW (
			X_ROWID			=>	l_row_id,
			X_PERIOD_ID		=>	X_PERIOD_ID,
			X_NO_OF_DAYS		=>	X_NO_OF_DAYS,
			X_ENABLED_FLAG		=>	X_ENABLED_FLAG,
			X_PERIOD_NAME		=>	X_PERIOD_NAME,
			X_DESCRIPTION		=>	X_DESCRIPTION,
			X_LAST_UPDATE_DATE	=>	sysdate,
			X_LAST_UPDATED_BY	=>	l_user_id,
			X_CREATION_DATE		=>	sysdate,
			X_CREATED_BY		=>	l_user_id,
			X_LAST_UPDATE_LOGIN	=>	0,
			X_OBJECT_VERSION_NUMBER =>	l_obj_verno
		);
else
   close c_chk_prd_exists;

   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno,l_last_updated_by;
   close c_obj_verno;

   if (l_last_updated_by in (1,2,0) OR
       NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

       AMS_TCOP_PERIODS_PKG.UPDATE_ROW(
		X_PERIOD_ID		=>	X_PERIOD_ID,
		X_NO_OF_DAYS		=>	X_NO_OF_DAYS,
		X_ENABLED_FLAG		=>	X_ENABLED_FLAG,
		X_PERIOD_NAME		=>	X_PERIOD_NAME,
		X_DESCRIPTION		=>	X_DESCRIPTION,
		X_LAST_UPDATE_DATE      =>    SYSDATE,
		X_LAST_UPDATED_BY       =>    l_user_id,
		X_LAST_UPDATE_LOGIN     =>    0,
		X_OBJECT_VERSION_NUMBER =>    l_obj_verno + 1
         );
    end if;
end if;

END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
	X_PERIOD_ID IN NUMBER,
	X_PERIOD_NAME IN VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
	X_OWNER IN VARCHAR2,
	X_CUSTOM_MODE IN VARCHAR2
) IS
    cursor c_last_updated_by is
    select last_updated_by
    from AMS_TCOP_FR_PERIODS_TL
    where PERIOD_ID = X_PERIOD_ID
    and  USERENV('LANG') = LANGUAGE;

    l_last_updated_by number;

BEGIN

  open c_last_updated_by;
  fetch c_last_updated_by into l_last_updated_by;
  close c_last_updated_by;


  if (l_last_updated_by in (1,2,0) OR
       NVL(x_custom_mode,'PRESERVE')='FORCE') THEN
  -- Only update rows which have not been altered by user

     UPDATE AMS_TCOP_FR_PERIODS_TL
     SET description = X_DESCRIPTION,
      period_name = X_PERIOD_NAME,
      source_lang = USERENV('LANG'),
      last_update_date = SYSDATE,
      last_updated_by = DECODE(X_OWNER, 'SEED', 1,
			       'ORACLE',2,
			       'SYSADMIN',0 , -1),
      last_update_login = 0
    WHERE PERIOD_ID = X_PERIOD_ID
    AND USERENV('LANG') IN (LANGUAGE, source_lang);

  end if;

END TRANSLATE_ROW;


PROCEDURE add_language
IS
BEGIN
  DELETE FROM AMS_TCOP_FR_PERIODS_TL T
  WHERE NOT EXISTS
    (SELECT NULL
     FROM AMS_TCOP_FR_PERIODS_B B
     WHERE B.PERIOD_ID = T.PERIOD_ID
    );

  UPDATE AMS_TCOP_FR_PERIODS_TL T SET (
      PERIOD_NAME,
      DESCRIPTION
    ) =
	 (SELECT
      T1.PERIOD_NAME,
      T1.DESCRIPTION
    FROM AMS_TCOP_FR_PERIODS_TL T1
    WHERE T1.PERIOD_ID = T.PERIOD_ID
    AND T1.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.PERIOD_ID,
      T.LANGUAGE
   ) IN
   (SELECT
      subt.PERIOD_ID,
      subt.LANGUAGE
    FROM AMS_TCOP_FR_PERIODS_TL subb, AMS_TCOP_FR_PERIODS_TL subt
    WHERE subb.PERIOD_ID = subt.PERIOD_ID
    AND subb.LANGUAGE = subt.SOURCE_LANG
    AND (subb.PERIOD_NAME <> subt.PERIOD_NAME
      OR subb.DESCRIPTION <> subt.DESCRIPTION
      OR (subb.DESCRIPTION IS NULL AND subt.DESCRIPTION IS NOT NULL)
      OR (subb.DESCRIPTION IS NOT NULL AND subt.DESCRIPTION IS NULL)
  ));

  INSERT INTO AMS_TCOP_FR_PERIODS_TL (
	PERIOD_ID,
	PERIOD_NAME,
	DESCRIPTION,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	LANGUAGE,
	SOURCE_LANG
  )
  SELECT /*+ ordered */
	b.PERIOD_ID,
	b.PERIOD_NAME,
	b.DESCRIPTION,
	b.CREATED_BY,
	b.CREATION_DATE,
	b.LAST_UPDATED_BY,
	b.LAST_UPDATE_DATE,
	b.LAST_UPDATE_LOGIN,
	l.language_code,
	b.SOURCE_LANG
  FROM AMS_TCOP_FR_PERIODS_TL b, fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND b.LANGUAGE = USERENV('lang')
  AND NOT EXISTS
    (SELECT NULL
    FROM AMS_TCOP_FR_PERIODS_TL T
    WHERE T.PERIOD_ID = b.PERIOD_ID
    AND T.LANGUAGE = l.language_code);
END add_language;


end AMS_TCOP_PERIODS_PKG;

/
