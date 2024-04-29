--------------------------------------------------------
--  DDL for Package Body BOM_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VAL_TO_ID" AS
/* $Header: BOMSVIDB.pls 120.3.12010000.3 2010/04/29 01:09:37 umajumde ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSVIDB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Val_To_Id
--
--  NOTES
--
--  HISTORY
--
--  01-JUL-99	Rahul Chitko	Initial Creation
--
-- 07-MAY-2001  Refai Farook    EAM related changes
--
--  21-AUG-01   Refai Farook    One To Many support changes
--
-- 06-May-05    Abhishek Rudresh     Common BOM Attr Updates
-- 13-JUL-06    Bhavnesh Patel       Added support for Structure Type
****************************************************************************/
	G_Pkg_Name	VARCHAR2(30) := 'BOM_Val_To_Id';
	g_token_tbl	Error_Handler.Token_Tbl_Type;

 function parse_item_name (org_id IN Number,
                        item_name IN Varchar2,
                        id OUT NOCOPY Number,
                        err_text out NOCOPY Varchar2) return Number;
        FUNCTION Get_BOM_Implementation_Date(p_bill_seq_id IN NUMBER)
        RETURN DATE
        IS
          CURSOR c1 IS SELECT implementation_date FROM
           bom_bill_of_materials WHERE
           bill_sequence_id = p_bill_seq_id;
        BEGIN
          FOR r1 IN c1
          LOOP
            Return r1.implementation_date;
          END LOOP;
	  EXCEPTION WHEN OTHERS THEN
	    Return NULL;
        END;


 --Bug 8850425 begin
 FUNCTION Comp_Operation_Seq_Id(  p_component_sequence_id   IN NUMBER
                                , p_operation_sequence_number IN NUMBER
                                ) RETURN NUMBER
	IS
  l_id   NUMBER;
	BEGIN

  select comp_operation_seq_id
	into   l_id
 	from   bom_component_operations
	where  component_sequence_id = p_component_sequence_id
 	and    operation_seq_num = p_operation_sequence_number;

	RETURN l_id;

 EXCEPTION
	WHEN OTHERS THEN
  	RETURN NULL;

  END Comp_Operation_Seq_Id;

 --Bug 8850425 end


        /********************************************************************
        * Function      : Get_EnforceInteger_Code
        * Returns       : NUMBER
        * Purpose       : Will convert the value of enforce integer requirements value
 	*		into enforce integer requirements code
        *                 If the conversion fails then the function will return
        *                 a NULL otherwise will return the code.
        *                 For an unexpected error function will return a
        *                 missing value.
        *********************************************************************/
        FUNCTION Get_EnforceInteger_Code
                 (  p_enforce_integer  IN  VARCHAR2 )
                    RETURN NUMBER
        IS
		l_enforce_int_reqcode  NUMBER;
	BEGIN
		SELECT lookup_code INTO l_enforce_int_reqcode FROM mfg_lookups WHERE
			lookup_type = 'BOM_ENFORCE_INT_REQUIREMENTS' AND
			upper(meaning) = upper(p_enforce_integer);
		Return l_enforce_int_reqcode;
		EXCEPTION WHEN OTHERS THEN
			Return NULL;
	END;


	/********************************************************************
	* Function      : Operation Sequence Id
	* Returns       : NUMBER
	* Purpose       : Will convert the value of operation sequence number to
	*		  operation sequence id.
	*                 If the conversion fails then the function will return
	*		  a NULL otherwise will return the opseq_id.
	*		  For an unexpected error function will return a
	*		  missing value.
	*********************************************************************/
	FUNCTION Operation_Sequence_Id
		 (  p_organization_id               IN  NUMBER
                    ,p_assembly_item_id             IN  NUMBER
                    ,p_alternate_bom_designator     IN  VARCHAR2
                    ,p_operation_sequence_number    IN  NUMBER
	  	    ,x_err_text 	            IN OUT NOCOPY VARCHAR2) RETURN NUMBER
	IS
	   l_id                          NUMBER;

        BEGIN

           SELECT operation_sequence_id
            INTO l_id
            FROM bom_operation_sequences bos
            WHERE routing_sequence_id =
           (SELECT common_routing_sequence_id
            FROM bom_operational_routings bor
            WHERE assembly_item_id = p_assembly_item_id
            and organization_id = p_organization_id
            and nvl(alternate_routing_designator, nvl(p_alternate_bom_designator, 'NONE')) =
                nvl(p_alternate_bom_designator, 'NONE')
            and (  p_alternate_bom_designator is null
               or (p_alternate_bom_designator is not null
                   and (alternate_routing_designator = p_alternate_bom_designator
                        or not exists (SELECT null
                                       FROM bom_operational_routings bor2
                                       WHERE bor2.assembly_item_id = p_assembly_item_id
                                          and bor2.organization_id = p_organization_id
                                          and bor2.alternate_routing_designator =
                                              p_alternate_bom_designator
                                         )
                          )
                      )
                 )
            )
            and nvl(trunc(disable_date), trunc(sysdate)+1) > trunc(sysdate) and nvl(operation_type,1) = 1 and
            operation_seq_num = p_operation_sequence_number;

            RETURN l_id;

            EXCEPTION WHEN NO_DATA_FOUND THEN
              x_err_text := 'Id not found';
              RETURN NULL;

            WHEN TOO_MANY_ROWS THEN
              x_err_text := 'Too many rows';
              RETURN NULL;

            WHEN OTHERS THEN
              x_err_text := sqlerrm;
              RETURN FND_API.G_MISS_NUM;

	END Operation_Sequence_Id;


	/********************************************************************
	* Function      : Organization
	* Returns       : NUMBER
	* Purpose       : Will convert the value of organization_code to
	*		  organization_id using MTL_PARAMETERS.
	*                 If the conversion fails then the function will return
	*		  a NULL otherwise will return the org_id.
	*		  For an unexpected error function will return a
	*		  missing value.
	*********************************************************************/
	FUNCTION Organization
		 (  p_organization IN VARCHAR2
	  	  , x_err_text 	   IN OUT NOCOPY VARCHAR2) RETURN NUMBER
	IS
		l_id                          NUMBER;
		ret_code                      NUMBER;
		l_err_text                    VARCHAR2(2000);
	BEGIN
    		SELECT  organization_id
    		INTO    l_id
    		FROM    mtl_parameters
    		WHERE   organization_code = p_organization;

    		RETURN l_id;

		EXCEPTION

    		WHEN NO_DATA_FOUND THEN
        		RETURN NULL;

    		WHEN OTHERS THEN
        		RETURN FND_API.G_MISS_NUM;

	END Organization;

	/**********************************************************************
	* Function 	: Revised_Item
	* Parameters IN : Revised Item Name
	*		  Organization ID
	* Parameters OUT: Error_Text
	* Returns	: Revised Item Id
	* Purpose	: This function will get the ID for the revised item and
	*		  return the ID. If the revised item is invalid then the
	*		  ID will returned as NULL.
	**********************************************************************/
	FUNCTION Revised_Item(  p_revised_item_num IN VARCHAR2,
				p_organization_id IN NUMBER,
				x_err_text IN OUT NOCOPY VARCHAR2 )
	RETURN NUMBER
	IS
		l_id                          NUMBER;
		ret_code		      NUMBER;
		l_err_text 		      VARCHAR2(2000);
	BEGIN

    		/* ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                	org_id => p_organization_id,
                	flex_code => 'MSTK',
                	flex_name => p_revised_item_num,
                	flex_id => l_id,
                	set_id => -1,
                	err_text => x_err_text);*/
                    ret_code := parse_item_name(
                        org_id => p_organization_id,
                        item_name => p_revised_item_num,
                        id => l_id,
                        err_text => x_err_text);

    		IF (ret_code <> 0) THEN
			RETURN NULL;
    		ELSE
    			RETURN l_id;
    		END IF;

	END Revised_Item;

	/*******************************************************************
	* Function	: Component_Item
	* Parameters IN	: Component Item Name
	*		  Organization ID
	* Parameters OUT: Error Message
	* Returns	: Component_Item_Id
	* Purpose	: Function will convert the component item name to its
	*		  corresponsind ID and return the value.
	*		  If the component is invalid, then a NULL is returned.
	*********************************************************************/
	FUNCTION COMPONENT_ITEM( p_organization_id   IN NUMBER,
				p_component_item_num IN VARCHAR2,
				x_err_text IN OUT NOCOPY VARCHAR2)
	return NUMBER
	IS
		l_id				NUMBER;
		ret_code		      NUMBER;
	BEGIN

    	     /*	ret_code := INVPUOPI.mtl_pr_parse_flex_name(
               		org_id => p_organization_id,
               		flex_code => 'MSTK',
               		flex_name => p_component_item_num,
               		flex_id => l_id,
               		set_id => -1,
               		err_text => x_err_text); */
  ret_code := parse_item_name(
                        org_id => p_organization_id,
                        item_name => p_component_item_num,
                        id => l_id,
                        err_text => x_err_text);

       		IF (ret_code <> 0) THEN
			RETURN NULL;
       		END IF;

    		RETURN l_id;

	END COMPONENT_ITEM;

	/********************************************************************
	* Function	: Assembly_Item
	* Returns	: Number
	* Parameters IN	: Assembly Item Name
	*		  Organization_Id
	* Purpose	: This function will get ID for the assembly item and
	*                 return the ID. If the assembly item is invalid then
	*                 ID will returned as NULL.
	*********************************************************************/
	FUNCTION Assembly_Item
	(  p_assembly_item_name	IN VARCHAR2
	 , p_organization_id	IN NUMBER
	 , x_err_text		IN OUT NOCOPY VARCHAR2) RETURN NUMBER
	IS
	BEGIN
		RETURN Bom_Val_To_Id.Revised_Item
		       (  p_revised_item_num	=> p_assembly_item_name
			, p_organization_id	=> p_organization_id
			, x_err_text		=> x_err_text
			);

	END Assembly_Item;


	FUNCTION Bill_Sequence( p_assembly_item_id IN NUMBER,
		       p_alternate_bom_designator IN VARCHAR2,
		       p_organization_id  IN NUMBER,
		       x_err_text         IN OUT NOCOPY VARCHAR2
			)
	RETURN NUMBER
	IS
		l_id                          NUMBER;
		l_err_text		      VARCHAR2(2000);
	BEGIN

		SELECT bill_sequence_id
	  	INTO l_id
	  	FROM bom_bill_of_materials
	 	WHERE assembly_item_id = p_assembly_item_id
	 	  AND NVL(alternate_bom_designator, 'NONE') =
--	       		NVL(p_alternate_bom_designator, 'NONE')
                 decode(p_alternate_bom_designator,FND_API.G_MISS_CHAR,'NONE',NULL,'NONE',p_alternate_bom_designator)                 --2783251
    	 	  AND organization_id = p_organization_id;

		RETURN l_id;

		EXCEPTION
			WHEN OTHERS THEN
				RETURN NULL;
	END Bill_Sequence;

	/********************************************************************
	* Function	: Bill_Sequence_Id
	* Returns	: Number
	* Parameters IN	: Assemby_Item_Id
	*		  Organization_Id
	*		  Alternate_Bom_Code
	* Parameters OUT: Error Text
	* Purpose	: Function will use the input parameters to find the
	*		  bill sequence_id and return a NULL if an error
	*		  occured or the bill sequence_id could not be obtained
	********************************************************************/
	FUNCTION Bill_Sequence_Id
		(  p_assembly_item_id		IN  NUMBER
	  	 , p_alternate_bom_code	IN  VARCHAR2
	  	 , p_organization_id		IN  NUMBER
	  	 , x_err_text			IN OUT NOCOPY VARCHAR2
	  	 ) RETURN NUMBER
	IS
	BEGIN
		RETURN Bill_Sequence
		       (  p_assembly_item_id	=> p_assembly_item_id
			, p_alternate_bom_designator => p_alternate_bom_code
			, p_organization_id	=> p_organization_id
			, x_err_text		=> x_err_text
			);
	END Bill_Sequence_Id;

 /**********************************************************************
  * Function  : Structure_Type
  * Parameters IN : Structure Type Name
  * Parameters OUT: Error_Text
  * Returns : Structure_Type_ID
  * Purpose : This function will get the ID for the structure type name and
  *     return the ID. If the structure type name is invalid then the
  *     ID will be returned as NULL.
  **********************************************************************/
  FUNCTION Structure_Type(  p_structure_type_name IN VARCHAR2,
                            x_err_text IN OUT NOCOPY VARCHAR2 )
  RETURN NUMBER
  IS
    l_structure_type_id   BOM_STRUCTURE_TYPES_B.STRUCTURE_TYPE_ID%TYPE;
  BEGIN
    SELECT  STRUCTURE_TYPE_ID
    INTO    l_structure_type_id
    FROM    BOM_STRUCTURE_TYPES_B
    WHERE   STRUCTURE_TYPE_NAME = p_structure_type_name
    AND     ( DISABLE_DATE IS NULL OR DISABLE_DATE > SYSDATE );

    RETURN l_structure_type_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

    WHEN OTHERS THEN
      x_err_text := SQLERRM;
      RETURN NULL;

  END Structure_Type;



	/*********************************************************************
	* Procedure	: BOM_Header_UUI_To_UI
	* Returns	: None
	* Parameters IN	: Assembly Item Record
	*		  Assembly Item Unexposed Record
	* Parameters OUT: Assembly Item unexposed record
	*		  Message Token Table
	*		  Return Status
	* Purpose	: This procedure will perform all the required
	*		  User unique to Unique index conversions for Assembly
	*		  item. Any errors will be logged in the Message table
	*		  and a return satus of success or failure will be
	*		  returned to the calling program.
	*********************************************************************/
	PROCEDURE BOM_Header_UUI_To_UI
	(  p_bom_header_Rec	  IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_bom_header_unexp_Rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_bom_header_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status        IN OUT NOCOPY VARCHAR2
	)
	IS
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_bom_header_unexp_rec	Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type;
		l_return_status		VARCHAR2(1);
		l_err_text		VARCHAR2(2000);

                CURSOR c_Check_Alternate(  p_alt_designator     VARCHAR2,
                                           p_organization_id    NUMBER ) IS
                SELECT 1
                  FROM bom_alternate_designators
                 WHERE alternate_designator_code = p_alt_designator
                   AND organization_id = p_organization_id;

	BEGIN
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		l_bom_header_unexp_rec := p_bom_header_unexp_rec;


If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header UUI-UI Conversion . . '); END IF;


		--
		-- Assembly Item name cannot be NULL or missing.
		--
		IF p_bom_header_rec.assembly_item_name IS NULL OR
		   p_bom_header_rec.assembly_item_name = FND_API.G_MISS_CHAR
		THEN
			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_AITEM_NAME_KEYCOL_NULL'
			 , p_mesg_token_tbl	=> l_mesg_token_tbl
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );

			l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		--
		-- Assembly item name must be successfully converted to id.
		--

		l_bom_header_unexp_rec.assembly_item_id :=
		Assembly_Item (  p_assembly_item_name	=>
                                p_bom_header_rec.assembly_item_name
                 	       , p_organization_id       =>
                                l_bom_header_unexp_rec.organization_id
                 	       , x_err_text              => l_err_text
                     	       );

        	IF l_bom_header_unexp_rec.assembly_item_id IS NULL
        	THEN
			g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
			g_token_tbl(1).token_value :=
					p_bom_header_rec.assembly_item_name;
                	g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                	g_token_tbl(2).token_value :=
                                        p_bom_header_rec.organization_code;
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_ASSEMBLY_ITEM_INVALID'
                 	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                 	);
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
		ELSIF l_err_text IS NOT NULL AND
		  (l_bom_header_unexp_rec.assembly_item_id IS NULL OR
		   l_bom_header_unexp_rec.assembly_item_id = FND_API.G_MISS_NUM)
		THEN
			-- This is an unexpected error.
			Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
			 , p_Message_Text	=> l_err_text || ' in ' ||
						   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	END IF;

If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('After converting Assembly name ' || to_char(l_bom_header_unexp_rec.assembly_item_id) || ' Status ' || l_return_status); END IF;

                IF p_bom_header_rec.alternate_bom_code IS NOT NULL AND
                   p_bom_header_rec.alternate_bom_code <> FND_API.G_MISS_CHAR
                THEN
                        l_err_text := FND_API.G_RET_STS_ERROR;

                        FOR check_alternate IN
                                c_Check_Alternate
                                ( p_alt_designator  => p_bom_header_rec.alternate_bom_code,
                                  p_organization_id => l_bom_header_unexp_rec.organization_id )
                        LOOP
                                l_err_text := FND_API.G_RET_STS_SUCCESS;
                        END LOOP;

                        IF l_err_text <> FND_API.G_RET_STS_SUCCESS
                        THEN
                                g_token_tbl(1).token_name := 'ALTERNATE_BOM_CODE';
                                g_token_tbl(1).token_value :=
                                        p_bom_header_rec.alternate_bom_code;
                                g_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                                g_token_tbl(2).token_value := p_bom_header_rec.organization_code;
                                Error_Handler.Add_Error_Token
                                (  p_Message_Name       => 'BOM_ALT_DESIGNATOR_INVALID'
                                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_token_tbl          => g_token_tbl
                                 );

                                l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                END IF;

		x_return_status := l_return_status;
		x_bom_header_unexp_rec := l_bom_header_unexp_rec;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END BOM_Header_UUI_To_UI;


	/*********************************************************************
	* Procedure	: Bom_Header_VID
	* Returns	: None
	* Parameters IN	: BOM Header exposed Record
	*		  BOM Header Unexposed Record
	* Parameters OUT: BOM Header Unexposed Record
	*		  Return Status
	*		  Message Token Table
	* Purpose	: This is the access procedure which the private API
	*		  will call to perform the BOM Header value to ID
	*		  conversions. If any of the conversions fail then the
	*		  the procedure will return with an error status and
	*		  the messsage token table filled with appropriate
	*		  error message.
	*********************************************************************/
	PROCEDURE Bom_Header_VID
	(  x_Return_Status       IN OUT NOCOPY VARCHAR2
	 , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , p_bom_head_unexp_rec  IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_bom_head_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , p_bom_header_Rec      IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	)
	IS
		l_return_status 	VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_err_text		VARCHAR2(2000);
		l_Token_Tbl		Error_Handler.Token_Tbl_Type;
		l_bom_head_unexp_rec	Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
					:= p_bom_head_unexp_rec;
    l_src_bill_sequence_id NUMBER;

  BEGIN

If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Header VID conversion . . . ');
END IF;
		IF p_bom_header_rec.common_organization_code IS NOT NULL AND
		   p_bom_header_rec.common_organization_code <>
							FND_API.G_MISS_CHAR
		THEN
			l_bom_head_unexp_rec.common_organization_id :=
			Organization(  p_organization	=>
					     p_bom_header_rec.common_organization_code					     , x_err_text	=> l_err_text
				     );

			IF l_bom_head_unexp_rec.common_organization_id IS NULL
			THEN
				l_token_tbl(1).token_name:= 'ORGANIZATION_CODE';
				l_token_tbl(1).token_value :=
					p_bom_header_rec.common_organization_code;
				Error_Handler.Add_Error_Token
				(  p_mesg_token_tbl	=> l_Mesg_Token_Tbl
				 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
				 , p_Message_name	=>
							'BOM_COMMON_ORG_INVALID'
				 , p_token_tbl		=> l_token_tbl
				 );
				l_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
		ELSIF p_bom_header_rec.common_organization_code IS NULL AND
		      p_bom_header_rec.common_assembly_item_name IS NOT NULL
		THEN
			--
			-- If common organization code is not specified then
			-- use the current organization;similar to the form.
			--
			l_bom_head_unexp_rec.common_organization_id :=
				l_bom_head_unexp_rec.organization_id;
		END IF;

If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Common Org Converted . . .'); END IF;

		IF p_bom_header_rec.common_assembly_item_name IS NOT NULL AND
		   p_bom_header_rec.common_assembly_item_name <>
							FND_API.G_MISS_CHAR
		THEN
			l_bom_head_unexp_rec.common_assembly_item_id :=
			Assembly_Item
			(  p_assembly_item_name	=>
				p_bom_header_rec.common_assembly_item_name
         		 , p_organization_id	=>
				l_bom_head_unexp_rec.common_organization_id
         		 , x_err_text 		=> l_err_text
			 );
			IF l_bom_head_unexp_rec.common_assembly_item_id IS NULL
			THEN
				l_token_tbl(1).token_name :=
					'BOM_COMMON_ASSEMBLY_ITEM_NAME';
				l_token_tbl(2).token_value :=
				     p_bom_header_rec.common_assembly_item_name;
				Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_name       =>
                                                     'BOM_COMMON_ASSY_INVALID'
				 , p_token_tbl		=> l_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;
			ELSIF l_err_text IS NOT NULL AND
			      l_bom_head_unexp_rec.common_assembly_item_id
						IS NULL
			THEN
				 Error_Handler.Add_Error_Token
                                (  p_mesg_token_tbl     => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                                 , p_Message_text	=>
				'Unexpected Error ' || l_err_text || ' in ' ||
				G_PKG_NAME
                                 , p_token_tbl          => l_token_tbl
                                 );
                                l_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
			END IF;
		END IF;

If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converted common assembly name . . .'); end if;

		--
		-- Convert common org code and common assembly name information
		-- into common bill sequence_id
		--
		IF l_bom_head_unexp_rec.common_organization_id IS NOT NULL AND
		   l_bom_head_unexp_rec.common_assembly_item_id IS NOT NULL AND
		   l_bom_head_unexp_rec.common_organization_id <>
							FND_API.G_MISS_NUM AND
		   l_bom_head_unexp_rec.common_assembly_item_id <>
							FND_API.G_MISS_NUM
		THEN
      l_src_bill_sequence_id := Bill_Sequence_Id
                                                (  p_assembly_item_id	=>
                                                          l_bom_head_unexp_rec.common_assembly_item_id
                                                 , p_alternate_bom_code => p_bom_header_rec.alternate_bom_code
                                                 , p_organization_id	=>
                                                           l_bom_head_unexp_rec.common_organization_id
                                                 , x_err_text		=> l_err_text
                                                 );


      IF p_bom_header_Rec.enable_attrs_update = 'Y'
      THEN
         l_bom_head_unexp_rec.common_bill_sequence_id := l_bom_head_unexp_rec.bill_sequence_id;
         l_bom_head_unexp_rec.source_bill_sequence_id := l_src_bill_sequence_id;
      ELSE
         l_bom_head_unexp_rec.common_bill_sequence_id := l_src_bill_sequence_id;
         l_bom_head_unexp_rec.source_bill_sequence_id := l_src_bill_sequence_id;
      END IF;


      IF /*l_bom_head_unexp_rec.common_bill_sequence_id*/l_src_bill_sequence_id IS NULL
			THEN
				--
				-- Common bill sequence was not found
				--
				l_token_tbl.Delete;
				l_token_tbl(1).token_name :=
						'COMMON_ASSEMBLY_ITEM_NAME';
				l_token_tbl(1).token_value :=
				     p_bom_header_rec.common_assembly_item_name;
				l_token_tbl(2).token_name :=
						'COMMON_ORGANIZATION_CODE';
				l_token_tbl(2).token_value :=
				     p_bom_header_rec.common_organization_code;
				Error_Handler.Add_Error_Token
				(  p_message_name	=>
						'BOM_COMMON_BILL_SEQ_NOT_FOUND'
				 , p_token_tbl		=> l_token_tbl
				 , p_mesg_token_tbl	=> l_mesg_token_tbl
				 , x_mesg_token_tbl	=> l_mesg_token_tbl
				);
				l_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
		END IF;
If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converted common bill sequence id. . .'); end if;

    IF Bom_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Structure Type Name VID conversion . . . ');
    END IF;

    IF  ( p_bom_header_rec.structure_type_name IS NOT NULL AND
          p_bom_header_rec.structure_type_name <> FND_API.G_MISS_CHAR )
    THEN
      l_bom_head_unexp_rec.structure_type_id := Structure_Type
                                                  (   p_structure_type_name => p_bom_header_rec.structure_type_name
                                                    , x_err_text => l_err_text
                                                   );

      IF ( l_bom_head_unexp_rec.structure_type_id IS NULL )
      THEN
        Error_Handler.Add_Error_Token
          (   p_mesg_token_tbl	=> l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
            , p_Message_name	=> 'BOM_STRUCTURE_TYPE_INVALID'
            , p_token_tbl		=> l_token_tbl
          );

        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF; -- end if l_bom_head_unexp_rec.structure_type_id IS NULL
    END IF; -- end if p_bom_header_rec.structure_type_name IS NOT NULL

    If Bom_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Converted Structure Type ID . . . ');
    END IF;

		x_return_status := l_return_status;

If Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Return status of Header VID: ' || l_return_status ); end if;

		x_bom_head_unexp_rec := l_bom_head_unexp_rec;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END Bom_Header_VID;

	/*******************************************************************
	* Procedure	: Bom_Revision_UUI_To_UI2
	* Parameters IN	: Bom Revisions exposed Record
	*		  Bom Revisions unexposed record
	* Parameters OUT: Bom revisions unexposed record
	* 		  Message Token Table
	*		  Return Status
	* Purpose	: User Unique to Unique Index conversion will convert
	*		  convert the user friendly values for the primary key
	*		  of Revisions entity columns.
	*******************************************************************/
	PROCEDURE Bom_Revision_UUI_To_UI2
	(  p_bom_revision_rec   IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
	, p_bom_rev_unexp_rec   IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
	, x_bom_rev_unexp_rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
	, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, x_return_status       IN OUT NOCOPY VARCHAR2
	)
	IS
		l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_bom_rev_unexp_rec	Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type;
		l_err_text		VARCHAR2(2000);
	BEGIN
		x_bom_rev_unexp_rec := p_bom_rev_unexp_rec;
		l_bom_rev_unexp_rec := p_bom_rev_unexp_rec;

		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF p_bom_revision_rec.assembly_item_name IS NULL OR
		   p_bom_revision_rec.assembly_item_name = FND_API.G_MISS_CHAR
		THEN
			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_REV_ASSY_KEYCOL_NULL'
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		--
		-- Convert Assembly Item Name
		--

		g_Token_Tbl(1).Token_Name  := 'ASSEMBLY_ITEM_NAME';
        	g_Token_Tbl(1).Token_Value :=
					p_bom_revision_Rec.assembly_item_name;
        	g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
        	g_token_tbl(2).token_value :=
					p_bom_revision_Rec.organization_code;

        	l_bom_rev_unexp_rec.assembly_item_id :=
        	Revised_Item(  p_revised_item_num       =>
                                p_bom_revision_rec.assembly_item_name
                     	     ,  p_organization_id       =>
                                l_bom_rev_unexp_rec.organization_id
                    	     ,  x_err_text              => l_err_text
                    		 );

        	IF l_bom_rev_unexp_rec.assembly_item_id IS NULL
        	THEN
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_ASSEMBLY_ITEM_INVALID'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                	 );
                	x_Return_Status := FND_API.G_RET_STS_ERROR;
		END IF;

		x_bom_rev_unexp_rec := l_bom_rev_unexp_rec;

	END Bom_Revision_UUI_To_UI2;


	/*********************************************************************
	* Function	: Locator_Id
	* Returns	: NUMBER
	* Purpose	: Convert Location Name to locator_id. If the
	*		  conversion fails the function will return a NULL else
	*		  the locator_id. If an unexpected error is encountered
	*		  then the function will return an unexpected error.
	**********************************************************************/
	FUNCTION locator_id (p_location_name IN VARCHAR2,
			     p_organization_id IN NUMBER
			     )
	RETURN NUMBER
	IS
		supply_locator_id	NUMBER;
		ret_code		NUMBER;
		l_err_text		VARCHAR2(240);
	BEGIN
        /* Commented for Bug 2804151

        	ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                        	org_id => p_organization_id,
                        	flex_code => 'MTLL',
                        	flex_name => p_location_name,
                        	flex_id => supply_locator_id,
                        	set_id => -1,
                        	err_text => l_err_text);

       		IF (ret_code <> 0) THEN
       			RETURN NULL;
       		ELSE
			RETURN supply_locator_id;
       		END IF;
	*/
              Begin

                select inventory_location_id
                into   supply_locator_id
                from   mtl_item_locations_kfv
                where  concatenated_segments = p_location_name and
                       organization_id  = p_organization_id;

                RETURN supply_locator_id;

              Exception
                WHEN NO_DATA_FOUND Then
                  RETURN NULL;
              End;


	END locator_id;

/**************************************************************************
* Function      : Old_Component_Sequence
* Returns       : NUMBER
* Putpose       : Using the input parameters the function will retrieve the
*                 old component sequence id of the component and return.
*                 If the function fails to find a record then it will return
*                 a NULL value. In case of an unexpected error the function
*                 will return a missing value.
****************************************************************************/
	FUNCTION Old_Component_Sequence(  p_component_item_id   IN  NUMBER
                                , p_old_effective_date  IN  DATE
                                , p_old_op_seq_num      IN  NUMBER
                                , p_bill_sequence_id    IN  NUMBER
                                )
	RETURN NUMBER
	IS
		l_id                          NUMBER;
	BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN
	Error_Handler.Write_Debug('Old Operation: ' || to_char(p_old_op_seq_num));
	Error_Handler.Write_Debug('Bill Sequence: ' || to_char(p_bill_sequence_id));
	Error_Handler.Write_Debug('Old Effective: ' || to_char(p_old_effective_date));
END IF;

        	SELECT  component_sequence_id
          	INTO  l_id
          	FROM  bom_inventory_components
         	WHERE  component_item_id = p_component_item_id
         	  AND  bill_sequence_id  = p_bill_sequence_id
         	  AND  effectivity_date  = p_old_effective_date
         	  AND  operation_seq_num = p_old_op_seq_num;

        	RETURN l_id;

		EXCEPTION

    		WHEN NO_DATA_FOUND THEN
       	 		RETURN NULL;

    		WHEN OTHERS THEN
        		RETURN FND_API.G_MISS_NUM;

	END Old_Component_Sequence;


	/*****************************************************************
	*
	* Function Revised Item Sequence
	*
        * Following Revsied_Item_Sequence is moved to Engineering Space
        * by MK on 12/03/00
        *
	FUNCTION Revised_Item_Sequence
                              (  p_revised_item_id      IN   NUMBER
                               , p_change_notice        IN   VARCHAR2
                               , p_organization_id      IN   NUMBER
                               , p_new_item_revision    IN   VARCHAR2
                               , p_new_routing_revision IN   VARCHAR2
                               , p_effective_date       IN   DATE
                               , p_from_end_item_number IN   VARCHAR2 := NULL
                               )
	RETURN NUMBER
	IS
		l_id                          NUMBER;
	BEGIN

                -- Modified by MK on 11/02/00
                -- Modified by MK on 11/20/00
                -- Bug #1454568, User may set Miss Char to Primary Keys
                -- It will be regarded as Null
        	SELECT revised_item_sequence_id
          	INTO l_id
          	FROM Eng_revised_items
         	WHERE NVL(from_end_item_unit_number,FND_API.G_MISS_CHAR )
                                  = NVL(p_from_end_item_number, FND_API.G_MISS_CHAR)
                  AND NVL(new_item_revision, FND_API.G_MISS_CHAR) =
               	                	NVL(p_new_item_revision, FND_API.G_MISS_CHAR)
                  AND NVL(new_routing_revision, FND_API.G_MISS_CHAR) =
                                        NVL(p_new_routing_revision, FND_API.G_MISS_CHAR)
                  AND TRUNC(scheduled_date)  = TRUNC(p_effective_date )
                  AND change_notice     = p_change_notice
                  AND organization_id   = p_organization_id
                  AND revised_item_id   = p_revised_item_id ;


    		RETURN l_id;

		EXCEPTION

    		WHEN NO_DATA_FOUND THEN

        		RETURN NULL;

    		WHEN OTHERS THEN
        		RETURN FND_API.G_MISS_NUM;

	END Revised_Item_Sequence;
	******************************************************************/


	/*************************************************************
	* Function	: BillAndRevItemSeq
	* Parameters IN	: Revised Item Unique Key information
	* Parameters OUT: Bill Sequence ID
	* Returns	: Revised Item Sequence
	* Purpose	: Will use the revised item information to find the bill
	*		  sequence and the revised item sequence.
        * History       : Added p_new_routing_revsion and
        *                 p_from_end_item_number in argument
        *
        * Following Revsied_Item_Sequence is moved to Engineering Space
        * by MK on 12/03/00

	FUNCTION  BillAndRevItemSeq(  p_revised_item_id		IN  NUMBER
	               		    , p_item_revision		IN  VARCHAR2
		        	    , p_effective_date		IN  DATE
		        	    , p_change_notice		IN  VARCHAR2
			            , p_organization_id		IN  NUMBER
                                    , p_new_routing_revision    IN  VARCHAR2
                                    , p_from_end_item_number    IN  VARCHAR2 := NULL
         			    , x_Bill_Sequence_Id	IN OUT NOCOPY NUMBER
	             		    )
	RETURN NUMBER
	IS
		l_Bill_Seq	NUMBER;
		l_Rev_Item_Seq	NUMBER;
	BEGIN

                -- Modified by MK on 11/02/00
                -- Modified by MK on 11/20/00
                -- Bug #1454568, User may set Miss Char to Primary Keys
                -- It will be regarded as Null
		SELECT bill_sequence_id, revised_item_Sequence_id
	  	INTO l_Bill_Seq, l_Rev_Item_Seq
	  	FROM eng_revised_items
	 	WHERE NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                          =  NVL(p_from_end_item_number,FND_API.G_MISS_CHAR)
                  AND NVL(new_routing_revision,FND_API.G_MISS_CHAR)
                                          =  NVL(p_new_routing_revision,FND_API.G_MISS_CHAR)
	 	  AND NVL(new_item_revision, FND_API.G_MISS_CHAR)
                                          =  NVL(p_item_revision ,  FND_API.G_MISS_CHAR)
	 	  AND TRUNC(scheduled_date) 	 = TRUNC(p_effective_date)
	 	  AND change_notice		 = p_change_notice
	 	  AND organization_id		 = p_organization_id
                  AND revised_item_id            = p_revised_item_id ;


	 	x_Bill_Sequence_Id := l_Bill_Seq;
	 	RETURN l_Rev_Item_Seq;

		EXCEPTION
		WHEN OTHERS THEN
			x_Bill_Sequence_Id := NULL;
			RETURN NULL;
	END BillAndRevItemSeq;
	******************************************************************/


--  Substitute_Component

	FUNCTION Substitute_Component(p_substitute_component IN VARCHAR2,
			      p_organization_id IN NUMBER,
			      x_err_text IN OUT NOCOPY VARCHAR2 )
	RETURN NUMBER
	IS
	l_id                          NUMBER;
	ret_code		      NUMBER;
	BEGIN

    	/* 	ret_code := INVPUOPI.mtl_pr_parse_flex_name(
               		org_id => p_organization_id,
               		flex_code => 'MSTK',
               		flex_name => p_substitute_component,
               		flex_id => l_id,
               		set_id => -1,
               		err_text => x_err_text); */
   ret_code := parse_item_name(
                        org_id => p_organization_id,
                        item_name => p_substitute_component,
                        id => l_id,
                        err_text => x_err_text);
    		IF (ret_code <> 0) THEN
			RETURN NULL;
    		ELSE
			RETURN l_id;
    		END IF;

	END Substitute_Component;

	--  New_Sub_Comp

	FUNCTION New_Sub_Comp(p_new_sub_comp IN VARCHAR2,
		      p_organization_id IN NUMBER,
		      x_err_text IN OUT NOCOPY VARCHAR2 )
	RETURN NUMBER
	IS
		l_id                          NUMBER;
		ret_code		      NUMBER;
		l_err_text		      VARCHAR2(2000);
	BEGIN
    		ret_code := INVPUOPI.mtl_pr_parse_flex_name(
               		org_id => p_organization_id,
               		flex_code => 'MSTK',
               		flex_name => p_new_sub_comp,
               		flex_id => l_id,
               		set_id => -1,
               		err_text => x_err_text);

       		IF (ret_code <> 0) THEN
			RETURN NULL;
		ELSE
			RETURN l_id;
		END IF;

	END New_Sub_Comp;

	/*****************************************************************
	* Function	: Component_Sequence
	* Parameters IN	: Revised Component unique index information
	* Parameters OUT: Error Text
	* Returns	: Component_Sequence_Id
	* Purpose	: Function will query the component sequence id using
	*		  alternate unique key information. If unsuccessfull
	*		  function will return a NULL.
	********************************************************************/
	FUNCTION Component_Sequence(p_component_item_id IN NUMBER,
			    p_operation_sequence_num IN VARCHAR2,
			    p_effectivity_date       IN DATE,
			    p_bill_sequence_id       IN NUMBER,
                            p_from_unit_number       IN VARCHAR2 := NULL,
			    x_err_text IN OUT NOCOPY VARCHAR2 )
	RETURN NUMBER
	IS
		l_id                          NUMBER;
		ret_code		      NUMBER;
		l_err_text		      VARCHAR2(2000);
	BEGIN

		select component_sequence_id
		into   l_id
		from   bom_inventory_components
		where  bill_sequence_id = p_bill_sequence_id
		and    component_item_id = p_component_item_id
		and    operation_seq_num = p_operation_sequence_num
		and    effectivity_date = p_effectivity_date
                and
                       (p_from_unit_number IS NULL
                        or
                        p_from_unit_number = FND_API.G_MISS_CHAR
                        or
                        from_end_item_unit_number = p_from_unit_number);

    		RETURN l_id;

	EXCEPTION

    		WHEN OTHERS THEN
			RETURN NULL;

	END Component_Sequence;

	/*****************************************************************
	* Function	: Vendor_Id
	* Parameters IN	: Vendor Name
	* Parameters OUT:
	* Returns	: Vendor_Id
	* Purpose	: Function will query the vendor_id for the vendor
	*                 name passed and returns the same
	********************************************************************/
	FUNCTION Vendor_Id (p_Vendor_Name IN VARCHAR2)
	RETURN NUMBER
	IS
		l_id                          NUMBER;
	BEGIN

		select vendor_id
		into   l_id
		from   po_vendors
		where  vendor_name = p_Vendor_Name
		and    enabled_flag = 'Y'
		and    sysdate between nvl(start_date_active,sysdate-1) AND nvl(end_date_active,sysdate+1);

    		RETURN l_id;
	EXCEPTION
    		WHEN OTHERS THEN
			RETURN NULL;
	END Vendor_Id;

	/******************************************************************
	* Procedure	: Rev_Component_VID
	* Parameters IN	: Revised Component exposed column record
	*		  Revised component unexposed column record
	* Parameters OUT: Revised component unexposed column record after the
	*		  conversion
	* Purpose	: The procedure will convert the columns that need
	*		  value to id conversion by calling there respective
	*		  procedures.
	********************************************************************/
	PROCEDURE Rev_Component_VID
	(   x_Return_Status        IN OUT NOCOPY Varchar2
	 ,  x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 ,  p_Rev_Comp_Unexp_Rec    IN Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 ,  x_Rev_Comp_Unexp_Rec   IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 ,  p_Rev_Component_Rec     IN Bom_Bo_Pub.Rev_Component_Rec_Type
	) IS
		l_return_value	NUMBER;
		l_Return_Status VARCHAR2(1);
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_Token_Tbl		Error_Handler.Token_Tbl_Type;
		l_Rev_Comp_Unexp_Rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;

	BEGIN
	l_Return_Status := FND_API.G_RET_STS_SUCCESS;
	l_Rev_Comp_Unexp_Rec := p_Rev_Comp_Unexp_Rec;

	--
	-- Convert Location_Name to Location_Id
	--
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Executing Location Val-ID conversion . . .'); END IF;

	IF p_rev_component_rec.location_name IS NOT NULL AND
	   p_rev_component_rec.location_name <> FND_API.G_MISS_CHAR
	THEN
		l_Return_Value := Locator_Id
				  (  p_Location_name	=>
				     p_rev_component_rec.location_name
			     	   , p_organization_id =>
			       	     l_rev_comp_unexp_rec.organization_id
			     	   );
		IF l_Return_Value IS NULL THEN
			l_token_tbl(1).token_name  := 'LOCATION_NAME';
			l_token_tbl(1).token_value :=
				p_rev_component_rec.location_name;
			l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
                        l_token_tbl(2).token_value :=
                                p_rev_component_rec.component_item_name;

			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_LOCATION_NAME_INVALID'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> l_Token_Tbl
			 );
			l_Return_Status := FND_API.G_RET_STS_ERROR;
		ELSIF l_Return_Value = FND_API.G_MISS_NUM
		THEN
			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> NULL
			 , p_Message_Text	=>
			   'Unexpected error while converting location name'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_MEsg_Token_Tbl
			 );
			l_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
		ELSE
			l_Rev_Comp_Unexp_Rec.supply_locator_id :=
			l_Return_Value;
		END IF;
	END IF;

	--
	-- Using old_component information, get the old_component_sequence_id
	--
IF Bom_Globals.Get_Debug = 'Y' THEN
	Error_Handler.Write_Debug('Executing old_Comp_seqid Val-ID conversion . . .');
	Error_Handler.Write_Debug('Bill Sequence: ' || to_char(l_rev_comp_unexp_rec.bill_sequence_id));
END IF;


	IF p_Rev_Component_Rec.old_effectivity_date IS NOT NULL  AND
	   p_Rev_Component_Rec.old_effectivity_date <> FND_API.G_MISS_DATE AND
	   p_Rev_component_rec.old_operation_sequence_number IS NOT NULL AND
	   p_Rev_component_rec.old_operation_sequence_number <>
	   FND_API.G_MISS_NUM
	THEN
		l_Return_Value :=
		Old_Component_Sequence
		 (  p_component_item_id		=>
		    l_rev_comp_unexp_rec.component_item_id
               	  , p_old_effective_date		=>
		    p_rev_component_rec.old_effectivity_date
                  , p_old_op_seq_num		=>
		    p_rev_component_rec.old_operation_sequence_number
		  , p_bill_sequence_id    	=>
			l_rev_comp_unexp_rec.bill_sequence_id
                 );

		IF l_Return_Value IS NULL
		THEN
			l_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
			l_token_tbl(1).token_value :=
				p_rev_component_rec.component_item_name;
			l_token_tbl(2).token_name  := 'OLD_EFFECTIVITY_DATE';
			l_token_tbl(2).token_value :=
				p_rev_component_rec.old_effectivity_date;
			l_token_tbl(3).token_name  :=
				'OLD_OPERATION_SEQUENCE_NUMBER';
			l_token_tbl(3).token_value :=
			     p_rev_component_rec.old_operation_sequence_number;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_OLD_COMP_VID_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;
		ELSIF l_Return_Value = FND_API.G_MISS_NUM
		THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
			 , p_Message_Text	=>
			   'Unexpected Error while converting old_comp_seq_id'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;
		ELSE
			l_rev_comp_unexp_rec.old_component_sequence_id :=
			l_Return_Value;

-- dbms_output.put_line('Old Sequence: ' || to_char(l_return_value));

		END IF;
	END IF;

	--
	-- Get the Revised Item Sequence_Id using the revised item
	-- information when the calling object is ECO

-- dbms_output.put_line('Executing revised item seq Val-ID conversion . . .');
-- dbms_output.put_line('Revised item: ' ||
-- 		      to_char(l_rev_comp_unexp_rec.revised_item_id));
-- dbms_output.put_line('Item Revision: ' ||
-- 		      p_rev_component_rec.new_revised_item_revision);
-- dbms_output.put_line('Change Notice: ' || p_rev_component_rec.eco_name);

	IF Bom_Globals.Get_Bo_Identifier <> 'BOM'
	THEN

             NULL ;

        /* Following getting revised_item_sequence_id moved to Engineering
        -- space to resolve dependency.
        -- by MK on 12/03/00

        -- Modified by MK 11/02/00
	l_Return_Value := Revised_Item_Sequence
			  (  p_revised_item_id	=>
          			     l_rev_comp_unexp_rec.revised_item_id
                           , p_change_notice	=> p_rev_component_rec.eco_name
                           , p_organization_id	=>
			             l_rev_comp_unexp_rec.organization_id
                           , p_new_item_revision =>
			             p_rev_component_rec.new_revised_item_revision
                           , p_new_routing_revision =>
                                     p_rev_component_rec.new_routing_revision
                           , p_effective_date    =>
                                     p_rev_component_rec.start_effective_date
                           , p_from_end_item_number =>
                             p_rev_component_rec.from_end_item_unit_number
                           );


        IF l_Return_Value IS NULL
        THEN
        	Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISED_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        ELSIF l_Return_Value = FND_API.G_MISS_NUM
        THEN
              Error_Handler.Add_Error_Token
              (  p_Message_Name       => NULL
               , p_Message_Text       =>
                 'Unexpected Error while converting revised_item_sequence_id'
               , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , p_Token_Tbl          => l_Token_Tbl
              );
              l_Return_Status := FND_API.G_RET_STS_ERROR;
         ELSE
              l_rev_comp_unexp_rec.revised_item_sequence_id :=
              l_Return_Value;
-- dbms_output.put_line('Revised item sequence: ' || to_char(l_Return_Value));

         END IF;

        */  -- Comment out by MK on 12/03/00

	END IF;

	--
	-- Convert Suggested_Vendor_Name to Vendor_Id
	--

	IF p_rev_component_rec.Suggested_Vendor_Name IS NOT NULL AND
	   p_rev_component_rec.Suggested_Vendor_Name <> FND_API.G_MISS_CHAR
	THEN
		l_Return_Value := Vendor_Id
				  (  p_vendor_name	=>
				     p_rev_component_rec.Suggested_Vendor_Name
			     	   );
		IF l_Return_Value IS NULL THEN
			l_token_tbl(1).token_name  := 'VENDOR_NAME';
			l_token_tbl(1).token_value :=
				p_rev_component_rec.Suggested_Vendor_Name;

			Error_Handler.Add_Error_Token
			(  p_Message_Name	=> 'BOM_NEW_VENDOR_NAME'
			 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			 , p_Token_Tbl		=> l_Token_Tbl
			 );
		END IF;
		l_Rev_Comp_Unexp_Rec.vendor_id := l_Return_Value;
	END IF;

	 	x_return_status := l_Return_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('returning from comp vid with ' || l_Return_status); END IF;

	 	x_mesg_token_tbl := l_Mesg_Token_Tbl;
	 	x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;

	END Rev_Component_VID;

	/*****************************************************************
	* Procedure     : Rev_Component_UUI_To_UI
	* Parameters IN : Revised component exposed columns record
	*                 Revised component unexposed columns record
	* Parameters OUT: Revised component unexposed columns record after the
	*		  conversion
	*                 Mesg_Token_Tbl
	*                 Return_Status
	* Purpose       : This procedure will perform value to id conversion
	*		  for all the revised component columns that form the
	*		  unique key for this entity.
	*********************************************************************/
	PROCEDURE Rev_Component_UUI_To_UI
	(  p_rev_component_Rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_rev_comp_unexp_Rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , x_rev_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status      IN OUT NOCOPY VARCHAR2
	)
	IS
        	l_err_text      VARCHAR2(2000);
        	l_rev_comp_unexp_rec    Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
        	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
		l_Return_status		VARCHAR2(1);
	BEGIN
	l_rev_comp_unexp_rec := p_rev_comp_unexp_Rec;
	l_Return_status := FND_API.G_RET_STS_SUCCESS;

	/******************************************************
	--
	-- Verify that the unique key columns are not empty
	--
	********************************************************/
	IF p_rev_component_rec.component_item_name IS NULL OR
	   p_rev_component_rec.component_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RCOMP_NAME_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF p_rev_component_rec.revised_item_name IS NULL OR
	   p_rev_component_rec.revised_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RCOMP_RITEM_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF (p_rev_component_rec.transaction_type <> BOM_globals.G_OPR_CREATE) AND
       (p_rev_component_rec.operation_sequence_number IS NULL OR
	   p_rev_component_rec.operation_sequence_number = FND_API.G_MISS_NUM)
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RCOMP_OPSEQ_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF p_rev_component_rec.start_effective_date IS NULL OR
	   p_rev_component_rec.start_effective_date = FND_API.G_MISS_DATE
	THEN
		 Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RCOMP_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

	--
	-- If key columns are NULL, then return.
	--
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		x_Return_Status := FND_API.G_RET_STS_ERROR;
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                RETURN;
	END IF;

	/***********************************************************
	--
	-- Convert Component Item Name to Component Item ID
	--
	************************************************************/
	l_rev_comp_unexp_rec.component_item_id :=
	Component_Item(   p_organization_id	=>
				l_rev_comp_unexp_rec.organization_id
                        , p_component_item_num	=>
				p_rev_component_rec.component_item_name
                        , x_err_text		=> l_err_text
			);

	IF l_rev_comp_unexp_rec.component_item_id IS NULL
	THEN
		g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
		g_Token_Tbl(1).Token_Value :=
			p_rev_component_rec.component_item_name;
		g_Token_Tbl(2).Token_Name  := 'ORGANIZATION_CODE';
                g_Token_Tbl(2).Token_Value :=
                        p_rev_component_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_REVISED_COMP_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
		x_Return_Status := l_Return_Status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Returning from Rev_Component_UUI_To_UI with ' || l_Return_Status); END IF;

	END Rev_Component_UUI_To_UI;

	/*****************************************************************
	* Procedure	: Rev_Component_UUI_to_UI2
	* Purpose	: This procedure is similar to the UUI-UI conversion
	*		  procedure, except that the calling program will be
	*		  able to determine the scope of the Error.
	*		  This procedure will convert all those values which
	*		  will cause the siblings to error out.
	********************************************************************/
	PROCEDURE Rev_Component_UUI_to_UI2
	(  p_rev_component_rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_rev_comp_unexp_rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , x_rev_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_other_message	IN OUT NOCOPY VARCHAR2
	 , x_other_token_tbl	IN OUT NOCOPY Error_Handler.Token_Tbl_Type
	 , x_Return_Status	IN OUT NOCOPY VARCHAR2
	)
	IS
		l_return_status		VARCHAR2(1);
		l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_rev_comp_unexp_rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
					:= p_rev_comp_unexp_rec;
		l_err_text		VARCHAR2(2000);
	BEGIN

	--
	-- IF revised item key columns is NULL, then set the other
	-- message and return with an error.
	--
        IF (p_rev_component_rec.revised_item_name IS NULL OR
           p_rev_component_rec.revised_item_name = FND_API.G_MISS_CHAR)
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RCOMP_RITEM_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF p_rev_component_rec.start_effective_date IS NULL OR
           p_rev_component_rec.start_effective_date = FND_API.G_MISS_DATE
        THEN
                 Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RCOMP_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

        END IF;

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		x_return_status := l_return_status;
		x_other_message := 'BOM_REV_ITEM_KEY_NULL';
        	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
	END IF;

        /******************************************************
        --
        -- Convert Revised Item Name to Revised Item ID
        --
        ********************************************************/
	l_return_status := FND_API.G_RET_STS_SUCCESS;
        g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        g_Token_Tbl(1).Token_Value := p_rev_component_rec.revised_item_name;
	g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
	g_token_tbl(2).token_value := p_rev_component_rec.organization_code;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting assembly item ' || p_rev_component_rec.revised_item_name); END IF;

        l_rev_comp_unexp_rec.revised_item_id :=
        Revised_Item(  p_revised_item_num       =>
                                p_rev_component_rec.revised_item_name
                     ,  p_organization_id       =>
                                l_rev_comp_unexp_rec.organization_id
                     ,  x_err_text              => l_err_text
                     );


        IF l_rev_comp_unexp_rec.revised_item_id IS NULL OR
	   l_rev_comp_unexp_rec.revised_item_id = FND_API.G_MISS_NUM
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISED_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                l_Return_Status := FND_API.G_RET_STS_ERROR;

		/* Added this code segment (including RETURN) so there
		   is no error collection. UUI conversion code must exit
		   as soon as a conversion error occurs.
		   Fix added to all conversion error code from this point
		   on in this package
		-- Code added by AS on 03/22/99 to fix bug 853138
		*/

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
        	x_Return_Status := l_Return_Status;
		x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                x_other_token_tbl(1).token_value :=
			p_rev_component_rec.component_item_name;

        	RETURN;
	END IF;

       /* Set the system information record values for assembly_item_id
          and org_id. These values will be used for validating serial effective
          assemblies */

        Bom_Globals.Set_Org_Id (l_rev_comp_unexp_rec.organization_id);
        Bom_Globals.Set_Assembly_Item_Id (l_rev_comp_unexp_rec.revised_item_id);

        /****************************************************************
        --
        -- Using the revised item key information, get the bill_sequence_id
        -- and revised item sequence id
        --
        ****************************************************************/
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing UUI_UI2 for components and retrieving rev item seq id . . . '); END IF;

	IF Bom_Globals.Get_Bo_Identifier <> 'BOM'
	THEN
             NULL ;

             /* Following getting revised_item_sequence_id moved to Engineering
             -- space to resolve dependency.
             -- by MK on 12/03/00

        	l_rev_comp_unexp_rec.revised_item_sequence_id :=
                -- Modifed by MK 11/02/00
        	BillAndRevItemSeq(  p_revised_item_id   =>
                                         l_rev_comp_unexp_rec.revised_item_id
                                  , p_item_revision     =>
                                         p_rev_component_rec.new_revised_item_revision
                                  , p_effective_date    =>
                                         p_rev_component_rec.start_effective_date
                                  , p_change_notice     =>
                                         p_rev_component_rec.eco_name
                                  , p_organization_id   =>
                                         l_rev_comp_unexp_rec.organization_id
                                  , p_new_routing_revision =>
                                         p_rev_component_rec.new_routing_revision
                                  , p_from_end_item_number =>
                                         p_rev_component_rec.from_end_item_unit_number
                 		  , x_Bill_Sequence_Id  =>
                                         l_rev_comp_unexp_rec.bill_sequence_id
                                 );



        	IF l_rev_comp_unexp_rec.revised_item_Sequence_id IS NULL
        	THEN
                	g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                	g_Token_Tbl(1).Token_Value :=
                        	p_rev_component_rec.component_item_name;
                	g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                	g_Token_Tbl(2).Token_Value :=
                        	p_rev_component_rec.revised_item_name;
			g_token_tbl(3).token_name  := 'ECO_NAME';
			g_token_tbl(3).token_value :=
				p_rev_component_rec.eco_name;

                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_REV_SEQUENCE_NOT_FOUND'
                 	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, p_Token_Tbl          => g_Token_Tbl
                 	);
                	l_Return_Status := FND_API.G_RET_STS_ERROR;
                	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                	x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
                	x_Return_Status := l_Return_Status;
                	x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                	x_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                	x_other_token_tbl(1).token_value :=
                        	p_rev_component_rec.component_item_name;

			IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('And this call returned with ' || l_Return_Status); END IF;

                	RETURN;

        	END IF;
             */  -- Comment out by MK on 12/03/00

	ELSE
		--
		-- If the calling BO is BOM then get the bill sequence id
		--
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Getting bill_seq for assembly item ' || l_rev_comp_unexp_rec.revised_item_id); END IF;

		l_rev_comp_unexp_rec.bill_sequence_id :=
		    bill_sequence_id(p_assembly_item_id	=>
				      l_rev_comp_unexp_rec.revised_item_id,
				      p_organization_id	=>
				       l_rev_comp_unexp_rec.organization_id,
				      p_alternate_bom_code =>
					p_rev_component_rec.alternate_bom_code,
				      x_err_text	=> l_err_text
				      );

                IF l_rev_comp_unexp_rec.bill_Sequence_id IS NULL
                THEN
                        g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                        g_Token_Tbl(1).Token_Value :=
                                p_rev_component_rec.component_item_name;
                        g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value :=
                                p_rev_component_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_BOM_SEQUENCE_NOT_FOUND'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => g_Token_Tbl
                        );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
                        x_Return_Status := l_Return_Status;
                        x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                        x_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        x_other_token_tbl(1).token_value :=
                                p_rev_component_rec.component_item_name;
			RETURN;
		END IF;

	END IF;

	/* Get the BOM Implementation date */

	IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO
	THEN
	  l_rev_comp_unexp_rec.bom_implementation_date :=
			Get_BOM_Implementation_Date
			( p_bill_seq_id => l_rev_comp_unexp_rec.bill_Sequence_id);
	ELSE
	  l_rev_comp_unexp_rec.bom_implementation_date  := SYSDATE;
	END IF;

	Error_Handler.Write_Debug('BOM Implementation date is '||l_rev_comp_unexp_rec.bom_implementation_date);

	IF p_rev_component_rec.transaction_type IN
	   ( BOM_Globals.G_OPR_UPDATE, BOM_globals.G_OPR_DELETE,
	     BOM_Globals.G_OPR_CANCEL
	    ) AND
	   l_rev_comp_unexp_rec.bill_sequence_id IS NULL
        AND Bom_Globals.Get_Bo_Identifier <> Bom_Globals.G_ECO_BO -- Added by MK on 12/03/00
	THEN
		l_return_status := FND_API.G_RET_STS_ERROR;

                g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(1).Token_Value :=
                        p_rev_component_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_BILL_SEQUENCE_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
                x_Return_Status := l_Return_Status;
                x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                x_other_token_tbl(1).token_value :=
                        p_rev_component_rec.component_item_name;

                RETURN;
	END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing UUI_UI2 for components and retrieving enforce integer requirements code . . . '); END IF;

        IF p_rev_component_rec.enforce_int_requirements IS NOT NULL AND
           p_rev_component_rec.enforce_int_requirements <> FND_API.G_MISS_CHAR
	THEN
		l_rev_comp_unexp_rec.enforce_int_requirements_code :=
				Get_EnforceInteger_Code(
						p_enforce_integer => p_rev_component_rec.enforce_int_requirements);
		IF l_rev_comp_unexp_rec.enforce_int_requirements_code IS NULL AND
           	   l_rev_comp_unexp_rec.enforce_int_requirements_code = FND_API.G_MISS_NUM
        	THEN
                	g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                	g_Token_Tbl(1).Token_Value :=
                        	p_rev_component_rec.revised_item_name;
                	g_Token_Tbl(2).Token_Name  := 'ENFORCE_INTEGER';
                	g_Token_Tbl(2).Token_Value :=
                        	p_rev_component_rec.enforce_int_requirements;

                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_ENFORCE_INTCODE_NOTFOUND'
               		, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 	, p_Token_Tbl          => g_Token_Tbl
                 	);
                	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                	x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
                	x_Return_Status := l_Return_Status;
                	x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                	x_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                	x_other_token_tbl(1).token_value :=
                        	p_rev_component_rec.component_item_name;

                	RETURN;
        	END IF;
        END IF;


        	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_rev_comp_unexp_rec := l_rev_comp_unexp_rec;
		x_Return_Status := l_Return_Status;

	END Rev_Component_UUI_to_UI2;


	/******************************************************************
	* Procedure     : Sub_Component_UUI_To_UI
	* Parameters IN : Substitute component exposed columns record
	*                 Substitute component unexposed columns record
	* Parameters OUT: Substitute component unexposed columns record
	*                 Mesg_Token_Tbl
	*                 Return_Status
	* Purpose       : This procedure will perform val-id conversion for all
	*                 the Substitute component columns that form the unique
	*		  key for this entity.
	********************************************************************/
	PROCEDURE Sub_Component_UUI_To_UI
	(  p_sub_component_rec	IN  Bom_Bo_Pub.Sub_Component_Rec_Type
	 , p_sub_comp_unexp_rec IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
	 , x_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status      IN OUT NOCOPY VARCHAR2
	)
	IS
		l_sub_comp_unexp_rec	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_Err_Text		VARCHAR2(2000);
		l_return_status		VARCHAR2(1);
		l_token_tbl		Error_Handler.Token_Tbl_Type;
	BEGIN
	l_sub_comp_unexp_rec := p_sub_comp_unexp_rec;
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	/*************************************************************
	--
	-- Verify ACD Type is Add or Disable
	--
	*************************************************************/

	IF ( p_sub_component_rec.acd_type IS NULL OR
	     p_sub_component_rec.acd_type NOT IN (1, 3)
	    ) AND
	    Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
	THEN
		Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SBC_ACD_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
                x_Return_Status := l_Return_Status;
                RETURN;
	END IF;

	/*************************************************************
	--
	-- Verify that the substitute component unique key columns are
	-- not null
	--
	****************************************************************/
	IF p_sub_component_rec.substitute_component_name IS NULL OR
	   p_sub_component_rec.substitute_component_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_NAME_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;
	IF p_sub_component_rec.component_item_name IS NULL OR
	   p_sub_component_rec.component_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_RCOMP_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;
	IF p_sub_component_rec.revised_item_name IS NULL OR
	   p_sub_component_rec.revised_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_RITEM_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF p_sub_component_rec.operation_sequence_number IS NULL OR
	   p_sub_component_rec.operation_sequence_number = FND_API.G_MISS_NUM
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_OPSEQ_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF p_sub_component_rec.start_effective_date IS NULL OR
	   p_sub_component_rec.start_effective_date = FND_API.G_MISS_DATE
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

	--
	-- If key columns are NULL, then return.
	--
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;
		RETURN;
	END IF;

	/***************************************************************
	--
	-- Convert substitute item name to Substitute Item ID
	--
	****************************************************************/
	l_sub_comp_unexp_rec.substitute_component_id :=
	Substitute_Component(  p_substitute_component =>
				p_sub_component_rec.substitute_component_name
                        , p_organization_id	=>
				l_sub_comp_unexp_rec.organization_id
                        , x_err_text		=> l_err_text
			);
	IF l_sub_comp_unexp_rec.substitute_component_id IS NULL
	THEN
		g_Token_Tbl(1).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
		g_Token_Tbl(1).Token_Value :=
			p_sub_component_rec.substitute_component_name;
		g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
		g_token_tbl(2).token_value :=
			p_sub_component_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUBSTITUTE_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
		x_return_Status	:= l_return_status;

	/********************************************************************
	-- If Transaction Type is Update and New substitute component is given,
	-- Convert New substitute item name to New Substitute Item ID
	--
	*********************************************************************/

       IF ( p_Sub_Component_Rec.new_substitute_component_name is not null
	   AND p_sub_component_rec.substitute_component_name <> FND_API.G_MISS_CHAR
            and p_sub_component_rec.transaction_type = Bom_Globals.G_OPR_UPDATE)
	THEN
	l_sub_comp_unexp_rec.new_substitute_component_id :=
	Substitute_Component(  p_substitute_component =>
				p_sub_component_rec.new_substitute_component_name
                        , p_organization_id	=>
				l_sub_comp_unexp_rec.organization_id
                        , x_err_text		=> l_err_text
			);
	IF l_sub_comp_unexp_rec.new_substitute_component_id IS NULL
	THEN
		g_Token_Tbl(1).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
		g_Token_Tbl(1).Token_Value :=
			p_sub_component_rec.new_substitute_component_name;
		g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
		g_token_tbl(2).token_value :=
			p_sub_component_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUBSTITUTE_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
	END IF;

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
		x_return_Status	:= l_return_status;
     END IF;

END Sub_Component_UUI_To_UI;

/**************************************************************************
* Procedure	: Sub_Component_UUI_To_UI2
* Purpose	: This procedure is similar to the UUI-UI conversion
*		  The only reason that this procedure is seperated is that
*		  the calling program will be able to distinguish between
*		  the scope of the error when conversion in this procedure
*		  fail and would then error all the siblings.
***************************************************************************/
PROCEDURE Sub_Component_UUI_To_UI2
(  p_sub_component_rec  IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_other_message	IN OUT NOCOPY VARCHAR2
 , x_other_token_tbl	IN OUT NOCOPY Error_Handler.Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
)
IS
        l_sub_comp_unexp_rec    Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Err_Text              VARCHAR2(2000);
        l_return_status		      VARCHAR2(1);
        l_dummy                 NUMBER;
BEGIN
        l_sub_comp_unexp_rec := p_sub_comp_unexp_rec;
        l_return_status := FND_API.G_RET_STS_SUCCESS;


	--
	-- If any of the revised item key columns are NULL, then
	-- return with an other message
	--
        IF p_sub_component_rec.revised_item_name IS NULL OR
           p_sub_component_rec.revised_item_name = FND_API.G_MISS_CHAR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_RITEM_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        --
        -- If key any of the parent key columns are NULL, then return.
        --
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                x_return_status  := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;
		x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
                x_other_message  := 'BOM_REV_ITEM_KEY_NULL';
                RETURN;
        END IF;

        IF p_sub_component_rec.component_item_name IS NULL OR
           p_sub_component_rec.component_item_name = FND_API.G_MISS_CHAR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_RCOMP_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF p_sub_component_rec.operation_sequence_number IS NULL OR
           p_sub_component_rec.operation_sequence_number = FND_API.G_MISS_NUM
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_OPSEQ_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF p_sub_component_rec.start_effective_date IS NULL OR
           p_sub_component_rec.start_effective_date = FND_API.G_MISS_DATE
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SCOMP_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

	--
	-- If any of the revised component key columns are NULL, then
	-- return with an other message.
	--
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                x_return_status  := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;
                x_other_message  := 'BOM_REV_COMP_KEY_NULL';
                RETURN;
	END IF;

        /****************************************************************
        --
        -- Convert revised item name to revised item ID
        --
        ******************************************************************/
	g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        g_Token_Tbl(1).Token_Value := p_sub_component_rec.revised_item_name;
        g_Token_Tbl(1).Token_Name  := 'ORGANIZATION_CODE';
        g_Token_Tbl(1).Token_Value := p_sub_component_rec.organization_code;

-- dbms_output.put_line('Revised Item: ' || p_sub_component_rec.revised_item_name);

        l_sub_comp_unexp_rec.revised_item_id :=
        Revised_Item(  p_revised_item_num       =>
                                p_sub_component_rec.revised_item_name
                     ,  p_organization_id       =>
                                l_sub_comp_unexp_rec.organization_id
                     ,  x_err_text              => l_err_text
                     );

        IF l_sub_comp_unexp_rec.revised_item_id IS NULL
        THEN
                g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(1).Token_Value :=
                        p_sub_component_rec.revised_item_name;
                g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                g_token_tbl(2).token_value :=
                        p_sub_component_rec.organization_code;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISED_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
		--
		-- Set the other message and its tokens
		--
		x_other_message := 'BOM_SBC_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
				p_sub_component_rec.substitute_component_name;

                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;

        /***********************************************************
        --
        -- Convert Component Item Name to Component Item ID
        --
        ************************************************************/
        l_sub_comp_unexp_rec.component_item_id :=
        Component_Item(   p_organization_id     =>
                                l_sub_comp_unexp_rec.organization_id
                        , p_component_item_num  =>
                                p_sub_component_rec.component_item_name
                        , x_err_text            => l_err_text
                        );

        IF l_sub_comp_unexp_rec.component_item_id IS NULL
        THEN
                g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                g_Token_Tbl(1).Token_Value :=
                        p_sub_component_rec.component_item_name;
		g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
		g_token_tbl(2).token_value :=
			p_sub_component_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_REVISED_COMP_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
                --
                -- Set the other message and its tokens
                --
                x_other_message := 'BOM_SBC_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
                                p_sub_component_rec.substitute_component_name;

                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;


        /****************************************************************
        --
        -- Convert revised item information to bill_sequence_id
        --
        *****************************************************************/
/*
dbms_output.put_line('Revised  Id: ' || l_sub_comp_unexp_rec.revised_item_id);
dbms_output.put_line('Component Id: '|| l_sub_comp_unexp_rec.component_item_id);
dbms_output.put_line('Rev: ' || p_sub_component_rec.new_revised_item_revision);
dbms_output.put_line('Eff.Date: ' || p_sub_component_rec.start_effective_date);
*/
	IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
	THEN
             NULL ;

             /* Following getting revised_item_sequence_id moved to Engineering
             -- space to resolve dependency.
             -- by MK on 12/03/00

        	l_sub_comp_unexp_rec.revised_item_sequence_id :=
                -- Modifed by MK 11/02/00
        	BillAndRevItemSeq(  p_revised_item_id   =>
                                       l_sub_comp_unexp_rec.revised_item_id
                                  , p_item_revision     =>
                                       p_sub_component_rec.new_revised_item_revision
                                  , p_effective_date    =>
                                       p_sub_component_rec.start_effective_date
                                  , p_change_notice     =>
                                       p_sub_component_rec.eco_name
                                  , p_organization_id   =>
                                       l_sub_comp_unexp_rec.organization_id
                                  , p_new_routing_revision =>
                                       p_sub_component_rec.new_routing_revision
                                  , p_from_end_item_number =>
                                       p_sub_component_rec.from_end_item_unit_number
                                  , x_Bill_Sequence_Id  =>
                                       l_sub_comp_unexp_rec.bill_sequence_id
                                  );



        	IF l_sub_comp_unexp_rec.revised_item_Sequence_id IS NULL
        	THEN
                	g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                	g_Token_Tbl(1).Token_Value :=
                        p_sub_component_rec.component_item_name;
                	g_Token_Tbl(2).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
                	g_Token_Tbl(2).Token_Value :=
                        p_sub_component_rec.substitute_component_name;
			g_token_tbl(3).token_name  := 'ECO_NAME';
			g_token_tbl(3).token_value :=
			p_sub_component_rec.eco_name;
                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_SBC_REV_SEQ_NOT_FOUND'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
			 );
			l_Return_Status := FND_API.G_RET_STS_ERROR;
                	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                	x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
                	--
                	-- Set the other message and its tokens
                	--
                	x_other_message := 'BOM_SBC_UUI_SEV_ERROR';
                	x_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                	x_other_token_tbl(1).token_value :=
                                p_sub_component_rec.substitute_component_name;

                	x_Return_Status := l_Return_Status;
                	RETURN;
		END IF;

                */ -- Comment out by MK on 12/03/00

	   ELSE
	        --
                -- If the calling BO is BOM then get the bill sequence id
                --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Getting bill_seq for assembly item ' || l_sub_comp_unexp_rec.revised_item_id); END IF;

                l_sub_comp_unexp_rec.bill_sequence_id :=
                    bill_sequence_id(p_assembly_item_id =>
                                      l_sub_comp_unexp_rec.revised_item_id,
                                      p_organization_id =>
                                       l_sub_comp_unexp_rec.organization_id,
                                      p_alternate_bom_code =>
                                        p_sub_component_rec.alternate_bom_code,
                                      x_err_text        => l_err_text
                                      );

                IF l_sub_comp_unexp_rec.bill_Sequence_id IS NULL
                THEN
                        g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                        g_Token_Tbl(1).Token_Value :=
                                p_sub_component_rec.component_item_name;
                        g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value :=
                                p_sub_component_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_BOM_SEQUENCE_NOT_FOUND'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => g_Token_Tbl
                        );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
                        x_Return_Status := l_Return_Status;
                        x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                        x_other_token_tbl(1).token_name := 'SUBSTITUTE_COMPONENT_NAME';
                        x_other_token_tbl(1).token_value :=
                                p_sub_component_rec.component_item_name;
                        RETURN;
                END IF;
-- 	END IF; -- If-Else BO Is ECO Ends -- Comment out by MK on 12/03/00

        /*****************************************************************
        --
        -- Convert component information to component_sequence_id
        --
        ******************************************************************/
/*
dbms_output.put_line('Bill Seq: ' ||
                to_char(l_sub_comp_unexp_rec.bill_sequence_id));
dbms_output.put_line('Op Seq: ' ||
                to_char(p_sub_component_rec.operation_sequence_number));
*/

        l_sub_comp_unexp_rec.component_sequence_id :=
        Component_Sequence(  p_component_item_id        =>
                                l_sub_comp_unexp_rec.component_item_id
                           , p_operation_sequence_num   =>
                                p_sub_component_rec.operation_sequence_number
                           , p_effectivity_date         =>
                                p_sub_component_rec.start_effective_date
                           , p_bill_sequence_id         =>
                                l_sub_comp_unexp_rec.bill_sequence_id
                           , x_err_text                 => l_Err_Text
                           );

if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Sub Comp:  Component sequence ' || l_sub_comp_unexp_rec.component_sequence_id); END IF;

        IF l_sub_comp_unexp_rec.component_sequence_id IS NULL
        THEN
                g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                g_Token_Tbl(1).Token_Value :=
                        p_sub_component_rec.component_item_name;
		g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(2).Token_Value :=
                        p_sub_component_rec.revised_item_name;
		g_Token_Tbl(3).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
                g_Token_Tbl(3).Token_Value :=
                        p_sub_component_rec.substitute_component_name;


                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SBC_COMP_SEQ_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                --
                -- Set the other message and its tokens
                --
                x_other_message := 'BOM_SBC_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
                                p_sub_component_rec.substitute_component_name;

                 l_Return_Status := FND_API.G_RET_STS_ERROR;
                 g_Token_Tbl.Delete;
        END IF;
 	END IF; -- If-Else BO Is ECO Ends -- Added by MK on 12/03/00

/*if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Sub Comp:  Checking for editable common bill...'); END IF;

BEGIN
  SELECT 1
  INTO l_dummy
  FROM bom_bill_of_materials
  WHERE bill_sequence_id = source_bill_sequence_id
  AND bill_sequence_id = l_sub_comp_unexp_rec.bill_Sequence_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Error_Handler.Add_Error_Token
    (  p_Message_Name       => 'BOM_COMMON_SUB_COMP'
    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , p_Token_Tbl          => g_Token_Tbl
    );
    l_Return_Status := FND_API.G_RET_STS_ERROR;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
    x_Return_Status := l_Return_Status;
    x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
    x_other_token_tbl(1).token_name := 'SUBSTITUTE_COMPONENT_NAME';
    x_other_token_tbl(1).token_value := p_sub_component_rec.component_item_name;
    RETURN;
END;

*/

if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Sub Comp:  Enforce Int Requirements  ' || p_sub_component_rec.enforce_int_requirements); END IF;

        IF p_sub_component_rec.enforce_int_requirements IS NOT NULL AND
           p_sub_component_rec.enforce_int_requirements <> FND_API.G_MISS_CHAR
        THEN

                l_sub_comp_unexp_rec.enforce_int_requirements_code :=
                                Get_EnforceInteger_Code(
                                                p_enforce_integer => p_sub_component_rec.enforce_int_requirements);

if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Sub Comp:  Enforce Int Requirements code ' || to_char(l_sub_comp_unexp_rec.enforce_int_requirements_code)); END IF;

                IF l_sub_comp_unexp_rec.enforce_int_requirements_code IS NULL AND
                   l_sub_comp_unexp_rec.enforce_int_requirements_code = FND_API.G_MISS_NUM
                THEN
                        g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                        g_Token_Tbl(1).Token_Value :=
                                p_sub_component_rec.component_item_name;
			g_Token_Tbl(2).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
                	g_Token_Tbl(2).Token_Value :=
                        	p_sub_component_rec.substitute_component_name;
                        g_Token_Tbl(3).Token_Name  := 'ENFORCE_INTEGER';
                        g_Token_Tbl(3).Token_Value :=
                                p_sub_component_rec.enforce_int_requirements;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_ENFORCE_INTCODE_NOTFOUND'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => g_Token_Tbl
                        );
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
                        x_Return_Status := l_Return_Status;
                        x_other_message := 'BOM_SBC_UUI_SEV_ERROR';
                        x_other_token_tbl(1).token_name := 'SUBSTITUTE_COMPONENT_NAME';
                        x_other_token_tbl(1).token_value :=
                                p_sub_component_rec.substitute_component_name;

                        RETURN;
                END IF;
        END IF;


        	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_sub_comp_unexp_rec := l_sub_comp_unexp_rec;
		x_return_status := l_return_status;

	END Sub_Component_UUI_To_UI2;

	/***************************************************************
	* Procedure	: Ref_Designator_UUI_To_UI
	* Parameters IN	: Reference Designator exposed column record
	*		  Reference designator unexposed column record
	* Parameters OUT: Reference Designator unxposed column record
	*		  Mesg Token Tbl
	*		  Return Status
	* Purpose	: This procedure will convert user unique idx columns
	*		  into unique id columns.
	********************************************************************/
	PROCEDURE Ref_Designator_UUI_To_UI
	(  p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
	 , p_ref_desg_unexp_rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
	 , x_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status      IN OUT NOCOPY VARCHAR2
	)
	IS
		l_ref_desg_unexp_rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_Err_Text		VARCHAR2(2000);
		l_Return_Status		VARCHAR2(1);
		l_token_tbl		Error_Handler.Token_Tbl_Type;

	BEGIN

	l_return_status := FND_API.G_RET_STS_SUCCESS;

	/***************************************************************
	--
	-- Verify that ACD_Type is Valid
	--
	****************************************************************/
	IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO AND
	   (  p_ref_designator_rec.acd_type IS NULL OR
              p_ref_designator_rec.acd_type NOT IN (1, 3)
	    )
        THEN
                --added for bug 9647673 (begin)
                l_token_tbl.delete;
                l_token_tbl(1).token_name  := 'REF_DESG_NAME';
                l_token_tbl(1).token_value := p_ref_designator_rec.Reference_Designator_Name;

                l_token_tbl(2).token_name  := 'COMP_ITEM_NAME';
                l_token_tbl(2).token_value := p_ref_designator_rec.Component_Item_Name;

                l_token_tbl(3).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(3).token_value := p_ref_designator_rec.Revised_Item_Name;

                l_token_tbl(4).token_name  := 'ACD_TYPE';
                l_token_tbl(4).token_value := p_ref_designator_rec.acd_type;

                --added for bug 9647673 (end)

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RFD_ACD_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl  --added for bug 9647673

                 );
                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;

	/****************************************************************
	--
	-- Convert revised item name to revised item ID
	--
	******************************************************************/

        g_Token_Tbl(1).Token_Name  := 'REV_ITEM';
        g_Token_Tbl(1).Token_Value := p_ref_designator_rec.revised_item_name;
	l_ref_desg_unexp_rec	   := p_ref_desg_unexp_rec;

        /*************************************************************
        --
        -- Verify that the reference designator unique key columns are
        -- not null
        --
        ****************************************************************/
        IF p_ref_designator_rec.reference_designator_name IS NULL OR
           p_ref_designator_rec.reference_designator_name = FND_API.G_MISS_CHAR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_NAME_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_ref_designator_rec.component_item_name IS NULL OR
           p_ref_designator_rec.component_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_RCOMP_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_ref_designator_rec.revised_item_name IS NULL OR
           p_ref_designator_rec.revised_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_RITEM_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_ref_designator_rec.operation_sequence_number IS NULL OR
           p_ref_designator_rec.operation_sequence_number = FND_API.G_MISS_NUM
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_OPSEQ_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_ref_designator_rec.start_effective_date IS NULL OR
           p_ref_designator_rec.start_effective_date = FND_API.G_MISS_DATE
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

	--
	-- If key columns are NULL then return
	--
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;
		RETURN;
	END IF;

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
		x_Return_Status := l_Return_Status;

	END Ref_Designator_UUI_To_UI;

	/****************************************************************
	* Procedure	: Ref_Designator_UUI_To_UI2
	* Purpose	: This procedure is similar to the UUI-UI. The calling
	*		  program can decide on the scope of the error if the
	*		  conversion in this procedure fails.
	******************************************************************/
	PROCEDURE Ref_Designator_UUI_To_UI2
	(  p_ref_designator_rec IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
	 , p_ref_desg_unexp_rec IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
	 , x_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_other_message	IN OUT NOCOPY VARCHAR2
	 , x_other_token_tbl	IN OUT NOCOPY Error_Handler.Token_Tbl_Type
	 , x_Return_Status      IN OUT NOCOPY VARCHAR2
	)
	IS
        	l_ref_desg_unexp_rec  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type :=
				p_ref_desg_unexp_rec;
        	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        	l_Err_Text              VARCHAR2(2000);
        	l_Return_Status         VARCHAR2(1);
          l_dummy                 NUMBER;
	BEGIN

	--
	-- If any of the revised item key columns are NULL, then set the
	-- other message and its token and return.
	--
        IF p_ref_designator_rec.revised_item_name IS NULL OR
           p_ref_designator_rec.revised_item_name = FND_API.G_MISS_CHAR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_RITEM_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

        END IF;

	--
	-- Return if revised item key is NULL
	--
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		x_return_status := l_return_status;
		x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
		x_mesg_token_tbl := l_mesg_token_tbl;
		x_other_message := 'BOM_REV_ITEM_KEY_NULL';
		RETURN;
	END IF;

        IF p_ref_designator_rec.component_item_name IS NULL OR
           p_ref_designator_rec.component_item_name = FND_API.G_MISS_CHAR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_RCOMP_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_ref_designator_rec.operation_sequence_number IS NULL OR
           p_ref_designator_rec.operation_sequence_number = FND_API.G_MISS_NUM
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_OPSEQ_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_ref_designator_rec.start_effective_date IS NULL OR
           p_ref_designator_rec.start_effective_date = FND_API.G_MISS_DATE
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RDESG_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        --
        -- If key columns are NULL then return
        --
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;
		x_other_message := 'BOM_REV_COMP_KEY_NULL';
		x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
                RETURN;
        END IF;

        l_ref_desg_unexp_rec.revised_item_id :=
        Revised_Item(  p_revised_item_num       =>
                                p_ref_designator_rec.revised_item_name
                     ,  p_organization_id       =>
                                l_ref_desg_unexp_rec.organization_id
                     ,  x_err_text              => l_err_text
                     );

        IF l_ref_desg_unexp_rec.revised_item_id IS NULL
        THEN
		g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        	g_token_tbl(1).token_value :=
					p_ref_designator_rec.revised_item_name;
        	g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
        	g_token_tbl(2).token_value :=
					p_ref_designator_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISED_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
		g_token_tbl.delete(2);

                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
		--
		-- Set the other message
		--
                x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                x_other_token_tbl(1).token_value :=
			p_ref_designator_rec.reference_designator_name;

                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;

        /***********************************************************
        --
        -- Convert Component Item Name to Component Item ID
        --
        ************************************************************/
        l_ref_desg_unexp_rec.component_item_id :=
        Component_Item(   p_organization_id     =>
                                l_ref_desg_unexp_rec.organization_id
                        , p_component_item_num  =>
                                p_ref_designator_rec.component_item_name
                        , x_err_text            => l_err_text
                        );

        IF l_ref_desg_unexp_rec.component_item_id IS NULL
        THEN

		g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
        	g_token_tbl(1).token_value :=
				p_ref_designator_rec.component_item_name;
        	g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
        	g_token_tbl(2).token_value :=
					p_ref_designator_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_REVISED_COMP_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
                --
                -- Set the other message
                --
                x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                x_other_token_tbl(1).token_value :=
                        p_ref_designator_rec.reference_designator_name;

                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;

        /****************************************************************
        --
        -- Convert revised item information to bill_sequence_id
        --
        *****************************************************************/
	IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
	THEN
             NULL ;

             /* Following getting revised_item_sequence_id moved to Engineering
             -- space to resolve dependency.
             -- by MK on 12/03/00

        	l_ref_desg_unexp_rec.revised_item_sequence_id :=
                -- Modified by MK 11/02/00
        	BillAndRevItemSeq(  p_revised_item_id   =>
                                        l_ref_desg_unexp_rec.revised_item_id
                                  , p_item_revision     =>
                                        p_ref_designator_rec.new_revised_item_revision
                                  , p_effective_date    =>
                                        p_ref_designator_rec.start_effective_date
                                  , p_change_notice     =>
                                        p_ref_designator_rec.eco_name
                                  , p_organization_id   =>
                                        l_ref_desg_unexp_rec.organization_id
                                  , p_new_routing_revision =>
                                        p_ref_designator_rec.new_routing_revision
                                  , p_from_end_item_number =>
                                        p_ref_designator_rec.from_end_item_unit_number
                                  , x_Bill_Sequence_Id  =>
                                        l_ref_desg_unexp_rec.bill_sequence_id
                                  );



        	IF l_ref_desg_unexp_rec.revised_item_Sequence_id IS NULL
        	THEN
                	g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                	g_Token_Tbl(1).Token_Value :=
                      	  p_ref_designator_rec.revised_item_name;
                	g_Token_Tbl(2).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
                	g_Token_Tbl(2).Token_Value :=
                        	p_ref_designator_rec.reference_designator_name;
			g_Token_Tbl(3).Token_Name  := 'ECO_NAME';
                	g_Token_Tbl(3).Token_Value :=
                        	p_ref_designator_rec.eco_name;

                	Error_Handler.Add_Error_Token
                	(  p_Message_Name       => 'BOM_RFD_REV_SEQ_NOT_FOUND'
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_Token_Tbl          => g_Token_Tbl
                 	);
			l_Return_Status := FND_API.G_RET_STS_ERROR;
                	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                	x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
                	--
                	-- Set the other message
                	--
                	x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
                	x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                	x_other_token_tbl(1).token_value :=
                        p_ref_designator_rec.reference_designator_name;

                	x_Return_Status := l_Return_Status;
                	RETURN;
		END IF;

             */ -- Comment out by MK on 12/03/00

	ELSE
                --
                -- If the calling BO is BOM then get the bill sequence id
                --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Getting bill_seq f
or assembly item ' || l_ref_desg_unexp_rec.revised_item_id); END IF;

                l_ref_desg_unexp_rec.bill_sequence_id :=
                    bill_sequence_id(p_assembly_item_id =>
                                      l_ref_desg_unexp_rec.revised_item_id,
                                      p_organization_id =>
                                       l_ref_desg_unexp_rec.organization_id,
                                      p_alternate_bom_code =>
                                        p_ref_designator_rec.alternate_bom_code,
                                      x_err_text        => l_err_text
                                      );
                IF l_ref_desg_unexp_rec.bill_Sequence_id IS NULL
                THEN
                        g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                        g_Token_Tbl(1).Token_Value :=
                                p_ref_designator_rec.component_item_name;
                        g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                        g_Token_Tbl(2).Token_Value :=
                                p_ref_designator_rec.revised_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_BOM_SEQUENCE_NOT_FOUND'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => g_Token_Tbl
                        );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
                        x_Return_Status := l_Return_Status;
                        x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                        x_other_token_tbl(1).token_name := 'SUBSTITUTE_COMPONENT_
NAME';
                        x_other_token_tbl(1).token_value :=
                                p_ref_designator_rec.component_item_name;
                        RETURN;
                END IF;
	-- END IF;   -- Comment out by MK on 12/04/00
	-- if ECO BO or BOM BO Ends

	--
	-- Check Bill Sequence Id is found
	--
	IF l_ref_desg_unexp_rec.bill_sequence_id IS NULL
        THEN
                g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(1).Token_Value :=
                        p_ref_designator_rec.revised_item_name;
                g_Token_Tbl(2).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
                g_Token_Tbl(2).Token_Value :=
                        p_ref_designator_rec.reference_designator_name;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RFD_BILL_SEQ_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
                --
                -- Set the other message
                --
                x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                x_other_token_tbl(1).token_value :=
                        p_ref_designator_rec.reference_designator_name;

                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;
	/*****************************************************************
        --
        -- Convert component information to component_sequence_id
        --
        ******************************************************************/

        l_ref_desg_unexp_rec.component_sequence_id :=
        Component_Sequence(  p_component_item_id        =>
                                l_ref_desg_unexp_rec.component_item_id
                           , p_operation_sequence_num   =>
                                p_ref_designator_rec.operation_sequence_number
                           , p_effectivity_date         =>
                                p_ref_designator_rec.start_effective_date
                           , p_bill_sequence_id         =>
                                l_ref_desg_unexp_rec.bill_sequence_id
                           , x_err_text                 => l_Err_Text
                           );
        IF l_ref_desg_unexp_rec.component_sequence_id IS NULL
        THEN
                g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(1).Token_Value :=
                        p_ref_designator_rec.revised_item_name;
                g_Token_Tbl(2).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
                g_Token_Tbl(2).Token_Value :=
                        p_ref_designator_rec.reference_designator_name;
                g_Token_Tbl(3).Token_Name  := 'REVISED_COMPONENT_NAME';
                g_Token_Tbl(3).Token_Value :=
                        p_ref_designator_rec.component_item_name;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RFD_COMP_SEQ_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                --
                -- Set the other message
                --
                x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                x_other_token_tbl(1).token_value :=
                        p_ref_designator_rec.reference_designator_name;

                 l_Return_Status := FND_API.G_RET_STS_ERROR;
                 g_Token_Tbl.Delete;
        END IF;
	END IF;   -- Added by MK on 12/04/00

/*if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Ref Desg:  Checking for editable common bill...'); END IF;

BEGIN
  SELECT 1
  INTO l_dummy
  FROM bom_bill_of_materials
  WHERE bill_sequence_id = source_bill_sequence_id
  AND bill_sequence_id = l_ref_desg_unexp_rec.bill_sequence_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Error_Handler.Add_Error_Token
    (  p_Message_Name       => 'BOM_COMMON_REF_DESG'
    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , p_Token_Tbl          => g_Token_Tbl
    );
    l_Return_Status := FND_API.G_RET_STS_ERROR;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
    x_Return_Status := l_Return_Status;
    x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
    x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
    x_other_token_tbl(1).token_value := l_ref_desg_unexp_rec.bill_sequence_id;
    RETURN;
END;
*/
        	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	x_ref_desg_unexp_rec := l_ref_desg_unexp_rec;
		x_Return_Status := l_Return_Status;

	END Ref_Designator_UUI_To_UI2;



	/*
	** Procedures used by BOM Business Object
	*/

	PROCEDURE Bom_Component_UUI_To_UI
        (  p_bom_component_Rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_bom_comp_unexp_Rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status      IN OUT NOCOPY VARCHAR2
        )
	IS
		l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
		l_rev_comp_unexp_rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
		l_bom_component_rec	Bom_Bo_Pub.Bom_Comps_Rec_Type;
	BEGIN

		--
		-- Convert the BOM Record to ECO
		--
		Bom_Bo_Pub.Convert_BomComp_To_EcoComp
		(  p_bom_component_rec	=> p_bom_component_rec
		 , p_bom_comp_unexp_rec	=> p_bom_comp_unexp_rec
		 , x_rev_component_rec	=> l_rev_component_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 );

		Bom_Val_To_Id.Rev_Component_UUI_To_UI
		(  p_rev_component_rec	=> l_rev_component_rec
		 , p_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , x_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		 , x_return_status	=> x_return_status
		 );

		--
		-- Convert the Eco Component back to BOM
		--
		Bom_Bo_Pub.Convert_EcoComp_To_BomComp
		(  p_rev_component_rec	=> l_rev_component_rec
		 , p_rev_comp_unexp_rec	=> l_rev_comp_unexp_rec
		 , x_bom_component_rec	=> l_bom_component_rec
		 , x_bom_comp_unexp_rec	=> x_bom_comp_unexp_rec
		 );

	END Bom_Component_UUI_To_UI;


	PROCEDURE Bom_Component_UUI_to_UI2
        (  p_Bom_component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_Bom_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_Bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_other_message      IN OUT NOCOPY VARCHAR2
         , x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
         , x_Return_Status      IN OUT NOCOPY VARCHAR2
        )
	IS
                l_rev_component_rec     Bom_Bo_Pub.Rev_Component_Rec_Type;
                l_rev_comp_unexp_rec    Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
                l_bom_component_rec     Bom_Bo_Pub.Bom_Comps_Rec_Type;
        BEGIN

                --
                -- Convert the BOM Record to ECO
                --
                Bom_Bo_Pub.Convert_BomComp_To_EcoComp
                (  p_bom_component_rec  => p_bom_component_rec
                 , p_bom_comp_unexp_rec => p_bom_comp_unexp_rec
                 , x_rev_component_rec  => l_rev_component_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 );

                Rev_Component_UUI_To_UI2
                (  p_rev_component_rec  => l_rev_component_rec
                 , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
		 , x_other_message	=> x_other_message
		 , x_other_token_tbl	=> x_other_token_tbl
                 , x_mesg_token_tbl     => x_mesg_token_tbl
                 , x_return_status      => x_return_status
                 );

                --
                -- Convert the Eco Component back to BOM
                --
                Bom_Bo_Pub.Convert_EcoComp_To_BomComp
                (  p_rev_component_rec  => l_rev_component_rec
                 , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 , x_bom_component_rec  => l_bom_component_rec
                 , x_bom_comp_unexp_rec => x_bom_comp_unexp_rec
                 );

	END Bom_Component_UUI_to_UI2;


	PROCEDURE Bom_Component_VID
	(  x_return_status      IN OUT NOCOPY VARCHAR2
	 , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 , p_bom_component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
	 , p_bom_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	)
	IS
                l_rev_component_rec     Bom_Bo_Pub.Rev_Component_Rec_Type;
                l_rev_comp_unexp_rec    Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
                l_bom_component_rec     Bom_Bo_Pub.Bom_Comps_Rec_Type;
        BEGIN

                --
                -- Convert the BOM Record to ECO
                --
                Bom_Bo_Pub.Convert_BomComp_To_EcoComp
                (  p_bom_component_rec  => p_bom_component_rec
                 , p_bom_comp_unexp_rec => p_bom_comp_unexp_rec
                 , x_rev_component_rec  => l_rev_component_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 );

                Rev_Component_VID
                (  p_rev_component_rec  => l_rev_component_rec
                 , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 , x_mesg_token_tbl     => x_mesg_token_tbl
                 , x_return_status      => x_return_status
                 );

                --
                -- Convert the Eco Component back to BOM
                --
                Bom_Bo_Pub.Convert_EcoComp_To_BomComp
                (  p_rev_component_rec  => l_rev_component_rec
                 , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 , x_bom_component_rec  => l_bom_component_rec
                 , x_bom_comp_unexp_rec => x_bom_comp_unexp_rec
                 );

	END Bom_Component_VID;

	PROCEDURE Sub_Component_UUI_To_UI
	( p_bom_sub_component_rec IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
	, p_bom_sub_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
	, x_bom_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
	, x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, x_Return_Status          IN OUT NOCOPY VARCHAR2
	)
	IS
		l_sub_component_rec	Bom_Bo_Pub.Sub_Component_Rec_Type;
		l_sub_comp_unexp_rec	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
		l_bom_sub_component_rec	Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
	BEGIN
		--
		-- Convert the BOM Substitute Component to ECO
		--

		Bom_Bo_Pub.Convert_BomSComp_To_EcoSComp
		(  p_bom_sub_component_rec	=> p_bom_sub_component_rec
		 , p_bom_sub_comp_unexp_rec	=> p_bom_sub_comp_unexp_rec
		 , x_sub_component_rec		=> l_sub_component_rec
		 , x_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
		 );

		-- Call the UUI Conversion routine

		Sub_Component_UUI_To_UI
		(  p_sub_component_rec	=> l_sub_component_rec
		 , p_sub_comp_unexp_rec	=> l_sub_comp_unexp_rec
		 , x_sub_comp_unexp_rec	=> l_sub_comp_unexp_rec
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		 , x_return_Status	=> x_return_status
		 );

		-- Convert the ECO Record back to BOM

		Bom_Bo_Pub.Convert_EcoSComp_to_BomSComp
		(  p_sub_component_rec	=> l_sub_component_rec
		 , p_sub_comp_unexp_rec	=> l_sub_comp_unexp_rec
		 , x_bom_sub_component_rec => l_bom_sub_component_rec
		 , x_bom_sub_comp_unexp_rec => x_bom_sub_comp_unexp_rec
		 );

	END Sub_Component_UUI_To_UI;

	PROCEDURE Sub_Component_UUI_To_UI2
	(  p_bom_sub_component_rec  IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
	 , p_bom_sub_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
	 , x_bom_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
	 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_other_message      IN OUT NOCOPY VARCHAR2
	 , x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
	 , x_Return_Status      IN OUT NOCOPY VARCHAR2
	)
	IS
                l_sub_component_rec     Bom_Bo_Pub.Sub_Component_Rec_Type;
                l_sub_comp_unexp_rec    Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
                l_bom_sub_component_rec Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
        BEGIN
                --
                -- Convert the BOM Substitute Component to ECO
                --

                Bom_Bo_Pub.Convert_BomSComp_To_EcoSComp
                (  p_bom_sub_component_rec      => p_bom_sub_component_rec
                 , p_bom_sub_comp_unexp_rec     => p_bom_sub_comp_unexp_rec
                 , x_sub_component_rec          => l_sub_component_rec
                 , x_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
                 );

                -- Call the UUI Conversion routine

                Sub_Component_UUI_To_UI2
                (  p_sub_component_rec  => l_sub_component_rec
                 , p_sub_comp_unexp_rec => l_sub_comp_unexp_rec
                 , x_sub_comp_unexp_rec => l_sub_comp_unexp_rec
		 , x_other_message	=> x_other_message
		 , x_other_token_tbl	=> x_other_token_tbl
                 , x_mesg_token_tbl     => x_mesg_token_tbl
                 , x_return_Status      => x_return_status
                 );

                -- Convert the ECO Record back to BOM

                Bom_Bo_Pub.Convert_EcoSComp_to_BomSComp
                (  p_sub_component_rec  => l_sub_component_rec
                 , p_sub_comp_unexp_rec => l_sub_comp_unexp_rec
                 , x_bom_sub_component_rec => l_bom_sub_component_rec
                 , x_bom_sub_comp_unexp_rec => x_bom_sub_comp_unexp_rec
                 );

	END Sub_Component_UUI_To_UI2;


	PROCEDURE Ref_Designator_UUI_To_UI
	(  p_bom_ref_designator_rec IN Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
	, p_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
	, x_bom_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
	, x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, x_Return_Status      IN OUT NOCOPY VARCHAR2
	)
	IS
		l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_Rec_Type;
		l_ref_desg_unexp_rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
		l_bom_ref_designator_rec Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
	BEGIN
		--
		-- Convert the BOM reference designator record to ECO
		--
		Bom_Bo_Pub.Convert_BomDesg_To_EcoDesg
		(  p_bom_ref_designator_rec	=> p_bom_ref_designator_rec
		 , p_bom_ref_desg_unexp_rec	=> p_bom_ref_desg_unexp_rec
		 , x_ref_designator_rec		=> l_ref_designator_rec
		 , x_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
		 );

		-- Call the Ref. Designator UUI Conversion

		Ref_Designator_UUI_To_UI
		(  p_ref_designator_rec	=> l_ref_designator_rec
		 , p_ref_desg_unexp_rec	=> l_ref_desg_unexp_rec
		 , x_ref_desg_unexp_rec	=> l_ref_desg_unexp_rec
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		 , x_return_status	=> x_return_status
		 );

		-- Convert the ECO Reference Designator back to BOM

		Bom_Bo_Pub.Convert_EcoDesg_To_BomDesg
		(  p_ref_designator_rec		=> l_ref_designator_rec
		 , p_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
		 , x_bom_ref_designator_rec	=> l_bom_ref_designator_rec
		 , x_bom_ref_desg_unexp_rec	=> x_bom_ref_desg_unexp_rec
		 );

	END Ref_Designator_UUI_To_UI;

	PROCEDURE Ref_Designator_UUI_To_UI2
	(  p_Bom_ref_designator_rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
	, p_Bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
	, x_Bom_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
	, x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	, x_other_message      IN OUT NOCOPY VARCHAR2
	, x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
	, x_Return_Status      IN OUT NOCOPY VARCHAR2
	)
	IS
                l_ref_designator_rec    Bom_Bo_Pub.Ref_Designator_Rec_Type;
                l_ref_desg_unexp_rec    Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
                l_bom_ref_designator_rec Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
        BEGIN
                --
                -- Convert the BOM reference designator record to ECO
                --
                Bom_Bo_Pub.Convert_BomDesg_To_EcoDesg
                (  p_bom_ref_designator_rec     => p_bom_ref_designator_rec
                 , p_bom_ref_desg_unexp_rec     => p_bom_ref_desg_unexp_rec
                 , x_ref_designator_rec         => l_ref_designator_rec
                 , x_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
                 );

                -- Call the Ref. Designator UUI Conversion

                Ref_Designator_UUI_To_UI2
                (  p_ref_designator_rec => l_ref_designator_rec
                 , p_ref_desg_unexp_rec => l_ref_desg_unexp_rec
                 , x_ref_desg_unexp_rec => l_ref_desg_unexp_rec
		 , x_other_message	=> x_other_message
		 , x_other_token_tbl	=> x_other_token_tbl
                 , x_mesg_token_tbl     => x_mesg_token_tbl
                 , x_return_status      => x_return_status
                 );

                -- Convert the ECO Reference Designator back to BOM

                Bom_Bo_Pub.Convert_EcoDesg_To_BomDesg
                (  p_ref_designator_rec         => l_ref_designator_rec
                 , p_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
                 , x_bom_ref_designator_rec     => l_bom_ref_designator_rec
                 , x_bom_ref_desg_unexp_rec     => x_bom_ref_desg_unexp_rec
                 );


	END Ref_Designator_UUI_To_UI2;

	/***************************************************************
	* Procedure	: Bom_Comp_Operation_UUI_To_UI
	* Parameters IN	: Component_Operation exposed column record
	*		  Component Operation unexposed column record
	* Parameters OUT: Component Operation unxposed column record
	*		  Mesg Token Tbl
	*		  Return Status
	* Purpose	: This procedure will convert user unique idx columns
	*		  into unique id columns.
	********************************************************************/
	PROCEDURE Bom_Comp_Operation_UUI_To_UI
	(  p_bom_comp_ops_rec	      IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
	 , p_bom_comp_ops_unexp_rec   IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
	 , x_bom_comp_ops_unexp_rec  IN OUT NOCOPY  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
	 , x_Mesg_Token_Tbl          IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status           IN OUT NOCOPY  VARCHAR2
	)
	IS
		l_bom_comp_ops_unexp_rec	Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type;
		l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_Err_Text		VARCHAR2(2000);
		l_Return_Status	VARCHAR2(1);
		l_token_tbl		Error_Handler.Token_Tbl_Type;
	BEGIN

	l_return_status := FND_API.G_RET_STS_SUCCESS;

	/****************************************************************
	--
	-- Convert assembly item name to assembly item ID
	--
	******************************************************************/

        g_Token_Tbl(1).Token_Name  := 'REV_ITEM';
        g_Token_Tbl(1).Token_Value := p_bom_comp_ops_rec.assembly_item_name;
	  l_bom_comp_ops_unexp_rec   := p_bom_comp_ops_unexp_rec;

        /*************************************************************
        --
        -- Verify that the component ooperation unique key columns are
        -- not null
        --
        ****************************************************************/
        IF p_bom_comp_ops_rec.operation_sequence_number IS NULL OR
           p_bom_comp_ops_rec.operation_sequence_number = FND_API.G_MISS_NUM
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_COPS_OPSEQ_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_bom_comp_ops_rec.additional_operation_seq_num IS NULL OR
           p_bom_comp_ops_rec.additional_operation_seq_num = FND_API.G_MISS_NUM
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_COPS_AOPSEQ_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_bom_comp_ops_rec.component_item_name IS NULL OR
           p_bom_comp_ops_rec.component_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_COPS_COMP_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_bom_comp_ops_rec.assembly_item_name IS NULL OR
           p_bom_comp_ops_rec.assembly_item_name = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_COPS_ITEM_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_bom_comp_ops_rec.organization_code IS NULL OR
           p_bom_comp_ops_rec.organization_code = FND_API.G_MISS_CHAR
	THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_COPS_ORG_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;

	END IF;

        IF p_bom_comp_ops_rec.start_effective_date IS NULL OR
           p_bom_comp_ops_rec.start_effective_date = FND_API.G_MISS_DATE
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_COPS_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

	--
	-- If key columns are NULL then return
	--
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;
		x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;
		RETURN;
	END IF;

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
		x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;
		x_Return_Status := l_Return_Status;


	END Bom_Comp_Operation_UUI_To_UI;

	/****************************************************************
	* Procedure	: Bom_Comp_Operation_UUI_To_UI2
	* Purpose	: This procedure is similar to the UUI-UI. The calling
	*		  program can decide on the scope of the error if the
	*		  conversion in this procedure fails.
	******************************************************************/
	PROCEDURE Bom_Comp_Operation_UUI_To_UI2
	(  p_bom_comp_ops_rec       IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
	 , p_bom_comp_ops_unexp_rec IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
	 , x_bom_comp_ops_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
	 , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_other_message	    IN OUT NOCOPY VARCHAR2
	 , x_other_token_tbl	    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
	 , x_Return_Status          IN OUT NOCOPY VARCHAR2
	)
	IS
        	l_bom_comp_ops_unexp_rec  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type :=
				p_bom_comp_ops_unexp_rec;
        	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        	l_Err_Text              VARCHAR2(2000);
        	l_Return_Status         VARCHAR2(1);
          l_dummy                 NUMBER;
	BEGIN


        l_bom_comp_ops_unexp_rec.assembly_item_id :=
        Revised_Item(  p_revised_item_num       =>
                                p_bom_comp_ops_rec.assembly_item_name
                     ,  p_organization_id       =>
                                p_bom_comp_ops_unexp_rec.organization_id
                     ,  x_err_text              => l_err_text
                     );

        IF l_bom_comp_ops_unexp_rec.assembly_item_id IS NULL
        THEN
		g_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
        	g_token_tbl(1).token_value :=
					p_bom_comp_ops_rec.assembly_item_name;
        	g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
        	g_token_tbl(2).token_value :=
					p_bom_comp_ops_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISED_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
		g_token_tbl.delete(2);

                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;
		--
		-- Set the other message
		--
                x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
			p_bom_comp_ops_rec.component_item_name;
                x_other_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
                x_other_token_tbl(2).token_value :=
			p_bom_comp_ops_rec.additional_operation_seq_num;

                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;

        /***********************************************************
        --
        -- Convert Component Item Name to Component Item ID
        --
        ************************************************************/
        l_bom_comp_ops_unexp_rec.component_item_id :=
        Component_Item(   p_organization_id     =>
                                l_bom_comp_ops_unexp_rec.organization_id
                        , p_component_item_num  =>
                                p_bom_comp_ops_rec.component_item_name
                        , x_err_text            => l_err_text
                        );

        IF l_bom_comp_ops_unexp_rec.component_item_id IS NULL
        THEN

		g_token_tbl(1).token_name  := 'REVISED_COMPONENT_NAME';
        	g_token_tbl(1).token_value :=
				p_bom_comp_ops_rec.component_item_name;
        	g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
        	g_token_tbl(2).token_value :=
					p_bom_comp_ops_rec.organization_code;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_REVISED_COMP_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );

                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;
                --
                -- Set the other message
                --
                x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
                        p_bom_comp_ops_rec.component_item_name;
                x_other_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
                x_other_token_tbl(2).token_value :=
			p_bom_comp_ops_rec.additional_operation_seq_num;

                x_Return_Status := l_Return_Status;
                RETURN;
        END IF;

        /****************************************************************
        --
        -- Convert revised item information to bill_sequence_id
        --
        *****************************************************************/
                --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Getting bill_seq f
or assembly item ' || l_bom_comp_ops_unexp_rec.assembly_item_id); END IF;

       l_bom_comp_ops_unexp_rec.bill_sequence_id :=
                    bill_sequence_id(p_assembly_item_id =>
                                      l_bom_comp_ops_unexp_rec.assembly_item_id,
                                      p_organization_id =>
                                       l_bom_comp_ops_unexp_rec.organization_id,
                                      p_alternate_bom_code =>
                                        p_bom_comp_ops_rec.alternate_bom_code,
                                      x_err_text        => l_err_text
                                      );

       IF l_bom_comp_ops_unexp_rec.bill_Sequence_id IS NULL
       THEN
       		g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                g_Token_Tbl(1).Token_Value :=
                                p_bom_comp_ops_rec.component_item_name;
                g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(2).Token_Value :=
                               p_bom_comp_ops_rec.assembly_item_name;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_BOM_SEQUENCE_NOT_FOUND'
                  , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  , p_Token_Tbl          => g_Token_Tbl
                 );

                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;

                x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
                                p_bom_comp_ops_rec.component_item_name;
                x_other_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
                x_other_token_tbl(2).token_value :=
			p_bom_comp_ops_rec.additional_operation_seq_num;
                x_Return_Status := l_Return_Status;
                RETURN;
       END IF;

/*if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Comp OP:  Checking for editable common bill...'); END IF;

      BEGIN
        SELECT 1
        INTO l_dummy
        FROM bom_bill_of_materials
        WHERE bill_sequence_id = source_bill_sequence_id
        AND bill_sequence_id = l_bom_comp_ops_unexp_rec.bill_Sequence_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_COMMON_COMP_OP'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => g_Token_Tbl
          );
          l_Return_Status := FND_API.G_RET_STS_ERROR;
          x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
          x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;
          x_Return_Status := l_Return_Status;
          x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
          x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
          x_other_token_tbl(1).token_value :=
                                p_bom_comp_ops_rec.component_item_name;
          x_other_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
          x_other_token_tbl(2).token_value := p_bom_comp_ops_rec.additional_operation_seq_num;
          RETURN;
      END;
*/
	/*****************************************************************
        --
        -- Convert component information to component_sequence_id
        --
        ******************************************************************/

       l_bom_comp_ops_unexp_rec.component_sequence_id :=
               Component_Sequence(  p_component_item_id        =>
                                l_bom_comp_ops_unexp_rec.component_item_id
                           , p_operation_sequence_num   =>
                                p_bom_comp_ops_rec.operation_sequence_number
                           , p_effectivity_date         =>
                                p_bom_comp_ops_rec.start_effective_date
                           , p_bill_sequence_id         =>
                                l_bom_comp_ops_unexp_rec.bill_sequence_id
                           , p_from_unit_number =>
                                p_bom_comp_ops_rec.from_end_item_unit_number
                           , x_err_text                 => l_Err_Text
                           );
       IF l_bom_comp_ops_unexp_rec.component_sequence_id IS NULL
       THEN
     		g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(1).Token_Value :=
                        p_bom_comp_ops_rec.assembly_item_name;
                g_Token_Tbl(2).Token_Name  := 'OPERATION_SEQUENCE_NUMBER';
                g_Token_Tbl(2).Token_Value :=
                        p_bom_comp_ops_rec.additional_operation_seq_num;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_COPS_COMP_SEQ_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );

                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;

                --
                -- Set the other message
                --
                x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
                        p_bom_comp_ops_rec.component_item_name;
                x_other_token_tbl(2).token_name := 'COMP_OPERATION_SEQ_NUM';
                x_other_token_tbl(2).token_value :=
			p_bom_comp_ops_rec.operation_sequence_number;

                g_Token_Tbl.Delete;
                x_Return_Status := l_Return_Status;
               RETURN;
        END IF;

	/*****************************************************************
        --
        -- Convert operation_seq_num information to operation_sequence_id
        --
        ******************************************************************/

        l_bom_comp_ops_unexp_rec.additional_operation_seq_id :=
           Operation_Sequence_Id(  p_organization_id        =>
                                      l_bom_comp_ops_unexp_rec.organization_id
                                   , p_assembly_item_id =>
                                      l_bom_comp_ops_unexp_rec.assembly_item_id
                                   , p_alternate_bom_designator =>
                                     p_bom_comp_ops_rec.alternate_bom_code
                                   , p_operation_sequence_number   =>
                                    p_bom_comp_ops_rec.additional_operation_seq_num
                                   , x_err_text                 => l_Err_Text
                                );
        IF l_bom_comp_ops_unexp_rec.additional_operation_seq_id IS NULL
        THEN
        	g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        	g_Token_Tbl(1).Token_Value :=
                        p_bom_comp_ops_rec.assembly_item_name;
        	g_Token_Tbl(2).Token_Name  := 'OPERATION_SEQUENCE_NUMBER';
        	g_Token_Tbl(2).Token_Value :=
                        p_bom_comp_ops_rec.additional_operation_seq_num;

        	Error_Handler.Add_Error_Token
        	(  p_Message_Name       => 'BOM_COPS_OPSEQID_NOT_FOUND'
          	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          	, p_Token_Tbl          => g_Token_Tbl
        	 );


                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;

        	--
         	-- Set the other message
         	--
         	x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
         	x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
                        p_bom_comp_ops_rec.component_item_name;
                x_other_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
                x_other_token_tbl(2).token_value :=
			p_bom_comp_ops_rec.additional_operation_seq_num;

        	g_Token_Tbl.Delete;
                x_Return_Status := l_Return_Status;

                RETURN;
        END IF;


        --bug 8850425 fix begin
        /*****************************************************************
        --
        -- Convert additional_operation_seq_num information to comp_operation_seq_id
        --
        ******************************************************************/
        IF(p_bom_comp_ops_rec.transaction_type IN (BOM_globals.G_OPR_UPDATE,
                                                   BOM_globals.G_OPR_DELETE)) THEN
        l_bom_comp_ops_unexp_rec.comp_operation_seq_id :=
           Comp_Operation_Seq_Id(  p_component_sequence_id        =>
                                     l_bom_comp_ops_unexp_rec.component_sequence_id
                                   , p_operation_sequence_number   =>
                                    p_bom_comp_ops_rec.additional_operation_seq_num
                                );

        IF l_bom_comp_ops_unexp_rec.comp_operation_seq_id IS NULL
        THEN
        	g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        	g_Token_Tbl(1).Token_Value :=
                        p_bom_comp_ops_rec.assembly_item_name;
        	g_Token_Tbl(2).Token_Name  := 'OPERATION_SEQUENCE_NUMBER';
        	g_Token_Tbl(2).Token_Value :=
                        p_bom_comp_ops_rec.additional_operation_seq_num;

        	Error_Handler.Add_Error_Token
        	(  p_Message_Name       => 'BOM_COPS_OPSEQID_NOT_FOUND'
          	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          	, p_Token_Tbl          => g_Token_Tbl
        	 );


                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;

        	--
         	-- Set the other message
         	--
         	x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
         	x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
          x_other_token_tbl(1).token_value :=  p_bom_comp_ops_rec.component_item_name;
          x_other_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
          x_other_token_tbl(2).token_value :=
			    p_bom_comp_ops_rec.additional_operation_seq_num;

        	g_Token_Tbl.Delete;
          x_Return_Status := l_Return_Status;

          RETURN;
        END IF;
       END IF;

          --bug 8850425 fix end


       	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
       	x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;
	      x_Return_Status := l_Return_Status;

	/*****************************************************************
        --
        -- Convert new_additional_operation_seq_num information to operation_sequence_id
        --
        ******************************************************************/
      If(p_bom_comp_ops_rec.transaction_type = BOM_globals.G_OPR_UPDATE  and
		p_bom_comp_ops_rec.new_additional_op_seq_num is not null and
                p_bom_comp_ops_rec.new_additional_op_seq_num <> FND_API.G_MISS_NUM) then

        l_bom_comp_ops_unexp_rec.new_additional_op_seq_id :=
           Operation_Sequence_Id(  p_organization_id        =>
                                      l_bom_comp_ops_unexp_rec.organization_id
                                   , p_assembly_item_id =>
                                      l_bom_comp_ops_unexp_rec.assembly_item_id
                                   , p_alternate_bom_designator =>
                                     p_bom_comp_ops_rec.alternate_bom_code
                                   , p_operation_sequence_number   =>
                                    p_bom_comp_ops_rec.new_additional_op_seq_num
                                   , x_err_text                 => l_Err_Text
                                );
        IF l_bom_comp_ops_unexp_rec.new_additional_op_seq_id IS NULL
        THEN
        	g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        	g_Token_Tbl(1).Token_Value :=
                        p_bom_comp_ops_rec.assembly_item_name;
        	g_Token_Tbl(2).Token_Name  := 'OPERATION_SEQUENCE_NUMBER';
        	g_Token_Tbl(2).Token_Value :=
                        p_bom_comp_ops_rec.new_additional_op_seq_num;

        	Error_Handler.Add_Error_Token
        	(  p_Message_Name       => 'BOM_COPS_OPSEQID_NOT_FOUND'
          	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         	 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          	, p_Token_Tbl          => g_Token_Tbl
        	 );


                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;

        	--
         	-- Set the other message
         	--
         	x_other_message := 'BOM_COPS_UUI2_SEV_ERROR';
         	x_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
                x_other_token_tbl(1).token_value :=
                        p_bom_comp_ops_rec.component_item_name;
                x_other_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
                x_other_token_tbl(2).token_value :=
			p_bom_comp_ops_rec.additional_operation_seq_num;

        	g_Token_Tbl.Delete;
                x_Return_Status := l_Return_Status;

                RETURN;
        END IF;
      End If;
       	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
       	x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_rec;
	x_Return_Status := l_Return_Status;

     END Bom_Comp_Operation_UUI_To_UI2;

function parse_item_name (org_id IN Number,
                        item_name IN Varchar2,
                        id OUT NOCOPY Number,
                        err_text out NOCOPY Varchar2) return Number
is
Begin

  select inventory_item_id into id from mtl_system_items_kfv
   where concatenated_segments = item_name
   and organization_id =org_id;
   return 0;
exception
 when others then
 err_text := substrb(sqlerrm,1000);
 return 1;
end;


END BOM_Val_To_Id;

/
