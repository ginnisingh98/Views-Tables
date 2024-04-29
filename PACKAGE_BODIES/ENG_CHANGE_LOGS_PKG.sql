--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_LOGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_LOGS_PKG" as
/* $Header: ENGCLOGB.pls 120.1 2005/07/28 02:43:25 lkasturi noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CHANGE_LOG_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
  X_CHANGE_LINE_ID in NUMBER,
  X_LOCAL_REVISED_ITEM_SEQUENCE_ in NUMBER,
  X_LOG_CLASSIFICATION_CODE in VARCHAR2,
  X_LOG_TYPE_CODE in VARCHAR2,
  X_LOCAL_CHANGE_ID in NUMBER,
  X_LOCAL_CHANGE_LINE_ID in NUMBER,
  X_REVISED_ITEM_SEQUENCE_ID in NUMBER,
  X_LOCAL_ORGANIZATION_ID in NUMBER,
  X_LOG_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CHANGE_PROPAGATION_MAP_ID IN NUMBER
) is
  cursor C is select ROWID from ENG_CHANGE_LOGS_B
    where CHANGE_LOG_ID = X_CHANGE_LOG_ID
    ;
begin
  insert into ENG_CHANGE_LOGS_B (
    CHANGE_LOG_ID,
    CHANGE_ID,
    CHANGE_LINE_ID,
    LOCAL_REVISED_ITEM_SEQUENCE_ID,
    LOG_CLASSIFICATION_CODE,
    LOG_TYPE_CODE,
    LOCAL_CHANGE_ID,
    LOCAL_CHANGE_LINE_ID,
    REVISED_ITEM_SEQUENCE_ID,
    LOCAL_ORGANIZATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CHANGE_PROPAGATION_MAP_ID
  ) values (
    X_CHANGE_LOG_ID,
    X_CHANGE_ID,
    X_CHANGE_LINE_ID,
    X_LOCAL_REVISED_ITEM_SEQUENCE_,
    X_LOG_CLASSIFICATION_CODE,
    X_LOG_TYPE_CODE,
    X_LOCAL_CHANGE_ID,
    X_LOCAL_CHANGE_LINE_ID,
    X_REVISED_ITEM_SEQUENCE_ID,
    X_LOCAL_ORGANIZATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CHANGE_PROPAGATION_MAP_ID
  );

  insert into ENG_CHANGE_LOGS_TL (
    CHANGE_LOG_ID,
    LOG_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHANGE_LOG_ID,
    X_LOG_TEXT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_LOGS_TL T
    where T.CHANGE_LOG_ID = X_CHANGE_LOG_ID
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
  X_CHANGE_LOG_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
  X_CHANGE_LINE_ID in NUMBER,
  X_LOCAL_REVISED_ITEM_SEQUENCE_ in NUMBER,
  X_LOG_CLASSIFICATION_CODE in VARCHAR2,
  X_LOG_TYPE_CODE in VARCHAR2,
  X_LOCAL_CHANGE_ID in NUMBER,
  X_LOCAL_CHANGE_LINE_ID in NUMBER,
  X_REVISED_ITEM_SEQUENCE_ID in NUMBER,
  X_LOCAL_ORGANIZATION_ID in NUMBER,
  X_LOG_TEXT in VARCHAR2,
  X_CHANGE_PROPAGATION_MAP_ID IN NUMBER
) is
  cursor c is select
      CHANGE_ID,
      CHANGE_LINE_ID,
      LOCAL_REVISED_ITEM_SEQUENCE_ID,
      LOG_CLASSIFICATION_CODE,
      LOG_TYPE_CODE,
      LOCAL_CHANGE_ID,
      LOCAL_CHANGE_LINE_ID,
      REVISED_ITEM_SEQUENCE_ID,
      LOCAL_ORGANIZATION_ID,
      CHANGE_PROPAGATION_MAP_ID
    from ENG_CHANGE_LOGS_B
    where CHANGE_LOG_ID = X_CHANGE_LOG_ID
    for update of CHANGE_LOG_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LOG_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_LOGS_TL
    where CHANGE_LOG_ID = X_CHANGE_LOG_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHANGE_LOG_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CHANGE_ID = X_CHANGE_ID)
      AND ((recinfo.CHANGE_LINE_ID = X_CHANGE_LINE_ID)
           OR ((recinfo.CHANGE_LINE_ID is null) AND (X_CHANGE_LINE_ID is null)))
      AND ((recinfo.LOCAL_REVISED_ITEM_SEQUENCE_ID = X_LOCAL_REVISED_ITEM_SEQUENCE_)
           OR ((recinfo.LOCAL_REVISED_ITEM_SEQUENCE_ID is null) AND (X_LOCAL_REVISED_ITEM_SEQUENCE_ is null)))
      AND (recinfo.LOG_CLASSIFICATION_CODE = X_LOG_CLASSIFICATION_CODE)
      AND ((recinfo.LOG_TYPE_CODE = X_LOG_TYPE_CODE)
           OR ((recinfo.LOG_TYPE_CODE is null) AND (X_LOG_TYPE_CODE is null)))
      AND ((recinfo.LOCAL_CHANGE_ID = X_LOCAL_CHANGE_ID)
           OR ((recinfo.LOCAL_CHANGE_ID is null) AND (X_LOCAL_CHANGE_ID is null)))
      AND ((recinfo.LOCAL_CHANGE_LINE_ID = X_LOCAL_CHANGE_LINE_ID)
           OR ((recinfo.LOCAL_CHANGE_LINE_ID is null) AND (X_LOCAL_CHANGE_LINE_ID is null)))
      AND ((recinfo.REVISED_ITEM_SEQUENCE_ID = X_REVISED_ITEM_SEQUENCE_ID)
           OR ((recinfo.REVISED_ITEM_SEQUENCE_ID is null) AND (X_REVISED_ITEM_SEQUENCE_ID is null)))
      AND ((recinfo.LOCAL_ORGANIZATION_ID = X_LOCAL_ORGANIZATION_ID)
           OR ((recinfo.LOCAL_ORGANIZATION_ID is null) AND (X_LOCAL_ORGANIZATION_ID is null)))
      AND ((recinfo.CHANGE_PROPAGATION_MAP_ID = X_CHANGE_PROPAGATION_MAP_ID)
           OR ((recinfo.CHANGE_PROPAGATION_MAP_ID is null) AND (X_CHANGE_PROPAGATION_MAP_ID is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.LOG_TEXT = X_LOG_TEXT)
               OR ((tlinfo.LOG_TEXT is null) AND (X_LOG_TEXT is null)))
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
  X_CHANGE_LOG_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
  X_CHANGE_LINE_ID in NUMBER,
  X_LOCAL_REVISED_ITEM_SEQUENCE_ in NUMBER,
  X_LOG_CLASSIFICATION_CODE in VARCHAR2,
  X_LOG_TYPE_CODE in VARCHAR2,
  X_LOCAL_CHANGE_ID in NUMBER,
  X_LOCAL_CHANGE_LINE_ID in NUMBER,
  X_REVISED_ITEM_SEQUENCE_ID in NUMBER,
  X_LOCAL_ORGANIZATION_ID in NUMBER,
  X_LOG_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CHANGE_PROPAGATION_MAP_ID IN NUMBER
) is
begin
  update ENG_CHANGE_LOGS_B set
    CHANGE_ID = X_CHANGE_ID,
    CHANGE_LINE_ID = X_CHANGE_LINE_ID,
    LOCAL_REVISED_ITEM_SEQUENCE_ID = X_LOCAL_REVISED_ITEM_SEQUENCE_,
    LOG_CLASSIFICATION_CODE = X_LOG_CLASSIFICATION_CODE,
    LOG_TYPE_CODE = X_LOG_TYPE_CODE,
    LOCAL_CHANGE_ID = X_LOCAL_CHANGE_ID,
    LOCAL_CHANGE_LINE_ID = X_LOCAL_CHANGE_LINE_ID,
    REVISED_ITEM_SEQUENCE_ID = X_REVISED_ITEM_SEQUENCE_ID,
    LOCAL_ORGANIZATION_ID = X_LOCAL_ORGANIZATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    CHANGE_PROPAGATION_MAP_ID = X_CHANGE_PROPAGATION_MAP_ID
  where CHANGE_LOG_ID = X_CHANGE_LOG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_LOGS_TL set
    LOG_TEXT = X_LOG_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANGE_LOG_ID = X_CHANGE_LOG_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHANGE_LOG_ID in NUMBER
) is
begin
  delete from ENG_CHANGE_LOGS_TL
  where CHANGE_LOG_ID = X_CHANGE_LOG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_LOGS_B
  where CHANGE_LOG_ID = X_CHANGE_LOG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_LOGS_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_LOGS_B B
    where B.CHANGE_LOG_ID = T.CHANGE_LOG_ID
    );

  update ENG_CHANGE_LOGS_TL T set (
      LOG_TEXT
    ) = (select
      B.LOG_TEXT
    from ENG_CHANGE_LOGS_TL B
    where B.CHANGE_LOG_ID = T.CHANGE_LOG_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANGE_LOG_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHANGE_LOG_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_LOGS_TL SUBB, ENG_CHANGE_LOGS_TL SUBT
    where SUBB.CHANGE_LOG_ID = SUBT.CHANGE_LOG_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOG_TEXT <> SUBT.LOG_TEXT
      or (SUBB.LOG_TEXT is null and SUBT.LOG_TEXT is not null)
      or (SUBB.LOG_TEXT is not null and SUBT.LOG_TEXT is null)
  ));

  insert into ENG_CHANGE_LOGS_TL (
    CHANGE_LOG_ID,
    LOG_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CHANGE_LOG_ID,
    B.LOG_TEXT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_LOGS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_LOGS_TL T
    where T.CHANGE_LOG_ID = B.CHANGE_LOG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_CHANGE_LOGS_PKG;

/
