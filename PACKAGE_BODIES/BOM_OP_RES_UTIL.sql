--------------------------------------------------------
--  DDL for Package Body BOM_OP_RES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OP_RES_UTIL" AS
/* $Header: BOMURESB.pls 120.3.12000000.2 2007/09/13 07:09:31 pgandhik ship $ */

/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMURESS.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Op_Res_UTIL
--
--  NOTES
--
--  HISTORY
--
--  18-AUG-00 Masanori Kimizuka Initial Creation
--
****************************************************************************/

   G_Pkg_Name      CONSTANT VARCHAR2(30) := 'BOM_Op_Res_UTIL' ;



    /*****************************************************************
    * Procedure : Query_Row
    * Parameters IN : Rtg Operation Resource Key
    * Parameters OUT : Rtg Operation Resource Exposed column Record
    *                 Rtg Operation Resource Unexposed column Record
    * Returns   : None
    * Purpose   : Convert Record and Call Query_Row used by ECO.
    *             Query will query the database record and seperate
    *             the unexposed and exposed attributes before returning
    *             the records.
    ********************************************************************/
PROCEDURE Query_Row
       ( p_resource_sequence_number  IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_op_resource_rec           IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
       , x_op_res_unexp_rec          IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       )

IS

   l_rev_op_resource_rec     Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
   l_rev_op_res_unexp_rec    Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type;

BEGIN

       x_mesg_token_tbl := p_mesg_token_tbl;

       BOM_Op_Res_UTIL.Query_Row
       ( p_resource_sequence_number  => p_resource_sequence_number
       , p_operation_sequence_id     => p_operation_sequence_id
       , p_acd_type                  => p_acd_type
       , p_mesg_token_tbl            => p_mesg_Token_tbl
       , x_rev_op_resource_rec           => l_rev_op_resource_rec
       , x_rev_op_res_unexp_rec          => l_rev_op_res_unexp_rec
       , x_mesg_token_tbl            => x_mesg_token_tbl
       , x_return_status             => x_return_status
       ) ;

        -- Convert the ECO record to Routing Record

        Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
        (  p_rev_op_resource_rec     => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
         , x_rtg_op_resource_rec     => x_op_resource_rec
         , x_rtg_op_res_unexp_rec    => x_op_res_unexp_rec
         ) ;



END Query_Row;


    /*****************************************************************
    * Procedure : Query_Row used by ECO BO and internally called by RTG BO
    * Parameters IN : Revised Operation Resource Key
    * Parameters OUT: Revised Operation Resource Exposed column Record
    *                 Revised Operation Resource Unexposed column Record
    * Returns   : None
    * Purpose   : Revised Operation Resource Query Row
    *             will query the database record and seperate
    *             the unexposed and exposed attributes before returning
    *             the records.
    ********************************************************************/
PROCEDURE Query_Row
       ( p_resource_sequence_number  IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_rev_op_resource_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
       , x_rev_op_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       )
IS


   /* Define Variable */
   l_rev_op_resource_rec     Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
   l_rev_op_res_unexp_rec    Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type;
   l_err_text                VARCHAR2(2000) ;
   l_mesg_token_tbl          Error_Handler.Mesg_Token_Tbl_Type ;
   l_bo_id                   VARCHAR2(3) ;
   l_operation_sequence_id   NUMBER := p_operation_sequence_id ;

   /* Define Cursor */
   Cursor op_res_cur( p_resource_sequence_number NUMBER
                    , p_operation_sequence_id    NUMBER
                    , l_bo_id                    VARCHAR2
                    , p_acd_type                 NUMBER )
   IS

   SELECT * FROM BOM_OPERATION_RESOURCES
   WHERE ((  l_bo_id = BOM_Rtg_Globals.G_ECO_BO
            AND NVL(ACD_TYPE, FND_API.G_MISS_NUM)
                = NVL(p_acd_type,FND_API.G_MISS_NUM))
          OR
           ( l_bo_id = BOM_Rtg_Globals.G_RTG_BO
            /* AND ACD_TYPE IS NULL
	    Bug 6378493 Commenting out the condition on the parameter ACD_type */
	   )
         )
   AND   RESOURCE_SEQ_NUM         = p_resource_sequence_number
   AND   OPERATION_SEQUENCE_ID    = p_operation_sequence_id
   ;

   op_res_rec    BOM_OPERATION_RESOURCES%ROWTYPE ;


BEGIN

   x_mesg_token_tbl := p_mesg_token_tbl;
   l_bo_id := BOM_Rtg_Globals.Get_Bo_Identifier ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
   ('Querying an operation resource record : Res Seq Number ' || to_char(p_resource_sequence_number) || '. . . ' ) ;
   END IF ;

   -- Calling from revised operation resource with
   -- transaction type : Create, Acd_Type: Change or Disable
   -- to get the original value and defaulting
   IF l_bo_id = BOM_Rtg_Globals.G_ECO_BO AND
      p_acd_type = FND_API.G_MISS_NUM
   THEN
      l_bo_id := BOM_Rtg_Globals.G_RTG_BO ;

      begin
          SELECT old_operation_sequence_id
          INTO   l_operation_sequence_id
          FROM   BOM_OPERATION_SEQUENCES
          WHERE  operation_sequence_id = p_operation_sequence_id ;
      end ;

   END IF ;

   IF NOT op_res_cur%ISOPEN
   THEN
      OPEN op_res_cur( p_resource_sequence_number
                     , l_operation_sequence_id
                     , l_bo_id
                     , p_acd_type                 ) ;
   END IF ;

   FETCH op_res_cur INTO op_res_rec ;

   IF op_res_cur%FOUND
   THEN


      -- Unexposed Column
      l_rev_op_res_unexp_rec.Operation_Sequence_Id       := op_res_rec.OPERATION_SEQUENCE_ID ;
      l_rev_op_resource_rec.Substitute_Group_Number      := op_res_rec.SUBSTITUTE_GROUP_NUM ;
      l_rev_op_res_unexp_rec.Substitute_Group_Number     := l_rev_op_resource_rec.Substitute_Group_Number;
      l_rev_op_res_unexp_rec.Resource_Id                 := op_res_rec.RESOURCE_ID ;
      l_rev_op_res_unexp_rec.Activity_Id                 := op_res_rec.ACTIVITY_ID ;
      l_rev_op_res_unexp_rec.Setup_Id                    := op_res_rec.SETUP_ID ;

      -- Exposed Column
      l_rev_op_resource_rec.Eco_Name                     := op_res_rec.CHANGE_NOTICE ;
      l_rev_op_resource_rec.ACD_Type                     := op_res_rec.ACD_TYPE ;
      l_rev_op_resource_rec.Resource_Sequence_Number     := op_res_rec.RESOURCE_SEQ_NUM ;
      l_rev_op_resource_rec.Standard_Rate_Flag           := op_res_rec.STANDARD_RATE_FLAG ;
      l_rev_op_resource_rec.Assigned_Units               := op_res_rec.Assigned_Units ;
      l_rev_op_resource_rec.Usage_Rate_Or_Amount         := op_res_rec.USAGE_RATE_OR_AMOUNT ;
      l_rev_op_resource_rec.Usage_Rate_Or_Amount_Inverse := op_res_rec.USAGE_RATE_OR_AMOUNT_INVERSE ;
      l_rev_op_resource_rec.Basis_Type                   := op_res_rec.BASIS_TYPE ;
      l_rev_op_resource_rec.Schedule_Flag                := op_res_rec.SCHEDULE_FLAG ;
      l_rev_op_resource_rec.Resource_Offset_Percent      := op_res_rec.RESOURCE_OFFSET_PERCENT ;
      l_rev_op_resource_rec.Autocharge_Type              := op_res_rec.AUTOCHARGE_TYPE ;
      l_rev_op_resource_rec.Schedule_Sequence_Number     := op_res_rec.SCHEDULE_SEQ_NUM ;
      l_rev_op_resource_rec.Principle_Flag               := op_res_rec.PRINCIPLE_FLAG ;
      l_rev_op_resource_rec.Attribute_category           := op_res_rec.ATTRIBUTE_CATEGORY ;
      l_rev_op_resource_rec.Attribute1                   := op_res_rec.ATTRIBUTE1 ;
      l_rev_op_resource_rec.Attribute2                   := op_res_rec.ATTRIBUTE2 ;
      l_rev_op_resource_rec.Attribute3                   := op_res_rec.ATTRIBUTE3 ;
      l_rev_op_resource_rec.Attribute4                   := op_res_rec.ATTRIBUTE4 ;
      l_rev_op_resource_rec.Attribute5                   := op_res_rec.ATTRIBUTE5 ;
      l_rev_op_resource_rec.Attribute6                   := op_res_rec.ATTRIBUTE6 ;
      l_rev_op_resource_rec.Attribute7                   := op_res_rec.ATTRIBUTE7 ;
      l_rev_op_resource_rec.Attribute8                   := op_res_rec.ATTRIBUTE8 ;
      l_rev_op_resource_rec.Attribute9                   := op_res_rec.ATTRIBUTE9 ;
      l_rev_op_resource_rec.Attribute10                  := op_res_rec.ATTRIBUTE10 ;
      l_rev_op_resource_rec.Attribute11                  := op_res_rec.ATTRIBUTE11 ;
      l_rev_op_resource_rec.Attribute12                  := op_res_rec.ATTRIBUTE12 ;
      l_rev_op_resource_rec.Attribute13                  := op_res_rec.ATTRIBUTE13 ;
      l_rev_op_resource_rec.Attribute14                  := op_res_rec.ATTRIBUTE14 ;
      l_rev_op_resource_rec.Attribute15                  := op_res_rec.ATTRIBUTE15 ;
      l_rev_op_resource_rec.Original_System_Reference    := op_res_rec.ORIGINAL_SYSTEM_REFERENCE ;

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished querying and assigning operation record . . .') ;
      END IF ;

      x_return_status         := BOM_Rtg_Globals.G_RECORD_FOUND ;
      x_rev_op_resource_rec   := l_rev_op_resource_rec ;
      x_rev_op_res_unexp_rec  := l_rev_op_res_unexp_rec ;

   ELSE
      x_return_status         := BOM_Rtg_Globals.G_RECORD_NOT_FOUND ;
      x_rev_op_resource_rec   := l_rev_op_resource_rec ;
      x_rev_op_res_unexp_rec  := l_rev_op_res_unexp_rec ;

   END IF ;

   IF op_res_cur%ISOPEN
   THEN
      CLOSE op_res_cur ;
   END IF ;

EXCEPTION
   WHEN OTHERS THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Query Row. . .' || SQLERRM );
      END IF ;

      l_err_text := G_PKG_NAME || ' Utility (Op Resource Query Row) '
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


END Query_Row;


    /*********************************************************************
    * Procedure : Perform_Writes used by RTG BO
    * Parameters IN : Operation Resource exposed column record
    *                 Operation Resource unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose   : Convert Rtg Op Resource to ECO Op Resource and
    *             Call Check_Entity for ECO BO.
    *             Perform Writes is the only exposed procedure when the
    *             user has to perform any insert/update/deletes to the
    *             Operation Resources table.
    *********************************************************************/

    PROCEDURE Perform_Writes
        (  p_op_resource_rec       IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
         , p_op_res_unexp_rec      IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
    IS
        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        ) ;

        -- Call Perform Writes Procedure
        Bom_Op_Res_UTIL.Perform_Writes
        (  p_rev_op_resource_rec   => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec  => l_rev_op_res_unexp_rec
         , p_control_rec           => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , x_mesg_token_tbl        => x_mesg_token_tbl
         , x_return_status         => x_return_status
        ) ;

    END Perform_Writes ;



    /*********************************************************************
    * Procedure : Perform_Writes used by ECO BO and internally called by RTG BO
    * Parameters IN : Revised Op Resource exposed column record
    *                 Revised Op Resource unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose   : Perform Writes is the only exposed procedure when the
    *             user has to perform any insert/update/deletes to the
    *             Operation Resources table.
    *********************************************************************/
PROCEDURE Perform_Writes
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , p_control_rec           IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS

    l_rev_op_resource_rec    Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
    l_rev_op_res_unexp_rec   Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;


    -- Error Handlig Variables
    l_return_status VARCHAR2(1);
    l_err_text  VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;


BEGIN
   --
   -- Initialize Record and Status
   --
   l_rev_op_resource_rec    := p_rev_op_resource_rec ;
   l_rev_op_res_unexp_rec   := p_rev_op_res_unexp_rec ;
   l_return_status          := FND_API.G_RET_STS_SUCCESS ;
   x_return_status          := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Performing Database Writes . . .') ;
   END IF ;


   IF l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Resource : Executing Insert Row. . . ') ;
      END IF;

      Insert_Row
        (  p_rev_op_resource_rec   => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec  => l_rev_op_res_unexp_rec
         , x_return_status         => l_return_status
         , x_mesg_token_tbl        => l_mesg_token_tbl
        ) ;


   ELSIF l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
   THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Resource : Executing Update Row. . . ') ;
      END IF ;

      Update_Row
        (  p_rev_op_resource_rec   => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec  => l_rev_op_res_unexp_rec
         , x_return_status         => l_return_status
         , x_mesg_token_tbl        => l_mesg_token_tbl
        ) ;

   ELSIF l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE
   THEN

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Resource : Executing Delete Row. . . ') ;
      END IF ;

      Delete_Row
        (  p_rev_op_resource_rec   => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec  => l_rev_op_res_unexp_rec
         , x_return_status         => l_return_status
         , x_mesg_token_tbl        => l_mesg_token_tbl
        ) ;

   END IF ;

    --
    -- Return Status
    --
    x_return_status  := l_return_status ;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl ;

EXCEPTION
   WHEN OTHERS THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Perform Writes . . .' || SQLERRM );
      END IF ;

      l_err_text := G_PKG_NAME || ' Utility (Perform Writes) '
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

END Perform_Writes;


    /*****************************************************************************
    * Procedure : Insert_Row
    * Parameters IN : Revised Operation Resource exposed column record
    *                 Revised Operation Resource unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose   : This procedure will insert a record in the Operation Resource
    *             table; BOM_OPERATION_RESOURCES
    *
    *****************************************************************************/
PROCEDURE Insert_Row
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS

    -- Error Handlig Variables
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;

BEGIN

   x_return_status          := FND_API.G_RET_STS_SUCCESS ;

   --bug:3254815 Update request id, prog id, prog appl id and prog update date.
   INSERT  INTO BOM_OPERATION_RESOURCES
           (
              operation_sequence_id
            , resource_seq_num
            , resource_id
            , activity_id
            , standard_rate_flag
            , assigned_units
            , usage_rate_or_amount
            , usage_rate_or_amount_inverse
            , basis_type
            , schedule_flag
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , last_update_login
            , resource_offset_percent
            , autocharge_type
            , attribute_category
            , attribute1
            , attribute2
            , attribute3
            , attribute4
            , attribute5
            , attribute6
            , attribute7
            , attribute8
            , attribute9
            , attribute10
            , attribute11
            , attribute12
            , attribute13
            , attribute14
            , attribute15
            , request_id
            , program_application_id
            , program_id
            , program_update_date
            , schedule_seq_num
            , substitute_group_num
            , principle_flag
            , change_notice
            , acd_type
            , original_system_reference
            , setup_id
         )
  VALUES (
              p_rev_op_res_unexp_rec.operation_sequence_id
            , p_rev_op_resource_rec.resource_sequence_number
            , p_rev_op_res_unexp_rec.resource_id
            , p_rev_op_res_unexp_rec.activity_id
            , p_rev_op_resource_rec.standard_rate_flag
            , p_rev_op_resource_rec.assigned_units
            , p_rev_op_resource_rec.usage_rate_or_amount
            , p_rev_op_resource_rec.usage_rate_or_amount_inverse
            , p_rev_op_resource_rec.basis_type
            , p_rev_op_resource_rec.schedule_flag
            , SYSDATE                  -- Last Update Date
            , BOM_Rtg_Globals.Get_User_Id  -- Last Updated By
            , SYSDATE                  -- Creation Date
            , BOM_Rtg_Globals.Get_User_Id  -- Created By
            , BOM_Rtg_Globals.Get_Login_Id  -- Last Update Login
            , p_rev_op_resource_rec.resource_offset_percent
            , p_rev_op_resource_rec.autocharge_type
            , p_rev_op_resource_rec.attribute_category
            , p_rev_op_resource_rec.attribute1
            , p_rev_op_resource_rec.attribute2
            , p_rev_op_resource_rec.attribute3
            , p_rev_op_resource_rec.attribute4
            , p_rev_op_resource_rec.attribute5
            , p_rev_op_resource_rec.attribute6
            , p_rev_op_resource_rec.attribute7
            , p_rev_op_resource_rec.attribute8
            , p_rev_op_resource_rec.attribute9
            , p_rev_op_resource_rec.attribute10
            , p_rev_op_resource_rec.attribute11
            , p_rev_op_resource_rec.attribute12
            , p_rev_op_resource_rec.attribute13
            , p_rev_op_resource_rec.attribute14
            , p_rev_op_resource_rec.attribute15
            , Fnd_Global.Conc_Request_Id     -- Request Id
            , BOM_Rtg_Globals.Get_Prog_AppId -- Application Id
            , BOM_Rtg_Globals.Get_Prog_Id    -- Program Id
            , SYSDATE                    -- program_update_date
            , p_rev_op_resource_rec.schedule_sequence_number
            , nvl(p_rev_op_resource_rec.substitute_group_number, p_rev_op_res_unexp_rec.substitute_group_number)
            , p_rev_op_resource_rec.principle_flag
            , p_rev_op_resource_rec.eco_name
            , p_rev_op_resource_rec.acd_type
            , p_rev_op_resource_rec.original_system_reference
            , p_rev_op_res_unexp_rec.setup_id
            ) ;


EXCEPTION

    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Insert . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Op Resource Insert) ' ||
                                        SUBSTR(SQLERRM, 1, 200);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Insert_Row ;


    /***************************************************************************
    * Procedure : Update_Row
    * Parameters IN : Revised Operation Resource exposed column record
    *                 Revised Operation Resource unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose   : Update_Row procedure will update the production record with
    *             the user given values. Any errors will be returned by filling
    *             the Mesg_Token_Tbl and setting the return_status.
    ****************************************************************************/
PROCEDURE Update_Row
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS

    -- Error Handlig Variables
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;

BEGIN

   x_return_status          := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Performing update operation . . .') ;
   END IF ;

   UPDATE BOM_OPERATION_RESOURCES
   SET
      resource_id                 = p_rev_op_res_unexp_rec.resource_id
    , activity_id                 = p_rev_op_res_unexp_rec.activity_id
    , standard_rate_flag          = p_rev_op_resource_rec.standard_rate_flag
    , assigned_units              = p_rev_op_resource_rec.assigned_units
    , usage_rate_or_amount        = p_rev_op_resource_rec.usage_rate_or_amount
    , usage_rate_or_amount_inverse  =  p_rev_op_resource_rec.usage_rate_or_amount_inverse
    , basis_type                  = p_rev_op_resource_rec.basis_type
    , schedule_flag               = p_rev_op_resource_rec.schedule_flag
    , last_update_date            = SYSDATE                  /* Last Update Date */
    , last_updated_by             = BOM_Rtg_Globals.Get_User_Id  /* Last Updated By */
    , last_update_login           = BOM_Rtg_Globals.Get_Login_Id  /* Last Update Login */
    , resource_offset_percent     = p_rev_op_resource_rec.resource_offset_percent
    , autocharge_type             = p_rev_op_resource_rec.autocharge_type
    , attribute_category          = p_rev_op_resource_rec.attribute_category
    , attribute1                  = p_rev_op_resource_rec.attribute1
    , attribute2                  = p_rev_op_resource_rec.attribute2
    , attribute3                  = p_rev_op_resource_rec.attribute3
    , attribute4                  = p_rev_op_resource_rec.attribute4
    , attribute5                  = p_rev_op_resource_rec.attribute5
    , attribute6                  = p_rev_op_resource_rec.attribute6
    , attribute7                  = p_rev_op_resource_rec.attribute7
    , attribute8                  = p_rev_op_resource_rec.attribute8
    , attribute9                  = p_rev_op_resource_rec.attribute9
    , attribute10                 = p_rev_op_resource_rec.attribute10
    , attribute11                 = p_rev_op_resource_rec.attribute11
    , attribute12                 = p_rev_op_resource_rec.attribute12
    , attribute13                 = p_rev_op_resource_rec.attribute13
    , attribute14                 = p_rev_op_resource_rec.attribute14
    , attribute15                 = p_rev_op_resource_rec.attribute15
    , program_application_id      = BOM_Rtg_Globals.Get_Prog_AppId /* Application Id */
    , program_id                  = BOM_Rtg_Globals.Get_Prog_Id    /* Program Id */
    , program_update_date         = SYSDATE                    /* program_update_date */
    , schedule_seq_num            = p_rev_op_resource_rec.schedule_sequence_number
    , substitute_group_num        = nvl(p_rev_op_resource_rec.substitute_group_number, p_rev_op_res_unexp_rec.substitute_group_number)
    , principle_flag              = p_rev_op_resource_rec.principle_flag
    , original_system_reference   = p_rev_op_resource_rec.original_system_reference
    , setup_id                    = p_rev_op_res_unexp_rec.setup_id
    , request_id                  = Fnd_Global.Conc_Request_Id
   WHERE operation_sequence_id    = p_rev_op_res_unexp_rec.operation_sequence_id
   AND   resource_seq_num         = p_rev_op_resource_rec.resource_sequence_number
   AND   NVL(acd_type, 0)         = NVL(p_rev_op_resource_rec.acd_type,0) ;



EXCEPTION
    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Update . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Op Resource Update) ' ||
                                        SUBSTR(SQLERRM, 1, 200);
          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return the status and message table.
       x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Update_Row ;



    /********************************************************************
    * Procedure     : Delete_Row
    * Parameters IN : Revised Operation Resource exposed column record
    *                 Revised Operation Resource unexposed column record
    * Parameters OUT: Return Status
    *                 Message Token Table
    * Purpose       : Delete_Row procedure will delete the production record with
    *                 the user given values. Any errors will be returned by filling
    *                 the Mesg_Token_Tbl and setting the return_status.
    *
    *********************************************************************/
PROCEDURE Delete_Row
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS

    -- Error Handlig Variables
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_token_tbl       Error_Handler.Token_Tbl_Type;

BEGIN

    x_return_status          := FND_API.G_RET_STS_SUCCESS ;


    DELETE  FROM BOM_OPERATION_RESOURCES
    WHERE operation_sequence_id    = p_rev_op_res_unexp_rec.operation_sequence_id
    AND   resource_seq_num         = p_rev_op_resource_rec.resource_sequence_number
    AND   NVL(acd_type, 1)         = NVL(p_rev_op_resource_rec.acd_type,1) ;



      /******************************************************************
      -- Also delete substitute resources
      -- by first logging a warning notifying the user of the cascaded
      -- Delete.
      *******************************************************************/

     DELETE FROM BOM_SUB_OPERATION_RESOURCES sor
     WHERE   NOT EXISTS ( SELECT 'AnOther Res not exist'
                          FROM   BOM_OPERATION_RESOURCES bor
                          WHERE  bor.substitute_group_num  = sor.substitute_group_num
                          AND    bor.operation_sequence_id = sor.operation_sequence_id
                          )
     AND     sor.substitute_group_num  = nvl(p_rev_op_resource_rec.substitute_group_number, p_rev_op_res_unexp_rec.substitute_group_number)
     AND     sor.operation_sequence_id = p_rev_op_res_unexp_rec.operation_sequence_id ;

     IF SQL%FOUND THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
       -- This is a warning.
       THEN
          l_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
          l_token_tbl(1).token_value := p_rev_op_resource_rec.resource_sequence_number ;

          Error_Handler.Add_Error_Token
          ( p_Message_Name   => 'BOM_RES_DELETE_SUB_RES'
          , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
          , p_Message_Type   => 'W'
          , p_token_tbl      => l_token_tbl
          ) ;
       END IF;

     END IF ;

     x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

     IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished deleting revised operation record . . .') ;
     END IF ;


EXCEPTION
    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Delete . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Op Resource Delete) ' ||
                                        SUBSTR(SQLERRM, 1, 200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Delete_Row ;


END BOM_Op_Res_UTIL ;

/
