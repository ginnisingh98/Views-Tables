--------------------------------------------------------
--  DDL for Package Body BOM_REF_DESIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_REF_DESIG_PKG" as
/* $Header: bompirdb.pls 120.8.12010000.3 2015/07/10 12:24:48 nlingamp ship $ */

--  Business Event           4306013
PROCEDURE Raise_Business_Event( p_Component_Sequence_Id NUMBER,
                                p_last_update_date      DATE,
                                p_last_updated_by       NUMBER,
                                p_creation_date         DATE,
                                p_created_by            NUMBER,
                                p_last_update_login     NUMBER
                              );

PROCEDURE Check_Unique(X_rowid        VARCHAR2,
           X_component_sequence_id    NUMBER,
           X_designator VARCHAR2) IS
   dummy  NUMBER;
BEGIN
  SELECT 1 into dummy from dual
   WHERE NOT EXISTS
         (SELECT 1 from bom_reference_designators
           WHERE component_sequence_id = X_component_sequence_id
       AND component_reference_designator = X_designator
       AND ((acd_type is null) OR (acd_type <> 3))
       AND ((X_rowid is NULL) OR (rowid <> X_rowid))
         );
EXCEPTION
  WHEN no_data_found THEN
     Fnd_Message.Set_Name('INV','INV_ALREADY_EXISTS');
     Fnd_Message.Set_Token('ENTITY','Reference designator', TRUE);
     App_Exception.Raise_Exception;
END Check_Unique;

--* Procedure added for Bug 4247194
PROCEDURE Check_Add (   X_Component_Sequence_Id   NUMBER,
            X_Old_Component_Sequence_Id NUMBER,
            X_Designator      VARCHAR2,
            X_Change_Notice     VARCHAR2 ) IS

  rec_exist   NUMBER :=0 ;
  disable_exist   NUMBER;
BEGIN
  --* Checking whether reference designator record exists in implemented
  --* or unimplemented status. If the reference designator is being added
  --* for the first time, furthur validations will be ignored.
  SELECT Count(1) INTO rec_exist
  FROM   Bom_Inventory_Components bic,
         bom_reference_designators brd
        WHERE  --Nvl(bic.Old_Component_Sequence_Id,bic.Component_Sequence_Id) = X_Old_Component_Sequence_Id
             --commented out previous line and added line below for bug 8719529
 	     --Removed nvl function to improve performance. Both lines have same logic
             ((bic.Old_Component_Sequence_Id = X_Old_Component_Sequence_Id) OR
 	           (bic.Old_Component_Sequence_Id is NULL AND bic.Component_Sequence_Id = X_Old_Component_Sequence_Id))

  AND    --Nvl(bic.Change_Notice,'*') <> X_Change_Notice
         --commented out previous line and added line below for bug 8719529
 	 --Removed nvl function to improve performance. Both lines have same logic
 	 ((bic.Change_Notice <> X_Change_Notice) OR
 	       (bic.Change_Notice is NULL AND '*' <> X_Change_Notice))

  AND    brd.component_sequence_id = bic.component_sequence_id
  AND    brd.component_reference_designator = X_Designator
  AND    ((brd.acd_type is NULL) or (brd.acd_type <> 3));

  IF rec_exist > 0 THEN
    rec_exist :=0;
    BEGIN
      --* Checking whether a DISABLE record exists for the reference designator
      --* in any unimplemented ECO
      --* Old Comp Seq Id is passed in the subquery to fetch the highest
      --* unimplemented record. If this acd type for this record is 3
      --* then no furthur validation is done, since a disable record exists
      --* for this ADD record.
      --* If through a previous ECO, a DISABLE and ADD record have been entered
      --* then the following query will return 2 records. In this case we need
      --* to fetch only ADD record's acd type (1). So added rownum condition and
      --* included order by clause.

      SELECT  Acd_Type INTO rec_exist
      FROM  Bom_Reference_Designators
      WHERE Component_Sequence_Id = ( SELECT Max(bic.Component_Sequence_Id)
                 FROM   Bom_Inventory_Components bic,
                  bom_reference_designators brd
                 WHERE  bic.Old_Component_Sequence_Id = X_Old_Component_Sequence_Id
                 AND    bic.Change_Notice <> X_Change_Notice
                 AND    bic.Implementation_Date IS NULL
                 AND    brd.component_sequence_id = bic.component_sequence_id
                 AND    brd.component_reference_designator =  X_Designator )
       AND    Component_Reference_Designator =  X_Designator
       AND  Rownum < 2
       ORDER  BY Acd_Type;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF rec_exist IN (0,1) THEN
      --* If no_data_found for previous query or acd type is 1, checking current block
      --* DISABLE record exists in the current block
      SELECT 0 INTO disable_exist
      FROM  dual
      WHERE NOT EXISTS
        (SELECT 1 FROM bom_reference_designators
         WHERE  component_sequence_id = X_Component_Sequence_Id
         AND    component_reference_designator = X_Designator
         AND    acd_type = 3);

      --* If DISABLE record does not exist in current block then fire
      --* error message.
      IF disable_exist = 0 THEN
           Fnd_Message.Set_Name('INV','INV_ALREADY_EXISTS');
           Fnd_Message.Set_Token('ENTITY','Reference designator', TRUE);
           App_Exception.Raise_Exception;
      END IF;
     END IF;
   END IF;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
    NULL;
END Check_Add;
-- End of Bug 4247194

  PROCEDURE Default_Row(X_Total_Records          IN OUT NOCOPY NUMBER,
                        X_Component_Sequence_ID         NUMBER
                      ) IS
     BEGIN
        -- Get defaults
        select count(*)
          into X_Total_Records
          from bom_ref_designators_view
         where component_sequence_id = X_Component_Sequence_Id
           and nvl(acd_type,1) <> 3;
     EXCEPTION
        when no_data_found then
           null;
  END Default_Row;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Component_Ref_Desig            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Ref_Designator_Comment         VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
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
                       X_Attribute15                    VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM BOM_REFERENCE_DESIGNATORS
                 WHERE component_sequence_id = X_Component_Sequence_Id
                 AND   (    (acd_type = X_Acd_Type)
                        or (acd_type is NULL and X_Acd_Type is NULL));
    l_err_tbl Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status VARCHAR2(10);

   BEGIN


       INSERT INTO BOM_REFERENCE_DESIGNATORS(
              component_reference_designator,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              ref_designator_comment,
              change_notice,
              component_sequence_id,
              acd_type,
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
              X_Component_Ref_Desig,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Ref_Designator_Comment,
              X_Change_Notice,
              X_Component_Sequence_Id,
              X_Acd_Type,
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
    /* Added p_acd_type for bug 20345308 to resolve the issue where in, unique constraint error thrown
    when we try to save both 'disable' and 'add' actions of a reference designator at once in an ECO */
    BOMPCMBM.Insert_Related_Ref_Desg(p_component_sequence_id => X_Component_Sequence_Id
                                  , p_ref_desg => X_Component_Ref_Desig
				  , p_acd_type => X_Acd_Type
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
                     X_Component_Ref_Desig              VARCHAR2,
                     X_Ref_Designator_Comment           VARCHAR2,
                     X_Change_Notice                    VARCHAR2,
                     X_Component_Sequence_Id            NUMBER,
                     X_Acd_Type                         NUMBER,
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
                     X_Attribute15                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   BOM_REFERENCE_DESIGNATORS
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
               (Recinfo.component_reference_designator=X_Component_Ref_Desig)
           AND (   (Recinfo.ref_designator_comment =  X_Ref_Designator_Comment)
                OR (    (Recinfo.ref_designator_comment IS NULL)
                    AND (X_Ref_Designator_Comment IS NULL)))
           AND (   (Recinfo.change_notice =  X_Change_Notice)
                OR (    (Recinfo.change_notice IS NULL)
                    AND (X_Change_Notice IS NULL)))
           AND (Recinfo.component_sequence_id =  X_Component_Sequence_Id)
           AND (   (Recinfo.acd_type =  X_Acd_Type)
                OR (    (Recinfo.acd_type IS NULL)
                    AND (X_Acd_Type IS NULL)))
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
                       X_Component_Ref_Desig            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Ref_Designator_Comment         VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
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
                       X_Attribute15                    VARCHAR2
  ) IS
      l_err_tbl Error_Handler.Mesg_Token_Tbl_Type;
      l_return_status VARCHAR2(10);
      l_old_ref_desg VARCHAR2(15);
      l_acd_type NUMBER;

  BEGIN

    SELECT COMPONENT_REFERENCE_DESIGNATOR, ACD_TYPE
    INTO l_old_ref_desg, l_acd_type
    FROM BOM_REFERENCE_DESIGNATORS
    WHERE rowid = X_Rowid;

    UPDATE BOM_REFERENCE_DESIGNATORS
    SET
       component_reference_designator   =    X_Component_Ref_Desig,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       ref_designator_comment          =     X_Ref_Designator_Comment,
       change_notice                   =     X_Change_Notice,
       component_sequence_id           =     X_Component_Sequence_Id,
       acd_type                        =     X_Acd_Type,
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
    BOMPCMBM.Update_Related_Ref_Desg(p_component_sequence_id => X_Component_Sequence_Id
                                  , p_old_ref_desg => l_old_ref_desg
                                  , p_new_ref_desg => X_Component_Ref_Desig
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
    l_common_component_sequence_id NUMBER;
    l_ref_desg VARCHAR2(255);
    l_return_status VARCHAR2(1);
    l_Component_Sequence_Id NUMBER;
  BEGIN

    Select component_sequence_id, component_reference_designator
    into l_common_component_sequence_id, l_ref_desg
    From BOM_REFERENCE_DESIGNATORS
    WHERE rowid = X_Rowid;


    DELETE FROM BOM_REFERENCE_DESIGNATORS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
    BOMPCMBM.Delete_Related_Ref_Desg(p_src_comp_seq => l_common_component_sequence_id
                                     , p_ref_desg => l_ref_desg
                                     , x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      app_exception.raise_exception;
    END IF;

    -- Calling Raise_Business_Event to raise business event
    Raise_Business_Event(l_common_component_sequence_Id,sysdate,fnd_global.user_id
                        ,NULL,NULL,fnd_global.user_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Raise NO_DATA_FOUND;


  END Delete_Row;

 PROCEDURE Raise_Business_Event( p_Component_Sequence_Id NUMBER,
                                 p_last_update_date      DATE,
                                 p_last_updated_by       NUMBER,
                                 p_creation_date         DATE,
                                 p_created_by            NUMBER,
                                 p_last_update_login     NUMBER
                                 ) IS    --4306013
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

    -- Raising Business event
  Bom_Business_Event_PKG.Raise_Component_Event
     (p_bill_sequence_Id   => l_Bill_Sequence_Id
                  , p_pk1_value          => l_Component_Item_Id
                  , p_pk2_value          => l_Organization_Id
                  , p_obj_name           => NULL
                  , p_organization_id    => l_Organization_Id
                  , p_comp_item_name     => l_Component_Item_Name
                  , p_comp_description   => l_Component_Remarks
                  , p_Event_Load_Type => 'Single'
                  , p_Event_Entity_Name => 'Reference Designator'
                  , p_Event_Entity_Parent_Id  => p_Component_Sequence_Id
                  , p_Event_Name => Bom_Business_Event_PKG.G_COMPONENT_MODIFIED_EVENT
                  , p_last_update_date   => p_last_update_date
                  , p_last_updated_by    => p_last_updated_by
                  , p_creation_date      => p_creation_date
                  , p_created_by         => p_created_by
                  , p_last_update_login  => p_last_update_login
                  );

--         IF (SQL%NOTFOUND) THEN
--           Raise NO_DATA_FOUND;
--         END IF;
  END;

END BOM_REF_DESIG_PKG;

/
