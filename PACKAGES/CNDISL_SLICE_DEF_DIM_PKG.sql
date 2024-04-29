--------------------------------------------------------
--  DDL for Package CNDISL_SLICE_DEF_DIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNDISL_SLICE_DEF_DIM_PKG" AUTHID CURRENT_USER as
-- $Header: cndislbs.pls 115.1 99/07/16 07:06:31 porting shi $



PROCEDURE Default_Rows (X_column_map_id		IN OUT	number,
			X_destination_column_id IN OUT number,
			X_tmp_column_map_id	IN OUT	number,
			X_tmp_dest_column_id 	IN OUT number,
			X_rup_column_map_id	IN OUT	number,
			X_rup_dest_column_id 	IN OUT number);

PROCEDURE Populate_Fields (X_source_column_id	IN 	number,
			   X_column_name	IN OUT	varchar2,
			   X_dimension_name	IN OUT	varchar2,
			   X_dest_column_id	IN	number,
			   X_dest_column_name	IN OUT	varchar2);

PROCEDURE Insert_Row (	X_table_map_id		number,
			X_column_map_id		number,
			X_source_column_id	number,
			X_group_by_flag		varchar,
			X_destination_column_id	number,
			X_column_name		varchar,
			X_repository_id		number,
			X_table_id		number,
			X_tmp_table_map_id	number,
			X_tmp_table_id		number,
			X_tmp_column_map_id	number,
			X_tmp_dest_column_id 	number,
			X_rup_table_map_id	number,
			X_rup_table_id		number,
			X_rup_column_map_id	number,
			X_rup_dest_column_id 	number);


PROCEDURE Delete_Row ( 	X_column_map_id		number,
		       	X_destination_column_id	number,
			X_tmp_column_map_id	number,
		       	X_tmp_dest_column_id	number,
			X_rup_column_map_id	number,
		       	X_rup_dest_column_id	number);

END CNDISL_Slice_Def_Dim_PKG;

 

/
