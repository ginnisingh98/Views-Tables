--------------------------------------------------------
--  DDL for Package Body AMS_CELLS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CELLS_ALL_PKG" AS
/* $Header: amslcelb.pls 115.2 2000/01/09 17:36:39 pkm ship    $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_CELL_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CELL_CODE in VARCHAR2,
  X_MARKET_SEGMENT_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ORIGINAL_SIZE in NUMBER,
  X_PARENT_CELL_ID in NUMBER,
  X_CELL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_CELLS_ALL_B
    where CELL_ID = X_CELL_ID
    ;
begin
  insert into AMS_CELLS_ALL_B (
    OWNER_ID,
    CELL_ID,
    OBJECT_VERSION_NUMBER,
    CELL_CODE,
    MARKET_SEGMENT_FLAG,
    ENABLED_FLAG,
    ORIGINAL_SIZE,
    PARENT_CELL_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OWNER_ID,
    X_CELL_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CELL_CODE,
    X_MARKET_SEGMENT_FLAG,
    X_ENABLED_FLAG,
    X_ORIGINAL_SIZE,
    X_PARENT_CELL_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_CELLS_ALL_TL (
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    CELL_NAME,
    CELL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_LAST_UPDATE_LOGIN,
    X_CELL_NAME,
    X_CELL_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_CELLS_ALL_TL T
    where T.CELL_ID = X_CELL_ID
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
  X_CELL_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CELL_CODE in VARCHAR2,
  X_MARKET_SEGMENT_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ORIGINAL_SIZE in NUMBER,
  X_PARENT_CELL_ID in NUMBER,
  X_CELL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OWNER_ID,
      OBJECT_VERSION_NUMBER,
      CELL_CODE,
      MARKET_SEGMENT_FLAG,
      ENABLED_FLAG,
      ORIGINAL_SIZE,
      PARENT_CELL_ID
    from AMS_CELLS_ALL_B
    where CELL_ID = X_CELL_ID
    for update of CELL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CELL_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_CELLS_ALL_TL
    where CELL_ID = X_CELL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CELL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OWNER_ID = X_OWNER_ID)
           OR ((recinfo.OWNER_ID is null) AND (X_OWNER_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.CELL_CODE = X_CELL_CODE)
      AND (recinfo.MARKET_SEGMENT_FLAG = X_MARKET_SEGMENT_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.ORIGINAL_SIZE = X_ORIGINAL_SIZE)
           OR ((recinfo.ORIGINAL_SIZE is null) AND (X_ORIGINAL_SIZE is null)))
      AND ((recinfo.PARENT_CELL_ID = X_PARENT_CELL_ID)
           OR ((recinfo.PARENT_CELL_ID is null) AND (X_PARENT_CELL_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CELL_NAME = X_CELL_NAME)
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

procedure UPDATE_ROW (
  X_CELL_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CELL_CODE in VARCHAR2,
  X_MARKET_SEGMENT_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ORIGINAL_SIZE in NUMBER,
  X_PARENT_CELL_ID in NUMBER,
  X_CELL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_CELLS_ALL_B set
    OWNER_ID = X_OWNER_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    CELL_CODE = X_CELL_CODE,
    MARKET_SEGMENT_FLAG = X_MARKET_SEGMENT_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    ORIGINAL_SIZE = X_ORIGINAL_SIZE,
    PARENT_CELL_ID = X_PARENT_CELL_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CELL_ID = X_CELL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_CELLS_ALL_TL set
    CELL_NAME = X_CELL_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CELL_ID = X_CELL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CELL_ID in NUMBER
) is
begin
  delete from AMS_CELLS_ALL_TL
  where CELL_ID = X_CELL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_CELLS_ALL_B
  where CELL_ID = X_CELL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_CELLS_ALL_TL T
  where not exists
    (select NULL
    from AMS_CELLS_ALL_B B
    where B.CELL_ID = T.CELL_ID
    );

  update AMS_CELLS_ALL_TL T set (
      CELL_NAME,
      DESCRIPTION
    ) = (select
      B.CELL_NAME,
      B.DESCRIPTION
    from AMS_CELLS_ALL_TL B
    where B.CELL_ID = T.CELL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CELL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CELL_ID,
      SUBT.LANGUAGE
    from AMS_CELLS_ALL_TL SUBB, AMS_CELLS_ALL_TL SUBT
    where SUBB.CELL_ID = SUBT.CELL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CELL_NAME <> SUBT.CELL_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_CELLS_ALL_TL (
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    CELL_NAME,
    CELL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.CELL_NAME,
    B.CELL_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_CELLS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_CELLS_ALL_TL T
    where T.CELL_ID = B.CELL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW (
   x_cell_id      IN NUMBER,
   x_cell_name    IN VARCHAR2,
   x_description  IN VARCHAR2,
   x_owner        IN VARCHAR2
)
IS
BEGIN
    update ams_cells_all_tl set
       cell_name = NVL (x_cell_name, cell_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  cell_id = x_cell_id
    and      userenv('LANG') in (language, source_lang);
END Translate_Row;

PROCEDURE LOAD_ROW (
  X_CELL_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_CELL_CODE in VARCHAR2,
  X_MARKET_SEGMENT_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ORIGINAL_SIZE in NUMBER,
  X_PARENT_CELL_ID in NUMBER,
  X_CELL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner         IN VARCHAR2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_cell_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number
     FROM   ams_cells_all_b
     WHERE  cell_id = x_cell_id;

   CURSOR c_chk_cel_exists is
     SELECT 'x'
     FROM   ams_cells_all_b
     WHERE  cell_id = x_cell_id;

   CURSOR c_get_cel_id is
      SELECT ams_cells_all_b_s.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   OPEN c_chk_cel_exists;
   FETCH c_chk_cel_exists INTO l_dummy_char;
   IF c_chk_cel_exists%notfound THEN
      CLOSE c_chk_cel_exists;
      OPEN c_get_cel_id;
      FETCH c_get_cel_id INTO l_cell_id;
      CLOSE c_get_cel_id;
      l_obj_verno := 1;

      AMS_Cells_All_PKG.Insert_Row (
         X_ROWID        => l_row_id,
         X_CELL_ID      => l_cell_id,
         X_OWNER_ID     => x_owner_id,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_CELL_CODE    => x_cell_code,
         X_MARKET_SEGMENT_FLAG   => x_market_segment_flag,
         X_ENABLED_FLAG    => x_enabled_flag,
         X_ORIGINAL_SIZE   => x_original_size,
         X_PARENT_CELL_ID  => x_parent_cell_id,
         X_CELL_NAME       => x_cell_name,
         X_DESCRIPTION     => x_description,
         X_CREATION_DATE   => SYSDATE,
         X_CREATED_BY      => l_user_id,
         X_LAST_UPDATE_DATE   => SYSDATE,
         X_LAST_UPDATED_BY    => l_user_id,
         X_LAST_UPDATE_LOGIN  => 0
      );
   ELSE
      CLOSE c_chk_cel_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno;
      CLOSE c_obj_verno;

      AMS_Cells_All_PKG.Update_Row (
         X_CELL_ID   => x_cell_id,
         X_OWNER_ID  => x_owner_id,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_CELL_CODE    => x_cell_code,
         X_MARKET_SEGMENT_FLAG => x_market_segment_flag,
         X_ENABLED_FLAG    => x_enabled_flag,
         X_ORIGINAL_SIZE   => x_original_size,
         X_PARENT_CELL_ID  => x_parent_cell_id,
         X_CELL_NAME       => x_cell_name,
         X_DESCRIPTION     => x_description,
         X_LAST_UPDATE_DATE   => SYSDATE,
         X_LAST_UPDATED_BY    => l_user_id,
         X_LAST_UPDATE_LOGIN  => 0
      );
   END IF;
END Load_Row;

end AMS_CELLS_ALL_PKG;

/
