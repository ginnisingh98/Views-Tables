--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE_SUB_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE_SUB_COMPONENT" AS
/* $Header: ENGLSBCB.pls 115.23 2002/12/12 18:52:43 akumar ship $ */

--  +------------------------------------------+
--  | Global constant holding the package name |
--  +------------------------------------------+

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'ENG_Validate_Sub_Component';
G_RET_CODE       NUMBER;

/*********************** Entity **********************************************/

PROCEDURE CHECK_REQUIRED(  x_return_status	OUT NOCOPY VARCHAR2
			 , p_sub_component_rec	 IN
			   Bom_Bo_Pub.Sub_Component_Rec_Type
			 , x_Mesg_Token_tbl	OUT NOCOPY
			   Error_Handler.Mesg_Token_Tbl_Type
			 )
IS
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN
	IF p_sub_component_rec.Revised_Item_Name IS NULL OR
	   p_sub_component_rec.Revised_Item_Name = FND_API.G_MISS_CHAR OR
	   p_sub_component_rec.Start_Effective_Date IS NULL OR
	   p_sub_component_rec.Start_Effective_Date = FND_API.G_MISS_DATE OR
	   p_sub_component_rec.New_Revised_Item_Revision IS NULL OR
	   p_sub_component_rec.New_Revised_Item_Revision = FND_API.G_MISS_CHAR OR
	   p_sub_component_rec.Operation_Sequence_Number IS NULL OR
	   p_sub_component_rec.Operation_Sequence_Number = FND_API.G_MISS_NUM OR
	   p_sub_component_rec.Component_Item_Name IS NULL OR
	   p_sub_component_rec.Component_Item_Name = FND_API.G_MISS_CHAR OR
	   p_sub_component_rec.Alternate_BOM_Code IS NULL OR
	   p_sub_component_rec.Alternate_BOM_Code = FND_API.G_MISS_CHAR OR
	   p_sub_component_rec.Substitute_Component_Name IS NULL OR
	   p_sub_component_rec.Substitute_Component_Name = FND_API.G_MISS_CHAR OR
	   p_sub_component_rec.acd_type	IS NULL OR
	   p_sub_component_rec.acd_type	= FND_API.G_MISS_NUM
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		Error_Handler.Add_Error_Token
		(  x_Mesg_Token_Tbl	=> x_Mesg_Token_Tbl
		,  p_Message_Name	=> 'ENG_SUB_COMP_REQ'
		,  p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		);
		-- Log an error indicating that one of the required columns is
		-- missing with scope of 'R'
		RETURN;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

END CHECK_REQUIRED;

/*******************************************************************
* Procedure	: Entity
* Parameter IN	: Substitute Component Record
*		  Substitute component Record of Unexposed Columns
* Parameter OUT	: Return_Status - Indicating status of the process.
*		  Mesg_Token_Tbl - Table of Errors and their tokens
*
* Purpose	: Entity procedure will validate the entity record by
*		  verfying the business logic for Substitute Components
*
*********************************************************************/
PROCEDURE Check_Entity
(   x_return_status         OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl	    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec     IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_Sub_Comp_Unexp_Rec    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
)
IS
    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_sub_comp_unique   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_dummy             NUMBER :=0;
    l_dummy2            NUMBER :=0;
    l_parent_acd_type   NUMBER :=0;
    l_parent_BIT        NUMBER;
    l_rec_BSI           NUMBER;
    l_rec_AST           NUMBER;
    l_rec_BIT           NUMBER;
    l_rec_AII           NUMBER;
    l_rec_CII           NUMBER;
    l_rec_ID            DATE;
    l_processed         BOOLEAN;
    l_err_text          VARCHAR2(200);
    stmt_num            NUMBER := 0;
    l_token_tbl		Error_Handler.Token_Tbl_Type;
    l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
    l_sbc_item_type	NUMBER;
    l_sbc_bom_enabled_flag VARCHAR2(1);
    l_sbc_eng_item_flag	   VARCHAR2(1);
BEGIN

    BEGIN
       ------------------------------------------------------------------
       -- Select Bill_Sequence_Id, Assembly_Type, Assembly_Item_Id,     |
       -- ACD_TYPE, Component_Item_Id and Implementation_Date           |
       -- from bom_inventory_component and bom_bill_of_materials tables |
       ------------------------------------------------------------------

       SELECT   bbom.bill_sequence_id ,
                bbom.assembly_type,
                bbom.assembly_item_id,
                bic.ACD_TYPE,
                bic.bom_item_type,
                bic.component_item_id,
                bic.implementation_date,
                msi.bom_item_type
         INTO   l_rec_BSI,
                l_rec_AST,
                l_rec_AII,
                l_parent_acd_type,
                l_rec_BIT,
                l_rec_CII,
                l_rec_ID,
                l_parent_BIT
         FROM   mtl_system_items msi,
                bom_inventory_components bic,
                bom_bill_of_materials bbom
        WHERE   msi.inventory_item_id = bbom.assembly_item_id
        AND     msi.organization_id = bbom.organization_id
        AND     bic.component_sequence_id =
		p_Sub_Comp_Unexp_Rec.component_sequence_id
        AND     bic.bill_sequence_id = bbom.bill_sequence_id;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
--dbms_output.put_line('Bill SequenceId : ' || to_char(l_rec_BSI));
--dbms_output.put_line('Assembly Type   : ' || to_char(l_rec_AST));
--dbms_output.put_line('Comp SequenceId : ' || to_char(p_Sub_Comp_Unexp_Rec.component_sequence_id));


    ---------------------------------------------------------------------
    -- If the Transaction Type is CREATE and the ACD_type is ADD        |
    -- then check the type of item to which a sub component is being    |
    -- added. Planning bills cannot have sub comps esgs and also        |
    -- components which are not Standard cannot have sub comps. This    |
    --  OR so even if either exists sub comp cannot be added.           |
    ---------------------------------------------------------------------
    IF p_sub_component_rec.Transaction_Type = Bom_Globals.G_OPR_CREATE THEN

        BEGIN
--dbms_output.put_line('Checking for planning bill or non-std. component . . . ');

	    IF l_rec_bit IN (1, 2, 3)
	    THEN
             l_err_text := 'ENG_SBC_NON_STD_PARENT';
	     l_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		--dbms_output.put_line
        	-- ('Expected Error. non-standard component . . . ');

                Error_Handler.Add_Error_Token
                (  x_Mesg_Token_tbl     => l_Mesg_Token_tbl
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_message_name       => l_err_text
                 );
              END IF;

	    END IF;

	    IF l_parent_bit = 3 THEN
		l_Err_text := 'ENG_SBC_PLANNING_BILL';
		l_return_status := FND_API.G_RET_STS_ERROR;

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                --dbms_output.put_line
                -- ('Expected Error. planning parent. . . ');

                Error_Handler.Add_Error_Token
                (  x_Mesg_Token_tbl     => l_Mesg_Token_tbl
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_message_name       => l_err_text
                 );
              END IF;
	    END IF;

            -----------------------------------------------------------------
            -- If a record is found, then log an error because of the above |
            -- mentioned comment.                                           |
            -----------------------------------------------------------------

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- Do nothing
            WHEN OTHERS THEN
                --dbms_output.put_line('Unexpected error in Checking Planning Item
                --    ' || SQLERRM);
                Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl => l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => NULL
                 , p_message_text  => 'ERROR in Entity validation ' ||
                        	      substr(SQLERRM, 1, 240) || ' ' ||
				      to_char(SQLCODE)
                 );
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

    END IF;

    ------------------------------------------------------------------
    -- When update an ECO that has (a process and Approval Status of |
    -- 'Approval approved') we should change status to not submitted |
    -- for Approval                                                  |
    ------------------------------------------------------------------
    stmt_num := 2;
    IF (p_sub_component_rec.Transaction_Type = Bom_Globals.G_OPR_UPDATE OR
        p_sub_component_rec.Transaction_Type = Bom_Globals.G_OPR_CREATE)
    THEN
       Bom_Globals.Check_Approved_For_Process
                    ( p_change_notice => p_sub_component_rec.Eco_Name
                    , p_organization_id => p_Sub_Comp_Unexp_Rec.Organization_Id
                    , x_processed       =>l_processed
                    , x_err_text        =>l_err_text
                        );
       IF (l_processed) THEN
            Bom_Globals.Set_Request_For_Approval(
                p_change_notice     => p_sub_component_rec.Eco_Name
                ,p_organization_id  =>  p_Sub_Comp_Unexp_Rec.Organization_Id
                ,x_err_text     => l_err_text);
       END IF;
    END IF;

    -----------------------------------------------------------------------
    -- Check new substitute component item (for create or update) already |
    -- exists in MTL_SYSTEM_ITEMS and has the correct item attributes     |
    -----------------------------------------------------------------------

    stmt_num := 7;
    BEGIN
--dbms_output.put_line
--('Verify sub. comp. exists in MTL_System_Item with correct attributes . . .');

            SELECT bom_item_type, bom_enabled_flag, eng_item_flag
            INTO l_sbc_item_type, l_sbc_bom_enabled_flag, l_sbc_eng_item_flag
            FROM mtl_system_items
            WHERE organization_id = p_Sub_Comp_Unexp_Rec.Organization_Id
            AND inventory_item_id = p_Sub_Comp_Unexp_Rec.substitute_component_id;

	    IF l_sbc_item_type <> 4 THEN
	        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            		Error_Handler.Add_Error_Token
                        (  x_Mesg_Token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'ENG_SUB_COMP_NOT_STD'
                         );
		END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;

	IF l_sbc_bom_enabled_flag <> 'Y'
	THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			l_token_tbl(1).token_name  := 'SUBSTITUTE_ITEM_NAME';
			l_token_tbl(1).token_value :=
				p_sub_component_rec.substitute_component_name;
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_Token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'ENG_SUB_COMP_NOT_BOM_ENABLED'
			 , p_token_tbl	    => l_token_tbl
                         );
                END IF;
		l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF ((l_rec_AST = 2) OR (l_rec_AST = 1 AND l_sbc_eng_item_flag = 'Y'))
	THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_Token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'ENG_SUB_COMP_ASSEMBLY_MFG'
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

    EXCEPTION
        WHEN no_data_found THEN
		NULL;
    END;

    -------------------------------------------------------------------
    -- If bill is a Common for other bills, then make sure Substitute |
    --  Component Item exists in those orgs                           |
    -------------------------------------------------------------------
    stmt_num := 8;
    BEGIN
--dbms_output.put_line('Verfying component for other common orgs . . . ');

            SELECT 1
            INTO l_dummy
            FROM bom_bill_of_materials bbom
            WHERE rownum =1
            AND bbom.common_bill_sequence_id = l_rec_BSI
            AND bbom.organization_id <> bbom.common_organization_id
            AND not exists
                (SELECT null
                 FROM mtl_system_items msi
                 WHERE msi.organization_id = bbom.organization_id
                 AND msi.inventory_item_id =
		     p_Sub_Comp_Unexp_Rec.substitute_component_id
             	 AND msi.bom_enabled_flag = 'Y'
             	 AND msi.bom_item_type = 4
             	 AND (bbom.assembly_type = 2 OR
                 	(bbom.assembly_type = 1 AND msi.eng_item_flag = 'N')));

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		l_token_tbl.DELETE;
		l_Token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
		l_token_tbl(1).token_value :=
		  p_sub_component_rec.substitute_component_name;
                Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl 	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name  	=> 'ENG_SBC_COMBILL_DOES_NOT_EXIST'
                 , p_token_tbl	=> l_token_tbl
		);
             END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
    EXCEPTION
        WHEN no_data_found THEN
            null;
    END;

    ---------------------------------------------------------
    -- Verify sub comp is not the same as bill or component |
    ---------------------------------------------------------
    stmt_num := 9;
--dbms_output.put_line('Verifying sub. comp not same as parent . . . ');

    IF (p_Sub_Component_Rec.Transaction_Type = Bom_Globals.G_OPR_UPDATE AND
        p_Sub_Comp_Unexp_Rec.Component_Sequence_Id IN
       (l_rec_AII, l_rec_CII))
       OR
       (p_Sub_Component_Rec.Transaction_Type = Bom_Globals.G_OPR_CREATE AND
        p_Sub_Comp_Unexp_Rec.Substitute_Component_Id IN
       (l_rec_AII,l_rec_CII))
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            Error_Handler.Add_Error_Token
	    (  x_Mesg_Token_tbl	=> l_Mesg_Token_tbl
	     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , p_message_name  	=> 'ENG_SUBCOMP_SAMEAS_ITEM_COMP'
             , p_token_tbl	=> l_token_tbl
	     );
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    ------------------------------------------
    --  Validate attribute dependencies here.|
    ------------------------------------------
    -----------------------------------------
    -- substitute quantity couldn't be zero |
    -----------------------------------------

    stmt_num := 10;
    -----------------------------------------------------------------------
    -- If parent component acd_type is disabled, we can't do anything for |
    -- child component.                                                   |
    -----------------------------------------------------------------------
    stmt_num := 11;
        IF l_parent_acd_type = 3 THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl	=> l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'ENG_SBC_COMP_ACD_TYPE_DISABLE'
                 );
            END IF;
        END IF;

    -------------------------------------------------------------------
    -- if parent's acd_type is add, child acd_type should also be add |
    -------------------------------------------------------------------
    stmt_num := 12;
        IF ((l_parent_acd_type = 1 )  and ( p_Sub_Component_Rec.ACD_Type <> 1))
	THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
            l_token_tbl(1).token_value := p_sub_component_rec.component_item_name;
            Error_Handler.Add_Error_Token
	    (  x_Mesg_Token_tbl => l_Mesg_Token_tbl
	     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name  => 'ENG_SBC_ACD_NOT_COMPATIBLE'
	     , p_token_tbl	=> l_token_tbl
             );
        END IF;

    ------------------------------------------------------------------------
    -- if acd_type is disable, sub comp must belong to revisd comp already |
    -- if acd_type is not disable, sub comp must be unique for that        |
    -- revised component                                                   |
    ------------------------------------------------------------------------
    stmt_num := 13;
/*
    IF p_sub_component_rec.acd_type <> 3
       AND ( p_Sub_Component_Rec.Transaction_Type = Bom_Globals.G_OPR_CREATE OR
             p_Sub_Component_Rec.Transaction_Type = Bom_Globals.G_OPR_UPDATE
	    )
    THEN


        l_sub_comp_unique:= Verify_Unique_Substitute(	p_sub_component_rec
                                		     ,	p_sub_comp_Unexp_rec
						     );

    END IF;

*/

    stmt_num := 14;
    -------------------------------------------------------------------------
    -- if acd_type is disable, sub comp must belong to revised comp already |
    -------------------------------------------------------------------------

    IF p_sub_component_rec.acd_type = 3 THEN
        BEGIN
--dbms_output.put_line('Verifying if component is not disable type  . . . ');

            SELECT 1
              INTO l_dummy
              FROM bom_substitute_components sub_comp,
		   bom_inventory_components  rev_comp
             WHERE sub_comp.component_sequence_id   =
		   p_Sub_Comp_Unexp_Rec.Component_Sequence_Id
               AND sub_comp.Substitute_Component_Id =
		   p_Sub_Comp_Unexp_Rec.Substitute_Component_Id
	       AND rev_comp.component_sequence_id =
		   p_Sub_Comp_Unexp_Rec.Component_Sequence_Id
	       AND rev_comp.implementation_date	IS NOT NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) Then
		l_token_tbl(1).token_name  := 'SUBSTITUTE_ITEM_NAME';
		l_token_tbl(1).token_value :=
				p_sub_component_rec.substitute_component_name;
		l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
		l_token_tbl(2).token_value :=
				p_sub_component_rec.component_item_name;
                Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl => l_Mesg_Token_tbl
		 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name   => 'ENG_DISABLE_SCOMP_NOT_FOUND'
		 , p_token_tbl	    => l_token_tbl
                 );
               end if;
            l_return_status := FND_API.G_RET_STS_ERROR;
         END;
    END IF;

    ---dbms_output.put_line('l_return_status : '|| l_return_status);

    IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ----------------------------
    --  Done validating entity |
    ----------------------------

    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --dbms_output.put_line('expected Error : stmt_num  -'
          --  || to_char(stmt_num));
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.put_line('unexpected Error : stmt_num  -'
          --  || to_char(stmt_num));
    WHEN OTHERS THEN
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.put_line('other unexpected Error :
         --   stmt_num  -' || to_char(stmt_num));
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	    l_err_text := G_PKG_NAME ||
                'Validation (Substitute Component Entity)' ||
                SUBSTR(SQLERRM, 1, 100);
            Error_Handler.Add_Error_Token(  x_Mesg_Token_tbl => x_Mesg_Token_tbl
					, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , p_message_name  => NULL
                                        , p_message_text  => l_err_text
                                        );

        END IF;
END Check_Entity;


/*******************************************************************
* Procedure     : Check_Attributes
* Parameter IN  : Substitute Component Record
* Parameter OUT : Return_Status - Indicating status of the process.
*                 Mesg_Token_Tbl - Table of Errors and their tokens
*
* Purpose       : Procedure Attributes will verify the validity of
*                 all exposed columns to check if the user has given
*		  values that the columns can actually hold.
*********************************************************************/

PROCEDURE Check_Attributes
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_Mesg_Token_tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec         IN  Bom_Bo_Pub.Sub_Component_Rec_Type
)
IS
l_err_text      VARCHAR2(255);
l_token_tbl	 Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /**************************************************************************
		With patch to bug 728002, this is not valid now

    IF p_sub_component_rec.substitute_item_quantity IS NOT NULL AND
       p_sub_component_rec.substitute_item_quantity = 0
    THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		l_token_tbl(1).token_name  := 'SUBSITUTE_ITEM_NAME';
		l_token_tbl(1).token_value :=
			p_sub_component_rec.substitute_component_name;
                Error_Handler.Add_Error_Token
		(  x_Mesg_Token_tbl   => x_Mesg_Token_tbl
                 , p_message_name     => 'ENG_SUB_COMP_QTY_ZERO'
		 , p_token_tbl	      => l_token_tbl
		);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
    **************************************************************************/


END Check_Attributes;

/*******************************************************************
* Procedure     : Check_Entity_Delete
* Parameter IN  : Substitute Component Record
*                 Substitute component Record of Unexposed Columns
* Parameter OUT : Return_Status - Indicating status of the process.
*                 Mesg_Token_Tbl - Table of Errors and their tokens
*
* Purpose       : Entity_Delete procedure will verify if the record
*                 can be delete without violating any dependency rules
*********************************************************************/

PROCEDURE Check_Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_err_text                    VARCHAR2(255);
l_rec_ID            DATE := NULL;
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    --  Validate entity delete.
    x_return_status := l_return_status;

END Check_Entity_Delete;

/**************************************************************************
* Procedure	: Check_Existence
* Parameters IN	: Substitute Component exposed column record
*		  Substitute Component unexposed column record
* Parameters OUT: Old Substitute Component exposed column record
*		  Old substitute component unexposed column record
*		  Return status
*		  Mesg Token Table
* Purpose	: This procedure will verify if the user given record exists
*		  when the operation is Update/Delete and does not exist when
*		  the operation is Create. If the operation is Update/Delete
*		  the procedure will query the existing record and return them
*		  as old records.
***************************************************************************/
PROCEDURE Check_Existence
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_old_sub_component_rec      IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
 , x_old_sub_comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
)
IS
        l_token_tbl      Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status  VARCHAR2(1);
BEGIN
        l_Token_Tbl(1).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
        l_Token_Tbl(1).Token_Value :=
				p_sub_component_rec.substitute_component_name;
	l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
	l_token_tbl(2).token_value :=
				p_sub_component_rec.component_item_name;

        ENG_Sub_Component_Util.Query_Row
	(   p_substitute_component_id	=>
				p_sub_comp_unexp_rec.substitute_component_id
	,   p_component_sequence_id	=>
				p_sub_comp_unexp_rec.component_sequence_id
	,   p_acd_type			=>
				p_sub_component_rec.acd_type
	,   x_Sub_Component_Rec		=> x_old_sub_component_rec
	,   x_Sub_Comp_Unexp_Rec	=> x_old_sub_comp_unexp_rec
	,   x_return_status		=> l_return_status
	);

        IF l_return_status = Bom_Globals.G_RECORD_FOUND AND
           p_sub_component_rec.transaction_type = Bom_Globals.G_OPR_CREATE
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_SUB_COMP_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = Bom_Globals.G_RECORD_NOT_FOUND AND
              p_sub_component_rec.transaction_type IN
                (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_SUB_COMP_DOESNOT_EXIST'
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
                   'Substitute component '||
                   p_sub_component_rec.substitute_component_name
                 , p_token_tbl          => l_token_tbl
                 );
        ELSE
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Existence;

/****************************************************************************
* Procedure	: Check_Lineage
* Parameters IN	: Substitute Component exposed column record
*		  Substitute Component unexposed column record
* Parameters OUT: Mesg Token Table
*		  Return Status
* Purpose	: Procedure will verify that the parent-child relationship
*		  hold good in the production tables based on the data that
*	    	  the user has given.
*****************************************************************************/
PROCEDURE Check_Lineage
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
)
IS
        l_token_tbl             Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;

        CURSOR c_GetComponent IS
        SELECT revised_item_sequence_id
          FROM bom_inventory_components
         WHERE component_item_id = p_sub_comp_unexp_rec.component_item_id
           AND operation_seq_num = p_sub_component_rec.operation_sequence_number
           AND effectivity_date  = p_sub_component_rec.start_effective_date
           AND bill_sequence_id  = p_sub_comp_unexp_rec.bill_sequence_id;
BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        FOR Component IN c_GetComponent LOOP
                IF Component.revised_item_sequence_id <>
                        p_sub_comp_unexp_rec.revised_item_sequence_id
                THEN
                                l_Token_Tbl(1).token_name  :=
					'REVISED_COMPONENT_NAME';
                                l_Token_Tbl(1).token_value :=
                                     p_sub_component_rec.component_item_name;
                                l_Token_Tbl(2).token_name  :=
					'REVISED_ITEM_NAME';
                                l_Token_Tbl(2).token_value :=
                                     p_sub_component_rec.revised_item_name;
				l_Token_tbl(3).token_name  :=
					'SUBSTITUTE_ITEM_NAME';
				l_token_tbl(3).token_value :=
				  p_sub_component_rec.substitute_component_name;

                                Error_Handler.Add_Error_Token
                                (  p_Message_Name => 'ENG_SBC_REV_ITEM_MISMATCH'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                 );
                                x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
        END LOOP;

	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END CHECK_LINEAGE;

/****************************************************************************
* Procedure	: Check_Access
* Parameters IN	: Substitute Component exposed column record
*		  Substitute Component unexposed column record
* Prameters OUT : Mesg Token Table
*		  Return Status
* Purpose	: If the System Information record values are not already filled
*		  the process will query the appropriate profile values and
*		  verify that the user has access to the Revised Item, the
*		  parent component item and the item type of the substitute
*		  Component. It will also verify that the revised item is not
*		  already implemented or canceled.
****************************************************************************/
PROCEDURE Check_Access
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
)
IS
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        l_Return_Status         VARCHAR2(1);
	CURSOR c_GetSubCompType IS
	SELECT bom_item_type
	  FROM mtl_system_items
	 WHERE inventory_item_id = p_sub_comp_unexp_rec.substitute_component_id
	   AND organization_id   = p_sub_comp_unexp_rec.organization_id;

BEGIN
        l_return_status := FND_API.G_RET_STS_SUCCESS;

	--
	-- The calling progrma must make a calls to the parent entities
	-- Check_Access to make sure that the parent is accessible
	--
	/********************************************************
        IF Bom_Globals.Is_RComp_Cancl IS NULL OR
           Bom_Globals.Is_RComp_Cancl = FALSE
        THEN
                Eng_Validate_Rev_Component.Check_Access
                (  p_revised_item_name  => p_sub_component_rec.revised_item_name
		 , p_revised_item_id    => p_sub_comp_unexp_rec.revised_item_id
		 , p_organization_id    => p_sub_comp_unexp_rec.organization_id
		 , p_change_notice      => p_sub_component_rec.eco_name
		 , p_new_item_revision  =>
		 		p_sub_component_rec.new_revised_item_revision
		 , p_effectivity_date   =>
		 		p_sub_component_rec.start_effective_date
                 , p_component_item_id  =>
                                p_sub_comp_unexp_rec.component_item_id
                 , p_operation_seq_num  =>
                                p_sub_component_rec.operation_sequence_number
                 , p_bill_sequence_id   =>
                                p_sub_comp_unexp_rec.bill_sequence_id
                 , p_component_name     =>
                                p_sub_component_rec.component_item_name
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Return_Status      => l_return_status
                );
        END IF;
	**********************************************************/

	FOR SubCompType IN c_GetSubCompType
	LOOP
		IF SubCompType.bom_item_type = Bom_Globals.G_PRODUCT_FAMILY
		THEN
			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'ENG_SUB_COMP_PF'
			 , p_mesg_token_tbl	=> l_mesg_token_tbl
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 , p_token_tbl		=> l_token_tbl
			);
			l_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF SubCompType.bom_item_type NOT IN
		      (NVL(Bom_Globals.Get_MDL_Item_Access,0),
            	       NVL(Bom_Globals.Get_OC_Item_Access,0),
            	       NVL(Bom_Globals.Get_PLN_Item_Access,0),
            	       NVL(Bom_Globals.Get_STD_Item_Access,0)
           	       )
        	THEN
                	l_token_tbl(1).token_name  := 'REV_COMP';
                	l_token_tbl(1).token_value :=
				p_sub_component_rec.substitute_component_name;
               		l_token_tbl(2).token_name  := 'BOM_ITEM_TYPE';
                	l_token_tbl(2).translate   := TRUE;

                	IF SubCompType.bom_item_type = 1
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'ENG_MODEL';
                	ELSIF SubCompType.bom_item_type = 2
                	THEN
                      		l_Token_Tbl(2).Token_Value:='ENG_OPTION_CLASS';
                	ELSIF SubCompType.bom_item_type = 3
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'ENG_PLANNING';
                	ELSIF SubCompType.bom_item_type = 4
                	THEN
                      		l_Token_Tbl(2).Token_Value := 'ENG_STANDARD';
                	END IF;

                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'ENG_SUB_COMP_ACCESS_DENIED'
                 	 , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                	 , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                 	 , p_Token_Tbl          => l_token_tbl
                 	 );
                 	l_token_tbl.DELETE(2);
                 	l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	END LOOP;
        x_return_status := l_return_status;

        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
END Check_Access;

END ENG_Validate_Sub_Component;

/
