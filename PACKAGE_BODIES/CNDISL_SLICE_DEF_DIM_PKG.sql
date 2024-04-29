--------------------------------------------------------
--  DDL for Package Body CNDISL_SLICE_DEF_DIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNDISL_SLICE_DEF_DIM_PKG" as
-- $Header: cndislbb.pls 115.1 99/07/16 07:06:28 porting ship $


-- -----------------------------------------------------------

PROCEDURE Default_Rows (X_column_map_id		IN OUT	number,
			X_destination_column_id IN OUT number,
			X_tmp_column_map_id	IN OUT	number,
			X_tmp_dest_column_id 	IN OUT number,
			X_rup_column_map_id	IN OUT	number,
			X_rup_dest_column_id 	IN OUT number) IS
BEGIN

  SELECT cn_column_maps_s.nextval, cn_objects_s.nextval
	INTO X_column_map_id, X_destination_column_id
	FROM dual;

  SELECT cn_column_maps_s.nextval, cn_objects_s.nextval
	INTO X_tmp_column_map_id, X_tmp_dest_column_id
	FROM dual;

  SELECT cn_column_maps_s.nextval, cn_objects_s.nextval
	INTO X_rup_column_map_id, X_rup_dest_column_id
	FROM dual;

END Default_Rows;

-- -----------------------------------------------------------

PROCEDURE Populate_Fields (X_source_column_id	IN 	number,
			   X_column_name	IN OUT	varchar2,
			   X_dimension_name	IN OUT	varchar2,
			   X_dest_column_id	IN	number,
			   X_dest_column_name	IN OUT	varchar2) IS
BEGIN

  SELECT col.name, dim.name
	INTO X_column_name, X_dimension_name
	FROM cn_obj_columns_v col,
	     cn_dimensions    dim
	WHERE col.column_id = X_source_column_id
	  AND col.dimension_id = dim.dimension_id (+);

  SELECT name
	INTO X_dest_column_name
	FROM cn_obj_columns_v
	WHERE column_id = X_dest_column_id;

END Populate_Fields;

-- -----------------------------------------------------------

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
			X_rup_dest_column_id 	number) IS

BEGIN

  INSERT INTO cn_column_maps (table_map_id, column_map_id,
				source_column_id, group_by_flag,
				destination_column_id)
	VALUES (X_table_map_id, X_column_map_id,
				X_source_column_id, X_group_by_flag,
				X_destination_column_id);

  INSERT INTO cn_obj_columns_v (column_id, name, dependency_map_complete,
		status, repository_id, table_id, data_length,
		data_type, nullable, primary_key, position,
		dimension_id, data_scale, column_type, object_type)
	(SELECT X_destination_column_id, X_column_name, 'N',
		'V', X_repository_id, X_table_id, data_length,
		data_type, nullable, 'N', position,
		dimension_id, data_scale, column_type, 'COL'
	FROM cn_obj_columns_v WHERE column_id = X_source_column_id);


  -- Temp. slice table definition ----------

  INSERT INTO cn_column_maps (table_map_id, column_map_id,
				source_column_id, group_by_flag,
				destination_column_id)
	VALUES (X_tmp_table_map_id, X_tmp_column_map_id,
				X_source_column_id, X_group_by_flag,
				X_tmp_dest_column_id);

  INSERT INTO cn_obj_columns_v (column_id, name, dependency_map_complete,
		status, repository_id, table_id, data_length,
		data_type, nullable, primary_key, position,
		dimension_id, data_scale, column_type, object_type)
	(SELECT X_tmp_dest_column_id, X_column_name, 'N',
		'V', X_repository_id, X_tmp_table_id, data_length,
		data_type, nullable, 'N', position,
		dimension_id, data_scale, column_type, 'COL'
	FROM cn_obj_columns_v WHERE column_id = X_source_column_id);

  -- Temp. Rollup table definition ----------

  INSERT INTO cn_column_maps (table_map_id, column_map_id,
				source_column_id, group_by_flag,
				destination_column_id)
	VALUES (X_rup_table_map_id, X_rup_column_map_id,
				X_source_column_id, X_group_by_flag,
				X_rup_dest_column_id);

  INSERT INTO cn_obj_columns_v (column_id, name, dependency_map_complete,
		status, repository_id, table_id, data_length,
		data_type, nullable, primary_key, position,
		dimension_id, data_scale, column_type, object_type)
	(SELECT X_rup_dest_column_id, X_column_name, 'N',
		'V', X_repository_id, X_rup_table_id, data_length,
		data_type, nullable, 'N', position,
		dimension_id, data_scale, column_type, 'COL'
	FROM cn_obj_columns_v WHERE column_id = X_source_column_id);

END Insert_Row;

-- -----------------------------------------------------------

PROCEDURE Delete_Row ( 	X_column_map_id		number,
		       	X_destination_column_id	number,
			X_tmp_column_map_id	number,
		       	X_tmp_dest_column_id	number,
			X_rup_column_map_id	number,
		       	X_rup_dest_column_id	number) IS
BEGIN

  DELETE cn_column_maps WHERE column_map_id = X_column_map_id;
  DELETE cn_obj_columns_v WHERE column_id = X_destination_column_id;

  DELETE cn_column_maps WHERE column_map_id = X_tmp_column_map_id;
  DELETE cn_obj_columns_v WHERE column_id = X_tmp_dest_column_id;

  DELETE cn_column_maps WHERE column_map_id = X_rup_column_map_id;
  DELETE cn_obj_columns_v WHERE column_id = X_rup_dest_column_id;

END Delete_Row;

-- -----------------------------------------------------------

END CNDISL_slice_def_dim_PKG;

/
