--------------------------------------------------------
--  DDL for Package Body CN_COLUMN_TRG_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLUMN_TRG_MAPS_PKG" AS
-- $Header: cnrectmb.pls 115.1 99/07/16 07:13:41 porting ship $


--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_column_trg_map_id	cn_column_trg_maps.column_trg_map_id%TYPE,
	X_trigger_id		cn_column_trg_maps.trigger_id%TYPE,
	X_column_id		cn_column_trg_maps.column_id%TYPE) IS

    X_primary_key               cn_column_trg_maps.column_trg_map_id%TYPE;
  BEGIN

    X_primary_key := X_column_trg_map_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_column_trg_maps (
	column_trg_map_id,
	trigger_id,
	column_id)
      VALUES (
	X_column_trg_map_id,
	X_trigger_id,
	X_column_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_column_trg_maps
     WHERE column_trg_map_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	recinfo IN OUT cn_column_trg_maps%ROWTYPE) IS
  BEGIN
    -- select row based on column_trg_map_id (primary key)
    IF (recinfo.column_trg_map_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_column_trg_maps cctm
        WHERE cctm.column_trg_map_id = recinfo.column_trg_map_id;

    END IF;
  END select_row;


END cn_column_trg_maps_pkg;

/
