--------------------------------------------------------
--  DDL for Package Body PRODUCT_FAMILY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRODUCT_FAMILY_PKG" AS
/* $Header: BOMPFAPB.pls 120.2 2005/06/21 03:32:41 appldev ship $ */


	PROCEDURE Update_PF_Item_Id(X_Inventory_Item_Id	NUMBER,
			  	    X_Organization_Id	NUMBER,
				    X_PF_Item_Id	NUMBER,
				    X_Trans_Type	VARCHAR2,
				    X_Error_Msg	    IN OUT NOCOPY VARCHAR2,
				    X_Error_Code    IN OUT NOCOPY NUMBER) IS
	BEGIN

		UPDATE MTL_SYSTEM_ITEMS
		   SET Product_Family_Item_Id = X_PF_Item_Id
		 WHERE Inventory_Item_Id = X_Inventory_Item_Id
		   and Organization_id  = X_Organization_Id;

		-- All exception handling is done by the trigger
		-- that is fired due to this Update and this
		-- Package let it pass thru without intervention.

	END Update_PF_Item_Id;



	/************** Procedure Delete_PF_Memeber *******************/

	PROCEDURE Delete_PF_Member(X_Member_Item_Id	NUMBER,
				   X_Organization_Id	NUMBER,
				   X_Bill_Sequence_Id	NUMBER,
				   X_Error_Msg IN OUT NOCOPY VARCHAR2,
				   X_Error_Code IN OUT NOCOPY NUMBER) IS
	X_Err_Msg	VARCHAR2(2000);
	X_Err_Code	NUMBER;	-- These local variables are for the call made to the other func.
	BEGIN

		DELETE FROM Bom_Inventory_Components
		 WHERE Component_Item_Id = X_Member_Item_Id
		   AND Bill_Sequence_Id  = X_Bill_Sequence_Id; -- This will delete all the records under
							       -- that Bill_Sequence_Id.

		--Once the record has been deleted also NULL the Product_Family_Item_Id.

		Update_PF_Item_Id(X_Inventory_Item_Id => X_Member_Item_Id,
				  X_Organization_Id   => X_Organization_Id,
				  X_PF_Item_Id	  => NULL,
				  X_Trans_Type	  => 'REMOVE',
				  X_Error_Msg	  => X_Err_Msg,
				  X_Error_Code	  => X_Err_Code);

	END Delete_PF_Member;



	/***************** Function Check_Overlap_Dates *********************/

	FUNCTION Check_Overlap_Dates (X_Effectivity_Date DATE,
				      X_Disable_Date	 DATE,
				      X_Member_Item_Id	 NUMBER,
				      X_Bill_Sequence_Id NUMBER,
				      X_Rowid		 VARCHAR2) RETURN BOOLEAN IS
	X_Count	NUMBER := 0;
	CURSOR X_All_Dates IS
		SELECT 'X' date_available FROM sys.dual
		 WHERE EXISTS (
				SELECT 1 from BOM_Inventory_Components
				 WHERE Component_Item_Id = X_Member_Item_Id
				   AND Bill_Sequence_Id  = X_Bill_Sequence_Id
				   AND (( RowId		<> X_RowID ) or (X_RowId IS NULL))
				   AND ( X_Disable_Date IS NULL
					 OR ( Trunc(X_Disable_Date) >= Trunc(Effectivity_Date)
					    )
					)
				   AND ( Trunc(X_Effectivity_Date) <= Trunc(Disable_Date)
					 OR Disable_Date IS NULL
					)
			       );
	BEGIN

		FOR X_Date IN X_All_Dates LOOP
			X_Count := X_Count + 1;
		END LOOP;

		-- If count <> 0 that means the current date is overlapping with some record.
		IF X_Count <> 0 THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;

	END Check_Overlap_Dates;

	/*********************** Procedure Update_Config_Item **********************/

        PROCEDURE Update_Config_Item(X_PF_Item_Id       NUMBER,
                                    X_Base_Item_Id     NUMBER,
                                    X_Organization_Id  NUMBER,
                                    X_Error_Msg   IN OUT NOCOPY  VARCHAR2,
                                    X_Error_Code  IN OUT NOCOPY  NUMBER) IS


	CURSOR X_Config_Items IS
		SELECT config_item_id
		  FROM BOM_ATO_Configurations BAC
		 WHERE BAC.Base_Model_Id   = X_Base_Item_Id
		   AND BAC.Organization_Id = X_Organization_Id;
	X_TransType	Varchar2(15);
	X_Err_Msg	VarChar2(80);
	X_Err_Code	NUMBER;

	BEGIN
		-- If the user selects or deselects a MODEL item as a PF Member then update the
		-- Product_Family_Item_Id with the value of PF_Item_id passed here, which can be
		-- an actuall value or a NULL. A Null indicates that the user has removed a
		-- memeber from PF which is of type MODEL.


		IF X_PF_Item_Id IS NULL THEN

			X_TransType := 'REMOVE';
		ELSE
			X_TransType := 'ADD';
		END IF;

		--First set the Product_Family_Item_Id for the Base Item itself.

                Update_PF_Item_Id(X_Inventory_Item_Id => X_Base_Item_Id,
                                  X_Organization_Id   => X_Organization_Id,
                                  X_PF_Item_Id    => X_PF_Item_Id,
                                  X_Trans_Type    => X_TransType,
                                  X_Error_Msg     => X_Err_Msg,
                                  X_Error_Code    => X_Err_Code);


		-- After that loop thru the cursor to Update all the Config Item
		FOR X_Config IN X_Config_Items LOOP
			Update_PF_Item_Id(X_Inventory_Item_Id => X_Config.Config_Item_Id,
                                  	  X_Organization_Id   => X_Organization_Id,
                                  	  X_PF_Item_Id    => X_PF_Item_Id,
                                  	  X_Trans_Type    => X_TransType,
                                  	  X_Error_Msg     => X_Err_Msg,
                                  	  X_Error_Code    => X_Err_Code);
		END LOOP;

	END Update_Config_Item;

	PROCEDURE GetMemberInfo(p_Organization_id	IN 	NUMBER,
				p_Component_Item_Id	IN	NUMBER,
				x_Bom_Item_Type		IN OUT NOCOPY VARCHAR2,
				x_Forecast_Control	IN OUT NOCOPY VARCHAR2,
				x_Planning_Method	IN OUT NOCOPY VARCHAR2
				)
	 IS
	CURSOR X_MemberDetail IS
	  SELECT ML1.Meaning Bom_Item_Type,
		 ML2.Meaning Forecast_Control,
		 ML3.Meaning Planning_Method
	    FROM MTL_System_Items MSI,
		 MFG_Lookups ML1,
		 MFG_Lookups ML2,
		 MFG_Lookups ML3
	   WHERE MSI.Inventory_Item_Id = p_Component_Item_Id
	     AND MSI.Organization_Id   = p_Organization_Id
	     AND ML1.Lookup_Code(+)    = MSI.Bom_Item_Type
	     AND ML1.Lookup_Type(+)    = 'BOM_ITEM_TYPE'
	     AND ML2.Lookup_Code(+)    = MSI.ATO_Forecast_Control
	     AND ML2.Lookup_Type(+)    = 'MRP_ATO_FORECAST_CONTROL'
	     AND ML3.Lookup_Code(+)    = MSI.MRP_Planning_Code
	     AND ML3.Lookup_Type(+)    = 'MRP_PLANNING_CODE';
	BEGIN
		FOR X_Member IN X_MemberDetail LOOP
			x_Bom_Item_Type		:= X_Member.Bom_Item_Type;
			x_Forecast_Control	:= X_Member.Forecast_Control;
			x_Planning_Method	:= X_Member.Planning_Method;
		END LOOP;
	END GetMemberInfo;

	FUNCTION Check_Unique(X_Assembly_Item_Id NUMBER,
        		      X_Organization_Id  NUMBER) RETURN BOOLEAN
	IS
   	dummy        NUMBER;
	BEGIN
   		SELECT 1 INTO dummy FROM dual
    		 WHERE not exists
          		(SELECT 1 FROM bom_bill_of_materials
            		  WHERE assembly_item_id = X_Assembly_item_id
              		    AND organization_id = X_organization_id
          		);
		RETURN TRUE;
   EXCEPTION
      WHEN no_data_found THEN
		RETURN FALSE;
END Check_Unique;

 END Product_Family_PKG;

/
