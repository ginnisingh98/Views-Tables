--------------------------------------------------------
--  DDL for Package Body BOM_OP_SEQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OP_SEQ_UTIL" AS
/* $Header: BOMUOPSB.pls 120.4.12010000.2 2008/10/15 12:05:28 tbhande ship $ */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMUOPSS.pls
--
--  DESCRIPTION
--
--     Body of package BOM_Op_Seq_UTIL
--
--  NOTES
--
--  HISTORY
--
--  10-AUG-00 Masanroi Kimizuka Initial Creation
--  25-OCT-00 Masanori Kimizuka Modified Insert_Row to add Eco_For_Production
--
****************************************************************************/

   G_Pkg_Name      CONSTANT VARCHAR2(30) := 'BOM_Op_Seq_UTIL';



    /*****************************************************************
    * Procedure : Query_Row used by RTG BO
    * Parameters IN : Rtg Operation Key
    * Parameters out: Rtg Operation Exposed column Record
    *                 Rtg Operation Unexposed column Record
    * Returns   : None
    * Purpose   : Convert Record and Call Query_Row for Common
    *             Query will query the database record and seperate
    *             the unexposed and exposed attributes before returning
    *             the records.
    ********************************************************************/

PROCEDURE Query_Row
       ( p_operation_sequence_number IN  NUMBER
       , p_effectivity_date          IN  DATE
       , p_routing_sequence_id       IN  NUMBER
       , p_operation_type            IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_operation_rec             IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
       , x_op_unexp_rec              IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       )


IS

   /* Define Variable */
   l_com_operation_rec   Bom_Rtg_Pub.Com_Operation_Rec_Type ;
   l_com_op_unexp_rec    Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type;
   l_err_text            VARCHAR2(2000);

BEGIN

         x_mesg_token_tbl := p_mesg_token_tbl;

         BOM_Op_Seq_UTIL.Query_Row
         ( p_operation_sequence_number  => p_operation_sequence_number
         , p_effectivity_date           => p_effectivity_date
         , p_routing_sequence_id        => p_routing_sequence_id
         , p_operation_type             => p_operation_type
         , p_mesg_Token_tbl             => p_Mesg_Token_Tbl
         , x_com_operation_rec          => l_com_operation_rec
         , x_com_op_unexp_rec           => l_com_op_unexp_rec
         , x_mesg_token_tbl             => x_mesg_token_tbl
         , x_return_status              => x_return_status
         ) ;

        -- Convert the ECO record to Routing Record
        Bom_Rtg_Pub.Convert_ComOp_To_RtgOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rtg_operation_rec      => x_operation_rec
         , x_rtg_op_unexp_rec       => x_op_unexp_rec
         ) ;

END Query_Row;


    /*****************************************************************
    * Procedure : Query_Row used by ECO BO
    * Parameters IN : Revised Operation Key
    * Parameters out: Revised Operation Exposed column Record
    *                 Revised Operation Unexposed column Record
    * Returns   : None
    * Purpose   : Convert Record and Call Query_Row for Common
    *             Query will query the database record and seperate
    *             the unexposed and exposed attributes before returning
    *             the records.
    ********************************************************************/

PROCEDURE Query_Row
       ( p_operation_sequence_number IN  NUMBER
       , p_effectivity_date          IN  DATE
       , p_routing_sequence_id       IN  NUMBER
       , p_operation_type            IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_rev_operation_rec         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
       , x_rev_op_unexp_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       )


IS

   /* Define Variable */
   l_com_operation_rec   Bom_Rtg_Pub.Com_Operation_Rec_Type ;
   l_com_op_unexp_rec    Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type;
   l_err_text            VARCHAR2(2000);

BEGIN

         x_mesg_token_tbl := p_mesg_token_tbl;

         BOM_Op_Seq_UTIL.Query_Row
         ( p_operation_sequence_number  => p_operation_sequence_number
         , p_effectivity_date           => p_effectivity_date
         , p_routing_sequence_id        => p_routing_sequence_id
         , p_operation_type             => p_operation_type
         , p_mesg_Token_tbl             => p_Mesg_Token_Tbl
         , x_com_operation_rec          => l_com_operation_rec
         , x_com_op_unexp_rec           => l_com_op_unexp_rec
         , x_mesg_token_tbl             => x_mesg_token_tbl
         , x_return_status              => x_return_status
         );

        -- Convert the Common record to Revised Operation record
        Bom_Rtg_Pub.Convert_ComOp_To_EcoOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rev_operation_rec      => x_rev_operation_rec
         , x_rev_op_unexp_rec       => x_rev_op_unexp_rec
         ) ;

END Query_Row;




    /*****************************************************************
    * Procedure : Query_Row used for Common
    *                internally called by RTG BO and Eco Rtg
    * Parameters IN : Common Operation Key
    * Parameters out: Common Operation Exposed   column Record
    *                 Common Operation Unexposed column Record
    * Returns   : None
    * Purpose   : Common Operation Query Row
    *             will query the database record and seperate
    *             the unexposed and exposed attributes before returning
    *             the records.
    ********************************************************************/


PROCEDURE   Query_Row
       ( p_operation_sequence_number IN  NUMBER
       , p_effectivity_date          IN  DATE
       , p_routing_sequence_id       IN  NUMBER
       , p_operation_type            IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_com_operation_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
       , x_com_op_unexp_rec          IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       )
IS

   /* Define Variable */
   l_com_operation_rec   Bom_Rtg_Pub.Com_Operation_Rec_Type ;
   l_com_op_unexp_rec    Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type;
   l_bo_id               VARCHAR2(3) ;
   l_err_text            VARCHAR2(2000);


   /* Define Cursor */
   Cursor op_seq_csr( p_operation_sequence_number NUMBER
                    , p_effectivity_date          DATE
                    , p_routing_sequence_id       NUMBER
                    , p_operation_type            NUMBER
                    , l_bo_id                     VARCHAR2
                    )
   IS

   SELECT * FROM BOM_OPERATION_SEQUENCES
   WHERE ((  l_bo_id = BOM_Rtg_Globals.G_ECO_BO )
             -- AND implementation_date IS NULL )
         OR (l_bo_id = BOM_Rtg_Globals.G_RTG_BO
             AND implementation_date IS NOT NULL )
         )
   AND   ( ( NVL(OPERATION_TYPE,1) = 1 AND -- Added nvl for bug 2856314
             EFFECTIVITY_DATE   = p_effectivity_date  -- Changed for bug 2647027
-- /** time **/      TRUNC(EFFECTIVITY_DATE) = TRUNC(p_effectivity_date)
           )
           OR p_operation_type IN (2,3)
         )
   AND   NVL(OPERATION_TYPE, 1) = DECODE(p_operation_type, FND_API.G_MISS_NUM, 1
                                        , NVL(p_operation_type, 1))
   AND   OPERATION_SEQ_NUM = p_operation_sequence_number
   AND   routing_sequence_id    = p_routing_sequence_id
   ;

   op_seq_rec    BOM_OPERATION_SEQUENCES%ROWTYPE ;


BEGIN

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
        Error_Handler.Write_Debug
      ('Querying an operation sequence record : Seq Number '
                 || to_char(p_operation_sequence_number) || '. . . ' ) ;
        Error_Handler.Write_Debug (' : Routing seq id ' || to_char( p_routing_sequence_id));
        Error_Handler.Write_Debug (' : Effecitive date' || to_char( p_effectivity_date));
        Error_Handler.Write_Debug (' : Operation type ' || to_char( NVL(p_operation_type , 1)));
      END IF ;

--      dbms_output.put_line('Op Type   : ' ||
--      to_char(p_operation_type);
--      dbms_output.put_line('Effective: ' || to_char(p_effectivity_date ));
--      dbms_output.put_line('Rtg Seq : ' || to_char(p_routing_Sequence_Id));

   x_mesg_token_tbl := p_mesg_token_tbl;
   l_bo_id := BOM_Rtg_Globals.Get_Bo_Identifier ;

   IF NOT op_seq_csr%ISOPEN
   THEN
      OPEN op_seq_csr( p_operation_sequence_number
                     , p_effectivity_date
                     , p_routing_sequence_id
                     , p_operation_type
                     , l_bo_id
                      ) ;
   END IF ;

   FETCH op_seq_csr INTO op_seq_rec ;

   IF op_seq_csr%FOUND
   THEN

      -- Set  Queried Record to Exposed and Unexposed Recourd
      -- Unexposed Column
      l_com_op_unexp_rec.Revised_Item_Sequence_Id    := op_seq_rec.REVISED_ITEM_SEQUENCE_ID ;
      l_com_op_unexp_rec.Operation_Sequence_Id       := op_seq_rec.OPERATION_SEQUENCE_ID ;
      l_com_op_unexp_rec.Old_Operation_Sequence_Id   := op_seq_rec.OLD_OPERATION_SEQUENCE_ID ;
      l_com_op_unexp_rec.Routing_Sequence_Id         := op_seq_rec.routing_sequence_id ;
      l_com_op_unexp_rec.Standard_Operation_Id       := op_seq_rec.STANDARD_OPERATION_ID ;
      l_com_op_unexp_rec.Department_Id               := op_seq_rec.DEPARTMENT_ID ;
      l_com_op_unexp_rec.Process_Op_Seq_Id           := op_seq_rec.PROCESS_OP_SEQ_ID ;
      l_com_op_unexp_rec.Line_Op_Seq_Id              := op_seq_rec.LINE_OP_SEQ_ID ;
      l_com_op_unexp_rec.User_Elapsed_Time           := op_seq_rec.TOTAL_TIME_USER ;
      l_com_op_unexp_rec.lowest_acceptable_yield     := op_seq_rec.LOWEST_ACCEPTABLE_YIELD ; -- Added for MES Enhancement
      l_com_op_unexp_rec.use_org_settings            := op_seq_rec.USE_ORG_SETTINGS ;
      l_com_op_unexp_rec.queue_mandatory_flag        := op_seq_rec.QUEUE_MANDATORY_FLAG ;
      l_com_op_unexp_rec.run_mandatory_flag          := op_seq_rec.RUN_MANDATORY_FLAG ;
      l_com_op_unexp_rec.to_move_mandatory_flag      := op_seq_rec.TO_MOVE_MANDATORY_FLAG ;
      l_com_op_unexp_rec.show_next_op_by_default     := op_seq_rec.SHOW_NEXT_OP_BY_DEFAULT ;
      l_com_op_unexp_rec.show_scrap_code             := op_seq_rec.SHOW_SCRAP_CODE ;
      l_com_op_unexp_rec.show_lot_attrib             := op_seq_rec.SHOW_LOT_ATTRIB ;
      l_com_op_unexp_rec.track_multiple_res_usage_dates := op_seq_rec.TRACK_MULTIPLE_RES_USAGE_DATES ; -- End of MES Changes

      -- Exposed Column
      l_com_operation_rec.Eco_Name                   := op_seq_rec.CHANGE_NOTICE ;
      l_com_operation_rec.ACD_Type                   := op_seq_rec.ACD_TYPE ;
      l_com_operation_rec.Operation_Sequence_Number  := op_seq_rec.OPERATION_SEQ_NUM ;
      l_com_operation_rec.Operation_Type             := op_seq_rec.OPERATION_TYPE ;
      l_com_operation_rec.Start_Effective_Date       := op_seq_rec.EFFECTIVITY_DATE ;
      l_com_operation_rec.Op_Lead_Time_Percent       := op_seq_rec.OPERATION_LEAD_TIME_PERCENT ;
      l_com_operation_rec.Minimum_Transfer_Quantity  := op_seq_rec.MINIMUM_TRANSFER_QUANTITY ;
      l_com_operation_rec.Count_Point_Type           := op_seq_rec.COUNT_POINT_TYPE ;
      l_com_operation_rec.Operation_Description      := op_seq_rec.OPERATION_DESCRIPTION ;
      l_com_operation_rec.Disable_Date               := op_seq_rec.DISABLE_DATE ;
      l_com_operation_rec.Backflush_Flag             := op_seq_rec.BACKFLUSH_FLAG ;
      l_com_operation_rec.Option_Dependent_Flag      := op_seq_rec.OPTION_DEPENDENT_FLAG ;
      l_com_operation_rec.Reference_Flag             := op_seq_rec.REFERENCE_FLAG ;
      l_com_operation_rec.Yield                      := op_seq_rec.YIELD ;
      l_com_operation_rec.Cumulative_Yield           := op_seq_rec.CUMULATIVE_YIELD ;
      l_com_operation_rec.Reverse_CUM_Yield          := op_seq_rec.REVERSE_CUMULATIVE_YIELD ;
      -- l_com_operation_rec.Calculated_Labor_Time      := op_seq_rec.LABOR_TIME_CALC ;
      -- l_com_operation_rec.Calculated_Machine_Time    := op_seq_rec.MACHINE_TIME_CALC ;
      -- l_com_operation_rec.Calculated_Elapsed_Time    := op_seq_rec.TOTAL_TIME_CALC ;
      l_com_operation_rec.User_Labor_Time            := op_seq_rec.LABOR_TIME_USER ;
      l_com_operation_rec.User_Machine_Time          := op_seq_rec.MACHINE_TIME_USER ;
      l_com_operation_rec.Net_Planning_Percent       := op_seq_rec.NET_PLANNING_PERCENT ;
      l_com_operation_rec.Include_In_Rollup          := op_seq_rec.INCLUDE_IN_ROLLUP ;
      l_com_operation_rec.Op_Yield_Enabled_Flag      := op_seq_rec.OPERATION_YIELD_ENABLED ;
      -- Added by MK on 04/10/2001 for eAM changes
      l_com_operation_rec.Shutdown_Type              := op_seq_rec.SHUTDOWN_TYPE ;
      l_com_operation_rec.Attribute_category         := op_seq_rec.ATTRIBUTE_CATEGORY ;
      l_com_operation_rec.Attribute1                 := op_seq_rec.ATTRIBUTE1 ;
      l_com_operation_rec.Attribute2                 := op_seq_rec.ATTRIBUTE2 ;
      l_com_operation_rec.Attribute3                 := op_seq_rec.ATTRIBUTE3 ;
      l_com_operation_rec.Attribute4                 := op_seq_rec.ATTRIBUTE4 ;
      l_com_operation_rec.Attribute5                 := op_seq_rec.ATTRIBUTE5 ;
      l_com_operation_rec.Attribute6                 := op_seq_rec.ATTRIBUTE6 ;
      l_com_operation_rec.Attribute7                 := op_seq_rec.ATTRIBUTE7 ;
      l_com_operation_rec.Attribute8                 := op_seq_rec.ATTRIBUTE8 ;
      l_com_operation_rec.Attribute9                 := op_seq_rec.ATTRIBUTE9 ;
      l_com_operation_rec.Attribute10                := op_seq_rec.ATTRIBUTE10 ;
      l_com_operation_rec.Attribute11                := op_seq_rec.ATTRIBUTE11 ;
      l_com_operation_rec.Attribute12                := op_seq_rec.ATTRIBUTE12 ;
      l_com_operation_rec.Attribute13                := op_seq_rec.ATTRIBUTE13 ;
      l_com_operation_rec.Attribute14                := op_seq_rec.ATTRIBUTE14 ;
      l_com_operation_rec.Attribute15                := op_seq_rec.ATTRIBUTE15 ;
      l_com_operation_rec.Original_System_Reference  := op_seq_rec.ORIGINAL_SYSTEM_REFERENCE ;
      l_com_operation_rec.Long_Description	     := op_seq_rec.LONG_DESCRIPTION ; -- Added for long description project (Bug 2689249)

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished querying and assigning operation record . . .') ;
      END IF ;

      x_return_status     := BOM_Rtg_Globals.G_RECORD_FOUND ;
      x_com_operation_rec := l_com_operation_rec ;
      x_com_op_unexp_rec  := l_com_op_unexp_rec ;

   ELSE
      x_return_status     := BOM_Rtg_Globals.G_RECORD_NOT_FOUND ;
      x_com_operation_rec := l_com_operation_rec ;
      x_com_op_unexp_rec  := l_com_op_unexp_rec ;

   END IF ;

   IF op_seq_csr%ISOPEN
   THEN
      CLOSE op_seq_csr ;
   END IF ;

EXCEPTION
   WHEN OTHERS THEN
      l_err_text := G_PKG_NAME || ' Utility (Operation Query Row) '
                               || substrb(SQLERRM,1,200);

--    dbms_output.put_line('Unexpected Error: '||l_err_text);

      Error_Handler.Add_Error_Token
      ( p_message_name   => NULL
      , p_message_text   => l_err_text
      , p_mesg_token_tbl => p_mesg_token_tbl
      , x_mesg_token_tbl => x_mesg_token_tbl
      );

      x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Query_Row;


    /*********************************************************************
    * Procedure : Perform_Writes used by RTG BO
    * Parameters IN : Rtg Operation exposed column record
    *                 Rtg Operation unexposed column record
    * Parameters ouT: Return Status
    *                 Message Token Table
    * Purpose   : Convert Rtg Operation to Common Operation and
    *             Call Check_Entity for Common Operation.
    *             Perform Writes is the only exposed procedure when the
    *             user has to perform any insert/update/deletes to the
    *             Operation Sequences table.
    *********************************************************************/
    PROCEDURE Perform_Writes
        (  p_operation_rec         IN  Bom_Rtg_Pub.Operation_Rec_Type
         , p_op_unexp_rec          IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
        (  p_rtg_operation_rec      => p_operation_rec
         , p_rtg_op_unexp_rec       => p_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;

        -- Call Perform Writes Procedure

        Bom_Op_Seq_UTIL.Perform_Writes
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_rec           => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

    END Perform_Writes ;



    /*********************************************************************
    * Procedure : Perform_Writes used by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Convert Revised Operation to Common Operation and
    *             Call Check_Entity for Common Operation.
    *             Perform Writes is the only exposed procedure when the
    *             user has to perform any insert/update/deletes to the
    *             Operation Sequences table.
    *********************************************************************/
    PROCEDURE Perform_Writes
        (  p_rev_operation_rec         IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec          IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status             IN OUT NOCOPY VARCHAR2
        )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Revised Operation to Common Operation
        Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
        (  p_rev_operation_rec      => p_rev_operation_rec
         , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;


        -- Call Perform Writes Procedure
        Bom_Op_Seq_UTIL.Perform_Writes
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_rec           => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

    END Perform_Writes;


    /*********************************************************************
    * Procedure : Perform_Writes internally called by RTG BO and by ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Perform any insert/update/deletes to the
    *             Operation Sequences table.
    *********************************************************************/

PROCEDURE Perform_Writes
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , p_control_rec           IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )

IS

    l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
    l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
    l_routing_sequence_id    NUMBER ; -- Routing Sequence Id
    l_routing_type           NUMBER ; -- Routing Type

    -- Error Handlig Variables
    l_return_status          VARCHAR2(1);
    l_temp_return_status     VARCHAR2(1);
    l_err_text               VARCHAR2(2000) ;
    l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
    l_temp_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
    l_Token_Tbl              Error_Handler.Token_Tbl_Type;

    -- Check if Routing exists
    CURSOR l_rtg_exists_csr ( p_revised_item_id NUMBER
                            , p_organization_id NUMBER
                            , p_alternate_rtg_code VARCHAR2
                            )
    IS
        SELECT 'Routing Exists'
        FROM   DUAL
        WHERE NOT EXISTS ( SELECT  routing_sequence_id
                           FROM    bom_operational_routings
                           WHERE assembly_item_id = p_revised_item_id
                           AND   organization_id  = p_organization_id
                           AND NVL(alternate_routing_designator, FND_API.G_MISS_CHAR)  =
                               NVL(p_alternate_rtg_code,FND_API.G_MISS_CHAR)
             );

    -- Get Eng_Item_Flag for Routing Type value
    CURSOR l_routing_type_csr ( p_revised_item_id NUMBER
                               , p_organization_id NUMBER )
    IS
       SELECT decode(eng_item_flag, 'N', 1, 2) eng_item_flag
       FROM   MTL_SYSTEM_ITEMS
       WHERE  inventory_item_id = p_revised_item_id
       AND    organization_id   = p_organization_id ;

    -- Get Routing_Sequence_id
    CURSOR l_get_rtg_seq_csr
    IS
           SELECT bom_operational_routings_s.NEXTVAL routing_sequence_id
           FROM DUAL ;

BEGIN
   --
   -- Initialize Common Record and Status
   --
   l_com_operation_rec  := p_com_operation_rec ;
   l_com_op_unexp_rec   := p_com_op_unexp_rec ;
   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Performing Database Writes . . .') ;
   END IF ;


   IF l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operation Sequence: Executing Insert Row. . . ') ;
      END IF;

      /**************************************************************************
      -- commenting calling following logic for the release 11i.4 to remove dependancy
      -- on the eng odf. This is because the RTG and ECO objects should be
      -- independant of each other. But commenting out because we will reuse it
      --
      -- This logic is moved to Eng_Globals.Perform_Writes_For_Primary_RTG and
      -- it is called from Rev Operation Procedure in Private API.
      --
      -- Revised Operation
      --
      IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
      THEN
         FOR  l_rtg_exists_rec IN l_rtg_exists_csr
                    ( p_revised_item_id => p_com_op_unexp_rec.revised_item_id
                    , p_organization_id => p_com_op_unexp_rec.organization_id
                    , p_alternate_rtg_code => l_com_operation_rec.alternate_routing_code
                    )
         LOOP
            --
            -- Loop executes then the Routing does not exist.
            --
            FOR l_routing_type_rec IN l_routing_type_csr
                    ( p_revised_item_id => p_com_op_unexp_rec.revised_item_id
                    , p_organization_id => p_com_op_unexp_rec.organization_id)
            LOOP
               l_routing_type   :=  l_routing_type_rec.eng_item_flag ;
            END LOOP ;

            --
            -- If Caller Type is FORM, Generate new routing_sequence_id
            --
            IF p_control_rec.caller_type IS NOT NULL AND
            p_control_rec.caller_type = 'FORM'
            THEN
               FOR l_get_rtg_seq_rec IN l_get_rtg_seq_csr
               LOOP
               l_com_op_unexp_rec.routing_sequence_id :=
                        l_get_rtg_seq_rec.routing_sequence_id;
               END LOOP;

               l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
               l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;
               l_Token_Tbl(2).token_name  := 'OP_SEQ_NUMBER';
               l_Token_Tbl(2).token_value := p_com_operation_rec.operation_sequence_number ;

               Error_Handler.Add_Error_Token
               (  p_Message_Name       => 'BOM_NEW_PRIMARY_RTG_CREATED'
                , p_Message_Text       => NULL
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_message_type       => 'W'

               ) ;
            ELSE

               --
               -- Log a warning indicating that a new bill has been created
               -- as a result of the operation being added.
               --
               l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
               l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;
               l_Token_Tbl(2).token_name  := 'OP_SEQ_NUMBER';
               l_Token_Tbl(2).token_value := p_com_operation_rec.operation_sequence_number ;

               Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'BOM_NEW_PRIMARY_RTG_CREATED'
                     , p_Message_Text       => NULL
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                     , p_message_type       => 'W'
                    ) ;
            END IF ;

            --
            -- Create New Routing using Routing Attributes in Revised Items table
            --
            Create_New_Routing
            ( p_assembly_item_id            => l_com_op_unexp_rec.revised_item_id
            , p_organization_id             => l_com_op_unexp_rec.organization_id
            , p_pending_from_ecn            => l_com_operation_rec.eco_name
            , p_routing_sequence_id         => l_com_op_unexp_rec.routing_sequence_id
            , p_common_routing_sequence_id  => l_com_op_unexp_rec.routing_sequence_id
            , p_routing_type                => l_routing_type
            , p_last_update_date            => SYSDATE
            , p_last_updated_by             => BOM_Rtg_Globals.Get_User_Id
            , p_creation_date               => SYSDATE
            , p_created_by                  => BOM_Rtg_Globals.Get_User_Id
            , p_login_id                    => BOM_Rtg_Globals.Get_Login_Id
            , p_revised_item_sequence_id    => l_com_op_unexp_rec.revised_item_sequence_id
            , p_original_system_reference   => l_com_operation_rec.original_system_reference
            , x_Mesg_Token_Tbl              => l_temp_mesg_token_Tbl
            , x_return_status               => l_temp_return_status
            ) ;


            IF l_temp_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                l_return_status  := l_temp_return_status ;
                l_mesg_token_Tbl := l_temp_Mesg_Token_Tbl ;

            ELSE
                -- Create a new routing revision for the created primary routing
                INSERT INTO MTL_RTG_ITEM_REVISIONS
                       (  inventory_item_id
                        , organization_id
                        , process_revision
                        , implementation_date
                        , last_update_date
                        , last_updated_by
                        , creation_date
                        , created_by
                        , last_update_login
                        , change_notice
                        , ecn_initiation_date
                        , effectivity_date
                        , revised_item_sequence_id
                        )
                        SELECT
                          l_com_op_unexp_rec.revised_item_id
                        , l_com_op_unexp_rec.organization_id
                        , mp.starting_revision
                        , SYSDATE
                        , SYSDATE
                        , BOM_Rtg_Globals.Get_User_Id
                        , SYSDATE
                        , BOM_Rtg_Globals.Get_User_Id
                        , BOM_Rtg_Globals.Get_Login_Id
                        , l_com_operation_rec.eco_name
                        , SYSDATE
                        , SYSDATE
                        , l_com_op_unexp_rec.revised_item_sequence_id
                        FROM MTL_PARAMETERS mp
                        WHERE mp.organization_id = l_com_op_unexp_rec.organization_id
                        AND   NOT EXISTS( SELECT NULL
                                          FROM MTL_RTG_ITEM_REVISIONS
                                          WHERE implementation_date IS NOT NULL
                                          AND   organization_id   = l_com_op_unexp_rec.organization_id
                                          AND   inventory_item_id = l_com_op_unexp_rec.revised_item_id
                        ) ;

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Creating new routing revision for the created primary routing for the revised item . . . ') ;
      END IF;


            END IF ;

         END LOOP ;
      END IF ;

   **************************************************************************/

      Insert_Row
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => l_temp_return_status
         , x_mesg_token_tbl        => l_temp_mesg_token_tbl
        ) ;

       IF l_temp_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
                l_return_status  := l_temp_return_status ;
                l_mesg_token_Tbl := l_temp_Mesg_Token_Tbl ;
       END IF ;

   ELSIF l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
   THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Sequence: Executing Update Row. . . ') ;
      END IF ;

      Update_Row
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => l_return_status
         , x_mesg_token_tbl        => l_mesg_token_tbl
        ) ;

   ELSIF l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE
   THEN

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Sequence: Executing Delete Row. . . ') ;
      END IF ;

      Delete_Row
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_com_operation_rec     => l_com_operation_rec
         , x_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => l_return_status
         , x_mesg_token_tbl        => l_mesg_token_tbl
        ) ;


   /**************************************************************************
   -- commenting this calling procedure for the release 11i.4 to remove dependancy
   -- on the eng odf. This is because the RTG and ECO objects should be
   -- independant of each other. But commenting out because we will reuse it
   -- in release 12 when these all files alongwith the odf will be base.
   --
   -- Cancel_Operation procedure is moved to Eng_Globals packate and
   -- Eng_Globals.Cancel_Operation is called from Rev Op Private Procedure


   ELSIF l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CANCEL
   THEN


      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Sequence: Perform Cancel Operation . . .') ;
      END IF ;

        Cancel_Operation
        ( p_operation_sequence_id  => l_com_op_unexp_rec.operation_sequence_id
        , p_cancel_comments        => l_com_operation_rec.cancel_comments
        , p_op_seq_num             => l_com_operation_rec.operation_sequence_number
        , p_user_id                => BOM_Rtg_Globals.Get_User_Id
        , p_login_id               => BOM_Rtg_Globals.Get_Login_Id
        , p_prog_id                => BOM_Rtg_Globals.Get_Prog_Id
        , p_prog_appid             => BOM_Rtg_Globals.Get_Prog_AppId
        , x_return_status          => l_return_status
        , x_mesg_token_tbl         => l_mesg_token_tbl
        ) ;

     IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Cancel Operation is completed with return status ' || l_return_status ) ;
      END IF ;


   **************************************************************************/



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



/******************************************************************************
* Procedure : Create_New_Routing
* Parameters IN : Assembly_Item_Id
*                 Organization_Id
*                 Alternate_Routing_Code
*                 Pending from ECN
*                 Common_Routing_Sequence_Id
*                 Routing_Type
*                 WHO columns
*                 Revised_Item_Sequence_Id
* Purpose   : This procedure will be called when a revised operation is
*             the first operation being added on a revised item. This
*             procedure will create a Routing and update the revised item
*             information indicating that routing for this revised item now
*             exists.
******************************************************************************/
PROCEDURE Create_New_Routing
            ( p_assembly_item_id            IN NUMBER
            , p_organization_id             IN NUMBER
            , p_alternate_routing_code      IN VARCHAR2
            , p_pending_from_ecn            IN VARCHAR2
            , p_routing_sequence_id         IN NUMBER
            , p_common_routing_sequence_id  IN NUMBER
            , p_routing_type                IN NUMBER
            , p_last_update_date            IN DATE
            , p_last_updated_by             IN NUMBER
            , p_creation_date               IN DATE
            , p_created_by                  IN NUMBER
            , p_login_id                    IN NUMBER
            , p_revised_item_sequence_id    IN NUMBER
            , p_original_system_reference   IN VARCHAR2
            , x_mesg_token_tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
            , x_return_status               IN OUT NOCOPY VARCHAR2
            )
IS
    -- Error Handlig Variables
    l_return_status VARCHAR2(1);
    l_err_text  VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;

BEGIN
NULL ;
   /*  commenting this following updating for the release 11i.4 to remove dependancy
   --  on the eng odf.This is because the RTG and ECO objects should be
   --  independant of each other. But commenting out because we will reuse it
   --  in release 12 when these all files alongwith the odf will be base

   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Create New Routing for ECO . . .') ;
   END IF ;

   --
   -- Create New Routing using Routing Information in Revised Item table
   --
   INSERT INTO bom_operational_routings
                    (  assembly_item_id
                     , organization_id
                     , alternate_routing_designator
                     , pending_from_ecn
                     , routing_sequence_id
                     , common_routing_sequence_id
                     , routing_type
                     , last_update_date
                     , last_updated_by
                     , creation_date
                     , created_by
                     , last_update_login
                     , original_system_reference
                     , cfm_routing_flag
                     , completion_subinventory
                     , completion_locator_id
                     , mixed_model_map_flag
                     , priority
                     , ctp_flag
                     , routing_comment
                     )
              SELECT   p_assembly_item_id
                     , p_organization_id
                     , p_alternate_routing_code
                     , p_pending_from_ecn
                     , p_routing_sequence_id
                     , p_common_routing_sequence_id
                     , p_routing_type
                     , p_last_update_date
                     , p_last_updated_by
                     , p_creation_date
                     , p_created_by
                     , p_login_id
                     , p_original_system_reference
                     , cfm_routing_flag
                     , completion_subinventory
                     , completion_locator_id
                     , mixed_model_map_flag
                     , priority
                     , ctp_flag
                     , routing_comment
              FROM ENG_REVISED_ITEMS
              WHERE revised_item_sequence_id = p_revised_item_sequence_id ;


   --
   --
   -- Set Routing Sequence Id to Revised Item table
   --
   UPDATE ENG_REVISED_ITEMS
   SET    routing_sequence_id = p_routing_sequence_id
     ,    last_update_date  = p_last_update_date       --  Last Update Date
     ,    last_updated_by   = p_last_updated_by        --  Last Updated By
     ,    last_update_login = p_login_id               --  Last Update Login
   WHERE revised_item_sequence_id = p_revised_item_sequence_id ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Set created routing sequence id : ' || to_char(p_routing_sequence_id)
          || '  to the parenet revised item . . .') ;
   END IF ;


EXCEPTION
   WHEN OTHERS THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Creating New Routing . . .' || SQLERRM );
      END IF ;

      l_err_text := G_PKG_NAME || 'Utilities  (Create New Routing) '
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
*/


END Create_New_Routing ;



    /******************************************************************
    * Procedure : Copy_Std_Res_and_Docs
    *                     internally called by RTG BO and by ECO BO
    * Parameters IN : p_std_operation_id
    * Purpose   :     Copy Standard Operation Resource
    *                 to Operation Resources
    **********************************************************************/
/*
Bug : 	3728894
Desc : For Standered Operations, Eco_Name was not Inserted  at the time of insertion of the
operation_resources , so that needed to insert explicitly, because resources query at the form level searches for Eco_Name
and thes Resources could not be Picked at that time.

Procedure Overloaded because tree parameters are passing this time, Two argument Procedure is also taken care after this.

*/

 PROCEDURE  Copy_Std_Res_and_Docs
    (   p_operation_sequence_id    IN  NUMBER
     ,  p_std_operation_id         IN  NUMBER
     ,  p_change_notice IN VARCHAR2
     )
    IS
    BEGIN

                   INSERT INTO BOM_OPERATION_RESOURCES
                   ( operation_sequence_id
                   , resource_seq_num
                   , resource_id
                   , acd_type
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
                   , substitute_group_num
                   , Schedule_Seq_num   -- Bug 7370692
                   , change_notice)
                   SELECT p_operation_sequence_id
                        , resource_seq_num
                        , resource_id
                        , DECODE(  BOM_Rtg_Globals.Get_Bo_Identifier
                                 , BOM_Rtg_Globals.G_ECO_BO
                                 , 1 -- Acd Type : ADD
                                 , NULL )
                        , activity_id
                        , standard_rate_flag
                        , assigned_units
                        , usage_rate_or_amount
                        , usage_rate_or_amount_inverse
                        , basis_type
                        , schedule_flag
                        , SYSDATE                  --  Last Update Date
                        , BOM_Rtg_Globals.Get_User_Id  --  Last Updated By
                        , SYSDATE                  --  Creation Date
                        , BOM_Rtg_Globals.Get_User_Id  --  Created By
                        , BOM_Rtg_Globals.Get_User_Id  --  Last Update Login
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
                        , NULL                           --  Request Id
                        , BOM_Rtg_Globals.Get_Prog_AppId --  Program Application Id
                        , BOM_Rtg_Globals.Get_Prog_Id    --  Prog id
                        , SYSDATE                        --  Program Update Date
                        , substitute_group_num
			, resource_seq_num   -- Bug 7370692  (Schedule_Seq_num=resource_seq_num)
                        , p_change_notice
                   FROM BOM_STD_OP_RESOURCES
                   WHERE standard_operation_id = p_std_operation_id ;

                   --
                   -- Copy alternate resources
                   --

                   INSERT INTO BOM_SUB_OPERATION_RESOURCES
                   ( operation_sequence_id
                   , substitute_group_num
                   , resource_id
                   , schedule_seq_num
                   , replacement_group_num
                   , activity_id
                   , standard_rate_flag
                   , assigned_units
                   , usage_rate_or_amount
                   , usage_rate_or_amount_inverse
                   , basis_type
                   , schedule_flag
                   , autocharge_type
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                   , request_id
                   , program_application_id
                   , program_id
                   , program_update_date
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
                   , principle_flag
                   , setup_id
                   , change_notice
                   , acd_type
                   , original_system_reference)
                   SELECT p_operation_sequence_id
                        , substitute_group_num
                        , resource_id
                        , schedule_seq_num -- Bug 7370692   0 -- defaulting SSN to zero and the user has to change this value.
                        , replacement_group_num
                        , activity_id
                        , standard_rate_flag
                        , assigned_units
                        , usage_rate_or_amount
                        , usage_rate_or_amount_inverse
                        , basis_type
                        , schedule_flag
                        , autocharge_type
                        , SYSDATE                        --  Last Update Date
                        , BOM_Rtg_Globals.Get_User_Id    --  Last Updated By
                        , SYSDATE                        --  Creation Date
                        , BOM_Rtg_Globals.Get_User_Id    --  Created By
                        , BOM_Rtg_Globals.Get_User_Id    --  Last Update Login
                        , NULL                           --  Request Id
                        , BOM_Rtg_Globals.Get_Prog_AppId --  Program Application Id
                        , BOM_Rtg_Globals.Get_Prog_Id    --  Prog id
                        , SYSDATE                        --  Program Update Date
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
                        , NULL -- principle_flag
                        , NULL -- setup_id
                        , NULL -- change_notice
                        , DECODE(  BOM_Rtg_Globals.Get_Bo_Identifier
                                 , BOM_Rtg_Globals.G_ECO_BO
                                 , 1 -- Acd Type : ADD
                                 , NULL )
                        , NULL -- original_system_reference
                   FROM BOM_STD_SUB_OP_RESOURCES
                   WHERE standard_operation_id = p_std_operation_id ;

                   --
                   -- Copy Attachment
                   --
                   FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                   X_from_entity_name  => 'BOM_STANDARD_OPERATIONS',
                   X_from_pk1_value    => to_char(p_std_operation_id),
                   X_from_pk2_value    => null,
                   X_from_pk3_value    => null,
                   X_from_pk4_value    => null,
                   X_from_pk5_value    => null,
                   X_to_entity_name    => 'BOM_OPERATION_SEQUENCES',
                   X_to_pk1_value      => to_char( p_operation_sequence_id ),
                   X_to_pk2_value      => null,
                   X_to_pk3_value      => null,
                   X_to_pk4_value      => null,
                   X_to_pk5_value      => null,
                   X_created_by        => BOM_Rtg_Globals.Get_User_Id,
                   X_last_update_login => BOM_Rtg_Globals.Get_User_Id,
                   X_program_application_id        => BOM_Rtg_Globals.Get_Prog_AppId,
                   X_program_id        => BOM_Rtg_Globals.Get_Prog_Id,
                   X_request_id        => null
                   ) ;



    END  Copy_Std_Res_and_Docs ;
/*
Bug : 	3728894
Desc : As Part of fix this Procedure is overloaded, with three argument.
*/


PROCEDURE  Copy_Std_Res_and_Docs
    (   p_operation_sequence_id    IN  NUMBER
     ,  p_std_operation_id         IN  NUMBER
     )
    IS
    BEGIN
        Copy_Std_Res_and_Docs( p_operation_sequence_id,p_std_operation_id,null);
END Copy_Std_Res_and_Docs;


    /******************************************************************
    * Procedure : Copy_Old_Op_Seq_Children
    *                     internally called by RTG BO and by ECO BO
    * Parameters IN : p_operation_sequence_id
    * Purpose   :     Copy Old Operation Children
    *                 for Revised Operation Acd Type is Disable
    **********************************************************************/
    PROCEDURE  Copy_Old_Op_Seq_Children
    (   p_operation_sequence_id        IN  NUMBER
     ,  p_old_operation_sequence_id    IN  NUMBER
     ,  p_eco_name                     IN  VARCHAR2
     )
    IS
    BEGIN

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Debug1. . . ' ) ;
        END IF ;

                   INSERT INTO BOM_OPERATION_RESOURCES
                   ( operation_sequence_id
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
                   -- , original_system_reference
                   -- , setup_id
                   )
                   SELECT
                     p_operation_sequence_id
                   , resource_seq_num
                   , resource_id
                   , activity_id
                   , standard_rate_flag
                   , assigned_units
                   , usage_rate_or_amount
                   , usage_rate_or_amount_inverse
                   , basis_type
                   , schedule_flag
                   , SYSDATE                      --  Last Update Date
                   , BOM_Rtg_Globals.Get_User_Id  --  Last Updated By
                   , SYSDATE                      --  Creation Date
                   , BOM_Rtg_Globals.Get_User_Id  --  Created By
                   , BOM_Rtg_Globals.Get_User_Id  --  Last Update Login
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
                   , NULL                           --  Request Id
                   , BOM_Rtg_Globals.Get_Prog_AppId --  Program Application Id
                   , BOM_Rtg_Globals.Get_Prog_Id    --  Prog id
                   , SYSDATE                        --  Program Update Date
                   , schedule_seq_num
                   , substitute_group_num
                   , principle_flag
                   , p_eco_name                     --  change_notice
                   , 3                              --  acd_type : Disable
                   -- , original_system_reference
                   -- , setup_id
                   FROM BOM_OPERATION_RESOURCES
                   WHERE operation_sequence_id = p_old_operation_sequence_id ;

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Debug2. . . ' ) ;
        END IF ;

                   INSERT INTO BOM_SUB_OPERATION_RESOURCES
                   ( operation_sequence_id
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
                   -- , original_system_reference
                   -- , setup_id
                   )
                   SELECT
                     p_operation_sequence_id
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
                   , SYSDATE                      --  Last Update Date
                   , BOM_Rtg_Globals.Get_User_Id  --  Last Updated By
                   , SYSDATE                      --  Creation Date
                   , BOM_Rtg_Globals.Get_User_Id  --  Created By
                   , BOM_Rtg_Globals.Get_User_Id  --  Last Update Login
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
                   , NULL                           --  Request Id
                   , BOM_Rtg_Globals.Get_Prog_AppId --  Program Application Id
                   , BOM_Rtg_Globals.Get_Prog_Id    --  Prog id
                   , SYSDATE                        --  Program Update Date
                   , schedule_seq_num
                   , p_eco_name                     --  change_notice
                   , 3                              --  acd_type : Disable
                   -- , original_system_reference
                   -- , setup_id
                   FROM BOM_SUB_OPERATION_RESOURCES
                   WHERE operation_sequence_id = p_old_operation_sequence_id ;

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Debug3. . . ' ) ;
        END IF ;

END Copy_Old_Op_Seq_Children ;





    /*****************************************************************************
    * Procedure : Insert_Row
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : This procedure will insert a record in the Operation Sequence
    *             table; BOM_OPERATION_SEQUENCES.
    *
    *****************************************************************************/
PROCEDURE Insert_Row
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS
    l_Bo_Id               VARCHAR2(3) ;
    l_Eco_For_Production  NUMBER ;

    -- Error Handlig Variables
    l_return_status       VARCHAR2(1);
    l_err_text            VARCHAR2(2000) ;
    l_Mesg_Token_Tbl      Error_Handler.Mesg_Token_Tbl_Type ;


/* Comment out to resolve Eco Bo dependency

    CURSOR l_eco_for_production_csr ( p_revised_item_sequence_id NUMBER )
    IS
       SELECT NVL(eco_for_production, 2)
       FROM   ENG_REVISED_ITEMS
       WHERE  revised_item_sequence_id = p_revised_item_sequence_id ;
*/


BEGIN

   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   l_Bo_Id := BOM_Rtg_Globals.Get_Bo_Identifier ;


/* Comment out to resolve Eco Bo dependency
   IF l_Bo_Id = BOM_Rtg_Globals.G_ECO_BO THEN

IF BOM_Rtg_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Now Eco_For_Production in Parent Revised Item is set to this revised operation');
END IF;

      OPEN l_eco_for_production_csr ( p_revised_item_sequence_id =>
                                      p_com_op_unexp_rec.revised_item_sequence_id
                                     );
      FETCH l_eco_for_production_csr INTO l_Eco_For_Production ;
   END IF ;a
*/


   l_eco_for_production := BOM_Rtg_Globals.Get_Eco_For_Production;

   --bug:3254815 Update request id, prog id, prog appl id and prog update date.
   INSERT  INTO BOM_OPERATION_SEQUENCES(
    operation_sequence_id ,
    routing_sequence_id ,
    operation_seq_num ,
    last_update_date ,
    last_updated_by ,
    creation_date ,
    created_by ,
    last_update_login ,
    standard_operation_id ,
    department_id ,
    operation_lead_time_percent ,
    minimum_transfer_quantity ,
    count_point_type ,
    operation_description ,
    effectivity_date ,
    disable_date ,
    backflush_flag ,
    option_dependent_flag ,
    attribute_category ,
    attribute1 ,
    attribute2 ,
    attribute3 ,
    attribute4 ,
    attribute5 ,
    attribute6 ,
    attribute7 ,
    attribute8 ,
    attribute9 ,
    attribute10 ,
    attribute11 ,
    attribute12 ,
    attribute13 ,
    attribute14 ,
    attribute15 ,
    request_id ,
    program_application_id ,
    program_id ,
    program_update_date ,
    operation_type ,
    reference_flag ,
    process_op_seq_id ,
    line_op_seq_id ,
    yield ,
    cumulative_yield ,
    reverse_cumulative_yield ,
    -- labor_time_calc ,
    -- machine_time_calc ,
    -- total_time_calc ,
    labor_time_user ,
    machine_time_user ,
    total_time_user ,
    net_planning_percent ,
    include_in_rollup ,
    operation_yield_enabled ,
    change_notice ,
    implementation_date ,
    old_operation_sequence_id ,
    acd_type  ,
    revised_item_sequence_id ,
    original_system_reference ,
    eco_for_production ,
    shutdown_type   -- Added by MK for eAM changes
    , long_description, -- Added for long description project (Bug 2689249)
    lowest_acceptable_yield,  -- Added for MES Enhancement
    use_org_settings,
    queue_mandatory_flag,
    run_mandatory_flag,
    to_move_mandatory_flag,
    show_next_op_by_default,
    show_scrap_code,
    show_lot_attrib,
    track_multiple_res_usage_dates  -- End of MES Changes
     )
  VALUES (
      p_com_op_unexp_rec.operation_sequence_id
    , p_com_op_unexp_rec.routing_sequence_id
    , p_com_operation_rec.operation_sequence_number
    , SYSDATE                      --  Last Update Date
    , BOM_Rtg_Globals.Get_User_Id  --  Last Updated By
    , SYSDATE                      --  Creation Date
    , BOM_Rtg_Globals.Get_User_Id  --  Created By
    , BOM_Rtg_Globals.Get_Login_Id --  Last Update Login
    , p_com_op_unexp_rec.standard_operation_id
    , p_com_op_unexp_rec.department_id
    , p_com_operation_rec.op_lead_time_percent
    , p_com_operation_rec.minimum_transfer_quantity
    , p_com_operation_rec.count_point_type
    , p_com_operation_rec.operation_description
    , p_com_operation_rec.start_effective_date
    , p_com_operation_rec.disable_date
    , p_com_operation_rec.backflush_flag
    , p_com_operation_rec.option_dependent_flag
    , p_com_operation_rec.attribute_category
    , p_com_operation_rec.attribute1
    , p_com_operation_rec.attribute2
    , p_com_operation_rec.attribute3
    , p_com_operation_rec.attribute4
    , p_com_operation_rec.attribute5
    , p_com_operation_rec.attribute6
    , p_com_operation_rec.attribute7
    , p_com_operation_rec.attribute8
    , p_com_operation_rec.attribute9
    , p_com_operation_rec.attribute10
    , p_com_operation_rec.attribute11
    , p_com_operation_rec.attribute12
    , p_com_operation_rec.attribute13
    , p_com_operation_rec.attribute14
    , p_com_operation_rec.attribute15
    , Fnd_Global.Conc_Request_Id     -- Request Id
    , BOM_Rtg_Globals.Get_Prog_AppId -- Application Id
    , BOM_Rtg_Globals.Get_Prog_Id    -- Program Id
    , SYSDATE                        -- program_update_date
    , p_com_operation_rec.operation_type
    , p_com_operation_rec.reference_flag
    , p_com_op_unexp_rec.process_op_seq_id
    , p_com_op_unexp_rec.line_op_seq_id
    , p_com_operation_rec.yield
    , p_com_operation_rec.cumulative_yield
    , p_com_operation_rec.reverse_CUM_yield
    -- , p_com_operation_rec.calculated_labor_time
    -- , p_com_operation_rec.calculated_machine_time
    -- , p_com_operation_rec.calculated_elapsed_time
    , p_com_operation_rec.user_labor_time
    , p_com_operation_rec.user_machine_time
    , p_com_op_unexp_rec.user_elapsed_time
    , p_com_operation_rec.net_planning_percent
    -- , p_com_operation_rec.include_in_rollup
    -- , p_com_operation_rec.op_yield_enabled_flag
    , NVL(p_com_operation_rec.include_in_rollup, 1)
    , NVL(p_com_operation_rec.op_yield_enabled_flag,1)
    -- For bugfix 1744254, revop does not have these cols
    , p_com_operation_rec.eco_name
    , DECODE( l_Bo_Id, BOM_Rtg_Globals.G_RTG_BO, SYSDATE, NULL ) -- Implementation Date
    , p_com_op_unexp_rec.old_operation_sequence_id
    , p_com_operation_rec.acd_type
    , p_com_op_unexp_rec.revised_item_sequence_id
    , p_com_operation_rec.original_system_reference
    , l_Eco_For_Production
      -- DECODE( l_Bo_Id, BOM_Rtg_Globals.G_ECO_BO, l_Eco_For_Production, 2) -- Eco for Production flag
    , p_com_operation_rec.shutdown_type -- Added by MK for eAM changes
    , p_com_operation_rec.long_description -- Added for long description project (Bug 2689249)
    , p_com_op_unexp_rec.lowest_acceptable_yield  -- Added for MES Enhancement
    , p_com_op_unexp_rec.use_org_settings
    , p_com_op_unexp_rec.queue_mandatory_flag
    , p_com_op_unexp_rec.run_mandatory_flag
    , p_com_op_unexp_rec.to_move_mandatory_flag
    , p_com_op_unexp_rec.show_next_op_by_default
    , p_com_op_unexp_rec.show_scrap_code
    , p_com_op_unexp_rec.show_lot_attrib
    , p_com_op_unexp_rec.track_multiple_res_usage_dates  -- End of MES Changes
    );

IF BOM_Rtg_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Operation : '|| to_char(p_com_op_unexp_rec.operation_sequence_id)
                                ||' has been created. ' );
END IF;



    IF  p_com_op_unexp_rec.operation_sequence_id IS NOT NULL
    AND NVL(p_com_operation_rec.acd_type , 1 ) = 1 -- Acd Type : ADD
    THEN
    --
    -- Copy Standard Operation Resources
    --
        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Copy Standard Operation Resources. . . ' ) ;
        END IF ;

    IF p_com_operation_rec.reference_flag = 1 OR (p_com_operation_rec.reference_flag = 2 AND nvl(BOM_Globals.Get_Caller_Type, '') <> 'MIGRATION') THEN
         Copy_Std_Res_and_Docs
         (  p_operation_sequence_id =>
                p_com_op_unexp_rec.operation_sequence_id
          , p_std_operation_id      =>
                p_com_op_unexp_rec.standard_operation_id
          , p_change_notice         =>
                p_com_operation_rec.Eco_Name
         ) ;
    END IF;

    ELSIF  NVL(p_com_operation_rec.acd_type , 1 ) = 3 -- Acd Type : Disable
    AND    l_Bo_Id =  BOM_Rtg_Globals.G_ECO_BO
    THEN
    --
    -- Copy Old Operation childeren when Rev Op's Acd type is disable
    --
        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Copy Operation Resources of Old Rev Operation when the Acd Type is disable. . . ' ) ;
        END IF ;

         Copy_Old_Op_Seq_Children
         (  p_operation_sequence_id =>
                p_com_op_unexp_rec.operation_sequence_id
         ,  p_old_operation_sequence_id =>
                p_com_op_unexp_rec.old_operation_sequence_id
         ,  p_eco_name              =>
                p_com_operation_rec.eco_name
         ) ;

    END IF ;



EXCEPTION

    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Insert . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Operation Insert) ' ||
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

END Insert_Row ;


    /***************************************************************************
    * Procedure : Update_Row
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Update_Row procedure will update the production record with
    *         the user given values. Any errors will be returned by filling
    *         the Mesg_Token_Tbl and setting the return_status.
    ****************************************************************************/
PROCEDURE Update_Row
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_Token_Tbl       Error_Handler.Token_Tbl_Type;

BEGIN

   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;


   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Performing update operation . . .') ;
   END IF ;

   UPDATE BOM_OPERATION_SEQUENCES
   SET  operation_seq_num           = DECODE(p_com_operation_rec.new_operation_sequence_number ,
                                        NULL , p_com_operation_rec.operation_sequence_number ,
                                        p_com_operation_rec.new_operation_sequence_number
                                        )
    ,    last_update_date            = SYSDATE                  /* Last Update Date */
    ,    last_updated_by             = BOM_Rtg_Globals.Get_User_Id  /* Last Updated By */
    ,    last_update_login           = BOM_Rtg_Globals.Get_Login_Id /* Last Update Login */
    ,    standard_operation_id       = p_com_op_unexp_rec.standard_operation_id
    ,    department_id               = p_com_op_unexp_rec.department_id
    ,    operation_lead_time_percent = p_com_operation_rec.op_lead_time_percent
    ,    minimum_transfer_quantity   = p_com_operation_rec.minimum_transfer_quantity
    ,    count_point_type            = p_com_operation_rec.count_point_type
    ,    operation_description       = p_com_operation_rec.operation_description
    ,    effectivity_date            = DECODE(p_com_operation_rec.new_start_effective_date ,
                                              NULL , p_com_operation_rec.start_effective_date ,
                                              p_com_operation_rec.new_start_effective_date
                                       )
    ,    disable_date                = p_com_operation_rec.disable_date
    ,    backflush_flag              = p_com_operation_rec.backflush_flag
    ,    option_dependent_flag       = p_com_operation_rec.option_dependent_flag
    ,    attribute_category          = p_com_operation_rec.attribute_category
    ,    attribute1                  = p_com_operation_rec.attribute1
    ,    attribute2                  = p_com_operation_rec.attribute2
    ,    attribute3                  = p_com_operation_rec.attribute3
    ,    attribute4                  = p_com_operation_rec.attribute4
    ,    attribute5                  = p_com_operation_rec.attribute5
    ,    attribute6                  = p_com_operation_rec.attribute6
    ,    attribute7                  = p_com_operation_rec.attribute7
    ,    attribute8                  = p_com_operation_rec.attribute8
    ,    attribute9                  = p_com_operation_rec.attribute9
    ,    attribute10                 = p_com_operation_rec.attribute10
    ,    attribute11                 = p_com_operation_rec.attribute11
    ,    attribute12                 = p_com_operation_rec.attribute12
    ,    attribute13                 = p_com_operation_rec.attribute13
    ,    attribute14                 = p_com_operation_rec.attribute14
    ,    attribute15                 = p_com_operation_rec.attribute15
    ,    program_application_id      = BOM_Rtg_Globals.Get_Prog_AppId /* Application Id */
    ,    program_id                  = BOM_Rtg_Globals.Get_Prog_Id    /* Program Id */
    ,    program_update_date         = SYSDATE                    /* program_update_date */
    ,    reference_flag              = p_com_operation_rec.reference_flag
    ,    process_op_seq_id           = p_com_op_unexp_rec.process_op_seq_id
    ,    line_op_seq_id              = p_com_op_unexp_rec.line_op_seq_id
    ,    yield                       = p_com_operation_rec.yield
    ,    cumulative_yield            = p_com_operation_rec.cumulative_yield
    ,    reverse_cumulative_yield    = p_com_operation_rec.reverse_CUM_yield
    -- ,    labor_time_calc             = p_com_operation_rec.calculated_labor_time
    -- ,    machine_time_calc           = p_com_operation_rec.calculated_machine_time
    -- ,    total_time_calc             = p_com_operation_rec.calculated_elapsed_time
    ,    labor_time_user             = p_com_operation_rec.user_labor_time
    ,    machine_time_user           = p_com_operation_rec.user_machine_time
    ,    total_time_user             = p_com_op_unexp_rec.user_elapsed_time
    ,    net_planning_percent        = p_com_operation_rec.net_planning_percent
    -- ,    include_in_rollup           = p_com_operation_rec.include_in_rollup
    -- ,    operation_yield_enabled     = p_com_operation_rec.op_yield_enabled_flag
    ,    include_in_rollup           = NVL(p_com_operation_rec.include_in_rollup,1)
    ,    operation_yield_enabled     = NVL(p_com_operation_rec.op_yield_enabled_flag,1)
                                       -- For bugfix 1744254, RevOp does not have these cols
    ,    acd_type                    = p_com_operation_rec.acd_type
    ,    original_system_reference   = p_com_operation_rec.original_system_reference
    ,    shutdown_type               = p_com_operation_rec.shutdown_type -- Added by MK for eAM changes
    ,    long_description            = p_com_operation_rec.long_description -- Added for long description (Bug 2689249)
    ,    request_id                  = Fnd_Global.Conc_Request_Id
   WHERE operation_sequence_id = p_com_op_unexp_rec.operation_sequence_id ;


   UPDATE BOM_INVENTORY_COMPONENTS bic
   SET    bic.operation_lead_time_percent = p_com_operation_rec.op_lead_time_percent
        , bic.LAST_UPDATE_DATE    = SYSDATE
        , bic.LAST_UPDATED_BY     = BOM_Rtg_Globals.Get_User_Id
        , bic.LAST_UPDATE_LOGIN   = BOM_Rtg_Globals.Get_Login_Id
        , bic.REQUEST_ID          = Fnd_Global.Conc_Request_Id
        , bic.PROGRAM_ID          = Fnd_Global.Conc_Program_Id
        , bic.PROGRAM_APPLICATION_ID = Fnd_Global.Prog_Appl_Id
        , bic.PROGRAM_UPDATE_DATE = SYSDATE
   WHERE  bic.operation_seq_num = p_com_operation_rec.operation_sequence_number
   AND    bic.bill_sequence_id  = (SELECT  bom.BILL_SEQUENCE_ID
                                   FROM    BOM_BILL_OF_MATERIALS bom
                                         , bom_operational_routings bor
                                   WHERE NVL(bor.alternate_routing_designator, 'NONE')
                                               =  nvl(bom.alternate_bom_designator,'NONE')
                                   AND   bom.assembly_item_id = bor.assembly_item_id
                                   AND   bom.organization_id  = bor.organization_id
                                   AND   bor.routing_sequence_id = p_com_op_unexp_rec.routing_sequence_id) ;

   IF SQL%FOUND THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
              ('Operation lead time in bom inventory components refered Operation Seq Num is updated.') ;
      END IF ;

      --
      -- Log Warning Message
      --
      l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
      l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;

      Error_Handler.Add_Error_Token
      (  p_message_name   => 'BOM_OP_LT_PCT_UPDATED'
       , p_mesg_token_tbl => l_mesg_token_Tbl
       , x_mesg_token_tbl => l_mesg_token_tbl
       , p_message_type   => 'W' /* Warning */
       , p_Token_Tbl      => l_Token_Tbl
      ) ;
   END IF ;


EXCEPTION
    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Update . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Operation Update) ' ||
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

END Update_Row ;


    /********************************************************************
    * Procedure     : Delete_Row
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose       : For ECO BO, procedure will delete a revised operation
    *                 record for a ECO.
    *                 This procedure will not delete a record in production
    *                 which is already implemented.
    *                 For RTG BO, Procedure will perfrom an Delete from the
    *                 BOM_Operation_Sequences by creating a delete Group.
    *********************************************************************/
PROCEDURE Delete_Row
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_com_operation_rec     IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
         , x_com_op_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
IS

    l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
    l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
    l_dg_sequence_id         NUMBER;


    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_Token_Tbl       Error_Handler.Token_Tbl_Type;
    l_rtg_type        NUMBER;



    -- Check Delete Group
    CURSOR l_del_grp_csr  ( p_del_group_name    VARCHAR2
                          , p_organization_id NUMBER )
    IS
       SELECT   description
              , delete_group_sequence_id
              , delete_type
       FROM   BOM_DELETE_GROUPS
       WHERE  delete_group_name   = p_del_group_name
       AND    organization_id     = p_organization_id ;

   -- Exception
   DUPLICATE_DEL_GROUP EXCEPTION ;

BEGIN
   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   --
   -- Initialize Common Record and Status
   --
   l_com_operation_rec  := p_com_operation_rec ;
   l_com_op_unexp_rec   := p_com_op_unexp_rec ;


   IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
   THEN

      DELETE  FROM BOM_OPERATION_SEQUENCES
      WHERE   OPERATION_SEQUENCE_ID = l_com_op_unexp_rec.operation_sequence_id ;


      DELETE FROM BOM_OPERATION_RESOURCES
      WHERE   OPERATION_SEQUENCE_ID = l_com_op_unexp_rec.operation_sequence_id ;


      /******************************************************************
      -- Also delete the operation resources and substitute resources
      -- by first logging a warning notifying the user of the cascaded
      -- Delete.
      *******************************************************************/

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         AND SQL%FOUND
      -- This is a warning.
      THEN
         l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
         l_Token_Tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;

         Error_Handler.Add_Error_Token
         (  p_Message_Name   => 'BOM_OP_DEL_CHILDREN'
          , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
          , p_Token_Tbl      => l_Token_Tbl
          , p_message_type   => 'W'
         ) ;
      END IF;


      DELETE FROM BOM_SUB_OPERATION_RESOURCES
      WHERE   OPERATION_SEQUENCE_ID = l_com_op_unexp_rec.operation_sequence_id ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Finished deleting revised operation record . . .') ;
END IF ;


   ELSIF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO
   THEN
      FOR l_del_grp_rec IN l_del_grp_csr
                 ( p_del_group_name   =>  l_com_operation_rec.delete_group_name
                 , p_organization_id  =>  l_com_op_unexp_rec.organization_id   )
      LOOP
         IF l_del_grp_rec.delete_type <> 5 /* Operation */
         THEN
            RAISE DUPLICATE_DEL_GROUP ;
         END IF ;

         --
         -- If Delete Group for Opetaion exists, Set Delete Group Sequence Id
         -- and Description to Unexposed Column
         --
         l_com_op_unexp_rec.DG_Sequence_Id  := l_del_grp_rec.delete_group_sequence_id ;
         l_com_op_unexp_rec.DG_Description  := l_del_grp_rec.description ;

      END LOOP;

      IF  l_com_op_unexp_rec.DG_Sequence_Id <> FND_API.G_MISS_NUM
      THEN
          l_dg_sequence_id := l_com_op_unexp_rec.DG_Sequence_Id;
      ELSE
          --
          -- If l_dg_seqeunce_id is Null, Modal_Delete.Delte_Manager procedure
          -- would create New Delete Group
          --
          l_dg_sequence_id := NULL;

           Error_Handler.Add_Error_Token
            (  p_message_name   => 'NEW_DELETE_GROUP'
             , p_mesg_token_tbl => l_mesg_token_Tbl
             , x_mesg_token_tbl => l_mesg_token_tbl
             , p_message_type   => 'W' /* Warning */
            ) ;

      END IF;


      IF l_com_operation_rec.alternate_routing_code = FND_API.G_MISS_CHAR THEN
         l_com_operation_rec.alternate_routing_code := NULL ;
      END IF ;

-- bug 5199643
     select routing_type into l_rtg_type from bom_operational_routings
     where routing_sequence_id = l_com_op_unexp_rec.routing_sequence_id;


      l_dg_sequence_id :=
      MODAL_DELETE.DELETE_MANAGER
                (  new_group_seq_id        => l_dg_sequence_id,
                   name                    => l_com_operation_rec.Delete_Group_Name,
                   group_desc              => l_com_operation_rec.dg_description,
                   org_id                  => l_com_op_unexp_rec.organization_id,
                   bom_or_eng              => l_rtg_type /* bug 5199643 */,
                   del_type                => 5 /* Operation */,
                   ent_bill_seq_id         => NULL,
                   ent_rtg_seq_id          => l_com_op_unexp_rec.routing_sequence_id,
                   ent_inv_item_id         => l_com_op_unexp_rec.revised_item_id,
                   ent_alt_designator      => l_com_operation_rec.alternate_routing_code,
                   ent_comp_seq_id         => NULL,
                   ent_op_seq_id           => l_com_op_unexp_rec.operation_sequence_id ,
                   user_id                 => BOM_Rtg_Globals.Get_User_Id
                 ) ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Finished creatin new delete group . . .') ;
END IF ;

   END IF ;

   -- Return records
   x_com_operation_rec  := l_com_operation_rec ;
   x_com_op_unexp_rec   := l_com_op_unexp_rec ;

   -- Return the status and message table.
   x_return_status      := l_return_status;
   x_mesg_token_tbl     := l_mesg_token_tbl;


EXCEPTION
    WHEN DUPLICATE_DEL_GROUP THEN

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Duplicate Delete Group Error occured in Delete . . .' || SQLERRM);
       END IF;


       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN

          Error_Handler.Add_Error_Token
          (  p_message_name   => 'BOM_DUPLICATE_DELETE_GROUP'
           , p_mesg_token_tbl =>  l_mesg_token_Tbl
           , x_mesg_token_tbl =>  l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return records
       x_com_operation_rec  := l_com_operation_rec ;
       x_com_op_unexp_rec   := l_com_op_unexp_rec ;

       -- Return the status and message table.
       x_return_status  := FND_API.G_RET_STS_ERROR;
       x_mesg_token_tbl := l_mesg_token_tbl;

    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Delete . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Operation Delete) ' ||
                                        SUBSTR(SQLERRM, 1, 200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return records
       x_com_operation_rec  := l_com_operation_rec ;
       x_com_op_unexp_rec   := l_com_op_unexp_rec ;

       -- Return the status and message table.
       x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Delete_Row ;



    /********************************************************************
    * Procedure     : Cancel_Operaiton
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose       : This procedure will move revised operation to Eng Revised
    *                 Operation table and set cansel information.
    *                 Also it will delte any child operation resources and sub
    *                 operation resources.
    *********************************************************************/
PROCEDURE Cancel_Operation
( p_operation_sequence_id  IN  NUMBER
, p_cancel_comments        IN  VARCHAR2
, p_op_seq_num             IN  NUMBER
, p_user_id                IN  NUMBER
, p_login_id               IN  NUMBER
, p_prog_id                IN  NUMBER
, p_prog_appid             IN  NUMBER
, x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status          IN OUT NOCOPY VARCHAR2
)


IS

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_Token_Tbl       Error_Handler.Token_Tbl_Type;


BEGIN
null;
/* commenting this procedure for the release 11i.4 to remove dependancy
   on the eng odf.This is because the RTG and ECO objects should be
   independant of each other. But commenting out because we will reuse it
   in release 12 when these all files alongwith the odf will be base

   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Performing cancel revised operation : '
                                 || to_char(p_operation_sequence_id) || '  . . .') ;
   END IF ;

   --
   -- Insert the cancelled revised operation into
   -- ENG_REVISED_OPERATIONS
   --
   INSERT INTO ENG_REVISED_OPERATIONS (
                   operation_sequence_id
                 , routing_sequence_id
                 , operation_seq_num
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , standard_operation_id
                 , department_id
                 , operation_lead_time_percent
                 , minimum_transfer_quantity
                 , count_point_type
                 , operation_description
                 , effectivity_date
                 , disable_date
                 , backflush_flag
                 , option_dependent_flag
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
                 , operation_type
                 , reference_flag
                 , process_op_seq_id
                 , line_op_seq_id
                 , yield
                 , cumulative_yield
                 , reverse_cumulative_yield
                 , labor_time_calc
                 , machine_time_calc
                 , total_time_calc
                 , labor_time_user
                 , machine_time_user
                 , total_time_user
                 , net_planning_percent
                 , x_coordinate
                 , y_coordinate
                 , include_in_rollup
                 , operation_yield_enabled
                 , change_notice
                 , implementation_date
                 , old_operation_sequence_id
                 , acd_type
                 , revised_item_sequence_id
                 , cancellation_date
                 , cancel_comments
                 , original_system_reference )
          SELECT
                   OPERATION_SEQUENCE_ID
                 , routing_sequence_id
                 , OPERATION_SEQ_NUM
                 , SYSDATE                  --  Last Update Date
                 , p_user_id                --  Last Updated By
                 , SYSDATE                  --  Creation Date
                 , p_user_id                --  Created By
                 , p_login_id               --  Last Update Login
                 , STANDARD_OPERATION_ID
                 , DEPARTMENT_ID
                 , OPERATION_LEAD_TIME_PERCENT
                 , MINIMUM_TRANSFER_QUANTITY
                 , COUNT_POINT_TYPE
                 , OPERATION_DESCRIPTION
                 , EFFECTIVITY_DATE
                 , DISABLE_DATE
                 , BACKFLUSH_FLAG
                 , OPTION_DEPENDENT_FLAG
                 , ATTRIBUTE_CATEGORY
                 , ATTRIBUTE1
                 , ATTRIBUTE2
                 , ATTRIBUTE3
                 , ATTRIBUTE4
                 , ATTRIBUTE5
                 , ATTRIBUTE6
                 , ATTRIBUTE7
                 , ATTRIBUTE8
                 , ATTRIBUTE9
                 , ATTRIBUTE10
                 , ATTRIBUTE11
                 , ATTRIBUTE12
                 , ATTRIBUTE13
                 , ATTRIBUTE14
                 , ATTRIBUTE15
                 , NULL                       --  Request Id
                 , p_prog_appid               --  Application Id
                 , p_prog_id                  --  Program Id
                 , SYSDATE                    --  program_update_date
                 , OPERATION_TYPE
                 , REFERENCE_FLAG
                 , PROCESS_OP_SEQ_ID
                 , LINE_OP_SEQ_ID
                 , YIELD
                 , CUMULATIVE_YIELD
                 , REVERSE_CUMULATIVE_YIELD
                 , LABOR_TIME_CALC
                 , MACHINE_TIME_CALC
                 , TOTAL_TIME_CALC
                 , LABOR_TIME_USER
                 , MACHINE_TIME_USER
                 , TOTAL_TIME_USER
                 , NET_PLANNING_PERCENT
                 , X_COORDINATE
                 , Y_COORDINATE
                 , INCLUDE_IN_ROLLUP
                 , OPERATION_YIELD_ENABLED
                 , CHANGE_NOTICE
                 , IMPLEMENTATION_DATE
                 , OLD_OPERATION_SEQUENCE_ID
                 , ACD_TYPE
                 , REVISED_ITEM_SEQUENCE_ID
                 , SYSDATE                    -- Cancellation Date
                 , p_cancel_comments          -- Cancel Comments
                 , ORIGINAL_SYSTEM_REFERENCE
         FROM    BOM_OPERATION_SEQUENCES
         WHERE   operation_sequence_id = p_operation_sequence_id ;


   --
   -- Delete Cancel Revisd Operation from operation table
   --
    DELETE FROM BOM_OPERATION_SEQUENCES
    WHERE  operation_sequence_id = p_operation_sequence_id ;

   --
   -- Delete child Operation Resources
   --
    DELETE FROM BOM_OPERATION_RESOURCES
    WHERE  operation_sequence_id = p_operation_sequence_id ;


    IF SQL%FOUND THEN

         --
         -- Log a warning indicating operation resources and
         -- substitute operation resources also get deleted.
         --
         -- l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
         -- l_Token_Tbl(1).token_value := p_op_seq_num ;

         Error_Handler.Add_Error_Token
          (   p_Message_Name       => 'BOM_OP_CANCEL_DEL_CHILDREN'
            , p_Message_Text       => NULL
            , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_Token_Tbl          => l_Token_Tbl
            , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_message_type       => 'W'
          ) ;

    END IF ;


    --
    -- Delete child Sub Operation Resources
    --
    DELETE FROM BOM_SUB_OPERATION_RESOURCES
    WHERE  operation_sequence_id = p_operation_sequence_id ;

   -- Return Token
    x_mesg_token_tbl := l_mesg_token_tbl ;


EXCEPTION
    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Cancel . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Operation Cancel) ' ||
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
*/
END Cancel_Operation ;

END BOM_Op_Seq_UTIL ;

/
