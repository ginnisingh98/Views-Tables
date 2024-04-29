--------------------------------------------------------
--  DDL for Package Body GCS_SYSTEM_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_SYSTEM_TASKS_PKG" AS
/* $Header: gcssystaskb.pls 120.1 2005/10/30 05:19:07 appldev noship $ */



  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	                VARCHAR2,
				task_code			VARCHAR2,
                        	status_code	                VARCHAR2,
				creation_date			DATE,
				created_by			NUMBER,
				last_update_date		DATE,
				last_updated_by			NUMBER,
				last_update_login		NUMBER,
                        	object_version_number           NUMBER) IS
    CURSOR	task_row IS
    SELECT	row_id
    FROM	gcs_system_tasks st
    WHERE	st.task_code= insert_row.task_code;
  BEGIN
    IF task_code IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO gcs_system_tasks(task_code,
                                 status_code,
                                 creation_date,
                                 created_by,
                                 last_update_date,
                                 last_updated_by,
                                 last_update_login,
                                 object_version_number)
    SELECT	task_code,
                status_code,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                object_version_number
    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_system_tasks st
		 WHERE	st.task_code= insert_row.task_code);


    OPEN task_row;
    FETCH task_row INTO row_id;
    IF task_row%NOTFOUND THEN
      CLOSE task_row;
      raise no_data_found;
    END IF;
    CLOSE task_row;

  END Insert_Row;

  PROCEDURE Update_Row(		row_id	IN OUT NOCOPY	        VARCHAR2,
				task_code			VARCHAR2,
                        	status_code	                VARCHAR2,
				creation_date			DATE,
				created_by			NUMBER,
				last_update_date		DATE,
				last_updated_by			NUMBER,
				last_update_login		NUMBER,
                        	object_version_number           NUMBER) IS
  BEGIN
      UPDATE	gcs_system_tasks st
      SET		status_code			= update_row.status_code,
  			last_update_date		= update_row.last_update_date,
  			last_updated_by			= update_row.last_updated_by,
  			last_update_login		= update_row.last_update_login,
  			object_version_number		= update_row.object_version_number
      WHERE		st.task_code 			= update_row.task_code;

      IF SQL%NOTFOUND THEN
        raise no_data_found;
      END IF;

  END Update_Row;



  PROCEDURE Load_Row(		task_code			VARCHAR2,
				owner				VARCHAR2,
				last_update_date		VARCHAR2,
				custom_mode			VARCHAR2,
				status_code		        VARCHAR2,
                		object_version_number           NUMBER) IS

    row_id	VARCHAR2(64);
    f_luby	NUMBER;	-- Task owner in file
    f_ludate	DATE;	-- Task update date in file
    db_luby	NUMBER; -- Task owner in db
    db_ludate	DATE;	-- Task update date in db

    f_start_date DATE; -- start date in file
  BEGIN
    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	st.last_updated_by,
                st.last_update_date
      INTO	db_luby,
                db_ludate
      FROM	GCS_SYSTEM_TASKS st
      WHERE	st.task_code = Load_Row.task_code;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby,
                                   f_ludate,
                                   db_luby,
                                   db_ludate,
                                   custom_mode) THEN
        update_row(		row_id				=> row_id,
				task_code			=> TASK_CODE,
				status_code			=> STATUS_CODE,
				creation_date			=> f_ludate,
				created_by			=> f_luby,
				last_update_date		=> f_ludate,
				last_updated_by			=> f_luby,
				last_update_login		=> 0,
                        	object_version_number   	=> OBJECT_VERSION_NUMBER);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(		row_id				=> row_id,
				task_code			=> TASK_CODE,
				status_code			=> STATUS_CODE,
				creation_date			=> f_ludate,
				created_by			=> f_luby,
				last_update_date		=> f_ludate,
				last_updated_by			=> f_luby,
				last_update_login		=> 0,
				object_version_number		=> OBJECT_VERSION_NUMBER);
    END;

  END Load_Row;


END  GCS_SYSTEM_TASKS_PKG;

/
