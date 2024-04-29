--------------------------------------------------------
--  DDL for Package Body IEU_WP_SECTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_SECTIONS_PKG" as
/* $Header: IEUVSECB.pls 120.0 2005/06/02 15:45:40 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  P_SECTION_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_SECURITY_GROUP_ID in NUMBER,
  P_SECTION_CODE in VARCHAR2,
  P_SECTION_LABEL in VARCHAR2,
  P_SECTION_DESCRIPTION in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEU_WP_SECTIONS_B
    where SECTION_ID = P_SECTION_ID
    ;
begin
  insert into IEU_WP_SECTIONS_B (
    SECTION_ID,
    OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID,
    SECTION_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_SECTION_ID,
    P_OBJECT_VERSION_NUMBER,
    P_SECURITY_GROUP_ID,
    P_SECTION_CODE,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  insert into IEU_WP_SECTIONS_TL (
    SECTION_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    SECTION_LABEL,
    SECTION_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_SECTION_ID,
    P_OBJECT_VERSION_NUMBER,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_SECURITY_GROUP_ID,
    P_SECTION_LABEL,
    P_SECTION_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEU_WP_SECTIONS_TL T
    where T.SECTION_ID = P_SECTION_ID
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
  P_SECTION_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_SECURITY_GROUP_ID in NUMBER,
  P_SECTION_CODE in VARCHAR2,
  P_SECTION_LABEL in VARCHAR2,
  P_SECTION_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID,
      SECTION_CODE
    from IEU_WP_SECTIONS_B
    where SECTION_ID = P_SECTION_ID
    for update of SECTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SECTION_LABEL,
      SECTION_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEU_WP_SECTIONS_TL
    where SECTION_ID = P_SECTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SECTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
      AND ((recinfo.SECURITY_GROUP_ID = P_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (P_SECURITY_GROUP_ID is null)))
      AND (recinfo.SECTION_CODE = P_SECTION_CODE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SECTION_LABEL = P_SECTION_LABEL)
          AND ((tlinfo.SECTION_DESCRIPTION = P_SECTION_DESCRIPTION)
               OR ((tlinfo.SECTION_DESCRIPTION is null) AND (P_SECTION_DESCRIPTION is null)))
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
  P_SECTION_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_SECURITY_GROUP_ID in NUMBER,
  P_SECTION_CODE in VARCHAR2,
  P_SECTION_LABEL in VARCHAR2,
  P_SECTION_DESCRIPTION in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEU_WP_SECTIONS_B set
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID = P_SECURITY_GROUP_ID,
    SECTION_CODE = P_SECTION_CODE,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where SECTION_ID = P_SECTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEU_WP_SECTIONS_TL set
    SECTION_LABEL = P_SECTION_LABEL,
    SECTION_DESCRIPTION = P_SECTION_DESCRIPTION,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SECTION_ID = P_SECTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_SECTION_ID in NUMBER
) is
begin
  delete from IEU_WP_SECTIONS_TL
  where SECTION_ID = P_SECTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_WP_SECTIONS_B
  where SECTION_ID = P_SECTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_WP_SECTIONS_TL T
  where not exists
    (select NULL
    from IEU_WP_SECTIONS_B B
    where B.SECTION_ID = T.SECTION_ID
    );

  update IEU_WP_SECTIONS_TL T set (
      SECTION_LABEL,
      SECTION_DESCRIPTION
    ) = (select
      B.SECTION_LABEL,
      B.SECTION_DESCRIPTION
    from IEU_WP_SECTIONS_TL B
    where B.SECTION_ID = T.SECTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SECTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SECTION_ID,
      SUBT.LANGUAGE
    from IEU_WP_SECTIONS_TL SUBB, IEU_WP_SECTIONS_TL SUBT
    where SUBB.SECTION_ID = SUBT.SECTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SECTION_LABEL <> SUBT.SECTION_LABEL
      or SUBB.SECTION_DESCRIPTION <> SUBT.SECTION_DESCRIPTION
      or (SUBB.SECTION_DESCRIPTION is null and SUBT.SECTION_DESCRIPTION is not null)
      or (SUBB.SECTION_DESCRIPTION is not null and SUBT.SECTION_DESCRIPTION is null)
  ));

  insert into IEU_WP_SECTIONS_TL (
    SECTION_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    SECTION_LABEL,
    SECTION_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SECTION_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.SECTION_LABEL,
    B.SECTION_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_WP_SECTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_WP_SECTIONS_TL T
    where T.SECTION_ID = B.SECTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IEU_WP_SECTIONS_PKG;

/
