--------------------------------------------------------
--  DDL for Package Body IEC_G_REP_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_REP_REPORTS_PKG" as
/* $Header: IECREPRB.pls 115.11 2003/08/22 20:42:30 hhuang ship $ */

procedure INSERT_ROW (
  X_ROWID out nocopy VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_LAST_GENERATED in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REPORT_TITLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_G_REP_REPORTS_B
    where REPORT_ID = X_REPORT_ID
    ;
begin
  x_rowid := NULL;

  insert into IEC_G_REP_REPORTS_B (
    REPORT_ID,
    LAST_GENERATED,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_REPORT_ID,
    X_LAST_GENERATED,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_G_REP_REPORTS_TL (
    REPORT_TITLE,
    REPORT_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REPORT_TITLE,
    X_REPORT_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_G_REP_REPORTS_TL T
    where T.REPORT_ID = X_REPORT_ID
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
  X_REPORT_ID in NUMBER,
  X_LAST_GENERATED in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REPORT_TITLE in VARCHAR2
) is
  cursor c is select
      LAST_GENERATED,
      OBJECT_VERSION_NUMBER
    from IEC_G_REP_REPORTS_B
    where REPORT_ID = X_REPORT_ID
    for update of REPORT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      REPORT_TITLE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_G_REP_REPORTS_TL
    where REPORT_ID = X_REPORT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REPORT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.LAST_GENERATED = X_LAST_GENERATED)
           OR ((recinfo.LAST_GENERATED is null) AND (X_LAST_GENERATED is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.REPORT_TITLE = X_REPORT_TITLE)
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
  X_REPORT_ID in NUMBER,
  X_LAST_GENERATED in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REPORT_TITLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_G_REP_REPORTS_B set
    LAST_GENERATED = X_LAST_GENERATED,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REPORT_ID = X_REPORT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_G_REP_REPORTS_TL set
    REPORT_TITLE = X_REPORT_TITLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REPORT_ID = X_REPORT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REPORT_ID in NUMBER
) is
begin
  delete from IEC_G_REP_REPORTS_TL
  where REPORT_ID = X_REPORT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_G_REP_REPORTS_B
  where REPORT_ID = X_REPORT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_G_REP_REPORTS_TL T
  where not exists
    (select NULL
    from IEC_G_REP_REPORTS_B B
    where B.REPORT_ID = T.REPORT_ID
    );

  update IEC_G_REP_REPORTS_TL T set (
      REPORT_TITLE
    ) = (select
      B.REPORT_TITLE
    from IEC_G_REP_REPORTS_TL B
    where B.REPORT_ID = T.REPORT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REPORT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REPORT_ID,
      SUBT.LANGUAGE
    from IEC_G_REP_REPORTS_TL SUBB, IEC_G_REP_REPORTS_TL SUBT
    where SUBB.REPORT_ID = SUBT.REPORT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REPORT_TITLE <> SUBT.REPORT_TITLE
  ));

  insert into IEC_G_REP_REPORTS_TL (
    REPORT_TITLE,
    REPORT_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.REPORT_TITLE,
    B.REPORT_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_G_REP_REPORTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_G_REP_REPORTS_TL T
    where T.REPORT_ID = B.REPORT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_REPORT_ID in NUMBER,
  X_LAST_GENERATED in DATE,
  X_REPORT_TITLE in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW (X_REPORT_ID, X_LAST_GENERATED, 0, X_REPORT_TITLE, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_REPORT_ID, X_LAST_GENERATED, 0, X_REPORT_TITLE, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_REPORT_ID in NUMBER,
  X_REPORT_TITLE in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  update IEC_G_REP_REPORTS_TL set
  REPORT_TITLE = X_REPORT_TITLE,
  SOURCE_LANG = userenv('LANG'),
  LAST_UPDATE_DATE = SYSDATE,
  LAST_UPDATED_BY = DECODE(X_OWNER, 'SEED', 1, 0),
  LAST_UPDATE_LOGIN = 0
  where REPORT_ID = X_REPORT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end TRANSLATE_ROW;

end IEC_G_REP_REPORTS_PKG;

/