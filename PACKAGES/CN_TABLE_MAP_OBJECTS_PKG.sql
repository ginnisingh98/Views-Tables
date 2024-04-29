--------------------------------------------------------
--  DDL for Package CN_TABLE_MAP_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TABLE_MAP_OBJECTS_PKG" AUTHID CURRENT_USER as
/* $Header: cntmobjs.pls 120.3 2005/09/20 05:12:14 vensrini noship $ */
PROCEDURE insert_row (
  X_rowid IN OUT NOCOPY VARCHAR2,
  X_table_map_object_id  IN OUT NOCOPY NUMBER,
  X_tm_object_type IN VARCHAR2,
  X_table_map_id IN NUMBER,
  X_object_id IN NUMBER,
  X_creation_date IN DATE,
  X_created_by IN NUMBER,
  X_org_id IN NUMBER);

PROCEDURE lock_row (
  X_table_map_object_id IN NUMBER,
  X_tm_object_type in VARCHAR2,
  X_table_map_id IN NUMBER,
  X_object_id IN NUMBER);

PROCEDURE update_row (
  X_table_map_object_id IN NUMBER,
  X_tm_object_type in VARCHAR2,
  X_table_map_id IN NUMBER,
  X_object_id IN NUMBER,
  X_last_update_date IN DATE,
  X_last_updated_by IN NUMBER,
  X_last_update_login IN NUMBER,
  x_org_id IN NUMBER,
  x_object_version_number IN OUT NOCOPY NUMBER
  );

PROCEDURE delete_row (
  X_table_map_object_id IN NUMBER,
  X_ORG_ID IN NUMBER
		     );

PROCEDURE load_row(x_TABLE_MAP_OBJECT_ID in varchar2,
                   x_ORG_ID in varchar2,
                   x_TM_OBJECT_TYPE in varchar2,
                   x_TABLE_MAP_ID in varchar2,
                   x_OBJECT_ID in varchar2,
                   x_LAST_UPDATE_DATE in varchar2,
                   x_LAST_UPDATED_BY in varchar2,
                   x_CREATION_DATE in varchar2,
                   x_CREATED_BY in varchar2,
                   x_LAST_UPDATE_LOGIN in varchar2,
                   x_SECURITY_GROUP_ID in varchar2,
                   x_OBJECT_VERSION_NUMBER in varchar2,
                   x_APPLICATION_SHORT_NAME in varchar2,
                   x_OWNER in varchar2);

PROCEDURE load_seed_row(x_UPLOAD_MODE in varchar2,
                        x_TABLE_MAP_OBJECT_ID in varchar2,
                        x_ORG_ID in varchar2,
                        x_TM_OBJECT_TYPE in varchar2,
                        x_TABLE_MAP_ID in varchar2,
                        x_OBJECT_ID in varchar2,
                        x_LAST_UPDATE_DATE in varchar2,
                        x_LAST_UPDATED_BY in varchar2,
                        x_CREATION_DATE in varchar2,
                        x_CREATED_BY in varchar2,
                        x_LAST_UPDATE_LOGIN in varchar2,
                        x_SECURITY_GROUP_ID in varchar2,
                        x_OBJECT_VERSION_NUMBER in varchar2,
                        x_APPLICATION_SHORT_NAME in varchar2,
			x_OWNER in varchar2);

END cn_table_map_objects_pkg;

 

/
