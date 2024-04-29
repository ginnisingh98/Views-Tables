--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE_REV_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE_REV_COMPONENT" AS
/* $Header: ENGLCMPB.pls 115.55 2002/12/13 00:13:19 bbontemp ship $ */

--  Global constant holding the package name

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'ENG_Validate_Rev_Component';
l_dummy				       VARCHAR2(80);
l_MODEL			      CONSTANT NUMBER := 1;
l_OPTION_CLASS		      CONSTANT NUMBER := 2;
l_PLANNING		      CONSTANT NUMBER := 3;
l_STANDARD		      CONSTANT NUMBER := 4;
l_Sub_Locator_Control	      NUMBER;
l_locator_control	      NUMBER;
l_org_locator_control  	      NUMBER;
l_item_locator_control 	      NUMBER;
l_item_loc_restricted	      NUMBER; -- 1,if Locator is Restricted, else 2

g_Comp_Item_Type        NUMBER; -- Bom_Item_Type of Component
g_Assy_Item_Type        NUMBER; -- Bom_Item_Type of Assembly
g_Comp_ATO_flag         CHAR;   -- ATO flag for Component
g_Assy_ATO_flag         CHAR;   -- ATO flag for Assembly
g_Comp_PTO_flag         CHAR;   -- PTO flag for Component
g_Assy_PTO_flag         CHAR;   -- PTO flag for Assembly
g_Comp_Config           CHAR;   -- Is component a config item
g_Comp_ATO_Forecast_Control NUMBER;  -- Component items ATO Forecast Control
g_Assy_Config           CHAR;   -- Is assembly  a config item
g_Comp_Eng_Flag         CHAR;   -- Is component an Engineering Item
g_Assy_Eng_Flag		CHAR;	-- Is assembly an Engineering Item
g_Comp_ATP_Comp_flag    CHAR;   -- Components ATP Component Flag
g_Assy_ATP_Comp_flag    CHAR;   -- Assembly's ATP Component flag
g_Comp_ATP_Check_flag   CHAR;   -- Components ATP check flag
g_Assy_ATP_Check_flag   CHAR;   -- Assembly's ATP check flag
g_Assy_Wip_supply_Type  NUMBER; -- Assembly 's wip supply type
g_Comp_Wip_Supply_Type  NUMBER; -- Components WIP Supply Type
g_Assy_Bom_Enabled_flag	CHAR;	-- Assembly's bom_enabled_flag
g_Comp_Bom_Enabled_flag CHAR;	-- Component's bom_enabled_flag

g_rev_component_rec	      Bom_bo_Pub.Rev_Component_Rec_Type;
g_Rev_Comp_Unexp_Rec	      Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
g_Token_Tbl		      Error_Handler.Token_Tbl_Type;


/*****************************************************************************
* Procedure	: Check_Required
* Parameters IN	: Revised Component exposed column record
* Paramaters OUT: Return Status
*		  Mesg Token Table
* Purpose	: Procedure will check if the user has given all the required
*		  columns for the type of operation user is trying to perform.
*		  If the required columns are not filled in, then the record
*		  would get an error.
******************************************************************************/
PROCEDURE Check_Required
( x_return_status               OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
)
IS
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	g_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
	g_token_tbl(1).token_value := p_rev_component_rec.component_item_name;

	IF p_rev_component_rec.acd_type IS NULL OR
	   p_rev_component_rec.acd_type = FND_API.G_MISS_NUM
	THEN
		Error_Handler.Add_Error_Token
                ( p_message_name       => 'ENG_ACD_TYPE_MISSING'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_Token_Tbl          => g_Token_Tbl
                );

		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	-- Return the message table.

	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Required;


 /***************************************************************************
 * Function	: Control (Local function)
 * Parameter IN	: Org Level Control
 *		  Subinventory Level Control
 *		  Item Level Control
 * Returns	: Number
 * Purpose	: Control procedure will take the various level control values
 *		  and decide if the Locator is controlled at the org,subinven
 *		  or item level. It will also decide if the locator is
 *		  pre-specified or dynamic.
 **************************************************************************/
 FUNCTION CONTROL(org_control      IN    number,
                    sub_control      IN    number,
                    item_control     IN    number default NULL)
                    RETURN NUMBER  IS
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

  /***************************************************************************
  * Function	: Check_Overlap_Dates (Local function)
  * Parameter IN: Effectivity Date
  *		  Disable Date
  *		  Bill Sequence Id
  *		  Component Item Id
  * Return	: True if dates are overlapping else false.
  * Purpose	: The function will check if the same component is entered
  *		  with overlapping dates. Components with overlapping dates
  *		  will get a warning.
  ***************************************************************************/
  FUNCTION Check_Overlap_Dates (X_Effectivity_Date DATE,
                                X_Disable_Date     DATE,
                                X_Member_Item_Id   NUMBER,
                                X_Bill_Sequence_Id NUMBER,
                                X_Rowid            VARCHAR2)
  RETURN BOOLEAN
  IS
  	X_Count NUMBER := 0;
        CURSOR X_All_Dates IS
                SELECT 'X' date_available FROM sys.dual
                 WHERE EXISTS (
                                SELECT 1 from BOM_Inventory_Components
                                 WHERE Component_Item_Id = X_Member_Item_Id
                                   AND Bill_Sequence_Id  = X_Bill_Sequence_Id
                                   AND (( RowId         <> X_RowID ) or
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

  /***************************************************************************
  * Function    : Check_Overlap_Numbers (Local function)
  * Parameter IN: from end item unit number
  *               to end item unit number
  *               Bill Sequence Id
  *               Component Item Id
  * Return      : True if unit numbers are overlapping, else false.
  * Purpose     : The function will check if the same component is entered
  *               with overlapping unit numbers. Components with overlapping
  *               unit numbers will get a warning.
  * History	: Created by AS on 07/08/99 as part of unit effectivity
  *		  functionality.
  ***************************************************************************/
  FUNCTION Check_Overlap_Numbers(X_From_End_Item_Number VARCHAR2,
                                 X_To_End_Item_Number VARCHAR2,
                                 X_Member_Item_Id   NUMBER,
                                 X_Bill_Sequence_Id NUMBER,
                                 X_Rowid            VARCHAR2)
  RETURN BOOLEAN
  IS
        X_Count NUMBER := 0;
        CURSOR X_All_Numbers IS
                SELECT 'X' unit_available FROM sys.dual
                 WHERE EXISTS (
                                SELECT 1 from BOM_Inventory_Components
                                 WHERE Component_Item_Id = X_Member_Item_Id
                                   AND Bill_Sequence_Id  = X_Bill_Sequence_Id
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

          -- If count <> 0 that means the unit numbers are overlapping with
          -- some record.
                IF X_Count <> 0 THEN
                        RETURN TRUE;
                ELSE
                        RETURN FALSE;
                END IF;

   END Check_Overlap_Numbers;

/****************************************************************************
* Function	: Verify_Item_Attributes
* Prameters IN	: Organization_Id
*		  Component Item Id
*		  Assembly Item Id
*		  Eng Bill flag for Assembly
* Parameters OUT: Mesg Token_Tbl
* Return	: True if no attributes are invalid and False otherwise
* Purpose	: The function will validate the following BOM Matrix.
*----------------------------------------------------------------------------
*                                    Component Types
*----------------------------------------------------------------------------
*Bill            PTO     ATO     PTO   ATO             ATO    PTO   Standard
*Types           Model   Model   OC    OC   Planning   Item   Item  Item
*-------------  ------------------------------------------------------------
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
*****************************************************************************/
FUNCTION Verify_Item_Attributes
	 (  p_Mesg_token_tbl 	IN  Error_Handler.Mesg_Token_Tbl_Type
          , x_Mesg_Token_Tbl	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type)
RETURN BOOLEAN
IS
dummy	NUMBER;
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

BEGIN
	l_Mesg_Token_Tbl := p_Mesg_Token_Tbl;

--dbms_output.put_line('Within the Verify Item Attributes procedure . . . ');

	-- Verify Eng flag for Assembly and Component
	IF g_Assy_Eng_Flag = 'N' and       -- Bill is manufacturing
	   g_Comp_Eng_Flag = 'Y'  	   -- and component is Engineering
	THEN
		Error_Handler.Add_Error_Token
		(  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_message_name	=> 'ENG_ASSY_COMP_ENG_FLG_MISMATCH'
		 , p_Token_Tbl		=> g_Token_Tbl
		 );
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		RETURN FALSE;
	END IF;

	/*******************************************************************
	-- Verify ATO MODEL OR ATO OPTION CLASS Assembly(not config) Attributes
	-- ATO Model does not allow
	-- 1. Planning Components
	-- 2. PTO Model or PTO Option Class
	-- 3. PTO Standard
	-- If the Assembly is ATO Standard, then it does not allow the
	-- above three types and
	-- 4. ATO Model or
	-- 5. ATO Option Class
	*******************************************************************/
	IF ( ( ( g_Assy_Item_Type IN (l_MODEL, l_OPTION_CLASS, l_STANDARD)  AND
	         g_Assy_ATO_flag  = 'Y' AND
		 g_Assy_Config = 'N'
	        )
	      ) AND
	      ( g_Comp_Item_Type = l_PLANNING OR
	        ( g_Comp_Item_Type IN (l_MODEL, l_OPTION_CLASS, l_STANDARD) AND
	          g_Comp_PTO_Flag  = 'Y'
	        )
	       )
	    ) OR
	    (
		g_Assy_Item_Type = l_STANDARD AND
		g_Assy_ATO_flag = 'Y'    AND
		g_Assy_Config = 'N' 	 AND
		( g_Comp_Item_Type IN (l_MODEL, l_OPTION_CLASS) AND
		  g_Comp_ATO_Flag = 'Y'
		)
	    )
	THEN
		IF g_Assy_Item_Type = l_MODEL
		THEN
			g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
			g_Token_Tbl(2).Token_Value := 'ENG_MODEL_TYPE';
			g_Token_Tbl(2).Translate := TRUE;
		ELSIF g_Assy_Item_Type = l_OPTION_CLASS
		THEN
			g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        g_Token_Tbl(2).Token_Value := 'ENG_OPTION_CLASS_TYPE';
                        g_Token_Tbl(2).Translate := TRUE;
		ELSE
			g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        g_Token_Tbl(2).Token_Value := 'ENG_STANDARD_TYPE';
                        g_Token_Tbl(2).Translate := TRUE;
		END IF;
			g_token_tbl(3).token_name  := 'REVISED_ITEM_NAME';
			g_token_tbl(3).token_value :=
					g_rev_component_rec.revised_item_name;

		IF g_Assy_Item_Type IN ( l_MODEL, l_OPTION_CLASS)
		THEN
			Error_Handler.Add_Error_Token
			( p_message_name	=> 'ENG_ATO_PROP_MISMATCH'
		 	, p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 	, x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 	, p_Token_Tbl		=> g_Token_Tbl
                	);
		ELSE
                        Error_Handler.Add_Error_Token
                        ( p_message_name        => 'ENG_ATO_STD_PROP_MISMATCH'
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
		-- 1. ATO Model
		-- 2. ATO Option Class
		-- 3. ATO Standard or
		-- 4. Standard item
		-- only if the assemly is Phantom is Wip_Supply_Type is 6
		*************************************************************/
	ELSIF g_Assy_ATO_Flag = 'Y' AND
	      g_Assy_Config   = 'Y'
	THEN
		IF g_Assy_Wip_Supply_Type <> 6 AND
		   ( ( g_Comp_Item_Type in (l_MODEL, l_OPTION_CLASS, l_STANDARD)
		       AND
		       g_Comp_ATO_Flag = 'Y'
		      ) OR
		      g_Comp_Item_Type = l_STANDARD
		    )
		THEN
			g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
			g_token_tbl(2).token_value :=
				g_rev_component_rec.revised_item_name;

			Error_Handler.Add_Error_Token
                	( p_message_name       => 'ENG_CFG_SUPPLY_NOT_PHANTOM'
                 	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, p_Token_Tbl          => g_Token_Tbl
                	);
			g_token_tbl.delete(2);

			x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
			RETURN FALSE;

		      /*******************************************************
		       -- Assembly is Config item with Wip Supply of Phantom
		       -- but the component item types do not match
		       *******************************************************/
		ELSIF g_Assy_Wip_Supply_Type = 6 AND
		      NOT
		      ( ( g_Comp_Item_Type IN
			  (l_MODEL, l_OPTION_CLASS, l_STANDARD)
                          AND
                          g_Comp_ATO_Flag = 'Y'
                         ) OR
                         g_Comp_Item_Type = l_STANDARD
                       )
		THEN
		 	g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                        g_token_tbl(2).token_value :=
                                g_rev_component_rec.revised_item_name;

			Error_Handler.Add_Error_Token
                        ( p_message_name       => 'ENG_CONFIG_PROP_MISMATCH'
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
	ELSIF g_Assy_Item_Type IN ( l_MODEL, l_OPTION_CLASS) AND
	      g_Assy_PTO_flag  = 'Y' AND
	      ( g_Comp_Item_Type = l_PLANNING OR
		( g_Comp_Item_Type = l_OPTION_CLASS AND
		  g_Comp_ATO_flag  = 'Y'
		)
	       )
	THEN
		IF g_Assy_Item_Type = l_MODEL
		THEN
                        g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        g_Token_Tbl(2).Token_Value := 'ENG_MODEL_TYPE';
                        g_Token_Tbl(2).Translate := TRUE;
                ELSIF g_Assy_Item_Type = l_OPTION_CLASS
                THEN
                        g_Token_Tbl(2).Token_Name := 'ITEM_TYPE';
                        g_Token_Tbl(2).Token_Value := 'ENG_OPTION_CLASS_TYPE';
                        g_Token_Tbl(2).Translate := TRUE;
		END IF;

		g_token_tbl(3).token_name  := 'REVISED_ITEM_NAME';
		g_token_tbl(3).token_value :=
				g_rev_component_rec.revised_item_name;

		Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_MODEL_OC_PROP_MISMATCH'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                 );

		g_Token_Tbl.DELETE(2);
		g_token_tbl.delete(3);
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                RETURN FALSE;

		/*************************************************************
		--
		-- PTO STandard will only allow Standard or PTO Standard
		--
		*************************************************************/
	ELSIF g_Assy_Item_Type = l_STANDARD AND
              g_Assy_PTO_Flag  = 'Y' AND
              NOT ( ( g_Comp_Item_Type = l_STANDARD AND
                      g_Comp_PTO_flag  = 'Y'
                    ) OR
                    ( g_Comp_Item_Type = l_STANDARD)
                  )
        THEN
		g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
		g_token_tbl(2).token_value :=
					g_rev_component_rec.revised_item_name;
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_PTO_STD_PROP_MISMATCH'
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
	ELSIF g_Assy_Item_Type = l_STANDARD AND
	      g_Assy_PTO_Flag = 'N' AND
	      g_Assy_ATO_Flag = 'N' AND
	      NOT
	      ( g_Comp_Item_Type = l_STANDARD AND
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
                (  p_message_name       => 'ENG_STANDARD_PROP_MISMATCH'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		g_token_tbl.delete(2);
                RETURN FALSE;

	END IF;


	-- Once the matrix is verified then check the ATP Components and ATP
	-- Check attributes

         IF ( g_Assy_ATP_Comp_flag = 'N' AND
              g_Comp_Atp_Check_Flag = 'Y'
	    )
	THEN
		g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                g_token_tbl(2).token_value :=
                                        g_rev_component_rec.revised_item_name;

		Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_ASSY_COMP_ATP_MISMATCH'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                 );
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		g_token_tbl.delete(2);
      		RETURN FALSE;  -- ATP Item Attribute Invalid
	END IF;
	--dbms_output.put_line('End of Item Attribute Validation . . .');

   -- If control comes till this point then it would mean a success of
   -- attribute validation. Hence,

   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
   RETURN TRUE;

END Verify_Item_Attributes;


/****************************************************************************
* Function	: Check_PTO_ATO_For_Optional (Local Function)
* Returns	: 0 if Success
*		  1 if Optional value is incorrect for ATO/PTO Model/OC
*		  2 if Optional value is incorrect for Planning/Standard Bill
* Purpose	: Function will verify the following things:
*		  1. Optional must be NO (2) if Bill if Planning or Standard
*		  2. If Bill is PTO Model or Option Class and component is
*		     ATO Standard with no base model then Optional must be Yes
*	 	     (1)
*****************************************************************************/
--
-- Check if the PTO and ATO flags of Assembly and Component for the
-- Optional flag to be correct.
--

FUNCTION  Check_PTO_ATO_for_Optional
	RETURN NUMBER
IS
BEGIN

	--dbms_output.put_line('Value of Optional when checking ATO / PTO . . .');

	IF ( g_Assy_PTO_flag = 'Y' 			    AND
	     g_Assy_Item_Type IN ( l_MODEL, l_OPTION_CLASS) AND
	     g_Comp_ATO_flag = 'Y' 			    AND
	     g_Comp_Item_Type = l_STANDARD 		    AND
	     g_Comp_Config = 'N' 			    AND
	     g_Rev_Component_Rec.optional = 2
	    )
	THEN
		RETURN 1;
	ELSIF ( g_Assy_Item_Type IN (l_STANDARD, l_PLANNING)  AND
	        g_Rev_Component_Rec.optional = 1
	       )
	THEN
		RETURN 2;
	ELSE
		RETURN 0;
	END IF;

END Check_PTO_ATO_for_Optional;

/*****************************************************************************
* Function	: Check_Planning_Percent
* Returns	: 0 for Success else 1, 2, or 3 for errors
* Purpose	: The function will verify the following:
*		  Planning percent can be <> 100 only if
*		  1. Bill is Planning else RETURN error code 1 Or
*		  2. Bill is a Model/Option Class and Component is optional Or
*		     else return error code 2.
*		  3. Bill is a Model/Option Class and component is not Optional
*		     and forecase control is = 2 (Consume and Derive)
*****************************************************************************/
FUNCTION Check_Planning_Percent RETURN NUMBER
IS
BEGIN
	IF g_rev_component_rec.planning_percent <> 100 THEN
		IF g_Assy_Item_Type = l_STANDARD THEN
			RETURN 1;
		ELSIF ( g_Assy_Item_Type IN (l_MODEL, l_OPTION_CLASS) AND
			g_rev_component_rec.optional <> 1 AND
			g_Comp_ATO_Forecast_Control  <> 2
		       )
		THEN
			RETURN 2;
		ELSIF ( g_Assy_Item_Type IN (l_MODEL, l_OPTION_CLASS) AND
                        ( g_rev_component_rec.optional = 1 OR
		 	  g_Comp_ATO_Forecast_Control <> 2
			 )
                       )
		THEN
			RETURN 3;
		ELSE
			RETURN 0;
		END IF;
	END IF;

END Check_Planning_Percent;

/****************************************************************************
* Function	: Chk_Req_For_Rev_Or_Shp
* Returns	: 1 if Required for Revenue is invalid
*		  2 if Required to Ship is invalid
*		  3 if both are incorrect
*		  0 if both are correct
* Purpose	: Function will verify the following:
*		  Required for Revenue / Required to Ship must be NO if
*		  Replenish_To_Order_Flag is 'Y' for the Bill
*****************************************************************************/
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


-- Local Function Check_ATP
/****************************************************************************
*Function	: Check_ATP
*Returns	: 1 if the ATP value is incorrect because qty is negative
*		  2 if the ATP value is incorrect because qty is fractional
*		  0 if the ATP value is valid.
*Purpose	: Function will verify if the Check_Atp value is correct
*		  wrt to the check_atp and atp_components_flag of the parent
*		  and component. It will also check if the component quantity
*		  is greater than 0 for the check_atp to be yes.
*****************************************************************************/
FUNCTION Check_ATP RETURN NUMBER
IS
BEGIN
--dbms_output.put_line('Withing Function Check_ATP . . .');

    IF g_Assy_ATP_Comp_flag = 'Y' AND
       g_Comp_ATP_Check_flag= 'Y'
    THEN
	IF g_rev_component_rec.quantity_per_assembly < 0 THEN

		RETURN 1;
	ELSIF round(g_rev_component_rec.quantity_per_assembly) <>
	      g_rev_component_rec.quantity_per_assembly
	THEN
		RETURN 2;
	ELSE
		RETURN 0;
	END IF;
    ELSE
	RETURN 1;
    END IF;

END Check_ATP;

/*****************************************************************************
* Function	: Check_Mutually_Exclusive
* Returns	: 0 if the Mutually exlusive values is correct
*		  1 if BOM is not Installed
*		  2 if Revised Component is Model or Option Class
* Purpose	: Will verify the value of mutually exclusive options column
*		  by verifying if BOM is Installed and the component is
*		  either a Model or Option Class. In only this case the column
*		  can have a value of Yes (1).
******************************************************************************/
--Local function to validate Mutually_Exclusive_Option
FUNCTION Check_Mutually_Exclusive RETURN NUMBER
IS
X_Bom_Status	VARCHAR2(80);
X_Industry	VARCHAR2(80);
X_Install_Bom	BOOLEAN;
BEGIN
	--dbms_output.put_Line('Checking Mutually Exclusive for value : ' ||
	--		   to_char(g_rev_component_rec.Mutually_Exclusive));
	IF g_rev_component_rec.Mutually_Exclusive = 1 THEN
 		X_install_bom := Fnd_Installation.Get
				 ( appl_id     => '702',
                                   dep_appl_id => '702',
                                   status      => X_bom_status,
                                   industry    => X_industry);
		IF UPPER(X_Bom_Status) = 'INSTALLED' AND
		   g_Comp_Item_Type IN (l_MODEL, l_OPTION_CLASS)
		THEN
			RETURN 0;
		ELSIF g_Comp_Item_Type NOT IN (l_MODEL, l_OPTION_CLASS)
		THEN
			RETURN 2;
		ELSE
			RETURN 1;
		END IF;
	ELSE
		RETURN 0;
	END IF;

END Check_Mutually_Exclusive;

/****************************************************************************
* Function	: Check_Supply_Type
* Returns	: TRUE if the supply type is correct, false otherwise
* Purpose	: Function will verify if the Wip_supply_Type value is
*		  is correct by doing the following checks:
*		  1. Wip_Supply_Type = 6 (Phantom), then component must have
*		     a bill, else log a warning.
*		  2. Wip_Supply_Type must be Phantom if the component is
*		     Model or Option Class
*****************************************************************************/
FUNCTION Check_Supply_Type
	 (  p_Mesg_Token_Tbl IN Error_Handler.Mesg_Token_Tbl_Type
	  , x_Mesg_token_tbl OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type)
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
			  g_rev_comp_unexp_rec.organization_id;

		    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		    RETURN TRUE;

		    EXCEPTION
			WHEN NO_DATA_FOUND THEN
            			Error_Handler.Add_Error_Token
				(  p_message_name	=> 'BOM_NO_BILL'
				 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
				 , p_Token_Tbl		=> g_Token_Tbl
                                 );
				x_Mesg_token_tbl := l_Mesg_Token_Tbl;
				RETURN TRUE;
				-- Since this is a warning return true
		  END;
		ELSE
			-- If component is Model/OC then WIP_Supply Type must
			-- be Phantom
			IF g_Comp_Item_Type IN (l_MODEL, l_OPTION_CLASS) AND
			   g_rev_component_rec.wip_supply_type <> 6
			THEN
                                    Error_Handler.Add_Error_Token
                                    ( p_message_name => 'ENG_WIP_SUPPLY_PHANTOM'
                                     ,p_Mesg_Token_Tbl=> l_Mesg_token_Tbl
                                     ,x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                                     ,p_token_tbl     => g_Token_Tbl
                                     );
				x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
--dbms_output.put_line('Returing False from Check Supply Type . . .');

                                RETURN FALSE;
			END IF;
	       END IF;
	ELSE
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		RETURN TRUE;
	END IF;

END Check_Supply_Type;

-- Local Function to verify Minimum Quantity.
FUNCTION Check_Min_Quantity RETURN BOOLEAN
IS
BEGIN
--dbms_output.put_line('Low Quantity : ' ||
--	             to_char(g_rev_component_rec.minimum_allowed_quantity));
	--dbms_output.put_line('Component Quantity : ' ||
		--	   to_char(g_rev_component_rec.quantity_per_assembly));
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
--dbms_output.put_line('High Quantity : ' ||
--		     to_char(g_rev_component_rec.maximum_allowed_quantity));
        --dbms_output.put_line('Component Quantity : ' ||
		--	 to_char(g_rev_component_rec.quantity_per_assembly));

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

--dbms_output.put_line('Checking Subinv value . . . ' ||
--			g_rev_component_rec.supply_subinventory);

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

--dbms_output.put_line('Subinventory is Restricted . . . ');

		IF l_allow_expense_to_asset = '1' THEN

--dbms_output.put_line('Allow Expense to Asset 1 . . .');

			OPEN c_Restrict_SubInv_Trk;
			FETCH c_Restrict_SubInv_Trk INTO l_Sub_Locator_Control;
--dbms_output.put_line('Within locator check ' || to_char(l_Sub_Locator_Control));

			IF c_Restrict_SubInv_Trk%Found THEN
				CLOSE c_Restrict_SubInv_Trk;
				RETURN TRUE;
			ELSE
--dbms_output.put_line('Sub loc in Subinv: ' || to_char(l_Sub_Locator_Control));

				CLOSE c_Restrict_SubInv_Trk;
				RETURN FALSE;
			END IF;
		ELSE
			IF l_InventoryAsset = 'Y' THEN

--dbms_output.put_line('Inventory Asset Yes . . .');

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
--dbms_output.put_line('Inventory Asset No . . .');

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

--dbms_output.put_line('Subinventory not restricted . . .');

		IF l_Allow_Expense_To_Asset = '1' THEN

--dbms_output.put_line('Allow Expense to Asset = 1  . . .');

			OPEN c_SubInventory_Tracked;
			FETCH c_SubInventory_Tracked INTO l_Sub_Locator_Control;
			IF c_SubInventory_Tracked%FOUND THEN
				CLOSE c_SubInventory_Tracked;
				RETURN TRUE;
			ELSE
				CLOSE c_SubInventory_Tracked;
				RETURN FALSE;
			END IF;
		ELSE
			IF l_InventoryAsset = 'Y' THEN
--dbms_output.put_line('Inventory Asset = Y . . .');

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
--dbms_output.put_line('Fetched from Subinventory Tracked . . .');

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
FUNCTION Check_Locators RETURN BOOLEAN IS
  Cursor CheckDuplicate is
        SELECT 'checking for duplicates' dummy
         FROM sys.dual
        WHERE EXISTS (
          SELECT null
            FROM mtl_item_locations
           WHERE organization_id = g_rev_comp_Unexp_rec.organization_id
             AND inventory_location_id = g_rev_comp_Unexp_rec.supply_locator_id
             AND subinventory_code <> g_rev_component_rec.supply_subinventory);

  x_Control NUMBER;
  l_Success	BOOLEAN;
BEGIN

  l_org_locator_control := 0 ;
  l_item_locator_control := 0;


--dbms_output.put_line('Within Check Locators function. . .');

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
  -- When a SubInventory is validated, then depending on the Cursor being
  -- used in the Check_SubInventory procedure, the value of
  -- l_Sub_Locator_Control would be set. Else if there is no change in subinv
  -- then excute subinv check.
  --

  --dbms_output.put_line('Checking Subinventory locator control,
	--		calling Check_Supply_SubInventory . . .');

  IF l_Sub_Locator_Control IS NULL AND
     g_rev_component_rec.supply_subinventory IS NOT NULL THEN
	l_Success := Check_Supply_SubInventory;
  END IF;

 --dbms_output.put_line('After calling Check_Supply_SubInventory in Check_Locators . . .');


  --
  -- Locator cannot be NULL is if locator restricted
  --
  IF g_rev_component_rec.location_name IS NULL
     AND l_item_loc_restricted = 1
  THEN
	l_locator_control := 4;
	RETURN FALSE;
  ELSIF g_rev_component_rec.location_name IS NULL
        AND l_item_loc_restricted = 2
  THEN
	RETURN TRUE;
  END IF;

--dbms_output.put_line('Within Check locators . . .');

  IF l_org_locator_control  is not null AND
     l_sub_locator_control  is not null AND
     l_item_locator_control is not null THEN
--dbms_output.put_line('Org _Control: ' || to_char(l_org_locator_control));
--dbms_output.put_line('Sub _Control: ' || to_char(l_sub_locator_control));
--dbms_output.put_line('Item Control: ' || to_char(l_item_locator_control));

     x_control := Control( Org_Control  => l_org_locator_control,
        		   Sub_Control  => l_sub_locator_control,
        		   Item_Control => l_item_locator_control
			  );


     l_locator_control := x_control;
	-- Variable to identify if the dynamic loc. message must be logged.

     IF x_Control = 1 THEN  -- No Locator Control
 	RETURN FALSE;  -- No Locator and Locator Id is supplied then raise Error
     ELSIF x_Control = 2 THEN   -- PRESPECIFIED
	BEGIN

--dbms_output.put_line('Checking when x_control returned 2 and item locator is '
--	 	      || to_char(l_item_locator_control));

	    -- If restrict locators is Y then check in mtl_secondary_locators
	    -- if the item is assigned to the subinventory/location combination
	    -- If restrict locators is N then check that the locator exists
	    -- and is assigned to the subinventory and this combination is
	    -- found in mtl_item_locations.

	    IF l_item_loc_restricted = 1  -- Restrict Locators  = YES
	    THEN

			-- **** Check for restrict Locators YES ****
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
		   AND mil.inventory_location_id = msl.secondary_locator
		   AND mil.organization_id =
					msl.organization_id
		   AND NVL(mil.disable_date, SYSDATE+1) > SYSDATE ;

		--If no exception is raised then the Locator is Valid
		RETURN TRUE;
	     ELSE
			-- **** Check for restrict Locators NO ****
		--dbms_output.put_line('Item restrict locators is NO . . .');
                SELECT 'Valid'
                  INTO l_dummy
                  FROM mtl_item_locations mil
                 WHERE mil.subinventory_code 	 =
		       g_rev_component_rec.supply_subinventory
                   AND mil.inventory_location_id =
		       g_rev_comp_Unexp_rec.supply_locator_id
		   AND mil.organization_id 	 =
		       g_rev_comp_Unexp_rec.organization_id
		   AND NVL(mil.DISABLE_DATE, SYSDATE+1) > SYSDATE;

                --If no exception is raised then the Locator is Valid
                RETURN TRUE;

	     END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN FALSE;
	END;

     ELSIF x_Control = 3 THEN   -- DYNAMIC LOCATORS ARE NOT ALLOWED IN OI.
		-- Dynamic locators are not allowed in open interface, so
		-- raise an error if the locator control is dynamic.
		l_locator_control := 3;
		RETURN FALSE;
     ELSE
		--dbms_output.put_line('Finally returing a true value . . .');
                RETURN TRUE;

     END IF; -- X_control Checking Ends

  ELSE
	RETURN TRUE;
  END IF;  -- If Locator Control check Ends.

END Check_Locators;

/*****************************************************************************
* Function	: Check_Op_Seq
* Returns	: 0 if new op_seq or op_seq is valid
* 		  1 if new_op_seq or op_seq does not exist
*		  2 if new_op_seq or op_seq is not unique
* Purpose	: Verify the following:
* 		  Function Check_Op_Seq will check if the op_seq_num or the
*		  new_op_seq_num exists.
*		  If they exist, then it will go ahead and check if the the same
*		  component does not already exist with the same op_seq_num
******************************************************************************/
FUNCTION Check_Op_Seq RETURN NUMBER
IS
CURSOR Valid_Op_Seq IS
       SELECT 'Valid' valid_op_seq
         FROM bom_operational_routings bor,
              bom_operation_sequences bos
        WHERE bor.assembly_item_id = g_rev_comp_Unexp_rec.revised_item_id
          AND bor.organization_id  = g_rev_comp_Unexp_rec.organization_id
          AND NVL(bor.alternate_routing_designator, 'NONE') =
              NVL(g_rev_component_rec.alternate_bom_code, 'NONE')
          AND bos.routing_sequence_id = bor.routing_sequence_id
          AND bos.operation_seq_num   =
	      decode( g_rev_component_rec.new_operation_sequence_number,
		      NULL,
		      g_rev_component_rec.Operation_Sequence_Number,
		      g_rev_component_rec.new_Operation_sequence_number
		     );

CURSOR c_Op_Seq_Used IS
	/* Verify that the same component is not already effective */
	SELECT 'Already Used' op_seq_used
	  FROM bom_inventory_components bic
         WHERE bic.bill_sequence_id    = g_rev_comp_Unexp_rec.bill_sequence_id
           AND bic.component_item_id   = g_rev_comp_Unexp_rec.component_item_id
           AND bic.operation_seq_num   =
	       decode( g_rev_component_rec.new_operation_sequence_number,
                       NULL,
                       g_rev_component_rec.operation_sequence_number,
                       g_rev_component_rec.new_operation_sequence_number
                      );
BEGIN

	-- If a record is found then it will mean that though
	-- the Operation Sequence exists in the Routings table
	-- a component already exist with that operation sequence abd
	-- Effectivity date so it cannot be inserted. So generate an error
	-- hence, this function will return a false.

	FOR l_valid_op IN  Valid_Op_Seq LOOP
		-- if operation_seq exists in Operation_Sequences then
		-- verify that the same  component does not already exist
		-- for that bill with the same operation seq.

		FOR l_Op_Seq_Used IN c_Op_Seq_Used LOOP
			RETURN 2;
			-- Op_seq_num or the new_op_seq_num is not unique
		END LOOP;

--dbms_output.put_line('Check Op Seq returing with Success (0) ');

		RETURN 0;  -- op_seq_num or new_op_seq_num is valid

	END LOOP;

	RETURN 1;
	-- op_seq_num or new_op_seq_num is invalid
	-- i.e does not exist in bom_oper_sequences

END Check_Op_Seq;


FUNCTION Check_Optional RETURN BOOLEAN
IS
CURSOR c_CheckOptional IS
	SELECT 'Valid' is_Valid
	  FROM mtl_system_items assy,
	       mtl_system_items comp
	 WHERE assy.organization_id = g_rev_comp_Unexp_rec.organization_id
	   AND assy.inventory_item_id = g_rev_comp_Unexp_rec.revised_item_id
	   AND comp.organization_id = g_rev_comp_Unexp_rec.organization_id
	   AND comp.inventory_item_id = g_rev_comp_Unexp_rec.component_item_id
	   AND ( ( assy.bom_item_type IN ( l_Planning, l_Standard)
	           AND g_rev_component_rec.optional = 2  /* NO */
	          )
	    	  OR
		  ( assy.bom_item_type IN ( l_Model, l_Option_Class)
		    AND assy.pick_components_flag = 'Y'
					/* PTO Model or PTO Option Class */
		    AND comp.bom_item_type = l_Standard
		    AND comp.replenish_to_order_flag = 'Y'
		    AND comp.base_item_id IS NULL
		    AND g_rev_component_rec.Optional = 1
		  )
		);

BEGIN
	-- Optional must be 2 if Bill is Planning or Standard.
	-- If the Bill is PTO Model or PTO Option Class and the Component
	-- is an ATO Standard item with no Base Model then Optional must be 1
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

/****************************************************************************
* Function	: Check_Common_Other_Orgs
* Return	: True if component exists in other orgs, False otherwise
* Purpose	: If component is being added to a bill that is being referenced
*		  by items (bills) in other orgs (as a common), the component
*		  must exist in those orgs as well, with the correct item
*		  attributes. This function will verify this and will return
*		  on success and false on failure.
******************************************************************************/
FUNCTION Check_Common_Other_Orgs
RETURN NUMBER
IS
  l_other_orgs   BOOLEAN;
  CURSOR bom_enabled_in_other_orgs IS
  	SELECT 1
        FROM BOM_BILL_OF_MATERIALS bom
        WHERE bom.common_bill_sequence_id =
	      g_rev_comp_Unexp_rec.bill_sequence_id
          AND bom.organization_id <> g_rev_comp_Unexp_rec.organization_id
          AND NOT EXISTS (SELECT 1
                          FROM MTL_SYSTEM_ITEMS msi
                          WHERE msi.organization_id = bom.organization_id
                            AND msi.inventory_item_id =
				g_rev_comp_Unexp_rec.component_item_id
                            AND msi.bom_enabled_flag = 'Y'
			  );

	CURSOR in_other_orgs IS
	SELECT 1
	  FROM BOM_BILL_OF_MATERIALS bom
         WHERE bom.common_bill_sequence_id =
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
        WHERE bom.common_bill_sequence_id =
              g_rev_comp_Unexp_rec.bill_sequence_id
          AND bom.organization_id <> g_rev_comp_Unexp_rec.organization_id
          AND NOT EXISTS (SELECT 1
                          FROM MTL_SYSTEM_ITEMS msi
                          WHERE msi.organization_id = bom.organization_id
                            AND msi.inventory_item_id =
                                g_rev_comp_Unexp_rec.component_item_id
                            AND msi.bom_enabled_flag = 'Y'
                            AND (( bom.assembly_type = 1 AND
                                   msi.eng_item_flag = 'N'
                                  )
                                  OR bom.assembly_type = 2
                                 )
                          );
BEGIN

	-- If component not in other Orgs that refer the bill as common
	-- then return an error code of 1

--dbms_output.put_line('Checking if component exists in other ORGS when bill is common . . .');

	FOR c_other_orgs IN in_other_orgs LOOP
        	RETURN 1;
        END LOOP;

--dbms_output.put_line('Checking if component is BOM enabled in other ORGS . . .');

	FOR c_bom_enabled IN bom_enabled_in_other_orgs LOOP
		RETURN 2;
	END LOOP;

--dbms_output.put_line('Checking if component is ENG flag is compatible in other ORGS . . .');

	FOR c_eng_flag IN eng_flag_in_other_orgs LOOP
		RETURN 3;
	END LOOP;

	RETURN 0;

END Check_Common_Other_Orgs;

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

/*****************************************************************************
* Procedure	: Check_Entity
* Parameters IN : Revised component exposed column record
*		  Revised component unexposed column record
*		  Revised component old exposed column record
*		  Revised component old unexposed column record
* Parameters OUT: Mesg _Token_Tbl
*		  Return Status
* Purpose	: Check_Entity validate the entity for the correct business
*		  logic. It will verify the values by running checks on inter-
*		  dependent columns. It will also verify that changes in one
*		  column value does not invalidate some other columns.
******************************************************************************/
PROCEDURE Check_Entity
( x_return_status		OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec   	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, p_Old_Rev_Component_Rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Old_Rev_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
)
IS
l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bill_sequence_id      NUMBER;
l_processed		BOOLEAN;
l_result		NUMBER;
l_Err_Text		VARCHAR2(2000);
l_bom_item_type		NUMBER;
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_is_comp_unit_Controlled BOOLEAN := FALSE;

CURSOR c_RefDesgs IS
SELECT count(component_sequence_id) number_of_desgs
  FROM bom_reference_designators
 WHERE component_sequence_id = p_rev_comp_unexp_rec.component_sequence_id;

CURSOR c_NewBill IS
	SELECT revised_item_id,
	       change_notice,
	       organization_id
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
CURSOR c_ItemNum IS
	SELECT 'Valid'
          FROM BOM_inventory_components
         WHERE item_num = p_rev_component_rec.item_sequence_number
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

CURSOR c_OE_installed IS
	SELECT distinct 'I'
	  FROM fnd_product_installations
	 WHERE application_id = 300
	   AND status = 'I';

Is_Item_ATO VARCHAR2(1) := 'N';
Is_Item_PTO VARCHAR2(1) := 'N';

CURSOR c_ATO_PTO IS
	SELECT mi.replenish_to_order_flag, mi.pick_components_flag
	  FROM mtl_system_items mi, eng_revised_items eri
	 WHERE mi.inventory_item_id = eri.revised_item_id
	   AND mi.organization_id = eri.organization_id
	   AND eri.revised_item_sequence_id =
	       p_rev_comp_Unexp_rec.revised_item_sequence_id;

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

BEGIN

        g_rev_component_rec := p_rev_component_rec;
        g_Rev_Comp_Unexp_Rec := p_Rev_Comp_Unexp_Rec;

--dbms_output.put_line('Subinventory. . . ' ||
--		     g_rev_component_rec.supply_subinventory);
--dbms_output.put_line('Locator . . . ' ||
--		     to_char(g_Rev_Comp_Unexp_Rec.supply_locator_id));


--dbms_output.put_line('Performing Revised component Entity Validation . . .');

    IF Bom_Globals.Get_Unit_Controlled_Item IS NULL
    THEN
	FOR Unit_Cont_Item IN Unit_Controlled_Item
        LOOP
                IF Unit_Cont_Item.Effectivity_Control = 2
                THEN
                        Bom_Globals.Set_Unit_Controlled_Item
                        ( p_unit_controlled_item => TRUE);
                ELSIF Unit_Cont_Item.Effectivity_Control = 1
                THEN
                        Bom_Globals.Set_Unit_Controlled_Item
                        ( p_unit_controlled_item => FALSE);
                END IF;
        END LOOP;
    END IF;

    l_is_comp_unit_controlled := Bom_GLOBALS.Get_Unit_Controlled_Component;

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
                comp.bom_item_type,
                comp.pick_components_flag,
                comp.replenish_to_order_flag,
                comp.wip_supply_type,
                DECODE(NVL(comp.base_item_id, 0), 0 , 'N', 'Y'),
                comp.eng_item_flag,
                comp.atp_components_flag,
                comp.atp_flag,
		comp.bom_enabled_flag,
		comp.ato_forecast_control
          INTO  g_Assy_Item_Type,
                g_Assy_PTO_flag,
                g_Assy_ATO_flag,
                g_Assy_Wip_Supply_Type,
                g_Assy_Config,
		g_Assy_Eng_Flag,
                g_Assy_ATP_Comp_flag,
                g_Assy_ATP_Check_flag,
		g_Assy_Bom_Enabled_flag,
                g_Comp_Item_Type,
                g_Comp_PTO_flag,
                g_Comp_ATO_flag,
                g_Comp_Wip_Supply_Type,
                g_Comp_Config,
                g_Comp_Eng_Flag,
                g_Comp_ATP_Comp_flag,
                g_Comp_ATP_Check_flag,
		g_Comp_Bom_Enabled_flag,
		g_Comp_ATO_Forecast_Control
          FROM  mtl_system_items assy,
                mtl_system_items comp
         WHERE  assy.organization_id   = g_rev_Comp_Unexp_Rec.Organization_Id
           AND  assy.inventory_item_id = g_rev_Comp_Unexp_Rec.revised_item_id
           AND  comp.organization_id   = g_rev_Comp_Unexp_Rec.Organization_Id
           AND  comp.inventory_item_id = g_rev_Comp_Unexp_Rec.Component_item_id;
--dbms_output.put_line('Queried all assembly and component attributes. . .');

	--
	-- Set the 1st token of Token Table to Revised Component value
	--
	g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
	g_Token_Tbl(1).Token_Value := p_rev_component_rec.component_item_name;

        -- The ECO can be updated but a warning needs to be generated and
        -- scheduled revised items need to be update to Open
        -- and the ECO status need to be changed to Not Submitted for Approval


        Bom_GLOBALS.Check_Approved_For_Process
	(p_change_notice    => p_rev_component_rec.eco_name,
         p_organization_id  => p_rev_comp_unexp_rec.organization_id,
         x_processed        => l_processed,
         x_err_text         => l_err_text
         );
        IF l_processed = TRUE
        THEN
        	-- If the above process returns true then set the ECO approval.
        	BEGIN
        		Bom_GLOBALS.Set_Request_For_Approval
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

	-- To End Item Unit Number must be greater than or equal to
	-- From End Item Unit Number

	IF NVL(p_rev_component_rec.From_End_Item_Unit_Number, FND_API.G_MISS_CHAR)
	   >
	   NVL(p_rev_component_rec.To_End_Item_Unit_Number, FND_API.G_MISS_CHAR)
	THEN
                g_token_tbl.delete;
		g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value :=
                                        g_rev_component_rec.component_item_name;
                Error_Handler.Add_Error_Token
                (  p_message_name       => 'ENG_TOUNIT_LESS_THAN_FROMUNIT'
                 , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_token_tbl          => g_token_tbl
                 );

                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

   --
   -- All validations that only apply to Operation Type  CREATE
   --
   IF p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE THEN

	-- When disabling a component, to end item number must be the same
	-- as the value in the bill component being disabled.

	IF g_rev_component_rec.acd_type = 3 AND
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
                	(  p_message_name       => 'ENG_DISABLE_TOUNIT_INVALID'
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

	IF g_rev_component_rec.acd_type = 1 AND
	   l_is_comp_unit_controlled AND
	   NOT Bom_Globals.Get_Unit_Controlled_Item
	THEN
                g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value :=
                                        g_rev_component_rec.component_item_name;
                g_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                g_token_tbl(2).token_value :=
                                        g_rev_component_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name       => 'ENG_CMP_UNIT_RIT_NOT_UNIT'
                 , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_token_tbl          => g_token_tbl
                 );

                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

        -- Unit controlled revised items can only have non-ATO or non-PTO
        -- standard items as components.
        -- Added by AS on 07/08/99 as part of unit effectivity changes

        IF g_rev_component_rec.acd_type = 1 AND
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
                (  p_message_name       => 'ENG_CMP_UNIT_TYPE_NOT_VALID'
                 , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_token_tbl          => g_token_tbl
                 );

                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	--
	-- Verify that the Parent has BOM Enabled
	--
	IF g_Assy_Bom_Enabled_flag <> 'Y'
	THEN
		g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
		g_token_tbl(1).token_value :=
					g_rev_component_rec.revised_item_name;

		Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_REV_ITEM_BOM_NOT_ENABLED'
		 , p_mesg_token_tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_token_tbl		=> g_token_tbl
		 );

		l_return_status := FND_API.G_RET_STS_ERROR;
		g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                g_token_tbl(1).token_value :=
                                        p_rev_component_rec.component_item_name;

	END IF;

	IF NOT Check_PrimaryBill THEN
--dbms_output.put_line('ACD type to be add if primary bill does not exist . . .');
		IF p_rev_component_rec.acd_type <> 1
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
				(  p_message_name   => 'ENG_CMP_ACD_TYPE_ADD'
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
                SELECT 'Valid'
                  INTO l_dummy
                  FROM eng_revised_items eri,
		       bom_bill_of_materials bom
                 WHERE eri.revised_item_sequence_id =
		       p_Rev_Comp_Unexp_Rec.revised_item_sequence_id
                   AND bom.bill_sequence_id         = eri.bill_sequence_id
                   AND bom.common_bill_sequence_id  <> bom.bill_sequence_id;

                -- If no exception is raised then Bill is referencing another
		-- bill
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
			g_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
			g_token_tbl(2).token_value :=
				p_rev_component_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'ENG_BILL_COMMON'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
			);
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                                NULL;
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
                    , p_Message_name    => 'ENG_COMP_SAME_AS_BILL'
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
	IF g_Comp_Bom_Enabled_Flag = 'N' THEN
               -- Bom_Enabled is N, so cannot add a component.
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                   Error_Handler.Add_Error_Token
		   (  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		    , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                    , p_Message_name	=> 'ENG_COMP_ITEM_BOM_NOT_ENABLED'
                    , p_token_tbl	=> g_token_tbl
		    );
               END IF;
               l_return_status := FND_API.G_RET_STS_ERROR;
   	END IF;

	/*******************************************************************
	--
	-- Item Num Check
	--
	********************************************************************/
	IF p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE
	   AND
	   ( p_rev_component_rec.acd_type = 1  OR
	     ( p_rev_component_rec.acd_type = 2 AND
	       p_rev_component_rec.item_sequence_number <>
	       p_old_rev_component_rec.item_sequence_number
	     )
	   )
   	THEN
             -- Verify if a component is already added using this item_num
	     -- If there is, log a WARNING.

                item_num_for_bill := 0;

                FOR Item_Num in c_ItemNum LOOP
                        item_num_for_bill := 1;
                END LOOP;

                IF item_num_for_bill = 1 THEN
                	Error_Handler.Add_Error_Token
			(  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                         , p_message_name	=> 'ENG_ITEM_NUM_INVALID'
			 , p_Token_Tbl		=> g_Token_Tbl
                         );
                END IF;

	END IF; -- Item Num Check ends

	/********************************************************************
	--
        -- Also verify that the component being added is not a Product Family
        --
	*********************************************************************/

	IF g_Comp_Item_Type = 5
	THEN
        	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
			(  p_message_name	=> 'ENG_ITEM_PRODUCT_FAMILY'
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

	--
	-- Verify if the revised item is being referenced as common in
	-- other orgs then it satisfies all the criteria required for the
	-- component to be on the bill.
	--
	l_result := Check_Common_Other_Orgs;

--dbms_output.put_line('Check Common_Other_Orgs returned with result ' || to_char(l_result));

	IF l_result <> 0
      	THEN
	     IF l_result = 1 THEN
		l_err_text := 'ENG_COMP_NOTEXIST_IN_OTHER_ORG';
	     ELSIF l_result = 2 THEN
		l_err_text := 'ENG_COMP_NOT_BOMENABLED';

	     ELSIF l_result = 3 THEN
		l_err_text := 'ENG_COMP_NOT_ENG_IN_OTHER_ORGS';
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

   IF p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
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
                        ( p_message_name    => 'ENG_SHIP_ALLOWED_NOT_UPDATE'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF p_rev_component_rec.old_effectivity_date IS NOT NULL AND
	   p_rev_component_rec.old_effectivity_date <> FND_API.G_MISS_DATE
	THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'ENG_OLD_EFFECTIVITY_GIVEN'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_rev_component_rec.old_operation_sequence_number IS NOT NULL AND
           p_rev_component_rec.old_operation_sequence_number <> FND_API.G_MISS_NUM
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'ENG_OLD_OP_SEQ_NUM_GIVEN'
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
	   p_old_rev_component_rec.acd_type
	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'ENG_ACD_TYPE_NOT_UPDATEABLE'
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
	IF p_old_rev_component_rec.acd_type = 3
	THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'ENG_COMPONENT_DISABLED'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_token_tbl      => g_token_tbl
                        );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	-- User cannot update to_end_item_unit_number when the component
	-- is disabled.

	IF p_rev_component_rec.acd_type = 3 AND
	   p_rev_component_rec.to_end_item_unit_number <>
		p_old_rev_component_rec.to_end_item_unit_number
	THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        ( p_message_name    => 'ENG_DISABLE_TOUNIT_NONUPD'
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
      (Bom_GLOBALS.G_OPR_CREATE, Bom_GLOBALS.G_OPR_UPDATE)
   THEN
	--
	-- Verify that the disable date is greater than effectivity date
	-- for both operations Create and Update
	--

	IF p_rev_component_rec.disable_date <
	   p_rev_component_rec.start_effective_date THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                	Error_Handler.Add_Error_Token
			(  p_message_name	=> 'ENG_COMP_DIS_DATE_INVALID'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> g_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	--dbms_output.put_line('Verified disable date . . . ' || l_return_status);

	/********************************************************************
	--
	-- Verify that the number of reference designators equals the component
	-- quantity if quantity related = 1
	--
	**********************************************************************/
	IF p_rev_component_rec.quantity_related = 1
	THEN
		FOR cnt_desg IN c_RefDesgs
		LOOP
			IF cnt_desg.number_of_desgs <>
				p_rev_component_rec.quantity_per_assembly
			THEN
				--
				-- Give a warning
				--
			     Error_Handler.Add_Error_Token
                             ( p_message_name  => 'ENG_QTY_REL_QTY_REF_DESG'
                              , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                              , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                              , p_Token_Tbl     => g_Token_Tbl
                        	);
			END IF;
		END LOOP;
	END IF;

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
                ( p_message_name  => 'ENG_QTY_REL_QTY_FRACTIONAL'
                , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , p_Token_Tbl     => g_Token_Tbl
                 );

		l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	/*********************************************************************
	--
	-- Verify yield factor
	-- IF Component is Option Class or bill is planning
	-- then yield must be 1
	-- If yield is >0 and less than 1 then give a warning.
	--
	*********************************************************************/
	IF p_rev_component_rec.projected_yield <> 1 THEN
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
				(  p_Message_Name    => 'ENG_COMP_YIELD_NOT_ONE'
				 , p_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
				 , p_Token_Tbl	     => g_Token_Tbl
                                 );
				g_token_tbl.delete(2);
                        END IF;
			l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	END IF;

	/********************************************************************
   	--
	-- If the Operation is Create with an Acd_Type of Change or Disable
	-- then component pointed to by old_component_sequence_id should
	-- already be implemented
	--
	*********************************************************************/

   	IF (p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE) AND
       	    p_rev_component_rec.acd_type  IN (2, 3)
   	THEN
--dbms_output.put_line('Old sequence: ' ||
--		     to_char(p_rev_comp_Unexp_rec.old_component_sequence_id));
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
			    (  p_message_name   => 'ENG_OLD_COMP_SEQ_ID_INVALID'
			     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			     , p_Token_Tbl	=> g_Token_Tbl
                             );
        		END IF;
        		l_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			--dbms_output.put_line(SQLERRM);
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

	/********************************************************************
	--
	-- If Operation_Seq_Num is not NULL then it must be unique in case of
	-- Creates and in Case of Updates new_operation_sequence must be valid
	-- if the user is trying to update operation_sequence_number
	--
	*********************************************************************/

	IF ( p_rev_component_rec.operation_sequence_number <> 1 AND
	     p_rev_Component_rec.ACD_Type = 1
	    ) OR
	   ( NVL(p_rev_component_rec.new_operation_sequence_number,1) <> 1 AND
	     ( ( p_rev_component_rec.ACD_Type = 2 AND
	         p_rev_component_rec.transaction_type =
		  Bom_Globals.G_OPR_CREATE
		) OR
		 p_rev_component_rec.transaction_type =
		  Bom_Globals.G_OPR_UPDATE
	      ) AND
	     NVL(p_old_rev_component_rec.operation_sequence_number, 1) <>
	     NVL(p_rev_component_rec.new_operation_sequence_number, 1)
	    )
	THEN
--dbms_output.put_line('Verifying operation Sequence Number. . . ');
--dbms_output.put_line('Op Seq Num: ' ||
--		      to_char(p_rev_component_rec.operation_sequence_number));
--dbms_output.put_line('New Op Seq Num: ' ||
--                    to_char(p_rev_component_rec.new_operation_sequence_number));
--dbms_output.put_line('Old Op Seq Num: ' ||
--                    to_char(p_rev_component_rec.old_operation_sequence_number));

		l_result := Check_Op_Seq;

		IF l_result = 1
		THEN
			IF FND_MSG_PUB.Check_Msg_Level
			   (FND_MSG_PUB.G_MSG_LVL_ERROR)
                	THEN
				g_Token_Tbl(1).Token_Name := 'REVISED_ITEM_NAME';
				g_Token_Tbl(1).Token_Value :=
					g_Rev_Component_rec.revised_item_name;
                        	Error_Handler.Add_Error_Token
				(  p_Message_Name   => 'ENG_OP_SEQ_NUM_INVALID'
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
                	END IF;
                	l_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF l_result = 2 THEN
                        IF FND_MSG_PUB.Check_Msg_Level
			   (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
			     g_Token_Tbl(2).Token_Name := 'OP_SEQ_NUM';
                             g_Token_Tbl(2).Token_Value :=
                             to_char
                             (g_Rev_Component_rec.operation_sequence_number);
                            Error_Handler.Add_Error_Token
			    (  p_message_name	=> 'ENG_OP_SEQ_NUM_NOT_UNIQUE'
			     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			     , p_Token_Tbl	=> g_Token_Tbl
                            );
                        END IF;
			g_Token_Tbl.DELETE(2);
                        l_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF l_result = 0 AND
		      p_Rev_Component_rec.old_operation_sequence_number
		      IS NOT NULL AND
		      p_Rev_Component_rec.old_operation_sequence_number <>
			FND_API.G_MISS_NUM
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

			IF FND_MSG_PUB.Check_Msg_Level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR) AND
			   l_result = 0
                        THEN
                             g_Token_Tbl(2).Token_Name := 'OLD_OP_SEQUENCE_NUM';
                             g_Token_Tbl(2).Token_Value :=
                             to_char
                            (g_Rev_Component_rec.old_operation_sequence_number);
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => 'ENG_OLD_OP_SEQ_NUM_GIVEN'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => g_Token_Tbl
                            );
                        END IF;
                        g_Token_Tbl.DELETE(2);
                        l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	END IF; -- Operation_seq_Num Check Ends.

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
	    X_Rowid		=> NULL)
      	THEN
           --if function return true then component dates overlapp

	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
           THEN
           	Error_Handler.Add_Error_Token
		(  p_Message_Name	=> 'ENG_COMP_OPSEQ_DATE_OVERLAP'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 );
           END IF;
           -- Since Open Interface allows for Dates to be
	   -- overlapping do set the error status.
      	END IF;

--dbms_output.put_line('Verified overlapping dates . . . ' || l_return_status);

        /********************************************************************
        --
        -- Check for Overlapping numbers for the component being inserted.
        --
        *********************************************************************/
        IF Check_Overlap_Numbers
           (X_From_end_item_number
		=> p_rev_component_rec.from_end_item_unit_number,
            X_to_end_item_number
		=> p_rev_component_rec.to_end_item_unit_number,
            X_Member_Item_Id    => p_rev_comp_unexp_rec.component_item_id,
            X_Bill_Sequence_id  => p_rev_comp_unexp_rec.bill_sequence_id,
            X_Rowid             => NULL)
        THEN
           --if function return true then component dates overlapp

           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
           THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_COMP_OPSEQ_UNIT_OVERLAP'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
           END IF;
           -- Since Open Interface allows for Dates to be
           -- overlapping do set the error status.
        END IF;

--dbms_output.put_line('Verified overlapping unit numbers. . .' || l_return_status);

	/*********************************************************************
	--
	-- Check whether the entered attributes match with the current
	-- component attributes
	--
	**********************************************************************/
	IF (( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
	      p_rev_component_rec.acd_type = 1
	    ) OR
	   (((p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
	      ) OR
	       p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
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
			( p_message_name	=> 'ENG_COMP_OPTIONAL'
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
                        ( p_message_name        => 'ENG_COMP_NOT_OPTIONAL'
                        , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        );
		END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;

	--dbms_output.put_line('Verified PTO / ATO . . .' || l_return_status);

	/*********************************************************************
	--
        -- Planning Percent can be other than 100 for only some combination of
        -- Assembly and component_types.
	--
	**********************************************************************/
	--
	IF (( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
              p_rev_component_rec.acd_type = 1 AND
              p_rev_component_rec.planning_percent <> 100
            ) OR
           (((p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
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
			(  p_Message_Name	=> 'ENG_NOT_A_PLANNING_PARENT'
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
			IF g_Assy_Item_Type = l_MODEL
			THEN
				g_Token_Tbl(3).Token_Value := 'ENG_MODEL_TYPE';
			ELSIF g_Assy_Item_Type = l_OPTION_CLASS THEN
				g_Token_Tbl(3).Token_Value :=
				'ENG_OPTION_CLASS_TYPE';
			END IF;
			g_Token_Tbl(3).Translate := TRUE;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_COMP_MODEL_OC_OPTIONAL'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
			g_Token_Tbl.DELETE(2);
			g_Token_Tbl.DELETE(3);
			l_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;
		ELSIF l_Result = 3 THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
			g_Token_Tbl(1).Token_Name := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(1).Token_Value :=
                        g_rev_component_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       =>
						'ENG_COMP_OPTIONAL_ATO_FORECAST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
			g_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
                        g_Token_Tbl(1).Token_Value :=
                        g_rev_component_rec.component_item_name;

                    END IF;
		    l_return_status := FND_API.G_RET_STS_ERROR;
     		END IF;  -- If Result Ends
        END IF; -- If Plannng <> 100 Ends

	--dbms_output.put_line('Verified Planning % . . .' || l_return_status);

	/*********************************************************************
	--
        -- Check Required for Revenue / Required to Ship
	--
	**********************************************************************/
        IF (( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
              p_rev_component_rec.acd_type = 1 AND
	      ( p_rev_component_rec.required_for_revenue = 1 OR
		p_rev_component_rec.required_to_ship = 1
	       )
            ) OR
           (((p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
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
			( p_message_name     => 'ENG_COMP_REQ_FOR_REV_INVALID'
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
                        ( p_message_name     => 'ENG_COMP_REQ_TO_SHIP_INVALID'
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
                        ( p_message_name     => 'ENG_COMP_REQ_TO_SHIP_INVALID'
                        , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , p_Token_Tbl        => g_Token_Tbl
                        );

                        g_Token_Tbl(2).Token_Name := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value :=
                                g_rev_component_rec.revised_item_name;
                        Error_Handler.Add_Error_Token
                        ( p_message_name     => 'ENG_COMP_REQ_FOR_REV_INVALID'
                        , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                        , p_Token_Tbl        => g_Token_Tbl
                        );

			g_Token_Tbl.DELETE(2);
			l_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;

--dbms_output.put_line('Verified Req for Rev and Shipping . . . ' ||
--		      l_return_status);

	/*********************************************************************
	--
	-- Verify the value of SO_Basis
	--
	*********************************************************************/
	IF p_rev_component_rec.so_basis = 1 AND
	   g_Comp_Item_Type <> l_OPTION_CLASS
	THEN
                 Error_Handler.Add_Error_Token
                 (  p_message_name     => 'ENG_SO_BASIS_ONE'
                  , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                  , p_Token_Tbl        => g_Token_Tbl
                  );
		l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	/********************************************************************
	--
        -- Check Check_ATP Flag. Check_ATP can be True only if Assembly has
	-- Atp Components flag = Y and the Component has a Check_ATP.
	--
	********************************************************************/
        IF (( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
              p_rev_component_rec.acd_type = 1 AND
              p_rev_component_rec.check_atp = 1
             ) OR
             ( ( ( p_rev_component_rec.Transaction_Type =
		   Bom_GLOBALS.G_OPR_CREATE AND
               	   p_rev_component_rec.acd_type = 2
                 ) OR
                  p_rev_component_rec.Transaction_Type =
		  Bom_GLOBALS.G_OPR_UPDATE
               ) AND
               NVL(p_Old_rev_component_rec.check_atp, 0) <>
               p_rev_component_rec.check_atp
             )
           )
	THEN
		l_result := Check_ATP;
		/* We will not be using the result of the check_atp procedure
		   to decide the translatable token since the message text
		   is now changed. Please refer to text for ENG_ATP_CHECK_NOT_NO
		*/
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) AND
		l_result <> 0
             THEN
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_ATP_CHECK_NOT_NO'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                 );
		g_Token_Tbl.DELETE(2);
		l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
        END IF;

	--dbms_output.put_line('After verification of Check ATP, Req for Rev' );

	/********************************************************************
	--
        -- Check Mutually Exclusive, which can be set only if the
        -- Component is an Option Class and BOM is installed.
	--
	*********************************************************************/

        IF ( p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE OR
             p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
	    )
           AND
	   p_rev_component_rec.mutually_exclusive = 1
	THEN
	     l_result := Check_Mutually_Exclusive;
             IF l_result <> 0 THEN
	        IF l_result = 1 THEN
		   l_err_text := 'ENG_MUT_EXCL_BOM_NOT_INST';
	        ELSIF l_result = 2 THEN
		   l_err_text := 'ENG_MUT_EXCL_NOT_MDL_OPTCLASS';
	        END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
		   (  p_message_name	=> l_err_text
		    , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		    , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		    , p_Token_Tbl		=> g_Token_Tbl
		    );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;

	--dbms_output.put_line('After verification of Mutually exclusive . . .' ||
		--	      l_return_status);

        -- So process can continue in case of a warning. Since it has
        -- indecisive o/p to continue or not, the function will
        -- log the error or warning and return TRUE if warning
        -- so the process can continue or will return an FALSE if
        -- process needs to return
        IF (( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
              p_rev_component_rec.acd_type = 1 AND
              p_rev_component_rec.wip_supply_type IS NOT NULL
            ) OR
           (((p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
             )
              AND
              NVL(p_Old_rev_component_rec.wip_supply_type, 0) <>
              p_rev_component_rec.wip_supply_type
            )
           )
	   AND
            Check_Supply_Type
	    (  p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	     , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl ) = FALSE
	THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	--dbms_output.put_line
	--('After verification of Supply Type . . .' || l_return_status);

        -- Check Minimum Quantity which must be <= Component Quantity
        IF ( p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE OR
             p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
	    ) AND
             p_rev_component_rec.minimum_allowed_quantity is not null
           AND
           NOT Check_Min_Quantity THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_MIN_QUANTITY_INVALID'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                 );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Check Maximun Quantity which must be >= Component Quantity or
	-- should be NULL if the minimum quantity is NULL.
        IF ( p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE OR
             p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
	    ) AND
            p_rev_component_rec.maximum_allowed_quantity IS NOT NULL
           AND
           NOT Check_Max_Quantity THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_MAX_QUANTITY_INVALID'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                 );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	--dbms_output.put_line('After verification of Min / Max quantity . . .');

        -------------------------------------------------
        -- Required since quantity cannot be fractional
        -- if OE is installed and revised item is
        -- ATO/PTO.
        -- Fix made by AS 04/27/98
        -- Bug 651689
        -------------------------------------------------

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

	 IF ( p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE OR
              p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
             ) AND
           (Is_OE_Installed = 'I'
            AND ( (  Is_Item_ATO = 'Y' OR
                     Is_Item_PTO = 'Y'
		   ) AND
                   (round(p_rev_component_rec.quantity_per_assembly)
             	    <> p_rev_component_rec.quantity_per_assembly)
		 )
	   )
         THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
		(  p_message_name	=> 'ENG_COMP_QTY_FRACTIONAL'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
                );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;

	--dbms_output.put_line('Checked if fractional quantity is valid . . .' ||
	--		      l_return_status);


	/********************************************************************
	--
	-- Verify if the Check_Atp is Yes and the Component quantity is
	-- negative. If it is then give out an error.
	--
	********************************************************************/

	IF g_Comp_Atp_Check_Flag = 'Y' AND
	   p_rev_component_rec.quantity_per_assembly < 0
	THEN
	     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name       => 'ENG_COMP_QTY_NEGATIVE'
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
                (  p_message_name       => 'ENG_COMP_PTO_QTY_NEGATIVE'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

--dbms_output.put_line('Checking Supply Subinventory . . . ' ||
--		     p_rev_component_rec.Supply_SubInventory);

	/*******************************************************************
	--
        -- Check Supply Subinventory
	--
	********************************************************************/
        IF (( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
              p_rev_component_rec.acd_type = 1 AND
              p_rev_component_rec.Supply_SubInventory IS NOT NULL
            ) OR
           (((p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
              ) OR
               p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
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
		(  p_message_name	=> 'ENG_SUBINV_INVALID'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 );
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
--dbms_output.put_line('After checking Subinventory . . . ' || l_return_status);

	--dbms_output.put_line('Checking Locators . . . .');
	/********************************************************************
	--
        -- Check Locators
	--
	********************************************************************/
        IF (( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
              p_rev_component_rec.acd_type = 1 AND
              p_rev_component_rec.Supply_SubInventory IS NOT NULL AND
	      p_rev_component_rec.Supply_SubInventory <> FND_API.G_MISS_CHAR
            ) OR
           ((( p_rev_component_rec.Transaction_Type=Bom_GLOBALS.G_OPR_CREATE AND
               p_rev_component_rec.acd_type = 2
             ) OR
               p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
            )
              AND
              NVL(p_Old_rev_comp_unexp_rec.supply_locator_id, 0) <>
              NVL(p_rev_comp_unexp_rec.supply_locator_id, 0)
           )
          )
           AND
	   NOT Check_Locators
	THEN
		--dbms_output.put_line('Locators check returned with an error-' ||
		--		to_char(l_locator_control));

	     IF l_locator_control = 4 THEN
	         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name       => 'ENG_LOCATOR_REQUIRED'
                       , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , p_Token_Tbl          => g_Token_Tbl
                      );
                END IF;
	     ELSIF l_locator_control = 3 THEN
	     	-- Log the Dynamic locator control message.
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
		      (  p_message_name	      => 'ENG_LOCATOR_CANNOT_BE_DYNAMIC'
		       , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                       , p_Token_Tbl          => g_Token_Tbl
                      );
                END IF;
	     ELSIF l_locator_control = 2 THEN
		IF  l_item_loc_restricted  = 1 THEN

			-- if error occured when item_locator_control was
			-- restrcited

             		IF FND_MSG_PUB.Check_Msg_Level
			   (FND_MSG_PUB.G_MSG_LVL_ERROR)
             		THEN
                	     Error_Handler.Add_Error_Token
			     (  p_message_name  => 'ENG_ITEM_LOCATOR_RESTRICTED'
			      , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	      , p_Token_Tbl      => g_Token_Tbl
                              );
             		END IF;
		ELSE
			IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
			      g_Token_Tbl(1).token_name := 'REVISED_COMPONENT_NAME';
			      g_Token_Tbl(1).token_value:= p_rev_component_rec.component_item_name;

                              Error_Handler.Add_Error_Token
			      (  p_message_name	  => 'ENG_LOCATOR_NOT_IN_SUBINV'
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
                             (  p_message_name  => 'ENG_ITEM_NO_LOCATOR_CONTROL'
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
		(  p_message_name	=> 'ENG_LOCATOR_MUST_BE_NULL'
		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
             	END IF;
             	l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	--dbms_output.put_line('Operation CREATE ENDS . . .' || l_return_status);

   END IF; -- Operation in UPDATE or CREATE

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

--dbms_output.put_line('Entity Validation done . . . Return Status is ' ||
--		     l_return_status);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

--dbms_output.put_line('Expected Error in Rev. Comp. Entity Validation . . .');

        x_return_status := FND_API.G_RET_STS_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

--dbms_output.put_line('UNExpected Error in Rev. Comp. Entity Validation . . .');

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    WHEN OTHERS THEN
--dbms_output.put_line(SQLERRM || ' ' || TO_CHAR(SQLCODE));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Entity;

/*****************************************************************************
* Procedure	: Check_Attribute (Validation)
* Parameters IN	: Revised Component Record of exposed columns
* Parameters OUT: Mesg_Token_Tbl
*		  Return_Status
* Purpose	: Attribute validation procedure will validate each attribute
*		  of Revised component in its entirety. If the validation of
*		  a column requires looking at some other columns value then
*		  the validation is done at the Entity level instead.
*		  All errors in the attribute validation are accumulated before
*		  the procedure returns with a Return_Status of 'E'.
Item**************************************************************************/
PROCEDURE Check_Attributes
( x_return_status		OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
)
IS
l_return_status VARCHAR2(1);
l_err_text	VARCHAR2(2000);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    g_rev_component_rec := p_rev_component_rec;

    -- Set the first token to be equal to the component_name
    g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
    g_Token_Tbl(1).Token_Value := p_rev_component_rec.component_item_name;


    --
    -- Check if the user is trying to create/update a record with missing
    -- value when the column value is required.
    --
    IF p_rev_component_rec.item_sequence_number = FND_API.G_MISS_NUM
    THEN
	Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_ITEM_NUM_MISSING'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.quantity_per_assembly = FND_API.G_MISS_NUM
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_COMP_QUANTITY_MISSING'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.projected_yield = FND_API.G_MISS_NUM
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_COMP_YIELD_MISSING'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.planning_percent = FND_API.G_MISS_NUM
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_PLAN_PERCENT_MISSING'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.quantity_related = FND_API.G_MISS_NUM
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_QUANTITY_RELATED_MISSING'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.include_in_cost_rollup = FND_API.G_MISS_NUM
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_INCL_IN_COST_ROLLUP_MISSING'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.check_atp = FND_API.G_MISS_NUM
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_CHECK_ATP_MISSING'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


    IF p_rev_component_rec.acd_type IS NOT NULL AND
       p_rev_component_rec.acd_type NOT IN (1, 2, 3)
    THEN
	g_token_tbl(2).token_name  := 'ACD_TYPE';
	g_token_tbl(2).token_value := p_rev_component_rec.acd_type;

	Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_ACD_TYPE_INVALID'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
	l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Validate rev_component attributes

/* -- Not necessary since the UUI to UI conversions take care of this

    IF  p_rev_component_rec.transaction_type = Bom_GLOBALS.G_OPR_CREATE AND
        (p_rev_component_rec.from_end_item_unit_number IS NOT NULL
         OR
         p_rev_component_rec.from_end_item_unit_number <> FND_API.G_MISS_CHAR)
    THEN
        IF NOT  ENG_Validate.End_Item_Unit_Number
                ( p_from_end_item_unit_number =>
                        p_rev_component_rec.from_end_item_unit_number
                , p_revised_item_id =>
                        p_rev_component_rec.component_item_id
                , x_err_text => l_err_text
                )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                     g_token_tbl(1).token_name  := 'FROM_END_ITEM_UNIT_NUMBER';
                     g_token_tbl(1).token_value :=
                                    p_rev_component_rec.from_end_item_unit_number;
                     Error_Handler.Add_Error_Token
                     ( p_Message_Name       => 'ENG_FROM_END_ITEM_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => g_Token_Tbl
                     );
            END IF;
        END IF;
    END IF;
*/

    IF  p_rev_component_rec.transaction_type = Bom_GLOBALS.G_OPR_CREATE AND
        (p_rev_component_rec.to_end_item_unit_number IS NOT NULL
         OR
         p_rev_component_rec.to_end_item_unit_number <> FND_API.G_MISS_CHAR)
    THEN
        IF NOT  ENG_Validate.End_Item_Unit_Number
                ( p_from_end_item_unit_number =>
                        p_rev_component_rec.to_end_item_unit_number
                , p_revised_item_id =>
                        p_rev_comp_unexp_rec.component_item_id
                , x_err_text => l_err_text
                )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                     g_token_tbl(1).token_name  := 'FROM_END_ITEM_UNIT_NUMBER';
                     g_token_tbl(1).token_value :=
                                    p_rev_component_rec.to_end_item_unit_number;
                     g_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
		     g_token_tbl(2).token_value :=
                                    p_rev_component_rec.component_item_name;
		     g_token_tbl(3).token_name  := 'ORGANIZATION_CODE';
		     g_token_tbl(3).token_value :=
                                    p_rev_component_rec.organization_code;
		     Error_Handler.Add_Error_Token
                     ( p_Message_Name       => 'ENG_CMP_TO_UNIT_NUM_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => g_Token_Tbl
                     );
            END IF;
        END IF;
    END IF;

    IF p_rev_component_rec.transaction_type = Bom_GLOBALS.G_OPR_CREATE AND
       p_rev_component_rec.to_end_item_unit_number = FND_API.G_MISS_CHAR
    THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'ENG_CMP_TO_UNIT_NUM_NULL'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF  p_rev_component_rec.wip_supply_type IS NOT NULL  AND
	p_rev_component_rec.wip_supply_type = 7
    THEN
    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		g_token_tbl(2).token_name  := 'WIP_SUPPLY_TYPE';
		g_token_tbl(2).token_value :=
				p_rev_component_rec.wip_supply_type;
        	Error_Handler.Add_Error_Token
		(  p_Message_Name	=> 'ENG_WIP_SUPPLY_TYPE_7'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
		);
		g_token_tbl.delete(2);
       	END IF;
       	l_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF p_rev_component_rec.wip_supply_type IS NOT NULL AND
	  p_rev_component_rec.wip_supply_type <> 7 AND
          NOT ENG_Validate.Wip_Supply_Type
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
                (  p_Message_Name       => 'ENG_WIP_SUPPLY_TYPE_INVALID'
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
		(  p_Message_Name	=> 'ENG_OPSEQ_LESS_THAN_ZERO'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> g_Token_Tbl
		 );
	END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

 --dbms_output.put_line('After Operation Sequence Num . . . ' || l_return_status);

    IF  p_rev_component_rec.item_sequence_number IS NOT NULL AND
	( p_rev_component_rec.item_sequence_number < 0 OR
	  p_rev_component_rec.item_sequence_number > 9999
	)
    THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> 'ENG_ITEM_NUM_INVALID'
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
		(  p_Message_Name	=> 'ENG_COMPYIELD_OUT_OF_RANGE'
                 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_token_tbl		=> g_token_tbl
		);
        END IF;
	l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_rev_component_rec.include_in_cost_rollup IS NOT NULL AND
       p_rev_component_rec.include_in_cost_rollup NOT IN (1,2)
    THEN
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_INCL_IN_COST_ROLL_INVALID'
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
                (  p_Message_Name       => 'ENG_SO_BASIS_INVALID'
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
                (  p_Message_Name       => 'ENG_OPTIONAL_INVALID'
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
                (  p_Message_Name       => 'ENG_MUTUALLY_EXCLUSIVE_INVALID'
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
                (  p_Message_Name       => 'ENG_CHECK_ATP_INVALID'
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
                (  p_Message_Name       => 'ENG_SHIPPING_ALLOWED_INVALID'
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
                (  p_Message_Name       => 'ENG_REQUIRED_TO_SHIP_INVALID'
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
                (  p_Message_Name       => 'ENG_REQ_FOR_REVENUE_INVALID'
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
                (  p_Message_Name       => 'ENG_INCL_ON_SHIP_DOCS_INVALID'
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
                (  p_Message_Name       => 'ENG_QTY_RELATED_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Done validating attributes

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN OTHERS THEN
--dbms_output.put_line('Some unknown error in Attribute Validation . . .' ||
--		     SQLERRM );

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
                 , p_Message_Text	=> 'Error in Rev Comp Attr. Validation '
					   || SUBSTR(SQLERRM, 1, 30) || ' ' ||
					   to_char(SQLCODE)
                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_token_Tbl
		 );
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Attributes;

PROCEDURE Check_Entity_Delete
( x_return_status               OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

BEGIN

    g_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
    g_Token_Tbl(1).Token_Value := p_rev_component_rec.component_item_name;

   --
   -- Verify that the component is not already cancelled.
   --
   IF p_rev_component_rec.Transaction_Type = Bom_GLOBALS.G_OPR_DELETE THEN
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
        -- if not exception is raised then record is deleted. so raise an error.
        --
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             Error_Handler.Add_Error_Token
	     (  p_Message_Name		=> 'ENG_COMP_CANCELLED'
	      , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	      , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	      , p_Token_Tbl		=> g_Token_Tbl
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

/*****************************************************************************
* Procedure     : Check_Existence
* Parameters IN : Revised component exposed column record
*                 Revised component unexposed column record
* Parameters OUT: Old Revised component exposed column record
*                 Old Revised component unexposed column record
*                 Mesg Token Table
*                 Return Status
* Purpose       : Check_Existence will poerform a query using the primary key
*                 information and will return a success if the operation is
*                 CREATE and the record EXISTS or will return an
*                 error if the operation is UPDATE and the record DOES NOT
*                 EXIST.
*                 In case of UPDATE if the record exists then the procedure
*                 will return the old record in the old entity parameters
*                 with a success status.
****************************************************************************/
PROCEDURE Check_Existence
(  p_rev_component_rec          IN  Bom_Bo_Pub.Rev_Component_Rec_Type
 , p_rev_comp_unexp_rec         IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_old_rev_component_rec      IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
 , x_old_rev_comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              OUT NOCOPY VARCHAR2
)
IS
        l_token_tbl      Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status  VARCHAR2(1);
BEGIN
        l_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
        l_Token_Tbl(1).Token_Value := p_rev_component_rec.component_item_name;
	l_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
        l_Token_Tbl(2).Token_Value := p_rev_component_rec.revised_item_name;

        ENG_Rev_Component_Util.Query_Row
	( p_Component_Item_Id	      => p_rev_comp_unexp_rec.component_item_id
	, p_Operation_Sequence_Number =>
				p_rev_component_rec.operation_sequence_number
	, p_Effectivity_Date	      =>
				p_rev_component_rec.start_effective_date
	, p_Bill_Sequence_Id	      => p_rev_comp_unexp_rec.bill_sequence_id
	, p_from_end_item_number      => p_rev_component_rec.from_end_item_unit_number
	, x_Rev_Component_Rec	      => x_old_rev_component_rec
	, x_Rev_Comp_Unexp_Rec        => x_old_rev_comp_unexp_rec
	, x_Return_Status	      => l_return_status
	);

        IF l_return_status = Bom_Globals.G_RECORD_FOUND AND
           p_rev_component_rec.transaction_type = Bom_Globals.G_OPR_CREATE
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_REV_COMP_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = Bom_Globals.G_RECORD_NOT_FOUND AND
              p_rev_component_rec.transaction_type IN
                (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_REV_COMP_DOESNOT_EXIST'
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
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Existence;

/****************************************************************************
* Prcoedure	: Check_Lineage
* Parameters IN	: Revised Component exposed column record
*		  Revised Component unexposed column record
* Parameters OUT: Mesg_Token_Tbl
*		  Return_Status
* Purpose	: Check_Lineage procedure will verify that the entity record
*		  that the user has passed is for the right parent and that
*		  the parent exists.
*****************************************************************************/
PROCEDURE Check_Lineage
(  p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
 , p_rev_comp_unexp_rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
	CURSOR c_GetComponent IS
	SELECT revised_item_sequence_id
	  FROM bom_inventory_components
	 WHERE component_item_id = p_rev_comp_unexp_rec.component_item_id
	   AND bill_sequence_id  = p_rev_comp_unexp_rec.bill_sequence_id
	   AND operation_seq_num = p_rev_component_rec.operation_sequence_number
	   AND effectivity_date  = p_rev_component_rec.start_effective_date;

	l_Token_Tbl		Error_Handler.Token_Tbl_Type;
	l_return_status 	VARCHAR2(1);
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

BEGIN
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	/******************************************************************
	--
	-- In case of an update, based on the revised item information
	-- Bill Sequence Id and Revised Item Sequence Id is queried from
	-- the database. The revised item sequence id can however be different
	-- from that in the database and should be checked and given an
	-- error.
	*******************************************************************/

	IF p_rev_component_rec.transaction_type IN
	   (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE,
	    Bom_Globals.G_OPR_CANCEL)
	THEN
		FOR Component IN c_GetComponent LOOP
			IF Component.revised_item_sequence_id <>
			   p_rev_comp_unexp_rec.revised_item_sequence_id
			THEN
				l_Token_Tbl(1).token_name  :=
						'REVISED_COMPONENT_NAME';
				l_Token_Tbl(1).token_value :=
					p_rev_component_rec.component_item_name;
				l_Token_Tbl(2).token_name  :=
						'REVISED_ITEM_NAME';
				l_Token_Tbl(2).token_value :=
					p_rev_component_rec.revised_item_name;
				l_token_tbl(3).token_name  := 'ECO_NAME';
				l_token_tbl(3).token_value :=
					p_rev_component_rec.eco_name;

				Error_Handler.Add_Error_Token
				(  p_Message_Name   => 'ENG_REV_ITEM_MISMATCH'
				 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				 , p_Token_Tbl	    => l_Token_Tbl
				 );
				l_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
		END LOOP;
	END IF;

	x_return_status := l_return_status;
	x_mesg_token_tbl := l_mesg_token_tbl;

END Check_Lineage;

/****************************************************************************
* Procedure	: Check_Access
* Parameters IN	: Revised Item Unique Key
*		  Revised Component unique key
* Parameters OUT: Mesg_Token_Tbl
*		  Return_Status
* Purpose	: Procedure will verify that the revised item and the revised
*		  component is accessible to the user.
*****************************************************************************/
PROCEDURE Check_Access
(  p_revised_item_name		IN  VARCHAR2
 , p_revised_item_id		IN  NUMBER
 , p_organization_id		IN  NUMBER
 , p_change_notice		IN  VARCHAR2
 , p_new_item_revision		IN  VARCHAR2
 , p_effectivity_date		IN  DATE
 , p_component_item_id		IN  NUMBER
 , p_operation_seq_num		IN  NUMBER
 , p_bill_sequence_id		IN  NUMBER
 , p_component_name		IN  VARCHAR2
 , p_Mesg_Token_Tbl		IN  Error_Handler.Mesg_Token_Tbl_Type :=
				    Error_Handler.G_MISS_MESG_TOKEN_TBL
 , p_entity_processed		IN  VARCHAR2 := 'RC'
 , p_rfd_sbc_name		IN  VARCHAR2 := NULL
 , x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
	l_Token_Tbl		Error_Handler.Token_Tbl_Type;
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type :=
				p_Mesg_Token_Tbl;
	l_return_status		VARCHAR2(1);
	l_Rev_Comp_Item_Type	NUMBER;
	l_error_name		VARCHAR2(30);
        l_is_comp_unit_controlled BOOLEAN := FALSE;

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

	--
	-- Revised Item Access check should be done by the calling
	-- program
	--
	/***********************************************
	Eng_Validate_Revised_Item.Check_Access
	(  p_revised_item_name		=> p_revised_item_name
	 , p_revised_item_id		=> p_revised_item_id
	 , p_change_notice		=> p_change_notice
	 , p_organization_id		=> p_organization_id
	 , p_new_item_revision		=> p_new_item_revision
	 , p_effectivity_date		=> p_effectivity_date
	 , p_Mesg_Token_Tbl		=> l_Mesg_Token_Tbl
	 , x_Mesg_Token_Tbl		=> l_Mesg_Token_Tbl
	 , x_Return_Status		=> l_Return_Status
	);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		x_Return_Status := l_return_status;
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

		RETURN;
	END IF;
	***************************************************/


	/***************************************************************
	--
	-- Check if the user has access to the revised component's
	-- bom_item_type
	--
	****************************************************************/
	SELECT bom_item_type
	  INTO l_rev_comp_item_type
	  FROM mtl_system_items
	 WHERE inventory_item_id = p_component_item_id
	   AND organization_id   = p_organization_id;

	IF l_rev_comp_item_type NOT IN
	   (NVL(Bom_Globals.Get_MDL_Item_Access,0),
	    NVL(Bom_Globals.Get_OC_Item_Access,0),
	    NVL(Bom_Globals.Get_PLN_Item_Access,0),
	    NVL(Bom_Globals.Get_STD_Item_Access,0)
	   )
	THEN
		l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
		l_token_tbl(1).token_value := p_component_name;
		l_token_tbl(2).token_name  := 'BOM_ITEM_TYPE';
		l_token_tbl(2).translate   := TRUE;

                IF l_rev_comp_Item_Type = 1
                THEN
                      l_Token_Tbl(2).Token_Value := 'ENG_MODEL';
                ELSIF l_rev_comp_Item_Type = 2
                THEN
                      l_Token_Tbl(2).Token_Value:='ENG_OPTION_CLASS';
                ELSIF l_rev_comp_Item_Type = 3
                THEN
                      l_Token_Tbl(2).Token_Value := 'ENG_PLANNING';
                ELSIF l_rev_comp_Item_Type = 4
                THEN
                      l_Token_Tbl(2).Token_Value := 'ENG_STANDARD';
                END IF;

		Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REV_COMP_ACCESS_DENIED'
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
                (  p_Message_Name       => 'ENG_REV_COMP_PRODUCT_FAMILY'
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

	IF Bom_Globals.Is_RComp_Cancl IS NULL THEN
		FOR RevComp IN c_CheckCancelled
		LOOP
			l_token_tbl.DELETE;
			l_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
			l_Token_Tbl(1).Token_value := p_component_name;
			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'ENG_REV_COMP_CANCELLED'
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

        FOR UnitEffective IN c_Check_Unit_Effective
        LOOP
                IF UnitEffective.Effectivity_Control = 2
                THEN
                        Bom_Globals.Set_Unit_Controlled_Component
                        ( p_unit_controlled_component => TRUE);

			l_is_comp_unit_controlled := TRUE;

                ELSIF UnitEffective.Effectivity_Control = 1
                THEN
                        Bom_Globals.Set_Unit_Controlled_Component
                        ( p_unit_controlled_component => FALSE);

			l_is_comp_unit_controlled := FALSE;
                END IF;
        END LOOP;

        IF NOT Bom_Globals.Get_Unit_Effectivity AND
           l_is_comp_unit_controlled
        THEN
                l_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
		l_token_tbl(1).token_value :=
                                    p_component_name;
		l_token_tbl(2).token_name := 'ECO_NAME';
		l_token_tbl(2).token_value :=
                                    p_change_notice;
		Error_Handler.Add_Error_Token
                ( p_Message_Name   => 'ENG_REV_COMP_UNIT_CONTROL'
                , p_Mesg_Token_Tbl => l_mesg_token_tbl
                , x_Mesg_Token_Tbl => l_mesg_token_tbl
                , p_Token_Tbl      => l_token_tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

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
				l_error_name := 'ENG_RFD_COMP_ACD_TYPE_DISABLE';
				l_token_tbl(1).token_name  :=
					'REFERENCE_DESIGNATOR_NAME';
				l_token_tbl(1).token_value := p_rfd_sbc_name;
			ELSE
				l_error_name := 'ENG_SBC_COMP_ACD_TYPE_DISABLE';
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

END ENG_Validate_Rev_Component;

/
