--------------------------------------------------------
--  DDL for Package IBE_SHOPLIST_LINE_RELATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SHOPLIST_LINE_RELATION_PKG" AUTHID CURRENT_USER AS
/* $Header: IBEVSLRS.pls 115.3 2002/12/21 08:09:05 ajlee ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_ShopList_Line_Relation_PKG';

-- Start of Comments
-- Package name     : IBE_Shop_List_Line_Relationship_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Insert_Row(
   x_shlitem_rel_id           OUT NOCOPY NUMBER  ,
   p_request_id               IN  NUMBER  ,
   p_program_application_id   IN  NUMBER  ,
   p_program_id               IN  NUMBER  ,
   p_program_update_date      IN  DATE    ,
   p_object_version_number    IN  NUMBER  ,
   p_created_by               IN  NUMBER  ,
   p_creation_date            IN  DATE    ,
   p_last_updated_by          IN  NUMBER  ,
   p_last_update_date         IN  DATE    ,
   p_last_update_login        IN  NUMBER  ,
   p_shp_list_item_id         IN  NUMBER  ,
   p_related_shp_list_item_id IN  NUMBER  ,
   p_relationship_type_code   IN  VARCHAR2
);


PROCEDURE Update_Row(
   p_shlitem_rel_id           IN NUMBER  ,
   p_request_id               IN NUMBER  ,
   p_program_application_id   IN NUMBER  ,
   p_program_id               IN NUMBER  ,
   p_program_update_date      IN DATE    ,
   p_object_version_number    IN NUMBER  ,
   p_created_by               IN NUMBER  ,
   p_creation_date            IN DATE    ,
   p_last_updated_by          IN NUMBER  ,
   p_last_update_date         IN DATE    ,
   p_last_update_login        IN NUMBER  ,
   p_shp_list_item_id         IN NUMBER  ,
   p_related_shp_list_item_id IN NUMBER  ,
   p_relationship_type_code   IN VARCHAR2
);


PROCEDURE Delete_Row(p_shlitem_rel_id IN NUMBER);

END IBE_ShopList_Line_Relation_PKG;

 

/
