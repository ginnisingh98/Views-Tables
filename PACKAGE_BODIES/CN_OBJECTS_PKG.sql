--------------------------------------------------------
--  DDL for Package Body CN_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJECTS_PKG" AS
-- $Header: cnreobjb.pls 120.6 2005/09/26 01:51:32 hakhter noship $
--+
-- Public Functions
--+

  PROCEDURE insert_row (
	X_rowid		IN OUT NOCOPY 	ROWID,
	X_object_id			cn_objects.object_id%TYPE,
	X_dependency_map_complete 	cn_objects.dependency_map_complete%TYPE,
	X_name				cn_objects.name%TYPE,
	X_description			cn_objects.description%TYPE,
	X_object_type			cn_objects.object_type%TYPE,
	X_repository_id			cn_objects.repository_id%TYPE,
	X_next_synchronization_date 	cn_objects.next_synchronization_date%TYPE,
	X_synchronization_frequency 	cn_objects.synchronization_frequency%TYPE,
	X_object_status			cn_objects.object_status%TYPE,
	X_object_value 			cn_objects.object_value%TYPE,
    X_org_id                cn_objects.org_id%TYPE) IS

  BEGIN
    INSERT INTO cn_objects (
	object_id,
	dependency_map_complete,
	name,
	description,
	object_type,
	repository_id,
	next_synchronization_date,
	synchronization_frequency,
	object_status,
	object_value,
    org_id,
	object_version_number)
    VALUES (
	X_object_id,
	X_dependency_map_complete,
	X_name,
	X_description,
	X_object_type,
	X_repository_id,
	X_next_synchronization_date,
	X_synchronization_frequency,
	X_object_status,
	X_object_value,
    X_org_id,
	1);

    SELECT ROWID
      INTO X_rowid
      FROM cn_objects
     WHERE object_id = X_object_id
     AND   org_id = X_org_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	recinfo IN OUT NOCOPY cn_objects%ROWTYPE) IS

  BEGIN

    -- select row based on object_id (primary key)
    IF (recinfo.object_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_objects co
       WHERE co.object_id = recinfo.object_id;

    END IF;

  END select_row;

    PROCEDURE LOAD_SEED_ROW (
	x_UPLOAD_MODE in varchar2,
        x_OBJECT_ID in varchar2,
        x_DEPENDENCY_MAP_COMPLETE in varchar2,
        x_NAME in varchar2,
        x_OBJECT_TYPE in varchar2,
        x_REPOSITORY_ID in varchar2,
        x_OBJECT_STATUS in varchar2,
        x_LAST_UPDATE_DATE in varchar2,
        x_LAST_UPDATED_BY in varchar2,
        x_CREATION_DATE in varchar2,
        x_CREATED_BY in varchar2,
        x_LAST_UPDATE_LOGIN in varchar2,
        x_DESCRIPTION in varchar2,
        x_NEXT_SYNCHRONIZATION_DATE in varchar2,
        x_SYNCHRONIZATION_FREQUENCY in varchar2,
        x_DATA_LENGTH in varchar2,
        x_DATA_TYPE in varchar2,
        x_NULLABLE in varchar2,
        x_PRIMARY_KEY in varchar2,
        x_POSITION in varchar2,
        x_DIMENSION_ID in varchar2,
        x_DATA_SCALE in varchar2,
        x_COLUMN_TYPE in varchar2,
        x_TABLE_ID in varchar2,
        x_UNIQUE_FLAG in varchar2,
        x_PACKAGE_TYPE in varchar2,
        x_PACKAGE_SPECIFICATION_ID in varchar2,
        x_PARAMETER_LIST in varchar2,
        x_RETURN_TYPE in varchar2,
        x_PROCEDURE_TYPE in varchar2,
        x_PACKAGE_ID in varchar2,
        x_START_VALUE in varchar2,
        x_INCREMENT_VALUE in varchar2,
        x_STATEMENT_TEXT in varchar2,
        x_ALIAS in varchar2,
        x_TABLE_LEVEL in varchar2,
        x_TABLE_TYPE in varchar2,
        x_WHEN_CLAUSE in varchar2,
        x_TRIGGERING_EVENT in varchar2,
        x_EVENT_ID in varchar2,
        x_PUBLIC_FLAG in varchar2,
        x_CHILD_FLAG in varchar2,
        x_FOR_EACH_ROW in varchar2,
        x_TRIGGER_TYPE in varchar2,
        x_USER_COLUMN_NAME in varchar2,
        x_SEED_OBJECT_ID in varchar2,
        x_PRIMARY_KEY_COLUMN_ID in varchar2,
        x_USER_NAME_COLUMN_ID in varchar2,
        x_CONNECT_TO_USERNAME in varchar2,
        x_CONNECT_TO_PASSWORD in varchar2,
        x_CONNECT_TO_HOST in varchar2,
        x_USER_NAME in varchar2,
        x_SCHEMA in varchar2,
        x_FOREIGN_KEY in varchar2,
        x_CLASSIFICATION_COLUMN in varchar2,
        x_ORG_ID in varchar2,
        x_CALC_FORMULA_FLAG in varchar2,
        x_CALC_ELIGIBLE_FLAG in varchar2,
        x_COLUMN_DATATYPE in varchar2,
        x_VALUE_SET_ID in varchar2,
        x_OBJECT_VALUE in varchar2,
        x_CUSTOM_CALL in varchar2,
        x_SECURITY_GROUP_ID in varchar2,
        x_APPLICATION_SHORT_NAME in varchar2,
        x_OWNER in varchar2)
    IS
    BEGIN
     if (x_upload_mode = 'NLS') then
       --CN_OBJECTS_PKG.TRANSLATE_ROW(x_owner);
       -- As this ldt is not required to loaded translated data, you could leave it blank.
	    null;
     else
       	CN_OBJECTS_PKG.LOAD_ROW(
	                x_OBJECT_ID,
                	x_DEPENDENCY_MAP_COMPLETE,
                	x_NAME,
                	x_OBJECT_TYPE,
                	x_REPOSITORY_ID,
                	x_OBJECT_STATUS,
                	x_LAST_UPDATE_DATE,
                	x_LAST_UPDATED_BY,
                	x_CREATION_DATE,
                	x_CREATED_BY,
                	x_LAST_UPDATE_LOGIN,
                	x_DESCRIPTION,
                	x_NEXT_SYNCHRONIZATION_DATE,
                	x_SYNCHRONIZATION_FREQUENCY,
                	x_DATA_LENGTH,
                	x_DATA_TYPE,
                	x_NULLABLE,
                	x_PRIMARY_KEY,
                	x_POSITION,
                	x_DIMENSION_ID,
                	x_DATA_SCALE,
                	x_COLUMN_TYPE,
                	x_TABLE_ID,
                	x_UNIQUE_FLAG,
                	x_PACKAGE_TYPE,
                	x_PACKAGE_SPECIFICATION_ID,
                	x_PARAMETER_LIST,
                	x_RETURN_TYPE,
                	x_PROCEDURE_TYPE,
                	x_PACKAGE_ID,
                	x_START_VALUE,
                	x_INCREMENT_VALUE,
                	x_STATEMENT_TEXT,
                	x_ALIAS,
                	x_TABLE_LEVEL,
                	x_TABLE_TYPE,
                	x_WHEN_CLAUSE,
                	x_TRIGGERING_EVENT,
                	x_EVENT_ID,
                	x_PUBLIC_FLAG,
                	x_CHILD_FLAG,
                	x_FOR_EACH_ROW,
                	x_TRIGGER_TYPE,
                	x_USER_COLUMN_NAME,
                	x_SEED_OBJECT_ID,
                	x_PRIMARY_KEY_COLUMN_ID,
                	x_USER_NAME_COLUMN_ID,
                	x_CONNECT_TO_USERNAME,
                	x_CONNECT_TO_PASSWORD,
                	x_CONNECT_TO_HOST,
                	x_USER_NAME,
                	x_SCHEMA,
                	x_FOREIGN_KEY,
                	x_CLASSIFICATION_COLUMN,
                	x_ORG_ID,
                	x_CALC_FORMULA_FLAG,
                	x_CALC_ELIGIBLE_FLAG,
                	x_COLUMN_DATATYPE,
                	x_VALUE_SET_ID,
                	x_OBJECT_VALUE,
                	x_CUSTOM_CALL,
                	x_SECURITY_GROUP_ID,
			x_APPLICATION_SHORT_NAME,
			x_OWNER

		);
       	    null;
     end if;
    END LOAD_SEED_ROW;


PROCEDURE LOAD_ROW
    (   x_OBJECT_ID in varchar2,
        x_DEPENDENCY_MAP_COMPLETE in varchar2,
        x_NAME in varchar2,
        x_OBJECT_TYPE in varchar2,
        x_REPOSITORY_ID in varchar2,
        x_OBJECT_STATUS in varchar2,
        x_LAST_UPDATE_DATE in varchar2,
        x_LAST_UPDATED_BY in varchar2,
        x_CREATION_DATE in varchar2,
        x_CREATED_BY in varchar2,
        x_LAST_UPDATE_LOGIN in varchar2,
        x_DESCRIPTION in varchar2,
        x_NEXT_SYNCHRONIZATION_DATE in varchar2,
        x_SYNCHRONIZATION_FREQUENCY in varchar2,
        x_DATA_LENGTH in varchar2,
        x_DATA_TYPE in varchar2,
        x_NULLABLE in varchar2,
        x_PRIMARY_KEY in varchar2,
        x_POSITION in varchar2,
        x_DIMENSION_ID in varchar2,
        x_DATA_SCALE in varchar2,
        x_COLUMN_TYPE in varchar2,
        x_TABLE_ID in varchar2,
        x_UNIQUE_FLAG in varchar2,
        x_PACKAGE_TYPE in varchar2,
        x_PACKAGE_SPECIFICATION_ID in varchar2,
        x_PARAMETER_LIST in varchar2,
        x_RETURN_TYPE in varchar2,
        x_PROCEDURE_TYPE in varchar2,
        x_PACKAGE_ID in varchar2,
        x_START_VALUE in varchar2,
        x_INCREMENT_VALUE in varchar2,
        x_STATEMENT_TEXT in varchar2,
        x_ALIAS in varchar2,
        x_TABLE_LEVEL in varchar2,
        x_TABLE_TYPE in varchar2,
        x_WHEN_CLAUSE in varchar2,
        x_TRIGGERING_EVENT in varchar2,
        x_EVENT_ID in varchar2,
        x_PUBLIC_FLAG in varchar2,
        x_CHILD_FLAG in varchar2,
        x_FOR_EACH_ROW in varchar2,
        x_TRIGGER_TYPE in varchar2,
        x_USER_COLUMN_NAME in varchar2,
        x_SEED_OBJECT_ID in varchar2,
        x_PRIMARY_KEY_COLUMN_ID in varchar2,
        x_USER_NAME_COLUMN_ID in varchar2,
        x_CONNECT_TO_USERNAME in varchar2,
        x_CONNECT_TO_PASSWORD in varchar2,
        x_CONNECT_TO_HOST in varchar2,
        x_USER_NAME in varchar2,
        x_SCHEMA in varchar2,
        x_FOREIGN_KEY in varchar2,
        x_CLASSIFICATION_COLUMN in varchar2,
        x_ORG_ID in varchar2,
        x_CALC_FORMULA_FLAG in varchar2,
        x_CALC_ELIGIBLE_FLAG in varchar2,
        x_COLUMN_DATATYPE in varchar2,
        x_VALUE_SET_ID in varchar2,
        x_OBJECT_VALUE in varchar2,
        x_CUSTOM_CALL in varchar2,
        x_SECURITY_GROUP_ID in varchar2,
        x_APPLICATION_SHORT_NAME in varchar2,
        x_OWNER in varchar2)
IS
	USER_ID NUMBER;
BEGIN
	NULL;

	-- Proceed only when the object_id is not null
	if (x_OBJECT_ID is NOT NULL) then

		-- Check whether SEED Data or Custom Data you are uploading
		IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      			USER_ID := 1;
    		ELSE
      			USER_ID := 0;
   		END IF;

		update cn_objects_all set
			DEPENDENCY_MAP_COMPLETE = x_DEPENDENCY_MAP_COMPLETE,
			NAME = x_NAME,
			OBJECT_TYPE = x_OBJECT_TYPE,
			REPOSITORY_ID = to_number(x_REPOSITORY_ID),
			OBJECT_STATUS = x_OBJECT_STATUS,
			LAST_UPDATE_DATE = SYSDATE,
			LAST_UPDATED_BY = USER_ID,
			CREATION_DATE = to_date(x_CREATION_DATE,'DD-MM-YYYY'),
			CREATED_BY = to_number(x_CREATED_BY),
			LAST_UPDATE_LOGIN = 0,
			DESCRIPTION = x_DESCRIPTION,
			NEXT_SYNCHRONIZATION_DATE = to_date(x_NEXT_SYNCHRONIZATION_DATE,'DD-MM-YYYY'),
			SYNCHRONIZATION_FREQUENCY = x_SYNCHRONIZATION_FREQUENCY,
			DATA_LENGTH = to_number(x_DATA_LENGTH),
			DATA_TYPE = x_DATA_TYPE,
			NULLABLE = x_NULLABLE,
			PRIMARY_KEY = x_PRIMARY_KEY,
			POSITION = to_number(x_POSITION),
			DIMENSION_ID = to_number(x_DIMENSION_ID),
			DATA_SCALE = to_number(x_DATA_SCALE),
			COLUMN_TYPE = x_COLUMN_TYPE,
			TABLE_ID = to_number(x_TABLE_ID),
			UNIQUE_FLAG = x_UNIQUE_FLAG,
			PACKAGE_TYPE = x_PACKAGE_TYPE,
			PACKAGE_SPECIFICATION_ID = x_PACKAGE_SPECIFICATION_ID,
			PARAMETER_LIST = x_PARAMETER_LIST,
			RETURN_TYPE = x_RETURN_TYPE,
			PROCEDURE_TYPE = x_PROCEDURE_TYPE,
			PACKAGE_ID = to_number(x_PACKAGE_ID),
			START_VALUE = to_number(x_START_VALUE),
			INCREMENT_VALUE = to_number(x_INCREMENT_VALUE),
			STATEMENT_TEXT = x_STATEMENT_TEXT,
			ALIAS = x_ALIAS,
			TABLE_LEVEL = x_TABLE_LEVEL,
			TABLE_TYPE = x_TABLE_TYPE,
			WHEN_CLAUSE = x_WHEN_CLAUSE,
			TRIGGERING_EVENT = x_TRIGGERING_EVENT,
			EVENT_ID = to_number(x_EVENT_ID),
			PUBLIC_FLAG = x_PUBLIC_FLAG,
			CHILD_FLAG = x_CHILD_FLAG,
			FOR_EACH_ROW = x_FOR_EACH_ROW,
			TRIGGER_TYPE = x_TRIGGER_TYPE,
			USER_COLUMN_NAME = x_USER_COLUMN_NAME,
			SEED_OBJECT_ID = to_number(x_SEED_OBJECT_ID),
			PRIMARY_KEY_COLUMN_ID = to_number(x_PRIMARY_KEY_COLUMN_ID),
			USER_NAME_COLUMN_ID = to_number(x_USER_NAME_COLUMN_ID),
			CONNECT_TO_USERNAME = x_CONNECT_TO_USERNAME,
			CONNECT_TO_PASSWORD = x_CONNECT_TO_PASSWORD,
			CONNECT_TO_HOST = x_CONNECT_TO_HOST,
			USER_NAME = x_USER_NAME,
			SCHEMA = x_SCHEMA,
			FOREIGN_KEY = x_FOREIGN_KEY,
			CLASSIFICATION_COLUMN = x_CLASSIFICATION_COLUMN,
			ORG_ID = to_number(x_ORG_ID),
			CALC_FORMULA_FLAG = x_CALC_FORMULA_FLAG,
			CALC_ELIGIBLE_FLAG = x_CALC_ELIGIBLE_FLAG,
			COLUMN_DATATYPE = x_COLUMN_DATATYPE,
			VALUE_SET_ID = to_number(x_VALUE_SET_ID),
			OBJECT_VALUE = x_OBJECT_VALUE,
			CUSTOM_CALL = x_CUSTOM_CALL,
			SECURITY_GROUP_ID = to_number(x_SECURITY_GROUP_ID)
		where
			OBJECT_ID = X_OBJECT_ID
                        and ORG_ID = X_ORG_ID;

		IF (SQL%NOTFOUND)  THEN
     			-- Insert new record to CN_OBJECTS_TABLE table
			insert into CN_OBJECTS_ALL
			(
			OBJECT_ID,
			DEPENDENCY_MAP_COMPLETE,
			NAME,
			OBJECT_TYPE,
			REPOSITORY_ID,
			OBJECT_STATUS,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			DESCRIPTION,
			NEXT_SYNCHRONIZATION_DATE,
			SYNCHRONIZATION_FREQUENCY,
			DATA_LENGTH,
			DATA_TYPE,
			NULLABLE,
			PRIMARY_KEY,
			POSITION,
			DIMENSION_ID,
			DATA_SCALE,
			COLUMN_TYPE,
			TABLE_ID,
			UNIQUE_FLAG,
			PACKAGE_TYPE,
			PACKAGE_SPECIFICATION_ID,
			PARAMETER_LIST,
			RETURN_TYPE,
			PROCEDURE_TYPE,
			PACKAGE_ID,
			START_VALUE,
			INCREMENT_VALUE,
			STATEMENT_TEXT,
			ALIAS,
			TABLE_LEVEL,
			TABLE_TYPE,
			WHEN_CLAUSE,
			TRIGGERING_EVENT,
			EVENT_ID,
			PUBLIC_FLAG,
			CHILD_FLAG,
			FOR_EACH_ROW,
			TRIGGER_TYPE,
			USER_COLUMN_NAME,
			SEED_OBJECT_ID,
			PRIMARY_KEY_COLUMN_ID,
			USER_NAME_COLUMN_ID,
			CONNECT_TO_USERNAME,
			CONNECT_TO_PASSWORD,
			CONNECT_TO_HOST,
			USER_NAME,
			SCHEMA,
			FOREIGN_KEY,
			CLASSIFICATION_COLUMN,
			ORG_ID,
			CALC_FORMULA_FLAG,
			CALC_ELIGIBLE_FLAG,
			COLUMN_DATATYPE,
			VALUE_SET_ID,
			OBJECT_VALUE,
			CUSTOM_CALL,
			SECURITY_GROUP_ID,
			OBJECT_VERSION_NUMBER)

			values
			(
			to_number(x_OBJECT_ID),
                	x_DEPENDENCY_MAP_COMPLETE,
                	x_NAME,
                	x_OBJECT_TYPE,
                	to_number(x_REPOSITORY_ID),
                	x_OBJECT_STATUS,
                	SYSDATE,
                	USER_ID,
                	SYSDATE,
                	USER_ID,
                	0,
                	x_DESCRIPTION,
                	to_date(x_NEXT_SYNCHRONIZATION_DATE,'DD-MM-YYYY'),
                	x_SYNCHRONIZATION_FREQUENCY,
                	to_number(x_DATA_LENGTH),
                	x_DATA_TYPE,
                	x_NULLABLE,
                	x_PRIMARY_KEY,
                	to_number(x_POSITION),
                	to_number(x_DIMENSION_ID),
                	to_number(x_DATA_SCALE),
                	x_COLUMN_TYPE,
                	to_number(x_TABLE_ID),
                	x_UNIQUE_FLAG,
                	x_PACKAGE_TYPE,
                	to_number(x_PACKAGE_SPECIFICATION_ID),
                	x_PARAMETER_LIST,
                	x_RETURN_TYPE,
                	x_PROCEDURE_TYPE,
                	to_number(x_PACKAGE_ID),
                	to_number(x_START_VALUE),
                	to_number(x_INCREMENT_VALUE),
                	x_STATEMENT_TEXT,
                	x_ALIAS,
                	x_TABLE_LEVEL,
                	x_TABLE_TYPE,
                	x_WHEN_CLAUSE,
                	x_TRIGGERING_EVENT,
                	to_number(x_EVENT_ID),
                	x_PUBLIC_FLAG,
                	x_CHILD_FLAG,
                	x_FOR_EACH_ROW,
                	x_TRIGGER_TYPE,
                	x_USER_COLUMN_NAME,
                	to_number(x_SEED_OBJECT_ID),
                	to_number(x_PRIMARY_KEY_COLUMN_ID),
                	to_number(x_USER_NAME_COLUMN_ID),
                	x_CONNECT_TO_USERNAME,
                	x_CONNECT_TO_PASSWORD,
                	x_CONNECT_TO_HOST,
                	x_USER_NAME,
                	x_SCHEMA,
                	x_FOREIGN_KEY,
                	x_CLASSIFICATION_COLUMN,
                	to_number(x_ORG_ID),
                	x_CALC_FORMULA_FLAG,
                	x_CALC_ELIGIBLE_FLAG,
                	x_COLUMN_DATATYPE,
                	to_number(x_VALUE_SET_ID),
                	x_OBJECT_VALUE,
                	x_CUSTOM_CALL,
                	to_number(x_SECURITY_GROUP_ID),
			1
			);

		END IF;
	end if;

END LOAD_ROW;



END cn_objects_pkg;

/
