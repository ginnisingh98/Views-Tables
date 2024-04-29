--------------------------------------------------------
--  DDL for Package Body FLM_PULLSEQUENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_PULLSEQUENCE" as
/* $Header: FLMKBPSB.pls 115.4 2002/11/27 11:24:22 nrajpal noship $ */



FUNCTION  Check_Unique( p_Organization_Id          NUMBER,
                        p_Kanban_Plan_Id           NUMBER,
                        p_Inventory_Item_Id        NUMBER,
                        p_Subinventory_Name        VARCHAR2,
                        p_Locator_Id               NUMBER)
RETURN BOOLEAN IS
  l_Dummy Varchar2(1);
BEGIN
  Select 'x'
  Into l_Dummy
  From MTL_KANBAN_PULL_SEQUENCES
  Where organization_id = p_Organization_Id
  And   kanban_plan_id = p_kanban_plan_id
  And   inventory_item_id = p_inventory_item_id
  And   subinventory_name = p_Subinventory_Name
  And   nvl(locator_id,-1)= nvl(p_locator_id,-1);

  Return False;

Exception
  When No_Data_found Then
    Return True;

END Check_Unique;


PROCEDURE   Insert_Row(x_rowid		  IN OUT NOCOPY Varchar2,
                       x_pull_sequence_id IN Out NOCOPY NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id       		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_Kanban_Flag 		NUMBER,
                       p_Calculate_Kanban_Flag 		NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_type		NUMBER,
                       p_Allocation_Percent		NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag          		NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
                       p_Request_Id        		NUMBER,
                       p_Program_application_Id		NUMBER,
                       p_Program_Id        		NUMBER,
                       p_Program_Update_date        	DATE,
		       p_point_of_use_x			NUMBER,
		       p_point_of_use_y			NUMBER,
		       p_point_of_supply_x		NUMBER,
		       p_point_of_supply_y		NUMBER --,
		       -- p_update_status			NUMBER
	) IS

   CURSOR C1 IS SELECT rowid FROM MTL_KANBAN_PULL_SEQUENCES
             WHERE pull_sequence_id = x_pull_sequence_id;
   CURSOR C2 IS SELECT mtl_kanban_pull_sequences_s.nextval FROM sys.dual;

BEGIN
   if (x_pull_sequence_id is NULL) then
     OPEN C2;
     FETCH C2 INTO x_pull_sequence_id;
     CLOSE C2;
   end if;

   INSERT INTO MTL_KANBAN_PULL_SEQUENCES(
              Pull_sequence_id,
              Inventory_item_id,
              Organization_id,
              Subinventory_name,
              Kanban_Plan_id,
              Source_type,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_By,
              Last_Update_Login,
              Locator_id,
              Supplier_id,
              Supplier_site_id,
              Source_Organization_id,
              Source_Subinventory,
              Source_Locator_id,
              Wip_Line_id,
              Release_Kanban_flag,
              Calculate_Kanban_flag,
              Kanban_size,
              Number_of_cards,
              Minimum_order_quantity,
              Aggregation_type,
              Allocation_Percent,
              Replenishment_lead_time,
              Fixed_Lot_multiplier,
              Safety_Stock_Days,
              Updated_Flag,
              Attribute_Category,
              Attribute1,
              Attribute2,
              Attribute3,
              Attribute4,
              Attribute5,
              Attribute6,
              Attribute7,
              Attribute8,
              Attribute9,
              Attribute10,
              Attribute11,
              Attribute12,
              Attribute13,
              Attribute14,
              Attribute15,
              Request_Id,
              Program_application_Id,
              Program_Id,
              Program_Update_date,
	      Point_of_use_x,
	      Point_of_use_y,
	      Point_of_supply_x,
	      Point_of_supply_y --,
--	      Update_status
    ) Values (
              x_Pull_sequence_id,
              p_Inventory_item_id,
              p_Organization_id,
              p_Subinventory_name,
              p_Kanban_Plan_id,
              p_Source_type,
              p_Last_Update_Date,
              p_Last_Updated_By,
              p_Creation_Date,
              p_Created_By,
              p_Last_Update_Login,
              p_Locator_id,
              p_Supplier_id,
              p_Supplier_site_id,
              p_Source_Organization_id,
              p_Source_Subinventory,
              p_Source_Locator_id,
              p_Wip_Line_id,
              p_Release_Kanban_flag,
              p_Calculate_Kanban_flag,
              p_Kanban_size,
              p_Number_of_cards,
              p_Minimum_order_quantity,
              p_Aggregation_type,
              p_Allocation_Percent,
              p_Replenishment_lead_time,
              p_Fixed_Lot_multiplier,
              p_Safety_Stock_Days,
              p_Updated_Flag,
              p_Attribute_Category,
              p_Attribute1,
              p_Attribute2,
              p_Attribute3,
              p_Attribute4,
              p_Attribute5,
              p_Attribute6,
              p_Attribute7,
              p_Attribute8,
              p_Attribute9,
              p_Attribute10,
              p_Attribute11,
              p_Attribute12,
              p_Attribute13,
              p_Attribute14,
              p_Attribute15,
              p_Request_Id,
              p_Program_application_Id,
              p_Program_Id,
              p_Program_Update_Date,
	      p_Point_of_use_x,
	      p_Point_of_use_y,
	      p_Point_of_supply_x,
	      p_Point_of_supply_y --,
--	      p_Update_status
	);

  OPEN C1;
  FETCH C1 INTO x_rowid;
  if (C1%NOTFOUND) then
    CLOSE C1;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C1;

End Insert_Row;

PROCEDURE   Lock_Row  (p_Pull_Sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id        		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_Kanban_flag            NUMBER,
                       p_Calculate_Kanban_flag          NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_type		NUMBER,
                       p_Allocation_Percent             NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag           	NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
		       p_point_of_use_x			NUMBER,
		       p_point_of_use_y			NUMBER,
		       p_point_of_supply_x		NUMBER,
		       p_point_of_supply_y		NUMBER --,
		       -- p_update_status			NUMBER
	) IS
    CURSOR C IS
        SELECT *
        FROM   MTL_KANBAN_PULL_SEQUENCES
        WHERE  pull_sequence_id = p_pull_sequence_id
        FOR UPDATE of source_type NOWAIT;

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
	Recinfo.Inventory_item_id = p_Inventory_item_id and
      	Recinfo.Organization_Id = p_Organization_Id and
 	Recinfo.Subinventory_name = p_Subinventory_name and
 	Recinfo.Kanban_Plan_id = p_Kanban_Plan_id and
	Recinfo.Source_type = p_Source_type and
      ((Recinfo.Locator_id		=	p_Locator_id)
     or ((Recinfo.Locator_id is null)  and (p_Locator_id is null))) and
      ((Recinfo.Supplier_id		=	p_Supplier_id)
     or ((Recinfo.Supplier_id is null) and (p_Supplier_id is null))) and
      ((Recinfo.Supplier_site_id	=	p_Supplier_site_id)
     or ((Recinfo.Supplier_site_id is null) and (p_Supplier_site_id is null))) and
      ((Recinfo.Source_Organization_id	=	p_Source_Organization_id)
     or ((Recinfo.Source_Organization_id is null) and (p_Source_Organization_id is null))) and
      ((Recinfo.Source_Subinventory	=	p_Source_Subinventory)
     or ((Recinfo.Source_Subinventory is null) and (p_Source_Subinventory is null))) and
      ((Recinfo.Source_Locator_id	=	p_Source_Locator_id)
     or ((Recinfo.Source_Locator_id is null) and (p_Source_Locator_id is null))) and
      ((Recinfo.Wip_Line_id		=	p_Wip_Line_id)
     or ((Recinfo.Wip_Line_id is null) and (p_Wip_Line_id is null))) and
      ((Recinfo.Release_Kanban_Flag	=	p_Release_Kanban_flag)
     or ((Recinfo.Release_Kanban_flag is null) and (p_Release_Kanban_flag is null))) and
      ((Recinfo.Calculate_Kanban_Flag	=	p_Calculate_Kanban_flag)
     or ((Recinfo.Calculate_Kanban_flag is null) and (p_Calculate_Kanban_flag is null))) and
      ((Recinfo.Kanban_size		=	p_Kanban_size)
     or ((Recinfo.Kanban_size is null) and (p_Kanban_size is null))) and
      ((Recinfo.Number_of_cards		=	p_Number_of_cards)
     or ((Recinfo.Number_of_cards is null) and (p_Number_of_cards is null))) and
      ((Recinfo.Minimum_order_quantity	=	p_Minimum_order_quantity)
     or ((Recinfo.Minimum_order_quantity is null) and (p_Minimum_order_quantity is null))) and
      ((Recinfo.Aggregation_Type	=	p_Aggregation_Type)
     or ((Recinfo.Aggregation_Type is null) and (p_Aggregation_Type is null))) and
      ((Recinfo.Allocation_Percent	=	p_Allocation_Percent)
     or ((Recinfo.Allocation_Percent is null) and (p_Allocation_Percent is null))) and
      ((Recinfo.Replenishment_lead_time	=	p_Replenishment_lead_time)
     or ((Recinfo.Replenishment_lead_time is null) and (p_Replenishment_lead_time is null))) and
      ((Recinfo.fixed_lot_multiplier	=	p_fixed_lot_multiplier)
     or ((Recinfo.fixed_lot_multiplier is null) and (p_fixed_lot_multiplier is null))) and
      ((Recinfo.Safety_Stock_Days	=	p_Safety_Stock_Days)
     or ((Recinfo.Safety_Stock_Days is null) and (p_Safety_Stock_Days is null))) and
      ((Recinfo.Updated_Flag		=	p_Updated_Flag)
     or ((Recinfo.Updated_Flag is null) and (p_Updated_Flag is null)))
      AND (   (Recinfo.point_of_use_x =  p_point_of_use_x)
           OR (    (Recinfo.point_of_use_x IS NULL)
               AND (p_point_of_use_x IS NULL)))
      AND (   (Recinfo.point_of_use_y =  p_point_of_use_y)
           OR (    (Recinfo.point_of_use_y IS NULL)
               AND (p_point_of_use_y IS NULL)))
      AND (   (Recinfo.point_of_supply_x =  p_point_of_supply_x)
           OR (    (Recinfo.point_of_supply_x IS NULL)
               AND (p_point_of_supply_x IS NULL)))
      AND (   (Recinfo.point_of_supply_y =  p_point_of_supply_y)
           OR (    (Recinfo.point_of_supply_y IS NULL)
               AND (p_point_of_supply_y IS NULL)))
/*
      AND (   (Recinfo.update_status =  p_update_status)
           OR (    (Recinfo.update_status IS NULL)
               AND (p_update_status IS NULL)))
*/
      AND (   (Recinfo.Attribute_Category = p_Attribute_Category)
           OR (    (Recinfo.Attribute_Category is null)
	       AND (p_Attribute_Category is null)))
      AND (   (Recinfo.attribute1 = p_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (p_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 =  p_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (p_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 =  p_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (p_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 =  p_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (p_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 =  p_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (p_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 =  p_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (p_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 =  p_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (p_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 =  p_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (p_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 =  p_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (p_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 =  p_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (p_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 =  p_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (p_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 =  p_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (p_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 =  p_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (p_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 =  p_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (p_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 =  p_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (p_Attribute15 IS NULL)))
  ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

END Lock_Row;


PROCEDURE   Update_Row(p_Pull_Sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id        		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_Kanban_flag 		NUMBER,
                       p_Calculate_Kanban_flag 		NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_Type		NUMBER,
                       p_Allocation_Percent		NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag           	NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
		       p_point_of_use_x			NUMBER,
		       p_point_of_use_y			NUMBER,
		       p_point_of_supply_x		NUMBER,
		       p_point_of_supply_y		NUMBER --,
--		       p_update_status			NUMBER
	) IS

BEGIN

	UPDATE MTL_KANBAN_PULL_SEQUENCES
	SET
      		Inventory_item_id 	=	p_Inventory_item_id,
      		Organization_Id 	=	p_Organization_Id,
 		Subinventory_name       =	p_Subinventory_name,
	 	Kanban_Plan_id         	=	p_Kanban_Plan_id,
 		Source_type             =	p_Source_type,
 		Last_Update_Date        =	p_Last_Update_Date,
 		Last_Updated_By         =	p_Last_Updated_By,
 		Creation_Date           =	p_Creation_Date,
 		Created_By              =	p_Created_By,
 		Last_Update_Login       =	p_Last_Update_Login,
 		Locator_id              =	p_Locator_id,
 		Supplier_id             =	p_Supplier_id,
 		Supplier_site_id        =	p_Supplier_site_id,
 		Source_Organization_id  =	p_Source_Organization_id,
 		Source_Subinventory     =	p_Source_Subinventory,
 		Source_Locator_id       =	p_Source_Locator_id,
 		Wip_Line_id             =	p_Wip_Line_id,
 		Release_Kanban_Flag     =	p_Release_Kanban_flag,
 		Calculate_Kanban_Flag   =	p_Calculate_Kanban_flag,
 		Kanban_size             =	p_Kanban_size,
 		Number_of_cards         =	p_Number_of_cards,
 		Minimum_order_quantity  =	p_Minimum_order_quantity,
 		Aggregation_Type        =	p_Aggregation_Type,
 		Allocation_Percent      =	p_Allocation_Percent,
 		Replenishment_lead_time =	p_Replenishment_lead_time,
 		Fixed_Lot_multiplier    =	p_Fixed_Lot_multiplier,
 		Safety_Stock_Days       =	p_Safety_Stock_Days,
 		Updated_Flag            =	p_Updated_Flag,
		Point_of_use_x		=	p_Point_of_use_x,
		Point_of_use_y		=	p_Point_of_use_y,
		Point_of_supply_x	=	p_Point_of_supply_x,
		Point_of_supply_y	=	p_Point_of_supply_y,
-- 		Update_Status		=	p_Update_Status,
 		Attribute_Category      =	p_Attribute_Category,
 		Attribute1              =	p_Attribute1,
 		Attribute2              =	p_Attribute2,
 		Attribute3              =	p_Attribute3,
 		Attribute4              =	p_Attribute4,
 		Attribute5              =	p_Attribute5,
 		Attribute6              =	p_Attribute6,
 		Attribute7              =	p_Attribute7,
 		Attribute8              =	p_Attribute8,
 		Attribute9              =	p_Attribute9,
 		Attribute10             =	p_Attribute10,
 		Attribute11             =	p_Attribute11,
 		Attribute12             =	p_Attribute12,
 		Attribute13             =	p_Attribute13,
 		Attribute14             =	p_Attribute14,
 		Attribute15             =	p_Attribute15
    WHERE pull_sequence_id = p_pull_sequence_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

END Update_Row;


PROCEDURE Delete_Row(p_Pull_Sequence_Id     Number) IS

BEGIN

  DELETE FROM MTL_KANBAN_PULL_SEQUENCES
  WHERE pull_sequence_id = p_pull_sequence_id;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;

END Delete_Row;

END FLM_PullSequence;

/
