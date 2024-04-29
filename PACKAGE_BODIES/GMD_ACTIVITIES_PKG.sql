--------------------------------------------------------
--  DDL for Package Body GMD_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ACTIVITIES_PKG" as
/* $Header: GMDACTMB.pls 120.1 2005/09/29 11:18:57 srsriran noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_ACTIVITY in VARCHAR2,
  X_COST_ANALYSIS_CODE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_ACTIVITY_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_ACTIVITIES_B
    where ACTIVITY = X_ACTIVITY
    ;
begin
  insert into GMD_ACTIVITIES_B (
    ACTIVITY,
    COST_ANALYSIS_CODE,
    DELETE_MARK,
    TEXT_CODE,
    TRANS_CNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ACTIVITY,
    X_COST_ANALYSIS_CODE,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_TRANS_CNT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_ACTIVITIES_TL (
    ACTIVITY,
    ACTIVITY_DESC,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ACTIVITY,
    X_ACTIVITY_DESC,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_ACTIVITIES_TL T
    where T.ACTIVITY = X_ACTIVITY
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
  X_ACTIVITY in VARCHAR2,
  X_COST_ANALYSIS_CODE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_ACTIVITY_DESC in VARCHAR2
) is
  cursor c is select
      COST_ANALYSIS_CODE,
      DELETE_MARK,
      TEXT_CODE,
      TRANS_CNT
    from GMD_ACTIVITIES_B
    where ACTIVITY = X_ACTIVITY
    for update of ACTIVITY nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ACTIVITY_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_ACTIVITIES_TL
    where ACTIVITY = X_ACTIVITY
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ACTIVITY nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.COST_ANALYSIS_CODE = X_COST_ANALYSIS_CODE)
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.TRANS_CNT = X_TRANS_CNT)
           OR ((recinfo.TRANS_CNT is null) AND (X_TRANS_CNT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ACTIVITY_DESC = X_ACTIVITY_DESC)
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
  X_ACTIVITY in VARCHAR2,
  X_COST_ANALYSIS_CODE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_ACTIVITY_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_ACTIVITIES_B set
    COST_ANALYSIS_CODE = X_COST_ANALYSIS_CODE,
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    TRANS_CNT = X_TRANS_CNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ACTIVITY = X_ACTIVITY;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_ACTIVITIES_TL set
    ACTIVITY_DESC = X_ACTIVITY_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ACTIVITY = X_ACTIVITY
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTIVITY in VARCHAR2
) is
begin

 /* delete from GMD_ACTIVITIES_TL
  where ACTIVITY = X_ACTIVITY;

  if (sql%notfound) then
    raise no_data_found;
  end if; */

   update GMD_ACTIVITIES_B
   set delete_mark = 1
   where ACTIVITY = X_ACTIVITY;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_ACTIVITIES_TL T
  where not exists
    (select NULL
    from GMD_ACTIVITIES_B B
    where B.ACTIVITY = T.ACTIVITY
    );

  update GMD_ACTIVITIES_TL T set (
      ACTIVITY_DESC
    ) = (select
      B.ACTIVITY_DESC
    from GMD_ACTIVITIES_TL B
    where B.ACTIVITY = T.ACTIVITY
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTIVITY,
      T.LANGUAGE
  ) in (select
      SUBT.ACTIVITY,
      SUBT.LANGUAGE
    from GMD_ACTIVITIES_TL SUBB, GMD_ACTIVITIES_TL SUBT
    where SUBB.ACTIVITY = SUBT.ACTIVITY
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ACTIVITY_DESC <> SUBT.ACTIVITY_DESC
  ));

  insert into GMD_ACTIVITIES_TL (
    ACTIVITY,
    ACTIVITY_DESC,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ACTIVITY,
    B.ACTIVITY_DESC,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_ACTIVITIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_ACTIVITIES_TL T
    where T.ACTIVITY = B.ACTIVITY
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMD_ACTIVITIES_PKG;

/
