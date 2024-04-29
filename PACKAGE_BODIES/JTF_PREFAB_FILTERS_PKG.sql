--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_FILTERS_PKG" as
/* $Header: jtfprefiltertb.pls 120.2 2005/10/28 00:25:42 emekala noship $ */
procedure INSERT_ROW (
  X_ROWID in out  NOCOPY VARCHAR2,
  X_FILTER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_FILTER_NAME in VARCHAR2,
  X_FILTER_STRING in VARCHAR2,
  X_EXCLUSION_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_PREFAB_FILTERS_B
    where FILTER_ID = X_FILTER_ID
    ;
begin
  insert into JTF_PREFAB_FILTERS_B (
    FILTER_ID,
    OBJECT_VERSION_NUMBER,
    -- SECURITY_GROUP_ID,
    APPLICATION_ID,
    FILTER_NAME,
    FILTER_STRING,
    EXCLUSION_FLAG,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FILTER_ID,
    X_OBJECT_VERSION_NUMBER,
    -- X_SECURITY_GROUP_ID,
    X_APPLICATION_ID,
    X_FILTER_NAME,
    X_FILTER_STRING,
    X_EXCLUSION_FLAG,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_PREFAB_FILTERS_TL (
    FILTER_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FILTER_ID,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    -- X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_PREFAB_FILTERS_TL T
    where T.FILTER_ID = X_FILTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_FILTER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_FILTER_NAME in VARCHAR2,
  X_FILTER_STRING in VARCHAR2,
  X_EXCLUSION_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      -- SECURITY_GROUP_ID,
      APPLICATION_ID,
      FILTER_NAME,
      FILTER_STRING,
      EXCLUSION_FLAG,
      ENABLED_FLAG
    from JTF_PREFAB_FILTERS_B
    where FILTER_ID = X_FILTER_ID
    for update of FILTER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_PREFAB_FILTERS_TL
    where FILTER_ID = X_FILTER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FILTER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      -- AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
      --      OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.FILTER_NAME = X_FILTER_NAME)
      AND (recinfo.FILTER_STRING = X_FILTER_STRING)
      AND (recinfo.EXCLUSION_FLAG = X_EXCLUSION_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
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

procedure UPDATE_ROW (
  X_FILTER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_FILTER_NAME in VARCHAR2,
  X_FILTER_STRING in VARCHAR2,
  X_EXCLUSION_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_PREFAB_FILTERS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    -- SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    APPLICATION_ID = X_APPLICATION_ID,
    FILTER_NAME = X_FILTER_NAME,
    FILTER_STRING = X_FILTER_STRING,
    EXCLUSION_FLAG = X_EXCLUSION_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FILTER_ID = X_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_PREFAB_FILTERS_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FILTER_ID = X_FILTER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FILTER_ID in NUMBER
) is
begin
  delete from JTF_PREFAB_FILTERS_TL
  where FILTER_ID = X_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_PREFAB_FILTERS_B
  where FILTER_ID = X_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_PREFAB_FILTERS_TL T
  where not exists
    (select NULL
    from JTF_PREFAB_FILTERS_B B
    where B.FILTER_ID = T.FILTER_ID
    );

  update JTF_PREFAB_FILTERS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from JTF_PREFAB_FILTERS_TL B
    where B.FILTER_ID = T.FILTER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FILTER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FILTER_ID,
      SUBT.LANGUAGE
    from JTF_PREFAB_FILTERS_TL SUBB, JTF_PREFAB_FILTERS_TL SUBT
    where SUBB.FILTER_ID = SUBT.FILTER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into JTF_PREFAB_FILTERS_TL (
    FILTER_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FILTER_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    -- B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_PREFAB_FILTERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_PREFAB_FILTERS_TL T
    where T.FILTER_ID = B.FILTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_FILTER_NAME in VARCHAR2,
  X_FILTER_STRING in VARCHAR2,
  X_EXCLUSION_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
	l_row_id        VARCHAR2(255);

    	f_luby		NUMBER;
    	f_ludate    	DATE;
    	db_luby		NUMBER;
    	db_ludate	DATE;
   	l_filter_id    NUMBER;

	cursor c is select nvl(max(FILTER_ID), 0) from jtf_prefab_filters_b where FILTER_ID < 10000;
	l_pseudo_seq	       NUMBER := NULL;
begin

      if (X_OWNER = 'SEED') then
	f_luby := 1;
      else
        f_luby := 0;
      end if;

      f_ludate := X_LAST_UPDATE_DATE;

      begin
	  SELECT FILTER_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
	  INTO l_filter_id, db_luby, db_ludate
	  FROM JTF_PREFAB_FILTERS_B
	  WHERE APPLICATION_ID = X_APPLICATION_ID AND
                FILTER_NAME = X_FILTER_NAME;

	  -- **** Entry is there, check if it's legal to update ****
	  IF ((X_CUSTOM_MODE = 'FORCE') OR
              ((f_luby = 0) AND (db_luby = 1)) OR
              ((f_luby = db_luby) AND (f_ludate > db_ludate))
             )
	  then
	      -- **** call Update row ****
              JTF_PREFAB_FILTERS_PKG.UPDATE_ROW (
                  X_FILTER_ID                 =>   l_filter_id,
                  X_OBJECT_VERSION_NUMBER     =>   X_OBJECT_VERSION_NUMBER,
                  X_SECURITY_GROUP_ID         =>   X_SECURITY_GROUP_ID,
                  X_APPLICATION_ID            =>   X_APPLICATION_ID,
                  X_FILTER_NAME               =>   X_FILTER_NAME,
                  X_FILTER_STRING             =>   X_FILTER_STRING,
                  X_EXCLUSION_FLAG            =>   X_EXCLUSION_FLAG,
                  X_ENABLED_FLAG              =>   X_ENABLED_FLAG,
                  X_DESCRIPTION               =>   X_DESCRIPTION,
                  X_LAST_UPDATE_DATE          =>   f_ludate,
                  X_LAST_UPDATED_BY           =>   f_luby,
                  X_LAST_UPDATE_LOGIN         =>   0);
           end if;
      exception
  	   when no_data_found then
	      -- **** generate pseudo sequence ***
	      OPEN c;
	      FETCH c INTO l_pseudo_seq;
	      CLOSE c;

              JTF_PREFAB_FILTERS_PKG.INSERT_ROW (
                  X_ROWID                      =>   l_row_id,
                  X_FILTER_ID                  =>   (l_pseudo_seq + 1),
                  X_OBJECT_VERSION_NUMBER      =>   X_OBJECT_VERSION_NUMBER,
                  X_SECURITY_GROUP_ID          =>   X_SECURITY_GROUP_ID,
                  X_APPLICATION_ID             =>   X_APPLICATION_ID,
                  X_FILTER_NAME                =>   X_FILTER_NAME,
                  X_FILTER_STRING              =>   X_FILTER_STRING,
                  X_EXCLUSION_FLAG             =>   X_EXCLUSION_FLAG,
                  X_ENABLED_FLAG               =>   X_ENABLED_FLAG,
                  X_DESCRIPTION                =>   X_DESCRIPTION,
                  X_CREATION_DATE              =>   f_ludate,
                  X_CREATED_BY                 =>   f_luby,
                  X_LAST_UPDATE_DATE           =>   f_ludate,
                  X_LAST_UPDATED_BY            =>   f_luby,
                  X_LAST_UPDATE_LOGIN          =>   0);
      end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FILTER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    -- **** local variables *****
    f_luby		NUMBER;
    f_ludate    	DATE;
    db_luby		NUMBER;
    db_ludate		DATE;
    l_filter_id        NUMBER;
begin

  if (X_OWNER = 'SEED') then
     f_luby := 1;
  else
     f_luby := 0;
  end if;

  f_ludate := X_LAST_UPDATE_DATE;

  begin
      SELECT tl.FILTER_ID, tl.LAST_UPDATED_BY, tl.LAST_UPDATE_DATE
      INTO l_filter_id, db_luby, db_ludate
      FROM JTF_PREFAB_FILTERS_B b, JTF_PREFAB_FILTERS_TL tl
      WHERE b.FILTER_ID = tl.FILTER_ID AND
            b.APPLICATION_ID = X_APPLICATION_ID AND
            b.FILTER_NAME = X_FILTER_NAME AND
            tl.LANGUAGE = userenv('LANG');

      if ((X_CUSTOM_MODE = 'FORCE') OR
          ((f_luby = 0) AND (db_luby = 1)) OR
          ((f_luby = db_luby) AND (f_ludate > db_ludate))
         )
      then
          update JTF_PREFAB_FILTERS_TL set
            DESCRIPTION = nvl(X_DESCRIPTION, DESCRIPTION),
	    LAST_UPDATE_DATE = f_ludate,
	    LAST_UPDATED_BY = f_luby,
	    LAST_UPDATE_LOGIN = 0,
	    SOURCE_LANG = userenv('LANG')
          where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
	        FILTER_ID = l_filter_id;
      end if;
   exception
	when no_data_found then null;
   end;
end TRANSLATE_ROW;

end JTF_PREFAB_FILTERS_PKG;

/
