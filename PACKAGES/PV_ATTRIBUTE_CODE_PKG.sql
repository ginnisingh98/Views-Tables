--------------------------------------------------------
--  DDL for Package PV_ATTRIBUTE_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTRIBUTE_CODE_PKG" AUTHID CURRENT_USER AS
 /* $Header: pvxtatcs.pls 120.2 2005/07/05 16:42:10 appldev ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTRIBUTE_CODES_B_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================

 PROCEDURE Insert_Row(
           px_attr_code_id   IN OUT NOCOPY NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 );

 PROCEDURE Update_Row(
           p_attr_code_id    NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 );

PROCEDURE Update_Row_Seed(
           p_attr_code_id    NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 );


 PROCEDURE Delete_Row(
     p_ATTR_CODE_ID  NUMBER);
 PROCEDURE Lock_Row(
           p_attr_code_id    NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 );

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  p_attr_code_id      in VARCHAR2
, p_description       in VARCHAR2
, p_owner             in VARCHAR2
);

procedure  LOAD_ROW(
  p_ATTR_CODE_ID          IN VARCHAR2,
  p_ATTRIBUTE_ID	  IN VARCHAR2,
  p_ENABLED_FLAG          in VARCHAR2,
  p_ATTR_CODE		  IN VARCHAR2,
  p_DESCRIPTION           in VARCHAR2  DEFAULT NULL ,
  p_Owner                 in VARCHAR2
);

procedure  LOAD_SEED_ROW (
  P_UPLOAD_MODE           IN VARCHAR2,
  p_ATTR_CODE_ID          IN VARCHAR2,
  p_ATTRIBUTE_ID	  IN VARCHAR2,
  p_ENABLED_FLAG          in VARCHAR2,
  p_ATTR_CODE		  IN VARCHAR2,
  p_DESCRIPTION           in VARCHAR2  DEFAULT NULL ,
  p_Owner                 in VARCHAR2
);



 END PV_ATTRIBUTE_CODE_PKG;

 

/
