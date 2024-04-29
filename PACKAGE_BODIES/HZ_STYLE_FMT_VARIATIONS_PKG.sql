--------------------------------------------------------
--  DDL for Package Body HZ_STYLE_FMT_VARIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_STYLE_FMT_VARIATIONS_PKG" as
/* $Header: ARHPSFVB.pls 115.7 2004/02/25 23:15:47 geliu noship $ */

L_USER_ID_FOR_SEED NUMBER := NULL;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in out NOCOPY NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID from HZ_STYLE_FMT_VARIATIONS
    where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE and
    	VARIATION_NUMBER = X_VARIATION_NUMBER
    ;
begin
  if X_VARIATION_NUMBER is null then
    select nvl(max(VARIATION_NUMBER),0)+1 into X_VARIATION_NUMBER
        from HZ_STYLE_FMT_VARIATIONS where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE;
  end if;
  insert into HZ_STYLE_FMT_VARIATIONS (
    STYLE_FORMAT_CODE,
    VARIATION_NUMBER,
    VARIATION_RANK,
    SELECTION_CONDITION,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER
  ) values (
    DECODE( X_STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR, NULL, X_STYLE_FORMAT_CODE ),
    DECODE( X_VARIATION_NUMBER, FND_API.G_MISS_NUM, NULL, X_VARIATION_NUMBER ),
    DECODE( X_VARIATION_RANK, FND_API.G_MISS_NUM, NULL, X_VARIATION_RANK ),
    DECODE( X_SELECTION_CONDITION, FND_API.G_MISS_CHAR, NULL, X_SELECTION_CONDITION ),
    DECODE( X_START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_START_DATE_ACTIVE ),
    DECODE( X_END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_END_DATE_ACTIVE ),
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.CREATED_BY),
    HZ_UTILITY_V2PUB.CREATION_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER )
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2
) is
  cursor c is select
      VARIATION_RANK,
      SELECTION_CONDITION
    from HZ_STYLE_FMT_VARIATIONS
    where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
      and VARIATION_NUMBER = X_VARIATION_NUMBER
    for update of VARIATION_RANK nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.VARIATION_RANK = X_VARIATION_RANK)
      AND (recinfo.SELECTION_CONDITION = X_SELECTION_CONDITION)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin

  update HZ_STYLE_FMT_VARIATIONS set
    VARIATION_RANK = DECODE( X_VARIATION_RANK, NULL, VARIATION_RANK, FND_API.G_MISS_CHAR, NULL, X_VARIATION_RANK ),
    SELECTION_CONDITION = DECODE( X_SELECTION_CONDITION, NULL, SELECTION_CONDITION, FND_API.G_MISS_CHAR, NULL, X_SELECTION_CONDITION ),
    START_DATE_ACTIVE = DECODE( X_START_DATE_ACTIVE, NULL, START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_START_DATE_ACTIVE ),
    END_DATE_ACTIVE = DECODE( X_END_DATE_ACTIVE, NULL, END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_END_DATE_ACTIVE ),
    LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    LAST_UPDATED_BY = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    OBJECT_VERSION_NUMBER = DECODE(X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER,
                                  FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER)
  where
    STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE and
    VARIATION_NUMBER = X_VARIATION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

PROCEDURE SELECT_ROW (
  X_STYLE_FORMAT_CODE		IN OUT NOCOPY VARCHAR2,
  X_VARIATION_NUMBER    	IN OUT NOCOPY NUMBER,
  X_VARIATION_RANK 		OUT    NOCOPY NUMBER,
  X_SELECTION_CONDITION		OUT    NOCOPY VARCHAR2,
  X_START_DATE_ACTIVE		OUT    NOCOPY DATE,
  X_END_DATE_ACTIVE		OUT    NOCOPY DATE
) IS
BEGIN
    SELECT
        NVL( STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR ),
        NVL( VARIATION_NUMBER, FND_API.G_MISS_NUM ),
        NVL( VARIATION_RANK, FND_API.G_MISS_NUM ),
        NVL( SELECTION_CONDITION, FND_API.G_MISS_CHAR ),
        NVL( START_DATE_ACTIVE, FND_API.G_MISS_DATE ),
        NVL( END_DATE_ACTIVE, FND_API.G_MISS_DATE )
    INTO X_STYLE_FORMAT_CODE,
         X_VARIATION_NUMBER,
	 X_VARIATION_RANK,
	 X_SELECTION_CONDITION,
         X_START_DATE_ACTIVE,
	 X_END_DATE_ACTIVE
    FROM HZ_STYLE_FMT_VARIATIONS
    WHERE STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
      AND VARIATION_NUMBER = X_VARIATION_NUMBER ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'style_fmt_variation_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', 'STYLE_FORMAT_CODE, VARIATION_NUMBER' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END SELECT_ROW;



procedure DELETE_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER
) is
begin
  delete from HZ_STYLE_FMT_VARIATIONS
  where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
    and VARIATION_NUMBER = X_VARIATION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  null;
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_VARIATION_NUMBER in NUMBER,
  X_VARIATION_RANK in NUMBER,
  X_SELECTION_CONDITION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE   in DATE,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_variation_number number := x_variation_number;
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_rowid     varchar2(64);
  l_object_version_number number;
begin

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
    select LAST_UPDATED_BY, LAST_UPDATE_DATE, OBJECT_VERSION_NUMBER
         into l_db_luby, l_db_ludate, l_object_version_number
         from HZ_STYLE_FMT_VARIATIONS
         where STYLE_FORMAT_CODE = x_style_format_code
           and VARIATION_NUMBER  = x_variation_number;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    if ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
    then
      hz_style_fmt_variations_pkg.update_row (
        X_STYLE_FORMAT_CODE    => X_STYLE_FORMAT_CODE,
        X_VARIATION_NUMBER     => X_VARIATION_NUMBER,
        X_VARIATION_RANK       => X_VARIATION_RANK,
        X_SELECTION_CONDITION  => X_SELECTION_CONDITION,
	X_START_DATE_ACTIVE    => X_START_DATE_ACTIVE,
	X_END_DATE_ACTIVE      => X_END_DATE_ACTIVE,
	X_OBJECT_VERSION_NUMBER => l_object_version_number
      );
    end if;

  exception
    when no_data_found then
      -- record not found, insert in all cases
      hz_style_fmt_variations_pkg.insert_row(
          x_rowid                => l_rowid,
          x_style_format_code    => X_STYLE_FORMAT_CODE,
          x_variation_number     => l_variation_number,
          x_variation_rank       => X_VARIATION_RANK,
          x_selection_condition  => X_SELECTION_CONDITION,
          x_start_date_active    => X_START_DATE_ACTIVE,
	  x_end_date_active      => X_END_DATE_ACTIVE,
	  x_object_version_number => 1
      );
  end;

end LOAD_ROW;

end HZ_STYLE_FMT_VARIATIONS_PKG;

/
