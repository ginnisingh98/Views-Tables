--------------------------------------------------------
--  DDL for Package BOM_STRUCTURE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_STRUCTURE_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: BOMPSTYPS.pls 120.0 2005/05/25 05:28:58 appldev noship $ */

  PROCEDURE Insert_Row(X_Structure_Type_Name         VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Item_Catalog_Group_Id          NUMBER,
                       X_Effective_Date                 DATE,
                       X_Structure_Creation_Allowed     VARCHAR2,
                       X_Allow_Subtypes			VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Disable_Date                   VARCHAR2,
                       X_Parent_Structure_Type_Id       NUMBER,
                       X_Enable_Attachments_Flag        VARCHAR2,
                       X_Display_Name                   VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Upload_mode                    VARCHAR2,
		       X_Custom_mode			VARCHAR2,
                       X_Owner				VARCHAR2
                      );


-- Procedures for BOM_STRUCTURE_TYPES_VL Table Handlers ----
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_STRUCTURE_TYPE_ID in NUMBER,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_STRUCTURE_TYPE_NAME in VARCHAR2,
  X_ITEM_CATALOG_GROUP_ID in NUMBER,
  X_EFFECTIVE_DATE in DATE,
  X_STRUCTURE_CREATION_ALLOWED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_STRUCTURE_TYPE_ID in NUMBER,
  X_ENABLE_ATTACHMENTS_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_UNIMPLEMENTED_BOMS IN VARCHAR2,
  X_ALLOW_SUBTYPES IN VARCHAR2
  );
procedure LOCK_ROW (
  X_STRUCTURE_TYPE_ID in NUMBER,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_STRUCTURE_TYPE_NAME in VARCHAR2,
  X_ITEM_CATALOG_GROUP_ID in NUMBER,
  X_EFFECTIVE_DATE in DATE,
  X_STRUCTURE_CREATION_ALLOWED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_STRUCTURE_TYPE_ID in NUMBER,
  X_ENABLE_ATTACHMENTS_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ENABLE_UNIMPLEMENTED_BOMS IN VARCHAR2,
  X_ALLOW_SUBTYPES IN VARCHAR2
);
procedure UPDATE_ROW (
  X_STRUCTURE_TYPE_ID in NUMBER,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_STRUCTURE_TYPE_NAME in VARCHAR2,
  X_ITEM_CATALOG_GROUP_ID in NUMBER,
  X_EFFECTIVE_DATE in DATE,
  X_STRUCTURE_CREATION_ALLOWED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_STRUCTURE_TYPE_ID in NUMBER,
  X_ENABLE_ATTACHMENTS_FLAG in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_UNIMPLEMENTED_BOMS IN VARCHAR2,
  X_ALLOW_SUBTYPES IN VARCHAR2
);
procedure DELETE_ROW (
  X_STRUCTURE_TYPE_ID in NUMBER
);

PROCEDURE Check_If_Connected(
  p_parent_structure_type_id     IN NUMBER,
  p_structure_type_id            IN NUMBER,
  x_return_status                OUT NOCOPY VARCHAR2
);

PROCEDURE   ADD_LANGUAGE;

-- End of Procedures for BOM_STRUCTURE_TYPES_VL Table Handlers ----
END BOM_STRUCTURE_TYPES_PKG;

 

/
