--------------------------------------------------------
--  DDL for Package Body AR_BPA_PAGE_SETUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_PAGE_SETUPS_PKG" as
/* $Header: ARBPSTPB.pls 120.0 2004/07/30 07:28:06 verao noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PAGE_SETUP_ID in NUMBER,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_TOP_MARGIN in NUMBER,
  X_BOTTOM_MARGIN in NUMBER,
  X_LEFT_MARGIN in NUMBER,
  X_RIGHT_MARGIN in NUMBER,
  X_PAGE_NUMBER_LOC in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PAGE_UNIT_OF_MEASURE in VARCHAR2,
  X_PAGE_SETUP_NAME in VARCHAR2,
  X_PAGE_SETUP_DESC in VARCHAR2,
  X_PRINT_FONT_FAMILY in VARCHAR2,
  X_PRINT_FONT_SIZE  in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_BPA_PAGE_SETUPS_B
    where PAGE_SETUP_ID = X_PAGE_SETUP_ID
    ;
begin
  insert into AR_BPA_PAGE_SETUPS_B (
    PAGE_WIDTH,
    PAGE_HEIGHT,
    TOP_MARGIN,
    BOTTOM_MARGIN,
    LEFT_MARGIN,
    RIGHT_MARGIN,
    PAGE_NUMBER_LOC,
    PAGE_SETUP_ID,
    SEEDED_FLAG,
    PAGE_UNIT_OF_MEASURE,
    PRINT_FONT_FAMILY,
    PRINT_FONT_SIZE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PAGE_WIDTH,
    X_PAGE_HEIGHT,
    X_TOP_MARGIN,
    X_BOTTOM_MARGIN,
    X_LEFT_MARGIN,
    X_RIGHT_MARGIN,
    X_PAGE_NUMBER_LOC,
    X_PAGE_SETUP_ID,
    X_SEEDED_FLAG,
    X_PAGE_UNIT_OF_MEASURE,
    X_PRINT_FONT_FAMILY,
    X_PRINT_FONT_SIZE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AR_BPA_PAGE_SETUPS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    PAGE_SETUP_ID,
    PAGE_SETUP_NAME,
    PAGE_SETUP_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PAGE_SETUP_ID,
    X_PAGE_SETUP_NAME,
    X_PAGE_SETUP_DESC,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AR_BPA_PAGE_SETUPS_TL T
    where T.PAGE_SETUP_ID = X_PAGE_SETUP_ID
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
  X_PAGE_SETUP_ID in NUMBER,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_TOP_MARGIN in NUMBER,
  X_BOTTOM_MARGIN in NUMBER,
  X_LEFT_MARGIN in NUMBER,
  X_RIGHT_MARGIN in NUMBER,
  X_PAGE_NUMBER_LOC in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PAGE_UNIT_OF_MEASURE in VARCHAR2,
  X_PAGE_SETUP_NAME in VARCHAR2,
  X_PAGE_SETUP_DESC in VARCHAR2,
  X_PRINT_FONT_FAMILY in VARCHAR2,
  X_PRINT_FONT_SIZE  in VARCHAR2
) is
  cursor c is select
      PAGE_WIDTH,
      PAGE_HEIGHT,
      TOP_MARGIN,
      BOTTOM_MARGIN,
      LEFT_MARGIN,
      RIGHT_MARGIN,
      PAGE_NUMBER_LOC,
      SEEDED_FLAG,
      PAGE_UNIT_OF_MEASURE,
      PRINT_FONT_FAMILY,
      PRINT_FONT_SIZE
    from AR_BPA_PAGE_SETUPS_B
    where PAGE_SETUP_ID = X_PAGE_SETUP_ID
    for update of PAGE_SETUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PAGE_SETUP_NAME,
      PAGE_SETUP_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_BPA_PAGE_SETUPS_TL
    where PAGE_SETUP_ID = X_PAGE_SETUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PAGE_SETUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PAGE_WIDTH = X_PAGE_WIDTH)
      AND (recinfo.PAGE_HEIGHT = X_PAGE_HEIGHT)
      AND (recinfo.TOP_MARGIN = X_TOP_MARGIN)
      AND (recinfo.BOTTOM_MARGIN = X_BOTTOM_MARGIN)
      AND (recinfo.LEFT_MARGIN = X_LEFT_MARGIN)
      AND (recinfo.RIGHT_MARGIN = X_RIGHT_MARGIN)
      AND (recinfo.PAGE_NUMBER_LOC = X_PAGE_NUMBER_LOC)
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND (recinfo.PAGE_UNIT_OF_MEASURE = X_PAGE_UNIT_OF_MEASURE)
      AND (recinfo.PRINT_FONT_FAMILY = X_PRINT_FONT_FAMILY)
      AND (recinfo.PRINT_FONT_SIZE = X_PRINT_FONT_SIZE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PAGE_SETUP_NAME = X_PAGE_SETUP_NAME)
          AND ((tlinfo.PAGE_SETUP_DESC = X_PAGE_SETUP_DESC)
               OR ((tlinfo.PAGE_SETUP_DESC is null) AND (X_PAGE_SETUP_DESC is null)))
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
  X_PAGE_SETUP_ID in NUMBER,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_TOP_MARGIN in NUMBER,
  X_BOTTOM_MARGIN in NUMBER,
  X_LEFT_MARGIN in NUMBER,
  X_RIGHT_MARGIN in NUMBER,
  X_PAGE_NUMBER_LOC in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PAGE_UNIT_OF_MEASURE in VARCHAR2,
  X_PAGE_SETUP_NAME in VARCHAR2,
  X_PAGE_SETUP_DESC in VARCHAR2,
  X_PRINT_FONT_FAMILY in VARCHAR2,
  X_PRINT_FONT_SIZE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_BPA_PAGE_SETUPS_B set
    PAGE_WIDTH = X_PAGE_WIDTH,
    PAGE_HEIGHT = X_PAGE_HEIGHT,
    TOP_MARGIN = X_TOP_MARGIN,
    BOTTOM_MARGIN = X_BOTTOM_MARGIN,
    LEFT_MARGIN = X_LEFT_MARGIN,
    RIGHT_MARGIN = X_RIGHT_MARGIN,
    PAGE_NUMBER_LOC = X_PAGE_NUMBER_LOC,
    SEEDED_FLAG = X_SEEDED_FLAG,
    PAGE_UNIT_OF_MEASURE = X_PAGE_UNIT_OF_MEASURE,
    PRINT_FONT_FAMILY = X_PRINT_FONT_FAMILY,
    PRINT_FONT_SIZE = X_PRINT_FONT_SIZE ,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PAGE_SETUP_ID = X_PAGE_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_BPA_PAGE_SETUPS_TL set
    PAGE_SETUP_NAME = X_PAGE_SETUP_NAME,
    PAGE_SETUP_DESC = X_PAGE_SETUP_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PAGE_SETUP_ID = X_PAGE_SETUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PAGE_SETUP_ID in NUMBER
) is
begin
  delete from AR_BPA_PAGE_SETUPS_TL
  where PAGE_SETUP_ID = X_PAGE_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_BPA_PAGE_SETUPS_B
  where PAGE_SETUP_ID = X_PAGE_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_BPA_PAGE_SETUPS_TL T
  where not exists
    (select NULL
    from AR_BPA_PAGE_SETUPS_B B
    where B.PAGE_SETUP_ID = T.PAGE_SETUP_ID
    );

  update AR_BPA_PAGE_SETUPS_TL T set (
      PAGE_SETUP_NAME,
      PAGE_SETUP_DESC
    ) = (select
      B.PAGE_SETUP_NAME,
      B.PAGE_SETUP_DESC
    from AR_BPA_PAGE_SETUPS_TL B
    where B.PAGE_SETUP_ID = T.PAGE_SETUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PAGE_SETUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PAGE_SETUP_ID,
      SUBT.LANGUAGE
    from AR_BPA_PAGE_SETUPS_TL SUBB, AR_BPA_PAGE_SETUPS_TL SUBT
    where SUBB.PAGE_SETUP_ID = SUBT.PAGE_SETUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PAGE_SETUP_NAME <> SUBT.PAGE_SETUP_NAME
      or SUBB.PAGE_SETUP_DESC <> SUBT.PAGE_SETUP_DESC
      or (SUBB.PAGE_SETUP_DESC is null and SUBT.PAGE_SETUP_DESC is not null)
      or (SUBB.PAGE_SETUP_DESC is not null and SUBT.PAGE_SETUP_DESC is null)
  ));

  insert into AR_BPA_PAGE_SETUPS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    PAGE_SETUP_ID,
    PAGE_SETUP_NAME,
    PAGE_SETUP_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PAGE_SETUP_ID,
    B.PAGE_SETUP_NAME,
    B.PAGE_SETUP_DESC,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_BPA_PAGE_SETUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_BPA_PAGE_SETUPS_TL T
    where T.PAGE_SETUP_ID = B.PAGE_SETUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW(
  X_PAGE_SETUP_ID in NUMBER,
  X_PAGE_WIDTH in NUMBER,
  X_PAGE_HEIGHT in NUMBER,
  X_TOP_MARGIN in NUMBER,
  X_BOTTOM_MARGIN in NUMBER,
  X_LEFT_MARGIN in NUMBER,
  X_RIGHT_MARGIN in NUMBER,
  X_PAGE_NUMBER_LOC in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PAGE_UNIT_OF_MEASURE in VARCHAR2,
  X_PAGE_SETUP_NAME in VARCHAR2,
  X_PAGE_SETUP_DESC in VARCHAR2,
  X_PRINT_FONT_FAMILY in VARCHAR2,
  X_PRINT_FONT_SIZE in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
user_id            number := 0;
row_id             varchar2(64);
BEGIN
  if (X_OWNER = 'SEED') then
        user_id := 1;
  end if;

  BEGIN
    AR_BPA_PAGE_SETUPS_PKG.UPDATE_ROW (
	        X_PAGE_SETUP_ID 	=>  X_PAGE_SETUP_ID ,
		  X_PAGE_WIDTH 	=>  X_PAGE_WIDTH ,
		  X_PAGE_HEIGHT 	=>  X_PAGE_HEIGHT ,
		  X_TOP_MARGIN 	=>  X_TOP_MARGIN ,
		  X_BOTTOM_MARGIN 	=>  X_BOTTOM_MARGIN ,
		  X_LEFT_MARGIN 	=>  X_LEFT_MARGIN ,
		  X_RIGHT_MARGIN 	=>  X_RIGHT_MARGIN ,
		  X_PAGE_NUMBER_LOC 	=>  X_PAGE_NUMBER_LOC ,
		  X_SEEDED_FLAG 	=>  X_SEEDED_FLAG ,
		  X_PAGE_UNIT_OF_MEASURE 	=>  X_PAGE_UNIT_OF_MEASURE ,
		  X_PAGE_SETUP_NAME 	=>  X_PAGE_SETUP_NAME ,
		  X_PAGE_SETUP_DESC 	=>  X_PAGE_SETUP_DESC ,
              X_PRINT_FONT_FAMILY   =>  X_PRINT_FONT_FAMILY,
              X_PRINT_FONT_SIZE     =>  X_PRINT_FONT_SIZE,
              X_LAST_UPDATE_DATE 	=> sysdate,
		  X_LAST_UPDATED_BY 	=> user_id,
		  X_LAST_UPDATE_LOGIN 	=> 0);
 exception
       when NO_DATA_FOUND then
           AR_BPA_PAGE_SETUPS_PKG.INSERT_ROW (
  		X_ROWID 			=> row_id,
	        X_PAGE_SETUP_ID 	=>  X_PAGE_SETUP_ID ,
		  X_PAGE_WIDTH 	=>  X_PAGE_WIDTH ,
		  X_PAGE_HEIGHT 	=>  X_PAGE_HEIGHT ,
		  X_TOP_MARGIN 	=>  X_TOP_MARGIN ,
		  X_BOTTOM_MARGIN 	=>  X_BOTTOM_MARGIN ,
		  X_LEFT_MARGIN 	=>  X_LEFT_MARGIN ,
		  X_RIGHT_MARGIN 	=>  X_RIGHT_MARGIN ,
		  X_PAGE_NUMBER_LOC 	=>  X_PAGE_NUMBER_LOC ,
		  X_SEEDED_FLAG 	=>  X_SEEDED_FLAG ,
		  X_PAGE_UNIT_OF_MEASURE 	=>  X_PAGE_UNIT_OF_MEASURE ,
		  X_PAGE_SETUP_NAME 	=>  X_PAGE_SETUP_NAME ,
		  X_PAGE_SETUP_DESC 	=>  X_PAGE_SETUP_DESC ,
              X_PRINT_FONT_FAMILY   =>  X_PRINT_FONT_FAMILY,
              X_PRINT_FONT_SIZE     =>  X_PRINT_FONT_SIZE,
  		  X_CREATION_DATE 	=> sysdate,
              X_CREATED_BY 		=> user_id,
              X_LAST_UPDATE_DATE 	=> sysdate,
              X_LAST_UPDATED_BY 	=> user_id,
              X_LAST_UPDATE_LOGIN 	=> 0);
    end;
end load_row;

procedure TRANSLATE_ROW (
  X_PAGE_SETUP_ID in NUMBER,
  X_PAGE_SETUP_NAME in VARCHAR2,
  X_PAGE_SETUP_DESC in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    update AR_BPA_PAGE_SETUPS_TL
      set PAGE_SETUP_NAME = X_PAGE_SETUP_NAME ,
          PAGE_SETUP_DESC = X_PAGE_SETUP_DESC ,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where PAGE_SETUP_ID = X_PAGE_SETUP_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;



end AR_BPA_PAGE_SETUPS_PKG;

/
