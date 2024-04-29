--------------------------------------------------------
--  DDL for Package IBC_ATTRIBUTE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_ATTRIBUTE_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctatts.pls 120.2 2005/07/12 03:46:10 appldev ship $*/

-- Purpose: Table Handler for Ibc_Attribute_Types table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- vicho             11/13/2002      Added Overloaded procedures for OA UI
-- Subir Anshumali   06/03/2005      Declared OUT and IN OUT arguments as references using the NOCOPY hint
-- Sharma	     07/04/2005  Modified LOAD_ROW, TRANSLATE_ROW and created
--				 LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE insert_row (
 x_rowid OUT NOCOPY VARCHAR2
,p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_data_type_code                  IN VARCHAR2
,p_data_length                     IN NUMBER
,p_min_instances                   IN NUMBER
,p_max_instances                   IN NUMBER
,p_reference_code                  IN VARCHAR2
,p_default_value                   IN VARCHAR2
,p_updateable_flag                 IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_attribute_type_name             IN VARCHAR2
,p_description                     IN VARCHAR2
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_display_order		   IN NUMBER	    DEFAULT NULL
,p_flex_value_set_id		   IN NUMBER	    DEFAULT NULL
);


PROCEDURE lock_row (
 p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_data_type_code                  IN VARCHAR2
,p_data_length                     IN NUMBER
,p_min_instances                   IN NUMBER
,p_max_instances                   IN NUMBER
,p_reference_code                  IN VARCHAR2
,p_default_value                   IN VARCHAR2
,p_updateable_flag                 IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_attribute_type_name             IN VARCHAR2
,p_description                     IN VARCHAR2
);


PROCEDURE update_row (
 p_attribute_type_code             IN VARCHAR2
,p_attribute_type_name             IN VARCHAR2      DEFAULT NULL
,p_content_type_code               IN VARCHAR2
,p_data_length                     IN NUMBER        DEFAULT NULL
,p_data_type_code                  IN VARCHAR2      DEFAULT NULL
,p_default_value                   IN VARCHAR2      DEFAULT NULL
,p_description                     IN VARCHAR2      DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_max_instances                   IN NUMBER        DEFAULT NULL
,p_min_instances                   IN NUMBER        DEFAULT NULL
,p_object_version_number           IN NUMBER        DEFAULT NULL
,p_reference_code                  IN VARCHAR2      DEFAULT NULL
,p_updateable_flag                 IN VARCHAR2      DEFAULT NULL
,p_display_order		   IN NUMBER	    DEFAULT NULL
,p_flex_value_set_id		   IN NUMBER	    DEFAULT NULL
);


PROCEDURE delete_row (
 p_attribute_type_code  IN VARCHAR2
,p_content_type_code    IN VARCHAR2
);

PROCEDURE delete_rows (
  p_content_type_code IN VARCHAR2
);

PROCEDURE LOAD_ROW (
 p_upload_mode			   IN VARCHAR2,
 p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_data_type_code                  IN VARCHAR2
,p_data_length                     IN NUMBER
,p_min_instances                   IN NUMBER
,p_max_instances                   IN NUMBER
,p_reference_code                  IN VARCHAR2
,p_default_value                   IN VARCHAR2
,p_updateable_flag                 IN VARCHAR2
,p_attribute_type_name             IN VARCHAR2
,p_description                     IN VARCHAR2
,p_owner                           IN VARCHAR2
,p_display_order		   IN NUMBER	    DEFAULT NULL
,p_flex_value_set_id		   IN NUMBER	    DEFAULT NULL,
p_last_update_date IN VARCHAR2 );

PROCEDURE LOAD_SEED_ROW (
 p_upload_mode			   IN VARCHAR2,
 p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_data_type_code                  IN VARCHAR2
,p_data_length                     IN NUMBER
,p_min_instances                   IN NUMBER
,p_max_instances                   IN NUMBER
,p_reference_code                  IN VARCHAR2
,p_default_value                   IN VARCHAR2
,p_updateable_flag                 IN VARCHAR2
,p_attribute_type_name             IN VARCHAR2
,p_description                     IN VARCHAR2
,p_owner                           IN VARCHAR2
,p_display_order		   IN NUMBER	    DEFAULT NULL
,p_flex_value_set_id		   IN NUMBER	    DEFAULT NULL,
 p_last_update_date IN VARCHAR2 );




PROCEDURE TRANSLATE_ROW (
 p_upload_mode			   IN VARCHAR2,
 p_content_type_code               IN VARCHAR2
,p_attribute_type_code             IN VARCHAR2
,p_attribute_type_name             IN VARCHAR2
,p_description                     IN VARCHAR2
,p_owner                           IN VARCHAR2
, p_last_update_date IN VARCHAR2 );

PROCEDURE add_language;


--
-- Overloaded Procedures for OA Content Type UI
--
PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  X_MIN_INSTANCES IN NUMBER,
  X_MAX_INSTANCES IN NUMBER,
  X_DEFAULT_VALUE IN VARCHAR2,
  X_UPDATEABLE_FLAG IN VARCHAR2,
  X_REFERENCE_CODE IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_DISPLAY_ORDER IN NUMBER,
  X_FLEX_VALUE_SET_ID IN NUMBER,
  X_DATA_TYPE_CODE IN VARCHAR2,
  X_DATA_LENGTH IN NUMBER,
  X_ATTRIBUTE_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
);

PROCEDURE LOCK_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  X_MIN_INSTANCES IN NUMBER,
  X_MAX_INSTANCES IN NUMBER,
  X_DEFAULT_VALUE IN VARCHAR2,
  X_UPDATEABLE_FLAG IN VARCHAR2,
  X_REFERENCE_CODE IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_DISPLAY_ORDER IN NUMBER,
  X_FLEX_VALUE_SET_ID IN NUMBER,
  X_DATA_TYPE_CODE IN VARCHAR2,
  X_DATA_LENGTH IN NUMBER,
  X_ATTRIBUTE_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2
);

PROCEDURE UPDATE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  X_MIN_INSTANCES IN NUMBER,
  X_MAX_INSTANCES IN NUMBER,
  X_DEFAULT_VALUE IN VARCHAR2,
  X_UPDATEABLE_FLAG IN VARCHAR2,
  X_REFERENCE_CODE IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_DISPLAY_ORDER IN NUMBER,
  X_FLEX_VALUE_SET_ID IN NUMBER,
  X_DATA_TYPE_CODE IN VARCHAR2,
  X_DATA_LENGTH IN NUMBER,
  X_ATTRIBUTE_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
);

PROCEDURE DELETE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2
);

END Ibc_Attribute_Types_Pkg;

 

/
