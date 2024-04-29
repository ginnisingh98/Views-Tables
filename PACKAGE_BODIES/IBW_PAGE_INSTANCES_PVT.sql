--------------------------------------------------------
--  DDL for Package Body IBW_PAGE_INSTANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_PAGE_INSTANCES_PVT" AS
/* $Header: IBWPGIB.pls 120.4 2005/11/09 03:44 vekancha noship $*/


  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBW_PAGES_PVT
  --
  -- PURPOSE
  --   Private API for inserting records into page instances table. Mainly used by offline engine
  --
  -- NOTES
  --   Offline engine uses this API to insert into IBW_PAGE_INSTANCES table.

  -- HISTORY
  --   05/10/2005	VEKANCHA	Created

  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBW_PAGE_INSTANCES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBWPGIB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    TABLE HANDLERS
--      1. insert_row
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- insert row into page instances table
-- ****************************************************************************

PROCEDURE insert_row (
	page_id  OUT NOCOPY NUMBER,
	x_page_id IN NUMBER,
	x_bus_context IN VARCHAR2,
	x_bus_context_value IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
)

IS

	x_page_inst_id	NUMBER;
	created_by		NUMBER;
	creation_date	DATE;
	last_updated_by	NUMBER;
	last_update_date	DATE;
	last_update_login	NUMBER;
	obj_ver_number	NUMBER := 1;
	program_id		NUMBER;
	program_login_id	NUMBER;
	program_app_id	NUMBER;
	request_id		NUMBER;

	CURSOR c IS SELECT ibw_page_instances_s1.nextval FROM dual;

	CURSOR c1 IS SELECT page_instance_id  FROM ibw_page_instances
	    WHERE page_instance_id = x_page_inst_id;


BEGIN

	OPEN c;
	FETCH c INTO x_page_inst_id;
	CLOSE c;


	FND_PROFILE.GET('USER_ID', created_by);

	creation_date := SYSDATE;

	last_updated_by := created_by;

	last_update_date := SYSDATE;

	FND_PROFILE.GET('LOGIN_ID', last_update_login);

	FND_PROFILE.GET('CONC_PROGRAM_ID', program_id);

	FND_PROFILE.GET('CONC_LOGIN_ID', program_login_id);

	FND_PROFILE.GET('CONC_PROGRAM_APPLICATION_ID', program_app_id);

	FND_PROFILE.GET('CONC_REQUEST_ID', request_id);

	INSERT INTO ibw_page_instances (page_instance_id, page_id, business_context, business_context_value, created_by, creation_date,
							last_updated_by, last_update_date, last_update_login, object_version_number,
							program_id, program_login_id, program_application_id, request_id)
			VALUES (x_page_inst_id, x_page_id, x_bus_context, x_bus_context_value, created_by, creation_date,
						last_updated_by, last_update_date, last_update_login, obj_ver_number,
						program_id, program_login_id, program_app_id, request_id);

	OPEN c1;
	FETCH c1 INTO page_id;
	IF (c1%NOTFOUND) THEN
		CLOSE c1;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE c1;

--	COMMIT;

END insert_row;

END IBW_PAGE_INSTANCES_PVT;

/
