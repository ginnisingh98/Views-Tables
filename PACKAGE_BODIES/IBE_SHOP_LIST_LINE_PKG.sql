--------------------------------------------------------
--  DDL for Package Body IBE_SHOP_LIST_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SHOP_LIST_LINE_PKG" AS
/* $Header: IBEVSLLB.pls 120.1 2005/08/28 21:50:58 appldev ship $ */

-- Start of comments
-- Package name  : IBE_Shop_List_Line_PKG
--    Function   :
--    Parameters :
--    Version    : Current version	1.0
--    Notes      :
--
-- End of comments
l_true VARCHAR2(1) := FND_API.G_TRUE;

PROCEDURE Insert_Row(
   x_shp_list_item_id            OUT NOCOPY NUMBER  ,
   p_object_version_number       IN  NUMBER  ,
   p_creation_date               IN  DATE    ,
   p_created_by                  IN  NUMBER  ,
   p_last_updated_by             IN  NUMBER  ,
   p_last_update_date            IN  DATE    ,
   p_last_update_login           IN  NUMBER  ,
   p_request_id                  IN  NUMBER  ,
   p_program_id                  IN  NUMBER  ,
   p_program_application_id      IN  NUMBER  ,
   p_program_update_date         IN  DATE    ,
   p_shp_list_id                 IN  NUMBER  ,
   p_inventory_item_id           IN  NUMBER  ,
   p_organization_id             IN  NUMBER  ,
   p_uom_code                    IN  VARCHAR2,
   p_quantity                    IN  NUMBER  ,
   p_config_header_id            IN  NUMBER  ,
   p_config_revision_num         IN  NUMBER  ,
   p_complete_configuration_flag IN  VARCHAR2,
   p_valid_configuration_flag    IN  VARCHAR2,
   p_item_type_code              IN  VARCHAR2,
   p_attribute_category          IN  VARCHAR2,
   p_attribute1                  IN  VARCHAR2,
   p_attribute2                  IN  VARCHAR2,
   p_attribute3                  IN  VARCHAR2,
   p_attribute4                  IN  VARCHAR2,
   p_attribute5                  IN  VARCHAR2,
   p_attribute6                  IN  VARCHAR2,
   p_attribute7                  IN  VARCHAR2,
   p_attribute8                  IN  VARCHAR2,
   p_attribute9                  IN  VARCHAR2,
   p_attribute10                 IN  VARCHAR2,
   p_attribute11                 IN  VARCHAR2,
   p_attribute12                 IN  VARCHAR2,
   p_attribute13                 IN  VARCHAR2,
   p_attribute14                 IN  VARCHAR2,
   p_attribute15                 IN  VARCHAR2,
   p_org_id                      IN  NUMBER
)
IS
   CURSOR C2 IS SELECT IBE_SH_SHP_LIST_ITEMS_S1.nextval FROM sys.dual;
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('start IBE_Shop_List_LINE_PKG.Insert row');
   END IF;
   INSERT INTO ibe_shp_list_items_all(
      shp_list_item_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      shp_list_id,
      inventory_item_id,
      organization_id,
      uom_code,
      quantity,
      config_header_id,
      config_revision_num,
      complete_configuration_flag,
      valid_configuration_flag,
      item_type_code,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      org_id
   )
   VALUES(
      ibe_sh_shp_list_items_s1.NEXTVAL,
      DECODE(p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id),
      DECODE(p_program_application_id, FND_API.G_MISS_NUM, NULL, p_program_application_id),
      DECODE(p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
      DECODE(p_program_update_date, FND_API.G_MISS_DATE, NULL, p_program_update_date),
      1,
      FND_Global.User_ID,
      SYSDATE,
      FND_Global.User_ID,
      SYSDATE,
      FND_Global.Login_ID,
      p_shp_list_id,
      p_inventory_item_id,
      p_organization_id,
      p_uom_code,
      p_quantity,
      DECODE(p_config_header_id, FND_API.G_MISS_NUM, NULL, p_config_header_id),
      DECODE(p_config_revision_num, FND_API.G_MISS_NUM, NULL, p_config_revision_num),
      DECODE(p_complete_configuration_flag, FND_API.G_MISS_CHAR, NULL, p_complete_configuration_flag),
      DECODE(p_valid_configuration_flag, FND_API.G_MISS_CHAR, NULL, p_valid_configuration_flag),
      DECODE(p_item_type_code, FND_API.G_MISS_CHAR, NULL, p_item_type_code),
      DECODE(p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category),
      DECODE(p_attribute1,  FND_API.G_MISS_CHAR, NULL, p_attribute1),
      DECODE(p_attribute2,  FND_API.G_MISS_CHAR, NULL, p_attribute2),
      DECODE(p_attribute3,  FND_API.G_MISS_CHAR, NULL, p_attribute3),
      DECODE(p_attribute4,  FND_API.G_MISS_CHAR, NULL, p_attribute4),
      DECODE(p_attribute5,  FND_API.G_MISS_CHAR, NULL, p_attribute5),
      DECODE(p_attribute6,  FND_API.G_MISS_CHAR, NULL, p_attribute6),
      DECODE(p_attribute7,  FND_API.G_MISS_CHAR, NULL, p_attribute7),
      DECODE(p_attribute8,  FND_API.G_MISS_CHAR, NULL, p_attribute8),
      DECODE(p_attribute9,  FND_API.G_MISS_CHAR, NULL, p_attribute9),
      DECODE(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
      DECODE(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
      DECODE(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
      DECODE(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
      DECODE(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
      DECODE(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15),
      DECODE(p_org_id, FND_API.G_MISS_NUM, MO_GLOBAL.get_current_org_id(), p_org_id))
RETURNING shp_list_item_id INTO x_shp_list_item_id;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Exit IBE_Shop_List_line_PKG.Insert row');
   END IF;
END Insert_Row;


PROCEDURE Update_Row(
   p_shp_list_item_id            IN NUMBER  ,
   p_object_version_number       IN NUMBER  ,
   p_creation_date               IN DATE    ,
   p_created_by                  IN NUMBER  ,
   p_last_updated_by             IN NUMBER  ,
   p_last_update_date            IN DATE    ,
   p_last_update_login           IN NUMBER  ,
   p_request_id                  IN NUMBER  ,
   p_program_id                  IN NUMBER  ,
   p_program_application_id      IN NUMBER  ,
   p_program_update_date         IN DATE    ,
   p_shp_list_id                 IN NUMBER  ,
   p_inventory_item_id           IN NUMBER  ,
   p_organization_id             IN NUMBER  ,
   p_uom_code                    IN VARCHAR2,
   p_quantity                    IN NUMBER  ,
   p_config_header_id            IN NUMBER  ,
   p_config_revision_num         IN NUMBER  ,
   p_complete_configuration_flag IN VARCHAR2,
   p_valid_configuration_flag    IN VARCHAR2,
   p_item_type_code              IN VARCHAR2,
   p_attribute_category          IN VARCHAR2,
   p_attribute1                  IN VARCHAR2,
   p_attribute2                  IN VARCHAR2,
   p_attribute3                  IN VARCHAR2,
   p_attribute4                  IN VARCHAR2,
   p_attribute5                  IN VARCHAR2,
   p_attribute6                  IN VARCHAR2,
   p_attribute7                  IN VARCHAR2,
   p_attribute8                  IN VARCHAR2,
   p_attribute9                  IN VARCHAR2,
   p_attribute10                 IN VARCHAR2,
   p_attribute11                 IN VARCHAR2,
   p_attribute12                 IN VARCHAR2,
   p_attribute13                 IN VARCHAR2,
   p_attribute14                 IN VARCHAR2,
   p_attribute15                 IN VARCHAR2,
   p_org_id                      IN NUMBER
)
IS
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Start IBE_Shop_List_line_PKG.update_row');
   END IF;

   UPDATE ibe_shp_list_items_all
   SET request_id = DECODE(p_request_id, FND_API.G_MISS_NUM, request_id, p_request_id),
       program_application_id = DECODE(p_program_application_id, FND_API.G_MISS_NUM, program_application_id, p_program_application_id),
       program_id = DECODE(p_program_id, FND_API.G_MISS_NUM, program_id, p_program_id),
       program_update_date = DECODE(p_program_update_date, FND_API.G_MISS_DATE, program_update_date, p_program_update_date),
       object_version_number = object_version_number + 1,
       created_by = created_by,
       creation_date = creation_date,
       last_updated_by = FND_Global.User_ID,
       last_update_date = SYSDATE,
       last_update_login = FND_Global.Login_ID,
       shp_list_id = shp_list_id,
       inventory_item_id = inventory_item_id,
       organization_id = organization_id,
       uom_code = DECODE(p_uom_code, FND_API.G_MISS_CHAR, uom_code, p_uom_code),
       quantity = DECODE(p_quantity, FND_API.G_MISS_NUM, quantity, p_quantity),
       config_header_id = DECODE(p_config_header_id, FND_API.G_MISS_NUM, config_header_id, p_config_header_id),
       config_revision_num = DECODE(p_config_revision_num, FND_API.G_MISS_NUM, config_revision_num, p_config_revision_num),
       complete_configuration_flag = DECODE(p_complete_configuration_flag, FND_API.G_MISS_CHAR, complete_configuration_flag, p_complete_configuration_flag),
       valid_configuration_flag = DECODE(p_valid_configuration_flag, FND_API.G_MISS_CHAR, valid_configuration_flag, p_valid_configuration_flag),
       item_type_code = DECODE(p_item_type_code, FND_API.G_MISS_CHAR, item_type_code, p_item_type_code),
       attribute_category = DECODE(p_attribute_category, FND_API.G_MISS_CHAR, attribute_category, p_attribute_category),
       attribute1  = DECODE(p_attribute1,  FND_API.G_MISS_CHAR, attribute1,  p_attribute1),
       attribute2  = DECODE(p_attribute2,  FND_API.G_MISS_CHAR, attribute2,  p_attribute2),
       attribute3  = DECODE(p_attribute3,  FND_API.G_MISS_CHAR, attribute3,  p_attribute3),
       attribute4  = DECODE(p_attribute4,  FND_API.G_MISS_CHAR, attribute4,  p_attribute4),
       attribute5  = DECODE(p_attribute5,  FND_API.G_MISS_CHAR, attribute5,  p_attribute5),
       attribute6  = DECODE(p_attribute6,  FND_API.G_MISS_CHAR, attribute6,  p_attribute6),
       attribute7  = DECODE(p_attribute7,  FND_API.G_MISS_CHAR, attribute7,  p_attribute7),
       attribute8  = DECODE(p_attribute8,  FND_API.G_MISS_CHAR, attribute8,  p_attribute8),
       attribute9  = DECODE(p_attribute9,  FND_API.G_MISS_CHAR, attribute9,  p_attribute9),
       attribute10 = DECODE(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10),
       attribute11 = DECODE(p_attribute11, FND_API.G_MISS_CHAR, attribute11, p_attribute11),
       attribute12 = DECODE(p_attribute12, FND_API.G_MISS_CHAR, attribute12, p_attribute12),
       attribute13 = DECODE(p_attribute13, FND_API.G_MISS_CHAR, attribute13, p_attribute13),
       attribute14 = DECODE(p_attribute14, FND_API.G_MISS_CHAR, attribute14, p_attribute14),
       attribute15 = DECODE(p_attribute15, FND_API.G_MISS_CHAR, attribute15, p_attribute15),
       org_id      = org_id
   WHERE shp_list_item_id = p_shp_list_item_id
     AND object_version_number = DECODE(p_object_version_number, FND_API.G_MISS_NUM, object_version_number, p_object_version_number);
    IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Exit IBE_Shop_List_line_PKG.update_row');
    END IF;
END Update_Row;


PROCEDURE Delete_Row(
   p_shp_list_item_id      IN NUMBER,
   p_object_version_number IN NUMBER := FND_API.G_MISS_NUM
)
IS
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('start IBE_Shop_List_line_PKG.delete row');
   END IF;
   DELETE
   FROM ibe_shp_list_items_all
   WHERE shp_list_item_id      = p_shp_list_item_id
     AND object_version_number = DECODE(p_object_version_number, FND_API.G_MISS_NUM, object_version_number, p_object_version_number);

   IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
   END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Exit IBE_Shop_List_line_PKG.delete row');
   END IF;
END Delete_Row;

END IBE_Shop_List_Line_PKG;

/
