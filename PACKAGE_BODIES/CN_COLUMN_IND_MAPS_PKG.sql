--------------------------------------------------------
--  DDL for Package Body CN_COLUMN_IND_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLUMN_IND_MAPS_PKG" AS
-- $Header: cnrecimb.pls 115.1 99/07/16 07:13:30 porting ship $


--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_column_ind_map_id	cn_column_ind_maps.column_ind_map_id%TYPE,
	X_index_id		cn_column_ind_maps.index_id%TYPE,
	X_column_id		cn_column_ind_maps.column_id%TYPE,
	X_column_position	cn_column_ind_maps.column_position%TYPE,
	X_order_flag		cn_column_ind_maps.order_flag%TYPE) IS

    X_primary_key               cn_column_trg_maps.column_trg_map_id%TYPE;
  BEGIN

    X_primary_key := X_column_ind_map_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_column_ind_maps (
	column_ind_map_id,
	index_id,
	column_id,
	column_position,
	order_flag)
      VALUES (
	X_column_ind_map_id,
	X_index_id,
	X_column_id,
	X_column_position,
	X_order_flag);

    SELECT ROWID
      INTO X_rowid
      FROM cn_column_ind_maps
     WHERE column_ind_map_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	recinfo IN OUT cn_column_ind_maps%ROWTYPE) IS
  BEGIN
    -- select row based on index_id (primary key)
    IF (recinfo.index_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_column_ind_maps ccim
        WHERE ccim.index_id = recinfo.index_id;

    END IF;
  END select_row;


END cn_column_ind_maps_pkg;

/
