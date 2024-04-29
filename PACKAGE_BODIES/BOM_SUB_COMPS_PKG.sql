--------------------------------------------------------
--  DDL for Package Body BOM_SUB_COMPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_SUB_COMPS_PKG" as
/* $Header: bompiscb.pls 120.7.12000000.2 2007/06/18 06:31:21 pgandhik ship $ */


  PROCEDURE Raise_Business_Event( p_Component_Sequence_Id NUMBER,
                                  p_last_update_date      DATE,
                                  p_last_updated_by       NUMBER,
                                  p_creation_date         DATE,
                                  p_created_by            NUMBER,
                                  p_last_update_login     NUMBER
                                );


  PROCEDURE Get_Uom(X_uom_code         IN OUT NOCOPY VARCHAR2,
        X_sub_comp_id          NUMBER,
        X_org_id             NUMBER) IS

  BEGIN
     SELECT primary_uom_code
       INTO X_uom_code
       FROM mtl_system_items
      WHERE inventory_item_id = X_sub_comp_id
        AND organization_id   = X_org_id;

  END Get_Uom;

  PROCEDURE Check_Unique(X_acd_type       NUMBER,
             X_sub_comp_id        NUMBER,
             X_comp_seq_id        NUMBER,
       X_row_id       VARCHAR2) IS
  dummy   NUMBER;

  BEGIN
     SELECT 1
       INTO dummy
       FROM dual
      WHERE not exists
            (SELECT 'x' FROM bom_substitute_components
        WHERE nvl(acd_type, 1) = nvl(X_acd_type, 1)
    AND substitute_component_id = X_sub_comp_id
    AND component_sequence_id = X_comp_seq_id
    AND ((X_row_id is NULL) OR (rowid <> X_row_id))
             );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
  app_exception.raise_exception;

  END Check_Unique;

  PROCEDURE Check_Commons(X_bill_seq_id     NUMBER,
              X_org_id            NUMBER,
              X_sub_comp_id     NUMBER) IS
  counter NUMBER;

  BEGIN
     SELECT 1
       INTO counter
       FROM bom_bill_of_materials bbom
      WHERE bbom.common_bill_sequence_id = X_bill_seq_id
        AND bbom.organization_id <> X_org_id
	AND not exists
            (SELECT null
               FROM mtl_system_items msi
              WHERE msi.organization_id = bbom.organization_id
		AND msi.inventory_item_id = X_sub_comp_id
		AND msi.bom_enabled_flag = 'Y'
		AND ((bbom.assembly_type = 1
                      AND msi.eng_item_flag = 'N')
                     OR (bbom.assembly_type = 2)))
       AND ROWNUM=1; /* Bug 6134795 To insert a value 1 into counter
	if one or more common bills exist if substitute component
	does not exist in Other organizations */
      fnd_message.set_name('INV','INV_NOT_VALID');
      fnd_message.set_token('ENTITY','Substitute item', TRUE);
      app_exception.raise_exception;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
  null;

  END Check_Commons;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Substitute_Component_Id        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Change_Notice                  VARCHAR2,
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
                       X_Enforce_Int_Requirements       NUMBER DEFAULT NULL
  ) IS
    CURSOR C IS SELECT rowid FROM BOM_SUBSTITUTE_COMPONENTS
                 WHERE component_sequence_id = X_Component_Sequence_Id
                 AND   (    (acd_type = X_Acd_Type)
                        or (acd_type is NULL and X_Acd_Type is NULL));

    l_err_tbl Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status VARCHAR2(10);

   BEGIN


       INSERT INTO BOM_SUBSTITUTE_COMPONENTS(
              substitute_component_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              substitute_item_quantity,
              component_sequence_id,
              acd_type,
              change_notice,
        enforce_int_requirements,
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
              attribute15
             ) VALUES (
              X_Substitute_Component_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Substitute_Item_Quantity,
              X_Component_Sequence_Id,
              X_Acd_Type,
              X_Change_Notice,
        X_Enforce_Int_Requirements,
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
              X_Attribute15
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
    BOMPCMBM.Insert_Related_Sub_Comp(p_component_sequence_id => X_Component_Sequence_Id
                                  , p_sub_comp_item_id => X_Substitute_Component_Id
                                  , x_Mesg_Token_Tbl => l_err_tbl
                                  , x_Return_Status => l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN
     app_exception.raise_exception;
   END IF;

       -- Calling Raise_Business_Event to raise business event
    Raise_Business_Event(X_Component_Sequence_Id,X_Last_Update_Date,X_Last_Updated_By,
                        X_Creation_Date,X_Created_By,X_Last_Update_Login);

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Substitute_Component_Id          NUMBER,
                     X_Substitute_Item_Quantity         NUMBER,
                     X_Component_Sequence_Id            NUMBER,
                     X_Acd_Type                         NUMBER,
                     X_Change_Notice                    VARCHAR2,
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
                     X_Enforce_Int_Requirements         NUMBER DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   BOM_SUBSTITUTE_COMPONENTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Component_Sequence_Id NOWAIT;
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
               (Recinfo.substitute_component_id =  X_Substitute_Component_Id)
           AND (Recinfo.substitute_item_quantity =  X_Substitute_Item_Quantity)
           AND (Recinfo.component_sequence_id =  X_Component_Sequence_Id)
           AND (   (Recinfo.acd_type =  X_Acd_Type)
                OR (    (Recinfo.acd_type IS NULL)
                    AND (X_Acd_Type IS NULL)))
           AND (   (Recinfo.change_notice =  X_Change_Notice)
                OR (    (Recinfo.change_notice IS NULL)
                    AND (X_Change_Notice IS NULL)))
           AND (   (Recinfo.enforce_int_requirements =  X_Enforce_Int_Requirements)
                OR (    (Recinfo.enforce_int_requirements IS NULL)
                    AND (X_Enforce_Int_Requirements IS NULL)))
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
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Substitute_Component_Id        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Change_Notice                  VARCHAR2,
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
                       X_Enforce_Int_Requirements       NUMBER DEFAULT NULL

  ) IS
    l_err_tbl Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status VARCHAR2(10);
    l_old_sub_comp_id NUMBER;
    l_acd_type NUMBER;
  BEGIN
    SELECT substitute_component_id, ACD_TYPE
    INTO l_old_sub_comp_id, l_acd_type
    FROM BOM_SUBSTITUTE_COMPONENTS
    WHERE rowid = X_Rowid;

    UPDATE BOM_SUBSTITUTE_COMPONENTS
    SET
       substitute_component_id         =     X_Substitute_Component_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       substitute_item_quantity        =     X_Substitute_Item_Quantity,
       component_sequence_id           =     X_Component_Sequence_Id,
       acd_type                        =     X_Acd_Type,
       change_notice                   =     X_Change_Notice,
       enforce_int_requirements        =     X_Enforce_Int_Requirements,
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
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
    BOMPCMBM.Update_Related_Sub_Comp(p_component_sequence_id => X_Component_Sequence_Id
                                  , p_old_sub_comp_item_id => l_old_sub_comp_id
                                  , p_new_sub_comp_item_id=> X_Substitute_Component_ID
                                  , p_acd_type => l_acd_type
                                  , x_Mesg_Token_Tbl => l_err_tbl
                                  , x_Return_Status => l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN
     app_exception.raise_exception;
   END IF;

       -- Calling Raise_Business_Event to raise business event
    Raise_Business_Event(X_Component_Sequence_Id,X_Last_Update_Date,X_Last_Updated_By,
                        NULL,NULL,X_Last_Update_Login);

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
    l_Component_Sequence_Id NUMBER;
    l_common_component_sequence_id NUMBER;
    l_sub_comp_id  NUMBER;
    l_return_status VARCHAR2(1);
  BEGIN
    Select component_sequence_id, substitute_component_id
    into l_common_component_sequence_id, l_sub_comp_id
    From BOM_SUBSTITUTE_COMPONENTS
    WHERE rowid = X_Rowid;


    DELETE FROM BOM_SUBSTITUTE_COMPONENTS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    BOMPCMBM.Delete_Related_Sub_Comp(p_src_comp_seq => l_common_component_sequence_id
                                     ,p_sub_comp_item_id => l_sub_comp_id
                                     ,x_return_status => l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN
     app_exception.raise_exception;
   END IF;

   -- Calling Raise_Business_Event to raise business event
    Raise_Business_Event(l_common_component_sequence_Id,sysdate,fnd_global.user_id,NULL,NULL,NULL);

  Exception
    WHEN NO_DATA_FOUND THEN
      Raise NO_DATA_FOUND;


  END Delete_Row;


  PROCEDURE Raise_Business_Event( p_Component_Sequence_Id NUMBER,
                                  p_last_update_date      DATE,
                                  p_last_updated_by       NUMBER,
                                  p_creation_date         DATE,
                                  p_created_by            NUMBER,
                                  p_last_update_login     NUMBER
                                  ) IS           --4306013
    l_Component_Item_Name VARCHAR2(512);
    l_Component_Item_Id NUMBER;
    l_Bill_Sequence_Id NUMBER;
    l_Organization_Id NUMBER;
    l_Component_Remarks VARCHAR2(240);

  BEGIN

      SELECT bic.Bill_Sequence_Id, bbm.Organization_Id, bic.Component_Item_Id,
          bic.Component_Remarks, msi.Concatenated_Segments
        INTO l_Bill_Sequence_Id, l_Organization_Id, l_Component_Item_Id,
          l_Component_Remarks, l_Component_Item_Name
      FROM Bom_Bill_Of_Materials bbm, Bom_Inventory_Components bic, Mtl_System_Items_Kfv msi
      WHERE bbm.Bill_Sequence_Id = bic.Bill_Sequence_Id
        And msi.Inventory_Item_Id = bic.Component_Item_Id
        And msi.Organization_Id = bbm.Organization_Id
        And bic.Component_Sequence_Id = p_Component_Sequence_Id;

  Bom_Business_Event_PKG.Raise_Component_Event
     ( p_bill_sequence_Id   => l_Bill_Sequence_Id
    , p_pk1_value          => l_Component_Item_Id
    , p_pk2_value          => l_Organization_Id
    , p_obj_name           => NULL
    , p_organization_id    => l_Organization_Id
    , p_comp_item_name     => l_Component_Item_Name
    , p_comp_description   => l_Component_Remarks
    , p_Event_Load_Type => 'Single'
    , p_Event_Entity_Name => 'Substitute Component'
    , p_Event_Entity_Parent_Id  => p_Component_Sequence_Id
    , p_Event_Name => Bom_Business_Event_PKG.G_COMPONENT_MODIFIED_EVENT
    , p_last_update_date   => p_last_update_date
    , p_last_updated_by    => p_last_updated_by
    , p_creation_date      => p_creation_date
    , p_created_by         => p_created_by
    , p_last_update_login  => p_last_update_login
      );
  END;

END BOM_SUB_COMPS_PKG;

/
