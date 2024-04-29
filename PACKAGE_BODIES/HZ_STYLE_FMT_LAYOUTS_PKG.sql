--------------------------------------------------------
--  DDL for Package Body HZ_STYLE_FMT_LAYOUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_STYLE_FMT_LAYOUTS_PKG" as
/* $Header: ARHPSFYB.pls 115.9 2004/02/25 23:16:07 geliu noship $ */

L_USER_ID_FOR_SEED NUMBER := NULL;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STYLE_FMT_LAYOUT_ID in out NOCOPY NUMBER,
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_LINE_NUMBER in NUMBER,
  X_POSITION in NUMBER,
  X_MANDATORY_FLAG in VARCHAR2,
  X_USE_INITIAL_FLAG in VARCHAR2,
  X_UPPERCASE_FLAG in VARCHAR2,
  X_TRANSFORM_FUNCTION in VARCHAR2,
  X_DELIMITER_BEFORE in VARCHAR2,
  X_DELIMITER_AFTER in VARCHAR2,
  X_BLANK_LINES_BEFORE in NUMBER,
  X_BLANK_LINES_AFTER in NUMBER,
  X_PROMPT in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OBJECT_VERSION_NUMBER  IN NUMBER
) is
  cursor C is select ROWID from HZ_STYLE_FMT_LAYOUTS_B
    where STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID
    ;
begin
  insert into HZ_STYLE_FMT_LAYOUTS_B (
    STYLE_FMT_LAYOUT_ID,
    STYLE_FORMAT_CODE,
    VARIATION_NUMBER,
    ATTRIBUTE_CODE,
    ATTRIBUTE_APPLICATION_ID,
    LINE_NUMBER,
    POSITION,
    MANDATORY_FLAG,
    USE_INITIAL_FLAG,
    UPPERCASE_FLAG,
    TRANSFORM_FUNCTION,
    DELIMITER_BEFORE,
    DELIMITER_AFTER,
    BLANK_LINES_BEFORE,
    BLANK_LINES_AFTER,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER
  ) values (
    DECODE( X_STYLE_FMT_LAYOUT_ID, FND_API.G_MISS_NUM, HZ_STYLE_FMT_LAYOUTS_S.NEXTVAL, NULL, HZ_STYLE_FMT_LAYOUTS_S.NEXTVAL, X_STYLE_FMT_LAYOUT_ID ),
    DECODE( X_STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR, NULL, X_STYLE_FORMAT_CODE ),
    DECODE( X_VARIATION_NUMBER, FND_API.G_MISS_NUM, NULL, X_VARIATION_NUMBER ),
    DECODE( X_ATTRIBUTE_CODE, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE_CODE ),
    DECODE( X_ATTRIBUTE_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_ATTRIBUTE_APPLICATION_ID ),
    DECODE( X_LINE_NUMBER, FND_API.G_MISS_NUM, NULL, X_LINE_NUMBER ),
    DECODE( X_POSITION, FND_API.G_MISS_NUM, NULL, X_POSITION ),
    DECODE( X_MANDATORY_FLAG, FND_API.G_MISS_CHAR, NULL, X_MANDATORY_FLAG ),
    DECODE( X_USE_INITIAL_FLAG, FND_API.G_MISS_CHAR, NULL, X_USE_INITIAL_FLAG ),
    DECODE( X_UPPERCASE_FLAG, FND_API.G_MISS_CHAR, NULL, X_UPPERCASE_FLAG ),
    DECODE( X_TRANSFORM_FUNCTION, FND_API.G_MISS_CHAR, NULL, X_TRANSFORM_FUNCTION ),
    DECODE( X_DELIMITER_BEFORE, FND_API.G_MISS_CHAR, NULL, X_DELIMITER_BEFORE ),
    DECODE( X_DELIMITER_AFTER, FND_API.G_MISS_CHAR, NULL, X_DELIMITER_AFTER ),
    DECODE( X_BLANK_LINES_BEFORE, FND_API.G_MISS_NUM, NULL, X_BLANK_LINES_BEFORE ),
    DECODE( X_BLANK_LINES_AFTER, FND_API.G_MISS_NUM, NULL, X_BLANK_LINES_AFTER ),
    DECODE( X_START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_START_DATE_ACTIVE ),
    DECODE( X_END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_END_DATE_ACTIVE ),
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.CREATED_BY),
    HZ_UTILITY_V2PUB.CREATION_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER )
  ) RETURNING
    STYLE_FMT_LAYOUT_ID
  INTO
    X_STYLE_FMT_LAYOUT_ID;

  insert into HZ_STYLE_FMT_LAYOUTS_TL (
    STYLE_FMT_LAYOUT_ID,
    PROMPT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_STYLE_FMT_LAYOUT_ID,
    DECODE( X_PROMPT, FND_API.G_MISS_CHAR, NULL, X_PROMPT ),
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.CREATED_BY),
    HZ_UTILITY_V2PUB.CREATION_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HZ_STYLE_FMT_LAYOUTS_TL T
    where T.STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID
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
  X_STYLE_FMT_LAYOUT_ID in NUMBER,
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_LINE_NUMBER in NUMBER,
  X_POSITION in NUMBER,
  X_MANDATORY_FLAG in VARCHAR2,
  X_USE_INITIAL_FLAG in VARCHAR2,
  X_UPPERCASE_FLAG in VARCHAR2,
  X_TRANSFORM_FUNCTION in VARCHAR2,
  X_DELIMITER_BEFORE in VARCHAR2,
  X_DELIMITER_AFTER in VARCHAR2,
  X_BLANK_LINES_BEFORE in NUMBER,
  X_BLANK_LINES_AFTER in NUMBER,
  X_PROMPT in VARCHAR2
) is
  cursor c is select
      STYLE_FORMAT_CODE,
      VARIATION_NUMBER,
      ATTRIBUTE_CODE,
      ATTRIBUTE_APPLICATION_ID,
      LINE_NUMBER,
      POSITION,
      MANDATORY_FLAG,
      USE_INITIAL_FLAG,
      UPPERCASE_FLAG,
      TRANSFORM_FUNCTION,
      DELIMITER_BEFORE,
      DELIMITER_AFTER,
      BLANK_LINES_BEFORE,
      BLANK_LINES_AFTER
    from HZ_STYLE_FMT_LAYOUTS_B
    where STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID
    for update of STYLE_FMT_LAYOUT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PROMPT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_STYLE_FMT_LAYOUTS_TL
    where STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STYLE_FMT_LAYOUT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE)
      AND (recinfo.VARIATION_NUMBER = X_VARIATION_NUMBER)
      AND (recinfo.ATTRIBUTE_CODE = X_ATTRIBUTE_CODE)
      AND (recinfo.ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID)
      AND (recinfo.LINE_NUMBER = X_LINE_NUMBER)
      AND (recinfo.POSITION = X_POSITION)
      AND (recinfo.MANDATORY_FLAG = X_MANDATORY_FLAG)
      AND (recinfo.USE_INITIAL_FLAG = X_USE_INITIAL_FLAG)
      AND (recinfo.UPPERCASE_FLAG = X_UPPERCASE_FLAG)
      AND ((recinfo.TRANSFORM_FUNCTION = X_TRANSFORM_FUNCTION)
           OR ((recinfo.TRANSFORM_FUNCTION is null) AND (X_TRANSFORM_FUNCTION is null)))
      AND ((recinfo.DELIMITER_BEFORE = X_DELIMITER_BEFORE)
           OR ((recinfo.DELIMITER_BEFORE is null) AND (X_DELIMITER_BEFORE is null)))
      AND ((recinfo.DELIMITER_AFTER = X_DELIMITER_AFTER)
           OR ((recinfo.DELIMITER_AFTER is null) AND (X_DELIMITER_AFTER is null)))
      AND ((recinfo.BLANK_LINES_BEFORE = X_BLANK_LINES_BEFORE)
           OR ((recinfo.BLANK_LINES_BEFORE is null) AND (X_BLANK_LINES_BEFORE is null)))
      AND ((recinfo.BLANK_LINES_AFTER = X_BLANK_LINES_AFTER)
           OR ((recinfo.BLANK_LINES_AFTER is null) AND (X_BLANK_LINES_AFTER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.PROMPT = X_PROMPT)
               OR ((tlinfo.PROMPT is null) AND (X_PROMPT is null)))
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
  X_STYLE_FMT_LAYOUT_ID in NUMBER,
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_LINE_NUMBER in NUMBER,
  X_POSITION in NUMBER,
  X_MANDATORY_FLAG in VARCHAR2,
  X_USE_INITIAL_FLAG in VARCHAR2,
  X_UPPERCASE_FLAG in VARCHAR2,
  X_TRANSFORM_FUNCTION in VARCHAR2,
  X_DELIMITER_BEFORE in VARCHAR2,
  X_DELIMITER_AFTER in VARCHAR2,
  X_BLANK_LINES_BEFORE in NUMBER,
  X_BLANK_LINES_AFTER in NUMBER,
  X_PROMPT in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OBJECT_VERSION_NUMBER IN NUMBER
) is
begin
  update HZ_STYLE_FMT_LAYOUTS_B set
    STYLE_FORMAT_CODE = DECODE( X_STYLE_FORMAT_CODE, NULL, STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR, NULL, X_STYLE_FORMAT_CODE ),
    VARIATION_NUMBER = DECODE( X_VARIATION_NUMBER, NULL, VARIATION_NUMBER, FND_API.G_MISS_NUM, NULL, X_VARIATION_NUMBER ),
    ATTRIBUTE_CODE = DECODE( X_ATTRIBUTE_CODE, NULL, ATTRIBUTE_CODE, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE_CODE ),
    ATTRIBUTE_APPLICATION_ID = DECODE( X_ATTRIBUTE_APPLICATION_ID, NULL, ATTRIBUTE_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_ATTRIBUTE_APPLICATION_ID ),
    LINE_NUMBER = DECODE( X_LINE_NUMBER, NULL, LINE_NUMBER, FND_API.G_MISS_NUM, NULL, X_LINE_NUMBER ),
    POSITION = DECODE( X_POSITION, NULL, POSITION, FND_API.G_MISS_NUM, NULL, X_POSITION ),
    MANDATORY_FLAG = DECODE( X_MANDATORY_FLAG, NULL, MANDATORY_FLAG, FND_API.G_MISS_CHAR, NULL, X_MANDATORY_FLAG ),
    USE_INITIAL_FLAG = DECODE( X_USE_INITIAL_FLAG, NULL, USE_INITIAL_FLAG, FND_API.G_MISS_CHAR, NULL, X_USE_INITIAL_FLAG ),
    UPPERCASE_FLAG = DECODE( X_UPPERCASE_FLAG, NULL, UPPERCASE_FLAG, FND_API.G_MISS_CHAR, NULL, X_UPPERCASE_FLAG ),
    TRANSFORM_FUNCTION = DECODE( X_TRANSFORM_FUNCTION, NULL, TRANSFORM_FUNCTION, FND_API.G_MISS_CHAR, NULL, X_TRANSFORM_FUNCTION ),
    DELIMITER_BEFORE = DECODE( X_DELIMITER_BEFORE, NULL, DELIMITER_BEFORE, FND_API.G_MISS_CHAR, NULL, X_DELIMITER_BEFORE ),
    DELIMITER_AFTER = DECODE( X_DELIMITER_AFTER, NULL, DELIMITER_AFTER, FND_API.G_MISS_CHAR, NULL, X_DELIMITER_AFTER ),
    BLANK_LINES_BEFORE = DECODE( X_BLANK_LINES_BEFORE, NULL, BLANK_LINES_BEFORE, FND_API.G_MISS_NUM, NULL, X_BLANK_LINES_BEFORE ),
    BLANK_LINES_AFTER = DECODE( X_BLANK_LINES_AFTER, NULL, BLANK_LINES_AFTER, FND_API.G_MISS_NUM, NULL, X_BLANK_LINES_AFTER ),
    START_DATE_ACTIVE = DECODE( X_START_DATE_ACTIVE, NULL, START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_START_DATE_ACTIVE ),
    END_DATE_ACTIVE = DECODE( X_END_DATE_ACTIVE, NULL, END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_END_DATE_ACTIVE ),
    LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    LAST_UPDATED_BY = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    OBJECT_VERSION_NUMBER = DECODE(X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER,
                                  FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER)
  where STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HZ_STYLE_FMT_LAYOUTS_TL set
    PROMPT = DECODE( X_PROMPT, NULL, PROMPT, FND_API.G_MISS_CHAR, NULL, X_PROMPT ),
    LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    LAST_UPDATED_BY = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    SOURCE_LANG = userenv('LANG')
  where STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

PROCEDURE SELECT_ROW (
  X_STYLE_FMT_LAYOUT_ID        IN OUT  NOCOPY NUMBER,
  X_STYLE_FORMAT_CODE          OUT     NOCOPY VARCHAR2,
  X_VARIATION_NUMBER           OUT     NOCOPY NUMBER,
  X_ATTRIBUTE_CODE	       OUT     NOCOPY VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID   OUT     NOCOPY NUMBER,
  X_LINE_NUMBER                OUT     NOCOPY NUMBER,
  X_POSITION                   OUT     NOCOPY NUMBER,
  X_MANDATORY_FLAG	       OUT     NOCOPY VARCHAR2,
  X_USE_INITIAL_FLAG	       OUT     NOCOPY VARCHAR2,
  X_UPPERCASE_FLAG	       OUT     NOCOPY VARCHAR2,
  X_TRANSFORM_FUNCTION	       OUT     NOCOPY VARCHAR2,
  X_DELIMITER_BEFORE	       OUT     NOCOPY VARCHAR2,
  X_DELIMITER_AFTER	       OUT     NOCOPY VARCHAR2,
  X_BLANK_LINES_BEFORE	       OUT     NOCOPY NUMBER,
  X_BLANK_LINES_AFTER	       OUT     NOCOPY NUMBER,
  X_PROMPT                     OUT     NOCOPY VARCHAR2,
  X_START_DATE_ACTIVE	       OUT     NOCOPY DATE,
  X_END_DATE_ACTIVE	       OUT     NOCOPY DATE
) IS
BEGIN

    SELECT
        NVL( B.STYLE_FMT_LAYOUT_ID, FND_API.G_MISS_NUM ),
        NVL( B.STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR ),
        NVL( B.VARIATION_NUMBER, FND_API.G_MISS_NUM ),
        NVL( B.ATTRIBUTE_CODE, FND_API.G_MISS_CHAR ),
	NVL( B.ATTRIBUTE_APPLICATION_ID, FND_API.G_MISS_NUM ),
        NVL( B.LINE_NUMBER, FND_API.G_MISS_NUM ),
        NVL( B.POSITION, FND_API.G_MISS_NUM ),
        NVL( B.MANDATORY_FLAG, FND_API.G_MISS_CHAR ),
        NVL( B.USE_INITIAL_FLAG, FND_API.G_MISS_CHAR ),
        NVL( B.UPPERCASE_FLAG, FND_API.G_MISS_CHAR ),
        NVL( B.TRANSFORM_FUNCTION, FND_API.G_MISS_CHAR ),
        NVL( B.DELIMITER_BEFORE, FND_API.G_MISS_CHAR ),
        NVL( B.DELIMITER_AFTER, FND_API.G_MISS_CHAR ),
        NVL( B.BLANK_LINES_BEFORE, FND_API.G_MISS_NUM ),
        NVL( B.BLANK_LINES_AFTER, FND_API.G_MISS_NUM ),
        NVL( T.PROMPT, FND_API.G_MISS_CHAR ),
	NVL( B.START_DATE_ACTIVE, FND_API.G_MISS_DATE ),
        NVL( B.END_DATE_ACTIVE, FND_API.G_MISS_DATE )
    INTO
        X_STYLE_FMT_LAYOUT_ID   ,
        X_STYLE_FORMAT_CODE     ,
        X_VARIATION_NUMBER      ,
        X_ATTRIBUTE_CODE	,
        X_ATTRIBUTE_APPLICATION_ID ,
        X_LINE_NUMBER           ,
        X_POSITION              ,
        X_MANDATORY_FLAG	,
        X_USE_INITIAL_FLAG	,
        X_UPPERCASE_FLAG	,
        X_TRANSFORM_FUNCTION	,
        X_DELIMITER_BEFORE	,
        X_DELIMITER_AFTER	,
        X_BLANK_LINES_BEFORE	,
        X_BLANK_LINES_AFTER	,
	X_PROMPT,
	X_START_DATE_ACTIVE	,
        X_END_DATE_ACTIVE
    FROM HZ_STYLE_FMT_LAYOUTS_B B, HZ_STYLE_FMT_LAYOUTS_TL T
    WHERE B.STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID
    AND   T.STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID
    AND   T.LANGUAGE = userenv('LANG');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'style_fmt_layout_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', 'STYLE_FMT_LAYOUT_ID' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END SELECT_ROW;


procedure DELETE_ROW (
  X_STYLE_FMT_LAYOUT_ID in NUMBER
) is
begin
  delete from HZ_STYLE_FMT_LAYOUTS_TL
  where STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_STYLE_FMT_LAYOUTS_B
  where STYLE_FMT_LAYOUT_ID = X_STYLE_FMT_LAYOUT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HZ_STYLE_FMT_LAYOUTS_TL T
  where not exists
    (select NULL
    from HZ_STYLE_FMT_LAYOUTS_B B
    where B.STYLE_FMT_LAYOUT_ID = T.STYLE_FMT_LAYOUT_ID
    );

  update HZ_STYLE_FMT_LAYOUTS_TL T set (
      PROMPT
    ) = (select
      B.PROMPT
    from HZ_STYLE_FMT_LAYOUTS_TL B
    where B.STYLE_FMT_LAYOUT_ID = T.STYLE_FMT_LAYOUT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STYLE_FMT_LAYOUT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STYLE_FMT_LAYOUT_ID,
      SUBT.LANGUAGE
    from HZ_STYLE_FMT_LAYOUTS_TL SUBB, HZ_STYLE_FMT_LAYOUTS_TL SUBT
    where SUBB.STYLE_FMT_LAYOUT_ID = SUBT.STYLE_FMT_LAYOUT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PROMPT <> SUBT.PROMPT
      or (SUBB.PROMPT is null and SUBT.PROMPT is not null)
      or (SUBB.PROMPT is not null and SUBT.PROMPT is null)
  ));

  insert into HZ_STYLE_FMT_LAYOUTS_TL (
    STYLE_FMT_LAYOUT_ID,
    PROMPT,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STYLE_FMT_LAYOUT_ID,
    B.PROMPT,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HZ_STYLE_FMT_LAYOUTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HZ_STYLE_FMT_LAYOUTS_TL T
    where T.STYLE_FMT_LAYOUT_ID = B.STYLE_FMT_LAYOUT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_CODE in VARCHAR2,
  X_LINE_NUMBER in NUMBER,
  X_POSITION in NUMBER,
  X_MANDATORY_FLAG in VARCHAR2,
  X_USE_INITIAL_FLAG in VARCHAR2,
  X_UPPERCASE_FLAG in VARCHAR2,
  X_TRANSFORM_FUNCTION in VARCHAR2,
  X_DELIMITER_BEFORE in VARCHAR2,
  X_DELIMITER_AFTER in VARCHAR2,
  X_BLANK_LINES_BEFORE in NUMBER,
  X_BLANK_LINES_AFTER in NUMBER,
  X_PROMPT in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_rowid     varchar2(64);
  l_app_id    number;
  l_id        number;
  l_object_version_number number;

begin

  -- look up application id
  select APPLICATION_ID
    into l_app_id
    from FND_APPLICATION
   where APPLICATION_SHORT_NAME = X_ATTRIBUTE_APPLICATION_CODE;

  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_f_luby := 1;
    L_USER_ID_FOR_SEED := 1;
  else
    l_f_luby := 0;
  end if;

  -- Get last update date of ldt entity
  l_f_ludate := nvl(x_last_update_date, sysdate);

  begin
    select STYLE_FMT_LAYOUT_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE, OBJECT_VERSION_NUMBER
         into l_id, l_db_luby, l_db_ludate, l_object_version_number
         from HZ_STYLE_FMT_LAYOUTS_B
         where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
           and VARIATION_NUMBER  = X_VARIATION_NUMBER
           and ATTRIBUTE_CODE    = X_ATTRIBUTE_CODE
           and ATTRIBUTE_APPLICATION_ID = l_app_id;


    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    if ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
    then
      hz_style_fmt_layouts_pkg.update_row (
        X_STYLE_FMT_LAYOUT_ID  => l_id,
        X_STYLE_FORMAT_CODE    => X_STYLE_FORMAT_CODE,
        X_VARIATION_NUMBER     => X_VARIATION_NUMBER,
        X_ATTRIBUTE_CODE       => X_ATTRIBUTE_CODE,
        X_ATTRIBUTE_APPLICATION_ID => l_app_id,
        X_LINE_NUMBER          => X_LINE_NUMBER,
        X_POSITION             => X_POSITION,
        X_MANDATORY_FLAG       => X_MANDATORY_FLAG,
        X_USE_INITIAL_FLAG     => X_USE_INITIAL_FLAG,
        X_UPPERCASE_FLAG       => X_UPPERCASE_FLAG,
        X_TRANSFORM_FUNCTION   => X_TRANSFORM_FUNCTION,
        X_DELIMITER_BEFORE     => X_DELIMITER_BEFORE,
        X_DELIMITER_AFTER      => X_DELIMITER_AFTER,
        X_BLANK_LINES_BEFORE   => X_BLANK_LINES_BEFORE,
        X_BLANK_LINES_AFTER    => X_BLANK_LINES_AFTER,
        X_PROMPT               => X_PROMPT,
	X_START_DATE_ACTIVE    => X_START_DATE_ACTIVE,
	X_END_DATE_ACTIVE      => X_END_DATE_ACTIVE,
        X_OBJECT_VERSION_NUMBER => l_object_version_number
      );
    end if;

  exception
    when no_data_found then
      -- record not found, insert in all cases
      hz_style_fmt_layouts_pkg.insert_row(
          x_rowid                => l_rowid,
          x_style_fmt_layout_id  => l_id,
          x_style_format_code    => X_STYLE_FORMAT_CODE,
          x_variation_number     => X_VARIATION_NUMBER,
          x_attribute_code       => X_ATTRIBUTE_CODE,
          x_attribute_application_id => l_app_id,
          x_line_number          => X_LINE_NUMBER,
          x_position             => X_POSITION,
          x_mandatory_flag       => X_MANDATORY_FLAG,
          x_use_initial_flag     => X_USE_INITIAL_FLAG,
          x_uppercase_flag       => X_UPPERCASE_FLAG,
          x_transform_function   => X_TRANSFORM_FUNCTION,
          x_delimiter_before     => X_DELIMITER_BEFORE,
          x_delimiter_after      => X_DELIMITER_AFTER,
          x_blank_lines_before   => X_BLANK_LINES_BEFORE,
          x_blank_lines_after    => X_BLANK_LINES_AFTER,
          x_prompt               => X_PROMPT,
          x_start_date_active    => X_START_DATE_ACTIVE,
	  x_end_date_active      => X_END_DATE_ACTIVE,
	  x_object_version_number => 1
      );
  end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_CODE in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_app_id    number;
  l_id        number;
begin

  -- look up application id
  select APPLICATION_ID
    into l_app_id
    from FND_APPLICATION
   where APPLICATION_SHORT_NAME = X_ATTRIBUTE_APPLICATION_CODE;

  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_f_luby := 1;
  else
    l_f_luby := 0;
  end if;

  -- Get last update date of ldt entity
  l_f_ludate := nvl(x_last_update_date, sysdate);

  begin
    select STYLE_FMT_LAYOUT_ID into l_id
        from HZ_STYLE_FMT_LAYOUTS_B
         where STYLE_FORMAT_CODE = x_style_format_code
           and VARIATION_NUMBER  = x_variation_number
           and ATTRIBUTE_CODE = x_attribute_code
           and ATTRIBUTE_APPLICATION_ID = l_app_id;

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
         into l_db_luby, l_db_ludate
         from HZ_STYLE_FMT_LAYOUTS_TL
         where STYLE_FMT_LAYOUT_ID = l_id
           and LANGUAGE = userenv('LANG');

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    if ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
    then
      update HZ_STYLE_FMT_LAYOUTS_TL
         set PROMPT            = nvl(X_PROMPT,PROMPT),
             LAST_UPDATE_DATE  = l_f_ludate,
             LAST_UPDATED_BY   = l_f_luby,
             LAST_UPDATE_LOGIN = 0,
             SOURCE_LANG       = userenv('LANG')
       where style_fmt_layout_id = l_id
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;  -- no translation found.  standards say do nothing.
  end;

end TRANSLATE_ROW;

end HZ_STYLE_FMT_LAYOUTS_PKG;

/
