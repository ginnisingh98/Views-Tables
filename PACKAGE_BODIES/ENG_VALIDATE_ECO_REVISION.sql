--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE_ECO_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE_ECO_REVISION" AS
/* $Header: ENGLREVB.pls 115.18 2002/12/12 17:01:34 akumar ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Validate_Eco_Revision';
l_dummy				       VARCHAR2(80);

/****************************************************************************
*Procedure	: Entity (Validate)
*Parameters IN	: Eco Revisions Record of exposed columns
*		  Eco Revisions Record of unexposed columns
*Parameters OUT	: Mesg Token Table
*		  Return_Status
*Purpose	: Entity validation will execute the business logic to verify
*		  the correctness of the revisions record wrt to the trasaction
*		  type.
****************************************************************************/
PROCEDURE Check_Entity
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_eco_revision_rec          IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy			      VARCHAR2(80);
l_processed	              BOOLEAN;
l_token_tbl		      Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl	      Error_Handler.Mesg_Token_Tbl_Type;
l_Err_Text		      VARCHAR2(2000);
BEGIN

--dbms_output.put_line('Performing ECO Revisions Entity validation  . . .');

      ENG_GLOBALS.Check_Approved_For_Process
	( p_change_notice 	=> p_eco_revision_rec.Eco_Name,
          p_organization_id     => p_Eco_Rev_Unexp_Rec.organization_id,
          x_processed           => l_processed,
          x_err_text            => l_err_text
         );

      IF l_processed = TRUE
      THEN
           -- If the above process returns true then set the ECO approval.

           BEGIN
                ENG_GLOBALS.Set_Request_For_Approval
		(p_change_notice    => p_eco_revision_rec.Eco_Name,
                 p_organization_id  => p_Eco_Rev_Unexp_Rec.organization_id,
                 x_err_text         => l_err_text
                 );

           	EXCEPTION
                	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                             l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           END;

       END IF;

--dbms_output.put_line('Return Status so far ...before checking valid revision '
--		     || l_return_status );

	IF p_eco_revision_rec.Transaction_Type = ENG_GLOBALS.G_OPR_UPDATE AND
	   p_eco_revision_rec.new_revision IS NOT NULL
	THEN
		-- Verfiy that the user is not trying to change the revision to
 		-- a revision that already exists.

		BEGIN
			SELECT 'Valid'
			  INTO l_dummy
			  FROM sys.dual
			 WHERE NOT EXISTS
			           ( SELECT 1
				       FROM eng_change_order_revisions
				      WHERE revision =
					    p_eco_revision_rec.new_revision
					AND change_notice =
					    p_eco_revision_rec.Eco_Name
				   );
			EXCEPTION
			   WHEN NO_DATA_FOUND THEN
			       	-- new revision record exists and should be
				-- errored out

				-- Set token values for the message
				l_token_tbl(1).token_name  := 'REVISION';
				l_token_tbl(1).token_value :=
					p_eco_revision_rec.new_revision;
				l_token_tbl(2).token_name  := 'ECO_NAME';
				l_token_tbl(2).token_value :=
					p_eco_revision_rec.eco_name;

			    Error_Handler.Add_Error_Token
			    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , p_message_name  => 'ENG_ECO_REVISION_NOT_UNIQUE'
			     , p_token_tbl     => l_token_tbl
			    );
			    l_return_status := FND_API.G_RET_STS_ERROR;
		END;
	END IF;
    x_return_status := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Entity;

--  Procedure Attributes

PROCEDURE Check_Attributes
(   x_return_status		OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_eco_revision_rec		IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- AT THE REVISIONS LEVEL THERE ARE NO COLUMNS APART FROM THE DESCRIPTIVE
    -- FLEX WHICH CAN BE ATTRIBUTE VALIDATED.
    -- VALIDITY OF ORGANIZATION_ID AND CHANGE_NOTICE WILL HAPPEN IN THE
    -- EARLIER STEPS ITSELF.

    --  Validate eco_revision attributes

--dbms_output.put_line('Performing ECO Revisions Attribute Validation . . .');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Attributes;

--  Procedure Entity_Delete

PROCEDURE Check_Entity_Delete
(   x_return_status		OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_eco_revision_rec		IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

	-- Validation of whether the ECO is implemented or canceled will
	-- happen in earlier steps
	-- so their is no Delete Validation

	x_Return_Status := l_return_status;

END Check_Entity_Delete;

/*****************************************************************************
* Procedure	: Check_Existence
* Parameters IN : ECO Revision exposed column record
*		  ECO Revision unexposed column record
* Parameters OUT: Old ECO Revision exposed column record
*		  Old ECO Revision unexposed column record
* 	 	  Mesg Token Table
*		  Return Status
* Purpose	: Check_Existence will poerform a query using the primary key
*		  information and will return a success if the operation is
*		  CREATE and the record EXISTS or will return an
*		  error if the operation is UPDATE and the record DOES NOT
*		  EXIST.
*		  In case of UPDATE if the record exists then the procedure
*		  will return the old record in the old entity parameters
*		  with a success status.
****************************************************************************/
PROCEDURE Check_Existence
(  p_eco_revision_rec           IN  Eng_Eco_Pub.Eco_Revision_Rec_Type
 , p_eco_rev_unexp_rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_old_eco_revision_rec	IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_Rec_Type
 , x_old_eco_rev_unexp_rec	IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
)
IS
	l_token_tbl	 Error_Handler.Token_Tbl_Type;
	l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
	l_return_status  VARCHAR2(1);
BEGIN
	l_Token_Tbl(1).Token_Name  := 'REVISION';
	l_Token_Tbl(1).Token_Value := p_eco_Revision_rec.revision;
	l_token_tbl(2).Token_Name  := 'ECO_NAME';
	l_token_Tbl(2).Token_Value := p_eco_revision_rec.eco_name;

	ENG_Eco_Revision_Util.Query_Row
	(  p_Change_Notice	=> p_eco_revision_rec.eco_name
	 , p_Organization_Id	=> p_eco_rev_unexp_rec.organization_id
	 , p_Revision		=> p_eco_revision_rec.revision
	 , x_Eco_Revision_Rec	=> x_old_eco_revision_rec
	 , x_Eco_Rev_Unexp_Rec	=> x_old_eco_rev_unexp_rec
	 , x_Return_Status	=> l_return_status
	 );
	IF l_return_status = Eng_Globals.G_RECORD_FOUND AND
	   p_eco_revision_rec.transaction_type = Eng_Globals.G_OPR_CREATE
	THEN
		Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_ECO_REV_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF l_return_status = Eng_Globals.G_RECORD_NOT_FOUND AND
	      p_eco_revision_rec.transaction_type IN
		(Eng_Globals.G_OPR_UPDATE, Eng_Globals.G_OPR_DELETE)
	THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'ENG_ECO_REV_DOESNOT_EXIST'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl	=> l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , p_message_name	=> 'ENG_REV_EXS_UNEXP_SKIP'
                 , p_token_tbl		=> l_token_tbl
                 );
	ELSE
		 l_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

	x_return_status := l_return_status;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END CHECK_EXISTENCE;

/**************************************************************************
* Procedure	: Check_Access
* Parameters	: Eco Revision unique key
* Parameters OUT: Mesg Token Table
*		  Return Status
* Purpose	: Procedure will verify that the user has access to the
*		  current ECO before performing any operation on Revisions.
****************************************************************************/
PROCEDURE Check_Access
(  p_revision		IN  VARCHAR2
 , p_change_notice	IN  VARCHAR2
 , p_organization_id	IN  NUMBER
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status	OUT NOCOPY VARCHAR2
)
IS
	l_token_tbl 		Error_Handler.Token_Tbl_Type;
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
	--
        -- Use the ECO Check Access procedure to verify if the user has
	-- access to the current ECO.
	--
	l_token_tbl(1).token_name  := 'REVISION';
	l_token_tbl(1).token_value := p_revision;

--dbms_output.put_line('Revision: ' || p_Revision);
--dbms_output.put_line('ECO     : ' || p_change_notice);
--dbms_output.put_line('Org     : ' || to_char(p_organization_id));

	--
	-- Driving program must make sure to call the ECO Access check.
	--
	/**************************************
	Eng_Validate_Eco.Check_Access
        (  p_change_notice	=> p_change_notice
	 , p_organization_id	=> p_organization_id
	 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	 , x_Return_Status	=> l_return_status
	);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> 'ENG_REV_ACCESS_FAT_FATAL'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Token_Tbl		=> l_Token_Tbl
		 );
	END IF;
	**********************************************/

	x_return_status  := l_return_status;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Access;

/****************************************************************************
* Procedure Check_Required
* Parameters IN	: Eco Revision exposed column record
* Parameters OUT: Mesg Token Tbl
* Purpose	: Will check if all the required columns have beem filled in
*		  by the user.
****************************************************************************/
PROCEDURE CHECK_REQUIRED
(  x_return_status	OUT NOCOPY VARCHAR2
 , p_eco_revision_rec	IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
 , x_mesg_token_tbl    	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
	l_mesg_token_tbl	Error_Handler.Mesg_token_Tbl_Type;

BEGIN
	IF p_eco_revision_rec.revision IS NULL OR
	   p_eco_revision_rec.revision = FND_API.G_MISS_CHAR
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		Error_Handler.Add_Error_Token
		(  x_mesg_token_tbl => x_mesg_token_tbl
		 , p_mesg_token_tbl => l_mesg_token_tbl
	         , p_message_name   => 'ENG_REVISION_KEYCOL_NULL'
	         );
	ELSE
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

END CHECK_REQUIRED;


END ENG_Validate_Eco_Revision;

/
