--------------------------------------------------------
--  DDL for Package CN_COLUMN_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLUMN_MAPS_PKG" AUTHID CURRENT_USER AS
-- $Header: cncocms.pls 120.5 2005/09/20 05:10:54 vensrini noship $
--
-- Public Procedures
--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the table.
-- History
--   15-FEB-94            Devesh Khatu            Created
--   09-MAR-00          Dave Maskell            Table redesign


PROCEDURE insert_row (
	X_rowid	 OUT NOCOPY ROWID,
	X_column_map_id          IN OUT NOCOPY cn_column_maps.column_map_id%TYPE,
	X_destination_column_id  cn_column_maps.destination_column_id%TYPE,
	X_table_map_id           cn_column_maps.table_map_id%TYPE,
	X_expression             cn_column_maps.expression%TYPE,
	X_editable               cn_column_maps.editable%TYPE,
	X_modified               cn_column_maps.modified%TYPE,
	X_update_clause          cn_column_maps.update_clause%TYPE,
	X_calc_ext_table_id      cn_column_maps.calc_ext_table_id%TYPE,
    X_creation_date          cn_column_maps.creation_date%TYPE,
    X_created_by             cn_column_maps.created_by%TYPE,
    X_org_id                 cn_column_maps.org_id%TYPE);

--
-- Procedure Name
--   select_row
-- Purpose
--   Select a row from the table, given the primary key
-- History
--
/*
PROCEDURE select_row (
        x_recinfo IN OUT NOCOPY cn_column_maps%ROWTYPE);

--
--   09-MAR-00		Dave Maskell		Added new procedures
--
PROCEDURE lock_row (
	X_column_map_id          cn_column_maps.column_map_id%TYPE,
	X_destination_column_id  cn_column_maps.destination_column_id%TYPE,
	X_table_map_id           cn_column_maps.table_map_id%TYPE,
	X_expression             cn_column_maps.expression%TYPE,
	X_editable               cn_column_maps.editable%TYPE,
	X_modified               cn_column_maps.modified%TYPE,
	X_update_clause          cn_column_maps.update_clause%TYPE,
	X_calc_ext_table_id      cn_column_maps.calc_ext_table_id%TYPE);
*/
PROCEDURE update_row (
	X_column_map_id          cn_column_maps.column_map_id%TYPE,
	X_destination_column_id  cn_column_maps.destination_column_id%TYPE,
	X_table_map_id           cn_column_maps.table_map_id%TYPE,
	X_expression             cn_column_maps.expression%TYPE,
	X_editable               cn_column_maps.editable%TYPE,
	X_modified               cn_column_maps.modified%TYPE,
	X_update_clause          cn_column_maps.update_clause%TYPE,
	X_calc_ext_table_id      cn_column_maps.calc_ext_table_id%TYPE,
        X_last_update_date       cn_column_maps.last_update_date%TYPE,
        X_last_updated_by        cn_column_maps.last_updated_by%TYPE,
	X_last_update_login      cn_column_maps.last_update_login%TYPE,
	x_object_version_number  IN OUT NOCOPY NUMBER,
    x_org_id                 IN NUMBER);

PROCEDURE delete_row (
     X_column_map_id in NUMBER,
     x_org_id        IN NUMBER);

PROCEDURE load_row(x_COLUMN_MAP_ID in varchar2,
                   x_DESTINATION_COLUMN_ID in varchar2,
                   x_TABLE_MAP_ID in varchar2,
                   x_LAST_UPDATE_DATE in varchar2,
                   x_LAST_UPDATED_BY in varchar2,
                   x_CREATION_DATE in varchar2,
                   x_CREATED_BY in varchar2,
                   x_LAST_UPDATE_LOGIN in varchar2,
                   x_SOURCE_COLUMN_ID in varchar2,
                   x_DRIVING_COLUMN_ID in varchar2,
                   x_EXPRESSION in varchar2,
                   x_AGGREGATE_FUNCTION in varchar2,
                   x_SEED_COLUMN_MAP_ID in varchar2,
                   x_GROUP_BY_FLAG in varchar2,
                   x_UNIQUE_FLAG in varchar2,
                   x_ORG_ID in varchar2,
                   x_UPDATE_CLAUSE in varchar2,
                   x_MODIFIED in varchar2,
                   x_EDITABLE in varchar2,
                   x_CALC_EXT_TABLE_ID in varchar2,
                   x_OBJECT_VERSION_NUMBER in varchar2,
                   x_SECURITY_GROUP_ID in varchar2,
                   x_APPLICATION_SHORT_NAME in varchar2,
                   x_OWNER in varchar2);

PROCEDURE load_seed_row(x_UPLOAD_MODE in varchar2,
                        x_COLUMN_MAP_ID in varchar2,
                        x_DESTINATION_COLUMN_ID in varchar2,
                        x_TABLE_MAP_ID in varchar2,
                        x_LAST_UPDATE_DATE in varchar2,
                        x_LAST_UPDATED_BY in varchar2,
                        x_CREATION_DATE in varchar2,
                        x_CREATED_BY in varchar2,
                        x_LAST_UPDATE_LOGIN in varchar2,
                        x_SOURCE_COLUMN_ID in varchar2,
                        x_DRIVING_COLUMN_ID in varchar2,
                        x_EXPRESSION in varchar2,
                        x_AGGREGATE_FUNCTION in varchar2,
                        x_SEED_COLUMN_MAP_ID in varchar2,
                        x_GROUP_BY_FLAG in varchar2,
                        x_UNIQUE_FLAG in varchar2,
                        x_ORG_ID in varchar2,
                        x_UPDATE_CLAUSE in varchar2,
                        x_MODIFIED in varchar2,
                        x_EDITABLE in varchar2,
                        x_CALC_EXT_TABLE_ID in varchar2,
                        x_OBJECT_VERSION_NUMBER in varchar2,
                        x_SECURITY_GROUP_ID in varchar2,
                        x_APPLICATION_SHORT_NAME in varchar2,
                        x_OWNER in varchar2);

END cn_column_maps_pkg;

 

/
