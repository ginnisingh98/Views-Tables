--------------------------------------------------------
--  DDL for Package IBC_CITEM_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_VERSIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctcivs.pls 120.2 2005/07/29 15:00:21 appldev ship $*/

-- Purpose: Table Handler for Ibc_Citem_Versions table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002  Created Package
-- shitij.vatsa      11/04/2002  Updated for FND_API.G_MISS_XXX
-- shitij.vatsa      02/11/2003  Added parameter p_subitem_version_id
--                               to the APIs
-- shitij.vatsa      05/03/2004  Added a new API
--                               populate_all_attachments
--                               Bug Fix:3597752
-- Subir Anshumali   06/03/2005  Declared OUT and IN OUT arguments as references using the NOCOPY hint.
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_citem_version_id               IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_version_number                  IN NUMBER
,p_citem_version_status            IN VARCHAR2
,p_start_date                      IN DATE
,p_end_date                        IN DATE
,px_object_version_number          IN OUT NOCOPY NUMBER
,p_attribute_file_id               IN NUMBER
,p_attachment_attribute_code       IN VARCHAR2
,p_attachment_file_id              IN NUMBER
,p_content_item_name               IN VARCHAR2
,p_attachment_file_name            IN VARCHAR2      DEFAULT NULL
,p_description                     IN VARCHAR2
,p_default_rendition_mime_type     IN VARCHAR2      DEFAULT NULL
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_citem_translation_status        IN VARCHAR2      DEFAULT NULL
);

PROCEDURE POPULATE_ALL_LANG (
  p_CITEM_VERSION_ID IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_VERSION_NUMBER IN NUMBER,
  p_CITEM_VERSION_STATUS IN VARCHAR2,
  p_START_DATE IN DATE,
  p_END_DATE IN DATE,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  P_SOURCE_LANG   IN VARCHAR2 DEFAULT USERENV('LANG'),
  p_ATTACHMENT_FILE_ID IN NUMBER,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 DEFAULT NULL,
  p_CREATION_DATE IN DATE      DEFAULT NULL,
  p_CREATED_BY IN NUMBER     DEFAULT NULL,
  p_LAST_UPDATE_DATE IN DATE    DEFAULT NULL,
  p_LAST_UPDATED_BY IN NUMBER   DEFAULT NULL,
  p_LAST_UPDATE_LOGIN IN NUMBER  DEFAULT NULL,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  DEFAULT NULL
);

PROCEDURE INSERT_BASE_LANG (
  x_ROWID  OUT NOCOPY VARCHAR2,
  px_CITEM_VERSION_ID IN OUT NOCOPY NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_VERSION_NUMBER IN NUMBER,
  p_CITEM_VERSION_STATUS IN VARCHAR2,
  p_START_DATE IN DATE,
  p_END_DATE IN DATE,
  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  P_SOURCE_LANG   IN VARCHAR2 DEFAULT USERENV('LANG'),
  p_ATTACHMENT_FILE_ID IN NUMBER DEFAULT NULL,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2  DEFAULT NULL,
  p_DESCRIPTION IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 DEFAULT NULL,
  p_CREATION_DATE IN DATE      DEFAULT NULL,
  p_CREATED_BY IN NUMBER     DEFAULT NULL,
  p_LAST_UPDATE_DATE IN DATE    DEFAULT NULL,
  p_LAST_UPDATED_BY IN NUMBER   DEFAULT NULL,
  p_LAST_UPDATE_LOGIN IN NUMBER  DEFAULT NULL,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  DEFAULT NULL);

PROCEDURE LOCK_ROW (
  p_CITEM_VERSION_ID IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_VERSION_NUMBER IN NUMBER,
  p_CITEM_VERSION_STATUS IN VARCHAR2,
  p_START_DATE IN DATE,
  p_END_DATE IN DATE,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_FILE_ID IN NUMBER,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2);

PROCEDURE UPDATE_ROW (
 p_citem_version_id                IN NUMBER
,p_content_item_id                 IN NUMBER        DEFAULT NULL
,p_source_lang                     IN VARCHAR2      DEFAULT USERENV('LANG')
,p_version_number                  IN NUMBER        DEFAULT NULL
,p_citem_version_status            IN VARCHAR2      DEFAULT NULL
,p_attachment_attribute_code       IN VARCHAR2      DEFAULT NULL
,p_start_date                      IN DATE          DEFAULT NULL
,p_end_date                        IN DATE          DEFAULT NULL
,px_object_version_number          IN OUT NOCOPY NUMBER
,p_attribute_file_id               IN NUMBER        DEFAULT NULL
,p_attachment_file_id              IN NUMBER        DEFAULT NULL
,p_content_item_name               IN VARCHAR2      DEFAULT NULL
,p_attachment_file_name            IN VARCHAR2      DEFAULT NULL
,p_description                     IN VARCHAR2      DEFAULT NULL
,p_default_rendition_mime_type     IN VARCHAR2      DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_citem_translation_status        IN VARCHAR2      DEFAULT NULL
);

PROCEDURE DELETE_ROW (
  p_CITEM_VERSION_ID IN NUMBER
);

PROCEDURE ADD_LANGUAGE;


PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CITEM_VERSION_ID    IN NUMBER,
  p_CONTENT_ITEM_ID     IN NUMBER,
  p_VERSION_NUMBER     IN NUMBER,
  p_CITEM_VERSION_STATUS   IN VARCHAR2,
  p_START_DATE      IN DATE,
  p_END_DATE      IN DATE,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  p_ATTRIBUTE_FILE_ID   IN NUMBER  ,
  p_ATTACHMENT_FILE_ID   IN NUMBER  DEFAULT NULL,
  p_CONTENT_ITEM_NAME   IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME  IN VARCHAR2 DEFAULT NULL,
  p_DESCRIPTION     IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 DEFAULT NULL,
  p_OWNER       IN VARCHAR2,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2  );

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CITEM_VERSION_ID    IN NUMBER,
  p_CONTENT_ITEM_ID     IN NUMBER,
  p_VERSION_NUMBER     IN NUMBER,
  p_CITEM_VERSION_STATUS   IN VARCHAR2,
  p_START_DATE      IN DATE,
  p_END_DATE      IN DATE,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  p_ATTRIBUTE_FILE_ID   IN NUMBER  ,
  p_ATTACHMENT_FILE_ID   IN NUMBER  DEFAULT NULL,
  p_CONTENT_ITEM_NAME   IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME  IN VARCHAR2 DEFAULT NULL,
  p_DESCRIPTION     IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 DEFAULT NULL,
  p_OWNER       IN VARCHAR2,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2  );

PROCEDURE TRANSLATE_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CITEM_VERSION_ID IN NUMBER,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_FILE_ID IN NUMBER,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2,
  p_DESCRIPTION    IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 DEFAULT NULL,
  p_OWNER     IN  VARCHAR2,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2  );

PROCEDURE populate_attachments (
  p_citem_version_id  IN NUMBER
 ,p_base_lang         IN VARCHAR2 DEFAULT USERENV('LANG')
 );

PROCEDURE populate_all_attachments (
  p_citem_version_id  IN NUMBER
 ,p_base_lang         IN VARCHAR2 DEFAULT USERENV('LANG')
 );

END Ibc_Citem_Versions_Pkg;

 

/
