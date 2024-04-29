--------------------------------------------------------
--  DDL for Package Body BOM_RTG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_PVT" AS
/* $Header: BOMRPVTB.pls 120.3 2006/05/23 05:01:57 bbpatel noship $*/
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMRPVTB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Rtg_Pvt
--
--  NOTES
--
--  HISTORY
--
--  02-AUG-1999 Biao Zhang      Initial Creation
--
--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'Bom_Rtg_Pvt';
G_EXC_QUIT_IMPORT       EXCEPTION;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_SEV_QUIT_OBJECT     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;

--  Operation_Resources

/****************************************************************************
* Procedure : Operation_Resources
* Parameters IN   : Operation Resources Table and all the other sibiling entities
* Parameters OUT  : Operatin Resources and all the other sibiling entities
* Purpose   : This procedure will process all the Operation Resources records.
*
*****************************************************************************/

PROCEDURE Operation_Resources
(   p_validation_level        IN  NUMBER
,   p_organization_id         IN  NUMBER
,   p_assembly_item_name      IN  VARCHAR2
,   p_alternate_routing_code  IN  VARCHAR2
,   p_operation_seq_num       IN  NUMBER
,   p_effectivity_date        IN  DATE
,   p_operation_type          IN  NUMBER
,   p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
,   p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
,   x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status           IN OUT NOCOPY VARCHAR2
)

IS

/* Exposed and Unexposed record */
l_op_resource_rec         Bom_Rtg_Pub.Op_Resource_Rec_Type ;
l_op_res_unexp_rec        Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type ;
l_op_resource_tbl         Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
l_old_op_resource_rec     Bom_Rtg_Pub.Op_Resource_Rec_Type ;
l_old_op_res_unexp_rec    Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type ;

/* Other Entities */
l_rtg_header_rec        Bom_Rtg_Pub.Rtg_Header_Rec_Type ;
l_rtg_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
l_operation_tbl         Bom_Rtg_Pub.Operation_Tbl_Type ;
l_sub_resource_tbl      Bom_Rtg_Pub.Sub_Resource_Tbl_Type  := p_sub_resource_tbl ;
l_op_network_tbl        Bom_Rtg_Pub.Op_Network_Tbl_Type ;

/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type ;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);


/* Others */
l_return_status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_op_parent_exists      BOOLEAN := FALSE ;
l_rtg_parent_exists     BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid                 BOOLEAN := TRUE;
l_temp_op_rec		BOM_RTG_Globals.Temp_Op_Rec_Type;

BEGIN

   --  Init local table variables.
   l_return_status    := 'S';
   l_bo_return_status := 'S';
   l_op_resource_tbl  := p_op_resource_tbl ;
   l_op_res_unexp_rec.organization_id := BOM_Rtg_Globals.Get_Org_Id ;
   FOR I IN 1..l_op_resource_tbl.COUNT LOOP
   BEGIN

      --  Load local records
      l_op_resource_rec := l_op_resource_tbl(I) ;

      l_op_resource_rec.transaction_type :=
         UPPER(l_op_resource_rec.transaction_type) ;

      --
      -- make sure to set process_children to false at the start of
      -- every iteration
      --
      l_process_children := FALSE;

      --
      -- Initialize the Unexposed Record for every iteration of the Loop
      -- so that sequence numbers get generated for every new row.
      --
      l_op_res_unexp_rec.Operation_Sequence_Id   := NULL ;
      l_op_res_unexp_rec.Substitute_Group_Number := l_op_resource_rec.Substitute_Group_Number ;
      l_op_res_unexp_rec.Resource_Id             := NULL ;
      l_op_res_unexp_rec.Activity_Id             := NULL ;
      l_op_res_unexp_rec.Setup_Id                := NULL ;


      IF p_operation_seq_num  IS NOT NULL AND
         p_assembly_item_name IS NOT NULL AND
         p_effectivity_date   IS NOT NULL AND
         p_organization_id    IS NOT NULL
      THEN
         -- Revised Operation or Operation Sequence parent exists
         l_op_parent_exists  := TRUE ;

      ELSIF p_assembly_item_name IS NOT NULL AND
            p_organization_id    IS NOT NULL
      THEN
         -- Revised Item or Routing parent exists
         l_rtg_parent_exists := TRUE ;
      END IF ;

	 -- If effectivity/op seq num of the parent operation has changed, update the child resource record
      IF BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag
      AND BOM_RTG_Globals.Get_Temp_Op_Rec1
          ( l_op_resource_rec.operation_sequence_number
	  , p_effectivity_date -- this cannot be null as this check is done only when the op has children
	  , l_temp_op_rec) THEN
	 l_op_resource_rec.operation_sequence_number := l_temp_op_rec.new_op_seq_num;
	 l_op_resource_rec.op_start_effective_Date := l_temp_op_rec.new_start_eff_date;
/*
		Bom_Default_Op_Res.Init_Eff_Date_Op_Seq_Num
		( p_op_seq_num	=> p_operation_seq_num
		, p_eff_date	=> p_effectivity_date
		, p_op_res_rec	=> l_op_resource_rec
		, x_op_res_rec	=> l_op_resource_rec
		);
*/
      END IF;


      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF (l_op_resource_rec.return_status IS NULL OR
          l_op_resource_rec.return_status  = FND_API.G_MISS_CHAR)
         AND
         (
            -- Did Op_Seq call this procedure, that is,
            -- if revised operation(operation sequence) exists, then is this record a child ?
            (l_op_parent_exists AND
               (l_op_resource_rec.assembly_item_name = p_assembly_item_name AND
                l_op_res_unexp_rec.organization_id = p_organization_id      AND
                NVL(l_op_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR)
                           = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR) AND
                l_op_resource_rec.operation_sequence_number
                                                      = p_operation_seq_num AND
                l_op_resource_rec.op_start_effective_date
                                                      = p_effectivity_date  AND
                NVL(l_op_resource_rec.operation_type, 1)
                                                      = NVL(p_operation_type, 1)
               )
            )
            OR
            -- Did Rtg_Header call this procedure, that is,
            -- if revised item or routing header exists, then is this record a child ?
            (l_rtg_parent_exists AND
               (l_op_resource_rec.assembly_item_name = p_assembly_item_name AND
               l_op_res_unexp_rec.organization_id    = p_organization_id    AND
               NVL(l_op_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR)
                               = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)
               )
            )
           OR
           (NOT l_rtg_parent_exists AND NOT l_op_parent_exists)
         )
      THEN
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_op_resource_rec.return_status := FND_API.G_RET_STS_SUCCESS;

         --
         -- Process Flow step 3 :Check if transaction_type is valid
         -- Transaction_Type must be CRATE, UPDATE, DELETE or CANCEL(in only ECO for Rrg)
         -- Call the BOM_Rtg_Globals.Transaction_Type_Validity
         --
         BOM_Rtg_Globals.Transaction_Type_Validity
         (   p_transaction_type => l_op_resource_rec.transaction_type
         ,   p_entity           => 'Op_Res'
         ,   p_entity_id        => l_op_resource_rec.resource_sequence_number
         ,   x_valid            => l_valid
         ,   x_mesg_token_tbl   => l_mesg_token_tbl
         ) ;

         IF NOT l_valid
         THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         --
         -- Process Flow step 4(a): Convert user unique index to unique
         -- index I
         -- Call BOM_Rtg_Val_To_Id.Op_Resource_UUI_To_UI Shared Utility Package
         --
	 BOM_Rtg_Val_To_Id.Op_Resource_UUI_To_UI
         ( p_op_resource_rec    => l_op_resource_rec
         , p_op_res_unexp_rec   => l_op_res_unexp_rec
         , x_op_res_unexp_rec   => l_op_res_unexp_rec
         , x_mesg_token_tbl     => l_mesg_token_tbl
         , x_return_status      => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_RES_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_op_resource_rec.resource_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;

/*       --
         -- Process Flow step 4(b): Convert user unique index to unique
         -- index II
         -- Call the BOM_Rtg_Val_To_Id.Operation_UUI_To_UI2
         --

         BOM_Rtg_Val_To_Id.Op_Resource_UUI_To_UI2
         ( p_op_resource_rec    => l_op_resource_rec
         , p_op_res_unexp_rec   => l_op_res_unexp_rec
         , x_op_res_unexp_rec   => l_op_res_unexp_rec
         , x_mesg_token_tbl     => l_mesg_token_tbl
         , x_other_message      => l_other_message
         , x_other_token_tbl    => l_other_token_tbl
         , x_return_status      => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index2 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            RAISE EXC_SEV_QUIT_SIBLINGS ;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                   l_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;
*/
         --
         -- Process Flow step 5: Verify Operation Resource's existence
         -- Call the Bom_Validate_Op_Seq.Check_Existence
         --
         --
         Bom_Validate_Op_Res.Check_Existence
         (  p_op_resource_rec        => l_op_resource_rec
         ,  p_op_res_unexp_rec       => l_op_res_unexp_rec
         ,  x_old_op_resource_rec    => l_old_op_resource_rec
         ,  x_old_op_res_unexp_rec   => l_old_op_res_unexp_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;


         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check Existence completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_RES_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
            l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_op_resource_rec.assembly_item_name ;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
            l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_op_resource_rec.assembly_item_name ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

         --
         -- Process Flow step 6: Is Operation Resource record an orphan ?
         --

         IF NOT l_op_parent_exists
         THEN

            --
            -- Process Flow step 7 : Check Assembly Item Operability for Routing
            -- Call Bom_Validate_Rtg_Header.Check_Access
            --

            Bom_Validate_Rtg_Header.Check_Access
            ( p_assembly_item_name => l_op_resource_rec.assembly_item_name
            , p_assembly_item_id   => l_op_res_unexp_rec.assembly_item_id
            , p_organization_id    => l_op_res_unexp_rec.organization_id
            , p_mesg_token_tbl     => Error_Handler.G_MISS_MESG_TOKEN_TBL
            , p_alternate_rtg_code => l_op_resource_rec.alternate_routing_code
            , x_mesg_token_tbl     => l_mesg_token_tbl
            , x_return_status      => l_return_status
            ) ;

            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Check Assembly Item Operability completed with return_status: ' || l_return_status) ;
            END IF ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               l_other_message := 'BOM_RES_RITACC_FAT_FATAL';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
               l_return_status := 'F' ;
               RAISE EXC_FAT_QUIT_SIBLINGS ;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_RES_RITACC_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

         END IF; -- l_op_parent_exists

         --
         -- Process Flow step 8 : Check if the parent operation is
         -- non-referencing operation of type: Event
         --
         Bom_Validate_Op_Res.Check_NonRefEvent
         (   p_operation_sequence_id => l_op_res_unexp_rec.operation_sequence_id
          ,  p_operation_type      => l_op_resource_rec.operation_type
          ,  p_entity_processed    => 'RES'
          ,  x_mesg_token_tbl      => l_mesg_token_tbl
          ,  x_return_status       => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Check non-ref operation completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
               IF l_op_resource_rec.operation_type IN (2 , 3) -- Process or Line Op
               THEN

                  l_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
                  l_token_tbl(2).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          l_op_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_RES_OPTYPE_NOT_EVENT'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;
               ELSIF nvl(BOM_Globals.Get_Caller_Type, '') <> 'MIGRATION' THEN
                  l_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
                  l_token_tbl(2).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          l_op_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_RES_MUST_NONREF'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;

               END IF ;

               l_return_status := 'F';
               l_other_message := 'BOM_RES_ACCESS_FAT_FATAL';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
               RAISE EXC_FAT_QUIT_SIBLINGS ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
               l_other_message := 'BOM_RES_ACCESS_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;


         --
         -- Process Flow step 9: Value to Id conversions
         -- Call BOM_Rtg_Val_To_Id.Op_Resource_VID
         --

         BOM_Rtg_Val_To_Id.Op_Resource_VID
         (  p_op_resource_rec        => l_op_resource_rec
         ,  p_op_res_unexp_rec       => l_op_res_unexp_rec
         ,  x_op_res_unexp_rec       => l_op_res_unexp_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         );

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Value-id conversions completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_op_resource_rec.transaction_type = 'CREATE'
            THEN
               l_other_message := 'BOM_RES_VID_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_VID_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <>0
         THEN
/*
            p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
         ,  p_sub_resource_tbl    => Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
*/

            Bom_Rtg_Error_Handler.Log_Error
            (
               p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     => l_op_resource_tbl
            ,  p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_scope         => NULL
            ,  p_error_level         => Error_Handler.G_RES_LEVEL
            ,  p_entity_index        => I
            ,  p_other_message       => NULL
            ,  p_other_mesg_appid    => 'BOM'
            ,  p_other_status        => NULL
            ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
            ) ;
         END IF;

         --
         -- Process Flow step 10 : Check required fields exist
         -- (also includes a part of conditionally required fields)
         --

/*
         Bom_Validate_Op_Res.Check_Required
         ( p_op_resource_rec            => l_op_resource_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;



         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check required completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
            THEN
               l_other_message := 'BOM_RES_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;
*/

         --
         -- Process Flow step 11 : Attribute Validation for CREATE and UPDATE
         -- Call Bom_Validate_Op_Res.Check_Attributes
         --

         IF l_op_resource_rec.transaction_type IN
            (BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
         THEN
            Bom_Validate_Op_Res.Check_Attributes
            ( p_op_resource_rec   => l_op_resource_rec
            , p_op_res_unexp_rec  => l_op_res_unexp_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Attribute validation completed with return_status: ' || l_return_status) ;
            END IF ;


            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               IF l_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               THEN
                  l_other_message := 'BOM_RES_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_op_resource_rec.resource_sequence_number ;
                     RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_RES_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                           l_op_resource_rec.resource_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
               Bom_Rtg_Error_Handler.Log_Error
               (
                  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
               ,  p_op_resource_tbl     => l_op_resource_tbl
               ,  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  p_error_level         => Error_Handler.G_RES_LEVEL
               ,  p_entity_index        => I
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
               ) ;
           END IF;
        END IF;



        IF l_op_resource_rec.transaction_type IN
           (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
        THEN

        --
        -- Process flow step 12: Populate NULL columns for Update and Delete
        -- Call Bom_Default_Op_Res.Populate_Null_Columns
        --

           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns') ;
           END IF ;

             Bom_Default_Op_Res.Populate_Null_Columns
             (   p_op_resource_rec       => l_op_resource_rec
             ,   p_old_op_resource_rec   => l_old_op_resource_rec
             ,   p_op_res_unexp_rec      => l_op_res_unexp_rec
             ,   p_old_op_res_unexp_rec  => l_old_op_res_unexp_rec
             ,   x_op_resource_rec       => l_op_resource_rec
             ,   x_op_res_unexp_rec      => l_op_res_unexp_rec
             ) ;

        ELSIF l_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
        THEN
        --
        -- Process Flow step 13 : Default missing values for Op Resource (CREATE)
        -- Call Bom_Default_Op_Res.Attribute_Defaulting
        --

           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting') ;
           END IF ;

             Bom_Default_Op_Res.Attribute_Defaulting
             (   p_op_resource_rec     => l_op_resource_rec
             ,   p_op_res_unexp_rec    => l_op_res_unexp_rec
             ,   x_op_resource_rec     => l_op_resource_rec
             ,   x_op_res_unexp_rec    => l_op_res_unexp_rec
             ,   x_mesg_token_tbl      => l_mesg_token_tbl
             ,   x_return_status       => l_return_status
             ) ;


           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
              l_other_message := 'BOM_RES_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'BOM_RES_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                           l_op_resource_rec.resource_sequence_number ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
               Bom_Rtg_Error_Handler.Log_Error
               (
                  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
               ,  p_op_resource_tbl     => l_op_resource_tbl
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  p_error_level         => Error_Handler.G_RES_LEVEL
               ,  p_entity_index        => I
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
               ) ;
          END IF;
       END IF;

       --
       -- Process Flow step 14: Conditionally Required Attributes
       --
       --
       /*
       IF l_op_resource_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CREATE
                                                , BOM_Rtg_Globals.G_OPR_UPDATE )
       THEN
          Bom_Validate_Op_Seq.Check_Conditionally_Required
          ( p_op_resource_rec       => l_op_resource_rec
          , p_op_res_unexp_rec      => l_op_res_unexp_rec
          , x_return_status         => l_return_status
          , x_mesg_token_tbl        => l_mesg_token_tbl
          ) ;


          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check Conditionally Required Attr. completed with return_status: ' || l_return_status) ;
          END IF ;


          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_RES_CONREQ_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_RES_CONREQ_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             Bom_Rtg_Error_Handler.Log_Error
             (    p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
               ,  p_op_resource_tbl     => l_op_resource_tbl
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  p_error_level         => Error_Handler.G_RES_LEVEL
               ,  p_entity_index        => I
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
             ) ;
          END IF;
       END IF;
       */

       --
       -- Process Flow step 15: Entity defaulting for CREATE and UPDATE
       --
       IF l_op_resource_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CREATE
                                                , BOM_Rtg_Globals.G_OPR_UPDATE )

       THEN
          Bom_Default_Op_Res.Entity_Defaulting
              (   p_op_resource_rec   => l_op_resource_rec
              ,   p_op_res_unexp_rec  => l_op_res_unexp_rec
              ,   x_op_resource_rec   => l_op_resource_rec
              ,   x_op_res_unexp_rec  => l_op_res_unexp_rec
              ,   x_mesg_token_tbl    => l_mesg_token_tbl
              ,   x_return_status     => l_return_status
              ) ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Entity defaulting completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_RES_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.operation_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_RES_ENTDEF_UNEXP_SKIP';
             l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             Bom_Rtg_Error_Handler.Log_Error
             (
                  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
               ,  p_op_resource_tbl     => l_op_resource_tbl
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  p_error_level         => Error_Handler.G_RES_LEVEL
               ,  p_entity_index        => I
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
             ) ;
          END IF ;
       END IF ;


       --
       -- Process Flow step 16 - Entity Level Validation
       -- Call Bom_Validate_Op_Res.Check_Entity
       --
       Bom_Validate_Op_Res.Check_Entity
          (  p_op_resource_rec       => l_op_resource_rec
          ,  p_op_res_unexp_rec      => l_op_res_unexp_rec
          ,  p_old_op_resource_rec   => l_old_op_resource_rec
          ,  p_old_op_res_unexp_rec  => l_old_op_res_unexp_rec
          ,  x_op_resource_rec       => l_op_resource_rec
          ,  x_op_res_unexp_rec      => l_op_res_unexp_rec
          ,  x_mesg_token_tbl        => l_mesg_token_tbl
          ,  x_return_status         => l_return_status
          ) ;


       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          IF l_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
          THEN
             l_other_message := 'BOM_RES_ENTVAL_CSEV_SKIP';
             l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                           l_op_resource_rec.resource_sequence_number ;
             RAISE EXC_SEV_SKIP_BRANCH ;
          ELSE
             RAISE EXC_SEV_QUIT_RECORD ;
          END IF;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_RES_ENTVAL_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                        l_op_resource_rec.resource_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
       THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
          ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
          ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
          ,  p_op_resource_tbl     => l_op_resource_tbl
          ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
	      ,  p_sub_resource_tbl    => l_sub_resource_tbl
	      ,  p_mesg_token_tbl      => l_mesg_token_tbl
	      ,  p_error_status        => 'W'
          ,  p_error_scope         => NULL
          ,  p_other_message       => NULL
          ,  p_other_mesg_appid    => 'BOM'
          ,  p_other_status        => NULL
          ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
          ,  p_error_level         => Error_Handler.G_RES_LEVEL
          ,  p_entity_index        => I
          ,  x_rtg_header_rec      => l_rtg_header_rec
          ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
          ,  x_op_network_tbl      => l_op_network_tbl
          ,  x_operation_tbl       => l_operation_tbl
          ,  x_op_resource_tbl     => l_op_resource_tbl
          ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;
       END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Entity validation completed with '
             || l_return_Status || ' proceeding for database writes . . . ') ;
END IF;

       --
       -- Process Flow step 17: Database Writes
       --
          SAVEPOINT validate_sgn;
          Bom_Op_Res_Util.Perform_Writes
          (   p_op_resource_rec     => l_op_resource_rec
          ,   p_op_res_unexp_rec    => l_op_res_unexp_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;

       IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_RES_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                          l_op_resource_rec.resource_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl .COUNT <>0
       THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
          ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
          ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
          ,  p_op_resource_tbl     => l_op_resource_tbl
          ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
          ,  p_sub_resource_tbl    => l_sub_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => 'W'
          ,  p_error_scope         => NULL
          ,  p_other_message       => NULL
          ,  p_other_mesg_appid    => 'BOM'
          ,  p_other_status        => NULL
          ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
          ,  p_error_level         => Error_Handler.G_RES_LEVEL
          ,  p_entity_index        => I
          ,  x_rtg_header_rec      => l_rtg_header_rec
          ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
          ,  x_op_network_tbl      => l_op_network_tbl
          ,  x_operation_tbl       => l_operation_tbl
          ,  x_op_resource_tbl     => l_op_resource_tbl
          ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;
       END IF;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Res Database writes completed with status  ' || l_return_status);
       END IF;
       --
       -- Process Flow Step 18: Validate SGN order
       --

       Bom_Validate_Op_Res.Val_SGN_Order
       ( p_op_seq_id      => l_op_res_unexp_rec.operation_sequence_id
       , x_mesg_token_tbl => l_mesg_token_tbl
       , x_return_status  => l_return_status);

       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          ROLLBACK TO validate_sgn;
          RAISE EXC_SEV_QUIT_SIBLINGS;
       END IF;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('validate SGN order completed with status  ' || l_return_status);
       END IF;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_op_resource_tbl(I)          := l_op_resource_rec;


    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
          ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
          ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
          ,  p_op_resource_tbl     => l_op_resource_tbl
          ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
          ,  p_sub_resource_tbl    => l_sub_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => Error_Handler.G_STATUS_ERROR
          ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
          ,  p_other_message       => NULL
          ,  p_other_mesg_appid    => 'BOM'
          ,  p_other_status        => NULL
          ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
          ,  p_error_level         => Error_Handler.G_RES_LEVEL
          ,  p_entity_index        => I
          ,  x_rtg_header_rec      => l_rtg_header_rec
          ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
          ,  x_op_network_tbl      => l_op_network_tbl
          ,  x_operation_tbl       => l_operation_tbl
          ,  x_op_resource_tbl     => l_op_resource_tbl
          ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status := l_return_status ;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;


      WHEN EXC_SEV_QUIT_BRANCH THEN

         Bom_Rtg_Error_Handler.Log_Error
         (
            p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status  := l_return_status;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl := l_sub_resource_tbl ;

      WHEN EXC_SEV_SKIP_BRANCH THEN
         Bom_Rtg_Error_Handler.Log_Error
         (
            p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

        IF l_bo_return_status = 'S'
        THEN
           l_bo_return_status  := l_return_status ;
        END IF;
        x_return_status       := l_bo_return_status;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        x_op_resource_tbl     := l_op_resource_tbl ;
        x_sub_resource_tbl    := l_sub_resource_tbl ;

      WHEN EXC_SEV_QUIT_SIBLINGS THEN
         Bom_Rtg_Error_Handler.Log_Error
         (
            p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         IF l_bo_return_status = 'S'
         THEN
           l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl := l_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_BRANCH THEN
         Bom_Rtg_Error_Handler.Log_Error
         (
            p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         x_return_status       := Error_Handler.G_STATUS_FATAL;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
         Bom_Rtg_Error_Handler.Log_Error
         (
             p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

        x_return_status       := Error_Handler.G_STATUS_FATAL;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        x_op_resource_tbl     := l_op_resource_tbl ;
        x_sub_resource_tbl    := l_sub_resource_tbl ;

/*
    WHEN EXC_FAT_QUIT_OBJECT THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_return_status       := 'Q';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
*/

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
         Bom_Rtg_Error_Handler.Log_Error
         (
            p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
         ,  p_error_scope         => NULL
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_mesg_appid    => 'BOM'
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_return_status       := 'U';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;

   END ; -- END block


   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;

   END LOOP; -- END Operation Resources processing loop

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status    := l_return_status;
   END IF;

   x_mesg_token_tbl      := l_mesg_token_tbl ;
   x_op_resource_tbl     := l_op_resource_tbl ;
   x_sub_resource_tbl    := l_sub_resource_tbl ;
   x_mesg_token_tbl      := l_mesg_token_tbl ;

END Operation_Resources ;


--  Sub_Operation_Resources

/****************************************************************************
* Procedure : Sub_Operation_Resources
* Parameters IN   : Sub Operation Resources Table and all the other sibiling entities
* Parameters OUT  : Sub Operatin Resources and all the other sibiling entities
* Purpose   : This procedure will process all the Sub Operation Resources records.
*
*****************************************************************************/

PROCEDURE Sub_Operation_Resources
(   p_validation_level        IN  NUMBER
,   p_organization_id         IN  NUMBER   := NULL
,   p_assembly_item_name      IN  VARCHAR2 := NULL
,   p_alternate_routing_code  IN  VARCHAR2 := NULL
,   p_operation_seq_num       IN  NUMBER   := NULL
,   p_effectivity_date        IN  DATE     := NULL
,   p_operation_type          IN  NUMBER   := NULL
,   p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status           IN OUT NOCOPY VARCHAR2
)

IS

/* Exposed and Unexposed record */
l_sub_resource_rec         Bom_Rtg_Pub.Sub_Resource_Rec_Type ;
l_sub_res_unexp_rec        Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type ;
l_old_sub_resource_rec     Bom_Rtg_Pub.Sub_Resource_Rec_Type ;
l_old_sub_res_unexp_rec    Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type ;

l_sub_resource_tbl         Bom_Rtg_Pub.Sub_Resource_Tbl_Type ;

/* Other Entities */
l_rtg_header_rec        Bom_Rtg_Pub.Rtg_Header_Rec_Type ;
l_rtg_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
l_operation_tbl         Bom_Rtg_Pub.Operation_Tbl_Type ;
l_op_resource_tbl       Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
l_op_network_tbl        Bom_Rtg_Pub.Op_Network_Tbl_Type ;

/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type ;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);


/* Others */
l_return_status         VARCHAR2(3);
l_bo_return_status      VARCHAR2(1);
l_op_parent_exists      BOOLEAN := FALSE ;
l_rtg_parent_exists     BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid                 BOOLEAN := TRUE;
l_temp_op_rec		BOM_RTG_Globals.Temp_Op_Rec_Type;

BEGIN

   --  Init local table variables.
   l_return_status    := 'S';
   l_bo_return_status := 'S';
   l_sub_resource_tbl  := p_sub_resource_tbl ;
   l_sub_res_unexp_rec.organization_id := BOM_Rtg_Globals.Get_Org_Id ;


   FOR I IN 1..l_sub_resource_tbl.COUNT LOOP
   BEGIN

      --  Load local records
      l_sub_resource_rec := l_sub_resource_tbl(I) ;

      l_sub_resource_rec.transaction_type :=
         UPPER(l_sub_resource_rec.transaction_type) ;

      --
      -- Initialize the Unexposed Record for every iteration of the Loop
      -- so that sequence numbers get generated for every new row.
      --
      l_sub_res_unexp_rec.Operation_Sequence_Id   := NULL ;
      l_sub_res_unexp_rec.Substitute_Group_Number := l_sub_resource_rec.Substitute_Group_Number ;
      l_sub_res_unexp_rec.Resource_Id             := NULL ;
      l_sub_res_unexp_rec.New_Resource_Id         := NULL ;
      l_sub_res_unexp_rec.Activity_Id             := NULL ;
      l_sub_res_unexp_rec.Setup_Id                := NULL ;

      IF p_operation_seq_num  IS NOT NULL AND
         p_assembly_item_name IS NOT NULL AND
         p_effectivity_date   IS NOT NULL AND
         p_organization_id    IS NOT NULL
      THEN
         -- Revised Operation or Operation Sequence parent exists
         l_op_parent_exists  := TRUE ;

      ELSIF p_assembly_item_name IS NOT NULL AND
            p_organization_id    IS NOT NULL
      THEN
         -- Revised Item or Routing parent exists
         l_rtg_parent_exists := TRUE ;
      END IF ;

      -- If effectivity/op seq num of the parent operation has changed, update the child resource record
      IF BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag
      AND BOM_RTG_Globals.Get_Temp_Op_Rec1
          ( l_sub_resource_rec.operation_sequence_number
	  , p_effectivity_date -- this cannot be null as this check is done only when the op has children
	  , l_temp_op_rec)
      THEN
	 l_sub_resource_rec.operation_sequence_number := l_temp_op_rec.new_op_seq_num;
	 l_sub_resource_rec.op_start_effective_Date := l_temp_op_rec.new_start_eff_date;
/*
		Bom_Default_Sub_Op_Res.Init_Eff_Date_Op_Seq_Num
		( p_op_seq_num	=> p_operation_seq_num
		, p_eff_date	=> p_effectivity_date
		, p_sub_res_rec	=> l_sub_resource_rec
		, x_sub_res_rec	=> l_sub_resource_rec
		);
*/
      END IF;


      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF (l_sub_resource_rec.return_status IS NULL OR
          l_sub_resource_rec.return_status  = FND_API.G_MISS_CHAR)
         AND
         (
            -- Did Op_Seq call this procedure, that is,
            -- if revised operation(operation sequence) exists, then is this record a child ?
            (l_op_parent_exists AND
               (l_sub_resource_rec.assembly_item_name = p_assembly_item_name AND
                l_sub_res_unexp_rec.organization_id   = p_organization_id    AND
                NVL(l_sub_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR)
                                 = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR) AND
                l_sub_resource_rec.operation_sequence_number
                                                       = p_operation_seq_num AND
                l_sub_resource_rec.op_start_effective_date
                                                       = p_effectivity_date  AND
                NVL(l_sub_resource_rec.operation_type, 1) = NVL(p_operation_type, 1)
               )
            )
            OR
            -- Did Rtg_Header call this procedure, that is,
            -- if revised item or routing header exists, then is this record a child ?
            (l_rtg_parent_exists AND
               (l_sub_resource_rec.assembly_item_name = p_assembly_item_name AND
                l_sub_res_unexp_rec.organization_id   = p_organization_id    AND
                NVL(l_sub_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR)
                                 = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)
               )
            )
           OR
           (NOT l_rtg_parent_exists AND NOT l_op_parent_exists)
         )
      THEN
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_sub_resource_rec.return_status := FND_API.G_RET_STS_SUCCESS;

         --
         -- Process Flow step 3 :Check if transaction_type is valid
         -- Transaction_Type must be CRATE, UPDATE, DELETE or CANCEL(in only ECO for Rrg)
         -- Call the BOM_Rtg_Globals.Transaction_Type_Validity
         --

         BOM_Rtg_Globals.Transaction_Type_Validity
         (   p_transaction_type => l_sub_resource_rec.transaction_type
         ,   p_entity           => 'Sub_Res'
         ,   p_entity_id        => nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number)
         ,   x_valid            => l_valid
         ,   x_mesg_token_tbl   => l_mesg_token_tbl
         ) ;

         IF NOT l_valid
         THEN
             l_return_status := Error_Handler.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         --
         -- Process Flow step 4(a): Convert user unique index to unique
         -- index I
         -- Call BOM_Rtg_Val_To_Id.Op_Resource_UUI_To_UI Shared Utility Package
         --
	 BOM_Rtg_Val_To_Id.Sub_Resource_UUI_To_UI
         ( p_sub_resource_rec    => l_sub_resource_rec
         , p_sub_res_unexp_rec   => l_sub_res_unexp_rec
         , x_sub_res_unexp_rec   => l_sub_res_unexp_rec
         , x_mesg_token_tbl      => l_mesg_token_tbl
         , x_return_status       => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_SUB_RES_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
            RAISE EXC_SEV_QUIT_SIBLINGS ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;
/*
         --
         -- Process Flow step 4(b): Convert user unique index to unique
         -- index II
         -- Call the BOM_Rtg_Val_To_Id.Operation_UUI_To_UI2
         --

         BOM_Rtg_Val_To_Id.Sub_Resource_UUI_To_UI2
         ( p_sub_resource_rec   => l_sub_resource_rec
         , p_sub_res_unexp_rec  => l_sub_res_unexp_rec
         , x_sub_res_unexp_rec  => l_sub_res_unexp_rec
         , x_mesg_token_tbl     => l_mesg_token_tbl
         , x_other_message      => l_other_message
         , x_other_token_tbl    => l_other_token_tbl
         , x_return_status      => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index2 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            RAISE EXC_SEV_QUIT_SIBLINGS ;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;
*/
         --
         -- Process Flow step 5: Verify Operation Resource's existence
         -- Call the Bom_Validate_Op_Seq.Check_Existence
         --
         --

         Bom_Validate_Sub_Op_Res.Check_Existence
         (  p_sub_resource_rec        => l_sub_resource_rec
         ,  p_sub_res_unexp_rec       => l_sub_res_unexp_rec
         ,  x_old_sub_resource_rec    => l_old_sub_resource_rec
         ,  x_old_sub_res_unexp_rec   => l_old_sub_res_unexp_rec
         ,  x_mesg_token_tbl          => l_mesg_token_tbl
         ,  x_return_status           => l_return_status
         ) ;


         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check Existence completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_SUB_RES_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
            -- l_other_token_tbl(3).token_name := 'REVISED_ITEM_NAME';
            -- l_other_token_tbl(3).token_value :=
            --           l_sub_resource_rec.assembly_item_name ;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
            -- l_other_token_tbl(3).token_name := 'REVISED_ITEM_NAME';
            -- l_other_token_tbl(3).token_value :=
            --            l_sub_resource_rec.assembly_item_name ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

         --
         -- Process Flow step 6: Is Operation Resource record an orphan ?
         --

         IF NOT l_op_parent_exists
         THEN

            --
            -- Process Flow step 7 : Check Assembly Item Operability for Routing
            -- Call Bom_Validate_Rtg_Header.Check_Access
            --

            Bom_Validate_Rtg_Header.Check_Access
            ( p_assembly_item_name => l_sub_resource_rec.assembly_item_name
            , p_assembly_item_id   => l_sub_res_unexp_rec.assembly_item_id
            , p_organization_id    => l_sub_res_unexp_rec.organization_id
            , p_alternate_rtg_code => l_sub_resource_rec.alternate_routing_code
            , p_mesg_token_tbl     => Error_Handler.G_MISS_MESG_TOKEN_TBL
            , x_mesg_token_tbl     => l_mesg_token_tbl
            , x_return_status      => l_return_status
            ) ;

            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Check Assembly Item Operability completed with return_status: ' || l_return_status) ;
            END IF ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               l_other_message := 'BOM_SUB_RES_RITACC_FAT_FATAL';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
               l_return_status := 'F' ;
               RAISE EXC_FAT_QUIT_SIBLINGS ;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_SUB_RES_RITACC_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

            --
            -- Process Flow step 8 : Check if the parent operation is
            -- non-referencing operation of type: Event
            -- Call Bom_Validate_Op_Seq.Check_NonRefEvent
            --
            Bom_Validate_Op_Res.Check_NonRefEvent
            (  p_operation_sequence_id      =>
                                      l_sub_res_unexp_rec.operation_sequence_id
            ,  p_operation_type            => l_sub_resource_rec.operation_type
            ,  p_entity_processed          => 'SR'
            ,  x_mesg_token_tbl            => l_mesg_token_tbl
            ,  x_return_status             => l_return_status
            ) ;

            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Check non-ref operation completed with return_status: ' || l_return_status) ;
            END IF ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               IF l_sub_resource_rec.operation_type IN (2 , 3) -- Process or Line Op
               THEN


                  l_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_token_tbl(1).token_value :=
                          l_sub_resource_rec.sub_resource_code ;
                  l_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
                  l_token_tbl(3).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(3).token_value :=
                          l_sub_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_SUB_RES_OPTYPE_NOT_EVENT'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;

               ELSE

                  l_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_token_tbl(1).token_value :=
                          l_sub_resource_rec.sub_resource_code ;
                  l_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
                  l_token_tbl(3).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(3).token_value :=
                          l_sub_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_SUB_RES_MUST_NONREF'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;



               END IF ;

               l_other_message := 'BOM_SUB_RES_ACCESS_FAT_FATAL';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;


               l_return_status := 'F';
               RAISE EXC_FAT_QUIT_SIBLINGS ;

            -- For eAM enhancement, maintenace routings do not support
            -- sub resource currently
            ELSIF l_return_status = 'EAM'  THEN

                  l_return_status := FND_API.G_RET_STS_ERROR ;

                  l_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_token_tbl(1).token_value :=
                          l_sub_resource_rec.sub_resource_code ;
                  l_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
                  l_token_tbl(3).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(3).token_value :=
                          l_sub_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_EAM_SUB_RES_NOT_ACCESS'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;



                  l_other_message := 'BOM_SUB_RES_ACCESS_FAT_FATAL';
                  l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
                  l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;

                  l_return_status := 'F';
                  RAISE EXC_FAT_QUIT_SIBLINGS ;


            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_SUB_RES_ACCESS_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

         END IF;

         --
         -- Process Flow step 9: Value to Id conversions
         -- Call BOM_Rtg_Val_To_Id.Sub_Resource_VID
         --
         BOM_Rtg_Val_To_Id.Sub_Resource_VID
         (  p_sub_resource_rec       => l_sub_resource_rec
         ,  p_sub_res_unexp_rec      => l_sub_res_unexp_rec
         ,  x_sub_res_unexp_rec      => l_sub_res_unexp_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         );

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Value-id conversions completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_sub_resource_rec.transaction_type = 'CREATE'
            THEN
               l_other_message := 'BOM_SUB_RES_VID_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
               RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_VID_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                     l_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                     nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <>0
         THEN
            Bom_Rtg_Error_Handler.Log_Error
            (
               p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_error_scope         => NULL
            ,  p_other_message       => NULL
            ,  p_other_mesg_appid    => 'BOM'
            ,  p_other_status        => NULL
            ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
            ) ;
         END IF;

         --
         -- Process Flow step 10 : Check required fields exist
         -- (also includes a part of conditionally required fields)
         --

/*
         Bom_Validate_Op_Res.Check_Required
         ( p_sub_resource_rec           => l_sub_resource_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;



         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check required completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
            THEN
               l_other_message := 'BOM_SUB_RES_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        l_sub_resource_rec.schedule_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                     l_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                     l_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;
*/

         --
         -- Process Flow step 11 : Attribute Validation for CREATE and UPDATE
         -- Call Bom_Validate_Sub_Op_Res.Check_Attributes
         --

         IF l_sub_resource_rec.transaction_type IN
            (BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
         THEN
            Bom_Validate_Sub_Op_Res.Check_Attributes
            ( p_sub_resource_rec   => l_sub_resource_rec
            , p_sub_res_unexp_rec  => l_sub_res_unexp_rec
            , x_return_status      => l_return_status
            , x_mesg_token_tbl     => l_mesg_token_tbl
            ) ;

            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Attribute validation completed with return_status: ' || l_return_status) ;
            END IF ;


            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               IF l_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               THEN
                  l_other_message := 'BOM_SUB_RES_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
                  l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
               ELSE
                  RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_SUB_RES_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
               Bom_Rtg_Error_Handler.Log_Error
               (  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
               ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_SR_LEVEL
               ,  p_entity_index        => I
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
               ) ;
           END IF;
        END IF;



        IF l_sub_resource_rec.transaction_type IN
           (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
        THEN

        --
        -- Process flow step 12: Populate NULL columns for Update and Delete
        -- Call Bom_Default_Op_Res.Populate_Null_Columns
        --

           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns') ;
           END IF ;

             Bom_Default_Sub_Op_Res.Populate_Null_Columns
             (   p_sub_resource_rec       => l_sub_resource_rec
             ,   p_old_sub_resource_rec   => l_old_sub_resource_rec
             ,   p_sub_res_unexp_rec      => l_sub_res_unexp_rec
             ,   p_old_sub_res_unexp_rec  => l_old_sub_res_unexp_rec
             ,   x_sub_resource_rec       => l_sub_resource_rec
             ,   x_sub_res_unexp_rec      => l_sub_res_unexp_rec
             ) ;

        ELSIF l_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
        THEN
        --
        -- Process Flow step 13 : Default missing values for Op Resource (CREATE)
        -- Call Bom_Default_Op_Res.Attribute_Defaulting
        --
             Bom_Default_Sub_Op_Res.Attribute_Defaulting
             (   p_sub_resource_rec     => l_sub_resource_rec
             ,   p_sub_res_unexp_rec    => l_sub_res_unexp_rec
             ,   x_sub_resource_rec     => l_sub_resource_rec
             ,   x_sub_res_unexp_rec    => l_sub_res_unexp_rec
             ,   x_mesg_token_tbl       => l_mesg_token_tbl
             ,   x_return_status        => l_return_status
             ) ;

           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
              l_other_message := 'BOM_SUB_RES_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
              l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
              l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
              l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'BOM_SUB_RES_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
              l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
              l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
              l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
               Bom_Rtg_Error_Handler.Log_Error
               (  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
               ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_SR_LEVEL
               ,  p_entity_index        => I
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
               ) ;
          END IF;
       END IF;

       --
       -- Process Flow step 14: Conditionally Required Attributes
       --
       --
/*
       IF l_sub_resource_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CREATE
                                                 , BOM_Rtg_Globals.G_OPR_UPDATE )
       THEN

          Bom_Validate_Sub_Op_Seq.Check_Conditionally_Required
          ( p_sub_resource_rec       => l_sub_resource_rec
          , p_sub_res_unexp_rec      => l_sub_res_unexp_rec
          , x_return_status          => l_return_status
          , x_mesg_token_tbl         => l_mesg_token_tbl
          ) ;


          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check Conditionally Required Attr. completed with return_status: ' || l_return_status) ;
          END IF ;


          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_SUB_RES_CONREQ_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                l_other_token_tbl(1).token_value :=
                         l_sub_resource_rec.sub_resource_code ;
                l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                        l_sub_resource_rec.schedule_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_SUB_RES_CONREQ_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
             l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
             l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
             l_other_token_tbl(2).token_value :=
                        l_sub_resource_rec.schedule_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             Bom_Rtg_Error_Handler.Log_Error
             (  p_sub_resource_tbl    => l_sub_resource_tbl
             ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
             ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
             ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
             ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
             ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
             ,  p_mesg_token_tbl      => l_mesg_token_tbl
             ,  p_error_status        => 'W'
             ,  p_error_level         => Error_Handler.G_SR_LEVEL
             ,  p_entity_index        => I
             ,  p_error_scope         => NULL
             ,  p_other_message       => NULL
             ,  p_other_mesg_appid    => 'BOM'
             ,  p_other_status        => NULL
             ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
             ,  x_rtg_header_rec      => l_rtg_header_rec
             ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
             ,  x_op_network_tbl      => l_op_network_tbl
             ,  x_operation_tbl       => l_operation_tbl
             ,  x_op_resource_tbl     => l_op_resource_tbl
             ,  x_sub_resource_tbl    => l_sub_resource_tbl
             ) ;
          END IF;
       END IF;
  */

       --
       -- Process Flow step 15: Entity defaulting for CREATE and UPDATE
       --
       IF l_sub_resource_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CREATE
                                                 , BOM_Rtg_Globals.G_OPR_UPDATE )

       THEN
          Bom_Default_Sub_Op_Res.Entity_Defaulting
              (   p_sub_resource_rec   => l_sub_resource_rec
              ,   p_sub_res_unexp_rec  => l_sub_res_unexp_rec
              ,   x_sub_resource_rec   => l_sub_resource_rec
              ,   x_sub_res_unexp_rec  => l_sub_res_unexp_rec
              ,   x_mesg_token_tbl     => l_mesg_token_tbl
              ,   x_return_status      => l_return_status
              ) ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Entity defaulting completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_SUB_RES_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
                l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_SUB_RES_ENTDEF_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
             l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
             l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
             l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             Bom_Rtg_Error_Handler.Log_Error
             (  p_sub_resource_tbl    => l_sub_resource_tbl
             ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
             ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
             ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
             ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
             ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
             ,  p_mesg_token_tbl      => l_mesg_token_tbl
             ,  p_error_status        => 'W'
             ,  p_error_level         => Error_Handler.G_SR_LEVEL
             ,  p_entity_index        => I
             ,  p_error_scope         => NULL
             ,  p_other_message       => NULL
             ,  p_other_mesg_appid    => 'BOM'
             ,  p_other_status        => NULL
             ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
             ,  x_rtg_header_rec      => l_rtg_header_rec
             ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
             ,  x_op_network_tbl      => l_op_network_tbl
             ,  x_operation_tbl       => l_operation_tbl
             ,  x_op_resource_tbl     => l_op_resource_tbl
             ,  x_sub_resource_tbl    => l_sub_resource_tbl
             ) ;
          END IF ;
       END IF ;


       --
       -- Process Flow step 16 - Entity Level Validation
       -- Call Bom_Validate_Op_Res.Check_Entity
       --
       Bom_Validate_Sub_Op_Res.Check_Entity
          (  p_sub_resource_rec       => l_sub_resource_rec
          ,  p_sub_res_unexp_rec      => l_sub_res_unexp_rec
          ,  p_old_sub_resource_rec   => l_old_sub_resource_rec
          ,  p_old_sub_res_unexp_rec  => l_old_sub_res_unexp_rec
          ,  x_sub_resource_rec       => l_sub_resource_rec
          ,  x_sub_res_unexp_rec      => l_sub_res_unexp_rec
          ,  x_mesg_token_tbl         => l_mesg_token_tbl
          ,  x_return_status          => l_return_status
          ) ;


       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          IF l_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
          THEN
             l_other_message := 'BOM_SUB_RES_ENTVAL_CSEV_SKIP';
             l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
             l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
             l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
             l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
             RAISE EXC_SEV_SKIP_BRANCH ;
          ELSE
             RAISE EXC_SEV_QUIT_RECORD ;
          END IF;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_SUB_RES_ENTVAL_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
          l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
          l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
          l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
       THEN
          Bom_Rtg_Error_Handler.Log_Error
          (    p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_error_scope         => NULL
            ,  p_other_message       => NULL
            ,  p_other_mesg_appid    => 'BOM'
            ,  p_other_status        => NULL
            ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;
       END IF;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation completed with '
             || l_return_Status || ' proceeding for database writes . . . ') ;
       END IF;

       --
       -- Process Flow step 16 : Database Writes
       --
          SAVEPOINT validate_sgn; -- Bug 3798362
          Bom_Sub_Op_Res_Util.Perform_Writes
          (   p_sub_resource_rec     => l_sub_resource_rec
          ,   p_sub_res_unexp_rec    => l_sub_res_unexp_rec
          ,   x_mesg_token_tbl       => l_mesg_token_tbl
          ,   x_return_status        => l_return_status
          ) ;

       IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_SUB_RES_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
          l_other_token_tbl(1).token_value :=
                        l_sub_resource_rec.sub_resource_code ;
          l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
          l_other_token_tbl(2).token_value :=
                        nvl(l_sub_resource_rec.substitute_group_number, l_sub_res_unexp_rec.substitute_group_number) ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl .COUNT <>0
       THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_error_scope         => NULL
            ,  p_other_message       => NULL
            ,  p_other_mesg_appid    => 'BOM'
            ,  p_other_status        => NULL
            ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;
       END IF;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Res Database writes completed with status  ' || l_return_status);
       END IF;


       --
       -- Process Flow Step 17: Validate SGN order -- Bug 3798362
       --

       Bom_Validate_Op_Res.Val_SGN_Order
       ( p_op_seq_id      => l_sub_res_unexp_rec.operation_sequence_id
       , x_mesg_token_tbl => l_mesg_token_tbl
       , x_return_status  => l_return_status);

       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          ROLLBACK TO validate_sgn;
          RAISE EXC_SEV_QUIT_SIBLINGS;
       END IF;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Res validate SGN order completed with status  ' || l_return_status);
       END IF;
    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_sub_resource_tbl(I)          := l_sub_resource_rec;


    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => Error_Handler.G_STATUS_ERROR
            ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_other_message       => NULL
            ,  p_other_mesg_appid    => 'BOM'
            ,  p_other_status        => NULL
            ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status := l_return_status ;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;


      WHEN EXC_SEV_QUIT_BRANCH THEN

         Bom_Rtg_Error_Handler.Log_Error
         (     p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => Error_Handler.G_STATUS_ERROR
            ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
            ,  p_other_status        => Error_Handler.G_STATUS_ERROR
            ,  p_other_message       => l_other_message
            ,  p_other_token_tbl     => l_other_token_tbl
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_other_mesg_appid    => 'BOM'
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status  := l_return_status;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;

      WHEN EXC_SEV_SKIP_BRANCH THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => Error_Handler.G_STATUS_ERROR
            ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
            ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
            ,  p_other_message       => l_other_message
            ,  p_other_token_tbl     => l_other_token_tbl
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_other_mesg_appid    => 'BOM'
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

        IF l_bo_return_status = 'S'
        THEN
           l_bo_return_status  := l_return_status ;
        END IF;
        x_return_status       := l_bo_return_status;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        x_sub_resource_tbl    := l_sub_resource_tbl ;

      WHEN EXC_SEV_QUIT_SIBLINGS THEN
         Bom_Rtg_Error_Handler.Log_Error
         (     p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => Error_Handler.G_STATUS_ERROR
            ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
            ,  p_other_status        => Error_Handler.G_STATUS_ERROR
            ,  p_other_message       => l_other_message
            ,  p_other_token_tbl     => l_other_token_tbl
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_other_mesg_appid    => 'BOM'
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         IF l_bo_return_status = 'S'
         THEN
           l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_BRANCH THEN
         Bom_Rtg_Error_Handler.Log_Error
         (     p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => Error_Handler.G_STATUS_FATAL
            ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
            ,  p_other_status        => Error_Handler.G_STATUS_FATAL
            ,  p_other_message       => l_other_message
            ,  p_other_token_tbl     => l_other_token_tbl
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_other_mesg_appid    => 'BOM'
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         x_return_status       := Error_Handler.G_STATUS_FATAL;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
         Bom_Rtg_Error_Handler.Log_Error
         (     p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl       =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl     =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_op_network_tbl      =>Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => Error_Handler.G_STATUS_FATAL
            ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
            ,  p_other_status        => Error_Handler.G_STATUS_FATAL
            ,  p_other_message       => l_other_message
            ,  p_other_token_tbl     => l_other_token_tbl
            ,  p_error_level         => Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  p_other_mesg_appid    => 'BOM'
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

        x_return_status       := Error_Handler.G_STATUS_FATAL;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        x_sub_resource_tbl    := l_sub_resource_tbl ;

/*
    WHEN EXC_FAT_QUIT_OBJECT THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_SR_LEVEL
         ,  p_entity_index        => I
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_return_status       := 'Q';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
*/

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
         ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_SR_LEVEL
         ,  p_other_mesg_appid    => 'BOM'
         ,  p_entity_index         => I
         ,  p_error_scope          => NULL
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_return_status       := 'U';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;

   END ; -- END block


   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;

   END LOOP; -- END Substitute Operation Resources processing loop

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;

   x_mesg_token_tbl      := l_mesg_token_tbl ;
   x_sub_resource_tbl    := l_sub_resource_tbl ;
   x_mesg_token_tbl      := l_mesg_token_tbl ;

END Sub_Operation_Resources ;

/****************************************************************************
* Procedure     : Op_Network
* Parameters IN : Op Network Table and all the other entities
* Parameters OUT: Op Network Table and all the other entities
* Purpose       : This procedure will process all the network records.
*                 Although the other entities are not children of this entity
*                 the are taken as parameters so that the error handler could
*                 set the records to appropriate status if a fatal or severity
*                 1 error occurs.
*****************************************************************************/

PROCEDURE Op_Networks
(   p_validation_level           IN  NUMBER
 ,  p_assembly_item_name         IN  VARCHAR2   := NULL
 ,  p_assembly_item_id           IN  NUMBER     := NULL
 ,  p_organization_id            IN  NUMBER     := NULL
 ,  p_alternate_rtg_code         IN  VARCHAR2   := NULL
 ,  p_op_network_tbl             IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
 ,  x_op_network_tbl             IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
 ,  x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status              IN OUT NOCOPY VARCHAR2
 )
IS

/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type ;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);


l_valid                 BOOLEAN := TRUE;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_rtg_parent_exists     BOOLEAN := FALSE;

l_rtg_header_rec        Bom_Rtg_Pub.rtg_header_Rec_Type;
l_rtg_header_unexp_rec  Bom_Rtg_Pub.rtg_header_unexposed_Rec_Type;
l_old_rtg_header_rec    Bom_Rtg_Pub.rtg_header_Rec_Type;
l_old_rtg_header_unexp_rec Bom_Rtg_Pub.rtg_Header_Unexposed_Rec_Type;
l_op_network_rec        Bom_Rtg_Pub.op_network_Rec_Type;
l_op_network_unexp_rec  Bom_Rtg_Pub.op_network_Unexposed_Rec_Type;
l_op_network_tbl        Bom_Rtg_Pub.op_network_Tbl_Type := p_op_network_tbl;
l_old_op_network_rec    Bom_Rtg_Pub.op_network_Rec_Type := NULL;
l_old_op_network_unexp_rec
                        Bom_Rtg_Pub.op_network_Unexposed_Rec_Type := NULL;
l_rtg_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
l_operation_tbl         Bom_Rtg_Pub.operation_tbl_type;
l_op_resource_tbl       Bom_Rtg_Pub.op_resource_tbl_type;
l_sub_resource_tbl      Bom_Rtg_Pub.sub_resource_tbl_type;

l_return_value          NUMBER;
  /*below change for RBO support for OSFM*/
l_common_routing_sequence_id   NUMBER;
l_prev_start_id                NUMBER:=0;
l_prev_end_id                  NUMBER:=0;
l_temp_rtg_id                  NUMBER:=0;

l_line_op		BOOLEAN := FALSE; -- Added for calc_cynp
l_process_op		BOOLEAN := FALSE;
l_dummy			VARCHAR2(1) := 'S';
--l_temp_op_rec_tbl_test   BOM_RTG_Globals.Temp_Op_Rec_Tbl_Type;

BEGIN
  IF BOM_Rtg_Globals.Get_Debug = 'Y'
  THEN Error_Handler.Write_Debug
    ('Within Operation Network procedure call. . . ');
  END IF;

    l_return_status := 'S';
    l_bo_return_status := 'S';

    --  Init local table variables.
    l_op_network_tbl := p_op_network_tbl;

    l_op_network_unexp_rec.organization_id := BOM_Rtg_Globals.Get_org_id;
    FOR I IN 1..l_op_network_tbl.COUNT LOOP
    BEGIN

        --  Load local records.
        l_op_network_rec := l_op_network_tbl(I);

        --
        -- Process Flow Step 2: Check if return status is NULL
        --

        l_op_network_rec.transaction_type :=
                UPPER(l_op_network_rec.transaction_type);

        IF p_assembly_item_name IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                l_rtg_parent_exists := TRUE;
        END IF;

        --
        -- Initialize the Unexposed Record for every iteration of the Loop
        -- so that sequence numbers get generated for every new row.
        --
        l_op_network_unexp_rec.From_Op_Seq_Id := NULL ;
        l_op_network_unexp_rec.To_Op_Seq_Id := NULL ;
        l_op_network_unexp_rec.new_from_op_seq_id := NULL;
        l_op_network_unexp_rec.new_to_op_seq_id := NULL;

        --
        -- Process Flow Step 2.5: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --
        IF (l_op_network_rec.return_status IS NULL OR
            l_op_network_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_rtg_parent_exists
           OR
           (l_rtg_parent_exists AND
              ( l_op_network_rec.assembly_item_name = p_assembly_item_name AND
                l_op_network_unexp_rec.organization_id = p_organization_id AND
                NVL(l_op_network_rec.alternate_routing_code, FND_API.G_MISS_CHAR) =
                    NVL(p_alternate_rtg_code, FND_API.G_MISS_CHAR)
              )
             )
            )
        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;
           l_op_network_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           --
           -- Step 3: Check if transaction_type is valid
           --
           BOM_Rtg_Globals.Transaction_Type_Validity
           (   p_transaction_type       => l_op_network_rec.transaction_type
           ,   p_entity                 => 'Op_Network'
           ,   p_entity_id              => l_op_network_rec.assembly_item_name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           --
           -- Process Flow Step: 4 Convert User Unique Index
           --l_temp_op_rec_tbl	BOM_RTG_Globals.Temp_Op_Rec_Tbl_Type;
--	   BOM_RTG_Globals.Set_Temp_Op_Tbl(l_temp_op_rec_tbl_test);
           BOM_Rtg_Val_To_Id.Op_Network_UUI_To_UI
           (  p_op_network_rec          => l_op_network_rec
            , p_op_network_unexp_rec    => l_op_network_unexp_rec
            , x_op_network_unexp_rec    => l_op_network_unexp_rec
            , x_mesg_token_tbl          => l_mesg_token_tbl
            , x_return_status           => l_return_status
            );

           IF  l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_OP_NWK_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                RAISE EXC_SEV_QUIT_OBJECT;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_OP_NWK_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

  /*below change for RBO support for OSFM*/
  /**************************************************************************
   * 1. If its update of OSFM Network, then we store the start operation id *
   * at the start. Then at the end of the network transactions, we check    *
   * that this start operation is the same as the one at the end of update. *
   * If its not(user changed start) we should error out!                    *
   * 2. Same for the End operation.                                         *
   * 3. We are also adding logic to default the subinventory and locator.   *
   * Since the original logic as in OSFM forms trigger, depends on the end  *
   * operation sub inv and locator, we have put the logic here. So that we  *
   * can get the end operation at the end of saving all the network links.  *
   * 4. Also, we cannot ask user to decide for following 2 cases as forms   *
   * does , so we are going to give user instruction to do so by going to   *
   * the form.But we will not assume any thing and let the data be as it is!*
   * Cases in question :                                                    *
   * a. When the end operation has sub inv and loc; also it matches with the*
   *    routing sub inv => we will not change data and tell user that if    *
   *    he/she wwants they can change this in form.                         *
   * b. When sub inv also match , then we will not change the locator =>    *
   *    we will tell user that the sub inv matches and locators are not the *
   *    same, and that they can change this in form if they wish!           *
   **************************************************************************/
   l_temp_rtg_id := BOM_RTG_Globals.Get_Routing_Sequence_Id();
   IF( l_temp_rtg_id  IS NULL OR l_temp_rtg_id = 0 ) OR
     ( BOM_RTG_Globals.Is_Osfm_NW_Calc_Flag = FALSE) THEN

     BOM_RTG_Globals.Set_Routing_Sequence_Id(
     l_op_network_unexp_rec.routing_sequence_id);
     BOM_RTG_Globals.Set_Osfm_NW_Calc_Flag(TRUE);
     IF BOM_Rtg_Globals.Get_Debug = 'Y'
     THEN Error_Handler.Write_Debug
      ('Op Network: Calling BOM_Op_Network_UTIL.Get_WSM_Netowrk_Attribs....');
     END IF;

      BOM_Op_Network_UTIL.Get_WSM_Netowrk_Attribs  (
      p_routing_sequence_id =>l_op_network_unexp_rec.routing_sequence_id
    , x_prev_start_id      => l_prev_start_id
    , x_prev_end_id        => l_prev_end_id
    , x_mesg_token_tbl     => l_mesg_token_tbl
    , x_Return_status      => l_return_status
     );
     IF BOM_Rtg_Globals.Get_Debug = 'Y'
     THEN Error_Handler.Write_Debug
      ('Op Network: Get_WSM_Netowrk_Attribs returned with Status '||
      l_return_status);
     END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
       l_other_message := 'BOM_WSM_NWK_NO_START_OR_END';
       RAISE EXC_SEV_QUIT_OBJECT ;
     END IF;

   END IF;
  /*above change for RBO support for OSFM*/

           /* No longer Used
           -- Step 5: Verify routing header's existence in database.
           -- If  routing header record is being created and the business object
           -- does not carry the Rtg header, then it is imperative to check
           -- for the Rtg Header's existence.

           IF l_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
              AND NOT l_rtg_parent_exists
           THEN
                l_rtg_header_rec.alternate_routing_code :=
                                               p_alternate_rtg_code;
                l_rtg_header_unexp_rec.organization_id := p_organization_id;
                l_rtg_header_unexp_rec.assembly_item_id := p_assembly_item_id;
                l_rtg_header_rec.transaction_type := 'XXX';

                Bom_Validate_rtg_header.Check_Existence
                ( p_rtg_header_rec        => l_rtg_header_rec
                , p_rtg_header_unexp_rec  => l_rtg_header_unexp_rec
                , x_old_rtg_header_rec    => l_old_rtg_header_rec
                , x_old_rtg_header_unexp_rec => l_old_rtg_header_unexp_rec
                , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                , x_return_status            => l_return_status
                );
                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'BOM_RTG_HEADER_NOT_EXIST';
                   l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                   l_other_token_tbl(1).token_value :=
                                        l_op_network_rec.assembly_item_name;
                   l_other_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                   l_other_token_tbl(2).token_value :=
                                        l_op_network_rec.organization_code;
                   RAISE EXC_SEV_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'BOM_RTG_REV_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name :='ASSEMBLY_ITEM_NAME';
                   l_other_token_tbl(1).token_value :=
                                     l_op_network_rec.assembly_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
          END IF;
          */


           --
           -- Process Flow step 5: Verify operation network's existence
           --
           Bom_Validate_Op_Network.Check_Existence
                (  p_op_network_rec             => l_op_network_rec
                ,  p_op_network_unexp_rec       => l_op_network_unexp_rec
                ,  x_old_op_network_rec         => l_old_op_network_rec
                ,  x_old_op_network_unexp_rec   => l_old_op_network_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_return_status
                );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                /*  No longer used
                l_other_message := 'BOM_OP_NWK_EXS_SEV_SKIP';
                l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                l_other_token_tbl(3).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(3).token_value :=
                             l_op_network_rec.assembly_item_name ;
                */
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_OP_NWK_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                -- l_other_token_tbl(3).token_name := 'ASSEMBLY_ITEM_NAME';
                -- l_other_token_tbl(3).token_value :=
                --           l_op_network_rec.assembly_item_name ;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           --
           -- Process Flow step 7:
           -- Check assembly item's operability for routing
           --
           IF NOT l_rtg_parent_exists
           THEN

                Bom_Validate_Rtg_Header.Check_Access
                ( p_assembly_item_name => l_op_network_rec.assembly_item_name
                , p_assembly_item_id   => l_op_network_unexp_rec.assembly_item_id
                , p_organization_id    => l_op_network_unexp_rec.organization_id
                , p_alternate_rtg_code => l_op_network_rec.alternate_routing_code
                , p_mesg_token_tbl     => Error_Handler.G_MISS_MESG_TOKEN_TBL

                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_OP_NWK_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                        l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_OP_NWK_RITACC_UNEXP_ERROR';
                        l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                        l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;

           --
           -- Process Flow step 9: Attribute Validation for Create and Update
           --
           IF l_op_network_rec.transaction_type IN
                (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_CREATE)
           THEN
               Bom_Validate_Op_Network.Check_Access
                (   p_op_network_rec           => l_op_network_rec
                ,   p_op_network_unexp_rec     => l_op_network_unexp_rec
                ,   x_return_status            => l_return_status
                ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug
    ('Op Network: Check Access is completed with status '|| l_return_status );
END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_OP_NWK_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                        l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;

                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;


           --
           -- Process Flow step 9: Attribute Validation for Create and Update
           --
           IF l_op_network_rec.transaction_type IN
                (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_CREATE)
           THEN
               Bom_Validate_Op_Network.Check_Attributes
                (   x_return_status            => l_return_status
                ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                ,   p_op_network_rec           => l_op_network_rec
                ,   p_op_network_unexp_rec     => l_op_network_unexp_rec
                ,   p_old_op_network_rec       => l_Old_op_network_rec
                ,   p_old_op_network_unexp_rec => l_Old_op_network_unexp_rec
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug
    ('Op Network: Check Attributes is completed with status '|| l_return_status );
END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;

                        /* No linger used
                        IF l_op_network_rec.transaction_type = 'CREATE'
                        THEN
                           l_other_message :='BOM_OP_NWK_ATTVAL_CSEV_ERROR';
                           l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                           l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                           l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                           l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                           RAISE EXC_SEV_SKIP_BRANCH;
                        ELSE
                           RAISE EXC_SEV_QUIT_RECORD;
                        END IF;
                        */
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_OP_NWK_ATTVAL_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                        l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;

                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;


           IF l_op_network_rec.Transaction_Type IN
                (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
           THEN

                -- Process flow  - Populate NULL columns for Update and
                -- Delete.

                Bom_Default_Op_Network.Populate_NULL_Columns
                (   p_op_network_rec            => l_op_network_rec
                ,   p_op_network_unexp_rec      => l_op_network_unexp_rec
                ,   p_old_op_network_rec        => l_old_op_network_rec
                ,   p_old_op_network_unexp_rec  => l_old_op_network_unexp_rec
                ,   x_op_network_rec            => l_op_network_rec
                ,   x_op_network_unexp_rec      => l_op_network_unexp_rec
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug
    ('Op Network: Populate Null columns is completed with status '|| l_return_status );
END IF;


           ELSIF l_op_network_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
           THEN
                --
                --  Default missing values for Operation network record creation
                --
                Bom_Default_Op_Network.Attribute_Defaulting
                (   p_op_network_rec       => l_op_network_rec
                ,   p_op_network_unexp_rec => l_op_network_unexp_rec
                ,   x_op_network_rec       => l_op_network_rec
                ,   x_op_network_unexp_rec => l_op_network_unexp_rec
                ,   x_mesg_token_tbl       => l_mesg_token_tbl
                ,   x_return_status        => l_return_status
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug
    ('Op Network: Attribute Defaulting is completed with status '|| l_return_status );
END IF;



               IF l_return_status = Error_Handler.G_STATUS_ERROR
               THEN
                   RAISE EXC_SEV_QUIT_RECORD;

                   /* No longer used
                   IF l_op_network_rec.transaction_type = 'CREATE'
                   THEN
                       l_other_message := 'BOM_OP_NWK_ATTDEF_CSEV_SKIP';
                       l_other_token_tbl(1).token_name := 'FROM_OP_SEQ_NUMBER';
                       l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                       l_other_token_tbl(2).token_name := 'TO_OP_SEQ_NUMBER';
                       l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                       RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                       RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                   */

               ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
               THEN
                    l_other_message := 'BOM_OP_NWK_ATTDEF_UNEXP_SKIP';
                    l_other_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                    l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                    l_other_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                    l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                    RAISE EXC_UNEXP_SKIP_OBJECT;
               END IF;

           END IF;


           --
           --  Default missing values for Operation network record creation
           --
           Bom_Default_Op_Network.Entity_Attribute_Defaulting
           (   p_op_network_rec       => l_op_network_rec
           ,   p_op_network_unexp_rec => l_op_network_unexp_rec
           ,   x_op_network_rec       => l_op_network_rec
           ,   x_op_network_unexp_rec => l_op_network_unexp_rec
           ,   x_mesg_token_tbl       => l_mesg_token_tbl
           ,   x_return_status        => l_return_status
           );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                   RAISE EXC_SEV_QUIT_RECORD;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                    l_other_message := 'BOM_OP_NWK_ATTDEF_UNEXP_SKIP';
                    l_other_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                    l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                    l_other_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                    l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                    RAISE EXC_UNEXP_SKIP_OBJECT;


           -- Added for eAM enhancement. Entity_Attribute_Defaulting
           -- may return a warning message.
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
              Bom_Rtg_Error_Handler.Log_Error
              (  p_rtg_header_rec      => l_rtg_header_rec
              ,  p_op_network_tbl      => l_op_network_tbl
              ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
              ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
              ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
              ,  p_sub_resource_tbl    => Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
              ,  p_mesg_token_tbl      => l_mesg_token_tbl
              ,  p_error_status        => 'W'
              ,  p_error_level         => Error_Handler.G_NWK_LEVEL
              ,  p_entity_index        => I
              ,  p_error_scope         => NULL
              ,  p_other_message       => NULL
              ,  p_other_mesg_appid    => 'BOM'
              ,  p_other_status        => NULL
              ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
              ,  x_rtg_header_rec      => l_rtg_header_rec
              ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
              ,  x_op_network_tbl      => l_op_network_tbl
              ,  x_operation_tbl       => l_operation_tbl
              ,  x_op_resource_tbl     => l_op_resource_tbl
              ,  x_sub_resource_tbl    => l_sub_resource_tbl
              ) ;
           END IF;



           --
           -- Process Flow step 13: Entity level Validation for Create and Update
           --
           Bom_Validate_Op_Network.Check_Entity1
           (  x_return_status           => l_return_status
           ,  x_Mesg_Token_Tbl          => l_Mesg_Token_Tbl
           ,  p_op_network_rec          => l_op_network_rec
           ,  p_op_network_unexp_rec    => l_op_network_unexp_rec
           ,  p_old_op_network_rec      => l_old_op_network_rec
           ,  p_old_op_network_unexp_rec=> l_old_op_network_unexp_rec
           );

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug
    ('Op Network: Check Entity1 is completed with status '|| l_return_status );
END IF;


           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                /* No longer used
                l_other_message := 'BOM_OP_NWK_ENTVAL_CSEV_ERROR';
                l_other_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                */

                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_OP_NWK_ENTVAL_UNEXP_ERROR';
                l_other_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           --
           -- Process Flow step 14 : Database Writes
           --
           Bom_Op_Network_Util.Perform_Writes
                (   p_op_network_rec            => l_op_network_rec
                ,   p_op_network_unexp_rec      => l_op_network_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug
    ('Op Network: Perform Writes is completed with status '|| l_return_status );
END IF;


           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_OP_NWK_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           --
           -- Process Flow step 15 : Entity level2 validation
           --
           --
             Bom_Validate_Op_Network.Check_Entity2
             (  x_return_status           => l_return_status
             ,  x_Mesg_Token_Tbl          => l_Mesg_Token_Tbl
             ,  p_op_network_rec          => l_op_network_rec
             ,  p_op_network_unexp_rec    => l_op_network_unexp_rec
             ,  p_old_op_network_rec      => l_old_op_network_rec
             ,  p_old_op_network_unexp_rec=> l_old_op_network_unexp_rec
             );

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug
    ('Op Network: Check Entity2 is completed with status '|| l_return_status );
END IF;

     /* below is OSFM change */
     BOM_RTG_Globals.Add_Osfm_NW_Count(1);
     /* above is OSFM change */

             IF l_return_status = Error_Handler.G_STATUS_ERROR
             THEN
                l_other_message := 'BOM_OP_NWK_ENTVAL_CSEV_ERROR';
                l_other_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;

                RAISE EXC_SEV_QUIT_OBJECT ;
             ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
             THEN
                l_other_message := 'BOM_OP_NWK_ENTVAL_UNEXP_ERROR';
                l_other_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                                    l_op_network_rec.from_op_seq_number;
                l_other_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                                    l_op_network_rec.to_op_seq_number;
                RAISE EXC_UNEXP_SKIP_OBJECT;
             ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
             THEN
              Bom_Rtg_Error_Handler.Log_Error
              (  p_rtg_header_rec      => l_rtg_header_rec
              ,  p_op_network_tbl      => l_op_network_tbl
              ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
              ,  p_operation_tbl       => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
              ,  p_op_resource_tbl     => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
              ,  p_sub_resource_tbl    => Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
              ,  p_mesg_token_tbl      => l_mesg_token_tbl
              ,  p_error_status        => 'W'
              ,  p_error_level         => Error_Handler.G_NWK_LEVEL
              ,  p_entity_index        => I
              ,  p_error_scope         => NULL
              ,  p_other_message       => NULL
              ,  p_other_mesg_appid    => 'BOM'
              ,  p_other_status        => NULL
              ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
              ,  x_rtg_header_rec      => l_rtg_header_rec
              ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
              ,  x_op_network_tbl      => l_op_network_tbl
              ,  x_operation_tbl       => l_operation_tbl
              ,  x_op_resource_tbl     => l_op_resource_tbl
              ,  x_sub_resource_tbl    => l_sub_resource_tbl
              ) ;
            END IF;

        END IF;

        --  Load tables.
        l_op_network_tbl(I)          := l_op_network_rec;

	-- Initialize variables for calc_cynp
	IF l_op_network_rec.Operation_Type = Bom_Rtg_Globals.G_LINE_OP THEN
		l_line_op := TRUE;
	ELSIF l_op_network_rec.Operation_Type = Bom_Rtg_Globals.G_PROCESS_OP THEN
		l_process_op := TRUE;
	END IF;

        --  For loop exception handler.

     EXCEPTION

        WHEN EXC_SEV_QUIT_RECORD THEN
             Bom_Rtg_Error_Handler.Log_Error
             (  p_rtg_header_rec       => l_rtg_header_rec
             ,  p_op_network_tbl       => l_op_network_tbl
             ,  p_rtg_revision_tbl     => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
             ,  p_operation_tbl        => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
             ,  p_op_resource_tbl      => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
             ,  p_sub_resource_tbl     => Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
             ,  p_mesg_token_tbl       => l_mesg_token_tbl
             ,  p_error_status         => Error_Handler.G_STATUS_ERROR
             ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
             ,  p_error_level          => Error_Handler.G_NWK_LEVEL
             ,  p_entity_index         => I
             ,  p_other_message        => NULL
             ,  p_other_mesg_appid     => 'BOM'
             ,  p_other_status         => NULL
             ,  p_other_token_tbl      => Error_Handler.G_MISS_TOKEN_TBL
             ,  x_rtg_header_rec       => l_rtg_header_rec
             ,  x_rtg_revision_tbl     => l_rtg_revision_tbl
             ,  x_operation_tbl        => l_operation_tbl
             ,  x_op_resource_tbl      => l_op_resource_tbl
             ,  x_sub_resource_tbl     => l_sub_resource_tbl
             ,  x_op_network_tbl       => l_op_network_tbl
             );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
   --   x_rtg_header_rec               := l_rtg_header_rec;
   --   x_rtg_revision_tbl             := l_rtg_revision_tbl;
   --   x_operation_tbl                := l_operation_tbl;
   --   x_op_resource_tbl              := l_op_resource_tbl;
   --   x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;


        WHEN EXC_SEV_QUIT_OBJECT THEN
            Bom_Rtg_Error_Handler.Log_Error
            ( p_rtg_header_rec        => l_rtg_header_rec
            , p_op_network_tbl        => l_op_network_tbl
            , p_rtg_revision_tbl      => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            , p_operation_tbl         => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            , p_op_resource_tbl       => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            , p_sub_resource_tbl      => Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
            , p_mesg_token_tbl        => l_mesg_token_tbl
            , p_error_status          => Error_Handler.G_STATUS_ERROR
            , p_error_scope           => Error_Handler.G_SCOPE_ALL
            , p_error_level           => Error_Handler.G_NWK_LEVEL
            , p_other_message         => l_other_message
            , p_other_status          => Error_Handler.G_STATUS_ERROR
            , p_other_token_tbl       => l_other_token_tbl
            , p_other_mesg_appid      => 'BOM'
            , p_entity_index          => I
            , x_rtg_header_rec        => l_rtg_header_rec
            , x_rtg_revision_tbl      => l_rtg_revision_tbl
            , x_operation_tbl         => l_operation_tbl
            , x_op_resource_tbl       => l_op_resource_tbl
            , x_sub_resource_tbl      => l_sub_resource_tbl
            , x_op_network_tbl        => l_op_network_tbl
            );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
   --   x_rtg_header_rec               := l_rtg_header_rec;
   --   x_rtg_revision_tbl             := l_rtg_revision_tbl;
   --   x_operation_tbl                := l_operation_tbl;
   --   x_op_resource_tbl              := l_op_resource_tbl;
   --   x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

        WHEN EXC_FAT_QUIT_OBJECT THEN

          Bom_Rtg_Error_Handler.Log_Error
            (  p_op_network_tbl       => l_op_network_tbl
            ,  p_rtg_header_rec       => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl     => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_operation_tbl        => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            ,  p_op_resource_tbl      => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            ,  p_sub_resource_tbl     => Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
            ,  p_mesg_token_tbl       => l_mesg_token_tbl
            ,  p_error_status         => Error_Handler.G_STATUS_FATAL
            ,  p_error_scope          => Error_Handler.G_SCOPE_ALL
            ,  p_error_level          => Error_Handler.G_NWK_LEVEL
            ,  p_other_message        => l_other_message
            ,  p_other_status         => Error_Handler.G_STATUS_FATAL
            ,  p_other_token_tbl      => l_other_token_tbl
            ,  p_other_mesg_appid     => 'BOM'
            ,  p_entity_index         => 1
            ,  x_rtg_header_rec       => l_rtg_header_rec
            ,  x_rtg_revision_tbl     => l_rtg_revision_tbl
            ,  x_operation_tbl        => l_operation_tbl
            ,  x_op_resource_tbl      => l_op_resource_tbl
            ,  x_sub_resource_tbl     => l_sub_resource_tbl
            ,  x_op_network_tbl       => l_op_network_tbl
            );
        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
   --   x_rtg_header_rec               := l_rtg_header_rec;
   --   x_rtg_revision_tbl             := l_rtg_revision_tbl;
   --   x_operation_tbl                := l_operation_tbl;
   --   x_op_resource_tbl              := l_op_resource_tbl;
   --   x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

            Bom_Rtg_Error_Handler.Log_Error
            ( p_op_network_tbl       => l_op_network_tbl
            , p_rtg_header_rec       =>Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            , p_rtg_revision_tbl     =>Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            , p_operation_tbl        =>Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            , p_op_resource_tbl      =>Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            , p_sub_resource_tbl     =>Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
            , p_mesg_token_tbl       => l_mesg_token_tbl
            , p_error_status         => Error_Handler.G_STATUS_UNEXPECTED
            , p_error_scope          => Error_Handler.G_SCOPE_ALL
            , p_error_level          => Error_Handler.G_NWK_LEVEL
            , p_other_message        => l_other_message
            , p_other_status         => Error_Handler.G_STATUS_NOT_PICKED
            , p_other_token_tbl      => l_other_token_tbl
            , p_other_mesg_appid     => 'BOM'
            , p_entity_index         => I
            , x_rtg_header_rec       => l_rtg_header_rec
            , x_rtg_revision_tbl     => l_rtg_revision_tbl
            , x_operation_tbl        => l_operation_tbl
            , x_op_resource_tbl      => l_op_resource_tbl
            , x_sub_resource_tbl     => l_sub_resource_tbl
            , x_op_network_tbl       => l_op_network_tbl
            );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
   --   x_rtg_header_rec               := l_rtg_header_rec;
   --   x_rtg_revision_tbl             := l_rtg_revision_tbl;
   --   x_operation_tbl                := l_operation_tbl;
   --   x_op_resource_tbl              := l_op_resource_tbl;
   --   x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;
        l_return_status := 'U';

        END; -- END block

    END LOOP; -- END Revisions processing loop
    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        --RETURN;
    END IF;
    /** Following for Rouitng Network Level validations that cannot be
        done only after the whole network is defined ,
        So cannot fit into link level validation code */
  -- Commented to make use of bom_calc_cynp.calc_cynp (bug 2689249)
/*
    FOR I IN 1..l_op_network_tbl.COUNT LOOP
    BEGIN

      IF    l_op_network_rec.connection_type <> 3  -- Not Rework
      AND   BOM_Rtg_Globals.Get_Eam_Item_Type <>
            BOM_Rtg_Globals.G_ASSET_ACTIVITY THEN
      bom_rtg_network_validate_api.validate_routing_network
      ( p_rtg_sequence_id => l_op_network_unexp_rec.routing_sequence_id
      , p_assy_item_id    => l_op_network_unexp_rec.assembly_item_id
      , p_org_id          => l_op_network_unexp_rec.organization_id
      , p_alt_rtg_desig   => l_op_network_rec.alternate_routing_code
      , p_operation_type  => l_op_network_rec.operation_type
      , x_status          => l_return_status
      , x_message         => l_other_message
      ) ;
     IF BOM_Rtg_Globals.Get_Debug = 'Y'
     THEN Error_Handler.Write_Debug
      ('After calling Rtg Network Validate API. Retrun status is '|| l_return_status);
     END IF;
--dbms_output.put_line('returned from nwk validate');
     IF  l_return_status = 'F' AND l_other_message IS NOT NULL THEN

        IF  UPPER( RTRIM(l_other_message) ) =
          UPPER('A loop has been detected in this Routing Network.')
        THEN
          Error_Handler.Add_Error_Token
          (  p_message_name       => 'BOM_OP_NWK_LOOP_EXIT'
          , p_token_tbl          => l_token_tbl
          , p_mesg_token_tbl     => l_mesg_token_tbl
          , x_mesg_token_tbl     => l_mesg_token_tbl
          );
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF  UPPER( RTRIM(l_other_message) ) =
          UPPER('A broken link exists in this routing Network.')
        THEN

          Error_Handler.Add_Error_Token
          (  p_message_name       => 'BOM_RTG_NTWK_BROKEN_LINK_EXIST'
           , p_token_tbl          => l_token_tbl
           , p_mesg_token_tbl     => l_mesg_token_tbl
           , x_mesg_token_tbl     => l_mesg_token_tbl
          );

          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE

          Error_Handler.Add_Error_Token
          (  p_message_name       => 'BOM_OP_NWK_VLDN_ERROR'
           , p_token_tbl          => l_token_tbl
           , p_mesg_token_tbl     => l_mesg_token_tbl
           , x_mesg_token_tbl     => l_mesg_token_tbl
          );

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
--dbms_output.put_line('before raising excptn');
	RAISE EXC_SEV_QUIT_OBJECT ;
      END IF;
    END IF;

    END;
    END LOOP; -- END
*/

    l_temp_rtg_id := BOM_RTG_Globals.Get_Routing_Sequence_Id();
    IF l_process_op THEN
         bom_calc_cynp.calc_cynp_rbo(p_routing_sequence_id => l_temp_rtg_id,
			             p_operation_type      => BOM_Rtg_Globals.G_PROCESS_OP,
				     p_update_events       => 0,
				     x_token_tbl => l_token_tbl,
				     x_err_msg => l_other_message,
				     x_return_status => l_dummy);

	IF l_dummy = 'E' THEN
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
          Error_Handler.Add_Error_Token
          (  p_message_name       => l_other_message
           , p_token_tbl          => l_token_tbl
           , p_mesg_token_tbl     => l_mesg_token_tbl
           , x_mesg_token_tbl     => l_mesg_token_tbl
          );
          l_return_status := FND_API.G_RET_STS_ERROR;
	  RAISE EXC_SEV_QUIT_OBJECT ;
	 END IF;
	END IF;
    END IF;
    IF l_line_op THEN
	 bom_calc_cynp.calc_cynp_rbo(p_routing_sequence_id => l_temp_rtg_id,
			             p_operation_type      => BOM_Rtg_Globals.G_LINE_OP,
				     p_update_events       => 0,
				     x_token_tbl => l_token_tbl,
				     x_err_msg => l_other_message,
				     x_return_status => l_dummy);

	IF l_dummy = 'E' THEN
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
          Error_Handler.Add_Error_Token
          (  p_message_name       => l_other_message
           , p_token_tbl          => l_token_tbl
           , p_mesg_token_tbl     => l_mesg_token_tbl
           , x_mesg_token_tbl     => l_mesg_token_tbl
          );
          l_return_status := FND_API.G_RET_STS_ERROR;
	  RAISE EXC_SEV_QUIT_OBJECT ;
	 END IF;
	END IF;

    END IF;

  /* end of the whole network validation */

  /*below change for RBO support for OSFM*/
   IF ( l_op_network_tbl.COUNT = BOM_RTG_Globals.Get_Osfm_NW_Count() )
   AND( l_op_network_tbl.COUNT <> 0  )
   AND ( l_temp_rtg_id IS NOT NULL AND l_temp_rtg_id <>0 )THEN
     IF BOM_Rtg_Globals.Get_Debug = 'Y'
     THEN Error_Handler.Write_Debug
      ('Op Network: Calling BOM_Validate_Op_Network.Check_WSM_Netowrk_Attribs....');
     END IF;

     BOM_Validate_Op_Network.Check_WSM_Netowrk_Attribs  (
      p_routing_sequence_id =>l_temp_rtg_id
    , p_prev_start_id      => l_prev_start_id
    , p_prev_end_id        => l_prev_end_id
    , x_mesg_token_tbl     => l_mesg_token_tbl
    , x_Return_status      => l_return_status
     );

     IF BOM_Rtg_Globals.Get_Debug = 'Y'
     THEN Error_Handler.Write_Debug
      ('Op Network: Check_WSM_Netowrk_Attribs comleted with Status '||
      l_return_status);
     END IF;


     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
       RAISE EXC_SEV_QUIT_OBJECT ;
     END IF;
     IF BOM_Rtg_Globals.Get_Debug = 'Y'
     THEN Error_Handler.Write_Debug
      ('Op Network: Calling BOM_Op_Network_UTIL.Set_WSM_Network_Sub_Loc...');
     END IF;

     BOM_Op_Network_UTIL.Set_WSM_Network_Sub_Loc(
      p_routing_sequence_id =>l_temp_rtg_id
    , p_end_id             => l_prev_end_id
    , x_mesg_token_tbl     => l_mesg_token_tbl
    , x_Return_status      => l_return_status
     );

     IF BOM_Rtg_Globals.Get_Debug = 'Y'
     THEN Error_Handler.Write_Debug
      ('Op Network: Set_WSM_Network_Sub_Loc comleted with Status '||
      l_return_status);
     END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
       RAISE EXC_SEV_QUIT_OBJECT ;
     END IF;
   END IF;
  /*above change for RBO support for OSFM*/

    -- bug:5235684 SSOS is required for standard/network routing for serial controlled item
    -- and it should be present on primary path.
    IF (    ( l_return_status = FND_API.G_RET_STS_SUCCESS )
        AND ( BOM_RTG_Globals.Get_Routing_Sequence_Id() IS NOT NULL )  )
    THEN
      Bom_Validate_Rtg_Header.Validate_SSOS
          (  p_routing_sequence_id  => BOM_RTG_Globals.Get_Routing_Sequence_Id()
           , p_ser_start_op_seq     => NULL
           , p_validate_from_table  => TRUE
           , x_mesg_token_tbl       => l_Mesg_Token_Tbl
           , x_return_status        => l_return_status );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE EXC_SEV_QUIT_OBJECT;
      END IF;
    END IF; -- end if ( l_return_status = FND_API.G_RET_STS_SUCCESS )

    --bug:5060186 Copy the first or last operation of the network if disabled.
    IF ( BOM_RTG_Globals.Get_Routing_Sequence_Id() IS NOT NULL ) THEN
      Bom_Op_Network_Util.Copy_First_Last_Dis_Op(
                                                  p_routing_sequence_id => BOM_RTG_Globals.Get_Routing_Sequence_Id()
                                                , x_mesg_token_tbl     => l_mesg_token_tbl
                                                , x_return_status      => l_return_status );

      IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
          Error_Handler.Write_Debug
            ( 'Op Network: Copy First/Last Disabled Operation completed with status ' ||
              l_return_status );
      END IF;
    END IF;

     --  Load OUT parameters

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

     x_return_status            := l_bo_return_status;
     x_op_network_tbl           := l_op_network_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

  EXCEPTION
        WHEN EXC_SEV_QUIT_OBJECT THEN
            Bom_Rtg_Error_Handler.Log_Error
            ( p_rtg_header_rec         => l_rtg_header_rec
            , p_op_network_tbl         => l_op_network_tbl
            , p_rtg_revision_tbl       => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            , p_operation_tbl          => Bom_Rtg_Pub.G_MISS_OPERATION_TBL
            , p_op_resource_tbl        => Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
            , p_sub_resource_tbl       => Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
            , p_mesg_token_tbl         => l_mesg_token_tbl
            , p_error_status           => Error_Handler.G_STATUS_ERROR
            , p_error_scope            => Error_Handler.G_SCOPE_ALL
            , p_error_level            => Error_Handler.G_NWK_LEVEL
            , p_other_message          => l_other_message
            , p_other_status           => Error_Handler.G_STATUS_ERROR
            , p_other_token_tbl        => l_other_token_tbl
            , p_other_mesg_appid       => 'BOM'
            , p_entity_index           => 1
            , x_rtg_header_rec         => l_rtg_header_rec
            , x_rtg_revision_tbl       => l_rtg_revision_tbl
            , x_operation_tbl          => l_operation_tbl
            , x_op_resource_tbl        => l_op_resource_tbl
            , x_sub_resource_tbl       => l_sub_resource_tbl
            , x_op_network_tbl         => l_op_network_tbl
            );
        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;

	x_op_network_tbl:= l_op_network_tbl;
	x_return_status	:= l_return_status;
	x_Mesg_Token_Tbl:= l_Mesg_Token_Tbl;

END Op_Networks;

--  Operation_Sequences

/****************************************************************************
* Procedure : Operation_Sequences
* Parameters IN   : Operation Sequences Table and all the other sibiling and
*                   child entities
* Parameters OUT  : Operatin Sequences and all the other sibiling and
*                   child entities entities
* Purpose   : This procedure will process all the Operation Seuqence records.
*             It will process the entities that are children of operation
*             sequences.
*****************************************************************************/

PROCEDURE Operation_Sequences
(   p_validation_level        IN  NUMBER
,   p_organization_id         IN  NUMBER   := NULL
,   p_assembly_item_name      IN  VARCHAR2 := NULL
,   p_alternate_routing_code  IN  VARCHAR2 := NULL
,   p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
,   p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
,   p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
,   x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
,   x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
,   x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
,   x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status           IN OUT NOCOPY VARCHAR2
)

IS

/* Exposed and Unexposed record */
l_operation_rec         Bom_Rtg_Pub.Operation_Rec_Type ;
l_operation_tbl         Bom_Rtg_Pub.Operation_Tbl_Type ;
l_op_unexp_rec          Bom_Rtg_Pub.Op_Unexposed_Rec_Type ;
l_old_operation_rec     Bom_Rtg_Pub.Operation_Rec_Type ;
l_old_op_unexp_rec      Bom_Rtg_Pub.Op_Unexposed_Rec_Type ;

/* Other Entities */
l_rtg_header_rec        Bom_Rtg_Pub.Rtg_Header_Rec_Type ;
l_rtg_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
l_op_resource_tbl       Bom_Rtg_Pub.Op_Resource_Tbl_Type   := p_op_resource_tbl ;
l_sub_resource_tbl      Bom_Rtg_Pub.Sub_Resource_Tbl_Type  := p_sub_resource_tbl ;
l_op_network_tbl        Bom_Rtg_Pub.Op_Network_Tbl_Type    := p_op_network_tbl ;

/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);


/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_process_children      BOOLEAN := TRUE ;
l_parent_exists         BOOLEAN := FALSE ;
l_valid                 BOOLEAN := TRUE ;

l_op_seq_num		NUMBER;
l_strt_eff_date		DATE;
l_tmp_cnt		NUMBER := 1;
l_dummy_cnt		NUMBER;
l_temp_op_rec_tbl	BOM_RTG_Globals.Temp_Op_Rec_Tbl_Type;

l_cfm_routing_flag    BOM_OPERATIONAL_ROUTINGS.CFM_ROUTING_FLAG%TYPE;
l_routing_sequence_id NUMBER;

BEGIN

   --  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_operation_tbl    := p_operation_tbl ;
   l_op_unexp_rec.organization_id := BOM_Rtg_Globals.Get_Org_Id ;
   l_temp_op_rec_tbl.DELETE;
   l_tmp_cnt := 1;
   FOR I IN 1..l_operation_tbl.COUNT LOOP
   BEGIN

      --  Load local records.
      l_operation_rec := l_operation_tbl(I);

      l_operation_rec.transaction_type :=
         UPPER(l_operation_rec.transaction_type);


      --
      -- make sure to set process_children to false at the start of
      -- every iteration
      --
      l_process_children := FALSE;

      -- Initialize the init_eff_date_op_num flag to false for every operation (bug 2767019)
      BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag := FALSE;

      --
      -- Initialize the Unexposed Record for every iteration of the Loop
      -- so that sequence numbers get generated for every new row.
      --
      l_op_unexp_rec.Operation_Sequence_Id   := NULL ;
      l_op_unexp_rec.Standard_Operation_Id   := NULL ;
      l_op_unexp_rec.Department_Id           := NULL ;
      l_op_unexp_rec.Process_Op_Seq_Id       := NULL ;
      l_op_unexp_rec.Line_Op_Seq_Id          := NULL ;
      l_op_unexp_rec.DG_Sequence_Id          := NULL ;
      l_op_unexp_rec.User_Elapsed_Time       := NULL ;
      l_op_unexp_rec.DG_Description          := NULL ;
      l_op_unexp_rec.DG_New                  := NULL ;
      l_op_unexp_rec.Lowest_acceptable_yield := NULL ;	-- Added for MES Enhancement
      l_op_unexp_rec.Use_org_settings	     := NULL ;
      l_op_unexp_rec.Queue_mandatory_flag    := NULL ;
      l_op_unexp_rec.Run_mandatory_flag	     := NULL ;
      l_op_unexp_rec.To_move_mandatory_flag  := NULL ;
      l_op_unexp_rec.Show_next_op_by_default := NULL ;
      l_op_unexp_rec.Show_scrap_code	     := NULL ;
      l_op_unexp_rec.Show_lot_attrib	     := NULL ;
      l_op_unexp_rec.Track_multiple_res_usage_dates := NULL ;  -- End of MES Changes

      IF p_assembly_item_name IS NOT NULL AND
         p_organization_id IS NOT NULL
      THEN
         -- Revised Item or Routing parent exists
         l_parent_exists := TRUE ;
      END IF ;

      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF (l_operation_rec.return_status IS NULL OR
         l_operation_rec.return_status = FND_API.G_MISS_CHAR)
         AND

         -- Did Rtg Header call this procedure, that is,
         -- if revised item or routing header exists,
         -- then is this record a child ?
         (NOT l_parent_exists
          OR
          (l_parent_exists AND
            (l_operation_rec.assembly_item_name = p_assembly_item_name AND
             l_op_unexp_rec.organization_id = p_organization_id        AND
             NVL(l_operation_rec.alternate_routing_code, FND_API.G_MISS_CHAR)
                                  = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)
             )
          )
         )
      THEN

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_operation_rec.return_status := FND_API.G_RET_STS_SUCCESS;

         --
         -- Process Flow step 3 :Check if transaction_type is valid
         -- Transaction_Type must be CRATE, UPDATE, DELETE
         -- Call the BOM_Rtg_Globals.Transaction_Type_Validity
         --

         BOM_Rtg_Globals.Transaction_Type_Validity
         (   p_transaction_type => l_operation_rec.transaction_type
         ,   p_entity           => 'Op_Seq'
         ,   p_entity_id        => l_operation_rec.operation_sequence_number
         ,   x_valid            => l_valid
         ,   x_mesg_token_tbl   => l_mesg_token_tbl
         ) ;

         IF NOT l_valid
         THEN
             l_return_status := Error_Handler.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         --
         -- Process Flow step 4(a): Convert user unique index to unique
         -- index I
         -- Call BOM_Rtg_Val_To_Id.Operation_UUI_To_UI Shared Utility Package
         --

         BOM_Rtg_Val_To_Id.Operation_UUI_To_UI
         ( p_operation_rec         => l_operation_rec
         , p_op_unexp_rec          => l_op_unexp_rec
         , x_op_unexp_rec          => l_op_unexp_rec
         , x_mesg_token_tbl        => l_mesg_token_tbl
         , x_return_status         => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_OP_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_operation_rec.operation_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('Convert to User Unique Index to Index2 completed
                with return_status: ' || l_return_status) ;
         END IF ;

         END IF;

     /*
         --
         -- Process Flow step 4(b): Convert user unique index to unique
         -- index II
         -- Call the BOM_Rtg_Val_To_Id.Operation_UUI_To_UI2
         --

         BOM_Rtg_Val_To_Id.Operation_UUI_To_UI2
         ( p_operation_rec      => l_operation_rec
         , p_op_unexp_rec       => l_op_unexp_rec
         , x_op_unexp_rec       => l_op_unexp_rec
         , x_mesg_token_tbl     => l_mesg_token_tbl
         , x_other_message      => l_other_message
         , x_other_token_tbl    => l_other_token_tbl
         , x_return_status      => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index2 completed with return_status:
            ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            RAISE EXC_SEV_QUIT_SIBLINGS ;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                   l_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;
     */
         --
         -- Process Flow step 5: Verify Operation Sequence's existence
         -- Call the Bom_Validate_Op_Seq.Check_Existence
         --
         --
         Bom_Validate_Op_Seq.Check_Existence
         (  p_operation_rec          => l_operation_rec
         ,  p_op_unexp_rec           => l_op_unexp_rec
         ,  x_old_operation_rec      => l_old_operation_rec
         ,  x_old_op_unexp_rec       => l_old_op_unexp_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check Existence completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_OP_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
            l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_operation_rec.assembly_item_name ;
	    RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
            l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_operation_rec.assembly_item_name ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

         --
         -- Process Flow step 6: Is Operation Sequence record an orphan ?
         --

         IF NOT l_parent_exists
         THEN

            --
            -- Process Flow step 7 : Check Assembly Item Operability for Routing
            -- Call Bom_Validate_Rtg_Header.Check_Access
            --
            Bom_Validate_Rtg_Header.Check_Access
            ( p_assembly_item_name => l_operation_rec.assembly_item_name
            , p_assembly_item_id   => l_op_unexp_rec.assembly_item_id
            , p_organization_id    => l_op_unexp_rec.organization_id
            , p_alternate_rtg_code => l_operation_rec.alternate_routing_code
            , p_mesg_token_tbl     => Error_Handler.G_MISS_MESG_TOKEN_TBL
            , x_mesg_token_tbl     => l_mesg_token_tbl
            , x_return_status      => l_return_status
            ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check Assembly Item Operability completed with return_status: ' || l_return_status) ;
         END IF ;


            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               l_other_message := 'BOM_OP_RITACC_FAT_FATAL';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
               l_return_status := 'F' ;
               RAISE EXC_FAT_QUIT_SIBLINGS ;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_OP_RITACC_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

            --
            -- Process Flow step 8 : Check the routing does not have a common
            --
            --

            Bom_Validate_Op_Seq.Check_CommonRtg
            (  p_routing_sequence_id   => l_op_unexp_rec.routing_sequence_id
            ,  x_mesg_token_tbl       => l_mesg_token_tbl
            ,  x_return_status        => l_return_status
            ) ;

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check the routing non-referenced common completed with return_status: ' || l_return_status) ;
         END IF ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN

              l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
              l_token_tbl(1).token_value := l_operation_rec.operation_sequence_number ;
              l_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
              l_token_tbl(2).token_value := l_operation_rec.assembly_item_name ;

              Error_Handler.Add_Error_Token
              ( p_Message_Name   => 'BOM_OP_RTG_HAVECOMMON'
              , p_mesg_token_tbl => l_mesg_token_tbl
              , x_mesg_token_tbl => l_mesg_token_tbl
              , p_Token_Tbl      => l_token_tbl
              ) ;

               l_return_status := 'F';
               RAISE EXC_FAT_QUIT_SIBLINGS ;

            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_OP_ACCESS_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

         END IF;  -- Parent not exists


         -- Process Flow Step  : Check parent CFM Routing Flag
         -- Validate Non-Operated Columns using CFM Routing Flag
         -- Standard Routing, Flow Routing, Lot Based Routing.
         -- If a non-operated column is not null, the procedure set it to null
         -- and occur Warning.
         --
         BOM_Validate_Op_Seq.Check_NonOperated_Attribute
         ( p_operation_rec        => l_operation_rec
         , p_op_unexp_rec         => l_op_unexp_rec
         , x_operation_rec        => l_operation_rec
         , x_op_unexp_rec         => l_op_unexp_rec
         , x_mesg_token_tbl       => l_mesg_token_tbl
         , x_return_status        => l_return_status
         ) ;


         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check non-operating columns completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
	    l_other_message := 'BOM_OP_NONOPERATED_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <>0
         THEN
            Bom_Rtg_Error_Handler.Log_Error
            (  p_operation_tbl       => l_operation_tbl
            ,  p_op_resource_tbl     => l_op_resource_tbl
            ,  p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_op_network_tbl      => l_op_network_tbl
            ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_OP_LEVEL
            ,  p_entity_index        => I
            ,  p_error_scope         => NULL
            ,  p_other_message       => NULL
            ,  p_other_mesg_appid    => 'BOM'
            ,  p_other_status        => NULL
            ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
            ) ;
         END IF;


         --
         -- Process Flow step 9: Value to Id conversions
         -- Call BOM_Rtg_Val_To_Id.Operation_VID
         --
         BOM_Rtg_Val_To_Id.Operation_VID
         (  p_operation_rec          => l_operation_rec
         ,  p_op_unexp_rec           => l_op_unexp_rec
         ,  x_op_unexp_rec           => l_op_unexp_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         );

         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Value-id conversions completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_operation_rec.transaction_type = 'CREATE'
            THEN
               l_other_message := 'BOM_OP_VID_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_VID_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <>0
         THEN
            Bom_Rtg_Error_Handler.Log_Error
            (  p_operation_tbl       => l_operation_tbl
            ,  p_op_resource_tbl     => l_op_resource_tbl
            ,  p_sub_resource_tbl    => l_sub_resource_tbl
            ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
            ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
            ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_OP_LEVEL
            ,  p_entity_index        => I
            ,  p_error_scope         => NULL
            ,  p_other_message       => NULL
            ,  p_other_mesg_appid    => 'BOM'
            ,  p_other_status        => NULL
            ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
            ,  x_rtg_header_rec      => l_rtg_header_rec
            ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
            ,  x_op_network_tbl      => l_op_network_tbl
            ,  x_operation_tbl       => l_operation_tbl
            ,  x_op_resource_tbl     => l_op_resource_tbl
            ,  x_sub_resource_tbl    => l_sub_resource_tbl
            ) ;
         END IF;

         --copy the routing sequence id, since all the operation will belong to same routing
         l_routing_sequence_id := l_op_unexp_rec.Routing_Sequence_Id;
         --
         -- Process Flow step 10 : Check required fields exist
         -- (also includes a part of conditionally required fields)
         --

         Bom_Validate_Op_Seq.Check_Required
         ( p_operation_rec              => l_operation_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;


         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check required completed with return_status: ' || l_return_status) ;
         END IF ;


         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
            THEN
               l_other_message := 'BOM_OP_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;

         --
         -- Process Flow step 11 : Attribute Validation for CREATE and UPDATE
         --
         --

         IF l_operation_rec.transaction_type IN
            (BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
         THEN
            Bom_Validate_Op_Seq.Check_Attributes
            ( p_operation_rec     => l_operation_rec
            , p_op_unexp_rec      => l_op_unexp_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;
            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Attribute validation completed with return_status: ' || l_return_status) ;
            END IF ;

            IF BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag -- Added for bug 2767019
	    THEN
		-- This flag is set only for Create transactions and
		--   if the date is in the past wrt time, but on the same day
		-- Initialize the date which will be used for this operation
		l_operation_rec.Start_Effective_Date := sysdate;
	    END IF;
	    IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               IF l_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               THEN
                  l_other_message := 'BOM_OP_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_operation_rec.operation_sequence_number ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_OP_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                           l_operation_rec.operation_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
               Bom_Rtg_Error_Handler.Log_Error
               (  p_operation_tbl       => l_operation_tbl
               ,  p_op_resource_tbl     => l_op_resource_tbl
               ,  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_OP_LEVEL
               ,  p_entity_index        => I
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
               ) ;
           END IF;
        END IF;


        IF l_operation_rec.transaction_type IN
           (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
        THEN

        --
        -- Process flow step 12: Populate NULL columns for Update and Delete
        -- Call Bom_Default_Op_Seq.Populate_Null_Columns
        --

           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns') ;
           END IF ;

           Bom_Default_Op_Seq.Populate_Null_Columns
           (   p_operation_rec     => l_operation_rec
           ,   p_old_operation_Rec => l_old_operation_rec
           ,   p_op_unexp_rec      => l_op_unexp_rec
           ,   p_old_op_unexp_rec  => l_old_op_unexp_rec
           ,   x_operation_Rec     => l_operation_rec
           ,   x_op_unexp_rec      => l_op_unexp_rec
           ) ;


        ELSIF l_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
        THEN
        --
        -- Process Flow step 13 : Default missing values for Operation (CREATE)
        -- (also includes Entity Defaulting)
        -- Call Bom_Default_Op_Seq.Attribute_Defaulting
        --

           Bom_Default_Op_Seq.Attribute_Defaulting
           (   p_operation_rec   => l_operation_rec
           ,   p_op_unexp_rec    => l_op_unexp_rec
           ,   x_operation_rec   => l_operation_rec
           ,   x_op_unexp_rec    => l_op_unexp_rec
           ,   x_mesg_token_tbl  => l_mesg_token_tbl
           ,   x_return_status   => l_return_status
           ) ;

           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
              l_other_message := 'BOM_OP_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'BOM_OP_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                           l_operation_rec.operation_sequence_number ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
               Bom_Rtg_Error_Handler.Log_Error
               (  p_operation_tbl       => l_operation_tbl
               ,  p_op_resource_tbl     => l_op_resource_tbl
               ,  p_sub_resource_tbl    => l_sub_resource_tbl
               ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
               ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
               ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_OP_LEVEL
               ,  p_entity_index        => I
               ,  p_error_scope         => NULL
               ,  p_other_message       => NULL
               ,  p_other_mesg_appid    => 'BOM'
               ,  p_other_status        => NULL
               ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
               ,  x_rtg_header_rec      => l_rtg_header_rec
               ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
               ,  x_op_network_tbl      => l_op_network_tbl
               ,  x_operation_tbl       => l_operation_tbl
               ,  x_op_resource_tbl     => l_op_resource_tbl
               ,  x_sub_resource_tbl    => l_sub_resource_tbl
               ) ;
          END IF;
       END IF;

       --
       -- Process Flow step 14: Conditionally Required Attributes
       --
       --
       IF l_operation_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CREATE
                                              , BOM_Rtg_Globals.G_OPR_UPDATE )
       THEN
          Bom_Validate_Op_Seq.Check_Conditionally_Required
          ( p_operation_rec              => l_operation_rec
          , p_op_unexp_rec               => l_op_unexp_rec
          , x_return_status              => l_return_status
          , x_mesg_token_tbl             => l_mesg_token_tbl
          ) ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check Conditionally Required Attr. completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_OP_CONREQ_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_OP_CONREQ_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             Bom_Rtg_Error_Handler.Log_Error
             (  p_operation_tbl       => l_operation_tbl
             ,  p_op_resource_tbl     => l_op_resource_tbl
             ,  p_sub_resource_tbl    => l_sub_resource_tbl
             ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
             ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
             ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
             ,  p_mesg_token_tbl      => l_mesg_token_tbl
             ,  p_error_status        => 'W'
             ,  p_error_level         => Error_Handler.G_OP_LEVEL
             ,  p_entity_index        => I
             ,  p_error_scope         => NULL
             ,  p_other_message       => NULL
             ,  p_other_mesg_appid    => 'BOM'
             ,  p_other_status        => NULL
             ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
             ,  x_rtg_header_rec      => l_rtg_header_rec
             ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
             ,  x_op_network_tbl      => l_op_network_tbl
             ,  x_operation_tbl       => l_operation_tbl
             ,  x_op_resource_tbl     => l_op_resource_tbl
             ,  x_sub_resource_tbl    => l_sub_resource_tbl
             ) ;
          END IF;
       END IF;

       --
       -- Process Flow step 15: Entity defaulting for CREATE and UPDATE
       -- Merged into Process Flow step 13 : Default missing values
       --

       IF l_operation_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CREATE
                                              , BOM_Rtg_Globals.G_OPR_UPDATE )
       THEN
          Bom_Default_Op_Seq.Entity_Defaulting
              (   p_operation_rec   => l_operation_rec
              ,   p_op_unexp_rec    => l_op_unexp_rec
              ,   x_operation_rec   => l_operation_rec
              ,   x_op_unexp_rec    => l_op_unexp_rec
              ,   x_mesg_token_tbl  => l_mesg_token_tbl
              ,   x_return_status   => l_return_status
              ) ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Entity defaulting completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_OP_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_OP_ENTDEF_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             Bom_Rtg_Error_Handler.Log_Error
             (  p_operation_tbl       => l_operation_tbl
             ,  p_op_resource_tbl     => l_op_resource_tbl
             ,  p_sub_resource_tbl    => l_sub_resource_tbl
             ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
             ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
             ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
             ,  p_mesg_token_tbl      => l_mesg_token_tbl
             ,  p_error_status        => 'W'
             ,  p_error_level         => Error_Handler.G_OP_LEVEL
             ,  p_entity_index        => I
             ,  p_error_scope         => NULL
             ,  p_other_message       => NULL
             ,  p_other_mesg_appid    => 'BOM'
             ,  p_other_status        => NULL
             ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
             ,  x_rtg_header_rec      => l_rtg_header_rec
             ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
             ,  x_op_network_tbl      => l_op_network_tbl
             ,  x_operation_tbl       => l_operation_tbl
             ,  x_op_resource_tbl     => l_op_resource_tbl
             ,  x_sub_resource_tbl    => l_sub_resource_tbl
             ) ;
          END IF ;
       END IF ;


       --
       -- Process Flow step 16 - Entity Level Validation
       -- Call Bom_Validate_Op_Seq.Check_Entity
       --
       Bom_Validate_Op_Seq.Check_Entity
          (  p_operation_rec     => l_operation_rec
          ,  p_op_unexp_rec      => l_op_unexp_rec
          ,  p_old_operation_rec => l_old_operation_rec
          ,  p_old_op_unexp_rec  => l_old_op_unexp_rec
          ,  x_operation_rec     => l_operation_rec
          ,  x_op_unexp_rec      => l_op_unexp_rec
          ,  x_mesg_token_tbl    => l_mesg_token_tbl
          ,  x_return_status     => l_return_status
          ) ;


       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          IF l_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
          THEN
             l_other_message := 'BOM_OP_ENTVAL_CSEV_SKIP';
             l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                           l_operation_rec.operation_sequence_number ;
             RAISE EXC_SEV_SKIP_BRANCH ;
          ELSE
             RAISE EXC_SEV_QUIT_RECORD ;
          END IF;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_OP_ENTVAL_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                        l_operation_rec.operation_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
       THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_operation_tbl       => l_operation_tbl
          ,  p_op_resource_tbl     => l_op_resource_tbl
          ,  p_sub_resource_tbl    => l_sub_resource_tbl
          ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
          ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
          ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => 'W'
          ,  p_error_level         => Error_Handler.G_OP_LEVEL
          ,  p_entity_index        => I
          ,  p_error_scope         => NULL
          ,  p_other_message       => NULL
          ,  p_other_mesg_appid    => 'BOM'
          ,  p_other_status        => NULL
          ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
          ,  x_rtg_header_rec      => l_rtg_header_rec
          ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
          ,  x_op_network_tbl      => l_op_network_tbl
          ,  x_operation_tbl       => l_operation_tbl
          ,  x_op_resource_tbl     => l_op_resource_tbl
          ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;
       END IF;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation completed with '
             || l_return_Status || ' proceeding for database writes . . . ') ;
       END IF;

       --
       -- Process Flow step 16 : Database Writes
       --
          Bom_Op_Seq_Util.Perform_Writes
          (   p_operation_rec       => l_operation_rec
          ,   p_op_unexp_rec        => l_op_unexp_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;

       IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_OP_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                          l_operation_rec.operation_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl .COUNT <>0
       THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_operation_tbl       => l_operation_tbl
          ,  p_op_resource_tbl     => l_op_resource_tbl
          ,  p_sub_resource_tbl    => l_sub_resource_tbl
          ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
          ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
          ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => 'W'
          ,  p_error_level         => Error_Handler.G_OP_LEVEL
          ,  p_entity_index        => I
          ,  p_error_scope         => NULL
          ,  p_other_message       => NULL
          ,  p_other_mesg_appid    => 'BOM'
          ,  p_other_status        => NULL
          ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
          ,  x_rtg_header_rec      => l_rtg_header_rec
          ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
          ,  x_op_network_tbl      => l_op_network_tbl
          ,  x_operation_tbl       => l_operation_tbl
          ,  x_op_resource_tbl     => l_op_resource_tbl
          ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;
       END IF;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Op Database writes completed with status  ' || l_return_status);
       END IF;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_operation_tbl(I)          := l_operation_rec;


    -- Indicate that children need to be processed
    -- l_process_children := TRUE;
   IF l_operation_rec.reference_flag = 1 AND nvl(BOM_Globals.Get_Caller_Type,'') = 'MIGRATION' THEN --for iSetup issue
       FOR J IN 1..l_op_resource_tbl.COUNT LOOP

         IF l_operation_rec.Assembly_Item_Name = l_op_resource_tbl(J).Assembly_Item_Name AND
            l_operation_rec.Organization_Code = l_op_resource_tbl(J).Organization_Code AND
            l_operation_rec.Operation_Sequence_Number = l_op_resource_tbl(J).Operation_Sequence_Number AND
            l_operation_rec.Start_Effective_Date = l_op_resource_tbl(J).Op_Start_Effective_Date AND
            nvl(l_operation_rec.Alternate_Routing_Code,'@#$%^') = nvl(l_op_resource_tbl(J).Alternate_Routing_Code,'@#$%^') THEN
         l_op_resource_tbl(J).return_status := nvl(l_return_status,'S');
         END IF;
       END LOOP;
       FOR K IN 1..l_sub_resource_tbl.COUNT LOOP
         IF l_operation_rec.Assembly_Item_Name = l_sub_resource_tbl(K).Assembly_Item_Name AND
            l_operation_rec.Organization_Code = l_sub_resource_tbl(K).Organization_Code AND
            l_operation_rec.Operation_Sequence_Number = l_sub_resource_tbl(K).Operation_Sequence_Number AND
            l_operation_rec.Start_Effective_Date = l_sub_resource_tbl(K).Op_Start_Effective_Date AND
            nvl(l_operation_rec.Alternate_Routing_Code,'@#$%^') = nvl(l_sub_resource_tbl(K).Alternate_Routing_Code,'@#$%^') THEN
         l_sub_resource_tbl(K).return_status := nvl(l_return_status,'S');
         END IF;
       END LOOP;
       l_process_children := FALSE;
   ELSE
     l_process_children := TRUE;
   END IF;



    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
          Bom_Rtg_Error_Handler.Log_Error
          (  p_operation_tbl       => l_operation_tbl
          ,  p_op_resource_tbl     => l_op_resource_tbl
          ,  p_sub_resource_tbl    => l_sub_resource_tbl
          ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
          ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
          ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => Error_Handler.G_STATUS_ERROR
          ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level         => Error_Handler.G_OP_LEVEL
          ,  p_entity_index        => I
          ,  p_other_message       => NULL
          ,  p_other_mesg_appid    => 'BOM'
          ,  p_other_status        => NULL
          ,  p_other_token_tbl     => Error_Handler.G_MISS_TOKEN_TBL
          ,  x_rtg_header_rec      => l_rtg_header_rec
          ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
          ,  x_op_network_tbl      => l_op_network_tbl
          ,  x_operation_tbl       => l_operation_tbl
          ,  x_op_resource_tbl     => l_op_resource_tbl
          ,  x_sub_resource_tbl    => l_sub_resource_tbl
          ) ;


         l_process_children := TRUE;

         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status := l_return_status ;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_operation_tbl       := l_operation_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
         x_op_network_tbl      := l_op_network_tbl ;


      WHEN EXC_SEV_QUIT_BRANCH THEN

         Bom_Rtg_Error_Handler.Log_Error
         (  p_operation_tbl       => l_operation_tbl
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_OP_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;



         l_process_children := FALSE;

         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status  := l_return_status;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_operation_tbl       := l_operation_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
         x_op_network_tbl      := l_op_network_tbl ;


      WHEN EXC_SEV_SKIP_BRANCH THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_operation_tbl       => l_operation_tbl
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_OP_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

        l_process_children    := FALSE ;
        IF l_bo_return_status = 'S'
        THEN
           l_bo_return_status := l_return_status ;
        END IF;
        x_return_status       := l_bo_return_status;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        x_operation_tbl       := l_operation_tbl ;
        x_op_resource_tbl     := l_op_resource_tbl ;
        x_sub_resource_tbl := l_sub_resource_tbl ;
        x_op_network_tbl      := l_op_network_tbl ;

      WHEN EXC_SEV_QUIT_SIBLINGS THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_operation_tbl       => l_operation_tbl
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_OP_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_process_children    := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
           l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_operation_tbl       := l_operation_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
         x_op_network_tbl      := l_op_network_tbl ;


      WHEN EXC_FAT_QUIT_BRANCH THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_operation_tbl       => l_operation_tbl
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_OP_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_process_children    := FALSE ;
         x_return_status       := Error_Handler.G_STATUS_FATAL;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_operation_tbl       := l_operation_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
         x_op_network_tbl      := l_op_network_tbl ;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_operation_tbl       => l_operation_tbl
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_OP_LEVEL
         ,  p_entity_index        => I
         ,  p_other_mesg_appid    => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

	l_process_children    := FALSE ;
        x_return_status       := Error_Handler.G_STATUS_FATAL;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        x_operation_tbl       := l_operation_tbl ;
        x_op_resource_tbl     := l_op_resource_tbl ;
        x_sub_resource_tbl    := l_sub_resource_tbl ;
        x_op_network_tbl      := l_op_network_tbl ;

/*
    WHEN EXC_FAT_QUIT_OBJECT THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_operation_tbl       => l_operation_tbl
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_OP_LEVEL
         ,  p_entity_index        => I
            , p_other_mesg_appid     => 'BOM'
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_return_status       := 'Q';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_operation_tbl       := l_operation_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
         x_op_network_tbl      := l_op_network_tbl ;
*/

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
         Bom_Rtg_Error_Handler.Log_Error
         (  p_operation_tbl       => l_operation_tbl
         ,  p_op_resource_tbl     => l_op_resource_tbl
         ,  p_sub_resource_tbl    => l_sub_resource_tbl
         ,  p_rtg_header_rec      => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
         ,  p_rtg_revision_tbl    => Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
         ,  p_op_network_tbl      => Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_OP_LEVEL
         ,  p_error_scope         => NULL
         ,  p_other_mesg_appid    => 'BOM'
         ,  p_entity_index        => I
         ,  x_rtg_header_rec      => l_rtg_header_rec
         ,  x_rtg_revision_tbl    => l_rtg_revision_tbl
         ,  x_op_network_tbl      => l_op_network_tbl
         ,  x_operation_tbl       => l_operation_tbl
         ,  x_op_resource_tbl     => l_op_resource_tbl
         ,  x_sub_resource_tbl    => l_sub_resource_tbl
         ) ;

         l_return_status       := 'U';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         x_operation_tbl       := l_operation_tbl ;
         x_op_resource_tbl     := l_op_resource_tbl ;
         x_sub_resource_tbl    := l_sub_resource_tbl ;
         x_op_network_tbl      := l_op_network_tbl ;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;


   IF l_process_children
   THEN
      -- Process Operation Resources that are direct children of this
      -- Operation

	   l_op_seq_num := nvl(l_operation_rec.New_Operation_Sequence_Number, l_operation_rec.operation_sequence_number);
	   l_strt_eff_date := nvl(l_operation_rec.New_Start_Effective_Date, l_operation_rec.start_effective_date);

	IF l_operation_rec.New_Operation_Sequence_Number IS NOT NULL -- populate the temp_op_rec_tbl to be used later by networks
	  OR l_operation_rec.New_Start_Effective_Date IS NOT NULL
	  OR BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag THEN -- added for bug 2767019

	   l_temp_op_rec_tbl(l_tmp_cnt).old_op_seq_num := l_operation_rec.operation_sequence_number;
	   l_temp_op_rec_tbl(l_tmp_cnt).new_op_seq_num := l_op_seq_num;

	   l_temp_op_rec_tbl(l_tmp_cnt).old_start_eff_date := l_operation_rec.start_effective_date;
	   l_temp_op_rec_tbl(l_tmp_cnt).new_start_eff_date := l_strt_eff_date;

	   l_tmp_cnt := l_tmp_cnt + 1;
	   BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag := TRUE;

	   -- Set the temp_op_rec_tbl to be used by the children(res and sub res) and network (for OSFM)
	   BOM_RTG_Globals.Set_Temp_Op_Tbl(l_temp_op_rec_tbl);
	END IF;

      Operation_Resources
      (   p_validation_level        => p_validation_level
      ,   p_organization_id         => l_op_unexp_rec.organization_id
      ,   p_assembly_item_name      => l_operation_rec.assembly_item_name
      ,   p_alternate_routing_code  => l_operation_rec.alternate_routing_code
--    ,   p_operation_seq_num       => l_operation_rec.operation_sequence_number
--    ,   p_effectivity_date        => l_operation_rec.start_effective_date
      ,   p_operation_seq_num       => l_op_seq_num
      ,   p_effectivity_date        => l_strt_eff_date
      ,   p_operation_type          => l_operation_rec.operation_type
      ,   p_op_resource_tbl         => l_op_resource_tbl
      ,   p_sub_resource_tbl        => l_sub_resource_tbl
      ,   x_op_resource_tbl         => l_op_resource_tbl
      ,   x_sub_resource_tbl        => l_sub_resource_tbl
      ,   x_mesg_token_tbl          => l_mesg_token_tbl
      ,   x_return_status           => l_return_status
      ) ;

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   ELSIF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;

      -- Process Substitute Operation Resources that are direct children of this
      -- operation

      Sub_Operation_Resources
      (   p_validation_level         => p_validation_level
      ,   p_organization_id          => l_op_unexp_rec.organization_id
      ,   p_assembly_item_name       => l_operation_rec.assembly_item_name
      ,   p_alternate_routing_code   => l_operation_rec.alternate_routing_code
      ,   p_operation_seq_num       => l_op_seq_num
      ,   p_effectivity_date        => l_strt_eff_date
      ,   p_operation_type           => l_operation_rec.operation_type
      ,   p_sub_resource_tbl         => l_sub_resource_tbl
      ,   x_sub_resource_tbl         => l_sub_resource_tbl
      ,   x_mesg_token_tbl           => l_mesg_token_tbl
      ,   x_return_status            => l_return_status
      ) ;

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   ELSIF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;


   END IF;   -- Process children
   END LOOP; -- END Operation Sequences processing loop
   -- Reset the Init_Eff_Date_Op_Num flag so that this affects only it's children
   BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag := FALSE;


    -- bug:5060186 Copy the first or last operation of the network routing if disabled.
    IF ( l_routing_sequence_id IS NOT NULL ) THEN
      SELECT  CFM_ROUTING_FLAG
      INTO    l_cfm_routing_flag
      FROM    BOM_OPERATIONAL_ROUTINGS
      WHERE   ROUTING_SEQUENCE_ID = l_routing_sequence_id;

      IF ( l_cfm_routing_flag = 3 ) THEN -- check if the routing is network routing
        Bom_Op_Network_Util.Copy_First_Last_Dis_Op(
                                                    p_routing_sequence_id => l_routing_sequence_id
                                                  , x_mesg_token_tbl     => l_mesg_token_tbl
                                                  , x_return_status      => l_return_status );

        IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
            Error_Handler.Write_Debug
              ( 'Op Sequences: Copy First/Last Disabled Operation completed with status ' ||
                l_return_status );
        END IF; -- end if BOM_Rtg_Globals.Get_Debug = 'Y'
      END IF; -- end if l_cfm_routing_flag = 3
    END IF; -- end if l_routing_sequence_id IS NOT NULL

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;

   x_mesg_token_tbl      := l_mesg_token_tbl ;
   x_operation_tbl       := l_operation_tbl ;
   x_op_resource_tbl     := l_op_resource_tbl ;
   x_sub_resource_tbl    := l_sub_resource_tbl ;
   x_op_network_tbl      := l_op_network_tbl ;

END Operation_Sequences ;


/****************************************************************************
* Procedure     : Rtg_Revisions
* Parameters IN : Rtg Revision Table and all the other entities
* Parameters OUT: Rtg Revision Table and all the other entities
* Purpose       : This procedure will process all the Rtg revision records.
*                 Although the other entities are not children of this entity
*                 the are taken as parameters so that the error handler could
*                 set the records to appropriate status if a fatal or severity
*                 1 error occurs.
*****************************************************************************/

PROCEDURE Rtg_Revisions
(   p_validation_level           IN  NUMBER
 ,  p_assembly_item_name         IN  VARCHAR2   := NULL
 ,  p_assembly_item_id           IN  NUMBER     := NULL
 ,  p_organization_id            IN  NUMBER     := NULL
 ,  p_alternate_rtg_code         IN  VARCHAR2   := NULL
 ,  p_rtg_revision_tbl           IN  Bom_Rtg_Pub.rtg_Revision_Tbl_Type
 ,  p_operation_tbl              IN  Bom_Rtg_Pub.Operation_Tbl_Type
 ,  p_op_resource_tbl            IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
 ,  p_sub_resource_tbl           IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
 ,  p_op_network_tbl             IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
 ,  x_rtg_revision_tbl           IN OUT NOCOPY Bom_Rtg_Pub.rtg_Revision_Tbl_Type
 ,  x_operation_tbl              IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
 ,  x_op_resource_tbl            IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
 ,  x_sub_resource_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
 ,  x_op_network_tbl             IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
 ,  x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status              IN OUT NOCOPY VARCHAR2
 )
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_bom_parent_exists     BOOLEAN := FALSE;
l_rtg_header_rec        Bom_Rtg_Pub.rtg_Header_Rec_Type;
l_rtg_header_unexp_rec  Bom_Rtg_Pub.rtg_Header_unexposed_Rec_Type;
l_old_rtg_header_rec    Bom_Rtg_Pub.rtg_Header_Rec_Type;
l_old_rtg_header_unexp_rec Bom_Rtg_Pub.rtg_Header_Unexposed_Rec_Type;
l_rtg_revision_rec      Bom_Rtg_Pub.Rtg_Revision_Rec_Type;
l_rtg_rev_unexp_rec     Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type;
l_rtg_revision_tbl      Bom_Rtg_Pub.rtg_Revision_Tbl_Type := p_rtg_revision_tbl;
l_old_rtg_revision_rec  Bom_Rtg_Pub.Rtg_Revision_Rec_Type := NULL;
l_old_rtg_rev_unexp_rec Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type := NULL;
l_operation_tbl         Bom_Rtg_Pub.operation_tbl_Type := p_operation_tbl;
l_op_resource_tbl       Bom_Rtg_Pub.op_resource_tbl_Type := p_op_resource_tbl;
l_sub_resource_tbl      Bom_Rtg_Pub.sub_resource_tbl_Type :=
                                p_sub_resource_tbl;
l_op_network_tbl        Bom_Rtg_Pub.op_network_tbl_Type :=
                                p_op_network_tbl;
l_return_value          NUMBER;
l_rtg_parent_exists     BOOLEAN := FALSE ;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

BEGIN

    l_return_status := 'S';
    l_bo_return_status := 'S';

    --  Init local table variables.

    l_rtg_revision_tbl := p_rtg_revision_tbl;
    l_rtg_rev_unexp_rec.organization_id := BOM_Rtg_Globals.Get_org_id;

    FOR I IN 1..l_rtg_revision_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_rtg_revision_rec := l_rtg_revision_tbl(I);

        l_rtg_revision_rec.transaction_type :=
                UPPER(l_rtg_revision_rec.transaction_type);

        IF p_assembly_item_name IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                l_rtg_parent_exists := TRUE;
        END IF;

        --
        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

        IF (l_rtg_revision_rec.return_status IS NULL OR
            l_rtg_revision_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_rtg_parent_exists
           OR
           (l_rtg_parent_exists AND
              ( l_rtg_revision_rec.assembly_item_name = p_assembly_item_name AND
                l_rtg_rev_unexp_rec.organization_id =   p_organization_id AND
                NVL(l_rtg_revision_rec.alternate_routing_code, FND_API.G_MISS_CHAR) =
                                  NVL(p_alternate_rtg_code, FND_API.G_MISS_CHAR)
              )
             )
            )
        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;
           l_rtg_revision_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           --
           -- Check if transaction_type is valid
           --
           BOM_Rtg_Globals.Transaction_Type_Validity
           (   p_transaction_type       => l_rtg_revision_rec.transaction_type
           ,   p_entity                 => 'Routing_Revision'
           ,   p_entity_id              => l_rtg_revision_rec.revision
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           --
           -- Process Flow step 4: Verify that Revision is not NULL or MISSING
           --

           IF l_rtg_revision_rec.revision is NULL OR
              l_rtg_revision_rec.revision =  FND_API.G_MISS_CHAR
           THEN
                l_other_message := 'BOM_RTG_REV_KEYCOL_NULL';
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           --
           -- Process Flow Step: 5 Convert User Unique Index
           --
           BOM_Rtg_Val_To_Id.Rtg_Revision_UUI_To_UI
           (  p_rtg_revision_rec        => l_rtg_revision_rec
            , p_rtg_rev_unexp_rec       => l_rtg_rev_unexp_rec
            , x_rtg_rev_unexp_rec       => l_rtg_rev_unexp_rec
            , x_mesg_token_tbl          => l_mesg_token_tbl
            , x_return_status           => l_return_status
            );
            IF  l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
                l_other_message := 'BOM_RTG_REV_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_rtg_revision_rec.revision;
                RAISE EXC_SEV_QUIT_OBJECT;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
                l_other_message := 'BOM_RTG_REV_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_rtg_revision_rec.revision;

                RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;


           /*  BIao No Longer
           -- Verify Rtg Header's existence in database.
           -- If revision is being created and the business object does not
           -- carry the Rtg header, then it is imperative to check for the
           -- Rtg Header's existence.

           IF l_rtg_revision_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
              AND
              NOT l_rtg_parent_exists
           THEN
                l_rtg_header_rec.alternate_routing_code := p_alternate_rtg_code;
                l_rtg_header_unexp_rec.organization_id  := p_organization_id;
                l_rtg_header_unexp_rec.assembly_item_id := p_assembly_item_id;
                l_rtg_header_rec.transaction_type := 'XXX';

                Bom_Validate_Rtg_Header.Check_Existence
                ( p_rtg_header_rec      => l_rtg_header_rec
                , p_rtg_header_unexp_rec  => l_rtg_header_unexp_rec
                , x_old_rtg_header_rec  => l_old_rtg_header_rec
                , x_old_rtg_header_unexp_rec => l_old_rtg_header_unexp_rec
                , x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                , x_return_status          => l_return_status
                );
                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'BOM_RTG_HEADER_NOT_EXIST';
                   l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                   l_other_token_tbl(1).token_value :=
                                        l_rtg_revision_rec.assembly_item_name;
                   l_other_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                   l_other_token_tbl(2).token_value :=
                                        l_rtg_revision_rec.organization_code;
                   RAISE EXC_SEV_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'BOM_RTG_REV_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISION';
                   l_other_token_tbl(1).token_value :=
                                                l_rtg_revision_rec.revision;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;

           */

           --
           -- Process Flow step 5: Verify Revision's existence
           --
           Bom_Validate_Rtg_Revision.Check_Existence
                (  p_rtg_revision_rec           => l_rtg_revision_rec
                ,  p_rtg_rev_unexp_rec          => l_rtg_rev_unexp_rec
                ,  x_old_rtg_revision_rec       => l_old_rtg_revision_rec
                ,  x_old_rtg_rev_unexp_rec      => l_old_rtg_rev_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_return_status
                );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_RTG_REV_EXS_SEV_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_rtg_revision_rec.revision;
--                RAISE EXC_UNEXP_SKIP_OBJECT; -- this should not stop processing of other entities, bug 2871039
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RTG_REV_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_rtg_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           -- Process Flow step 5: Is Revision record an orphan ?

           IF NOT l_rtg_parent_exists
           THEN

                Bom_Validate_Rtg_Header.Check_Access
                ( p_assembly_item_name  => l_rtg_revision_rec.assembly_item_name
                , p_assembly_item_id    => l_rtg_rev_unexp_rec.assembly_item_id
                , p_organization_id     => l_rtg_rev_unexp_rec.organization_id
                , p_alternate_rtg_code  =>
                                     l_rtg_revision_rec.alternate_routing_code
                , p_mesg_token_tbl     => Error_Handler.G_MISS_MESG_TOKEN_TBL
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RTG_REV_AITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISION';
                        l_other_token_tbl(1).token_value :=
                                                l_rtg_revision_rec.revision;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RTG_REV_AITACC_UNEXP_ERROR';
                        l_other_token_tbl(1).token_name := 'REVISION';
                        l_other_token_tbl(1).token_value :=
                                                l_rtg_revision_rec.revision;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;

        --
        -- Process Flow step 9: Attribute Validation for Create and Update
        --
        IF l_rtg_revision_rec.transaction_type IN
                (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_CREATE)
        THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Rtg Revision : Check Attributes . . .');
END IF;

                Bom_Validate_Rtg_Revision.Check_Attributes
                (   x_return_status            => l_return_status
                ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                ,   p_rtg_revision_rec         => l_rtg_revision_rec
                ,   p_rtg_rev_unexp_rec        => l_rtg_rev_unexp_rec
                ,   p_old_rtg_revision_rec     => l_old_rtg_revision_rec
                ,   p_old_rtg_rev_unexp_rec    => l_old_rtg_rev_unexp_rec
                );

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RTG_REV_ATTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISION';
                        l_other_token_tbl(1).token_value :=
                                                l_rtg_revision_rec.revision;
                        IF l_rtg_header_rec.transaction_type = 'CREATE'
                        THEN
                                RAISE EXC_SEV_SKIP_BRANCH;
                        ELSE
                                RAISE EXC_SEV_QUIT_RECORD;
                        END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RTG_REV_ATTVAL_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISION';
                        l_other_token_tbl(1).token_value :=
                                                l_rtg_revision_rec.revision;

                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
       END IF;


       IF l_rtg_revision_rec.Transaction_Type IN
                (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
       THEN

                -- Process flow  - Populate NULL columns for Update and
                -- Delete.

                Bom_Default_Rtg_Revision.Populate_NULL_Columns
                (   p_rtg_revision_rec          => l_rtg_revision_rec
                ,   p_rtg_rev_unexp_rec         => l_rtg_rev_unexp_rec
                ,   p_old_rtg_revision_rec      => l_old_rtg_revision_rec
                ,   p_old_rtg_rev_unexp_rec     => l_old_rtg_rev_unexp_rec
                ,   x_rtg_revision_rec          => l_rtg_revision_rec
                ,   x_rtg_rev_unexp_rec         => l_rtg_rev_unexp_rec
                );

      ELSIF l_rtg_revision_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
      THEN

                --
                --  Default missing values for Operation
                -- CREATE
                --
                        NULL;

                /*
                ** There is not attribute defualting for RTG Revisions
                */



      END IF;

        --
        -- Process Flow step 12: Attribute Validation for Create and Update
        --

           Bom_Validate_Rtg_Revision.Check_Entity
                (  x_return_status        => l_return_status
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  p_rtg_revision_rec     => l_rtg_revision_rec
                ,  p_rtg_rev_unexp_rec    => l_rtg_rev_unexp_rec
                ,  p_old_rtg_revision_rec => l_old_rtg_revision_rec
                ,  p_old_rtg_rev_unexp_rec=> l_old_rtg_rev_unexp_rec
                );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_RTG_REV_ENTVAL_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value :=
                                                l_rtg_revision_rec.revision;
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RTG_REV_ENTVAL_UNEXP_ERROR';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_rtg_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           --
           -- Process Flow step 13 : Database Writes
           --
           BOM_RTG_Revision_Util.Perform_Writes
                (   p_rtg_revision_rec          => l_rtg_revision_rec
                ,   p_rtg_rev_unexp_rec         => l_rtg_rev_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RTG_REV_WRITES_UNEXP_ERROR';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_rtg_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

        END IF;
        -- End IF that checks RETURN STATUS AND PARENT-CHILD RELATIONSHIP

        --  Load tables.

        l_rtg_revision_tbl(I)          := l_rtg_revision_rec;

        --  For loop exception handler.
     EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

                Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_revision_tbl   => l_rtg_revision_tbl
                ,  p_operation_tbl      => l_operation_tbl
                ,  p_op_resource_tbl    => l_op_resource_tbl
                ,  p_sub_resource_tbl   => l_sub_resource_tbl
                ,  p_op_network_tbl     => l_op_network_tbl
                ,  p_rtg_header_rec     => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level        => Error_Handler.G_REV_LEVEL
                ,  p_entity_index       => I
                ,  p_other_message      => NULL
                ,  p_other_mesg_appid   => 'BOM'
                ,  p_other_status       => NULL
                ,  p_other_token_tbl    => Error_Handler.G_MISS_TOKEN_TBL
                ,  x_rtg_header_rec     => l_rtg_header_rec
                ,  x_rtg_revision_tbl   => l_rtg_revision_tbl
                ,  x_operation_tbl      => l_operation_tbl
                ,  x_op_resource_tbl    => l_op_resource_tbl
                ,  x_sub_resource_tbl   => l_sub_resource_tbl
                ,  x_op_network_tbl     => l_op_network_tbl
           );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

        WHEN EXC_SEV_QUIT_OBJECT THEN

            Bom_Rtg_Error_Handler.Log_Error
            (  p_rtg_revision_tbl       => l_rtg_revision_tbl
             , p_operation_tbl          => l_operation_tbl
             , p_op_resource_tbl        => l_op_resource_tbl
             , p_sub_resource_tbl       => l_sub_resource_tbl
             , p_op_network_tbl         => l_op_network_tbl
             , p_rtg_header_rec         => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
             , p_mesg_token_tbl         => l_mesg_token_tbl
             , p_error_status           => Error_Handler.G_STATUS_ERROR
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_REV_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_ERROR
             , p_other_token_tbl        => l_other_token_tbl
             , p_other_mesg_appid       => 'BOM'
             , p_entity_index           => I
             , x_rtg_header_rec         => l_rtg_header_rec
             , x_rtg_revision_tbl       => l_rtg_revision_tbl
             , x_operation_tbl          => l_operation_tbl
             , x_op_resource_tbl        => l_op_resource_tbl
             , x_sub_resource_tbl       => l_sub_resource_tbl
             , x_op_network_tbl         => l_op_network_tbl
             );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

       WHEN EXC_FAT_QUIT_OBJECT THEN

          Bom_Rtg_Error_Handler.Log_Error
            (  p_rtg_revision_tbl       => l_rtg_revision_tbl
             , p_operation_tbl          => l_operation_tbl
             , p_op_resource_tbl        => l_op_resource_tbl
             , p_sub_resource_tbl       => l_sub_resource_tbl
             , p_op_network_tbl         => l_op_network_tbl
             , p_rtg_header_rec         => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
             , p_mesg_token_tbl         => l_mesg_token_tbl
             , p_error_status           => Error_Handler.G_STATUS_FATAL
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_REV_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_FATAL
             , p_other_token_tbl        => l_other_token_tbl
             , p_other_mesg_appid       => 'BOM'
             , p_entity_index           => I
             , x_rtg_header_rec         => l_rtg_header_rec
             , x_rtg_revision_tbl       => l_rtg_revision_tbl
             , x_operation_tbl          => l_operation_tbl
             , x_op_resource_tbl        => l_op_resource_tbl
             , x_sub_resource_tbl       => l_sub_resource_tbl
             , x_op_network_tbl         => l_op_network_tbl
        );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

            Bom_Rtg_Error_Handler.Log_Error
            (  p_rtg_revision_tbl       => l_rtg_revision_tbl
             , p_operation_tbl          => l_operation_tbl
             , p_op_resource_tbl        => l_op_resource_tbl
             , p_sub_resource_tbl       => l_sub_resource_tbl
             , p_op_network_tbl         => l_op_network_tbl
             , p_rtg_header_rec         => Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
             , p_mesg_token_tbl         => l_mesg_token_tbl
             , p_error_status           => Error_Handler.G_STATUS_UNEXPECTED
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_REV_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_NOT_PICKED
             , p_other_token_tbl        => l_other_token_tbl
             , p_other_mesg_appid       => 'BOM'
             , p_entity_index           => I
             , x_rtg_header_rec         => l_rtg_header_rec
             , x_rtg_revision_tbl       => l_rtg_revision_tbl
             , x_operation_tbl          => l_operation_tbl
             , x_op_resource_tbl        => l_op_resource_tbl
             , x_sub_resource_tbl       => l_sub_resource_tbl
             , x_op_network_tbl         => l_op_network_tbl
             );
        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;
        --l_return_status := 'U';

        END; -- END block

     END LOOP; -- END Revisions processing loop

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

     --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     x_rtg_revision_tbl         := l_rtg_revision_tbl;
     x_operation_tbl            := l_operation_tbl;
     x_op_resource_tbl          := l_op_resource_tbl;
     x_sub_resource_tbl         := l_sub_resource_tbl;
     x_op_network_tbl           := l_op_network_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Rtg_Revisions;

/***************************************************************************
* Procedure     : Rtg_Header (Unexposed)
* Parameters IN : Rtg Header Record and all the child entities
* Parameters OUT: Rtg Header Record and all the child entities
* Purpose       : This procedure will validate and perform the appropriate
*                 action on the RTG Header record.
*                 It will process the entities that are children of this header.
***************************************************************************/
-- Header needs to be changed
PROCEDURE Rtg_Header
(   p_validation_level              IN  NUMBER
,   p_rtg_header_rec                IN  Bom_Rtg_Pub.rtg_Header_Rec_Type
,   p_rtg_revision_tbl              IN  Bom_Rtg_Pub.rtg_Revision_Tbl_Type
,   p_operation_tbl                 IN  Bom_Rtg_Pub.Operation_Tbl_Type
,   p_op_resource_tbl               IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
,   p_sub_resource_tbl              IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   p_op_network_tbl                IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
,   x_rtg_header_rec                IN OUT NOCOPY Bom_Rtg_Pub.rtg_Header_Rec_Type
,   x_rtg_revision_tbl              IN OUT NOCOPY Bom_Rtg_Pub.rtg_Revision_Tbl_Type
,   x_operation_tbl                 IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
,   x_op_resource_tbl               IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
,   x_sub_resource_tbl              IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
,   x_op_network_tbl                IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_rtg_header_rec        Bom_Rtg_Pub.Rtg_Header_Rec_Type;
l_old_rtg_header_rec    Bom_Rtg_Pub.Rtg_Header_Rec_Type;
l_old_rtg_header_unexp_rec Bom_Rtg_Pub.rtg_Header_Unexposed_Rec_Type;
l_rtg_header_Unexp_Rec  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type;
l_rtg_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type := p_rtg_revision_tbl;
l_operation_tbl         Bom_Rtg_Pub.operation_tbl_type   := p_operation_tbl;
l_op_resource_tbl       Bom_Rtg_Pub.op_resource_tbl_type := p_op_resource_tbl;
l_sub_resource_tbl      Bom_Rtg_Pub.sub_resource_tbl_type :=
                                p_sub_resource_tbl;
l_op_network_tbl        Bom_Rtg_Pub.op_network_tbl_type :=
                                p_op_network_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

BEGIN



        -- Begin block that processes header.
        -- This block holds the exception handlers for header errors.

    BEGIN

        --  Load entity and record-specific details into system_information
        --  record

        l_rtg_header_unexp_rec.organization_id := BOM_Rtg_Globals.Get_Org_Id;


        l_rtg_header_rec := p_rtg_header_rec;
        l_rtg_header_rec.transaction_type :=
                                UPPER(l_rtg_header_rec.transaction_type);

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Processing Rtg Header - Trans Type : '|| l_rtg_header_rec.transaction_type) ;
End IF ;
        -- Process Flow Step 2: Check if record has not yet been processed
        --

        IF l_rtg_header_rec.return_status IS NOT NULL AND
           l_rtg_header_rec.return_status <> FND_API.G_MISS_CHAR
        THEN
                x_return_status                := l_return_status;
                x_rtg_header_rec               := l_rtg_header_rec;
                x_rtg_revision_tbl             := l_rtg_revision_tbl;
                x_operation_tbl                := l_operation_tbl;
                x_op_resource_tbl              := l_op_resource_tbl;
                x_sub_resource_tbl             := l_sub_resource_tbl;
                x_op_network_tbl               := l_op_network_tbl;
                RETURN;
        END IF;

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_rtg_header_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- Process Flow Step 3: Check if transaction_type is valid
        --
	BOM_Rtg_Globals.Transaction_Type_Validity
        (   p_transaction_type  => l_rtg_header_rec.transaction_type
        ,   p_entity            => 'Routing_Header'
        ,   p_entity_id         => l_rtg_header_rec.assembly_item_name
        ,   x_valid             => l_valid
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
        );

        IF NOT l_valid
        THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
        END IF;

        --
        -- Process Flow Step 4: Convert User Unique Index to Unique Index
        --

        BOM_Rtg_Val_To_Id.Rtg_Header_UUI_To_UI
        (  p_rtg_header_rec             => l_rtg_header_rec
         , p_rtg_header_unexp_rec       => l_rtg_header_unexp_rec
         , x_rtg_header_unexp_rec       => l_rtg_header_unexp_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
        );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: UUI-UI Conversion. Return Status :  '||  l_return_status  );
END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'BOM_RTG_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'BOM_RTG_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

        --
        -- Process Flow step 5: Verify Rtg Header's existence
        --
        Bom_Validate_Rtg_Header.Check_Existence
              (   p_rtg_header_rec      => l_rtg_header_rec
                , p_rtg_header_unexp_rec=> l_rtg_header_unexp_rec
                , x_old_rtg_header_rec  => l_old_rtg_header_rec
                , x_old_rtg_header_unexp_rec=> l_old_rtg_header_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_return_status
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Check Existence. Return Status :  '||  l_return_status  );
END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'BOM_RTG_EXS_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'BOM_RTG_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;


        --
        -- Process Flow Step:6 Check Access to the Bill Item's Rtg Item Type
        --
        Bom_Validate_Rtg_Header.Check_Access
         ( p_assembly_item_name => l_rtg_header_rec.assembly_item_name
         , p_assembly_item_id   => l_rtg_header_unexp_rec.assembly_item_id
         , p_alternate_rtg_code => l_rtg_header_rec.alternate_routing_code
         , p_organization_id    => l_rtg_header_unexp_rec.organization_id
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_mesg_token_tbl
         , x_return_status      => l_return_status
         );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Check Access. Return Status :  '||  l_return_status  );
END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'BOM_RTG_ACC_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'BOM_RTG_ACC_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

        --
        -- Process Flow Step: 7 Check Flow Routing's operability for routing.
        --
        Bom_Validate_Rtg_Header.Check_flow_routing_operability
        (  p_assembly_item_name  => l_rtg_header_rec.assembly_item_name
         , p_cfm_routing_flag    => l_rtg_header_rec.cfm_routing_flag
         , p_organization_code   => l_rtg_header_rec.organization_code
         , p_organization_id     => l_rtg_header_Unexp_rec.organization_id
         , x_mesg_token_tbl      => l_mesg_token_tbl
         , x_return_status       => l_return_status
        );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header:  Check Flow Routing operability. Return Status :  '||  l_return_status  );
END IF;


        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'BOM_RTG_FRACC_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'BOM_RTG_FRACC_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

        Bom_Validate_Rtg_Header.Check_lot_controlled_item  -- for bug 3132425
               (  p_assembly_item_id  => l_rtg_header_unexp_rec.assembly_item_id
                , p_organization_id   => l_rtg_header_Unexp_rec.organization_id
                , x_mesg_token_tbl    => l_mesg_token_tbl
                , x_return_status     => l_return_status
               );

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
            Error_Handler.Write_Debug ('Rtg Header:  Check Lot Controlled Item. Return Status :  '||l_return_status);
        END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'BOM_NON_LOT_OSFM';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
                RAISE EXC_UNEXP_SKIP_OBJECT;
       END IF;

        /* Moved to Entity Defaulting
        --
        -- Process Flow Step 7.5:  Validation for no_operated columns in
        -- flow routing.
        --
        IF l_rtg_header_rec.cfm_routing_flag = 2
        THEN
           l_rtg_header_rec.line_code := NULL;
           l_rtg_header_rec.mixed_model_map_flag:= NULL;
           l_rtg_header_rec.total_product_cycle_time := NULL;
        END IF;
        */

        --
        -- Process Flow Step 8: Value-ID conversion.
        --
IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug('Rtg Header: Value-Id Conversion . . .');
END IF;
        BOM_Rtg_Val_To_Id.Rtg_Header_VID
        (  x_Return_Status         => l_return_status
        ,  x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
        ,  p_rtg_header_rec        => l_rtg_header_rec
        ,  p_rtg_header_unexp_rec  => l_rtg_header_unexp_rec
        ,  x_rtg_header_unexp_rec  => l_rtg_header_unexp_rec
        );


        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
            IF l_rtg_header_rec.transaction_type = 'CREATE'
            THEN
                l_other_message := 'BOM_RTG_VID_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
                RAISE EXC_SEV_QUIT_RECORD;
            END IF;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'BOM_RTG_VID_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
        THEN
              Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                ,  p_other_message         => NULL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_other_status          => NULL
                ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
                ,  p_error_scope           => NULL
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );
        END IF;

        --
        -- Process Flow step 10: Attribute Validation for Create and Update
        --

        IF l_rtg_header_rec.transaction_type IN
                (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_CREATE)
        THEN

           Bom_Validate_Rtg_Header.Check_Attributes
                (   x_return_status            => l_return_status
                ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                ,   p_rtg_header_rec           => l_rtg_header_rec
                ,   p_rtg_header_unexp_rec     => l_rtg_header_unexp_rec
                ,   p_old_rtg_header_rec       => l_old_rtg_header_rec
                ,   p_old_rtg_header_unexp_rec => l_old_rtg_header_unexp_rec
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Check Attributes. Return Status :  '||  l_return_status  );
END IF ;


           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
               IF l_rtg_header_rec.transaction_type = 'CREATE'
               THEN
                   l_other_message := 'BOM_RTG_ATTVAL_CSEV_SKIP';
                   l_other_token_tbl(1).token_name
                                                := 'ASSEMBLY_ITEM_NAME';
                   l_other_token_tbl(1).token_value :=
                   l_rtg_header_rec.assembly_item_name;
                   RAISE EXC_SEV_SKIP_BRANCH;
               ELSE
                   RAISE EXC_SEV_QUIT_RECORD;
               END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
               l_other_message := 'BOM_RTG_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name
                                := 'ASSEMBLY_ITEM_NAME';
               l_other_token_tbl(1).token_value
                                := l_rtg_header_rec.assembly_item_name;

               RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
           THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Warning :  '||  l_return_status  );
END IF ;
                 Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                ,  p_other_message         => NULL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_other_status          => NULL
                ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
                ,  p_error_scope           => NULL
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );
           END IF;
        END IF;

        --
        -- Process Flow Step:12
        -- If the Transaction Type is Update/Delete, then Populate_Null_Columns
        -- Else Attribute_Defaulting
        --
        IF l_rtg_header_rec.Transaction_Type IN
           (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
        THEN

         --
         -- Process flow step 12 - Populate NULL columns for Update and
         -- Delete.
         --
                BOM_Default_Rtg_Header.Populate_NULL_Columns
                (   p_rtg_header_rec            => l_rtg_header_rec
                ,   p_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
                ,   p_Old_rtg_header_rec        => l_old_rtg_header_rec
                ,   p_Old_rtg_header_unexp_rec  => l_old_rtg_header_unexp_rec
                ,   x_rtg_header_rec            => l_rtg_header_rec
                ,   x_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Populate Null Columns. Return Status :  '||  l_return_status  );
END IF ;

         ELSIF l_rtg_header_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE THEN
         --
         -- Process Flow step 12: Default missing values for Operation CREATE
         --
               BOM_Default_Rtg_Header.Attribute_Defaulting
                (   p_rtg_header_rec            => l_rtg_header_rec
                ,   p_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
                ,   x_rtg_header_rec            => l_rtg_header_rec
                ,   x_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Attribute Defaulting. Return Status :  '||  l_return_status  );
END IF ;

               IF l_return_status = Error_Handler.G_STATUS_ERROR
               THEN
                   IF l_rtg_header_rec.transaction_type = 'CREATE'
                   THEN
                       l_other_message := 'BOM_RTG_ATTDEF_CSEV_SKIP';
                       l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                       l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                       RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                       RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
               ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
               THEN
                       l_other_message := 'BOM_RTG_ATTDEF_UNEXP_SKIP';
                       l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                       l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                       RAISE EXC_UNEXP_SKIP_OBJECT;
               ELSIF l_return_status ='S' AND
                     l_Mesg_Token_Tbl.COUNT <>0
               THEN
                       Bom_Rtg_Error_Handler.Log_Error
                       (  p_rtg_header_rec        => l_rtg_header_rec
                       ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                       ,  p_operation_tbl         => l_operation_tbl
                       ,  p_op_resource_tbl       => l_op_resource_tbl
                       ,  p_sub_resource_tbl      => l_sub_resource_tbl
                       ,  p_op_network_tbl        => l_op_network_tbl
                       ,  p_mesg_token_tbl        => l_mesg_token_tbl
                       ,  p_error_status          => 'W'
                       ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                       ,  p_other_message         => NULL
                       ,  p_other_mesg_appid      => 'BOM'
                       ,  p_other_status          => NULL
                       ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
                       ,  p_error_scope           => NULL
                       ,  p_entity_index          => 1
                       ,  x_rtg_header_rec        => l_rtg_header_rec
                       ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                       ,  x_operation_tbl         => l_operation_tbl
                       ,  x_op_resource_tbl       => l_op_resource_tbl
                       ,  x_sub_resource_tbl      => l_sub_resource_tbl
                       ,  x_op_network_tbl        => l_op_network_tbl
                       );
               END IF;
        END IF;

        --
        -- Process Flow step 13 - Check Conditionally Required Fields
        --
        Bom_Validate_Rtg_Header.Check_Required
        (   x_return_status             => l_return_status
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   p_rtg_header_rec            => l_rtg_header_rec
        ,   p_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
        );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Check Required. Return Status :  '||  l_return_status  );
END IF ;

       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
           IF l_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
           THEN
                l_other_message := 'BOM_RTG_CONREQ_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_SKIP_BRANCH;
           ELSE
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RTG_CONREQ_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_rtg_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
       ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
       THEN
                Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                ,  p_other_message         => NULL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_other_status          => NULL
                ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
                ,  p_error_scope           => NULL
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );
        END IF;

        --
        -- Process Flow step 14 - Entity Level Defaulting for Operation CREATE
        -- and operation update.

        IF l_rtg_header_rec.Transaction_Type IN (
                     BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
        THEN

           BOM_Default_Rtg_Header.Entity_Attribute_Defaulting
                (   p_rtg_header_rec            => l_rtg_header_rec
                ,   p_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
                ,   x_rtg_header_rec            => l_rtg_header_rec
                ,   x_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Entity Level Defaulting. Return Status :  '||  l_return_status  );
END IF ;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
             IF l_rtg_header_rec.transaction_type = 'CREATE'
             THEN
                l_other_message := 'BOM_RTG_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_SEV_SKIP_BRANCH;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD;
              END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RTG_ENTDEF_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
           Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                ,  p_other_message         => NULL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_other_status          => NULL
                ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
                ,  p_error_scope           => NULL
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );
           END IF;
        END IF;



        --
        -- Process Flow step 15 - Entity Level Validation
        --

        --IF l_rtg_header_rec.transaction_type <> G_Globals.G_OPR_DELETE
        IF l_rtg_header_rec.transaction_type <> 'DELETE'
        THEN
		Bom_Validate_Rtg_Header.Check_Entity
                (  x_return_status        => l_return_status
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  p_rtg_header_rec       => l_rtg_header_rec
                ,  p_rtg_header_unexp_rec => l_rtg_header_unexp_rec
                ,  p_old_rtg_header_rec   => l_rtg_header_rec
                ,  p_old_rtg_header_unexp_rec => l_old_rtg_header_unexp_rec
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Check Entity. Return Status : '||  l_return_status  );
END IF ;

        ELSE
                Bom_Validate_Rtg_Header.Check_Entity_Delete
                ( x_return_status       => l_return_status
                , x_Mesg_Token_Tbl      => l_mesg_token_tbl
                , p_rtg_header_rec      => l_rtg_header_rec
                , p_rtg_header_Unexp_Rec  => l_rtg_header_unexp_rec
                , x_rtg_header_unexp_rec        => l_rtg_header_unexp_rec
                );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Check Entity for Deleting. Return Status : '||  l_return_status  );
END IF ;

        END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                IF l_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                THEN
                l_other_message := 'BOM_RTG_ENTVAL_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_rtg_header_rec.assembly_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
          l_other_message := 'BOM_RTG_ENTVAL_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
          l_other_token_tbl(1).token_value :=
                                  l_rtg_header_rec.assembly_item_name;
           RAISE EXC_UNEXP_SKIP_OBJECT;
        ELSIF l_return_status ='S' AND
           l_Mesg_Token_Tbl.COUNT <>0
        THEN
                Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                ,  p_other_message         => NULL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_other_status          => NULL
                ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
                ,  p_error_scope           => NULL
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );
        END IF;

        --
        -- Process Flow step 16 : Database Writes
        --
        BOM_Rtg_Header_Util.Perform_Writes
        (   p_rtg_header_rec            => l_rtg_header_rec
        ,   p_rtg_header_unexp_rec      => l_rtg_header_unexp_rec
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Rtg Header: Perform DB Writes. Return Status :  '||  l_return_status  );
END IF ;

        IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
            l_other_message := 'BOM_RTG_WRITES_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
            l_other_token_tbl(1).token_value :=
                                l_rtg_header_rec.assembly_item_name;
            RAISE EXC_UNEXP_SKIP_OBJECT;
        ELSIF l_return_status ='S' AND
            l_Mesg_Token_Tbl.COUNT <>0
        THEN
            Bom_Rtg_Error_Handler.Log_Error
            (  p_rtg_header_rec        => l_rtg_header_rec
            ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
            ,  p_operation_tbl         => l_operation_tbl
            ,  p_op_resource_tbl       => l_op_resource_tbl
            ,  p_sub_resource_tbl      => l_sub_resource_tbl
            ,  p_op_network_tbl        => l_op_network_tbl
            ,  p_mesg_token_tbl        => l_mesg_token_tbl
            ,  p_error_status          => 'W'
            ,  p_error_level           => Error_Handler.G_RTG_LEVEL
            ,  p_other_message         => NULL
            ,  p_other_mesg_appid      => 'BOM'
            ,  p_other_status          => NULL
            ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
            ,  p_error_scope           => NULL
            ,  p_entity_index          => 1
            ,  x_rtg_header_rec        => l_rtg_header_rec
            ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
            ,  x_operation_tbl         => l_operation_tbl
            ,  x_op_resource_tbl       => l_op_resource_tbl
            ,  x_sub_resource_tbl      => l_sub_resource_tbl
            ,  x_op_network_tbl        => l_op_network_tbl
            );

        END IF;
     EXCEPTION

     WHEN EXC_SEV_QUIT_RECORD THEN
          Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope           => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                ,  p_other_message         => NULL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_other_status          => NULL
                ,  p_other_token_tbl       => Error_Handler.G_MISS_TOKEN_TBL
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

                Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec         => l_rtg_header_rec
                ,  p_rtg_revision_tbl       => l_rtg_revision_tbl
                ,  p_operation_tbl          => l_operation_tbl
                ,  p_op_resource_tbl        => l_op_resource_tbl
                ,  p_sub_resource_tbl       => l_sub_resource_tbl
                ,  p_op_network_tbl         => l_op_network_tbl
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope            => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status           => Error_Handler.G_STATUS_ERROR
                ,  p_other_message          => l_other_message
                ,  p_other_token_tbl        => l_other_token_tbl
                ,  p_error_level            => Error_Handler.G_RTG_LEVEL
                ,  p_other_mesg_appid       => 'BOM'
                ,  p_entity_index           => 1
                ,  x_rtg_header_rec         => l_rtg_header_rec
                ,  x_rtg_revision_tbl       => l_rtg_revision_tbl
                ,  x_operation_tbl          => l_operation_tbl
                ,  x_op_resource_tbl        => l_op_resource_tbl
                ,  x_sub_resource_tbl       => l_sub_resource_tbl
                ,  x_op_network_tbl         => l_op_network_tbl
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;
        RETURN;

    WHEN EXC_SEV_SKIP_BRANCH THEN

             Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope           => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level           => Error_Handler.G_RTG_LEVEL
                ,  p_other_message         => l_other_message
                ,  p_other_token_tbl       => l_other_token_tbl
                ,  p_other_status          => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;
        RETURN;

    WHEN EXC_FAT_QUIT_OBJECT THEN

                Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec         => l_rtg_header_rec
                ,  p_rtg_revision_tbl       => l_rtg_revision_tbl
                ,  p_operation_tbl          => l_operation_tbl
                ,  p_op_resource_tbl        => l_op_resource_tbl
                ,  p_sub_resource_tbl       => l_sub_resource_tbl
                ,  p_op_network_tbl         => l_op_network_tbl
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope            => Error_Handler.G_SCOPE_ALL
                ,  p_other_message          => l_other_message
                ,  p_other_status           => Error_Handler.G_STATUS_FATAL
                ,  p_other_token_tbl        => l_other_token_tbl
                ,  p_error_level            => Error_Handler.G_RTG_LEVEL
                ,  p_other_mesg_appid       => 'BOM'
                ,  p_entity_index           => 1
                ,  x_rtg_header_rec         => l_rtg_header_rec
                ,  x_rtg_revision_tbl       => l_rtg_revision_tbl
                ,  x_operation_tbl          => l_operation_tbl
                ,  x_op_resource_tbl        => l_op_resource_tbl
                ,  x_sub_resource_tbl       => l_sub_resource_tbl
                ,  x_op_network_tbl         => l_op_network_tbl
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;
        l_return_status := 'Q';

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

                Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec         => l_rtg_header_rec
                ,  p_rtg_revision_tbl       => l_rtg_revision_tbl
                ,  p_operation_tbl          => l_operation_tbl
                ,  p_op_resource_tbl        => l_op_resource_tbl
                ,  p_sub_resource_tbl       => l_sub_resource_tbl
                ,  p_op_network_tbl         => l_op_network_tbl
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status           => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message          => l_other_message
                ,  p_other_token_tbl        => l_other_token_tbl
                ,  p_error_level            => Error_Handler.G_RTG_LEVEL
                ,  p_other_mesg_appid       => 'BOM'
                ,  p_error_scope            => NULL
                ,  p_entity_index           => 1
                ,  x_rtg_header_rec         => l_rtg_header_rec
                ,  x_rtg_revision_tbl       => l_rtg_revision_tbl
                ,  x_operation_tbl          => l_operation_tbl
                ,  x_op_resource_tbl        => l_op_resource_tbl
                ,  x_sub_resource_tbl       => l_sub_resource_tbl
                ,  x_op_network_tbl         => l_op_network_tbl
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;
        l_return_status := 'U';

    END; -- END Header processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

        --
        -- Process Rtg Revisions that are chilren of this header
        --

        Rtg_Revisions
        (   p_validation_level      => p_validation_level
        ,   p_assembly_item_name    => l_rtg_header_rec.assembly_item_name
        ,   p_assembly_item_id      => NULL
        ,   p_organization_id       => l_rtg_header_unexp_rec.organization_id
        ,   p_alternate_rtg_code    => l_rtg_header_rec.alternate_routing_code
        ,   p_rtg_revision_tbl      => l_rtg_revision_tbl
        ,   p_operation_tbl         => l_operation_tbl
        ,   p_op_resource_tbl       => l_op_resource_tbl
        ,   p_sub_resource_tbl      => l_sub_resource_tbl
        ,   p_op_network_tbl        => l_op_network_tbl
        ,   x_rtg_revision_tbl      => l_rtg_revision_tbl
        ,   x_operation_tbl         => l_operation_tbl
        ,   x_op_resource_tbl       => l_op_resource_tbl
        ,   x_sub_resource_tbl      => l_sub_resource_tbl
        ,   x_op_network_tbl        => l_op_network_tbl
        ,   x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
        ,   x_return_status         => l_return_status
        );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    -- Process operations that are orphans (without immediate revised
    -- item parents) but are indirect children of this header

	 Operation_Sequences
         (   p_validation_level    => p_validation_level
         ,   p_assembly_item_name  => l_rtg_header_rec.assembly_item_name
         ,   p_organization_id     => l_rtg_header_unexp_rec.organization_id
         ,   p_alternate_routing_code => l_rtg_header_rec.alternate_routing_code
         ,   p_operation_tbl       => l_operation_tbl
         ,   p_op_resource_tbl     => l_op_resource_tbl
         ,   p_sub_resource_tbl    => l_sub_resource_tbl
         ,   p_op_network_tbl      => l_op_network_tbl
         ,   x_operation_tbl       => l_operation_tbl
         ,   x_op_resource_tbl     => l_op_resource_tbl
         ,   x_sub_resource_tbl    => l_sub_resource_tbl
         ,   x_op_network_tbl      => l_op_network_tbl
         ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
         ,   x_return_status       => l_return_status
        );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    -- Check if the value of SSOS is valid -- Added for SSOS (bug 2689249)
	IF l_rtg_header_rec.ser_start_op_seq IS NOT NULL THEN

	   BOM_Validate_Rtg_Header.Check_SSOS
	   ( p_rtg_header_rec	=> l_rtg_header_rec
           , p_rtg_header_unexp_rec  => l_rtg_header_unexp_rec
	   , x_mesg_token_tbl	=> l_Mesg_Token_Tbl
	   , x_return_status	=> l_return_status
	   );

	   IF l_return_status <> 'S'
	   THEN
		l_bo_return_status := l_return_status;
		IF l_Mesg_Token_Tbl.COUNT <> 0 THEN
                    Bom_Rtg_Error_Handler.Log_Error
		    (  p_rtg_header_rec         => l_rtg_header_rec
		    ,  p_rtg_revision_tbl       => l_rtg_revision_tbl
		    ,  p_operation_tbl          => l_operation_tbl
		    ,  p_op_resource_tbl        => l_op_resource_tbl
		    ,  p_sub_resource_tbl       => l_sub_resource_tbl
		    ,  p_op_network_tbl         => l_op_network_tbl
		    ,  p_mesg_token_tbl         => l_mesg_token_tbl
		    ,  p_error_status           => Error_Handler.G_STATUS_ERROR
		    ,  p_other_status           => NULL
		    ,  p_other_message          => l_other_message
		    ,  p_other_token_tbl        => l_other_token_tbl
		    ,  p_error_level            => Error_Handler.G_RTG_LEVEL
		    ,  p_other_mesg_appid       => 'BOM'
		    ,  p_error_scope            => NULL
		    ,  p_entity_index           => 1
		    ,  x_rtg_header_rec         => l_rtg_header_rec
		    ,  x_rtg_revision_tbl       => l_rtg_revision_tbl
		    ,  x_operation_tbl          => l_operation_tbl
		    ,  x_op_resource_tbl        => l_op_resource_tbl
		    ,  x_sub_resource_tbl       => l_sub_resource_tbl
		    ,  x_op_network_tbl         => l_op_network_tbl
		    );
		END IF;
	   END IF;
	END IF;

    --
    -- Process resource that are orphans (without immediate revised
    -- item parents) but are indirect children of this header
         Operation_Resources
         (   p_validation_level    => p_validation_level
         ,   p_assembly_item_name  => l_rtg_header_rec.assembly_item_name
         ,   p_organization_id     => l_rtg_header_unexp_rec.organization_id
         ,   p_effectivity_date  => NULL
         ,   p_operation_type    => NULL
         ,   p_operation_seq_num => NULL
         ,   p_alternate_routing_code   =>
                                  l_rtg_header_rec.alternate_routing_code
         ,   p_op_resource_tbl     => l_op_resource_tbl
         ,   p_sub_resource_tbl    => l_sub_resource_tbl
         ,   x_op_resource_tbl     => l_op_resource_tbl
         ,   x_sub_resource_tbl    => l_sub_resource_tbl
         ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
         ,   x_return_status       => l_return_status
    );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    --
    -- Process substitue resource that are orphans (without immediate revised
    -- item parents) but are indirect children of this header

        Sub_Operation_Resources
        (   p_validation_level     => p_validation_level
        ,   p_assembly_item_name   => l_rtg_header_rec.assembly_item_name
        ,   p_organization_id      => l_rtg_header_unexp_rec.organization_id
        ,   p_alternate_routing_code    =>
                                      l_rtg_header_rec.alternate_routing_code
        ,   p_sub_resource_tbl     => l_sub_resource_tbl
        ,   p_operation_seq_num =>  NULL
        ,   p_effectivity_date => NULL
        ,   p_operation_type => NULL
        ,   x_sub_resource_tbl     => l_sub_resource_tbl
        ,   x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
        ,   x_return_status        => l_return_status
        );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;
       Op_networks
       (   p_validation_level         => p_validation_level
       ,   p_assembly_item_id         => l_rtg_header_unexp_rec.assembly_item_id
       ,   p_assembly_item_name       => l_rtg_header_rec.assembly_item_name
       ,   p_organization_id          => l_rtg_header_unexp_rec.organization_id
       ,   p_alternate_rtg_code       => l_rtg_header_rec.alternate_routing_code
       ,   p_op_network_tbl           => l_op_network_tbl
       ,   x_op_network_tbl           => l_op_network_tbl
       ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
       ,   x_return_status            => l_return_status
        );

    -- bug:5235684 SSOS is required for standard/network routing for serial controlled item
    -- and it should be present on primary path.
    IF ( l_return_status = FND_API.G_RET_STS_SUCCESS )
    THEN
      Bom_Validate_Rtg_Header.Validate_SSOS
          (  p_routing_sequence_id  => l_rtg_header_unexp_rec.routing_sequence_id
           , p_ser_start_op_seq     => l_rtg_header_rec.ser_start_op_seq
           , p_validate_from_table  => FALSE
           , x_mesg_token_tbl       => l_Mesg_Token_Tbl
           , x_return_status        => l_return_status );

      IF  ( ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) AND
            ( l_Mesg_Token_Tbl.COUNT <> 0 ) )
      THEN
          Bom_Rtg_Error_Handler.Log_Error
            (  p_rtg_header_rec         => l_rtg_header_rec
            ,  p_rtg_revision_tbl       => l_rtg_revision_tbl
            ,  p_operation_tbl          => l_operation_tbl
            ,  p_op_resource_tbl        => l_op_resource_tbl
            ,  p_sub_resource_tbl       => l_sub_resource_tbl
            ,  p_op_network_tbl         => l_op_network_tbl
            ,  p_mesg_token_tbl         => l_mesg_token_tbl
            ,  p_error_status           => Error_Handler.G_STATUS_ERROR
            ,  p_other_status           => NULL
            ,  p_other_message          => l_other_message
            ,  p_other_token_tbl        => l_other_token_tbl
            ,  p_error_level            => Error_Handler.G_RTG_LEVEL
            ,  p_other_mesg_appid       => 'BOM'
            ,  p_error_scope            => NULL
            ,  p_entity_index           => 1
            ,  x_rtg_header_rec         => l_rtg_header_rec
            ,  x_rtg_revision_tbl       => l_rtg_revision_tbl
            ,  x_operation_tbl          => l_operation_tbl
            ,  x_op_resource_tbl        => l_op_resource_tbl
            ,  x_sub_resource_tbl       => l_sub_resource_tbl
            ,  x_op_network_tbl         => l_op_network_tbl
            );
      END IF; -- end if l_return_status <> 'S'
    END IF; -- end if ( l_return_status = FND_API.G_RET_STS_SUCCESS )

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


     --  Load OUT parameters

     x_return_status                := l_bo_return_status;
     x_rtg_header_rec               := l_rtg_header_rec;
     x_rtg_revision_tbl             := l_rtg_revision_tbl;
     x_operation_tbl                := l_operation_tbl;
     x_op_resource_tbl              := l_op_resource_tbl;
     x_sub_resource_tbl             := l_sub_resource_tbl;
     x_op_network_tbl               := l_op_network_tbl;

END Rtg_Header;


/***************************************************************************
* Procedure     : Process_Rtg
* Parameters IN : RTG Business Object Entities, Record for Header and tables
*                 for the remaining entities
* Parameters OUT: RTG Business Object Entities, Record for Header and tables
*                 for the remaining entities
* Returns       : None
* Purpose       : This is the only exposed procedure in the PVT API.
*                 Process_Rtg will drive the business object processing. It
*                 will take each entity and call individual procedure that will
*                 handle the processing of that entity and its children.
****************************************************************************/
PROCEDURE Process_Rtg
(   p_api_version_number      IN  NUMBER
  , p_validation_level        IN  NUMBER
  , x_return_status           IN OUT NOCOPY VARCHAR2
  , x_msg_count               IN OUT NOCOPY NUMBER
  , p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
  , p_rtg_revision_tbl        IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
  , p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
  , p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
  , p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
  , p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
  , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
  , x_rtg_revision_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
  , x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
  , x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
  , x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
  , x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Rtg';
l_err_text                    VARCHAR2(240);
l_return_status               VARCHAR2(1);
l_bo_return_status            VARCHAR2(1);

l_assembly_item_name    VARCHAR2(81);
l_organization_code     VARCHAR2(3);
l_organization_id       NUMBER;
l_rtg_header_rec        Bom_Rtg_Pub.Rtg_Header_Rec_Type;
l_rtg_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
l_operation_tbl         Bom_Rtg_Pub.Operation_Tbl_Type;
l_op_resource_tbl       Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
l_sub_resource_tbl      Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
l_op_network_tbl        Bom_Rtg_Pub.Op_Network_Tbl_Type;


l_mesg_token_tbl              Error_Handler.Mesg_Token_Tbl_Type;
l_other_message               VARCHAR2(2000);
l_other_token_tbl             Error_Handler.Token_Tbl_Type;

EXC_ERR_PVT_API_MAIN          EXCEPTION;

BEGIN
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Processing Rtg BO Private API . . . ' ) ;
End IF ;

      --  Init local variables.
      l_rtg_header_rec    :=  p_rtg_header_rec  ;
      l_rtg_revision_tbl  :=  p_rtg_revision_tbl;
      l_operation_tbl     :=  p_operation_tbl ;
      l_op_resource_tbl   :=  p_op_resource_tbl ;
      l_sub_resource_tbl  :=  p_sub_resource_tbl ;
      l_op_network_tbl    :=  p_op_network_tbl ;

        -- Business Object starts with a status of Success
        l_bo_return_status := 'S';

        --Load environment information into the SYSTEM_INFORMATION record
        -- (USER_ID, LOGIN_ID, PROG_APPID, PROG_ID)

        BOM_Rtg_Globals.Init_System_Info_Rec
                        (  x_mesg_token_tbl => l_mesg_token_tbl
                        ,  x_return_status  => l_return_status
                        );

        /* below are changes for OSFM */
        BOM_Rtg_Globals.Set_Osfm_NW_Count(0);
        BOM_Rtg_Globals.Set_Osfm_NW_Calc_Flag(FALSE);
        /* above are changes for OSFM */
        /* Initialize System_Information Unit_Effectivity flag

        IF FND_PROFILE.DEFINED('PJM:PJM_UNITEFF_NO_EFFECT') AND
               FND_PROFILE.VALUE('PJM:PJM_UNITEFF_NO_EFFECT') = 'Y'
        THEN
                BOM_Rtg_Globals.Set_Unit_Effectivity (TRUE);
        ELSE
                BOM_Rtg_Globals.Set_Unit_Effectivity (FALSE);
        END IF;

       */

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                RAISE EXC_ERR_PVT_API_MAIN;
        END IF;

        --
        -- Start with processing of the routing header.
        --
        IF  (l_rtg_header_rec.assembly_item_name <> FND_API.G_MISS_CHAR
                AND l_rtg_header_rec.assembly_item_name IS NOT NULL)
        THEN
		Rtg_Header
                (   p_validation_level          => p_validation_level
                ,   p_rtg_header_rec            => l_rtg_header_rec
                ,   p_rtg_revision_tbl          => l_rtg_revision_tbl
                ,   p_operation_tbl             => l_operation_tbl
                ,   p_op_resource_tbl           => l_op_resource_tbl
                ,   p_sub_resource_tbl          => l_sub_resource_tbl
                ,   p_op_network_tbl            => l_op_network_tbl
                ,   x_rtg_header_rec            => l_rtg_header_rec
                ,   x_rtg_revision_tbl          => l_rtg_revision_tbl
                ,   x_operation_tbl             => l_operation_tbl
                ,   x_op_resource_tbl           => l_op_resource_tbl
                ,   x_sub_resource_tbl          => l_sub_resource_tbl
                ,   x_op_network_tbl            => l_op_network_tbl
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF NVL(l_return_status, 'S') = 'Q'
                THEN
                        l_return_status := 'F';
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') = 'U'
                THEN
                        RAISE G_EXC_QUIT_IMPORT;

                ELSIF NVL(l_return_status, 'S') <> 'S'
                THEN
                        l_bo_return_status := l_return_status;
                END IF;

        END IF;  -- Processing Rtg Header Ends

        --
        -- Process Rtg Revisions
        --
        IF l_rtg_revision_tbl.Count <> 0
        THEN
                Rtg_Revisions
                (   p_validation_level          => p_validation_level
                ,   p_rtg_revision_tbl          => l_rtg_revision_tbl
                ,   p_operation_tbl             => l_operation_tbl
                ,   p_op_resource_tbl           => l_op_resource_tbl
                ,   p_sub_resource_tbl          => l_sub_resource_tbl
                ,   p_op_network_tbl            => l_op_network_tbl
                ,   p_assembly_item_name => NULL
                ,   p_assembly_item_id=> NULL
                ,   p_organization_id => NULL
                ,   p_alternate_rtg_code => NULL
                ,   x_rtg_revision_tbl          => l_rtg_revision_tbl
                ,   x_operation_tbl             => l_operation_tbl
                ,   x_op_resource_tbl           => l_op_resource_tbl
                ,   x_sub_resource_tbl          => l_sub_resource_tbl
                ,   x_op_network_tbl            => l_op_network_tbl
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF NVL(l_return_status, 'S') = 'Q'
                THEN
                        l_return_status := 'F';
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') = 'U'
                THEN
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') <> 'S'
                THEN
                        l_bo_return_status := l_return_status;
                END IF;

        END IF;  -- Processing of Rtg revisions Ends

        --
        --  Process operations
        --
        IF l_operation_tbl.COUNT <> 0
        THEN
              Operation_Sequences
                (   p_validation_level          => p_validation_level
                ,   p_operation_tbl             => l_operation_tbl
                ,   p_op_resource_tbl           => l_op_resource_tbl
                ,   p_sub_resource_tbl          => l_sub_resource_tbl
                ,   p_op_network_tbl            => l_op_network_tbl
                ,   p_organization_id => NULL
                ,   p_assembly_item_name => NULL
                ,   p_alternate_routing_code => NULL
                ,   x_operation_tbl             => l_operation_tbl
                ,   x_op_resource_tbl           => l_op_resource_tbl
                ,   x_sub_resource_tbl          => l_sub_resource_tbl
                ,   x_op_network_tbl            => l_op_network_tbl
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF NVL(l_return_status, 'S') = 'Q'
                THEN
                        l_return_status := 'F';
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') = 'U'
                THEN
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') <> 'S'
                THEN
                        l_bo_return_status := l_return_status;
                END IF;
        END IF; -- Processing of operations
/*
        -- Not necessary to be called here again
	-- Check if the value of SSOS is valid -- Added for SSOS
	IF l_rtg_header_rec.ser_start_op_seq IS NOT NULL THEN

	   BOM_Validate_Rtg_Header.Check_SSOS
	   ( p_rtg_header_rec	=> l_rtg_header_rec
           , p_rtg_header_unexp_rec  => l_rtg_header_unexp_rec
	   , x_mesg_token_tbl	=> l_Mesg_Token_Tbl
	   , x_return_status	=> l_return_status
	   );

	   IF l_return_status <> 'S'
	   THEN
		l_bo_return_status := l_return_status;
	   END IF;
	END IF;
*/
        --
        --  Process operation resources
        --
        IF l_op_resource_tbl.Count <> 0
        THEN
	      Operation_Resources
                (   p_validation_level          => p_validation_level
                ,   p_op_resource_tbl           => l_op_resource_tbl
                ,   p_sub_resource_tbl          => l_sub_resource_tbl
                ,   p_organization_id		=> NULL
                ,   p_assembly_item_name	=> NULL
                ,   p_alternate_routing_code	=> NULL
                ,   p_operation_seq_num		=> NULL
                ,   p_effectivity_date		=> NULL
                ,   p_operation_type		=> NULL
                ,   x_op_resource_tbl           => l_op_resource_tbl
                ,   x_sub_resource_tbl          => l_sub_resource_tbl
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );
                IF NVL(l_return_status, 'S') = 'Q'
                THEN
                        l_return_status := 'F';
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') = 'U'
                THEN
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') <> 'S'
                THEN
                        l_bo_return_status := l_return_status;
                END IF;
        END IF; -- Processing of operation  resources

        --
        --  Process operation substitute resources
        --
        IF l_sub_resource_tbl.Count <> 0
        THEN
              Sub_Operation_Resources
                (   p_validation_level          => p_validation_level
                ,   p_sub_resource_tbl          => l_sub_resource_tbl
                ,   p_organization_id		=> NULL
                ,   p_assembly_item_name	=> NULL
                ,   p_alternate_routing_code	=> NULL
                ,   p_operation_seq_num		=>  NULL
                ,   p_effectivity_date		=> NULL
                ,   p_operation_type		=> NULL
                ,   x_sub_resource_tbl          => l_sub_resource_tbl
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF NVL(l_return_status, 'S') = 'Q'
                THEN
                        l_return_status := 'F';
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') = 'U'
                THEN
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') <> 'S'
                THEN
                        l_bo_return_status := l_return_status;
                END IF;
        END IF; -- Processing of operation sub resources

        --
        --  Process operation networks
        --
        IF l_op_network_tbl.Count <> 0
        THEN
              Op_Networks
                (
                    p_validation_level          => p_validation_level
                ,   p_op_network_tbl            => l_op_network_tbl
                ,   p_assembly_item_name	=> NULL
                ,   p_assembly_item_id		=> NULL
                ,   p_organization_id		=> NULL
                ,   p_alternate_rtg_code	=> NULL
                ,   x_op_network_tbl            => l_op_network_tbl
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF NVL(l_return_status, 'S') = 'Q'
                THEN
                        l_return_status := 'F';
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') = 'U'
                THEN
                        RAISE G_EXC_QUIT_IMPORT;
                ELSIF NVL(l_return_status, 'S') <> 'S'
                THEN
                        l_bo_return_status := l_return_status;
                END IF;
        END IF; -- Processing of operation network

        x_return_status                := l_bo_return_status;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;


    -- Reset system_information business object flags

    BOM_Rtg_Globals.Set_STD_Item_Access( p_std_item_access => NULL);
    BOM_Rtg_Globals.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    BOM_Rtg_Globals.Set_PLN_Item_Access( p_pln_item_access => NULL);
    BOM_Rtg_Globals.Set_OC_Item_Access( p_oc_item_access   => NULL);

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug
   ('-----------------------------------------------------' ) ;
   Error_Handler.Write_Debug
   ('End of Rtg BO Private API with return_status: ' || x_return_status) ;
END IF;

-- dbms_output.put_line('after all things with return status = '||x_return_status);

EXCEPTION

    WHEN EXC_ERR_PVT_API_MAIN THEN
    Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_error_status          => FND_API.G_RET_STS_UNEXP_ERROR
                ,  p_other_status          => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message         => l_other_message
                ,  p_other_token_tbl       => l_other_token_tbl
                ,  p_error_level           => 0
                ,  p_Mesg_Token_tbl	       => Error_Handler.G_MISS_MESG_TOKEN_TBL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_error_scope           => NULL
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );

        x_return_status                := l_return_status;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

-- Reset system_information business object flags

    BOM_Rtg_Globals.Set_STD_Item_Access( p_std_item_access => NULL);
    BOM_Rtg_Globals.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    BOM_Rtg_Globals.Set_PLN_Item_Access( p_pln_item_access => NULL);
    BOM_Rtg_Globals.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN G_EXC_QUIT_IMPORT THEN
        x_return_status                := l_return_status;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug
   ('-----------------------------------------------------' ) ;
   Error_Handler.Write_Debug
   ('Quit Rtg BO Private API process with return_status: ' || x_return_status) ;
END IF;


    -- Reset system_information business object flags
    BOM_Rtg_Globals.Set_STD_Item_Access( p_std_item_access => NULL);
    BOM_Rtg_Globals.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    BOM_Rtg_Globals.Set_PLN_Item_Access( p_pln_item_access => NULL);
    BOM_Rtg_Globals.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN OTHERS THEN

        l_return_status := Error_Handler.G_STATUS_UNEXPECTED ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME || ' : Process Rtg '
                        || substrb(SQLERRM,1,200);
                Error_Handler.Add_Error_Token
                        ( p_Message_Text   => l_err_text
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        );
        END IF;

        Bom_Rtg_Error_Handler.Log_Error
                (  p_rtg_header_rec        => l_rtg_header_rec
                ,  p_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  p_operation_tbl         => l_operation_tbl
                ,  p_op_resource_tbl       => l_op_resource_tbl
                ,  p_sub_resource_tbl      => l_sub_resource_tbl
                ,  p_op_network_tbl        => l_op_network_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status          => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message         => l_other_message
                ,  p_other_token_tbl       => l_other_token_tbl
                ,  p_error_level           => 0
                ,  p_error_scope           => NULL
                ,  p_other_mesg_appid      => 'BOM'
                ,  p_entity_index          => 1
                ,  x_rtg_header_rec        => l_rtg_header_rec
                ,  x_rtg_revision_tbl      => l_rtg_revision_tbl
                ,  x_operation_tbl         => l_operation_tbl
                ,  x_op_resource_tbl       => l_op_resource_tbl
                ,  x_sub_resource_tbl      => l_sub_resource_tbl
                ,  x_op_network_tbl        => l_op_network_tbl
                );

        x_return_status                := l_return_status;
        x_rtg_header_rec               := l_rtg_header_rec;
        x_rtg_revision_tbl             := l_rtg_revision_tbl;
        x_operation_tbl                := l_operation_tbl;
        x_op_resource_tbl              := l_op_resource_tbl;
        x_sub_resource_tbl             := l_sub_resource_tbl;
        x_op_network_tbl               := l_op_network_tbl;
    -- Reset system_information business object flags

    BOM_Rtg_Globals.Set_STD_Item_Access( p_std_item_access => NULL);
    BOM_Rtg_Globals.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    BOM_Rtg_Globals.Set_PLN_Item_Access( p_pln_item_access => NULL);
    BOM_Rtg_Globals.Set_OC_Item_Access( p_oc_item_access   => NULL);

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug
   ('-----------------------------------------------------' ) ;
   Error_Handler.Write_Debug
   ('Rtg BO Private API process is terminated with unexpected error: ' || x_return_status) ;
END IF;

  END Process_Rtg;

END Bom_Rtg_Pvt ;

/
