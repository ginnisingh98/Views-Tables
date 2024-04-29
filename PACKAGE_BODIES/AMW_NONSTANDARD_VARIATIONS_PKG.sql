--------------------------------------------------------
--  DDL for Package Body AMW_NONSTANDARD_VARIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_NONSTANDARD_VARIATIONS_PKG" as
/* $Header: amwnstvb.pls 120.1 2005/06/28 14:26:29 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VARIATION_ROW_ID in NUMBER,
  X_STD_PROCESS_ID in NUMBER,
  X_STD_PROCESS_REV_NUM in NUMBER,
  X_NON_STD_PROCESS_ID in NUMBER,
  X_NON_STD_PROCESS_REV_NUM in NUMBER,
  X_STD_CHILD_ID in NUMBER,
  X_NON_STD_CHILD_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REASON in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMW_NONSTANDARD_VARIATIONS_B
    where VARIATION_ROW_ID = X_VARIATION_ROW_ID
    ;
begin
  insert into AMW_NONSTANDARD_VARIATIONS_B (
    VARIATION_ROW_ID,
    STD_PROCESS_ID,
    STD_PROCESS_REV_NUM,
    NON_STD_PROCESS_ID,
    NON_STD_PROCESS_REV_NUM,
    STD_CHILD_ID,
    NON_STD_CHILD_ID,
    START_DATE,
    END_DATE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VARIATION_ROW_ID,
    X_STD_PROCESS_ID,
    X_STD_PROCESS_REV_NUM,
    X_NON_STD_PROCESS_ID,
    X_NON_STD_PROCESS_REV_NUM,
    X_STD_CHILD_ID,
    X_NON_STD_CHILD_ID,
    X_START_DATE,
    X_END_DATE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMW_NONSTANDARD_VARIATIONS_TL (
    VARIATION_ROW_ID,
    REASON,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VARIATION_ROW_ID,
    X_REASON,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_NONSTANDARD_VARIATIONS_TL T
    where T.VARIATION_ROW_ID = X_VARIATION_ROW_ID
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
  X_VARIATION_ROW_ID in NUMBER,
  X_STD_PROCESS_ID in NUMBER,
  X_STD_PROCESS_REV_NUM in NUMBER,
  X_NON_STD_PROCESS_ID in NUMBER,
  X_NON_STD_PROCESS_REV_NUM in NUMBER,
  X_STD_CHILD_ID in NUMBER,
  X_NON_STD_CHILD_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REASON in VARCHAR2
) is
  cursor c is select
      STD_PROCESS_ID,
      STD_PROCESS_REV_NUM,
      NON_STD_PROCESS_ID,
      NON_STD_PROCESS_REV_NUM,
      STD_CHILD_ID,
      NON_STD_CHILD_ID,
      START_DATE,
      END_DATE,
      OBJECT_VERSION_NUMBER
    from AMW_NONSTANDARD_VARIATIONS_B
    where VARIATION_ROW_ID = X_VARIATION_ROW_ID
    for update of VARIATION_ROW_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      REASON,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_NONSTANDARD_VARIATIONS_TL
    where VARIATION_ROW_ID = X_VARIATION_ROW_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VARIATION_ROW_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.STD_PROCESS_ID = X_STD_PROCESS_ID)
           OR ((recinfo.STD_PROCESS_ID is null) AND (X_STD_PROCESS_ID is null)))
      AND ((recinfo.STD_PROCESS_REV_NUM = X_STD_PROCESS_REV_NUM)
           OR ((recinfo.STD_PROCESS_REV_NUM is null) AND (X_STD_PROCESS_REV_NUM is null)))
      AND ((recinfo.NON_STD_PROCESS_ID = X_NON_STD_PROCESS_ID)
           OR ((recinfo.NON_STD_PROCESS_ID is null) AND (X_NON_STD_PROCESS_ID is null)))
      AND ((recinfo.NON_STD_PROCESS_REV_NUM = X_NON_STD_PROCESS_REV_NUM)
           OR ((recinfo.NON_STD_PROCESS_REV_NUM is null) AND (X_NON_STD_PROCESS_REV_NUM is null)))
      AND ((recinfo.STD_CHILD_ID = X_STD_CHILD_ID)
           OR ((recinfo.STD_CHILD_ID is null) AND (X_STD_CHILD_ID is null)))
      AND ((recinfo.NON_STD_CHILD_ID = X_NON_STD_CHILD_ID)
           OR ((recinfo.NON_STD_CHILD_ID is null) AND (X_NON_STD_CHILD_ID is null)))
      AND ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.REASON = X_REASON)
               OR ((tlinfo.REASON is null) AND (X_REASON is null)))
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
  X_VARIATION_ROW_ID in NUMBER,
  X_STD_PROCESS_ID in NUMBER,
  X_STD_PROCESS_REV_NUM in NUMBER,
  X_NON_STD_PROCESS_ID in NUMBER,
  X_NON_STD_PROCESS_REV_NUM in NUMBER,
  X_STD_CHILD_ID in NUMBER,
  X_NON_STD_CHILD_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REASON in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMW_NONSTANDARD_VARIATIONS_B set
    STD_PROCESS_ID = X_STD_PROCESS_ID,
    STD_PROCESS_REV_NUM = X_STD_PROCESS_REV_NUM,
    NON_STD_PROCESS_ID = X_NON_STD_PROCESS_ID,
    NON_STD_PROCESS_REV_NUM = X_NON_STD_PROCESS_REV_NUM,
    STD_CHILD_ID = X_STD_CHILD_ID,
    NON_STD_CHILD_ID = X_NON_STD_CHILD_ID,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VARIATION_ROW_ID = X_VARIATION_ROW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_NONSTANDARD_VARIATIONS_TL set
    REASON = X_REASON,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VARIATION_ROW_ID = X_VARIATION_ROW_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_VARIATION_ROW_ID in NUMBER
) is
begin
  delete from AMW_NONSTANDARD_VARIATIONS_TL
  where VARIATION_ROW_ID = X_VARIATION_ROW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_NONSTANDARD_VARIATIONS_B
  where VARIATION_ROW_ID = X_VARIATION_ROW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMW_NONSTANDARD_VARIATIONS_TL T
  where not exists
    (select NULL
    from AMW_NONSTANDARD_VARIATIONS_B B
    where B.VARIATION_ROW_ID = T.VARIATION_ROW_ID
    );

  update AMW_NONSTANDARD_VARIATIONS_TL T set (
      REASON
    ) = (select
      B.REASON
    from AMW_NONSTANDARD_VARIATIONS_TL B
    where B.VARIATION_ROW_ID = T.VARIATION_ROW_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VARIATION_ROW_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VARIATION_ROW_ID,
      SUBT.LANGUAGE
    from AMW_NONSTANDARD_VARIATIONS_TL SUBB, AMW_NONSTANDARD_VARIATIONS_TL SUBT
    where SUBB.VARIATION_ROW_ID = SUBT.VARIATION_ROW_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REASON <> SUBT.REASON
      or (SUBB.REASON is null and SUBT.REASON is not null)
      or (SUBB.REASON is not null and SUBT.REASON is null)
  ));

  insert into AMW_NONSTANDARD_VARIATIONS_TL (
    VARIATION_ROW_ID,
    REASON,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.VARIATION_ROW_ID,
    B.REASON,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_NONSTANDARD_VARIATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_NONSTANDARD_VARIATIONS_TL T
    where T.VARIATION_ROW_ID = B.VARIATION_ROW_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMW_NONSTANDARD_VARIATIONS_PKG;

/
