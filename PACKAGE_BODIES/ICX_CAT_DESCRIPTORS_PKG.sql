--------------------------------------------------------
--  DDL for Package Body ICX_CAT_DESCRIPTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_DESCRIPTORS_PKG" AS
/* $Header: ICXDESIB.pls 115.5 2004/03/31 21:53:08 vkartik ship $ */

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_RT_DESCRIPTOR_ID in NUMBER,
  X_KEY in VARCHAR2,
  X_DESCRIPTOR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RT_CATEGORY_ID in NUMBER,
  X_TYPE in NUMBER,
  X_SEARCH_RESULTS_VISIBLE in VARCHAR2,
  X_ITEM_DETAIL_VISIBLE in VARCHAR2,
  X_REQUIRED in NUMBER,
  X_REFINABLE in NUMBER,
  X_SEARCHABLE in NUMBER,
  X_VALIDATED in NUMBER,
  X_SEQUENCE in NUMBER,
  X_TITLE in VARCHAR2,
  X_DEFAULTVALUE in VARCHAR2,
  X_MULTI_VALUE_TYPE in NUMBER,
  X_MULTI_VALUE_KEY in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_STORED_IN_TABLE in VARCHAR2,
  X_STORED_IN_COLUMN in VARCHAR2,
  X_SECTION_TAG in NUMBER,
  X_CLASS in VARCHAR2
) is
  cursor C is select ROWID from ICX_CAT_DESCRIPTORS_TL
    where RT_DESCRIPTOR_ID = X_RT_DESCRIPTOR_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into ICX_CAT_DESCRIPTORS_TL (
    RT_DESCRIPTOR_ID,
    KEY,
    DESCRIPTOR_NAME,
    DESCRIPTION,
    RT_CATEGORY_ID,
    TYPE,
    SEARCH_RESULTS_VISIBLE,
    ITEM_DETAIL_VISIBLE,
    REQUIRED,
    REFINABLE,
    SEARCHABLE,
    VALIDATED,
    SEQUENCE,
    TITLE,
    DEFAULTVALUE,
    MULTI_VALUE_TYPE,
    MULTI_VALUE_KEY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG,
    STORED_IN_TABLE,
    STORED_IN_COLUMN,
    SECTION_TAG,
    CLASS
  ) select
    X_RT_DESCRIPTOR_ID,
    X_KEY,
    X_DESCRIPTOR_NAME,
    X_DESCRIPTION,
    X_RT_CATEGORY_ID,
    X_TYPE,
    X_SEARCH_RESULTS_VISIBLE,
    X_ITEM_DETAIL_VISIBLE,
    X_REQUIRED,
    X_REFINABLE,
    X_SEARCHABLE,
    X_VALIDATED,
    X_SEQUENCE,
    X_TITLE,
    X_DEFAULTVALUE,
    X_MULTI_VALUE_TYPE,
    X_MULTI_VALUE_KEY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_STORED_IN_TABLE,
    X_STORED_IN_COLUMN,
    X_SECTION_TAG,
    X_CLASS
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ICX_CAT_DESCRIPTORS_TL T
    where T.RT_DESCRIPTOR_ID = X_RT_DESCRIPTOR_ID
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
  X_RT_DESCRIPTOR_ID in NUMBER,
  X_KEY in VARCHAR2,
  X_DESCRIPTOR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RT_CATEGORY_ID in NUMBER,
  X_TYPE in NUMBER,
  X_SEARCH_RESULTS_VISIBLE in VARCHAR2,
  X_ITEM_DETAIL_VISIBLE in VARCHAR2,
  X_REQUIRED in NUMBER,
  X_REFINABLE in NUMBER,
  X_SEARCHABLE in NUMBER,
  X_VALIDATED in NUMBER,
  X_SEQUENCE in NUMBER,
  X_TITLE in VARCHAR2,
  X_DEFAULTVALUE in VARCHAR2,
  X_MULTI_VALUE_TYPE in NUMBER,
  X_MULTI_VALUE_KEY in VARCHAR2
) is
  cursor c1 is select
      RT_DESCRIPTOR_ID,
      KEY,
      DESCRIPTOR_NAME,
      DESCRIPTION,
      RT_CATEGORY_ID,
      TYPE,
      SEARCH_RESULTS_VISIBLE,
      ITEM_DETAIL_VISIBLE,
      REQUIRED,
      REFINABLE,
      SEARCHABLE,
      VALIDATED,
      SEQUENCE,
      TITLE,
      DEFAULTVALUE,
      MULTI_VALUE_TYPE,
      MULTI_VALUE_KEY,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ICX_CAT_DESCRIPTORS_TL
    where RT_DESCRIPTOR_ID = X_RT_DESCRIPTOR_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RT_DESCRIPTOR_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.KEY = X_KEY)
          AND (tlinfo.DESCRIPTOR_NAME = X_DESCRIPTOR_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (tlinfo.RT_CATEGORY_ID = X_RT_CATEGORY_ID)
          AND (tlinfo.TYPE = X_TYPE)
          AND ((tlinfo.SEARCH_RESULTS_VISIBLE = X_SEARCH_RESULTS_VISIBLE)
               OR ((tlinfo.SEARCH_RESULTS_VISIBLE is null) AND (X_SEARCH_RESULTS_VISIBLE is null)))
          AND ((tlinfo.ITEM_DETAIL_VISIBLE = X_ITEM_DETAIL_VISIBLE)
               OR ((tlinfo.ITEM_DETAIL_VISIBLE is null) AND (X_ITEM_DETAIL_VISIBLE is null)))
          AND ((tlinfo.REQUIRED = X_REQUIRED)
               OR ((tlinfo.REQUIRED is null) AND (X_REQUIRED is null)))
          AND ((tlinfo.REFINABLE = X_REFINABLE)
               OR ((tlinfo.REFINABLE is null) AND (X_REFINABLE is null)))
          AND ((tlinfo.SEARCHABLE = X_SEARCHABLE)
               OR ((tlinfo.SEARCHABLE is null) AND (X_SEARCHABLE is null)))
          AND ((tlinfo.VALIDATED = X_VALIDATED)
               OR ((tlinfo.VALIDATED is null) AND (X_VALIDATED is null)))
          AND ((tlinfo.SEQUENCE = X_SEQUENCE)
               OR ((tlinfo.SEQUENCE is null) AND (X_SEQUENCE is null)))
          AND ((tlinfo.TITLE = X_TITLE)
               OR ((tlinfo.TITLE is null) AND (X_TITLE is null)))
          AND ((tlinfo.DEFAULTVALUE = X_DEFAULTVALUE)
               OR ((tlinfo.DEFAULTVALUE is null) AND (X_DEFAULTVALUE is null)))
          AND ((tlinfo.MULTI_VALUE_TYPE = X_MULTI_VALUE_TYPE)
               OR ((tlinfo.MULTI_VALUE_TYPE is null) AND (X_MULTI_VALUE_TYPE is
null)))
          AND ((tlinfo.MULTI_VALUE_KEY = X_MULTI_VALUE_KEY)
               OR ((tlinfo.MULTI_VALUE_KEY is null) AND (X_MULTI_VALUE_KEY is null)))
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
  X_RT_DESCRIPTOR_ID in NUMBER,
  X_KEY in VARCHAR2,
  X_DESCRIPTOR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RT_CATEGORY_ID in NUMBER,
  X_TYPE in NUMBER,
  X_SEARCH_RESULTS_VISIBLE in VARCHAR2,
  X_ITEM_DETAIL_VISIBLE in VARCHAR2,
  X_REQUIRED in NUMBER,
  X_REFINABLE in NUMBER,
  X_SEARCHABLE in NUMBER,
  X_VALIDATED in NUMBER,
  X_SEQUENCE in NUMBER,
  X_TITLE in VARCHAR2,
  X_DEFAULTVALUE in VARCHAR2,
  X_MULTI_VALUE_TYPE in NUMBER,
  X_MULTI_VALUE_KEY in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_STORED_IN_TABLE in VARCHAR2,
  X_STORED_IN_COLUMN in VARCHAR2,
  X_SECTION_TAG in NUMBER,
  X_CLASS in VARCHAR2
) is
begin
  --Attributes that are not translated i.e rt_category_id, key, type,
  --search_resuls_visible, item_detail_visible, required, refinable,
  --searchable, sequence, stored_in_table, stored_in_column,
  --section_tag and class should be updated
  --for all rows irrespective of the language and source_lang
  --So changed the update statement into two update statements,
  --first sql non-translated values only for those descriptors which are
  --not customized i.e. for a descriptor there should
  --be no row with the last_updated_by <> -1.
  --and the secpnd sql updates the translated values, for the descriptors
  --which were not already translated by the customers
  --due the clause (userenv('LANG') in (LANGUAGE, SOURCE_LANG))
  update ICX_CAT_DESCRIPTORS_TL o set
    KEY = X_KEY,
    RT_CATEGORY_ID = X_RT_CATEGORY_ID,
    TYPE = X_TYPE,
    SEARCH_RESULTS_VISIBLE = X_SEARCH_RESULTS_VISIBLE,
    ITEM_DETAIL_VISIBLE = X_ITEM_DETAIL_VISIBLE,
    REQUIRED = X_REQUIRED,
    REFINABLE = X_REFINABLE,
    SEARCHABLE = X_SEARCHABLE,
    SEQUENCE = X_SEQUENCE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    STORED_IN_TABLE = X_STORED_IN_TABLE,
    STORED_IN_COLUMN = X_STORED_IN_COLUMN,
    SECTION_TAG = X_SECTION_TAG,
    CLASS = X_CLASS
  where RT_DESCRIPTOR_ID = X_RT_DESCRIPTOR_ID
    and not exists ( select null from ICX_CAT_DESCRIPTORS_TL i
                      where i.RT_DESCRIPTOR_ID = o.RT_DESCRIPTOR_ID
                        and i.LAST_UPDATED_BY <>  -1);

  update ICX_CAT_DESCRIPTORS_TL set
    DESCRIPTOR_NAME = X_DESCRIPTOR_NAME,
    DESCRIPTION = X_DESCRIPTION,
    VALIDATED = X_VALIDATED,
    TITLE = X_TITLE,
    DEFAULTVALUE = X_DEFAULTVALUE,
    MULTI_VALUE_TYPE = X_MULTI_VALUE_TYPE,
    MULTI_VALUE_KEY = X_MULTI_VALUE_KEY,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    SOURCE_LANG = userenv('LANG')
  where RT_DESCRIPTOR_ID = X_RT_DESCRIPTOR_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RT_DESCRIPTOR_ID in NUMBER
) is
begin
  delete from ICX_CAT_DESCRIPTORS_TL
  where RT_DESCRIPTOR_ID = X_RT_DESCRIPTOR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


procedure TRANSLATE_ROW(
  X_RT_DESCRIPTOR_ID            in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_DESCRIPTOR_NAME             in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2) is
begin

  update icx_cat_descriptors_tl set
    descriptor_name 	     = nvl(X_DESCRIPTOR_NAME, DESCRIPTOR_NAME),
    description              = nvl(X_DESCRIPTION, DESCRIPTION),
    source_lang              = userenv('LANG'),
    last_update_date         = sysdate,
    last_updated_by          = decode(X_OWNER, 'SEED', -1, 0),
    last_update_login        = 0
  where rt_descriptor_id = to_number(X_RT_DESCRIPTOR_ID)
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


procedure LOAD_ROW(
  X_DESCRIPTOR_ID               in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_KEY                         in      VARCHAR2,
  X_DESCRIPTOR_NAME             in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_CATEGORY_ID                 in      VARCHAR2,
  X_TYPE                        in      VARCHAR2,
  X_SEARCH_RESULTS_VISIBLE      in      VARCHAR2,
  X_ITEM_DETAIL_VISIBLE         in      VARCHAR2,
  X_REQUIRED                    in      VARCHAR2,
  X_REFINABLE                   in      VARCHAR2,
  X_SEARCHABLE                  in      VARCHAR2,
  X_VALIDATED                   in      VARCHAR2,
  X_SEQUENCE                    in      VARCHAR2,
  X_TITLE                       in      VARCHAR2,
  X_DEFAULTVALUE                in      VARCHAR2,
  X_MULTI_VALUE_TYPE            in      VARCHAR2,
  X_MULTI_VALUE_KEY             in      VARCHAR2,
  X_STORED_IN_TABLE             in      VARCHAR2,
  X_STORED_IN_COLUMN            in      VARCHAR2,
  X_SECTION_TAG                 in      NUMBER,
  X_CLASS            		in      VARCHAR2
) is
begin

  declare
     user_id    number := 0;
     row_id     varchar2(64);

  begin
     if (X_OWNER = 'SEED') then
       user_id := -1;
     end if;

     ICX_CAT_DESCRIPTORS_PKG.UPDATE_ROW (
          X_RT_DESCRIPTOR_ID =>         to_number(X_DESCRIPTOR_ID),
          X_KEY =>                      X_KEY,
          X_DESCRIPTOR_NAME =>          X_DESCRIPTOR_NAME,
          X_DESCRIPTION =>              X_DESCRIPTION,
          X_RT_CATEGORY_ID =>           to_number(X_CATEGORY_ID),
          X_TYPE =>                     to_number(X_TYPE),
          X_SEARCH_RESULTS_VISIBLE =>   X_SEARCH_RESULTS_VISIBLE,
          X_ITEM_DETAIL_VISIBLE =>      X_ITEM_DETAIL_VISIBLE,
          X_REQUIRED =>                 to_number(X_REQUIRED),
          X_REFINABLE =>                to_number(X_REFINABLE),
          X_SEARCHABLE =>               to_number(X_SEARCHABLE),
          X_VALIDATED =>                to_number(X_VALIDATED),
          X_SEQUENCE =>                 to_number(X_SEQUENCE),
          X_TITLE =>                    X_TITLE,
          X_DEFAULTVALUE =>             X_DEFAULTVALUE,
          X_MULTI_VALUE_TYPE =>         to_number(X_MULTI_VALUE_TYPE),
          X_MULTI_VALUE_KEY =>          X_MULTI_VALUE_KEY,
          X_LAST_UPDATED_BY =>          user_id,
          X_LAST_UPDATE_DATE =>         sysdate,
          X_LAST_UPDATE_LOGIN =>        0,
          X_REQUEST_ID =>               null,
          X_PROGRAM_APPLICATION_ID =>   null,
          X_PROGRAM_ID =>     		null,
          X_PROGRAM_UPDATE_DATE =>      null,
          X_STORED_IN_TABLE =>     	X_STORED_IN_TABLE,
          X_STORED_IN_COLUMN =>      	X_STORED_IN_COLUMN,
          X_SECTION_TAG =>      	X_SECTION_TAG,
          X_CLASS =>      	X_CLASS
);

  exception
     when NO_DATA_FOUND then

       ICX_CAT_DESCRIPTORS_PKG.INSERT_ROW (
          X_ROWID =>                    row_id,
          X_RT_DESCRIPTOR_ID =>         to_number(X_DESCRIPTOR_ID),
          X_KEY =>                      X_KEY,
          X_DESCRIPTOR_NAME =>          X_DESCRIPTOR_NAME,
          X_DESCRIPTION =>              X_DESCRIPTION,
          X_RT_CATEGORY_ID =>           to_number(X_CATEGORY_ID),
          X_TYPE =>                     to_number(X_TYPE),
          X_SEARCH_RESULTS_VISIBLE =>   X_SEARCH_RESULTS_VISIBLE,
          X_ITEM_DETAIL_VISIBLE =>      X_ITEM_DETAIL_VISIBLE,
          X_REQUIRED =>                 to_number(X_REQUIRED),
          X_REFINABLE =>                to_number(X_REFINABLE),
          X_SEARCHABLE =>               to_number(X_SEARCHABLE),
          X_VALIDATED =>                to_number(X_VALIDATED),
          X_SEQUENCE =>                 to_number(X_SEQUENCE),
          X_TITLE =>                    X_TITLE,
          X_DEFAULTVALUE =>             X_DEFAULTVALUE,
          X_MULTI_VALUE_TYPE =>         to_number(X_MULTI_VALUE_TYPE),
          X_MULTI_VALUE_KEY =>          X_MULTI_VALUE_KEY,
          X_CREATED_BY =>               user_id,
          X_CREATION_DATE =>            sysdate,
          X_LAST_UPDATED_BY =>          user_id,
          X_LAST_UPDATE_DATE =>         sysdate,
          X_LAST_UPDATE_LOGIN =>        0,
          X_REQUEST_ID =>               null,
          X_PROGRAM_APPLICATION_ID =>   null,
          X_PROGRAM_ID =>     		null,
          X_PROGRAM_UPDATE_DATE =>      null,
          X_STORED_IN_TABLE =>     	X_STORED_IN_TABLE,
          X_STORED_IN_COLUMN =>      	X_STORED_IN_COLUMN,
          X_SECTION_TAG =>      	X_SECTION_TAG,
          X_CLASS =>      	X_CLASS);

  end;
end LOAD_ROW;


procedure ADD_LANGUAGE
is
begin
  /* comment out for bug 2085107
  update ICX_CAT_DESCRIPTORS_TL T set (
      DESCRIPTOR_NAME,
      DESCRIPTION
    ) = (select
      B.DESCRIPTOR_NAME,
      B.DESCRIPTION
    from ICX_CAT_DESCRIPTORS_TL B
    where B.RT_DESCRIPTOR_ID = T.RT_DESCRIPTOR_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RT_DESCRIPTOR_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RT_DESCRIPTOR_ID,
      SUBT.LANGUAGE
    from ICX_CAT_DESCRIPTORS_TL SUBB, ICX_POR_DESCRIPTORS_TL SUBT
    where SUBB.RT_DESCRIPTOR_ID = SUBT.RT_DESCRIPTOR_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTOR_NAME <> SUBT.DESCRIPTOR_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
  */


  insert into ICX_CAT_DESCRIPTORS_TL (
    RT_DESCRIPTOR_ID,
    KEY,
    DESCRIPTOR_NAME,
    DESCRIPTION,
    RT_CATEGORY_ID,
    TYPE,
    SEARCH_RESULTS_VISIBLE,
    ITEM_DETAIL_VISIBLE,
    REQUIRED,
    REFINABLE,
    SEARCHABLE,
    VALIDATED,
    SEQUENCE,
    TITLE,
    DEFAULTVALUE,
    MULTI_VALUE_TYPE,
    MULTI_VALUE_KEY,
    CLASS,
    CUSTOMIZATION_LEVEL,
    SECTION_TAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG,
    STORED_IN_TABLE,
    STORED_IN_COLUMN
  ) select
    B.RT_DESCRIPTOR_ID,
    B.KEY,
    B.DESCRIPTOR_NAME,
    B.DESCRIPTION,
    B.RT_CATEGORY_ID,
    B.TYPE,
    B.SEARCH_RESULTS_VISIBLE,
    B.ITEM_DETAIL_VISIBLE,
    B.REQUIRED,
    B.REFINABLE,
    B.SEARCHABLE,
    B.VALIDATED,
    B.SEQUENCE,
    B.TITLE,
    B.DEFAULTVALUE,
    B.MULTI_VALUE_TYPE,
    B.MULTI_VALUE_KEY,
    B.CLASS,
    B.CUSTOMIZATION_LEVEL,
    B.SECTION_TAG,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.STORED_IN_TABLE,
    B.STORED_IN_COLUMN
  from ICX_CAT_DESCRIPTORS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ICX_CAT_DESCRIPTORS_TL T
    where T.RT_DESCRIPTOR_ID = B.RT_DESCRIPTOR_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

end ICX_CAT_DESCRIPTORS_PKG;

/
