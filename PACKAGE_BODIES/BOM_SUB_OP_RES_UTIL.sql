--------------------------------------------------------
--  DDL for Package Body BOM_SUB_OP_RES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_SUB_OP_RES_UTIL" AS
/* $Header: BOMUSORB.pls 120.2.12010000.2 2011/12/06 10:43:59 rambkond ship $ */

/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMUSORB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Sub_Op_Res_UTIL
--
--  NOTES
--
--  HISTORY
--
--  22-AUG-00   Masanori Kimizuka Initial Creation
--  08-DEC-2005 Bhavnesh Patel    4689856:Added basis type column to identify
--                                a sub resource
****************************************************************************/

   G_Pkg_Name      CONSTANT VARCHAR2(30) := 'BOM_Sub_Op_Res_UTIL' ;

    /*****************************************************************
    * Procedure : Query_Row
    * Parameters IN : Sub Operation Resource Key
    * Parameters out: Sub Operation Resource Exposed column Record
    *                 Sub Operation Resource Unexposed column Record
    * Returns   : None
    * Purpose   : Convert Record and Call Query_Row used by ECO.
    *             Query will query the database record and seperate
    *             the unexposed and exposed attributes before returning
    *             the records.
    ********************************************************************/
PROCEDURE Query_Row
       ( p_resource_id               IN  NUMBER
       , p_substitute_group_number   IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_replacement_group_number  IN  NUMBER  --bug 2489765
       , p_basis_type                IN  NUMBER
       , p_schedule_flag             IN  NUMBER  /* Added for bug 13005178 */
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_sub_resource_rec          IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
       , x_sub_res_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       )

IS

   l_rev_sub_resource_rec     Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type ;
   l_rev_sub_res_unexp_rec    Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type;

BEGIN

       x_mesg_token_tbl := p_mesg_token_tbl;

       BOM_Sub_Op_Res_UTIL.Query_Row
       ( p_resource_id               => p_resource_id
       , p_substitute_group_number   => p_substitute_group_number
       , p_operation_sequence_id     => p_operation_sequence_id
       , p_acd_type                  => p_acd_type
       , p_replacement_group_number  => p_replacement_group_number   --bug 2489765
       , p_basis_type                => p_basis_type
       , p_schedule_flag             => p_schedule_flag  /* Added for bug 13005178 */
       , p_mesg_token_tbl            => p_mesg_Token_tbl
       , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
       , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
       , x_mesg_token_tbl            => x_mesg_token_tbl
       , x_return_status             => x_return_status
       ) ;

        -- Convert the ECO record to Routing Record

        Bom_Rtg_Pub.Convert_EcoSubRes_To_RtgSubRes
        (  p_rev_sub_resource_rec     => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec    => l_rev_sub_res_unexp_rec
         , x_rtg_sub_resource_rec     => x_sub_resource_rec
         , x_rtg_sub_res_unexp_rec    => x_sub_res_unexp_rec
         ) ;



END Query_Row;


    /*****************************************************************
    * Procedure : Query_Row used by ECO BO and internally called by RTG BO
    * Parameters IN : Revised Sub Operation Resource Key
    * Parameters out: Revised Sub Operation Resource Exposed column Record
    *                 Revised Sub Operation Resource Unexposed column Record
    * Returns   : None
    * Purpose   : Sub Revised Operation Resource Query Row
    *             will query the database record and seperate
    *             the unexposed and exposed attributes before returning
    *             the records.
    ********************************************************************/
PROCEDURE Query_Row
       ( p_resource_id               IN  NUMBER
       , p_substitute_group_number   IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_replacement_group_number  IN  NUMBER --bug 2489765
       , p_basis_type                IN  NUMBER
       , p_schedule_flag             IN  NUMBER  /* Added for bug 13005178 */
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_rev_sub_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
       , x_rev_sub_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       )
IS


   /* Define Variable */
   l_rev_sub_resource_rec     Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type ;
   l_rev_sub_res_unexp_rec    Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type;
   l_err_text                 VARCHAR2(2000) ;
   l_bo_id                    VARCHAR2(3) ;
   l_mesg_token_tbl           Error_Handler.Mesg_Token_Tbl_Type ;


   /* Define Cursor */
   Cursor sub_res_csr ( p_sub_resource_id          NUMBER
                      , p_substiute_group_number   NUMBER
                      , p_operation_sequence_id    NUMBER
                      , l_bo_id                    VARCHAR2
                      , p_acd_type                 NUMBER
              			  , p_replacement_group_number NUMBER  -- bug 2489765
                      , p_basis_type               NUMBER
                      , p_schedule_flag            NUMBER   /* Added for bug 13005178 */
                      )
   IS

   SELECT * FROM BOM_SUB_OPERATION_RESOURCES
   WHERE  ((  l_bo_id = BOM_Rtg_Globals.G_ECO_BO
            AND ACD_TYPE = p_acd_type    )
          OR
           ( l_bo_id = BOM_Rtg_Globals.G_RTG_BO
             AND ACD_TYPE IS NULL        )
         )
   AND   BASIS_TYPE               = p_basis_type
   AND   RESOURCE_ID              = p_resource_id
   AND   SUBSTITUTE_GROUP_NUM     = p_substiute_group_number
   AND   OPERATION_SEQUENCE_ID    = p_operation_sequence_id
   AND   REPLACEMENT_GROUP_NUM    = p_replacement_group_number  --bug 2489765
   AND   SCHEDULE_FLAG            = p_schedule_flag;  /* Added filter for bug 13005178 */

   sub_res_rec    BOM_SUB_OPERATION_RESOURCES%ROWTYPE ;


BEGIN

   x_mesg_token_tbl := p_mesg_token_tbl;
   l_bo_id := BOM_Rtg_Globals.Get_Bo_Identifier ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
   ('Querying a sub operation resource record : Sub Res Id ' || to_char(p_resource_id)
                       || ' -  Schedule Seq Num ' || to_char(p_substitute_group_number) || '. ' ) ;
   END IF ;

   IF NOT sub_res_csr%ISOPEN
   THEN
      OPEN sub_res_csr( p_resource_id
                      , p_substitute_group_number
                      , p_operation_sequence_id
                      , l_bo_id
                      , p_acd_type
                      , p_replacement_group_number -- bug 2489765
                      , p_basis_type
                      , p_schedule_flag  /* Added for bug 13005178 */
                      ) ;
   END IF ;

   FETCH sub_res_csr INTO sub_res_rec ;

   IF sub_res_csr%FOUND
   THEN


      -- Unexposed Column
      l_rev_sub_res_unexp_rec.Operation_Sequence_Id       := sub_res_rec.OPERATION_SEQUENCE_ID ;
      l_rev_sub_resource_rec.Substitute_Group_Number      := sub_res_rec.SUBSTITUTE_GROUP_NUM ;
      l_rev_sub_res_unexp_rec.Substitute_Group_Number     := l_rev_sub_resource_rec.Substitute_Group_Number;
      l_rev_sub_res_unexp_rec.Resource_Id                 := sub_res_rec.RESOURCE_ID ;
      l_rev_sub_res_unexp_rec.Activity_Id                 := sub_res_rec.ACTIVITY_ID ;
      l_rev_sub_res_unexp_rec.Setup_Id                    := sub_res_rec.SETUP_ID ;

      -- Exposed Column
      l_rev_sub_resource_rec.Eco_Name                     := sub_res_rec.CHANGE_NOTICE ;
      l_rev_sub_resource_rec.ACD_Type                     := sub_res_rec.ACD_TYPE ;
      l_rev_sub_resource_rec.Schedule_Sequence_Number     := sub_res_rec.SCHEDULE_SEQ_NUM ;
      l_rev_sub_resource_rec.Replacement_Group_Number     := sub_res_rec.REPLACEMENT_GROUP_NUM ;
      l_rev_sub_resource_rec.Standard_Rate_Flag           := sub_res_rec.STANDARD_RATE_FLAG ;
      l_rev_sub_resource_rec.Assigned_Units               := sub_res_rec.Assigned_Units ;
      l_rev_sub_resource_rec.Usage_Rate_Or_Amount         := sub_res_rec.USAGE_RATE_OR_AMOUNT ;
      l_rev_sub_resource_rec.Usage_Rate_Or_Amount_Inverse := sub_res_rec.USAGE_RATE_OR_AMOUNT_INVERSE ;
      l_rev_sub_resource_rec.Basis_Type                   := sub_res_rec.BASIS_TYPE ;
      l_rev_sub_resource_rec.Schedule_Flag                := sub_res_rec.SCHEDULE_FLAG ;
      l_rev_sub_resource_rec.Resource_Offset_Percent      := sub_res_rec.RESOURCE_OFFSET_PERCENT ;
      l_rev_sub_resource_rec.Autocharge_Type              := sub_res_rec.AUTOCHARGE_TYPE ;
      l_rev_sub_resource_rec.Schedule_Sequence_Number     := sub_res_rec.SCHEDULE_SEQ_NUM ;
      l_rev_sub_resource_rec.Principle_Flag               := sub_res_rec.PRINCIPLE_FLAG ;
      l_rev_sub_resource_rec.Attribute_category           := sub_res_rec.ATTRIBUTE_CATEGORY ;
      l_rev_sub_resource_rec.Attribute1                   := sub_res_rec.ATTRIBUTE1 ;
      l_rev_sub_resource_rec.Attribute2                   := sub_res_rec.ATTRIBUTE2 ;
      l_rev_sub_resource_rec.Attribute3                   := sub_res_rec.ATTRIBUTE3 ;
      l_rev_sub_resource_rec.Attribute4                   := sub_res_rec.ATTRIBUTE4 ;
      l_rev_sub_resource_rec.Attribute5                   := sub_res_rec.ATTRIBUTE5 ;
      l_rev_sub_resource_rec.Attribute6                   := sub_res_rec.ATTRIBUTE6 ;
      l_rev_sub_resource_rec.Attribute7                   := sub_res_rec.ATTRIBUTE7 ;
      l_rev_sub_resource_rec.Attribute8                   := sub_res_rec.ATTRIBUTE8 ;
      l_rev_sub_resource_rec.Attribute9                   := sub_res_rec.ATTRIBUTE9 ;
      l_rev_sub_resource_rec.Attribute10                  := sub_res_rec.ATTRIBUTE10 ;
      l_rev_sub_resource_rec.Attribute11                  := sub_res_rec.ATTRIBUTE11 ;
      l_rev_sub_resource_rec.Attribute12                  := sub_res_rec.ATTRIBUTE12 ;
      l_rev_sub_resource_rec.Attribute13                  := sub_res_rec.ATTRIBUTE13 ;
      l_rev_sub_resource_rec.Attribute14                  := sub_res_rec.ATTRIBUTE14 ;
      l_rev_sub_resource_rec.Attribute15                  := sub_res_rec.ATTRIBUTE15 ;
      l_rev_sub_resource_rec.Original_System_Reference    := sub_res_rec.ORIGINAL_SYSTEM_REFERENCE ;

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished querying and assigning operation record . . .') ;
      END IF ;

      x_return_status          := BOM_Rtg_Globals.G_RECORD_FOUND ;
      x_rev_sub_resource_rec   := l_rev_sub_resource_rec ;
      x_rev_sub_res_unexp_rec  := l_rev_sub_res_unexp_rec ;

   ELSE
      x_return_status          := BOM_Rtg_Globals.G_RECORD_NOT_FOUND ;
      x_rev_sub_resource_rec   := l_rev_sub_resource_rec ;
      x_rev_sub_res_unexp_rec  := l_rev_sub_res_unexp_rec ;

   END IF ;

   IF sub_res_csr%ISOPEN
   THEN
      CLOSE sub_res_csr ;
   END IF ;

EXCEPTION
   WHEN OTHERS THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Perform Writes . . .' || SQLERRM );
      END IF ;

      l_err_text := G_PKG_NAME || ' Utility (Sub Op Resource Query Row) '
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
    * Parameters IN : Sub Operation Resource exposed column record
    *                 Sub Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Convert Rtg Sub Op Resource to ECO Sub Op Resource and
    *             Call Check_Entity for ECO BO.
    *             Perform Writes is the only exposed procedure when the
    *             user has to perform any insert/update/deletes to the
    *             Sub Operation Resources table.
    *********************************************************************/

    PROCEDURE Perform_Writes
        (  p_sub_resource_rec       IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
         , p_sub_res_unexp_rec      IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        )
    IS
        l_rev_sub_resource_rec      Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type ;
        l_rev_sub_res_unexp_rec     Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgSubRes_To_EcoSubRes
        (  p_rtg_sub_resource_rec      => p_sub_resource_rec
         , p_rtg_sub_res_unexp_rec     => p_sub_res_unexp_rec
         , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
         , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
        ) ;

        -- Call Perform Writes Procedure
        Bom_Sub_Op_Res_UTIL.Perform_Writes
        (  p_rev_sub_resource_rec   => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
         , p_control_rec => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , x_mesg_token_tbl         => x_mesg_token_tbl
         , x_return_status          => x_return_status
        ) ;

    END Perform_Writes ;



    /*********************************************************************
    * Procedure : Perform_Writes used by ECO BO and internally called by RTG BO
    * Parameters IN : Revised Sub Op Resource exposed column record
    *                 Revised Sub Op Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Perform Writes is the only exposed procedure when the
    *             user has to perform any insert/update/deletes to the
    *             Operation Resources table.
    *********************************************************************/
PROCEDURE Perform_Writes
        (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , p_control_rec            IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS

    l_rev_sub_resource_rec    Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type ;
    l_rev_sub_res_unexp_rec   Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;


    -- Error Handlig Variables
    l_return_status     VARCHAR2(1);
    l_err_text          VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;


BEGIN
   --
   -- Initialize Record and Status
   --
   l_rev_sub_resource_rec    := p_rev_sub_resource_rec ;
   l_rev_sub_res_unexp_rec   := p_rev_sub_res_unexp_rec ;
   l_return_status           := FND_API.G_RET_STS_SUCCESS ;
   x_return_status           := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Performing Database Writes . . .') ;
   END IF ;


   IF l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Sub Operatin Sequence: Executing Insert Row. . . ') ;
      END IF;

      Insert_Row
        (  p_rev_sub_resource_rec   => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
         , x_return_status          => l_return_status
         , x_mesg_token_tbl         => x_mesg_token_tbl
        ) ;


   ELSIF l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
   THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Sub Operatin Sequence: Executing Update Row. . . ') ;
      END IF ;

      Update_Row
        (  p_rev_sub_resource_rec   => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
         , x_return_status          => l_return_status
         , x_mesg_token_tbl         => x_mesg_token_tbl
        ) ;

   ELSIF l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE
   THEN

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Sub Operatin Sequence: Executing Delete Row. . . ') ;
      END IF ;

      Delete_Row
        (  p_rev_sub_resource_rec   => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
         , x_return_status          => l_return_status
         , x_mesg_token_tbl         => x_mesg_token_tbl
        ) ;

   END IF ;

    --
    -- Return Status
    --
    x_return_status := l_return_status ;
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
    * Parameters IN : Revised Sub Operation Resource exposed column record
    *                 Revised Sub Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : This procedure will insert a record in the Sub Operation Resource
    *             table; BOM_SUB_OPERATION_RESOURCES
    *
    *****************************************************************************/
PROCEDURE Insert_Row
        (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        )
IS

    -- Error Handlig Variables
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;

BEGIN

   x_return_status           := FND_API.G_RET_STS_SUCCESS ;

   --bug:3254815 Update request id.
   INSERT  INTO BOM_SUB_OPERATION_RESOURCES
           (
              operation_sequence_id
            , substitute_group_num
            , resource_id
            , replacement_group_num
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
            , principle_flag
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
            , change_notice
            , acd_type
            , original_system_reference
            , setup_id
         )
  VALUES (
              p_rev_sub_res_unexp_rec.operation_sequence_id
            , nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number)
            , p_rev_sub_res_unexp_rec.resource_id
            , p_rev_sub_resource_rec.replacement_group_number
            , p_rev_sub_res_unexp_rec.activity_id
            , p_rev_sub_resource_rec.standard_rate_flag
            , p_rev_sub_resource_rec.assigned_units
            , p_rev_sub_resource_rec.usage_rate_or_amount
            , p_rev_sub_resource_rec.usage_rate_or_amount_inverse
            , p_rev_sub_resource_rec.basis_type
            , p_rev_sub_resource_rec.schedule_flag
            , SYSDATE                  -- Last Update Date
            , BOM_Rtg_Globals.Get_User_Id  -- Last Updated By
            , SYSDATE                  -- Creation Date
            , BOM_Rtg_Globals.Get_User_Id  -- Created By
            , BOM_Rtg_Globals.Get_Login_Id  -- Last Update Login
            , p_rev_sub_resource_rec.resource_offset_percent
            , p_rev_sub_resource_rec.autocharge_type
            , p_rev_sub_resource_rec.principle_flag
            , p_rev_sub_resource_rec.attribute_category
            , p_rev_sub_resource_rec.attribute1
            , p_rev_sub_resource_rec.attribute2
            , p_rev_sub_resource_rec.attribute3
            , p_rev_sub_resource_rec.attribute4
            , p_rev_sub_resource_rec.attribute5
            , p_rev_sub_resource_rec.attribute6
            , p_rev_sub_resource_rec.attribute7
            , p_rev_sub_resource_rec.attribute8
            , p_rev_sub_resource_rec.attribute9
            , p_rev_sub_resource_rec.attribute10
            , p_rev_sub_resource_rec.attribute11
            , p_rev_sub_resource_rec.attribute12
            , p_rev_sub_resource_rec.attribute13
            , p_rev_sub_resource_rec.attribute14
            , p_rev_sub_resource_rec.attribute15
            , Fnd_Global.Conc_Request_Id     -- Request Id
            , BOM_Rtg_Globals.Get_Prog_AppId -- Application Id
            , BOM_Rtg_Globals.Get_Prog_Id    -- Program Id
            , SYSDATE                    -- program_update_date
            , p_rev_sub_resource_rec.schedule_sequence_number
            , p_rev_sub_resource_rec.eco_name
            , p_rev_sub_resource_rec.acd_type
            , p_rev_sub_resource_rec.original_system_reference
            , p_rev_sub_res_unexp_rec.setup_id
            ) ;


EXCEPTION

    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Insert . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Sub Op Resource Insert) ' ||
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

END Insert_Row ;


    /***************************************************************************
    * Procedure : Update_Row
    * Parameters IN : Revised Sub Operation Resource exposed column record
    *                 Revised Sub Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Update_Row procedure will update the production record with
    *             the user given values. Any errors will be returned by filling
    *             the Mesg_Token_Tbl and setting the return_status.
    ****************************************************************************/
PROCEDURE Update_Row
        (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        )
IS

    -- Error Handlig Variables
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;

BEGIN

   x_return_status           := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Performing update operation . . .') ;
   END IF ;


   UPDATE BOM_SUB_OPERATION_RESOURCES
   SET
      replacement_group_num       = NVL(p_rev_sub_resource_rec.new_replacement_group_number, p_rev_sub_resource_rec.replacement_group_number) -- bug 3741570
    , resource_id                 = NVL(p_rev_sub_res_unexp_rec.new_resource_id, p_rev_sub_res_unexp_rec.resource_id)
    , schedule_seq_num            = p_rev_sub_resource_rec.schedule_sequence_number
    , activity_id                 = p_rev_sub_res_unexp_rec.activity_id
    , standard_rate_flag          = p_rev_sub_resource_rec.standard_rate_flag
    , assigned_units              = p_rev_sub_resource_rec.assigned_units
    , usage_rate_or_amount        = p_rev_sub_resource_rec.usage_rate_or_amount
    , usage_rate_or_amount_inverse  =  p_rev_sub_resource_rec.usage_rate_or_amount_inverse
    , basis_type                  = NVL(p_rev_sub_resource_rec.new_basis_type,p_rev_sub_resource_rec.basis_type)
    , schedule_flag               = NVL(p_rev_sub_resource_rec.new_schedule_flag, p_rev_sub_resource_rec.schedule_flag) /*Fix for bug 13005178*/
    , last_update_date            = SYSDATE                  /* Last Update Date */
    , last_updated_by             = BOM_Rtg_Globals.Get_User_Id  /* Last Updated By */
    , last_update_login           = BOM_Rtg_Globals.Get_Login_Id  /* Last Update Login */
    , resource_offset_percent     = p_rev_sub_resource_rec.resource_offset_percent
    , autocharge_type             = p_rev_sub_resource_rec.autocharge_type
    , principle_flag              = p_rev_sub_resource_rec.principle_flag
    , attribute_category          = p_rev_sub_resource_rec.attribute_category
    , attribute1                  = p_rev_sub_resource_rec.attribute1
    , attribute2                  = p_rev_sub_resource_rec.attribute2
    , attribute3                  = p_rev_sub_resource_rec.attribute3
    , attribute4                  = p_rev_sub_resource_rec.attribute4
    , attribute5                  = p_rev_sub_resource_rec.attribute5
    , attribute6                  = p_rev_sub_resource_rec.attribute6
    , attribute7                  = p_rev_sub_resource_rec.attribute7
    , attribute8                  = p_rev_sub_resource_rec.attribute8
    , attribute9                  = p_rev_sub_resource_rec.attribute9
    , attribute10                 = p_rev_sub_resource_rec.attribute10
    , attribute11                 = p_rev_sub_resource_rec.attribute11
    , attribute12                 = p_rev_sub_resource_rec.attribute12
    , attribute13                 = p_rev_sub_resource_rec.attribute13
    , attribute14                 = p_rev_sub_resource_rec.attribute14
    , attribute15                 = p_rev_sub_resource_rec.attribute15
    , program_application_id      = BOM_Rtg_Globals.Get_Prog_AppId /* Application Id */
    , program_id                  = BOM_Rtg_Globals.Get_Prog_Id    /* Program Id */
    , program_update_date         = SYSDATE                    /* program_update_date */
    , original_system_reference   = p_rev_sub_resource_rec.original_system_reference
    , setup_Id                    = p_rev_sub_res_unexp_rec.setup_id
    , request_id                  = Fnd_Global.Conc_Request_Id
   WHERE NVL(acd_type, 0)         = NVL(p_rev_sub_resource_rec.acd_type,0)
   AND   basis_type               = p_rev_sub_resource_rec.basis_type
   AND   substitute_group_num     = nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number)
   AND   resource_id              = p_rev_sub_res_unexp_rec.resource_id
   AND   replacement_group_num    = p_rev_sub_resource_rec.replacement_group_number -- bug 3741570
   AND   operation_sequence_id    = p_rev_sub_res_unexp_rec.operation_sequence_id
   AND   schedule_flag            = p_rev_sub_resource_rec.schedule_flag;   /* Added filter for bug 13005178 */



EXCEPTION
    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Update . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Sub Op Resource Update) ' ||
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

END Update_Row ;



    /********************************************************************
    * Procedure     : Delete_Row
    * Parameters IN : Revised Sub Operation Resource exposed column record
    *                 Revised Sub Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose       : Delete_Row procedure will delete the production record with
    *                 the user given values. Any errors will be returned by filling
    *                 the Mesg_Token_Tbl and setting the return_status.
    *
    *********************************************************************/
PROCEDURE Delete_Row
        (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        )
IS

    -- Error Handlig Variables
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;


BEGIN

    x_return_status           := FND_API.G_RET_STS_SUCCESS ;

    DELETE  FROM BOM_SUB_OPERATION_RESOURCES
    WHERE NVL(acd_type, 0)         = NVL(p_rev_sub_resource_rec.acd_type,0)
    AND   basis_type               = p_rev_sub_resource_rec.basis_type
    AND   substitute_group_num     = nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number)
    AND   resource_id              = p_rev_sub_res_unexp_rec.resource_id
    AND   replacement_group_num    = p_rev_sub_resource_rec.replacement_group_number -- bug 3741570
    AND   operation_sequence_id    = p_rev_sub_res_unexp_rec.operation_sequence_id
    AND   schedule_flag            = p_rev_sub_resource_rec.schedule_flag   /* Added filter for bug 13005178 */
    ;

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished deleting revised sub operation resource record . . .') ;
    END IF ;


EXCEPTION
    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Delete . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Sub Op Resource Delete) ' ||
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


END BOM_Sub_Op_Res_UTIL ;

/
