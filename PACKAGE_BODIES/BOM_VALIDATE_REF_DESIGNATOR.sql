--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_REF_DESIGNATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_REF_DESIGNATOR" AS
/* $Header: BOMLRFDB.pls 120.4.12010000.6 2010/07/28 00:16:51 umajumde ship $ */
/**********************************************************************
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLRFDB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Ref_designators
--
--  NOTES
--
--  HISTORY
--
--  19-JUL-1999	Rahul Chitko	Initial Creation
--
--  08-MAY-2001 Refai Farook    EAM related changes
--
--  05-JUL-2004 Hari Gelli    Added Check_Quantity procedure
**************************************************************************/
G_PKG_NAME	CONSTANT VARCHAR2(30) := 'BOM_Validate_Ref_Designator';
ret_code		 NUMBER;
l_dummy			 VARCHAR2(80);


/*************************************************************************
* Local Procedure: Calculate_both_totals
* Parameter IN	 : old_component_sequenc_id
* Parameters OUT : Total Quantity of Designators
* Purpose	 : Procedure calculate_both_totals will take the component
*		   sequence_id and calculate the number of designators that
*		   already exist for it and the how many exist on the same
*		   component on the ECO with an acd_type of add or disable
*		   Then by making use of the set operater it will eliminate
*		   the disable one's from the list. This is the quantity
*		   of designator that will remain on the component after
*		   implementation and is returned by the procedure as
*		   Total Quantity.
**************************************************************************/
Procedure Calculate_Both_Totals( p_old_component_sequence_id	IN 	NUMBER,
				 x_TotalQuantity		IN OUT NOCOPY 	NUMBER
				)
IS

  X_OldComp number;
  X_Add constant number := 1;
  X_Delete constant number := 3;
  l_Implemented_Count	NUMBER;
  l_dummy		varchar2(80);

  Cursor GetTotalQty is
    Select brd.component_reference_designator
    From bom_reference_designators brd
    Where brd.component_sequence_id = p_old_component_sequence_id
    And nvl(brd.acd_type, X_Add) = X_Add
    Union
    Select brd.component_reference_designator
    From bom_reference_designators brd,
         bom_inventory_components bic
    Where /* Bug 9346685 : Replaced decode with conditions
		DECODE(bic.old_component_sequence_id, NULL,
		 bic.component_sequence_id,
		 bic.old_component_sequence_id) = p_old_component_sequence_id */
    (bic.old_component_sequence_id = p_old_component_sequence_id
     OR
     (bic.old_component_sequence_id IS NULL
      AND bic.component_sequence_id = p_old_component_sequence_id))
    And   bic.component_sequence_id = brd.component_sequence_id
    And   bic.implementation_date is null
    And   brd.acd_type = X_Add
    Minus
    Select brd.component_reference_designator
    From bom_reference_designators brd,
         bom_inventory_components bic
    Where /* Bug 9346685 : Replaced decode with conditions
		DECODE(bic.old_component_sequence_id, NULL,
		 bic.component_sequence_id,
		 bic.old_component_sequence_id) = p_old_component_sequence_id */
    (bic.old_component_sequence_id = p_old_component_sequence_id
     OR
     (bic.old_component_sequence_id IS NULL
      AND bic.component_sequence_id = p_old_component_sequence_id))
    And   bic.component_sequence_id = brd.component_sequence_id
    And   bic.implementation_date is null
    And   brd.acd_type = X_Delete;

BEGIN
  IF (Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO) THEN
	BEGIN
		Select count(*)
		Into   X_TotalQuantity
		From   bom_reference_designators brd ,
         	       bom_inventory_components bic
    		Where  brd.component_sequence_id = p_old_component_sequence_id
    		And    bic.component_sequence_id = brd.component_sequence_id
    		And    bic.implementation_date is NOT NULL
    		And    nvl(brd.acd_type, 1) = 1 ;

		RETURN;
	EXCEPTION
		WHEN OTHERS THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

  ELSE
    X_TotalQuantity :=0;
  	For X_Designators in GetTotalQty loop
  	  X_TotalQuantity := X_TotalQuantity + 1;
  	End loop;
    RETURN;
  END IF;

  -- Else return 0
  X_TotalQuantity := 0;

END Calculate_Both_Totals;

/*************************************************************************
* Local Procedure: Check_Quantity
* Parameter IN	 : component_sequenc_id
*                : component_item_name
* Parameters OUT : Error_Status
* Purpose	 : Procedure Check_Quantity will take the component
*		   sequence_id and checks if the quantity related is set to yes for
*      the component and if it is yes then calculates the number of designators
*      by calling the Calculate_both_totals and valiadtes the totals and
*      send back the error status or success.
**************************************************************************/
PROCEDURE Check_Quantity
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_component_sequence_id	    IN 	NUMBER
,   p_component_item_name       IN  VARCHAR2
)
IS
l_ref_qty		      NUMBER := 0;
l_quantity		      NUMBER;
l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

l_token_tbl		      Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl	  Error_Handler.Mesg_Token_Tbl_Type;

CURSOR c_QuantityRelated IS
	SELECT component_quantity
          FROM bom_inventory_components
         WHERE component_sequence_id = p_component_sequence_id
           AND quantity_related      = 1;

CURSOR c_acdtype IS
	SELECT acd_type, old_component_sequence_id
	  FROM bom_inventory_components bic
         WHERE bic.component_sequence_id = p_component_sequence_id;
BEGIN

    /*****************************************************************
      --
    -- If no exception is raised then validate the actual quantity of
    -- ref. designators with respect to the component quantity
    -- If the designators are not equal, then set error status.
    ******************************************************************/

    OPEN c_QuantityRelated;
    FETCH c_QuantityRelated INTO l_Quantity;

    IF c_QuantityRelated%FOUND THEN

      FOR acd IN c_acdtype LOOP
        IF acd.acd_type = 2 /* CHANGE */
        THEN
          Calculate_Both_Totals
          (  p_old_component_sequence_id => acd.old_component_sequence_id
             , x_TotalQuantity           => l_ref_qty
             );
        ELSE
            Calculate_Both_Totals
            ( p_old_component_sequence_id => p_component_sequence_id
              , x_TotalQuantity             => l_ref_qty);
        END IF;
      END LOOP;

      IF l_quantity <> l_ref_qty  THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        l_token_tbl.delete ;
        l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
        l_token_tbl(1).token_value := p_component_item_name;
        Error_Handler.Add_Error_Token
        (  x_Mesg_Token_Tbl	=> l_Mesg_Token_tbl
         , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
         , p_message_name  	=> 'BOM_QUANTITY_RELATED_INVALID'
         , p_token_tbl		  => l_token_tbl
         , p_message_type   => 'W'
        );
      END IF;
    END IF;
    CLOSE c_QuantityRelated;

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    x_return_status := l_return_status;

END Check_Quantity;

/********************************************************************
*
* Procedure     : Check_Entity
* Parameters IN : Reference Designator Record as given by the User
*                 Reference Designator Unexposed Record
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Entity validate procedure will execute the business
*		  validations for the referenced designator entity
*		  Any errors are loaded in the Mesg_Token_Tbl and
*		  a return status value is set.
********************************************************************/

PROCEDURE Check_Entity
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec        IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_temp_var 		      NUMBER := 0;
l_ref_qty		      NUMBER := 0;
l_component_qty		      NUMBER;
l_dummy			      VARCHAR(80);
l_processed		      BOOLEAN;
l_quantity		      NUMBER;
l_change		      NUMBER := 0;
l_component_seq_id	      NUMBER := 0;
l_token_tbl		      Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl	      Error_Handler.Mesg_Token_Tbl_Type;
l_Err_text		      VARCHAR2(2000);
l_basis_type		      NUMBER;
l_assy_bom_enabled  VARCHAR2(1);
l_parent_PTO_flag      VARCHAR2(1);
l_rec_ATO_flag         VARCHAR2(1);
l_rec_optional         NUMBER;
l_rec_BIT              NUMBER;
l_parent_BIT           NUMBER;

CURSOR c_acdtype IS
	SELECT acd_type, old_component_sequence_id
	  FROM bom_inventory_components bic
         WHERE bic.component_sequence_id =
	       p_Ref_Desg_Unexp_Rec.component_sequence_id;

CURSOR c_QuantityRelated IS
	SELECT component_quantity
          FROM bom_inventory_components
         WHERE component_sequence_id =
	       p_Ref_Desg_Unexp_rec.component_sequence_id
           AND quantity_related      = 1;
BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Validation for Ref. Desgs begins . . .'); END IF;
If bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Ref Desg:  Checking for editable common bill...'); END IF;
    BEGIN
    --validation for BOM ER #9946990
     SELECT     bic.bom_item_type,
                msi.bom_item_type,
                msi.pick_components_flag,
                msi2.replenish_to_order_flag,
                bic.optional
         INTO   l_rec_BIT,
                l_parent_BIT,
                l_parent_PTO_flag,
                l_rec_ATO_flag,
                l_rec_optional
         FROM   mtl_system_items msi,
                mtl_system_items msi2,
                bom_inventory_components bic,
                bom_bill_of_materials bbom
        WHERE   msi.inventory_item_id = bbom.assembly_item_id
        AND     msi.organization_id = bbom.organization_id
        AND     msi2.inventory_item_id = bic.component_item_id
        AND     msi2.organization_id = bic.pk2_value
        AND     bic.component_sequence_id =
		p_Ref_Desg_Unexp_rec.component_sequence_id
        AND     bic.bill_sequence_id = bbom.bill_sequence_id;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

      --if a mandatory ATO item was added in a kit or pto model when the related profile was set, you cannot
    --update or delete the component once the profile is unset (meaning you cannot insert, update
    --or delete a substitute component on it

       IF
        nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 AND
        l_parent_BIT = Bom_Globals.G_STANDARD AND
        l_parent_PTO_Flag  = 'Y' AND
        l_rec_ATO_Flag = 'Y' AND
        l_rec_BIT = Bom_Globals.G_STANDARD
        THEN
        Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_KIT_COMP_PRF_NOT_SET'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
        l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;




        IF
        nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 AND
        l_parent_BIT = Bom_Globals.G_MODEL AND
        l_parent_PTO_Flag  = 'Y' AND
        l_rec_ATO_Flag = 'Y' AND
        l_rec_BIT = Bom_Globals.G_STANDARD AND
        l_rec_optional = 2
        THEN
        Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_MODEL_COMP_PRF_NOT_SET'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
        l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
       --BOM ER #9946990 changes (end)

BEGIN
  IF Bom_Globals.Get_Caller_Type <> 'MIGRATION' THEN
  SELECT 1
  INTO l_dummy
  FROM bom_bill_of_materials
  WHERE bill_sequence_id = source_bill_sequence_id
  AND bill_sequence_id = p_ref_desg_unexp_rec.bill_sequence_id;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Error_Handler.Add_Error_Token
    (  p_Message_Name       => 'BOM_COMMON_REF_DESG'
    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , p_Token_Tbl          => l_Token_Tbl
    );
    l_Return_Status := FND_API.G_RET_STS_ERROR;

END;
/*  4870173  */
  select basis_type into l_basis_type from bom_components_b where component_sequence_id = p_Ref_Desg_Unexp_Rec.component_sequence_id;
        If(l_Basis_type = 2) THEN
          	l_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
            l_Token_Tbl(1).Token_Value := p_Ref_Designator_Rec.component_item_name;
         	Error_Handler.Add_Error_Token
          (  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_message_name       => 'BOM_LOT_BASED_RDS'
            , p_Token_Tbl          => l_Token_Tbl
          );
          l_return_status := FND_API.G_RET_STS_ERROR;
      End if;

/*Check BOM enabled flag of the assembly*/
SELECT msi.bom_enabled_flag
INTO l_assy_bom_enabled
FROM mtl_system_items_b msi,
bom_bill_of_materials bbom
WHERE bbom.bill_sequence_id = p_Ref_Desg_Unexp_Rec.bill_sequence_id
AND bbom.assembly_item_id = msi.inventory_item_id
AND bbom.organization_id = msi.organization_id;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Assy Bom Enabled flag : ' || l_assy_bom_enabled); END IF;

IF l_assy_bom_enabled <> 'Y'
THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
			l_token_tbl(1).token_value :=
				p_ref_designator_rec.Revised_Item_Name;
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_Token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'BOM_REV_ITEM_BOM_NOT_ENABLED'
			 , p_token_tbl	    => l_token_tbl
                         );
                END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
END IF;

    -- The ECO can be updated but a warning needs to be generated and
    -- scheduled revised items need to be update to Open
    -- and the ECO status need to be changed to Not Submitted for Approval

    IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
    THEN
    Bom_GLOBALS.Check_Approved_For_Process
	( p_change_notice    => p_ref_designator_rec.Eco_Name,
          p_organization_id  => p_ref_desg_Unexp_rec.organization_id,
          x_processed        => l_processed,
          x_err_text         => l_err_text
        );

    IF l_processed = TRUE THEN
          -- If the above process returns true then set the ECO approval.

    	BEGIN
          Bom_GLOBALS.Set_Request_For_Approval
	  ( p_change_notice     => p_ref_designator_rec.Eco_Name,
            p_organization_id   => p_ref_desg_Unexp_rec.organization_id,
            x_err_text          => l_err_text
           );

          EXCEPTION
                    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                          l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END;

     END IF;
   END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified if process exists . . .'); END IF;

     /**********************************************************************
     *
     * If the Transaction Type is CREATE and the ACD_Type = Disable, then
     * the reference designator should already exist for the revised
     * component.
     * This piece of code will not be executed by BOM BO since the acd_type is
     * is not going to be 3 when the procedure is invoked from BOM BO.
     ***********************************************************************/
     IF p_ref_designator_rec.acd_type = 3 THEN
	BEGIN

                   SELECT component_reference_designator
                     INTO l_dummy
                     FROM bom_reference_designators brd,
                          bom_inventory_components bic
                    WHERE bic.component_sequence_id =
                                p_ref_desg_unexp_rec.component_sequence_id
                      AND brd.component_sequence_id = bic.old_component_sequence_id
                      AND brd.component_reference_designator =
                          p_ref_designator_rec.reference_designator_name
                      AND NVL(brd.ACD_TYPE,1) <> 3; /* bug 9270000 */


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Ref Desigantor: ' || l_dummy); END IF;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- It means that the reference designator does not
			-- exist on the revised component or it is probably
			-- not implemented yet.

			l_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
                	l_Token_Tbl(1).Token_Value :=
                		p_Ref_Designator_Rec.component_item_name;

			l_token_tbl(2).token_name  :=
				'REFERENCE_DESIGNATOR_NAME';
			l_token_tbl(2).token_value :=
				p_ref_designator_rec.reference_designator_name;

                	Error_Handler.Add_Error_Token
                	(  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	 , p_message_name       => 'BOM_DISABLE_DESG_NOT_FOUND'
                 	 , p_Token_Tbl          => l_Token_Tbl
                 	 );

			l_return_status := FND_API.G_RET_STS_ERROR;
	END;

     END IF;

     /************************************************************************
     * Check if ACD_Type of component is ADD then ref. desg is also add.
     * no need for a exception as validity of component_sequence_id is already
     * checked for.
     *************************************************************************/

    FOR acd IN c_acdtype LOOP
    	--
    	-- If the component has an ACD_Type of ADD then ref. Desg must also
	-- be ADD
    	--
    	IF acd.acd_type = 1 /* ADD */ AND
       	   p_ref_designator_rec.acd_type <> 1
    	THEN
 		l_return_status := FND_API.G_RET_STS_ERROR;


                l_token_tbl.delete;   -- Added by MK on 11/14/00
		l_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
		l_Token_Tbl(1).Token_Value :=
	          	p_Ref_Designator_Rec.component_item_name;

        	Error_Handler.Add_Error_Token
		(  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'BOM_RFD_ACD_NOT_COMPATIBLE'
		 , p_Token_Tbl		=> l_Token_Tbl
                 );
    	END IF;
    END LOOP;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified Compatible ACD Types . . .'); END IF;

    /************************************************************************
    * If the Transaction Type is CREATE and the ACD_type is ADD then check the
    * type of item to which a ref. designator is being added. Planning bills
    * cannot have ref. desgs and also  components which are not Standard cannot
    * have ref. desgs. This OR so even if either exists Ref. Designators cannot
    * be added.
    *************************************************************************/

    BEGIN
    	SELECT 'Non-Standard Comp'
      	  INTO l_dummy
      	  FROM bom_inventory_Components bic
         WHERE bic.component_sequence_id  =
	       p_Ref_Desg_Unexp_Rec.component_sequence_id
       	   AND bic.bom_item_type in (1, 2, 3); /*MODEL,OPTION CLASS,PLANNING*/

	   -- If no exception is raised then
	   -- Generate an error saying that the component is non-standard.

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            Error_Handler.Add_Error_Token
            (  x_Mesg_Token_tbl => l_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'BOM_RFD_NON_STD_PARENT'
             );
        END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- do nothing
			NULL;
		WHEN OTHERS THEN
--	        	dbms_output.put_line
--			('Unexpected error in Checking Planning Item ' ||
--                        SQLERRM
--                       );

                       Error_Handler.Add_Error_Token
                        (  x_Mesg_Token_tbl => l_Mesg_Token_tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_text   => 'ERROR in Entity validation '
                                               || SUBSTR(SQLERRM, 1, 30) ||
                                               ' ' || to_char(SQLCODE)
                         , p_message_name   => NULL
                         );

                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END;  /* End Checking for non-standard component */

     BEGIN
	  SELECT 'Planning Bill'
	    INTO l_dummy
	    FROM sys.dual
       	   WHERE EXISTS (SELECT 'Planning Item'
		     	     FROM bom_bill_of_materials bom,
			      	  mtl_system_items msi,
				  bom_inventory_components bic
		    	    WHERE msi.bom_item_type	= 3 /* PLANNING */
			      AND msi.inventory_item_id = bom.assembly_item_id
		      	      AND msi.organization_id   = bom.organization_id
			      AND bom.bill_sequence_id = bic.bill_sequence_id
			      AND bic.component_sequence_id =
				  p_Ref_Desg_Unexp_Rec.Component_sequence_id
			  );

	-- If a record is found, then log an error because of the above
	-- mentioned comment.
	l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            Error_Handler.Add_Error_Token
	    (  x_Mesg_Token_tbl	=> l_Mesg_Token_Tbl
	     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , p_message_name  	=> 'BOM_RFD_PLANNING_BILL'
             );
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL; -- Do nothing
		WHEN OTHERS THEN
--		      dbms_output.put_line
--			('Unexpected error in Checking Planning Item ' ||
--			SQLERRM
--			);

		       Error_Handler.Add_Error_Token
			(  x_Mesg_Token_tbl => l_Mesg_Token_tbl
			 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			 , p_message_text   => 'ERROR in Entity validation '
					       || SUBSTR(SQLERRM, 1, 30) ||
					       ' ' || to_char(SQLCODE)
			 , p_message_name   => NULL
                         );

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;  /* End Checking for Planning Parent */


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified Component not planning . . .'); END IF;

    /************************************************************************
    * If a ref. designator is being added or deleted, and if the Quantity
    * Related is 1 then their must be a check that the number of designators
    * is equal to the component_quantity.
    *************************************************************************/
    IF (p_ref_designator_rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE) THEN
    BEGIN

       OPEN c_QuantityRelated;
       FETCH c_QuantityRelated INTO l_Quantity;

       --IF c_QuantityRelated%FOUND THEN
       -- Bug No:3522842. For BOM BO Quantity Related validation will be done from Bom_Bo_Pvt.
       IF c_QuantityRelated%FOUND  AND Bom_Globals.Get_Bo_Identifier <> Bom_Globals.G_BOM_BO THEN

	  /*****************************************************************
          --
	  -- If no exception is raised then validate the actual quantity of
	  -- ref. designators with respect to the component quantity
	  -- If the designators are not equal, then generate a WARNING.
	  --
	  -- If the component to which the reference designator is added is a
	  -- CREATE/ADD then the reference designator must all have CREATE/ADD,
	  -- in this only the reference designators on the current component
	  -- need to be considered, therefore the old component sequence_id is
	  -- same as component sequence id. But, if the parent component is
	  -- CREATE/CHANGE, then ref. designators to the old and new
	  -- component should be considered
	  ******************************************************************/

	 FOR acd IN c_acdtype LOOP
		IF acd.acd_type = 2 /* CHANGE */
		THEN
	  	    Calculate_Both_Totals
		    (  p_old_component_sequence_id =>
		       acd.old_component_sequence_id
		     , x_TotalQuantity             => l_ref_qty
		     );
		ELSE
		    Calculate_Both_Totals
		    (  p_old_component_sequence_id =>
		       p_ref_desg_Unexp_rec.component_sequence_id
                     , x_TotalQuantity             => l_ref_qty);
		END IF;
	 END LOOP;

--	dbms_output.put_line('Ref. Desg Qty: ' || to_char(l_ref_qty));
--	dbms_output.put_line('Quantity: ' || to_char(l_quantity));


	  /***************************************************************
	  -- Since the Component Quantity is Mandatory is must have been
	  -- validated prior to this call or it must have been defaulted
	  -- to 1 if the user has not supplied a value.
	  ****************************************************************/

	  IF (p_ref_designator_rec.acd_type  = 1) THEN
   	     l_change := 1;
	  ELSIF (p_ref_designator_rec.acd_type  = 3) THEN
	     l_change := -1;
	  END IF;

	  IF l_quantity <> l_ref_qty + l_change THEN
		-- Log a warning but do not set the error status
                l_token_tbl.delete ; -- Added by MK on 11/14/00
		l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
		l_token_tbl(1).token_value :=
			p_ref_designator_rec.component_item_name;
                Error_Handler.Add_Error_Token
		(  x_Mesg_Token_Tbl	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name  	=> 'BOM_QUANTITY_RELATED_INVALID'
		 , p_token_tbl		=> l_token_tbl
                 , p_message_type       => 'W' -- Added by MK on 11/14/00
                 );
	  END IF;

       END IF;
       CLOSE c_QuantityRelated;
    END;     /* operation = CREATE ENDS */
    END IF;  /* If Operation = CREATE ENDS */

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified Quantity Related . . .'); END IF;

    --  Done validating entity

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;


/* When the Designator name is updated with New_designator, It should be checked that the new_desinator
does not exists already */

     IF ( p_ref_designator_rec.new_reference_designator is not null
          and p_ref_designator_rec.new_reference_designator <> FND_API.G_MISS_CHAR
            and p_ref_designator_rec.transaction_type = Bom_Globals.G_OPR_UPDATE) THEN

        select count(*) into l_temp_var
          FROM    BOM_REFERENCE_DESIGNATORS
      	  WHERE   COMPONENT_REFERENCE_DESIGNATOR =  p_ref_designator_rec.new_reference_designator
    	  AND     COMPONENT_SEQUENCE_ID = p_Ref_Desg_Unexp_Rec.component_sequence_id
    	  AND     NVL(DECODE(ACD_TYPE, FND_API.G_MISS_NUM, null, acd_type), 0) =
          NVL(DECODE(p_ref_designator_rec.acd_type, FND_API.G_MISS_NUM, null, p_ref_designator_rec.acd_type), 0) ;

        IF (l_temp_var <>0) then

        	l_Token_Tbl(1).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
        	l_Token_Tbl(1).Token_Value :=
                        p_ref_designator_rec.new_reference_designator;
        	l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
        	l_token_tbl(2).token_value := p_ref_designator_rec.component_item_name;

                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'BOM_REF_DESG_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified New_designator ...'); END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Expected Error in Ref Desgs. Entity Validation '); END IF;

	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('UNExpected Error in Ref. Desgs Entity Validation '); END IF;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Entity;

/********************************************************************
*
* Procedure     : Check_Attributes
* Parameters IN : Reference Designator Record as given by the User
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Attribute validation will validate individual attributes
*		  and any errors will be populated in the Mesg_Token_Tbl
*		  and returned with a return_status.
********************************************************************/

PROCEDURE Check_Attributes
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
)
IS
l_token_tbl		Error_Handler.Token_tbl_Type;
l_Mesg_token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate ref_designator attributes

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation Starts . . . '); END IF;

    IF p_ref_designator_rec.acd_type IS NOT NULL AND
       ( ( Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO AND
           p_ref_designator_rec.acd_type NOT IN(1, 3)
	  ) OR
	 ( Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO AND
	   p_ref_designator_rec.acd_type IS NOT NULL OR
	   p_ref_designator_rec.acd_type <> FND_API.G_MISS_NUM
	 )
	)
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		l_token_tbl(1).token_name := 'REF_DESG';
		l_token_tbl(1).token_value := 'BOM_REF_DESG_CAP';
		l_token_tbl(1).translate   := TRUE;

		Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'BOM_RFD_SBC_ACD_TYPE_INVALID'
                 , p_token_tbl		=> l_token_tbl
		 );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After ACD_TYPE . . .'); END IF;

    --  Done validating attributes
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Expected Error in Ref. Desgs Attr Validation . . .'); END IF;
	x_Mesg_token_Tbl := l_Mesg_token_Tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('UNExpected Error in Ref. Desgs Attr Validation . . .'); END IF;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Attributes;

/********************************************************************
*
* Procedure     : Check_Entity_Delete
* Parameters IN : Reference Designator Record as given by the User
*                 Reference Designator Unexposed Record
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Entity Delete procedure will verify if the entity can
*		  can be deleted without violating any business rules.
*		  In case of errors the Mesg_token_Tbl is populated and
*		  process return with a status other than 'S'
*		  Warning will not prevent the entity from being deleted.
********************************************************************/

PROCEDURE Check_Entity_Delete
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Mesg_Token_Tbl	      Error_Handler.Mesg_Token_Tbl_Type;
l_token_tbl		      Error_Handler.Token_Tbl_Type;
l_rec_BIT              NUMBER;
l_parent_BIT           NUMBER;
l_parent_PTO_flag      VARCHAR2(1);
l_rec_ATO_flag         VARCHAR2(1);
l_rec_optional         NUMBER;
BEGIN


    BEGIN
    --validation for BOM ER
     SELECT     bic.bom_item_type,
                msi.bom_item_type,
                msi.pick_components_flag,
                msi2.replenish_to_order_flag,
                bic.optional
         INTO   l_rec_BIT,
                l_parent_BIT,
                l_parent_PTO_flag,
                l_rec_ATO_flag,
                l_rec_optional
         FROM   mtl_system_items msi,
                mtl_system_items msi2,
                bom_inventory_components bic,
                bom_bill_of_materials bbom
        WHERE   msi.inventory_item_id = bbom.assembly_item_id
        AND     msi.organization_id = bbom.organization_id
        AND     msi2.inventory_item_id = bic.component_item_id
        AND     msi2.organization_id = bic.pk2_value
        AND     bic.component_sequence_id =
		p_Ref_Desg_Unexp_rec.component_sequence_id
        AND     bic.bill_sequence_id = bbom.bill_sequence_id;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

       IF
        nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 AND
        l_parent_BIT = Bom_Globals.G_STANDARD AND
        l_parent_PTO_Flag  = 'Y' AND
        l_rec_ATO_Flag = 'Y' AND
        l_rec_BIT = Bom_Globals.G_STANDARD
        THEN
        Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_KIT_COMP_PRF_NOT_SET'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
        l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


    --if a mandatory ATO item was added in a pto model when the related profile was set, you cannot
    --update or delete the component once the profile is unset (meaning you cannot insert, update
    --or delete a substitute component on it

        IF
        nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1 AND
        l_parent_BIT = Bom_Globals.G_MODEL AND
        l_parent_PTO_Flag  = 'Y' AND
        l_rec_ATO_Flag = 'Y' AND
        l_rec_BIT = Bom_Globals.G_STANDARD AND
        l_rec_optional = 2
        THEN
        Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_MODEL_COMP_PRF_NOT_SET'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
        l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
       --BOM ER changes (end)


    /***********************************************************************
    -- If a Ref, Designator is being deleted and the Quantity Related for the
    -- Component is 1 then a warning must be given if the the deletion is
    -- going to make the number or designators <> Component Quantity.
    ************************************************************************/
    BEGIN
 	SELECT 'Related'
	  INTO l_dummy
	  FROM bom_inventory_components
	 WHERE quantity_related = 1
	   AND component_sequence_id =
	       p_ref_desg_Unexp_rec.component_sequence_id;


	-- But the Quantity Related is 1 so log a warning
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			-- This ideally should be a warning
        THEN
                -- Added token by MK on 12/06/00
                l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
                l_token_tbl(1).token_value :=
                        p_ref_designator_rec.component_item_name;

     		Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'BOM_QUANTITY_RELATED_INVALID'
                 , p_message_type       => 'W'

                 );
	END IF;

     EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
     END ;

     -- Added by MK on 11/14/00
     x_return_status :=  l_return_status ;
     x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Entity_Delete;

/*****************************************************************************
* Procedure     : Check_Existence
* Parameters IN : Refernce Designator exposed column record
*                 Refernce Designator unexposed column record
* Parameters OUT: Old Reference Designator exposed column record
*                 Old Reference Designator unexposed column record
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
(  p_ref_designator_rec         IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec         IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_old_ref_designator_rec     IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
 , x_old_ref_desg_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_Return_Status		VARCHAR2(1);
	l_Token_Tbl		Error_Handler.Token_Tbl_Type;
BEGIN
        l_Token_Tbl(1).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
        l_Token_Tbl(1).Token_Value :=
			p_ref_designator_rec.reference_designator_name;
	l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
	l_token_tbl(2).token_value := p_ref_designator_rec.component_item_name;

        BOM_Ref_Designator_Util.Query_Row
	(   p_ref_designator		=>
				p_ref_designator_rec.reference_designator_name
	,   p_component_sequence_id	=>
				p_ref_desg_unexp_rec.component_sequence_id
	,   p_acd_type			=> p_ref_designator_rec.acd_type
	,   x_Ref_Designator_Rec	=> x_old_ref_designator_rec
	,   x_Ref_Desg_Unexp_Rec	=> x_old_ref_desg_unexp_rec
	,   x_Return_Status		=> l_return_status
	);

        IF l_return_status = Bom_Globals.G_RECORD_FOUND AND
           p_ref_designator_rec.transaction_type = Bom_Globals.G_OPR_CREATE
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'BOM_REF_DESG_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = Bom_Globals.G_RECORD_NOT_FOUND AND
              p_ref_designator_rec.transaction_type IN
                 (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'BOM_REF_DESG_DOESNOT_EXIST'
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
                   'Reference Designator '||
                   p_ref_designator_rec.reference_designator_name
                 , p_token_tbl          => l_token_tbl
                 );
        ELSE

                 /* Assign the relevant transaction type for SYNC operations */

                 IF p_ref_designator_rec.transaction_type = 'SYNC' THEN
                   IF l_return_status = Bom_Globals.G_RECORD_FOUND THEN
                     x_old_ref_designator_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_UPDATE;
                   ELSE
                     x_old_ref_designator_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_CREATE;
                   END IF;
                 END IF;
                 l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Existence;

PROCEDURE Check_Lineage
(  p_ref_designator_rec         IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec         IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
	l_token_tbl 		Error_Handler.Token_Tbl_Type;
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

	CURSOR c_GetComponent IS
	SELECT revised_item_sequence_id
	  FROM bom_inventory_components
	 WHERE component_item_id= p_ref_desg_unexp_rec.component_item_id
	   AND operation_seq_num=p_ref_designator_rec.operation_sequence_number
	   AND effectivity_date = p_ref_designator_rec.start_effective_date
	   AND bill_sequence_id = p_ref_desg_unexp_rec.bill_sequence_id;
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	FOR Component IN c_GetComponent LOOP
		IF Component.revised_item_sequence_id <>
			p_ref_desg_unexp_rec.revised_item_sequence_id
		THEN
                                l_Token_Tbl(1).token_name  :=
					'REVISED_COMPONENT_NAME';
                                l_Token_Tbl(1).token_value :=
                                     p_ref_designator_rec.component_item_name;
                                l_Token_Tbl(2).token_name  :=
					'REFERENCE_DESIGNATOR_NAME';
                                l_Token_Tbl(2).token_value :=
                                 p_ref_designator_rec.reference_designator_name;
				 l_Token_Tbl(3).token_name  :=
                                        'REVISED_ITEM_NAME';
                                l_Token_Tbl(3).token_value :=
                                 p_ref_designator_rec.revised_item_name;

                                Error_Handler.Add_Error_Token
                                (  p_Message_Name => 'BOM_REF_REV_ITEM_MISMATCH'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                 );
                                x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	END LOOP;

	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END CHECK_LINEAGE;

PROCEDURE CHECK_ACCESS
(  p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status	IN OUT NOCOPY VARCHAR2
)
IS
	l_return_status		VARCHAR2(1);
	l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_dummy			VARCHAR2(80);
	l_token_tbl		Error_Handler.Token_Tbl_Type;
BEGIN
	l_return_status := FND_API.G_RET_STS_SUCCESS;

    /************************************************************************
     *
     * If the parent component is having an ACD_type of Disable then cannot
     * perform any operations on the reference designator.
     *
     ************************************************************************/
    BEGIN
        SELECT 'parent not disabled'
          INTO l_dummy
          FROM bom_inventory_components bic
         WHERE bic.component_sequence_id =
               p_Ref_Desg_Unexp_Rec.component_sequence_id
           AND NVL(bic.acd_type, 0)  <> 3;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        -- This means that the parent is disabled as
                        -- the record search was fired to get a parent
                        -- which is not disabled

                        l_token_Tbl(1).Token_Name := 'REF_DESG';
                        l_token_Tbl(1).Token_Value :=
                        p_Ref_Designator_Rec.Reference_Designator_Name;

                        Error_Handler.Add_Error_Token
                        (  x_Mesg_Token_tbl   => l_Mesg_token_tbl
                         , p_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                         , p_message_name     => 'BOM_RFD_COMP_ACD_TYPE_DISABLE'
                         , p_Token_Tbl        => l_Token_Tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                WHEN OTHERS THEN
                        --This means that an unexpected error has occured
                       Error_Handler.Add_Error_Token
                        (  x_Mesg_Token_tbl     => l_Mesg_Token_tbl
                         , p_Mesg_token_Tbl     => l_Mesg_Token_Tbl
                         , p_message_name       => NULL
                         , p_message_text       => 'ERROR in Entity validation '
                                                   || SUBSTR(SQLERRM, 1, 240)
                                                   || ' ' || to_char(SQLCODE)
                         );

                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
    x_return_status  := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END CHECK_ACCESS;

/*
** BOM Business Object procedure calls
*/
PROCEDURE Check_Entity
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_ref_designator_rec        IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_bom_Ref_Desg_Unexp_Rec        IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
)
IS
	l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_rec_Type;
	l_ref_desg_unexp_rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN
	--Convert the BOM Record to ECO

	Bom_Bo_Pub.Convert_Bomdesg_To_EcoDesg
	(  p_bom_ref_designator_rec	=> p_bom_ref_designator_rec
	 , p_bom_ref_desg_unexp_rec	=> p_bom_ref_desg_unexp_rec
	 , x_ref_designator_rec		=> l_Ref_designator_rec
	 , x_ref_Desg_unexp_rec		=> l_ref_desg_unexp_rec
	);

	-- Call Check Entity
	Bom_Validate_Ref_Designator.Check_Entity
	(  p_ref_designator_rec		=> l_ref_designator_rec
	 , p_ref_desg_unexp_rec		=> l_Ref_Desg_unexp_rec
	 , x_return_status		=> x_return_status
	 , x_mesg_token_tbl		=> x_mesg_token_tbl
	);

END Check_Entity;

--  Procedure Attributes

PROCEDURE Check_Attributes
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_Bom_ref_designator_rec        IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
)
IS
        l_ref_designator_rec    Bom_Bo_Pub.Ref_Designator_rec_Type;
        l_ref_desg_unexp_rec    Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN
        --Convert the BOM Record to ECO

        Bom_Bo_Pub.Convert_Bomdesg_To_EcoDesg
        (  p_bom_ref_designator_rec     => p_bom_ref_designator_rec
         , x_ref_designator_rec         => l_Ref_designator_rec
         , x_ref_Desg_unexp_rec         => l_ref_desg_unexp_rec
        );

        -- Call Check Entity
        Bom_Validate_Ref_Designator.Check_Attributes
        (  p_ref_designator_rec         => l_ref_designator_rec
         , x_return_status              => x_return_status
         , x_mesg_token_tbl             => x_mesg_token_tbl
        );

END Check_Attributes;

--  Procedure Entity_Delete

PROCEDURE Check_Entity_Delete
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_ref_designator_rec        IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_bom_Ref_Desg_Unexp_Rec        IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
)
IS
        l_ref_designator_rec    Bom_Bo_Pub.Ref_Designator_rec_Type;
        l_ref_desg_unexp_rec    Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN
        --Convert the BOM Record to ECO

        Bom_Bo_Pub.Convert_Bomdesg_To_EcoDesg
        (  p_bom_ref_designator_rec     => p_bom_ref_designator_rec
         , p_bom_ref_desg_unexp_rec     => p_bom_ref_desg_unexp_rec
         , x_ref_designator_rec         => l_Ref_designator_rec
         , x_ref_Desg_unexp_rec         => l_ref_desg_unexp_rec
        );

        -- Call Check Entity
        Bom_Validate_Ref_Designator.Check_Entity_Delete
        (  p_ref_designator_rec         => l_ref_designator_rec
         , p_ref_desg_unexp_rec         => l_Ref_Desg_unexp_rec
         , x_return_status              => x_return_status
         , x_mesg_token_tbl             => x_mesg_token_tbl
        );


END Check_Entity_Delete;

PROCEDURE Check_Existence
(  p_bom_ref_designator_rec         IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
 , p_bom_ref_desg_unexp_rec         IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_old_bom_ref_designator_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
 , x_old_bom_ref_desg_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
        l_ref_designator_rec    Bom_Bo_Pub.Ref_Designator_rec_Type;
        l_ref_desg_unexp_rec    Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
	l_old_ref_designator_rec Bom_Bo_Pub.Ref_Designator_Rec_Type;
	l_old_ref_desg_unexp_rec Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;

BEGIN
        --Convert the BOM Record to ECO

        Bom_Bo_Pub.Convert_Bomdesg_To_EcoDesg
        (  p_bom_ref_designator_rec     => p_bom_ref_designator_rec
         , p_bom_ref_desg_unexp_rec     => p_bom_ref_desg_unexp_rec
         , x_ref_designator_rec         => l_Ref_designator_rec
         , x_ref_Desg_unexp_rec         => l_ref_desg_unexp_rec
        );

-- dbms_output.put_line('Before Check Existence . . . ');
-- dbms_output.put_line('Component Sequence: ' || l_ref_desg_unexp_rec.component_sequence_id);
-- dbms_output.put_line('Reference Designator ' || l_Ref_designator_rec.reference_designator_name);

        -- Call Check Entity
        Bom_Validate_Ref_Designator.Check_Existence
        (  p_ref_designator_rec         => l_ref_designator_rec
         , p_ref_desg_unexp_rec         => l_Ref_Desg_unexp_rec
	 , x_old_ref_designator_rec	=> l_old_ref_designator_rec
	 , x_old_ref_desg_unexp_rec	=> l_old_ref_desg_unexp_rec
         , x_return_status              => x_return_status
         , x_mesg_token_tbl             => x_mesg_token_tbl
        );

	-- Convert ECO Record to BOM before returning
	Bom_Bo_Pub.Convert_EcoDesg_To_BomDesg
	(  p_ref_designator_rec		=> l_old_ref_designator_rec
	 , p_ref_desg_unexp_rec		=> l_old_ref_desg_unexp_rec
	 , x_bom_ref_designator_rec	=> x_old_bom_ref_designator_rec
	 , x_bom_ref_desg_unexp_rec	=> x_old_bom_ref_desg_unexp_rec
	);

END Check_Existence;

PROCEDURE Check_Lineage
(  p_bom_ref_designator_rec         IN  Bom_Bo_Pub.bom_Ref_Designator_Rec_Type
 , p_bom_ref_desg_unexp_rec         IN  Bom_Bo_Pub.bom_Ref_Desg_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
        l_ref_designator_rec    Bom_Bo_Pub.Ref_Designator_rec_Type;
        l_ref_desg_unexp_rec    Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN
        --Convert the BOM Record to ECO

        Bom_Bo_Pub.Convert_Bomdesg_To_EcoDesg
        (  p_bom_ref_designator_rec     => p_bom_ref_designator_rec
         , p_bom_ref_desg_unexp_rec     => p_bom_ref_desg_unexp_rec
         , x_ref_designator_rec         => l_Ref_designator_rec
         , x_ref_Desg_unexp_rec         => l_ref_desg_unexp_rec
        );

        -- Call Check Entity
        Bom_Validate_Ref_Designator.Check_Lineage
        (  p_ref_designator_rec         => l_ref_designator_rec
         , p_ref_desg_unexp_rec         => l_Ref_Desg_unexp_rec
         , x_return_status              => x_return_status
         , x_mesg_token_tbl             => x_mesg_token_tbl
        );

END Check_Lineage;

PROCEDURE CHECK_ACCESS
(  p_bom_ref_designator_rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
 , p_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
)
IS
        l_ref_designator_rec    Bom_Bo_Pub.Ref_Designator_rec_Type;
        l_ref_desg_unexp_rec    Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN
        --Convert the BOM Record to ECO

        Bom_Bo_Pub.Convert_Bomdesg_To_EcoDesg
        (  p_bom_ref_designator_rec     => p_bom_ref_designator_rec
         , p_bom_ref_desg_unexp_rec     => p_bom_ref_desg_unexp_rec
         , x_ref_designator_rec         => l_Ref_designator_rec
         , x_ref_Desg_unexp_rec         => l_ref_desg_unexp_rec
        );

        -- Call Check Access
        Bom_Validate_Ref_Designator.Check_Access
        (  p_ref_designator_rec         => l_ref_designator_rec
         , p_ref_desg_unexp_rec         => l_Ref_Desg_unexp_rec
         , x_return_status              => x_return_status
         , x_mesg_token_tbl             => x_mesg_token_tbl
        );

END Check_Access;


END BOM_Validate_Ref_Designator;

/
