--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PS_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PS_FILTERS_PKG" as
/* $Header: amstfltb.pls 115.7 2002/01/24 22:27:11 pkm ship     $ */
procedure INSERT_ROW (
  P_FILTER_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_FILTER_REF_CODE in VARCHAR2,
  P_CONTENT_TYPE in VARCHAR2,
  P_GROUP_NUM in NUMBER,
  P_FILTER_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_IBA_PS_FILTERS_B (
    OBJECT_VERSION_NUMBER,
    FILTER_ID,
    FILTER_REF_CODE,
    CONTENT_TYPE,
    GROUP_NUM,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_OBJECT_VERSION_NUMBER,
    P_FILTER_ID,
    P_FILTER_REF_CODE,
    P_CONTENT_TYPE,
    P_GROUP_NUM,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  insert into AMS_IBA_PS_FILTERS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    FILTER_ID,
    FILTER_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_OBJECT_VERSION_NUMBER,
    P_FILTER_ID,
    P_FILTER_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_IBA_PS_FILTERS_TL T
    where T.FILTER_ID = P_FILTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure LOCK_ROW (
  X_FILTER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FILTER_REF_CODE in VARCHAR2,
  X_CONTENT_TYPE in VARCHAR2,
  X_GROUP_NUM in NUMBER,
  X_FILTER_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      FILTER_REF_CODE,
      CONTENT_TYPE,
      GROUP_NUM
    from AMS_IBA_PS_FILTERS_B
    where FILTER_ID = X_FILTER_ID
    for update of FILTER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FILTER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_IBA_PS_FILTERS_TL
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
  if (
          ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.FILTER_REF_CODE = X_FILTER_REF_CODE)
           OR ((recinfo.FILTER_REF_CODE is null) AND (X_FILTER_REF_CODE is null)))
      AND ((recinfo.CONTENT_TYPE = X_CONTENT_TYPE)
           OR ((recinfo.CONTENT_TYPE is null) AND (X_CONTENT_TYPE is null)))
      AND ((recinfo.GROUP_NUM = X_GROUP_NUM)
           OR ((recinfo.GROUP_NUM is null) AND (X_GROUP_NUM is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FILTER_NAME = X_FILTER_NAME)
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
  P_FILTER_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_FILTER_REF_CODE in VARCHAR2,
  P_CONTENT_TYPE in VARCHAR2,
  P_GROUP_NUM in NUMBER,
  P_FILTER_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_IBA_PS_FILTERS_B set
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    FILTER_REF_CODE = P_FILTER_REF_CODE,
    CONTENT_TYPE = P_CONTENT_TYPE,
    GROUP_NUM = P_GROUP_NUM,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where FILTER_ID = P_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_IBA_PS_FILTERS_TL set
    FILTER_NAME = P_FILTER_NAME,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FILTER_ID = P_FILTER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  P_FILTER_ID in NUMBER
) is
begin
  delete from AMS_IBA_PS_FILTERS_TL
  where FILTER_ID = P_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_IBA_PS_FILTERS_B
  where FILTER_ID = P_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PS_FILTERS_TL T
  where not exists
    (select NULL
    from AMS_IBA_PS_FILTERS_B B
    where B.FILTER_ID = T.FILTER_ID
    );

  update AMS_IBA_PS_FILTERS_TL T set (
      FILTER_NAME
    ) = (select
      B.FILTER_NAME
    from AMS_IBA_PS_FILTERS_TL B
    where B.FILTER_ID = T.FILTER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FILTER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FILTER_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PS_FILTERS_TL SUBB, AMS_IBA_PS_FILTERS_TL SUBT
    where SUBB.FILTER_ID = SUBT.FILTER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FILTER_NAME <> SUBT.FILTER_NAME
  ));

  insert into AMS_IBA_PS_FILTERS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    FILTER_ID,
    FILTER_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    B.FILTER_ID,
    B.FILTER_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PS_FILTERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PS_FILTERS_TL T
    where T.FILTER_ID = B.FILTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE translate_row (
   x_filter_id IN NUMBER,
   x_filter_name IN VARCHAR2,
   x_owner IN VARCHAR2
)
IS
BEGIN
    update ams_iba_ps_filters_tl set
       filter_name = nvl(x_filter_name, filter_name),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  filter_id = x_filter_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;


PROCEDURE load_row (
   x_filter_id           IN NUMBER,
   x_filter_ref_code     IN VARCHAR2,
   x_content_type        IN VARCHAR2,
   x_group_num           IN NUMBER,
   x_filter_name         IN VARCHAR2,
   x_owner               IN VARCHAR2
)
IS
   l_user_id      number := 0;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_filter_id     number;

   cursor  c_obj_verno is
     select object_version_number
     from    ams_iba_ps_filters_b
     where  filter_id =  x_filter_id;

   cursor c_chk_filter_exists is
     select 'x'
     from   ams_iba_ps_filters_b
     where  filter_id = x_filter_id;

   cursor c_get_filter_id is
      select ams_iba_ps_filters_b_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   open c_chk_filter_exists;
   fetch c_chk_filter_exists into l_dummy_char;
   if c_chk_filter_exists%notfound THEN
      if x_filter_id is null then
         open c_get_filter_id;
         fetch c_get_filter_id into l_filter_id;
         close c_get_filter_id;
      else
         l_filter_id := x_filter_id;
      end if;
      l_obj_verno := 1;

      AMS_IBA_PS_FILTERS_PKG.INSERT_ROW (
         p_filter_id => l_filter_id,
         p_object_version_number => l_obj_verno,
         p_filter_ref_code => x_filter_ref_code,
         p_content_type => x_content_type,
         p_group_num => x_group_num,
         p_filter_name => x_filter_name,
         p_creation_date => SYSDATE,
         p_created_by => l_user_id,
         p_last_update_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_login => 0
      );
   else
      open c_obj_verno;
      fetch c_obj_verno into l_obj_verno;
      close c_obj_verno;
      l_filter_id := x_filter_id;
      AMS_IBA_PS_FILTERS_PKG.UPDATE_ROW (
         p_filter_id => l_filter_id,
         p_object_version_number => l_obj_verno+1,
         p_filter_ref_code => x_filter_ref_code,
         p_content_type => x_content_type,
         p_group_num => x_group_num,
         p_filter_name => x_filter_name,
         p_last_update_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_login => 0
      );
   end if;
   close c_chk_filter_exists;
END load_row;


end AMS_IBA_PS_FILTERS_PKG;

/
