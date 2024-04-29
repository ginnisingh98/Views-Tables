--------------------------------------------------------
--  DDL for Package IBC_CONTENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CONTENT_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctctys.pls 120.2 2005/07/12 03:42:24 appldev ship $*/

-- Purpose: Table Handler for Ibc_Content_Types table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- vicho             11/13/2002      Added Overloaded procedures for OA UI
-- shitij.vatsa      02/11/2003      Added parameter p_subitem_version_id
--                                   to the APIs
-- vicho             07/24/03        Fixed p_encrypt_flag to type, VARCHAR2
-- Subir Anshumali   06/03/2005      Declared OUT and IN OUT arguments as references using the NOCOPY hint.
-- Sharma	     07/04/2005  Modified LOAD_ROW, TRANSLATE_ROW and created
--				 LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_content_type_status             IN VARCHAR2
,p_application_id                  IN NUMBER
,p_request_id                      IN NUMBER
,p_object_version_number           IN NUMBER
,p_content_type_name               IN VARCHAR2
,p_description                     IN VARCHAR2
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2      DEFAULT NULL
,p_OWNER_FND_USER_ID               IN NUMBER        DEFAULT NULL

);

PROCEDURE LOCK_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_TYPE_STATUS IN VARCHAR2,
  p_APPLICATION_ID IN NUMBER,
  p_REQUEST_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CONTENT_TYPE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2
);
PROCEDURE UPDATE_ROW (
 p_content_type_code               IN VARCHAR2
,p_application_id                  IN NUMBER        DEFAULT NULL
,p_content_type_name               IN VARCHAR2      DEFAULT NULL
,p_content_type_status             IN VARCHAR2      DEFAULT NULL
,p_description                     IN VARCHAR2      DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_object_version_number           IN NUMBER        DEFAULT NULL
,p_request_id                      IN NUMBER        DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2      DEFAULT NULL
,p_OWNER_FND_USER_ID               IN  NUMBER       DEFAULT NULL
);

PROCEDURE DELETE_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2
);
PROCEDURE ADD_LANGUAGE;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_TYPE_CODE    IN  VARCHAR2,
  p_APPLICATION_ID       IN  NUMBER,
  p_CONTENT_TYPE_NAME    IN  VARCHAR2,
  p_CONTENT_TYPE_STATUS  IN  VARCHAR2,
  p_DESCRIPTION          IN  VARCHAR2,
  p_OWNER                IN  VARCHAR2,
  p_OWNER_FND_USER_ID    IN  NUMBER DEFAULT NULL,
  p_encrypt_flag         IN  VARCHAR2 DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2);

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_TYPE_CODE    IN  VARCHAR2,
  p_APPLICATION_ID       IN  NUMBER,
  p_CONTENT_TYPE_NAME    IN  VARCHAR2,
  p_CONTENT_TYPE_STATUS  IN  VARCHAR2,
  p_DESCRIPTION          IN  VARCHAR2,
  p_OWNER                IN  VARCHAR2,
  p_OWNER_FND_USER_ID    IN  NUMBER DEFAULT NULL,
  p_encrypt_flag         IN  VARCHAR2 DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2);

PROCEDURE TRANSLATE_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_TYPE_CODE  IN VARCHAR2,
  p_CONTENT_TYPE_NAME  IN VARCHAR2,
  p_DESCRIPTION     IN VARCHAR2,
  p_OWNER         IN VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2);


PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_APPLICATION_ID IN NUMBER,
  X_OWNER_FND_USER_ID IN NUMBER,
  X_CONTENT_TYPE_STATUS IN VARCHAR2,
  X_REQUEST_ID IN NUMBER,
--   x_program_update_date IN DATE,
--   x_program_application_id IN NUMBER,
--   x_program_id IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_CONTENT_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_encrypt_flag IN VARCHAR2 DEFAULT NULL
);

procedure LOCK_ROW (
  X_CONTENT_TYPE_CODE in VARCHAR2,
  X_CONTENT_TYPE_STATUS in VARCHAR2     DEFAULT NULL,
  X_ENCRYPT_FLAG in VARCHAR2            DEFAULT NULL,
  X_APPLICATION_ID in NUMBER            DEFAULT NULL,
  X_REQUEST_ID in NUMBER                DEFAULT NULL,
  X_OWNER_FND_USER_ID in NUMBER         DEFAULT NULL,
  X_OBJECT_VERSION_NUMBER in NUMBER     DEFAULT NULL,
  X_SECURITY_GROUP_ID IN NUMBER         DEFAULT NULL,
  X_CONTENT_TYPE_NAME in VARCHAR2       DEFAULT NULL,
  X_DESCRIPTION in VARCHAR2             DEFAULT NULL
);

PROCEDURE UPDATE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_APPLICATION_ID IN NUMBER,
  X_OWNER_FND_USER_ID IN NUMBER,
--  x_program_update_date IN DATE,
--  x_program_application_id IN NUMBER,
--  x_program_id IN NUMBER,
  X_CONTENT_TYPE_STATUS IN VARCHAR2,
  X_REQUEST_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_CONTENT_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_encrypt_flag IN VARCHAR2 DEFAULT NULL
);

PROCEDURE DELETE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2
);

PROCEDURE COPY_ROW(P_content_type_code IN VARCHAR2
);

PROCEDURE Sync_Content_types(p_new_content_type_code IN VARCHAR2
                            ,p_old_content_type_code IN VARCHAR2
);


END Ibc_Content_Types_Pkg;

 

/
