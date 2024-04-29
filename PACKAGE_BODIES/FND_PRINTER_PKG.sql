--------------------------------------------------------
--  DDL for Package Body FND_PRINTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PRINTER_PKG" as
/* $Header: AFPRMPRB.pls 120.2 2005/08/19 20:17:07 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PRINTER_NAME in VARCHAR2,
  X_PRINTER_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_PRINTER
    where PRINTER_NAME = X_PRINTER_NAME
    ;
begin
  insert into FND_PRINTER (
    PRINTER_NAME,
    PRINTER_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PRINTER_NAME,
    X_PRINTER_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_PRINTER_TL (
    PRINTER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PRINTER_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_PRINTER_TL T
    where T.PRINTER_NAME = X_PRINTER_NAME
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
  X_PRINTER_NAME in VARCHAR2,
  X_PRINTER_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PRINTER_TYPE
    from FND_PRINTER
    where PRINTER_NAME = X_PRINTER_NAME
    for update of PRINTER_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION
    from FND_PRINTER_TL
    where PRINTER_NAME = X_PRINTER_NAME
    and LANGUAGE = userenv('LANG')
    for update of PRINTER_NAME nowait;
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
  if (    (recinfo.PRINTER_TYPE = X_PRINTER_TYPE)
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

  if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PRINTER_NAME in VARCHAR2,
  X_PRINTER_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_PRINTER set
    PRINTER_TYPE = X_PRINTER_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PRINTER_NAME = X_PRINTER_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_PRINTER_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PRINTER_NAME = X_PRINTER_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PRINTER_NAME in VARCHAR2
) is
begin
  delete from FND_PRINTER
  where PRINTER_NAME = X_PRINTER_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_PRINTER_TL
  where PRINTER_NAME = X_PRINTER_NAME;

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

  delete from FND_PRINTER_TL T
  where not exists
    (select NULL
    from FND_PRINTER B
    where B.PRINTER_NAME = T.PRINTER_NAME
    );

  update FND_PRINTER_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FND_PRINTER_TL B
    where B.PRINTER_NAME = T.PRINTER_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PRINTER_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.PRINTER_NAME,
      SUBT.LANGUAGE
    from FND_PRINTER_TL SUBB, FND_PRINTER_TL SUBT
    where SUBB.PRINTER_NAME = SUBT.PRINTER_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_PRINTER_TL (
    PRINTER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PRINTER_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_PRINTER_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_PRINTER_TL T
    where T.PRINTER_NAME = B.PRINTER_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_PRINTER_PKG;

/
