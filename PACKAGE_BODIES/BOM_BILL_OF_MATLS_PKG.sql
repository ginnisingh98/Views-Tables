--------------------------------------------------------
--  DDL for Package Body BOM_BILL_OF_MATLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BILL_OF_MATLS_PKG" as
/* $Header: bompibmb.pls 120.8 2006/06/11 19:32:05 seradhak ship $ */

PROCEDURE Populate_Fields(
  P_Bill_Sequence_Id in number,
  P_Item_Seq_Increment in number,
  P_Current_Rev IN OUT NOCOPY varchar2,
  P_Base_Model IN OUT NOCOPY varchar2,
  P_Base_Model_Desc IN OUT NOCOPY varchar2,
  P_Common_Item IN OUT NOCOPY varchar2,
  P_Common_Description IN OUT NOCOPY varchar2,
  P_Item_Num_Default IN OUT NOCOPY number,
  P_Common_Org_Code IN OUT NOCOPY varchar2,
  P_Common_Org_Name IN OUT NOCOPY varchar2) IS

  Cursor GetBillInfo is
    Select bom.assembly_item_id,
           bom.organization_id,
           bom.common_bill_sequence_id,
           bom.common_assembly_item_id,
           bom.common_organization_id,
           msi.base_item_id,
           bom.source_bill_sequence_id
    From bom_bill_of_materials bom,
         mtl_system_items msi
    Where bom.bill_sequence_id = P_Bill_Sequence_id
    and   msi.inventory_item_id = bom.assembly_item_id
    and   msi.organization_id = bom.organization_id;
  Cursor GetCommon (P_Common_Assembly_Item_Id number,
  P_Common_Organization_Id number) is
    Select mif.item_number part,
           mif.description description
    From mtl_item_flexfields mif
    Where mif.inventory_item_id = P_Common_Assembly_Item_Id
    And   mif.organization_id = P_Common_Organization_Id;
  Cursor GetCommonOrg (P_Common_Organization_Id number) is
    SELECT mp.organization_code ORGANIZATION_CODE, hou.name ORGANIZATION_NAME
    FROM hr_all_organization_units_vl hou,
         mtl_parameters mp
    WHERE mp.organization_id = hou.organization_id
    AND hou.organization_id = P_Common_Organization_Id;
  Cursor GetBaseModel (P_Base_Item_Id number, P_Org_Id number) is
    Select mif.item_number part,
           mif.description description
    From mtl_item_flexfields mif
    Where mif.inventory_item_id = P_Base_Item_Id
    And   mif.organization_id = P_Org_Id;
  CURSOR GetItemSeq IS
      SELECT nvl(max(item_num), 0) + P_Item_Seq_Increment default_seq
        FROM bom_inventory_components
       WHERE bill_sequence_id = P_Bill_Sequence_Id;
   No_Revision_Found       EXCEPTION;
   Pragma exception_init(no_revision_found, -20001);
BEGIN
  For X_Bill in GetBillInfo loop
    BEGIN
    BOM_REVISIONS.Get_Revision(
    type    => 'PART',
    eco_status    => 'ALL',
      examine_type  => 'IMPL_ONLY',
    org_id    => X_Bill.Organization_Id,
    item_id   => X_Bill.Assembly_Item_Id,
    rev_date  => sysdate,
    itm_rev   => P_Current_Rev);
    EXCEPTION
       WHEN no_revision_found THEN
          null;
    END;
    IF X_Bill.source_bill_sequence_id <> P_bill_sequence_id THEN
      FOR X_CommonItem in GetCommon
      (P_Common_Assembly_Item_Id => X_Bill.common_assembly_item_id,
       P_Common_Organization_Id =>  X_Bill.common_organization_id) LOOP
         P_Common_Item := X_CommonItem.Part;
         P_Common_Description := X_CommonItem.Description;
      END LOOP; -- common
      FOR X_CommonOrg in GetCommonOrg
      (P_Common_Organization_Id =>  X_Bill.common_organization_id) LOOP
         P_Common_Org_Code := X_CommonOrg.ORGANIZATION_CODE;
         P_Common_Org_Name := X_CommonOrg.ORGANIZATION_NAME;
      END LOOP; -- Common Org
    Else
      P_Common_Item := null;
      P_Common_Description := null;
      P_Common_Org_Code := null;
      P_Common_Org_Name := null;
    END IF;

    IF X_Bill.base_item_id is NOT NULL THEN
      FOR X_BaseModel in GetBaseModel
      (P_Base_Item_Id => X_Bill.base_item_id,
       P_Org_Id => X_Bill.organization_id) LOOP
         P_Base_Model := X_BaseModel.Part;
         P_Base_Model_Desc := X_BaseModel.Description;
      END LOOP; -- base model
    Else
      P_Base_Model := null;
      P_Base_Model_Desc := null;
    END IF;

    -- Set Item Num default value
    FOR X_Increment IN GetItemSeq LOOP
      /*IF X_Increment.default_seq <= 9999 then
        P_Item_Num_Default := X_increment.default_seq;
      Else
        P_Item_Num_Default := 9999;
      End if;*/
      P_Item_Num_Default := X_increment.default_seq;
    END LOOP; -- increment
  End loop; -- bill
END Populate_Fields;

PROCEDURE Check_Unique(X_Rowid        VARCHAR2,
           X_Assembly_Item_Id   NUMBER,
           X_Alternate_Bom_Designator VARCHAR2,
           X_Organization_Id    NUMBER) IS
   dummy  NUMBER;
BEGIN
   SELECT 1 INTO dummy FROM dual
    WHERE not exists
          (SELECT 1 FROM bom_bill_of_materials
            WHERE assembly_item_id = X_Assembly_item_id
              AND nvl(alternate_bom_designator,'no alt') =
                  nvl(X_alternate_bom_designator,'no alt')
        AND organization_id = X_organization_id
        AND ((X_rowid is NULL) OR (rowid <> X_rowid))
          );
   EXCEPTION
      WHEN no_data_found THEN
         Fnd_Message.Set_Name('BOM','BOM_BILL_ALREADY_EXISTS');
         Fnd_Message.Set_Token('ENTITY','BILL OF MATERIAL', TRUE);
         App_Exception.Raise_Exception;
END Check_Unique;

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Assembly_Item_Id               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Common_Assembly_Item_Id        NUMBER,
                       X_Specific_Assembly_Comment      VARCHAR2,
                       X_Pending_From_Ecn               VARCHAR2,
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
                       X_Assembly_Type                  NUMBER,
                       X_Common_Bill_Sequence_Id        IN OUT NOCOPY NUMBER,
                       X_Bill_Sequence_Id               IN OUT NOCOPY NUMBER,
                       X_Common_Organization_Id         NUMBER,
                       X_Next_Explode_Date              DATE,
                       X_structure_type_id              NUMBER := NULL,
                       X_implementation_date            DATE   := NULL,
                       X_effectivity_control            NUMBER := NULL

  ) IS
     l_preferred_flag Varchar2(1);
     x_err_text   varchar2(2000);
    CURSOR C IS SELECT rowid FROM BOM_BILL_OF_MATERIALS
                 WHERE bill_sequence_id = X_Bill_Sequence_Id;
      CURSOR C2 IS SELECT bom_inventory_components_s.nextval FROM sys.dual;
   BEGIN
      if (X_Bill_Sequence_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Bill_Sequence_Id;
        CLOSE C2;
      end if;
      IF (X_Common_Assembly_Item_Id is NULL) THEN
        X_Common_Bill_Sequence_Id := X_Bill_Sequence_Id;
      ELSE
        SELECT bill_sequence_id
          INTO X_Common_Bill_Sequence_Id
          FROM bom_bill_of_materials
         WHERE organization_id = X_Common_Organization_Id
           AND bill_sequence_id = common_bill_sequence_id
           AND assembly_item_id = X_Common_Assembly_Item_Id
           AND NVL(alternate_bom_designator, 'NONE') =
               NVL(X_Alternate_Bom_Designator,'NONE');
      END IF;
      l_preferred_flag := BOM_Validate.Is_Preferred_Structure
                       (p_assembly_item_id => X_Assembly_item_Id,
                        p_organization_id => X_Organization_Id,
                        p_alternate_bom_code => X_Alternate_Bom_Designator,
                        x_err_text => x_err_text);

       INSERT INTO BOM_BILL_OF_MATERIALS
       (      assembly_item_id,
              organization_id,
              alternate_bom_designator,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              common_assembly_item_id,
              specific_assembly_comment,
              pending_from_ecn,
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
              assembly_type,
              common_bill_sequence_id,
              bill_sequence_id,
              common_organization_id,
              next_explode_date,
        structure_type_id,
        implementation_date,
              effectivity_control,
              is_preferred,
              source_bill_sequence_id,
              pk1_value,
              pk2_value
             ) VALUES (
              X_Assembly_Item_Id,
              X_Organization_Id,
              X_Alternate_Bom_Designator,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Common_Assembly_Item_Id,
              X_Specific_Assembly_Comment,
              X_Pending_From_Ecn,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Assembly_Type,
              X_Common_Bill_Sequence_Id,
              X_Bill_Sequence_Id,
              X_Common_Organization_Id,
              X_Next_Explode_Date,
        X_structure_type_id,
        X_implementation_date,
        X_effectivity_control,
              decode ( l_preferred_flag, 'N',null,'Y'),
              X_Common_Bill_Sequence_Id,
              X_Assembly_Item_Id,
              X_Organization_Id
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;


 -- Raising Business event      4306013
  Bom_Business_Event_PKG.Raise_Bill_Event
     (p_pk1_value => X_Assembly_Item_Id
      , p_pk2_value          => X_Organization_Id
      , p_obj_name           => NULL
      , p_structure_name     => X_Alternate_Bom_Designator
      , p_organization_id    => X_Organization_Id
      , p_structure_comment  => X_Specific_Assembly_Comment
      , p_Event_Load_Type => 'Single'
      , p_Event_Entity_Name => 'Structure'
      , p_Event_Entity_Parent_Id  => X_Bill_Sequence_Id
      , p_Event_Name => Bom_Business_Event_PKG.G_STRUCTURE_CREATION_EVENT
      , p_last_update_date => X_Last_Update_Date
      , p_last_updated_by  => X_Last_Updated_By
      , p_creation_date    => X_Creation_Date
      , p_created_by       => X_Created_By
      , p_last_update_login=> X_Last_Update_Login
      );
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Assembly_Item_Id                 NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Alternate_Bom_Designator         VARCHAR2,
                     X_Common_Assembly_Item_Id          NUMBER,
                     X_Specific_Assembly_Comment        VARCHAR2,
                     X_Pending_From_Ecn                 VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Assembly_Type                    NUMBER,
                     X_Common_Bill_Sequence_Id          NUMBER,
                     X_Bill_Sequence_Id                 NUMBER,
                     X_Common_Organization_Id           NUMBER,
                     X_Next_Explode_Date                DATE,
                     X_structure_type_id                NUMBER := NULL,
                     X_implementation_date              DATE   := NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   BOM_BILL_OF_MATERIALS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Bill_Sequence_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.assembly_item_id =  X_Assembly_Item_Id)
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (   (Recinfo.alternate_bom_designator =  X_Alternate_Bom_Designator)
                OR (    (Recinfo.alternate_bom_designator IS NULL)
                    AND (X_Alternate_Bom_Designator IS NULL)))
           AND (   (Recinfo.common_assembly_item_id =  X_Common_Assembly_Item_Id)
                OR (    (Recinfo.common_assembly_item_id IS NULL)
                    AND (X_Common_Assembly_Item_Id IS NULL)))
           AND (   (Recinfo.specific_assembly_comment =  X_Specific_Assembly_Comment)
                OR (    (Recinfo.specific_assembly_comment IS NULL)
                    AND (X_Specific_Assembly_Comment IS NULL)))
           AND (   (Recinfo.pending_from_ecn =  X_Pending_From_Ecn)
                OR (    (Recinfo.pending_from_ecn IS NULL)
                    AND (X_Pending_From_Ecn IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (Recinfo.assembly_type =  X_Assembly_Type)
           AND (Recinfo.common_bill_sequence_id =  X_Common_Bill_Sequence_Id)
           AND (Recinfo.bill_sequence_id =  X_Bill_Sequence_Id)
           AND (   (Recinfo.common_organization_id =  X_Common_Organization_Id)
                OR (    (Recinfo.common_organization_id IS NULL)
                    AND (X_Common_Organization_Id IS NULL)))
           AND (   (Recinfo.next_explode_date =  X_Next_Explode_Date)
                OR (    (Recinfo.next_explode_date IS NULL)
                    AND (X_Next_Explode_Date IS NULL)))
           AND (   (Recinfo.structure_type_id =  X_Structure_Type_Id)
                OR (    (Recinfo.structure_type_id IS NULL)
                    AND (X_Structure_Type_Id IS NULL)))
           AND (   (Recinfo.implementation_date =  X_Implementation_Date)
                OR (    (Recinfo.implementation_date IS NULL)
                    AND (X_Implementation_Date IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Assembly_Item_Id               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Common_Assembly_Item_Id        NUMBER,
                       X_Specific_Assembly_Comment      VARCHAR2,
                       X_Pending_From_Ecn               VARCHAR2,
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
                       X_Assembly_Type                  NUMBER,
                       X_Common_Bill_Sequence_Id IN OUT NOCOPY NUMBER,
                       X_Bill_Sequence_Id               NUMBER,
                       X_Common_Organization_Id         NUMBER,
                       X_Next_Explode_Date              DATE,
                       X_structure_type_id              NUMBER := NULL,
                       X_implementation_date            DATE   := NULL,
                       X_effectivity_control               NUMBER := NULL

  ) IS
  l_creation_date  DATE;
  l_created_by     NUMBER;
  BEGIN
    IF (X_Common_Assembly_Item_Id is NULL) THEN
      X_Common_Bill_Sequence_Id := X_Bill_Sequence_Id;
    ELSE
      SELECT bill_sequence_id
        INTO X_Common_Bill_Sequence_Id
        FROM bom_bill_of_materials
       WHERE organization_id = X_Common_Organization_Id
         AND bill_sequence_id = common_bill_sequence_id
         AND assembly_item_id = X_Common_Assembly_Item_Id
         AND NVL(alternate_bom_designator, 'NONE') =
             NVL(X_Alternate_Bom_Designator,'NONE');
    END IF;

    UPDATE BOM_BILL_OF_MATERIALS
    SET
       assembly_item_id                =     X_Assembly_Item_Id,
       organization_id                 =     X_Organization_Id,
       alternate_bom_designator        =     X_Alternate_Bom_Designator,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       common_assembly_item_id         =     X_Common_Assembly_Item_Id,
       specific_assembly_comment       =     X_Specific_Assembly_Comment,
       pending_from_ecn                =     X_Pending_From_Ecn,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       assembly_type                   =     X_Assembly_Type,
       common_bill_sequence_id         =     X_Common_Bill_Sequence_Id,
       bill_sequence_id                =     X_Bill_Sequence_Id,
       common_organization_id          =     X_Common_Organization_Id,
       next_explode_date               =     X_Next_Explode_Date,
       structure_type_id         =     X_structure_type_id,
       implementation_date         =     X_implementation_date,
       effectivity_control      =     X_effectivity_control
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    SELECT creation_date,created_by INTO l_creation_date,l_created_by
    FROM bom_bill_of_materials
    WHERE organization_id = X_Organization_Id
    AND bill_sequence_id = X_Bill_Sequence_Id
    AND assembly_item_id = X_Assembly_Item_Id
    AND NVL(alternate_bom_designator, 'NONE') =
    NVL(X_Alternate_Bom_Designator,'NONE');

    -- Raising Business event   4306013
  Bom_Business_Event_PKG.Raise_Bill_Event
     (p_pk1_value => X_Assembly_Item_Id
      , p_pk2_value          => X_Organization_Id
      , p_obj_name           => NULL
      , p_structure_name     => X_Alternate_Bom_Designator
      , p_organization_id    => X_Organization_Id
      , p_structure_comment  => X_Specific_Assembly_Comment
      , p_Event_Load_Type => 'Single'
      , p_Event_Entity_Name => 'Structure'
      , p_Event_Entity_Parent_Id  => X_Bill_Sequence_Id
      , p_Event_Name => Bom_Business_Event_PKG.G_STRUCTURE_MODIFIED_EVENT
      , p_last_update_date => X_Last_Update_Date
      , p_last_updated_by  => X_Last_Updated_By
      , p_creation_date    => l_creation_date
      , p_created_by       => l_created_by
      , p_last_update_login=> X_Last_Update_Login
      );
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

    l_Structure_Name VARCHAR2(10);
    l_Organization_Id NUMBER;
    l_Assembly_Item_Id NUMBER;
    l_specific_assembly_comment VARCHAR2(240);
--    bill_seq_id NUMBER;                                -- 4306013

  BEGIN
    DELETE FROM BOM_BILL_OF_MATERIALS
    WHERE rowid = X_Rowid;

  -- Getting the structure name and comments to raise the business event
--    SELECT bbm.Organization_Id, bbm.Assembly_Item_Id, bbm.Alternate_Bom_Designator, specific_assembly_comment
--      INTO l_Organization_Id, l_Assembly_Item_Id, l_Structure_Name, l_specific_assembly_comment
--    FROM Bom_Bill_Of_Materials bbm
--    WHERE rowid = X_Rowid;

--    SELECT bill_sequence_id into bill_seq_id
--    from bom_structures_b
--    where assembly_item_id = l_Assembly_Item_Id
--    and organization_id = l_Organization_Id
--    and Alternate_Bom_Designator = l_Structure_Name;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Delete_Row;


END BOM_BILL_OF_MATLS_PKG;

/
