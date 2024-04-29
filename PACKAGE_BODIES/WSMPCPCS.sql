--------------------------------------------------------
--  DDL for Package Body WSMPCPCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPCPCS" as
/* $Header: WSMCPCSB.pls 120.2 2005/09/09 07:02:54 abgangul noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_substitute_component_id        NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_attribute_category             VARCHAR2,
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
                       X_Request_Id                     NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_basis_type                     NUMBER   --LBM enh
   ) IS
     CURSOR C IS SELECT rowid FROM WSM_CO_PROD_COMP_SUBSTITUTES
                 WHERE co_product_group_id      = X_co_product_group_id
                 AND   substitute_component_id  = X_Substitute_Component_Id;
     l_basis_type number;  --LBM enh

    BEGIN
       if X_basis_type = 2 then  --LBM enh
           l_basis_type := 2;
       else
           l_basis_type := null;
       end if;                   --LBM enh

       INSERT INTO WSM_CO_PROD_COMP_SUBSTITUTES (
                CO_PRODUCT_GROUP_ID,
                SUBSTITUTE_COMPONENT_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                SUBSTITUTE_ITEM_QUANTITY,
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
                ATTRIBUTE15,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                BASIS_TYPE            --LBM enh
             ) VALUES (
                X_co_product_group_id,
                X_substitute_component_id,
                X_creation_date,
                X_created_by,
                X_last_update_login,
                X_last_updated_by,
                X_last_update_date,
                X_substitute_item_quantity,
                X_attribute_category,
                X_attribute1,
                X_attribute2,
                X_attribute3,
                X_attribute4,
                X_attribute5,
                X_attribute6,
                X_attribute7,
                X_attribute8,
                X_attribute9,
                X_attribute10,
                X_attribute11,
                X_attribute12,
                X_attribute13,
                X_attribute14,
                X_attribute15,
                X_request_id,
                X_program_application_id,
                X_program_id,
                X_program_update_date,
                l_basis_type             --LBM enh
             );


    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  END Insert_Row;

  PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_substitute_component_id        NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_attribute_category             VARCHAR2,
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
                       X_Request_Id                     NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_basis_type                     NUMBER   --LBM enh
   ) IS

    l_basis_type      number; --LBM enh
    BEGIN

       if X_basis_type = 2 then  --LBM enh
           l_basis_type := 2;
       else
           l_basis_type := null;
       end if;                   --LBM enh

       UPDATE WSM_CO_PROD_COMP_SUBSTITUTES
       SET
            co_product_group_id     = x_co_product_group_id,
            substitute_component_id = x_substitute_component_id,
            last_update_login       = x_last_update_login,
            last_updated_by         = x_last_updated_by,
            last_update_date        = x_last_update_date,
            substitute_item_quantity = x_substitute_item_quantity,
            attribute_category      = x_attribute_category,
            attribute1              = x_attribute1,
            attribute2              = x_attribute2,
            attribute3              = x_attribute3,
            attribute4              = x_attribute4,
            attribute5              = x_attribute5,
            attribute6              = x_attribute6,
            attribute7              = x_attribute7,
            attribute8              = x_attribute8,
            attribute9              = x_attribute9,
            attribute10             = x_attribute10,
            attribute11             = x_attribute11,
            attribute12             = x_attribute12,
            attribute13             = x_attribute13,
            attribute14             = x_attribute14,
            attribute15             = x_attribute15,
            request_id              = x_request_id,
            program_application_id  = x_program_application_id,
            program_id              = x_program_id,
            program_update_date     = x_program_update_date,
            basis_type              = l_basis_type     --LBM enh
       WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Lock_Row  (X_Rowid                          VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_substitute_component_id        NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_attribute_category             VARCHAR2,
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
                       X_basis_type                     NUMBER     --LBM enh
   ) IS
    CURSOR C IS
        SELECT *
        FROM   WSM_CO_PROD_COMP_SUBSTITUTES
        WHERE  rowid = X_Rowid
        FOR UPDATE of substitute_component_id NOWAIT;
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
           AND (Recinfo.co_product_group_id    =  X_Co_Product_Group_Id)
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
           AND (   (Recinfo.basis_type =  X_basis_type)      --LBM enh
                OR (    (Recinfo.basis_type IS NULL)         --LBM enh
                    AND (X_basis_type IS NULL)))             --LBM enh
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  END Lock_Row;


  PROCEDURE Check_Unique(X_Rowid			VARCHAR2,
		     	 X_co_product_group_id		NUMBER,
                         X_substitute_component_id      NUMBER,
                         X_organization_id              NUMBER) IS

  dummy 	NUMBER;
  x1_dummy 	NUMBER; -- abedajna
  x_substitute  VARCHAR2(820);

  duplicate_sub_comp_error   	EXCEPTION;


  BEGIN

-- commented out by abedajna on 10/12/00 for perf. tuning
/*
**  SELECT 1 INTO dummy
**  FROM   DUAL
**  WHERE NOT EXISTS
**    ( SELECT 1
**      FROM wsm_co_prod_comp_substitutes
**      WHERE co_product_group_id         = X_co_product_group_id
**    AND   substitute_component_id     = X_substitute_component_id
**    AND  ((X_Rowid IS NULL) OR (ROWID <> X_ROWID)));
**
**  EXCEPTION
**  WHEN NO_DATA_FOUND THEN
**      fnd_message.set_name('WSM','WSM_DUPLICATE_SUB_COMP');
**      app_exception.raise_exception;
*/

-- modification begin for perf. tuning.. abedajna 10/12/00

  x1_dummy := 0;

  SELECT 1 INTO x1_dummy
  FROM wsm_co_prod_comp_substitutes
  WHERE co_product_group_id         = X_co_product_group_id
  AND   substitute_component_id     = X_substitute_component_id
  AND  ((X_Rowid IS NULL) OR (ROWID <> X_ROWID));

  IF x1_dummy <> 0 THEN
  	RAISE duplicate_sub_comp_error;
  END IF;


  EXCEPTION

  WHEN NO_DATA_FOUND THEN
  	NULL;

  WHEN duplicate_sub_comp_error THEN
      fnd_message.set_name('WSM','WSM_DUPLICATE_SUB_COMP');
      app_exception.raise_exception;

  WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name('WSM','WSM_DUPLICATE_SUB_COMP');
      app_exception.raise_exception;


-- modification end for perf. tuning.. abedajna 10/12/00

END Check_Unique;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN

    DELETE FROM WSM_CO_PROD_COMP_SUBSTITUTES
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
END Delete_Row;

END WSMPCPCS;

/
