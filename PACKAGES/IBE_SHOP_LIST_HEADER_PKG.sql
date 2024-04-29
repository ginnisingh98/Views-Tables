--------------------------------------------------------
--  DDL for Package IBE_SHOP_LIST_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SHOP_LIST_HEADER_PKG" AUTHID CURRENT_USER AS
/* $Header: IBEVSLHS.pls 115.2 2002/12/13 02:39:08 mannamra ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_Shop_List_Header_PKG';

-- Start of Comments
-- Package name     : IBE_Shop_List_Header_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Insert_Row(
   x_shp_list_id            OUT NOCOPY NUMBER  ,
   p_request_id             IN  NUMBER  ,
   p_program_application_id IN  NUMBER  ,
   p_program_id             IN  NUMBER  ,
   p_program_update_date    IN  DATE    ,
   p_object_version_number  IN  NUMBER  ,
   p_created_by             IN  NUMBER  ,
   p_creation_date          IN  DATE    ,
   p_last_updated_by        IN  NUMBER  ,
   p_last_update_date       IN  DATE    ,
   p_last_update_login      IN  NUMBER  ,
   p_party_id               IN  NUMBER  ,
   p_cust_account_id        IN  NUMBER  ,
   p_shopping_list_name     IN  VARCHAR2,
   p_description            IN  VARCHAR2,
   p_attribute_category     IN  VARCHAR2,
   p_attribute1             IN  VARCHAR2,
   p_attribute2             IN  VARCHAR2,
   p_attribute3             IN  VARCHAR2,
   p_attribute4             IN  VARCHAR2,
   p_attribute5             IN  VARCHAR2,
   p_attribute6             IN  VARCHAR2,
   p_attribute7             IN  VARCHAR2,
   p_attribute8             IN  VARCHAR2,
   p_attribute9             IN  VARCHAR2,
   p_attribute10            IN  VARCHAR2,
   p_attribute11            IN  VARCHAR2,
   p_attribute12            IN  VARCHAR2,
   p_attribute13            IN  VARCHAR2,
   p_attribute14            IN  VARCHAR2,
   p_attribute15            IN  VARCHAR2,
   p_org_id                 IN  NUMBER);


PROCEDURE Update_Row(
   p_shp_list_id            IN NUMBER  ,
   p_request_id             IN NUMBER  ,
   p_program_application_id IN NUMBER  ,
   p_program_id             IN NUMBER  ,
   p_program_update_date    IN DATE    ,
   p_object_version_number  IN NUMBER  ,
   p_created_by             IN NUMBER  ,
   p_creation_date          IN DATE    ,
   p_last_updated_by        IN NUMBER  ,
   p_last_update_date       IN DATE    ,
   p_last_update_login      IN NUMBER  ,
   p_party_id               IN NUMBER  ,
   p_cust_account_id        IN NUMBER  ,
   p_shopping_list_name     IN VARCHAR2,
   p_description            IN VARCHAR2,
   p_attribute_category     IN VARCHAR2,
   p_attribute1             IN VARCHAR2,
   p_attribute2             IN VARCHAR2,
   p_attribute3             IN VARCHAR2,
   p_attribute4             IN VARCHAR2,
   p_attribute5             IN VARCHAR2,
   p_attribute6             IN VARCHAR2,
   p_attribute7             IN VARCHAR2,
   p_attribute8             IN VARCHAR2,
   p_attribute9             IN VARCHAR2,
   p_attribute10            IN VARCHAR2,
   p_attribute11            IN VARCHAR2,
   p_attribute12            IN VARCHAR2,
   p_attribute13            IN VARCHAR2,
   p_attribute14            IN VARCHAR2,
   p_attribute15            IN VARCHAR2,
   p_org_id                 IN NUMBER);


PROCEDURE Delete_Row(
   p_shp_list_id           IN NUMBER,
   p_object_version_number IN NUMBER := FND_API.G_MISS_NUM
);

END IBE_Shop_List_Header_PKG;

 

/
