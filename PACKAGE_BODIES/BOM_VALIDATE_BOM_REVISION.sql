--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_BOM_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_BOM_REVISION" AS
/* $Header: BOMLREVB.pls 120.0 2005/05/25 04:57:08 appldev noship $ */
/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLCMPS.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Bom_Revision
--
--  NOTES
--
--  HISTORY
--
--  30-JUL-99 Rahul Chitko      Initial Creation
--
--  08-MAY-2001 Refai Farook    EAM related changes
--
**************************************************************************/

PROCEDURE Check_Entity
( x_return_status              IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_revision_rec           IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
, p_bom_rev_Unexp_Rec          IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
, p_old_bom_revision_Rec       IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
, p_old_bom_Rev_Unexp_Rec      IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
)
IS
	CURSOR c_Get_Revision IS
	SELECT revision, effectivity_date
	  FROM mtl_item_revisions
	 WHERE inventory_item_id = p_bom_rev_unexp_rec.assembly_item_id
	   AND organization_id = p_bom_rev_unexp_rec.organization_id
	 ORDER BY effectivity_date desc, revision desc;

	l_current_rev VARCHAR2(3);
        l_current_rev_date date;
	l_token_tbl	Error_Handler.Token_Tbl_Type;
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_dummy		NUMBER;
BEGIN
	--
	-- Check if the user has entered a revision that is greater than
	-- the most current revision. If not then it is an error
	--
	IF p_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE
	THEN
		OPEN c_Get_Revision;
		FETCH  c_Get_Revision INTO l_current_rev, l_current_rev_date;

		IF (l_current_rev is not null and
        	    p_bom_revision_rec.revision <= l_current_rev)

		THEN
			l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
			l_token_tbl(1).token_value :=
					p_bom_revision_rec.assembly_item_name;
			l_token_tbl(2).token_name := 'REVISION';
			l_token_tbl(2).token_value := p_bom_revision_rec.revision;
			l_token_tbl(3).token_name := 'CURRENT_REVISION';
			l_token_tbl(3).token_value := l_current_rev;

      			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'BOM_NEXT_REVISION'
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 , p_token_tbl		=> l_token_tbl
			 );
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;


		IF (Bom_Globals.get_caller_type()= 'MIGRATION' AND
                  NVL(p_bom_revision_rec.start_effective_date, SYSDATE) < l_current_rev_date  AND
		  NVL(p_bom_revision_rec.start_effective_date, SYSDATE) < SYSDATE )

		THEN

      			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'INV_ITM_REV_OUT_EFF_DATE'
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 , p_token_tbl		=> l_token_tbl
			 );
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;


		--
		-- If the user is attempting to create a new revision, then the
		-- bill for the item must exist for the user to be able to create a
		-- revision through BOM

		--
		-- If the user is attempting to create a new revision, then the
		-- bill for the item must exist for the user to be able to create a
		-- revision through BOM
		--
		BEGIN
                        SELECT 1
                        INTO   l_dummy
                        FROM   SYS.DUAL
                        WHERE  EXISTS ( SELECT bill_sequence_id
                                        FROM bom_bill_of_materials
                                        WHERE assembly_item_id
                                               = p_bom_rev_Unexp_Rec.assembly_item_id
                                        AND    organization_id
                                               = p_bom_rev_Unexp_Rec.organization_id
                                       ) ;


                        /* Comment out due to an error when the SQL return multiple rec.
                        SELECT bill_sequence_id
			  INTO l_dummy
          		  FROM bom_bill_of_materials
           		 WHERE assembly_item_id = p_bom_rev_Unexp_Rec.assembly_item_id
           		   AND organization_id  = p_bom_rev_Unexp_Rec.organization_id;
                        */

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					x_return_status := FND_API.G_RET_STS_ERROR;
					l_token_tbl(1).token_name :=
						'ASSEMBLY_ITEM_NAME';
					l_token_tbl(1).token_value :=
					  p_bom_revision_rec.assembly_item_name;
					Error_Handler.Add_Error_Token
					(  p_mesg_token_tbl	=> l_mesg_token_tbl
					  ,x_mesg_token_tbl	=> l_mesg_token_tbl
					  ,p_message_name	=> 'BOM_REV_BILL_MISS'
					  ,p_token_tbl		=> l_token_tbl
					 );

		END;
	END IF;

	-- If the user is attempting to create or update effective date of the
	-- revision and the date is less than the current date then it should get
	-- an error.
	--Error_Handler.Write_Debug( 'Current '||to_char(p_bom_revision_rec.start_effective_date));
	--Error_Handler.Write_Debug(' Old  '||to_char(p_old_bom_revision_rec.start_effective_date));
	--Error_Handler.Write_Debug(p_bom_revision_rec.transaction_type );
	IF (  p_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE AND
              Bom_Globals.get_caller_type()<> 'MIGRATION' AND             -- bug 2869453
	      NVL(p_bom_revision_rec.start_effective_date, SYSDATE) < SYSDATE
	    ) OR
	   (  p_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_UPDATE AND
	      p_old_bom_revision_Rec.start_effective_date <>
	      p_bom_revision_rec.start_effective_date AND
	      ( NVL(p_bom_revision_rec.start_effective_date,SYSDATE) < SYSDATE
	        OR p_old_bom_revision_Rec.start_effective_date < SYSDATE )
	   )
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		l_token_tbl(1).token_name := 'REVISION';
		l_token_tbl(1).token_value :=
				p_bom_revision_rec.revision;
		l_token_tbl(2).token_name := 'OLD_EFFECTIVE_DATE';
		l_token_tbl(2).token_value :=
				to_char(p_old_bom_revision_rec.start_effective_date);
		l_token_tbl(3).token_name := 'START_EFFECTIVE_DATE';
		l_token_tbl(3).token_value :=
				to_char(p_bom_revision_rec.start_effective_date);
		l_token_tbl(4).token_name := 'ASSEMBLY_ITEM_NAME';
		l_token_tbl(4).token_value := p_bom_revision_rec.assembly_item_name;
		Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_REV_START_DATE_LESS_CURR'
		 , p_mesg_token_tbl	=> l_mesg_token_tbl
		 , x_mesg_token_tbl	=> l_mesg_token_tbl
		 , p_token_tbl		=> l_token_tbl
		 );
	END IF;

	x_mesg_token_tbl := l_mesg_token_tbl;

END Check_Entity;

PROCEDURE Check_Required
( x_return_status              IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_revision_rec           IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
)
IS
BEGIN
	IF p_bom_revision_rec.revision IS NULL OR
	   p_bom_revision_rec.revision = FND_API.G_MISS_CHAR
	THEN
		Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_REVISION_REQUIRED'
		 , p_message_text	=> NULL
		 , x_mesg_token_tbl	=> x_mesg_token_tbl
		 );

		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

END Check_Required;


PROCEDURE Check_Existence
(  p_bom_revision_rec          IN  Bom_Bo_Pub.Bom_revision_Rec_Type
 , p_bom_rev_unexp_rec         IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_old_bom_revision_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Rec_Type
 , x_old_bom_rev_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status             IN OUT NOCOPY VARCHAR2
)
IS
	l_return_status	VARCHAR2(1);
	l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_token_tbl		Error_Handler.Token_Tbl_Type;
BEGIN
	Bom_Bom_Revision_Util.Query_Row
	 (  p_revision		=> p_bom_revision_rec.revision
 	  , p_assembly_item_id  => p_bom_rev_unexp_rec.assembly_item_id
	  , p_organization_id   => p_bom_rev_unexp_rec.organization_id
	  , x_bom_revision_rec  => x_old_bom_revision_rec
	  , x_bom_rev_unexp_rec => x_old_bom_rev_unexp_rec
	  , x_return_status	=> l_return_status
	  );


	l_token_tbl(1).token_name := 'REVISION';
	l_token_tbl(1).token_value := p_bom_revision_rec.revision;
	l_token_tbl(2).token_name := 'ASSEMBLY_ITEM_NAME';
	l_token_tbl(2).token_value := p_bom_revision_rec.assembly_item_name;

	IF l_return_status = Bom_Globals.G_RECORD_FOUND AND
	   p_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE
	THEN
		Error_Handler.Add_Error_Token
		(  p_message_name	=> 'BOM_REVISION_ALREADY_EXISTS'
		 , p_message_text	=> NULL
		 , p_token_tbl		=> l_token_tbl
		 , p_mesg_token_tbl	=> l_mesg_token_tbl
		 , x_mesg_token_tbl	=> l_mesg_token_tbl
		 );
		x_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF l_return_status = BOM_Globals.G_RECORD_NOT_FOUND AND
	      p_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
	THEN
		Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_REVISION_DOESNOT_EXIST'
                 , p_message_text       => NULL
                 , p_mesg_token_tbl     => l_mesg_token_tbl
		 , p_token_tbl		=> l_token_tbl
                 , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
                x_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_message_name       => NULL
                 , p_message_text       =>
                 	'Unexpected error while existence verification of ' ||
                 	'Item Revision '||
                 	p_bom_revision_rec.revision
                 , p_token_tbl          => l_token_tbl
                  );

		x_return_status := l_return_status;
        ELSE

                 /* Assign the relevant transaction type for SYNC operations */

                 IF p_bom_revision_rec.transaction_type = 'SYNC' THEN
                   IF l_return_status = Bom_Globals.G_RECORD_FOUND THEN
                     x_old_bom_revision_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_UPDATE;
                   ELSE
                     x_old_bom_revision_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_CREATE;
                   END IF;
                 END IF;
                 x_return_status := FND_API.G_RET_STS_SUCCESS;

	END IF;

	x_mesg_token_tbl := l_mesg_token_tbl;

END Check_Existence;

END Bom_Validate_Bom_Revision;

/
