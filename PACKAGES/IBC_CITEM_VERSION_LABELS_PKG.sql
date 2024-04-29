--------------------------------------------------------
--  DDL for Package IBC_CITEM_VERSION_LABELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_VERSION_LABELS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctcvls.pls 120.1 2005/07/29 15:07:20 appldev ship $*/

-- Purpose: Table Handler for Ibc_Citem_Version_Labels table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,p_content_item_id                 IN NUMBER
,p_label_code                      IN VARCHAR2
,p_citem_version_id                IN NUMBER
,p_object_version_number           IN NUMBER
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
);

PROCEDURE LOCK_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_LABEL_CODE IN VARCHAR2,
  p_CITEM_VERSION_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
);

PROCEDURE UPDATE_ROW (
 p_content_item_id                 IN NUMBER
,p_label_code                      IN VARCHAR2
,p_citem_version_id                IN NUMBER        DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_object_version_number           IN NUMBER        DEFAULT NULL
);

PROCEDURE DELETE_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_LABEL_CODE IN VARCHAR2
);

PROCEDURE LOAD_ROW (
 p_UPLOAD_MODE IN VARCHAR2,
 p_CONTENT_ITEM_ID IN NUMBER,
 p_LABEL_CODE IN VARCHAR2,
 p_CITEM_VERSION_ID IN NUMBER,
 p_OWNER    IN VARCHAR2,
 p_LAST_UPDATE_DATE IN VARCHAR2);

PROCEDURE LOAD_SEED_ROW (
 p_UPLOAD_MODE IN VARCHAR2,
 p_CONTENT_ITEM_ID IN NUMBER,
 p_LABEL_CODE IN VARCHAR2,
 p_CITEM_VERSION_ID IN NUMBER,
 p_OWNER    IN VARCHAR2,
 p_LAST_UPDATE_DATE IN VARCHAR2);


END Ibc_Citem_Version_Labels_Pkg;

 

/
