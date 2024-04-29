--------------------------------------------------------
--  DDL for Package PV_ATTRIBUTE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTRIBUTE_USAGES_PKG" AUTHID CURRENT_USER AS
 /* $Header: pvxtatus.pls 115.3 2002/12/10 19:39:11 amaram ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTRIBUTE_USAGES_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================

 PROCEDURE Insert_Row(
           px_attribute_usage_id   IN OUT  NOCOPY NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_request_id    NUMBER,
           p_program_application_id    NUMBER,
           p_program_id    NUMBER,
           p_program_update_date    DATE,
           px_object_version_number   IN OUT  NOCOPY NUMBER,
           p_attribute_usage_type    VARCHAR2,
           p_attribute_usage_code    VARCHAR2,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2
           --p_security_group_id    NUMBER
           );

 PROCEDURE Update_Row(
           p_attribute_usage_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_request_id    NUMBER,
           p_program_application_id    NUMBER,
           p_program_id    NUMBER,
           p_program_update_date    DATE,
           p_object_version_number    NUMBER,
           p_attribute_usage_type    VARCHAR2,
           p_attribute_usage_code    VARCHAR2,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2
           --p_security_group_id    NUMBER
           );

 PROCEDURE Delete_Row(
     p_ATTRIBUTE_USAGE_ID  NUMBER);
 PROCEDURE Lock_Row(
           p_attribute_usage_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_request_id    NUMBER,
           p_program_application_id    NUMBER,
           p_program_id    NUMBER,
           p_program_update_date    DATE,
           p_object_version_number    NUMBER,
           p_attribute_usage_type    VARCHAR2,
           p_attribute_usage_code    VARCHAR2,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2
           --p_security_group_id    NUMBER
           );

 END PV_ATTRIBUTE_USAGES_PKG;


 

/
