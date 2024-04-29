--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_BOM_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_BOM_HEADER" AS
/* $Header: BOMLBOMB.pls 120.13.12010000.7 2010/08/03 19:47:05 umajumde ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLBOMB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Bom_Header
--
--  NOTES
--
--  HISTORY
--
--  01-JUL-99   Rahul Chitko    Initial Creation
--
--  08-MAY-2001 Refai Farook    EAM related changes
--
--  06-May-05   Abhishek Rudresh     Common BOM Attr Updates

--  20-Jun-05	Vani Hymavathi	     Validations for to OPM convergence project
--  13-JUL-06   Bhavnesh Patel     Added support for Structure Type
****************************************************************************/
        G_Pkg_Name      VARCHAR2(30) := 'BOM_Validate_Bom_Header';
        g_token_tbl     Error_Handler.Token_Tbl_Type;


	/*******************************************************************
	* Procedure	: Check_Existence
	* Returns	: None
	* Parameters IN	: Bom Header Exposed Record
	*		  Bom Header Unexposed Record
	* Parameters OUT: Old BOM Header exposed Record
	*		  Old BOM Header Unexposed Record
	*		  Mesg Token Table
	*		  Return Status
	* Purpose	: Procedure will query the old bill of materials header
	*		  record and return it in old record variables. If the
	* 		  Transaction Type is Create and the record already
	*		  exists the return status would be error or if the
	*		  transaction type is Update or Delete and the record
	*		  does not exist then the return status would be an
	*		  error as well. Mesg_Token_Table will carry the
	*		  error messsage and the tokens associated with the
	*		  message.
	*********************************************************************/
        PROCEDURE Check_Existence
        (  p_bom_header_rec         IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec   IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_old_bom_header_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , x_old_bom_head_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        )
	IS
        	l_token_tbl      Error_Handler.Token_Tbl_Type;
        	l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
        	l_return_status  VARCHAR2(1);
	BEGIN

If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Quering Assembly item ' || to_char(p_bom_head_unexp_rec.assembly_item_id)); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' Org: ' || to_char(p_bom_head_unexp_rec.organization_id) || ' Alt: ' || p_bom_header_rec.alternate_bom_code ); END IF;

 /* bug 4133037, For creates we need to check for existance in bom_structures_b */

        If(p_bom_header_rec.transaction_type = BOM_Globals.G_OPR_CREATE) then
             Bom_Bom_Header_Util.Query_Table_Row
                (  p_assembly_item_id   =>
                        p_bom_head_unexp_rec.assembly_item_id
                 , p_alternate_bom_code =>
                        p_bom_header_rec.alternate_bom_code
                 , p_organization_id    =>
                        p_bom_head_unexp_rec.organization_id
                 , x_bom_header_rec     => x_old_bom_header_rec
                 , x_bom_head_unexp_rec => x_old_bom_head_unexp_rec
                 , x_return_status      => l_return_status
                 );
        else
		Bom_Bom_Header_Util.Query_Row
		(  p_assembly_item_id	=>
			p_bom_head_unexp_rec.assembly_item_id
		 , p_alternate_bom_code	=>
			p_bom_header_rec.alternate_bom_code
		 , p_organization_id	=>
			p_bom_head_unexp_rec.organization_id
		 , x_bom_header_rec	=> x_old_bom_header_rec
		 , x_bom_head_unexp_rec => x_old_bom_head_unexp_rec
		 , x_return_status	=> l_return_status
		 );
        end if;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

		IF l_return_status = BOM_Globals.G_RECORD_FOUND AND
		   p_bom_header_rec.transaction_type = BOM_Globals.G_OPR_CREATE
		THEN
			l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
			l_token_tbl(1).token_value :=
					p_bom_header_rec.assembly_item_name;
			Error_Handler.Add_Error_Token
                	(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 	 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	 , p_message_name  => 'BOM_ASSY_ITEM_ALREADY_EXISTS'
                 	 , p_token_tbl     => l_token_tbl
                 	 );
			l_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF l_return_status = BOM_Globals.G_RECORD_NOT_FOUND AND
		      p_bom_header_rec.transaction_type IN
			 (BOM_Globals.G_OPR_UPDATE, BOM_Globals.G_OPR_DELETE)
		THEN
			l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_bom_header_rec.assembly_item_name;
			Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name  => 'BOM_ASSY_ITEM_DOESNOT_EXISTS'
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
                  	 'Assembly item '||
                  	 p_bom_header_rec.assembly_item_name
                	 , p_token_tbl          => l_token_tbl
                	 );
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	ELSE

                 /* Assign the relevant transaction type for SYNC operations */

                  IF p_bom_header_rec.transaction_type = 'SYNC' THEN
                    IF l_return_status = Bom_Globals.G_RECORD_FOUND THEN
                      x_old_bom_header_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_UPDATE;
                    ELSE
                      x_old_bom_header_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_CREATE;
                    END IF;
                  END IF;
                  l_return_status := FND_API.G_RET_STS_SUCCESS;

        	END IF;

		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;
	END Check_Existence;


	/*******************************************************************
	* Procedure	: Check_Access
	* Returns	: None
	* Parameters IN	: Assembly_Item_Id
	*		  Organization_Id
	*		  Alternate_Bom_Designator
	* Parameters OUT: Return Status
	*		  Message Token Table
	* Purpose	: This procedure will check if the user has access
	*		  to the Assembly Item's BOM Item Type.
	* 		  If not then an appropriate message and a error status
	*		  will be returned back.
	*********************************************************************/
	PROCEDURE Check_Access
		  (  p_assembly_item_id	  IN  NUMBER
		   , p_alternate_bom_code IN  VARCHAR2
		   , p_organization_id	  IN  NUMBER
		   , p_mesg_token_tbl	  IN  Error_Handler.Mesg_Token_Tbl_Type
					 := Error_Handler.G_MISS_MESG_TOKEN_TBL
		   , x_mesg_token_tbl	  IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
		   , x_return_status      IN OUT NOCOPY VARCHAR2
		   )
	IS
		l_return_status	   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
		l_Mesg_Token_Tbl   Error_Handler.Mesg_Token_Tbl_Type :=
					p_mesg_token_tbl;
		l_bom_item_type	   NUMBER;
		l_assembly_type	   NUMBER;
                l_tracking_qty_ind VARCHAR2(30);
                l_OPM_org	   VARCHAR2(1);
		l_token_tbl	   Error_Handler.Token_Tbl_Type;

	BEGIN

		SELECT bom_item_type, decode(eng_item_flag, 'N', 1, 2)
                        ,tracking_quantity_ind
                  INTO l_bom_item_type, l_assembly_type,l_tracking_qty_ind
                  FROM mtl_system_items
                 WHERE inventory_item_id = p_assembly_item_id
                   AND organization_id   = p_organization_id;

                SELECT process_enabled_flag
                  INTO  l_OPM_org
                  FROM mtl_parameters
                 WHERE  organization_id   = p_organization_id;

		--
		-- If user is trying to update an Engineering Item from BOM
		-- Business Object, the user should not be allowed.
		--

		/*IF l_assembly_type = 2 -- Engineering Item
		THEN
			Error_Handler.Add_Error_Token
			(  p_Message_name	=> 'BOM_ASSEMBLY_TYPE_ENG'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );
			l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;*/

                /* Validations for OPM Convergence Project
                   Model/Option class bills are not allowed in OPM organizations*/

                 IF (l_OPM_org='Y' and l_bom_item_type in (1,2))THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_name       => 'BOM_OPM_ORG_MODEL_OC'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;

                /* Validations for OPM Convergence Project
                   Dual UOM controlled items should not be allowed*/

                 IF (l_tracking_qty_ind<>'P' )THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_name       => 'BOM_DUAL_UOM_ITEMS'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;


		IF BOM_Globals.Get_STD_Item_Access IS NULL AND
           	   BOM_Globals.Get_PLN_Item_Access IS NULL AND
           	   BOM_Globals.Get_MDL_Item_Access IS NULL AND
		   BOM_Globals.Get_OC_Item_Access  IS NULL
        	THEN
                	--
                	-- Get respective profile values
                	--
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Checking item type access . . . '); END IF;

			IF fnd_profile.value('BOM:STANDARD_ITEM_ACCESS') = '1'
                	THEN
                        	BOM_Globals.Set_STD_Item_Access
                        	( p_std_item_access     => 4);
                	ELSE
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('no access to standard items'); END IF;
			BOM_Globals.Set_STD_Item_Access
			(p_std_item_access      => NULL);
                	END IF;

                	IF fnd_profile.value('BOM:MODEL_ITEM_ACCESS') = '1'
                	THEN
                        	BOM_Globals.Set_MDL_Item_Access
                        	( p_mdl_item_access     => 1);
                        	BOM_Globals.Set_OC_Item_Access
                        	( p_oc_item_access      => 2);
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Model/OC items are accessible. . . '); END IF;
                	ELSE
                        	BOM_Globals.Set_MDL_Item_Access
                        	( p_mdl_item_access     => NULL);
                        	BOM_Globals.Set_OC_Item_Access
                        	( p_oc_item_access      => NULL);
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' Model/OC item access denied . . . '); END IF;
                	END IF;

                	IF fnd_profile.value('BOM:PLANNING_ITEM_ACCESS') = '1'
                	THEN
                        	BOM_Globals.Set_PLN_Item_Access
                        	( p_pln_item_access     => 3);
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Planning item accessible. . . '); END IF;
                	ELSE
                        	BOM_Globals.Set_PLN_Item_Access
                        	( p_pln_item_access     => NULL);
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Planning item access denied. . . '); END IF;
                	END IF;
		END IF;

		--
		-- Use BOM Item Type of the Assembly Item that is queried above
		-- to check if user has access to it.
		--
		IF l_Bom_Item_Type NOT IN
                      ( NVL(BOM_Globals.Get_STD_Item_Access, 0),
                        NVL(BOM_Globals.Get_PLN_Item_Access, 0),
                        NVL(BOM_Globals.Get_OC_Item_Access, 0) ,
                        NVL(BOM_Globals.Get_MDL_Item_Access, 0),
			BOM_Globals.G_PRODUCT_FAMILY
                       )
                THEN
                        l_Token_Tbl(1).Token_Name := 'BOM_ITEM_TYPE';
                        l_Token_Tbl(1).Translate  := TRUE;
                        IF l_Bom_Item_Type = 1
                        THEN
                                l_Token_Tbl(1).Token_Value := 'BOM_MODEL';
                        ELSIF l_Bom_Item_Type = 2
                        THEN
                                l_Token_Tbl(1).Token_Value:='BOM_OPTION_CLASS';
                        ELSIF l_Bom_Item_Type = 3
                        THEN
                                l_Token_Tbl(1).Token_Value := 'BOM_PLANNING';
                        ELSIF l_Bom_Item_Type = 4
                        THEN
                                l_Token_Tbl(1).Token_Value := 'BOM_STANDARD';
                        END IF;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_ASSY_ITEM_ACCESS_DENIED'
                         , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

		x_return_status	  := l_return_status;
		x_mesg_token_tbl  := l_mesg_token_tbl;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Access returning with ' || l_return_status ); END IF;

	END Check_Access;


	/********************************************************************
	* Procedure     : Check_Attributes
	* Parameters IN : Revised Item Exposed Column record
	*                 Revised Item Unexposed Column record
	*                 Old Revised Item Exposed Column record
	*                 Old Revised Item unexposed column record
	* Parameters OUT: Return Status
	*                 Mesg Token Table
	* Purpose       : Check_Attrbibutes procedure will validate every
	*		  revised item attrbiute in its entirety.
	**********************************************************************/
	PROCEDURE Check_Attributes
	(  x_return_status           IN OUT NOCOPY VARCHAR2
	 , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , p_bom_header_Rec	     IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_bom_head_unexp_rec	     IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , p_old_bom_header_rec      IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_old_bom_head_unexp_rec  IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	)
	IS
	l_err_text              VARCHAR2(2000) := NULL;
	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
	l_Token_Tbl             Error_Handler.Token_Tbl_Type;

	BEGIN

    		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within Bom Header Check Attributes . . . '); END IF;

		IF p_bom_header_rec.alternate_bom_code IS NOT NULL AND
		   p_bom_header_rec.alternate_bom_code <> FND_API.G_MISS_CHAR
		   AND
		   (  p_bom_header_rec.alternate_bom_code <>
		      p_old_bom_header_rec.alternate_bom_code OR
		      p_old_bom_header_rec.alternate_bom_code IS NULL
		    )
		THEN
			IF NOT BOM_Validate.Alternate_Designator
				(  p_alternate_bom_code	=>
					p_bom_header_rec.alternate_bom_code
				 , p_organization_id	=>
					p_bom_head_unexp_rec.organization_id
				)
			THEN
				l_token_tbl(1).token_name :=
						'ALTERNATE_BOM_CODE';
				l_token_tbl(1).token_value :=
					p_bom_header_rec.alternate_bom_code;
				Error_Handler.Add_Error_Token
				(  p_token_tbl		=> l_token_tbl
				 , p_message_name	=>
						'BOM_ALTERNATE_DESG_INVALID'
				 , p_mesg_token_tbl	=> l_mesg_token_tbl
				 , x_mesg_token_tbl	=> l_mesg_token_tbl
				 );
				x_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
		END IF;

                IF p_bom_header_rec.assembly_type IS NOT NULL AND
                   p_bom_header_rec.assembly_type <> FND_API.G_MISS_NUM AND
                   p_bom_header_rec.assembly_type NOT IN (1,2)
                THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_bom_header_rec.assembly_item_name;
                        l_token_tbl(2).token_name  := 'ASSEMBLY_TYPE';
                        l_token_tbl(2).token_value :=
                                        p_bom_header_rec.assembly_type;
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_ASSEMBLY_TYPE_INVALID'
                         , p_token_tbl          => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_Attributes;

	/*********************************************************************
	* Procedure     : Check_Required
	* Parameters IN : BOM Header Exposed column record
	* Parameters OUT: Mesg Token Table
	*                 Return_Status
	* Purpose	:
	**********************************************************************/
	PROCEDURE Check_Required
	(  x_return_status      IN OUT NOCOPY VARCHAR2
	 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , p_bom_header_Rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 )
	IS
        	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        	l_Token_Tbl             Error_Handler.Token_Tbl_Type;
	BEGIN
        	x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF (  p_bom_header_rec.common_organization_code IS NOT NULL AND
		      p_bom_header_rec.common_organization_code <>
							FND_API.G_MISS_CHAR
		    ) AND
		    (  p_bom_header_rec.common_assembly_item_name IS NULL OR
		       p_bom_header_rec.common_assembly_item_name =
							FND_API.G_MISS_CHAR
		     )
		THEN
			--
			-- If the common org code is given the common assembly
			-- name is required.
			--
			l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
			l_token_tbl(1).token_value :=
				p_bom_header_rec.assembly_item_name;

			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_COMMON_ASSY_REQUIRED'
			 , p_token_tbl		=> l_Token_tbl
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 );

			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_Required;


	/********************************************************************
	* Procedure	: Check_Entity
	* Parameters IN	: Bom Header Exposed column record
	*		  Bom Header Unexposed column record
	*		  Old Bom Header exposed column record
	*		  Old Bom Header unexposed column record
	* Parameters OUT: Message Token Table
	*		  Return Status
	* Purpose	: This procedure will perform the business logic
	*		  validation for the BOM Header Entity. It will perform
	*		  any cross entity validations and make sure that the
	*		  user is not entering values which may disturb the
	*		  integrity of the data.
	*********************************************************************/
	PROCEDURE Check_Entity
	(  p_bom_header_rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_bom_head_unexp_rec	IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , p_old_bom_head_rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_old_bom_head_unexp_rec  IN Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_mesg_token_tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_return_status	IN OUT NOCOPY VARCHAR2
	 )
	IS
		l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
		l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
		l_Token_Tbl	 Error_Handler.Token_Tbl_Type;
		l_dummy		 VARCHAR2(1);
    		l_valid_op_seq   VARCHAR2(1);
		bit		 NUMBER;
		base_id		 NUMBER;
		struct_type_id   NUMBER;
		ato              VARCHAR2(1);
    		pto              VARCHAR2(1);
		assmtype	 NUMBER;
		l_count		 NUMBER;
                bom_enabled      VARCHAR2(1);
    l_mater_org_id NUMBER;
		l_comp_rev_status VARCHAR2(1); --Bug 7526867

                 /* Commented out for bug: 8208327
         Changes to the header of a bom with a common bom reference should be
         allowed. However, modifications to components should not. This check
         was moved to procedure bom_components */

             /*   CURSOR c_CheckCommon IS
                SELECT NVL(common_bill_sequence_id,bill_sequence_id) common_bill_seq,
		       bill_sequence_id
                  FROM bom_bill_of_materials
                 WHERE assembly_item_id = p_bom_head_unexp_rec.assembly_item_id
                   AND organization_id  = p_bom_head_unexp_rec.organization_id
                   AND NVL(alternate_bom_designator, 'XXXX') =
                       NVL(p_bom_header_rec.alternate_bom_code, 'XXXX'); */

  l_existing_str_type BOM_STRUCTURE_TYPES_B.STRUCTURE_TYPE_NAME%TYPE;

	BEGIN

                  --
                  -- Verify that the Parent has BOM Enabled
		  -- Bug:8359043 Matching eng_item_flag with assembly_type
                  --
                  select bom_enabled_flag,
			decode(eng_item_flag,
			       'Y',decode(p_bom_header_rec.assembly_type,1,'E',null), --Eng item with manufacturing bill
			       'N',decode(p_bom_header_rec.assembly_type,2,'M',null)  --Manufacturing item with Eng bill
		 	) into bom_enabled,l_dummy from mtl_system_items
                  where inventory_item_id = p_bom_head_unexp_rec.assembly_item_id
                   AND organization_id  = p_bom_head_unexp_rec.organization_id;

                  IF bom_enabled <> 'Y'
                  THEN
                  g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                  g_token_tbl(1).token_value :=
                         p_bom_header_rec.assembly_item_name;

                  Error_Handler.Add_Error_Token
                  (  p_message_name       => 'BOM_REV_ITEM_BOM_NOT_ENABLED'
                  , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  , p_token_tbl          => g_token_tbl
                  );

                  l_return_status := FND_API.G_RET_STS_ERROR;

                END IF;

		--
		-- Bug:8359043
		-- Verify that engineering bill is created for engineering assy
		-- and manufacturing bill is created for manufacturing assy
		--
		IF l_dummy IS NOT NULL THEN
	           l_return_status := FND_API.G_RET_STS_ERROR;
        	   l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
	           l_token_tbl(1).token_value := p_bom_header_rec.assembly_item_name;
	           IF l_dummy = 'E' THEN
        		Error_Handler.Add_Error_Token
	                   (  p_message_name        => 'BOM_ENG_ITEM_MANF_BILL'
	                     , p_token_tbl                => l_token_tbl
	                     , p_mesg_token_tbl        => l_mesg_token_tbl
	                     , x_mesg_token_tbl        => l_mesg_token_tbl
	                   );
        	   ELSE
                	Error_Handler.Add_Error_Token
	                   (  p_message_name        => 'BOM_MANF_ITEM_ENG_BILL'
        	             , p_token_tbl                => l_token_tbl
	                     , p_mesg_token_tbl        => l_mesg_token_tbl
        	             , x_mesg_token_tbl        => l_mesg_token_tbl
                	   );
	           END IF;
		END IF;

                --  PackBom Related validations ..

    SELECT structure_type_id INTO struct_type_id FROM bom_structure_types_b
		  WHERE structure_type_name = 'Packaging Hierarchy';

     IF p_bom_head_unexp_rec.structure_type_id = struct_type_id
     THEN

                --
                -- Verify If PIM_PDS profiles are enabled to create a Packaging Hierarchy
	 IF Bom_Globals.IS_PIM_PDS_ENABLED = 'N'
	 THEN
        Error_Handler.Add_Error_Token
        (  p_message_name	=> 'BOM_CREATE_PACK_HIER_NOT_ALLOW'
         , p_mesg_token_tbl	=> l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
         );
        l_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;

      ---
      -- Packaging BOM creation is allowed only with the prefered structure name for the
      -- structure type 'Packaging Hierarchy'
      ---
      SELECT Count(1) INTO l_count FROM bom_alternate_designators
        WHERE structure_type_id = struct_type_id and alternate_designator_code = p_bom_header_rec.alternate_bom_code
          AND organization_id = p_bom_head_unexp_rec.organization_id AND is_preferred = 'Y';

      IF l_count < 1 THEN
        l_token_tbl(1).token_name  := 'STRUCTURE_NAME';
        l_token_tbl(1).token_value := p_bom_header_rec.alternate_bom_code;
        l_token_tbl(2).token_name  := 'STRUCTURE_TYPE';
        l_token_tbl(2).token_value := p_bom_header_rec.Structure_Type_Name;

        Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_STRUCTNAMEANDTYPE_INVALID'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_token_tbl
          );
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      ---
      -- Do not allow packaging hierarchies to be created in child orgs.
      -- Pkg Hiers cannonly be commoned from the master org.
      ---
      IF p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_CREATE AND
		     p_bom_head_unexp_rec.source_bill_sequence_id IS NULL
      THEN
        SELECT master_organization_id INTO l_mater_org_id FROM mtl_parameters
          WHERE organization_id = p_bom_head_unexp_rec.organization_id;
        IF (p_bom_head_unexp_rec.organization_id <> l_mater_org_id) THEN
          Error_Handler.Add_Error_Token
          (  p_message_name	=> 'BOM_PKG_HIERARCHY_IN_CHILD_ORG'
           , p_mesg_token_tbl	=> l_Mesg_Token_Tbl
           , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
           );
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;
    END IF;


		--
		-- If alternate designator is NOT NULL, then Primary Bill
		-- must exist if the user is trying to create an Alternate
		--
		IF p_bom_header_rec.alternate_bom_code IS NOT NULL AND
		   p_bom_header_rec.alternate_bom_code <> FND_API.G_MISS_CHAR
		THEN
	            BEGIN
			SELECT '1'
			  INTO l_dummy
		  	  FROM bom_bill_of_materials
			 WHERE alternate_bom_designator IS NULL
			   AND assembly_item_id =
					p_bom_head_unexp_rec.assembly_item_id
			   AND organization_id =
					p_bom_head_unexp_rec.organization_id
			   AND ((p_bom_header_rec.assembly_type= 2)
                  		OR
                   		(p_bom_header_rec.assembly_type =1
				  and assembly_type = 1));

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_return_status :=
							FND_API.G_RET_STS_ERROR;
					l_token_tbl(1).token_name :=
						'ASSEMBLY_ITEM_NAME';
					l_token_tbl(1).token_value :=
					    p_bom_header_rec.assembly_item_name;
					Error_Handler.Add_Error_Token
					(  p_message_name    =>
						'BOM_CANNOT_ADD_ALTERNATE'
					 , p_token_tbl	     => l_token_tbl
					 , p_mesg_token_tbl  => l_mesg_token_tbl
					 , x_mesg_token_tbl  => l_mesg_token_tbl
					 );
		    END;
		END IF;

    --validate structure type
    --The value of structure type in the case of null or FND_API.MISS_CHAR
    --will be ignored.

		IF (    p_bom_header_rec.alternate_bom_code IS NOT NULL
        AND p_bom_header_rec.alternate_bom_code <> FND_API.G_MISS_CHAR
        AND p_bom_head_unexp_rec.structure_type_id IS NOT NULL
        AND p_bom_head_unexp_rec.structure_type_id <> FND_API.G_MISS_NUM )
		THEN
      SELECT  COUNT(1)
      INTO    l_count
      FROM    BOM_ALTERNATE_DESIGNATORS BAD
      WHERE
          BAD.ORGANIZATION_ID = p_bom_head_unexp_rec.organization_id
      AND BAD.ALTERNATE_DESIGNATOR_CODE = p_bom_header_rec.alternate_bom_code
      AND BAD.STRUCTURE_TYPE_ID IN
            ( SELECT  BST.STRUCTURE_TYPE_ID
              FROM    BOM_STRUCTURE_TYPES_B BST
              START WITH BST.STRUCTURE_TYPE_ID = p_bom_head_unexp_rec.structure_type_id
              CONNECT BY PRIOR BST.PARENT_STRUCTURE_TYPE_ID = BST.STRUCTURE_TYPE_ID
            );

      IF ( l_count = 0 ) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        l_token_tbl(1).token_name  := 'STRUCTURE_NAME';
        l_token_tbl(1).token_value := p_bom_header_rec.alternate_bom_code;
        l_token_tbl(2).token_name  := 'STRUCTURE_TYPE';
        l_token_tbl(2).token_value := p_bom_header_rec.Structure_Type_Name;

        Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_STRUCTNAMEANDTYPE_INVALID'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_token_tbl
          );
      END IF; -- end if l_count = 0
    END IF; -- end if p_bom_header_rec.alternate_bom_code IS NOT NULL

    -- In update case, the new structure type must be a child of the existing one
    IF (    p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
        AND p_bom_head_unexp_rec.structure_type_id IS NOT NULL
        AND p_bom_head_unexp_rec.structure_type_id <> FND_API.G_MISS_NUM
        AND p_bom_head_unexp_rec.structure_type_id <> p_old_bom_head_unexp_rec.structure_type_id )
    THEN
      SELECT  COUNT(1)
      INTO    l_count
      FROM    BOM_STRUCTURE_TYPES_B BST
      WHERE   BST.STRUCTURE_TYPE_ID = p_bom_head_unexp_rec.structure_type_id
      START WITH BST.STRUCTURE_TYPE_ID = p_old_bom_head_unexp_rec.structure_type_id
      CONNECT BY PRIOR BST.STRUCTURE_TYPE_ID = BST.PARENT_STRUCTURE_TYPE_ID;

      IF ( l_count = 0 ) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        --existing structure type is not populated in the BO record
        l_token_tbl(1).token_name  := 'OLD_STRTYPE';
        BEGIN
          SELECT  STRUCTURE_TYPE_NAME
          INTO    l_existing_str_type
          FROM    BOM_STRUCTURE_TYPES_B
          WHERE   STRUCTURE_TYPE_ID = p_old_bom_head_unexp_rec.structure_type_id;

          l_token_tbl(1).token_value := l_existing_str_type;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_token_tbl(1).token_value := '';
        END;

        l_token_tbl(2).token_name  := 'NEW_STRTYPE';
        l_token_tbl(2).token_value := p_bom_header_rec.structure_type_name;

        Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_UPDATE_STRTYPE_INVALID'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_token_tbl
          );
      END IF; -- end if l_count = 0
    END IF; -- end if p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_UPDATE


		/** -------------------------------------------------------------
		** When commoning a bill, either creating or updating an existing
		** one, the following validations are performed
		** 1. Common_bill_Sequence_Id is non-updateable. So once a common
		**    bom is created user can only delete it and cannot simply
		**    update it to piont to another bom as common
		** 2. Manufactuing BOM's cannot refer to an Engineering BOM as common
		** 3. If the BOM being updated already has components, then it cannot
		**    refer to another BOM as common
		** 4. If a BOM is referencing another bill as common, then only the
		**    parent BOM is updateable
		** 5. If a BOM is already referencing another bill as common, then
		**    this BOM cannot be used as common for another BOM. i.e it is
		**    not permitted to create a chain of common BOM's
		** 6. The current BOM and the bill being referenced as common must have the
		**    same master org
		** 7. If a BOM in one org is referening a BOM in another org as common, then
		**    make sure that then all the components that exist under the parent org
		**    must exist both the orgs
		** 8. If a BOM in one org is referencing a BOM in another org as common, then
		**    any substitute components under the components must also exist in both
		**    orgs
		** 9. When referencing another bom as common, the items must have the same
		**    bom_item_type, pick_components_flag, replenish_to_order_flag and
		**    bom_enabled_flag
		** --------------------------------------------------------------------**/

		--
		-- If the user is performing an update operation, then the user
		-- must not enter the value for common organization code and
		-- common assembly item name. Providing these values would mean that
		-- the user is attempting to update these non-updateable columns
		--
		IF p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
		   AND
		   ( ( p_bom_header_rec.common_organization_code IS NOT NULL
		       AND p_bom_header_rec.common_organization_code <>
						FND_API.G_MISS_CHAR
		       AND NVL(p_bom_header_rec.common_organization_code, 'XXX') <>
			   NVL(p_old_bom_head_rec.common_organization_code,'XXX')
		      )
		      OR
		      ( p_bom_header_rec.common_assembly_item_name IS NOT NULL
			AND p_bom_header_rec.common_assembly_item_name <>
						FND_API.G_MISS_CHAR
			AND NVL(p_bom_header_rec.common_assembly_item_name, 'NONE') <>
			    NVL(p_old_bom_head_rec.common_assembly_item_name, 'NONE')
		       )
		     )
		THEN

			l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
			l_token_tbl(1).token_value :=
					p_bom_header_rec.assembly_item_name;
                      Error_Handler.Add_Error_Token
                      (  p_message_name       =>
                                        'BOM_COMMON_ORG_ASSY_NONUPD'
                       , p_token_tbl          => l_token_tbl
                       , p_mesg_token_tbl     => l_mesg_token_tbl
                       , x_mesg_token_tbl     => l_mesg_token_tbl
                       );
                       l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		--
		-- If the user is trying to perform an update, and the bill is
		-- referencing another bill as common, then this bill is not
		-- updateable. Only the parent bill is
		--
        		/* Commented out for bug: 8208327
                   Changes to the header of a bom with a common bom reference should be
                   allowed. However, modifications to components should not. This check
                   was moved to procedure bom_components */
		/* FOR CheckCommon IN c_CheckCommon
		LOOP
			IF CheckCommon.common_bill_seq <>
			   CheckCommon.bill_sequence_id
			THEN
				l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
				l_token_tbl(1).token_value :=
					p_bom_header_rec.assembly_item_name;
				Error_Handler.Add_Error_Token
                        	(  p_message_name       =>
                                	'BOM_ASSY_COMMON_REF_COMMON'
                        	 , p_token_tbl          => l_token_tbl
                        	 , p_mesg_token_tbl     => l_mesg_token_tbl
                        	 , x_mesg_token_tbl     => l_mesg_token_tbl
                        	 );
                        	l_return_status := FND_API.G_RET_STS_ERROR;
			END IF;

		END LOOP;	*/
		--
		--
		-- If the user is assigning a common assembly to the current
		-- bill then the common assembly must already have a common
		-- assembly. i.e User cannot create a chain of common bills
		--
		-- Using the common bill sequence_id check if the record for the
		-- common bill has a common bill sequence id.
		IF p_bom_head_unexp_rec.source_bill_sequence_id IS NOT NULL AND
		   p_bom_head_unexp_rec.source_bill_sequence_id <>
							FND_API.G_MISS_NUM
		THEN
		BEGIN
			SELECT '1'
		  	  INTO l_dummy
		          FROM bom_bill_of_materials
		 	 WHERE bill_sequence_id =
				p_bom_head_unexp_rec.source_bill_sequence_id
			   AND NVL(source_bill_sequence_id, bill_sequence_id) <>
					bill_sequence_id;

			l_token_tbl.delete;
			l_token_tbl(1).token_name := 'COMMON_ASSEMBLY_ITEM_NAME';
			l_token_tbl(1).token_value :=
				p_bom_header_rec.common_assembly_item_name;
			l_token_tbl(2).token_name := 'ASSEMBLY_ITEM_NAME';
			l_token_tbl(2).token_value :=
				p_bom_header_rec.assembly_item_name;
			Error_Handler.Add_Error_Token
			(  p_message_name	=>
				'BOM_ASSY_COMMON_OTHER_ASSY'
			 , p_token_tbl		=> l_token_tbl
			 , p_mesg_token_tbl	=> l_mesg_token_tbl
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );
			l_return_status := FND_API.G_RET_STS_ERROR;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;

		END;
		--
		-- If the current bill is a manufacturing bill then the
		-- common bill must also be a manufactuing bill
		--
		BEGIN
			SELECT '1'
			  INTO l_dummy
			  FROM mtl_system_items assy,
			       mtl_system_items common
			 WHERE assy.inventory_item_id =
				p_bom_head_unexp_rec.assembly_item_id
			   AND assy.organization_id =
				p_bom_head_unexp_rec.organization_id
			   AND common.inventory_item_id =
				p_bom_head_unexp_rec.common_assembly_item_id
			   AND common.organization_id =
				p_bom_head_unexp_rec.common_organization_id
			   AND  ((common.eng_item_flag = 'N' and
				assy.eng_item_flag = common.eng_item_flag)
				  OR
				  common.eng_item_flag <> 'N');

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_token_tbl(1).token_name :=
				  'ASSEMBLY_ITEM_NAME';
					l_token_tbl(1).token_value :=
				   p_bom_header_rec.assembly_item_name;
					l_token_tbl(2).token_name :=
				   'COMMON_ASSEMBLY_ITEM_NAME';
				   	l_token_tbl(2).token_value :=
				   p_bom_header_rec.common_assembly_item_name;
				Error_Handler.Add_Error_Token
				(  p_message_name	=>
						'BOM_COMMON_ASSY_TYPE_MISMATCH'
				 , p_token_tbl		=> l_token_tbl
				 , p_mesg_token_tbl	=> l_mesg_token_tbl
				 , x_mesg_token_tbl	=> l_mesg_token_tbl
				 );
				l_return_status := FND_API.G_RET_STS_ERROR;
		END;
		END IF;

    IF p_bom_header_Rec.ENABLE_ATTRS_UPDATE = 'Y'
    THEN
      -- Add operation sequence number validation here
      --call bompcmbm.validate_operation_sequence_id
      BOMPCMBM.Validate_Operation_Sequence_Id(p_src_bill_sequence_id => p_bom_head_unexp_rec.source_bill_sequence_id
                                     , p_assembly_item_id => p_bom_head_unexp_rec.assembly_item_id
                                     , p_organization_id => p_bom_head_unexp_rec.organization_id
                                     , p_alt_desg => p_bom_header_rec.alternate_bom_code
                                     , x_Return_Status  => l_valid_op_seq);
      IF l_valid_op_seq = FND_API.G_RET_STS_ERROR
      THEN
        --BOM_COMMON_OPN_INVALID
            l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
            l_token_tbl(1).token_value := p_bom_header_rec.assembly_item_name;
            l_token_tbl(2).token_name := 'COMMON_ASSY_ITEM_NAME';
            l_token_tbl(2).token_value :=	p_bom_header_rec.common_assembly_item_name;
            l_token_tbl(3).token_name := 'SOURCE_ORG';
            l_token_tbl(3).token_value := p_bom_header_rec.common_organization_code;
            l_token_tbl(4).token_name := 'DEST_ORG';
            l_token_tbl(4).token_value := p_bom_header_rec.organization_code;
            l_token_tbl(5).token_name := 'ASSEMBLY_ITEM_NAME1';
            l_token_tbl(5).token_value := p_bom_header_rec.assembly_item_name;

            Error_Handler.Add_Error_Token
            (  p_message_name       =>
                          'BOM_COMMON_OPN_INVALID'
             , p_token_tbl          => l_token_tbl
             , p_mesg_token_tbl     => l_mesg_token_tbl
             , x_mesg_token_tbl     => l_mesg_token_tbl
             );
            l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;



		--
		-- Validation for inter-org common
		--
		IF ( p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_UPDATE AND
		     p_bom_head_unexp_rec.source_bill_sequence_id IS NOT NULL AND
		     p_bom_head_unexp_rec.source_bill_sequence_id <> FND_API.G_MISS_NUM AND
		     p_old_bom_head_unexp_rec.source_bill_sequence_id IS NULL AND
		     p_old_bom_head_unexp_rec.organization_id <>
			p_bom_head_unexp_rec.common_organization_id
		    )
		   OR
		   ( p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_CREATE AND
		     p_bom_head_unexp_rec.source_bill_sequence_id IS NOT NULL AND
		     p_bom_head_unexp_rec.source_bill_sequence_id <> FND_API.G_MISS_NUM AND
		     p_bom_head_unexp_rec.common_organization_id <>
				p_bom_head_unexp_rec.organization_id
		    )
		THEN
		   BEGIN
      			SELECT '1'
        		  INTO l_dummy
        	          FROM mtl_parameters mp1, mtl_parameters mp2
       			 WHERE mp1.organization_id = p_bom_head_unexp_rec.organization_id
         		   AND mp2.organization_id =
			       DECODE(p_bom_header_rec.transaction_type, Bom_Globals.G_OPR_CREATE,
				      p_bom_head_unexp_rec.common_organization_id,
				      Bom_Globals.G_OPR_UPDATE,
				      p_old_bom_head_unexp_rec.common_organization_id
				      )
         		   AND mp1.master_organization_id = mp2.master_organization_id;

   			EXCEPTION
      				WHEN no_data_found THEN
                                        l_token_tbl(1).token_name :=
                                  		'ASSEMBLY_ITEM_NAME';
                                        l_token_tbl(1).token_value :=
                                   	p_bom_header_rec.assembly_item_name;
                                        l_token_tbl(2).token_name :=
                                   		'COMMON_ASSEMBLY_ITEM_NAME';
                                        l_token_tbl(2).token_value :=
                                   		p_bom_header_rec.common_assembly_item_name;
					l_token_tbl(3).token_name := 'ORG_CODE';
					l_token_tbl(3).token_value :=
						p_bom_header_rec.organization_code;
					l_token_tbl(4).token_name := 'COMMON_ORG_CODE';
					l_token_tbl(4).token_value :=
						p_bom_header_rec.common_organization_code;

                                	Error_Handler.Add_Error_Token
                                	(  p_message_name       =>
                                                'BOM_COMMON_MASTER_ORG_MISMATCH'
                                	 , p_token_tbl          => l_token_tbl
                                	 , p_mesg_token_tbl     => l_mesg_token_tbl
                                	 , x_mesg_token_tbl     => l_mesg_token_tbl
                                	 );

         				l_return_status := FND_API.G_RET_STS_ERROR;
   		    END; -- if master org same ends

          -- Add operation sequence number validation here
          --call bompcmbm.validate_operation_sequence_id
          /*BOMPCMBM.Validate_Operation_Sequence_Id(p_src_bill_sequence_id => p_bom_head_unexp_rec.source_bill_sequence_id
                                         , p_assembly_item_id => p_bom_head_unexp_rec.assembly_item_id
                                         , p_organization_id => p_bom_head_unexp_rec.organization_id
                                         , p_alt_desg => p_bom_header_rec.alternate_bom_code
                                         , x_Return_Status  => l_valid_op_seq);
          IF l_valid_op_seq = FND_API.G_RET_STS_UNEXP_ERROR
          THEN
            --BOM_COMMON_OPN_INVALID
                l_token_tbl(1).token_name := 'ALT_DESG';
                l_token_tbl(1).token_value := p_bom_header_rec.alternate_bom_code;
                l_token_tbl(2).token_name := 'COMMON_ASSY_ITEM_NAME';
                l_token_tbl(2).token_value :=	p_bom_header_rec.common_assembly_item_name;
                l_token_tbl(3).token_name := 'SOURCE_ORG';
                l_token_tbl(3).token_value := p_bom_header_rec.common_organization_code;
		      			l_token_tbl(4).token_name := 'DEST_ORG';
					      l_token_tbl(4).token_value := p_bom_header_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_message_name       =>
                              'BOM_COMMON_OPN_INVALID'
                 , p_token_tbl          => l_token_tbl
                 , p_mesg_token_tbl     => l_mesg_token_tbl
                 , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
        				l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;*/

                -- If the current bom and the bom being referenced as common are not in the
                -- same org, then make sure that the components of the parent BOM exist in
                -- both the organizations
                   BEGIN
                        SELECT bom_item_type, base_item_id, replenish_to_order_flag,
                               pick_components_flag--, DECODE(eng_item_flag, 'Y', 2, 1)
                          INTO bit, base_id, ato, pto--, assmtype
                          FROM mtl_system_items
                         WHERE inventory_item_id = p_bom_head_unexp_rec.assembly_item_id
                           AND organization_id = p_bom_head_unexp_rec.organization_id;



                        SELECT assembly_type
                        INTO assmtype
                        FROM bom_structures_b
                        WHERE bill_sequence_id = p_bom_head_unexp_rec.source_bill_sequence_id;

                        SELECT count(*)
                          INTO l_count
                          FROM bom_inventory_components bic
                         WHERE bic.bill_sequence_id = p_bom_head_unexp_rec.source_bill_sequence_id
                           AND nvl(bic.disable_date, sysdate + 1) >= sysdate --- Bug: 3448641
                           AND not exists
                               (SELECT 'x'
                                  FROM mtl_system_items s
                                 WHERE s.organization_id = p_bom_head_unexp_rec.organization_id
                                   AND s.inventory_item_id = bic.component_item_id
                                   AND ((assmtype = 1 AND s.eng_item_flag = 'N')
                                          OR (assmtype = 2)
                                        )
/* Commented the following for Bug2984763 */
                                   AND s.bom_enabled_flag = 'Y' /* Uncommented for bug 5925020 */
                                   AND s.inventory_item_id <> p_bom_head_unexp_rec.assembly_item_id
                                   AND ((bit = 1 AND s.bom_item_type <> 3)
                                         OR (bit = 2 AND s.bom_item_type <> 3)
                                         OR (bit = 3)
                                         OR (bit = 4
                                             AND (s.bom_item_type = 4
                                                  OR
                                                  ( s.bom_item_type IN (2, 1)
                                                    AND s.replenish_to_order_flag = 'Y'
                                                    AND base_id IS NOT NULL
                                                    AND ato = 'Y'
                                                   )
                                                 )
                                              )
                                          )
                                   AND (bit = 3
                                         OR
                                        pto = 'Y'
                                        OR
                                        s.pick_components_flag = 'N'
                                        )
                                   AND (bit = 3
                                         OR
                                        NVL(s.bom_item_type, 4) <> 2
                                                OR
                                           (s.bom_item_type = 2
                                            AND (( pto = 'Y'
                                                   AND s.pick_components_flag = 'Y'
                                                  )
                                                  OR ( ato = 'Y'
                                                       AND s.replenish_to_order_flag = 'Y'
                                                      )
                                                 )
                                            )
                                         )
                                   AND (
                                        (
                                          (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
                                           and
                                          (not( bit = 4
                                                AND pto = 'Y'
                                                AND s.bom_item_type = 4
                                                AND s.replenish_to_order_flag = 'Y'
                                               )
                                          )
                                         ) OR
                                         (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) = 1)
                                        )  /* BOM ER 9904085 */
                                   AND (
                                        (
                                          (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
                                           and
                                          (not( bit = 1
                                                AND pto = 'Y'
                                                AND nvl(bic.optional, 1) = 2
                                                AND s.bom_item_type = 4
                                                AND s.replenish_to_order_flag = 'Y'
                                               )
                                           )
                                          ) OR
                                         (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) = 1)
                                         )   /* BOM ER 9904085 */
                        );



                        IF l_Count > 0
                        THEN
                                l_token_tbl.DELETE;
                                l_token_tbl(1).token_name :=
                                                'ASSEMBLY_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                        p_bom_header_rec.assembly_item_name;
                                l_token_tbl(2).token_name := 'ORG_CODE';
                                l_token_tbl(2).token_value :=
                                                p_bom_header_rec.organization_code;
                                l_token_tbl(3).token_name := 'COMMON_ORG_CODE';
                                l_token_tbl(3).token_value :=
						p_bom_header_rec.common_organization_code;

                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_COMMON_COMP_PROP_MISMATCH'
                                 , p_token_tbl      => l_token_tbl
                                 , p_mesg_token_tbl => l_mesg_token_tbl
                                 , x_mesg_token_tbl => l_mesg_token_tbl
                                 );

                                 l_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;
                   END;

    --If the source bom comtains fixed rev components, make sure the same revisions exist in the
    --destination org.
    BOMPCMBM.check_comp_rev_in_local_org(p_src_bill_seq_id => p_bom_head_unexp_rec.source_bill_sequence_id,
                                         p_org_id => p_bom_head_unexp_rec.organization_id,
                                         x_return_status => l_comp_rev_status); --Bug 7526867

    IF l_comp_rev_status <> FND_API.G_RET_STS_SUCCESS --Bug 7526867
    THEN

      l_token_tbl.DELETE;
      l_token_tbl(1).token_name := 'ASSY_ITEM';
      l_token_tbl(1).token_value := p_bom_header_rec.assembly_item_name;
      l_token_tbl(2).token_name := 'ORG_CODE';
      l_token_tbl(2).token_value := p_bom_header_rec.organization_code;

      Error_Handler.Add_Error_Token
      (  p_message_name   => 'BOM_SRC_COMP_FIXED_REV'
       , p_token_tbl      => l_token_tbl
       , p_mesg_token_tbl => l_mesg_token_tbl
       , x_mesg_token_tbl => l_mesg_token_tbl
       );

       l_return_status := FND_API.G_RET_STS_ERROR;  --Bug 7526867

    END IF;

                   --
                   -- Make sure that the substitute components exist in both the organizations
                   --
		  BEGIN
			SELECT count(*)
			  INTO l_count
        	          FROM bom_inventory_components bic,
             		       bom_substitute_components bsc
       			 WHERE bic.bill_sequence_id =p_bom_head_unexp_rec.source_bill_sequence_id
         		   AND bic.component_sequence_id = bsc.component_sequence_id
         		   AND bsc.substitute_component_id not in
               		       (select msi1.inventory_item_id
                  		  from mtl_system_items msi1, mtl_system_items msi2
                 		 where msi1.organization_id = p_bom_head_unexp_rec.organization_id
                   		   and msi1.inventory_item_id = bsc.substitute_component_id
                         and msi1.bom_enabled_flag = 'Y'
                   		   and msi2.organization_id = p_bom_head_unexp_rec.common_organization_id
                   		   and msi2.inventory_item_id = msi1.inventory_item_id
                         AND ((assmtype = 1 AND msi1.eng_item_flag = 'N')
                               OR (assmtype = 2)
                             )
                                   AND msi1.inventory_item_id <> p_bom_head_unexp_rec.assembly_item_id
                                   AND ((bit = 1 AND msi1.bom_item_type <> 3)
                                         OR (bit = 2 AND msi1.bom_item_type <> 3)
                                         OR (bit = 3)
                                         OR (bit = 4
                                             AND (msi1.bom_item_type = 4
                                                  OR
                                                  ( msi1.bom_item_type IN (2, 1)
                                                    AND msi1.replenish_to_order_flag = 'Y'
                                                    AND base_id IS NOT NULL
                                                    AND ato = 'Y'
                                                   )
                                                 )
                                              )
                                          )
                                   AND (bit = 3
                                         OR
                                        pto = 'Y'
                                        OR
                                        msi1.pick_components_flag = 'N'
                                        )
                                   AND (bit = 3
                                         OR
                                        NVL(msi1.bom_item_type, 4) <> 2
                                                OR
                                           (msi1.bom_item_type = 2
                                            AND (( pto = 'Y'
                                                   AND msi1.pick_components_flag = 'Y'
                                                  )
                                                  OR ( ato = 'Y'
                                                       AND msi1.replenish_to_order_flag = 'Y'
                                                      )
                                                 )
                                            )
                                         )
                                   AND /* not( bit = 4
                                            AND pto = 'Y'
                                            AND msi1.bom_item_type = 4
                                            AND msi1.replenish_to_order_flag = 'Y'
                                           ) */
                                       (
                                        (
                                          (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
                                           and
                                          (not( bit = 4
                                                AND pto = 'Y'
                                                AND msi1.bom_item_type = 4
                                                AND msi1.replenish_to_order_flag = 'Y'
                                               )
                                          )
                                         ) OR
                                         (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) = 1)
                                        )  /* BOM ER 9904085 */
                         );
      			  IF (l_count > 0) THEN
				l_token_tbl.DELETE;
                                l_token_tbl(1).token_name :=
                                                'COMPONENT_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                        p_bom_header_rec.assembly_item_name;
                                l_token_tbl(2).token_name := 'ASSEMBLY_ITEM_NAME';
                                l_token_tbl(2).token_value :=
                                                p_bom_header_rec.organization_code;
                                l_token_tbl(3).token_name := 'COMMON_ORG_CODE';
                                l_token_tbl(3).token_value :=
						p_bom_header_rec.common_organization_code;

                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_COMMON_SCOMP_NOTINALLORG'
                                 , p_token_tbl      => l_token_tbl
                                 , p_mesg_token_tbl => l_mesg_token_tbl
                                 , x_mesg_token_tbl => l_mesg_token_tbl
                                 );

                                 l_return_status := FND_API.G_RET_STS_ERROR;

      			  END IF;
 	   	END; -- Check if all the substitutes exist ends
    END IF;  -- User creating a common or updating the common info Ends

/* BOM ER 9904085 */
--begin
IF ( p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_UPDATE AND
		     p_bom_head_unexp_rec.source_bill_sequence_id IS NOT NULL AND
		     p_bom_head_unexp_rec.source_bill_sequence_id <> FND_API.G_MISS_NUM AND
		     p_old_bom_head_unexp_rec.source_bill_sequence_id IS NULL AND
		     p_old_bom_head_unexp_rec.organization_id =
			p_bom_head_unexp_rec.common_organization_id
		    )
		   OR
		   ( p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_CREATE AND
		     p_bom_head_unexp_rec.source_bill_sequence_id IS NOT NULL AND
		     p_bom_head_unexp_rec.source_bill_sequence_id <> FND_API.G_MISS_NUM AND
		     p_bom_head_unexp_rec.common_organization_id =
				p_bom_head_unexp_rec.organization_id
		    )
			THEN
 BEGIN

						SELECT bom_item_type, base_item_id, replenish_to_order_flag,
                               pick_components_flag--, DECODE(eng_item_flag, 'Y', 2, 1)
                          INTO bit, base_id, ato, pto--, assmtype
                          FROM mtl_system_items
                         WHERE inventory_item_id = p_bom_head_unexp_rec.assembly_item_id
                           AND organization_id = p_bom_head_unexp_rec.organization_id;

						    SELECT assembly_type
                        INTO assmtype
                        FROM bom_structures_b
                        WHERE bill_sequence_id = p_bom_head_unexp_rec.source_bill_sequence_id;

						SELECT count(*)
                          INTO l_count
                          FROM bom_inventory_components bic
                         WHERE bic.bill_sequence_id = p_bom_head_unexp_rec.source_bill_sequence_id
                           AND nvl(bic.disable_date, sysdate + 1) >= sysdate
                           AND not exists
                               (SELECT 'x'
                                  FROM mtl_system_items s
                                 WHERE s.organization_id = p_bom_head_unexp_rec.organization_id
                                   AND s.inventory_item_id = bic.component_item_id
                                   AND ((assmtype = 1 AND s.eng_item_flag = 'N')
                                          OR (assmtype = 2)
                                        )
                                   AND s.bom_enabled_flag = 'Y'
                                   AND s.inventory_item_id <> p_bom_head_unexp_rec.assembly_item_id
								   AND (
                                        (
                                          (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
                                           and
                                          (not( bit = 4
                                                AND pto = 'Y'
                                                AND s.bom_item_type = 4
                                                AND s.replenish_to_order_flag = 'Y'
                                               )
                                          )
                                         ) OR
                                         (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) = 1)
                                        )
                                   AND (
                                          (
                                            (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
                                            and
                                            (not( bit = 1
                                                AND pto = 'Y'
                                                AND nvl(bic.optional, 1) = 2
                                                AND s.bom_item_type = 4
                                                AND s.replenish_to_order_flag = 'Y'
                                                )
                                            )
                                           ) OR
                                            (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) = 1)
                                         )
                        );

						IF l_Count > 0
                        THEN
                                l_token_tbl.DELETE;
                                l_token_tbl(1).token_name :=
                                                'ASSEMBLY_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                        p_bom_header_rec.assembly_item_name;
                                l_token_tbl(2).token_name := 'COMMON_ORG_CODE';
                                l_token_tbl(2).token_value :=
						p_bom_header_rec.common_organization_code;

                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_SAME_ORG_COMMON_PROP_MIS'
                                 , p_token_tbl      => l_token_tbl
                                 , p_mesg_token_tbl => l_mesg_token_tbl
                                 , x_mesg_token_tbl => l_mesg_token_tbl
                                 );

                                 l_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;
                   END;




                   -- Make sure that the substitute components properties are allowed as well
                   --
		  BEGIN
			SELECT count(*)
			  INTO l_count
        	          FROM bom_inventory_components bic,
             		       bom_substitute_components bsc
       			 WHERE bic.bill_sequence_id =p_bom_head_unexp_rec.source_bill_sequence_id
         		   AND bic.component_sequence_id = bsc.component_sequence_id
         		   AND bsc.substitute_component_id not in
               		       (select msi1.inventory_item_id
                  		  from mtl_system_items msi1, mtl_system_items msi2
                 		 where msi1.organization_id = p_bom_head_unexp_rec.organization_id
                   		   and msi1.inventory_item_id = bsc.substitute_component_id
                         and msi1.bom_enabled_flag = 'Y'
                   		   and msi2.organization_id = p_bom_head_unexp_rec.common_organization_id
                   		   and msi2.inventory_item_id = msi1.inventory_item_id
                         AND ((assmtype = 1 AND msi1.eng_item_flag = 'N')
                               OR (assmtype = 2)
                             )
                                   AND msi1.inventory_item_id <> p_bom_head_unexp_rec.assembly_item_id

                                   AND
                                       (
                                        (
                                          (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1)
                                           and
                                          (not( bit = 4
                                                AND pto = 'Y'
                                                AND msi1.bom_item_type = 4
                                                AND msi1.replenish_to_order_flag = 'Y'
                                               )
                                          )
                                         ) OR
                                         (nvl(fnd_profile.value('BOM:MANDATORY_ATO_IN_PTO'), 2) = 1)
                                        )
                         );
      			  IF (l_count > 0) THEN
				l_token_tbl.DELETE;
                                l_token_tbl(1).token_name :=
                                                'COMPONENT_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                        p_bom_header_rec.assembly_item_name;
                                l_token_tbl(2).token_name := 'COMMON_ORG_CODE';
                                l_token_tbl(2).token_value :=
						p_bom_header_rec.common_organization_code;

                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_COMMON_SCOMP_PROP_MIS'
                                 , p_token_tbl      => l_token_tbl
                                 , p_mesg_token_tbl => l_mesg_token_tbl
                                 , x_mesg_token_tbl => l_mesg_token_tbl
                                 );

                                 l_return_status := FND_API.G_RET_STS_ERROR;

      			  END IF;
 	   	END; -- Check if all the substitutes exist ends
    END IF;  -- User creating a common or updating the common info Ends
	/* BOM ER 9904085 */
    --end


		-- check to see if bill item and common item have same bom_item_type,
		-- pick_components_flag and replenish_to_order_flag
		-- Common item must have bom_enabled_flag = 'Y'
		--
        IF ( p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_UPDATE AND
             p_bom_head_unexp_rec.source_bill_sequence_id IS NOT NULL AND
             p_bom_head_unexp_rec.source_bill_sequence_id <> FND_API.G_MISS_NUM AND
             p_old_bom_head_unexp_rec.source_bill_sequence_id IS NULL
            )
           OR
           ( p_bom_header_rec.transaction_type = Bom_Globals.G_OPR_CREATE AND
             p_bom_head_unexp_rec.source_bill_sequence_id IS NOT NULL AND
             p_bom_head_unexp_rec.source_bill_sequence_id <> FND_API.G_MISS_NUM
           )
        THEN
           BEGIN
                 SELECT 1
         		 INTO l_count
         		 FROM mtl_system_items msi1, mtl_system_items msi2
        	        WHERE
--Bug 2217522             msi1.organization_id = p_bom_head_unexp_rec.common_organization_id
                          msi1.organization_id = p_bom_head_unexp_rec.organization_id   --Bug 2217522
          		  AND msi1.inventory_item_id = p_bom_head_unexp_rec.assembly_item_id
          		  AND msi2.organization_id = p_bom_head_unexp_rec.common_organization_id
          		  AND msi2.inventory_item_id=p_bom_head_unexp_rec.common_assembly_item_id
          		  AND msi2.bom_enabled_flag = 'Y'
          		  AND msi1.bom_item_type = msi2.bom_item_type
          		  AND msi1.pick_components_flag = msi2.pick_components_flag
          		  AND msi1.replenish_to_order_flag = msi2.replenish_to_order_flag
                          AND msi1.effectivity_control = msi2.effectivity_control;
                          --Commoning should happen within the eff ctrl.
    			EXCEPTION
       			   WHEN no_data_found THEN
			       l_return_status := FND_API.G_RET_STS_ERROR;
				l_token_tbl.DELETE;
                                l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                                l_token_tbl(1).token_value := p_bom_header_rec.assembly_item_name;
                                l_token_tbl(2).token_name := 'COMMON_ORG_CODE';
                                l_token_tbl(2).token_value :=
						p_bom_header_rec.common_organization_code;
				l_token_tbl(3).token_name := 'ORG_CODE';
				l_token_tbl(3).token_value := p_bom_header_rec.organization_code;

                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_COMMON_ATOPTO_MISMATCH'
                                 , p_token_tbl      => l_token_tbl
                                 , p_mesg_token_tbl => l_mesg_token_tbl
                                 , x_mesg_token_tbl => l_mesg_token_tbl
                                 );
		   END;
        END IF;


		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END Check_Entity;


	PROCEDURE Check_Entity_Delete
        ( x_return_status       IN OUT NOCOPY VARCHAR2
        , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , p_bom_header_rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
        , p_bom_head_Unexp_Rec  IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	, x_bom_head_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
        )
        IS
		l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_bom_head_unexp_rec	Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
				:= p_bom_head_Unexp_Rec;
		Cursor CheckGroup is
		SELECT description,
           	       delete_group_sequence_id,
           	       delete_type
          	  FROM bom_delete_groups
    	         WHERE delete_group_name = p_bom_header_rec.Delete_Group_Name
    		   AND organization_id = p_bom_head_Unexp_Rec.organization_id;

        BEGIN
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		x_bom_head_unexp_rec := p_bom_head_unexp_rec;

        	IF p_bom_header_rec.Delete_Group_Name IS NULL OR
		   p_bom_header_rec.Delete_Group_Name = FND_API.G_MISS_CHAR
		THEN
			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_DG_NAME_MISSING'
			 , p_mesg_token_tbl	=> l_mesg_token_tbl
			 , x_mesg_token_tbl	=> x_mesg_token_tbl
			 );
			x_return_status := FND_API.G_RET_STS_ERROR;
			RETURN;
		END IF;

		For c_CheckGroup in CheckGroup
		LOOP
       			If c_CheckGroup.delete_type <> 2  /* Bill */ then
         			Error_Handler.Add_Error_Token
			     (  p_message_name => 'BOM_DUPLICATE_DELETE_GROUP'
			      , p_mesg_token_tbl=>l_mesg_token_tbl
			      , x_mesg_token_tbl=>x_mesg_token_tbl
			      );
			      x_return_status := FND_API.G_RET_STS_ERROR;
			      RETURN;
       			End if;


       			l_bom_head_unexp_rec.DG_description :=
					c_Checkgroup.description;
       			l_bom_head_unexp_rec.DG_sequence_id :=
					c_Checkgroup.delete_group_sequence_id;

			RETURN;

		END LOOP;

		IF l_bom_head_unexp_rec.DG_sequence_id IS NULL
		THEN
			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'NEW_DELETE_GROUP'
			 , p_message_type	=> 'W'
			 , p_mesg_token_tbl	=> l_mesg_token_tbl
			 , x_mesg_token_tbl	=> x_mesg_token_tbl
			 );

			l_bom_head_unexp_rec.DG_new := TRUE;
			l_bom_head_unexp_rec.DG_description :=
				p_bom_header_rec.DG_description;
		END IF;


		-- Return the unexposed record
		x_bom_head_unexp_rec := l_bom_head_unexp_rec;

        END Check_Entity_Delete;


END Bom_Validate_Bom_Header;

/
