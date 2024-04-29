--------------------------------------------------------
--  DDL for Package Body MTL_CYCLE_COUNT_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CYCLE_COUNT_ENTRIES_PKG" as
/* $Header: INVATCEB.pls 120.1.12000000.2 2007/07/18 10:29:20 abaid ship $ */
--Added NOCOPY hint to X_Rowid IN OUT parameter to comply with
--GSCC File.Sql.39 standard Bug:4410902
  PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,
                       X_Cycle_Count_Entry_Id           NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Count_List_Sequence            NUMBER,
                       X_Count_Date_First               DATE,
                       X_Count_Date_Current             DATE,
                       X_Count_Date_Prior               DATE,
                       X_Count_Date_Dummy               DATE,
                       X_Counted_By_Employee_Id_First   NUMBER,
                       X_Counted_By_Employee_Id_Curr    NUMBER,
                       X_Counted_By_Employee_Id_Prior   NUMBER,
                       X_Counted_By_Employee_Id_Dummy   NUMBER,
                       X_Count_Uom_First                VARCHAR2,
                       X_Count_Uom_Current              VARCHAR2,
                       X_Count_Uom_Prior                VARCHAR2,
                       X_Count_Quantity_First           NUMBER,
                       X_Count_Quantity_Current         NUMBER,
                       X_Count_Quantity_Prior           NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Entry_Status_Code              NUMBER,
                       X_Count_Due_Date                 DATE,
                       X_Organization_Id                NUMBER,
                       X_Cycle_Count_Header_Id          NUMBER,
                       X_Number_Of_Counts               NUMBER,
                       X_Locator_Id                     NUMBER,
                       X_Adjustment_Quantity            NUMBER,
                       X_Adjustment_Date                DATE,
                       X_Adjustment_Amount              NUMBER,
                       X_Item_Unit_Cost                 NUMBER,
                       X_Inventory_Adjustment_Account   NUMBER,
                       X_Approval_Date                  DATE,
                       X_Approver_Employee_Id           NUMBER,
                       X_Revision                       VARCHAR2,
                       X_Lot_Number                     VARCHAR2,
                       X_Lot_Control                    VARCHAR2,
                       X_System_Quantity_First          NUMBER,
                       X_System_Quantity_Current        NUMBER,
                       X_System_Quantity_Prior          NUMBER,
                       X_Reference_First                VARCHAR2,
                       X_Reference_Current              VARCHAR2,
                       X_Reference_Prior                VARCHAR2,
                       X_Primary_Uom_Quantity_First     NUMBER,
                       X_Primary_Uom_Quantity_Current   NUMBER,
                       X_Primary_Uom_Quantity_Prior     NUMBER,
                       X_Count_Type_Code                NUMBER,
                       X_Transaction_Reason_Id          NUMBER,
                       X_Approval_Type                  NUMBER,
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
		       X_Serial_Number			VARCHAR2,
		       X_Serial_Detail			NUMBER,
		       X_Approval_Condition		NUMBER,
		       X_Neg_Adjustment_Quantity	NUMBER,
		       X_Neg_Adjustment_Amount		NUMBER,
                       X_Outermost_Lpn_ID               NUMBER DEFAULT NULL,
                       X_Parent_Lpn_ID                  NUMBER DEFAULT NULL,
                       X_Cost_Group_ID                  NUMBER DEFAULT NULL,
                       -- BEGIN INVCONV
                       X_Count_Secondary_Uom_First      VARCHAR2 DEFAULT NULL,
                       X_Count_Secondary_Uom_Current    VARCHAR2 DEFAULT NULL,
                       X_Count_Secondary_Uom_Prior      VARCHAR2 DEFAULT NULL,
                       X_Secondary_Uom_Quantity_First   NUMBER   DEFAULT NULL,
                       X_Secondary_Uom_Quantity_Curr    NUMBER   DEFAULT NULL,
                       X_Secondary_Uom_Quantity_Prior   NUMBER   DEFAULT NULL,
                       X_Secondary_System_Qty_First     NUMBER   DEFAULT NULL,
                       X_Secondary_System_Qty_Current   NUMBER   DEFAULT NULL,
                       X_Secondary_System_Qty_Prior     NUMBER   DEFAULT NULL,
                       X_Secondary_Adjustment_Qty       NUMBER   DEFAULT NULL
                       -- END INVCONV
  ) IS
    CURSOR C IS SELECT rowid FROM mtl_cycle_count_entries
                 WHERE (   (cycle_count_header_id = X_Cycle_Count_Header_Id)
                        or (cycle_count_header_id is NULL and X_Cycle_Count_Header_Id is NULL));

   BEGIN
       INSERT INTO mtl_cycle_count_entries(
              cycle_count_entry_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              count_list_sequence,
              count_date_first,
              count_date_current,
              count_date_prior,
              count_date_dummy,
              counted_by_employee_id_first,
              counted_by_employee_id_current,
              counted_by_employee_id_prior,
              counted_by_employee_id_dummy,
              count_uom_first,
              count_uom_current,
              count_uom_prior,
              count_quantity_first,
              count_quantity_current,
              count_quantity_prior,
              inventory_item_id,
              subinventory,
              entry_status_code,
              count_due_date,
              organization_id,
              cycle_count_header_id,
              number_of_counts,
              locator_id,
              adjustment_quantity,
              adjustment_date,
              adjustment_amount,
              item_unit_cost,
              inventory_adjustment_account,
              approval_date,
              approver_employee_id,
              revision,
              lot_number,
              lot_control,
              system_quantity_first,
              system_quantity_current,
              system_quantity_prior,
              reference_first,
              reference_current,
              reference_prior,
              primary_uom_quantity_first,
              primary_uom_quantity_current,
              primary_uom_quantity_prior,
              count_type_code,
              transaction_reason_id,
              approval_type,
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
	      serial_number,
	      serial_detail,
	      approval_condition,
	      neg_adjustment_quantity,
	      neg_adjustment_amount,
              outermost_lpn_id,
              parent_lpn_id,
              cost_group_id,
              -- BEGIN INVCONV
              Count_Secondary_Uom_First,
              Count_Secondary_Uom_Current,
              Count_Secondary_Uom_Prior,
              Secondary_Uom_Quantity_First,
              Secondary_Uom_Quantity_Current,
              Secondary_Uom_Quantity_Prior,
              Secondary_System_Qty_First,
              Secondary_System_Qty_Current,
              Secondary_System_Qty_Prior,
              Secondary_Adjustment_Quantity
              -- END INVCONV
             )
	VALUES (
              X_Cycle_Count_Entry_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Count_List_Sequence,
              X_Count_Date_First,
              X_Count_Date_Current,
              X_Count_Date_Prior,
              X_Count_Date_Dummy,
              X_Counted_By_Employee_Id_First,
              X_Counted_By_Employee_Id_Curr,
              X_Counted_By_Employee_Id_Prior,
              X_Counted_By_Employee_Id_Dummy,
              X_Count_Uom_First,
              X_Count_Uom_Current,
              X_Count_Uom_Prior,
              X_Count_Quantity_First,
              X_Count_Quantity_Current,
              X_Count_Quantity_Prior,
              X_Inventory_Item_Id,
              X_Subinventory,
              X_Entry_Status_Code,
              X_Count_Due_Date,
              X_Organization_Id,
              X_Cycle_Count_Header_Id,
              X_Number_Of_Counts,
              X_Locator_Id,
              X_Adjustment_Quantity,
              X_Adjustment_Date,
              X_Adjustment_Amount,
              X_Item_Unit_Cost,
              X_Inventory_Adjustment_Account,
              X_Approval_Date,
              X_Approver_Employee_Id,
              X_Revision,
              X_Lot_Number,
              X_Lot_Control,
              X_System_Quantity_First,
              X_System_Quantity_Current,
              X_System_Quantity_Prior,
              X_Reference_First,
              X_Reference_Current,
              X_Reference_Prior,
              X_Primary_Uom_Quantity_First,
              X_Primary_Uom_Quantity_Current,
              X_Primary_Uom_Quantity_Prior,
              X_Count_Type_Code,
              X_Transaction_Reason_Id,
              X_Approval_Type,
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
	      X_Serial_Number,
	      X_Serial_Detail,
	      X_Approval_Condition,
	      X_Neg_Adjustment_Quantity,
	      X_Neg_Adjustment_Amount,
              X_Outermost_Lpn_ID,
              X_Parent_Lpn_ID,
              X_Cost_Group_ID,
              -- BEGIN INVCONV
              X_Count_Secondary_Uom_First,
              X_Count_Secondary_Uom_Current,
              X_Count_Secondary_Uom_Prior,
              X_Secondary_Uom_Quantity_First,
              X_Secondary_Uom_Quantity_Curr,
              X_Secondary_Uom_Quantity_Prior,
              X_Secondary_System_Qty_First,
              X_Secondary_System_Qty_Current,
              X_Secondary_System_Qty_Prior,
              X_Secondary_Adjustment_Qty
              -- END INVCONV
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cycle_Count_Entry_Id             NUMBER,
                     X_Count_List_Sequence              NUMBER,
                     X_Count_Date_First                 DATE,
                     X_Count_Date_Current               DATE,
                     X_Count_Date_Prior                 DATE,
                     X_Count_Date_Dummy                 DATE,
                     X_Counted_By_Employee_Id_First     NUMBER,
                     X_Counted_By_Employee_Id_Curr      NUMBER,
                     X_Counted_By_Employee_Id_Prior     NUMBER,
                     X_Counted_By_Employee_Id_Dummy     NUMBER,
                     X_Count_Uom_First                  VARCHAR2,
                     X_Count_Uom_Current                VARCHAR2,
                     X_Count_Uom_Prior                  VARCHAR2,
                     X_Count_Quantity_First             NUMBER,
                     X_Count_Quantity_Current           NUMBER,
                     X_Count_Quantity_Prior             NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Subinventory                     VARCHAR2,
                     X_Entry_Status_Code                NUMBER,
                     X_Count_Due_Date                   DATE,
                     X_Organization_Id                  NUMBER,
                     X_Cycle_Count_Header_Id            NUMBER,
                     X_Number_Of_Counts                 NUMBER,
                     X_Locator_Id                       NUMBER,
                     X_Adjustment_Quantity              NUMBER,
                     X_Adjustment_Date                  DATE,
                     X_Adjustment_Amount                NUMBER,
                     X_Item_Unit_Cost                   NUMBER,
                     X_Inventory_Adjustment_Account     NUMBER,
                     X_Approval_Date                    DATE,
                     X_Approver_Employee_Id             NUMBER,
                     X_Revision                         VARCHAR2,
                     X_Lot_Number                       VARCHAR2,
                     X_Lot_Control                      VARCHAR2,
                     X_System_Quantity_First            NUMBER,
                     X_System_Quantity_Current          NUMBER,
                     X_System_Quantity_Prior            NUMBER,
                     X_Reference_First                  VARCHAR2,
                     X_Reference_Current                VARCHAR2,
                     X_Reference_Prior                  VARCHAR2,
                     X_Primary_Uom_Quantity_First       NUMBER,
                     X_Primary_Uom_Quantity_Current     NUMBER,
                     X_Primary_Uom_Quantity_Prior       NUMBER,
                     X_Count_Type_Code                  NUMBER,
                     X_Transaction_Reason_Id            NUMBER,
                     X_Approval_Type                    NUMBER,
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
		     X_Serial_Number			VARCHAR2,
		     X_Serial_Detail			NUMBER,
		     X_Approval_Condition		NUMBER,
		     X_Neg_Adjustment_Quantity		NUMBER,
		     X_Neg_Adjustment_Amount		NUMBER,
                     X_Outermost_Lpn_ID                 NUMBER DEFAULT NULL,
                     X_Parent_Lpn_ID                    NUMBER DEFAULT NULL,
                     X_Cost_Group_ID                    NUMBER DEFAULT NULL,
                     -- BEGIN INVCONV
                     X_Count_Secondary_Uom_First      VARCHAR2 DEFAULT NULL,
                     X_Count_Secondary_Uom_Current    VARCHAR2 DEFAULT NULL,
                     X_Count_Secondary_Uom_Prior      VARCHAR2 DEFAULT NULL,
                     X_Secondary_Uom_Quantity_First   NUMBER   DEFAULT NULL,
                     X_Secondary_Uom_Quantity_Curr    NUMBER   DEFAULT NULL,
                     X_Secondary_Uom_Quantity_Prior   NUMBER   DEFAULT NULL,
                     X_Secondary_System_Qty_First     NUMBER   DEFAULT NULL,
                     X_Secondary_System_Qty_Current   NUMBER   DEFAULT NULL,
                     X_Secondary_System_Qty_Prior     NUMBER   DEFAULT NULL,
                     X_Secondary_Adjustment_Qty       NUMBER   DEFAULT NULL
                     -- END INVCONV
  ) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_cycle_count_entries
        WHERE  rowid = X_Rowid
        FOR UPDATE of Cycle_Count_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;
    RECORD_CHANGED EXCEPTION;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if not ( (Recinfo.cycle_count_entry_id =  X_Cycle_Count_Entry_Id)
           AND (   (Recinfo.count_list_sequence =  X_Count_List_Sequence)
                OR (    (Recinfo.count_list_sequence IS NULL)
                    AND (X_Count_List_Sequence IS NULL)))
           AND (   (Recinfo.count_date_first =  X_Count_Date_First)
                OR (    (Recinfo.count_date_first IS NULL)
                    AND (X_Count_Date_First IS NULL)))
           AND (   (Recinfo.count_date_current =  X_Count_Date_Current)
                OR (    (Recinfo.count_date_current IS NULL)
                    AND (X_Count_Date_Current IS NULL)))
           AND (   (Recinfo.count_date_prior =  X_Count_Date_Prior)
                OR (    (Recinfo.count_date_prior IS NULL)
                    AND (X_Count_Date_Prior IS NULL)))
           AND (   (Recinfo.count_date_dummy =  X_Count_Date_Dummy)
                OR (    (Recinfo.count_date_dummy IS NULL)
                    AND (X_Count_Date_Dummy IS NULL)))
           AND (   (Recinfo.counted_by_employee_id_first =  X_Counted_By_Employee_Id_First)
                OR (    (Recinfo.counted_by_employee_id_first IS NULL)
                    AND (X_Counted_By_Employee_Id_First IS NULL)))
           AND (   (Recinfo.counted_by_employee_id_current =  X_Counted_By_Employee_Id_Curr)
                OR (    (Recinfo.counted_by_employee_id_current IS NULL)
                    AND (X_Counted_By_Employee_Id_Curr IS NULL)))
           AND (   (Recinfo.counted_by_employee_id_prior =  X_Counted_By_Employee_Id_Prior)
                OR (    (Recinfo.counted_by_employee_id_prior IS NULL)
                    AND (X_Counted_By_Employee_Id_Prior IS NULL)))
           AND (   (Recinfo.counted_by_employee_id_dummy =  X_Counted_By_Employee_Id_Dummy)
                OR (    (Recinfo.counted_by_employee_id_dummy IS NULL)
                    AND (X_Counted_By_Employee_Id_Dummy IS NULL)))
           AND (   (Recinfo.count_uom_first =  X_Count_Uom_First)
                OR (    (Recinfo.count_uom_first IS NULL)
                    AND (X_Count_Uom_First IS NULL)))
           AND (   (Recinfo.count_uom_current =  X_Count_Uom_Current)
                OR (    (Recinfo.count_uom_current IS NULL)
                    AND (X_Count_Uom_Current IS NULL)))
           AND (   (Recinfo.count_uom_prior =  X_Count_Uom_Prior)
                OR (    (Recinfo.count_uom_prior IS NULL)
                    AND (X_Count_Uom_Prior IS NULL)))
           AND (   (Recinfo.count_quantity_first =  X_Count_Quantity_First)
                OR (    (Recinfo.count_quantity_first IS NULL)
                    AND (X_Count_Quantity_First IS NULL)))
           AND (   (Recinfo.count_quantity_current =  X_Count_Quantity_Current)
                OR (    (Recinfo.count_quantity_current IS NULL)
                    AND (X_Count_Quantity_Current IS NULL)))
           AND (   (Recinfo.count_quantity_prior =  X_Count_Quantity_Prior)
                OR (    (Recinfo.count_quantity_prior IS NULL)
                    AND (X_Count_Quantity_Prior IS NULL)))
           AND (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (Recinfo.subinventory =  X_Subinventory)
           AND (   (Recinfo.entry_status_code =  X_Entry_Status_Code)
                OR (    (Recinfo.entry_status_code IS NULL)
                    AND (X_Entry_Status_Code IS NULL)))
           AND (   (Recinfo.count_due_date =  X_Count_Due_Date)
                OR (    (Recinfo.count_due_date IS NULL)
                    AND (X_Count_Due_Date IS NULL)))
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (   (Recinfo.cycle_count_header_id =  X_Cycle_Count_Header_Id)
                OR (    (Recinfo.cycle_count_header_id IS NULL)
                    AND (X_Cycle_Count_Header_Id IS NULL)))
           AND (   (Recinfo.number_of_counts =  X_Number_Of_Counts)
                OR (    (Recinfo.number_of_counts IS NULL)
                    AND (X_Number_Of_Counts IS NULL)))
           AND (   (Recinfo.locator_id =  X_Locator_Id)
                OR (    (Recinfo.locator_id IS NULL)
                    AND (X_Locator_Id IS NULL)))
           AND (   (Recinfo.adjustment_quantity =  X_Adjustment_Quantity)
                OR (    (Recinfo.adjustment_quantity IS NULL)
                    AND (X_Adjustment_Quantity IS NULL)))
           AND (   (Recinfo.adjustment_date =  X_Adjustment_Date)
                OR (    (Recinfo.adjustment_date IS NULL)
                    AND (X_Adjustment_Date IS NULL)))
           AND (   (Recinfo.adjustment_amount =  X_Adjustment_Amount)
                OR (    (Recinfo.adjustment_amount IS NULL)
                    AND (X_Adjustment_Amount IS NULL)))
           AND (   (Recinfo.item_unit_cost =  X_Item_Unit_Cost)
                OR (    (Recinfo.item_unit_cost IS NULL)
                    AND (X_Item_Unit_Cost IS NULL)))
           AND (   (Recinfo.inventory_adjustment_account =  X_Inventory_Adjustment_Account)
                OR (    (Recinfo.inventory_adjustment_account IS NULL)
                    AND (X_Inventory_Adjustment_Account IS NULL)))
           AND (   (Recinfo.approval_date =  X_Approval_Date)
                OR (    (Recinfo.approval_date IS NULL)
                    AND (X_Approval_Date IS NULL)))
           AND (   (Recinfo.approver_employee_id =  X_Approver_Employee_Id)
                OR (    (Recinfo.approver_employee_id IS NULL)
                    AND (X_Approver_Employee_Id IS NULL)))
           AND (   (Recinfo.revision =  X_Revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_Revision IS NULL)))
           AND (   (Recinfo.lot_number =  X_Lot_Number)
                OR (    (Recinfo.lot_number IS NULL)
                    AND (X_Lot_Number IS NULL)))
           AND (   (Recinfo.lot_control =  X_Lot_Control)
                OR (    (Recinfo.lot_control IS NULL)
                    AND (X_Lot_Control IS NULL)))
           AND (   (Recinfo.system_quantity_first =  X_System_Quantity_First)
                OR (    (Recinfo.system_quantity_first IS NULL)
                    AND (X_System_Quantity_First IS NULL)))
           AND (   (Recinfo.system_quantity_current =  X_System_Quantity_Current
)
                OR (    (Recinfo.system_quantity_current IS NULL)
                    AND (X_System_Quantity_Current IS NULL)))
           AND (   (Recinfo.system_quantity_prior =  X_System_Quantity_Prior)
                OR (    (Recinfo.system_quantity_prior IS NULL)
                    AND (X_System_Quantity_Prior IS NULL)))
           AND (   (Recinfo.reference_first =  X_Reference_First)
                OR (    (Recinfo.reference_first IS NULL)
                    AND (X_Reference_First IS NULL)))
           AND (   (Recinfo.reference_current =  X_Reference_Current)
                OR (    (Recinfo.reference_current IS NULL)
                    AND (X_Reference_Current IS NULL)))
           AND (   (Recinfo.reference_prior =  X_Reference_Prior)
                OR (    (Recinfo.reference_prior IS NULL)
                    AND (X_Reference_Prior IS NULL)))
           AND (   (Recinfo.primary_uom_quantity_first =  X_Primary_Uom_Quantity_First)
                OR (    (Recinfo.primary_uom_quantity_first IS NULL)
                    AND (X_Primary_Uom_Quantity_First IS NULL)))
           AND (   (Recinfo.primary_uom_quantity_current =  X_Primary_Uom_Quantity_Current)
                OR (    (Recinfo.primary_uom_quantity_current IS NULL)
                    AND (X_Primary_Uom_Quantity_Current IS NULL)))) then
		RAISE RECORD_CHANGED;
	end if;

          if not ((   (Recinfo.primary_uom_quantity_prior =  X_Primary_Uom_Quantity_Prior)
                OR (    (Recinfo.primary_uom_quantity_prior IS NULL)
                    AND (X_Primary_Uom_Quantity_Prior IS NULL)))
           AND (   (Recinfo.count_type_code =  X_Count_Type_Code)
                OR (    (Recinfo.count_type_code IS NULL)
                    AND (X_Count_Type_Code IS NULL)))
           AND (   (Recinfo.transaction_reason_id =  X_Transaction_Reason_Id)
                OR (    (Recinfo.transaction_reason_id IS NULL)
                    AND (X_Transaction_Reason_Id IS NULL)))
           AND (   (Recinfo.approval_type =  X_Approval_Type)
                OR (    (Recinfo.approval_type IS NULL)
                    AND (X_Approval_Type IS NULL)))
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
           AND (   (Recinfo.serial_number =  X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.serial_detail =  X_Serial_Detail)
                OR (    (Recinfo.serial_detail IS NULL)
                    AND (X_Serial_Detail IS NULL)))
           AND (   (Recinfo.approval_condition =  X_Approval_Condition)
                OR (    (Recinfo.approval_condition IS NULL)
                    AND (X_Approval_Condition IS NULL)))
	   AND (   (Recinfo.neg_adjustment_quantity =  X_Neg_Adjustment_Quantity)
                OR (    (Recinfo.neg_adjustment_quantity IS NULL)
                    AND (X_Neg_Adjustment_Quantity IS NULL)))
           AND (   (Recinfo.neg_adjustment_amount =  X_Neg_Adjustment_Amount)
                OR (    (Recinfo.neg_adjustment_amount IS NULL)
                    AND (X_Neg_Adjustment_Amount IS NULL)))
           AND (   (Recinfo.parent_lpn_id =  X_Parent_Lpn_ID)
                OR (    (Recinfo.parent_lpn_id IS NULL)
                    AND (X_Parent_Lpn_ID IS NULL)))
           AND (   (Recinfo.outermost_lpn_id =  X_Outermost_Lpn_ID)
                OR (    (Recinfo.Outermost_lpn_id IS NULL)
                    AND (X_Outermost_Lpn_ID IS NULL)))
           AND (   (Recinfo.cost_group_id =  X_Cost_Group_ID)
                OR (    (Recinfo.cost_group_id IS NULL)
                    AND (X_Cost_Group_ID IS NULL)))
      ) then
	Raise RECORD_CHANGED;
    end if;

    -- BEGIN INVCONV
    if not ((   (Recinfo.count_secondary_uom_first =  X_Count_Secondary_Uom_First)
                OR (    (Recinfo.count_secondary_uom_first IS NULL)
                    AND (X_Count_Secondary_Uom_First IS NULL)))
           AND (   (Recinfo.count_secondary_uom_current =  X_Count_Secondary_Uom_Current)
                OR (    (Recinfo.count_secondary_uom_current IS NULL)
                    AND (X_Count_Secondary_Uom_Current IS NULL)))
           AND (   (Recinfo.count_secondary_uom_prior =  X_Count_Secondary_Uom_Prior)
                OR (    (Recinfo.count_secondary_uom_prior IS NULL)
                    AND (X_Count_Secondary_Uom_Prior IS NULL)))
           AND (   (Recinfo.secondary_uom_quantity_first =  X_Secondary_Uom_Quantity_First)
                OR (    (Recinfo.secondary_uom_quantity_first IS NULL)
                    AND (X_Secondary_Uom_Quantity_First IS NULL)))
           AND (   (Recinfo.secondary_uom_quantity_current =  X_Secondary_Uom_Quantity_Curr)
                OR (    (Recinfo.secondary_uom_quantity_current IS NULL)
                    AND (X_Secondary_Uom_Quantity_Curr IS NULL)))
           AND (   (Recinfo.secondary_uom_quantity_prior =  X_Secondary_Uom_Quantity_Prior)
                OR (    (Recinfo.secondary_uom_quantity_prior IS NULL)
                    AND (X_Secondary_Uom_Quantity_Prior IS NULL)))
           AND (   (Recinfo.secondary_system_qty_first =  X_Secondary_System_Qty_First)
                OR (    (Recinfo.secondary_system_qty_first IS NULL)
                    AND (X_Secondary_System_Qty_First IS NULL)))
           AND (   (Recinfo.secondary_system_qty_current =  X_Secondary_System_Qty_Current)
                OR (    (Recinfo.secondary_system_qty_current IS NULL)
                    AND (X_Secondary_System_Qty_Current IS NULL)))
           AND (   (Recinfo.secondary_system_qty_prior =  X_Secondary_System_Qty_Prior)
                OR (    (Recinfo.secondary_system_qty_prior IS NULL)
                    AND (X_Secondary_System_Qty_Prior IS NULL)))
           AND (   (Recinfo.secondary_adjustment_quantity =  X_Secondary_Adjustment_Qty)
                OR (    (Recinfo.secondary_adjustment_quantity IS NULL)
                    AND (X_Secondary_Adjustment_Qty IS NULL)))
    ) then
	   Raise RECORD_CHANGED;
    end if;
    -- END INVCONV

    EXCEPTION
    WHEN RECORD_CHANGED THEN
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    WHEN OTHERS THEN
	raise;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cycle_Count_Entry_Id           NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Count_List_Sequence            NUMBER,
                       X_Count_Date_First               DATE,
                       X_Count_Date_Current             DATE,
                       X_Count_Date_Prior               DATE,
                       X_Count_Date_Dummy               DATE,
                       X_Counted_By_Employee_Id_First   NUMBER,
                       X_Counted_By_Employee_Id_Curr    NUMBER,
                       X_Counted_By_Employee_Id_Prior   NUMBER,
                       X_Counted_By_Employee_Id_Dummy   NUMBER,
                       X_Count_Uom_First                VARCHAR2,
                       X_Count_Uom_Current              VARCHAR2,
                       X_Count_Uom_Prior                VARCHAR2,
                       X_Count_Quantity_First           NUMBER,
                       X_Count_Quantity_Current         NUMBER,
                       X_Count_Quantity_Prior           NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Entry_Status_Code              NUMBER,
                       X_Count_Due_Date                 DATE,
                       X_Organization_Id                NUMBER,
                       X_Cycle_Count_Header_Id          NUMBER,
                       X_Number_Of_Counts               NUMBER,
                       X_Locator_Id                     NUMBER,
                       X_Adjustment_Quantity            NUMBER,
                       X_Adjustment_Date                DATE,
                       X_Adjustment_Amount              NUMBER,
                       X_Item_Unit_Cost                 NUMBER,
                       X_Inventory_Adjustment_Account   NUMBER,
                       X_Approval_Date                  DATE,
                       X_Approver_Employee_Id           NUMBER,
                       X_Revision                       VARCHAR2,
                       X_Lot_Number                     VARCHAR2,
                       X_Lot_Control                    VARCHAR2,
                       X_System_Quantity_First          NUMBER,
                       X_System_Quantity_Current        NUMBER,
                       X_System_Quantity_Prior          NUMBER,
                       X_Reference_First                VARCHAR2,
                       X_Reference_Current              VARCHAR2,
                       X_Reference_Prior                VARCHAR2,
                       X_Primary_Uom_Quantity_First     NUMBER,
                       X_Primary_Uom_Quantity_Current   NUMBER,
                       X_Primary_Uom_Quantity_Prior     NUMBER,
                       X_Count_Type_Code                NUMBER,
                       X_Transaction_Reason_Id          NUMBER,
                       X_Approval_Type                  NUMBER,
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
		       X_Serial_Number			VARCHAR2,
		       X_Serial_Detail			NUMBER,
		       X_Approval_Condition		NUMBER,
		       X_Neg_Adjustment_Quantity	NUMBER,
		       X_Neg_Adjustment_Amount		NUMBER,
                       X_Outermost_Lpn_ID               NUMBER DEFAULT NULL,
                       X_Parent_Lpn_ID                  NUMBER DEFAULT NULL,
                       X_Cost_Group_ID                  NUMBER DEFAULT NULL,
                       -- BEGIN INVCONV
                       X_Count_Secondary_Uom_First      VARCHAR2 DEFAULT NULL,
                       X_Count_Secondary_Uom_Current    VARCHAR2 DEFAULT NULL,
                       X_Count_Secondary_Uom_Prior      VARCHAR2 DEFAULT NULL,
                       X_Secondary_Uom_Quantity_First   NUMBER   DEFAULT NULL,
                       X_Secondary_Uom_Quantity_Curr    NUMBER   DEFAULT NULL,
                       X_Secondary_Uom_Quantity_Prior   NUMBER   DEFAULT NULL,
                       X_Secondary_System_Qty_First     NUMBER   DEFAULT NULL,
                       X_Secondary_System_Qty_Current   NUMBER   DEFAULT NULL,
                       X_Secondary_System_Qty_Prior     NUMBER   DEFAULT NULL,
                       X_Secondary_Adjustment_Qty       NUMBER   DEFAULT NULL
                       -- END INVCONV

  ) IS
    --Bug 6012343 -Added the following variables
  l_standard_operation_id NUMBER;
  l_wms_installed      boolean;
  l_return_status      VARCHAR2(300);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(300);
  BEGIN
     /* Bug 6012343 */
    l_standard_operation_id := NULL;
    l_wms_installed := WMS_INSTALL.check_install(l_return_status,
							     l_msg_count,
							     l_msg_data,
    						 	     x_organization_id);

    IF ((l_wms_installed) AND X_Entry_Status_Code=3) THEN

      BEGIN
        SELECT STANDARD_OPERATION_ID
        INTO   l_standard_operation_id
	FROM BOM_STANDARD_OPERATIONS
	WHERE WMS_TASK_TYPE = 3
	AND ORGANIZATION_ID = x_organization_id
	AND ROWNUM = 1;

      EXCEPTION
        WHEN OTHERS THEN
          l_standard_operation_id := NULL ;
      END;

    END IF ;

   /*  Bug 6012343 */
    UPDATE mtl_cycle_count_entries
    SET
       cycle_count_entry_id            =     X_Cycle_Count_Entry_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       count_list_sequence             =     X_Count_List_Sequence,
       count_date_first                =     X_Count_Date_First,
       count_date_current              =     X_Count_Date_Current,
       count_date_prior                =     X_Count_Date_Prior,
       count_date_dummy                =     X_Count_Date_Dummy,
       counted_by_employee_id_first    =     X_Counted_By_Employee_Id_First,
       counted_by_employee_id_current   =     X_Counted_By_Employee_Id_Curr,
       counted_by_employee_id_prior    =     X_Counted_By_Employee_Id_Prior,
       counted_by_employee_id_dummy    =     X_Counted_By_Employee_Id_Dummy,
       count_uom_first                 =     X_Count_Uom_First,
       count_uom_current               =     X_Count_Uom_Current,
       count_uom_prior                 =     X_Count_Uom_Prior,
       count_quantity_first            =     X_Count_Quantity_First,
       count_quantity_current          =     X_Count_Quantity_Current,
       count_quantity_prior            =     X_Count_Quantity_Prior,
       inventory_item_id               =     X_Inventory_Item_Id,
       subinventory                    =     X_Subinventory,
       entry_status_code               =     X_Entry_Status_Code,
       count_due_date                  =     X_Count_Due_Date,
       organization_id                 =     X_Organization_Id,
       cycle_count_header_id           =     X_Cycle_Count_Header_Id,
       number_of_counts                =     X_Number_Of_Counts,
       locator_id                      =     X_Locator_Id,
       adjustment_quantity             =     X_Adjustment_Quantity,
       adjustment_date                 =     X_Adjustment_Date,
       adjustment_amount               =     X_Adjustment_Amount,
       item_unit_cost                  =     X_Item_Unit_Cost,
       inventory_adjustment_account    =     X_Inventory_Adjustment_Account,
       approval_date                   =     X_Approval_Date,
       approver_employee_id            =     X_Approver_Employee_Id,
       revision                        =     X_Revision,
       lot_number                      =     X_Lot_Number,
       lot_control                     =     X_Lot_Control,
       system_quantity_first           =     X_System_Quantity_First,
       system_quantity_current         =     X_System_Quantity_Current,
       system_quantity_prior           =     X_System_Quantity_Prior,
       reference_first                 =     X_Reference_First,
       reference_current               =     X_Reference_Current,
       reference_prior                 =     X_Reference_Prior,
       primary_uom_quantity_first      =     X_Primary_Uom_Quantity_First,
       primary_uom_quantity_current    =     X_Primary_Uom_Quantity_Current,
       primary_uom_quantity_prior      =     X_Primary_Uom_Quantity_Prior,
       count_type_code                 =     X_Count_Type_Code,
       transaction_reason_id           =     X_Transaction_Reason_Id,
       approval_type                   =     X_Approval_Type,
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
       serial_number		       =     X_Serial_Number,
       serial_detail		       =     X_Serial_Detail,
       approval_condition	       =     X_Approval_Condition,
       neg_adjustment_quantity	       =     X_Neg_Adjustment_Quantity,
       neg_adjustment_Amount	       =     X_Neg_Adjustment_Amount,
       outermost_lpn_id                =     X_Outermost_Lpn_ID,
       parent_lpn_id                   =     X_Parent_Lpn_ID,
       cost_group_id                   =     X_Cost_Group_ID,
       -- BEGIN INVCONV
       Count_Secondary_Uom_First       =     X_Count_Secondary_Uom_First,
       Count_Secondary_Uom_Current     =     X_Count_Secondary_Uom_Current,
       Count_Secondary_Uom_Prior       =     X_Count_Secondary_Uom_Prior,
       Secondary_Uom_Quantity_First    =     X_Secondary_Uom_Quantity_First,
       Secondary_Uom_Quantity_Current  =     X_Secondary_Uom_Quantity_Curr,
       Secondary_Uom_Quantity_Prior    =     X_Secondary_Uom_Quantity_Prior,
       Secondary_System_Qty_First      =     X_Secondary_System_Qty_First,
       Secondary_System_Qty_Current    =     X_Secondary_System_Qty_Current,
       Secondary_System_Qty_Prior      =     X_Secondary_System_Qty_Prior,
       Secondary_Adjustment_Quantity   =     X_Secondary_Adjustment_Qty,
       -- END INVCONV
       standard_operation_id           =     l_standard_operation_id --End of fix of Bug 6012343
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM mtl_cycle_count_entries
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END MTL_CYCLE_COUNT_ENTRIES_PKG;

/
