--------------------------------------------------------
--  DDL for Package Body JTF_PC_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PC_HIERARCHIES_PKG" AS
/*$Header: jtfpjphb.pls 120.2 2005/08/18 22:54:58 stopiwal ship $*/

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_NODE_ID in NUMBER,
  X_NODE_TYPE in VARCHAR2,
  X_NODE_REFERENCE in NUMBER,
  X_TOP_NODE_ID  in NUMBER,
  X_PARENT_NODE_ID in NUMBER,
  X_LEVEL_NUMBER in NUMBER,
  X_ACTIVE in VARCHAR2,
  X_ORG_ID in NUMBER DEFAULT NULL,
  X_DEPENDENT in VARCHAR2 DEFAULT NULL,
  X_START_DATE_EFFECTIVE in DATE,
  X_END_DATE_EFFECTIVE in DATE DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT NULL
) is

  CURSOR C is SELECT rowid FROM JTF_PC_HIERARCHIES
              WHERE  NODE_ID = X_Node_Id;
begin

INSERT INTO jtf_pc_hierarchies (
NODE_ID,
NODE_TYPE,
NODE_REFERENCE,
TOP_NODE_ID,
PARENT_NODE_ID,
OBJECT_VERSION_NUMBER,
LEVEL_NUMBER,
ACTIVE,
ORG_ID,
DEPENDENT,
START_DATE_EFFECTIVE,
END_DATE_EFFECTIVE,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15)
VALUES (
X_NODE_ID,
X_NODE_TYPE,
X_NODE_REFERENCE,
X_TOP_NODE_ID,
X_PARENT_NODE_ID,
1,
X_LEVEL_NUMBER,
X_ACTIVE,
X_ORG_ID,
X_DEPENDENT,
X_START_DATE_EFFECTIVE,
X_END_DATE_EFFECTIVE,
X_CREATED_BY,
X_CREATION_DATE,
X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN,
X_ATTRIBUTE_CATEGORY,
X_ATTRIBUTE1,
X_ATTRIBUTE2,
X_ATTRIBUTE3,
X_ATTRIBUTE4,
X_ATTRIBUTE5,
X_ATTRIBUTE6,
X_ATTRIBUTE7,
X_ATTRIBUTE8,
X_ATTRIBUTE9,
X_ATTRIBUTE10,
X_ATTRIBUTE11,
X_ATTRIBUTE12,
X_ATTRIBUTE13,
X_ATTRIBUTE14,
X_ATTRIBUTE15
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
     CLOSE C;
     Raise NO_DATA_FOUND;
  end if;
  CLOSE C;
  select count(node_id) into X_Rowid from jtf_pc_hierarchies;

end INSERT_ROW;

procedure LOCK_ROW (
  X_NODE_ID in NUMBER,
  X_NODE_TYPE in VARCHAR2,
  X_NODE_REFERENCE in NUMBER,
  X_TOP_NODE_ID  in NUMBER,
  X_PARENT_NODE_ID in NUMBER,
  X_LEVEL_NUMBER in NUMBER,
  X_ACTIVE in VARCHAR2,
  X_ORG_ID in NUMBER DEFAULT NULL,
  X_DEPENDENT in VARCHAR2 DEFAULT NULL,
  X_START_DATE_EFFECTIVE in DATE,
  X_END_DATE_EFFECTIVE in DATE DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL
) is

  CURSOR C is SELECT *
              FROM   jtf_pc_hierarchies
              WHERE  node_id = X_Node_Id
              FOR UPDATE of node_id NOWAIT;
  Recinfo C%ROWTYPE;

begin

  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
  end if;
  CLOSE C;
  if (    (Recinfo.node_id = X_Node_Id)
      AND (Recinfo.Node_Type = X_Node_Type)
      AND (Recinfo.Node_Reference = X_Node_Reference)
      AND (Recinfo.Top_Node_Id = X_Top_Node_Id)
      AND (Recinfo.Parent_Node_Id = X_Parent_Node_Id)
      AND (Recinfo.Active = X_Active)
      AND (Recinfo.Level_Number = X_Level_Number)
      AND ((Recinfo.Dependent = X_Dependent)
          OR ((Recinfo.Dependent IS NULL)
          AND (X_Dependent IS NULL)))
      AND ((Recinfo.Org_Id = X_Org_Id)
          OR ((Recinfo.Org_Id IS NULL)
          AND (X_Org_Id IS NULL)))
      AND (Recinfo.Start_Date_Effective = X_Start_Date_Effective)
      AND ((Recinfo.End_Date_Effective = X_End_Date_Effective)
          OR ((Recinfo.End_Date_Effective IS NULL)
          AND (X_End_Date_Effective IS NULL)))
      AND ((Recinfo.Attribute1 = X_Attribute1)
          OR ((Recinfo.Attribute1 IS NULL)
          AND (X_Attribute1 IS NULL)))
      AND ((Recinfo.Attribute2 = X_Attribute2)
          OR ((Recinfo.Attribute2 IS NULL)
          AND (X_Attribute2 IS NULL)))
      AND ((Recinfo.Attribute3 = X_Attribute3)
          OR ((Recinfo.Attribute3 IS NULL)
          AND (X_Attribute3 IS NULL)))
      AND ((Recinfo.Attribute4 = X_Attribute4)
          OR ((Recinfo.Attribute4 IS NULL)
          AND (X_Attribute4 IS NULL)))
      AND ((Recinfo.Attribute5 = X_Attribute5)
          OR ((Recinfo.Attribute5 IS NULL)
          AND (X_Attribute5 IS NULL)))
      AND ((Recinfo.Attribute6 = X_Attribute6)
          OR ((Recinfo.Attribute6 IS NULL)
          AND (X_Attribute6 IS NULL)))
      AND ((Recinfo.Attribute7 = X_Attribute7)
          OR ((Recinfo.Attribute7 IS NULL)
          AND (X_Attribute7 IS NULL)))
      AND ((Recinfo.Attribute8 = X_Attribute8)
          OR ((Recinfo.Attribute8 IS NULL)
          AND (X_Attribute8 IS NULL)))
      AND ((Recinfo.Attribute9 = X_Attribute9)
          OR ((Recinfo.Attribute9 IS NULL)
          AND (X_Attribute9 IS NULL)))
      AND ((Recinfo.Attribute10 = X_Attribute10)
          OR ((Recinfo.Attribute10 IS NULL)
          AND (X_Attribute10 IS NULL)))
      AND ((Recinfo.Attribute11 = X_Attribute11)
          OR ((Recinfo.Attribute11 IS NULL)
          AND (X_Attribute11 IS NULL)))
      AND ((Recinfo.Attribute12 = X_Attribute12)
          OR ((Recinfo.Attribute12 IS NULL)
          AND (X_Attribute12 IS NULL)))
      AND ((Recinfo.Attribute13 = X_Attribute13)
          OR ((Recinfo.Attribute13 IS NULL)
          AND (X_Attribute13 IS NULL)))
      AND ((Recinfo.Attribute14 = X_Attribute14)
          OR ((Recinfo.Attribute14 IS NULL)
          AND (X_Attribute14 IS NULL)))
      AND ((Recinfo.Attribute15 = X_Attribute15)
          OR ((Recinfo.Attribute15 IS NULL)
          AND (X_Attribute15 IS NULL)))
      AND ((Recinfo.Attribute_Category = X_Attribute_Category)
          OR ((Recinfo.Attribute_Category IS NULL)
          AND (X_Attribute_Category IS NULL)))
     ) then
      return;
  else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_NODE_ID in NUMBER,
  X_NODE_TYPE in VARCHAR2,
  X_NODE_REFERENCE in NUMBER,
  X_TOP_NODE_ID  in NUMBER,
  X_PARENT_NODE_ID in NUMBER,
  X_LEVEL_NUMBER in NUMBER,
  X_ACTIVE in VARCHAR2,
  X_ORG_ID in NUMBER DEFAULT NULL,
  X_DEPENDENT in VARCHAR2 DEFAULT NULL,
  X_START_DATE_EFFECTIVE in DATE,
  X_END_DATE_EFFECTIVE in DATE DEFAULT NULL,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT NULL
) is

begin

  UPDATE jtf_pc_hierarchies
  SET    node_type = X_Node_Type,
         node_reference = X_Node_Reference,
         top_node_id = X_Top_Node_Id,
         parent_node_id = X_Parent_Node_Id,
         level_number = X_Level_Number,
         active = X_Active,
         org_id = X_Org_Id,
         dependent = X_Dependent,
         start_date_effective = X_Start_Date_Effective,
         end_date_effective = X_End_Date_Effective,
         object_version_number = X_Object_Version_Number + 1,
         attribute_category = X_Attribute_Category,
         attribute1 = X_Attribute1,
         attribute2 = X_Attribute2,
         attribute3 = X_Attribute3,
         attribute4 = X_Attribute4,
         attribute5 = X_Attribute5,
         attribute6 = X_Attribute6,
         attribute7 = X_Attribute7,
         attribute8 = X_Attribute8,
         attribute9 = X_Attribute9,
         attribute10 = X_Attribute10,
         attribute11 = X_Attribute11,
         attribute12 = X_Attribute12,
         attribute13 = X_Attribute13,
         attribute14 = X_Attribute14,
         attribute15 = X_Attribute15,
         last_update_date = X_Last_Update_Date,
         last_updated_by = X_Last_Updated_By,
         last_update_login = X_Last_Update_Login
  WHERE  node_id = X_Node_Id
  AND object_version_number = X_Object_Version_Number;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_NODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is

begin

  DELETE FROM jtf_pc_hierarchies
  WHERE  node_id = X_Node_Id
  AND object_version_number = X_Object_Version_Number;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

end DELETE_ROW;

/*procedure LOAD_ROW (
  X_NODE_ID in NUMBER,
  X_NODE_TYPE in VARCHAR2,
  X_NODE_REFERENCE in NUMBER,
  X_TOP_NODE_ID  in NUMBER,
  X_PARENT_NODE_ID in NUMBER,
  X_LEVEL_NUMBER in NUMBER,
  X_ACTIVE in VARCHAR2,
  X_ORG_ID in NUMBER DEFAULT NULL,
  X_DEPENDENT in VARCHAR2 DEFAULT NULL,
  X_START_DATE_EFFECTIVE in DATE,
  X_END_DATE_EFFECTIVE in DATE DEFAULT NULL,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL
) is

  h_record_exists       number(15);

  user_id               number;
  row_id                varchar2(64);

begin

     user_id := 1;

  select count(*)
  into   h_record_exists
  from   jtf_pc_hierarchies
  where  node_id = X_Node_Id;

  if (h_record_exists > 0) then
     jtf_pc_hierarchies_pkg.update_row (
	X_Node_Id			=> X_Node_Id,
    X_Node_Type         => X_Node_Type,
    X_Node_Reference    => X_Node_Reference,
	X_Top_Node_Id			=> X_Top_Node_Id,
	X_Parent_Node_Id		=> X_Parent_Node_Id,
    X_Level_Number          => X_Level_Number,
    X_Org_Id                => X_Org_Id,
    X_Dependent             => X_Dependent,
    X_Active                => X_Active,
	X_Start_Date_Effective	=> X_Start_Date_Effective,
	X_End_Date_Effective	=> X_End_Date_Effective,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Attribute_Category	=> X_Attribute_Category,
    X_Object_Version_Number => X_Object_Version_Number,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
     );
  else
     jtf_pc_hierarchies_pkg.insert_row (
	X_Rowid				=> row_id,
	X_Node_Id			=> X_Node_Id,
    X_Node_Type         => X_Node_Type,
    X_Node_Reference    => X_Node_Reference,
	X_Top_Node_Id			=> X_Top_Node_Id,
	X_Parent_Node_Id		=> X_Parent_Node_Id,
    X_Level_Number          => X_Level_Number,
    X_Org_Id                => X_Org_Id,
    X_Dependent             => X_Dependent,
    X_Active                => X_Active,
	X_Start_Date_Effective	=> X_Start_Date_Effective,
	X_End_Date_Effective	=> X_End_Date_Effective,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Attribute_Category	=> X_Attribute_Category,
	X_Creation_Date			=> sysdate,
	X_Created_By			=> user_id,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
     );
  end if;

end LOAD_ROW;*/

END JTF_PC_HIERARCHIES_PKG;

/
