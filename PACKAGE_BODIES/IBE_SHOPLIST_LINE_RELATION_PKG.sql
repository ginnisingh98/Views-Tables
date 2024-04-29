--------------------------------------------------------
--  DDL for Package Body IBE_SHOPLIST_LINE_RELATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SHOPLIST_LINE_RELATION_PKG" AS
/* $Header: IBEVSLRB.pls 115.2 2002/12/21 06:44:48 ajlee ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_ShopList_Line_Relation_PKG';
l_true VARCHAR2(1) := FND_API.G_TRUE;

-- Start of Comments
-- Package name     : IBE_ShopList_Line_Relation_PKG
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
)
IS
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('start IBE_ShopList_Line_relation_PKG.Insert row');
   END IF;

   INSERT INTO ibe_sh_shlitem_rels
   (
      shlitem_rel_id          ,
      request_id              ,
      program_application_id  ,
      program_id              ,
      program_update_date     ,
      object_version_number   ,
      created_by              ,
      creation_date           ,
      last_updated_by         ,
      last_update_date        ,
      last_update_login       ,
      shp_list_item_id        ,
      related_shp_list_item_id,
      relationship_type_code
   )
   VALUES
   (
      ibe_sh_shlitem_rels_s1.NEXTVAL,
      DECODE(p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id),
      DECODE(p_program_application_id, FND_API.G_MISS_NUM, NULL, p_program_application_id),
      DECODE(p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
      DECODE(p_program_update_date, FND_API.G_MISS_DATE, NULL, p_program_update_date),
      1,
      FND_Global.User_Id,
      SYSDATE,
      FND_Global.User_Id,
      SYSDATE,
      FND_Global.Login_Id,
      p_shp_list_item_id,
      p_related_shp_list_item_id,
      p_relationship_type_code
   )
   RETURNING shlitem_rel_id INTO x_shlitem_rel_id;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Exit IBE_ShopList_Line_relation_PKG.Insert row');
   END IF;

END Insert_Row;



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
)
IS
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('start IBE_ShopList_Line_relation_PKG.Update row');
   END IF;

    UPDATE ibe_sh_shlitem_rels
    SET request_id = DECODE(p_request_id, FND_API.G_MISS_NUM, request_id, p_request_id),
        program_application_id = DECODE(p_program_application_id, FND_API.G_MISS_NUM, program_application_id, p_program_application_id),
        program_id = DECODE(p_program_id, FND_API.G_MISS_NUM, program_id, p_program_id),
        program_update_date = DECODE(p_program_update_date, fnd_api.g_miss_date, program_update_date, p_program_update_date),
        object_version_number = object_version_number + 1,
        created_by = created_by,
        creation_date = creation_date,
        last_updated_by = FND_Global.User_Id,
        last_update_date = SYSDATE,
        last_update_login = FND_Global.Login_Id,
        shp_list_item_id = DECODE(p_shp_list_item_id, FND_API.G_MISS_NUM, shp_list_item_id, p_shp_list_item_id),
        related_shp_list_item_id = DECODE(p_related_shp_list_item_id, FND_API.G_MISS_NUM, related_shp_list_item_id, p_related_shp_list_item_id),
        relationship_type_code = DECODE(p_relationship_type_code, FND_API.G_MISS_CHAR, relationship_type_code, p_relationship_type_code)
    WHERE shlitem_rel_id = p_shlitem_rel_id;

    IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Exit IBE_ShopList_Line_relation_PKG.update row');
    END IF;

END Update_Row;


PROCEDURE Delete_Row(p_shlitem_rel_id IN NUMBER)
IS
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('start IBE_ShopList_Line_relation_PKG.Delete row');
   END IF;

   DELETE
   FROM IBE_SH_SHLITEM_RELS
   WHERE SHLITEM_REL_ID = p_SHLITEM_REL_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Exit IBE_ShopList_Line_relation_PKG.Delete row');
   END IF;

END Delete_Row;

END IBE_ShopList_Line_Relation_PKG;

/
