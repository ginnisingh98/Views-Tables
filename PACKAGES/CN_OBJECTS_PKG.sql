--------------------------------------------------------
--  DDL for Package CN_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJECTS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnreobjs.pls 120.3 2005/09/20 07:12:43 hakhter noship $
  --+
  -- Procedure Name
  --   insert_row
  -- Purpose
  --   Insert a new record in the table with values supplied by the parameters.
  -- History
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
	X_object_value                cn_objects.object_value%TYPE,
    X_org_id                cn_objects.org_id%TYPE);

  --+
  -- Procedure Name
  --   select_row
  -- Purpose
  --   Select a row from the table, given the primary key
  -- History
  --+

  PROCEDURE select_row(
	recinfo 	IN OUT NOCOPY 	cn_objects%ROWTYPE);

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
        x_OWNER in varchar2
    );

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
        x_OWNER in varchar2);

END cn_objects_pkg;
 

/
