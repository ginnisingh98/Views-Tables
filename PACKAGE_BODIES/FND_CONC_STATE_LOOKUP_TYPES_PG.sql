--------------------------------------------------------
--  DDL for Package Body FND_CONC_STATE_LOOKUP_TYPES_PG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_STATE_LOOKUP_TYPES_PG" as
/* $Header: AFCPSC6B.pls 120.2 2005/08/19 11:36:55 ddhulla ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_LOOKUP_TYPE_ID in NUMBER,
  X_LOOKUP_TYPE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_USER_LOOKUP_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_CONC_STATE_LOOKUP_TYPES
    where LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID
    ;
begin
  insert into FND_CONC_STATE_LOOKUP_TYPES (
    LOOKUP_TYPE_ID,
    LOOKUP_TYPE_NAME,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOOKUP_TYPE_ID,
    X_LOOKUP_TYPE_NAME,
    X_ENABLED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_CONC_STATE_LOOKUP_TYPES_TL (
    LOOKUP_TYPE_ID,
    USER_LOOKUP_TYPE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOOKUP_TYPE_ID,
    X_USER_LOOKUP_TYPE_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_CONC_STATE_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID
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
  X_LOOKUP_TYPE_ID in NUMBER,
  X_LOOKUP_TYPE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_USER_LOOKUP_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      LOOKUP_TYPE_NAME,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from FND_CONC_STATE_LOOKUP_TYPES
    where LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID
    for update of LOOKUP_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_LOOKUP_TYPE_NAME,
      DESCRIPTION
    from FND_CONC_STATE_LOOKUP_TYPES_TL
    where LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID
    and LANGUAGE = userenv('LANG')
    for update of LOOKUP_TYPE_ID nowait;
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
  if (    (recinfo.LOOKUP_TYPE_NAME = X_LOOKUP_TYPE_NAME)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
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

  if (    (tlinfo.USER_LOOKUP_TYPE_NAME = X_USER_LOOKUP_TYPE_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_LOOKUP_TYPE_ID in NUMBER,
  X_LOOKUP_TYPE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_USER_LOOKUP_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_CONC_STATE_LOOKUP_TYPES set
    LOOKUP_TYPE_NAME = X_LOOKUP_TYPE_NAME,
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_CONC_STATE_LOOKUP_TYPES_TL set
    USER_LOOKUP_TYPE_NAME = X_USER_LOOKUP_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE_ID in NUMBER
) is
begin
  delete from FND_CONC_STATE_LOOKUP_TYPES
  where LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_CONC_STATE_LOOKUP_TYPES_TL
  where LOOKUP_TYPE_ID = X_LOOKUP_TYPE_ID;

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

  delete from FND_CONC_STATE_LOOKUP_TYPES_TL T
  where not exists
    (select NULL
    from FND_CONC_STATE_LOOKUP_TYPES B
    where B.LOOKUP_TYPE_ID = T.LOOKUP_TYPE_ID
    );

  update FND_CONC_STATE_LOOKUP_TYPES_TL T set (
      USER_LOOKUP_TYPE_NAME,
      DESCRIPTION
    ) = (select
      B.USER_LOOKUP_TYPE_NAME,
      B.DESCRIPTION
    from FND_CONC_STATE_LOOKUP_TYPES_TL B
    where B.LOOKUP_TYPE_ID = T.LOOKUP_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE_ID,
      SUBT.LANGUAGE
    from FND_CONC_STATE_LOOKUP_TYPES_TL SUBB, FND_CONC_STATE_LOOKUP_TYPES_TL SUBT
    where SUBB.LOOKUP_TYPE_ID = SUBT.LOOKUP_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_LOOKUP_TYPE_NAME <> SUBT.USER_LOOKUP_TYPE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_CONC_STATE_LOOKUP_TYPES_TL (
    LOOKUP_TYPE_ID,
    USER_LOOKUP_TYPE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOOKUP_TYPE_ID,
    B.USER_LOOKUP_TYPE_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_CONC_STATE_LOOKUP_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_CONC_STATE_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE_ID = B.LOOKUP_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_CONC_STATE_LOOKUP_TYPES_PG;

/
