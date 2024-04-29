--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_BOM_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_BOM_COMPONENT" AS
/* $Header: BOMDCMPB.pls 120.3.12010000.2 2009/12/16 21:45:50 umajumde ship $ */

/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDCMPB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Default_Bom_Component
--
--  NOTES
--
--  HISTORY
--  08-JUL-1999 Rahul Chitko    Initial Creation
--
--  31-AUG-01   Refai Farook    One To Many support changes
--
--  15-NOV-02	Anirban Dey	Added Auto_Request_Material Defaulting
--
****************************************************************************/

	g_rev_component_rec     Bom_Bo_Pub.Rev_Component_Rec_Type;
	g_Rev_Comp_Unexp_Rec    Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
	x_text                  VARCHAR2(80);


 --added for bug 9076970 begin
  FUNCTION Check_Routing_Exists
	RETURN BOOLEAN
	IS
                l_alternate_bom_designator VARCHAR2(10) := NULL;

                CURSOR GetAlternate IS
                SELECT alternate_bom_designator
                FROM bom_bill_of_materials
                WHERE bill_sequence_id = g_rev_comp_unexp_rec.bill_sequence_id;

  		CURSOR CheckRouting IS
   		SELECT 'x'
     		FROM bom_operation_sequences bos, bom_operational_routings bor
    		WHERE bor.common_routing_sequence_id = bos.routing_sequence_id
      		AND bor.organization_id = g_rev_comp_unexp_rec.organization_id
      		AND bor.assembly_item_id = g_rev_comp_unexp_rec.revised_item_id
      		AND nvl(bor.alternate_routing_designator,
              		nvl(l_alternate_bom_designator, 'NONE')) =
          		nvl(l_alternate_bom_designator, 'NONE');

		l_dummy VARCHAR2(1);

	BEGIN
		IF g_rev_comp_unexp_rec.bill_sequence_id IS NULL
		THEN
			RETURN FALSE;
		END IF;

		OPEN GetAlternate;
		FETCH GetAlternate INTO l_alternate_bom_designator;
		Close GetAlternate;

	        OPEN CheckRouting;
                FETCH CheckRouting INTO l_dummy;
                IF CheckRouting%FOUND THEN
                        CLOSE CheckRouting;
                        RETURN TRUE;
                ELSE
                        CLOSE CheckRouting;
                        RETURN FALSE;
                END IF;
	END Check_Routing_Exists;
  --added for bug 9076970 end

	/*******************************************************************
	* Following are all get functions which will be used by the attribute
	* defaulting procedure. Each column needing to be defaulted has one GET
	* function.
	********************************************************************/


	-- Added in 11.5.9 by ADEY

        FUNCTION Get_Auto_Request_Material
        RETURN VARCHAR2
        IS
        BEGIN

                RETURN 'Y';   -- Return YES

        END Get_Auto_Request_Material;


	FUNCTION Get_Required_For_Revenue
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 2;   -- Return FALSE which is 2

	END Get_Required_For_Revenue;

	FUNCTION Get_Component_Sequence
	RETURN NUMBER
	IS
		CURSOR Comp_Seq IS
		SELECT Bom_Inventory_Components_S.NEXTVAL Component_Sequence
	  	FROM SYS.DUAL;
	BEGIN

    		FOR c_Comp_Seq IN Comp_Seq LOOP
			RETURN c_Comp_Seq.Component_Sequence;
    		END LOOP ;
		RETURN NULL;
	END Get_Component_Sequence;

	-- Added by AS on 07/08 as part of adding unit effectivity capability
	-- into the packages.

	FUNCTION Get_To_End_Item_Number
	RETURN VARCHAR2
	IS
		CURSOR c_To_End_Item_Number IS
		SELECT To_End_Item_Unit_Number
	  	FROM BOM_Inventory_Components
	 	WHERE component_sequence_id =
			g_rev_comp_unexp_rec.old_component_sequence_id;
	BEGIN
    		FOR To_End_Item_Number IN c_To_End_Item_Number
    		LOOP
			RETURN To_End_Item_Number.To_End_Item_Unit_Number;
    		END LOOP;
		RETURN NULL;
	END Get_To_End_Item_Number;

	FUNCTION Get_Operation_Seq_Num
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 1;

	END Get_Operation_Seq_Num;

	FUNCTION Get_Item_Num
	RETURN NUMBER
	IS
		p_Item_Seq_Increment NUMBER;
	 	CURSOR GetItemSeq IS
      		SELECT nvl(max(item_num), 0) + P_Item_Seq_Increment default_seq
        	FROM bom_inventory_components
       		WHERE bill_sequence_id = g_rev_Comp_Unexp_rec.Bill_Sequence_Id;
	BEGIN
		p_Item_Seq_Increment :=
			fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT');

		FOR l_Def_Item_Seq IN GetItemSeq LOOP
			RETURN l_Def_Item_Seq.Default_Seq;
		END LOOP;

	-- If for some reason the For loop does not execute then default the
	-- Item num to 10
		RETURN 10;

	END Get_Item_Num;

	FUNCTION Get_Pick_Components
	RETURN NUMBER
	IS
		l_pick_components NUMBER;
 		CURSOR GetPickComps IS
      		SELECT decode(pick_components_flag, 'Y', 1, 2) pick_comps
        	FROM mtl_system_items
       		WHERE inventory_item_id = g_rev_comp_Unexp_rec.component_item_id
         	AND organization_id   = g_rev_comp_Unexp_rec.organization_id;
	BEGIN

    		for pick_comps_loop in GetPickComps loop
 			l_pick_components := pick_comps_loop.pick_comps;
    		end loop;

    		RETURN (l_pick_components);
	END Get_Pick_Components;

  FUNCTION Get_Component_Quantity
  RETURN NUMBER
  IS
  l_component_quantity NUMBER;
  l_Structure_Type_Name VARCHAR2(30);
  l_Assembly_Item_Id NUMBER;
  l_Organization_Id  NUMBER;
  BEGIN
      IF (g_rev_component_rec.inverse_quantity IS NOT NULL
        AND g_rev_component_rec.inverse_quantity <> FND_API.G_MISS_NUM)
      THEN
          IF (g_rev_component_rec.inverse_quantity = 0)
          THEN
              l_component_quantity := 0;
          ELSE
              l_component_quantity := 1/g_rev_component_rec.inverse_quantity;
          END IF;
      ELSE
          SELECT STRUCTURE_TYPE_NAME,
              ASSEMBLY_ITEM_ID,
              ORGANIZATION_ID
              INTO
              l_Structure_Type_Name,
              l_Assembly_Item_Id,
              l_Organization_Id
              FROM BOM_STRUCTURE_TYPES_B STRUCT_TYPE,
                   BOM_STRUCTURES_B  BOM_STRUCT
          WHERE  BOM_STRUCT.STRUCTURE_TYPE_ID = STRUCT_TYPE.STRUCTURE_TYPE_ID
          AND BOM_STRUCT.BILL_SEQUENCE_ID = g_Rev_Comp_Unexp_Rec.BILL_SEQUENCE_ID;

          IF (l_Structure_Type_Name ='Packaging Hierarchy') THEN
              l_component_quantity := Bom_GTIN_Rules.Get_Suggested_Quantity(
                                      p_organization_id => l_Organization_Id,
                                      p_assembly_item_id => l_Assembly_Item_Id,
                                      p_component_item_id => g_Rev_Comp_Unexp_Rec.Component_Item_Id);
          ELSE
              l_component_quantity := 1;
          END IF;
      END IF;

      RETURN l_component_quantity;

  END Get_Component_Quantity;

  FUNCTION Get_Component_Yield_Factor
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 1;

	END Get_Component_Yield_Factor;

	FUNCTION Get_Effectivity_Date
	RETURN DATE
	IS
		CURSOR c_EffectiveDate IS
		SELECT scheduled_date
	  	FROM eng_revised_items
	 	WHERE revised_item_sequence_id =
	   		g_Rev_Comp_Unexp_Rec.revised_item_sequence_id;
	BEGIN

    		FOR x_EffectiveDate IN c_EffectiveDate LOOP
			RETURN x_EffectiveDate.scheduled_date;
    		END LOOP;

    		RETURN SYSDATE;

	END Get_Effectivity_Date;

	FUNCTION Get_Planning_Factor
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 100;

	END Get_Planning_Factor;

	FUNCTION Get_Quantity_Related
	RETURN NUMBER
	IS
	BEGIN
		RETURN 2;

	END Get_Quantity_Related;

	FUNCTION Get_So_Basis
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 2;

	END Get_So_Basis;

	FUNCTION Get_Optional
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 2;

	END Get_Optional;

	FUNCTION Get_Mutually_Exclusive
	RETURN NUMBER
	IS
	BEGIN

   		 RETURN 2;

	END Get_Mutually_Exclusive;

	/**************************************************************
	* If the item attribute Default_Include_In_Cost_Rollup IS NULL or
	* Yes then Include_In_Cost_Rollup is YES (1)
	* Else Include_In_Cost_Rollup is NO (2)
	***************************************************************/
	FUNCTION Get_Include_In_Cost_Rollup
	RETURN NUMBER
	IS
		CURSOR c_DefaultRollup is
		SELECT default_include_in_rollup_flag
	  	FROM mtl_system_items
	 	WHERE inventory_item_id = g_Rev_Comp_Unexp_Rec.component_item_id
	   	AND organization_id   = g_Rev_Comp_Unexp_Rec.organization_id;
	BEGIN

		-- The default for this value comes from the Mtl_System_Items
		-- Table field Default_Include_In_Rollup_Flag
    		FOR l_DefaultRollup in c_DefaultRollup LOOP
			IF l_DefaultRollup.Default_include_in_rollup_flag
				IS NULL OR
	   		   l_DefaultRollup.Default_include_in_rollup_flag = 'N'
			THEN
				RETURN 2;
			ELSE
				RETURN 1;
			END IF;
    		END LOOP;

	END Get_Include_In_Cost_Rollup;

	/*********************************************************************
	* If the Assembly item has ATP Components flag as yes and the component
	* item attribute is Check_ATP yes then ECO can allow Check_ATP
	* as YES (1) else Check_ATP is NO (2)
	* Bug 2820312,2243418: Defaulting the component's ATP value from items is
        * not dependent on the assembly (commented the ATP check on assembly)
	**********************************************************************/

	FUNCTION Get_Check_Atp
	RETURN NUMBER
	IS
		CURSOR c_CheckATP IS
		SELECT 1 atp_allowed
	  	FROM 	mtl_system_items assy,
	       		mtl_system_items comp
	 	WHERE assy.organization_id=g_Rev_Comp_Unexp_Rec.organization_id
	   	AND assy.inventory_item_id= g_Rev_Comp_Unexp_Rec.Revised_item_id
	   	--AND assy.atp_components_flag = 'Y'
	   	AND comp.organization_id = g_Rev_Comp_Unexp_Rec.organization_id
	   	AND comp.inventory_item_id =
				g_Rev_Comp_Unexp_Rec.component_item_id
	   	AND comp.atp_flag IN ( 'Y', 'C', 'R');

	BEGIN

    		FOR CheckAtp IN c_CheckATP LOOP
			IF CheckAtp.atp_allowed = 1 THEN
				RETURN 1;
			ELSE
				RETURN 2;
			END IF;
    		END LOOP;

    		RETURN 2; -- If no records are retrived.
	END Get_Check_Atp;

	FUNCTION Get_Shipping_Allowed
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 2;

	END Get_Shipping_Allowed;

	FUNCTION Get_Required_To_Ship
	RETURN NUMBER
	IS
	BEGIN

    		RETURN 2;

	END Get_Required_To_Ship;

	FUNCTION Get_Include_On_Ship_Docs
	RETURN NUMBER
	IS
	BEGIN

     		RETURN 2;

	END Get_Include_On_Ship_Docs;

	FUNCTION get_bom_item_type
	RETURN NUMBER
	IS
		l_bom_item_type	NUMBER;
	BEGIN
		SELECT bom_item_type
	  	INTO l_bom_item_type
	  	FROM mtl_system_items msi
	 	WHERE msi.inventory_item_id =
				g_Rev_Comp_Unexp_rec.component_item_id
	   	AND msi.organization_id = g_Rev_Comp_Unexp_rec.organization_id;

	   	RETURN l_bom_item_type;

	END;

	FUNCTION get_unit_price
	RETURN NUMBER
	IS
		l_unit_price	NUMBER;
	BEGIN
		SELECT list_price_per_unit
	  	INTO l_unit_price
	  	FROM mtl_system_items msi
	 	WHERE msi.inventory_item_id =
				g_Rev_Comp_Unexp_rec.component_item_id
	   	AND msi.organization_id = g_Rev_Comp_Unexp_rec.organization_id
		AND msi.inventory_item_flag = 'Y' --- to check whether this is a direct item
		AND msi.stock_enabled_flag = 'N'
		AND msi.eam_item_type is NOT NULL; -- to check if it is an eAM item

	   	RETURN l_unit_price;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		RETURN NULL;
	END;

	/*******************************************************************
	* Check if revised_item has a bill_sequence_id.
	* If it does then retun that as the default value, if not then
	* generate the Bill_Sequence_Id from the Sequence.
	**********************************************************************/
	FUNCTION Get_Bill_Sequence
	RETURN NUMBER
	IS
		CURSOR c_CheckForNew IS
       		SELECT Bill_Sequence_Id
	 	FROM bom_bill_of_materials bom
        	WHERE bom.assembly_item_id =
	      		g_Rev_Comp_Unexp_Rec.revised_item_id
	  	AND bom.organization_id =
	      		g_Rev_Comp_Unexp_Rec.organization_id
	  	AND NVL(bom.alternate_bom_designator, 'NONE') =
	      		NVL(g_rev_component_rec.alternate_bom_code, 'NONE');

		CURSOR c_CheckBillInRevisedItem IS
		SELECT bill_sequence_id
	  	FROM eng_revised_items
	 	WHERE revised_item_sequence_id =
			g_rev_comp_unexp_rec.revised_item_sequence_id;

		l_bill_sequence_id	NUMBER;
	BEGIN

		FOR CheckBill IN c_CheckBillInRevisedItem LOOP
			IF CheckBill.Bill_Sequence_Id IS NOT NULL THEN
				l_Bill_Sequence_Id :=
					CheckBill.Bill_Sequence_Id;
				RETURN l_Bill_Sequence_Id;
			END IF;
		END LOOP;

		--
		-- If bill sequence id is not found in Eng_Revised_Items
		-- Only then go to the Bom Table to look for Bill_Sequence_Id
		--
		OPEN c_CheckForNew;
		FETCH c_CheckForNew INTO l_bill_sequence_id;
		CLOSE c_CheckForNew;

		IF l_Bill_Sequence_Id IS NULL
		THEN
			SELECT BOM_INVENTORY_COMPONENTS_S.NextVal
        	  	INTO l_Bill_Sequence_Id
        	  	FROM SYS.DUAL;

	    	RETURN l_Bill_Sequence_id;
		ELSE
			Return l_bill_sequence_id;

		END IF;
	END;

	PROCEDURE Get_Flex_Rev_Component
	IS
	BEGIN

    	--  In the future call Flex APIs for defaults

    	IF g_rev_component_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute_category := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute1 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute2 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute3 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute4 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute5 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute6 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute7 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute8 := NULL;
   	END IF;

    	IF g_rev_component_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute9 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute10 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute11 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute12 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute13 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute14 := NULL;
    	END IF;

    	IF g_rev_component_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        	g_rev_component_rec.attribute15 := NULL;
    	END IF;

	END Get_Flex_Rev_Component;


	 /********************************************************************
        * Function      : Get_EnforceInteger_Value
        * Returns       : VARCHAR2
        * Purpose       : Will convert the value of enforce integer requirements code
        *               into enforce integer requirements value
        *                 If the conversion fails then the function will return
        *                 a NULL otherwise will return the code.
        *                 For an unexpected error function will return a
        *                 missing value.
        *********************************************************************/
        FUNCTION Get_EnforceInteger_Value
                 (  p_enforce_integer  IN  NUMBER)
                    RETURN VARCHAR2
        IS
                l_enforce_int_reqvalue  varchar2(80);
        BEGIN
                SELECT meaning INTO l_enforce_int_reqvalue FROM mfg_lookups WHERE
                        lookup_type = 'BOM_ENFORCE_INT_REQUIREMENTS' AND
                        lookup_code = p_enforce_integer;
                Return l_enforce_int_reqvalue;
                EXCEPTION WHEN OTHERS THEN
                        Return NULL;
        END;



	/********************************************************************
	* Parameters IN	: Revised component exposed column record
	*		  Revised Component unexposed column record
	* Parameters OUT: Revised Component record after defaulting
	*		  Revised component unexposed columns record
	*		  Mesg Token Table
	*		  Return_Status
	* Purpose	: Attribute defaulting proc. defualts columns to
	*		  appropriate values. Defualting will happen for
	*		  exposed as well as unexposed columns.
	*********************************************************************/
	PROCEDURE Attribute_Defaulting
	( p_rev_component_rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	, p_Rev_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	, p_control_rec		IN  Bom_Bo_Pub.Control_Rec_Type
					:= Bom_Bo_Pub.G_DEFAULT_CONTROL_REC
	, x_rev_component_rec	IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
	, x_Rev_Comp_Unexp_Rec	IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	, x_Mesg_Token_Tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, x_Return_Status	IN OUT NOCOPY VARCHAR2
	)
	IS
	l_pick_components 	NUMBER := 0;
	l_to_end_item_unit_number VARCHAR2(30) := NULL;
	l_Mesg_Token_Tbl 	Error_Handler.Mesg_Token_Tbl_Type;
	l_Token_Tbl		Error_Handler.Token_Tbl_Type;
	l_default_wip_values	NUMBER;
	l_assy_item_type	NUMBER;		--* Added for Bug 4568522
	CURSOR default_wip_values IS
	SELECT wip_supply_type,
	       wip_supply_subinventory,
	       wip_supply_locator_id
	  FROM mtl_system_items
	 WHERE inventory_item_id = p_rev_comp_unexp_rec.component_item_id
	   AND organization_id   = p_rev_comp_unexp_rec.organization_id;
	BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within the Rev. Component Defaulting...'); END IF;

    		--  Initialize package global records

    		g_rev_component_rec := p_rev_component_rec;
    		g_Rev_Comp_Unexp_Rec := p_Rev_Comp_Unexp_Rec;

		x_return_status := fnd_api.g_ret_sts_success;

		-- Get the profile value which indicates whether
		-- wip values should be defaulted from those that of an
		-- item.
		l_default_wip_values := fnd_profile.value('BOM:DEFAULT_WIP_VALUES');


      --Bug 9076970 begin
      --change operation_seq_num to 1 if routing does not exist
      IF NOT Check_Routing_Exists
      THEN
      IF ( g_rev_component_rec.operation_sequence_number <> 1 AND
             g_rev_Component_rec.ACD_Type = 1
            ) OR
           ( g_rev_component_rec.operation_sequence_number <> 1 AND
             g_rev_Component_rec.ACD_Type is NULL and
              g_rev_component_rec.transaction_type = BOM_Globals.G_OPR_CREATE
            ) OR
           ( g_rev_component_rec.operation_sequence_number <> 1 AND
             NVL(g_rev_Component_rec.ACD_Type, 1) = 2           AND
             NVL(g_rev_component_rec.new_operation_sequence_number,FND_API.G_MISS_NUM)
                 = FND_API.G_MISS_NUM
            )

             THEN
               g_rev_component_rec.operation_sequence_number := 1;

             ELSIF ( NVL(g_rev_component_rec.new_operation_sequence_number,1) <> 1 AND
             ( ( g_rev_component_rec.ACD_Type = 2 AND
                 g_rev_component_rec.transaction_type =
                  BOM_Globals.G_OPR_CREATE
                ) OR
                 g_rev_component_rec.transaction_type =
                  BOM_Globals.G_OPR_UPDATE
              ) AND
	      (
               --NVL(p_old_rev_component_rec.operation_sequence_number, 1) <>
               --NVL(p_rev_component_rec.new_operation_sequence_number, 1) AND
	       g_rev_component_rec.new_operation_sequence_number <> FND_API.G_MISS_NUM
	      )
            )
            THEN
             g_rev_component_rec.new_operation_sequence_number := 1;
            END IF;
          END IF;
          --Bug 9076970 changes end




    		--  Default missing attributes.


    		/***********************************************************
    		--
    		-- Default Component_Sequence_Id
    		--
    		***********************************************************/
    		IF g_Rev_Comp_Unexp_Rec.component_sequence_id IS NULL OR
       		   g_Rev_Comp_Unexp_Rec.component_sequence_id = FND_API.G_MISS_NUM
    		THEN
        		g_Rev_Comp_Unexp_Rec.component_sequence_id :=
				Get_Component_Sequence;
    		END IF;

    		/*************************************************************
    		--
    		-- Default Bill_Sequence_Id
    		--
    		**************************************************************/

    		IF g_Rev_Comp_Unexp_rec.bill_sequence_id IS NULL THEN

        		g_Rev_Comp_Unexp_Rec.bill_sequence_id :=
						get_bill_sequence;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Generated Bill Sequence_id...' || to_char(g_rev_comp_Unexp_rec.bill_sequence_id)); END IF;
    		END IF;

    		/*********************************************************
    		--
    		-- Default Required_For_Revenue
    		--
    		***********************************************************/

    		IF g_rev_component_rec.required_for_revenue IS NULL  THEN

        		g_rev_component_rec.required_for_revenue :=
					Get_Required_For_Revenue;
    		END IF;

    		/************************************************************
    		--
    		-- Default To_End_Item_Unit_Number
    		--
    		************************************************************/

    		IF NVL(g_rev_component_rec.acd_type, FND_API.G_MISS_NUM) = 3 AND
                   g_rev_comp_unexp_rec.old_component_sequence_id IS NOT NULL AND
		   ((p_control_rec.caller_type = 'FORM' AND
		     p_control_rec.unit_controlled_item)
		    OR
		    p_control_rec.caller_type <> 'FORM')
		THEN
		   -- Log warning if to_end_item_unit_number is being overwritten
		   -- Added warning and code to overwrite unit number
		   -- on 11/17/99 (By AS - to accomodate call from ECO form)

                   l_to_end_item_unit_number :=
                                Get_To_End_Item_Number;

		   IF (NVL(g_rev_component_rec.to_end_item_unit_number,
			  FND_API.G_MISS_CHAR) <>
				NVL(l_to_end_item_unit_number, FND_API.G_MISS_CHAR))
		      AND l_to_end_item_unit_number IS NOT NULL
		   THEN
			l_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
			l_Token_Tbl(1).Token_Value := g_rev_component_rec.component_item_name;
			Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_COMP_END_UNIT_OVERWRITTEN'
                         , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                         , p_Message_Type	=> 'W'
			);
		   END IF;

		   g_rev_component_rec.to_end_item_unit_number :=
                                l_to_end_item_unit_number;
    		END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting to_end_item_unit_num..'); END IF;

		--* Added for Bug 4568522
		SELECT	Bom_Item_Type
		INTO	l_assy_item_type
	  	FROM 	Mtl_system_items_b
	 	WHERE	organization_id = g_Rev_Comp_Unexp_Rec.organization_id
	   	AND	inventory_item_id= g_Rev_Comp_Unexp_Rec.Revised_item_id;
		--* End of Bug 4568522

		/************************************************************
    		--
    		-- Default Item_Num
    		--
    		*************************************************************/

		-- Put in extra check for acd_type in order to handle records
		-- that come in thru the ECO form
		-- By AS on 07/28/99
		-- Added an OR condition so that the defaulting happens for BOM
		-- BO as well, since ACD_type is null when coming thru BOM - By RC

                IF ( g_rev_component_rec.acd_type IS NOT NULL AND
                     g_rev_component_rec.acd_type <> FND_API.G_MISS_NUM
		    ) OR
		    Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
    		THEN

	                /************************************************************
                	--
                	-- Default Item_Num
                	--
                	*************************************************************/

			IF ((g_rev_component_rec.item_sequence_number IS NULL) OR
			   (g_rev_component_rec.item_sequence_number =
							fnd_api.g_miss_num))
			    AND l_assy_item_type <> Bom_Globals.G_PRODUCT_FAMILY		--* Added for Bug 4568522
			 THEN

        			g_rev_component_rec.item_sequence_number :=
					Get_Item_Num;

			--* Added for Bug 4568522
			ELSE
				IF l_assy_item_type = Bom_Globals.G_PRODUCT_FAMILY THEN
					g_rev_component_rec.item_sequence_number := 1;
				END IF;
    			END IF;
			--* End of Bug 4568522

			IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting item num . . . '); END IF;

                	/**********************************************************
                	--
                	-- Default Operation_Seq_Num
                	--
                	***********************************************************/

                	IF g_rev_component_rec.operation_sequence_number IS NULL THEN

                        	g_rev_component_rec.operation_sequence_number :=
                                        Get_Operation_Seq_Num;
                	END IF;

			--
			-- make sure that new_operation_sequence is set to null if the
			-- has not entered any value.
			--
			IF g_rev_component_rec.new_operation_sequence_number = FND_API.G_MISS_NUM
			THEN
				g_rev_component_rec.new_operation_sequence_number := null;
			END IF;

			IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting operation seq num...'); END IF;

			IF g_rev_component_rec.acd_type = 3 AND
			   g_rev_component_rec.disable_date IS NULL
			THEN
				g_rev_component_rec.disable_date :=
					g_rev_component_rec.start_effective_date;
			END IF;

			IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting disable_date...'); END IF;
		END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting operation seq num...'); END IF;

    		/************************************************************
    		--
    		-- Default Component_Quantity
    		--
    		*************************************************************/

    		IF g_rev_component_rec.quantity_per_assembly IS NULL
		THEN
                    g_rev_component_rec.quantity_per_assembly :=
                                Get_Component_Quantity;
                /* Commented as part of bug#3310077.
    		ELSIF g_rev_component_rec.quantity_per_assembly <> FND_API.G_MISS_NUM THEN -- added for bug 2442791
			g_rev_component_rec.quantity_per_assembly :=
				round(g_rev_component_rec.quantity_per_assembly, 7);
                */
		END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting component qunatity...'); END IF;

    		/************************************************************
    		--
    		-- Default Pick_Components
    		--
    		*************************************************************/

    		IF g_Rev_Comp_Unexp_Rec.pick_components IS NULL OR
       		   g_rev_comp_unexp_rec.pick_components = FND_API.G_MISS_NUM
    		THEN
			g_Rev_Comp_Unexp_Rec.pick_components :=
				Get_Pick_Components;
    		END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting pick components . . .'); END IF;

    		/*************************************************************
    		--
    		-- Default Effectivity Date
    		--
    		**************************************************************/

    		IF g_rev_component_rec.start_effective_date IS NULL THEN

        		g_rev_component_rec.start_effective_date :=
				Get_Effectivity_Date;
    		END IF;

		/*
		IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
		THEN
		  IF trunc(g_rev_component_rec.start_effective_date) = trunc(SYSDATE)
		   AND g_rev_component_rec.start_effective_date < SYSDATE
		  THEN
		    g_rev_component_rec.start_effective_date := SYSDATE;
		  END IF;
		END IF;
		*/

    		/*************************************************************
    		--
    		-- Default Disable Date
    		--
    		**************************************************************/
    		IF g_rev_component_rec.disable_date = FND_API.G_MISS_DATE THEN
		   g_rev_component_rec.disable_date := NULL;
    		END IF;

		IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After Effectivity Defaulted . . .'); END IF;

    		/************************************************************
    		--
    		-- Default Planning Factor (Planning_Percent)
    		--
    		**************************************************************/

    		IF g_rev_component_rec.planning_percent IS NULL THEN

        		g_rev_component_rec.planning_percent :=
				Get_Planning_Factor;
   		END IF;

    		/*************************************************************
    		--
    		-- Default Quantity Related
    		--
    		**************************************************************/

    		IF g_rev_component_rec.quantity_related IS NULL THEN

        		g_rev_component_rec.quantity_related :=
				Get_Quantity_Related;
    		END IF;

    		/*************************************************************
    		--
    		-- Default  SO_Basis
    		--
    		**************************************************************/
    		IF g_rev_component_rec.so_basis IS NULL THEN
        		g_rev_component_rec.so_basis := Get_So_Basis;
    		END IF;

    		/*************************************************************
    		--
    		-- Default Optional
    		--
    		**************************************************************/
    		IF g_rev_component_rec.optional IS NULL THEN
        		g_rev_component_rec.optional := Get_Optional;
    		END IF;

    		/*************************************************************
    		--
    		-- Default Mutually_Exclusive_Options (Mutually_Exclusive)
    		--
    		**************************************************************/
    		IF g_rev_component_rec.mutually_exclusive IS NULL THEN

        		g_rev_component_rec.mutually_exclusive :=
				Get_Mutually_Exclusive;
    		END IF;

		IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After Mutually Exclusive defualting...'); END IF;


    		-- Added extra IF condition for component_item_id to accomodate
		-- records that come in thru the ECO form.
		-- By AS on 07/28/99

		IF g_rev_comp_unexp_rec.component_item_id IS NOT NULL AND
		   g_rev_comp_unexp_rec.component_item_id <> FND_API.G_MISS_NUM
		THEN

                	/************************************************************
                	--
                	-- Default Include_In_Cost_Rollup
                	--
                	*************************************************************/

			IF g_rev_component_rec.include_in_cost_rollup IS NULL
			THEN
        			g_rev_component_rec.include_in_cost_rollup :=
						Get_Include_In_Cost_Rollup;
    			END IF;

			IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After include in cost rollup defualting . . . '); END IF;

    			/***********************************************************
    			--
    			-- Default Check_ATP
    			--
    			*************************************************************/

			IF g_rev_component_rec.check_atp IS NULL
			THEN
        			g_rev_component_rec.check_atp := Get_Check_Atp;
    			END IF;

			IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After Check ATP Defualted . . . '); END IF;

			IF g_rev_comp_Unexp_rec.bom_item_type IS NULL OR
                   	   g_rev_comp_unexp_rec.bom_item_type = FND_API.G_MISS_NUM
                	THEN
                        	g_rev_comp_Unexp_rec.bom_item_type := get_bom_item_type;
                	END IF;

                	/***********************************************************
                	--
                	-- Default Component_Yield_Factor (Projected_Yield)
                	--
                	************************************************************/

                	IF g_rev_component_rec.projected_yield IS NULL THEN

                        	g_rev_component_rec.projected_yield :=
                                	Get_Component_Yield_Factor;
                	END IF;

			IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After defaulting component yeild factor . . .'); END IF;

		END IF;

		-- Defaulting used by the ECO form
		-- Added by AS on 07/29/99

                IF g_rev_comp_unexp_rec.component_item_id IS NULL OR
                   g_rev_comp_unexp_rec.component_item_id = FND_API.G_MISS_NUM
                THEN
                        g_rev_component_rec.check_atp := 2;
		END IF;

    		/************************************************************
    		--
    		-- Default Shipping Allowed
    		--
    		**************************************************************/
    		IF g_rev_component_rec.shipping_allowed IS NULL THEN
        		g_rev_component_rec.shipping_allowed :=
				Get_Shipping_Allowed;
    		END IF;

    		/*************************************************************
    		--
    		-- Default Required_To_Ship
    		--
    		**************************************************************/
    		IF g_rev_component_rec.required_to_ship IS NULL THEN
        		g_rev_component_rec.required_to_ship :=
				Get_Required_To_Ship;
    		END IF;

    		/*************************************************************
    		--
    		-- Default Include_On_Ship_Docs
    		--
    		**************************************************************/
    		IF g_rev_component_rec.include_on_ship_docs IS NULL THEN
        		g_rev_component_rec.include_on_ship_docs :=
				Get_Include_On_Ship_Docs;
    		END IF;

    		/*************************************************************
    		--
    		-- Default Supply Subinventory
    		-- If the user is trying to NULL to subinventory, then NULL out
    		-- Supply Locator also.
    		--
    		**************************************************************/
    		IF g_rev_component_rec.supply_subinventory =
				FND_API.G_MISS_CHAR THEN
 			g_rev_component_rec.supply_subinventory := NULL;
			g_Rev_Comp_Unexp_Rec.Supply_Locator_Id  := NULL;
    		END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Subinventory . . . ' || g_rev_component_rec.supply_subinventory ); END IF;


                /*********************************************************
                --
                -- Default Auto_Request_Material
                -- Added in 11.5.9 by ADEY
                ***********************************************************/

                IF (g_rev_component_rec.auto_request_material IS NULL
			OR g_rev_component_rec.auto_request_material = FND_API.G_MISS_CHAR)
			AND l_assy_item_type <> Bom_Globals.G_PRODUCT_FAMILY  --* Added for Bug 4568522
		THEN

                        g_rev_component_rec.auto_request_material :=
                                        Get_Auto_Request_Material;

		--* Added for Bug 4568522
		ELSE
			IF l_assy_item_type = Bom_Globals.G_PRODUCT_FAMILY THEN
				g_rev_component_rec.auto_request_material := NULL;
			END IF;
		--* End of Bug 4568522

                END IF;

    		/*************************************************************
    		--
    		-- Default Unit_Price for direct items
    		--
    		**************************************************************/

                IF g_rev_component_rec.Unit_Price IS NULL
                      OR  g_rev_component_rec.Unit_Price = FND_API.G_MISS_NUM THEN
                        g_rev_component_rec.Unit_Price := get_unit_price;
                END IF;

                IF g_rev_component_rec.location_name =
                                FND_API.G_MISS_CHAR THEN
                        g_rev_component_rec.location_name := NULL;
                        g_rev_comp_unexp_rec.Supply_Locator_Id  := NULL;
                END IF;

                IF g_rev_component_rec.minimum_allowed_quantity =
                                FND_API.G_MISS_NUM THEN
                        g_rev_component_rec.minimum_allowed_quantity := NULL;
                END IF;

                IF g_rev_component_rec.maximum_allowed_quantity =
                                FND_API.G_MISS_NUM THEN
                        g_rev_component_rec.maximum_allowed_quantity := NULL;
                END IF;


    		IF g_rev_component_rec.comments = FND_API.G_MISS_CHAR THEN
			g_rev_component_rec.comments := NULL;
    		END IF;

    		IF g_rev_component_rec.wip_supply_type = FND_API.G_MISS_NUM THEN
			g_rev_component_rec.wip_supply_type := NULL;
    		END IF;

                IF g_rev_component_rec.Suggested_Vendor_Name =
                                FND_API.G_MISS_CHAR THEN --- Deepu
                        g_rev_component_rec.Suggested_Vendor_Name := NULL;
                END IF;
/*
                IF g_rev_component_rec.Purchasing_Category =
                                FND_API.G_MISS_CHAR THEN --- Deepu
                        g_rev_component_rec.Purchasing_Category := NULL;
                END IF;

*/

		-- verify if the profile value that indicates default wip
		-- values from those that of an item is set. If it is then
		-- copy these values from the item record.
		IF (l_default_wip_values = 1)
		THEN
			FOR c_default IN default_wip_values
			LOOP
				IF g_rev_component_rec.wip_supply_type IS NULL
				   OR
				   g_rev_component_rec.wip_supply_type =
						FND_API.G_MISS_NUM
				THEN
					g_rev_component_rec.wip_supply_type :=
						c_default.wip_supply_type;
				END IF;

				IF g_rev_component_rec.supply_subinventory IS NULL
				   OR
				   g_rev_component_rec.supply_subinventory =
					FND_API.G_MISS_CHAR
				THEN
				    g_rev_component_rec.supply_subinventory :=
					c_default.wip_supply_subinventory;
				END IF;

				IF g_rev_comp_unexp_rec.supply_locator_id IS NULL
				OR
				   g_rev_comp_unexp_rec.supply_locator_id =
					FND_API.G_MISS_NUM
				THEN
					g_rev_comp_unexp_rec.supply_locator_id
						:=
					c_default.wip_supply_locator_id;
				END IF;

			END LOOP;

		END IF;

    		IF g_rev_component_rec.acd_type = FND_API.G_MISS_NUM THEN
			g_rev_component_rec.acd_type := NULL;
    		END IF;

    		IF g_rev_comp_unexp_rec.supply_locator_id = FND_API.G_MISS_NUM
		THEN
			g_rev_comp_unexp_rec.supply_locator_id := NULL;
    		END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute defaulting enforce_int_requirements_code...'); END IF;

/* bug2758790, form defaults the enforce req code to 0 and value to 'none' */

    		IF( g_rev_comp_unexp_rec.enforce_int_requirements_code = FND_API.G_MISS_NUM
                     or  g_rev_comp_unexp_rec.enforce_int_requirements_code is NULL)
		     AND l_assy_item_type <> Bom_Globals.G_PRODUCT_FAMILY	--* Added for Bug 4568522
		THEN
			g_rev_comp_unexp_rec.enforce_int_requirements_code := 0;
    		END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute defaulting enforce_int_requirements...'); END IF;
    		IF (g_rev_component_rec.enforce_int_requirements = FND_API.G_MISS_CHAR
                    or  g_rev_component_rec.enforce_int_requirements  is NULL)
		    AND l_assy_item_type <> Bom_Globals.G_PRODUCT_FAMILY	--* Added for Bug 4568522
		THEN
			g_rev_component_rec.enforce_int_requirements := Get_EnforceInteger_Value(
                                                p_enforce_integer => 0);

		--* Added for Bug 4568522
		ELSE
			IF l_assy_item_type = Bom_Globals.G_PRODUCT_FAMILY THEN
				g_rev_component_rec.enforce_int_requirements := NULL;
			END IF;
		--* End of Bug 4568522

    		END IF;

    		IF g_rev_component_rec.attribute_category = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute1 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute2 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute3 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute4 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute5 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute6 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute7 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute8 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute9 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute10 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute11 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute12 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute13 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute14 = FND_API.G_MISS_CHAR
    		OR  g_rev_component_rec.attribute15 = FND_API.G_MISS_CHAR
    		THEN

        		Get_Flex_Rev_Component;

    		END IF;

  		x_rev_component_rec := g_rev_component_rec;
  		x_Rev_Comp_Unexp_Rec := g_Rev_Comp_Unexp_Rec;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Getting out of Attribute Defualting...'); END IF;

	END Attribute_Defaulting;

	/*********************************************************************
	* Procedure	: Attribute_Defaulting
	* Parameters IN	: Inventory Component Exposed column record
	*		  Inventory Component unexposed column record
	* Parameters OUT: Components exposed column record after defaulting
	*		  Component unexposed column record after defaulting
	*		  Message Token Table
	*		  Return Status
	* Purpose	: This procedure will default values in all the comp.
	*		  fields that the user has left unfilled. This procedure
	*		  will share code with the Engineering Business Object
	* 		  Revised Component Attribute Defaulting Code.
	**********************************************************************/
        PROCEDURE Attribute_Defaulting
        (  p_bom_component_rec	IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_bom_Comp_unexp_rec	IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_bom_Component_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
         , x_bom_Comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         )
	IS
		l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
		l_return_status		VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
		l_Mesg_Token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
	BEGIN

		--
		-- The record definition of Revised Component in ECO BO is
		-- slightly different than the component definition of BOM BO
		-- So, we will copy the values of BOM BO Record into an ECO
		-- BO compatible record before we make a call to the
		-- Attribute Defaulting procedure.
		--

		Bom_Bo_Pub.Convert_BomComp_To_EcoComp
		(  p_bom_component_rec	=> p_bom_component_rec
		 , p_bom_comp_unexp_rec	=> p_bom_comp_unexp_rec
		 , x_rev_component_rec	=> l_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 );

		-- Once the record transfer is done call the ECO BO's
		-- revised component attribute defaulting
		--
		Bom_Default_Bom_Component.Attribute_Defaulting
		(  p_rev_component_rec	=> l_rev_component_rec
		 , p_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , x_rev_component_rec	=> l_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , x_mesg_token_tbl	=> l_mesg_token_tbl
		 , x_return_status	=> l_return_status
		);


		--
		-- On return from the Attribute Defualting, save the defaulted
		-- record back in the BOM BO's records
		--
		Bom_Bo_Pub.Convert_EcoComp_To_BomComp
		(  p_rev_component_rec  => l_rev_component_rec
                 , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
		 , x_bom_component_rec  => x_bom_component_rec
                 , x_bom_comp_unexp_rec => x_bom_comp_unexp_rec
		 );

		x_return_status := l_return_Status;
		x_mesg_token_Tbl := l_mesg_token_tbl;

	END Attribute_Defaulting;

	/*******************************************************************
	* Procedure	: Populate_Null_Columns (earlier called Complete_Record)
	* Parameters IN	: Revised Component exposed column record
	*		  Revised Component DB record of exposed columns
	*		  Revised Component unexposed column record
	*		  Revised Component DB record of unexposed columns
	* Parameters OUT: Revised Component exposed Record
	* 		  Revised Component Unexposed Record
	* Purpose	: Complete record will compare the database record with
	*		  the user given record and will complete the user
	*		  record with values from the database record, for all
	*		  columns that the user has left NULL.
	********************************************************************/
	PROCEDURE Populate_Null_Columns
	( p_rev_component_rec	   IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	, p_old_rev_component_rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	, p_Rev_Comp_Unexp_Rec	   IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	, p_Old_Rev_Comp_Unexp_Rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	, x_Rev_Component_Rec	   IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
	, x_Rev_Comp_Unexp_Rec	   IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	)
	IS
	l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type :=
					p_rev_component_rec;
	l_Rev_Comp_Unexp_Rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type :=
					p_Rev_Comp_Unexp_Rec;
	BEGIN

                IF l_rev_component_rec.supply_subinventory = FND_API.G_MISS_CHAR THEN
                        l_rev_component_rec.supply_subinventory := NULL;
                        l_rev_component_rec.location_name := NULL;
                        l_rev_comp_unexp_rec.supply_locator_id := NULL;
    		ELSIF l_rev_component_rec.supply_subinventory IS NULL THEN
        		l_rev_component_rec.supply_subinventory :=
			p_old_rev_component_rec.supply_subinventory;
                /* Bug 2694107 */
	  	  If (p_rev_comp_unexp_rec.supply_locator_id IS NULL) or
	  	     (p_rev_comp_unexp_rec.supply_locator_id = FND_API.G_MISS_NUM) THEN
	  		l_rev_comp_unexp_rec.supply_locator_id :=
	  		p_old_rev_comp_unexp_rec.supply_locator_id;
                  End if;
                 /* Bug 2694107 */
    		ELSIF l_rev_component_rec.Supply_Subinventory IS NOT NULL AND
	  		l_rev_component_rec.Supply_Subinventory <>
	  		p_old_rev_component_rec.supply_subinventory AND
	  		( ( l_rev_comp_unexp_rec.supply_locator_id IS NOT NULL
			    AND
	      		    p_old_rev_comp_unexp_rec.supply_locator_id IS NOT
				NULL
	     		   ) AND
	     		   ( l_rev_comp_unexp_rec.supply_locator_id =
	       		      p_old_rev_comp_unexp_rec.supply_locator_id OR
	       		      ( l_rev_comp_unexp_rec.supply_locator_id IS NOT
				 NULL AND
		 		l_rev_comp_unexp_rec.supply_locator_id =
					FND_API.G_MISS_NUM
				)
	      		     )
	   		  )
    		THEN
	   		l_rev_comp_unexp_rec.supply_locator_id := NULL;
	   		-- Give out a warning indicating the locator has been
			-- made NULL.

    		ELSIF l_rev_component_rec.Supply_Subinventory IS NOT NULL AND
          		l_rev_component_rec.Supply_Subinventory <>
          		p_old_rev_component_rec.supply_subinventory AND
	  		l_rev_comp_unexp_rec.supply_locator_id =
				FND_API.G_MISS_NUM
    		THEN
--	  		dbms_output.put_line('Supply Locator made NULL . . .');

           		l_rev_comp_unexp_rec.supply_locator_id := NULL;
           		-- Give out a warning indicating the locator has been
			--made NULL.
    		ELSIF l_rev_component_rec.Supply_Subinventory IS NOT NULL AND
	  		l_rev_component_rec.Supply_Subinventory =
          		p_old_rev_component_rec.supply_subinventory  AND
	  		p_rev_comp_unexp_rec.supply_locator_id IS NULL
    		THEN
	  		l_rev_comp_unexp_rec.supply_locator_id :=
	  		p_old_rev_comp_unexp_rec.supply_locator_id;
    		END IF;

                IF l_rev_comp_unexp_rec.supply_locator_id = FND_API.G_MISS_NUM THEN
                        l_rev_comp_unexp_rec.supply_locator_id := NULL;
                        l_rev_component_rec.location_name := NULL;
                END IF;

    		IF l_rev_component_rec.required_for_revenue IS NULL
    		THEN
        		l_rev_component_rec.required_for_revenue :=
			p_old_rev_component_rec.required_for_revenue;
    		END IF;

    		IF l_rev_component_rec.maximum_allowed_quantity IS NULL
    		THEN
        		l_rev_component_rec.maximum_allowed_quantity :=
			p_old_rev_component_rec.maximum_allowed_quantity;
    		END IF;

    		IF l_rev_component_rec.wip_supply_type IS NULL THEN
        		l_rev_component_rec.wip_supply_type :=
			p_old_rev_component_rec.wip_supply_type;
               /* Added for bug3221540 */
               ELSIF l_rev_component_rec.wip_supply_type = FND_API.G_MISS_NUM
               THEN
                      l_rev_component_rec.wip_supply_type := NULL;
    		END IF;

    		IF l_rev_component_rec.operation_sequence_number IS NULL
    		THEN
        		l_rev_component_rec.operation_sequence_number :=
			p_old_rev_component_rec.operation_sequence_number;
    		END IF;

    		IF l_rev_component_rec.item_sequence_number IS NULL THEN
        		l_rev_component_rec.item_sequence_number :=
			p_old_rev_component_rec.item_sequence_number;
    		END IF;

    		IF l_rev_component_rec.basis_type IS NULL THEN
        		l_rev_component_rec.basis_type:=
			p_old_rev_component_rec.basis_type;
    		END IF;

    		IF l_rev_component_rec.quantity_per_assembly IS NULL
    			AND (l_rev_component_rec.inverse_quantity = FND_API.G_MISS_NUM
    			OR l_rev_component_rec.inverse_quantity IS NULL
    			OR l_rev_component_rec.inverse_quantity = 0)
    		THEN
        		l_rev_component_rec.quantity_per_assembly :=
			p_old_rev_component_rec.quantity_per_assembly;
                /* Commented as part of bug#3310077
    		ELSIF l_rev_component_rec.quantity_per_assembly <> FND_API.G_MISS_NUM THEN -- added for bug 2442791
			l_rev_component_rec.quantity_per_assembly :=
				round(l_rev_component_rec.quantity_per_assembly, 7);
                */
    		END IF;

    		IF l_rev_component_rec.projected_yield IS NULL
    		THEN
        		l_rev_component_rec.projected_yield :=
			p_old_rev_component_rec.projected_yield;
    		END IF;

    		IF l_rev_component_rec.comments IS NULL
    		THEN
        		l_rev_component_rec.comments :=
			p_old_rev_component_rec.comments ;
    		END IF;

    		IF l_rev_component_rec.disable_date IS NULL THEN
        		l_rev_component_rec.disable_date :=
			p_old_rev_component_rec.disable_date;
		/* Added for bug 3486547 */
                ELSIF  l_rev_component_rec.disable_date = FND_API.G_MISS_DATE
                 then
                   l_rev_component_rec.disable_date := NULL;
    		END IF;

    		IF l_rev_component_rec.attribute_category IS NULL THEN
        		l_rev_component_rec.attribute_category :=
			p_old_rev_component_rec.attribute_category;
    		END IF;

    		IF l_rev_component_rec.attribute1 IS NULL THEN
        		l_rev_component_rec.attribute1 :=
				p_old_rev_component_rec.attribute1;
    		END IF;

    		IF l_rev_component_rec.attribute2  IS NULL THEN
        		l_rev_component_rec.attribute2 :=
				p_old_rev_component_rec.attribute2;
    		END IF;

    		IF l_rev_component_rec.attribute3 IS NULL THEN
        		l_rev_component_rec.attribute3 :=
				p_old_rev_component_rec.attribute3;
    		END IF;

    		IF l_rev_component_rec.attribute4 IS NULL THEN
        		l_rev_component_rec.attribute4 :=
				p_old_rev_component_rec.attribute4;
    		END IF;

    		IF l_rev_component_rec.attribute5 IS NULL THEN
        		l_rev_component_rec.attribute5 :=
				p_old_rev_component_rec.attribute5;
    		END IF;

    		IF l_rev_component_rec.attribute6 IS NULL THEN
        		l_rev_component_rec.attribute6 :=
				p_old_rev_component_rec.attribute6;
    		END IF;

    		IF l_rev_component_rec.attribute7 IS NULL THEN
        		l_rev_component_rec.attribute7 :=
				p_old_rev_component_rec.attribute7;
    		END IF;

    		IF l_rev_component_rec.attribute8 IS NULL THEN
        		l_rev_component_rec.attribute8 :=
				p_old_rev_component_rec.attribute8;
    		END IF;

    		IF l_rev_component_rec.attribute9 IS NULL THEN
        		l_rev_component_rec.attribute9 :=
				p_old_rev_component_rec.attribute9;
    		END IF;

    		IF l_rev_component_rec.attribute10 IS NULL THEN
        		l_rev_component_rec.attribute10 :=
				p_old_rev_component_rec.attribute10;
    		END IF;

    		IF l_rev_component_rec.attribute11 IS NULL THEN
        		l_rev_component_rec.attribute11 :=
				p_old_rev_component_rec.attribute11;
    		END IF;

    		IF l_rev_component_rec.attribute12 IS NULL THEN
        		l_rev_component_rec.attribute12 :=
				p_old_rev_component_rec.attribute12;
    		END IF;

    		IF l_rev_component_rec.attribute13 IS NULL THEN
        		l_rev_component_rec.attribute13 :=
				p_old_rev_component_rec.attribute13;
    		END IF;

    		IF l_rev_component_rec.attribute14 IS NULL THEN
        		l_rev_component_rec.attribute14 :=
				p_old_rev_component_rec.attribute14;
    		END IF;

    		IF l_rev_component_rec.attribute15 IS NULL THEN
        		l_rev_component_rec.attribute15 :=
				p_old_rev_component_rec.attribute15;
    		END IF;

		/* Assign NULL to the attribute fields if they are MISSING */

		g_rev_component_rec := l_rev_component_rec;
		Get_Flex_Rev_Component;
		l_rev_component_rec := g_rev_component_rec;

    		IF l_rev_component_rec.planning_percent IS NULL
    		THEN
        		l_rev_component_rec.planning_percent :=
			p_old_rev_component_rec.planning_percent;
    		END IF;

    		IF l_rev_component_rec.quantity_related IS NULL THEN
        		l_rev_component_rec.quantity_related :=
			p_old_rev_component_rec.quantity_related;
    		END IF;

    		IF l_rev_component_rec.so_basis IS NULL THEN
        		l_rev_component_rec.so_basis :=
				p_old_rev_component_rec.so_basis;
    		END IF;

    		IF l_rev_component_rec.optional IS NULL THEN
        		l_rev_component_rec.optional :=
				p_old_rev_component_rec.optional;
    		END IF;

    		IF l_rev_component_rec.mutually_exclusive IS NULL THEN
        		l_rev_component_rec.mutually_exclusive :=
			p_old_rev_component_rec.mutually_exclusive;
    		END IF;

    		IF l_rev_component_rec.include_in_cost_rollup IS NULL THEN
        		l_rev_component_rec.include_in_cost_rollup :=
			p_old_rev_component_rec.include_in_cost_rollup;
    		END IF;

    		IF l_rev_component_rec.check_atp IS NULL THEN
        		l_rev_component_rec.check_atp :=
				p_old_rev_component_rec.check_atp;
    		END IF;

    		IF l_rev_component_rec.shipping_allowed IS NULL THEN
        		l_rev_component_rec.shipping_allowed :=
			p_old_rev_component_rec.shipping_allowed;
    		END IF;

    		IF l_rev_component_rec.required_to_ship IS NULL THEN
        		l_rev_component_rec.required_to_ship :=
			p_old_rev_component_rec.required_to_ship;
    		END IF;

    		IF l_rev_component_rec.include_on_ship_docs IS NULL THEN
        		l_rev_component_rec.include_on_ship_docs :=
			p_old_rev_component_rec.include_on_ship_docs;
    		END IF;

    		IF l_rev_component_rec.minimum_allowed_quantity IS NULL THEN
        		l_rev_component_rec.minimum_allowed_quantity :=
			p_old_rev_component_rec.minimum_allowed_quantity;
    		END IF;

    		IF l_rev_component_rec.acd_type IS NULL THEN
       		l_rev_component_rec.acd_type :=
				p_old_rev_component_rec.acd_type;
    		END IF;

		IF l_rev_component_rec.from_end_item_unit_number = FND_API.G_MISS_CHAR
		THEN
			l_rev_component_rec.from_end_item_unit_number := null;
		ELSIF l_rev_component_rec.from_end_item_unit_number IS  NULL
		THEN
		      l_rev_component_rec.from_end_item_unit_number :=
					p_old_rev_component_rec.from_end_item_unit_number;
		END IF;

		IF l_rev_component_rec.to_end_item_unit_number = FND_API.G_MISS_CHAR
                THEN
                        l_rev_component_rec.to_end_item_unit_number := null;
                ELSIF l_rev_component_rec.to_end_item_unit_number IS  NULL
                THEN
                      l_rev_component_rec.to_end_item_unit_number :=
                                        p_old_rev_component_rec.to_end_item_unit_number;
                END IF;

		-- Added in 11.5.9 by ADEY
                IF l_rev_component_rec.auto_request_material IS NULL
                THEN
                        l_rev_component_rec.auto_request_material :=
                        p_old_rev_component_rec.auto_request_material;
                END IF;

                IF l_rev_component_rec.Suggested_Vendor_Name IS NULL --- Deepu
                THEN
                        l_rev_component_rec.Suggested_Vendor_Name :=
				p_old_rev_component_rec.Suggested_Vendor_Name;
			l_Rev_Comp_Unexp_Rec.Vendor_Id :=
				p_Old_Rev_Comp_Unexp_Rec.Vendor_Id;
                END IF;
/*

                IF l_rev_component_rec.Purchasing_Category_Id IS NULL --- Deepu
                THEN
                        l_rev_component_rec.Purchasing_Category_Id :=
                        p_old_rev_component_rec.Purchasing_Category_Id;
                END IF;
*/
                IF l_rev_component_rec.Unit_Price IS NULL --- Deepu
                THEN
                        l_rev_component_rec.Unit_Price :=
                        p_old_rev_component_rec.Unit_Price;
                END IF;

		--
    		-- Also copy the Unexposed Columns from Database to New record
    		--
    		IF l_rev_component_rec.transaction_type <>
					BOM_GLOBALS.G_OPR_CREATE
		THEN

			l_Rev_Comp_Unexp_Rec.component_sequence_id :=
			p_Old_Rev_Comp_Unexp_Rec.component_sequence_id;

    			l_Rev_Comp_Unexp_Rec.old_component_Sequence_id :=
    			p_Old_Rev_Comp_Unexp_Rec.old_component_Sequence_id;

			l_Rev_Comp_Unexp_Rec.Revised_Item_Sequence_Id :=
			p_Old_Rev_Comp_Unexp_Rec.Revised_Item_Sequence_Id;

			l_Rev_Comp_Unexp_Rec.Rowid :=
			p_Old_Rev_Comp_Unexp_Rec.Rowid;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Comp Seq: ' || to_char(l_Rev_Comp_Unexp_Rec.component_sequence_id)); END IF;
		ELSIF l_rev_component_rec.transaction_type =
			 BOM_GLOBALS.G_OPR_CREATE
		THEN
		        /***********************************************
        		--
        		-- Default Component_Sequence_Id
        		--
        		**************************************************/

			IF l_Rev_Comp_Unexp_Rec.component_sequence_id IS NULL OR
			   l_Rev_Comp_Unexp_Rec.component_sequence_id =
					FND_API.G_MISS_NUM
       			THEN
                		l_Rev_Comp_Unexp_Rec.component_sequence_id :=
                                        Get_Component_Sequence;

        		END IF;
    		END IF;

    		l_Rev_Comp_Unexp_Rec.Bom_Item_Type :=
    		p_Old_Rev_Comp_Unexp_Rec.Bom_Item_Type;

    		l_Rev_Comp_Unexp_Rec.Include_On_Bill_Docs :=
    		p_Old_Rev_Comp_Unexp_Rec.Include_On_Bill_Docs;

    		l_rev_comp_unexp_rec.pick_components :=
    		p_old_rev_comp_unexp_rec.pick_components;

		IF l_rev_component_rec.enforce_int_requirements = FND_API.G_MISS_CHAR THEN
    			l_rev_comp_unexp_rec.enforce_int_requirements_code := 0;
    			l_rev_component_rec.enforce_int_requirements      := Get_EnforceInteger_Value(
                                                p_enforce_integer => 0);
		ELSIF l_rev_component_rec.enforce_int_requirements IS NULL THEN
    			l_rev_comp_unexp_rec.enforce_int_requirements_code :=
    				p_old_rev_comp_unexp_rec.enforce_int_requirements_code;
        		l_rev_component_rec.enforce_int_requirements :=
			p_old_rev_component_rec.enforce_int_requirements;
		END IF;

    		x_Rev_Component_Rec := l_rev_component_rec;
    		x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

	END Populate_Null_Columns;
	/******************************************************************
	* Procedure	: Populate_Null_Columns
	* Parameters IN	: Bom Component Exposed Column record
	*		  Bom Component unexposed column record
	*		  Old Bom Component exposed column record
	*		  Old Bom Component unexposed column record
	* Parameters OUT: Bom Componet exposed column record
	*		  Bom Component unexposed column record
	* Purpose	: Will populate the NULL columns from the record that
	*		  is queried from the database.
	********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_bom_Component_rec      IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_bom_Comp_unexp_rec     IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , p_old_bom_Component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_old_bom_Comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_bom_Component_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
         , x_bom_Comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
        )
	IS
		l_rev_component_rec	 Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec	 Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
		l_old_rev_component_rec	 Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_old_rev_comp_unexp_rec Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
	BEGIN
                --
                -- The record definition of Revised Component in ECO BO is
                -- slightly different than the component definition of BOM BO
                -- So, we will copy the values of BOM BO Record into an ECO
                -- BO compatible record before we make a call to the
                -- Attribute Defaulting procedure.
                --

                Bom_Bo_Pub.Convert_BomComp_To_EcoComp
                (  p_bom_component_rec  => p_bom_component_rec
                 , p_bom_comp_unexp_rec => p_bom_comp_unexp_rec
                 , x_rev_component_rec  => l_rev_component_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 );

		--
		-- Also convert the old component information from BOM Bo
		-- To ECO Bo
		--
		Bom_Bo_Pub.Convert_BomComp_To_EcoComp
                (  p_bom_component_rec  => p_old_bom_component_rec
                 , p_bom_comp_unexp_rec => p_old_bom_comp_unexp_rec
                 , x_rev_component_rec  => l_old_rev_component_rec
                 , x_rev_comp_unexp_rec => l_old_rev_comp_unexp_rec
                 );


                -- Once the record transfer is done call the ECO BO's
                -- revised component attribute defaulting
                --
                Bom_Default_Bom_Component.Populate_Null_Columns
                (  p_rev_component_rec  	=> l_rev_component_rec
                 , p_rev_comp_unexp_rec 	=> l_rev_comp_unexp_rec
		 , p_old_rev_component_rec	=> l_old_rev_component_rec
		 , p_old_rev_comp_unexp_rec	=> l_old_rev_comp_unexp_rec
                 , x_rev_component_rec  	=> l_rev_component_rec
                 , x_rev_comp_unexp_rec 	=> l_rev_comp_unexp_rec
                 );


                --
                -- On return from the Attribute Defualting, save the defaulted
                -- record back in the BOM BO's records
                --
                Bom_Bo_Pub.Convert_EcoComp_To_BomComp
                (  p_rev_component_rec  => l_rev_component_rec
                 , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 , x_bom_component_rec  => x_bom_component_rec
                 , x_bom_comp_unexp_rec => x_bom_comp_unexp_rec
                 );

	END Populate_Null_Columns;


	/******************************************************************
	* Procedure	: Entity_Defaulting
	* Parameters IN	: Revised Component Exposed Column Record
	* 		  Revised Component Unexposed Column Record
	* Parameters OUT: Revised Component Exposed Column Record
	* Purpose	: This procedure will default all those attribute that
	*		  require help of external values and conditions for
	*		  defaulting and cannot be simply defaulted.
	********************************************************************/
	PROCEDURE Entity_Defaulting
	(  p_rev_component_rec     IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_old_rev_component_rec IN  Bom_Bo_Pub.Rev_Component_Rec_Type :=
                                         Bom_Bo_Pub.G_MISS_REV_COMPONENT_REC
	 , x_rev_component_rec     IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
	)
	IS
	BEGIN

    		--  Load out record
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within entity defaulting . . .'); END IF;

    		x_rev_component_rec := p_rev_component_rec;

                IF (p_rev_component_rec.quantity_per_assembly) IS NULL
                THEN
		  IF (p_rev_component_rec.inverse_quantity IS NOT NULL
                        AND p_rev_component_rec.inverse_quantity <> FND_API.G_MISS_NUM)
                  THEN
                        IF (p_rev_component_rec.inverse_quantity = 0)
                        THEN
                           x_rev_component_rec.quantity_per_assembly := 0;
                        ELSE
                           x_rev_component_rec.quantity_per_assembly :=
                                1/p_rev_component_rec.inverse_quantity;
                        END IF;
                  END IF;
		END IF;

    		IF p_rev_component_rec.maximum_allowed_quantity IS NOT NULL AND
       			p_rev_component_rec.minimum_allowed_quantity IS NULL
    		THEN
        		x_rev_component_rec.minimum_allowed_quantity :=
                        p_rev_component_rec.quantity_per_assembly;
    		END IF;

    		IF p_rev_component_rec.maximum_allowed_quantity IS NULL AND
       			p_rev_component_rec.minimum_allowed_quantity IS NOT NULL
    		THEN
        		x_rev_component_rec.maximum_allowed_quantity :=
                	p_rev_component_rec.quantity_per_assembly;
    		END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN error_handler.write_debug('exiting defaulting . . .'); END IF;

	END Entity_Defaulting;

        /******************************************************************
        * Procedure     : Entity_Defaulting
        * Parameters IN : Bom Inventory Component Exposed Column Record
        *                 Bom Inventory Component Unexposed Column Record
        * Parameters OUT: Bom Inventory Component Exposed Column Record
        * Purpose       : This procedure will default all those attribute that
        *                 require help of external values and conditions for
        *                 defaulting and cannot be simply defaulted.
        ********************************************************************/
        PROCEDURE Entity_Defaulting
        (  p_bom_component_rec     IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_old_bom_component_rec IN  Bom_Bo_Pub.Bom_Comps_Rec_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_COMPONENT_REC
         , x_bom_component_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
        )
        IS
		l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_old_rev_component_Rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec   Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type :=
					Bom_Bo_Pub.G_MISS_REV_COMP_UNEXP_REC;
		l_bom_comp_unexp_rec	Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type;
        BEGIN
                --
                -- The record definition of Revised Component in ECO BO is
                -- slightly different than the component definition of BOM BO
                -- So, we will copy the values of BOM BO Record into an ECO
                -- BO compatible record before we make a call to the
                -- Attribute Defaulting procedure.
                --

                Bom_Bo_Pub.Convert_BomComp_To_EcoComp
                (  p_bom_component_rec  => p_bom_component_rec
                 , x_rev_component_rec  => l_rev_component_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 );

                --
                -- Also convert the old component information from BOM Bo
                -- To ECO Bo
                --
                Bom_Bo_Pub.Convert_BomComp_To_EcoComp
                (  p_bom_component_rec  => p_old_bom_component_rec
                 , x_rev_component_rec  => l_old_rev_component_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 );


		--
                -- Once the record transfer is done call the ECO BO's
                -- revised component Entity Defaulting
		--
		Entity_Defaulting
		(  p_rev_component_rec		=> l_rev_component_rec
		 , p_old_rev_component_rec	=> l_old_rev_component_rec
		 , x_rev_component_rec		=> l_rev_component_rec
		 );

		--
		-- Convert the ECO Record back to BOM before returning
		--
		Bom_Bo_Pub.Convert_EcoComp_To_BomComp
		(  p_rev_component_rec		=> l_rev_component_rec
		 , x_bom_component_rec		=> x_bom_component_rec
		 , x_bom_comp_unexp_rec		=> l_bom_comp_unexp_rec
		 );

        END Entity_Defaulting;

END Bom_Default_Bom_Component;

/
