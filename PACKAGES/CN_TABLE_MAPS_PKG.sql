--------------------------------------------------------
--  DDL for Package CN_TABLE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TABLE_MAPS_PKG" AUTHID CURRENT_USER AS
-- $Header: cncotms.pls 120.4 2005/10/24 00:44:50 apink noship $
--
-- Public Procedures
--
--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the table.
--
PROCEDURE insert_row (
	X_rowid	 OUT NOCOPY ROWID,
	X_table_map_id             IN OUT NOCOPY cn_table_maps.table_map_id%TYPE,
	X_mapping_type             cn_table_maps.mapping_type%TYPE,
	X_module_id                cn_table_maps.module_id%TYPE,
	X_source_table_id          cn_table_maps.source_table_id%TYPE,
	X_source_tbl_pkcol_id      cn_table_maps.source_tbl_pkcol_id%TYPE,
	X_destination_table_id     cn_table_maps.destination_table_id%TYPE,
	X_source_hdr_tbl_pkcol_id  cn_table_maps.source_hdr_tbl_pkcol_id%TYPE,
	X_source_tbl_hdr_fkcol_id  cn_table_maps.source_tbl_hdr_fkcol_id%TYPE,
	X_notify_where             cn_table_maps.notify_where%TYPE,
	X_collect_where            cn_table_maps.collect_where%TYPE,
	X_delete_flag              cn_table_maps.delete_flag%TYPE,
	X_creation_date            cn_table_maps.creation_date%TYPE,
	X_created_by               cn_table_maps.created_by%TYPE,
    X_org_id                   cn_table_maps.org_id%TYPE);

PROCEDURE lock_row (
	X_table_map_id             cn_table_maps.table_map_id%TYPE,
	X_mapping_type             cn_table_maps.mapping_type%TYPE,
	X_module_id                cn_table_maps.module_id%TYPE,
	X_source_table_id          cn_table_maps.source_table_id%TYPE,
	X_source_tbl_pkcol_id      cn_table_maps.source_tbl_pkcol_id%TYPE,
	X_destination_table_id     cn_table_maps.destination_table_id%TYPE,
	X_source_hdr_tbl_pkcol_id      cn_table_maps.source_hdr_tbl_pkcol_id%TYPE,
	X_source_tbl_hdr_fkcol_id  cn_table_maps.source_tbl_hdr_fkcol_id%TYPE,
	X_notify_where             cn_table_maps.notify_where%TYPE,
	X_collect_where            cn_table_maps.collect_where%TYPE,
	X_delete_flag              cn_table_maps.delete_flag%TYPE);

PROCEDURE update_row (
	X_table_map_id             cn_table_maps.table_map_id%TYPE,
	X_mapping_type             cn_table_maps.mapping_type%TYPE,
	X_module_id                cn_table_maps.module_id%TYPE,
	X_source_table_id          cn_table_maps.source_table_id%TYPE,
	X_source_tbl_pkcol_id      cn_table_maps.source_tbl_pkcol_id%TYPE,
	X_destination_table_id     cn_table_maps.destination_table_id%TYPE,
	X_source_hdr_tbl_pkcol_id      cn_table_maps.source_hdr_tbl_pkcol_id%TYPE,
	X_source_tbl_hdr_fkcol_id  cn_table_maps.source_tbl_hdr_fkcol_id%TYPE,
	X_notify_where             cn_table_maps.notify_where%TYPE,
	X_collect_where            cn_table_maps.collect_where%TYPE,
	X_delete_flag              cn_table_maps.delete_flag%TYPE,
    X_last_update_date         cn_table_maps.last_update_date%TYPE,
    X_last_updated_by          cn_table_maps.last_updated_by%TYPE,
    X_last_update_login        cn_table_maps.last_update_login%TYPE,
    x_object_version_number    NUMBER := cn_api.G_MISS_NUM,
    x_org_id       cn_table_maps.org_id%TYPE);

PROCEDURE delete_row (
  X_table_map_id in NUMBER,
  X_org_id IN NUMBER);

PROCEDURE load_seed_row(x_UPLOAD_MODE in varchar2,
                        x_TABLE_MAP_ID in varchar2,
                        x_MAPPING_TYPE in varchar2,
                        x_SOURCE_TABLE_ID in varchar2,
                        x_DESTINATION_TABLE_ID in varchar2,
                        x_MODULE_ID in varchar2,
                        x_LAST_UPDATE_DATE in varchar2,
                        x_LAST_UPDATED_BY in varchar2,
                        x_CREATION_DATE in varchar2,
                        x_CREATED_BY in varchar2,
                        x_DESCRIPTION in varchar2,
                        x_SEED_TABLE_MAP_ID in varchar2,
                        x_ORG_ID in varchar2,
                        x_LAST_UPDATE_LOGIN in varchar2,
                        x_SOURCE_TBL_PKCOL_ID in varchar2,
                        x_DELETE_FLAG in varchar2,
                        x_SOURCE_HDR_TBL_PKCOL_ID in varchar2,
                        x_SOURCE_TBL_HDR_FKCOL_ID in varchar2,
                        x_NOTIFY_WHERE in varchar2,
                        x_COLLECT_WHERE in varchar2,
                        x_OBJECT_VERSION_NUMBER in varchar2,
                        x_SECURITY_GROUP_ID in varchar2,
                        x_FILTER in varchar2,
                        x_APPLICATION_SHORT_NAME in varchar2,
                        x_OWNER in varchar2);

PROCEDURE load_row(x_TABLE_MAP_ID in varchar2,
                   x_MAPPING_TYPE in varchar2,
                   x_SOURCE_TABLE_ID in varchar2,
                   x_DESTINATION_TABLE_ID in varchar2,
                   x_MODULE_ID in varchar2,
                   x_LAST_UPDATE_DATE in varchar2,
                   x_LAST_UPDATED_BY in varchar2,
                   x_CREATION_DATE in varchar2,
                   x_CREATED_BY in varchar2,
                   x_DESCRIPTION in varchar2,
                   x_SEED_TABLE_MAP_ID in varchar2,
                   x_ORG_ID in varchar2,
                   x_LAST_UPDATE_LOGIN in varchar2,
                   x_SOURCE_TBL_PKCOL_ID in varchar2,
                   x_DELETE_FLAG in varchar2,
                   x_SOURCE_HDR_TBL_PKCOL_ID in varchar2,
                   x_SOURCE_TBL_HDR_FKCOL_ID in varchar2,
                   x_NOTIFY_WHERE in varchar2,
                   x_COLLECT_WHERE in varchar2,
                   x_OBJECT_VERSION_NUMBER in varchar2,
                   x_SECURITY_GROUP_ID in varchar2,
                   x_FILTER in varchar2,
                   x_APPLICATION_SHORT_NAME in varchar2,
                   x_OWNER in varchar2);

END cn_table_maps_pkg;


 

/
