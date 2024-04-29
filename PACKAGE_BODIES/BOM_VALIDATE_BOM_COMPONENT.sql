--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_BOM_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_BOM_COMPONENT" AS
/* $Header: BOMLCMPB.pls 120.43.12010000.19 2011/04/02 05:53:59 xiaozhou ship $ */
/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLCMPB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Bom_Component
--
--  NOTES
--
--  HISTORY
--
--  11-JUN-99 Rahul Chitko	Initial Creation
--
--  08-MAY-2001 Refai Farook    EAM related changes
--
--  30-AUG-01   Refai Farook    One To Many support changes
--
--  25-SEP-01   Refai Farook    Added new function (Check_Unit_Number) and changes to the Check_Entity
--                              procedure. (Mass changes for unit effectivity changes)
--
--  15-NOV-02	Anirban Dey	Added support for Auto_Request_Material in 11.5.9
--
--  06-May-05 Abhishek Rudresh        Common BOM Attrs update

--  20-Jun-05   Vani Hymavathi       Validations for to OPM convergence project
**************************************************************************/

	G_PKG_NAME		      VARCHAR2(30) :=
					'BOM_Validate_Bom_Component';

	l_dummy                                VARCHAR2(80);
	/*
	l_MODEL                       CONSTANT NUMBER := 1;
	l_OPTION_CLASS                CONSTANT NUMBER := 2;
	l_PLANNING                    CONSTANT NUMBER := 3;
	l_STANDARD                    CONSTANT NUMBER := 4;
	l_PRODUCT_FAMILY	      CONSTANT NUMBER := 5;
	*/
	l_Sub_Locator_Control         NUMBER;
	l_locator_control             NUMBER;
	l_org_locator_control         NUMBER;
	l_item_locator_control        NUMBER;
	l_item_loc_restricted         NUMBER; -- 1,Locator is Restricted,else 2

	g_Comp_Item_Type        NUMBER; -- Bom_Item_Type of Component
	g_Assy_Item_Type        NUMBER; -- Bom_Item_Type of Assembly
	g_Comp_ATO_flag         CHAR;   -- ATO flag for Component
	g_Assy_ATO_flag         CHAR;   -- ATO flag for Assembly
	g_Comp_PTO_flag         CHAR;   -- PTO flag for Component
	g_Assy_PTO_flag         CHAR;   -- PTO flag for Assembly
	g_Comp_Config           CHAR;   -- Is component a config item
	g_Comp_ATO_Forecast_Control NUMBER;  -- Component items ATO Frcst Ctrl
	g_Assy_Config           CHAR;   -- Is assembly  a config item
	g_Comp_Eng_Flag         CHAR;   -- Is component an Engineering Item
	g_Assy_Eng_Flag         CHAR;   -- Is assembly an Engineering Item
	g_Comp_ATP_Comp_flag    CHAR;   -- Components ATP Component Flag
	g_Assy_ATP_Comp_flag    CHAR;   -- Assembly's ATP Component flag
	g_Comp_ATP_Check_flag   CHAR;   -- Components ATP check flag
	g_Assy_ATP_Check_flag   CHAR;   -- Assembly's ATP check flag
	g_Assy_Wip_supply_Type  NUMBER; -- Assembly 's wip supply type
	g_Comp_Wip_Supply_Type  NUMBER; -- Components WIP Supply Type
	g_Assy_Bom_Enabled_flag CHAR;   -- Assembly's bom_enabled_flag
	g_Comp_Bom_Enabled_flag CHAR;   -- Component's bom_enabled_flag
        g_Assy_Effectivity_Control  NUMBER;             --2044133
        g_Comp_Effectivity_Control  NUMBER;             --2044133
        g_Comp_Tracking_Quantity_Ind VARCHAR2(30);
        g_Assy_Tracking_Quantity_Ind VARCHAR2(30);
	g_Assy_Assembly_Type        NUMBER;             --4161794

        g_rev_component_rec           Bom_bo_Pub.Rev_Component_Rec_Type;
	g_Rev_Comp_Unexp_Rec          Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
	g_Token_Tbl                   Error_Handler.Token_Tbl_Type;

FUNCTION Item_Revision_Exists (p_item_id IN NUMBER,
				p_org_id  IN NUMBER,
				p_eff_dt  IN DATE)
RETURN BOOLEAN
IS
    CURSOR c1 IS
       SELECT REVISION
       FROM   MTL_ITEM_REVISIONS_B MIR
       WHERE  INVENTORY_ITEM_ID = p_item_id
       AND    ORGANIZATION_ID = p_org_id
       AND    MIR.EFFECTIVITY_DATE <= p_eff_dt;
BEGIN
     Error_Handler.Write_Debug('In Item Check Revisio' );
     Error_Handler.Write_Debug('Item id '||to_char(p_item_id));
     Error_Handler.Write_Debug('Org id '||to_char(p_org_id));
     Error_Handler.Write_Debug('Eff Dt '||to_char(p_eff_dt));
  FOR r1 IN c1
  LOOP
     Error_Handler.Write_Debug('In loop');
    Return TRUE;
  END LOOP;
     Error_Handler.Write_Debug('Returning False' );
  Return FALSE;
END;


/*******************************************************************
* PROCEDURE	: Check_Component_Type_Rule
* Parameters IN	: p_parent_item_id   parent item id
*		  p_child_item_id    child item id
*		  p_organization_id  org id.
*                 p_init_msg_list    Default value is TRUE.By default
*                 the error handler is initialized.If the caller does not
*                 want the error handler to get initialized, the caller
*                 has to pass FALSE.
* Parameters OUT: x_return_status is FND_API.G_RET_STS_SUCCESS or
*                                    FND_API.G_RET_STS_ERROR
*                 x_error_message    The error message passed to the
	 			     caller
* Purpose	: This procedure will actually check if any component
*                 type rule exists between the two item types of the item
*                 which are to be associated.If such any component type
*                 rule exists then the procedure checks if these items
*                 can be associated according to the rule.If not the
*                 procedure returns the error staus and error message.
*                 If the items can be associated then it returns success.
*******************************************************************/

PROCEDURE Check_Component_Type_Rule(
		x_return_status	   IN OUT NOCOPY VARCHAR2
	      ,	x_error_message    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
              , p_init_msg_list    IN  BOOLEAN := TRUE
              , p_parent_item_id   IN NUMBER
 	      , p_child_item_id    IN NUMBER
	      , p_organization_id  IN NUMBER
	      )
IS
        l_customization_code       AK_CUSTOMIZATIONS.CUSTOMIZATION_CODE%TYPE;
        l_parent_item_type         MTL_SYSTEM_ITEMS.ITEM_TYPE%TYPE;
	l_child_item_type          MTL_SYSTEM_ITEMS.ITEM_TYPE%TYPE;
	l_parent_item_type_name    FND_LOOKUP_VALUES_VL.MEANING%TYPE;
	l_child_item_type_name     FND_LOOKUP_VALUES_VL.MEANING%TYPE;
	l_return_status            VARCHAR2(1);
	l_mesg_token_tbl           Error_Handler.Mesg_Token_Tbl_Type;
	l_token_tbl                Error_Handler.Token_Tbl_Type;
	l_message_list             Error_Handler.Error_Tbl_Type;
	l_parent_name              VARCHAR2(700);
	l_child_name               VARCHAR2(700);

BEGIN

        --
        -- Initialize the message list if the user has set the
        -- Init Message List parameter
        --
        IF p_init_msg_list
        THEN
           Error_Handler.Initialize;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := 'N';

	SELECT MSI.ITEM_TYPE, LOOKUP.MEANING ,MSI.CONCATENATED_SEGMENTS
	INTO l_parent_item_type,l_parent_item_type_name,l_parent_name
	FROM MTL_SYSTEM_ITEMS_KFV MSI ,FND_COMMON_LOOKUPS LOOKUP
	WHERE
	INVENTORY_ITEM_ID = p_parent_item_id AND ORGANIZATION_ID = p_organization_id
	AND MSI.ITEM_TYPE = LOOKUP.LOOKUP_CODE(+)
	AND LOOKUP.LOOKUP_TYPE(+) = 'ITEM_TYPE'
	AND LOOKUP.ENABLED_FLAG(+) = 'Y'
	AND (LOOKUP.START_DATE_ACTIVE IS NULL OR LOOKUP.START_DATE_ACTIVE < SYSDATE)
	AND (LOOKUP.END_DATE_ACTIVE IS NULL OR LOOKUP.END_DATE_ACTIVE > SYSDATE);

	--dbms_output.put_line('l_parent_item_type_name '||l_parent_item_type_name);
	--dbms_output.put_line('l_parent_name '||l_parent_name);
	--dbms_output.put_line('l_parent_item_type '||l_parent_item_type);

	SELECT MSI.ITEM_TYPE, LOOKUP.MEANING ,MSI.CONCATENATED_SEGMENTS
	INTO l_child_item_type , l_child_item_type_name,l_child_name
	FROM MTL_SYSTEM_ITEMS_KFV MSI ,FND_COMMON_LOOKUPS LOOKUP
	WHERE
	INVENTORY_ITEM_ID = p_child_item_id AND ORGANIZATION_ID = p_organization_id
	AND MSI.ITEM_TYPE = LOOKUP.LOOKUP_CODE(+)
	AND LOOKUP.LOOKUP_TYPE(+) = 'ITEM_TYPE'
	AND LOOKUP.ENABLED_FLAG(+) = 'Y'
	AND (LOOKUP.START_DATE_ACTIVE IS NULL OR LOOKUP.START_DATE_ACTIVE < SYSDATE)
        AND (LOOKUP.END_DATE_ACTIVE IS NULL OR LOOKUP.END_DATE_ACTIVE > SYSDATE);

        --dbms_output.put_line('l_child_item_type_name '||l_child_item_type_name);
	--dbms_output.put_line('l_child_name '||l_child_name);
	--dbms_output.put_line('l_child_item_type '||l_child_item_type);

	-- dbms_output.put_line('CHILD ITEM TYPE '||l_child_item_type_name);
	IF (l_parent_item_type IS NOT  NULL)
	THEN
	    SELECT TEMPLATES.CUSTOMIZATION_CODE INTO l_customization_code
  	    FROM FND_COMMON_LOOKUPS LOOKUP,
     	         EGO_CRITERIA_TEMPLATES_V TEMPLATES
	    WHERE LOOKUP.LOOKUP_TYPE = 'ITEM_TYPE'
	         AND LOOKUP.ENABLED_FLAG = 'Y'
		 AND (LOOKUP.START_DATE_ACTIVE IS NULL OR LOOKUP.START_DATE_ACTIVE < SYSDATE)
		 AND (LOOKUP.END_DATE_ACTIVE IS NULL OR LOOKUP.END_DATE_ACTIVE > SYSDATE)
		 AND LOOKUP.LOOKUP_CODE = TEMPLATES.CLASSIFICATION1
		 AND TEMPLATES.CUSTOMIZATION_APPLICATION_ID = 702
		 AND TEMPLATES.REGION_APPLICATION_ID = 702
		 AND TEMPLATES.REGION_CODE = 'BOM_ITEM_TYPE_REGION'
		 AND LOOKUP_CODE = l_parent_item_type
                 AND TEMPLATES.CLASSIFICATION1 = l_parent_item_type;
	     --dbms_output.put_line('l_customization_code '||l_customization_code);
	BEGIN

	    SELECT 'Y' INTO l_return_status FROM DUAL
	    WHERE l_child_item_type IN
	    (
	       SELECT VALUE_VARCHAR2 FROM EGO_CRITERIA_V
	       WHERE
	       CUSTOMIZATION_APPLICATION_ID = 702 AND
	       REGION_APPLICATION_ID = 702 AND
	       REGION_CODE = 'BOM_ITEM_TYPE_REGION'
	       AND  CUSTOMIZATION_CODE = l_customization_code
	    );
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  IF l_return_status <> 'Y'
	  THEN
		    l_token_tbl(1).token_name  := 'PARENT_ITEM_NAME';
		    l_token_tbl(1).token_value := l_parent_name;
		    l_token_tbl(2).token_name  := 'PARENT_ITEM_TYPE';
		    l_token_tbl(2).token_value := l_parent_item_type_name;
		    l_token_tbl(3).token_name  := 'CHILD_ITEM_NAME';
		    l_token_tbl(3).token_value   := l_child_name;
		    l_token_tbl(4).token_name  := 'CHILD_ITEM_TYPE';
		    l_token_tbl(4).token_value   := l_child_item_type_name;

	    Error_Handler.Add_Error_Token
		(  p_Message_Name       => 'BOM_COMP_ASSOC_DENIED'
		 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
		 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
		 , p_Token_Tbl          => l_token_tbl
		);

	    Error_Handler.Translate_And_Insert_Messages
		(  p_mesg_token_tbl     => l_mesg_token_tbl
		 , p_application_id     => 'BOM'
		);

	    Error_Handler.Get_Message_List( x_message_list => l_message_list);
	    x_error_message := l_message_list(1).Message_Text;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    -- dbms_output.put_line('RETURN STATUS WITH EXCEPTION '||l_return_status);
	    -- dbms_output.put_line('RETURN STATUS '||x_return_status);
	    -- dbms_output.put_line('RETURN MESSAGE '||x_error_message);
            IF p_init_msg_list
            THEN
                Error_Handler.Write_To_DebugFile;
	        Error_Handler.Close_Debug_Session;
            END IF;
	  END IF;
	END;
	ELSE
	  l_return_status := 'Y' ;
	END IF;

	IF l_return_status = 'Y'
	THEN
	    x_return_status  := FND_API.G_RET_STS_SUCCESS;
	    -- dbms_output.put_line('CRITERIA TEMPLATE FOUND.ITEM TYPES MATCH FOUND.');
	    -- dbms_output.put_line('RETURN STATUS '||x_return_status);
	    -- dbms_output.put_line('RETURN MESSAGE '||x_error_message);
	END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_return_status  := FND_API.G_RET_STS_SUCCESS;
      -- dbms_output.put_line('NO CRITERIA TEMPLATE FOUND. SO ANYTHING CAN BE ADDED');
      -- dbms_output.put_line('RETURN STATUS '||x_return_status);
      -- dbms_output.put_line('RETURN MESSAGE '||x_error_message);

END Check_Component_Type_Rule;

	/*******************************************************************
	* Procedure	: Check_Entity
	* Parameters IN	: Bom Component Exposed Column record
	*		  Bom Component unexposed column record
	*		  Bom Component old exposed column record
	*		  Bom Component old unexposed column record
	* Parameters OUT: Return Status
	*		  Message Token Table
	* Purpose	: Procedure will execute the business logic and will
	*		  also perform any required cross entity validations
	*******************************************************************/
	PROCEDURE Check_Entity
	( x_return_status	   IN OUT NOCOPY VARCHAR2
	, x_Mesg_Token_Tbl	   IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, p_bom_component_rec	   IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	, p_bom_Comp_Unexp_Rec	   IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	, p_old_bom_Component_Rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	, p_old_bom_Comp_Unexp_Rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	)
	IS
		l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
		l_old_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_old_rev_comp_unexp_rec
					Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
	BEGIN
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		-- Convert BOM record into ECO record

		Bom_Bo_Pub.Convert_BomComp_To_EcoComp
		(  p_bom_component_rec	=> p_bom_component_rec
		 , p_bom_comp_unexp_rec	=> p_bom_comp_unexp_rec
		 , x_rev_component_rec	=> l_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		);

		-- Also convert Old BOM component record into ECO
		Bom_Bo_Pub.Convert_BomComp_To_EcoComp
		(  p_bom_component_rec	=> p_old_bom_component_rec
		 , p_bom_comp_unexp_rec	=> p_old_bom_comp_unexp_rec
		 , x_rev_component_rec	=> l_old_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_old_rev_comp_unexp_rec
		 );

		-- Call Check Entity
		Bom_Validate_Bom_Component.Check_Entity
		(  p_rev_component_rec	=> l_rev_component_rec
		 , p_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , p_old_rev_component_rec	=> l_old_rev_component_rec
		 , p_old_rev_comp_unexp_rec	=> l_old_rev_comp_unexp_rec
		 , x_return_status	=> x_return_status
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		 );

	END Check_Entity;


	/********************************************************************
	* Procedure	: Check_Attributes
	* Parameters IN	: Bom Component exposed column record
	*		  Bom component unexposed column record
	* Parameters OUT: Return Status
	*		  Message Token Table
	* Purpose	: Check_Attributes will verify the exposed attributes
	*		  of the component record in their own entirety. No
	*		  cross entity validations will be performed.
	********************************************************************/
	PROCEDURE Check_Attributes
	( x_return_status	IN OUT NOCOPY VARCHAR2
	, x_Mesg_Token_Tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, p_bom_component_rec	IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	, p_bom_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	)
	IS

		l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
	BEGIN
		Bom_Bo_Pub.Convert_BomComp_To_EcoComp
		(  p_bom_component_rec	=> p_bom_component_rec
		 , p_bom_comp_unexp_rec	=> p_bom_comp_unexp_rec
		 , x_rev_component_rec	=> l_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 );

		-- Call Check Attributes procedure
		Bom_Validate_Bom_Component.Check_Attributes
		(  p_rev_component_rec	=> l_rev_component_rec
		 , p_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , x_return_status	=> x_return_status
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		);

	END Check_Attributes;

	PROCEDURE Check_Entity_Delete
	( x_return_status	IN OUT NOCOPY VARCHAR2
	, x_Mesg_Token_Tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, p_bom_component_rec	IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	, p_bom_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	)
	IS
	BEGIN
		NULL;
	END Check_Entity_Delete;


	PROCEDURE Check_Required
	( x_return_status		IN OUT NOCOPY VARCHAR2
	, x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, p_bom_component_rec           IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	)
	IS
		l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
	BEGIN
		Bom_Bo_Pub.Convert_BomComp_to_EcoComp
		(  p_bom_component_rec	=> p_bom_component_rec
	 	 , x_rev_component_rec	=> l_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 );

		Bom_Validate_Bom_Component.Check_required
		(  p_rev_component_rec	=> l_rev_component_rec
		 , x_return_status	=> x_return_status
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		 );
	END Check_Required;


	PROCEDURE Check_Existence
	(  p_bom_component_rec	     IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	 , p_bom_comp_unexp_rec	     IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 , x_old_bom_component_rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
	 , x_old_bom_comp_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl	     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_return_status	     IN OUT NOCOPY VARCHAR2
	)
	IS
		l_rev_component_rec	 Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec	 Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
		l_old_rev_component_rec	 Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_old_rev_comp_unexp_rec Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
	BEGIN
		-- Convert bom component to eco component
		Bom_Bo_Pub.Convert_BomComp_To_EcoComp
		(  p_bom_component_rec	=> p_bom_component_rec
		 , p_bom_comp_unexp_rec	=> p_bom_comp_unexp_rec
		 , x_rev_component_rec	=> l_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		);

		Bom_Validate_Bom_Component.Check_Existence
		(  p_rev_component_rec	=> l_rev_component_rec
		 , p_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , x_old_rev_component_rec => l_old_rev_component_rec
		 , x_old_rev_comp_unexp_rec => l_old_rev_comp_unexp_rec
		 , x_return_status	=> x_return_status
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		);

		-- Convert old Eco Record back to Comp

		Bom_Bo_Pub.Convert_EcoComp_To_BomComp
		(  p_rev_component_rec	=> l_old_rev_component_rec
		 , p_rev_comp_unexp_rec	=> l_old_rev_comp_unexp_rec
		 , x_bom_component_rec	=> x_old_bom_component_rec
		 , x_bom_comp_unexp_rec	=> x_old_bom_comp_unexp_rec
		 );

	END Check_Existence;

        /* Component count under a bill cannot exceed 9999 */

	PROCEDURE Check_ComponentCount
	(  p_bom_component_rec       IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	 , p_bom_comp_unexp_rec      IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 	 , x_Return_Status           IN OUT NOCOPY VARCHAR2
	)
	IS

	  l_total 		NUMBER := 0;
       	  l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_type;

	BEGIN

          x_return_status := FND_API.G_RET_STS_SUCCESS;

/*	Added condition for date through bug 3238782 */

	  SELECT count(*) INTO l_total FROM bom_inventory_components WHERE
	   bill_sequence_id = p_bom_comp_unexp_rec.bill_sequence_id
		and sysdate between effectivity_date and
                         nvl(disable_date,sysdate + 1);

	  IF l_total > BOM_GLOBALS.G_COMPS_LIMIT THEN
                g_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                g_token_tbl(1).token_value :=
                                p_bom_component_rec.assembly_item_name;
              	Error_Handler.Add_Error_Token
                ( p_message_name       => 'BOM_COMP_COUNT_EXCEEDS_LIMIT'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_Token_Tbl          => g_Token_Tbl
		, p_message_type       => 'W' -- Bug 3238782
                 );
                --x_return_status := FND_API.G_RET_STS_ERROR; -- bug 3238782
          END IF;

          x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_ComponentCount;

	PROCEDURE Check_Lineage
	(  p_bom_component_rec       IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	 , p_bom_comp_unexp_rec      IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 	 , x_Return_Status           IN OUT NOCOPY VARCHAR2
	)
	IS
	BEGIN
		NULL;

	END Check_Lineage;

	/**********************************************************************
	* Procedure	: Check_Acces
	* Parameters IN	: Organization_Id
	*		  Component Item Id and Name
	*		  Message Token Table
	* Parameters OUT: Message Token Table
	*		  Return Status
	* Purpose	: This procedure will check if the user has access to
	* 		  the inventory components BOM_ITEM_TYPE.
	**********************************************************************/
	PROCEDURE Check_Access
	(  p_organization_id            IN  NUMBER
	 , p_component_item_id          IN  NUMBER
	 , p_component_name             IN  VARCHAR2
	 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                    Error_Handler.G_MISS_MESG_TOKEN_TBL
	 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status              IN OUT NOCOPY VARCHAR2
	)
	IS
		l_bom_comp_item_type	NUMBER;
                l_OPM_org        VARCHAR2(1);
		l_return_status		VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
		l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_type;
		l_token_tbl		Error_Handler.Token_Tbl_Type;
	BEGIN
        	/*************************************************************
        	--
        	-- Check if the user has access to the revised component's
        	-- bom_item_type
        	--
        	**************************************************************/
        	SELECT bom_item_type
           	  INTO l_Bom_comp_item_type
          	  FROM mtl_system_items
         	 WHERE inventory_item_id = p_component_item_id
           	   AND organization_id   = p_organization_id;

                 SELECT process_enabled_flag
                   INTO  l_OPM_org
                   FROM mtl_parameters
                  WHERE  organization_id   = p_organization_id;

                 /* Validations for OPM Convergence Project
                    Model/Option class items are not allowed in OPM organizations*/

                  IF (l_OPM_org='Y' and l_bom_comp_item_type in ( Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS))THEN
                         Error_Handler.Add_Error_Token
                         (  p_Message_name       => 'BOM_OPM_ORG_MODEL_OC'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                          , x_mesg_token_tbl     => l_mesg_token_tbl
                          );
                         l_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;

        	IF l_bom_comp_item_type NOT IN
           	(NVL(BOM_Globals.Get_MDL_Item_Access,0),
            	 NVL(BOM_Globals.Get_OC_Item_Access,0),
            	 NVL(BOM_Globals.Get_PLN_Item_Access,0),
          	 NVL(BOM_Globals.Get_STD_Item_Access,0)
           	)
        	THEN
                	l_token_tbl(1).token_name  := 'COMPONENT_ITEM_NAME';
                	l_token_tbl(1).token_value := p_component_name;
                	l_token_tbl(2).token_name  := 'BOM_ITEM_TYPE';
                	l_token_tbl(2).translate   := TRUE;

                	IF l_bom_comp_Item_Type = 1
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'BOM_MODEL';
                	ELSIF l_bom_comp_Item_Type = 2
                	THEN
                     	 	l_Token_Tbl(2).Token_Value:='BOM_OPTION_CLASS';
                	ELSIF l_bom_comp_Item_Type = 3
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'BOM_PLANNING';
                	ELSIF l_bom_comp_Item_Type = 4
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'BOM_STANDARD';
                	END IF;

                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_BOM_COMP_ACCESS_DENIED'
                 	 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 	 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                	 , p_Token_Tbl          => l_token_tbl
                 	);
                 	l_token_tbl.DELETE(2);
                 	l_return_status := FND_API.G_RET_STS_ERROR;
        	END IF;

	END Check_Access;

	/*******************************************************************
	-- Since ENG and BOM Business object share the entities Revised comp.
	-- Reference Designator and Substitute Component but use a different
	-- Record structure for exposed and unexposed columns, there are two
	-- sets of procedures. Internally the Bom Bo will call the ECO's
	-- Check_<Funtion> procedure since ECO was coded earlier than BOM BO.
	--
	-- Parameters to the ECO's BO are revised component where are the
	-- parameter to the BOM's BO are Bom Component.
	*********************************************************************/

	/*****************************************************************
	* Procedure     : Check_Required
	* Parameters IN : Revised Component exposed column record
	* Paramaters OUT: Return Status
	*                 Mesg Token Table
	* Purpose       : Procedure will check if the user has given all the
	*		  required columns for the type of operation user is
	*		  trying to perform. If the required columns are not
	*		  filled in, then the record would get an error.
	********************************************************************/
	PROCEDURE Check_Required
	(  x_return_status               IN OUT NOCOPY VARCHAR2
	 , x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 )
	IS
        	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
	BEGIN
        	x_return_status := FND_API.G_RET_STS_SUCCESS;

        	g_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
        	g_token_tbl(1).token_value :=
				p_rev_component_rec.component_item_name;

        	IF ( p_rev_component_rec.acd_type IS NULL OR
           	     p_rev_component_rec.acd_type = FND_API.G_MISS_NUM
		    ) AND
		    Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
        	THEN
                	Error_Handler.Add_Error_Token
                	( p_message_name       => 'BOM_ACD_TYPE_MISSING'
                	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	, p_Token_Tbl          => g_Token_Tbl
                	);
                	x_return_status := FND_API.G_RET_STS_ERROR;
        	END IF;

		IF ( p_rev_component_rec.start_effective_date IS NULL OR
		     p_rev_component_rec.start_effective_date = FND_API.G_MISS_DATE
		    ) AND
		   ( p_rev_component_rec.from_end_item_unit_number IS NULL OR
		     p_rev_component_rec.from_end_item_unit_number = FND_API.G_MISS_CHAR
		    )
		THEN
			Error_Handler.Add_Error_Token
                        ( p_message_name       => 'BOM_EFFECTIVITY_MISSING'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => g_Token_Tbl
                        );
                        x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

        	-- Return the message table.

        	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_Required;


	 /*****************************************************************
	 * Function	: Control
	 * Parameter IN	: Org Level Control
	 *		  Subinventory Level Control
	 *		  Item Level Control
	 * Returns	: Number
	 * Purpose	: Control procedure will take the various level control
	 *		  values and decide if the Locator is controlled at the
         *		  org,subinventory or item level. It will also decide
	 *		  if the locator is pre-specified or dynamic.
	 *******************************************************************/
 	FUNCTION CONTROL(org_control      IN    number,
                    sub_control      IN    number,
                    item_control     IN    number default NULL)
                    RETURN NUMBER
	IS
  		locator_control number;
  	BEGIN

    		IF (org_control = 1) then
       			locator_control := 1;
    		ELSIF (org_control = 2) then
       			locator_control := 2;
    		ELSIF (org_control = 3) then
       			locator_control := 3;
    		ELSIF (org_control = 4) then
      			IF (sub_control = 1) then
         			locator_control := 1;
      			ELSIF (sub_control = 2) then
         			locator_control := 2;
      			ELSIF (sub_control = 3) then
         			locator_control := 3;
      			ELSIF (sub_control = 5) then
        			IF (item_control = 1) then
           				locator_control := 1;
        			ELSIF (item_control = 2) then
           				locator_control := 2;
        			ELSIF (item_control = 3) then
           				locator_control := 3;
        			ELSIF (item_control IS NULL) then
           				locator_control := sub_control;
        			END IF;
      			END IF;
    		END IF;

    		RETURN locator_control;

  	END CONTROL;

	/*******************************************************************
	* Function	: Check_Overlap_Dates (Local function)
	* Parameter IN: Effectivity Date
	*		  Disable Date
	*		  Bill Sequence Id
	*		  Component Item Id
	* Return	: True if dates are overlapping else false.
	* Purpose	: The function will check if the same component is
	*		  entered with overlapping dates. Components with
	*		  overlapping dates will get a warning.
	******************************************************************/
	FUNCTION Check_Overlap_Dates
		( X_Effectivity_Date DATE,
		  X_Disable_Date     DATE,
                  X_Member_Item_Id   NUMBER,
                  X_Bill_Sequence_Id NUMBER,
                  X_Rowid            VARCHAR2,
                  X_Comp_Seq_Id      NUMBER,
                  X_Operation_Seq_Num NUMBER)
	RETURN BOOLEAN
  	IS
  		X_Count NUMBER := 0;
        	CURSOR X_All_Dates IS
                	SELECT 'X' date_available FROM sys.dual
                 	WHERE EXISTS (
                                SELECT 1 from BOM_Inventory_Components
                                 WHERE Component_Item_Id = X_Member_Item_Id
                                   AND Bill_Sequence_Id  = X_Bill_Sequence_Id
                                   AND Operation_Seq_Num = X_Operation_Seq_Num
				   --Commented out line below for bug 8839091
                                   --Uncommented for bug 9780939
           AND Component_Sequence_Id <> X_Comp_Seq_Id
				   AND (( RowId <> X_RowID ) or
					(X_RowId IS NULL))
                                   AND ( X_Disable_Date IS NULL
                                         OR ( Trunc(X_Disable_Date) >
					      Trunc(Effectivity_Date)
                                            )
                                        )
                                   AND ( Trunc(X_Effectivity_Date) <
					 Trunc(Disable_Date)
                                         OR Disable_Date IS NULL
                                        )
                               );
    	BEGIN

        	FOR X_Date IN X_All_Dates LOOP
          		X_Count := X_Count + 1;
          	END LOOP;

          	-- If count <> 0 that means the current date is overlapping with
	  	-- some record.
                IF X_Count <> 0 THEN
                        RETURN TRUE;
                ELSE
                        RETURN FALSE;
                END IF;

	END Check_Overlap_Dates;


	/*******************************************************************
	* Function    : Check_Overlap_Numbers (Local function)
	* Parameter IN: from end item unit number
	*               to end item unit number
	*               Bill Sequence Id
	*               Component Item Id
	* Return      : True if unit numbers are overlapping, else false.
	* Purpose     : The function will check if the same component is entered
	*               with overlapping unit numbers. Components with
	*		overlapping unit numbers will get a warning.
	* History	: Created by AS on 07/08/99 as part of unit effectivity
	*		  functionality.
	*********************************************************************/
	FUNCTION Check_Overlap_Numbers
		 (  X_From_End_Item_Number VARCHAR2
                  , X_To_End_Item_Number VARCHAR2
                  , X_Member_Item_Id   NUMBER
                  , X_Bill_Sequence_Id NUMBER
                  , X_Rowid            VARCHAR2
		  , X_Comp_Seq_Id      NUMBER
		  , X_Operation_Seq_Num NUMBER)
  	RETURN BOOLEAN
  	IS
        	X_Count NUMBER := 0;
        	CURSOR X_All_Numbers IS
                	SELECT 'X' unit_available FROM sys.dual
                 	WHERE EXISTS (
                                SELECT 1 from BOM_Inventory_Components
                                 WHERE Component_Item_Id = X_Member_Item_Id
                                   AND Bill_Sequence_Id  = X_Bill_Sequence_Id
				   AND Operation_Seq_Num = X_Operation_Seq_Num
           AND DISABLE_DATE IS NULL --bug:5347036 Consider only enabled components
				   AND Component_Sequence_Id <> X_Comp_Seq_Id
				   AND (RowId <> X_RowID
                                        OR X_RowId IS NULL)
                                   AND (X_To_End_Item_Number IS NULL
                                        OR X_To_End_Item_Number >
                                           From_End_Item_Unit_Number)
                                   AND (X_From_End_Item_Number <
                                         To_End_Item_Unit_Number
                                         OR To_End_Item_Unit_Number IS NULL
                                        )
                               );
    	BEGIN

          	FOR X_Unit IN X_All_Numbers LOOP
                	X_Count := X_Count + 1;
          	END LOOP;

          	-- If count <> 0 that means the unit numbers are overlapping
                IF X_Count <> 0 THEN
                        RETURN TRUE;
                ELSE
                        RETURN FALSE;
                END IF;

   	END Check_Overlap_Numbers;


	/********************************************************************
	* Function	: Verify_Item_Attributes
	* Prameters IN	: Organization_Id
	*		  Component Item Id
	*		  Assembly Item Id
	*		  Eng Bill flag for Assembly
	* Parameters OUT: Mesg Token_Tbl
	* Return	: True if no attributes are invalid and False otherwise
	* Purpose	: The function will validate the following BOM Matrix.
	*----------------------------------------------------------------------
	*                                    Component Types
	*----------------------------------------------------------------------
	*Bill            PTO     ATO     PTO   ATO             ATO    PTO   Std
	*Types           Model   Model   OC    OC   Planning   Item   Item  Item
	*-------------  --------------------------------------------------------
	*PTO Model       Yes     Yes     Yes   No   No         Yes    Yes   Yes
	*ATO Model       No      Yes     No    Yes  No         Yes    No    Yes
	*PTO OC          Yes     Yes     Yes   No   No         Yes    Yes   Yes
	*ATO OC          No      Yes     No    Yes  No         Yes    No    Yes
	*Planning        Yes     Yes     Yes   Yes  Yes        Yes    Yes   Yes
	*ATO Item        No      No      No    No   No         Yes    No    Yes
	*PTO Item        No      No      No    No   No          No    Yes   Yes
	*Standard Item   No      No      No    No   No         Yes    No    Yes
	*Config Item     No      Yes     No    Yes  No         Yes    No    Yes
	*
	**********************************************************************/
	FUNCTION Verify_Item_Attributes
	(  p_Mesg_token_tbl IN  Error_Handler.Mesg_Token_Tbl_Type
         , x_Mesg_Token_Tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type)
	RETURN BOOLEAN
	IS
		dummy	NUMBER;
		l_allow_eng_comps VARCHAR2(10);
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

	BEGIN
		l_Mesg_Token_Tbl := p_Mesg_Token_Tbl;

--		dbms_output.put_line
--		('Within the Verify Item Attributes procedure . . . ');

		-- Verify Eng flag for Assembly and Component
		l_allow_eng_comps := fnd_profile.value('ENG:ALLOW_ENG_COMPS');
		IF (g_Assy_Assembly_Type = 1 and  -- Bill is manufacturing
		-- Introduced new global variable to hold assembly_type of
		-- bill header.
		--bug: 4161794
	   	   g_Comp_Eng_Flag = 'Y' and  -- and component is Engineering
                   (l_allow_eng_comps is NULL or l_allow_eng_comps <> '1'))
		THEN
			Error_Handler.Add_Error_Token
			(  x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
			 , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
			 , p_message_name    => 'BOM_ASSY_COMP_ENG_FLG_MISMATCH'
			 , p_Token_Tbl	     => g_Token_Tbl
			 );
			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
			RETURN FALSE;
		END IF;

		/************************************************************
		-- Verify ATO MODEL OR ATO OPTION CLASS Assembly(not config)
		-- Attributes ATO Model does not allow
		-- 1. Planning Components
		-- 2. PTO Model or PTO Option Class
		-- 3. PTO Standard
		-- If the Assembly is ATO Standard, then it does not allow the
		-- above three types and
		-- 4. ATO Model or
		-- 5. ATO Option Class
		**************************************************************/
		IF ( ( ( g_Assy_Item_Type IN
			  (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS, Bom_Globals.G_STANDARD)  AND
	         	 g_Assy_ATO_flag  = 'Y' AND
		 	 g_Assy_Config = 'N'
	        	 )
	      	      ) AND
	      	      ( g_Comp_Item_Type = Bom_Globals.G_PLANNING OR
	        	( g_Comp_Item_Type IN
				(Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS, Bom_Globals.G_STANDARD) AND
	          		g_Comp_PTO_Flag  = 'Y'
	        	 )
	       	       )
	    	    ) OR
	    	   (
			g_Assy_Item_Type = Bom_Globals.G_STANDARD AND
			g_Assy_ATO_flag = 'Y'    AND
			g_Assy_Config = 'N' 	 AND
			( g_Comp_Item_Type IN (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS) AND
		  	  g_Comp_ATO_Flag = 'Y'
			 )
	    	    )
		THEN
			IF g_Assy_Item_Type = Bom_Globals.G_MODEL
			THEN
				g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
				g_Token_Tbl(2).Token_Value := 'BOM_MODEL_TYPE';
				g_Token_Tbl(2).Translate := TRUE;
			ELSIF g_Assy_Item_Type = Bom_Globals.G_OPTION_CLASS
			THEN
				g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        	g_Token_Tbl(2).Token_Value :=
						'BOM_OPTION_CLASS_TYPE';
                        	g_Token_Tbl(2).Translate := TRUE;
			ELSE
				g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        	g_Token_Tbl(2).Token_Value :=
							'BOM_STANDARD_TYPE';
                        	g_Token_Tbl(2).Translate := TRUE;
			END IF;
			g_token_tbl(3).token_name := 'REVISED_ITEM_NAME';
			g_token_tbl(3).token_value :=
					g_rev_component_rec.revised_item_name;

			IF g_Assy_Item_Type IN ( Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
			THEN
				Error_Handler.Add_Error_Token
				( p_message_name    => 'BOM_ATO_PROP_MISMATCH'
		 		, p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
		 		, x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
		 		, p_Token_Tbl	    => g_Token_Tbl
                		);
			ELSE
                        	Error_Handler.Add_Error_Token
                        	( p_message_name => 'BOM_ATO_STD_PROP_MISMATCH'
                       		 , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                       		 , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                       		 , p_Token_Tbl           => g_Token_Tbl
                       		 );
			END IF;
			g_Token_Tbl.DELETE(2);
			g_Token_Tbl.DELETE(3);

			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                	RETURN FALSE;

		/*************************************************************
		-- If the Assembly is a Config Item i.e. ATO with Base_Item_Id
		-- NOT NULL then it will allow
		-- 1. ATO Standard or
		-- 2. Standard item
		-- and
		-- 1. ATO Model
		-- 2. ATO Option Class
		-- only if the assemly is Phantom is Wip_Supply_Type is 6
		-- validation is changed by vhymavat for bug 2595175
		*************************************************************/
		ELSIF g_Assy_ATO_Flag = 'Y' AND
	      		g_Assy_Config   = 'Y'
		THEN
			IF( g_rev_component_rec.Wip_Supply_Type <> 6 AND
		   	  g_Comp_Item_Type IN
				(Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
		       		AND
		       	    g_Comp_ATO_Flag = 'Y'
		      	   )

			THEN
				g_token_tbl(2).token_name:='REVISED_ITEM_NAME';
				g_token_tbl(2).token_value :=
					g_rev_component_rec.revised_item_name;

				Error_Handler.Add_Error_Token
                		( p_message_name => 'BOM_CFG_SUPPLY_NOT_PHANTOM'
                 		, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 		, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 		, p_Token_Tbl          => g_Token_Tbl
                		);
				g_token_tbl.delete(2);

				x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
				RETURN FALSE;

		      	/****************************************************
		       	-- Assembly is Config item with Wip Supply of Phantom
		       	-- but the component item types do not match
		       	****************************************************/
			ELSIF
		      	NOT
		      	( ( g_Comp_Item_Type IN
			      (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS, Bom_Globals.G_STANDARD)
                          	AND
                             g_Comp_ATO_Flag = 'Y'
                            ) OR
                            g_Comp_Item_Type = Bom_Globals.G_STANDARD
                         )
			THEN
		 		g_token_tbl(2).token_name:= 'REVISED_ITEM_NAME';
                        	g_token_tbl(2).token_value :=
                                	g_rev_component_rec.revised_item_name;

				Error_Handler.Add_Error_Token
                        	( p_message_name => 'BOM_CONFIG_PROP_MISMATCH'
                       		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       		 , p_Token_Tbl          => g_Token_Tbl
                       		 );

				x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
				g_token_tbl.delete(2);
                        	RETURN FALSE;
			END IF;

		/*************************************************************
		-- Verify PTO MODEL or OPTION CLASS Assembly Attributes
	     	-- PTO Models do not allow
		-- 1. ATO Option Class and
		-- 2. Planning components
		**************************************************************/
		ELSIF g_Assy_Item_Type IN ( Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS) AND
	      		g_Assy_PTO_flag  = 'Y' AND
	      		( g_Comp_Item_Type = Bom_Globals.G_PLANNING OR
				( g_Comp_Item_Type = Bom_Globals.G_OPTION_CLASS AND
		  	          g_Comp_ATO_flag  = 'Y'
			 	 )
	       	         )
		THEN
			IF g_Assy_Item_Type = Bom_Globals.G_MODEL
			THEN
                        	g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        	g_Token_Tbl(2).Token_Value := 'BOM_MODEL_TYPE';
                        	g_Token_Tbl(2).Translate := TRUE;
                	ELSIF g_Assy_Item_Type = Bom_Globals.G_OPTION_CLASS
                	THEN
                        	g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        	g_Token_Tbl(2).Token_Value :=
					'BOM_OPTION_CLASS_TYPE';
                        	g_Token_Tbl(2).Translate := TRUE;
			END IF;

			g_token_tbl(3).token_name  := 'REVISED_ITEM_NAME';
			g_token_tbl(3).token_value :=
				g_rev_component_rec.revised_item_name;

			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_MODEL_OC_PROP_MISMATCH'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
                	 );

			g_Token_Tbl.DELETE(2);
			g_token_tbl.delete(3);
			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                	RETURN FALSE;

			/****************************************************
			--
			-- PTO STandard will only allow Standard or PTO Standard
			--
			*****************************************************/
		ELSIF g_Assy_Item_Type = Bom_Globals.G_STANDARD AND
              	      g_Assy_PTO_Flag  = 'Y' AND
	      	      NOT
	      	      ( g_Comp_Item_Type = Bom_Globals.G_STANDARD AND
			      ( ( g_Comp_PTO_Flag = 'Y' AND
		    	          g_comp_ATO_Flag = 'N'
		   		 ) OR
		   		 ( g_comp_ATO_Flag = 'N' AND
		     		   g_comp_PTO_Flag = 'N'
		   		  ) OR  --added for BOM ER 9946990
                                  (g_comp_ATO_Flag = 'Y' AND
		     		   g_comp_PTO_Flag = 'N' AND
                                   nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) = 1
		   		  )
		 	       )
	      		)
     /* Commenting for Bug 2627352
              	      NOT ( ( g_Comp_Item_Type = Bom_Globals.G_STANDARD AND
                      	      g_Comp_PTO_flag  = 'Y'
                    	     ) OR
                    	     ( g_Comp_Item_Type = Bom_Globals.G_STANDARD)
                  	    )
    */
        	THEN
		g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
		g_token_tbl(2).token_value :=
					g_rev_component_rec.revised_item_name;
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_PTO_STD_PROP_MISMATCH'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                 );
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		g_token_tbl.delete(2);
                RETURN FALSE;

		/************************************************************
		--
		-- A STANDARD bill will only allow ATO Standard and Standard
		-- items as components
		--
		*************************************************************/
		ELSIF g_Assy_Item_Type = Bom_Globals.G_STANDARD AND
	      	      g_Assy_PTO_Flag = 'N' AND
	      	      g_Assy_ATO_Flag = 'N' AND
	      	      NOT
	      	      ( g_Comp_Item_Type = Bom_Globals.G_STANDARD AND
			      ( ( g_Comp_ATO_Flag = 'Y' AND
		    	          g_comp_PTO_Flag = 'N'
		   		 ) OR
		   		 ( g_comp_ATO_Flag = 'N' AND
		     		   g_comp_PTO_Flag = 'N'
		   		  )
		 		)
	      		)
		THEN
			g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                	g_token_tbl(2).token_value :=
                                        g_rev_component_rec.revised_item_name;
		 	Error_Handler.Add_Error_Token
                	(  p_message_name       => 'BOM_STANDARD_PROP_MISMATCH'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	 );
                	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
			g_token_tbl.delete(2);
                	RETURN FALSE;

		END IF;

                /**************************************************************
                -- ATP Validation for components is changed and now there is no restriction
                -- Comment out by MK on 06/05/2001

		-- Once the matrix is verified then check the ATP Components
		-- and ATP Check attributes

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Check the ATP Components and ATP Check attribute.' );
     error_handler.write_debug('Assy ATP Comp Flag : ' || g_Assy_ATP_Comp_flag  );
     error_handler.write_debug('Comp ATP Check Flag : ' || g_Comp_Atp_Check_Flag );
END IF;

         	IF ( g_Assy_ATP_Comp_flag = 'N' AND
                     g_Comp_Atp_Check_Flag = 'Y'
	    	    )
		THEN
			g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                	g_token_tbl(2).token_value :=
                                        g_rev_component_rec.revised_item_name;

			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_ASSY_COMP_ATP_MISMATCH'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
                 	);
			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
			g_token_tbl.delete(2);
      			RETURN FALSE;  -- ATP Item Attribute Invalid
		END IF;
--		dbms_output.put_line('End of Item Attribute Validation . . .');

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Check the ATP Components and ATP Check attribute.' );
END IF;

                **************************************************************/

   	-- If control comes till this point then it would mean a success of
   	-- attribute validation. Hence,

   		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
   		RETURN TRUE;

	END Verify_Item_Attributes;

	/********************************************************************
	* Function	: Check_PTO_ATO_For_Optional (Local Function)
	* Returns	: 0 if Success
	*		  1 if Optional value is incorrect for ATO/PTO Model/OC
	*		  2 if Optional value is incorrect for Plan/Stdd Bill
	* Purpose	: Function will verify the following things:
	*		  1. Optional must be NO (2) if Bill if Pln or Standard
	*		  2. If Bill is PTO Model or OC and component is
	*		     ATO Std with no base mdl then Optional must be Yes
	*	 	     (1)
	***********************************************************************/
	--
	-- Check if the PTO and ATO flags of Assembly and Component for the
	-- Optional flag to be correct.
	--

	FUNCTION  Check_PTO_ATO_for_Optional
	RETURN NUMBER
	IS
	BEGIN

--		dbms_output.put_line
-- 		('Value of Optional when checking ATO / PTO . . .');

		IF ( g_Assy_PTO_flag = 'Y' 			    AND
                    --following clause modified for BOM ER 9946990
	     	    ( (g_Assy_Item_Type = Bom_Globals.G_MODEL and nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1) OR g_Assy_Item_Type = Bom_Globals.G_OPTION_CLASS) AND
	     	     g_Comp_ATO_flag = 'Y' 			    AND
	     	     g_Comp_Item_Type = Bom_Globals.G_STANDARD 		    AND
	     	     g_Comp_Config = 'N' 			    AND
	     	     g_Rev_Component_Rec.optional = 2
	    	     )
		THEN
			RETURN 1;
		ELSIF ( g_Assy_Item_Type IN (Bom_Globals.G_STANDARD, Bom_Globals.G_PLANNING)  AND
	        	g_Rev_Component_Rec.optional = 1
	       		)
		THEN
			RETURN 2;
		ELSE
			RETURN 0;
		END IF;

	END Check_PTO_ATO_for_Optional;

	/********************************************************************
	* Function	: Check_Planning_Percent
	* Returns	: 0 for Success else 1, 2, or 3 for errors
	* Purpose	: The function will verify the following:
	*		  Planning percent can be <> 100 only if
	*		  1. Bill is Planning else RETURN error code 1 Or
	*		  2. Bill is a Model/Option Class and Component is
	*		     optional Or else return error code 2.
	*		  3. Bill is a Model/Option Class and component is not
	*		     Optional and forecase control is = 2
	*		     (Consume and Derive)
	********************************************************************/
	FUNCTION Check_Planning_Percent RETURN NUMBER
	IS
	BEGIN
		IF g_rev_component_rec.planning_percent <> 100 THEN
			IF g_Assy_Item_Type = Bom_Globals.G_STANDARD THEN
				RETURN 1;
			ELSIF ( g_Assy_Item_Type IN (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
				AND
				g_rev_component_rec.optional <> 1 AND
				g_Comp_ATO_Forecast_Control  <> 2
		       		)
			THEN
				RETURN 2;
        --Commented out condition below for bug 7392603
			/*ELSIF ( g_Assy_Item_Type IN (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
				AND
                        	( g_rev_component_rec.optional = 1 AND              -- changed for Bug3163342
		 	  	  g_Comp_ATO_Forecast_Control <> 2
			         )
                       		)
			THEN
				RETURN 3;*/
			ELSE
				RETURN 0;
			END IF;
		ELSE
			RETURN -1;
		END IF;

	END Check_Planning_Percent;


	/*******************************************************************
	* Function	: Chk_Req_For_Rev_Or_Shp
	* Returns	: 1 if Required for Revenue is invalid
	*		  2 if Required to Ship is invalid
	*		  3 if both are incorrect
	*		  0 if both are correct
	* Purpose	: Function will verify the following:
	*		  Required for Revenue / Required to Ship must be NO if
	*		  Replenish_To_Order_Flag is 'Y' for the Bill
	********************************************************************/
	FUNCTION Chk_Req_For_Rev_Or_Shp
	RETURN NUMBER
	IS
	BEGIN

		IF g_rev_component_rec.required_for_revenue = 1 AND
	   	   g_rev_component_rec.required_to_ship = 2 AND
	   	   g_Assy_ATO_Flag = 'Y'
		THEN
			RETURN 1;
		ELSIF g_rev_component_rec.required_to_ship = 1 AND
	      	      g_rev_component_rec.required_for_revenue = 2 AND
	      	      g_Assy_ATO_Flag = 'Y'
		THEN
			RETURN 2;
		ELSIF g_rev_component_rec.required_to_ship = 1 AND
	      	      g_rev_component_rec.required_for_revenue = 1 AND
	              g_Assy_ATO_Flag = 'Y'
		THEN
			RETURN 3;
		ELSE
			RETURN 0;
		END IF;

	END Chk_Req_For_Rev_Or_Shp;


	-- Local Function for Product Family Members
	/********************************************************************
        *Function       : CheckUnique_PF_Member
        *Returns        : 1 This component exits in an other Product Family
        *		  Bill
        *                 0 This component does not exist in other product
        *		  family Bill.
        *Purpose        : Function will verify if the component exists in
        *                 other product family Bills.
        **********************************************************************/
	FUNCTION CheckUnique_PF_Member RETURN NUMBER
	IS
		Pf_Item_Id	Number ;
	BEGIN
              --dbms_output.put_line('Withing Function CheckUnique_PF_Member . . .');

		IF g_Assy_Item_Type = Bom_Globals.G_PRODUCT_FAMILY
		THEN
			BEGIN
				SELECT product_family_item_id
				INTO   Pf_Item_Id
				FROM   mtl_system_items_b
				WHERE  inventory_item_id = g_rev_comp_Unexp_rec.component_item_id
				AND    organization_id = g_rev_comp_Unexp_rec.organization_id;

				If (Pf_Item_Id is NULL) THEN
					RETURN 0;
				ELSE
					RETURN 1;
				END IF;
			END;
		END IF;
		RETURN 0; -- This should never happen.  CheckUnique_PF_Member should be called if item type is PF.

	END CheckUnique_PF_Member;

	-- Local Function Check_ATP
	/********************************************************************
	*Function	: Check_ATP
	*Returns	: 1 if ATP invalid because qty is -ve
	*		  2 if ATP invalid because qty is fractional
	*		  0 if the ATP value is valid.
	*Purpose	: Function will verify if the Check_Atp value is correct
	*		  wrt to the check_atp and atp_components_flag of the
	*		  parent and component. It will also check if the
	*		  component quantity is greater than 0 for the
	*		  check_atp to be yes.
	**********************************************************************/
	FUNCTION Check_ATP RETURN NUMBER
	IS
	BEGIN
--		dbms_output.put_line('Withing Function Check_ATP . . .');

    		IF g_Assy_ATP_Comp_flag IN ('Y','R','C') AND
       		   g_Comp_ATP_Check_flag in ('Y', 'C', 'R')
    		THEN
			IF g_rev_component_rec.quantity_per_assembly < 0 THEN
				RETURN 1;
			ELSIF round(g_rev_component_rec.quantity_per_assembly)
			      <>  g_rev_component_rec.quantity_per_assembly
			THEN
				RETURN 2;
			ELSE
				RETURN 0;
			END IF;
    		ELSE
			RETURN 1;
    		END IF;

	END Check_ATP;

	/********************************************************************
	* Function	: Check_Mutually_Exclusive
	* Returns	: 0 if the Mutually exlusive values is correct
	*		  1 if BOM is not Installed
	*		  2 if Revised Component is Model or Option Class
	* Purpose	: Will verify the value of mutually exclusive options
	*		  column by verifying if BOM is Installed and the
	*		  component is either a Model or Option Class.
	*		  In only this case the column can have a value of
	*		  Yes (1).
	*********************************************************************/
	--Local function to validate Mutually_Exclusive_Option
	FUNCTION Check_Mutually_Exclusive RETURN NUMBER
	IS
		X_Bom_Status	VARCHAR2(80);
		X_Industry	VARCHAR2(80);
		X_Install_Bom	BOOLEAN;
	BEGIN
--		dbms_output.put_Line
--		('Checking Mutually Exclusive for value : ' ||
--		to_char(g_rev_component_rec.Mutually_Exclusive));

		IF g_rev_component_rec.Mutually_Exclusive = 1 THEN
 			X_install_bom := Fnd_Installation.Get
				 ( appl_id     => '702',
                                   dep_appl_id => '702',
                                   status      => X_bom_status,
                                   industry    => X_industry);
			IF X_install_bom AND
		   		g_Comp_Item_Type IN (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
			THEN
				RETURN 0;
			ELSIF g_Comp_Item_Type NOT IN (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
			THEN
				RETURN 2;
			ELSE
				RETURN 1;
			END IF;
		ELSE
			RETURN 0;
		END IF;

	END Check_Mutually_Exclusive;


	/******************************************************************
	* Function	: Check_Supply_Type
	* Returns	: TRUE if the supply type is correct, false otherwise
	* Purpose	: Function will verify if the Wip_supply_Type value is
	*		  is correct by doing the following checks:
	*		  1. Wip_Supply_Type = 6 (Phantom), then component must
	*		     have a bill, else log a warning.
	*		  2. Wip_Supply_Type must be Phantom if the component is
	*		     Model or Option Class
	********************************************************************/
	FUNCTION Check_Supply_Type
	 (  p_Mesg_Token_Tbl IN  Error_Handler.Mesg_Token_Tbl_Type
	  , x_Mesg_token_tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type)
	RETURN BOOLEAN
	IS
		l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
	BEGIN
		l_Mesg_token_Tbl := p_Mesg_Token_Tbl;

		IF g_rev_component_rec.WIP_Supply_Type IS NOT NULL
		THEN
			IF g_rev_component_rec.wip_supply_type = 6 /* PHANTOM */
			THEN
		  	BEGIN
				-- If Phantom then Component must be a Bill
		   		SELECT 'Valid'
		     		INTO l_dummy
		     		FROM bom_bill_of_materials
		    		WHERE assembly_item_id =
			  		g_rev_comp_unexp_rec.component_item_id
		      		AND organization_id  =
					  g_rev_comp_unexp_rec.organization_id
				AND rownum < 2; -- bug 2986752

		    		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		    		RETURN TRUE;

		    		EXCEPTION
				   WHEN NO_DATA_FOUND THEN
            				Error_Handler.Add_Error_Token
					(  p_message_name   => 'BOM_NO_BILL'
					 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
					 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 	 , p_message_type   => 'W'
					);
					x_Mesg_token_tbl := l_Mesg_Token_Tbl;
					RETURN TRUE;
					-- Since this is a warning return true
			END; -- Check if phantom block

/* bug 2681317 this restriction is removed as per CTO team's suggestions ref1588889
			ELSE
				-- If component is Model/OC then
				-- WIP_Supply Type must be Phantom
				IF g_Comp_Item_Type IN
					(l_MODEL, l_OPTION_CLASS) AND
			   	   g_rev_component_rec.wip_supply_type <> 6
				THEN
                                    Error_Handler.Add_Error_Token
                                    ( p_message_name => 'BOM_WIP_SUPPLY_PHANTOM'
                                     ,p_Mesg_Token_Tbl=> l_Mesg_token_Tbl
                                     ,x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                                     ,p_token_tbl     => g_Token_Tbl
                                     , p_message_type   => 'W'
                                     );
				     x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
--				     dbms_output.put_line
--				('Returing False Check Supply Type....');

                                     RETURN TRUE;
				END IF;
*/
	       		END IF;
		END IF;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
	RETURN TRUE;
	END Check_Supply_Type;

	-- Local Function to verify Minimum Quantity.
	FUNCTION Check_Min_Quantity RETURN BOOLEAN
	IS
	BEGIN
--		dbms_output.put_line('Low Quantity : ' ||
--		to_char(g_rev_component_rec.minimum_allowed_quantity));
--		dbms_output.put_line('Component Quantity : ' ||
--		to_char(g_rev_component_rec.quantity_per_assembly));
		IF NVL(g_rev_component_rec.minimum_allowed_quantity, 0) >
	           NVL(g_rev_component_rec.quantity_per_assembly, 0) THEN
                	RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;

	END Check_Min_Quantity;

	-- Local function to verify High Quantity
	FUNCTION Check_Max_Quantity RETURN BOOLEAN
	IS
	BEGIN
--		dbms_output.put_line('High Quantity : ' ||
--		to_char(g_rev_component_rec.maximum_allowed_quantity));
--        	dbms_output.put_line('Component Quantity : ' ||
--		to_char(g_rev_component_rec.quantity_per_assembly));

        	IF NVL(g_rev_component_rec.maximum_allowed_quantity, 0) <
		   NVL(g_rev_component_rec.quantity_per_assembly, 0) THEN
                	RETURN FALSE;
		ELSE
			RETURN TRUE;
        	END IF;

	END Check_Max_Quantity;

	-- Local function to check supply subinventory
	FUNCTION Check_Supply_SubInventory RETURN BOOLEAN
	IS
		l_allow_expense_to_asset VARCHAR2(10);
		l_RestrictSubInventory VARCHAR2(1);
		l_InventoryAsset	VARCHAR2(1);

		CURSOR c_Restrict_SubInv_Asset IS
		SELECT locator_type
	  	FROM mtl_item_sub_ast_trk_val_v
	 	WHERE inventory_item_id = g_rev_comp_Unexp_rec.component_item_id
	   	AND organization_id = g_rev_comp_Unexp_rec.organization_id
	   	AND secondary_inventory_name =
	       		g_rev_component_rec.supply_subinventory;

		CURSOR c_Restrict_SubInv_Trk IS
		SELECT locator_type
	  	FROM mtl_item_sub_trk_val_v
	 	WHERE inventory_item_id = g_rev_comp_Unexp_rec.component_item_id
	   	AND organization_id   = g_rev_comp_Unexp_rec.organization_id
	   	AND secondary_inventory_name =
	       		g_rev_component_rec.supply_subinventory;

		CURSOR c_SubInventory_Asset IS
		SELECT locator_type
	  	FROM mtl_sub_ast_trk_val_v
	 	WHERE organization_id = g_rev_comp_Unexp_rec.organization_id
	   	AND secondary_inventory_name =
	       		g_rev_component_rec.supply_subinventory;

		CURSOR c_Subinventory_Tracked IS
		SELECT locator_type
	  	FROM mtl_subinventories_trk_val_v
	 	WHERE organization_id = g_rev_comp_Unexp_rec.organization_id
	   	AND secondary_inventory_name =
	       		g_rev_component_rec.supply_subinventory;

	BEGIN

--		dbms_output.put_line('Checking Subinv value . . . ' ||
--		g_rev_component_rec.supply_subinventory);

		l_allow_expense_to_asset := fnd_profile.value
				    ('INV:EXPENSE_TO_ASSET_TRANSFER');

		-- Get Restrict_Subinventory_Flag for the Item
		SELECT DECODE(restrict_subinventories_code, 1, 'Y', 'N'),
	       		inventory_asset_flag
	  	INTO l_RestrictSubInventory,
	       	     l_InventoryAsset
	  	FROM mtl_system_items
	 	WHERE inventory_item_id = g_rev_comp_Unexp_rec.component_item_id
	   	AND organization_id   = g_rev_comp_Unexp_rec.organization_id;

		IF l_RestrictSubInventory = 'Y' THEN

--			dbms_output.put_line('Subinventory is Restricted...');

			IF l_allow_expense_to_asset = '1' THEN

--				dbms_output.put_line
--				('Allow Expense to Asset 1 . . .');

				OPEN c_Restrict_SubInv_Trk;
				FETCH c_Restrict_SubInv_Trk INTO
					l_Sub_Locator_Control;
--				dbms_output.put_line('Within locator check ' ||
--				to_char(l_Sub_Locator_Control));

				IF c_Restrict_SubInv_Trk%Found THEN
					CLOSE c_Restrict_SubInv_Trk;
					RETURN TRUE;
				ELSE
--					dbms_output.put_line
--					('Sub loc in Subinv: ' ||
--					to_char(l_Sub_Locator_Control));

					CLOSE c_Restrict_SubInv_Trk;
					RETURN FALSE;
				END IF;
			ELSE
				IF l_InventoryAsset = 'Y' THEN

--					dbms_output.put_line
--					('Inventory Asset Yes . . .');

					OPEN c_Restrict_SubInv_Asset;
                        		FETCH c_Restrict_SubInv_Asset INTO
				      		l_Sub_Locator_Control;
                        		IF c_Restrict_SubInv_Asset%Found THEN
                                		CLOSE c_Restrict_SubInv_Asset;
                                		RETURN TRUE;
                        		ELSE
                                		CLOSE c_Restrict_SubInv_Asset;
                                		RETURN FALSE;
                        		END IF;
				ELSE
--					dbms_output.put_line
--					('Inventory Asset No . . .');

					OPEN c_Restrict_SubInv_Trk;
                        		FETCH c_Restrict_SubInv_Trk INTO
				      		l_Sub_Locator_Control;
                        		IF c_Restrict_SubInv_Trk%Found THEN
                                		CLOSE c_Restrict_SubInv_Trk;
                                		RETURN TRUE;
                        		ELSE
                                		CLOSE c_Restrict_SubInv_Trk;
                                		RETURN FALSE;
                        		END IF;

				END IF;
			END IF;
		ELSE

--			dbms_output.put_line('Subinventory not restricted...');

			IF l_Allow_Expense_To_Asset = '1' THEN

--				dbms_output.put_line
--				('Allow Expense to Asset = 1 ...');

				OPEN c_SubInventory_Tracked;
				FETCH c_SubInventory_Tracked INTO
					l_Sub_Locator_Control;
				IF c_SubInventory_Tracked%FOUND THEN
					CLOSE c_SubInventory_Tracked;
					RETURN TRUE;
				ELSE
					CLOSE c_SubInventory_Tracked;
					RETURN FALSE;
				END IF;
			ELSE
				IF l_InventoryAsset = 'Y' THEN
--					dbms_output.put_line
--					('Inventory Asset = Y . . .');

					OPEN c_SubInventory_Asset;
					FETCH c_SubInventory_Asset INTO
				      		l_Sub_Locator_Control;
					IF c_SubInventory_Asset%FOUND THEN
						CLOSE c_SubInventory_Asset;
						RETURN TRUE;
					ELSE
						CLOSE c_SubInventory_Asset;
						RETURN FALSE;
					END IF;
				ELSE
--					dbms_output.put_line
--					('Fetched from Subinventory Tracked..');

					OPEN c_Subinventory_Tracked;
					FETCH c_Subinventory_Tracked INTO
				      		l_Sub_Locator_Control;
					IF c_SubInventory_Tracked%FOUND THEN
						CLOSE c_Subinventory_Tracked;
						RETURN TRUE;
					ELSE
						CLOSE c_Subinventory_Tracked;
						RETURN FALSE;
					END IF;
				END IF;
			END IF;
		END IF;
	END Check_Supply_SubInventory;

	-- Local function to verify locators
	FUNCTION Check_Locators RETURN BOOLEAN
	IS
  		Cursor CheckDuplicate is
        	SELECT 'checking for duplicates' dummy
         	FROM sys.dual
        	WHERE EXISTS (
          		SELECT null
            		FROM mtl_item_locations
           		WHERE organization_id =
				g_rev_comp_Unexp_rec.organization_id
             		AND inventory_location_id =
				g_rev_comp_Unexp_rec.supply_locator_id
             		AND subinventory_code <>
				g_rev_component_rec.supply_subinventory
				);

		x_Control NUMBER;
  		l_Success	BOOLEAN;
	 BEGIN

		l_org_locator_control := 0 ;
		l_item_locator_control := 0;


--		dbms_output.put_line('Within Check Locators function. . .');

		-- Get Value of Org_Locator and item_Locator.
		SELECT stock_locator_control_code
	  	INTO l_org_locator_control
          	FROM mtl_parameters
       		WHERE organization_id = g_rev_comp_Unexp_rec.organization_id;

		-- Get Value of Item Locator
  		SELECT location_control_code
	  	INTO l_item_locator_control
	  	FROM mtl_system_items
	 	WHERE organization_id = g_rev_comp_Unexp_rec.organization_id
	   	AND inventory_item_id = g_rev_comp_Unexp_rec.component_item_id;

		-- Get if locator is restricted or unrestricted

        	SELECT RESTRICT_LOCATORS_CODE
          	INTO l_item_loc_restricted
          	FROM mtl_system_items
         	WHERE organization_id = g_rev_comp_Unexp_rec.organization_id
           	AND inventory_item_id = g_rev_comp_Unexp_rec.component_item_id;

		--
  		-- When a SubInventory is validated, then depending on the
		-- Cursor being
		-- used in the Check_SubInventory procedure, the value of
		-- l_Sub_Locator_Control would be set.
		-- Else if there is no change in subinv
  		-- then excute subinv check.
  		--

--		dbms_output.put_line('Checking Subinventory locator control,
--		calling Check_Supply_SubInventory . . .');


IF Bom_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('L_SUB_LOC_CONTROL :' || to_number( l_Sub_Locator_Control)  );
     Error_Handler.Write_Debug('Now calling Check SupplySubInv: '|| g_rev_component_rec.supply_subinventory );
END IF;

		IF l_Sub_Locator_Control IS NULL AND
     		   g_rev_component_rec.supply_subinventory IS NOT NULL
		THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
     ('Now calling Check SupplySubInv. . .');
END IF;


			l_Success := Check_Supply_SubInventory;
  		END IF;

-- 		dbms_output.put_line
--		('After calling Check_Supply_SubInventory in Check_Locators..');

        /*
		Locator is not required.  But that validation should not be combined with Sub Inventory
		level locator control value.  So commenting this validation.  Bug 5032528
  		--
  		-- Locator cannot be NULL is if locator restricted
  		--
  		IF g_rev_comp_Unexp_rec.supply_locator_id IS NULL
     		AND l_item_loc_restricted = 1
  		THEN
			l_locator_control := 4;
			RETURN FALSE;
  		ELSIF g_rev_comp_Unexp_rec.supply_locator_id IS NULL
        		AND l_item_loc_restricted = 2
		THEN
			RETURN TRUE;
		END IF;
        */
--		dbms_output.put_line('Within Check locators . . .');

		IF l_org_locator_control  is not null AND
     		   l_sub_locator_control  is not null AND
     		   l_item_locator_control is not null
		THEN
--			dbms_output.put_line
--			('Org _Control: ' || to_char(l_org_locator_control));
--			dbms_output.put_line('Sub _Control: ' ||
--			to_char(l_sub_locator_control));
--			dbms_output.put_line('Item Control: ' ||
--			to_char(l_item_locator_control));

     			x_control := Control
			( Org_Control  => l_org_locator_control,
        		   Sub_Control  => l_sub_locator_control,
        		   Item_Control => l_item_locator_control
			  );

     			l_locator_control := x_control;
			-- Variable to identify if the dynamic loc.
			-- Message must be logged.

     			IF x_Control = 1
		        -- Added for bug 5032528, If locator is set, when locator control is none then only throw error
		         AND g_rev_comp_Unexp_rec.supply_locator_id IS NOT NULL THEN  -- No Locator Control
 				RETURN FALSE;  -- No Locator and Locator Id is
					       -- supplied then raise Error
     			ELSIF x_Control = 2 OR x_Control = 3 THEN   -- PRESPECIFIED
			/*
			 * Added OR x_Control = 3 as part of FP fix for bug 3624635
			 * Even for dynamic locators if the locators are
			 * in the system then we should be allowing.
			 */
			BEGIN

--				dbms_output.put_line
--				('Checking when x_control returned 2 and ' ||
--				' item locator is ' ||
--				to_char(l_item_locator_control));

	    			-- If restrict locators is Y then check in
				-- mtl_secondary_locators if the item is
				-- assigned to the subinventory/location
				-- combination If restrict locators is N then
				-- check that the locator exists
	    			-- and is assigned to the subinventory and this
				-- combination is found in mtl_item_locations.

	    			IF l_item_loc_restricted = 1
					-- Restrict Locators  = YES
	    			THEN

					--** Check for restrict Locators YES**
					SELECT 'Valid'
		  			INTO l_dummy
		  			FROM mtl_item_locations mil,
		       		             mtl_secondary_locators msl
               	 			WHERE msl.inventory_item_id =
		       			g_rev_comp_Unexp_rec.component_item_id
               	   			AND msl.organization_id =
		       			g_rev_comp_Unexp_rec.organization_id
               	   			AND msl.subinventory_code =
		       			g_rev_component_rec.supply_subinventory
		   			AND msl.secondary_locator =
		       			g_rev_comp_Unexp_rec.supply_locator_id
		   			AND mil.inventory_location_id =
						msl.secondary_locator
		   			AND mil.organization_id =
					msl.organization_id
		   			AND NVL(mil.disable_date, SYSDATE+1) >
						SYSDATE ;

					-- If no exception is raised then the
					-- Locator is Valid
					RETURN TRUE;
	     			ELSE
					--**Check for restrict Locators NO**
--					dbms_output.put_line
--					('Item restrict locators is NO . . .');

					SELECT 'Valid'
                  			INTO l_dummy
                  			FROM mtl_item_locations mil
                 			WHERE mil.subinventory_code 	 =
		       			g_rev_component_rec.supply_subinventory
                   			AND mil.inventory_location_id =
		       			g_rev_comp_Unexp_rec.supply_locator_id
		   			AND mil.organization_id 	 =
		       			g_rev_comp_Unexp_rec.organization_id
		   			AND NVL(mil.DISABLE_DATE, SYSDATE+1) >
					SYSDATE;

                			-- If no exception is raised then the
					-- Locator is Valid
                			RETURN TRUE;

	     			END IF;

				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						RETURN FALSE;
			END; -- x-control=2 OR x_Control = 3 Ends
                        /* Commented as part of FP fix for bug 3624635
     			ELSIF x_Control = 3 THEN
				-- DYNAMIC LOCATORS ARE NOT ALLOWED IN OI.
				-- Dynamic locators are not allowed in open
				-- interface, so raise an error if the locator
				-- control is dynamic.
				l_locator_control := 3;
				RETURN FALSE;
                        */
     			ELSE
--				dbms_output.put_line
--				('Finally returing a true value . . .');
                		RETURN TRUE;

     			END IF; -- X_control Checking Ends

  		ELSE
			RETURN TRUE;
  		END IF;  -- If Locator Control check Ends.

	END Check_Locators;

        /*******************************************************************
        * Function      : Check_Routing_Exists
        * Returns       : TRUE if routing exists for revised item
        *                 FALSE if no routing exists for the revised item
        * Purpose       : Verify the following:
        *                 Function Check_Routing_Exists checks if there is a
        *                 routing for the revised item.
        *                 If there is no routing, the user can only enter an
        *                 Operation Sequence Number of 1. Otherwise, the user
        *                 enter a NOT 1 value to indicate the routing operation.
        * History 	: Created by AS on 08/20. This validation modifies the
			  original Operation Sequence Number validation slightly.
	**********************************************************************/

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

	/*******************************************************************
	* Function	: Check_Op_Seq
	* Parameters	: l_unit_controlled_item - indicates whether revised
        *		  item is unit or date controlled
	* Returns	: 0 if new op_seq or op_seq is valid
	* 		  1 if new_op_seq or op_seq does not exist
	*		  2 if new_op_seq or op_seq is not unique
	                  3 if comp Operations exist with same op seq num
	* Purpose	: Verify the following:
	* 		  Function Check_Op_Seq will check if the op_seq_num
	*		  or the new_op_seq_num exists.
	*		  If they exist, then it will go ahead and check if
	*		  the the same component does not already exist with
	*		  the same op_seq_num
	**********************************************************************/
	FUNCTION Check_Op_Seq
	( l_unit_controlled_item	BOOLEAN
	)
	RETURN NUMBER
	IS

/* Bug 2573061
The cursor Valid_Op_Seq is checking whether the operation_seq_num of the
alternate_bill is existing in the alternate_routing or not.  If alternating
routing not exists for that alternate bill then it is returning error.
But it should not do that.  If alternate routing not exists it should validate
the operation_seq_nums from the primary routing.  so modified the cursor.
*/

		CURSOR Valid_Op_Seq (p_eco_for_production NUMBER)  IS
       		SELECT 'Valid' valid_op_seq
         	  FROM
/*                     bom_operational_routings bor,
              	       bom_operation_sequences bos
        	 WHERE bor.assembly_item_id =
				g_rev_comp_Unexp_rec.revised_item_id
          	   AND bor.organization_id  =
				g_rev_comp_Unexp_rec.organization_id
          	   AND NVL(bor.alternate_routing_designator, 'NONE') =
              	       NVL(g_rev_component_rec.alternate_bom_code, 'NONE')
          	   AND bos.routing_sequence_id = bor.common_routing_sequence_id
*/
                       bom_operation_sequences  bos
                 WHERE
                   bos.routing_sequence_id =
                   (
                      select common_routing_sequence_id
                      from bom_operational_routings
                      where assembly_item_id = g_rev_comp_Unexp_rec.revised_item_id
                            and organization_id = g_rev_comp_Unexp_rec.organization_id
                            and nvl(alternate_routing_designator,
                                  nvl(g_rev_component_rec.alternate_bom_code, 'NONE')) =
                                nvl(g_rev_component_rec.alternate_bom_code, 'NONE')
                            and (g_rev_component_rec.alternate_bom_code is null
                               or (g_rev_component_rec.alternate_bom_code is not null
                                   and (alternate_routing_designator =
                                          g_rev_component_rec.alternate_bom_code
                                        or not exists
                                          (select null
                                           from bom_operational_routings bor2
                                           where bor2.assembly_item_id =
                                                 g_rev_comp_Unexp_rec.revised_item_id
                                                 and bor2.organization_id = g_rev_comp_Unexp_rec.organization_id
                                                 and bor2.alternate_routing_designator =
                                                 g_rev_component_rec.alternate_bom_code
                                           )
                                        )
                                    )
                                 )
                   )
	      	   AND bos.operation_seq_num =
			decode(g_rev_component_rec.new_operation_sequence_number,
		      	      NULL,
		      	      g_rev_component_rec.Operation_Sequence_Number,
		      	      g_rev_component_rec.new_Operation_sequence_number
		     	      )
                    -- commented following AND condition for bug 7339077
                    -- AND nvl(trunc(disable_date), trunc(sysdate)+1)  > trunc(sysdate)
                      -- added following AND conditon for bug 7339077
                      AND nvl(disable_date, trunc(sysdate)+1) >= sysdate


                   AND (   (     p_eco_for_production = 2
                            AND  nvl(bos.eco_for_production, 2) <> 1
                            )
                        OR (    p_eco_for_production = 1
                            AND (   bos.implementation_date IS NOT NULL
                                    OR ( bos.revised_item_sequence_id
                                         = g_rev_comp_unexp_rec.revised_item_sequence_id)
                                )
                            )
                        ) ;

                   -- Added above conditions for Eco for Production by MK 02/02/2001
                   -- Form has this validation in LOV for New Operation Sequence Number filed

                l_eco_for_production NUMBER ; -- Added by MK 02/02/2001

		CURSOR c_Op_Seq_Date_Used IS
			/* Check same component is not already effective */
		SELECT 'Already Used' op_seq_used
	  	  FROM bom_inventory_components bic
         	 WHERE bic.bill_sequence_id    =
			g_rev_comp_Unexp_rec.bill_sequence_id
           	   AND bic.component_item_id   =
		       g_rev_comp_Unexp_rec.component_item_id
           	   AND bic.operation_seq_num   =
	       	       decode(g_rev_component_rec.new_operation_sequence_number,
                       	      NULL,
                       	      g_rev_component_rec.operation_sequence_number,
                       	      g_rev_component_rec.new_operation_sequence_number
                      	      )
		   /* Added extra condition to accomodate bill components
		   */
       AND bic.component_sequence_id <>
              g_rev_comp_Unexp_rec.component_sequence_id
       /*added extra condition to avoid validation against the same comp*/
		   AND (trunc(bic.effectivity_date)
				    < trunc(g_rev_component_rec.start_effective_date)
           	   	AND nvl(trunc(bic.disable_date),
				 trunc(g_rev_component_rec.start_effective_date) + 2)
            			    > trunc(g_rev_component_rec.start_effective_date));

                CURSOR c_Op_Seq_Unit_Used IS
                        /* Check same component is not already effective */
                SELECT 'Already Used' op_seq_used
                  FROM bom_inventory_components bic
                 WHERE bic.bill_sequence_id    =
                        g_rev_comp_Unexp_rec.bill_sequence_id
                   AND bic.component_item_id   =
                       g_rev_comp_Unexp_rec.component_item_id
                   AND bic.operation_seq_num   =
                       decode(g_rev_component_rec.new_operation_sequence_number,
                              NULL,
                              g_rev_component_rec.operation_sequence_number,
                              g_rev_component_rec.new_operation_sequence_number
                              )
		   AND DECODE(g_rev_component_rec.new_effectivity_date,
                              NULL,
                              g_rev_component_rec.start_effective_date,
                              g_rev_component_rec.new_effectivity_date
                              ) between bic.effectivity_date AND NVL(bic.disable_date, SYSDATE)
                   AND bic.component_sequence_id <> g_rev_comp_unexp_rec.component_sequence_id
                        /* Added extra condition to accomodate bill components
                        */
                   AND (bic.from_end_item_unit_number
                                <= g_rev_component_rec.from_end_item_unit_number
                             AND NVL(bic.to_end_item_unit_number,
                                g_rev_component_rec.from_end_item_unit_number)
                                >= g_rev_component_rec.from_end_item_unit_number);
	/* bug:4240031 Checking for the existence of Component Operation
	 * with the same Op_seq_num
	*/
		CURSOR c_Comp_Operation_Exist IS
		SELECT 'Already Exists' op_seq_exists
		 FROM  bom_component_operations bco
		 WHERE bco.component_sequence_id =
		                g_rev_comp_Unexp_rec.component_sequence_id
		  AND  bco.operation_seq_num =
		              decode(g_rev_component_rec.new_operation_sequence_number,
                                     NULL,
                                     g_rev_component_rec.operation_sequence_number,
                                     g_rev_component_rec.new_operation_sequence_number
                                    );

	BEGIN

		-- If a record is found then it will mean that though
		-- the Operation Sequence exists in the Routings table
		-- a component already exist with that operation sequence abd
		-- Effectivity date so it cannot be inserted. So return an error
		-- hence, this function will return a false.

                l_eco_for_production  := NVL(Bom_Globals.Get_Eco_For_Production,2)  ;

		FOR l_valid_op IN  Valid_Op_Seq(l_eco_for_production)  LOOP
			-- if operation_seq exists in Operation_Sequences then
			-- verify that the same component does not already exist
			-- for that bill with the same operation seq.
		-- bug :4240031
		     OPEN c_Comp_Operation_Exist;
		     FETCH c_Comp_Operation_Exist INTO l_dummy;
		     IF c_Comp_Operation_Exist%FOUND THEN
		         CLOSE c_Comp_Operation_Exist;
			 RETURN 3;
	             ELSE
		         CLOSE c_Comp_Operation_Exist;
		     END IF;
                -- bug:4240031 ends
		    IF l_unit_controlled_item
		    THEN
			FOR l_Op_Seq_Unit_Used IN c_Op_Seq_Unit_Used LOOP
				RETURN 2;
				-- Op_seq_num or the new_op_seq_num not unique
			END LOOP;
		    ELSE
			FOR l_Op_Seq_Date_Used IN c_Op_Seq_Date_Used LOOP
                                RETURN 2;
                                -- Op_seq_num or the new_op_seq_num not unique
                        END LOOP;
          --For date eff bills, editable common bills may exist. The operation seq num
          --must be valid for those bils too.
          IF NOT BOMPCMBM.Check_Op_Seq_In_Ref_Boms(p_src_bill_seq_id => g_rev_comp_Unexp_rec.bill_sequence_id
                                                  , p_op_seq => nvl(g_rev_component_rec.new_operation_sequence_number,
                                                                    g_rev_component_rec.operation_sequence_number)
                                                  )
          THEN RETURN 4;
          END IF;

		    END IF;

--			dbms_output.put_line
--			('Check Op Seq returing with Success (0) ');

	            RETURN 0;  -- op_seq_num or new_op_seq_num is valid

		END LOOP;

		RETURN 1;
		-- op_seq_num or new_op_seq_num is invalid
		-- i.e does not exist in bom_oper_sequences

	END Check_Op_Seq;

        /*
        ** Function Check_Unit_Number
        ** Will be called when the user is attempting to modify a unit effective BOM
        ** If the new unit number is creating a component with overlapping effectivity
        ** then this method will return 1
        ** else it will return 0
        */
        FUNCTION Check_Unit_Number
        RETURN NUMBER
        IS
                CURSOR c_Unit_Num_Used IS
                        /* Check same component is not already effective */
                SELECT 'Already Used' unit_num_used
                  FROM bom_inventory_components bic
                 WHERE bic.bill_sequence_id    =
                        g_rev_comp_Unexp_rec.bill_sequence_id
                   AND bic.component_item_id   =
                       g_rev_comp_Unexp_rec.component_item_id
                   AND bic.operation_seq_num   =
                       decode(g_rev_component_rec.new_operation_sequence_number,
                              NULL,
                              g_rev_component_rec.operation_sequence_number,
                              g_rev_component_rec.new_operation_sequence_number
                              )
                   AND DECODE(g_rev_component_rec.new_effectivity_date,
                              NULL,
                              g_rev_component_rec.start_effective_date,
                              g_rev_component_rec.new_effectivity_date
                              ) between bic.effectivity_date AND NVL(bic.disable_date, SYSDATE)
                   AND bic.component_sequence_id <> g_rev_comp_unexp_rec.component_sequence_id
                        /* Added extra condition to accomodate bill components
                        */
                   AND (( bic.from_end_item_unit_number
                                <= DECODE(g_rev_component_rec.new_from_end_item_unit_number,FND_API.G_MISS_CHAR, /* bug 8314145 */
                                          g_rev_component_rec.from_end_item_unit_number,
                                          NULL, g_rev_component_rec.from_end_item_unit_number,
                                          g_rev_component_rec.new_from_end_item_unit_number
                                          )
                             AND NVL(bic.to_end_item_unit_number,g_rev_component_rec.from_end_item_unit_number)
                                >= g_rev_component_rec.from_end_item_unit_number
                          )
                          OR
                          ( bic.from_end_item_unit_number
                                > DECODE(g_rev_component_rec.new_from_end_item_unit_number,FND_API.G_MISS_CHAR, /* bug 8314145 */
                                          g_rev_component_rec.from_end_item_unit_number,
                                          NULL, g_rev_component_rec.from_end_item_unit_number,
                                          g_rev_component_rec.new_from_end_item_unit_number
                                          )
                             AND NVL(bic.to_end_item_unit_number,g_rev_component_rec.from_end_item_unit_number)
                                <= g_rev_component_rec.from_end_item_unit_number
                          )
                        );

        BEGIN

                FOR is_overlap_unit_num IN c_Unit_Num_Used LOOP
                        RETURN 1;
                END LOOP;


                -- else return 0 for success

                return 0;

        END Check_Unit_Number;

       /*----------------- bug:4240031 creating a new function-------------*/
       /*
        * Bug:4240031 :Adding a function to validate the case of changing the Attribute Optional.
	* If there are component operations defined for the component then the value of the
	* Attribtue Optional can not be changed from Yes to No
       */
       FUNCTION Check_Optional_For_Comp_Ops RETURN BOOLEAN
       IS
		  CURSOR c_Change_Optional IS
		  SELECT 'Exist' there_Exist
		  FROM   bom_component_operations bco,
		         bom_components_b comp
		  WHERE  bco.component_sequence_id = comp.component_sequence_id
		  AND    comp.component_sequence_id = g_rev_comp_Unexp_rec.component_sequence_id
		  AND    comp.optional = 1
		  AND    g_rev_component_rec.Optional = 2;
       BEGIN
                OPEN c_Change_Optional;
		FETCH c_Change_Optional INTO l_dummy;
		IF c_Change_Optional%FOUND THEN
		      CLOSE c_Change_Optional;
		      RETURN TRUE;
		ELSE
		      CLOSE c_Change_Optional;
		      RETURN FALSE;
		END IF;
      END Check_Optional_For_Comp_Ops;

      /*--------------------Changes for bug:4240031 end-----------------*/

	FUNCTION Check_Optional RETURN BOOLEAN
	IS
		CURSOR c_CheckOptional IS
		SELECT 'Valid' is_Valid
	  	FROM mtl_system_items assy,
	       	     mtl_system_items comp
	       WHERE assy.organization_id = g_rev_comp_Unexp_rec.organization_id
	   	 AND assy.inventory_item_id =
					g_rev_comp_Unexp_rec.revised_item_id
	   	 AND comp.organization_id = g_rev_comp_Unexp_rec.organization_id
	   	 AND comp.inventory_item_id =
					g_rev_comp_Unexp_rec.component_item_id
	   	 AND ( ( assy.bom_item_type IN ( Bom_Globals.G_PLANNING, Bom_Globals.G_STANDARD)
	                 AND g_rev_component_rec.optional = 2  /* NO */
	                )
	    	  	OR
		  	( assy.bom_item_type IN ( Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
		    	  AND assy.pick_components_flag = 'Y'
					/* PTO Model or PTO Option Class */
		          AND comp.bom_item_type = Bom_Globals.G_STANDARD
		          AND comp.replenish_to_order_flag = 'Y'
		          AND comp.base_item_id IS NULL
		          AND g_rev_component_rec.Optional = 1
		        )
		      );

	BEGIN
		-- Optional must be 2 if Bill is Planning or Standard.
		-- If the Bill is PTO Model or PTO OC and the Component
		-- is an ATO Std item with no Base Model then Optional must be 1
		-- Else it can be anything from 1 and 2.



		OPEN c_CheckOptional;
		FETCH c_CheckOptional INTO l_dummy;
		IF c_CheckOptional%FOUND THEN
			CLOSE c_CheckOptional;
			RETURN TRUE;
		ELSE
			CLOSE c_CheckOptional;
			RETURN FALSE;
		END IF;

	END Check_Optional;


	/******************************************************************
	* Function	: Check_Common_Other_Orgs
	* Return	: True if component exists in other orgs, else False
	* Purpose	: If component is being added to a bill that is being
	*		  referenced by items (bills) in other orgs
	*	          (as a common), the component must exist in those orgs
	*		  as well, with the correct item attributes.
	*		  This function will verify this and will return True
	*		  on success and false on failure.
	*********************************************************************/
	FUNCTION Check_Common_Other_Orgs
	RETURN NUMBER
	IS
  		l_other_orgs   BOOLEAN;
      l_invalid_bill NUMBER;
      l_allow_eng_comps varchar2(10) := nvl(fnd_profile.value('ENG:ALLOW_ENG_COMPS'), '2'); -- Bug 6274872
  		CURSOR bom_enabled_in_other_orgs IS
  		SELECT 1
        	FROM BOM_BILL_OF_MATERIALS bom
        	WHERE bom.source_bill_sequence_id =
	      		g_rev_comp_Unexp_rec.bill_sequence_id
          	  AND bom.organization_id <>
					g_rev_comp_Unexp_rec.organization_id
          	  AND NOT EXISTS (SELECT 1
                          	    FROM MTL_SYSTEM_ITEMS msi
                          	   WHERE msi.organization_id =
						bom.organization_id
                            	     AND msi.inventory_item_id =
					 g_rev_comp_Unexp_rec.component_item_id
                            	     AND msi.bom_enabled_flag = 'Y'  -- Uncommented for bug 5925020
			  	  );

		CURSOR in_other_orgs IS
		SELECT 1
	  	FROM BOM_BILL_OF_MATERIALS bom
         	WHERE bom.source_bill_sequence_id =
               		g_rev_comp_Unexp_rec.bill_sequence_id
           	AND bom.organization_id <> g_rev_comp_Unexp_rec.organization_id
           	AND NOT EXISTS (SELECT 1
                          	FROM MTL_SYSTEM_ITEMS msi
                          	WHERE msi.organization_id = bom.organization_id
                            	AND msi.inventory_item_id =
                                	g_rev_comp_Unexp_rec.component_item_id
			 	);

		CURSOR eng_flag_in_other_orgs
		IS
		SELECT 1
	  	FROM BOM_BILL_OF_MATERIALS bom
        	WHERE bom.source_bill_sequence_id =
              		g_rev_comp_Unexp_rec.bill_sequence_id
          	AND bom.organization_id <> g_rev_comp_Unexp_rec.organization_id
          	AND NOT EXISTS (SELECT 1
                          	FROM MTL_SYSTEM_ITEMS msi
                          	WHERE msi.organization_id = bom.organization_id
                            	AND msi.inventory_item_id =
                                	g_rev_comp_Unexp_rec.component_item_id
                            	AND msi.bom_enabled_flag = 'Y'    -- Uncommented for bug 5925020

				AND (( bom.assembly_type = 1 AND
                                   	((msi.eng_item_flag = 'N' and l_allow_eng_comps = '2' ) or l_allow_eng_comps = '1' ) -- Bug 6274872
                                  	)
                                  	OR bom.assembly_type = 2
                                     )
                          	);

    /*Cursor editable_common_bom_other_org
    IS
    SELECT bill_Sequence_id
    FROM BOM_BILL_OF_MATERIALS
    WHERE common_bill_Sequence_id <> source_bill_sequence_id
      AND source_bill_sequence_id = g_rev_comp_Unexp_rec.bill_sequence_id
      AND organization_id <> g_rev_comp_Unexp_rec.organization_id;

    Cursor valid_op_seq(p_bill_seq_id NUMBER)
    IS
    SELECT 1
    FROM BOM_OPERATION_SEQUENCES bos, BOM_OPERATIONAL_ROUTINGS bor, BOM_BILL_OF_MATERIALS bom
    WHERE (bor.routing_sequence_id = bos.routing_sequence_id
    AND bor.assembly_item_id = bom.assembly_item_id
    AND bor.organization_id = bom.organization_id
    AND nvl(bor.alternate_routing_designator, 'XXX') = nvl(bom.alternate_bom_designator, 'XXX')
    AND bom.bill_sequence_id = p_bill_seq_id
    AND bos.operation_sequence_id <> g_rev_component_rec.New_Operation_Sequence_Number)
    OR g_rev_component_rec.New_Operation_Sequence_Number = 1;*/

	BEGIN

		-- If component not in other Orgs that refer the bill as common
		-- then return an error code of 1

--		dbms_output.put_line
--		('Checking if comp exists in other ORGS when bill is common..');

		FOR c_other_orgs IN in_other_orgs LOOP
        		RETURN 1;
        	END LOOP;

--		dbms_output.put_line
--		('Checking if component is BOM enabled in other ORGS . . .');

		FOR c_bom_enabled IN bom_enabled_in_other_orgs LOOP
			RETURN 2;
		END LOOP;

--		dbms_output.put_line('Checking if component is ENG flag is compatible in other ORGS . . .');

		FOR c_eng_flag IN eng_flag_in_other_orgs LOOP
			RETURN 3;
		END LOOP;

    /*FOR c_editable_comm_bill in  editable_common_bom_other_org
    LOOP
      OPEN invalid_op_seq(c_editable_comm_bill.bill_Sequence_id);
      FETCH invalid_op_seq INTO l_invalid_Bill;
      IF invalid_op_seq%FOUND
      THEN
        RETURN 4;
      END IF;
    END LOOP;*/
    --Moved this to check_op_seq as this should be caled even for commoning withing the org.

		RETURN 0;

	END Check_Common_Other_Orgs;

	--
	-- Function Check_Prrimary Bill
	--
	FUNCTION Check_PrimaryBill
	RETURN BOOLEAN
	IS
		CURSOR c_CheckPrimary IS
		SELECT 1
	  	FROM bom_bill_of_materials
	 	WHERE assembly_item_id = g_Rev_Comp_Unexp_Rec.revised_item_id
	   	AND organization_id  = g_Rev_Comp_Unexp_Rec.Organization_Id
	   	AND NVL(alternate_bom_designator, 'NONE') = 'NONE';
	BEGIN
		FOR CheckPrimary IN c_CheckPrimary LOOP
			RETURN TRUE;
		END LOOP;

		-- If the loop does not execute then
		-- return false

		RETURN FALSE;
	END Check_PrimaryBill;

	--
	-- Function Check_RevItem_Alternate
	-- Added by MK on 11/01/2000
        -- Called from Check_Access
        --
        -- This fuction moved to Engineering space to resolove ECO dependency
        -- by MK on 12/03/00
        /*
        FUNCTION Check_RevItem_Alternate(  p_revised_item_id         IN  NUMBER
                                         , p_organization_id         IN  NUMBER
                                         , p_change_notice           IN  VARCHAR2
                                         , p_new_item_revision       IN  VARCHAR2
                                         , p_new_routing_revsion     IN  VARCHAR2
                                         , p_effective_date          IN  DATE
                                         , p_from_end_item_number    IN  VARCHAR2
                                         )
        RETURN BOOLEAN
        IS

                l_return_status BOOLEAN ;

                CURSOR c_CheckPrimary    (  p_revied_item_id   NUMBER
                                          , p_organization_id  NUMBER)
                IS

                    SELECT 1
                    FROM bom_bill_of_materials
                    WHERE assembly_item_id = p_revied_item_id
                    AND   organization_id    = p_organization_id
                    AND   NVL(alternate_bom_designator, 'NONE') = 'NONE';

                CURSOR c_Alternate_Check    (  p_revised_item_id         NUMBER
                                             , p_organization_id         NUMBER
                                             , p_change_notice           VARCHAR2
                                             , p_new_item_revision       VARCHAR2
                                             , p_new_routing_revsion     VARCHAR2
                                             , p_from_end_item_number    VARCHAR2
                                             , p_effective_date          DATE
                                             )
                IS

                    SELECT   'Rev Item is only Eco for altenate routing'
                    FROM     ENG_REVISED_ITEMS  eri
                          ,  BOM_OPERATIONAL_ROUTINGS bor
                    WHERE    bor.alternate_routing_designator  IS NOT NULL
                    AND      eri.routing_sequence_id         =   bor.routing_sequence_id(+)
                    AND      eri.routing_sequence_id        IS NOT NULL
                    AND      eri.bill_sequence_id           IS NULL
                    AND      NVL(eri.from_end_item_unit_number, 'NONE')
                                                   = NVL(p_from_end_item_number, 'NONE')
                    AND      NVL(eri.new_item_revision,'NULL') = NVL(p_new_item_revision ,'NULL')
                    AND      NVL(eri.new_routing_revision,'NULL') = NVL(p_new_routing_revsion,'NULL')
                    AND      TRUNC(eri.scheduled_date)      = TRUNC(p_effective_date)
                    AND      eri.change_notice              = p_change_notice
                    AND      eri.organization_id            = p_organization_id
                    AND      eri.revised_item_id            = p_revised_item_id ;


         BEGIN

                FOR CheckPrimary IN c_CheckPrimary(p_revised_item_id, p_organization_id)
                LOOP
                        RETURN TRUE ;
                END LOOP;


                FOR CheckRevAlt IN c_Alternate_Check
                                            (  p_revised_item_id
                                             , p_organization_id
                                             , p_change_notice
                                             , p_new_item_revision
                                             , p_new_routing_revsion
                                             , p_from_end_item_number
                                             , p_effective_date
                                             )

                LOOP
                        RETURN FALSE ;
                END LOOP;



                -- If the loop does not execute then
                -- return True`

                RETURN TRUE ;

         END ;
         */ -- Comment out by MK on 12/03/00


         /*****************************************************
         * Added by MK on 01/26/2001 for ECO New Effectivities
         * This function is copied from
         * ENG_Validate.Check_RevCmp_In_ECO_By_WO which is
         * no longer used and modified.
         *
         * Function      : Check_RevCmp_In_ECO_By_WO
         * Parameters IN : Revised Item Sequence Id
         *                 Component Item Id
         *                 Operation Seq Num
         * Returns       : True if All Jobs in ECO by Lot, WO, Cum Qty have the
         *                 Rev Component and Op Seq Number else False.
         * Purpose       : Check if Component Item, Op Seq Num exists in material requirements
         *                 info of jobs and schedules Verify the user can create a revised
         *                 component record in ECO by WO
         *****************************************************************************/
         FUNCTION Check_RevCmp_In_ECO_By_WO
             ( p_revised_item_sequence_id IN  NUMBER
             , p_rev_comp_item_id         IN  NUMBER
             , p_operation_seq_num        IN  NUMBER
             , p_organization_id          IN  NUMBER
             , p_rev_item_id              IN  NUMBER
             )

         RETURN BOOLEAN
         IS
                l_ret_status BOOLEAN := TRUE ;

                l_lot_number varchar2(30) := NULL;
                l_from_wip_entity_id NUMBER :=0;
                l_to_wip_entity_id NUMBER :=0;
                l_from_cum_qty  NUMBER :=0;


                CURSOR  l_check_lot_num_csr ( p_lot_number        VARCHAR2
                                            , p_rev_comp_item_id  NUMBER
                                            , p_operation_seq_num NUMBER
                                            , p_organization_id   NUMBER
                                            , p_rev_item_id       NUMBER )
                IS
                   SELECT 'Cmp does not exist'
                   FROM   SYS.DUAL
                   WHERE  EXISTS (SELECT  NULL
                                  FROM    WIP_DISCRETE_JOBS  wdj
                                  WHERE  (wdj.status_type <> 1
                                           OR
                                           NOT EXISTS(SELECT NULL
                                                      FROM   WIP_REQUIREMENT_OPERATIONS wro
                                                      WHERE  (wro.operation_seq_num = p_operation_seq_num
                                                              OR p_operation_seq_num = 1)
                                                      AND    wro.inventory_item_id = p_rev_comp_item_id
                                                      AND    wro.wip_entity_id     = wdj.wip_entity_id)
                                          )
                                 AND      wdj.lot_number = p_lot_number
                                 AND      wdj.organization_id = p_organization_id
                                 AND      wdj.primary_item_id = p_rev_item_id
                   ) ;

                CURSOR  l_check_wo_csr (  p_from_wip_entity_id NUMBER
                                        , p_to_wip_entity_id   NUMBER
                                        , p_rev_comp_item_id   NUMBER
                                        , p_operation_seq_num  NUMBER
                                        , p_organization_id    NUMBER )
                IS
                   SELECT 'Cmp does not exist'
                   FROM   SYS.DUAL
                   WHERE  EXISTS (SELECT  NULL
                                  FROM    WIP_DISCRETE_JOBS  wdj
                                        , WIP_ENTITIES       we
                                        , WIP_ENTITIES       we1
                                        , WIP_ENTITIES       we2
                                  WHERE   (wdj.status_type <> 1
                                           OR
                                           NOT EXISTS (SELECT NULL
                                                       FROM   WIP_REQUIREMENT_OPERATIONS wro
                                                       WHERE  (wro.operation_seq_num = p_operation_seq_num
                                                               OR p_operation_seq_num = 1)
                                                       AND    wro.inventory_item_id = p_rev_comp_item_id
                                                       AND    wro.wip_entity_id     = wdj.wip_entity_id)
                                          )
                                  AND     wdj.wip_entity_id = we.wip_entity_id
                                  AND     we.organization_Id =  p_organization_id
                                  AND     we.wip_entity_name >= we1.wip_entity_name
                                  AND     we.wip_entity_name <= we2.wip_entity_name
                                  AND     we1.wip_entity_id = p_from_wip_entity_id
                                  AND     we2.wip_entity_id = NVL(p_to_wip_entity_id, p_from_wip_entity_id)
                                  ) ;


               CURSOR  l_check_cum_csr (  p_from_wip_entity_id NUMBER
                                        , p_rev_comp_item_id   NUMBER
                                        , p_operation_seq_num  NUMBER)
                IS
                   SELECT 'Cmp does not exist'
                   FROM   SYS.DUAL
                   WHERE  EXISTS (SELECT  NULL
                                  FROM    WIP_DISCRETE_JOBS  wdj
                                  WHERE   (wdj.status_type <> 1
                                           OR
                                           NOT EXISTS(SELECT NULL
                                                      FROM   WIP_REQUIREMENT_OPERATIONS wro
                                                      WHERE  (wro.operation_seq_num = p_operation_seq_num
                                                              OR p_operation_seq_num = 1)
                                                      AND    wro.inventory_item_id = p_rev_comp_item_id
                                                      AND    wro.wip_entity_id     = wdj.wip_entity_id)
                                          )
                                  AND     wdj.wip_entity_id = p_from_wip_entity_id
                                  ) ;

             BEGIN


                l_lot_number := BOM_Globals.Get_Lot_Number;
                l_from_wip_entity_id := BOM_Globals.Get_From_Wip_Entity_Id;
                l_to_wip_entity_id := BOM_Globals.Get_To_Wip_Entity_Id;
                l_from_cum_qty := BOM_Globals.Get_From_Cum_Qty;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check if the rev component is valid in Eco by Prod. . .' );
    Error_Handler.Write_Debug('Lot Number in parent rev item : ' || l_lot_number );
    Error_Handler.Write_Debug('From WIP Entity Id  in parent rev item : ' || to_char(l_from_wip_entity_id) );
    Error_Handler.Write_Debug('To WIP Entity Id  in parent rev item : ' || to_char(l_to_wip_entity_id) );
    Error_Handler.Write_Debug('Cum Qty in parent rev item : ' || to_char(l_from_cum_qty) );
END IF;


                -- Check if comp exists in ECO by Lot
                IF   l_lot_number         IS NOT NULL
                AND  l_from_wip_entity_id IS NULL
                AND  l_to_wip_entity_id   IS NULL
                AND  l_from_cum_qty       IS NULL
                THEN

                      FOR l_lot_num_rec IN l_check_lot_num_csr
                                        ( p_lot_number        => l_lot_number
                                        , p_rev_comp_item_id  => p_rev_comp_item_id
                                        , p_operation_seq_num => p_operation_seq_num
                                        , p_organization_id   => p_organization_id
                                        , p_rev_item_id       => p_rev_item_id
                                        )
                      LOOP

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('In Eco by Lot Number, this rev component is invalid. . .' );
END IF;
                          l_ret_status  := FALSE ;
                      END LOOP ;


                -- Check if comp exists  in ECO by Cum
                ELSIF  l_lot_number         IS NULL
                AND    l_from_wip_entity_id IS NOT NULL
                AND    l_to_wip_entity_id   IS NULL
                AND    l_from_cum_qty       IS NOT NULL
                THEN

                      FOR l_cum_rec IN l_check_cum_csr
                                        ( p_from_wip_entity_id => l_from_wip_entity_id
                                        , p_rev_comp_item_id   => p_rev_comp_item_id
                                        , p_operation_seq_num  => p_operation_seq_num )
                      LOOP

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('In Eco by Cum Qty, this rev component is invalid. . .' );
END IF;

                          l_ret_status  := FALSE ;
                      END LOOP ;

                -- Check if comp exists  in ECO by WO
                ELSIF  l_lot_number         IS NULL
                AND    l_from_wip_entity_id IS NOT NULL
                AND    l_from_cum_qty       IS NULL
                THEN

                      FOR l_wo_rec IN l_check_wo_csr
                                        ( p_from_wip_entity_id => l_from_wip_entity_id
                                        , p_to_wip_entity_id   => l_to_wip_entity_id
                                        , p_rev_comp_item_id   => p_rev_comp_item_id
                                        , p_operation_seq_num  => p_operation_seq_num
                                        , p_organization_id    => p_organization_Id   )
                      LOOP

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('In Eco by range work order, this rev component is invalid. . .' );
END IF;

                          l_ret_status  := FALSE ;
                      END LOOP ;

                ELSIF  l_lot_number         IS NULL
                AND    l_from_wip_entity_id IS NULL
                AND    l_to_wip_entity_id   IS NULL
                AND    l_from_cum_qty       IS NULL
                THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Parent revised item is not Eco by production. . .' );
END IF;

                      NULL ;

                   --  ELSE
                   --     l_ret_status  := FALSE ;
                   --

                END IF ;

                RETURN l_ret_status ;

         END Check_RevCmp_In_ECO_By_WO ;


	/******************** Local Procedures End **********************/


	/******************************************************************
        * Procedure     : Set_Item_Attributes
        * Purpose       : Set the global attribute flags. This procedure is
        *                 called ONLY by the ECO FORM. The open interfaces
        *                 will perform this step in the Entity validation
        *                 procedure.
        **********************************************************************/

	PROCEDURE Set_Item_Attributes
	( p_RI_bom_item_type            NUMBER
	, p_RC_bom_item_type            NUMBER
	, p_RC_replenish_to_order_flag  CHAR
	, p_RI_replenish_to_order_flag  CHAR
	, p_RC_pick_components_flag     CHAR
	, p_RI_pick_components_flag     CHAR
	, p_RC_base_item_id             NUMBER
	, p_RC_ato_forecast_control     NUMBER
	, p_RI_base_item_id             NUMBER
	, p_RC_eng_item_flag            CHAR
	, p_RI_eng_item_flag            CHAR
	, p_RC_atp_components_flag      CHAR
	, p_RI_atp_components_flag      CHAR
	, p_RC_atp_flag                 CHAR
	, p_RI_wip_supply_type          NUMBER
	, p_RC_wip_supply_type          NUMBER
	, p_RI_bom_enabled_flag         CHAR
	, p_RC_bom_enabled_flag         CHAR
	)
	IS
	BEGIN

		IF p_RI_base_item_id IS NULL OR
		   p_RI_base_item_id = 0
		THEN
			g_Assy_Config := 'N';
		ELSE
			g_Assy_Config := 'Y';
		END IF;

		IF p_RC_base_item_id IS NULL OR
                   p_RC_base_item_id = 0
                THEN
                        g_Comp_Config := 'N';
                ELSE
                        g_Comp_Config := 'Y';
                END IF;

                g_Assy_Item_Type := p_RI_bom_item_type;
		g_Assy_PTO_flag := p_RI_pick_components_flag;
                g_Assy_ATO_flag := p_RI_replenish_to_order_flag;
                g_Assy_Wip_Supply_Type := p_RI_wip_supply_type;
                g_Assy_Eng_Flag := p_RI_eng_item_flag;
                g_Assy_ATP_Comp_flag := p_RI_atp_components_flag;
                g_Assy_Bom_Enabled_flag := p_RI_bom_enabled_flag;
                g_Comp_Item_Type := p_RC_bom_item_type;
                g_Comp_PTO_flag := p_RC_pick_components_flag;
                g_Comp_ATO_flag := p_RC_replenish_to_order_flag;
                g_Comp_Wip_Supply_Type := p_RC_wip_supply_type;
                g_Comp_Eng_Flag := p_RC_eng_item_flag;
                g_Comp_ATP_Comp_flag := p_RC_atp_components_flag;
                g_Comp_ATP_Check_flag := p_RC_atp_flag;
                g_Comp_Bom_Enabled_flag := p_RC_bom_enabled_flag;
                g_Comp_ATO_Forecast_Control := p_RC_ato_forecast_control;
	END Set_Item_Attributes;





FUNCTION Dereferenced_Bom(p_bill_sequence_id NUMBER)
Return boolean
IS
l_deref_bom varchar2(1);
BEGIN
	SELECT 'Y' into l_deref_bom
	FROM BOM_BILL_OF_MATERIALS
	WHERE bill_sequence_id =  common_bill_sequence_id
	 AND bill_sequence_id <> nvl(source_bill_sequence_id, common_bill_sequence_id)
	 AND bill_sequence_id = p_bill_sequence_id;
	IF l_deref_bom = 'Y' THEN
	  Return true;
  END IF;
  Return false;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  return false;
END;


FUNCTION Is_Bill_Common(p_bill_sequence_id IN NUMBER)
RETURN Boolean
IS
  l_dummy VARCHAR2(1);
BEGIN
  SELECT 'Y'
  INTO l_dummy
  FROM BOM_STRUCTURES_B
  WHERE BILL_SEQUENCE_ID = p_bill_sequence_id
  AND BILL_SEQUENCE_ID <> SOURCE_BILL_SEQUENCE_ID;
  Return true;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return false;
END;



FUNCTION valid_common_bom_change( p_rev_component_rec      IN  Bom_Bo_Pub.Rev_Component_Rec_Type
                                 , p_Old_Rev_Component_Rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type)
RETURN boolean
IS
BEGIN
	IF p_Old_Rev_Component_Rec.Organization_Code <> p_rev_component_rec.Organization_Code
		OR p_Old_Rev_Component_Rec.Revised_Item_Name <> p_rev_component_rec.Revised_Item_Name
		--OR p_Old_Rev_Component_Rec.New_revised_Item_Revision  <> p_rev_component_rec.New_revised_Item_Revision
		--OR p_Old_Rev_Component_Rec.Start_Effective_Date      <> p_rev_component_rec.Start_Effective_Date
		OR p_Old_Rev_Component_Rec.New_Effectivity_Date      <> p_rev_component_rec.New_Effectivity_Date
		OR p_Old_Rev_Component_Rec.Disable_Date        <> p_rev_component_rec.Disable_Date
--		OR p_Old_Rev_Component_Rec.Operation_Sequence_Number     <> p_rev_component_rec.Operation_Sequence_Number
		OR p_Old_Rev_Component_Rec.Component_Item_Name       <> p_rev_component_rec.Component_Item_Name
		OR p_Old_Rev_Component_Rec.Alternate_BOM_Code        <> p_rev_component_rec.Alternate_BOM_Code
		--OR p_Old_Rev_Component_Rec.ACD_Type          <> p_rev_component_rec.ACD_Type
		OR p_Old_Rev_Component_Rec.Old_Effectivity_Date      <> p_rev_component_rec.Old_Effectivity_Date
		OR p_Old_Rev_Component_Rec.Old_Operation_Sequence_Number   <> p_rev_component_rec.Old_Operation_Sequence_Number
		OR p_Old_Rev_Component_Rec.New_Operation_Sequence_Number   <> p_rev_component_rec.New_Operation_Sequence_Number
		OR p_Old_Rev_Component_Rec.Item_Sequence_Number      <> p_rev_component_rec.Item_Sequence_Number
		OR p_Old_Rev_Component_Rec.Quantity_Per_Assembly     <> p_rev_component_rec.Quantity_Per_Assembly
		OR p_Old_Rev_Component_Rec.Inverse_Quantity          <> p_rev_component_rec.Inverse_Quantity
		OR p_Old_Rev_Component_Rec.Planning_Percent        <> p_rev_component_rec.Planning_Percent
		OR p_Old_Rev_Component_Rec.Projected_Yield       <> p_rev_component_rec.Projected_Yield
--		OR p_Old_Rev_Component_Rec.Include_In_Cost_Rollup  <> p_rev_component_rec.Include_In_Cost_Rollup
		OR p_Old_Rev_Component_Rec.So_Basis            <> p_rev_component_rec.So_Basis
		OR p_Old_Rev_Component_Rec.Optional            <> p_rev_component_rec.Optional
		OR p_Old_Rev_Component_Rec.Mutually_Exclusive  <> p_rev_component_rec.Mutually_Exclusive
		OR p_Old_Rev_Component_Rec.Check_Atp           <> p_rev_component_rec.Check_Atp
		OR p_Old_Rev_Component_Rec.Shipping_Allowed    <> p_rev_component_rec.Shipping_Allowed
		OR p_Old_Rev_Component_Rec.Required_To_Ship    <> p_rev_component_rec.Required_To_Ship
		OR p_Old_Rev_Component_Rec.Required_For_Revenue<> p_rev_component_rec.Required_For_Revenue
		OR p_Old_Rev_Component_Rec.Include_On_Ship_Docs <> p_rev_component_rec.Include_On_Ship_Docs
		OR p_Old_Rev_Component_Rec.Quantity_Related  <> p_rev_component_rec.Quantity_Related
		OR p_Old_Rev_Component_Rec.Minimum_Allowed_Quantity      <> p_rev_component_rec.Minimum_Allowed_Quantity
		OR p_Old_Rev_Component_Rec.Maximum_Allowed_Quantity      <> p_rev_component_rec.Maximum_Allowed_Quantity
		OR p_Old_Rev_Component_Rec.comments        <> p_rev_component_rec.comments
		OR p_Old_Rev_Component_Rec.cancel_comments   <> p_rev_component_rec.cancel_comments
		OR p_Old_Rev_Component_Rec.Attribute_category   <> p_rev_component_rec.Attribute_category
		OR p_Old_Rev_Component_Rec.Attribute1    <> p_rev_component_rec.Attribute1
		OR p_Old_Rev_Component_Rec.Attribute2    <> p_rev_component_rec.Attribute2
		OR p_Old_Rev_Component_Rec.Attribute3     <> p_rev_component_rec.Attribute3
		OR p_Old_Rev_Component_Rec.Attribute4        <> p_rev_component_rec.Attribute4
		OR p_Old_Rev_Component_Rec.Attribute5     <> p_rev_component_rec.Attribute5
		OR p_Old_Rev_Component_Rec.Attribute6    <> p_rev_component_rec.Attribute6
		OR p_Old_Rev_Component_Rec.Attribute7    <> p_rev_component_rec.Attribute7
		OR p_Old_Rev_Component_Rec.Attribute8    <> p_rev_component_rec.Attribute8
		OR p_Old_Rev_Component_Rec.Attribute9     <> p_rev_component_rec.Attribute9
		OR p_Old_Rev_Component_Rec.Attribute10   <> p_rev_component_rec.Attribute10
		OR p_Old_Rev_Component_Rec.Attribute11   <> p_rev_component_rec.Attribute11
		OR p_Old_Rev_Component_Rec.Attribute12   <> p_rev_component_rec.Attribute12
		OR p_Old_Rev_Component_Rec.Attribute13       <> p_rev_component_rec.Attribute13
		OR p_Old_Rev_Component_Rec.Attribute14     <> p_rev_component_rec.Attribute14
		OR p_Old_Rev_Component_Rec.Attribute15      <> p_rev_component_rec.Attribute15
		OR p_Old_Rev_Component_Rec.From_End_Item_Unit_Number    <> p_rev_component_rec.From_End_Item_Unit_Number
		OR p_Old_Rev_Component_Rec.Old_From_End_Item_Unit_Number  <> p_rev_component_rec.Old_From_End_Item_Unit_Number
		OR p_Old_Rev_Component_Rec.New_From_End_Item_Unit_Number   <> p_rev_component_rec.New_From_End_Item_Unit_Number
		OR p_Old_Rev_Component_Rec.To_End_Item_Unit_Number        <> p_rev_component_rec.To_End_Item_Unit_Number
		OR p_Old_Rev_Component_Rec.New_Routing_Revision      <> p_rev_component_rec.New_Routing_Revision
		OR p_Old_Rev_Component_Rec.Enforce_Int_Requirements  <> p_rev_component_rec.Enforce_Int_Requirements
		OR p_Old_Rev_Component_Rec.Auto_Request_Material     <> p_rev_component_rec.Auto_Request_Material
		OR p_Old_Rev_Component_Rec.Suggested_Vendor_Name     <> p_rev_component_rec.Suggested_Vendor_Name
		OR p_Old_Rev_Component_Rec.Unit_Price           <> p_rev_component_rec.Unit_Price
		OR p_Old_Rev_Component_Rec.Original_System_Reference     <> p_rev_component_rec.Original_System_Reference
	THEN return false;
	END IF;
	RETURN true;
END;



--Bug 8874286 begin
FUNCTION Get_Structure_Type_Name( p_bill_sequence_id IN NUMBER)
  RETURN VARCHAR2
  IS
  l_structure_type_name      VARCHAR2(30) := NULL;

  BEGIN
    SELECT STRUCTURE_TYPE_NAME
    INTO
    l_structure_type_name
    FROM BOM_STRUCTURE_TYPES_B STRUCT_TYPE,
    BOM_STRUCTURES_B  BOM_STRUCT
    WHERE  BOM_STRUCT.STRUCTURE_TYPE_ID = STRUCT_TYPE.STRUCTURE_TYPE_ID
    AND BOM_STRUCT.BILL_SEQUENCE_ID = p_bill_sequence_id;

    RETURN l_structure_type_name;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;

  END;
--Bug 8874286 end


	/******************************************************************
	* Procedure	: Check_Entity
	* Parameters IN : Revised component exposed column record
	*		  Revised component unexposed column record
	*		  Revised component old exposed column record
	*		  Revised component old unexposed column record
	*		  Control record
	* Parameters OUT: Mesg _Token_Tbl
	*		  Return Status
	* Purpose	: Check_Entity validate the entity for the correct
	*		  business logic. It will verify the values by running
	*		  checks on inter-dependent columns.
	*		  It will also verify that changes in one column value
	*		  does not invalidate some other columns.
	**********************************************************************/
	PROCEDURE Check_Entity
	( x_return_status	  IN OUT NOCOPY  VARCHAR2
	, x_Mesg_Token_Tbl	  IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
	, p_rev_component_rec  	   IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	, p_Rev_Comp_Unexp_Rec	   IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	, p_control_rec            IN  BOM_BO_PUB.Control_Rec_Type
                                   := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
	, p_Old_Rev_Component_Rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	, p_Old_Rev_Comp_Unexp_Rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	)
	IS
		l_return_status		VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
		l_bill_sequence_id      NUMBER;
		l_processed		BOOLEAN;
		l_result		NUMBER;
		l_Err_Text		VARCHAR2(2000);
		l_bom_item_type		NUMBER;
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_is_comp_unit_Controlled BOOLEAN := FALSE;
		l_is_item_unit_controlled BOOLEAN := FALSE;
		l_debug_error_mesg       VARCHAR2(2000);
		l_new_compare_date       DATE;
                l_new_op_seq_num         NUMBER; --added for bug 9920911
	        l_total_rds              NUMBER;
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
    l_Structure_Type_Name    VARCHAR2(30);


		CURSOR c_RefDesgs IS
		SELECT count(component_sequence_id) number_of_desgs
  		FROM bom_reference_designators
 		WHERE component_sequence_id =
			p_rev_comp_unexp_rec.component_sequence_id;

		CURSOR c_NewBill IS
		SELECT revised_item_id, change_notice, organization_id
	  	FROM eng_revised_items
	 	WHERE revised_item_sequence_id =
	       		p_rev_comp_Unexp_rec.revised_item_sequence_id;

		CURSOR CheckForNew IS
       		SELECT 'Valid'
         	FROM eng_revised_items eri
        	WHERE eri.revised_item_sequence_id =
	      		p_rev_comp_Unexp_rec.revised_item_sequence_id
          	AND eri.bill_sequence_id         IS NULL
          	AND NOT EXISTS (SELECT 1
                            	FROM bom_bill_of_materials bom
                           	WHERE bom.bill_sequence_id =
				 	p_rev_comp_Unexp_rec.bill_sequence_id
			  	);

		item_num_for_bill number := 0;
		CURSOR c_ItemDateNum IS
		SELECT 'Valid'
          	FROM BOM_inventory_components
         	WHERE item_num = p_rev_component_rec.item_sequence_number
           	AND component_item_id <> p_rev_comp_unexp_rec.component_item_id
		AND trunc(effectivity_date) <=
				trunc(p_rev_component_rec.start_effective_date)
            	AND nvl(trunc(disable_date),
		        trunc(p_rev_component_rec.start_effective_date) + 1) >=
                		trunc(p_rev_component_rec.start_effective_date)
		AND bill_sequence_id = p_Rev_Comp_Unexp_rec.bill_sequence_id;

                CURSOR c_ItemUnitNum IS
                SELECT 'Valid'
                FROM BOM_inventory_components
                WHERE item_num = p_rev_component_rec.item_sequence_number
                AND component_item_id <> p_rev_comp_unexp_rec.component_item_id
                AND disable_date is NULL
                AND from_end_item_unit_number <=
                        p_rev_component_rec.from_end_item_unit_number
                AND NVL(to_end_item_unit_number,
                        p_rev_component_rec.from_end_item_unit_number) >=
                                p_rev_component_rec.from_end_item_unit_number
                AND bill_sequence_id = p_Rev_Comp_Unexp_rec.bill_sequence_id;

		l_bom_ifce_key VARCHAR2(80);

		-------------------------------------------------
		-- Added since quantity cannot be fractional
		-- if OE is installed and revised item is
		-- ATO/PTO.

		-- Fix made by AS 04/27/98
		-- Bug 651689
		-------------------------------------------------
		Is_OE_Installed VARCHAR2(1) := 'N';

                -- Modified by MK on 11/13/00
		CURSOR c_OE_installed IS
		SELECT distinct 'I'
	  	FROM fnd_product_installations
	 	-- WHERE application_id = 300  -- Order Entry
                WHERE  application_id = 660 -- ONT: Order Management
	   	AND status = 'I';

		Is_Item_ATO VARCHAR2(1) := 'N';
		Is_Item_PTO VARCHAR2(1) := 'N';

		CURSOR c_ATO_PTO IS
		SELECT replenish_to_order_flag, pick_components_flag
	  	FROM mtl_system_items
	 	WHERE inventory_item_id =
			p_rev_comp_unexp_rec.revised_item_id
	   	AND organization_id = p_rev_comp_unexp_rec.organization_id;

		Cursor Unit_Controlled_Item IS
        	SELECT effectivity_control
          	FROM mtl_system_items
         	WHERE inventory_item_id = p_rev_comp_unexp_rec.revised_item_id
           	AND organization_id   = p_rev_comp_unexp_rec.organization_id;

		l_bill_to_end_number VARCHAR2(30);
		CURSOR c_To_End_Item_Number IS
        	SELECT To_End_Item_Unit_Number
          	FROM BOM_Inventory_Components
         	WHERE component_sequence_id =
                	g_rev_comp_unexp_rec.old_component_sequence_id;


               -- Added by MK on 02/02/2001
               -- Form has this validation LOV for Old Operation Sequence Number
               l_eco_for_production NUMBER ;

               CURSOR old_comp_csr (p_old_comp_seq_id NUMBER ,
                                    p_eco_for_production NUMBER)
               IS
                  SELECT 'Old Comp is invalid'
                  FROM   SYS.DUAL
                  WHERE  NOT EXISTS ( SELECT NULL
                                      FROM    BOM_INVENTORY_COMPONENTS ic
                                      WHERE   /*bug 11786826 comment this.  TRUNC(ic.effectivity_date) <=
                                                TRUNC(p_rev_component_rec.start_effective_date)
                                      AND   */
				        NVL(ic.disable_date,
                                                  TRUNC(p_rev_component_rec.start_effective_date)+1)
                                                  > p_rev_component_rec.start_effective_date
                                      AND     NVL(ic.disable_date , SYSDATE + 1) > SYSDATE
                                      AND     NVL(ic.revised_item_sequence_id, -999)
                                                  <> NVL(p_rev_comp_unexp_rec.revised_item_sequence_id, -100)
                                      AND     NOT EXISTS (SELECT NULL
                                                          FROM  bom_inventory_components ic2
                                                          WHERE ic2.revised_item_sequence_id
                                                                = NVL(p_rev_comp_unexp_rec.revised_item_sequence_id,
                                                                      -888)
                                                          AND decode(ic2.implementation_date,
                                                                     null,
                                                                     ic2.old_component_sequence_id,
                                                                     ic2.component_sequence_id) =
                                                              decode(ic.implementation_date,
                                                                     null,
                                                                     ic.old_component_sequence_id,
                                                                     ic.component_sequence_id)
                                                          AND ic2.component_sequence_id <>
                                                                       p_rev_comp_unexp_rec.component_sequence_id
                                                          )
                                      AND    ((    p_eco_for_production = 2
                                               AND NVL(ic.eco_for_production, 2) <> 1 )
                                               OR (p_eco_for_production = 1
                                                   AND ic.implementation_date IS NOT NULL
                                                   )
                                              )
                                      AND ic.component_sequence_id = p_old_comp_seq_id
                                    ) ;

	BEGIN

        g_rev_component_rec := p_rev_component_rec;
        g_Rev_Comp_Unexp_Rec := p_Rev_Comp_Unexp_Rec;

/*          5134934           */
  -- Basis type cannot be Lot if there are existing Reference Desigantors.
  IF (p_rev_component_rec.transaction_type = Bom_Globals.G_OPR_UPDATE) THEN

    If(p_rev_component_rec.Basis_type = 2) THEN
        select count(*) into l_total_rds from bom_reference_designators
        where nvl(p_rev_component_rec.acd_type,1) <>3 and component_sequence_id=p_Rev_Comp_Unexp_Rec.component_sequence_id;
     IF(l_total_rds <>0) THEN
         l_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
       l_Token_Tbl(1).Token_Value := p_rev_component_rec.component_item_name;
       Error_Handler.Add_Error_Token
          (  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_message_name       => 'BOM_LOT_BASED_RDS'
            , p_Token_Tbl          => l_Token_Tbl
          );
          l_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END IF;
END IF;



IF Bom_Globals.Get_Debug = 'Y'
THEN
  Error_Handler.Write_Debug('Performing Revised component Entity Validation. . .');
END IF;

    l_is_comp_unit_controlled := BOM_GLOBALS.Get_Unit_Controlled_Component;
    l_is_item_unit_controlled := BOM_GLOBALS.Get_Unit_Controlled_Item;

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Checked if revised item is unit controlled. . .');
   Error_Handler.Write_Debug('Org id: ' || to_char(g_rev_Comp_Unexp_Rec.Organization_Id));
   Error_Handler.Write_Debug('Item id: ' || to_char(g_rev_Comp_Unexp_Rec.revised_item_id));
   Error_Handler.Write_Debug('Comp id: ' || to_char(g_rev_Comp_Unexp_Rec.Component_item_id));
   Error_Handler.Write_Debug('Trans type: ' || g_rev_component_rec.transaction_type);
END IF;

    -- First Query all the attributes for the Assembly item and
    -- component item.
        SELECT  assy.bom_item_type,
                assy.pick_components_flag,
                assy.replenish_to_order_flag,
                assy.wip_supply_type,
                DECODE(NVL(assy.base_item_id, 0), 0 , 'N', 'Y'),
		assy.eng_item_flag,
                assy.atp_components_flag,
                assy.atp_flag,
		assy.bom_enabled_flag,
                assy.effectivity_control,                      --2044133
                assy.tracking_quantity_ind,
                comp.bom_item_type,
                comp.pick_components_flag,
                comp.replenish_to_order_flag,
                comp.wip_supply_type,
                DECODE(NVL(comp.base_item_id, 0), 0 , 'N', 'Y'),
                comp.eng_item_flag,
                comp.atp_components_flag,
                comp.atp_flag,
		comp.bom_enabled_flag,
		comp.ato_forecast_control,
                comp.effectivity_control,                       --2044133
                comp.tracking_quantity_ind
          INTO  g_Assy_Item_Type,
                g_Assy_PTO_flag,
                g_Assy_ATO_flag,
                g_Assy_Wip_Supply_Type,
                g_Assy_Config,
		g_Assy_Eng_Flag,
                g_Assy_ATP_Comp_flag,
                g_Assy_ATP_Check_flag,
		g_Assy_Bom_Enabled_flag,
                g_Assy_Effectivity_Control,                   --2044133
                G_Assy_Tracking_Quantity_Ind,
                g_Comp_Item_Type,
                g_Comp_PTO_flag,
                g_Comp_ATO_flag,
                g_Comp_Wip_Supply_Type,
                g_Comp_Config,
                g_Comp_Eng_Flag,
                g_Comp_ATP_Comp_flag,
                g_Comp_ATP_Check_flag,
		g_Comp_Bom_Enabled_flag,
		g_Comp_ATO_Forecast_Control,
                g_Comp_Effectivity_Control,                    --2044133
                G_Comp_Tracking_Quantity_Ind
          FROM  mtl_system_items assy,
                mtl_system_items comp
         WHERE  assy.organization_id   = g_rev_Comp_Unexp_Rec.Organization_Id
           AND  assy.inventory_item_id = g_rev_Comp_Unexp_Rec.revised_item_id
           AND  comp.organization_id   = g_rev_Comp_Unexp_Rec.Organization_Id
           AND  comp.inventory_item_id = g_rev_Comp_Unexp_Rec.Component_item_id;
-- dbms_output.put_line('Queried all assembly and component attributes. . .');


	--
	-- Set the assembly Type of the Assembly
	--

	IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
	THEN
	  select assembly_type
	  into g_Assy_Assembly_Type
	  --bug: 4161794. Introduced new global variable to hold value of assembly type
	  -- of the header.
	  from bom_bill_of_materials
	  where bill_sequence_id = p_rev_comp_Unexp_rec.bill_sequence_id;
	END IF;

       --if an ATO item was added in a kit when the related profile was set, you cannot
       --update or delete the component once the profile is unset
       --BOM ER #9946990 changes (begin)

       IF
        p_rev_component_rec.Transaction_Type IN (BOM_GLOBALS.G_OPR_UPDATE, BOM_Globals.G_OPR_DELETE) AND
        nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 AND
        g_Assy_Item_Type = Bom_Globals.G_STANDARD AND
        g_Assy_PTO_Flag  = 'Y' AND
        g_comp_ATO_Flag = 'Y' AND
        g_comp_PTO_Flag = 'N' AND
        g_Comp_Item_Type = Bom_Globals.G_STANDARD

        THEN

        Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_KIT_COMP_PRF_NOT_SET'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
        l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;



        --if a mandatory ATO item was added in a pto model when the related profile was set, you cannot
       --update or delete the component once the profile is unset
       --BOM ER #9946990 changes (begin)
       IF
        p_rev_component_rec.Transaction_Type IN (BOM_GLOBALS.G_OPR_UPDATE, BOM_Globals.G_OPR_DELETE) AND
        nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 AND
        g_Assy_Item_Type = Bom_Globals.G_MODEL AND
        g_Assy_PTO_Flag  = 'Y' AND
        g_comp_ATO_Flag = 'Y' AND
        g_comp_PTO_Flag = 'N' AND
        g_Comp_Item_Type = Bom_Globals.G_STANDARD AND
        g_Rev_Component_Rec.optional = 2

        THEN
        Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_MODEL_COMP_PRF_NOT_SET'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
         l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

       --BOM ER #9946990 changes (end)

       --BOM ER #9946990 changes(begin)
       --if user is trying to disable a mandatory ato component in a pto model when related bom profile is
       --not set, then throw error

        IF BOM_Globals.Get_Bo_Identifier = BOM_Globals.G_ECO_BO AND
        p_rev_component_rec.Transaction_Type = BOM_Globals.G_OPR_CREATE AND
        NVL(p_rev_component_rec.acd_type, 1) in (2, 3) AND --had to include acd_type 2 in here since while updating the record optional flag may not be populated or may not undergo a change
        nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 AND
        g_Assy_Item_Type = Bom_Globals.G_MODEL AND
        g_Assy_PTO_Flag  = 'Y' AND
        g_comp_ATO_Flag = 'Y' AND
        g_comp_PTO_Flag = 'N' AND
        g_Comp_Item_Type = Bom_Globals.G_STANDARD AND
        nvl(g_Rev_Component_Rec.optional,1) = 2

        THEN
        Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_MODEL_COMP_PRF_NOT_SET'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
         l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        --BOM ER #9946990 changes (end)
	--
	-- Set the 1st token of Token Table to Revised Component value
	--
	g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
	g_Token_Tbl(1).Token_Value := p_rev_component_rec.component_item_name;

        -- The ECO can be updated but a warning needs to be generated and
        -- scheduled revised items need to be update to Open
        -- and the ECO status need to be changed to Not Submitted for Approval


	IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
	THEN
        	BOM_GLOBALS.Check_Approved_For_Process
		(p_change_notice    => p_rev_component_rec.eco_name,
         	 p_organization_id  => p_rev_comp_unexp_rec.organization_id,
         	 x_processed        => l_processed,
         	 x_err_text         => l_err_text
         	);
        	IF l_processed = TRUE
        	THEN
        	-- If the above process returns true then set the ECO approval.
        	BEGIN
        		BOM_GLOBALS.Set_Request_For_Approval
			(p_change_notice 	=>
			 p_rev_component_rec.eco_name,
                 	 p_organization_id 	=>
			 p_rev_comp_unexp_rec.organization_id,
                 	 x_err_text          	=> l_err_text
                 	);

        	EXCEPTION
                	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                              l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	END;
        	END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Eco Status . . .' || l_return_status); END IF;

                -- Added by MK on 01/26/2001 for ECO New Effectivities
                -- Verify the ECO Effectivity, If ECO by WO, Lot Num, Or Cum Qty, then
                -- Check if the component exists in the WO or Lot Num.
                --
                IF   p_rev_component_rec.transaction_type = BOM_Globals.G_OPR_CREATE
                AND  p_rev_component_rec.acd_type  IN (2 , 3) -- Change or Disable
                THEN

                   IF NOT Check_RevCmp_In_ECO_By_WO
                    ( p_revised_item_sequence_id => p_rev_comp_unexp_rec.revised_item_sequence_id
                    , p_rev_comp_item_id         => p_rev_comp_unexp_rec.component_item_id
                    , p_operation_seq_num        => p_rev_component_rec.old_operation_sequence_number
                    , p_organization_id          => p_rev_comp_unexp_rec.organization_id
                    , p_rev_item_id              => p_rev_comp_unexp_rec.revised_item_id
                    )
                   THEN
                      g_token_tbl.delete;
                      g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                      g_token_tbl(1).token_value := p_rev_component_rec.revised_item_name;
		      g_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
                      g_token_tbl(2).token_value :=
                                        g_rev_component_rec.component_item_name;

                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_CMP_RIT_ECO_WO_EFF_INVALID'
                       , p_mesg_token_tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_token_tbl      => g_token_tbl
                      );
                      l_return_status := FND_API.G_RET_STS_ERROR;
	              g_token_tbl.delete;
	              g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
	              g_Token_Tbl(1).Token_Value := p_rev_component_rec.component_item_name;
                   END IF ;
IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check if the rev component is valid in Eco by Prod. . .' || l_return_status);
END IF;
                END IF ;


	END IF; -- validations called by only ECO BO
	-- To End Item Unit Number must be greater than or equal to
	-- From End Item Unit Number

	IF (p_rev_component_rec.To_End_Item_Unit_Number IS NOT NULL AND
	    p_rev_component_rec.To_End_Item_Unit_Number <> FND_API.G_MISS_CHAR AND
	    p_rev_component_rec.From_End_Item_Unit_Number IS NOT NULL AND
	    p_rev_component_rec.From_End_Item_Unit_Number <> FND_API.G_MISS_CHAR
	    )
	    AND
	    (p_rev_component_rec.From_End_Item_Unit_Number > p_rev_component_rec.To_End_Item_Unit_Number)
	THEN
                g_token_tbl.delete;
		g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value :=
                                        g_rev_component_rec.component_item_name;
                Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_TOUNIT_LESS_THAN_FROMUNIT'
                 , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_token_tbl          => g_token_tbl
                 );

                l_return_status := FND_API.G_RET_STS_ERROR;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check to end item unit number. . .' || l_return_status); END IF;

        END IF;

   --
   -- Verify that the Parent is BOM Enabled
   --
   IF g_Assy_Bom_Enabled_flag <> 'Y'
   THEN
     g_token_tbl.delete;
     g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
     g_token_tbl(1).token_value :=
           g_rev_component_rec.revised_item_name;

     Error_Handler.Add_Error_Token
     (  p_message_name => 'BOM_REV_ITEM_BOM_NOT_ENABLED'
      , p_mesg_token_tbl => l_Mesg_Token_Tbl
      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , p_token_tbl    => g_token_tbl
      );

     l_return_status := FND_API.G_RET_STS_ERROR;
 /*    g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                 g_token_tbl(1).token_value :=
                                         p_rev_component_rec.component_item_name;*/

   END IF;


   --
   -- All validations that only apply to Operation Type  CREATE
   --
   IF p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE THEN

	-- When disabling a component, to end item number must be the same
	-- as the value in the bill component being disabled.

    IF NVL(g_rev_component_rec.acd_type, 1) = 3 AND
       l_is_comp_unit_controlled
    THEN
      FOR To_End_Item_Number IN c_To_End_Item_Number
          LOOP
              l_bill_to_end_number :=
          To_End_Item_Number.To_End_Item_Unit_Number;
          END LOOP;

      IF l_bill_to_end_number <>
        p_rev_component_rec.to_end_item_unit_number
      THEN
        g_token_tbl.delete;
        g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                    g_token_tbl(1).token_value :=
                                          g_rev_component_rec.component_item_name;

                    Error_Handler.Add_Error_Token
                    (  p_message_name       => 'BOM_DISABLE_TOUNIT_INVALID'
                    , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , p_token_tbl          => g_token_tbl
                    );

                    l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;
           -- Component can be unit controlled only if parent revised item is
        -- unit controlled.
        -- Added by AS on 07/08/99 as part of unit effectivity changes

-- Bug 2044133 Fix Begin
--	IF NVL(g_rev_component_rec.acd_type, 1) = 1 AND
--	   l_is_comp_unit_controlled AND
--	   NOT l_is_item_unit_controlled
        IF NVL(g_rev_component_rec.acd_type, 1) = 1 AND
           g_Assy_Effectivity_Control = 1 AND
           g_Comp_Effectivity_Control = 2
-- Bug 2044133 Fix End

      	THEN
           g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value :=
                                        g_rev_component_rec.component_item_name;
                g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                g_token_tbl(2).token_value :=
                                        g_rev_component_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_CMP_UNIT_RIT_NOT_UNIT'
                 , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_token_tbl          => g_token_tbl
                 );

                l_return_status := FND_API.G_RET_STS_ERROR;
	      END IF;
		        -- Unit controlled revised items can only have non-ATO or non-PTO
        -- standard items as components.
        -- Added by AS on 07/08/99 as part of unit effectivity changes

        IF NVL(g_rev_component_rec.acd_type, 1) = 1 AND
           l_is_comp_unit_controlled AND
           (g_comp_item_type <> 4 OR
	    g_comp_ato_flag = 'Y' OR
	    g_comp_pto_flag = 'Y')
        THEN
                g_token_tbl.delete;
		g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                g_token_tbl(1).token_value :=
                                        g_rev_component_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_CMP_UNIT_TYPE_NOT_VALID'
                 , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_token_tbl          => g_token_tbl
                 );

                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
	--
	-- Verify that the Parent has BOM Enabled
	--
  --Moved this check out, so that its applicable for all transaction types
/* IF g_Assy_Bom_Enabled_flag <> 'Y'
	THEN
		g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
		g_token_tbl(1).token_value :=
					g_rev_component_rec.revised_item_name;

		Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_REV_ITEM_BOM_NOT_ENABLED'
		 , p_mesg_token_tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_token_tbl		=> g_token_tbl
		 );

		l_return_status := FND_API.G_RET_STS_ERROR;
		g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value :=
                                        p_rev_component_rec.component_item_name;

	END IF; */
	IF NOT Check_PrimaryBill AND Nvl(Bom_Globals.Get_Validate_For_Plm,'N') = 'N'
           THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('ACD type to be add if primary bill does not exist . . .'); END IF;
		IF NVL(p_rev_component_rec.acd_type, 1) <> 1 AND
		   Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
		THEN
			/*****************************************************
			--
			-- If the primary bill does not exist then the acd type
			-- of the component cannot be other that add.
			--
			******************************************************/
			IF FND_MSG_PUB.Check_Msg_Level
			   (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
            			Error_Handler.Add_Error_Token
				(  p_message_name   => 'BOM_CMP_ACD_TYPE_ADD'
				 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_token_tbl      => g_token_tbl
				);
        		END IF;
			l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

   	END IF;  -- End checking of ACD Type

	-- Component cannot be added if the Bill is referencing another
	-- bill as common
	BEGIN
         IF Bom_Globals.Get_Caller_Type <> 'MIGRATION' THEN
                SELECT 'Valid'
                  INTO l_dummy
                  FROM bom_bill_of_materials bom
                 WHERE bom.bill_sequence_id = p_rev_comp_unexp_rec.bill_sequence_id
                   AND bom.source_bill_sequence_id  <> bom.bill_sequence_id
                   AND nvl(p_rev_component_rec.acd_type, 1) in (1,3);

         --Dont reject updates outright. Some updates are allowed on Common BOM.
         --This is for updates through CO.

       -- If no exception is raised then Bill is referencing another
		   -- bill

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              g_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
              g_token_tbl(2).token_value :=
                p_rev_component_rec.revised_item_name;
                                Error_Handler.Add_Error_Token
              (  p_Message_Name	=> 'BOM_BILL_COMMON'
               , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
               , p_Token_Tbl		=> g_Token_Tbl
              );
          END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
  --       END IF;
           END IF;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                   --if the acd type is update, check if its a valid common bom update
                   IF nvl(p_rev_component_rec.acd_type, 1) in (1,3)
                      OR (nvl(p_rev_component_rec.acd_type, 1) = 2
                         AND valid_common_bom_change( p_rev_component_rec => p_rev_component_rec
                                                , p_Old_Rev_Component_Rec => p_Old_Rev_Component_Rec))
                      OR not Is_Bill_Common(p_bill_sequence_id =>
                                                 p_rev_comp_unexp_rec.bill_sequence_id)
                   THEN
                     NULL;
                   ELSE
                      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                          g_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                          g_token_tbl(2).token_value :=
                            p_rev_component_rec.revised_item_name;
                                            Error_Handler.Add_Error_Token
                          (  p_Message_Name	=> 'BOM_BILL_COMMON'
                           , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                                             , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                           , p_Token_Tbl		=> g_Token_Tbl
                          );
                      END IF;
                      l_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;
                   WHEN OTHERS THEN
                   	IF FND_MSG_PUB.Check_Msg_Level
			   (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                        	Error_Handler.Add_Error_Token
				(   p_message_name    => NULL
                                  , p_message_text    => 'Common Bill Check ' ||
						 SUBSTR(SQLERRM, 1, 30) || ' '||
						 TO_CHAR(SQLCODE)
				  , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
				  , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
				 );
                        END IF;
			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      	END; -- Check if parent Common Ends

	/*****************************************************************
	--
	-- Verify that the component item and revised item are not the same
	--
	******************************************************************/
	IF p_rev_comp_unexp_rec.revised_item_id =
	   p_rev_comp_unexp_rec.component_item_id
	THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
		   g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                   g_token_tbl(1).token_value :=
                                        g_rev_component_rec.revised_item_name;

                   Error_Handler.Add_Error_Token
                   (  x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                    , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                    , p_Message_name    => 'BOM_COMP_SAME_AS_BILL'
                    , p_token_tbl       => g_token_tbl
                    );
               END IF;
               l_return_status := FND_API.G_RET_STS_ERROR;
	       g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
               g_token_tbl(1).token_value :=
                                        p_rev_component_rec.component_item_name;

	END IF;

	/*************************************************************
	--
	-- Verify BOM_Enabled_Flag of the component being added.
	-- Only components with value Yes can be added.
	--
	**************************************************************/
/* This validation will not be required anymore as items which are not BOM allowed can
   be components, but will just not be able to have BOMs  --- Deepu
	*/
  /*Uncommented for bug 5925020*/

	IF g_Comp_Bom_Enabled_Flag = 'N' THEN
               -- Bom_Enabled is N, so cannot add a component .
		-- Check if ACD type is not Disable or Update
          IF( nvl(p_rev_component_rec.acd_type, 1)  NOT IN (2 , 3)) THEN -- Change or Disable
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                   Error_Handler.Add_Error_Token
		   (  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		    , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                    , p_Message_name	=> 'BOM_COMP_ITEM_BOM_NOT_ENABLED'
                    , p_token_tbl	=> g_token_tbl
		    );
               END IF;
               l_return_status := FND_API.G_RET_STS_ERROR;
	  END IF;
   	END IF;


	/*******************************************************************
	--
	-- Item Num Check
	--
	********************************************************************/
	IF p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE
	   AND
	   ( NVL(p_rev_component_rec.acd_type,1) = 1  OR
	     ( p_rev_component_rec.acd_type = 2 AND
	       p_rev_component_rec.item_sequence_number <>
	       p_old_rev_component_rec.item_sequence_number
	     )
	   )
           AND
           ((p_Control_rec.caller_type = 'FORM' AND
             p_control_rec.validation_controller = 'ITEM_SEQUENCE_NUMBER')
             OR
             p_control_rec.caller_type <> 'FORM')
   	THEN
             -- Verify if a component is already added using this item_num
	     -- If there is, log a WARNING.

                item_num_for_bill := 0;
		g_Token_Tbl.Delete;
                g_token_tbl(1).token_name  := 'ITEM_SEQUENCE_NUMBER';
                g_token_tbl(1).token_value := p_rev_component_rec.item_sequence_number;
                g_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(2).token_value := p_rev_component_rec.component_item_name;

                IF NOT l_is_item_unit_controlled
		THEN
			FOR Item_Num in c_ItemDateNum LOOP
                        	item_num_for_bill := 1;
                	END LOOP;
		ELSE
                        FOR Item_Num in c_ItemUnitNum LOOP
                                item_num_for_bill := 1;
                        END LOOP;
		END IF;

                IF item_num_for_bill = 1 THEN
                	Error_Handler.Add_Error_Token
			(  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                         , p_message_name	=> 'BOM_ITEM_NUM_NOT_UNIQUE'
			 , p_Token_Tbl		=> g_Token_Tbl
                         , p_message_type 	=> 'W'
			);
                END IF;

	END IF; -- Item Num Check ends


	/********************************************************************
	--
        -- Also verify that the component being added is not a Product Family
        --
	*********************************************************************/

	g_token_tbl.delete;
        g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
        g_token_tbl(1).token_value :=
                                        g_rev_component_rec.component_item_name;

	IF g_Comp_Item_Type = 5
	THEN
        	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_ITEM_PRODUCT_FAMILY'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                         , p_token_tbl		=> g_token_tbl
			 );
                END IF;

        END IF ; -- Product Family Check Ends
       IF NOT Verify_Item_Attributes(  p_Mesg_token_Tbl => l_Mesg_Token_Tbl
		 		     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				     )
       THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Check Item Attribute Validation. . .' || l_Return_Status  );
END IF;

	-- Verify if the revised item is being referenced as common in
	-- other orgs then it satisfies all the criteria required for the
	-- component to be on the bill.
	--

	-- Bug 10094436 - pim-ait integration: provide custom hook to ait for item org assignment
	--- custom hook API called for sun-integration
  IF BOM_Globals.get_debug = 'Y' THEN
	  error_handler.write_debug(' Check if custom hook enabled: ' || BOM_PUB_COMMON_COMP.GET_CUSTOM_MODE(1.0) );
  END IF;

	if BOM_PUB_COMMON_COMP.GET_CUSTOM_MODE(1.0) = 'Y' then
		IF BOM_Globals.get_debug = 'Y' THEN
		  error_handler.write_debug(' Before calling custom hook BOM_PUB_COMMON_COMP.ASSIGN_COMP_TO_ORGS assign component ' || g_rev_comp_Unexp_rec.component_item_id || ' - ' || to_char(sysdate, 'YYYY-MM-DD hh24:mi:ss') );
	  END IF;

	 BOM_PUB_COMMON_COMP.ASSIGN_COMP_TO_ORGS(
	      p_api_version                 => 1.0,
        p_revised_item_id             => g_Rev_Comp_Unexp_Rec.revised_item_id,
        p_organization_id             => g_Rev_Comp_Unexp_Rec.organization_id,
        p_bill_sequence_id            => g_Rev_Comp_Unexp_Rec.bill_sequence_id,
        p_alt_bom_designator          => g_rev_component_rec.alternate_bom_code,
        p_component_item_id           => g_rev_comp_Unexp_rec.component_item_id,
        p_eco_name                    => g_rev_component_rec.eco_name,
        x_return_status               => l_return_status,
        x_Mesg_Token_Tbl              => l_Mesg_Token_Tbl) ;

    IF BOM_Globals.get_debug = 'Y' THEN
		   error_handler.write_debug('After calling custom hook BOM_PUB_COMMON_COMP.ASSIGN_COMP_TO_ORGS - ' || to_char(sysdate, 'YYYY-MM-DD hh24:mi:ss') );
	  END IF;
	 end if;


	l_result := Check_Common_Other_Orgs;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Common_Other_Orgs returned with result ' || to_char(l_result)); END IF;

	IF l_result <> 0
  THEN
	  IF l_result = 1
    THEN
		  l_err_text := 'BOM_COMP_NOTEXIST_IN_OTHER_ORG';
    ELSIF l_result = 2 THEN
		  l_err_text := 'BOM_COMP_NOT_BOMENABLED';
    ELSIF l_result = 3 THEN
  		l_err_text := 'BOM_COMP_NOT_ENG_IN_OTHER_ORGS';
    /*ELSIF l_result = 4 THEN
      l_err_text := 'BOM_COMMON_OP_SEQ_INVALID';*/
    END IF;

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
		(  p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_message_name	=> l_err_text
                 , p_token_tbl		=> g_token_tbl
		 );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;  -- Check if exists in other orgs if common Ends

   END IF; -- End of Operation Type CREATE

   /**************************************************************************
   --
   -- Operations specific to the Transaction Type of Update
   --
   **************************************************************************/

   IF p_control_rec.caller_type <> 'FORM' AND
      p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
   THEN

	--
	-- Verify that the user is not trying to Update non-updateable columns
	--
	IF p_Old_Rev_Component_Rec.Shipping_Allowed <>
	   p_rev_component_rec.shipping_allowed
	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                	Error_Handler.Add_Error_Token
                        ( p_message_name    => 'BOM_SHIP_ALLOWED_NOT_UPDATE'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

--Since now we can update some attributes of common bills as well,
--ensure that:
--1. These updates on common bills are allowed
--2. No other attribute other than material conrol attrs gets updated in common bills


	       IF dereferenced_bom(p_rev_comp_unexp_rec.bill_sequence_id)
               THEN
	         IF valid_common_bom_change(p_rev_component_rec => p_rev_component_rec,
					                             p_Old_Rev_Component_Rec=>p_Old_Rev_Component_Rec)
		          AND p_rev_component_rec.transaction_type = BOM_Globals.G_OPR_UPDATE
	         THEN
           --if the change on common bom is only in the wip attributes,
	         --allow it.
		        NULL;
	         ELSE
             Error_Handler.Add_Error_Token
             (  p_message_name	=> 'BOM_INVALID_COMMON_BOM_CHANGE'
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , p_token_tbl		=> g_token_tbl
             );
            l_return_status := FND_API.G_RET_STS_ERROR;
         	 END IF;
         END IF;

	/*******************************************************************
	--  Bug:4240031
	-- Checks whether component operations exist when changing Optional
	-- from Yes to No
	--
	*******************************************************************/
       IF Check_Optional_For_Comp_Ops
       THEN
           g_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
           g_token_tbl(1).token_value := p_rev_component_rec.component_item_name;
           Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_COMP_OPERATION_EXIST'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                         , p_token_tbl		=> g_token_tbl
			 );
	   l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;


	/*******************bug:4240031 ends here***********************************/

	IF p_rev_component_rec.old_effectivity_date IS NOT NULL AND
	   p_rev_component_rec.old_effectivity_date <> FND_API.G_MISS_DATE AND
	   Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
	THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'BOM_OLD_EFFECTIVITY_GIVEN'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_rev_component_rec.old_operation_sequence_number IS NOT NULL AND
           p_rev_component_rec.old_operation_sequence_number <>
							FND_API.G_MISS_NUM AND
	   Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'BOM_OLD_OP_SEQ_NUM_GIVEN'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
	--
	-- ACD Type not updateable
	--
	IF p_rev_component_rec.acd_type <>
	   p_old_rev_component_rec.acd_type AND
	   Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'BOM_ACD_TYPE_NOT_UPDATEABLE'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	--
	-- Verify that the user is not trying to update a component which
	-- is Disabled on the ECO
	--
	IF p_old_rev_component_rec.acd_type = 3 AND
	   Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
	THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'BOM_COMPONENT_DISABLED'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	-- User cannot update to_end_item_unit_number when the component
	-- is disabled.

	IF NVL(p_rev_component_rec.acd_type, 1) = 3 AND
	   p_rev_component_rec.to_end_item_unit_number <>
		p_old_rev_component_rec.to_end_item_unit_number
	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'BOM_DISABLE_TOUNIT_NONUPD'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

   END IF;  /* Operation UPDATE ENDS */

   /*************************************************************************
   --
   -- All operations that would be common for Create and Update with slight
   --variation in
   -- checks.
   --
   **************************************************************************/
   IF p_rev_component_rec.Transaction_Type IN
      (BOM_GLOBALS.G_OPR_CREATE, BOM_GLOBALS.G_OPR_UPDATE)
   THEN
        /*********************************************************************
        --
        -- Verify yield factor
        -- IF Component is Option Class or bill is planning
        -- then yield must be 1
        -- If yield is >0 and less than 1 then give a warning.
        --
        *********************************************************************/
        IF ((p_control_rec.caller_type = 'FORM' AND
             p_control_rec.validation_controller = 'YIELD')
            OR
             p_control_rec.caller_type <> 'FORM')
           AND
           p_rev_component_rec.projected_yield <> 1 THEN
                IF g_assy_item_type     = 3 -- Planning parent
                   OR
                   g_comp_item_type     = 2  -- Option Class component
                THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                g_token_tbl(2).token_name  :=
                                                'REVISED_ITEM_NAME';
                                g_token_tbl(2).token_value :=
                                        g_rev_component_Rec.revised_item_name;
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name    => 'BOM_COMP_YIELD_NOT_ONE'
                                 , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , p_Token_Tbl       => g_Token_Tbl
                                 );
                                g_token_tbl.delete(2);
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF p_rev_component_rec.projected_yield <=0
                THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                g_token_tbl(2).token_name  :=
                                                'REVISED_ITEM_NAME';
                                g_token_tbl(2).token_value :=
                                        g_rev_component_Rec.revised_item_name;
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name    => 'BOM_COMP_YIELD_NOT_NEGATIVE'
                                 , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , p_Token_Tbl       => g_Token_Tbl
                                 );
                                g_token_tbl.delete(2);
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF p_rev_component_rec.projected_yield > 1
                THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                -- Log warning

                                Error_Handler.Add_Error_Token
                                (  p_Message_Name    => 'BOM_YIELD_WARNING'
                                 , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                                 , p_message_type    => 'W'
                                );
                        END IF;
                END IF;
        END IF;

       -- BASIS type should be 2 or null

       IF not(p_rev_component_rec.BASIS_TYPE is null or  p_rev_component_rec.BASIS_TYPE=2
            or p_rev_component_rec.BASIS_TYPE =FND_API.G_MISS_NUM)
         THEN
               Error_Handler.Add_Error_Token
               (  p_Message_Name    => 'BOM_BASIS_TYPE_INVALID'
                , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , p_message_type    => 'E'
               );
            l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

      -- Validations Related to Basis Type : Basis_type can not be lot if the
      -- WIP supply type is Phantom.  Basis_type can not be lot for Model/OC items

       IF (p_rev_component_rec.WIP_SUPPLY_TYPE =6 AND p_rev_component_rec.BASIS_TYPE=2)
         THEN
               Error_Handler.Add_Error_Token
               (  p_Message_Name    => 'BOM_LOT_BASED_PHANTOM'
                , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , p_message_type    => 'E'
               );
            l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

      -- For Components of PTO Kits, Models, Option Classes, Basis type should be item.
   	IF(g_Assy_PTO_flag ='Y' and  p_rev_component_rec.BASIS_TYPE=2) then
               Error_Handler.Add_Error_Token
               (  p_Message_Name    => 'BOM_LOT_BASED_PTO'
                , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , p_message_type    => 'E'
               );
            l_return_status := FND_API.G_RET_STS_ERROR;
   	END IF;

     --For ATO model, option class bills, optional,model,option class
     -- components should not be lot based.
   	IF ( p_rev_component_rec.BASIS_TYPE=2
     	    and (p_rev_component_rec.OPTIONAL=1
               or g_Comp_Item_Type in (Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS) )) THEN
               Error_Handler.Add_Error_Token
               (  p_Message_Name    => 'BOM_LOT_BASED_ATO'
                , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , p_message_type    => 'E'
               );
            l_return_status := FND_API.G_RET_STS_ERROR;
   	END IF;

     /* Validations for OPM convergence Project, Dual UOM tracking items should not be allowed
        for updates and creates */
       IF (G_Assy_Tracking_Quantity_Ind <>'P' or G_Comp_Tracking_Quantity_Ind <>'P') then
               Error_Handler.Add_Error_Token
               (  p_Message_Name    => 'BOM_DUAL_UOM_ITEMS'
                , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , p_message_type    => 'E'
               );
            l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

     IF p_control_rec.caller_type <> 'FORM'
     THEN
	--
	-- Verify that the disable date is greater than effectivity date
	-- for both operations Create and Update
	--

	-- If the transaction type is CREATE, then the new_effective_date column is
	-- ignored.
	-- but if the transaction type is update, then the new_effectivity_date can be
	-- used to update the effectivity date of a future effective component to bring it closer
	-- in its effectivity cyle. In this the validation for Insert and Update will differ
	-- If the new_effectivity_date col is not null and missing then it must be greater or =
	-- to SYSDATE.
	-- Also, disable_date must be greater or equal to the new_effective_date
	IF p_rev_component_rec.transaction_type in (BOM_GLOBALS.G_OPR_CREATE,
						   BOM_GLOBALS.G_OPR_UPDATE) AND
	   p_rev_component_rec.disable_date <
	   	p_rev_component_rec.start_effective_date THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                	Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_COMP_DIS_DATE_INVALID'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

	ELSIF p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_UPDATE AND
	      p_rev_component_rec.new_effectivity_date IS NOT NULL AND
	      p_rev_component_rec.new_effectivity_date <> FND_API.G_MISS_DATE AND
	      (
   --  p_rev_component_rec.new_effectivity_date < SYSDATE  OR    -- Bug3281414
		 p_rev_component_rec.disable_date < p_rev_component_rec.new_effectivity_date
	       )
	THEN
                 Error_Handler.Add_Error_Token
                 (  p_message_name       => 'BOM_COMP_DIS_DATE_INVALID'
                  , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  , p_Token_Tbl          => g_Token_Tbl
                  );
                  l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

--	dbms_output.put_line('Verified disable date . . . ' || l_return_status);

	/********************************************************************
	--
	-- Verify that the number of reference designators equals the component
	-- quantity if quantity related = 1
	--
	**********************************************************************/
  /* -- Bug No: 3522842. Quantity Related checks will be done in BOM_Bo_Pvt package.
	IF p_rev_component_rec.quantity_related = 1
	THEN
		FOR cnt_desg IN c_RefDesgs
		LOOP
		   	IF cnt_desg.number_of_desgs <>
			   p_rev_component_rec.quantity_per_assembly
			THEN
				-- GIVE A WARNING
                                --
				Error_Handler.Add_Error_Token
                                ( p_message_name  => 'BOM_QTY_REL_QTY_REF_DESG'
                                , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                                , p_Token_Tbl     => g_Token_Tbl
                                , p_message_type  => 'W'
				);
			END IF;
		END LOOP;
	END IF;
  */

	/********************************************************************
	--
	-- Verify that if the user is trying to create or update rev. comp
	-- to quantity related when the quantity_per_assembly is fractional
	--
	*********************************************************************/
	IF round(p_rev_component_rec.quantity_per_assembly) <>
	   p_rev_component_rec.quantity_per_assembly AND
	   p_rev_component_rec.quantity_related = 1
	THEN
		Error_Handler.Add_Error_Token
                ( p_message_name  => 'BOM_QTY_REL_QTY_FRACTIONAL'
                , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , p_Token_Tbl     => g_Token_Tbl
                 );

		l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	/********************************************************************
   	--
	-- If the Operation is Create with an Acd_Type of Change or Disable
	-- then component pointed to by old_component_sequence_id should
	-- already be implemented
	--
	*********************************************************************/

	/** This allowed thru the form and should be allowed thru the BO
	    as well

	IF   p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE AND
       	   p_rev_component_rec.acd_type  IN (2, 3)
   	THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Old sequence: ' || to_char(p_rev_comp_Unexp_rec.old_component_sequence_id)); END IF;
		BEGIN
			SELECT 'Component Implemented'
		  	  INTO l_dummy
		  	  FROM bom_inventory_components
		 	 WHERE component_sequence_id =
			       p_rev_comp_Unexp_rec.old_component_sequence_id
		   	   AND implementation_date IS NOT NULL;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- component is yet not implemented
	        	IF FND_MSG_PUB.Check_Msg_Level
			   (FND_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
            		    Error_Handler.Add_Error_Token
			    (  p_message_name   => 'BOM_OLD_COMP_SEQ_ID_INVALID'
			     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			     , p_Token_Tbl	=> g_Token_Tbl
                             );
        		END IF;
        		l_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
--			dbms_output.put_line(SQLERRM);
                      Error_Handler.Add_Error_Token
		      (  p_message_name	=> NULL
                       , p_message_text	=> 'ERROR Rev Cmp entity validate ' ||
					   SUBSTR(SQLERRM, 1, 30) || ' '    ||
					   TO_CHAR(SQLCODE)
		       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       );
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END;
   	END IF;

	** End of Comment **/

        -- If the user is attempting to change the from_end_item_unit number or to_end_item_unit_number
        -- then verify that the change is not creating a component with overlapping dates
        IF (p_rev_component_rec.from_end_item_unit_number IS NOT NULL AND
            p_rev_component_rec.new_from_end_item_unit_number IS NOT NULL AND
            p_rev_component_rec.new_from_end_item_unit_number <> FND_API.G_MISS_CHAR
           )
        THEN
                l_result := Check_Unit_Number();

                IF (l_result = 1)
                THEN
                        g_Token_Tbl(1).Token_Name := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(1).Token_Value :=
                        g_Rev_Component_rec.revised_item_name;
                        g_Token_Tbl(1).Token_Name := 'NEW_FROM_UNIT_NUMBER';
                        g_Token_Tbl(1).Token_Value := g_Rev_Component_rec.new_from_end_item_unit_number;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name   => 'BOM_NEW_FROM_UNIT_NUM_OVERLAP'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => g_Token_Tbl
                         );
                        --
                        -- reset the first token to revised component name.
                        --
                        g_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
                        g_Token_Tbl(1).Token_Value :=
                                        g_Rev_Component_rec.component_item_name;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
        END IF;


        /********************************************************************
        -- Added by MK on 02/02/2001
        -- If the rev component is Create with an Acd_Type of Change or Disable
        -- then component pointed to by old_component_sequence_id should
        -- be valid against cusror old_comp_csr's conditions.
        *********************************************************************/
        IF p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_CREATE AND
           p_rev_component_rec.acd_type  IN (2, 3)
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Checking old component : '|| to_char(p_rev_comp_unexp_rec.old_component_sequence_id));
END IF;

             l_eco_for_production  := NVL(Bom_Globals.Get_Eco_For_Production,2)  ;

             FOR old_comp_rec IN old_comp_csr
                     (p_rev_comp_unexp_rec.old_component_sequence_id,
                      l_eco_for_production)
             LOOP
                 -- component is invalid
                 IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => 'BOM_OLD_COMP_SEQ_ID_INVALID'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => g_Token_Tbl
                             );
                 END IF;
                 l_return_status := FND_API.G_RET_STS_ERROR;
             END LOOP ;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After checking old component. Return status is  '|| l_return_status);
END IF;

        END IF;

      --IF Nvl(Bom_Globals.Get_Validate_For_Plm,'N') = 'N'
      --THEN
        -- Modified by MK on 11/13/00
        IF ( p_rev_component_rec.operation_sequence_number <> 1 AND
--             NVL(p_rev_Component_rec.ACD_Type, 1) = 1
             p_rev_Component_rec.ACD_Type = 1
            ) OR  -- bug 5386719
           ( p_rev_component_rec.operation_sequence_number <> 1 AND
             p_rev_Component_rec.ACD_Type is NULL and
              p_rev_component_rec.transaction_type = BOM_Globals.G_OPR_CREATE
            ) OR
           ( p_rev_component_rec.operation_sequence_number <> 1 AND
             NVL(p_rev_Component_rec.ACD_Type, 1) = 2           AND
             NVL(p_rev_component_rec.new_operation_sequence_number,FND_API.G_MISS_NUM)
                 = FND_API.G_MISS_NUM
            ) OR
           ( NVL(p_rev_component_rec.new_operation_sequence_number,1) <> 1 AND
             ( ( p_rev_component_rec.ACD_Type = 2 AND
                 p_rev_component_rec.transaction_type =
                  BOM_Globals.G_OPR_CREATE
                ) OR
                 p_rev_component_rec.transaction_type =
                  BOM_Globals.G_OPR_UPDATE
              ) AND
	      (
               NVL(p_old_rev_component_rec.operation_sequence_number, 1) <>
               NVL(p_rev_component_rec.new_operation_sequence_number, 1) AND
	       p_rev_component_rec.new_operation_sequence_number <> FND_API.G_MISS_NUM
	      )
            )
	THEN

        	/*************************************************************
        	--
        	-- If Operation_Seq_Num is not 1 then there must be a routing
        	-- for the revised item.
        	-- Added by AS on 08/20/99 to accomodate calls from the
		-- ECO form to perform this validation.
        	*************************************************************/
   --Bug 9076970 changes begin
    IF  Check_Routing_Exists THEN
		/*IF NOT Check_Routing_Exists
		THEN
                        IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => 'BOM_ONLY_ONE'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => g_Token_Tbl
                             );
                        END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;
		ELSE */
		 --Bug 9076970 changes end
		/*************************************************************
		--
		-- If Operation_Seq_Num is not NULL then it must be unique in
		-- case of Creates and in Case of Updates new_operation_sequence
		-- must be valid if the user is trying to update
		-- operation_sequence_number
		**************************************************************/

		   l_result := Check_Op_Seq(l_is_item_unit_controlled);
       --arudresh_debug('Result after check_op_seq '||l_result);

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check_Op_Seq returned with : ' || l_result); END IF;
		   IF l_result = 1
		   THEN
				g_Token_Tbl(1).Token_Name := 'REVISED_ITEM_NAME';
				g_Token_Tbl(1).Token_Value :=
					g_Rev_Component_rec.revised_item_name;
                        	Error_Handler.Add_Error_Token
				(  p_Message_Name   => 'BOM_OP_SEQ_NUM_INVALID'
			 	 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , p_Token_Tbl	    => g_Token_Tbl
                                );
				--
				-- reset the first token to revised component name.
				--
				g_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
                                g_Token_Tbl(1).Token_Value :=
                                        g_Rev_Component_rec.component_item_name;
                	l_return_status := FND_API.G_RET_STS_ERROR;
		/* bug:4240031 If there are comp ops then op seq num can not be
		 * changed to that
		*/
		   ELSIF l_result = 3 THEN
		               g_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
                               g_Token_Tbl(1).Token_Value := g_Rev_Component_rec.component_item_name;
			       Error_Handler.Add_Error_Token
				(  p_Message_Name   => 'BOM_COMP_OPS_OP_SEQ'
			 	 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , p_Token_Tbl	    => g_Token_Tbl
                                );
                               l_return_status := FND_API.G_RET_STS_ERROR;
		   ELSIF l_result = 2 THEN
        IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO THEN
             g_Token_Tbl(2).Token_Name := 'OP_SEQ_NUM';
                               g_Token_Tbl(2).Token_Value :=
                               to_char
                               (g_Rev_Component_rec.operation_sequence_number);
                              Error_Handler.Add_Error_Token
            (  p_message_name	=> 'BOM_OP_SEQ_NUM_NOT_UNIQUE'
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_Token_Tbl	=> g_Token_Tbl
                              );
            g_Token_Tbl.DELETE(2);
                              l_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
             g_Token_Tbl(2).Token_Name := 'OP_SEQ_NUM';
                               g_Token_Tbl(2).Token_Value :=
                               to_char
                               (g_Rev_Component_rec.operation_sequence_number);
                              Error_Handler.Add_Error_Token
            (  p_message_name	=> 'BOM_OP_SEQ_NUM_NOT_UNIQUE'
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_Token_Tbl	=> g_Token_Tbl
             , p_message_type   => 'W'
                              );
            g_Token_Tbl.DELETE(2);
        END IF;
		   ELSIF l_result = 4 THEN
			       Error_Handler.Add_Error_Token
				(  p_Message_Name   => 'BOM_COMMON_OP_SEQ_INVALID'
			 	 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , p_Token_Tbl	    => g_Token_Tbl
                            );
         l_return_status := FND_API.G_RET_STS_ERROR;
		   ELSIF l_result = 0 AND
		      p_Rev_Component_rec.old_operation_sequence_number
		      IS NOT NULL AND
		      p_Rev_Component_rec.old_operation_sequence_number <>
			FND_API.G_MISS_NUM AND Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
		   THEN
			BEGIN
			     SELECT operation_seq_num
			       INTO l_result
			       FROM bom_inventory_components
			      WHERE component_sequence_id =
			       p_rev_comp_unexp_rec.old_component_sequence_id
			        AND operation_seq_num =
			      p_Rev_Component_rec.old_operation_sequence_number;

			    EXCEPTION
				WHEN OTHERS THEN
					l_result := 0;
			END;

			IF l_result = 0
                        THEN
                             g_Token_Tbl(2).Token_Name := 'OLD_OP_SEQUENCE_NUM';
                             g_Token_Tbl(2).Token_Value :=
                             to_char
                            (g_Rev_Component_rec.old_operation_sequence_number);
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => 'BOM_OLD_OP_SEQ_NUM_GIVEN'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => g_Token_Tbl
                            );
                            g_Token_Tbl.DELETE(2);
                            l_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
		   END IF;
		END IF;
	END IF; -- Operation_seq_Num Check Ends.
      --END IF; -- Validate for plm ends
    END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Op seq num validation completed with ' || l_return_status); END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO identifier is '||Bom_Globals.Get_Bo_Identifier); END IF;

  IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO AND NVL(p_rev_Component_rec.ACD_Type,1) <> 3 THEN
    IF Nvl(Bom_Globals.Get_Validate_For_Plm,'N') = 'N'
    THEN
     IF (p_control_rec.caller_type = 'FORM' AND
	 p_control_rec.write_to_db)
        OR
	p_control_rec.caller_type <> 'FORM'
     THEN

	IF NOT l_is_item_unit_controlled
	THEN

           /********************************************************************
           --
           -- Check for Overlapping dates for the component being inserted.
           --
           *********************************************************************/

	   IF Check_Overlap_Dates
	       (X_Effectivity_date	=> p_rev_component_rec.start_effective_date,
	    	X_Disable_date	=> p_rev_component_rec.disable_date,
	    	X_Member_Item_Id	=> p_rev_comp_unexp_rec.component_item_id,
	    	X_Bill_Sequence_id  => p_rev_comp_unexp_rec.bill_sequence_id,
	    	X_Rowid		=> NULL,
            	X_Comp_Seq_id       => p_rev_comp_unexp_rec.old_component_sequence_id,  --Fixed for Bug No 6688502
            	X_Operation_Seq_Num => p_rev_component_rec.operation_sequence_number)
      	   THEN
           	--if function return true then component dates overlapp

	   	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
           	THEN
                --added for bug 9647673 (begin)
                g_token_tbl.delete;
                g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value := p_rev_component_rec.Component_Item_Name;

                g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                g_token_tbl(2).token_value := p_rev_component_rec.Revised_Item_Name;

               --added for bug 9647673 (end)

           		Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_COMP_OPSEQ_DATE_OVERLAP'
		 	, p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			, p_token_tbl		=> g_token_tbl
		 	, x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			, p_message_type	=> 'W' --Changed from W to E for bug 8839091; changed back to W for bug 9780939
                 	);
		--l_return_status := FND_API.G_RET_STS_ERROR; --Added line, bug 9737140; commented out for bug 9780939
           	END IF;
                -- Since Open Interface allows for Dates to be
	   	-- overlapping do set the error status.
      	   END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified overlapping dates . . . ' || l_return_status); END IF;

	ELSE

           /********************************************************************
           --
           -- Check for Overlapping numbers for the component being inserted.
           --
           *********************************************************************/
           IF 	Check_Overlap_Numbers
           	(X_From_end_item_number
			=> p_rev_component_rec.from_end_item_unit_number,
            	 X_to_end_item_number
			=> p_rev_component_rec.to_end_item_unit_number,
            	 X_Member_Item_Id    => p_rev_comp_unexp_rec.component_item_id,
            	 X_Bill_Sequence_id  => p_rev_comp_unexp_rec.bill_sequence_id,
            	 X_Rowid             => NULL,
            	 X_Comp_Seq_id	=> p_rev_comp_unexp_rec.component_sequence_id,
	    	 X_Operation_Seq_Num	=>
			p_rev_component_rec.operation_sequence_number)
	   THEN
           	--if function return true then component dates overlapp

           	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
           	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_COMP_OPSEQ_UNIT_OVERLAP'
                 	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl           => g_token_tbl
                        , p_message_type        => 'W'
                 	);
           	END IF;
           	-- Since Open Interface allows for Dates to be
           	-- overlapping do set the error status.
	   END IF;
        END IF;
      END IF;
     END IF; -- Validate for PLM check ends
  ELSIF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO THEN
        --begin changes for bug 9920911
 	      IF p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_CREATE THEN
 	           l_new_op_seq_num := p_rev_component_rec.operation_sequence_number;
 	      ELSIF p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_UPDATE THEN
 	           l_new_op_seq_num := nvl(p_rev_component_rec.new_operation_sequence_number, p_rev_component_rec.operation_sequence_number);
 	      END IF;
 	 --end changes for bug 9920911
      IF Nvl(Bom_Globals.Get_Validate_For_Plm,'N') = 'N'
      THEN

	IF NOT l_is_item_unit_controlled
	THEN


           /********************************************************************
           --
           -- Check for Overlapping dates for the component being inserted.
           --
           *********************************************************************/

  /* Fix for bug 4585076 - While calling check_overlap_dates function, if txn type is create then pass start_effective_date
              else if txn type is update then pass new_effectivity_date.
           */
     IF p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_CREATE THEN
          l_new_compare_date := p_rev_component_rec.start_effective_date;
     ELSIF p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_UPDATE THEN
          l_new_compare_date := p_rev_component_rec.new_effectivity_date;
     END IF;

	   IF Bom_Validate_Comp_Operation.Check_Overlap_Dates
	       (p_Effectivity_date	=> l_new_compare_date, /*p_rev_component_rec.start_effective_date,*/
	    	p_Disable_date	=> p_rev_component_rec.disable_date,
	    	p_Component_Item_Id	=> p_rev_comp_unexp_rec.component_item_id,
	    	p_Bill_Sequence_id  => p_rev_comp_unexp_rec.bill_sequence_id,
                p_Component_Sequence_id => p_rev_comp_unexp_rec.component_sequence_id,
	    	p_Rowid		=> p_rev_comp_unexp_rec.rowid,
            	p_Operation_Seq_Num =>  l_new_op_seq_num, --p_rev_component_rec.operation_sequence_number, --9920911
                p_entity   => 'RC')
      	   THEN
           	--if function return true then component dates overlapp

	   	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
           	THEN
                --added for bug 9647673 (begin)
                g_token_tbl.delete;
                g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value := p_rev_component_rec.Component_Item_Name;

                g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                g_token_tbl(2).token_value := p_rev_component_rec.Revised_Item_Name;

               --added for bug 9647673 (end)

           		Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_COMP_OPSEQ_DATE_OVERLAP'
		 	, p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			, p_token_tbl		=> g_token_tbl
		 	, x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			, p_message_type	=> 'E'
                 	);
           	END IF;
             	l_return_status := FND_API.G_RET_STS_ERROR;
      	   END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified overlapping dates . . . ' || l_return_status); END IF;

	ELSE
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('I am here Inside Unit Eff'); END IF;

           /********************************************************************
           --
           -- Check for Overlapping numbers for the component being inserted.
           --
           *********************************************************************/
           IF 	Bom_Validate_Comp_Operation.Check_Overlap_Numbers
           	(p_From_end_item_number
			=> p_rev_component_rec.from_end_item_unit_number,
            	 p_to_end_item_number
			=> p_rev_component_rec.to_end_item_unit_number,
            	 p_Component_Item_Id    => p_rev_comp_unexp_rec.component_item_id,
            	 p_Bill_Sequence_id  => p_rev_comp_unexp_rec.bill_sequence_id,
            	 p_Rowid             => p_rev_comp_unexp_rec.rowid,
                 p_Component_Sequence_id => p_rev_comp_unexp_rec.component_sequence_id,
	    	 p_Operation_Seq_Num	=>  l_new_op_seq_num,
			--p_rev_component_rec.operation_sequence_number, --9920911
                 p_entity     => 'RC')
	   THEN
           	--if function return true then component unit numbers overlapp

           	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
           	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_COMP_OPSEQ_UNIT_OVERLAP'
                 	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl           => g_token_tbl
                        , p_message_type        => 'E'
                 	);
           	END IF;
             	l_return_status := FND_API.G_RET_STS_ERROR;
	   END IF;
        END IF;
      END IF; -- Validate for Plm check ends
     END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified overlapping unit numbers. . .' || l_return_status); END IF;


	If (p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND g_Assy_Item_Type = Bom_Globals.G_PRODUCT_FAMILY) THEN
		l_Result := CheckUnique_PF_Member;
		IF l_Result = 1 Then
		   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
			g_Token_Tbl(2).Token_Name := 'pf_item';
			g_Token_Tbl(2).Token_Value :=
			g_rev_component_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                        ( p_message_name        => 'BOM_PF_MEMBER_ALREADY_EXISTS'
                        , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        , p_Token_Tbl           => g_Token_Tbl
                        );
                   END IF;
                   l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	End if;

	/*********************************************************************
	--
	-- Check whether the entered attributes match with the current
	-- component attributes
	--
	**********************************************************************/
	IF (( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
	      NVL(p_rev_component_rec.acd_type, 1) = 1
	    ) OR
	   (((p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
	      ) OR
	       p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
	     )
	      AND
	      NVL(p_Old_rev_component_rec.optional, 0) <>
	      p_rev_component_rec.optional
	    )
	   )
	THEN
	     l_Result := Check_PTO_ATO_for_Optional;
	     IF l_Result = 1 THEN
             	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             	THEN
                	Error_Handler.Add_Error_Token
			( p_message_name	=> 'BOM_COMP_OPTIONAL'
		 	, p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 	, x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 	, p_Token_Tbl		=> g_Token_Tbl
                 	);
                END IF;
             	l_return_status := FND_API.G_RET_STS_ERROR;
	     ELSIF l_Result = 2
	     THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name        => 'BOM_COMP_NOT_OPTIONAL'
                        , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        );
		END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;

--	dbms_output.put_line('Verified PTO / ATO . . .' || l_return_status);

	/*********************************************************************
	--
        -- Planning Percent can be other than 100 for only some combination of
        -- Assembly and component_types.
	--
	**********************************************************************/
	--
	IF p_control_rec.caller_type <> 'FORM' AND
	  (( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
              NVL(p_rev_component_rec.acd_type, 1) = 1 AND
              p_rev_component_rec.planning_percent <> 100
            ) OR
           (((p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
             )
              AND
              NVL(p_Old_rev_component_rec.planning_percent, 0) <>
              p_rev_component_rec.planning_percent
            )
           )
	THEN
        	l_Result := Check_Planning_Percent;
		IF l_Result = 1 THEN
		   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             	   THEN
			g_Token_Tbl(2).Token_Name := 'REVISED_ITEM_NAME';
			g_Token_Tbl(2).Token_Value :=
			g_rev_component_rec.revised_item_name;
                	Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_NOT_A_PLANNING_PARENT'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
                        );
			g_Token_Tbl.DELETE(2);
             	    END IF;
             	    l_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF l_Result = 2 THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
			g_Token_Tbl(2).Token_Name := 'REVISED_ITEM_NAME';
			g_Token_Tbl(2).Token_Value :=
			g_rev_component_rec.revised_item_name;
			g_Token_Tbl(3).Token_Name := 'ITEM_TYPE';
			IF g_Assy_Item_Type = Bom_Globals.G_MODEL
			THEN
				g_Token_Tbl(3).Token_Value := 'BOM_MODEL_TYPE';
			ELSIF g_Assy_Item_Type = Bom_Globals.G_OPTION_CLASS THEN
				g_Token_Tbl(3).Token_Value :=
				'BOM_OPTION_CLASS_TYPE';
			END IF;
			g_Token_Tbl(3).Translate := TRUE;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_COMP_MODEL_OC_OPTIONAL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
			g_Token_Tbl.DELETE(2);
			g_Token_Tbl.DELETE(3);
			l_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;
	--Commented condition below for bug 7392603
  /*	ELSIF l_Result = 3 THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
			g_Token_Tbl(1).Token_Name := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(1).Token_Value :=
                        g_rev_component_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       =>
						'BOM_COMP_OPTIONAL_ATO_FORECAST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
			g_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
                        g_Token_Tbl(1).Token_Value :=
                        g_rev_component_rec.component_item_name;

                    END IF;
		    l_return_status := FND_API.G_RET_STS_ERROR;*/
     		END IF;  -- If Result Ends
        END IF; -- If Plannng <> 100 Ends

--	dbms_output.put_line('Verified Planning % . . .' || l_return_status);

	/*********************************************************************
	--
        -- Check Required for Revenue / Required to Ship
	--
	**********************************************************************/
        IF (( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
              NVL(p_rev_component_rec.acd_type, 1) = 1 AND
	      ( p_rev_component_rec.required_for_revenue = 1 OR
		p_rev_component_rec.required_to_ship = 1
	       )
            ) OR
           (((p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
             )
              AND
              ( NVL(p_Old_rev_component_rec.required_for_revenue, 0) <>
                    p_rev_component_rec.required_for_revenue OR
		NVL(p_old_rev_component_rec.required_to_ship, 0) <>
		    p_rev_component_rec.required_to_ship
	       )
            )
           )
	THEN

	     l_Result := Chk_Req_For_Rev_Or_Shp;
	     IF l_Result = 1 THEN
	        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
			g_Token_Tbl(2).Token_Name := 'REVISED_ITEM_NAME';
			g_Token_Tbl(2).Token_Value :=
				g_rev_component_rec.revised_item_name;
                	Error_Handler.Add_Error_Token
			( p_message_name     => 'BOM_COMP_REQ_FOR_REV_INVALID'
		 	, p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
		 	, x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
		 	, p_Token_Tbl	     => g_Token_Tbl
                 	);
			g_Token_Tbl.DELETE(2);
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	     ELSIF l_Result = 2 THEN
			g_Token_Tbl(2).Token_Name := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value :=
				g_rev_component_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                        ( p_message_name     => 'BOM_COMP_REQ_TO_SHIP_INVALID'
                        , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , p_Token_Tbl        => g_Token_Tbl
                        );
			g_Token_Tbl.DELETE(2);
			l_return_status := FND_API.G_RET_STS_ERROR;
	     ELSIF l_Result = 3 THEN
                        g_Token_Tbl(2).Token_Name := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value :=
                                g_rev_component_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                        ( p_message_name     => 'BOM_COMP_REQ_TO_SHIP_INVALID'
                        , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , p_Token_Tbl        => g_Token_Tbl
                        );

                        g_Token_Tbl(2).Token_Name := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value :=
                                g_rev_component_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                        ( p_message_name     => 'BOM_COMP_REQ_FOR_REV_INVALID'
                        , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , p_Token_Tbl        => g_Token_Tbl
                        );

			g_Token_Tbl.DELETE(2);
			l_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified Req for Rev and Shipping . . . ' || l_return_status); END IF;

	/*********************************************************************
	--
	-- Verify the value of SO_Basis
	-- first conditon is removed by MK on 11/13/00
	*********************************************************************/
	IF -- p_control_rec.caller_type = 'FORM' AND
	   p_rev_component_rec.so_basis = 1 AND
	   g_Comp_Item_Type <> Bom_Globals.G_OPTION_CLASS
	THEN
                 Error_Handler.Add_Error_Token
                 (  p_message_name     => 'BOM_SO_BASIS_ONE'
                  , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                  , p_Token_Tbl        => g_Token_Tbl
                  );
		l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	/********************************************************************
        -- ATP Validation for components is changed and now there is no restriction
        -- Comment out by MK on 06/05/2001
	--
        -- Check Check_ATP Flag. Check_ATP can be True only if Assembly has
	-- Atp Components flag = Y and the Component has a Check_ATP.
	--

        IF (( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
              NVL(p_rev_component_rec.acd_type, 1) = 1 AND
              p_rev_component_rec.check_atp = 1
             ) OR
             ( ( ( p_rev_component_rec.Transaction_Type =
		   BOM_GLOBALS.G_OPR_CREATE AND
               	   p_rev_component_rec.acd_type = 2
                 ) OR
                  p_rev_component_rec.Transaction_Type =
		  BOM_GLOBALS.G_OPR_UPDATE
               ) AND
               NVL(p_old_rev_component_rec.check_atp, 0) <>
               p_rev_component_rec.check_atp
               AND p_rev_component_rec.check_atp = 1 -- Added by MK on 11/13/00
             )
           )
	THEN
            l_result := Check_ATP;
		--  We will not be using the result of the check_atp procedure
		--   to decide the translatable token since the message text
		--   is now changed. Please refer to text for BOM_ATP_CHECK_NOT_NO

            --  Modified by MK on 11/13/00
            --  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) AND
            --     l_result <> 0
            --  THEN

            IF  l_result <> 0
            THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
	            (  p_message_name	=> 'BOM_ATP_CHECK_NOT_NO'
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , p_Token_Tbl		=> g_Token_Tbl
                     );
		    g_Token_Tbl.DELETE(2);
		-- l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;
        END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('After verification of Check ATP . . . ' || l_return_status);
END IF;
--	dbms_output.put_line('After verification of Check ATP, Req for Rev' );
	********************************************************************/

	/********************************************************************
	--
        -- Check Mutually Exclusive, which can be set only if the
        -- Component is an Option Class and BOM is installed.
	--
	*********************************************************************/

        IF ( p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE OR
             p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
	    )
           AND
	   NVL(p_rev_component_rec.mutually_exclusive, 2) = 1
	THEN
	     l_result := Check_Mutually_Exclusive;
             IF l_result <> 0 THEN
	        IF l_result = 1 THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name    => 'BOM_MUT_EXCL_BOM_NOT_INST'
                       , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                       );
                   END IF;
	        ELSIF l_result = 2 THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name    => 'BOM_MUT_EXCL_NOT_MDL_OPTCLASS'
                       , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                       , p_Token_Tbl       => g_Token_Tbl
                       );
                   END IF;
	        END IF;

                l_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;

--	dbms_output.put_line('After verification of Mutually exclusive . . .' ||
--			l_return_status);

        -- So process can continue in case of a warning. Since it has
        -- indecisive o/p to continue or not, the function will
        -- log the error or warning and return TRUE if warning
        -- so the process can continue or will return an FALSE if
        -- process needs to return
        IF ((p_control_rec.caller_type = 'FORM' AND
             p_control_rec.validation_controller = 'SUPPLY_TYPE')
            OR
            p_control_rec.caller_type <> 'FORM')
	   AND
	   ((( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
              NVL(p_rev_component_rec.acd_type, 1) = 1 AND
              p_rev_component_rec.wip_supply_type IS NOT NULL
             ) OR
            ((p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
             ))
              AND
              NVL(p_Old_rev_component_rec.wip_supply_type, 0) <>
              p_rev_component_rec.wip_supply_type
            )
	   AND
            NOT Check_Supply_Type
	    (  p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	     , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl )
	THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

--	dbms_output.put_line
--	('After verification of Supply Type . . .' || l_return_status);

        IF (p_control_rec.caller_type = 'FORM' AND
	    p_control_rec.validation_controller IN
				('MINIMUM_QUANTITY', 'MAXIMUM_QUANTITY'))
	   OR
	   p_control_rec.caller_type <> 'FORM'
	THEN
            -- Check Minimum Quantity which must be <= Component Quantity
            IF ( p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE OR
                 p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
	        ) AND
                 p_rev_component_rec.minimum_allowed_quantity is not null
               AND
               NOT Check_Min_Quantity THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                    Error_Handler.Add_Error_Token
		    (  p_message_name	=> 'BOM_MIN_QUANTITY_INVALID'
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , p_Token_Tbl		=> g_Token_Tbl
                     );
                 END IF;
                 l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Check Maximun Quantity which must be >= Component Quantity or
	    -- should be NULL if the minimum quantity is NULL.
            IF ( p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE OR
                 p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
	        ) AND
                p_rev_component_rec.maximum_allowed_quantity IS NOT NULL
               AND
               NOT Check_Max_Quantity THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                    Error_Handler.Add_Error_Token
		    (  p_message_name	=> 'BOM_MAX_QUANTITY_INVALID'
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , p_Token_Tbl		=> g_Token_Tbl
                     );
                 END IF;
                 l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
	END IF;

--	dbms_output.put_line('After verification of Min / Max quantity . . .');

        -------------------------------------------------
        -- Required since quantity cannot be fractional
        -- if OE is installed and revised item is
        -- ATO/PTO.
        -- Fix made by AS 04/27/98
        -- Bug 651689
	-- Fractional qty allowed for ATO revised items
	-- fix made by skagarwa 11/27/00
	-- Bug 1490837
        -------------------------------------------------
      /* commenting for bug 5011929
	 OPEN c_OE_Installed;
	 FETCH c_OE_Installed INTO Is_OE_Installed;
	 CLOSE c_OE_Installed;

	 Is_Item_ATO := 'N';
	 IS_Item_PTO := 'N';

	 FOR Is_Item_ATO_PTO IN c_ATO_PTO
	 LOOP
	 	Is_Item_ATO := Is_Item_ATO_PTO.replenish_to_order_flag;
	 	Is_Item_PTO := Is_Item_ATO_PTO.pick_components_flag;
         END LOOP;

	 IF ( p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE OR
              p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
             ) AND
           (Is_OE_Installed = 'I'
            AND ( (  Is_Item_PTO = 'Y'
		   ) AND
                   (round(p_rev_component_rec.quantity_per_assembly)
             	    <> p_rev_component_rec.quantity_per_assembly)
		 )
	   )
         THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_COMP_QTY_FRACTIONAL'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
          commented for bug 5011929 */
--	dbms_output.put_line('Checked if fractional quantity is valid . . .' ||
--		l_return_status);


	/********************************************************************
	--
	-- Verify if the Check_Atp is Yes and the Component quantity is
	-- negative. If it is then give out an error.
	--
	********************************************************************/

	IF p_rev_component_rec.check_atp = 1 AND -- Bug Fix 3688325
	   p_rev_component_rec.quantity_per_assembly < 0
	THEN
	     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_COMP_QTY_NEGATIVE'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	/********************************************************************
	--
	-- If component is a PTO Option Class, then component quantity cannot
	-- be negative
	--
	********************************************************************/
	IF g_Comp_PTO_Flag = 'Y' AND
           p_rev_component_rec.quantity_per_assembly < 0
        THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_COMP_PTO_QTY_NEGATIVE'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Checking Supply Subinventory . . . ' || p_rev_component_rec.Supply_SubInventory); END IF;

	/*******************************************************************
	--
        -- Check Supply Subinventory
	--
	********************************************************************/

        IF -- p_control_rec.caller_type = 'FORM' -- Comment out by MK on 11/13/00
	   -- AND
	  p_rev_component_rec.Supply_SubInventory <> FND_API.G_MISS_CHAR AND
	  (( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
              NVL(p_rev_component_rec.acd_type, 1) = 1 AND
              p_rev_component_rec.Supply_SubInventory IS NOT NULL
            ) OR
           (((p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
             )
              AND
              NVL(p_Old_rev_component_rec.supply_subinventory, 'NONE') <>
              NVL(p_rev_component_rec.supply_subinventory, 'NONE')
            )
           )
	   AND
	   NOT Check_Supply_SubInventory THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_SUBINV_INVALID'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After checking Subinventory . . . ' || l_return_status); END IF;

--	dbms_output.put_line('Checking Locators . . . .');
	/********************************************************************
	--
        -- Check Locators
	--
	********************************************************************/
        IF p_control_rec.caller_type <> 'FORM'
          AND (Bom_globals.Get_Caller_Type <> BOM_GLOBALS.G_MASS_CHANGE)  -- Bug2739314
          AND
	   (( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
              NVL(p_rev_component_rec.acd_type, 1) = 1 AND
              p_rev_component_rec.Supply_SubInventory IS NOT NULL AND
	      p_rev_component_rec.Supply_SubInventory <> FND_API.G_MISS_CHAR
            ) OR
           ((( p_rev_component_rec.Transaction_Type=BOM_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
             ) OR
               p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
            )
              AND
              NVL(p_Old_rev_comp_unexp_rec.supply_locator_id, 0) <>
              NVL(p_rev_comp_unexp_rec.supply_locator_id, 0)
           )
          )
           AND
	   NOT Check_Locators
	THEN
--		dbms_output.put_line('Locators check returned with an error-' ||
--		to_char(l_locator_control));

	     IF l_locator_control = 4 THEN
	         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name       => 'BOM_LOCATOR_REQUIRED'
                       , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , p_Token_Tbl          => g_Token_Tbl
                      );
                END IF;
	     /*  Error message should be proper.  Since dynamic locators are supported
		 same validation for pre-specified can be used.  Bug 5032528
	     ELSIF l_locator_control = 3 THEN
	     	-- Log the Dynamic locator control message.
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
		      g_Token_Tbl(1).token_name := 'REVISED_COMPONENT_NAME';
	              g_Token_Tbl(1).token_value:= p_rev_component_rec.component_item_name;

                      Error_Handler.Add_Error_Token
		      (  p_message_name	      => 'BOM_LOCATOR_CANNOT_BE_DYNAMIC'
		       , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , p_Token_Tbl          => g_Token_Tbl
                      );
                END IF;
		 */
       -- Added OR l_locator_control = 3 for bug 5032528
	   ELSIF (l_locator_control = 2 OR l_locator_control = 3 ) THEN
		IF  l_item_loc_restricted  = 1 THEN

			-- if error occured when item_locator_control was
			-- restrcited

             		IF FND_MSG_PUB.Check_Msg_Level
			   (FND_MSG_PUB.G_MSG_LVL_ERROR)
             		THEN
                            -- Added Token by MK on 12/06/00
                            g_Token_Tbl(2).Token_Name  := 'SUPPLY_SUBINVENTORY';
	                    g_Token_Tbl(2).Token_Value := p_rev_component_rec.Supply_SubInventory ;

                	     Error_Handler.Add_Error_Token
			     (  p_message_name  => 'BOM_ITEM_LOCATOR_RESTRICTED'
			      , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	      , p_Token_Tbl      => g_Token_Tbl
                              );

                             g_Token_Tbl.DELETE(2);

             		END IF;
		ELSE
			IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
			      g_Token_Tbl(2).token_name := 'REVISED_COMPONENT_NAME';
			      g_Token_Tbl(2).token_value:= p_rev_component_rec.component_item_name;
                              Error_Handler.Add_Error_Token
			      (  p_message_name	  => 'BOM_LOCATOR_NOT_IN_SUBINV'
			       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	       , p_Token_Tbl      => g_Token_Tbl
                              );

                        END IF;
		END IF;
	     ELSIF l_locator_control = 1 THEN
			IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                             Error_Handler.Add_Error_Token
                             (  p_message_name  => 'BOM_ITEM_NO_LOCATOR_CONTROL'
                              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                              , p_Token_Tbl      => g_Token_Tbl
                              );
                        END IF;

	     END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF p_rev_component_rec.location_name IS NOT NULL AND
	      p_rev_component_rec.supply_subinventory IS NULL
	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             	THEN
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_LOCATOR_MUST_BE_NULL'
		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
             	END IF;
             	l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

--	dbms_output.put_line('Operation CREATE ENDS . . .' || l_return_status);

  /*The following item num check introduced by bug 5053977 has been commented
  out because users get two error messages when they add a component with
  the same item seq as an already existing component in the ECO revised
  item components form. This is for bug 8423042*/
  /*******************************************************************
	--
	-- Item Num Check (Commented out for bug 8423042)
	--
	********************************************************************/

  /* Begin commenting out item num check for bug 8423042

    --Fix for bug 5053977- This validation should be done from ECO form.
	  --It is not done for BOM/ECO BO because it is performance intensive.


  IF  (p_Control_rec.caller_type = 'FORM' AND
             p_control_rec.validation_controller = 'ITEM_SEQUENCE_NUMBER')
	   AND
	   ( NVL(p_rev_component_rec.acd_type,1) = 1  OR
	     ( p_rev_component_rec.acd_type = 2 AND
	       ( p_rev_component_rec.item_sequence_number <>
	         p_old_rev_component_rec.item_sequence_number)
	     )
	   )
   	THEN
             -- Verify if a component is already added using this item_num
	     -- If there is, log a WARNING.

                item_num_for_bill := 0;
		g_Token_Tbl.Delete;
                g_token_tbl(1).token_name  := 'ITEM_SEQUENCE_NUMBER';
                g_token_tbl(1).token_value := p_rev_component_rec.item_sequence_number;
                g_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(2).token_value := p_rev_component_rec.component_item_name;

                IF NOT l_is_item_unit_controlled
		THEN
			FOR Item_Num in c_ItemDateNum LOOP
                        	item_num_for_bill := 1;
                	END LOOP;
		ELSE
                        FOR Item_Num in c_ItemUnitNum LOOP
                                item_num_for_bill := 1;
                        END LOOP;
		END IF;

                IF item_num_for_bill = 1 THEN
                	Error_Handler.Add_Error_Token
			(  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                         , p_message_name	=> 'BOM_ITEM_NUM_NOT_UNIQUE'
			 , p_Token_Tbl		=> g_Token_Tbl
                         , p_message_type 	=> 'W'
			);
                END IF;

	END IF; -- Item Num Check ends

  --Fix for bug 5053977 ends here.

  End commenting out of item num check for bug 8423042 */

   END IF; -- Operation in UPDATE or CREATE


   -- Added by MK on 06/04/2001
   IF BOM_Globals.Get_Bo_Identifier = BOM_Globals.G_BOM_BO AND
      p_rev_component_rec.transaction_type = BOM_Globals.G_OPR_DELETE
   THEN
       IF p_rev_comp_unexp_rec.Delete_Group_Name IS NULL OR
          p_rev_comp_unexp_rec.Delete_Group_Name = FND_API.G_MISS_CHAR
       THEN

            Error_Handler.Add_Error_Token
             (  p_message_name       => 'BOM_DG_NAME_MISSING'
              , p_mesg_token_tbl     => l_mesg_token_tbl
              , x_mesg_token_tbl     => l_mesg_token_tbl
             );

             l_return_status := FND_API.G_RET_STS_ERROR;

       END IF;

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check if Delete Group is missing . . . ' || l_return_status) ;
END IF ;


   END IF ;

  /********************************************************************
  -- If the structure type is Packaging Hierarchy the we will do the
  -- following validations
  ********************************************************************/
  IF p_Control_rec.caller_type <> 'FORM' THEN
-- Bug 8874286 begin
--  SELECT STRUCTURE_TYPE_NAME
--      INTO
--      l_Structure_Type_Name
--      FROM BOM_STRUCTURE_TYPES_B STRUCT_TYPE,
--           BOM_STRUCTURES_B  BOM_STRUCT
--  WHERE  BOM_STRUCT.STRUCTURE_TYPE_ID = STRUCT_TYPE.STRUCTURE_TYPE_ID
--  AND BOM_STRUCT.BILL_SEQUENCE_ID = g_Rev_Comp_Unexp_Rec.BILL_SEQUENCE_ID;
  l_Structure_Type_Name :=  Get_Structure_Type_Name(p_bill_sequence_id =>
                                                    g_Rev_Comp_Unexp_Rec.BILL_SEQUENCE_ID);

-- Bug 8874286 end

  IF (l_Structure_Type_Name ='Packaging Hierarchy') THEN
    IF p_rev_component_rec.quantity_per_assembly < 0
    THEN
      Error_Handler.Add_Error_Token
                  ( p_message_name  => 'BOM_PKG_HIER_NEGATIVE_QTY'
                  , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                  , p_Token_Tbl     => g_Token_Tbl
                  );

      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF round(p_rev_component_rec.quantity_per_assembly) <> p_rev_component_rec.quantity_per_assembly
    THEN
      Error_Handler.Add_Error_Token
                  ( p_message_name  => 'BOM_PKG_HIER_FRACTIONAL_QTY'
                  , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                  , p_Token_Tbl     => g_Token_Tbl
                  );

      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
 END IF;

-- Component Type Rule Validations.
-- Bug No: 4397973. Check Component types only when the current retrun status is success.
IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
THEN
  IF ( p_rev_component_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE )
  THEN
 	Bom_Validate_Bom_Component.Check_Component_Type_Rule
   	(  x_return_status       => l_return_status
   	 , x_error_message       => l_debug_error_mesg
         , p_init_msg_list       => FALSE
   	 , p_parent_item_id      => p_Rev_Comp_Unexp_Rec.Revised_Item_Id
   	 , p_child_item_id       => p_Rev_Comp_Unexp_Rec.Component_Item_Id
   	 , p_organization_id     => p_Rev_Comp_Unexp_Rec.Organization_Id
   	);

   	IF (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
	  	Error_Handler.Add_Error_Token
	        ( p_Message_Text   => l_debug_error_mesg
	        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               );
   	END IF;
  END IF;
END IF;

	IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
	    ('Check Component Type Rule . . . ' || l_return_status) ;
	END IF ;

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Validation done . . . Return Status is ' || l_return_status); END IF;

		EXCEPTION

    		WHEN FND_API.G_EXC_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Expected Error in Rev. Comp. Entity Validation . . .'); END IF;

        		x_return_status := FND_API.G_RET_STS_ERROR;
			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('UNExpected Error in Rev. Comp. Entity Validation . . .'); END IF;

        		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        		IF FND_MSG_PUB.Check_Msg_Level
				(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        		THEN
            			l_err_text := G_PKG_NAME ||
						' : (Entity Validation) ' ||
						substrb(SQLERRM,1,200);
            			Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
			END IF;
			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    		WHEN OTHERS THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(SQLERRM || ' ' || TO_CHAR(SQLCODE)); END IF;
        		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                l_err_text := G_PKG_NAME ||
                                                ' : (Entity Validation) ' ||
                                                substrb(SQLERRM,1,200);
                                Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				);
                        END IF;
 			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_Entity;

	/***************************************************************
	* Procedure	: Check_Attribute (Validation)
	* Parameters IN	: Revised Component Record of exposed columns
	* Parameters OUT: Mesg_Token_Tbl
	*		  Return_Status
	* Purpose	: Attribute validation procedure will validate each
	*		  attribute of Revised component in its entirety. If
	*		  the validation of a column requires looking at some
	*		  other columns value then the validation is done at
	*		  the Entity level instead.
	*		  All errors in the attribute validation are accumulated
	*		  before the procedure returns with a Return_Status
	*		  of 'E'.
	*********************************************************************/
	PROCEDURE Check_Attributes
	( x_return_status	IN OUT NOCOPY VARCHAR2
	, x_Mesg_Token_Tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, p_rev_component_rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	, p_Rev_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	)
	IS

	l_return_status VARCHAR2(1);
	l_err_text	VARCHAR2(2000);
        l_assembly_item_id  NUMBER;
        l_org_id            NUMBER;
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

        CURSOR c_Geteffcontrol IS SELECT effectivity_control FROM mtl_system_items
         WHERE inventory_item_id = p_rev_comp_unexp_rec.component_item_id AND
         organization_id   = l_org_id;

	BEGIN

    		x_return_status := FND_API.G_RET_STS_SUCCESS;
    		l_return_status := FND_API.G_RET_STS_SUCCESS;

    		g_rev_component_rec := p_rev_component_rec;

    		-- Set the first token to be equal to the component_name
    		g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
    		g_Token_Tbl(1).Token_Value :=
				p_rev_component_rec.component_item_name;

               l_assembly_item_id :=  Bom_Globals.Get_Assembly_item_Id;
               l_org_id           :=  Bom_Globals.Get_Org_Id;

    		--
    		-- Check if the user is trying to create/update a record with
		-- missing value when the column value is required.
    		--
    		IF p_rev_component_rec.item_sequence_number = FND_API.G_MISS_NUM
    		THEN
			Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_ITEM_NUM_MISSING'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
        		 );
        		l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;

    		IF p_rev_component_rec.quantity_per_assembly =
					FND_API.G_MISS_NUM
    		THEN
        		Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_COMP_QUANTITY_MISSING'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
        		 );
        		l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;

    		IF p_rev_component_rec.projected_yield = FND_API.G_MISS_NUM
    		THEN
        		Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_COMP_YIELD_MISSING'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
        		 );
        		l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;

    		IF p_rev_component_rec.planning_percent = FND_API.G_MISS_NUM
    		THEN
        		Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_PLAN_PERCENT_MISSING'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
        		 );
        		l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;

    		IF p_rev_component_rec.quantity_related = FND_API.G_MISS_NUM
    		THEN
        		Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_QUANTITY_RELATED_MISSING'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
         		);
        		l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;

    		IF p_rev_component_rec.include_in_cost_rollup = FND_API.G_MISS_NUM
    		THEN
        		Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_INCL_IN_CST_ROLLUP_MISSING'
        		                        -- 'BOM_INCL_IN_COST_ROLLUP_MISSING'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
         		);
        		l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;

    		IF p_rev_component_rec.check_atp = FND_API.G_MISS_NUM
    		THEN
        		Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_CHECK_ATP_MISSING'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
         		);
        		l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;


    		IF p_rev_component_rec.acd_type IS NOT NULL AND
       		   p_rev_component_rec.acd_type NOT IN (1, 2, 3) AND
	 	   Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
    		THEN
			g_token_tbl(2).token_name  := 'ACD_TYPE';
			g_token_tbl(2).token_value := p_rev_component_rec.acd_type;

			Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_ACD_TYPE_INVALID'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
         		);
			l_return_status := FND_API.G_RET_STS_ERROR;
    		END IF;

    		--  Validate rev_component attributes

                  -- The following validation should not be done for serial effective items

          --     Validate from_end_item_unit_number  5482117

          IF  p_rev_component_rec.transaction_type =  BOM_GLOBALS.G_OPR_CREATE
             AND (p_rev_component_rec.from_end_item_unit_number IS NOT NULL AND  p_rev_component_rec.from_end_item_unit_number <>  FND_API.G_MISS_CHAR)
             AND BOM_EAMUTIL.Asset_group_Item(item_id => l_assembly_item_id, org_id  => l_org_Id) = 'N'
          THEN
            IF NOT  Bom_Validate.End_Item_Unit_Number
                ( p_from_end_item_unit_number => p_rev_component_rec.from_end_item_unit_number
                , p_revised_item_id => p_rev_comp_unexp_rec.component_item_id
                , x_err_text => l_err_text
                )
            THEN
              g_token_tbl(1).token_name  := 'FROM_END_ITEM_UNIT_NUMBER';
              g_token_tbl(1).token_value := p_rev_component_rec.from_end_item_unit_number;
              g_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
              g_token_tbl(2).token_value := p_rev_component_rec.component_item_name;
              g_token_tbl(3).token_name  := 'ORGANIZATION_CODE';
              g_token_tbl(3).token_value := p_rev_component_rec.organization_code;
              Error_Handler.Add_Error_Token
              ( p_Message_Name=> 'BOM_CMP_FROM_UNIT_NUM_INVALID'
               , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , p_Token_Tbl          => g_Token_Tbl
              );
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;

    		IF  p_rev_component_rec.transaction_type =
			BOM_GLOBALS.G_OPR_CREATE AND
        	    (p_rev_component_rec.to_end_item_unit_number IS NOT NULL
         	     AND
         	      p_rev_component_rec.to_end_item_unit_number <>
			FND_API.G_MISS_CHAR) AND
                     BOM_EAMUTIL.Asset_group_Item(
                                       item_id => l_assembly_item_id,
                                       org_id  => l_org_Id) = 'N'
    		THEN
        		IF NOT  Bom_Validate.End_Item_Unit_Number
                		( p_from_end_item_unit_number =>
                        	  p_rev_component_rec.to_end_item_unit_number
                		, p_revised_item_id =>
                        	  p_rev_comp_unexp_rec.component_item_id
                		, x_err_text => l_err_text
                		 )
        		THEN
            			l_return_status := FND_API.G_RET_STS_ERROR;
                     		g_token_tbl(1).token_name  :=
					'FROM_END_ITEM_UNIT_NUMBER';
                     		g_token_tbl(1).token_value :=
                                    p_rev_component_rec.to_end_item_unit_number;
                     		g_token_tbl(2).token_name  :=
						'REVISED_COMPONENT_NAME';
		     		g_token_tbl(2).token_value :=
                                    p_rev_component_rec.component_item_name;
		     		g_token_tbl(3).token_name  :=
						'ORGANIZATION_CODE';
		     		g_token_tbl(3).token_value :=
                                    p_rev_component_rec.organization_code;
		     		Error_Handler.Add_Error_Token
                     		( p_Message_Name=> 'BOM_CMP_TO_UNIT_NUM_INVALID'
                    		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    		 , p_Token_Tbl          => g_Token_Tbl
                     		);
            		END IF;
        	END IF;


 --   	END IF;

	-- Added in 11.5.9 by ADEY
	IF p_rev_component_rec.auto_request_material IS NOT NULL AND
       	   UPPER(p_rev_component_rec.auto_request_material) NOT IN ('Y','N')
 	THEN
		g_token_tbl(2).token_name  := 'AUTO_REQ_MATERIAL';
		g_token_tbl(2).token_value := p_rev_component_rec.auto_request_material;

		Error_Handler.Add_Error_Token
        		(  p_Message_Name       => 'BOM_AUTO_REQ_MAT_INVALID'
        		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        		 , p_Token_Tbl          => g_Token_Tbl
         		);
		l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;


      /* Comment Out by MK on 11/20/00
        -- This validation is not required
        -- Modified condition by MK on 11/08/00
    	IF p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_CREATE AND
           ( p_rev_component_rec.from_end_item_unit_number <> FND_API.G_MISS_CHAR OR
             p_rev_component_rec.from_end_item_unit_number IS NOT NULL ) AND
       	   ( p_rev_component_rec.to_end_item_unit_number = FND_API.G_MISS_CHAR OR
             p_rev_component_rec.to_end_item_unit_number IS NULL )
    	THEN
        	Error_Handler.Add_Error_Token
        	(  p_Message_Name       => 'BOM_CMP_TO_UNIT_NUM_NULL'
        	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        	 , p_Token_Tbl          => g_Token_Tbl
         	);
        	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;
      */

      -- Validations specific to EAM items (Asset Groups and Asset Activities)

      IF BOM_EAMUTIL.Enabled = 'Y' THEN

        IF BOM_EAMUTIL.Asset_group_Item( item_id => l_assembly_item_id,
                                         org_id  => l_org_id ) = 'Y' THEN

          -- An asset group can have only date effective components

          FOR effctrlrec IN c_Geteffcontrol
          LOOP
            IF effctrlrec.effectivity_control <> 1 THEN
              Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_EFFCONTROL_INVALID'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
			);
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END LOOP;

          -- Validate the from_end_item_unit_number

          IF NOT Bom_Validate.Asset_Group_Serial_Number
                          ( p_assembly_item_id => l_assembly_item_id,
                            p_organization_id           => l_org_id,
                            p_serial_number    => p_rev_component_rec.from_end_item_unit_number,
                            X_err_text         => l_err_text ) THEN
            g_token_tbl(2).token_name  := 'FROM_END_ITEM_UNIT_NUMBER';
 	    g_token_tbl(2).token_value :=
		p_rev_component_rec.from_end_item_unit_number;
            Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_INVALID_FROM_SERIAL_NO'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
                         , p_message_text       => l_err_text
			);
            l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          -- Validate the to_end_item_unit_number

          IF p_rev_component_rec.to_end_item_unit_number IS NOT NULL AND
             p_rev_component_rec.to_end_item_unit_number <> FND_API.G_MISS_CHAR
          THEN

            IF NOT Bom_Validate.Asset_Group_Serial_Number
                          ( p_assembly_item_id => l_assembly_item_id,
                            p_organization_id           => l_org_id,
                            p_serial_number    => p_rev_component_rec.to_end_item_unit_number,
                            X_err_text         => l_err_text ) THEN
              g_token_tbl(2).token_name  := 'TO_END_ITEM_UNIT_NUMBER';
 	      g_token_tbl(2).token_value :=
		p_rev_component_rec.to_end_item_unit_number;
              Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_INVALID_TO_SERIAL_NO'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
                         , p_message_text       => l_err_text
			);
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;

          -- An asset group or activity cannnot be a component of another asset group

          IF BOM_EAMUTIL.Asset_Activity_Item(
               item_id => p_rev_comp_unexp_rec.component_item_id,
               org_id  => l_org_id )= 'Y'
             OR
             BOM_EAMUTIL.Asset_Group_Item(
               item_id => p_rev_comp_unexp_rec.component_item_id,
               org_id  => l_org_id ) = 'Y' THEN

              g_token_tbl(2).token_name  := 'COMPONENT_ITEM_NAME';
 	      g_token_tbl(2).token_value :=
		p_rev_component_rec.component_item_name;
              Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_COMP_CANNOT_BE_AN_AG'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
			);
              l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

        -- Asset activity items cannot have any supply types other than Push
        -- and Bulk

        IF BOM_EAMUTIL.Asset_Activity_Item( item_id => l_assembly_item_id,
                                            org_id  => l_org_id ) = 'Y' THEN
          IF p_rev_component_rec.wip_supply_type NOT IN (1,4) THEN
            g_token_tbl(2).token_name  := 'WIP_SUPPLY_TYPE';
 	    g_token_tbl(2).token_value :=
		p_rev_component_rec.wip_supply_type;
            Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_INVALID_AA_SUPTYPES'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
			);
            l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          -- An asset group cannnot be a component for an asset activity

          IF BOM_EAMUTIL.Asset_Group_Item(
               item_id => p_rev_comp_unexp_rec.component_item_id,
               org_id  => l_org_id ) = 'Y' THEN

              g_token_tbl(2).token_name  := 'COMPONENT_ITEM_NAME';
 	      g_token_tbl(2).token_value :=
		p_rev_component_rec.component_item_name;
              Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_COMP_CANNOT_BE_AN_AG'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
			);
              l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

      END IF; -- End of attribute validations for EAM items


      IF  p_rev_component_rec.wip_supply_type IS NOT NULL  AND
		p_rev_component_rec.wip_supply_type = 7
    	THEN
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
			g_token_tbl(2).token_name  := 'WIP_SUPPLY_TYPE';
			g_token_tbl(2).token_value :=
				p_rev_component_rec.wip_supply_type;
        		Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_WIP_SUPPLY_TYPE_7'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
			);
			g_token_tbl.delete(2);
       		END IF;
       		l_return_status := FND_API.G_RET_STS_ERROR;

    	ELSIF p_rev_component_rec.wip_supply_type IS NOT NULL AND
	  	p_rev_component_rec.wip_supply_type <> 7 AND
          	NOT Bom_Validate.Wip_Supply_Type
	      	(  p_wip_supply_type	=> p_rev_component_rec.wip_supply_type
	         , x_err_text		=> l_err_text
	         )
    	THEN
        	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
			g_token_tbl(1).token_name  := 'WIP_SUPPLY_TYPE';
                	g_token_tbl(1).token_value :=
                                p_rev_component_rec.wip_supply_type;

                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_WIP_SUPPLY_TYPE_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	);
                	g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                	g_token_tbl(1).token_value :=
                                p_rev_component_rec.component_item_name;

        	END IF;
        	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF  p_rev_component_rec.operation_sequence_number IS NOT NULL AND
		p_rev_component_rec.operation_sequence_number <= 0
    	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_OPSEQ_LESS_THAN_ZERO'
		  	 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 	 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
		 	);
		END IF;
            	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

-- 	dbms_output.put_line('After Operation Sequence Num . . . ' || l_return_status);

    	IF  p_rev_component_rec.item_sequence_number IS NOT NULL AND
		( p_rev_component_rec.item_sequence_number < 0 OR
	  	/* p_rev_component_rec.item_sequence_number > 9999999 */
	  	 p_rev_component_rec.item_sequence_number > (power(10,38)-1) /*
bug 7437710 */
	)
    	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_ITEM_NUM_INVALID'
			 , p_Mesg_token_Tbl	=> l_Mesg_token_Tbl
                	 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_token_tbl		=> g_Token_Tbl
			);
        	END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF  p_rev_component_rec.projected_yield IS NOT NULL AND
		p_rev_component_rec.projected_yield < 0 OR
		p_rev_component_rec.projected_yield > 1
    	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
		THEN
			g_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
			g_token_tbl(1).token_value := p_rev_component_rec.component_item_name;
			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_COMPYIELD_OUT_OF_RANGE'
                	 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_token_tbl		=> g_token_tbl
			 , p_message_type       => 'W' -- Bug 3226917
			);
        	END IF;
		--l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF p_rev_component_rec.include_in_cost_rollup IS NOT NULL AND
       		p_rev_component_rec.include_in_cost_rollup NOT IN (1,2)
    	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_INCL_IN_COST_ROLL_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	);
        	END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF p_rev_component_rec.SO_Basis IS NOT NULL AND
       		p_rev_component_rec.SO_Basis NOT IN (1, 2)
    	THEN
        	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_SO_BASIS_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	);
        	END IF;
        	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF p_rev_component_rec.optional IS NOT NULL AND
       		p_rev_component_rec.optional NOT IN (1, 2)
    	THEN
         	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_OPTIONAL_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	);
        	END IF;
        	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF p_rev_component_rec.mutually_exclusive IS NOT NULL AND
       		p_rev_component_rec.mutually_exclusive NOT IN (1, 2)
    	THEN
        	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_MUTUALLY_EXCLUSIVE_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	);
        	END IF;
        	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF p_rev_component_rec.check_atp IS NOT NULL AND
       		p_rev_component_rec.check_atp NOT IN (1, 2)
    	THEN
        	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_CHECK_ATP_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	);
        	END IF;
        	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    	IF p_rev_component_rec.shipping_allowed IS NOT NULL AND
       		p_rev_component_rec.shipping_allowed NOT IN (1, 2)
    	THEN
         	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_SHIPPING_ALLOWED_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
               		 );
        	END IF;
        	l_return_status := FND_API.G_RET_STS_ERROR;
    	END IF;

    IF p_rev_component_rec.required_to_ship IS NOT NULL AND
       p_rev_component_rec.required_to_ship NOT IN (1, 2)
    THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_REQUIRED_TO_SHIP_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.required_for_revenue IS NOT NULL AND
       p_rev_component_rec.required_for_revenue NOT IN (1, 2)
    THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_REQ_FOR_REVENUE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.include_on_ship_docs IS NOT NULL AND
       p_rev_component_rec.include_on_ship_docs NOT IN (1, 2)
    THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_INCL_ON_SHIP_DOCS_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.quantity_related IS NOT NULL AND
       p_rev_component_rec.quantity_related NOT IN (1, 2)
    THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_QTY_RELATED_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Validation specific to unimplemented BOM
    Error_handler.write_debug ('BOM Implementation date is '||p_rev_comp_unexp_rec.bom_implementation_date);

    IF p_rev_comp_unexp_rec.bom_implementation_date IS NULL
    /* added a dummy condition to make sure this validation happens for any BOM, no matter whether the BOM is fluid or not */
    OR 1=1
    THEN
      IF p_rev_component_rec.new_effectivity_date IS NOT NULL AND
       p_rev_component_rec.new_effectivity_date <> FND_API.G_MISS_DATE AND
       Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
      THEN
	/* Check revision exists for revised item */
	IF NOT Item_Revision_Exists(p_rev_comp_unexp_rec.revised_item_id,
				p_rev_comp_unexp_rec.organization_id,
				p_rev_component_rec.new_effectivity_date)
	THEN
          g_token_tbl(1).token_name := 'ITEM_NAME';
          g_token_tbl(1).token_value := p_rev_component_rec.revised_item_name;
          g_token_tbl(2).token_name := 'EFFECTIVITY_DATE';
          g_token_tbl(2).token_value := p_rev_component_rec.start_effective_date;
          g_token_tbl(3).token_name := 'NEW_EFFECTIVE_DATE';
          g_token_tbl(3).token_value := p_rev_component_rec.new_effectivity_date;

          Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_DATE_LESS_ITEMREV'
           , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , p_Token_Tbl          => g_Token_Tbl
           );
          l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	/* Check revision exists for component item */

        IF NOT Item_Revision_Exists(p_rev_comp_unexp_rec.component_item_id,
                                p_rev_comp_unexp_rec.organization_id,
                                p_rev_component_rec.new_effectivity_date)
        THEN
          g_token_tbl(1).token_name := 'ITEM_NAME';
          g_token_tbl(1).token_value := p_rev_component_rec.component_item_name;
          g_token_tbl(2).token_name := 'EFFECTIVITY_DATE';
          g_token_tbl(2).token_value := p_rev_component_rec.start_effective_date;
          g_token_tbl(3).token_name := 'NEW_EFFECTIVE_DATE';
          g_token_tbl(3).token_value := p_rev_component_rec.new_effectivity_date;

          Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_DATE_LESS_ITEMREV'
           , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , p_Token_Tbl          => g_Token_Tbl
           );
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    ELSE
        /* The validation to check the new effective date < sysdate has been commented since the business objects should be able to support migrating the old data from legacy system into apps. The new date validation is always done
in the UI   */

      Null;

   /*  commented for bug 3281414
      IF p_rev_component_rec.new_effectivity_date IS NOT NULL AND
       p_rev_component_rec.new_effectivity_date <> FND_API.G_MISS_DATE AND
       p_rev_component_rec.new_effectivity_date < SYSDATE AND
       Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
      THEN
        g_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
        g_token_tbl(1).token_value := p_rev_component_rec.component_item_name;
        g_token_tbl(2).token_name := 'EFFECTIVITY_DATE';
        g_token_tbl(2).token_value := p_rev_component_rec.start_effective_date;
        g_token_tbl(3).token_name := 'NEW_EFFECTIVE_DATE';
        g_token_tbl(3).token_value := p_rev_component_rec.new_effectivity_date;

        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'BOM_NEW_DATE_LESS_CURR'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;

      END IF;
   */
    END IF;

    /* added a condition to make sure this validation happens during create for any BOM, no matter whether the BOM is fluid or not */
    IF (p_rev_comp_unexp_rec.bom_implementation_date IS NULL )
     /*  OR (p_rev_component_rec.transaction_type = BOM_GLOBALS.G_OPR_CREATE)*/
   --Commented for bug 5702625.
    THEN
      IF p_rev_component_rec.start_effective_date IS NOT NULL AND
       p_rev_component_rec.start_effective_date <> FND_API.G_MISS_DATE AND
       Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
      THEN
        /* Check revision exists for revised item */
    	Error_handler.write_debug ('Checking for item revision start date');
        IF NOT Item_Revision_Exists(p_rev_comp_unexp_rec.revised_item_id,
                                p_rev_comp_unexp_rec.organization_id,
                                p_rev_component_rec.start_effective_date)
        THEN
    	  Error_handler.write_debug ('Checking for item revision start date error');
          g_token_tbl(1).token_name := 'ITEM_NAME';
          g_token_tbl(1).token_value := p_rev_component_rec.revised_item_name;
          --g_token_tbl(1).token_value := to_char(p_rev_comp_unexp_rec.revised_item_id)||':'||to_char(p_rev_comp_unexp_rec.organization_id)||':'||to_char(p_rev_component_rec.start_effective_date,'dd-mon-yyyy hh24:mi:ss');
          g_token_tbl(2).token_name := 'EFFECTIVITY_DATE';
          g_token_tbl(2).token_value := p_rev_component_rec.start_effective_date;

          Error_Handler.Add_Error_Token(
            p_Message_Name       => 'BOM_SDATE_LESS_ITEMREV'
           , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , p_Token_Tbl          => g_Token_Tbl
           );
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /* Check revision exists for component item */

        IF NOT Item_Revision_Exists(p_rev_comp_unexp_rec.component_item_id,
                                p_rev_comp_unexp_rec.organization_id,
                                p_rev_component_rec.start_effective_date)
        THEN
          g_token_tbl(1).token_name := 'ITEM_NAME';
          g_token_tbl(1).token_value := p_rev_component_rec.component_item_name;
          --g_token_tbl(1).token_value := to_char(p_rev_comp_unexp_rec.component_item_id)||':'||to_char(p_rev_comp_unexp_rec.organization_id)||':'||to_char(p_rev_component_rec.start_effective_date,'dd-mon-yyyy hh24:mi:ss');
          g_token_tbl(2).token_name := 'EFFECTIVITY_DATE';
          g_token_tbl(2).token_value := p_rev_component_rec.start_effective_date;

          Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_SDATE_LESS_ITEMREV'
           , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
           , p_Token_Tbl          => g_Token_Tbl
           );
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    ELSE

      /* The validation to check the start effective date > sysdate has been commented
	 since the business objects should be able to support migrating the old data
         from legacy system into apps. The start date validation is always done in the UI*/

	Null;

      /*
      IF p_rev_component_rec.start_effective_date IS NOT NULL AND
       p_rev_component_rec.start_effective_date <> FND_API.G_MISS_DATE AND
       trunc(p_rev_component_rec.start_effective_date) < trunc(SYSDATE) AND
       Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
      THEN
        g_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
        g_token_tbl(1).token_value := p_rev_component_rec.component_item_name;
        g_token_tbl(2).token_name := 'EFFECTIVITY_DATE';
        g_token_tbl(2).token_value := p_rev_component_rec.start_effective_date;

        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'BOM_START_DATE_LESS_CURR'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;

      END IF;
      */

    END IF;

    -- Validation specific to enforce integer requirements

    IF p_rev_comp_unexp_rec.enforce_int_requirements_code = 1 /* If the enforce int req is 'Up' */
    THEN

      BEGIN
		/* Enforce_Integer can be UP only if the component item's rounding control type allows
		   to round order quantities */

           SELECT 'x' INTO l_dummy FROM mtl_system_items WHERE
            inventory_item_id = p_rev_comp_unexp_rec.component_item_id
            AND organization_id = p_rev_comp_unexp_rec.organization_id
            AND rounding_control_type = 1;

	    EXCEPTION WHEN NO_DATA_FOUND THEN
		      g_token_tbl.DELETE;
        	Error_Handler.Add_Error_Token
        	(  p_Message_Name       => 'BOM_ENFORCE_INT_INVALID'
         	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         	, p_Token_Tbl          => g_Token_Tbl
         	);
        	l_return_status := FND_API.G_RET_STS_ERROR;
	    END;

    END IF;

   --Validation to ensure that a pending structure header cannot be modified without an ECO
      IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Checking if the BOM header is implemented . . .'); END IF;

   IF BOM_GLOBALS.Get_Bill_Header_ECN(p_rev_comp_unexp_rec.bill_Sequence_id) IS NOT NULL
      AND (p_rev_component_rec.eco_name IS NULL OR p_rev_component_rec.eco_name = FND_API.G_MISS_CHAR)
   THEN
      g_token_tbl(1).token_name := 'ALTERNATE';
      g_token_tbl(1).token_value := nvl(p_rev_component_rec.Alternate_BOM_Code, bom_globals.retrieve_message('BOM', 'BOM_PRIMARY'));
      g_token_tbl(2).token_name := 'ASSY_ITEM';
      g_token_tbl(2).token_value := p_rev_component_rec.Revised_Item_Name;
      g_token_tbl(3).token_name := 'CHANGE_NOTICE';
      g_token_tbl(3).token_value := BOM_GLOBALS.Get_Bill_Header_ECN(p_rev_comp_unexp_rec.bill_Sequence_id);

      Error_Handler.Add_Error_Token
      (  p_Message_Name       => 'BOM_HEADER_UNIMPLEMENTED'
       , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
       , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
       , p_Token_Tbl          => g_Token_Tbl
       );
      l_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

    --  Done validating attributes

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

		EXCEPTION

    		WHEN OTHERS THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Some unknown error in Attribute Validation . . .' || SQLERRM ); END IF;

			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> NULL
                 	 , p_Message_Text	=>
					'Error in Rev Comp Attr. Validation '
					   || SUBSTR(SQLERRM, 1, 30) || ' ' ||
					   to_char(SQLCODE)
                 	 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Mesg_Token_Tbl	=> l_Mesg_token_Tbl
		 	);
			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	END Check_Attributes;


	/*******************************************************************
	* Procedure	: Check_Entity_Delete
	* Parameters IN	: Revised Component Exposed Column Record
	*		  Revised Component unexposed column record
	* Parameters OUT: Message Token Table
	*		  Return Status
	* Procedure	: Will check if a component can be deleted.
	*******************************************************************/
	PROCEDURE Check_Entity_Delete
	( x_return_status          IN OUT NOCOPY VARCHAR2
	, x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, p_rev_component_rec      IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	, p_Rev_Comp_Unexp_Rec     IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	)
	IS
	l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

	BEGIN

    		g_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
    		g_Token_Tbl(1).Token_Value :=
				p_rev_component_rec.component_item_name;

   		--
   		-- Verify that the component is not already cancelled.
   		--
   		IF p_rev_component_rec.Transaction_Type =
			BOM_GLOBALS.G_OPR_DELETE
		THEN
    			BEGIN
        			SELECT 'Component cancelled'
          			INTO l_dummy
          			FROM sys.dual
         			WHERE NOT EXISTS
	       			(SELECT 1 from bom_inventory_components
                 		  WHERE component_sequence_id =
		       		     p_rev_comp_Unexp_rec.component_sequence_id
				)
           			AND EXISTS (SELECT 1 from eng_revised_components
                        		     WHERE component_sequence_id =
			      	    p_rev_comp_Unexp_rec.component_sequence_id);

        		--
        		-- if not exception is raised then record is deleted.
			-- so raise an error.
        		--
        			IF FND_MSG_PUB.Check_Msg_Level
				(FND_MSG_PUB.G_MSG_LVL_ERROR)
        			THEN
             				Error_Handler.Add_Error_Token
	     				(  p_Message_Name=> 'BOM_COMP_CANCELLED'
	     		 		, p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
	     		 		, x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
	     				 , p_Token_Tbl	=> g_Token_Tbl
	      				);
        			END IF;
        			l_return_status := FND_API.G_RET_STS_ERROR;
        			EXCEPTION
                			WHEN NO_DATA_FOUND THEN
                        		null; -- do nothing the record is valid.
     			END;
    	END IF;

   	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
   	x_return_status := l_return_status;

	EXCEPTION

    		WHEN FND_API.G_EXC_ERROR THEN

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_return_status := FND_API.G_RET_STS_ERROR;

    		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    		WHEN OTHERS THEN
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	END Check_Entity_Delete;

	/******************************************************************
	* Procedure     : Check_Existence
	* Parameters IN : Revised component exposed column record
	*                 Revised component unexposed column record
	* Parameters OUT: Old Revised component exposed column record
	*                 Old Revised component unexposed column record
	*                 Mesg Token Table
	*                 Return Status
	* Purpose       : Check_Existence will query using the primary key
	*                 information and return a success if the operation is
	*                 CREATE and the record EXISTS or will return an
	*                 error if the operation is UPDATE and record DOES NOT
	*                 EXIST.
	*                 In case of UPDATE if record exists, then the procedure
	*                 will return old record in the old entity parameters
	*                 with a success status.
	*********************************************************************/
	PROCEDURE Check_Existence
	(  p_rev_component_rec      IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_rev_comp_unexp_rec     IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , x_old_rev_component_rec  IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
	 , x_old_rev_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_return_status          IN OUT NOCOPY VARCHAR2
	)
	IS
        	l_token_tbl      Error_Handler.Token_Tbl_Type;
        	l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
        	l_return_status  VARCHAR2(1);
	BEGIN
        	l_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
        	l_Token_Tbl(1).Token_Value :=
				p_rev_component_rec.component_item_name;
		l_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
        	l_Token_Tbl(2).Token_Value :=
				p_rev_component_rec.revised_item_name;

        	Bom_Bom_Component_Util.Query_Row
		( p_Component_Item_Id => p_rev_comp_unexp_rec.component_item_id
		, p_Operation_Sequence_Number =>
				p_rev_component_rec.operation_sequence_number
		, p_Effectivity_Date	=>
				p_rev_component_rec.start_effective_date
		, p_Bill_Sequence_Id	=> p_rev_comp_unexp_rec.bill_sequence_id
		, p_from_end_item_number=>
				p_rev_component_rec.from_end_item_unit_number
		, p_mesg_Token_tbl	=> l_mesg_token_tbl
		, x_Rev_Component_Rec	=> x_old_rev_component_rec
		, x_Rev_Comp_Unexp_Rec  => x_old_rev_comp_unexp_rec
		, x_mesg_Token_tbl 	=> l_mesg_token_tbl
		, x_Return_Status	=> l_return_status
		);

        	IF l_return_status = BOM_Globals.G_RECORD_FOUND AND
           	p_rev_component_rec.transaction_type = BOM_Globals.G_OPR_CREATE
        	THEN
                	Error_Handler.Add_Error_Token
                	(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                	 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                	 , p_message_name  => 'BOM_REV_COMP_ALREADY_EXISTS'
                	 , p_token_tbl     => l_token_tbl
                	 );
                 	l_return_status := FND_API.G_RET_STS_ERROR;
        	ELSIF l_return_status = BOM_Globals.G_RECORD_NOT_FOUND AND
              		p_rev_component_rec.transaction_type IN
                	(BOM_Globals.G_OPR_UPDATE, BOM_Globals.G_OPR_DELETE)
        	THEN
                	Error_Handler.Add_Error_Token
                	(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                	 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                	 , p_message_name  => 'BOM_REV_COMP_DOESNOT_EXIST'
                	 , p_token_tbl     => l_token_tbl
                 	);
                 	l_return_status := FND_API.G_RET_STS_ERROR;
        	ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
        	THEN
                	Error_Handler.Add_Error_Token
                	(  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_message_name       => NULL
                	 , p_message_text       =>
                  	 'Unexpected error while existence verification of ' ||
                  	 'Revised component '||
		  	 p_rev_component_rec.component_item_name
                	 , p_token_tbl          => l_token_tbl
                	 );
        	ELSE


                  /* Assign the relevant transaction type for SYNC operations */

                  IF p_rev_component_rec.transaction_type = 'SYNC' THEN
                    IF l_return_status = Bom_Globals.G_RECORD_FOUND THEN
                      x_old_rev_component_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_UPDATE;
                    ELSE
                      x_old_rev_component_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_CREATE;
                    END IF;
                  END IF;
                  l_return_status := FND_API.G_RET_STS_SUCCESS;

        	END IF;

        	x_return_status := l_return_status;
        	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_Existence;

	/******************************************************************
	* Prcoedure	: Check_Lineage
	* Parameters IN	: Revised Component exposed column record
	*		  Revised Component unexposed column record
	* Parameters OUT: Mesg_Token_Tbl
	*		  Return_Status
	* Purpose	: Check_Lineage procedure will verify that the entity
	*		  record that the user has passed is for the right
	*		  parent and that the parent exists.
	*********************************************************************/
	PROCEDURE Check_Lineage
	(  p_rev_component_rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_rev_comp_unexp_rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status	IN OUT NOCOPY VARCHAR2
	)
	IS
		CURSOR c_GetComponent IS
		SELECT revised_item_sequence_id
	  	FROM bom_inventory_components
	 	WHERE component_item_id = p_rev_comp_unexp_rec.component_item_id
	   	AND bill_sequence_id  = p_rev_comp_unexp_rec.bill_sequence_id
	   	AND operation_seq_num =
				p_rev_component_rec.operation_sequence_number
	   	AND effectivity_date = p_rev_component_rec.start_effective_date;

		l_Token_Tbl		Error_Handler.Token_Tbl_Type;
		l_return_status 	VARCHAR2(1);
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

	BEGIN
		l_return_status := FND_API.G_RET_STS_SUCCESS;

		/*************************************************************
		--
		-- In case of an update, based on the revised item information
		-- Bill Sequence Id and Revised Item Sequence Id is queried from
		-- the database. The revised item sequence id can however be
		-- different from that in the database and should be checked
		-- and given an error.
		*************************************************************/

		IF p_rev_component_rec.transaction_type IN
	   	   (BOM_Globals.G_OPR_UPDATE, BOM_Globals.G_OPR_DELETE,
	    	    BOM_Globals.G_OPR_CANCEL)
		THEN
			FOR Component IN c_GetComponent LOOP
			 IF NVL(Component.revised_item_sequence_id, 0) <>
			    NVL(p_rev_comp_unexp_rec.revised_item_sequence_id,0)
			 THEN
					l_Token_Tbl(1).token_name  :=
						'REVISED_COMPONENT_NAME';
					l_Token_Tbl(1).token_value :=
					p_rev_component_rec.component_item_name;
					l_Token_Tbl(2).token_name  :=
						'REVISED_ITEM_NAME';
					l_Token_Tbl(2).token_value :=
					p_rev_component_rec.revised_item_name;
					l_token_tbl(3).token_name := 'ECO_NAME';
					l_token_tbl(3).token_value :=
					p_rev_component_rec.eco_name;

					Error_Handler.Add_Error_Token
					(  p_Message_Name =>
						'BOM_REV_ITEM_MISMATCH'
					 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
					 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
					 , p_Token_Tbl	    => l_Token_Tbl
					 );
					l_return_status :=
						FND_API.G_RET_STS_ERROR;
			  END IF;
			END LOOP;
		END IF;

		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END Check_Lineage;

	/*************************************************************
	* Procedure	: Check_Access
	* Parameters IN	: Revised Item Unique Key
	*		  Revised Component unique key
	* Parameters OUT: Mesg_Token_Tbl
	*		  Return_Status
	* Purpose	: Procedure will verify that the revised item and the
	*		  revised component is accessible to the user.
	********************************************************************/
	PROCEDURE Check_Access
	(  p_revised_item_name		IN  VARCHAR2
	 , p_revised_item_id		IN  NUMBER
	 , p_organization_id		IN  NUMBER
	 , p_change_notice		IN  VARCHAR2
	 , p_new_item_revision		IN  VARCHAR2
	 , p_effectivity_date		IN  DATE
         , p_new_routing_revsion        IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
         , p_from_end_item_number       IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
	 , p_component_item_id		IN  NUMBER
	 , p_operation_seq_num		IN  NUMBER
	 , p_bill_sequence_id		IN  NUMBER
	 , p_component_name		IN  VARCHAR2
	 , p_Mesg_Token_Tbl		IN  Error_Handler.Mesg_Token_Tbl_Type :=
				    Error_Handler.G_MISS_MESG_TOKEN_TBL
	 , p_entity_processed		IN  VARCHAR2 := 'RC'
	 , p_rfd_sbc_name		IN  VARCHAR2 := NULL
	 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status		IN OUT NOCOPY VARCHAR2
	)
	IS
		l_Token_Tbl		Error_Handler.Token_Tbl_Type;
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type :=
				p_Mesg_Token_Tbl;
		l_return_status		VARCHAR2(1);
		l_Rev_Comp_Item_Type	NUMBER;
		l_error_name		VARCHAR2(30);
        	l_is_comp_unit_controlled BOOLEAN := FALSE;
		l_is_item_unit_controlled BOOLEAN := FALSE;

		CURSOR c_CheckCancelled IS
		SELECT 1
	  	FROM sys.dual
	 	WHERE NOT EXISTS
			( SELECT component_sequence_id
		    	FROM bom_inventory_components
		   	WHERE component_item_id = p_component_item_id
		     	AND bill_sequence_id  = p_bill_sequence_id
		     	AND effectivity_date  = p_effectivity_date
		     	AND operation_seq_num = p_operation_seq_num
		 	) AND
			EXISTS
			( SELECT component_sequence_id
		    	    FROM eng_revised_components
		   	   WHERE component_item_id = p_component_item_id
                     	   AND bill_sequence_id  = p_bill_sequence_id
                     	   AND effectivity_date  = p_effectivity_date
                     	   AND operation_sequence_num = p_operation_seq_num
			   );

		CURSOR c_CheckDisabled IS
		SELECT component_item_id
	  	FROM bom_inventory_components
	 	WHERE component_item_id = p_component_item_id
           	AND bill_sequence_id  = p_bill_sequence_id
           	AND effectivity_date  = p_effectivity_date
           	AND operation_seq_num = p_operation_seq_num
	   	AND acd_type = 3;

        	CURSOR c_Check_Unit_Effective IS
        	SELECT effectivity_control
          	FROM mtl_system_items
         	WHERE inventory_item_id = p_component_item_id
           	AND organization_id   = p_organization_id;


	BEGIN
		l_return_status := FND_API.G_RET_STS_SUCCESS;

		/**********************************************************
		--
		-- Check if the user has access to the revised component's
		-- bom_item_type
		--
		***********************************************************/
		SELECT bom_item_type
	  	INTO l_rev_comp_item_type
	  	FROM mtl_system_items
	 	WHERE inventory_item_id = p_component_item_id
	   	AND organization_id   = p_organization_id;

		IF l_rev_comp_item_type NOT IN
	   	   (NVL(BOM_Globals.Get_MDL_Item_Access,0),
	   	    NVL(BOM_Globals.Get_OC_Item_Access,0),
	   	    NVL(BOM_Globals.Get_PLN_Item_Access,0),
	   	    NVL(BOM_Globals.Get_STD_Item_Access,0)
	  	    )
		THEN
			l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
			l_token_tbl(1).token_value := p_component_name;
			l_token_tbl(2).token_name  := 'BOM_ITEM_TYPE';
			l_token_tbl(2).translate   := TRUE;

                	IF l_rev_comp_Item_Type = 1
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'BOM_MODEL';
                	ELSIF l_rev_comp_Item_Type = 2
                	THEN
                      		l_Token_Tbl(2).Token_Value:='BOM_OPTION_CLASS';
                	ELSIF l_rev_comp_Item_Type = 3
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'BOM_PLANNING';
                	ELSIF l_rev_comp_Item_Type = 4
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'BOM_STANDARD';
                	END IF;

			Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_REV_COMP_ACCESS_DENIED'
                	 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                	 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                	 , p_Token_Tbl          => l_token_tbl
                 	);
		 	l_token_tbl.DELETE(2);
                 	l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

	IF l_rev_comp_item_type = 5 /* Product Family */
	THEN
		Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_REV_COMP_PRODUCT_FAMILY'
                 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 , p_Token_Tbl          => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	/****************************************************************
	--
	-- If revised item check is successful, then check if the revised
	-- component is not cancelled. This check will not prove useful for
	-- the revised item itself, since the check existence for a cancelled
	-- component would fail. But this procedure can be called by the
	-- child records of the revised component and make sure that the
	-- parent record is not cancelled.
	--
	********************************************************************/

	IF BOM_Globals.Is_RComp_Cancl IS NULL THEN
		FOR RevComp IN c_CheckCancelled
		LOOP
			l_token_tbl.DELETE;
			l_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
			l_Token_Tbl(1).Token_value := p_component_name;
			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_REV_COMP_CANCELLED'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> l_token_tbl
			);
			l_return_status := FND_API.G_RET_STS_ERROR;
		END LOOP;
	END IF;

        /*********************************************************************
         -- Added by AS on 07/06/99
         -- Checks that unit effective items are allowed only if the profile
         -- value allows them (profile value stored in system_information)
        *********************************************************************/

        IF NOT BOM_Globals.Get_Unit_Effectivity
	THEN
           	IF BOM_Globals.Get_Unit_Controlled_Component
		THEN
                	l_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
			l_token_tbl(1).token_value :=
                                    	p_component_name;
			l_token_tbl(2).token_name := 'ECO_NAME';
			l_token_tbl(2).token_value :=
                                    	p_change_notice;
			Error_Handler.Add_Error_Token
                	( p_Message_Name   => 'BOM_REV_COMP_UNIT_CONTROL'
                	, p_Mesg_Token_Tbl => l_mesg_token_tbl
                	, x_Mesg_Token_Tbl => l_mesg_token_tbl
                	, p_Token_Tbl      => l_token_tbl
                	);
                	l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
        ELSE
		IF NOT BOM_Globals.Get_Unit_Controlled_Item AND
		   BOM_Globals.Get_Unit_Controlled_Component
		THEN
                        l_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_token_tbl(1).token_value :=
                                        p_component_name;
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value :=
                                        p_change_notice;
                        Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_REV_ITEM_NOT_UNIT_CONTROL'
                        , p_Mesg_Token_Tbl => l_mesg_token_tbl
                        , x_Mesg_Token_Tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
	END IF;


        /**************************************************************
        -- Added by MK on 11/01/2000
        -- If bill sequence id is null(Trans Type : CREATE) and this revised
        --  item does not have primary bill, verify that parent revised
        -- item does not have routing sequence id which has alternate code.
        -- (Verify this eco is not only for alternate routing)
        --
        -- Moved to Engineering space to reslove ECO dependency
        -- by MK on 12/03/00
        IF p_bill_sequence_id IS NULL
        AND Not Check_RevItem_Alternate
                                    (  p_revised_item_id   =>  p_revised_item_id
                                     , p_organization_id   =>  p_organization_id
                                     , p_change_notice     =>  p_change_notice
                                     , p_new_item_revision =>  p_new_item_revision
                                     , p_new_routing_revsion => p_new_routing_revsion
                                     , p_effective_date    =>  p_effectivity_date
                                     , p_from_end_item_number => p_from_end_item_number
                                     )

        THEN

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(1).token_value := p_revised_item_name ;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_ADD_ALTERNATE'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );

                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        **************************************************************/



	/**************************************************************
	--
	-- If the Entity being processed is Reference Designator
	-- or subsitute component then check if the parent component is
	-- disabled. If it is then Error this record and also all the
	-- siblings
	--
	**************************************************************/
	IF p_entity_processed IN ('RFD', 'SBC')
	THEN
		FOR isdisabled IN c_CheckDisabled LOOP
			IF p_entity_processed = 'RFD'
			THEN
				l_error_name := 'BOM_RFD_COMP_ACD_TYPE_DISABLE';
				l_token_tbl(1).token_name  :=
					'REFERENCE_DESIGNATOR_NAME';
				l_token_tbl(1).token_value := p_rfd_sbc_name;
			ELSE
				l_error_name := 'BOM_SBC_COMP_ACD_TYPE_DISABLE';
				l_token_tbl(1).token_name  :=
                                        'SUBSTITUTE_ITEM_NAME';
                                l_token_tbl(1).token_value := p_rfd_sbc_name;
			END IF;

			l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
			l_token_tbl(2).token_value := p_component_name;

			l_return_status := FND_API.G_RET_STS_ERROR;

			 Error_Handler.Add_Error_Token
                        (  p_Message_Name       => l_error_name
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
		END LOOP;
	END IF;

	x_Return_Status := l_return_status;
	x_Mesg_Token_Tbl := l_mesg_token_tbl;

END Check_Access;

	/*************************************************************
	* Procedure	: Check_Direct_item_comps
	* Parameters IN	: Component Record
	* Parameters OUT: Component Record
	*		  Mesg_Token_Tbl
	*		  Return_Status
	* Purpose	: Procedure will verify that the component record, if
	*		  is a direct item component, is for EAM BOMs only,
	*		  has correct values for direct item specific attributes,
	*		  for normal item components, these attributes should
	*		  be ignored.
	********************************************************************/
PROCEDURE Check_Direct_item_comps
(    p_bom_component_rec       IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
   , p_bom_comp_unexp_rec      IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
   , x_bom_component_rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
   , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_Return_Status           IN OUT NOCOPY VARCHAR2
) IS
--	l_bom_component_rec	Bom_Bo_Pub.Bom_Comps_Rec_Type;
	l_Token_Tbl		Error_Handler.Token_Tbl_Type;
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_return_status		VARCHAR2(1);
BEGIN
	l_return_status := FND_API.G_RET_STS_SUCCESS;
	IF BOM_EAMUTIL.Direct_Item ( item_id => p_bom_comp_unexp_rec.Component_Item_Id,
                                     org_id  => p_bom_comp_unexp_rec.Organization_Id ) = 'N' THEN
		IF (p_bom_component_rec.Suggested_Vendor_Name IS NOT NULL
		 OR p_bom_component_rec.Suggested_Vendor_Name <> FND_API.G_MISS_CHAR)
		THEN
			x_bom_component_rec.Suggested_Vendor_Name := '';
--			x_bom_component_rec.Vendor_Id := '';
			Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_COMP_SUPPLIER_IGNORED'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
		END IF;
		IF (p_bom_component_rec.Unit_Price IS NOT NULL
		 OR p_bom_component_rec.Unit_Price <> FND_API.G_MISS_NUM)
		THEN
			x_bom_component_rec.Unit_Price := '';
			Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_COMP_PRICE_IGNORED'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
		END IF;
        /*  Commented as part of bug fix 3741040
	ELSE
		IF BOM_EAMUTIL.Asset_Group_Item ( item_id => p_bom_comp_unexp_rec.Assembly_Item_Id,
                                                  org_id  => p_bom_comp_unexp_rec.Organization_Id ) = 'N'
		AND BOM_EAMUTIL.Asset_Activity_Item ( item_id => p_bom_comp_unexp_rec.Assembly_Item_Id,
                                                      org_id  => p_bom_comp_unexp_rec.Organization_Id ) = 'N'
		THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	*/
	END IF;
--	l_bom_component_rec := x_bom_component_rec;
	x_Return_Status := l_return_status;
	x_Mesg_Token_Tbl := l_mesg_token_tbl;

END Check_Direct_item_comps;

PROCEDURE Validate_All_Attributes
(       p_bo_identifier                   IN VARCHAR2 := 'BOM',
        p_transaction_type                IN  VARCHAR2,
        p_revised_item_id                 IN  NUMBER,
        p_organization_id                 IN  NUMBER,
        p_organization_code               IN  VARCHAR2,
        p_alternate_bom_code              IN  VARCHAR2,
        p_bill_sequence_id                IN  NUMBER,
        p_bom_implementation_date         IN  DATE,
        p_component_sequence_id           IN  NUMBER,
        p_item_sequence_number            IN  NUMBER,
        p_operation_sequence_number       IN  NUMBER,
        p_new_operation_sequence_num      IN  NUMBER := NULL,
        p_component_item_id               IN  NUMBER,
        p_from_end_item_unit_number       IN  VARCHAR2 := NULL,
        p_to_end_item_unit_number         IN  VARCHAR2 := NULL,
        p_new_from_end_item_unit_num      IN  VARCHAR2 := NULL,
        p_start_effective_date            IN  DATE,
        p_new_effectivity_date            IN  DATE := NULL,
        p_disable_date                    IN  DATE := NULL,
        p_basis_type			  IN  NUMBER := NULL,
        p_quantity_per_assembly           IN  NUMBER := NULL,
        p_projected_yield                 IN  NUMBER := NULL,
        p_planning_percent                IN  NUMBER := NULL,
        p_quantity_related                IN  NUMBER := NULL,
        p_include_in_cost_rollup          IN  NUMBER := NULL,
        p_check_atp                       IN  NUMBER := NULL,
        p_acd_type                        IN  NUMBER := NULL,
        p_auto_request_material           IN  VARCHAR2 := NULL,
        p_wip_supply_type                 IN  NUMBER := NULL,
        p_Supply_SubInventory             IN  VARCHAR2 := NULL,
        p_supply_locator_id               IN  NUMBER := NULL,
        p_location_name                   IN  VARCHAR2 := NULL,
        p_SO_Basis                        IN  NUMBER := NULL,
        p_Optional                        IN  NUMBER := NULL,
        p_mutually_exclusive              IN  NUMBER := NULL,
        p_shipping_allowed                IN  NUMBER := NULL,
        p_required_to_ship                IN  NUMBER := NULL,
        p_required_for_revenue            IN  NUMBER := NULL,
        p_include_on_ship_docs            IN  NUMBER := NULL,
        p_enforce_int_reqs_code           IN  NUMBER := NULL,
        p_revised_item_name               IN  VARCHAR2 := NULL,
        p_component_item_name             IN  VARCHAR2 := NULL,
        p_minimum_allowed_quantity        IN  NUMBER := NULL,
        p_maximum_allowed_quantity        IN  NUMBER := NULL,
        p_Delete_Group_Name               IN  VARCHAR2 := NULL,
        p_eco_name                        IN  VARCHAR2 := NULL,
        p_comments                        IN  VARCHAR2 := NULL,
        p_pick_components                 IN  NUMBER := NULL,
        p_revised_item_sequence_id        IN  NUMBER := NULL,
        p_old_operation_sequence_num      IN  NUMBER := NULL,
        p_old_component_sequence_id       IN  NUMBER := NULL,
        p_old_effectivity_date            IN  DATE := NULL,
        p_old_rec_item_sequence_number    IN  NUMBER := NULL,
        p_Old_Rec_shipping_Allowed        IN  NUMBER := NULL,
        p_Old_rec_supply_locator_id       IN  NUMBER := NULL,
        p_Old_rec_supply_subinventory     IN  VARCHAR2 := NULL,
        p_old_rec_check_atp               IN  NUMBER := NULL,
        p_old_rec_acd_type                IN  NUMBER := NULL,
        p_old_rec_to_end_item_unit_num    IN  VARCHAR2 := NULL,
        p_original_system_reference       IN  VARCHAR2 := NULL,
        p_rowid                           IN  VARCHAR2 := NULL,
        x_return_status                  IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
        x_error_message                  IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2) IS

l_rev_component_rec      Bom_Bo_Pub.Rev_Component_Rec_Type;
l_rev_comp_unexp_rec     Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
l_old_rev_component_rec  Bom_Bo_Pub.Rev_Component_Rec_Type;
l_old_rev_comp_unexp_rec Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
l_return_status          VARCHAR2(1);
l_mesg_token_tbl         Error_Handler.Mesg_Token_Tbl_Type;

l_message_list           Error_Handler.Error_Tbl_Type;
l_debug_error_status     VARCHAR2(1);
l_debug_error_mesg       VARCHAR2(2000);
l_debug_filename         VARCHAR2(20) := 'compjbo'||to_char(sysdate,'MISS');
l_Assembly_Item_Name     VARCHAR2(2000);
l_Component_Item_Name    VARCHAR2(2000);


EXC_ERR_PVT_API_MAIN          EXCEPTION;

BEGIN

  /* Construct the exposed and unexposed records for
     component and call check_attributes. check_entity */

  Error_Handler.Initialize;
  Error_Handler.Set_Debug ('Y');
  Bom_Globals.Set_Debug ('Y');


  Error_Handler.Open_Debug_Session
        (  p_debug_filename    => l_debug_filename
         , p_output_dir        =>'/appslog/bis_top/utl/plm115dv/out'
         , x_return_status     => l_debug_error_status
         , x_error_mesg        => l_debug_error_mesg
  );

  if x_return_status <> 'S'
  then
    x_return_status := 'E';
    x_error_message := l_debug_error_mesg;
    return;
  end if;

  --Load environment information into the SYSTEM_INFORMATION record
  -- (USER_ID, LOGIN_ID, PROG_APPID, PROG_ID)

  Bom_Globals.Init_System_Info_Rec
                        (  x_mesg_token_tbl => l_mesg_token_tbl
                        ,  x_return_status  => l_return_status
                        );

  -- Initialize System_Information Unit_Effectivity flag

  IF (FND_PROFILE.DEFINED('PJM:PJM_UNITEFF_NO_EFFECT') AND
      FND_PROFILE.VALUE('PJM:PJM_UNITEFF_NO_EFFECT') = 'Y')
      OR (BOM_EAMUTIL.Enabled = 'Y')
  THEN
    Bom_Globals.Set_Unit_Effectivity (TRUE);
  ELSE
    Bom_Globals.Set_Unit_Effectivity (FALSE);
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    RAISE EXC_ERR_PVT_API_MAIN;
  END IF;

  Error_Handler.Write_Debug('After open debug  ');

  Error_Handler.Set_BO_Identifier(p_bo_identifier);
  Bom_Globals.Set_BO_Identifier(p_bo_identifier);

  /* Set the system information record values for assembly_item_id
     and org_id. These values will be used for validating serial effective
     assemblies */

  Bom_Globals.Set_Org_Id (p_organization_id);
  Bom_Globals.Set_Assembly_Item_Id (p_revised_item_id);

  Error_Handler.Write_Debug('after set org  ');

  x_return_status := 'S';

   /*Added code to get the parent name
   as the parent name is passed null
   BOM_VALIDATE_BOM_COMPONENT.Validate_All_Attributes from
   java call.*/
   IF (p_revised_item_name IS NULL)
   THEN
   	l_Assembly_Item_Name := Bom_Globals.Get_Item_Name(p_revised_item_id,
   	 		     	        	            p_organization_id);
   ELSE
      l_Assembly_Item_Name := p_revised_item_name;
   END IF;

   IF (p_component_item_name IS NULL)
   THEN
   	l_Component_Item_Name := Bom_Globals.Get_Item_Name(p_component_item_id,
   	 		     	        	            p_organization_id);
   ELSE
	l_Component_Item_Name := p_component_item_name;
   END IF;


  l_rev_component_rec.eco_name := p_eco_name;  -- ECO Specific

  l_rev_component_rec.organization_code :=
                                p_organization_code;
  l_rev_component_rec.revised_item_name :=
                                l_Assembly_Item_Name;
  l_rev_component_rec.new_revised_item_revision := NULL;
  Error_Handler.Write_Debug('0 ');
  Error_Handler.Write_Debug('p_start_Effective_date '||to_char(p_start_Effective_date,'YYYY-MM-DD HH24:MI:SS'));
  l_rev_component_rec.start_effective_date := p_start_Effective_date;
--  l_rev_component_rec.start_effective_date :=
--                                to_date(p_start_Effective_date,'YYYY-MM-DD HH24:MI:SS');

  l_rev_component_rec.new_effectivity_date :=
                                p_new_effectivity_date;

  l_rev_component_rec.disable_date :=
                                p_disable_date;

  Error_Handler.Write_Debug('1 ');
  l_rev_component_rec.operation_sequence_number :=
                                p_operation_sequence_number;
  l_rev_component_rec.component_item_name :=
                                l_Component_Item_Name;
  l_rev_component_rec.alternate_bom_code :=
                                p_alternate_bom_code;

  l_rev_component_rec.acd_type := p_acd_type; -- ECO Specific

  l_rev_component_rec.old_effectivity_date :=
                                p_old_effectivity_date; -- ECO Specific

  Error_Handler.Write_Debug('2 ');
  l_rev_component_rec.old_operation_sequence_number := p_old_operation_sequence_num; -- ECO Specific

  l_rev_component_rec.new_operation_sequence_number :=
                        p_new_operation_sequence_num;
  l_rev_component_rec.item_sequence_number :=
                                p_item_sequence_number;
  l_rev_component_rec.basis_type:=
                                p_basis_type;
  l_rev_component_rec.quantity_per_assembly :=
                                p_quantity_per_assembly;
  l_rev_component_rec.Planning_Percent :=
                                p_Planning_Percent;
  l_rev_component_rec.projected_yield :=
                                p_projected_yield;

  l_rev_component_rec.include_in_cost_rollup :=
                                p_include_in_cost_rollup;
  l_rev_component_rec.wip_supply_type :=
                                p_wip_supply_type;
  l_rev_component_rec.so_basis :=
                                p_so_basis;
  l_rev_component_rec.optional :=
                                p_optional;
  l_rev_component_rec.mutually_exclusive :=
                                p_mutually_exclusive;
  l_rev_component_rec.check_atp :=
                                p_check_atp;
  l_rev_component_Rec.shipping_allowed :=
                                p_shipping_allowed;
  l_rev_component_rec.required_to_ship :=
                                p_required_to_ship;
  l_rev_component_rec.required_for_revenue :=
                                p_required_for_revenue;
  l_rev_component_rec.include_on_ship_docs :=
                                p_include_on_ship_docs;
  l_rev_component_rec.quantity_related :=
                                p_quantity_related;
  l_rev_component_rec.supply_subinventory :=
                                p_supply_subinventory;
  l_rev_component_rec.location_name :=
                                p_location_name;
  l_rev_component_rec.minimum_allowed_quantity :=
                                p_minimum_allowed_quantity;
  l_rev_component_rec.maximum_allowed_quantity :=
                                p_maximum_allowed_quantity;
  l_rev_component_rec.comments :=
                                p_comments;
  /*
  l_rev_component_rec.attribute_category :=
                                p_attribute_category;
  l_rev_component_rec.attribute1 :=
                                p_attribute1;
  l_rev_component_rec.attribute2 :=
                                p_attribute2;
  l_rev_component_rec.attribute3 :=
                                p_attribute3;
  l_rev_component_rec.attribute4 :=
                                p_attribute4;
  l_rev_component_rec.attribute5 :=
                                p_attribute5;
  l_rev_component_rec.attribute6 :=
                                p_attribute6;
  l_rev_component_rec.attribute7 :=
                                p_attribute7;
  l_rev_component_rec.attribute8 :=
                                p_attribute8;
  l_rev_component_rec.attribute9 :=
                                p_attribute9;
  l_rev_component_rec.attribute10 :=
                                p_attribute10;
  l_rev_component_rec.attribute11 :=
                                p_attribute11;
  l_rev_component_rec.attribute12 :=
                                p_attribute12;
  l_rev_component_rec.attribute13 :=
                                p_attribute13;
  l_rev_component_rec.attribute14 :=
                                p_attribute14;
  l_rev_component_rec.attribute15 :=
                                p_attribute15;
  */
  l_rev_component_rec.original_system_reference :=
                                p_original_system_reference;
  l_rev_component_rec.transaction_type :=
                                p_transaction_type;
  Error_Handler.Write_Debug('3 ');
  l_rev_component_rec.From_End_Item_Unit_Number :=
                                p_From_End_Item_Unit_Number;
  l_rev_component_rec.To_End_Item_Unit_Number :=
                                p_To_End_Item_Unit_Number;
  l_rev_component_rec.New_From_End_Item_Unit_Number :=
                                p_New_From_End_Item_Unit_Num;
  l_rev_component_rec.New_Routing_Revision    := NULL ;
  l_rev_component_rec.auto_request_material :=
          p_auto_request_material;

  l_rev_comp_unexp_rec.organization_id :=
                                p_organization_id;
  l_rev_comp_unexp_rec.component_item_id :=
                                p_component_item_id;
  l_rev_comp_unexp_rec.component_sequence_id :=
                                p_component_sequence_id;
  l_rev_comp_unexp_rec.old_component_sequence_id :=
                                p_old_component_sequence_id;
  l_rev_comp_unexp_rec.revised_item_id :=
                                p_revised_item_id;
  l_rev_comp_unexp_rec.bill_sequence_id :=
                                p_bill_sequence_id;

  l_rev_comp_unexp_rec.pick_components :=
                                p_pick_components;
  l_rev_comp_unexp_rec.supply_locator_id :=
                                p_supply_locator_id;

  Error_Handler.Write_Debug('Rowid is '||p_rowid);
  l_rev_comp_unexp_rec.Rowid   :=
                                p_rowid ;
  /*
  l_rev_comp_unexp_rec.bom_item_type :=
                                p_bom_comp_unexp_rec.bom_item_type;
  l_rev_comp_unexp_rec.Delete_Group_Name :=
                                p_Delete_Group_Name ;
  l_rev_comp_unexp_rec.DG_Description    :=
                                p_DG_Description ;
  l_rev_comp_unexp_rec.DG_Sequence_Id    :=
                                p_bom_comp_unexp_rec.DG_Sequence_Id ;
  l_rev_component_rec.Enforce_Int_Requirements :=
                                p_Enforce_Int_Requirements;
  l_rev_component_rec.Row_Identifier := p_Row_Identifier;
  l_rev_component_rec.return_status :=
                                p_return_status;
  */

  l_rev_comp_unexp_rec.revised_item_sequence_id := p_revised_item_sequence_id; -- ECO Specific

  l_rev_comp_unexp_rec.Enforce_Int_Requirements_Code :=
                                p_Enforce_Int_Reqs_Code;
  Error_Handler.Write_Debug('4 ');

  l_rev_comp_unexp_rec.bom_implementation_date   :=
                                p_bom_implementation_date;

  /* Assign the values for teh OLD record */

   l_old_rev_component_rec.item_sequence_number :=
                p_old_rec_item_sequence_number;
   l_old_rev_component_rec.shipping_allowed :=
                p_Old_Rec_shipping_Allowed;
   l_old_rev_comp_unexp_rec.supply_locator_id :=
                p_Old_rec_supply_locator_id;
   l_old_rev_component_rec.supply_subinventory :=
                p_Old_rec_supply_subinventory;
   l_old_rev_component_rec.check_atp :=
                p_old_rec_check_atp;
   l_old_rev_component_rec.acd_type :=
                p_old_rec_acd_type;
   l_old_rev_component_rec.to_end_item_unit_number :=
                p_old_rec_to_end_item_unit_num;

  Error_Handler.Write_Debug('after assignement  ');
  /* validate parent access */

  Bom_Validate_Bom_Header.Check_Access
                ( p_assembly_item_id   => p_revised_item_id
                , p_organization_id    => p_organization_id
                , p_alternate_bom_code => p_alternate_bom_code
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => x_return_status
                );

  Error_Handler.Write_Debug('after check access  ');
  IF x_return_status <> 'S'
  THEN
    Error_Handler.Translate_And_Insert_Messages
        (  p_mesg_token_tbl     => l_mesg_token_tbl
         , p_application_id     => 'BOM'
         );

    Error_Handler.Get_Message_List( x_message_list => l_message_list);
    x_error_message := l_message_list(1).Message_Text;
    Error_Handler.Write_To_DebugFile;
    Error_Handler.Close_Debug_Session;

    Return;
  END IF;

  /* validate component access */

  Bom_Validate_Bom_Component.Check_Access
        (  p_organization_id         => p_organization_id
         , p_component_item_id       => p_component_item_id
         , p_component_name          => p_component_item_name
         , p_Mesg_Token_Tbl          => l_mesg_token_tbl
         , x_Mesg_Token_Tbl          => l_mesg_token_tbl
         , x_Return_Status           => x_return_status
        );

  Error_Handler.Write_Debug('after component access  ');
  IF x_return_status <> 'S'
  THEN
    Error_Handler.Translate_And_Insert_Messages
        (  p_mesg_token_tbl     => l_mesg_token_tbl
         , p_application_id     => 'BOM'
         );

    Error_Handler.Get_Message_List( x_message_list => l_message_list);
    x_error_message := l_message_list(1).Message_Text;
    Error_Handler.Write_To_DebugFile;
    Error_Handler.Close_Debug_Session;

    Return;
  END IF;

  /* Set the value for unit controlled item in system information record*/

  Bom_Globals.Set_Unit_Controlled_Item (
              p_inventory_item_id => p_revised_item_id,
              p_organization_id   => p_organization_id);

  /* Perform the attribute validation */

  Bom_Validate_Bom_Component.Check_Attributes
     ( x_return_status              => x_return_status
        , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
        , p_rev_component_rec          => l_rev_component_rec
        , p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
     );

  IF x_return_status <> 'S'
  THEN
    Error_Handler.Translate_And_Insert_Messages
        (  p_mesg_token_tbl     => l_mesg_token_tbl
         , p_application_id     => 'BOM'
         );

    Error_Handler.Get_Message_List( x_message_list => l_message_list);
    x_error_message := l_message_list(1).Message_Text;
    Error_Handler.Write_To_DebugFile;
    Error_Handler.Close_Debug_Session;

    Return;
  END IF;

  /* Mark the Validate plm flag in BOM Globals to 'Y' to avoid the
     following validations
     1. Overlap
     2. Check Operation sequence number uniqueness
     3. Checking ACD TYPE when there is no primary bill
  */
  Bom_Globals.Set_Validate_For_Plm('Y');

  /* Perform the entity validation */

  Bom_Validate_Bom_Component.Check_Entity
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  p_old_rev_component_rec      => l_old_rev_component_rec
                ,  p_old_rev_comp_unexp_rec     => l_old_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => x_Return_Status
                );

  Error_Handler.Write_Debug('after check entity  ');
  IF x_return_status <> 'S'
  THEN
    Error_Handler.Translate_And_Insert_Messages
        (  p_mesg_token_tbl     => l_mesg_token_tbl
         , p_application_id     => 'BOM'
         );

    Error_Handler.Get_Message_List( x_message_list => l_message_list);
    x_error_message := l_message_list(1).Message_Text;

    Error_Handler.Write_To_DebugFile;
    Error_Handler.Close_Debug_Session;

  END IF;
  EXCEPTION WHEN OTHERS THEN
    x_error_message := SQLCODE||'/'||SQLERRM;
    Error_Handler.Write_To_DebugFile;
    Error_Handler.Close_Debug_Session;

END;

-- add for bug 8639519
/********************************************************************
* Function      : Check_PTO_ATO_For_Optional (Local Function)
* Returns       : 0 if Success
*                 1 if Optional value is incorrect for ATO/PTO Model/OC
*                 2 if Optional value is incorrect for Plan/Stdd Bill
* Purpose       : Function will verify the following things:
*                 1. Optional must be NO (2) if Bill if Pln or Standard
*                 2. If Bill is PTO Model or OC and component is
*                    ATO Std with no base mdl then Optional must be Yes
*                     (1)
*                       -1. Error
***********************************************************************/
-- Check if the PTO and ATO flags of Assembly and Component for the
-- Optional flag to be correct.
--
FUNCTION Check_PTOATO_For_Optional( p_assembly_org_id IN NUMBER,
				     p_assembly_item_id IN NUMBER,
				     p_comp_org_id IN NUMBER,
				     p_comp_item_id IN NUMBER)
        RETURN NUMBER
IS
        l_Comp_Item_Type        NUMBER; -- Bom_Item_Type of Component
        l_Assy_Item_Type        NUMBER; -- Bom_Item_Type of Assembly
        l_Comp_ATO_flag         CHAR;   -- ATO flag for Component
        l_Assy_PTO_flag         CHAR;   -- PTO flag for Assembly
        l_Comp_Config           CHAR;   -- Is component a config item
BEGIN
         SELECT assy.bom_item_type,
          assy.pick_components_flag,
          comp.bom_item_type,
          comp.replenish_to_order_flag,
          DECODE(NVL(comp.base_item_id, 0), 0 , 'N', 'Y')
          INTO  l_Assy_Item_Type,
                l_Assy_PTO_flag,
                l_Comp_Item_Type,
                l_Comp_ATO_flag,
                l_Comp_Config
          FROM  mtl_system_items assy,
                mtl_system_items comp
         WHERE  assy.organization_id   = p_assembly_org_id
           AND  assy.inventory_item_id = p_assembly_item_id
           AND  comp.organization_id   = p_comp_org_id
           AND  comp.inventory_item_id = p_comp_item_id;

     IF ( l_Assy_PTO_flag = 'Y'
             AND l_Assy_Item_Type IN ( Bom_Globals.G_MODEL, Bom_Globals.G_OPTION_CLASS)
             AND l_Comp_ATO_flag = 'Y'
             AND l_Comp_Item_Type = Bom_Globals.G_STANDARD
             AND l_Comp_Config = 'N'
            )
                THEN
                        RETURN 1;
                ELSIF ( l_Assy_Item_Type IN (Bom_Globals.G_STANDARD, Bom_Globals.G_PLANNING) )
                THEN
                        RETURN 2;
                ELSE
                        RETURN 0;
                END IF;
        EXCEPTION WHEN OTHERS THEN
                RETURN -1;
END;





END BOM_VALIDATE_BOM_COMPONENT;

/
