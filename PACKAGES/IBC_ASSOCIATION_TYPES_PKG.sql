--------------------------------------------------------
--  DDL for Package IBC_ASSOCIATION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_ASSOCIATION_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctatys.pls 120.2 2005/07/12 01:40:01 appldev ship $ */

-- Purpose: Table Handler for IBC_ASSOCIATION_TYPES_B table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- Siva Devaki       12/01/2003      Added Overloaded procedures for OA UI
-- Siva Devaki       06/24/2005      NOCOPY changes made to fix#4399469
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE insert_row (
 p_association_type_code           IN VARCHAR2
,p_search_page                     IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_call_back_pkg                   IN VARCHAR2
,p_association_type_name           IN VARCHAR2
,p_description                     IN VARCHAR2
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,x_rowid                           OUT NOCOPY VARCHAR2
);

PROCEDURE lock_row (
 p_association_type_code           IN VARCHAR2
,p_search_page                     IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_association_type_name           IN VARCHAR2
,p_description                     IN VARCHAR2
);

PROCEDURE update_row (
 p_association_type_code           IN VARCHAR2
,p_association_type_name           IN VARCHAR2      DEFAULT NULL
,p_call_back_pkg                   IN VARCHAR2
,p_description                     IN VARCHAR2      DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_object_version_number           IN NUMBER        DEFAULT NULL
,p_search_page                     IN VARCHAR2      DEFAULT NULL
);


PROCEDURE delete_row (
  p_association_type_code IN VARCHAR2
);
PROCEDURE add_language;

PROCEDURE TRANSLATE_ROW (
 p_upload_mode			IN VARCHAR2
,p_association_type_code        IN VARCHAR2
,p_association_type_name        IN VARCHAR2
,p_description                  IN VARCHAR2
,p_owner                        IN VARCHAR2
,p_last_update_date		IN VARCHAR2
);


PROCEDURE LOAD_ROW (
 p_upload_mode			IN VARCHAR2
,p_association_type_code           IN VARCHAR2
,p_association_type_name           IN VARCHAR2
,p_call_back_pkg                   IN VARCHAR2
,p_description                     IN VARCHAR2
,p_search_page                     IN VARCHAR2
,p_owner                           IN VARCHAR2
,p_last_update_date		IN VARCHAR2
);

PROCEDURE LOAD_SEED_ROW (
 p_upload_mode			IN VARCHAR2
,p_association_type_code           IN VARCHAR2
,p_association_type_name           IN VARCHAR2
,p_call_back_pkg                   IN VARCHAR2
,p_description                     IN VARCHAR2
,p_search_page                     IN VARCHAR2
,p_owner                           IN VARCHAR2
,p_last_update_date		IN VARCHAR2
);

procedure INSERT_ROW (
  X_ROWID 			   IN OUT NOCOPY VARCHAR2,
  X_ASSOCIATION_TYPE_CODE 	   IN VARCHAR2,
  X_CALL_BACK_PKG 		   IN VARCHAR2,
  X_SEARCH_PAGE 		   IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER 	   IN NUMBER,
  X_ASSOCIATION_TYPE_NAME 	   IN VARCHAR2,
  X_DESCRIPTION 		   IN VARCHAR2,
  X_CREATION_DATE 		   IN DATE,
  X_CREATED_BY 			   IN NUMBER,
  X_LAST_UPDATE_DATE 		   IN DATE,
  X_LAST_UPDATED_BY 		   IN NUMBER,
  X_LAST_UPDATE_LOGIN 		   IN NUMBER,
  X_SECURITY_GROUP_ID		   IN NUMBER);

procedure LOCK_ROW (
  X_ASSOCIATION_TYPE_CODE 	   IN VARCHAR2,
  X_CALL_BACK_PKG 		   IN VARCHAR2,
  X_SEARCH_PAGE 		   IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER 	   IN NUMBER,
  X_ASSOCIATION_TYPE_NAME 	   IN VARCHAR2,
  X_DESCRIPTION 	           IN VARCHAR2,
  X_SECURITY_GROUP_ID		   IN NUMBER
);

procedure UPDATE_ROW (
  X_ASSOCIATION_TYPE_CODE 	   IN VARCHAR2,
  X_CALL_BACK_PKG 		   IN VARCHAR2,
  X_SEARCH_PAGE 		   IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER 	   IN NUMBER,
  X_ASSOCIATION_TYPE_NAME 	   IN VARCHAR2,
  X_DESCRIPTION 		   IN VARCHAR2,
  X_LAST_UPDATE_DATE 		   IN DATE,
  X_LAST_UPDATED_BY 	           IN NUMBER,
  X_LAST_UPDATE_LOGIN 		   IN NUMBER,
  X_SECURITY_GROUP_ID              IN NUMBER
);

procedure DELETE_ROW (
  X_ASSOCIATION_TYPE_CODE 	   IN VARCHAR2
);

END Ibc_Association_Types_Pkg;

 

/
