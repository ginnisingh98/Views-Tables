--------------------------------------------------------
--  DDL for Package Body IBW_REFERRAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_REFERRAL_PVT" AS
/* $Header: IBWREFB.pls 120.10 2005/12/15 00:57 vekancha noship $*/


  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBW_REFERRAL_PVT
  --
  -- PURPOSE
  --   Private API for inserting records into referral categories and also referral patterns. Mainly used by offline engine
  --
  -- NOTES
  --   Offline engine uses this API to insert records into IBW_REFERRAL_CATEGORIES_B, IBW_REFERRAL_CATEGORIES_TL,
  --	IBW_REFERRAL_PATTERNS_B, IBW_REFERRAL_PATTERNS_TL

  -- HISTORY
  --   05/10/2005	VEKANCHA	Created

  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBW_REFERRAL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBWREFB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    TABLE HANDLERS
--      1. insert_row
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- insert row into referral categories and referral patterns tables
-- ****************************************************************************

PROCEDURE insert_row (
	referral_category_id  OUT NOCOPY NUMBER,
	x_referral_category_name IN VARCHAR2,
	x_referral_pattern IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
)

IS

	x_ref_cat_id	NUMBER;
	x_ref_pat_id	NUMBER;
	x_status		VARCHAR2(1);
	x_user_def_flag	VARCHAR2(1);
	created_by		NUMBER;
	creation_date	DATE;
	last_updated_by	NUMBER;
	last_update_date	DATE;
	last_update_login	NUMBER;
	obj_ver_number	NUMBER;
	program_id		NUMBER;
	program_login_id	NUMBER;
	program_app_id	NUMBER;
	request_id		NUMBER;

	CURSOR c IS SELECT ibw_referral_categories_b_s1.nextval FROM dual;

	CURSOR c1 IS SELECT ibw_url_patterns_b_s1.nextval FROM dual;

	CURSOR c2 IS SELECT referral_category_id FROM ibw_referral_categories_b
	    WHERE referral_category_id = x_ref_cat_id;

BEGIN
	x_status := 'Y';
	x_user_def_flag := 'N';
	obj_ver_number := 1;
	OPEN c;
	FETCH c INTO x_ref_cat_id;
	CLOSE c;

	OPEN c1;
	FETCH c1 into x_ref_pat_id;
	CLOSE c1;

	FND_PROFILE.GET('USER_ID', created_by);

	creation_date := SYSDATE;

	last_updated_by := created_by;

	last_update_date := SYSDATE;

	FND_PROFILE.GET('LOGIN_ID', last_update_login);

	FND_PROFILE.GET('CONC_PROGRAM_ID', program_id);

	FND_PROFILE.GET('CONC_LOGIN_ID', program_login_id);

	FND_PROFILE.GET('CONC_PROGRAM_APPLICATION_ID', program_app_id);

	FND_PROFILE.GET('CONC_REQUEST_ID', request_id);

	INSERT INTO ibw_referral_categories_b (referral_category_id, status, user_defined_flag, created_by, creation_date,
							last_updated_by, last_update_date, last_update_login, object_version_number,
							program_id, program_login_id, program_application_id, request_id)
			VALUES (x_ref_cat_id, x_status, x_user_def_flag, created_by, creation_date,
						last_updated_by, last_update_date, last_update_login, obj_ver_number,
						program_id, program_login_id, program_app_id, request_id);

	INSERT INTO ibw_referral_categories_tl(referral_category_id, language, source_lang, referral_category_name, description, created_by, creation_date,
					last_updated_by, last_update_date, last_update_login, object_version_number,
					program_id, program_login_id, program_application_id, request_id)
			SELECT M.referral_category_id, l.language_code, b.language_code,  x_referral_category_name, NULL, M.created_by, M.creation_date,
				M.last_updated_by, M.last_update_date, M.last_update_login, M.object_version_number,
				M.program_id, M.program_login_id, M.program_application_id, M.request_id
			FROM ibw_referral_categories_b M, fnd_languages l, fnd_languages b
			WHERE l.installed_flag IN ('I','B') AND b.installed_flag='B' AND M.referral_category_id=x_ref_cat_id;


	INSERT INTO ibw_url_patterns_b (url_pattern_id, url_pattern, type_id, type, created_by, creation_date,
							last_updated_by, last_update_date, last_update_login, object_version_number,
							program_id, program_login_id, program_application_id, request_id)
			VALUES (x_ref_pat_id, x_referral_pattern, x_ref_cat_id, 'R', created_by, creation_date,
						last_updated_by, last_update_date, last_update_login, obj_ver_number,
						program_id, program_login_id, program_app_id, request_id);

	INSERT INTO ibw_url_patterns_tl(url_pattern_id, language, source_lang, description, created_by, creation_date,
					last_updated_by, last_update_date, last_update_login, object_version_number,
					program_id, program_login_id, program_application_id, request_id)
			SELECT M.url_pattern_id, l.language_code, b.language_code, NULL, M.created_by, M.creation_date,
				M.last_updated_by, M.last_update_date, M.last_update_login, M.object_version_number,
				M.program_id, M.program_login_id, M.program_application_id, M.request_id
			FROM ibw_url_patterns_b M, fnd_languages l, fnd_languages b
			WHERE l.installed_flag IN ('I','B') AND b.installed_flag='B' AND M.url_pattern_id=x_ref_pat_id;


	OPEN c2;
	FETCH c2 INTO referral_category_id;
	IF (c2%NOTFOUND) THEN
		CLOSE c2;
		ROLLBACK;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE c2;

--	COMMIT;

END insert_row;


procedure ADD_LANGUAGE
is
begin
  delete from IBW_REFERRAL_CATEGORIES_TL T
  where not exists
    (select NULL
    from IBW_REFERRAL_CATEGORIES_B B
    where B.REFERRAL_CATEGORY_ID = T.REFERRAL_CATEGORY_ID
    );

  update IBW_REFERRAL_CATEGORIES_TL T set (
      REFERRAL_CATEGORY_NAME,
      DESCRIPTION
    ) = (select
      B.REFERRAL_CATEGORY_NAME,
      B.DESCRIPTION
    from IBW_REFERRAL_CATEGORIES_TL B
    where B.REFERRAL_CATEGORY_ID = T.REFERRAL_CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REFERRAL_CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REFERRAL_CATEGORY_ID,
      SUBT.LANGUAGE
    from IBW_REFERRAL_CATEGORIES_TL SUBB, IBW_REFERRAL_CATEGORIES_TL SUBT
    where SUBB.REFERRAL_CATEGORY_ID = SUBT.REFERRAL_CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REFERRAL_CATEGORY_NAME <> SUBT.REFERRAL_CATEGORY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into IBW_REFERRAL_CATEGORIES_TL (
    REFERRAL_CATEGORY_ID,
    REFERRAL_CATEGORY_NAME,
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.REFERRAL_CATEGORY_ID,
    B.REFERRAL_CATEGORY_NAME,
    B.DESCRIPTION,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.PROGRAM_ID,
    B.PROGRAM_LOGIN_ID,
    B.PROGRAM_APPLICATION_ID,
    B.REQUEST_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IBW_REFERRAL_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IBW_REFERRAL_CATEGORIES_TL T
    where T.REFERRAL_CATEGORY_ID = B.REFERRAL_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END IBW_REFERRAL_PVT;

/
