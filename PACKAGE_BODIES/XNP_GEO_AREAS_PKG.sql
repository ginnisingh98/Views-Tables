--------------------------------------------------------
--  DDL for Package Body XNP_GEO_AREAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_GEO_AREAS_PKG" as
/* $Header: XNPGEOAB.pls 120.3 2006/02/13 07:49:44 dputhiye ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_GEO_AREA_ID in NUMBER,
  X_GEO_AREA_TYPE_CODE in VARCHAR2,
  X_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XNP_GEO_AREAS_B
    where GEO_AREA_ID = X_GEO_AREA_ID
    ;
begin
  insert into XNP_GEO_AREAS_B (
    GEO_AREA_ID,
    GEO_AREA_TYPE_CODE,
    CODE,
    ACTIVE_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_GEO_AREA_ID,
    X_GEO_AREA_TYPE_CODE,
    X_CODE,
    X_ACTIVE_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XNP_GEO_AREAS_TL (
    GEO_AREA_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_GEO_AREA_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
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
    from XNP_GEO_AREAS_TL T
    where T.GEO_AREA_ID = X_GEO_AREA_ID
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
  X_GEO_AREA_ID in NUMBER,
  X_GEO_AREA_TYPE_CODE in VARCHAR2,
  X_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      GEO_AREA_TYPE_CODE,
      CODE,
      ACTIVE_FLAG
    from XNP_GEO_AREAS_B
    where GEO_AREA_ID = X_GEO_AREA_ID
    for update of GEO_AREA_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XNP_GEO_AREAS_TL
    where GEO_AREA_ID = X_GEO_AREA_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GEO_AREA_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.GEO_AREA_TYPE_CODE = X_GEO_AREA_TYPE_CODE)
      AND (recinfo.CODE = X_CODE)
      AND (recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_GEO_AREA_ID in NUMBER,
  X_GEO_AREA_TYPE_CODE in VARCHAR2,
  X_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XNP_GEO_AREAS_B set
    GEO_AREA_TYPE_CODE = X_GEO_AREA_TYPE_CODE,
    CODE = X_CODE,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GEO_AREA_ID = X_GEO_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XNP_GEO_AREAS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GEO_AREA_ID = X_GEO_AREA_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GEO_AREA_ID in NUMBER
) is
begin
  delete from XNP_GEO_AREAS_TL
  where GEO_AREA_ID = X_GEO_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XNP_GEO_AREAS_B
  where GEO_AREA_ID = X_GEO_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XNP_GEO_AREAS_TL T
  where not exists
    (select NULL
    from XNP_GEO_AREAS_B B
    where B.GEO_AREA_ID = T.GEO_AREA_ID
    );

  update XNP_GEO_AREAS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XNP_GEO_AREAS_TL B
    where B.GEO_AREA_ID = T.GEO_AREA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GEO_AREA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GEO_AREA_ID,
      SUBT.LANGUAGE
    from XNP_GEO_AREAS_TL SUBB, XNP_GEO_AREAS_TL SUBT
    where SUBB.GEO_AREA_ID = SUBT.GEO_AREA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XNP_GEO_AREAS_TL (
    GEO_AREA_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GEO_AREA_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XNP_GEO_AREAS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XNP_GEO_AREAS_TL T
    where T.GEO_AREA_ID = B.GEO_AREA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
procedure LOAD_ROW (
  X_CODE in VARCHAR2,
  X_GEO_AREA_TYPE_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     varchar2(64);
    l_geo_area_id NUMBER;
  BEGIN
    -- BUG FIX 1647105
    -- Cannot assume the gea_area_id for WORLD will be 0
    -- IF X_CODE <> 'WORLD' THEN
      SELECT geo_area_id INTO l_geo_area_id
      FROM xnp_geo_areas_b
      WHERE geo_area_type_code = X_GEO_AREA_TYPE_CODE
      AND code = X_CODE;
    -- ELSE
    --   l_geo_area_id := 0;
    -- END IF;

    /*The following derivation has been replaced with the FND API. */
    /*dputhiye 19-JUL-2005. R12 ATG Seed Version by Date Uptake    */
    --IF (X_OWNER = 'SEED') THEN
    --  l_user_id := 1;
    --END IF;
    l_user_id := fnd_load_util.owner_id(X_OWNER);


    XNP_GEO_AREAS_PKG.UPDATE_ROW (
      X_GEO_AREA_ID => l_geo_area_id,
      X_GEO_AREA_TYPE_CODE => X_GEO_AREA_TYPE_CODE,
      X_CODE => X_CODE,
      X_ACTIVE_FLAG => X_ACTIVE_FLAG,
      X_DISPLAY_NAME => X_DISPLAY_NAME,
      X_DESCRIPTION => X_DESCRIPTION,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATE_LOGIN => 0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DECLARE
        l_geo_area_id NUMBER;
      BEGIN
        IF X_CODE <> 'WORLD' THEN
          SELECT XNP_GEO_AREAS_B_S.NEXTVAL
          INTO l_geo_area_id
          FROM dual;
        ELSE
          l_geo_area_id := 0;
        END IF;
        XNP_GEO_AREAS_PKG.INSERT_ROW (
        X_ROWID  => l_row_id,
        X_GEO_AREA_ID => l_geo_area_id,
        X_GEO_AREA_TYPE_CODE => X_GEO_AREA_TYPE_CODE,
        X_CODE => X_CODE,
        X_ACTIVE_FLAG => X_ACTIVE_FLAG,
        X_DISPLAY_NAME => X_DISPLAY_NAME,
        X_DESCRIPTION => X_DESCRIPTION,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => l_user_id,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => l_user_id,
        X_LAST_UPDATE_LOGIN => 0);
      END;
  END;
END LOAD_ROW;
procedure TRANSLATE_ROW (
  X_CODE in VARCHAR2,
  X_GEO_AREA_TYPE_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
  l_geo_area_id NUMBER;
BEGIN

  -- BUG FIX 1647105
  -- Cannot assume the gea_area_id for WORLD will be 0
  -- IF X_CODE <> 'WORLD' THEN
    SELECT geo_area_id INTO l_geo_area_id
    FROM xnp_geo_areas_b
    WHERE geo_area_type_code = X_GEO_AREA_TYPE_CODE
    AND code = X_CODE;
  -- ELSE
  --  l_geo_area_id := 0;
  -- END IF;

  -- Only update rows which have not been altered by user
  UPDATE XNP_GEO_AREAS_TL
  SET description = X_DESCRIPTION,
      display_name = X_DISPLAY_NAME,
      source_lang = userenv('LANG'),
      last_update_date = sysdate,
      --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 19-JUL-2005. DECODE replaced with FND API.*/
      last_updated_by = fnd_load_util.owner_id(X_OWNER),
      last_update_login = 0
  WHERE geo_area_id = l_geo_area_id
    AND userenv('LANG') IN (language, source_lang);
END TRANSLATE_ROW;
end XNP_GEO_AREAS_PKG;

/
