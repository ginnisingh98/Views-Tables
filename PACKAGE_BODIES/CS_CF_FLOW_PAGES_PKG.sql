--------------------------------------------------------
--  DDL for Package Body CS_CF_FLOW_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CF_FLOW_PAGES_PKG" as
/* $Header: CSCFFPGB.pls 120.0 2005/06/01 13:32:12 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FLOW_ID in NUMBER,
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
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
  X_PAGE_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_CF_FLOW_PAGES_B
    where FLOW_ID = X_FLOW_ID
    and FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
    ;
begin
  insert into CS_CF_FLOW_PAGES_B (
    FLOW_ID,
    FLOW_TYPE_PAGE_ID,
    ENABLED_FLAG,
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
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FLOW_ID,
    X_FLOW_TYPE_PAGE_ID,
    X_ENABLED_FLAG,
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
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CS_CF_FLOW_PAGES_TL (
    FLOW_ID,
    FLOW_TYPE_PAGE_ID,
    PAGE_DISPLAY_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FLOW_ID,
    X_FLOW_TYPE_PAGE_ID,
    X_PAGE_DISPLAY_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_CF_FLOW_PAGES_TL T
    where T.FLOW_ID = X_FLOW_ID
    and T.FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
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
  X_FLOW_ID in NUMBER,
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
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
  X_PAGE_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
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
    from CS_CF_FLOW_PAGES_B
    where FLOW_ID = X_FLOW_ID
    and FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
    for update of FLOW_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PAGE_DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_CF_FLOW_PAGES_TL
    where FLOW_ID = X_FLOW_ID
    and FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FLOW_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
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
      if (    ((tlinfo.PAGE_DISPLAY_NAME = X_PAGE_DISPLAY_NAME)
               OR ((tlinfo.PAGE_DISPLAY_NAME is null) AND (X_PAGE_DISPLAY_NAME is null)))
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
  X_FLOW_ID in NUMBER,
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
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
  X_PAGE_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_CF_FLOW_PAGES_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
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
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FLOW_ID = X_FLOW_ID
  and FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_CF_FLOW_PAGES_TL set
    PAGE_DISPLAY_NAME = X_PAGE_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FLOW_ID = X_FLOW_ID
  and FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FLOW_ID in NUMBER,
  X_FLOW_TYPE_PAGE_ID in NUMBER
) is
begin
  delete from CS_CF_FLOW_PAGES_TL
  where FLOW_ID = X_FLOW_ID
  and FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_CF_FLOW_PAGES_B
  where FLOW_ID = X_FLOW_ID
  and FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_CF_FLOW_PAGES_TL T
  where not exists
    (select NULL
    from CS_CF_FLOW_PAGES_B B
    where B.FLOW_ID = T.FLOW_ID
    and B.FLOW_TYPE_PAGE_ID = T.FLOW_TYPE_PAGE_ID
    );

  update CS_CF_FLOW_PAGES_TL T set (
      PAGE_DISPLAY_NAME
    ) = (select
      B.PAGE_DISPLAY_NAME
    from CS_CF_FLOW_PAGES_TL B
    where B.FLOW_ID = T.FLOW_ID
    and B.FLOW_TYPE_PAGE_ID = T.FLOW_TYPE_PAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FLOW_ID,
      T.FLOW_TYPE_PAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FLOW_ID,
      SUBT.FLOW_TYPE_PAGE_ID,
      SUBT.LANGUAGE
    from CS_CF_FLOW_PAGES_TL SUBB, CS_CF_FLOW_PAGES_TL SUBT
    where SUBB.FLOW_ID = SUBT.FLOW_ID
    and SUBB.FLOW_TYPE_PAGE_ID = SUBT.FLOW_TYPE_PAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PAGE_DISPLAY_NAME <> SUBT.PAGE_DISPLAY_NAME
      or (SUBB.PAGE_DISPLAY_NAME is null and SUBT.PAGE_DISPLAY_NAME is not null)
      or (SUBB.PAGE_DISPLAY_NAME is not null and SUBT.PAGE_DISPLAY_NAME is null)
  ));

  insert into CS_CF_FLOW_PAGES_TL (
    FLOW_ID,
    FLOW_TYPE_PAGE_ID,
    PAGE_DISPLAY_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FLOW_ID,
    B.FLOW_TYPE_PAGE_ID,
    B.PAGE_DISPLAY_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_CF_FLOW_PAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_CF_FLOW_PAGES_TL T
    where T.FLOW_ID = B.FLOW_ID
    and T.FLOW_TYPE_PAGE_ID = B.FLOW_TYPE_PAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_FLOW_ID in NUMBER,
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) IS

  f_luby number ; -- entity owner in file
  f_ludate date ; -- entity update date in file
  db_luby  number; -- entity owner in db
  db_ludate date; -- entity update date in db

  l_object_version_number number := 1;
  l_rowid varchar2(50);

  l_attribute_category varchar2(30);
  l_attribute1 varchar2(150);
  l_attribute2 varchar2(150);
  l_attribute3 varchar2(150);
  l_attribute4 varchar2(150);
  l_attribute5 varchar2(150);
  l_attribute6 varchar2(150);
  l_attribute7 varchar2(150);
  l_attribute8 varchar2(150);
  l_attribute9 varchar2(150);
  l_attribute10 varchar2(150);
  l_attribute11 varchar2(150);
  l_attribute12 varchar2(150);
  l_attribute13 varchar2(150);
  l_attribute14 varchar2(150);
  l_attribute15 varchar2(150);


begin

  f_luby := fnd_load_util.owner_id(X_OWNER);
  f_ludate := nvl(X_LAST_UPDATE_DATE, sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from CS_CF_FLOW_PAGES_B
  where  flow_id = X_FLOW_ID
  and    flow_type_page_id = X_FLOW_TYPE_PAGE_ID;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
    -- Update existing row
    SELECT object_version_number, rowid,
		 attribute_category,
		 attribute1,
		 attribute2,
		 attribute3,
		 attribute4,
		 attribute5,
		 attribute6,
		 attribute7,
		 attribute8,
		 attribute9,
		 attribute10,
		 attribute11,
		 attribute12,
		 attribute13,
		 attribute14,
		 attribute15
    INTO l_object_version_number, l_rowid,
	    l_attribute_category,
	    l_attribute1,
	    l_attribute2,
	    l_attribute3,
	    l_attribute4,
	    l_attribute5,
	    l_attribute6,
	    l_attribute7,
	    l_attribute8,
	    l_attribute9,
	    l_attribute10,
	    l_attribute11,
	    l_attribute12,
	    l_attribute13,
	    l_attribute14,
	    l_attribute15
    FROM CS_CF_FLOW_PAGES_B
    WHERE flow_id = X_FLOW_ID
    and flow_type_page_id = X_FLOW_TYPE_PAGE_ID
    FOR UPDATE ;

    CS_CF_FLOW_PAGES_PKG.Update_Row(
	 X_FLOW_ID => X_FLOW_ID,
	 X_FLOW_TYPE_PAGE_ID => X_FLOW_TYPE_PAGE_ID,
	 X_ENABLED_FLAG => X_ENABLED_FLAG,
	 X_OBJECT_VERSION_NUMBER => l_object_version_number + 1,
	 X_PAGE_DISPLAY_NAME => X_PAGE_DISPLAY_NAME,
	 X_ATTRIBUTE_CATEGORY => l_attribute_category,
	 X_ATTRIBUTE1 => l_attribute1,
	 X_ATTRIBUTE2 => l_attribute2,
	 X_ATTRIBUTE3 => l_attribute3,
	 X_ATTRIBUTE4 => l_attribute4,
	 X_ATTRIBUTE5 => l_attribute5,
	 X_ATTRIBUTE6 => l_attribute6,
	 X_ATTRIBUTE7 => l_attribute7,
	 X_ATTRIBUTE8 => l_attribute8,
	 X_ATTRIBUTE9 => l_attribute9,
	 X_ATTRIBUTE10 => l_attribute10,
	 X_ATTRIBUTE11 => l_attribute11,
	 X_ATTRIBUTE12 => l_attribute12,
	 X_ATTRIBUTE13 => l_attribute13,
	 X_ATTRIBUTE14 => l_attribute14,
	 X_ATTRIBUTE15 => l_attribute15,
	 X_LAST_UPDATE_DATE => f_ludate,
	 X_LAST_UPDATED_BY => f_luby,
	 X_LAST_UPDATE_LOGIN => 0);
  end if;
  exception
    when no_data_found then
	 -- Record doesn't exist - insert in all cases
	 CS_CF_FLOW_PAGES_PKG.Insert_Row(
	   X_ROWID => l_rowid,
	   X_FLOW_ID => X_FLOW_ID,
	   X_FLOW_TYPE_PAGE_ID => X_FLOW_TYPE_PAGE_ID,
	   X_ENABLED_FLAG => X_ENABLED_FLAG,
	   X_PAGE_DISPLAY_NAME => X_PAGE_DISPLAY_NAME,
	   X_OBJECT_VERSION_NUMBER => l_object_version_number,
	   X_ATTRIBUTE_CATEGORY => NULL,
	   X_ATTRIBUTE1 => NULL,
	   X_ATTRIBUTE2 => NULL,
	   X_ATTRIBUTE3 => NULL,
	   X_ATTRIBUTE4 => NULL,
	   X_ATTRIBUTE5 => NULL,
	   X_ATTRIBUTE6 => NULL,
	   X_ATTRIBUTE7 => NULL,
	   X_ATTRIBUTE8 => NULL,
	   X_ATTRIBUTE9 => NULL,
	   X_ATTRIBUTE10 => NULL,
	   X_ATTRIBUTE11 => NULL,
	   X_ATTRIBUTE12 => NULL,
	   X_ATTRIBUTE13 => NULL,
	   X_ATTRIBUTE14 => NULL,
	   X_ATTRIBUTE15 => NULL,
	   X_CREATION_DATE => sysdate,
	   X_CREATED_BY => f_luby,
	   X_LAST_UPDATE_DATE => f_ludate,
	   X_LAST_UPDATED_BY => f_luby,
	   X_LAST_UPDATE_LOGIN => 0);
end LOAD_ROW;

procedure TRANSLATE_ROW(
  X_FLOW_ID in NUMBER,
  X_FLOW_TYPE_PAGE_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_DISPLAY_NAME in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2

) IS

  f_luby		NUMBER;
  f_ludate	DATE;
  db_luby		NUMBER;
  db_ludate	DATE;

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(X_LAST_UPDATE_DATE, sysdate);

  SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from CS_CF_FLOW_PAGES_TL
  where flow_id = X_FLOW_ID
  and flow_type_page_id = X_FLOW_TYPE_PAGE_ID
  and language = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
    update CS_CF_FLOW_PAGES_TL set
	 PAGE_DISPLAY_NAME = nvl(X_PAGE_DISPLAY_NAME, PAGE_DISPLAY_NAME),
	 LAST_UPDATE_DATE = f_ludate,
	 LAST_UPDATED_BY = f_luby,
	 LAST_UPDATE_LOGIN = 0,
	 SOURCE_LANG = userenv('LANG')
    where FLOW_ID = X_FLOW_ID
    and   FLOW_TYPE_PAGE_ID = X_FLOW_TYPE_PAGE_ID
    and   userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  end if;

end TRANSLATE_ROW;


end CS_CF_FLOW_PAGES_PKG;

/
