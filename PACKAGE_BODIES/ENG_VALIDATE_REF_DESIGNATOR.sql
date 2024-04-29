--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE_REF_DESIGNATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE_REF_DESIGNATOR" 
/* $Header: ENGLRFDB.pls 115.16 2002/12/13 00:12:46 bbontemp ship $ */
AS
G_PKG_NAME	CONSTANT VARCHAR2(30) := 'ENG_Validate_Ref_Designator';
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
				 x_TotalQuantity		OUT NOCOPY	NUMBER
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
    Where DECODE(bic.old_component_sequence_id, NULL,
		 bic.component_sequence_id,
		 bic.old_component_sequence_id) = p_old_component_sequence_id
    And   bic.component_sequence_id = brd.component_sequence_id
    And   bic.implementation_date is null
    And   brd.acd_type = X_Add
    Minus
    Select brd.component_reference_designator
    From bom_reference_designators brd,
         bom_inventory_components bic
    Where DECODE(bic.old_component_sequence_id, NULL,
		 bic.component_sequence_id,
		 bic.old_component_sequence_id) = p_old_component_sequence_id
    And   bic.component_sequence_id = brd.component_sequence_id
    And   bic.implementation_date is null
    And   brd.acd_type = X_Delete;

BEGIN
  For X_Designators in GetTotalQty loop
    X_TotalQuantity := GetTotalQty%rowcount;
    RETURN;
  End loop;

  -- Else return 0
  X_TotalQuantity := 0;

END Calculate_Both_Totals;

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
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec        IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
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

--dbms_output.put_line('Entity Validation for Ref. Desgs begins . . .');

    -- The ECO can be updated but a warning needs to be generated and
    -- scheduled revised items need to be update to Open
    -- and the ECO status need to be changed to Not Submitted for Approval

    BOM_GLOBALS.Check_Approved_For_Process
	( p_change_notice    => p_ref_designator_rec.Eco_Name,
          p_organization_id  => p_ref_desg_Unexp_rec.organization_id,
          x_processed        => l_processed,
          x_err_text         => l_err_text
        );

    IF l_processed = TRUE THEN
          -- If the above process returns true then set the ECO approval.

    	BEGIN
          BOM_GLOBALS.Set_Request_For_Approval
	  ( p_change_notice     => p_ref_designator_rec.Eco_Name,
            p_organization_id   => p_ref_desg_Unexp_rec.organization_id,
            x_err_text          => l_err_text
           );

          EXCEPTION
                    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                          l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END;

     END IF;

--dbms_output.put_line('Verified if process exists . . .');

     /**********************************************************************
     *
     * If the Transaction Type is CREATE and the ACD_Type = Disable, then
     * the reference designator should already exist for the revised
     * component.
     *
     ***********************************************************************/
     IF p_ref_designator_rec.acd_type = 3 THEN
	BEGIN
		SELECT 1
		  INTO l_dummy
		  FROM bom_inventory_components
	         WHERE component_sequence_id =
		       p_ref_desg_unexp_rec.component_sequence_id
		   AND implementation_date IS NOT NULL
		   AND exists ( SELECT 1
				  FROM bom_reference_designators
				 WHERE component_sequence_id =
				 p_ref_desg_unexp_rec.component_sequence_id
				   AND component_reference_designator =
				 p_ref_designator_rec.reference_designator_name
				   AND acd_type = 1
				);

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
                 	 , p_message_name       => 'ENG_DISABLE_DESG_NOT_FOUND'
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

		l_Token_Tbl(1).Token_Name := 'REVISED_COMPONENT_NAME';
		l_Token_Tbl(1).Token_Value :=
		p_Ref_Designator_Rec.component_item_name;

        	Error_Handler.Add_Error_Token
		(  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'ENG_RFD_ACD_NOT_COMPATIBLE'
		 , p_Token_Tbl		=> l_Token_Tbl
                 );
    	END IF;
    END LOOP;

--dbms_output.put_line('Verified Compatible ACD Types . . .');

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
             , p_message_name   => 'ENG_RFD_NON_STD_PARENT'
             );
        END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- do nothing
			NULL;
		WHEN OTHERS THEN
	        	--dbms_output.put_line
            --            ('Unexpected error in Checking Planning Item ' ||
            --              SQLERRM
            --             );

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
             , p_message_name  	=> 'ENG_RFD_PLANNING_BILL'
             );
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL; -- Do nothing
		WHEN OTHERS THEN
		      --dbms_output.put_line
			--('Unexpected error in Checking Planning Item ' ||
			--  SQLERRM
			-- );

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


--dbms_output.put_line('Verified Component not planning . . .');

    /************************************************************************
    * If a ref. designator is being added or deleted, and if the Quantity
    * Related is 1 then their must be a check that the number of designators
    * is equal to the component_quantity.
    *************************************************************************/
    IF (p_ref_designator_rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE) THEN
    BEGIN

       OPEN c_QuantityRelated;
       FETCH c_QuantityRelated INTO l_Quantity;

       IF c_QuantityRelated%FOUND THEN

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

	--dbms_output.put_line('Ref. Desg Qty: ' || to_char(l_ref_qty));
	--dbms_output.put_line('Quantity: ' || to_char(l_quantity));


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
		l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
		l_token_tbl(1).token_value :=
			p_ref_designator_rec.component_item_name;
                Error_Handler.Add_Error_Token
		(  x_Mesg_Token_Tbl	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name  	=> 'ENG_QUANTITY_RELATED_INVALID'
		 , p_token_tbl		=> l_token_tbl
                 );
	  END IF;

       END IF;
       CLOSE c_QuantityRelated;
    END;     /* operation = CREATE ENDS */
    END IF;  /* If Operation = CREATE ENDS */

--dbms_output.put_line('Verified Quantity Related . . .');

    --  Done validating entity

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

--dbms_output.put_line('Expected Error in Ref Desgs. Entity Validation ');

	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

--dbms_output.put_line('UNExpected Error in Ref. Desgs Entity Validation ');
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
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
)
IS
l_token_tbl		Error_Handler.Token_tbl_Type;
l_Mesg_token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate ref_designator attributes

--dbms_output.put_line('Attribute Validation Starts . . . ');

    IF p_ref_designator_rec.acd_type IS NOT NULL AND
       p_ref_designator_rec.acd_type NOT IN(1, 3)
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		l_token_tbl(1).token_name := 'REF_DESG';
		l_token_tbl(1).token_value := 'ENG_REF_DESG_CAP';
		l_token_tbl(1).translate   := TRUE;

		Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'ENG_RFD_SBC_ACD_TYPE_INVALID'
                 , p_token_tbl		=> l_token_tbl
		 );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

--dbms_output.put_line('After ACD_TYPE . . .');

    --  Done validating attributes
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

--dbms_output.put_line('Expected Error in Ref. Desgs Attr Validation . . .');
	x_Mesg_token_Tbl := l_Mesg_token_Tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

--dbms_output.put_line('UNExpected Error in Ref. Desgs Attr Validation . . .');
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
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Mesg_Token_Tbl	      Error_Handler.Mesg_Token_Tbl_Type;

BEGIN

    /***********************************************************************
    -- If a Ref, Designator is being deleted and the Quantity Related for the
    -- Component is 1 then a warning must be given if the the deletion is
    -- going to make the number or designators <> Component Quantity.
    ************************************************************************/
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
     		Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'ENG_QUANTITY_RELATED_INVALID'
                 );
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;

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
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
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

        ENG_Ref_Designator_Util.Query_Row
	(   p_ref_designator		=>
				p_ref_designator_rec.reference_designator_name
	,   p_component_sequence_id	=>
				p_ref_desg_unexp_rec.component_sequence_id
	,   p_acd_type			=> p_ref_designator_rec.acd_type
	,   x_Ref_Designator_Rec	=> x_old_ref_designator_rec
	,   x_Ref_Desg_Unexp_Rec	=> x_old_ref_desg_unexp_rec
	,   x_Return_Status		=> l_return_status
	);

        IF l_return_status = BOM_Globals.G_RECORD_FOUND AND
           p_ref_designator_rec.transaction_type = BOM_Globals.G_OPR_CREATE
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_REF_DESG_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = BOM_Globals.G_RECORD_NOT_FOUND AND
              p_ref_designator_rec.transaction_type IN
                 (BOM_Globals.G_OPR_UPDATE, BOM_Globals.G_OPR_DELETE)
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_REF_DESG_DOESNOT_EXIST'
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
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Existence;

PROCEDURE Check_Lineage
(  p_ref_designator_rec         IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec         IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
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
                                (  p_Message_Name => 'ENG_REF_REV_ITEM_MISMATCH'
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
 , x_Mesg_Token_Tbl	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status	OUT NOCOPY VARCHAR2
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
                         , p_message_name     => 'ENG_RFD_COMP_ACD_TYPE_DISABLE'
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

END ENG_Validate_Ref_Designator;

/
