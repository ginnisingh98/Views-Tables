--------------------------------------------------------
--  DDL for Package PV_ATTR_PRINCIPALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTR_PRINCIPALS_PKG" AUTHID CURRENT_USER AS
 /* $Header: pvxtatps.pls 120.0 2007/12/20 07:09:06 abnagapp noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTR_PRINCIPALS_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================


 PROCEDURE Insert_Row(
           px_Attr_Principal_id   IN OUT  NOCOPY NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           px_object_version_number   IN OUT  NOCOPY NUMBER,
           p_attribute_id    NUMBER,
           p_jtf_auth_principal_id    NUMBER
           );

 PROCEDURE Update_Row(
           p_Attr_Principal_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_jtf_auth_principal_id NUMBER
           );

 PROCEDURE Delete_Row(
     p_Attr_Principal_ID  NUMBER);

 PROCEDURE Lock_Row(
           p_Attr_Principal_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_jtf_auth_principal_id    NUMBER
           );

 END PV_ATTR_PRINCIPALS_PKG;

/
