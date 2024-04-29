--------------------------------------------------------
--  DDL for Package Body AMW_COMPLIANCE_ENVS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_COMPLIANCE_ENVS_PKG" as
/* $Header: amwtenvb.pls 120.1 2006/05/31 23:34:19 npanandi noship $ */

-- ===============================================================
-- Package name
--          AMW_COMPLIANCE_ENVS_PKG
-- Purpose
--
-- History
-- 		  	06/24/2004    tsho     Creates
-- ===============================================================


-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new compliance environment
--          in AMW_COMPLIANCE_ENVS_B and AMW_COMPLIANCE_ENVS_TL
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2
) is
  cursor C is select ROWID from AMW_COMPLIANCE_ENVS_B
    where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID;
begin
  insert into AMW_COMPLIANCE_ENVS_B (
  COMPLIANCE_ENV_ID,
  START_DATE,
  END_DATE,
  ENABLED_FLAG,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  OBJECT_VERSION_NUMBER,
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
  ATTRIBUTE15
  ) values (
  X_COMPLIANCE_ENV_ID,
  X_START_DATE,
  X_END_DATE,
  X_ENABLED_FLAG,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_DATE,
  X_CREATED_BY,
  X_CREATION_DATE,
  X_LAST_UPDATE_LOGIN,
  X_SECURITY_GROUP_ID,
  X_OBJECT_VERSION_NUMBER,
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
  X_ATTRIBUTE15
  );

  insert into AMW_COMPLIANCE_ENVS_TL (
    LAST_UPDATE_LOGIN,
    COMPLIANCE_ENV_ID,
    NAME,
    ALIAS,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_COMPLIANCE_ENV_ID,
    X_COMPLIANCE_ENV_NAME,
    X_COMPLIANCE_ENV_ALIAS,
    X_COMPLIANCE_ENV_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_COMPLIANCE_ENVS_TL T
    where T.COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2
) is
  cursor c is select
    START_DATE,
    END_DATE,
    ENABLED_FLAG,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
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
    ATTRIBUTE15
    from AMW_COMPLIANCE_ENVS_B
    where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID
    for update of COMPLIANCE_ENV_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      ALIAS,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_COMPLIANCE_ENVS_TL
    where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of COMPLIANCE_ENV_ID nowait;
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
          ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_COMPLIANCE_ENV_NAME)
          AND ((tlinfo.ALIAS = X_COMPLIANCE_ENV_ALIAS)
               OR ((tlinfo.ALIAS is null) AND (X_COMPLIANCE_ENV_ALIAS is null)))
          AND ((tlinfo.DESCRIPTION = X_COMPLIANCE_ENV_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_COMPLIANCE_ENV_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
--          update AMW_COMPLIANCE_ENVS_B and AMW_COMPLIANCE_ENVS_TL
-- ===============================================================
procedure UPDATE_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2
) is
begin
  update AMW_COMPLIANCE_ENVS_B set
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
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
    ATTRIBUTE15 = X_ATTRIBUTE15
  where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_COMPLIANCE_ENVS_TL set
    NAME = X_COMPLIANCE_ENV_NAME,
    ALIAS = X_COMPLIANCE_ENV_ALIAS,
    DESCRIPTION = X_COMPLIANCE_ENV_DESCRIPTION,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


-- ===============================================================
-- Procedure name
--          LOAD_ROW
-- Purpose
--          load data to AMW_COMPLIANCE_ENVS_B and AMW_COMPLIANCE_ENVS_TL
-- ===============================================================
procedure LOAD_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_COMPLIANCE_ENV_NAME in VARCHAR2,
  X_COMPLIANCE_ENV_ALIAS in VARCHAR2,
  X_COMPLIANCE_ENV_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) IS
  l_user_id number;
  l_compliance_env_id number;
  l_row_id varchar2(32767);

BEGIN
	-- Translate owner to file_last_updated_by
	l_user_id := fnd_load_util.owner_id(X_OWNER);

	select COMPLIANCE_ENV_ID into l_compliance_env_id
  	  from AMW_COMPLIANCE_ENVS_B
	 where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID;

      AMW_COMPLIANCE_ENVS_PKG.UPDATE_ROW (
          X_COMPLIANCE_ENV_ID       => l_compliance_env_id,
          X_START_DATE              => X_START_DATE,
          X_END_DATE                => X_END_DATE,
          X_ENABLED_FLAG            => X_ENABLED_FLAG,
          X_LAST_UPDATED_BY         => l_user_id,
          X_LAST_UPDATE_DATE        => sysdate,
          X_LAST_UPDATE_LOGIN       => 0,
          X_SECURITY_GROUP_ID       => X_SECURITY_GROUP_ID,
          X_OBJECT_VERSION_NUMBER   => 1,
          X_ATTRIBUTE_CATEGORY      => X_ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1              => X_ATTRIBUTE1,
          X_ATTRIBUTE2              => X_ATTRIBUTE2,
          X_ATTRIBUTE3              => X_ATTRIBUTE3,
          X_ATTRIBUTE4              => X_ATTRIBUTE4,
          X_ATTRIBUTE5              => X_ATTRIBUTE5,
          X_ATTRIBUTE6              => X_ATTRIBUTE6,
          X_ATTRIBUTE7              => X_ATTRIBUTE7,
          X_ATTRIBUTE8              => X_ATTRIBUTE8,
          X_ATTRIBUTE9              => X_ATTRIBUTE9,
          X_ATTRIBUTE10             => X_ATTRIBUTE10,
          X_ATTRIBUTE11             => X_ATTRIBUTE11,
          X_ATTRIBUTE12             => X_ATTRIBUTE12,
          X_ATTRIBUTE13             => X_ATTRIBUTE13,
          X_ATTRIBUTE14             => X_ATTRIBUTE14,
          X_ATTRIBUTE15             => X_ATTRIBUTE15,
          X_COMPLIANCE_ENV_NAME     => X_COMPLIANCE_ENV_NAME,
          X_COMPLIANCE_ENV_ALIAS    => X_COMPLIANCE_ENV_ALIAS,
          X_COMPLIANCE_ENV_DESCRIPTION  => X_COMPLIANCE_ENV_DESCRIPTION);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	-- 07.29.2004 tsho: should use passed-in x_compliance_env_id
	/*
        select AMW_COMPLIANCE_ENV_S.nextval into l_compliance_env_id
          from dual;
	*/

      AMW_COMPLIANCE_ENVS_PKG.INSERT_ROW (
          X_ROWID                   => l_row_id,
          X_COMPLIANCE_ENV_ID       => X_COMPLIANCE_ENV_ID,
          X_START_DATE              => X_START_DATE,
          X_END_DATE                => X_END_DATE,
          X_ENABLED_FLAG            => X_ENABLED_FLAG,
          X_LAST_UPDATED_BY         => l_user_id,
          X_LAST_UPDATE_DATE        => sysdate,
          X_CREATED_BY              => l_user_id,
          X_CREATION_DATE           => sysdate,
          X_LAST_UPDATE_LOGIN       => 0,
          X_SECURITY_GROUP_ID       => X_SECURITY_GROUP_ID,
          X_OBJECT_VERSION_NUMBER   => 1,
          X_ATTRIBUTE_CATEGORY      => X_ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1              => X_ATTRIBUTE1,
          X_ATTRIBUTE2              => X_ATTRIBUTE2,
          X_ATTRIBUTE3              => X_ATTRIBUTE3,
          X_ATTRIBUTE4              => X_ATTRIBUTE4,
          X_ATTRIBUTE5              => X_ATTRIBUTE5,
          X_ATTRIBUTE6              => X_ATTRIBUTE6,
          X_ATTRIBUTE7              => X_ATTRIBUTE7,
          X_ATTRIBUTE8              => X_ATTRIBUTE8,
          X_ATTRIBUTE9              => X_ATTRIBUTE9,
          X_ATTRIBUTE10             => X_ATTRIBUTE10,
          X_ATTRIBUTE11             => X_ATTRIBUTE11,
          X_ATTRIBUTE12             => X_ATTRIBUTE12,
          X_ATTRIBUTE13             => X_ATTRIBUTE13,
          X_ATTRIBUTE14             => X_ATTRIBUTE14,
          X_ATTRIBUTE15             => X_ATTRIBUTE15,
          X_COMPLIANCE_ENV_NAME     => X_COMPLIANCE_ENV_NAME,
          X_COMPLIANCE_ENV_ALIAS    => X_COMPLIANCE_ENV_ALIAS,
          X_COMPLIANCE_ENV_DESCRIPTION  => X_COMPLIANCE_ENV_DESCRIPTION);

END LOAD_ROW;



-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_COMPLIANCE_ENV_ID in NUMBER
) is
begin
  delete from AMW_COMPLIANCE_ENVS_TL
  where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_COMPLIANCE_ENVS_B
  where COMPLIANCE_ENV_ID = X_COMPLIANCE_ENV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;



-- ===============================================================
-- Procedure name
--          ADD_LANGUAGE
-- Purpose
--
-- ===============================================================
procedure ADD_LANGUAGE
is
begin
  delete from AMW_COMPLIANCE_ENVS_TL T
  where not exists
    (select NULL
    from AMW_COMPLIANCE_ENVS_B B
    where B.COMPLIANCE_ENV_ID = T.COMPLIANCE_ENV_ID
    );

  update AMW_COMPLIANCE_ENVS_TL T set (
      NAME,
      ALIAS,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.ALIAS,
      B.DESCRIPTION
    from AMW_COMPLIANCE_ENVS_TL B
    where B.COMPLIANCE_ENV_ID = T.COMPLIANCE_ENV_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.COMPLIANCE_ENV_ID,
      T.LANGUAGE
  ) in (select
      SUBT.COMPLIANCE_ENV_ID,
      SUBT.LANGUAGE
    from AMW_COMPLIANCE_ENVS_TL SUBB, AMW_COMPLIANCE_ENVS_TL SUBT
    where SUBB.COMPLIANCE_ENV_ID = SUBT.COMPLIANCE_ENV_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.ALIAS <> SUBT.ALIAS
      or (SUBB.ALIAS is null and SUBT.ALIAS is not null)
      or (SUBB.ALIAS is not null and SUBT.ALIAS is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_COMPLIANCE_ENVS_TL (
    LAST_UPDATE_LOGIN,
    COMPLIANCE_ENV_ID,
    NAME,
    ALIAS,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.COMPLIANCE_ENV_ID,
    B.NAME,
    B.ALIAS,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_COMPLIANCE_ENVS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_COMPLIANCE_ENVS_TL T
    where T.COMPLIANCE_ENV_ID = B.COMPLIANCE_ENV_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/**05.31.2006 npanandi: bug 5259681 fix, added translate row***/
procedure TRANSLATE_ROW(
	X_COMPLIANCE_ENV_ID		       in NUMBER,
	X_COMPLIANCE_ENV_NAME	       in VARCHAR2,
	X_COMPLIANCE_ENV_DESCRIPTION   in VARCHAR2,
	X_COMPLIANCE_ENV_ALIAS         in VARCHAR2,
	X_LAST_UPDATE_DATE    	       in VARCHAR2,
	X_OWNER			               in VARCHAR2,
	X_CUSTOM_MODE		           in VARCHAR2) is

   f_luby	 number;	-- entity owner in file
   f_ludate	 date;	    -- entity update date in file
   db_luby	 number;	-- entity owner in db
   db_ludate date;		-- entity update date in db
begin
   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.owner_id(X_OWNER);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

   select last_updated_by, last_update_date
     into db_luby, db_ludate
	 from AMW_COMPLIANCE_ENVS_TL
	where compliance_env_id = X_COMPLIANCE_ENV_ID
	  and language = userenv('LANG');

   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
      update AMW_COMPLIANCE_ENVS_TL
	     set name	            = X_COMPLIANCE_ENV_NAME,
		     description        = nvl(X_COMPLIANCE_ENV_DESCRIPTION, description),
			 alias              = nvl(X_COMPLIANCE_ENV_ALIAS, alias),
		     source_lang		= userenv('LANG'),
		     last_update_date	= f_ludate,
		     last_updated_by	= f_luby,
		     last_update_login	= 0
	   where compliance_env_id = X_COMPLIANCE_ENV_ID
	     and userenv('LANG') in (language, source_lang);
   end if;

end TRANSLATE_ROW;
/**05.31.2006 npanandi: bug 5259681 fix ends***/


-- ----------------------------------------------------------------------
end AMW_COMPLIANCE_ENVS_PKG;

/
