--------------------------------------------------------
--  DDL for Package Body CSD_SC_RECOMMENDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_SC_RECOMMENDATIONS_PKG" as
/* $Header: csdtscrb.pls 120.0 2005/10/26 12:53:18 swai noship $ */

procedure INSERT_ROW (
  -- P_ROWID in out nocopy VARCHAR2,
  PX_SC_RECOMMENDATION_ID in out nocopy NUMBER,
  P_SC_DOMAIN_ID in NUMBER,
  P_RECOMMENDATION_TYPE_CODE in VARCHAR2,
  P_ACTIVE_FROM in DATE,
  P_ACTIVE_TO in DATE,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_SC_RECOMMENDATION_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is

  P_ROWID ROWID;

  cursor C is select ROWID from CSD_SC_RECOMMENDATIONS_B
    where SC_RECOMMENDATION_ID = PX_SC_RECOMMENDATION_ID
    ;

begin

  select CSD_SC_RECOMMENDATIONS_S1.nextval
  into PX_SC_RECOMMENDATION_ID
  from dual;

  insert into CSD_SC_RECOMMENDATIONS_B (
    SC_DOMAIN_ID,
    RECOMMENDATION_TYPE_CODE,
    ACTIVE_FROM,
    ACTIVE_TO,
    OBJECT_VERSION_NUMBER,
    SC_RECOMMENDATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_SC_DOMAIN_ID,
    P_RECOMMENDATION_TYPE_CODE,
    P_ACTIVE_FROM,
    P_ACTIVE_TO,
    P_OBJECT_VERSION_NUMBER,
    PX_SC_RECOMMENDATION_ID,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  insert into CSD_SC_RECOMMENDATIONS_TL (
    SC_RECOMMENDATION_ID,
    SC_RECOMMENDATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    PX_SC_RECOMMENDATION_ID,
    P_SC_RECOMMENDATION_NAME,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSD_SC_RECOMMENDATIONS_TL T
    where T.SC_RECOMMENDATION_ID = PX_SC_RECOMMENDATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  P_SC_RECOMMENDATION_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from CSD_SC_RECOMMENDATIONS_B
    where SC_RECOMMENDATION_ID = P_SC_RECOMMENDATION_ID
    for update of SC_RECOMMENDATION_ID nowait;
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

  if (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

/*
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = P_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
*/

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_SC_RECOMMENDATION_ID in NUMBER,
  P_SC_DOMAIN_ID in NUMBER,
  P_RECOMMENDATION_TYPE_CODE in VARCHAR2,
  P_ACTIVE_FROM in DATE,
  P_ACTIVE_TO in DATE,
  P_SC_RECOMMENDATION_NAME in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CSD_SC_RECOMMENDATIONS_B set
    SC_DOMAIN_ID = P_SC_DOMAIN_ID,
    RECOMMENDATION_TYPE_CODE = P_RECOMMENDATION_TYPE_CODE,
    ACTIVE_FROM = P_ACTIVE_FROM,
    ACTIVE_TO = P_ACTIVE_TO,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where SC_RECOMMENDATION_ID = P_SC_RECOMMENDATION_ID AND
        OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSD_SC_RECOMMENDATIONS_TL set
    SC_RECOMMENDATION_NAME = P_SC_RECOMMENDATION_NAME,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SC_RECOMMENDATION_ID = P_SC_RECOMMENDATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_SC_RECOMMENDATION_ID in NUMBER
) is
begin
  delete from CSD_SC_RECOMMENDATIONS_TL
  where SC_RECOMMENDATION_ID = P_SC_RECOMMENDATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSD_SC_RECOMMENDATIONS_B
  where SC_RECOMMENDATION_ID = P_SC_RECOMMENDATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSD_SC_RECOMMENDATIONS_TL T
  where not exists
    (select NULL
    from CSD_SC_RECOMMENDATIONS_B B
    where B.SC_RECOMMENDATION_ID = T.SC_RECOMMENDATION_ID
    );

  update CSD_SC_RECOMMENDATIONS_TL T set (
      SC_RECOMMENDATION_NAME
    ) = (select
      B.SC_RECOMMENDATION_NAME
    from CSD_SC_RECOMMENDATIONS_TL B
    where B.SC_RECOMMENDATION_ID = T.SC_RECOMMENDATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SC_RECOMMENDATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SC_RECOMMENDATION_ID,
      SUBT.LANGUAGE
    from CSD_SC_RECOMMENDATIONS_TL SUBB, CSD_SC_RECOMMENDATIONS_TL SUBT
    where SUBB.SC_RECOMMENDATION_ID = SUBT.SC_RECOMMENDATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SC_RECOMMENDATION_NAME <> SUBT.SC_RECOMMENDATION_NAME
      or (SUBB.SC_RECOMMENDATION_NAME is null and SUBT.SC_RECOMMENDATION_NAME is not null)
      or (SUBB.SC_RECOMMENDATION_NAME is not null and SUBT.SC_RECOMMENDATION_NAME is null)
  ));

  insert into CSD_SC_RECOMMENDATIONS_TL (
    SC_RECOMMENDATION_ID,
    SC_RECOMMENDATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SC_RECOMMENDATION_ID,
    B.SC_RECOMMENDATION_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSD_SC_RECOMMENDATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSD_SC_RECOMMENDATIONS_TL T
    where T.SC_RECOMMENDATION_ID = B.SC_RECOMMENDATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CSD_SC_RECOMMENDATIONS_PKG;

/