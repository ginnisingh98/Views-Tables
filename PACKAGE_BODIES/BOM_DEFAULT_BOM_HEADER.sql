--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_BOM_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_BOM_HEADER" AS
/* $Header: BOMDBOMB.pls 120.2 2006/07/14 04:25:32 bbpatel noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDBOMB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Default_Bom_Header
--
--  NOTES
--
--  HISTORY
--  07-JUL-1999 Rahul Chitko    Initial Creation
--  13-JUL-06   Bhavnesh Patel  Added support for Structure Type
****************************************************************************/
	G_PKG_NAME      CONSTANT VARCHAR2(30) := 'Bom_Default_Bom_Header';


	/********************************************************************
	* Function      : Get_Bill_Sequence
	* Return        : NUMBER
	* Purpose       : Function will return the bill_sequence_id.
	*
	**********************************************************************/
	FUNCTION Get_Bill_Sequence
	RETURN NUMBER
	IS
		l_bill_sequence_id      NUMBER := NULL;
	BEGIN

    		SELECT bom_inventory_components_s.nextval
    	  	  INTO l_bill_sequence_id
    	  	  FROM sys.dual;

		RETURN l_bill_sequence_id;

		EXCEPTION

		WHEN OTHERS THEN
        		RETURN NULL;

	END Get_Bill_Sequence;

	PROCEDURE Get_Flex_Bom_Header
	  (  p_bom_header_rec IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	   , x_bom_header_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
	  )
	IS
	BEGIN

	    --  In the future call Flex APIs for defaults
		x_bom_header_rec := p_bom_header_rec;

		IF p_bom_header_rec.attribute_category =FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute_category := NULL;
		END IF;

		IF p_bom_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute2  := NULL;
		END IF;

		IF p_bom_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute3  := NULL;
		END IF;

		IF p_bom_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute4  := NULL;
		END IF;

		IF p_bom_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute5  := NULL;
		END IF;

		IF p_bom_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute7  := NULL;
		END IF;

		IF p_bom_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute8  := NULL;
		END IF;

		IF p_bom_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute9  := NULL;
		END IF;

		IF p_bom_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute11 := NULL;
		END IF;

		IF p_bom_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute12 := NULL;
		END IF;

		IF p_bom_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute13 := NULL;
		END IF;

		IF p_bom_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute14 := NULL;
		END IF;

		IF p_bom_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute15 := NULL;
		END IF;

		IF p_bom_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute1  := NULL;
		END IF;

		IF p_bom_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute6  := NULL;
		END IF;

		IF p_bom_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN
			x_bom_header_rec.attribute10 := NULL;
		END IF;

	END Get_Flex_Bom_Header;



	/*********************************************************************
	* Procedure     : Attribute_Defaulting
	* Parameters IN : Bom Header exposed record
	*                 Bom Header unexposed record
	* Parameters OUT: Bom Header exposed record after defaulting
	*                 Bom Header unexposed record after defaulting
	*                 Mesg_Token_Table
	*                 Return_Status
	* Purpose       : Attribute Defaulting will default the necessary null
	*		  attribute with appropriate values.
	**********************************************************************/
	PROCEDURE Attribute_Defaulting
	(  p_bom_header_rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_bom_head_unexp_rec	IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_bom_header_rec	IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
	 , x_bom_head_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_mesg_token_tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_return_status	IN OUT NOCOPY VARCHAR2
	 )
	IS
	  l_token_tbl	Error_Handler.Token_Tbl_Type;
	BEGIN

		x_bom_header_rec := p_bom_header_rec;
		x_bom_head_unexp_rec := p_bom_head_unexp_rec;
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF p_bom_head_unexp_rec.bill_sequence_id IS NULL OR
		   p_bom_head_unexp_rec.bill_sequence_id = FND_API.G_MISS_NUM
		THEN
			x_bom_head_unexp_rec.bill_sequence_id :=
				Get_Bill_Sequence;
		END IF;

		Get_Flex_Bom_Header(  p_bom_header_rec => p_bom_header_rec
				    , x_bom_header_rec => x_bom_header_rec
				    );

		 IF(x_bom_header_rec.assembly_type is null)
		 THEN
			SELECT decode(eng_item_flag, 'N', 1, 2)
                  	  INTO x_bom_header_rec.assembly_type
                  	  FROM mtl_system_items
                 	  WHERE inventory_item_id = p_bom_head_unexp_rec.assembly_item_id
                   	    AND organization_id   = p_bom_head_unexp_rec.organization_id;
		END IF;

	         -- Default implementation date.  for bug3550305
                 IF(x_bom_header_rec.bom_implementation_date is null)
                 THEN
                    x_bom_header_rec.bom_implementation_date := sysdate;
                 ELSIF (x_bom_header_rec.bom_implementation_date =
                                               FND_API.G_MISS_DATE) THEN
                     x_bom_header_rec.bom_implementation_date := null;
                 END IF;


		/* Get the structure type information */

		Error_Handler.Write_Debug ('Get the structure type id');
        BEGIN
      IF x_bom_head_unexp_rec.structure_type_id IS NULL THEN
		    SELECT structure_type_id,
               enable_unimplemented_boms
		    INTO x_bom_head_unexp_rec.structure_type_id,
             x_bom_head_unexp_rec.enable_unimplemented_boms
 		    FROM bom_alt_designators_val_v
		    WHERE ( (x_bom_header_rec.alternate_bom_code IS NULL AND
		          alternate_designator_code IS NULL
			  AND organization_id = -1)
			  OR
         (x_bom_header_rec.alternate_bom_code IS NOT NULL AND
          x_bom_header_rec.alternate_bom_code = alternate_designator_code AND
                            x_bom_head_unexp_rec.organization_id = organization_id)
             );
      ELSE
        SELECT  ENABLE_UNIMPLEMENTED_BOMS
        INTO    x_bom_head_unexp_rec.enable_unimplemented_boms
        FROM    BOM_ALT_DESIGNATORS_VAL_V
        WHERE ( (     x_bom_header_rec.alternate_bom_code IS NULL
                 AND  ALTERNATE_DESIGNATOR_CODE IS NULL
                 AND  ORGANIZATION_ID = -1 )
              OR
                (     x_bom_header_rec.alternate_bom_code IS NOT NULL
                AND   x_bom_header_rec.alternate_bom_code = ALTERNATE_DESIGNATOR_CODE
                AND   x_bom_head_unexp_rec.organization_id = ORGANIZATION_ID )
              );
      END IF; --end IF x_bom_head_unexp_rec.structure_type_id
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
-- This stage is reached only when the BO is called from EAM due to the VPD security policy.
-- If any new security policy is later on added, post 11.5.10... we need to get the correct
-- context here and then take care of selecting the correct structure_type_id
          IF x_bom_header_rec.alternate_bom_code IS NULL THEN
            SELECT structure_type_id, nvl(enable_unimplemented_boms, 'N')
             INTO x_bom_head_unexp_rec.structure_type_id,
                  x_bom_head_unexp_rec.enable_unimplemented_boms
             FROM bom_structure_types_b
             WHERE structure_type_name = 'Asset BOM';
          ELSE
            -- If we come here, then there is some other unexpected error
            -- The alternate code given is incorrect and is currently not being handled
            -- as any other error.
            x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
          END IF;
        END;

		/* If the structure allows unimplemented BOMS and the BO is for BOM
		   and also the assembly is ENGG, create the BOM as unimplemented BOM */

		Error_Handler.Write_Debug ('Checking for unimplemented BOM');
		IF x_bom_header_rec.bom_implementation_date IS NULL
		THEN
		  Error_Handler.Write_Debug ('IS NULL' || 'BO: ' || Bom_Globals.Get_Bo_Identifier || 'unimpl: ' || x_bom_head_unexp_rec.enable_unimplemented_boms || ' assembly type: ' || x_bom_header_rec.assembly_type);
		  IF x_bom_header_rec.assembly_type <> 2 OR
		   --Bom_Globals.Get_Bo_Identifier <> 'BOM' OR
		   x_bom_head_unexp_rec.enable_unimplemented_boms <> 'Y' THEN
                	l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                	l_token_tbl(1).token_value :=
                                x_bom_header_rec.assembly_item_name;
                	l_token_tbl(1).token_name := 'ALTERNATE';
                	l_token_tbl(1).token_value :=
                                x_bom_header_rec.alternate_bom_code;
                	Error_Handler.Add_Error_Token
                	( p_message_name       => 'BOM_CANNOT_CREATE_UNIMPBOM'
                	, p_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
                	, x_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
                	, p_Token_Tbl          => l_Token_Tbl
                 	);
                	x_return_status := FND_API.G_RET_STS_ERROR;
		  END IF;
          	END IF;
		Error_Handler.Write_Debug ('After the unimplemented check');

	END Attribute_Defaulting;

	/******************************************************************
	* Procedure	: Populate_Null_Columns
	* Parameters IN	: Bom Header Exposed column record
	*		  Bom Header Unexposed column record
	*		  Old Bom Header Exposed Column Record
	*		  Old Bom Header Unexposed Column Record
	* Parameters OUT: Bom Header Exposed column record after populating
	*		  Bom Header Unexposed Column record after  populating
	* Purpose	: This procedure will look at the columns that the user 	*		  has not filled in and will assign those columns a
	*		  value from the old record.
	*		  This procedure is not called CREATE
	********************************************************************/
	PROCEDURE Populate_Null_Columns
	(  p_bom_header_rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , p_old_bom_header_rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_old_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_bom_header_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , x_bom_head_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	)
	IS
	  l_bom_header_rec Bom_Bo_Pub.Bom_Head_Rec_Type;  -- Bug 4909882
	BEGIN
		x_bom_header_rec := p_bom_header_rec;
		x_bom_head_unexp_rec := p_bom_head_unexp_rec;

		/* Assign NULL if the values are MISSING */

                /* Bug 4909882. This should be called at the end after assigning
		   OLD values
		Get_Flex_Bom_Header(  p_bom_header_rec => p_bom_header_rec
				    , x_bom_header_rec => x_bom_header_rec
				    ); */

		/* Assign OLD values if the values are NULL */

		IF p_bom_header_rec.attribute_category IS NULL
		THEN
			x_bom_header_rec.attribute_category :=
				p_old_bom_header_rec.attribute_category;

		END IF;

                IF p_bom_header_rec.attribute2 IS NULL
		THEN
                        x_bom_header_rec.attribute2  :=
				p_old_bom_header_rec.attribute2;
                END IF;

                IF p_bom_header_rec.attribute3 IS NULL
		THEN
                        x_bom_header_rec.attribute3  :=
				p_old_bom_header_rec.attribute3;
                END IF;

                IF p_bom_header_rec.attribute4 IS NULL THEN
                        x_bom_header_rec.attribute4  :=
				p_old_bom_header_rec.attribute4;
                END IF;

                IF p_bom_header_rec.attribute5 IS NULL
		THEN
                        x_bom_header_rec.attribute5  :=
				p_old_bom_header_rec.attribute5;
                END IF;

                IF p_bom_header_rec.attribute7 IS NULL
		THEN
                        x_bom_header_rec.attribute7  :=
				p_old_bom_header_rec.attribute7;
                END IF;

                IF p_bom_header_rec.attribute8 IS NULL
		THEN
                        x_bom_header_rec.attribute8  :=
				p_old_bom_header_rec.attribute8;
                END IF;

                IF p_bom_header_rec.attribute9 IS NULL
		THEN
                        x_bom_header_rec.attribute9  :=
				p_old_bom_header_rec.attribute9;
                END IF;

                IF p_bom_header_rec.attribute11 IS NULL
		THEN
                        x_bom_header_rec.attribute11 :=
				p_old_bom_header_rec.attribute11;
                END IF;

                IF p_bom_header_rec.attribute12 IS NULL
		THEN
                        x_bom_header_rec.attribute12 :=
				p_old_bom_header_rec.attribute12;
                END IF;

                IF p_bom_header_rec.attribute13 IS NULL
		THEN
                        x_bom_header_rec.attribute13 :=
				p_old_bom_header_rec.attribute13;
                END IF;

                IF p_bom_header_rec.attribute14 IS NULL
		THEN
                        x_bom_header_rec.attribute14 :=
				p_old_bom_header_rec.attribute14;
                END IF;

                IF p_bom_header_rec.attribute15 IS NULL
		THEN
                        x_bom_header_rec.attribute15 :=
				p_old_bom_header_rec.attribute15;
                END IF;

                IF p_bom_header_rec.attribute1 IS NULL
		THEN
                        x_bom_header_rec.attribute1  :=
				p_old_bom_header_rec.attribute1;
                END IF;

                IF p_bom_header_rec.attribute6 IS NULL
		THEN
                        x_bom_header_rec.attribute6  :=
				p_old_bom_header_rec.attribute6;
                END IF;

                IF p_bom_header_rec.attribute10 IS NULL
		THEN
                        x_bom_header_rec.attribute10 :=
				p_old_bom_header_rec.attribute10;
                END IF;

                -- Bug 4909882
                l_bom_header_rec := x_bom_header_rec;
		Get_Flex_Bom_Header(  p_bom_header_rec => l_bom_header_rec
				    , x_bom_header_rec => x_bom_header_rec
				    );
                IF p_bom_header_rec.assembly_type = FND_API.G_MISS_NUM OR
		   p_bom_header_rec.assembly_type IS NULL
		THEN
                        x_bom_header_rec.assembly_type :=
				p_old_bom_header_rec.assembly_type;
                END IF;

                x_bom_header_rec.bom_implementation_date :=
				p_old_bom_header_rec.bom_implementation_date;
		 --
                -- Get the unexposed columns from the database and return
                -- them as the unexposed columns for the current record.
                --
                x_bom_head_unexp_rec.bill_sequence_id := p_old_bom_head_unexp_rec.bill_sequence_id;

              --structure type id can not be updated to null, so ignore FND_API.G_MISS_NUM
              IF (    p_bom_head_unexp_rec.structure_type_id IS NULL
                  OR  p_bom_head_unexp_rec.structure_type_id = FND_API.G_MISS_NUM )
              THEN
                x_bom_head_unexp_rec.structure_type_id :=
				                        p_old_bom_head_unexp_rec.structure_type_id;
              END IF;


	END Populate_Null_Columns;

END Bom_Default_Bom_Header;

/
