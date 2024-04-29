--------------------------------------------------------
--  DDL for Package IBC_COMPOUND_RELATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_COMPOUND_RELATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctcrls.pls 120.1 2005/07/29 15:03:04 appldev ship $*/

-- Purpose: Table Handler for Ibc_Compound_Relations table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- shitij.vatsa      02/11/2003      Added parameter p_subitem_version_id
--                                   to the APIs
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_compound_relation_id           IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_citem_version_id                IN NUMBER
,p_object_version_number           IN NUMBER
,p_sort_order                      IN NUMBER
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_subitem_version_id              IN NUMBER        DEFAULT NULL
);

PROCEDURE LOCK_ROW (
  p_compound_relation_id IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CITEM_VERSION_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_SORT_ORDER IN NUMBER
);

PROCEDURE UPDATE_ROW (
 p_compound_relation_id            IN NUMBER
,p_attribute_type_code             IN VARCHAR2      DEFAULT NULL
,p_citem_version_id                IN NUMBER        DEFAULT NULL
,p_content_item_id                 IN NUMBER        DEFAULT NULL
,p_content_type_code               IN VARCHAR2      DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_object_version_number           IN NUMBER        DEFAULT NULL
,p_sort_order                      IN NUMBER        DEFAULT NULL
,p_subitem_version_id              IN NUMBER        DEFAULT NULL
);

PROCEDURE DELETE_ROW (
  p_compound_relation_id IN NUMBER
);

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ATTRIBUTE_TYPE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE      VARCHAR2,
  p_COMPOUND_RELATION_ID   NUMBER,
  p_CITEM_VERSION_ID     NUMBER,
  p_SORT_ORDER       NUMBER,
  p_OWNER    IN VARCHAR2,
  p_subitem_version_id    IN NUMBER        DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2);

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ATTRIBUTE_TYPE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE      VARCHAR2,
  p_COMPOUND_RELATION_ID   NUMBER,
  p_CITEM_VERSION_ID     NUMBER,
  p_SORT_ORDER       NUMBER,
  p_OWNER    IN VARCHAR2,
  p_subitem_version_id    IN NUMBER        DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2);

END Ibc_Compound_Relations_Pkg;

 

/
