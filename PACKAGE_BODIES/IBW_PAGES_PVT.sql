--------------------------------------------------------
--  DDL for Package Body IBW_PAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_PAGES_PVT" AS
/* $Header: IBWPAGB.pls 120.15 2006/02/23 23:48 vekancha noship $*/

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBW_PAGES_PVT
  --
  -- PURPOSE
  --   Private API for inserting and updating pages. Mainly used by offline engine
  --
  -- NOTES
  --   Offline engine uses this API to insert and update IBW_PAGES_B and IBW_PAGES_TL tables.

  -- HISTORY
  --   05/09/2005	VEKANCHA	Created

  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBW_PAGES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBWPAGB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    TABLE HANDLERS
--      1. insert_row
--      2. update_row
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- insert row into pages table
-- ****************************************************************************

PROCEDURE insert_row (
	page_id  OUT NOCOPY NUMBER,
	x_page_name IN VARCHAR2,
	x_description IN VARCHAR2,
	x_page_code IN VARCHAR2,
	x_app_context IN VARCHAR2,
	x_bus_context IN VARCHAR2,
	x_reference IN VARCHAR2,
	x_page_matching_criteria IN VARCHAR2,
	x_page_matching_value IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
)

IS

	x_page_id		NUMBER;
	page_code		VARCHAR2(30);
	tmp_code		NUMBER;
	page_status		VARCHAR2(30);
	site_area_id	NUMBER;
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

	CURSOR c IS SELECT ibw_pages_b_s1.nextval FROM dual;

	CURSOR c1 IS SELECT page_id FROM ibw_pages_b
	    WHERE page_id = x_page_id;

	CURSOR c2 IS SELECT ibw_pages_b_s2.nextval FROM dual;

BEGIN
	page_status := 'Y';
	obj_ver_number := 1;
	site_area_id := -1;
	OPEN c;
	FETCH c INTO x_page_id;
	CLOSE c;

	OPEN c2;
	FETCH c2 into tmp_code;
	CLOSE c2;

	IF x_page_code = FND_API.G_MISS_CHAR THEN
		page_code := 'IBW_PAGE_' || tmp_code;
	ELSE
		page_code := x_page_code;
	END IF;

	FND_PROFILE.GET('USER_ID', created_by);

	creation_date := SYSDATE;

	last_updated_by := created_by;

	last_update_date := SYSDATE;

	FND_PROFILE.GET('LOGIN_ID', last_update_login);

	FND_PROFILE.GET('CONC_PROGRAM_ID', program_id);

	FND_PROFILE.GET('CONC_LOGIN_ID', program_login_id);

	FND_PROFILE.GET('CONC_PROGRAM_APPLICATION_ID', program_app_id);

	FND_PROFILE.GET('CONC_REQUEST_ID', request_id);

	INSERT INTO ibw_pages_b (page_id, page_code, page_status, application_context, business_context, reference,site_area_id,
						page_matching_criteria, page_matching_value, created_by, creation_date,
						last_updated_by, last_update_date, last_update_login, object_version_number,
						program_id, program_login_id, program_application_id, request_id)
			VALUES (x_page_id, page_code, page_status, x_app_context, x_bus_context, x_reference, site_area_id,
						x_page_matching_criteria, x_page_matching_value, created_by, creation_date,
						last_updated_by, last_update_date, last_update_login, obj_ver_number,
						program_id, program_login_id, program_app_id, request_id);

	INSERT INTO ibw_pages_tl(page_id, language, source_lang, page_name, description, created_by, creation_date,
						last_updated_by, last_update_date, last_update_login, object_version_number,
						program_id, program_login_id, program_application_id, request_id)
			SELECT M.page_id, l.language_code, b.language_code,  x_page_name, x_description, M.created_by, M.creation_date,
					M.last_updated_by, M.last_update_date, M.last_update_login, M.object_version_number,
					M.program_id, M.program_login_id, M.program_application_id, M.request_id
			FROM ibw_pages_b M, fnd_languages l, fnd_languages b
			WHERE l.installed_flag IN ('I','B') AND b.installed_flag='B' AND M.page_id=x_page_id;

	OPEN c1;
	FETCH c1 INTO page_id;
	IF (c1%NOTFOUND) THEN
		CLOSE c1;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE c1;

--	COMMIT;

END insert_row;

-- ****************************************************************************
-- update row
-- ****************************************************************************

PROCEDURE update_row (
	x_page_id IN NUMBER,
	x_reference IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
)
IS

	x_last_updated_by	NUMBER;
	x_last_update_date	DATE;
	x_last_update_login	NUMBER;
	x_obj_ver_number	NUMBER;
	x_program_id		NUMBER;
	x_program_login_id	NUMBER;
	x_program_app_id	NUMBER;
	x_request_id		NUMBER;

BEGIN
	x_obj_ver_number := 1;

	FND_PROFILE.GET('USER_ID', x_last_updated_by);

	x_last_update_date := SYSDATE;

	FND_PROFILE.GET('LOGIN_ID', x_last_update_login);

	FND_PROFILE.GET('CONC_PROGRAM_ID', x_program_id);

	FND_PROFILE.GET('CONC_LOGIN_ID', x_program_login_id);

	FND_PROFILE.GET('CONC_PROGRAM_APPLICATION_ID', x_program_app_id);

	FND_PROFILE.GET('CONC_REQUEST_ID', x_request_id);

	UPDATE ibw_pages_b
		SET reference=x_reference, last_updated_by=x_last_updated_by, last_update_date=x_last_update_date,
			last_update_login=x_last_update_login, object_version_number=object_version_number+1,
			program_id=x_program_id, program_login_id=x_program_login_id, program_application_id=x_program_app_id,
			request_id=x_request_id
		WHERE page_id=x_page_id;

	if(sql%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;

--	COMMIT;

END update_row;


END IBW_PAGES_PVT;

/
