--------------------------------------------------------
--  DDL for Package Body E_REV_ITEM_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."E_REV_ITEM_INT_PKG" as
/* $Header: bompirib.pls 120.3 2006/11/21 09:33:01 rnarveka ship $
 |===========================================================================+
 |               Copyright (c) 1994 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/

  PROCEDURE After_Delete(X_revised_item_sequence_id	NUMBER) IS
    BEGIN
      DELETE FROM bom_inventory_comps_interface bici
       WHERE revised_item_sequence_id = X_revised_item_sequence_id;

  END After_Delete;

PROCEDURE Call_Mass_Change (
  X_change_notice in varchar2, 		-- CHANGE_ORDER
  X_org_id in NUMBER, 			-- ORGANIZATION_ID
  X_model_item_access in NUMBER, 	-- MODEL_ITEM_ACCESS
  X_planning_item_access in NUMBER, 	-- PLANNING_ITEM_ACCESS
  X_std_item_access in NUMBER, 		-- STANDARD_ITEM_ACCESS
  X_impl_code in NUMBER,	 	-- IMPLEMENT
  X_report_code in NUMBER, 		-- REPORT
  X_delete_code in NUMBER, 		-- DELETE
  X_req_id IN OUT NOCOPY NUMBER) IS
BEGIN
  X_req_id := FND_REQUEST.Submit_Request(
	'BOM', 					-- application
	'BMCMUD', 				-- concurrent program
	'', 					-- description
	'', FALSE,
	X_change_notice, 			-- CHANGE_ORDER
	to_char(X_org_id), 			-- ORGANIZATION_ID
	to_char(X_model_item_access), 		-- MODEL_ITEM_ACCESS
	to_char(X_planning_item_access), 	-- PLANNING_ITEM_ACCESS
	to_char(X_std_item_access), 		-- STANDARD_ITEM_ACCESS
	to_char(X_impl_code),	 		-- IMPLEMENT
	to_char(X_report_code), 		-- REPORT
	to_char(X_delete_code), 		-- DELETE
	chr(0), '',
	'', '', '', '', '', '', '', '', '', '',		-- argument 11..20
	'', '', '', '', '', '', '', '', '', '',		-- argument 21..30
	'', '', '', '', '', '', '', '', '', '',		-- argument 31..40
	'', '', '', '', '', '', '', '', '', '',		-- argument 41..50
	'', '', '', '', '', '', '', '', '', '',		-- argument 53..60
	'', '', '', '', '', '', '', '', '', '', 	-- argument 61..70
	'', '', '', '', '', '', '', '', '', '',		-- argument 71..80
	'', '', '', '', '', '', '', '', '', '',		-- argument 81..90
	'', '', '', '', '', '', '', '', '', '');	-- argument 91..100
END Call_Mass_Change;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Scheduled_Date                 DATE,
                       X_Mrp_Active                     NUMBER,
                       X_Update_Wip                     NUMBER,
                       X_Use_Up                         NUMBER,
                       X_Use_Up_Item_Id                 NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Category_Set_Id                NUMBER,
                       X_Structure_Id                   NUMBER,
                       X_Item_From                      VARCHAR2,
                       X_Item_To                        VARCHAR2,
                       X_Category_From                  VARCHAR2,
                       X_Category_To                    VARCHAR2,
                       X_Increment_Rev                  NUMBER,
                       X_Item_Type                      VARCHAR2,
                       X_Use_Up_Plan_Name               VARCHAR2,
                       X_Alternate_Selection_Code       NUMBER,
                       X_Base_Item_Id                   NUMBER,
		       X_Submit_Request                 BOOLEAN,
  		       X_model_item_access              NUMBER,
		       X_planning_item_access           NUMBER,
  		       X_std_item_access                NUMBER,
                       X_impl_code                      NUMBER,
		       X_report_code                    NUMBER,
		       X_delete_code                    NUMBER,
		       X_From_End_Item_Unit_Number      VARCHAR2,
		       X_req_id                     IN OUT NOCOPY NUMBER
  ) IS

    CURSOR C IS SELECT rowid FROM ENG_REVISED_ITEMS_INTERFACE
                 WHERE revised_item_sequence_id = X_Revised_Item_Sequence_Id;

   BEGIN
       INSERT INTO ENG_REVISED_ITEMS_INTERFACE(
              change_notice,
              organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              scheduled_date,
              mrp_active,
              update_wip,
              use_up,
              use_up_item_id,
              revised_item_sequence_id,
              alternate_bom_designator,
              category_set_id,
              structure_id,
              item_from,
              item_to,
              category_from,
              category_to,
              increment_rev,
              item_type,
              use_up_plan_name,
              alternate_selection_code,
              base_item_id,
              from_end_item_unit_number
             ) VALUES (
              X_Change_Notice,
              X_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
             /* decode(trunc(X_Scheduled_Date),
                     trunc(sysdate), sysdate,
                     X_Scheduled_Date), commented out to take proper system date bug5665084*/
		     X_Scheduled_Date,
              X_Mrp_Active,
              X_Update_Wip,
              X_Use_Up,
              X_Use_Up_Item_Id,
              X_Revised_Item_Sequence_Id,
              X_Alternate_Bom_Designator,
              X_Category_Set_Id,
              X_Structure_Id,
              X_Item_From,
              X_Item_To,
              X_Category_From,
              X_Category_To,
              X_Increment_Rev,
              X_Item_Type,
              X_Use_Up_Plan_Name,
              X_Alternate_Selection_Code,
              X_Base_Item_Id,
              X_From_End_Item_Unit_Number
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

 -- ERES BEGIN
 -- If ERES is enabled, launch conc process from the client code
 -- ELSE do it here
 -- ============================================================
    If NVL(FND_PROFILE.VALUE('EDR_ERES_ENABLED'),'N') = 'N' THEN
      If X_Submit_Request then
        Call_Mass_Change (
          X_change_notice => X_Change_Notice,
          X_org_id => X_Organization_Id,
          X_model_item_access => X_model_item_access,
          X_planning_item_access => X_planning_item_access,
          X_std_item_access => X_std_item_access,
          X_impl_code => X_impl_code,
          X_report_code => X_report_code,
          X_delete_code => X_delete_code,
          X_req_id => X_req_id);
      End If;
    End If;
 -- ERES END

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Change_Notice                    VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Scheduled_Date                   DATE,
                     X_Mrp_Active                       NUMBER,
                     X_Update_Wip                       NUMBER,
                     X_Use_Up                           NUMBER,
                     X_Use_Up_Item_Id                   NUMBER,
                     X_Revised_Item_Sequence_Id         NUMBER,
                     X_Alternate_Bom_Designator         VARCHAR2,
                     X_Category_Set_Id                  NUMBER,
                     X_Structure_Id                     NUMBER,
                     X_Item_From                        VARCHAR2,
                     X_Item_To                          VARCHAR2,
                     X_Category_From                    VARCHAR2,
                     X_Category_To                      VARCHAR2,
                     X_Increment_Rev                    NUMBER,
                     X_Item_Type                        VARCHAR2,
                     X_Use_Up_Plan_Name                 VARCHAR2,
                     X_Alternate_Selection_Code         NUMBER,
                     X_Base_Item_Id                     NUMBER,
		     X_From_End_Item_Unit_Number        VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   ENG_REVISED_ITEMS_INTERFACE
        WHERE  rowid = X_Rowid
        FOR UPDATE of Revised_Item_Sequence_Id NOWAIT;
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
               (   (Recinfo.change_notice =  X_Change_Notice)
                OR (    (Recinfo.change_notice IS NULL)
                    AND (X_Change_Notice IS NULL)))
           AND (   (Recinfo.organization_id =  X_Organization_Id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (   (trunc(Recinfo.scheduled_date) =  trunc(X_Scheduled_Date))
                OR (    (Recinfo.scheduled_date IS NULL)
                    AND (X_Scheduled_Date IS NULL)))
           AND (   (Recinfo.mrp_active =  X_Mrp_Active)
                OR (    (Recinfo.mrp_active IS NULL)
                    AND (X_Mrp_Active IS NULL)))
           AND (   (Recinfo.update_wip =  X_Update_Wip)
                OR (    (Recinfo.update_wip IS NULL)
                    AND (X_Update_Wip IS NULL)))
           AND (   (Recinfo.use_up =  X_Use_Up)
                OR (    (Recinfo.use_up IS NULL)
                    AND (X_Use_Up IS NULL)))
           AND (   (Recinfo.use_up_item_id =  X_Use_Up_Item_Id)
                OR (    (Recinfo.use_up_item_id IS NULL)
                    AND (X_Use_Up_Item_Id IS NULL)))
           AND (   (Recinfo.revised_item_sequence_id =  X_Revised_Item_Sequence_Id)
                OR (    (Recinfo.revised_item_sequence_id IS NULL)
                    AND (X_Revised_Item_Sequence_Id IS NULL)))
           AND (   (Recinfo.alternate_bom_designator =  X_Alternate_Bom_Designator)
                OR (    (Recinfo.alternate_bom_designator IS NULL)
                    AND (X_Alternate_Bom_Designator IS NULL)))
           AND (   (Recinfo.category_set_id =  X_Category_Set_Id)
                OR (    (Recinfo.category_set_id IS NULL)
                    AND (X_Category_Set_Id IS NULL)))
           AND (   (Recinfo.structure_id =  X_Structure_Id)
                OR (    (Recinfo.structure_id IS NULL)
                    AND (X_Structure_Id IS NULL)))
           AND (   (Recinfo.item_from =  X_Item_From)
                OR (    (Recinfo.item_from IS NULL)
                    AND (X_Item_From IS NULL)))
           AND (   (Recinfo.item_to =  X_Item_To)
                OR (    (Recinfo.item_to IS NULL)
                    AND (X_Item_To IS NULL)))
           AND (   (Recinfo.category_from =  X_Category_From)
                OR (    (Recinfo.category_from IS NULL)
                    AND (X_Category_From IS NULL)))
           AND (   (Recinfo.category_to =  X_Category_To)
                OR (    (Recinfo.category_to IS NULL)
                    AND (X_Category_To IS NULL)))
           AND (   (Recinfo.increment_rev =  X_Increment_Rev)
                OR (    (Recinfo.increment_rev IS NULL)
                    AND (X_Increment_Rev IS NULL)))
           AND (   (Recinfo.item_type =  X_Item_Type)
                OR (    (Recinfo.item_type IS NULL)
                    AND (X_Item_Type IS NULL)))
           AND (   (Recinfo.use_up_plan_name =  X_Use_Up_Plan_Name)
                OR (    (Recinfo.use_up_plan_name IS NULL)
                    AND (X_Use_Up_Plan_Name IS NULL)))
           AND (   (Recinfo.alternate_selection_code =  X_Alternate_Selection_Code)
                OR (    (Recinfo.alternate_selection_code IS NULL)
                    AND (X_Alternate_Selection_Code IS NULL)))
           AND (   (Recinfo.base_item_id =  X_Base_Item_Id)
                OR (    (Recinfo.base_item_id IS NULL)
                    AND (X_Base_Item_Id IS NULL)))
           AND (   (Recinfo.from_end_item_unit_number =  X_From_End_Item_Unit_Number)
                OR (    (Recinfo.from_end_item_unit_number IS NULL)
                    AND (X_From_End_Item_Unit_Number IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Scheduled_Date                 DATE,
                       X_Mrp_Active                     NUMBER,
                       X_Update_Wip                     NUMBER,
                       X_Use_Up                         NUMBER,
                       X_Use_Up_Item_Id                 NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Category_Set_Id                NUMBER,
                       X_Structure_Id                   NUMBER,
                       X_Item_From                      VARCHAR2,
                       X_Item_To                        VARCHAR2,
                       X_Category_From                  VARCHAR2,
                       X_Category_To                    VARCHAR2,
                       X_Increment_Rev                  NUMBER,
                       X_Item_Type                      VARCHAR2,
                       X_Use_Up_Plan_Name               VARCHAR2,
                       X_Alternate_Selection_Code       NUMBER,
                       X_Base_Item_Id                   NUMBER,
		       X_Submit_Request                 BOOLEAN,
  		       X_model_item_access              NUMBER,
		       X_planning_item_access           NUMBER,
  		       X_std_item_access                NUMBER,
                       X_impl_code                      NUMBER,
		       X_report_code                    NUMBER,
		       X_delete_code                    NUMBER,
		       X_From_End_Item_Unit_Number      VARCHAR2,
		       X_req_id                     IN OUT NOCOPY NUMBER
  ) IS
  BEGIN
    UPDATE ENG_REVISED_ITEMS_INTERFACE
    SET
       change_notice                   =     X_Change_Notice,
       organization_id                 =     X_Organization_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       scheduled_date                  =     X_Scheduled_Date, /*decode(trunc(X_Scheduled_Date),
				               trunc(sysdate), sysdate,
           				       X_Scheduled_Date)  commented out to take proper system date bug5665084*/
       mrp_active                      =     X_Mrp_Active,
       update_wip                      =     X_Update_Wip,
       use_up                          =     X_Use_Up,
       use_up_item_id                  =     X_Use_Up_Item_Id,
       revised_item_sequence_id        =     X_Revised_Item_Sequence_Id,
       alternate_bom_designator        =     X_Alternate_Bom_Designator,
       category_set_id                 =     X_Category_Set_Id,
       structure_id                    =     X_Structure_Id,
       item_from                       =     X_Item_From,
       item_to                         =     X_Item_To,
       category_from                   =     X_Category_From,
       category_to                     =     X_Category_To,
       increment_rev                   =     X_Increment_Rev,
       item_type                       =     X_Item_Type,
       use_up_plan_name                =     X_Use_Up_Plan_Name,
       alternate_selection_code        =     X_Alternate_Selection_Code,
       base_item_id                    =     X_Base_Item_Id,
       from_end_item_unit_number       =     X_From_End_Item_Unit_Number
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

 -- ERES BEGIN
 -- If ERES is enabled, launch conc process from the client code
 -- ELSE do it here
 -- ============================================================
    If NVL(FND_PROFILE.VALUE('EDR_ERES_ENABLED'),'N') = 'N' THEN
      If X_Submit_Request then
        Call_Mass_Change (
          X_change_notice => X_Change_Notice,
          X_org_id => X_Organization_Id,
          X_model_item_access => X_model_item_access,
          X_planning_item_access => X_planning_item_access,
          X_std_item_access => X_std_item_access,
          X_impl_code => X_impl_code,
          X_report_code => X_report_code,
          X_delete_code => X_delete_code,
          X_req_id => X_req_id);
      End If;
    End If;
 -- ERES END

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
    X_Rev_Itm_Seq_Id 	NUMBER;
  BEGIN

  BEGIN
    SELECT REVISED_ITEM_SEQUENCE_ID
	INTO X_Rev_Itm_Seq_Id
	FROM ENG_REVISED_ITEMS_INTERFACE
	WHERE ROWID = X_Rowid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
  END;

    DELETE FROM ENG_REVISED_ITEMS_INTERFACE
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

-- delete from child table
    E_Rev_Item_Int_Pkg.After_Delete(X_revised_item_sequence_id =>
					X_Rev_Itm_Seq_id);

  END Delete_Row;


END E_REV_ITEM_INT_PKG;

/
