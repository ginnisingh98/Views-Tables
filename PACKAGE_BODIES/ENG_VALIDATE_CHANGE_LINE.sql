--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE_CHANGE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE_CHANGE_LINE" AS
/* $Header: ENGLCHLB.pls 115.10 2003/05/05 06:31:25 akumar noship $ */
/****************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      ENGLCHLB.pls
--
--  DESCRIPTION
--
--      Body of package ENG_Validate_Change_Line
--
--  NOTES
--
--  HISTORY
--  13-AUG-2002Check_Entity Masanori Kimizuka    Initial Creation
--
****************************************************************************/

    G_Pkg_Name      VARCHAR2(30) := 'ENG_Validate_Change_Line';

    l_MODEL                       CONSTANT NUMBER := 1 ;
    l_OPTION_CLASS                CONSTANT NUMBER := 2 ;
    l_PLANNING                    CONSTANT NUMBER := 3 ;
    l_STANDARD                    CONSTANT NUMBER := 4 ;
    l_PRODFAMILY                  CONSTANT NUMBER := 5 ;


    /******************************************************************
    * Procedure     : Check_Existence
    *
    * Parameters IN : Change Line exposed column record
    *                 Change Line unexposed column record
    * Parameters OUT: Old Change Line exposed column record
    *                 Old Change Line unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Check_Existence will query using the primary key
    *                 information and return a success if the operation is
    *                 CREATE and the record EXISTS or will return an
    *                 error if the operation is UPDATE and record DOES NOT
    *                 EXIST.
    *                 In case of UPDATE if record exists, then the procedure
    *                 will return old record in the old entity parameters
    *                 with a success status.
    *********************************************************************/
    PROCEDURE Check_Existence
    (  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_old_change_line_rec         IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
     , x_old_change_line_unexp_rec   IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status               OUT NOCOPY VARCHAR2
    )
    IS
       l_token_tbl      Error_Handler.Token_Tbl_Type;
       l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
       l_return_status  VARCHAR2(1);

    BEGIN

       l_Token_Tbl(1).Token_Name  := 'LINE_NAME';
       l_Token_Tbl(1).Token_Value := p_change_line_rec.name ;

       Eng_Change_Line_Util.Query_Row
       ( p_line_sequence_number  => p_change_line_rec.sequence_number
       , p_organization_id       => p_change_line_unexp_rec.organization_id
       , p_change_notice         => p_change_line_rec.eco_name
       , p_change_line_name      => p_change_line_rec.name
       , p_mesg_token_tbl        => l_mesg_token_tbl
       , x_change_line_rec       => x_old_change_line_rec
       , x_change_line_unexp_rec => x_old_change_line_unexp_rec
       , x_mesg_token_tbl        => l_mesg_token_tbl
       , x_return_status         => l_return_status
       );


       IF l_return_status = Eng_Globals.G_RECORD_FOUND AND
          p_change_line_rec.transaction_type = BOM_Globals.G_OPR_CREATE
       THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'ENG_CL_ALREADY_EXISTS'
                     , p_token_tbl      => l_token_tbl
                     ) ;
                    l_return_status := FND_API.G_RET_STS_ERROR ;

        ELSIF l_return_status = Eng_Globals.G_RECORD_NOT_FOUND AND
               p_change_line_rec.transaction_type IN
                    (ENG_Globals.G_OPR_UPDATE, ENG_Globals.G_OPR_DELETE )
        THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'ENG_CL_DOESNOT_EXIST'
                     , p_token_tbl      => l_token_tbl
                    ) ;
                    l_return_status := FND_API.G_RET_STS_ERROR ;

        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_message_name       => NULL
                     , p_message_text       => 'Unexpected error while existence verification of '
                                               || 'Change Line Name '
                                               || p_change_line_rec.name
                     , p_token_tbl          => l_token_tbl
                     ) ;
        ELSE
                    l_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF ;

        x_return_status  := l_return_status;
        x_mesg_token_tbl := l_Mesg_Token_Tbl;

    END Check_Existence;


    /*****************************************************************
    * Procedure     : Check_Required
    * Parameters IN : Change Line exposed column record
    * Paramaters OUT: Return Status
    *                 Mesg Token Table
    * Purpose       : Procedure will check if the user has given all the
    *                 required columns for the type of operation user is
    *                 trying to perform. If the required columns are not
    *                 filled in, then the record would get an error.
    ********************************************************************/
    PROCEDURE Check_Required
    ( p_change_line_rec     IN  Eng_Eco_Pub.Change_Line_Rec_Type
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    )
    IS

       l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;
       l_err_text          VARCHAR(2000) ;
       l_Token_Tbl         Error_Handler.Token_Tbl_Type;

    BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_Token_Tbl(1).token_name  := 'LINE_NAME';
       l_Token_Tbl(1).token_value := p_change_line_rec.name ;


       -- Sequence Number
       IF ( p_change_line_rec.transaction_type = ENG_Globals.G_OPR_CREATE
            AND ( p_change_line_rec.sequence_number IS NULL OR
                  p_change_line_rec.sequence_number = FND_API.G_MISS_NUM )
           )
       THEN

           Error_Handler.Add_Error_Token
           (  p_message_name   => 'ENG_CL_SEQ_NUM_REQUIRED'
            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , p_Token_Tbl      => l_Token_Tbl
           ) ;

          x_return_status := FND_API.G_RET_STS_ERROR ;


       END IF ;

       -- Change Type Code
       IF ( p_change_line_rec.transaction_type = ENG_Globals.G_OPR_CREATE
            AND ( p_change_line_rec.change_type_code IS NULL OR
                  p_change_line_rec.change_type_code = FND_API.G_MISS_CHAR )
		  --added for bug 2848506 as change type for header level line is not required
		  AND p_change_line_rec.sequence_number > 0
           )
       THEN

           Error_Handler.Add_Error_Token
           (  p_message_name   => 'ENG_CL_CHANGE_TYPE_REQUIRED'
            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , p_Token_Tbl      => l_Token_Tbl
           ) ;

          x_return_status := FND_API.G_RET_STS_ERROR ;


       END IF ;


       -- Return the message table.
       x_mesg_token_tbl := l_Mesg_Token_Tbl ;


    EXCEPTION
       WHEN OTHERS THEN

          l_err_text := G_PKG_NAME || ' Validation (Check Required) '
                                || substrb(SQLERRM,1,200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;

    END Check_Required ;


    /***************************************************************
    * Procedure : Check_Attribute (Validation) for CREATE and UPDATE
    * Parameters IN : Change Line exposed column record
    *                 Change Line unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose   : Attribute validation procedure will validate each
    *             attribute of change line in its entirety. If
    *             the validation of a column requires looking at some
    *             other columns value then the validation is done at
    *             the Entity level instead.
    *             All errors in the attribute validation are accumulated
    *             before the procedure returns with a Return_Status
    *             of 'E'.
    *********************************************************************/
    PROCEDURE Check_Attributes
    (  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , p_old_change_line_rec         IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_old_change_line_unexp_rec   IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status               OUT NOCOPY VARCHAR2
    )
    IS

    l_return_status VARCHAR2(1);
    l_err_text  VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
    l_Token_Tbl         Error_Handler.Token_Tbl_Type;

    BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Set the first token to be equal to the line name
        l_Token_Tbl(1).token_name  := 'LINE_NAME';
        l_Token_Tbl(1).token_value := p_change_line_rec.name ;

        --
        -- Check if the user is trying to update a record with
        -- missing value when the column value is required.
        --
        IF p_change_line_rec.transaction_type = ENG_Globals.G_OPR_UPDATE
        THEN


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Change Line Attr Validation: Missing Value. . . ' || l_return_status) ;
END IF;

            -- Sequence Number
            IF p_change_line_rec.sequence_number = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_CL_SEQ_NUM_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Change Type Code
            IF p_change_line_rec.change_type_code = FND_API.G_MISS_CHAR
            THEN
            Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_CL_CHANGE_TYPE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF ;

        --
        -- Check if the user is trying to create/update a record with
        -- invalid value.
        --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Change Line Attr Validation: Invalid Value. . . ' || l_return_status) ;
END IF;

        -- Sequence Number
        IF p_change_line_rec.sequence_number IS NOT NULL
        AND(   p_change_line_rec.sequence_number < -1
               OR p_change_line_rec.sequence_number > 9999
        )
            THEN

               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_CL_SEQNUM_LESSTHAN_ZERO'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
            l_return_status := FND_API.G_RET_STS_ERROR ;
       END IF;

       --Status Name

       --Start of changes for      Bug  2908248

       IF p_change_line_rec.transaction_type = 'CREATE' and
           (p_change_line_unexp_rec.status_code <> 1 AND p_change_line_unexp_rec.status_code <> 4
	   )
        THEN
                l_token_tbl(1).token_name := 'STATUS_NAME';
                l_token_tbl(1).token_value := p_change_line_rec.Status_Name;

		l_token_tbl(2).token_name :='CL_NAME';
                l_token_tbl(2).token_value := p_change_line_rec.Name;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_CL_CREATE_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
                l_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        END IF;

     IF p_change_line_rec.transaction_type = 'UPDATE' and
           ( p_change_line_unexp_rec.status_code <> 1 AND p_change_line_unexp_rec.status_code <> 4 AND p_change_line_unexp_rec.status_code <> 11
	   AND p_change_line_unexp_rec.status_code <> 5)
        THEN
                l_token_tbl(1).token_name := 'STATUS_NAME';
                l_token_tbl(1).token_value := p_change_line_rec.Status_Name;

		l_token_tbl(2).token_name :='CL_NAME';
                l_token_tbl(2).token_value := p_change_line_rec.Name;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                                ( p_Message_Name => 'ENG_CL_CREATE_STAT_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl
                                );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
                l_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

       --End of changes for      Bug  2908248

--  Done validating attributes
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Change Line Attr Validation completed with return_status: ' || l_return_status) ;
END IF;

       x_return_status := l_return_status;
       x_mesg_token_tbl := l_Mesg_Token_Tbl;

    EXCEPTION
       WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Attribute Validation . . .' || SQLERRM );
END IF ;


          l_err_text := G_PKG_NAME || ' Validation (Attr. Validation) '
                                || substrb(SQLERRM,1,200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;


    END Check_Attributes ;


    /*****************************************************************
    * Procedure     : Check_Conditionally_Required for Common
    * Parameters IN : Change Line exposed column record
    *                 Change Line Unexposed column record
    * Paramaters OUT: Return Status
    *                 Mesg Token Table
    * Purpose       : Check Conditionally Required Columns
    *
    ********************************************************************/
    PROCEDURE Check_Conditionally_Required
    ( p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
    , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
    , x_return_status         OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    )
    IS

       l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;
       l_err_text          VARCHAR(2000) ;
       l_token_tbl      Error_Handler.Token_Tbl_Type;

    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_Token_Tbl(1).token_name  := 'LINE_NAME';
       l_Token_Tbl(1).token_value := p_change_line_rec.name ;

       -- Return the message table.
       x_mesg_token_tbl := l_Mesg_Token_Tbl ;


    EXCEPTION
       WHEN OTHERS THEN

          l_err_text := G_PKG_NAME || ' Validation (Check Conditionally Required) '
                                || substrb(SQLERRM,1,200);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;

    END Check_Conditionally_Required ;



    /******************************************************************
    * Procedure : Check_Entity_Delete
    * Parameters IN : Change Line exposed column record
    *                 Change Line unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose   :     Check_Entity validate the entity for the correct
    *                 business logic to delete the record.
    **********************************************************************/
    PROCEDURE Check_Entity_Delete
    (  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status               OUT NOCOPY VARCHAR2
    )
    IS

    l_return_status VARCHAR2(1);
    l_err_text  VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
    l_Token_Tbl         Error_Handler.Token_Tbl_Type;


    BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Set the first token to be equal to the line name
        l_Token_Tbl(1).token_name  := 'LINE_NAME';
        l_Token_Tbl(1).token_value := p_change_line_rec.name ;

        --
        -- Check if the user is trying to update a record with
        -- missing value when the column value is required.
        --
        IF p_change_line_rec.transaction_type = ENG_Globals.G_OPR_DELETE
        THEN


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Change Line Entity Validation on Delete . . . ' || l_return_status) ;
END IF;

        END IF ;


--  Done validating attributes
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Change Line Entity Validation on Delete completed with return_status: ' || l_return_status) ;
END IF;

       x_return_status := l_return_status;
       x_mesg_token_tbl := l_Mesg_Token_Tbl;

    EXCEPTION
       WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Entity Validation on Delete. . .' || SQLERRM );
END IF ;


          l_err_text := G_PKG_NAME || ' Validation (Entiy Validation) '
                                || substrb(SQLERRM,1,200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;


    END Check_Entity_Delete ;



    /******************************************************************
    * Procedure : Check_Entity
    * Parameters IN : Change Line exposed column record
    *                 Change Line unexposed column record
    *                 Old Change Line exposed column record
    *                 Old Change Line unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose   :     Check_Entity validate the entity for the correct
    *                 business logic. It will verify the values by running
    *                 checks on inter-dependent columns.
    *                 It will also verify that changes in one column value
    *                 does not invalidate some other columns.
    **********************************************************************/
    PROCEDURE Check_Entity
    (  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , p_old_change_line_rec         IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_old_change_line_unexp_rec   IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status               OUT NOCOPY VARCHAR2
    )
    IS

    -- Variables
    l_bom_item_type     NUMBER ;  -- Bom_Item_Type of Assembly
    l_pto_flag          CHAR ;    -- PTO flag for Assembly
    l_eng_item_flag     CHAR ;    -- Is assembly an Engineering Item
    l_bom_enabled_flag  CHAR ;    -- Assembly's bom_enabled_flag

    -- Error Handlig Variables
    l_return_status        VARCHAR2(1);
    l_err_text             VARCHAR2(2000) ;
    l_Mesg_Token_Tbl       Error_Handler.Mesg_Token_Tbl_Type ;
    l_token_tbl            Error_Handler.Token_Tbl_Type;

    -- Get CL Item Attr. Value
    CURSOR   l_item_cur (p_org_id NUMBER, p_item_id NUMBER) IS
       SELECT   bom_item_type
              , pick_components_flag
              , bom_enabled_flag
              , eng_item_flag
       FROM MTL_SYSTEM_ITEMS
       WHERE organization_id   = p_org_id
       AND   inventory_item_id = p_item_id
       ;


    -- Check if Seq Num Uniqueness
    CURSOR  l_duplicate_csr( p_change_line_id      NUMBER
                           --, p_change_notice       VARCHAR2
                           --, p_org_id              NUMBER
                           , p_change_id           NUMBER
                           , p_seq_num             NUMBER )
    IS
       SELECT 'Duplicate Seq Num'
       FROM   DUAL
       WHERE  EXISTS (
                      SELECT NULL
                      FROM ENG_CHANGE_LINES
                      WHERE  sequence_number  = p_seq_num
                      AND    change_line_id <> p_change_line_id
                      AND    change_id = p_change_id
                      --AND    change_notice = p_change_notice
                      --AND    organization_id = p_org_id
                      ) ;


    BEGIN

       --
       -- Initialize Common Record and Status
       --

       l_return_status           := FND_API.G_RET_STS_SUCCESS ;

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Performing Change Line Check Entitity Validation . . .') ;
END IF ;


       --
       -- Set the 1st token of Token Table to Change Line value
       --
       l_Token_Tbl(1).token_name  := 'LINE_NAME';
       l_Token_Tbl(1).token_value := p_change_line_rec.name;

-- BB start commenting out here
/*       -- Change Line Item Validation
       IF p_change_line_unexp_rec.item_id IS NOT NULL
       THEN
           -- First Query all the attributes for the Assembly item used Entity Validation
          FOR l_item_rec IN l_item_cur
                              (  p_org_id  => p_change_line_unexp_rec.organization_id
                               , p_item_id => p_change_line_unexp_rec.item_id
                               )
          LOOP

             l_bom_item_type    := l_item_rec.bom_item_type ;
             l_pto_flag         := l_item_rec.pick_components_flag ;
             l_eng_item_flag    := l_item_rec.eng_item_flag ;
             l_bom_enabled_flag := l_item_rec.bom_enabled_flag ;

          END LOOP ;


          --
          -- Check Item Attributes for Change Line
          --
          --
          -- Verify that the Parent has BOM Enabled
          --
          IF l_bom_enabled_flag <> 'Y'
          THEN
                l_token_tbl(2).token_name  := 'ITEM_NAME';
                l_token_tbl(2).token_value := p_change_line_rec.item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_CL_ITEM_BOM_NOT_ALLOWED'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF ;

          --
          -- Verify that the Item on CL is not PTO Item
          -- Routing canot be created for PTO Item
*/          /*
          IF l_pto_flag <> 'N'
          THEN
                l_token_tbl(2).token_name  := 'ITEM_NAME';
                l_token_tbl(2).token_value := p_change_line_rec.item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_CL_ITEM_PTO_ITEM'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF ;
          */
/*
          --
          -- Verify that the  BOM Item Type is not 3:Planning Item
          --
          IF l_bom_item_type = l_PLANNING
          THEN
                l_token_tbl(2).token_name  := 'ITEM_NAME';
                l_token_tbl(2).token_value := p_change_line_rec.item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_CL_ITEM_PLANNING_ITEM'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;

          END IF ;

       END IF ; -- Change Line Item Validation
*/
-- BB stop commenting here

       --
       -- Check uniquness of the sequence number.
       --
       IF  p_change_line_rec.transaction_type = BOM_Globals.G_OPR_CREATE
       OR  ( p_change_line_rec.transaction_type = BOM_Globals.G_OPR_UPDATE
            AND  p_change_line_rec.sequence_number
                 <>  p_old_change_line_rec.sequence_number)
       THEN

             FOR  l_duplicate_rec IN l_duplicate_csr
                           ( p_change_line_id => p_change_line_unexp_rec.change_line_id
                           --, p_change_notice  => p_change_line_rec.eco_name
                           --, p_org_id         => p_change_line_unexp_rec.organization_id
                           , p_change_id      => p_change_line_unexp_rec.change_id
                           , p_seq_num        => p_change_line_rec.sequence_number )
             LOOP

                l_token_tbl(2).token_name  := 'SEQ_NUM';
                l_token_tbl(2).token_value := p_change_line_rec.sequence_number;

                Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_OP_NOT_UNIQUE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                l_return_status := FND_API.G_RET_STS_ERROR ;

             END LOOP ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Check uniqueness of the sequence number . . . ' || l_return_status) ;
END IF ;

       END IF ;


       --
       -- Return Error Status
       --
       x_return_status  := l_return_status;
       x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;


    EXCEPTION
       WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Entity Validation . . .' || SQLERRM );
END IF ;


          l_err_text := G_PKG_NAME || ' Validation (Entity Validation) '
                                || substrb(SQLERRM,1,200);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;

    END Check_Entity ;



    /*************************************************************
    * Procedure     : Check_Access
    * Parameters IN : Change line record
    *                 Change line unexposed record
    * Parameters OUT: Mesg_Token_Tbl
    *                 Return_Status
    * Purpose       : Procedure will verify that the line item
    *                 is accessible to the user.
    ********************************************************************/
    PROCEDURE Check_Access
    (  p_change_line_rec           IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec     IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                        Error_Handler.G_MISS_MESG_TOKEN_TBL
     , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_Return_Status              OUT NOCOPY VARCHAR2
    )
    IS
    BEGIN
      NULL;
    END Check_Access;


    PROCEDURE Check_Access
    (  p_change_notice              IN  VARCHAR2
     , p_organization_id            IN  NUMBER
     , p_item_revision              IN  VARCHAR2
     , p_item_name                  IN  VARCHAR2
     , p_item_id                    IN  NUMBER
     , p_item_revision_id           IN  NUMBER
     , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                        Error_Handler.G_MISS_MESG_TOKEN_TBL
     , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_Return_Status              OUT NOCOPY VARCHAR2
    )
    IS
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type :=
                                p_Mesg_Token_Tbl;
        l_return_status         VARCHAR2(1);

        CURSOR c_ItemType IS
        SELECT bom_item_type
          FROM MTL_SYSTEM_ITEMS
         WHERE inventory_item_id = p_item_id
           AND organization_id   = p_organization_id;


    BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;


        --
        -- Check that the user has access to the BOM Item Type
        -- of the revised item
        --
        IF BOM_Globals.Get_STD_Item_Access IS NULL AND
           BOM_Globals.Get_PLN_Item_Access IS NULL AND
           BOM_Globals.Get_MDL_Item_Access IS NULL
        THEN

                --
                -- Get respective profile values
                --
                IF NVL(fnd_profile.value('ENG:STANDARD_ITEM_ECN_ACCESS'), 1) = 1
                THEN
                        BOM_Globals.Set_STD_Item_Access
                        ( p_std_item_access     => 4);
                ELSE
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('no access to standard items'); END IF;
                        BOM_Globals.Set_STD_Item_Access
                        (p_std_item_access      => NULL);
                END IF;

                IF fnd_profile.value('ENG:MODEL_ITEM_ECN_ACCESS') = '1'
                THEN
                        BOM_Globals.Set_MDL_Item_Access
                        ( p_mdl_item_access     => 1);
                        BOM_Globals.Set_OC_Item_Access
                        ( p_oc_item_access      => 2);
                ELSE
                        BOM_Globals.Set_MDL_Item_Access
                        ( p_mdl_item_access     => NULL);
                        BOM_Globals.Set_OC_Item_Access
                        ( p_oc_item_access      => NULL);
                END IF;

                IF fnd_profile.value('ENG:PLANNING_ITEM_ECN_ACCESS') = '1'
                THEN
                        BOM_Globals.Set_PLN_Item_Access
                        ( p_pln_item_access     => 3);
                ELSE
                        BOM_Globals.Set_PLN_Item_Access
                        ( p_pln_item_access     => NULL);
                END IF;
        END IF;


        FOR item_rec IN  c_ItemType
        LOOP
                IF item_rec.Bom_Item_Type = 5
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CL_ITEM_PROD_FAMILY'
                         , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
                        l_return_status := FND_API.G_RET_STS_ERROR;

                ELSIF item_rec.Bom_Item_Type NOT IN
                      ( NVL(BOM_Globals.Get_STD_Item_Access, 0),
                        NVL(BOM_Globals.Get_PLN_Item_Access, 0),
                        NVL(BOM_Globals.Get_OC_Item_Access, 0) ,
                        NVL(BOM_Globals.Get_MDL_Item_Access, 0)
                       )
                THEN
                        l_Token_Tbl(2).Token_Name := 'BOM_ITEM_TYPE';
                        l_Token_Tbl(2).Translate  := TRUE;
                        IF item_rec.Bom_Item_Type = 1
                        THEN
                                l_Token_Tbl(2).Token_Value := 'ENG_MODEL';
                        ELSIF item_rec.Bom_Item_Type = 2
                        THEN
                                l_Token_Tbl(2).Token_Value:='ENG_OPTION_CLASS';
                        ELSIF item_rec.Bom_Item_Type = 3
                        THEN
                                l_Token_Tbl(2).Token_Value := 'ENG_PLANNING';
                        ELSIF item_rec.Bom_Item_Type = 4
                        THEN
                                l_Token_Tbl(2).Token_Value := 'ENG_STANDARD';
                        END IF;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CL_ITEM_ACCESS_DENIED'
                         , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                        );

                        l_return_status := FND_API.G_RET_STS_ERROR;

                END IF;
        END LOOP;

        -- If all the access checks are satisfied then return a status of
        -- success, else return error.
        --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item Check Access returning . . . ' ||  l_return_status);
END IF;

        x_Return_Status := l_return_status;
        x_Mesg_Token_Tbl := l_mesg_token_tbl;

    END Check_Access;


END ENG_Validate_Change_Line ;

/
