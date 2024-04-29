--------------------------------------------------------
--  DDL for Package Body EDR_IDX_XML_ELEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_IDX_XML_ELEMENT_PKG" as
/* $Header: EDRGMLB.pls 120.2.12000000.1 2007/01/18 05:53:38 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_SECTION_NAME in VARCHAR2,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor C is select ROWID from EDR_IDX_XML_ELEMENT_B
    where ELEMENT_ID = X_ELEMENT_ID
    ;
begin
--Bug 3783242 : Start
--comment the original insert statements
--and calling the new insert_row proc instead
/*
  insert into EDR_IDX_XML_ELEMENT_B (
    ELEMENT_ID,
    XML_ELEMENT,
    DTD_ROOT_ELEMENT,
    APPLICATION_ID,
    INDEX_SECTION_NAME,
    INDEX_TAG,
    STATUS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ELEMENT_ID,
    X_XML_ELEMENT,
    X_DTD_ROOT_ELEMENT,
    X_APPLICATION_ID,
    X_INDEX_SECTION_NAME,
    X_INDEX_TAG,
    X_STATUS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EDR_IDX_XML_ELEMENT_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    ELEMENT_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_ELEMENT_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EDR_IDX_XML_ELEMENT_TL T
    where T.ELEMENT_ID = X_ELEMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
*/
  INSERT_ROW
  (X_ELEMENT_ID             => x_element_id,
   X_XML_ELEMENT            => x_xml_element,
   X_DTD_ROOT_ELEMENT       => x_dtd_root_element,
   X_APPLICATION_ID         => x_application_id,
   X_INDEX_TAG              => x_index_tag,
   X_STATUS                 => x_status,
   X_CREATED_BY             => x_created_by,
   X_CREATION_DATE          => x_creation_date,
   X_LAST_UPDATED_BY        => x_last_updated_by,
   X_LAST_UPDATE_DATE       => x_last_update_date,
   X_LAST_UPDATE_LOGIN      => x_last_update_login,
   X_DISPLAY_NAME           => x_display_name,
   X_DESCRIPTION            => x_description);
--Bug 3783242 : End

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

--Bug 3783242 : Start
procedure INSERT_ROW (
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is

  L_INDEX_SECTION_NAME VARCHAR2(30);

  --Define a cursor to query the indexed xml elements table based
  --on the display name.
  cursor C1(P_DISPLAY_NAME VARCHAR2) is
         select distinct index_section_name
         from edr_idx_xml_element_vl
         where display_name = P_DISPLAY_NAME;

begin
 open C1(X_DISPLAY_NAME);
 fetch C1 into L_INDEX_SECTION_NAME;
  if (C1%notfound) then
    --Since no record was found in the cursor, assign the index section name with
    --specified element id
    L_INDEX_SECTION_NAME := 'S'||X_ELEMENT_ID;
  end if;
  --If a record was found, then the existing section name gets reused.
 close C1;

 insert into EDR_IDX_XML_ELEMENT_B (
    ELEMENT_ID,
    XML_ELEMENT,
    DTD_ROOT_ELEMENT,
    APPLICATION_ID,
    INDEX_SECTION_NAME,
    INDEX_TAG,
    STATUS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ELEMENT_ID,
    X_XML_ELEMENT,
    X_DTD_ROOT_ELEMENT,
    X_APPLICATION_ID,
    L_INDEX_SECTION_NAME,
    X_INDEX_TAG,
    X_STATUS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EDR_IDX_XML_ELEMENT_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    ELEMENT_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_ELEMENT_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EDR_IDX_XML_ELEMENT_TL T
    where T.ELEMENT_ID = X_ELEMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;
--Bug 3783242 : End

procedure LOCK_ROW (
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_SECTION_NAME in VARCHAR2,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      XML_ELEMENT,
      DTD_ROOT_ELEMENT,
      APPLICATION_ID,
      INDEX_SECTION_NAME,
      INDEX_TAG,
      STATUS
    from EDR_IDX_XML_ELEMENT_B
    where ELEMENT_ID = X_ELEMENT_ID
    for update of ELEMENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from EDR_IDX_XML_ELEMENT_TL
    where ELEMENT_ID = X_ELEMENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ELEMENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.XML_ELEMENT = X_XML_ELEMENT)
      AND ((recinfo.DTD_ROOT_ELEMENT = X_DTD_ROOT_ELEMENT)
           OR ((recinfo.DTD_ROOT_ELEMENT is null) AND (X_DTD_ROOT_ELEMENT is null)))
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.INDEX_SECTION_NAME = X_INDEX_SECTION_NAME)
      AND (recinfo.INDEX_TAG = X_INDEX_TAG)
      AND (recinfo.STATUS = X_STATUS)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_SECTION_NAME in VARCHAR2,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
begin
  update EDR_IDX_XML_ELEMENT_B set
    XML_ELEMENT = X_XML_ELEMENT,
    DTD_ROOT_ELEMENT = X_DTD_ROOT_ELEMENT,
    APPLICATION_ID = X_APPLICATION_ID,
    INDEX_SECTION_NAME = X_INDEX_SECTION_NAME,
    INDEX_TAG = X_INDEX_TAG,
    STATUS = X_STATUS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ELEMENT_ID = X_ELEMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update EDR_IDX_XML_ELEMENT_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ELEMENT_ID = X_ELEMENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    --Bug 4417387: Start
    --raise no_data_found;
    insert into EDR_IDX_XML_ELEMENT_TL (
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      ELEMENT_ID,
      DISPLAY_NAME,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG
    ) select
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_LAST_UPDATED_BY, -- 'created by' same as 'last updated by' in this case
      X_LAST_UPDATE_DATE, -- 'creation date' same as 'last update date' in this case
      X_ELEMENT_ID,
      X_DISPLAY_NAME,
      X_DESCRIPTION,
      L.LANGUAGE_CODE,
      userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
      (select NULL
       from EDR_IDX_XML_ELEMENT_TL T
       where T.ELEMENT_ID = X_ELEMENT_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);
    --Bug 4417387: End
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_ELEMENT_ID in NUMBER
) is
begin
  delete from EDR_IDX_XML_ELEMENT_TL
  where ELEMENT_ID = X_ELEMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from EDR_IDX_XML_ELEMENT_B
  where ELEMENT_ID = X_ELEMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from EDR_IDX_XML_ELEMENT_TL T
  where not exists
    (select NULL
    from EDR_IDX_XML_ELEMENT_B B
    where B.ELEMENT_ID = T.ELEMENT_ID
    );

  update EDR_IDX_XML_ELEMENT_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from EDR_IDX_XML_ELEMENT_TL B
    where B.ELEMENT_ID = T.ELEMENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ELEMENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ELEMENT_ID,
      SUBT.LANGUAGE
    from EDR_IDX_XML_ELEMENT_TL SUBB, EDR_IDX_XML_ELEMENT_TL SUBT
    where SUBB.ELEMENT_ID = SUBT.ELEMENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into EDR_IDX_XML_ELEMENT_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    ELEMENT_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.ELEMENT_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EDR_IDX_XML_ELEMENT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EDR_IDX_XML_ELEMENT_TL T
    where T.ELEMENT_ID = B.ELEMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end EDR_IDX_XML_ELEMENT_PKG;

/
