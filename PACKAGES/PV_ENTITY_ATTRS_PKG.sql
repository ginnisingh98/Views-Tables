--------------------------------------------------------
--  DDL for Package PV_ENTITY_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTITY_ATTRS_PKG" AUTHID CURRENT_USER as
/* $Header: pvxteats.pls 120.1 2005/06/30 14:06:27 appldev ship $ */

procedure INSERT_ROW (
  px_entity_attr_id		IN OUT NOCOPY NUMBER,
  px_object_version_number	IN OUT NOCOPY NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_creation_date		IN DATE,
  p_created_by			IN NUMBER,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER);

procedure LOCK_ROW (
  p_entity_attr_id		IN NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_object_version_number	IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2
);

procedure UPDATE_ROW (
  p_entity_attr_id		IN NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_object_version_number	IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
);

procedure DELETE_ROW (
  p_entity_attr_id		IN NUMBER
);

procedure UPDATE_SEED_ROW (
  p_entity_attr_id		IN NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_object_version_number	IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
);

procedure SEED_UPDATE_ROW (
  p_entity_attr_id		IN NUMBER,
  p_object_version_number       IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_batch_sql_text		IN VARCHAR2,
  p_display_external_value_flag IN VARCHAR2,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
);

procedure LOAD_ROW (
  p_upload_mode                 IN VARCHAR2,
  p_entity_attr_id		IN NUMBER,
  p_object_version_number       IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_batch_sql_text		IN VARCHAR2,
  p_display_external_value_flag IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_owner                       IN VARCHAR2
);

end PV_ENTITY_ATTRS_PKG;

 

/
