--------------------------------------------------------
--  DDL for Package Body FND_INDUSTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_INDUSTRIES_PKG" as
/* $Header: AFINDSTB.pls 115.1 2004/08/20 14:11:40 dbowles noship $ */

-- TRANSLATE_ROW and LOAD_ROW is identical code.  Two procedures were
-- written to accomodate NLS standards.

procedure TRANSLATE_ROW (
  X_INDUSTRY_ID in VARCHAR2,
  X_INDUSTRY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in VARCHAR2,
  X_CREATION_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_LAST_UPDATE_LOGIN in VARCHAR2,
  X_CUSTOM_MODE  in VARCHAR2
  ) is

  f_luby         NUMBER; -- entity owner in file
  f_ludate       DATE;   -- entity update date in file
  db_luby        NUMBER; -- entity owner in db
  db_ludate      DATE;   -- entity update date in db
  f_creator      NUMBER; -- entity creator in file

 BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(X_OWNER);
    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
    -- Translate creator to f_creator
    f_creator := fnd_load_util.owner_id(X_CREATED_BY);
      SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM FND_INDUSTRIES
      WHERE INDUSTRY_ID = X_INDUSTRY_ID AND
            CREATED_BY = f_creator AND
            LANGUAGE = userenv('LANG');
      IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_industries set
          industry_name            = X_INDUSTRY_NAME,
          description              = X_DESCRIPTION,
	  last_update_date         = f_ludate,
	  last_updated_by          = f_luby,
	  last_update_login        = 0,
	  source_lang              = userenv('LANG')
        where industry_id          = X_INDUSTRY_ID
        AND userenv('LANG') in (language, source_lang);
      END IF;


END TRANSLATE_ROW;

procedure LOAD_ROW (
  X_INDUSTRY_ID in VARCHAR2,
  X_INDUSTRY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in VARCHAR2,
  X_CREATION_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_LAST_UPDATE_LOGIN in VARCHAR2,
  X_CUSTOM_MODE  in VARCHAR2
  ) is

  f_luby         NUMBER; -- entity owner in file
  f_ludate       DATE;   -- entity update date in file
  db_luby        NUMBER; -- entity owner in db
  db_ludate      DATE;   -- entity update date in db
  f_creator      NUMBER; -- entity creator in file

 BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(X_OWNER);
    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
    -- Translate creator to f_creator
    f_creator := fnd_load_util.owner_id(X_CREATED_BY);
     BEGIN
      SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM FND_INDUSTRIES
      WHERE INDUSTRY_ID = X_INDUSTRY_ID AND
            CREATED_BY = f_creator AND
            LANGUAGE = userenv('LANG');
      IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_industries set
          industry_name            = X_INDUSTRY_NAME,
          description              = X_DESCRIPTION,
	  last_update_date         = f_ludate,
	  last_updated_by          = f_luby,
	  last_update_login        = 0
        where industry_id          = X_INDUSTRY_ID
        AND userenv('LANG') in (language, source_lang);
      END IF;
    EXCEPTION
      when NO_DATA_FOUND then
        insert into fnd_industries(
          industry_id,
          industry_name,
          description,
          created_by,
          creation_date,
          last_update_date,
          last_updated_by,
          last_update_login,
          source_lang,
          language )
        select
          X_INDUSTRY_ID,
          X_INDUSTRY_NAME,
          X_DESCRIPTION,
          f_creator,
          f_ludate,
          f_ludate,
          f_luby,
          0,
          userenv('LANG'),
          l.language_code
        from
          fnd_languages l
        where l.installed_flag in ('I', 'B')
        and not exists
          (select null
           from fnd_industries t
           where t.industry_id = x_industry_id
           and t.language = l.language_code);

 END;

END LOAD_ROW;

PROCEDURE ADD_LANGUAGE IS

BEGIN
  insert into fnd_industries(
          industry_id,
          industry_name,
          description,
          created_by,
          creation_date,
          last_update_date,
          last_updated_by,
          last_update_login,
          source_lang,
          language )
          select
            b.industry_id,
            b.industry_name,
            b.description,
            b.created_by,
            b.creation_date,
            b.last_update_date,
            b.last_updated_by,
            b.last_update_login,
            b.source_lang,
            l.language_code
          from fnd_industries b, fnd_languages l
          where l.INSTALLED_FLAG in ('I', 'B')
                and b.language = userenv('LANG')
                and not exists
                  (select NULL
                   from fnd_industries t
                   where t.industry_id = b.industry_id
                   and t.language = l.language_code);



end ADD_LANGUAGE;

END FND_INDUSTRIES_PKG;

/
