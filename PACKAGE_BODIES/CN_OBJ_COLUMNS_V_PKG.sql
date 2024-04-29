--------------------------------------------------------
--  DDL for Package Body CN_OBJ_COLUMNS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_COLUMNS_V_PKG" as
-- $Header: cnrecolb.pls 115.1 99/07/16 07:13:36 porting ship $


--
-- Public Procedures
--

  --
  -- Procedure Name
  --   insert_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --   16-FEB-94	Devesh Khatu		Modified
  --
  PROCEDURE Insert_Row(
	X_Rowid                OUT	rowid,
        X_Row_Id                        rowid		default NULL,
        X_Column_Id            		number,
        X_Last_Update_Date            	date		default NULL,
        X_Last_Updated_By               number 		default NULL,
        X_Creation_Date                 date 		default NULL,
        X_Created_By                    number 		default NULL,
        X_Last_Update_Login             number 		default NULL,
        X_Name                          varchar2,
        X_Description                   varchar2 	default NULL,
        X_Dependency_Map_Complete       varchar2,
        X_Next_Synchronization_Date     date		default NULL,
        X_Synchronization_Frequency     varchar2 	default NULL,
        X_Status                        varchar2,
        X_Repository_Id                 number,
        X_Table_Id                      number 		default NULL,
        X_Data_Length                   number 		default NULL,
        X_Data_Type                     varchar2 	default NULL,
        X_Nullable                      varchar2 	default NULL,
        X_Primary_Key                   varchar2 	default NULL,
        X_Position                      number 		default NULL,
        X_Dimension_Id                  number 		default NULL,
        X_Data_Scale                    number 		default NULL,
        X_Column_Type                   varchar2 	default NULL,
	X_user_column_name		varchar2,
        X_Seed_Column_Id                number 		default NULL) IS

     X_primary_key_id	number;

     CURSOR C IS SELECT rowid
	 	   FROM cn_obj_columns_v
                  WHERE column_id = X_primary_key_id;

     CURSOR C2 IS SELECT cn_objects_s.nextval
		    FROM sys.dual;

  BEGIN

    if (X_Column_Id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_primary_key_id;
      CLOSE C2;
    else
      X_primary_key_id := X_Column_Id;
    end if;

    INSERT INTO cn_obj_columns_v(
	row_id,
        column_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        name,
        description,
        dependency_map_complete,
        next_synchronization_date,
        synchronization_frequency,
        status,
        repository_id,
        table_id,
        data_length,
        data_type,
        nullable,
        primary_key,
        position,
        dimension_id,
        data_scale,
        column_type,
        user_column_name,
	seed_column_id,
        object_type)
    VALUES (
        X_Row_Id,
        X_primary_key_id,
        X_Last_Update_Date,
        X_Last_Updated_By,
        X_Creation_Date,
        X_Created_By,
        X_Last_Update_Login,
        X_Name,
        X_Description,
        X_Dependency_Map_Complete,
        X_Next_Synchronization_Date,
        X_Synchronization_Frequency,
        X_Status,
        X_Repository_Id,
        X_Table_Id,
        X_Data_Length,
        X_Data_Type,
        X_Nullable,
        X_Primary_Key,
        X_Position,
        X_Dimension_Id,
        X_Data_Scale,
        X_Column_Type,
	X_user_column_name,
	X_Seed_Column_Id,
        'COL');

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;

  END Insert_Row;



  --
  -- Procedure Name
  --   update_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE update_row(
	X_rowid                               varchar2,
        X_row_id                              rowid	default NULL,
        X_column_id                           number,
        X_name                                varchar2,
        X_description                         varchar2	default NULL,
        X_dependency_map_complete             varchar2,
        X_next_synchronization_date           date	default NULL,
        X_synchronization_frequency           varchar2	default NULL,
        X_status                              varchar2,
        X_repository_id                       number,
        X_table_id                            number	default NULL,
        X_data_length                         number	default NULL,
        X_data_type                           varchar2	default NULL,
        X_nullable                            varchar2	default NULL,
        X_primary_key                         varchar2	default NULL,
        X_position                            number	default NULL,
        X_dimension_id                        number	default NULL,
        X_data_scale                          number	default NULL,
        X_column_type                         varchar2	default NULL,
        X_seed_column_id                      number	default NULL) IS

  BEGIN
    UPDATE cn_obj_columns_v
    SET

      row_id                                    =    X_row_id,
      column_id                                 =    X_column_id,
      name                                      =    X_name,
      description                               =    X_description,
      dependency_map_complete                   =    X_dependency_map_complete,
      next_synchronization_date                 =    X_next_synchronization_date,
      synchronization_frequency                 =    X_synchronization_frequency,
      status                                    =    X_status,
      repository_id                             =    X_repository_id,
      table_id                                  =    X_table_id,
      data_length                               =    X_data_length,
      data_type                                 =    X_data_type,
      nullable                                  =    X_nullable,
      primary_key                               =    X_primary_key,
      position                                  =    X_position,
      dimension_id                              =    X_dimension_id,
      data_scale                                =    X_data_scale,
      column_type                               =    X_column_type,
      seed_column_id                            =    X_seed_column_id
    WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Update_Row;




  --
  -- Procedure Name
  --   delete_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE delete_row(
	X_Rowid					varchar2) IS

  BEGIN
    DELETE FROM cn_obj_columns_v
     WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Delete_Row;


END cn_obj_columns_v_pkg;

/
