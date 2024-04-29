--------------------------------------------------------
--  DDL for Package CN_OBJ_COLUMNS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_COLUMNS_V_PKG" AUTHID CURRENT_USER as
-- $Header: cnrecols.pls 115.1 99/07/16 07:13:39 porting ship $


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
        X_row_id                        rowid		default NULL,
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
        X_Seed_Column_Id                number 		default NULL);



  --
  -- Procedure Name
  --   update_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Update_Row(
	X_rowid                               varchar2,
        X_row_id                              rowid	default NULL,
        X_column_id                           number,
        X_name                                varchar2,
        X_description                         varchar2	default NULL,
        x_dependency_map_complete             varchar2,
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
        X_seed_column_id                      number    default NULL);


  --
  -- Procedure Name
  --   delete_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Delete_Row(
	X_Rowid					varchar2);


END cn_obj_columns_v_pkg;

 

/
