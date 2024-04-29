--------------------------------------------------------
--  DDL for Package Body AMV_C_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_C_CATEGORIES_PKG" as
/* $Header: amvtcatb.pls 120.2 2006/02/03 16:12:29 mkettle ship $ */
procedure LOAD_ROW (
  X_CHANNEL_CATEGORY_ID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_APPLICATION_ID in VARCHAR2,
  X_CHANNEL_CATEGORY_ORDER in VARCHAR2,
  X_PARENT_CHANNEL_CATEGORY_ID in VARCHAR2,
  X_CHANNEL_COUNT in VARCHAR2,
  X_CHANNEL_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
is
l_user_id          	number := 0;
l_application_id   	number := 0;
l_channel_category_id   number := 0;
l_channel_category_order   number := 0;
l_parent_channel_category_id   number := 0;
l_channel_count   number := 0;
l_object_version_number number := 0;
l_row_id           	varchar2(64);

 CURSOR Check_Lub (v_ch_cat_id NUMBER) IS
  select last_updated_by
  from AMV_C_CATEGORIES_B
  where channel_category_id = v_ch_cat_id;

 l_lub NUMBER;
 l_upd VARCHAR2(5);


begin
	if (X_OWNER = 'SEED') then
		l_user_id := 1;
	end if;
	l_channel_category_id := to_number(x_channel_category_id);
	l_application_id := to_number(x_application_id);
	l_object_version_number := to_number(x_object_version_number);
	l_channel_category_order := to_number(x_channel_category_order);
	l_parent_channel_category_id := to_number(x_parent_channel_category_id);
	l_channel_count := to_number(x_channel_count);

    l_lub := null;
    l_upd := 'TRUE';
    OPEN  Check_Lub(x_channel_category_id);
    FETCH Check_Lub INTO l_lub;
    CLOSE Check_Lub;
    IF l_lub IS NOT NULL AND l_lub > 1000 THEN
      -- Row already exists in Customer Env
      -- and has been Customized
      l_upd := 'FALSE';
    END IF;

    IF l_upd = 'TRUE' THEN

      AMV_C_CATEGORIES_PKG.UPDATE_ROW (
	   	X_CHANNEL_CATEGORY_ID   => l_channel_category_id,
  		X_APPLICATION_ID => l_application_id,
	   	X_OBJECT_VERSION_NUMBER => l_object_version_number,
  		X_CHANNEL_CATEGORY_ORDER => l_channel_category_order,
  		X_PARENT_CHANNEL_CATEGORY_ID => l_parent_channel_category_id,
  		X_CHANNEL_COUNT => l_channel_count,
	  	X_CHANNEL_CATEGORY_NAME => x_channel_category_name,
		X_DESCRIPTION       => x_description,
		X_LAST_UPDATE_DATE  => sysdate,
		X_LAST_UPDATED_BY   => l_user_id,
		X_LAST_UPDATE_LOGIN => 0
		);
    END IF;

exception
	when NO_DATA_FOUND then
		AMV_C_CATEGORIES_PKG.INSERT_ROW (
			X_ROWID             => l_row_id,
			X_CHANNEL_CATEGORY_ID   => l_channel_category_id,
  			X_APPLICATION_ID => l_application_id,
			X_OBJECT_VERSION_NUMBER => l_object_version_number,
  			X_CHANNEL_CATEGORY_ORDER => l_channel_category_order,
  			X_PARENT_CHANNEL_CATEGORY_ID => l_parent_channel_category_id,
  			X_CHANNEL_COUNT => l_channel_count,
			X_CHANNEL_CATEGORY_NAME => x_channel_category_name,
			X_DESCRIPTION       => x_description,
			X_CREATION_DATE     => sysdate,
			X_CREATED_BY        => l_user_id,
			X_LAST_UPDATE_DATE  => sysdate,
			X_LAST_UPDATED_BY   => l_user_id,
			X_LAST_UPDATE_LOGIN => 0
			);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_CHANNEL_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
is
begin
	update AMV_C_CATEGORIES_TL set
		CHANNEL_CATEGORY_NAME = x_channel_category_name,
		DESCRIPTION       = x_description,
		LAST_UPDATE_DATE  = sysdate,
		LAST_UPDATED_BY   = decode(x_owner, 'SEED', 1, 0),
		LAST_UPDATE_LOGIN = 0,
	SOURCE_LANG = userenv('LANG')
	where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	and CHANNEL_CATEGORY_ID = x_channel_category_id
	and last_updated_by < 1000;
end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_CATEGORY_ORDER in NUMBER,
  X_PARENT_CHANNEL_CATEGORY_ID in NUMBER,
  X_CHANNEL_COUNT in NUMBER,
  X_CHANNEL_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMV_C_CATEGORIES_B
    where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID
    ;
begin
  insert into AMV_C_CATEGORIES_B (
    APPLICATION_ID,
    CHANNEL_CATEGORY_ID,
    OBJECT_VERSION_NUMBER,
    CHANNEL_CATEGORY_ORDER,
    PARENT_CHANNEL_CATEGORY_ID,
    CHANNEL_COUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_CHANNEL_CATEGORY_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CHANNEL_CATEGORY_ORDER,
    X_PARENT_CHANNEL_CATEGORY_ID,
    X_CHANNEL_COUNT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMV_C_CATEGORIES_TL (
    CHANNEL_CATEGORY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CHANNEL_CATEGORY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHANNEL_CATEGORY_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CHANNEL_CATEGORY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMV_C_CATEGORIES_TL T
    where T.CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID
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
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_CATEGORY_ORDER in NUMBER,
  X_PARENT_CHANNEL_CATEGORY_ID in NUMBER,
  X_CHANNEL_COUNT in NUMBER,
  X_CHANNEL_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      APPLICATION_ID,
      OBJECT_VERSION_NUMBER,
      CHANNEL_CATEGORY_ORDER,
      PARENT_CHANNEL_CATEGORY_ID,
      CHANNEL_COUNT
    from AMV_C_CATEGORIES_B
    where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID
    for update of CHANNEL_CATEGORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHANNEL_CATEGORY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMV_C_CATEGORIES_TL
    where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHANNEL_CATEGORY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.CHANNEL_CATEGORY_ORDER = X_CHANNEL_CATEGORY_ORDER)
      AND ((recinfo.PARENT_CHANNEL_CATEGORY_ID = X_PARENT_CHANNEL_CATEGORY_ID)
           OR ((recinfo.PARENT_CHANNEL_CATEGORY_ID is null) AND (X_PARENT_CHANNEL_CATEGORY_ID is null)))
      AND ((recinfo.CHANNEL_COUNT = X_CHANNEL_COUNT)
           OR ((recinfo.CHANNEL_COUNT is null) AND (X_CHANNEL_COUNT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CHANNEL_CATEGORY_NAME = X_CHANNEL_CATEGORY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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

procedure UPDATE_B_ROW (
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_CATEGORY_ORDER in NUMBER,
  X_PARENT_CHANNEL_CATEGORY_ID in NUMBER,
  X_CHANNEL_COUNT in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMV_C_CATEGORIES_B set
    APPLICATION_ID = X_APPLICATION_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    CHANNEL_CATEGORY_ORDER = X_CHANNEL_CATEGORY_ORDER,
    PARENT_CHANNEL_CATEGORY_ID = X_PARENT_CHANNEL_CATEGORY_ID,
    CHANNEL_COUNT = X_CHANNEL_COUNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_B_ROW;

procedure UPDATE_TL_ROW (
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_CHANNEL_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin

  update AMV_C_CATEGORIES_TL set
    CHANNEL_CATEGORY_NAME = X_CHANNEL_CATEGORY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_TL_ROW;

procedure UPDATE_ROW (
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_CATEGORY_ORDER in NUMBER,
  X_PARENT_CHANNEL_CATEGORY_ID in NUMBER,
  X_CHANNEL_COUNT in NUMBER,
  X_CHANNEL_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMV_C_CATEGORIES_B set
    APPLICATION_ID = X_APPLICATION_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    CHANNEL_CATEGORY_ORDER = X_CHANNEL_CATEGORY_ORDER,
    PARENT_CHANNEL_CATEGORY_ID = X_PARENT_CHANNEL_CATEGORY_ID,
    CHANNEL_COUNT = X_CHANNEL_COUNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMV_C_CATEGORIES_TL set
    CHANNEL_CATEGORY_NAME = X_CHANNEL_CATEGORY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHANNEL_CATEGORY_ID in NUMBER
) is
begin
  delete from AMV_C_CATEGORIES_TL
  where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMV_C_CATEGORIES_B
  where CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMV_C_CATEGORIES_TL T
  where not exists
    (select NULL
    from AMV_C_CATEGORIES_B B
    where B.CHANNEL_CATEGORY_ID = T.CHANNEL_CATEGORY_ID
    );

  update AMV_C_CATEGORIES_TL T set (
      CHANNEL_CATEGORY_NAME,
      DESCRIPTION
    ) = (select
      B.CHANNEL_CATEGORY_NAME,
      B.DESCRIPTION
    from AMV_C_CATEGORIES_TL B
    where B.CHANNEL_CATEGORY_ID = T.CHANNEL_CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANNEL_CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHANNEL_CATEGORY_ID,
      SUBT.LANGUAGE
    from AMV_C_CATEGORIES_TL SUBB, AMV_C_CATEGORIES_TL SUBT
    where SUBB.CHANNEL_CATEGORY_ID = SUBT.CHANNEL_CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHANNEL_CATEGORY_NAME <> SUBT.CHANNEL_CATEGORY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMV_C_CATEGORIES_TL (
    CHANNEL_CATEGORY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CHANNEL_CATEGORY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CHANNEL_CATEGORY_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CHANNEL_CATEGORY_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMV_C_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMV_C_CATEGORIES_TL T
    where T.CHANNEL_CATEGORY_ID = B.CHANNEL_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMV_C_CATEGORIES_PKG;

/
