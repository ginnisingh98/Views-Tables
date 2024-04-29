--------------------------------------------------------
--  DDL for Package Body FND_PRINTER_STYLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PRINTER_STYLES_PKG" as
/* $Header: AFPRRPSB.pls 120.2 2005/08/19 20:18:05 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PRINTER_STYLE_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_WIDTH in NUMBER,
  X_LENGTH in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_SRW_DRIVER in VARCHAR2,
  X_HEADER_FLAG in VARCHAR2,
  X_USER_PRINTER_STYLE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_PRINTER_STYLES
    where PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME
    ;
begin
  insert into FND_PRINTER_STYLES (
    PRINTER_STYLE_NAME,
    SEQUENCE,
    WIDTH,
    LENGTH,
    DESCRIPTION,
    ORIENTATION,
    SRW_DRIVER,
    HEADER_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PRINTER_STYLE_NAME,
    X_SEQUENCE,
    X_WIDTH,
    X_LENGTH,
    X_DESCRIPTION,
    X_ORIENTATION,
    X_SRW_DRIVER,
    X_HEADER_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_PRINTER_STYLES_TL (
    PRINTER_STYLE_NAME,
    USER_PRINTER_STYLE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PRINTER_STYLE_NAME,
    X_USER_PRINTER_STYLE_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_PRINTER_STYLES_TL T
    where T.PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME
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
  X_PRINTER_STYLE_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_WIDTH in NUMBER,
  X_LENGTH in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_SRW_DRIVER in VARCHAR2,
  X_HEADER_FLAG in VARCHAR2,
  X_USER_PRINTER_STYLE_NAME in VARCHAR2
) is
  cursor c is select
      SEQUENCE,
      WIDTH,
      LENGTH,
      DESCRIPTION,
      ORIENTATION,
      SRW_DRIVER,
      HEADER_FLAG
    from FND_PRINTER_STYLES
    where PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME
    for update of PRINTER_STYLE_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_PRINTER_STYLE_NAME
    from FND_PRINTER_STYLES_TL
    where PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME
    and LANGUAGE = userenv('LANG')
    for update of PRINTER_STYLE_NAME nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SEQUENCE = X_SEQUENCE)
      AND (recinfo.WIDTH = X_WIDTH)
      AND (recinfo.LENGTH = X_LENGTH)
      AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      AND ((recinfo.ORIENTATION = X_ORIENTATION)
           OR ((recinfo.ORIENTATION is null) AND (X_ORIENTATION is null)))
      AND ((recinfo.SRW_DRIVER = X_SRW_DRIVER)
           OR ((recinfo.SRW_DRIVER is null) AND (X_SRW_DRIVER is null)))
      AND ((recinfo.HEADER_FLAG = X_HEADER_FLAG)
           OR ((recinfo.HEADER_FLAG is null) AND (X_HEADER_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_PRINTER_STYLE_NAME = X_USER_PRINTER_STYLE_NAME)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PRINTER_STYLE_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_WIDTH in NUMBER,
  X_LENGTH in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_SRW_DRIVER in VARCHAR2,
  X_HEADER_FLAG in VARCHAR2,
  X_USER_PRINTER_STYLE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_PRINTER_STYLES set
    SEQUENCE = X_SEQUENCE,
    WIDTH = X_WIDTH,
    LENGTH = X_LENGTH,
    DESCRIPTION = X_DESCRIPTION,
    ORIENTATION = X_ORIENTATION,
    SRW_DRIVER = X_SRW_DRIVER,
    HEADER_FLAG = X_HEADER_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_PRINTER_STYLES_TL set
    USER_PRINTER_STYLE_NAME = X_USER_PRINTER_STYLE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PRINTER_STYLE_NAME in VARCHAR2
) is
begin
  delete from FND_PRINTER_STYLES
  where PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_PRINTER_STYLES_TL
  where PRINTER_STYLE_NAME = X_PRINTER_STYLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_PRINTER_STYLES_TL T
  where not exists
    (select NULL
    from FND_PRINTER_STYLES B
    where B.PRINTER_STYLE_NAME = T.PRINTER_STYLE_NAME
    );

  update FND_PRINTER_STYLES_TL T set (
      USER_PRINTER_STYLE_NAME
    ) = (select
      B.USER_PRINTER_STYLE_NAME
    from FND_PRINTER_STYLES_TL B
    where B.PRINTER_STYLE_NAME = T.PRINTER_STYLE_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PRINTER_STYLE_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.PRINTER_STYLE_NAME,
      SUBT.LANGUAGE
    from FND_PRINTER_STYLES_TL SUBB, FND_PRINTER_STYLES_TL SUBT
    where SUBB.PRINTER_STYLE_NAME = SUBT.PRINTER_STYLE_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_PRINTER_STYLE_NAME <> SUBT.USER_PRINTER_STYLE_NAME
  ));
*/

  insert into FND_PRINTER_STYLES_TL (
    PRINTER_STYLE_NAME,
    USER_PRINTER_STYLE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PRINTER_STYLE_NAME,
    B.USER_PRINTER_STYLE_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_PRINTER_STYLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_PRINTER_STYLES_TL T
    where T.PRINTER_STYLE_NAME = B.PRINTER_STYLE_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_PRINTER_STYLES_PKG;

/
