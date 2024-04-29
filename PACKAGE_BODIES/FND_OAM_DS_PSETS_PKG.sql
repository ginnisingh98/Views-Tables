--------------------------------------------------------
--  DDL for Package Body FND_OAM_DS_PSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DS_PSETS_PKG" as
/* $Header: AFOAMPSB.pls 120.1 2005/07/28 21:39:02 yawu noship $ */
procedure INSERT_ROW (
      X_ROWID in out nocopy VARCHAR2,
	X_POLICYSET_ID in NUMBER,
	X_POLICYSET_NAME IN VARCHAR2,
	X_DESCRIPTION IN VARCHAR2,
	X_CREATED_BY in NUMBER,
	X_CREATION_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_OAM_DS_PSETS_B
    where POLICYSET_ID = X_POLICYSET_ID;
begin
  insert into FND_OAM_DS_PSETS_B (
	POLICYSET_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
  ) values (
	X_POLICYSET_ID,
	X_CREATED_BY,
	X_CREATION_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN
  );

  insert into FND_OAM_DS_PSETS_TL (
	POLICYSET_ID,
	POLICYSET_NAME,
	DESCRIPTION,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
  ) select
	X_POLICYSET_ID,
      X_POLICYSET_NAME,
	X_DESCRIPTION,
	X_CREATED_BY,
	X_CREATION_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_DS_PSETS_TL T
    where T.POLICYSET_ID = X_POLICYSET_ID
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
	X_POLICYSET_ID in NUMBER,
	X_POLICYSET_NAME IN VARCHAR2,
	X_DESCRIPTION IN VARCHAR2,
	X_CREATED_BY in NUMBER,
	X_CREATION_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor c is select
	POLICYSET_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
    from FND_OAM_DS_PSETS_B
    where POLICYSET_ID = X_POLICYSET_ID
    for update of POLICYSET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      POLICYSET_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_OAM_DS_PSETS_TL
    where POLICYSET_ID = X_POLICYSET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of POLICYSET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.POLICYSET_NAME = X_POLICYSET_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
	X_POLICYSET_ID in NUMBER,
	X_POLICYSET_NAME IN VARCHAR2,
	X_DESCRIPTION IN VARCHAR2,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OAM_DS_PSETS_B set
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where POLICYSET_ID = X_POLICYSET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OAM_DS_PSETS_TL set
    POLICYSET_NAME = X_POLICYSET_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where POLICYSET_ID = X_POLICYSET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_POLICYSET_ID in NUMBER
) is
begin
  delete from FND_OAM_DS_PSETS_TL
  where POLICYSET_ID = X_POLICYSET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OAM_DS_PSETS_B
  where POLICYSET_ID = X_POLICYSET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FND_OAM_DS_PSETS_TL T
  where not exists
    (select NULL
    from FND_OAM_DS_PSETS_B B
    where B.POLICYSET_ID = T.POLICYSET_ID
    );

  update FND_OAM_DS_PSETS_TL T set (
      POLICYSET_NAME,
      DESCRIPTION
    ) = (select
      B.POLICYSET_NAME,
      B.DESCRIPTION
    from FND_OAM_DS_PSETS_TL B
    where B.POLICYSET_ID = T.POLICYSET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.POLICYSET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.POLICYSET_ID,
      SUBT.LANGUAGE
    from FND_OAM_DS_PSETS_TL SUBB, FND_OAM_DS_PSETS_TL SUBT
    where SUBB.POLICYSET_ID = SUBT.POLICYSET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.POLICYSET_NAME <> SUBT.POLICYSET_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FND_OAM_DS_PSETS_TL (
    POLICYSET_ID,
    POLICYSET_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.POLICYSET_ID,
    B.POLICYSET_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_DS_PSETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_DS_PSETS_TL T
    where T.POLICYSET_ID = B.POLICYSET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

Procedure TRANSLATE_ROW
(
 x_POLICYSET_ID  in NUMBER,
 x_POLICYSET_NAME in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number
)
is
begin

UPDATE FND_OAM_DS_PSETS_TL SET
POLICYSET_NAME  = nvl(x_POLICYSET_NAME,POLICYSET_NAME),
last_update_date        = nvl(x_last_update_date,sysdate),
last_updated_by         = x_last_updated_by,
last_update_login       = 0,
source_lang             = userenv('LANG')
WHERE POLICYSET_ID      = x_POLICYSET_ID
AND userenv('LANG') in (LANGUAGE,SOURCE_LANG);

  IF (sql%notfound) THEN
    raise no_data_found;
  END IF;

end TRANSLATE_ROW;

end FND_OAM_DS_PSETS_PKG;

/
