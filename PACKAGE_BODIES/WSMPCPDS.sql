--------------------------------------------------------
--  DDL for Package Body WSMPCPDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPCPDS" as
/* $Header: WSMCPRDB.pls 120.2 2005/09/09 07:09:56 abgangul noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_co_product_group_id     IN OUT NOCOPY NUMBER,
                       X_component_id                   NUMBER,
                       X_organization_id                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_co_product_id                  NUMBER,
/*coprod enh p2 .45*/
			X_alternate_designator		VARCHAR2,
/*end coprod enh p2 .45*/
                       X_bill_sequence_id               NUMBER,
                       X_component_sequence_id          NUMBER,
                       X_split                          NUMBER,
                       X_effectivity_date               DATE,
                       X_disable_date                   DATE,
                       X_primary_flag                   VARCHAR2,
                       X_revision                       VARCHAR2,
                       X_change_notice                  VARCHAR2,
                       X_implementation_date            DATE,
                       X_usage_rate                     NUMBER,
                       X_duality_flag                   VARCHAR2,
                       X_planning_factor                NUMBER,
                       X_component_yield_factor         NUMBER,
                       X_include_in_cost_rollup         NUMBER,
                       X_wip_supply_type                NUMBER,
                       X_supply_subinventory            VARCHAR2,
                       X_supply_locator_id              NUMBER,
                       X_component_remarks              VARCHAR2,
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
                       X_basis_type                     NUMBER          --LBM enh
   ) IS
     CURSOR C IS SELECT rowid FROM WSM_CO_PRODUCTS
                 WHERE component_id = X_component_id
                 AND   organization_id = X_organization_id
                 AND   co_product_group_id = X_co_product_group_id
                 AND   (    co_product_id = x_co_product_id
                        OR  ((co_product_id is NULL) AND
                             (x_co_product_id is NULL)));

--commented out by abedajna for perf. tuning
/*     CURSOR S IS SELECT WSM_co_products_s.nextval FROM sys.dual;
**
**    BEGIN
**      if (X_co_product_group_id is NULL) then
**        OPEN S;
**        FETCH S INTO X_co_product_group_id;
**        CLOSE S;
**      end if;
*/
    l_basis_type     number;  --LBM enh
    BEGIN

    if X_basis_type = 2 then  --LBM enh
        l_basis_type := 2;
    else
        l_basis_type := null;
    end if;                   --LBM enh

    IF (x_co_product_id IS NOT NULL) THEN

       INSERT INTO WSM_CO_PRODUCTS (
                CO_PRODUCT_GROUP_ID,
                COMPONENT_ID,
                ORGANIZATION_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                CO_PRODUCT_ID,
		ALTERNATE_DESIGNATOR, --coprod enh p2
                BILL_SEQUENCE_ID,
                COMPONENT_SEQUENCE_ID,
                SPLIT,
                EFFECTIVITY_DATE,
                DISABLE_DATE,
                PRIMARY_FLAG,
                REVISION,
                CHANGE_NOTICE,
                IMPLEMENTATION_DATE,
                USAGE_RATE,
                DUALITY_FLAG,
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
                BASIS_TYPE           ---LBM enh
             ) VALUES (
-- abedajna     X_co_product_group_id,
		decode(X_co_product_group_id, NULL, WSM_co_products_s.nextval, X_co_product_group_id),
                X_component_id,
                X_organization_id,
                X_creation_date,
                X_created_by,
                X_last_update_login,
                X_last_updated_by,
                X_last_update_date,
                X_co_product_id,
		X_alternate_designator, --coprod enh p2
                X_bill_sequence_id,
                X_component_sequence_id,
                X_split,
                X_effectivity_date,
                X_disable_date,
                X_primary_flag,
                X_revision,
                X_change_notice,
                X_implementation_date,
                X_usage_rate,
                X_duality_flag,
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
                l_basis_type       ---LBM enh
             )
	returning CO_PRODUCT_GROUP_ID into X_co_product_group_id;

    ELSE

       INSERT INTO WSM_CO_PRODUCTS (
                CO_PRODUCT_GROUP_ID,
                COMPONENT_ID,
                ORGANIZATION_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                CO_PRODUCT_ID,
		ALTERNATE_DESIGNATOR, --coprod enh p2
                BILL_SEQUENCE_ID,
                COMPONENT_SEQUENCE_ID,
                SPLIT,
                EFFECTIVITY_DATE,
                DISABLE_DATE,
                PRIMARY_FLAG,
                REVISION,
                CHANGE_NOTICE,
                IMPLEMENTATION_DATE,
                USAGE_RATE,
                DUALITY_FLAG,
                PLANNING_FACTOR,
                COMPONENT_YIELD_FACTOR,
                INCLUDE_IN_COST_ROLLUP,
                WIP_SUPPLY_TYPE,
                SUPPLY_SUBINVENTORY,
                SUPPLY_LOCATOR_ID,
                COMPONENT_REMARKS,
                COMP_ATTRIBUTE_CATEGORY,
                COMP_ATTRIBUTE1,
                COMP_ATTRIBUTE2,
                COMP_ATTRIBUTE3,
                COMP_ATTRIBUTE4,
                COMP_ATTRIBUTE5,
                COMP_ATTRIBUTE6,
                COMP_ATTRIBUTE7,
                COMP_ATTRIBUTE8,
                COMP_ATTRIBUTE9,
                COMP_ATTRIBUTE10,
                COMP_ATTRIBUTE11,
                COMP_ATTRIBUTE12,
                COMP_ATTRIBUTE13,
                COMP_ATTRIBUTE14,
                COMP_ATTRIBUTE15,
                BASIS_TYPE      --LBM enh
             ) VALUES (
-- abedajna     X_co_product_group_id,
		decode(X_co_product_group_id, NULL, WSM_co_products_s.nextval, X_co_product_group_id),
                X_component_id,
                X_organization_id,
                X_creation_date,
                X_created_by,
                X_last_update_login,
                X_last_updated_by,
                X_last_update_date,
                X_co_product_id,
		X_alternate_designator, --coprod enh p2
                X_bill_sequence_id,
                X_component_sequence_id,
                X_split,
                X_effectivity_date,
                X_disable_date,
                X_primary_flag,
                X_revision,
                X_change_notice,
                X_implementation_date,
                X_usage_rate,
                X_duality_flag,
                X_planning_factor,
                X_component_yield_factor,
                X_include_in_cost_rollup,
                X_wip_supply_type,
                X_supply_subinventory,
                X_supply_locator_id,
                X_component_remarks,
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
                l_basis_type       --LBM enh
             )
	returning CO_PRODUCT_GROUP_ID into X_co_product_group_id;

    END IF;

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                     X_co_product_group_id            NUMBER,
                     X_component_id                   NUMBER,
                     X_organization_id                NUMBER,
                     X_co_product_id                  NUMBER,
                     X_bill_sequence_id               NUMBER,
                     X_component_sequence_id          NUMBER,
                     X_split                          NUMBER,
                     X_effectivity_date               DATE,
                     X_disable_date                   DATE,
                     X_primary_flag                   VARCHAR2,
                     X_revision                       VARCHAR2,
                     X_change_notice                  VARCHAR2,
                     X_implementation_date            DATE,
                     X_usage_rate                     NUMBER,
                     X_duality_flag                   VARCHAR2,
                     X_planning_factor                NUMBER,
                     X_component_yield_factor         NUMBER,
                     X_include_in_cost_rollup         NUMBER,
                     X_wip_supply_type                NUMBER,
                     X_supply_subinventory            VARCHAR2,
                     X_supply_locator_id              NUMBER,
                     X_component_remarks              VARCHAR2,
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
                     X_Basis_type                     NUMBER    ---LBM enh
  ) IS
    CURSOR C IS
        SELECT *
        FROM   WSM_CO_PRODUCTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of component_id NOWAIT;
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

/*
   This call is used to lock records in WSM_co_products
   for both components as well as co-products.
   While modifying a co-product relationship ensure
   that the component record is locked before attempting
   to modify the co-product records for that component.
*/
   if (X_co_product_id is NOT NULL) THEN
    if (

               (Recinfo.component_id = X_component_id)
           AND (Recinfo.organization_id = X_organization_id)
           AND (Recinfo.co_product_group_id = X_co_product_group_id)
           AND (   (Recinfo.effectivity_date = X_effectivity_date)
                OR (    (Recinfo.effectivity_date IS NULL)
                    AND (X_effectivity_date IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (   (Recinfo.co_product_id = X_co_product_id)
                OR (    (Recinfo.co_product_id IS NULL)
                    AND (X_co_product_id IS NULL)))
           AND (   (Recinfo.bill_sequence_id = X_bill_sequence_id)
                OR (    (Recinfo.bill_sequence_id IS NULL)
                    AND (X_bill_sequence_id IS NULL)))
           AND (   (Recinfo.component_sequence_id = X_component_sequence_id)
                OR (    (Recinfo.component_sequence_id IS NULL)
                    AND (X_component_sequence_id IS NULL)))
           AND (   (Recinfo.split = X_split)
                OR (    (Recinfo.split IS NULL)
                    AND (X_split IS NULL)))
           AND (   (Recinfo.disable_date = X_disable_date)
                OR (    (Recinfo.disable_date IS NULL)
                    AND (X_disable_date IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (   (Recinfo.primary_flag = X_primary_flag)
                OR (    (Recinfo.primary_flag IS NULL)
                    AND (X_primary_flag IS NULL)))
           AND (   (Recinfo.revision = X_revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_revision IS NULL)))
           AND (   (Recinfo.change_notice = X_change_notice)
                OR (    (Recinfo.change_notice IS NULL)
                    AND (X_change_notice IS NULL)))
           AND (   (Recinfo.implementation_date = X_implementation_date)
                OR (    (Recinfo.implementation_date IS NULL)
                    AND (X_implementation_date IS NULL)))
           AND (   (Recinfo.usage_rate = X_usage_rate)
                OR (    (Recinfo.usage_rate IS NULL)
                    AND (X_usage_rate IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (   (Recinfo.duality_flag = X_duality_flag)
                OR (    (Recinfo.duality_flag IS NULL)
                    AND (X_duality_flag IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (   (Recinfo.attribute_category = X_attribute_category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_attribute_category IS NULL)))
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.basis_type = X_basis_type)     -- LBM enh
                OR (    (Recinfo.basis_type IS NULL)       -- LBM enh
                    AND (X_basis_type IS NULL)))           -- LBM enh

            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

   else
    if (
               (Recinfo.component_id = X_component_id)
           AND (Recinfo.organization_id = X_organization_id)
           AND (Recinfo.co_product_group_id = X_co_product_group_id)
           AND (   (Recinfo.effectivity_date = X_effectivity_date)
                OR (    (Recinfo.effectivity_date IS NULL)
                    AND (X_effectivity_date IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (   (Recinfo.co_product_id = X_co_product_id)
                OR (    (Recinfo.co_product_id IS NULL)
                    AND (X_co_product_id IS NULL)))
           AND (   (Recinfo.bill_sequence_id = X_bill_sequence_id)
                OR (    (Recinfo.bill_sequence_id IS NULL)
                    AND (X_bill_sequence_id IS NULL)))
           AND (   (Recinfo.component_sequence_id = X_component_sequence_id)
                OR (    (Recinfo.component_sequence_id IS NULL)
                    AND (X_component_sequence_id IS NULL)))
           AND (   (Recinfo.split = X_split)
                OR (    (Recinfo.split IS NULL)
                    AND (X_split IS NULL)))
           AND (   (Recinfo.disable_date = X_disable_date)
                OR (    (Recinfo.disable_date IS NULL)
                    AND (X_disable_date IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (   (Recinfo.primary_flag = X_primary_flag)
                OR (    (Recinfo.primary_flag IS NULL)
                    AND (X_primary_flag IS NULL)))
           AND (   (Recinfo.revision = X_revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_revision IS NULL)))
           AND (   (Recinfo.change_notice = X_change_notice)
                OR (    (Recinfo.change_notice IS NULL)
                    AND (X_change_notice IS NULL)))
           AND (   (Recinfo.implementation_date = X_implementation_date)
                OR (    (Recinfo.implementation_date IS NULL)
                    AND (X_implementation_date IS NULL)))
           AND (   (Recinfo.usage_rate = X_usage_rate)
                OR (    (Recinfo.usage_rate IS NULL)
                    AND (X_usage_rate IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (   (Recinfo.duality_flag = X_duality_flag)
                OR (    (Recinfo.duality_flag IS NULL)
                    AND (X_duality_flag IS NULL))
                OR (X_co_product_id is NOT NULL))
           AND (Recinfo.component_yield_factor =  X_component_yield_factor)
           AND (Recinfo.include_in_cost_rollup  = X_include_in_cost_rollup)
           AND (Recinfo.planning_factor         = X_planning_factor)
           AND (   (Recinfo.wip_supply_type  = X_wip_supply_type)
                OR (    (Recinfo.wip_supply_type IS NULL)
                    AND (X_wip_supply_type IS NULL)))
           AND (   (Recinfo.supply_subinventory = X_supply_subinventory)
                OR (    (Recinfo.supply_subinventory IS NULL)
                    AND (X_supply_subinventory IS NULL)))
           AND (   (Recinfo.supply_locator_id = X_supply_locator_id)
                OR (    (Recinfo.supply_locator_id IS NULL)
                    AND (X_supply_locator_id IS NULL)))
           AND (   (Recinfo.component_remarks = X_component_remarks)
                OR (    (Recinfo.component_remarks IS NULL)
                    AND (X_component_remarks IS NULL)))
           AND (   (Recinfo.comp_attribute_category = X_attribute_category)
                OR (    (Recinfo.comp_attribute_category IS NULL)
                    AND (X_attribute_category IS NULL)))
           AND (   (Recinfo.comp_attribute1 = X_Attribute1)
                OR (    (Recinfo.comp_attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.comp_attribute2 = X_Attribute2)
                OR (    (Recinfo.comp_attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.comp_attribute3 = X_Attribute3)
                OR (    (Recinfo.comp_attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.comp_attribute4 = X_Attribute4)
                OR (    (Recinfo.comp_attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.comp_attribute5 = X_Attribute5)
                OR (    (Recinfo.comp_attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.comp_attribute6 = X_Attribute6)
                OR (    (Recinfo.comp_attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.comp_attribute7 = X_Attribute7)
                OR (    (Recinfo.comp_attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.comp_attribute8 = X_Attribute8)
                OR (    (Recinfo.comp_attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.comp_attribute9 = X_Attribute9)
                OR (    (Recinfo.comp_attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.comp_attribute10 = X_Attribute10)
                OR (    (Recinfo.comp_attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.comp_attribute11 = X_Attribute11)
                OR (    (Recinfo.comp_attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.comp_attribute12 = X_Attribute12)
                OR (    (Recinfo.comp_attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.comp_attribute13 = X_Attribute13)
                OR (    (Recinfo.comp_attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.comp_attribute14 = X_Attribute14)
                OR (    (Recinfo.comp_attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.comp_attribute15 = X_Attribute15)
                OR (    (Recinfo.comp_attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.basis_type = X_basis_type)     -- LBM enh
                OR (    (Recinfo.basis_type IS NULL)       -- LBM enh
                    AND (X_basis_type IS NULL)))           -- LBM enh


            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
   end if;

  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_component_id                   NUMBER,
                       X_organization_id                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_last_update_date               DATE,
                       X_last_updated_by                NUMBER,
                       X_co_product_id                  NUMBER,
                       X_bill_sequence_id               NUMBER,
                       X_component_sequence_id          NUMBER,
                       X_split                          NUMBER,
                       X_effectivity_date               DATE,
                       X_disable_date                   DATE,
                       X_primary_flag                   VARCHAR2,
                       X_revision                       VARCHAR2,
                       X_change_notice                  VARCHAR2,
                       X_implementation_date            DATE,
                       X_usage_rate                     NUMBER,
                       X_duality_flag                   VARCHAR2,
                       X_planning_factor                NUMBER,
                       X_component_yield_factor         NUMBER,
                       X_include_in_cost_rollup         NUMBER,
                       X_wip_supply_type                NUMBER,
                       X_supply_subinventory            VARCHAR2,
                       X_supply_locator_id              NUMBER,
                       X_component_remarks              VARCHAR2,
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
                       X_basis_type                     NUMBER        --LBM enh
) IS

 l_basis_type      number; --LBM enh
 BEGIN

  if X_basis_type = 2 then  --LBM enh
     l_basis_type := 2;
  else
     l_basis_type := null;
  end if;                   --LBM enh

  IF (X_co_product_id is NOT NULL) THEN

   UPDATE WSM_CO_PRODUCTS
   SET
     co_product_group_id        =   X_co_product_group_id,
     component_id               =   X_component_id,
     organization_id            =   X_organization_id,
     last_update_login          =   X_last_update_login,
     last_update_date           =   X_last_update_date,
     last_updated_by            =   X_last_updated_by,
     co_product_id              =   X_co_product_id,
     bill_sequence_id           =   X_bill_sequence_id,
     component_sequence_id      =   X_component_sequence_id,
     split                      =   X_split,
     effectivity_date           =   X_effectivity_date,
     disable_date               =   X_disable_date,
     primary_flag               =   X_primary_flag,
     revision                   =   X_revision,
     change_notice              =   X_change_notice,
     implementation_date        =   X_implementation_date,
     usage_rate                 =   X_usage_rate,
     duality_flag               =   X_duality_flag,
     attribute_category         =   X_attribute_category,
     attribute1                 =   X_attribute1,
     attribute2                 =   X_attribute2,
     attribute3                 =   X_attribute3,
     attribute4                 =   X_attribute4,
     attribute5                 =   X_attribute5,
     attribute6                 =   X_attribute6,
     attribute7                 =   X_attribute7,
     attribute8                 =   X_attribute8,
     attribute9                 =   X_attribute9,
     attribute10                =   X_attribute10,
     attribute11                =   X_attribute11,
     attribute12                =   X_attribute12,
     attribute13                =   X_attribute13,
     attribute14                =   X_attribute14,
     attribute15                =   X_attribute15,
     basis_type                 =   l_basis_type    ---LBM enh
   WHERE rowid = X_rowid;

  ELSE

   UPDATE WSM_CO_PRODUCTS
   SET
     co_product_group_id        =   X_co_product_group_id,
     component_id               =   X_component_id,
     organization_id            =   X_organization_id,
     last_update_login          =   X_last_update_login,
     last_update_date           =   X_last_update_date,
     last_updated_by            =   X_last_updated_by,
     co_product_id              =   X_co_product_id,
     bill_sequence_id           =   X_bill_sequence_id,
     component_sequence_id      =   X_component_sequence_id,
     split                      =   X_split,
     effectivity_date           =   X_effectivity_date,
     disable_date               =   X_disable_date,
     primary_flag               =   X_primary_flag,
     revision                   =   X_revision,
     change_notice              =   X_change_notice,
     implementation_date        =   X_implementation_date,
     usage_rate                 =   X_usage_rate,
     duality_flag               =   X_duality_flag,
     planning_factor            =   X_planning_factor,
     component_yield_factor     =   X_component_yield_factor,
     include_in_cost_rollup     =   X_include_in_cost_rollup,
     wip_supply_type            =   X_wip_supply_type,
     supply_subinventory        =   X_supply_subinventory,
     supply_locator_id          =   X_supply_locator_id,
     component_remarks          =   X_component_remarks,
     comp_attribute_category    =   X_attribute_category,
     comp_attribute1            =   X_attribute1,
     comp_attribute2            =   X_attribute2,
     comp_attribute3            =   X_attribute3,
     comp_attribute4            =   X_attribute4,
     comp_attribute5            =   X_attribute5,
     comp_attribute6            =   X_attribute6,
     comp_attribute7            =   X_attribute7,
     comp_attribute8            =   X_attribute8,
     comp_attribute9            =   X_attribute9,
     comp_attribute10           =   X_attribute10,
     comp_attribute11           =   X_attribute11,
     comp_attribute12           =   X_attribute12,
     comp_attribute13           =   X_attribute13,
     comp_attribute14           =   X_attribute14,
     comp_attribute15           =   X_attribute15,
     basis_type                 =   l_basis_type    ---LBM enh
   WHERE rowid = X_rowid;

  END IF;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;



  PROCEDURE Check_Unique(X_Rowid			VARCHAR2,
		     	 X_component_id			NUMBER,
                       X_organization_id              NUMBER) IS

  x1_dummy 	NUMBER;  --abedajna
  dummy 	NUMBER;
  x_component   VARCHAR2(820);

  co_pdt_reltn_exst_error 	EXCEPTION;  --abedajna

  BEGIN


-- commented out by abedajna on 10/12/00 for perf. tuning

/*  SELECT 1 INTO dummy
**  FROM   DUAL
**  WHERE NOT EXISTS
**    ( SELECT 1
**      FROM WSM_co_products
**      WHERE component_id = X_component_id
**      AND   organization_id = X_organization_id
**      AND  ((X_Rowid IS NULL) OR (ROWID <> X_ROWID)));
**
**  EXCEPTION
**  WHEN NO_DATA_FOUND THEN
*/
      /* DEBUG - New Message */
/*
**      fnd_message.set_name ('BOM', 'CO_PRODUCT_RELATION_EXISTS');
*/

-- modification begin for perf. tuning.. abedajna 10/12/00

  x1_dummy := 0;

  SELECT 1 INTO x1_dummy
  FROM WSM_co_products
  WHERE component_id = X_component_id
  AND   organization_id = X_organization_id
  AND  ((X_Rowid IS NULL) OR (ROWID <> X_ROWID));

  IF x1_dummy <> 0 THEN
  	RAISE co_pdt_reltn_exst_error;
  END IF;

  EXCEPTION

  WHEN co_pdt_reltn_exst_error THEN
      fnd_message.set_name ('BOM', 'CO_PRODUCT_RELATION_EXISTS');


  WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name ('BOM', 'CO_PRODUCT_RELATION_EXISTS');


  WHEN NO_DATA_FOUND THEN
  	NULL;

-- modification end for perf. tuning.. abedajna 10/12/00


      SELECT item_number
      INTO   x_component
      FROM   mtl_item_flexfields
      WHERE  inventory_item_id = x_component_id
      AND    organization_id   = x_organization_id;

      fnd_message.set_token ('COMPONENT', x_component);
      app_exception.raise_exception;

END Check_Unique;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN

    DELETE FROM WSM_CO_PRODUCTS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
END Delete_Row;

END WSMPCPDS;

/
