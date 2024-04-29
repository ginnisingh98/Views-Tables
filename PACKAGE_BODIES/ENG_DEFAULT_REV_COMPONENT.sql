--------------------------------------------------------
--  DDL for Package Body ENG_DEFAULT_REV_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DEFAULT_REV_COMPONENT" AS
/* $Header: ENGDCMPB.pls 115.19 2002/12/13 00:35:51 bbontemp ship $ */

--  Global constant holding the package name

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'ENG_Default_Rev_Component';

--  Package global used within the package.

g_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
g_Rev_Comp_Unexp_Rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
x_text			VARCHAR2(80);

/*****************************************************************************
* Following are all get functions which will be used by the attribute
* defaulting procedure. Each column that need to be defaulted has one GET
* function.
*****************************************************************************/

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
	p_Item_Seq_Increment:=fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT');

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
BEGIN

    RETURN 1;  --Default the qty should be 1.

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

/****************************************************************************
*
* If the item attribute Default_Include_In_Cost_Rollup IS NULL or Yes then
* Include_In_Cost_Rollup is YES (1) Else Include_In_Cost_Rollup is NO (2)
*
*****************************************************************************/
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
	IF l_DefaultRollup.Default_include_in_rollup_flag IS NULL OR
	   l_DefaultRollup.Default_include_in_rollup_flag = 'Y'
	THEN
		RETURN 1;
	ELSE
		RETURN 2;
	END IF;
    END LOOP;

END Get_Include_In_Cost_Rollup;

/*****************************************************************************
*
* If the Assembly item has ATP Components flag as yes and the component item
* attribute is Check_ATP yes then ECO can allow Check_ATP as YES (1) else
* Check_ATP is NO (2)
*
******************************************************************************/

FUNCTION Get_Check_Atp
RETURN NUMBER
IS
CURSOR c_CheckATP IS
	SELECT 1 atp_allowed
	  FROM mtl_system_items assy,
	       mtl_system_items comp
	 WHERE assy.organization_id     = g_Rev_Comp_Unexp_Rec.organization_id
	   AND assy.inventory_item_id   = g_Rev_Comp_Unexp_Rec.Revised_item_id
	   AND assy.atp_components_flag = 'Y'
	   AND comp.organization_id   = g_Rev_Comp_Unexp_Rec.organization_id
	   AND comp.inventory_item_id = g_Rev_Comp_Unexp_Rec.component_item_id
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
RETURN NUMBER IS
l_bom_item_type	NUMBER;
BEGIN
	SELECT bom_item_type
	  INTO l_bom_item_type
	  FROM mtl_system_items msi
	 WHERE msi.inventory_item_id = g_Rev_Comp_Unexp_rec.component_item_id
	   AND msi.organization_id   = g_Rev_Comp_Unexp_rec.organization_id;

	   RETURN l_bom_item_type;

END;

/****************************************************************************
*
* Check if revised_item has a bill_sequence_id.
* If it does then retun that as the default value, if not then generate the
* Bill_Sequence_Id from the Sequence.
*
*****************************************************************************/
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
			l_Bill_Sequence_Id := CheckBill.Bill_Sequence_Id;
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

/*****************************************************************************
* Parameters IN	: Revised component exposed column record
*		  Revised Component unexposed column record
* Parameters OUT: Revised Component record after defaulting
*		  Revised component unexposed columns record after defaulting
*		  Mesg Token Table
*		  Return_Status
* Purpose	: Attribute defaulting proc. defualts columns to appropriate
*		  values. Defualting will happen for exposed as well as
*		  unexposed columns.
*****************************************************************************/
PROCEDURE Attribute_Defaulting
(   p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
,   p_Rev_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
,   x_rev_component_rec		IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
,   x_Rev_Comp_Unexp_Rec	IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_pick_components 	NUMBER := 0;
BEGIN

--dbms_output.put_line('Within the Rev. Component Defaulting . . . ');

    --  Initialize package global records

    g_rev_component_rec := p_rev_component_rec;
    g_Rev_Comp_Unexp_Rec := p_Rev_Comp_Unexp_Rec;

    --  Default missing attributes.

--dbms_output.put_line('Withing the entity level defaulting . . . ');

    /*******************************************************************
    --
    -- Default Component_Sequence_Id
    --
    ********************************************************************/
    IF g_Rev_Comp_Unexp_Rec.component_sequence_id IS NULL OR
       g_Rev_Comp_Unexp_Rec.component_sequence_id = FND_API.G_MISS_NUM
    THEN
        g_Rev_Comp_Unexp_Rec.component_sequence_id := Get_Component_Sequence;
    END IF;

    /*******************************************************************
    --
    -- Default Bill_Sequence_Id
    --
    ********************************************************************/

    IF g_Rev_Comp_Unexp_rec.bill_sequence_id IS NULL THEN

        g_Rev_Comp_Unexp_Rec.bill_sequence_id := get_bill_sequence;

--dbms_output.put_line('Generated Bill Sequence_id . . . ' ||
--		     to_char(g_rev_comp_Unexp_rec.bill_sequence_id));
    END IF;

    /*******************************************************************
    --
    -- Default Required_For_Revenue
    --
    ********************************************************************/

    IF g_rev_component_rec.required_for_revenue IS NULL  THEN

        g_rev_component_rec.required_for_revenue := Get_Required_For_Revenue;

    END IF;

    /*******************************************************************
    --
    -- Default Planning_Factor
    --
    ********************************************************************/

    IF g_rev_component_rec.planning_percent IS NULL  THEN

        g_rev_component_rec.planning_percent := Get_Planning_Factor;

    END IF;

    /*******************************************************************
    --
    -- Default Operation_Seq_Num
    --
    ********************************************************************/

    IF g_rev_component_rec.operation_sequence_number IS NULL THEN

        g_rev_component_rec.operation_sequence_number := Get_Operation_Seq_Num;

    END IF;

--dbms_output.put_line('After defaulting operation seq num . . .');

    /*******************************************************************
    --
    -- Default To_End_Item_Unit_Number
    --
    ********************************************************************/

    IF NVL(g_rev_component_rec.acd_type, FND_API.G_MISS_NUM) = 3 AND
       g_rev_component_rec.to_end_item_unit_number IS NULL THEN

        g_rev_component_rec.to_end_item_unit_number := Get_To_End_Item_Number;

    END IF;

--dbms_output.put_line('After defaulting to_end_item_unit_num. .');

    /*******************************************************************
    --
    -- Default Item_Num
    --
    ********************************************************************/

    IF g_rev_component_rec.item_sequence_number IS NULL THEN

        g_rev_component_rec.item_sequence_number := Get_Item_Num;

    END IF;

--dbms_output.put_line('After defaulting item num . . . ');

    /*******************************************************************
    --
    -- Default Component_Quantity
    --
    ********************************************************************/

    IF g_rev_component_rec.quantity_per_assembly IS NULL THEN

        g_rev_component_rec.quantity_per_assembly := Get_Component_Quantity;

    END IF;

--dbms_output.put_line('After defaulting component qunatity . . .');

    /*******************************************************************
    --
    -- Default Component_Yield_Factor (Projected_Yield)
    --
    ********************************************************************/

    IF g_rev_component_rec.projected_yield IS NULL THEN

        g_rev_component_rec.projected_yield := Get_Component_Yield_Factor;

    END IF;

--dbms_output.put_line('After defaulting component yeild factor . . .');

    /*******************************************************************
    --
    -- Default Pick_Components
    --
    ********************************************************************/

    IF g_Rev_Comp_Unexp_Rec.pick_components IS NULL OR
       g_rev_comp_unexp_rec.pick_components = FND_API.G_MISS_NUM
    THEN
	g_Rev_Comp_Unexp_Rec.pick_components := Get_Pick_Components;
    END IF;

--dbms_output.put_line('After defaulting pick components . . .');

    /*******************************************************************
    --
    -- Default Effectivity Date
    --
    ********************************************************************/

    IF g_rev_component_rec.start_effective_date IS NULL THEN

        g_rev_component_rec.start_effective_date := Get_Effectivity_Date;

    END IF;

    /*******************************************************************
    --
    -- Default Disable Date
    --
    ********************************************************************/
    IF g_rev_component_rec.disable_date = FND_API.G_MISS_DATE THEN
	g_rev_component_rec.disable_date := NULL;
    END IF;

--dbms_output.put_line('After Effectivity Defaulted . . .');

    /*******************************************************************
    --
    -- Default Planning Factor (Planning_Percent)
    --
    ********************************************************************/

    IF g_rev_component_rec.planning_percent IS NULL THEN

        g_rev_component_rec.planning_percent := Get_Planning_Factor;

    END IF;

    /*******************************************************************
    --
    -- Default Quantity Related
    --
    ********************************************************************/

    IF g_rev_component_rec.quantity_related IS NULL THEN

        g_rev_component_rec.quantity_related := Get_Quantity_Related;

    END IF;

    /*******************************************************************
    --
    -- Default  SO_Basis
    --
    ********************************************************************/
    IF g_rev_component_rec.so_basis IS NULL THEN

        g_rev_component_rec.so_basis := Get_So_Basis;

    END IF;

    /*******************************************************************
    --
    -- Default Optional
    --
    ********************************************************************/
    IF g_rev_component_rec.optional IS NULL THEN

        g_rev_component_rec.optional := Get_Optional;

    END IF;

    /*******************************************************************
    --
    -- Default Mutually_Exclusive_Options (Mutually_Exclusive)
    --
    ********************************************************************/
    IF g_rev_component_rec.mutually_exclusive IS NULL THEN

        g_rev_component_rec.mutually_exclusive := Get_Mutually_Exclusive;

    END IF;

--dbms_output.put_line('After Mutually Exclusive defualting . . . ');

    /*******************************************************************
    --
    -- Default Include_In_Cost_Rollup
    --
    ********************************************************************/
    IF g_rev_component_rec.include_in_cost_rollup IS NULL THEN

        g_rev_component_rec.include_in_cost_rollup :=
						Get_Include_In_Cost_Rollup;

    END IF;

--dbms_output.put_line('After include in cost rollup defualting . . . ');

    /*******************************************************************
    --
    -- Default Check_ATP
    --
    ********************************************************************/
    IF g_rev_component_rec.check_atp IS NULL THEN

        g_rev_component_rec.check_atp := Get_Check_Atp;

    END IF;

--dbms_output.put_line('After Check ATP Defualted . . . ');

    /*******************************************************************
    --
    -- Default Shipping Allowed
    --
    ********************************************************************/
    IF g_rev_component_rec.shipping_allowed IS NULL THEN

        g_rev_component_rec.shipping_allowed := Get_Shipping_Allowed;

    END IF;

    /*******************************************************************
    --
    -- Default Required_To_Ship
    --
    ********************************************************************/
    IF g_rev_component_rec.required_to_ship IS NULL THEN

        g_rev_component_rec.required_to_ship := Get_Required_To_Ship;

    END IF;

    /*******************************************************************
    --
    -- Default Include_On_Ship_Docs
    --
    ********************************************************************/
    IF g_rev_component_rec.include_on_ship_docs IS NULL THEN

        g_rev_component_rec.include_on_ship_docs := Get_Include_On_Ship_Docs;

    END IF;

    /*******************************************************************
    --
    -- Default Supply Subinventory
    -- If the user is trying to NULL to subinventory, then NULL out
    -- Supply Locator also.
    --
    ********************************************************************/
    IF g_rev_component_rec.supply_subinventory = FND_API.G_MISS_CHAR THEN
 	g_rev_component_rec.supply_subinventory := NULL;
	g_Rev_Comp_Unexp_Rec.Supply_Locator_Id  := NULL;
    END IF;

--dbms_output.put_line('Subinventory . . . ' ||
--		     g_rev_component_rec.supply_subinventory );

    IF g_rev_component_rec.comments = FND_API.G_MISS_CHAR THEN
	g_rev_component_rec.comments := NULL;
    END IF;

    IF g_rev_component_rec.wip_supply_type = FND_API.G_MISS_NUM THEN
	g_rev_component_rec.wip_supply_type := NULL;
    END IF;

    IF g_rev_comp_Unexp_rec.bom_item_type IS NULL OR
       g_rev_comp_unexp_rec.bom_item_type = FND_API.G_MISS_NUM
    THEN
	g_rev_comp_Unexp_rec.bom_item_type := get_bom_item_type;
    END IF;

    IF g_rev_component_rec.acd_type = FND_API.G_MISS_NUM THEN
	g_rev_component_rec.acd_type := NULL;
    END IF;

    IF g_rev_comp_unexp_rec.supply_locator_id = FND_API.G_MISS_NUM THEN
	g_rev_comp_unexp_rec.supply_locator_id := NULL;
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

--dbms_output.put_line('Getting out of Attribute Defualting . . . ');

END Attribute_Defaulting;

/******************************************************************************
* Procedure	: Populate_Null_Columns (earlier called Complete_Record)
* Parameters IN	: Revised Component exposed column record
*		  Revised Component DB record of exposed columns
*		  Revised Component unexposed column record
*		  Revised Component DB record of unexposed columns
* Parameters OUT: Revised Component exposed Record
* 		  Revised Component Unexposed Record
* Purpose	: Complete record will compare the database record with the
*		  user given record and will complete the user record with
*		  values from the database record, for all columns that the
*		  user has left NULL.
******************************************************************************/
PROCEDURE Populate_Null_Columns
( p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_old_rev_component_rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, p_Old_Rev_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Rev_Component_Rec		IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec		IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
)
IS
l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type :=
			p_rev_component_rec;
l_Rev_Comp_Unexp_Rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type :=
			p_Rev_Comp_Unexp_Rec;
BEGIN

    IF l_rev_component_rec.supply_subinventory IS NULL THEN
        l_rev_component_rec.supply_subinventory :=
	p_old_rev_component_rec.supply_subinventory;

    ELSIF l_rev_component_rec.Supply_Subinventory IS NOT NULL AND
	  l_rev_component_rec.Supply_Subinventory <>
	  p_old_rev_component_rec.supply_subinventory AND
	  ( ( l_rev_comp_unexp_rec.supply_locator_id     IS NOT NULL AND
	      p_old_rev_comp_unexp_rec.supply_locator_id IS NOT NULL
	     ) AND
	     ( l_rev_comp_unexp_rec.supply_locator_id =
	       p_old_rev_comp_unexp_rec.supply_locator_id OR
	       ( l_rev_comp_unexp_rec.supply_locator_id IS NOT NULL AND
		 l_rev_comp_unexp_rec.supply_locator_id = FND_API.G_MISS_NUM
		)
	      )
	   )
    THEN
	   l_rev_comp_unexp_rec.supply_locator_id := NULL;
	   -- Give out a warning indicating the locator has been made NULL.

    ELSIF l_rev_component_rec.Supply_Subinventory IS NOT NULL AND
          l_rev_component_rec.Supply_Subinventory <>
          p_old_rev_component_rec.supply_subinventory AND
	  l_rev_comp_unexp_rec.supply_locator_id = FND_API.G_MISS_NUM
    THEN
--	  dbms_output.put_line('Supply Locator made NULL . . .');

           l_rev_comp_unexp_rec.supply_locator_id := NULL;
           -- Give out a warning indicating the locator has been made NULL.

    ELSIF l_rev_component_rec.Supply_Subinventory IS NOT NULL AND
	  l_rev_component_rec.Supply_Subinventory =
          p_old_rev_component_rec.supply_subinventory  AND
	  p_rev_comp_unexp_rec.supply_locator_id IS NULL
    THEN
	  l_rev_comp_unexp_rec.supply_locator_id :=
	  p_old_rev_comp_unexp_rec.supply_locator_id;
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

    IF l_rev_component_rec.quantity_per_assembly IS NULL THEN
        l_rev_component_rec.quantity_per_assembly :=
	p_old_rev_component_rec.quantity_per_assembly;
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
    END IF;

    IF l_rev_component_rec.attribute_category IS NULL THEN
        l_rev_component_rec.attribute_category :=
	p_old_rev_component_rec.attribute_category;
    END IF;

    IF l_rev_component_rec.attribute1 IS NULL THEN
        l_rev_component_rec.attribute1 := p_old_rev_component_rec.attribute1;
    END IF;

    IF l_rev_component_rec.attribute2  IS NULL THEN
        l_rev_component_rec.attribute2 := p_old_rev_component_rec.attribute2;
    END IF;

    IF l_rev_component_rec.attribute3 IS NULL THEN
        l_rev_component_rec.attribute3 := p_old_rev_component_rec.attribute3;
    END IF;

    IF l_rev_component_rec.attribute4 IS NULL THEN
        l_rev_component_rec.attribute4 := p_old_rev_component_rec.attribute4;
    END IF;

    IF l_rev_component_rec.attribute5 IS NULL THEN
        l_rev_component_rec.attribute5 := p_old_rev_component_rec.attribute5;
    END IF;

    IF l_rev_component_rec.attribute6 IS NULL THEN
        l_rev_component_rec.attribute6 := p_old_rev_component_rec.attribute6;
    END IF;

    IF l_rev_component_rec.attribute7 IS NULL THEN
        l_rev_component_rec.attribute7 := p_old_rev_component_rec.attribute7;
    END IF;

    IF l_rev_component_rec.attribute8 IS NULL THEN
        l_rev_component_rec.attribute8 := p_old_rev_component_rec.attribute8;
    END IF;

    IF l_rev_component_rec.attribute9 IS NULL THEN
        l_rev_component_rec.attribute9 := p_old_rev_component_rec.attribute9;
    END IF;

    IF l_rev_component_rec.attribute10 IS NULL THEN
        l_rev_component_rec.attribute10 := p_old_rev_component_rec.attribute10;
    END IF;

    IF l_rev_component_rec.attribute11 IS NULL THEN
        l_rev_component_rec.attribute11 := p_old_rev_component_rec.attribute11;
    END IF;

    IF l_rev_component_rec.attribute12 IS NULL THEN
        l_rev_component_rec.attribute12 := p_old_rev_component_rec.attribute12;
    END IF;

    IF l_rev_component_rec.attribute13 IS NULL THEN
        l_rev_component_rec.attribute13 := p_old_rev_component_rec.attribute13;
    END IF;

    IF l_rev_component_rec.attribute14 IS NULL THEN
        l_rev_component_rec.attribute14 := p_old_rev_component_rec.attribute14;
    END IF;

    IF l_rev_component_rec.attribute15 IS NULL THEN
        l_rev_component_rec.attribute15 := p_old_rev_component_rec.attribute15;
    END IF;

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
        l_rev_component_rec.so_basis := p_old_rev_component_rec.so_basis;
    END IF;

    IF l_rev_component_rec.optional IS NULL THEN
        l_rev_component_rec.optional := p_old_rev_component_rec.optional;
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
        l_rev_component_rec.check_atp := p_old_rev_component_rec.check_atp;
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
       l_rev_component_rec.acd_type := p_old_rev_component_rec.acd_type;
    END IF;

    --
    -- Also copy the Unexposed Columns from Database to New record
    --
    IF l_rev_component_rec.transaction_type <> Bom_GLOBALS.G_OPR_CREATE THEN

	l_Rev_Comp_Unexp_Rec.component_sequence_id :=
	p_Old_Rev_Comp_Unexp_Rec.component_sequence_id;

    	l_Rev_Comp_Unexp_Rec.old_component_Sequence_id :=
    	p_Old_Rev_Comp_Unexp_Rec.old_component_Sequence_id;

	l_Rev_Comp_Unexp_Rec.Revised_Item_Sequence_Id :=
	p_Old_Rev_Comp_Unexp_Rec.Revised_Item_Sequence_Id;

--	dbms_output.put_line('Comp Seq: ' ||
--		to_char(l_Rev_Comp_Unexp_Rec.component_sequence_id));

    END IF;

    l_Rev_Comp_Unexp_Rec.Bom_Item_Type :=
    p_Old_Rev_Comp_Unexp_Rec.Bom_Item_Type;

    l_Rev_Comp_Unexp_Rec.Include_On_Bill_Docs :=
    p_Old_Rev_Comp_Unexp_Rec.Include_On_Bill_Docs;

    l_rev_comp_unexp_rec.pick_components :=
    p_old_rev_comp_unexp_rec.pick_components;


    x_Rev_Component_Rec := l_rev_component_rec;
    x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

END Populate_Null_Columns;

PROCEDURE Entity_Defaulting
(   p_rev_component_rec             IN  Bom_Bo_Pub.Rev_Component_Rec_Type
,   p_old_rev_component_rec         IN  Bom_Bo_Pub.Rev_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REV_COMPONENT_REC
,   x_rev_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_rev_component_rec := p_rev_component_rec;

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

END Entity_Defaulting;


END ENG_Default_Rev_Component;

/
