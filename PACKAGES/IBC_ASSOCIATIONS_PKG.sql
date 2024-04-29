--------------------------------------------------------
--  DDL for Package IBC_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_ASSOCIATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctasns.pls 120.1 2005/07/29 15:09:13 appldev ship $ */

-- Purpose: Table Handler for IBC_ASSOCIATIONS table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674


PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_association_id                 IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_citem_version_id                IN NUMBER       DEFAULT NULL
,p_association_type_code           IN VARCHAR2
,p_associated_object_val1          IN VARCHAR2
,p_associated_object_val2          IN VARCHAR2
,p_associated_object_val3          IN VARCHAR2
,p_associated_object_val4          IN VARCHAR2
,p_associated_object_val5          IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
);



PROCEDURE LOCK_ROW (
 p_association_id                  IN NUMBER
,p_content_item_id                 IN NUMBER
,p_citem_version_id                IN NUMBER   DEFAULT NULL
,p_association_type_code           IN VARCHAR2
,p_associated_object_val1          IN VARCHAR2
,p_associated_object_val2          IN VARCHAR2
,p_associated_object_val3          IN VARCHAR2
,p_associated_object_val4          IN VARCHAR2
,p_associated_object_val5          IN VARCHAR2
,p_object_version_number           IN NUMBER
);


PROCEDURE UPDATE_ROW (
 p_association_id                  IN NUMBER
,p_content_item_id                 IN NUMBER        DEFAULT NULL
,p_citem_version_id                IN NUMBER        DEFAULT NULL
,p_association_type_code           IN VARCHAR2      DEFAULT NULL
,p_associated_object_val1          IN VARCHAR2      DEFAULT NULL
,p_associated_object_val2          IN VARCHAR2      DEFAULT NULL
,p_associated_object_val3          IN VARCHAR2      DEFAULT NULL
,p_associated_object_val4          IN VARCHAR2      DEFAULT NULL
,p_associated_object_val5          IN VARCHAR2      DEFAULT NULL
,p_object_version_number           IN NUMBER        DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_creation_date                   IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
);


PROCEDURE delete_row (
 p_association_id IN NUMBER
);

PROCEDURE LOAD_ROW (
 p_upload_mode in VARCHAR2
,p_association_id                  IN NUMBER
,p_content_item_id                 IN NUMBER
,p_citem_version_id                IN NUMBER DEFAULT NULL
,p_association_type_code           IN VARCHAR2
,p_associated_object_val1          IN VARCHAR2
,p_associated_object_val2          IN VARCHAR2
,p_associated_object_val3          IN VARCHAR2
,p_associated_object_val4          IN VARCHAR2
,p_associated_object_val5          IN VARCHAR2
,p_OWNER      			   IN VARCHAR2
,p_last_update_date in VARCHAR2);

PROCEDURE LOAD_SEED_ROW (
 p_upload_mode IN VARCHAR2,
 p_association_id                  IN NUMBER
,p_content_item_id                 IN NUMBER
,p_citem_version_id                IN NUMBER DEFAULT NULL
,p_association_type_code           IN VARCHAR2
,p_associated_object_val1          IN VARCHAR2
,p_associated_object_val2          IN VARCHAR2
,p_associated_object_val3          IN VARCHAR2
,p_associated_object_val4          IN VARCHAR2
,p_associated_object_val5          IN VARCHAR2
,p_OWNER      			   IN VARCHAR2,
p_last_update_date in VARCHAR2);

END Ibc_Associations_Pkg;

 

/
