--------------------------------------------------------
--  DDL for Package IBC_CONTENT_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CONTENT_ITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctcons.pls 120.1 2005/07/29 14:56:00 appldev ship $*/

-- Purpose: Table Handler for Ibc_Content_Items table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- shitij.vatsa      02/11/2003      Added parameter p_subitem_version_id
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674


PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_content_item_id                IN OUT NOCOPY NUMBER
,p_content_type_code               IN VARCHAR2
,p_item_reference_code             IN VARCHAR2
,p_directory_node_id               IN NUMBER
,p_parent_item_id                  IN NUMBER
,p_live_citem_version_id           IN NUMBER
,p_content_item_status             IN VARCHAR2
,p_locked_by_user_id               IN NUMBER
,p_wd_restricted_flag              IN VARCHAR2
,p_base_language                   IN VARCHAR2
,p_translation_required_flag       IN VARCHAR2
,p_owner_resource_id               IN NUMBER
,p_owner_resource_type             IN VARCHAR2
,p_application_id                  IN NUMBER        DEFAULT NULL
,p_request_id                      IN NUMBER
,p_object_version_number           IN NUMBER        DEFAULT 1
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2      DEFAULT NULL
);

PROCEDURE LOCK_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_ITEM_REFERENCE_CODE IN VARCHAR2,
  p_DIRECTORY_NODE_ID IN NUMBER,
  p_parent_item_ID IN NUMBER,
  p_LIVE_CITEM_VERSION_ID IN NUMBER,
  p_CONTENT_ITEM_STATUS IN VARCHAR2,
  p_LOCKED_BY_USER_ID IN NUMBER,
  p_WD_RESTRICTED_FLAG IN VARCHAR2,
  p_BASE_LANGUAGE IN VARCHAR2,
  p_TRANSLATION_REQUIRED_FLAG IN VARCHAR2,
  p_OWNER_RESOURCE_ID IN NUMBER,
  p_APPLICATION_ID IN NUMBER,
  p_REQUEST_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
);
PROCEDURE UPDATE_ROW (
 p_content_item_id                 IN NUMBER
,p_content_type_code               IN VARCHAR2      DEFAULT NULL
,p_item_reference_code             IN VARCHAR2      DEFAULT NULL
,p_directory_node_id               IN NUMBER        DEFAULT NULL
,p_parent_item_id                  IN NUMBER        DEFAULT NULL
,p_live_citem_version_id           IN NUMBER        DEFAULT NULL
,p_content_item_status             IN VARCHAR2      DEFAULT NULL
,p_locked_by_user_id               IN NUMBER        DEFAULT NULL
,p_wd_restricted_flag              IN VARCHAR2      DEFAULT NULL
,p_base_language                   IN VARCHAR2      DEFAULT NULL
,p_translation_required_flag       IN VARCHAR2      DEFAULT NULL
,p_owner_resource_id               IN NUMBER        DEFAULT NULL
,p_owner_resource_type             IN VARCHAR2      DEFAULT NULL
,p_application_id                  IN NUMBER        DEFAULT NULL
,p_request_id                      IN NUMBER        DEFAULT NULL
,px_object_version_number          IN OUT NOCOPY NUMBER
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2      DEFAULT NULL
);

PROCEDURE DELETE_ROW (
  p_CONTENT_ITEM_ID IN NUMBER
);

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ITEM_REFERENCE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE   VARCHAR2,
  p_DIRECTORY_NODE_ID   NUMBER,
  p_parent_item_ID     IN NUMBER ,--DEFAULT NULL,
  p_LIVE_CITEM_VERSION_ID NUMBER,
  p_CONTENT_ITEM_STATUS   VARCHAR2,
  p_LOCKED_BY_USER_ID   NUMBER,
  --p_REUSABLE_FLAG    VARCHAR2 DEFAULT NULL,
  p_WD_RESTRICTED_FLAG   VARCHAR2,
  p_BASE_LANGUAGE    VARCHAR2,
  p_TRANSLATION_REQUIRED_FLAG VARCHAR2,
  p_OWNER_RESOURCE_ID   NUMBER,
  p_OWNER_RESOURCE_TYPE   VARCHAR2,
  p_APPLICATION_ID    NUMBER,
  p_OWNER    IN VARCHAR2,
  p_ENCRYPT_FLAG        IN VARCHAR2      DEFAULT NULL,
  p_LAST_UPDATE_DATE VARCHAR2);

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ITEM_REFERENCE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE   VARCHAR2,
  p_DIRECTORY_NODE_ID   NUMBER,
  p_parent_item_ID     IN NUMBER ,--DEFAULT NULL,
  p_LIVE_CITEM_VERSION_ID NUMBER,
  p_CONTENT_ITEM_STATUS   VARCHAR2,
  p_LOCKED_BY_USER_ID   NUMBER,
  --p_REUSABLE_FLAG    VARCHAR2 DEFAULT NULL,
  p_WD_RESTRICTED_FLAG   VARCHAR2,
  p_BASE_LANGUAGE    VARCHAR2,
  p_TRANSLATION_REQUIRED_FLAG VARCHAR2,
  p_OWNER_RESOURCE_ID   NUMBER,
  p_OWNER_RESOURCE_TYPE   VARCHAR2,
  p_APPLICATION_ID    NUMBER,
  p_OWNER    IN VARCHAR2,
  p_ENCRYPT_FLAG    IN VARCHAR2   DEFAULT NULL,
  p_LAST_UPDATE_DATE VARCHAR2);


END Ibc_Content_Items_Pkg;

 

/
