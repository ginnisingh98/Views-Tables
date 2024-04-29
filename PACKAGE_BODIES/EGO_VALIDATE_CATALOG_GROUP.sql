--------------------------------------------------------
--  DDL for Package Body EGO_VALIDATE_CATALOG_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_VALIDATE_CATALOG_GROUP" AS
/* $Header: EGOLCAGB.pls 120.1.12010000.1 2008/07/24 12:20:21 appldev ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOLCAGB.pls
--
--  DESCRIPTION
--
--      Body of package EGO_Validate_Catalog_Group
--
--  NOTES
--
--  HISTORY
--
--  20-SEP-2002		Rahul Chitko    Initial Creation
--  10-10-2002		Refai Farook	Added Check_Entity procedure
--  19-FEB-2003		Refai Farook	Inactive Date validations (Check_Attributes)
****************************************************************************/
        G_Pkg_Name      VARCHAR2(30) := 'EGO_Validate_Catalog_Group';
        g_token_tbl     Error_Handler.Token_Tbl_Type;


	/*******************************************************************
	* Procedure	: Check_Existence
	* Returns	: None
	* Purpose	:
	*********************************************************************/
        PROCEDURE Check_Existence
	(  x_Mesg_Token_Tbl         OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          OUT NOCOPY VARCHAR2
        )
	IS
        	l_token_tbl      Error_Handler.Token_Tbl_Type;
        	l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
        	l_return_status  VARCHAR2(1);
	BEGIN
		EGO_Catalog_Group_Util.Query_Row
		(
			x_mesg_token_tbl	=> l_mesg_token_tbl
		 ,	x_return_status		=> l_return_status
		 );
		 Error_Handler.Write_Debug('Query Row Returned with : ' || l_return_status);

		IF l_return_status = EGO_Globals.G_RECORD_FOUND AND
		   EGO_Globals.G_Catalog_Group_Rec.transaction_type = EGO_Globals.G_OPR_CREATE
		THEN
			l_token_tbl(1).token_name  := 'CATALOG_GROUP_NAME';
			l_token_tbl(1).token_value :=
					EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name;
			Error_Handler.Add_Error_Token
                	(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
			 , p_application_id     => 'EGO'
                 	 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 	 , p_message_name  => 'EGO_CATGRP_ALREADY_EXISTS'
                 	 , p_token_tbl     => l_token_tbl
                 	 );
			l_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF l_return_status = EGO_Globals.G_RECORD_NOT_FOUND AND
		      EGO_Globals.G_Catalog_Group_Rec.transaction_type IN
			 (EGO_Globals.G_OPR_UPDATE, EGO_Globals.G_OPR_DELETE)
		THEN
			l_token_tbl(1).token_name  := 'CATALOG_GROUP_NAME';
                        l_token_tbl(1).token_value :=
				EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name;
			Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
			 , p_application_id     => 'EGO'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name  => 'EGO_CATGRP_DOESNOT_EXIST'
                         , p_token_tbl     => l_token_tbl
                         );
			l_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
        	THEN
                	Error_Handler.Add_Error_Token
                	(  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
                	 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                	 , p_message_name       => NULL
			 , p_application_id     => 'EGO'
                	 , p_message_text       =>
                  	 'Unexpected error while existence verification of ' ||
                  	 'Catalog Group '|| EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name
                  	 , p_token_tbl          => l_token_tbl
                	 );
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	ELSE

                 /* Assign the relevant transaction type for SYNC operations */

                  IF EGO_Globals.G_Catalog_Group_Rec.transaction_type = 'SYNC' THEN
                    IF l_return_status = EGO_Globals.G_RECORD_FOUND THEN
                      EGO_Globals.G_Old_Catalog_Group_Rec.transaction_type :=
                                                   EGO_Globals.G_OPR_UPDATE;
                    ELSE
                      EGO_Globals.G_Old_Catalog_Group_Rec.transaction_type :=
                                                   EGO_Globals.G_OPR_CREATE;
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
	* Parameters OUT: Return Status
	*		  Message Token Table
	* Purpose	: Checks if the user has the necessary privilege
	*********************************************************************/
	PROCEDURE Check_Access
		  (  x_mesg_token_tbl	  OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
		   , x_return_status      OUT NOCOPY VARCHAR2
		   )
	IS
		l_return_status	   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
		l_Mesg_Token_Tbl   Error_Handler.Mesg_Token_Tbl_Type;
		l_token_tbl	   Error_Handler.Token_Tbl_Type;

	BEGIN
		/* Code to be added for proper data security checks. */

		x_return_status	  := l_return_status;
		x_mesg_token_tbl  := l_mesg_token_tbl;

		Error_Handler.Write_Debug('Check Access returning with ' || l_return_status );

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
	(  x_return_status           OUT NOCOPY VARCHAR2
	 , x_Mesg_Token_Tbl          OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	)
	IS
	l_err_text              VARCHAR2(2000) := NULL;
	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
	l_Token_Tbl             Error_Handler.Token_Tbl_Type;
	l_parent_inactive_date	DATE;

	BEGIN

    		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_id =
		    EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id
		   )
		THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'EGO_CATALOG_ID_SAMEAS_PARENT'
			 , p_application_id     => 'EGO'
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );
		END IF;

                IF EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id <> FND_API.G_MISS_NUM
                THEN

                  BEGIN
                        SELECT inactive_date INTO l_parent_inactive_date FROM mtl_item_catalog_groups_b
                         WHERE item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id;
                        EXCEPTION WHEN OTHERS THEN
                          x_return_status := FND_API.G_RET_STS_ERROR;
                          Error_Handler.Add_Error_Token
                          (  p_message_name     => 'EGO_CG_PARENT_NOT_FOUND'
                           , p_application_id     => 'EGO'
                           , x_mesg_token_tbl   => l_mesg_token_tbl
                           );
                  END;

                END IF;

		IF EGO_Globals.G_Catalog_Group_Rec.inactive_date IS NOT NULL AND
			EGO_Globals.G_Catalog_Group_Rec.inactive_date <> FND_API.G_MISS_DATE
		THEN

		  IF trunc(EGO_Globals.G_Catalog_Group_Rec.inactive_date) <>
				 trunc(nvl(EGO_Globals.G_Old_Catalog_Group_Rec.inactive_date,
					   EGO_Globals.G_Catalog_Group_Rec.inactive_date))
		  THEN

		    /* Inactive date should be greater than the current date */

		    IF trunc(EGO_Globals.G_Catalog_Group_Rec.inactive_date) < trunc(SYSDATE)
		    THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			Error_Handler.Add_Error_Token
			(  p_message_name	=> 'EGO_CG_ENDDATE_LESS_CURRDATE'
			 , p_application_id     => 'EGO'
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );
		    END IF;

		    /* Incative date cannnot be greater than the parent's inactive date */

		    IF nvl(l_parent_inactive_date,EGO_Globals.G_Catalog_Group_Rec.inactive_date) <
					EGO_Globals.G_Catalog_Group_Rec.inactive_date
		    THEN
			  x_return_status := FND_API.G_RET_STS_ERROR;
			  Error_Handler.Add_Error_Token
			  (  p_message_name	=> 'EGO_CG_ENDDATE_GREAT_PARENTDT'
			   , p_application_id     => 'EGO'
			   , x_mesg_token_tbl	=> l_mesg_token_tbl
			   );
		    END IF;

		  END IF;

		ELSIF EGO_Globals.G_Catalog_Group_Rec.inactive_date = FND_API.G_MISS_DATE
		THEN
		  /* Cannot nullify the end date for a cg when it's parent has one */

		  IF l_parent_inactive_date is NOT NULL
		  THEN
			  x_return_status := FND_API.G_RET_STS_ERROR;
			  Error_Handler.Add_Error_Token
			  (  p_message_name	=> 'EGO_CG_PARENT_HAS_ENDDATE'
			   , p_application_id     => 'EGO'
			   , x_mesg_token_tbl	=> l_mesg_token_tbl
			   );
		  END IF;

		END IF;

		Error_Handler.Write_Debug('Within Catalog Group Check Attributes . . . ');

		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_Attributes;

	/*********************************************************************
	* Procedure     : Check_Required
	* Parameters OUT: Mesg Token Table
	*                 Return_Status
	* Purpose	:
	**********************************************************************/
	PROCEDURE Check_Required
	(  x_return_status      OUT NOCOPY VARCHAR2
	 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 )
	IS
        	l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        	l_Token_Tbl             Error_Handler.Token_Tbl_Type;
	BEGIN
        	x_return_status := FND_API.G_RET_STS_SUCCESS;


		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

	END Check_Required;


	/********************************************************************
	* Procedure	: Check_Entity
	* Parameters IN	:
	* Parameters OUT: Message Token Table
	*		  Return Status
	* Purpose	: Checks for duplicate segment values
	*********************************************************************/
	PROCEDURE Check_Entity
	(  x_mesg_token_tbl	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_return_status	OUT NOCOPY VARCHAR2
	 )
	IS
		l_return_status  VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
		l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
		l_Token_Tbl	 Error_Handler.Token_Tbl_Type;
		l_ccid		 NUMBER;
	BEGIN

		/*
		l_ccid := EGO_ItemCat_Val_To_Id.Get_Catalog_Group_Id
				(p_catalog_group_name =>EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
				 , p_operation => 'FIND_COMBINATION');
		*/

	  	-- Work around to check the duplicate segment values since the FLEX API fails to
		-- perform the check. Please see bug 2682719

  		BEGIN

		  SELECT item_catalog_group_id INTO l_ccid FROM mtl_item_catalog_groups_kfv WHERE
		    upper(concatenated_segments) = upper(EGO_Globals.G_Catalog_Group_Rec.catalog_group_name);

		  EXCEPTION WHEN NO_DATA_FOUND THEN
		    l_ccid := NULL;

		  WHEN OTHERS THEN
		    l_ccid := NULL;
		    Error_Handler.Add_Error_Token
                    (  p_message_text       => 'Error in Check Entity : Catalog group name is '||EGO_Globals.G_Catalog_Group_Rec.Catalog_group_name||'/'||SQLERRM
                       , x_mesg_token_tbl     => l_mesg_token_tbl
                    );
                    l_return_status := FND_API.G_RET_STS_ERROR;

		END;

		IF l_ccid IS NOT NULL
		THEN
			IF ( EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = EGO_Globals.G_OPR_CREATE )
			   OR
			   ( EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = EGO_Globals.G_OPR_UPDATE AND
			     EGO_Globals.G_Catalog_Group_Rec.Catalog_group_id <> l_ccid )
			THEN
				-- dbms_output.put_line('Duplicate error in : '||EGO_Globals.G_Catalog_Group_Rec.Transaction_Type);
                       		Error_Handler.Add_Error_Token
                        	(  p_message_name       => 'EGO_CATALOG_ALREADY_EXISTS'
                         	, p_application_id     => 'EGO'
                         	, x_mesg_token_tbl     => l_mesg_token_tbl
                         	);
				l_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
		END IF;

		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END Check_Entity;


	PROCEDURE Check_Entity_Delete
        ( x_return_status       OUT NOCOPY VARCHAR2
        , x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
		l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
		l_dummy			VARCHAR2(1);
        BEGIN

		x_return_status  := FND_API.G_RET_STS_SUCCESS;

		/* Check if there are any items exist for this catalog group */

		BEGIN

			-- dbms_output.put_line('Checking for items during delete');

			SELECT 'x' INTO l_dummy FROM dual WHERE EXISTS (SELECT null FROM mtl_system_items_b
				WHERE item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.Catalog_group_id);

			Error_Handler.Add_Error_Token
                        (  p_message_name       => 'EGO_CATALOG_HAS_ITEMS'
                           , p_application_id     => 'EGO'
                           , x_mesg_token_tbl     => x_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;

			Return;

			EXCEPTION WHEN NO_DATA_FOUND
			THEN
				Null;

			WHEN OTHERS
			THEN
				Error_Handler.Add_Error_Token
                                (  p_message_text       => 'Error in Check Entity Delete : Catalog group name is '||EGO_Globals.G_Catalog_Group_Rec.Catalog_group_name||'/'||SQLERRM
                                , x_mesg_token_tbl     => x_mesg_token_tbl
                                );
                                x_return_status := FND_API.G_RET_STS_ERROR;

				Return;
		END;

		/* Check if this catalog group is bing used as a parent of another catalog group */

		BEGIN
			-- dbms_output.put_line('Checking for parent catalog group during delete');

			SELECT 'x' INTO l_dummy FROM dual WHERE EXISTS (SELECT null FROM mtl_item_catalog_groups_b
				WHERE parent_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.Catalog_group_id);

			-- dbms_output.put_line('Found parent catalog group during delete');

			Error_Handler.Add_Error_Token
                        (  p_message_name       => 'EGO_CATALOG_IS_PARENT'
                           , p_application_id     => 'EGO'
                           , x_mesg_token_tbl     => x_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;

			Return;

			EXCEPTION WHEN NO_DATA_FOUND
			THEN
				Null;

			WHEN OTHERS
			THEN
				Error_Handler.Add_Error_Token
                                (  p_message_text       => 'Error in Check Entity Delete : Catalog group name is '||EGO_Globals.G_Catalog_Group_Rec.Catalog_group_name||'/'||SQLERRM
                                , x_mesg_token_tbl     => x_mesg_token_tbl
                                );
                                x_return_status := FND_API.G_RET_STS_ERROR;

				Return;
		END;

        END Check_Entity_Delete;


END EGO_Validate_Catalog_Group;

/
