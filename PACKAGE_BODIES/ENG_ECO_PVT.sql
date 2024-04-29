--------------------------------------------------------
--  DDL for Package Body ENG_ECO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ECO_PVT" AS
/* $Header: ENGVECOB.pls 120.11.12010000.18 2013/07/03 07:43:52 evwang ship $ */

--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'ENG_Eco_PVT';
G_EXC_QUIT_IMPORT       EXCEPTION;

G_MISS_ECO_REC          ENG_Eco_PUB.ECO_Rec_Type;
G_MISS_ECO_REV_REC      ENG_Eco_PUB.ECO_Revision_Rec_Type;
G_MISS_REV_ITEM_REC     ENG_Eco_PUB.Revised_Item_Rec_Type;
G_MISS_REV_COMP_REC     BOM_BO_PUB.Rev_Component_Rec_Type;
G_MISS_REF_DESG_REC     BOM_BO_PUB.Ref_Designator_Rec_Type;
G_MISS_SUB_COMP_REC     BOM_BO_PUB.Sub_Component_Rec_Type;

G_MISS_REV_OP_REC       Bom_Rtg_Pub.Rev_Operation_Tbl_Type;   --L1
G_MISS_REV_OP_RES_REC   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type; --L1
G_MISS_REV_SUB_RES_REC  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;--L1

    -- Bug 2918350 // kamohan
    -- Start Changes

    FUNCTION ret_co_status ( p_change_notice VARCHAR2, p_organization_id NUMBER)
       RETURN NUMBER
    IS
	CURSOR check_co_sch IS
	 SELECT status_type
	   FROM eng_engineering_changes
	 WHERE change_notice = p_change_notice
	      AND organization_id = p_organization_id
	      AND nvl(plm_or_erp_change, 'PLM') = 'PLM'; -- Added for bug 3692807

	l_chk_co_sch eng_engineering_changes.status_type%TYPE;
    BEGIN
	OPEN check_co_sch;
	FETCH check_co_sch INTO l_chk_co_sch;
	IF check_co_sch%FOUND THEN
		l_chk_co_sch := l_chk_co_sch;
	ELSE
		l_chk_co_sch := 10000;
	END IF;
	CLOSE check_co_sch;

	RETURN l_chk_co_sch;

    END ret_co_status;

    -- End Changes



--  L1:  The following part is for ECO enhancement
--  Rev_Sub_Operation_Resources

PROCEDURE Rev_Sub_Operation_Resources
(   p_validation_level        IN  NUMBER
,   p_change_notice           IN  VARCHAR2 := NULL
,   p_organization_id         IN  NUMBER   := NULL
,   p_revised_item_name       IN  VARCHAR2 := NULL
,   p_effectivity_date        IN  DATE     := NULL
,   p_item_revision           IN  VARCHAR2 := NULL
,   p_routing_revision        IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number    IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_operation_seq_num       IN  NUMBER   := NULL
,   p_operation_type          IN  NUMBER   := NULL
,   p_alternate_routing_code  IN  VARCHAR2 := NULL -- Added for bug 13329115
,   p_rev_sub_resource_tbl    IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
,   x_rev_sub_resource_tbl    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
,   x_mesg_token_tbl          OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status           OUT NOCOPY VARCHAR2
)

IS

/* Exposed and Unexposed record */
l_eco_rec                ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl       ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_tbl       ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_rec      BOM_BO_PUB.Rev_Component_Rec_Type;
l_rev_component_tbl      BOM_BO_PUB.Rev_Component_Tbl_Type;
l_rev_comp_unexp_rec     BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
--l_old_rev_component_rec  BOM_BO_PUB.Rev_Component_Rec_Type;
--l_old_rev_comp_unexp_rec BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_ref_designator_tbl     BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl      BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl      Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl    Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
--l_rev_sub_resource_tbl   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type := p_rev_sub_resource_tbl;
l_rev_sub_resource_rec   Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type;
l_rev_sub_res_unexp_rec  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type;
l_old_rev_sub_resource_rec   Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type;
l_old_rev_sub_res_unexp_rec  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type;

/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);


/* Others */
l_return_status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_op_parent_exists      BOOLEAN := FALSE;
l_rtg_parent_exists     BOOLEAN := FALSE;
l_process_children      BOOLEAN := TRUE;
l_valid                 BOOLEAN := TRUE;

/* Error handler definations */
EXC_SEV_QUIT_RECORD     EXCEPTION ;
EXC_SEV_QUIT_BRANCH     EXCEPTION ;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION ;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION ;
EXC_SEV_SKIP_BRANCH     EXCEPTION ;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION ;
EXC_FAT_QUIT_BRANCH     EXCEPTION ;
EXC_FAT_QUIT_OBJECT     EXCEPTION ;

BEGIN

   --  Init local table variables.
   l_return_status    := 'S';
   l_bo_return_status := 'S';
   --l_rev_sub_resource_tbl  := p_rev_sub_resource_tbl;
   x_rev_sub_resource_tbl  := p_rev_sub_resource_tbl;
   l_rev_sub_res_unexp_rec.organization_id := Eng_Globals.Get_Org_Id;

   FOR I IN 1..x_rev_sub_resource_tbl.COUNT LOOP
   -- Processing records for which the return status is null
   IF (x_rev_sub_resource_tbl(I).return_status IS NULL OR
        x_rev_sub_resource_tbl(I).return_status  = FND_API.G_MISS_CHAR)
   THEN
   BEGIN

      --  Load local records
      l_rev_sub_resource_rec := x_rev_sub_resource_tbl(I);

      l_rev_sub_resource_rec.transaction_type :=
          UPPER(l_rev_sub_resource_rec.transaction_type);



      --
      -- Initialize the Unexposed Record for every iteration of the Loop
      -- so that sequence numbers get generated for every new row.
      --
      l_rev_sub_res_unexp_rec.Revised_Item_Sequence_Id := NULL ;
      l_rev_sub_res_unexp_rec.Operation_Sequence_Id   := NULL ;
      l_rev_sub_res_unexp_rec.Substitute_Group_Number := NULL ;
      l_rev_sub_res_unexp_rec.Resource_Id             := NULL ;
      l_rev_sub_res_unexp_rec.New_Resource_Id         := NULL ;
      l_rev_sub_res_unexp_rec.Activity_Id             := NULL ;
      l_rev_sub_res_unexp_rec.Setup_Id                := NULL ;

      IF p_operation_seq_num  IS NOT NULL AND
         p_revised_item_name  IS NOT NULL AND
         p_effectivity_date   IS NOT NULL AND
         p_organization_id    IS NOT NULL
      THEN
         -- Revised Operation or Operation Sequence parent exists
         l_op_parent_exists  := TRUE;

      ELSIF p_revised_item_name IS NOT NULL AND
            p_organization_id    IS NOT NULL
      THEN
         -- Revised Item or Routing parent exists
         l_rtg_parent_exists := TRUE;
      END IF ;

      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF --(l_rev_sub_resource_rec.return_status IS NULL OR
         -- l_rev_sub_resource_rec.return_status  = FND_API.G_MISS_CHAR)
         --AND
         (
            -- Did Op_Seq call this procedure, that is,
            -- if revised operation(operation sequence) exists, then is this record a child ?
            (   l_op_parent_exists AND
                l_rev_sub_resource_rec.ECO_name = p_change_notice       AND
                l_rev_sub_res_unexp_rec.organization_id
                                             =   p_organization_id      AND
                NVL(l_rev_sub_resource_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR )       AND
                l_rev_sub_resource_rec.revised_item_name
                                             =   p_revised_item_name    AND
                NVL(l_rev_sub_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR )
                                             =   NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)    AND   -- Added for bug 13329115
                l_rev_sub_resource_rec.operation_sequence_number
                                             =   p_operation_seq_num    AND
                NVL(l_rev_sub_resource_rec.new_routing_revision,FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision,FND_API.G_MISS_CHAR )     AND -- Added by MK on 11/02/00
                NVL(l_rev_sub_resource_rec.from_end_item_unit_number,FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number,FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
                l_rev_sub_resource_rec.op_start_effective_date
                                             = nvl(ENG_Default_Revised_Item.G_OLD_SCHED_DATE,p_effectivity_date) -- Bug 6657209
              --  NVL(l_rev_sub_resource_rec.operation_type, 1)
              --                               = NVL(p_operation_type, 1)

            )
            OR
            -- Did Rtg_Header call this procedure, that is,
            -- if revised item or routing header exists, then is this record a child ?
            (  l_rtg_parent_exists AND
               l_rev_sub_resource_rec.ECO_name = p_change_notice       AND
               l_rev_sub_res_unexp_rec.organization_id
                                             =   p_organization_id     AND
               NVL(l_rev_sub_resource_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR )       AND
               l_rev_sub_resource_rec.revised_item_name
                                             = p_revised_item_name     AND
               NVL(l_rev_sub_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR )
                                             =   NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)    AND   -- Added for bug 13329115
               NVL(l_rev_sub_resource_rec.new_routing_revision,FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision,FND_API.G_MISS_CHAR )     AND -- Added by MK on 11/02/00
               NVL(l_rev_sub_resource_rec.from_end_item_unit_number,FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number,FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
               l_rev_sub_resource_rec.op_start_effective_date
                                             = p_effectivity_date
             --   NVL(l_rev_sub_resource_rec.alternate_routing_code, 'P')
             --                      = NVL(p_alternate_routing_code, 'P')

            )
           OR
           (NOT l_rtg_parent_exists AND NOT l_op_parent_exists)
         )
      THEN
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_rev_sub_resource_rec.return_status := FND_API.G_RET_STS_SUCCESS;

         -- Bug 6657209
         IF (l_op_parent_exists and ENG_Default_Revised_Item.G_OLD_SCHED_DATE is not null) THEN
           l_rev_sub_resource_rec.op_start_effective_date := p_effectivity_date;
         END IF;
         --
         -- Process Flow step 3 : Check if transaction_type is valid
         -- Transaction_Type must be CRATE, UPDATE, DELETE or CANCEL(in only ECO for Rrg)
         -- Call the Bom_Rtg_Globals.Transaction_Type_Validity
         --
         Eng_Globals.Transaction_Type_Validity
         (   p_transaction_type => l_rev_sub_resource_rec.transaction_type
         ,   p_entity           => 'Sub_Res'
         ,   p_entity_id        => l_rev_sub_resource_rec.Sub_Resource_Code
         ,   x_valid            => l_valid
         ,   x_mesg_token_tbl   => l_mesg_token_tbl
         ) ;

         IF NOT l_valid
         THEN
            RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         --
         -- Process Flow step 4(a): Convert user unique index to unique
         -- index I
         -- Call Rtg_Val_To_Id.Op_Resource_UUI_To_UI Shared Utility Package
         --
         BOM_Rtg_Val_To_Id.Rev_Sub_Resource_UUI_To_UI
         ( p_rev_sub_resource_rec    => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec   => l_rev_sub_res_unexp_rec
         , x_rev_sub_res_unexp_rec   => l_rev_sub_res_unexp_rec
         , x_mesg_token_tbl          => l_mesg_token_tbl
         , x_return_status           => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_SUB_RES_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;

         -- Added by MK on 12/03/00 to resolve ECO dependency
         ENG_Val_To_Id.RtgAndRevitem_UUI_To_UI
           ( p_revised_item_name        => l_rev_sub_resource_rec.revised_item_name
           , p_revised_item_id          => l_rev_sub_res_unexp_rec.revised_item_id
           , p_item_revision            => l_rev_sub_resource_rec.new_revised_item_revision
           , p_effective_date           => l_rev_sub_resource_rec.op_start_effective_date
           , p_change_notice            => l_rev_sub_resource_rec.eco_name
           , p_organization_id          => l_rev_sub_res_unexp_rec.organization_id
           , p_new_routing_revision     => l_rev_sub_resource_rec.new_routing_revision
           , p_from_end_item_number     => l_rev_sub_resource_rec.from_end_item_unit_number
           , p_entity_processed         => 'SR'
           , p_operation_sequence_number => l_rev_sub_resource_rec.operation_sequence_number
           , p_sub_resource_code         => l_rev_sub_resource_rec.sub_resource_code
           , p_schedule_sequence_number  => l_rev_sub_resource_rec.schedule_sequence_number
           , p_alternate_routing_code    => l_rev_sub_resource_rec.alternate_routing_code    -- Added for bug 13329115
           , x_revised_item_sequence_id  => l_rev_sub_res_unexp_rec.revised_item_sequence_id
           , x_routing_sequence_id       => l_rev_sub_res_unexp_rec.routing_sequence_id
           , x_operation_sequence_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
           , x_other_message            => l_other_message
           , x_other_token_tbl          => l_other_token_tbl
           , x_Return_Status            => l_return_status
          ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 for Rtg and Rev Item Seq completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_SUB_RES_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;




         --
         -- Process Flow step 4(b): Convert user unique index to unique
         -- index II
         -- Call the Rtg_Val_To_Id.Rev_Sub_Resource_UUI_To_UI2
         --
        /*
         Bom_Rtg_Val_To_Id.Rev_Sub_Resource_UUI_To_UI2
         ( p_rev_sub_resource_rec   => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
         , x_sub_res_unexp_rec      => l_rev_sub_res_unexp_rec
         , x_mesg_token_tbl         => l_mesg_token_tbl
         , x_other_message          => l_other_message
         , x_other_token_tbl        => l_other_token_tbl
         , x_return_status          => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
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
                        l_rev_sub_resource_rec.sub_resource_code;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;

        */
         --
         -- Process Flow step 5: Verify Substitute Resource's existence
         -- Call the Bom_Validate_Sub_Op_Res.Check_Existence.
         --
         --

         Bom_Validate_Sub_Op_Res.Check_Existence
         (  p_rev_sub_resource_rec        => l_rev_sub_resource_rec
         ,  p_rev_sub_res_unexp_rec       => l_rev_sub_res_unexp_rec
         ,  x_old_rev_sub_resource_rec    => l_old_rev_sub_resource_rec
         ,  x_old_rev_sub_res_unexp_rec   => l_old_rev_sub_res_unexp_rec
         ,  x_mesg_token_tbl              => l_mesg_token_tbl
         ,  x_return_status               => l_return_status
         ) ;


         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check Existence completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_SUB_RES_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
            -- l_other_token_tbl(3).token_name := 'REVISED_ITEM_NAME';
            -- l_other_token_tbl(3).token_value :=
            --            l_rev_sub_resource_rec.revised_item_name ;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
            -- l_other_token_tbl(3).token_name := 'REVISED_ITEM_NAME';
            -- l_other_token_tbl(3).token_value :=
            --          l_rev_sub_resource_rec.revised_item_name ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;


         --
         -- Process Flow step 6: Is Substitute Resource record an orphan ?
         --

         IF NOT l_op_parent_exists
         THEN

            --
            -- Process Flow step 7: Check lineage
            --
            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');     END IF;
            BOM_Validate_Op_Seq.Check_Lineage
                ( p_routing_sequence_id       =>
                               l_rev_sub_res_unexp_rec.routing_sequence_id
                , p_operation_sequence_number =>
                               l_rev_sub_resource_rec.operation_sequence_number
                , p_effectivity_date          =>
                               l_rev_sub_resource_rec.op_start_effective_date
                , p_operation_type            =>
                               l_rev_sub_resource_rec.operation_type
                , p_revised_item_sequence_id  =>
                               l_rev_sub_res_unexp_rec.revised_item_sequence_id
                , x_mesg_token_tbl            => l_mesg_token_tbl
                , x_return_status             => l_return_status
                ) ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN

                l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                l_Token_Tbl(1).token_value := l_rev_sub_resource_rec.sub_resource_code ;
                l_Token_Tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
                l_Token_Tbl(2).token_value := l_rev_sub_resource_rec.schedule_sequence_number ;
                l_Token_Tbl(3).token_name  := 'OP_SEQ_NUMBER' ;
                l_Token_Tbl(3).token_value := l_rev_sub_resource_rec.operation_sequence_number ;
                l_Token_Tbl(4).token_name  := 'REVISED_ITEM_NAME' ;
                l_Token_Tbl(4).token_value := l_rev_sub_resource_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_Message_Name  => 'BOM_SUB_RES_REV_ITEM_MISMATCH'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                ) ;


                l_other_message := 'BOM_SUB_RES_LIN_SEV_SKIP';
                l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                l_other_token_tbl(1).token_value :=
                            l_rev_sub_resource_rec.sub_resource_code ;
                l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                            l_rev_sub_resource_rec.schedule_sequence_number ;

                RAISE EXC_SEV_QUIT_BRANCH;

            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
                l_other_message := 'BOM_SUB_RES_LIN_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                l_other_token_tbl(1).token_value :=
                            l_rev_sub_resource_rec.sub_resource_code ;
                l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                            l_rev_sub_resource_rec.schedule_sequence_number ;
                RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

            -- Process Flow step 8(a and b): Is ECO impl/cancl, or in wkflw process ?
            --

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check ECO access'); END IF;

            ENG_Validate_ECO.Check_Access
            ( p_change_notice       => l_rev_sub_resource_rec.ECO_Name
            , p_organization_id     => l_rev_sub_res_unexp_rec.organization_id
            , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
            , x_Return_Status       => l_return_status
            );

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
                        l_other_message := 'BOM_SUB_RES_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                        l_other_token_tbl(1).token_value :=
                                    l_rev_sub_resource_rec.sub_resource_code ;
                        l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_rev_sub_resource_rec.schedule_sequence_number ;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
                        l_other_message := 'BOM_SUB_RES_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                        l_other_token_tbl(1).token_value :=
                                    l_rev_sub_resource_rec.sub_resource_code ;
                        l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_rev_sub_resource_rec.schedule_sequence_number ;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

            -- Process Flow step 9(a and b): check that user has access to revised item
            --

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Revised item access'); END IF;
            ENG_Validate_Revised_Item.Check_Access
            (  p_change_notice   => l_rev_sub_resource_rec.ECO_Name
            ,  p_organization_id => l_rev_sub_res_unexp_rec.organization_id
            ,  p_revised_item_id => l_rev_sub_res_unexp_rec.revised_item_id
            ,  p_new_item_revision  =>
                               l_rev_sub_resource_rec.new_revised_item_revision
            ,  p_effectivity_date   =>
                               l_rev_sub_resource_rec.op_start_effective_date
            ,  p_new_routing_revsion   => l_rev_sub_resource_rec.new_routing_revision  -- Added by MK on 11/02/00
            ,  p_from_end_item_number  => l_rev_sub_resource_rec.from_end_item_unit_number -- Added by MK on 11/02/00
            ,  p_revised_item_name     =>
                               l_rev_sub_resource_rec.revised_item_name
            ,  p_entity_processed   => 'SR'                                               -- Added by MK
            ,  p_operation_seq_num  =>  l_rev_sub_resource_rec.operation_sequence_number  -- Added by MK
            ,  p_routing_sequence_id => l_rev_sub_res_unexp_rec.routing_sequence_id       -- Added by MK
            ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            ,  x_return_status      => l_Return_Status
            );

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
                        l_other_message := 'BOM_SUB_RES_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                        l_other_token_tbl(1).token_value :=
                                    l_rev_sub_resource_rec.sub_resource_code ;
                        l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_rev_sub_resource_rec.schedule_sequence_number ;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
                        l_other_message := 'BOM_SUB_RES_RITACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                        l_other_token_tbl(1).token_value :=
                                    l_rev_sub_resource_rec.sub_resource_code ;
                        l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_rev_sub_resource_rec.schedule_sequence_number ;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

            --
            -- Process Flow step 10(b) : Check that user has access to revised
            -- operation
            -- BOM_Validate_Op_Seq.Check_Access

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Operation sequence item access'); END IF;
            BOM_Validate_Op_Seq.Check_Access
              (  p_change_notice      => l_rev_sub_resource_rec.ECO_Name
              ,  p_organization_id    => l_rev_sub_res_unexp_rec.organization_id
              ,  p_revised_item_id    => l_rev_sub_res_unexp_rec.revised_item_id
              ,  p_revised_item_name  => l_rev_sub_resource_rec.revised_item_name
              ,  p_new_item_revision  =>
                             l_rev_sub_resource_rec.new_revised_item_revision
              ,  p_effectivity_date   =>
                             l_rev_sub_resource_rec.op_start_effective_date
              ,  p_new_routing_revsion   => l_rev_sub_resource_rec.new_routing_revision  -- Added by MK on 11/02/00
              ,  p_from_end_item_number  => l_rev_sub_resource_rec.from_end_item_unit_number -- Added by MK on 11/02/00
              ,  p_operation_seq_num  =>
                             l_rev_sub_resource_rec.operation_sequence_number
              ,  p_routing_sequence_id=>
                                   l_rev_sub_res_unexp_rec.routing_sequence_id
              ,  p_operation_type     => l_rev_sub_resource_rec.operation_type
              ,  p_entity_processed   => 'SR'
              ,  p_sub_resource_code  =>
                            l_rev_sub_resource_rec.sub_resource_code
              ,  p_sub_group_num      =>
                            l_rev_sub_resource_rec.schedule_sequence_number
              ,  p_resource_seq_num   => NULL
              ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              ,  x_return_status      => l_Return_Status
             );

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
                        l_other_message := 'BOM_SUB_RES_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                        l_other_token_tbl(1).token_value :=
                                    l_rev_sub_resource_rec.sub_resource_code ;
                        l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_rev_sub_resource_rec.schedule_sequence_number ;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
                        l_other_message := 'BOM_SUB_RES_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                        l_other_token_tbl(1).token_value :=
                                    l_rev_sub_resource_rec.sub_resource_code ;
                        l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                        l_other_token_tbl(2).token_value :=
                                    l_rev_sub_resource_rec.schedule_sequence_number ;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

         END IF; -- parent op does not exist

         --
         -- Process Flow step 11 : Check if the parent operation is
         -- non-referencing operation of type: Event
         -- Call Bom_Validate_Op_Seq.Check_NonRefEvent
         --
         Bom_Validate_Op_Res.Check_NonRefEvent
         (  p_operation_sequence_id =>
                                  l_rev_sub_res_unexp_rec.operation_sequence_id
            ,  p_operation_type       => l_rev_sub_resource_rec.operation_type
            ,  p_entity_processed     => 'RES'
            ,  x_mesg_token_tbl       => l_mesg_token_tbl
            ,  x_return_status        => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Check non-ref operation completed with return_status: '
                      || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
               IF l_rev_sub_resource_rec.operation_type IN (2, 3) -- Process or Line Op
               THEN

                  l_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_token_tbl(1).token_value :=
                          l_rev_sub_resource_rec.sub_resource_code ;
                  l_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          l_rev_sub_resource_rec.schedule_sequence_number ;
                  l_token_tbl(3).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(3).token_value :=
                          l_rev_sub_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_SUB_RES_OPTYPE_NOT_EVENT'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;
               ELSE

                  l_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_token_tbl(1).token_value :=
                          l_rev_sub_resource_rec.sub_resource_code ;
                  l_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          l_rev_sub_resource_rec.schedule_sequence_number ;
                  l_token_tbl(3).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(3).token_value :=
                          l_rev_sub_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_SUB_RES_MUST_NONREF'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;

               END IF ;

               l_return_status := 'F';
               l_other_message := 'BOM_SUB_RES_ACCESS_FAT_FATAL';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                                    l_rev_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                                    l_rev_sub_resource_rec.schedule_sequence_number ;

               RAISE EXC_FAT_QUIT_SIBLINGS ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
               l_other_message := 'BOM_SUB_RES_ACCESS_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;


         --
         -- Process Flow step 12: Value to Id conversions
         -- Call Rtg_Val_To_Id.Rev_Sub_Resource_VID
         --

         Bom_Rtg_Val_To_Id.Rev_Sub_Resource_VID
         (  p_rev_sub_resource_rec       => l_rev_sub_resource_rec
         ,  p_rev_sub_res_unexp_rec      => l_rev_sub_res_unexp_rec
         ,  x_rev_sub_res_unexp_rec      => l_rev_sub_res_unexp_rec
         ,  x_mesg_token_tbl             => l_mesg_token_tbl
         ,  x_return_status              => l_return_status
         );

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Value-id conversions completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_rev_sub_resource_rec.transaction_type = 'CREATE'
            THEN
               l_other_message := 'BOM_SUB_RES_VID_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_SUB_RES_VID_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
            l_other_token_tbl(1).token_value :=
                     l_rev_sub_resource_rec.sub_resource_code ;
            l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
            l_other_token_tbl(2).token_value :=
                     l_rev_sub_resource_rec.schedule_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl.COUNT <> 0
         THEN
           ECO_Error_Handler.Log_Error
            (
               p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
            ,  p_entity_index        => I
            ,  x_eco_rec             => l_ECO_rec
            ,  x_eco_revision_tbl    => l_eco_revision_tbl
            ,  x_revised_item_tbl    => l_revised_item_tbl
            ,  x_rev_component_tbl   => l_rev_component_tbl
            ,  x_ref_designator_tbl  => l_ref_designator_tbl
            ,  x_sub_component_tbl   => l_sub_component_tbl
            ,  x_rev_operation_tbl   => l_rev_operation_tbl
            ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
            ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
            ) ;


         END IF;


         --
         -- Process Flow step 13 : Check required fields exist
         -- (also includes a part of conditionally required fields)
         --
         -- No process contents

         --
         -- Process Flow step 14 : Attribute Validation for CREATE and UPDATE
         -- Call Bom_Validate_Op_Res.Check_Attributes
         --

         IF l_rev_sub_resource_rec.transaction_type IN
            (Bom_Rtg_Globals.G_OPR_CREATE, Bom_Rtg_Globals.G_OPR_UPDATE)
         THEN
            Bom_Validate_Sub_Op_Res.Check_Attributes
            ( p_rev_sub_resource_rec   => l_rev_sub_resource_rec
            , p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
            , x_return_status          => l_return_status
            , x_mesg_token_tbl         => l_mesg_token_tbl
            ) ;

            IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Attribute validation completed with return_status: ' ||
                  l_return_status) ;
            END IF ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               IF l_rev_sub_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
               THEN
                  l_other_message := 'BOM_SUB_RES_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                  l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
                  l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                  l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_SUB_RES_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
               l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
               l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
               l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl.COUNT <> 0
            THEN
               ECO_Error_Handler.Log_Error
               (
                  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
               ,  p_entity_index        => I
               ,  x_eco_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => l_rev_operation_tbl
               ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ) ;
           END IF;
        END IF;

        IF l_rev_sub_resource_rec.transaction_type IN
           (Bom_Rtg_Globals.G_OPR_UPDATE, Bom_Rtg_Globals.G_OPR_DELETE)
        THEN

        --
        -- Process flow step 16: Populate NULL columns for Update and Delete
        -- Call Bom_Default_Op_Res.Populate_Null_Columns
        --

           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns') ;
           END IF ;

           Bom_Default_Sub_Op_Res.Populate_Null_Columns
           (   p_rev_sub_resource_rec       => l_rev_sub_resource_rec
           ,   p_old_rev_sub_resource_rec   => l_old_rev_sub_resource_rec
           ,   p_rev_sub_res_unexp_rec      => l_rev_sub_res_unexp_rec
           ,   p_old_rev_sub_res_unexp_rec  => l_old_rev_sub_res_unexp_rec
           ,   x_rev_sub_resource_rec       => l_rev_sub_resource_rec
           ,   x_rev_sub_res_unexp_rec      => l_rev_sub_res_unexp_rec
           ) ;


        ELSIF l_rev_sub_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
        THEN
        --
        -- Process Flow step 18 : Default missing values for Sub Op Resource (CREATE)
        -- Call Bom_Default_Op_Res.Attribute_Defaulting
        --

           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting') ;
           END IF ;

           Bom_Default_Sub_Op_Res.Attribute_Defaulting
           (   p_rev_sub_resource_rec => l_rev_sub_resource_rec
           ,   p_rev_sub_res_unexp_rec=> l_rev_sub_res_unexp_rec
           ,   p_control_rec          => Bom_Rtg_Pub.G_Default_Control_Rec
           ,   x_rev_sub_resource_rec => l_rev_sub_resource_rec
           ,   x_rev_sub_res_unexp_rec=> l_rev_sub_res_unexp_rec
           ,   x_mesg_token_tbl       => l_mesg_token_tbl
           ,   x_return_status        => l_return_status
           ) ;


           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
              l_other_message := 'BOM_SUB_RES_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
              l_other_token_tbl(1).token_value:=
                        l_rev_sub_resource_rec.sub_resource_code ;
              l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
              l_other_token_tbl(2).token_value:=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'BOM_SUB_RES_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
              l_other_token_tbl(1).token_value:=
                        l_rev_sub_resource_rec.sub_resource_code ;
              l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
              l_other_token_tbl(2).token_value:=
                        l_rev_sub_resource_rec.schedule_sequence_number;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl.COUNT <> 0
           THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_SR_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => l_rev_operation_tbl
               ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ) ;
          END IF;
       END IF;

       --
       -- Process Flow step 17: Conditionally Required Attributes
       -- No process contents
       --

       --
       -- Process Flow step 18: Entity defaulting for CREATE and UPDATE
       --


       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting') ;
       END IF ;
       IF l_rev_sub_resource_rec.transaction_type IN ( Bom_Rtg_Globals.G_OPR_CREATE
                                                 , Bom_Rtg_Globals.G_OPR_UPDATE )
       THEN
          Bom_Default_Sub_OP_Res.Entity_Defaulting
              (   p_rev_sub_resource_rec   => l_rev_sub_resource_rec
              ,   p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
              ,   p_control_rec            => Bom_Rtg_Pub.G_Default_Control_Rec
              ,   x_rev_sub_resource_rec   => l_rev_sub_resource_rec
              ,   x_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
              ,   x_mesg_token_tbl         => l_mesg_token_tbl
              ,   x_return_status          => l_return_status
              ) ;

          IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Entity defaulting completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_rev_sub_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_SUB_RES_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
                l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
                l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
                l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_SUB_RES_ENTDEF_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
             l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
             l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
             l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl.COUNT <> 0
          THEN
             ECO_Error_Handler.Log_Error
             (  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
             ,  p_mesg_token_tbl      => l_mesg_token_tbl
             ,  p_error_status        => 'W'
             ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
             ,  p_entity_index        => I
             ,  x_ECO_rec               => l_ECO_rec
             ,  x_eco_revision_tbl      => l_eco_revision_tbl
             ,  x_revised_item_tbl      => l_revised_item_tbl
             ,  x_rev_component_tbl     => l_rev_component_tbl
             ,  x_ref_designator_tbl    => l_ref_designator_tbl
             ,  x_sub_component_tbl     => l_sub_component_tbl
             ,  x_rev_operation_tbl     => l_rev_operation_tbl
             ,  x_rev_op_resource_tbl   => l_rev_op_resource_tbl
             ,  x_rev_sub_resource_tbl  => x_rev_sub_resource_tbl
             ) ;
          END IF ;
       END IF ;


       --
       -- Process Flow step 19 - Entity Level Validation
       -- Call Bom_Validate_Op_Res.Check_Entity
       --

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Starting Entity Validation for Sub Op Resources . . . ') ;
END IF ;

          Bom_Validate_Sub_Op_Res.Check_Entity
          (  p_rev_sub_resource_rec       => l_rev_sub_resource_rec
          ,  p_rev_sub_res_unexp_rec      => l_rev_sub_res_unexp_rec
          ,  p_old_rev_sub_resource_rec   => l_old_rev_sub_resource_rec
          ,  p_old_rev_sub_res_unexp_rec  => l_old_rev_sub_res_unexp_rec
          ,  p_control_rec                => Bom_Rtg_Pub.G_Default_Control_Rec
          ,  x_rev_sub_resource_rec       => l_rev_sub_resource_rec
          ,  x_rev_sub_res_unexp_rec      => l_rev_sub_res_unexp_rec
          ,  x_mesg_token_tbl             => l_mesg_token_tbl
          ,  x_return_status              => l_return_status
          ) ;

       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          IF l_rev_sub_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
          THEN
             l_other_message := 'BOM_SUB_RES_ENTVAL_CSEV_SKIP';
             l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
             l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
             l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
             l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
             RAISE EXC_SEV_SKIP_BRANCH ;
          ELSE
             RAISE EXC_SEV_QUIT_RECORD ;
          END IF;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_SUB_RES_ENTVAL_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
          l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
          l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
          l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND l_mesg_token_tbl.COUNT <> 0
       THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => 'W'
          ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
          ,  p_entity_index        => I
          ,  x_ECO_rec             => l_ECO_rec
          ,  x_eco_revision_tbl    => l_eco_revision_tbl
          ,  x_revised_item_tbl    => l_revised_item_tbl
          ,  x_rev_component_tbl   => l_rev_component_tbl
          ,  x_ref_designator_tbl  => l_ref_designator_tbl
          ,  x_sub_component_tbl   => l_sub_component_tbl
          ,  x_rev_operation_tbl   => l_rev_operation_tbl
          ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ) ;
       END IF;

       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation completed with '
             || l_return_Status || ' proceeding for database writes . . . ') ;
       END IF;

       --
       -- Process Flow step 20 : Database Writes
       --
          Bom_Sub_Op_Res_Util.Perform_Writes
          (   p_rev_sub_resource_rec => l_rev_sub_resource_rec
          ,   p_rev_sub_res_unexp_rec=> l_rev_sub_res_unexp_rec
          ,   p_control_rec          => Bom_Rtg_Pub.G_Default_Control_Rec
          ,   x_mesg_token_tbl       => l_mesg_token_tbl
          ,   x_return_status        => l_return_status
          ) ;

       IF l_return_status = ECo_Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_SUB_RES_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'SUB_RESOURCE_CODE';
          l_other_token_tbl(1).token_value :=
                        l_rev_sub_resource_rec.sub_resource_code ;
          l_other_token_tbl(2).token_name := 'SCHEDULE_SEQ_NUMBER';
          l_other_token_tbl(2).token_value :=
                        l_rev_sub_resource_rec.schedule_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => 'W'
          ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
          ,  p_entity_index        => I
          ,  x_ECO_rec             => l_ECO_rec
          ,  x_eco_revision_tbl    => l_eco_revision_tbl
          ,  x_revised_item_tbl    => l_revised_item_tbl
          ,  x_rev_component_tbl   => l_rev_component_tbl
          ,  x_ref_designator_tbl  => l_ref_designator_tbl
          ,  x_sub_component_tbl   => l_sub_component_tbl
          ,  x_rev_operation_tbl   => l_rev_operation_tbl
          ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ) ;
       END IF;

       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Database writes completed with status  ' || l_return_status);
       END IF;


    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    x_rev_sub_resource_tbl(I)          := l_rev_sub_resource_rec;


    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => FND_API.G_RET_STS_ERROR
          ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
          ,  p_entity_index        => I
          ,  x_ECO_rec             => l_ECO_rec
          ,  x_eco_revision_tbl    => l_eco_revision_tbl
          ,  x_revised_item_tbl    => l_revised_item_tbl
          ,  x_rev_component_tbl   => l_rev_component_tbl
          ,  x_ref_designator_tbl  => l_ref_designator_tbl
          ,  x_sub_component_tbl   => l_sub_component_tbl
          ,  x_rev_operation_tbl   => l_rev_operation_tbl
          ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status := l_return_status ;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_SEV_QUIT_BRANCH THEN

         ECO_Error_Handler.Log_Error
         (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => ECo_Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status := l_return_status;
         END IF;

         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

      WHEN EXC_SEV_SKIP_BRANCH THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

        IF l_bo_return_status = 'S'
        THEN
           l_bo_return_status  := l_return_status ;
        END IF;
        x_return_status        := l_bo_return_status;
        x_mesg_token_tbl       := l_mesg_token_tbl ;
        --x_rev_sub_resource_tbl := l_rev_sub_resource_tbl ;

      WHEN EXC_SEV_QUIT_SIBLINGS THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         IF l_bo_return_status = 'S'
         THEN
           l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_BRANCH THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         x_return_status         := Error_Handler.G_STATUS_FATAL;
         x_mesg_token_tbl        := l_mesg_token_tbl ;
         --x_rev_sub_resource_tbl  := l_rev_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

        x_return_status       := Error_Handler.G_STATUS_FATAL;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

    WHEN EXC_FAT_QUIT_OBJECT THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         l_return_status       := 'Q';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => ECO_Error_Handler.G_SR_LEVEL
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         l_return_status       := 'U';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

   END ; -- END block


   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;

   END IF; -- End of processing records for which the return status is null
   END LOOP; -- END Substitute Operation Resources processing loop

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;

   x_mesg_token_tbl      := l_mesg_token_tbl ;
   --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;
   x_mesg_token_tbl      := l_mesg_token_tbl ;

END Rev_Sub_Operation_Resources ;

--  Rev_Operation_Resources

/****************************************************************************
* Procedure : Rev_Operation_Resources
* Parameters IN   : Revised Operation Resources Table and all the other sibiling entities
* Parameters OUT  : Revised Operatin Resources and all the other sibiling entities
* Purpose   : This procedure will process all the Revised Operation Resources records.
*
*****************************************************************************/

PROCEDURE Rev_Operation_Resources
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER   := NULL
,   p_revised_item_name             IN  VARCHAR2 := NULL
,   p_effectivity_date              IN  DATE     := NULL
,   p_item_revision                 IN  VARCHAR2 := NULL
,   p_routing_revision              IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number          IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_operation_seq_num             IN  NUMBER   := NULL
,   p_operation_type                IN  NUMBER   := NULL
,   p_alternate_routing_code        IN  VARCHAR2 := NULL -- Added for bug 13329115
,   p_rev_op_resource_tbl           IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
,   p_rev_sub_resource_tbl          IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
,   x_rev_op_resource_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
,   x_rev_sub_resource_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
,   x_mesg_token_tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
)
IS

/* Exposed and Unexposed record */
l_rev_op_resource_rec         Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
l_rev_op_res_unexp_rec        Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
--l_rev_op_resource_tbl         Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type ;
l_old_rev_op_resource_rec     Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
l_old_rev_op_res_unexp_rec    Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;



/* Other Entities */
l_eco_rec                ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl       ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_tbl       ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_rec      BOM_BO_PUB.Rev_Component_Rec_Type;
l_rev_component_tbl      BOM_BO_PUB.Rev_Component_Tbl_Type;
l_rev_comp_unexp_rec     BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_old_rev_component_rec  BOM_BO_PUB.Rev_Component_Rec_Type;
l_old_rev_comp_unexp_rec BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_ref_designator_tbl     BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl      BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl      Bom_Rtg_Pub.Rev_Operation_Tbl_Type ;
--l_rev_sub_resource_tbl   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type ;
--                                   := p_rev_sub_resource_tbl ;


/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type ;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);


/* Others */
l_return_status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_op_parent_exists      BOOLEAN := FALSE;
l_item_parent_exists    BOOLEAN := FALSE;
l_process_children      BOOLEAN := TRUE;
l_valid                 BOOLEAN := TRUE;

/* Error handler definations */
EXC_SEV_QUIT_RECORD     EXCEPTION ;
EXC_SEV_QUIT_BRANCH     EXCEPTION ;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION ;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION ;
EXC_SEV_SKIP_BRANCH     EXCEPTION ;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION ;
EXC_FAT_QUIT_BRANCH     EXCEPTION ;
EXC_FAT_QUIT_OBJECT     EXCEPTION ;

BEGIN

   --  Init local table variables.
   l_return_status    := 'S';
   l_bo_return_status := 'S';
   --l_rev_op_resource_tbl  := p_rev_op_resource_tbl;
   x_rev_op_resource_tbl  := p_rev_op_resource_tbl;
   x_rev_sub_resource_tbl  := p_rev_sub_resource_tbl;

   l_rev_op_res_unexp_rec.organization_id := Eng_Globals.Get_Org_Id;

   FOR I IN 1..x_rev_op_resource_tbl.COUNT LOOP
   -- Processing records for which the return status is null
   IF (x_rev_op_resource_tbl(I).return_status IS NULL OR
        x_rev_op_resource_tbl(I).return_status  = FND_API.G_MISS_CHAR) THEN
   BEGIN

      --  Load local records
      l_rev_op_resource_rec := x_rev_op_resource_tbl(I) ;

      l_rev_op_resource_rec.transaction_type :=
         UPPER(l_rev_op_resource_rec.transaction_type) ;

      --
      -- Initialize the Unexposed Record for every iteration of the Loop
      -- so that sequence numbers get generated for every new row.
      --
      l_rev_op_res_unexp_rec.Revised_Item_Sequence_Id:= NULL ;
      l_rev_op_res_unexp_rec.Operation_Sequence_Id   := NULL ;
      l_rev_op_res_unexp_rec.Substitute_Group_Number := NULL ;
      l_rev_op_res_unexp_rec.Resource_Id             := NULL ;
      l_rev_op_res_unexp_rec.Activity_Id             := NULL ;
      l_rev_op_res_unexp_rec.Setup_Id                := NULL ;


      IF p_operation_seq_num  IS NOT NULL AND
         p_revised_item_name  IS NOT NULL AND
         p_effectivity_date   IS NOT NULL AND
         p_organization_id    IS NOT NULL AND
         p_change_notice IS NOT NULL
      THEN
         -- Revised Operation parent exists
         l_op_parent_exists  := TRUE ;

      ELSIF p_revised_item_name IS NOT NULL AND
            p_effectivity_date IS NOT NULL  AND
            /* p_item_revision IS NOT NULL     AND Commented for Bug 6485168 */
            p_change_notice IS NOT NULL     AND
            p_organization_id IS NOT NULL
      THEN

         -- Revised Item parent exists
         l_item_parent_exists := TRUE ;
      END IF ;

      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                        ('ECO Name: ' || p_change_notice ||
                         ' Org: ' || p_organization_id ||
                         ' Eff. Dt: ' || to_char(p_effectivity_date) ||
                         ' Revision: ' || p_item_revision ||
                         ' Rev Item: ' || p_revised_item_name ||
                         ' Op. Seq: ' || p_operation_seq_num); END IF;


      IF --(l_rev_op_resource_rec.return_status IS NULL OR
         --l_rev_op_resource_rec.return_status  = FND_API.G_MISS_CHAR)
         --AND
         (
            -- Did Op_Seq call this procedure, that is,
            -- if revised operation(operation sequence) exists, then is this record a child ?
            (l_op_parent_exists AND
               (l_rev_op_resource_rec.ECO_Name
                                             = p_change_notice    AND
                l_rev_op_res_unexp_rec.organization_id
                                             = p_organization_id  AND
                l_rev_op_resource_rec.op_start_effective_date
                                             = nvl(ENG_Default_Revised_Item.G_OLD_SCHED_DATE,p_effectivity_date) AND -- Bug 6657209
                NVL(l_rev_op_resource_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             = NVL(p_item_revision, FND_API.G_MISS_CHAR )   AND
                l_rev_op_resource_rec.revised_item_name
                                            = p_revised_item_name AND
                NVL(l_rev_op_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR )
                                            = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR) AND --Added for bug 13329115
                NVL(l_rev_op_resource_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             = NVL(p_routing_revision, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
                NVL(l_rev_op_resource_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             = NVL(p_from_end_item_number, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
                l_rev_op_resource_rec.operation_sequence_number
                                            = p_operation_seq_num AND
                NVL(l_rev_op_resource_rec.operation_type, 1)
                                           = NVL(p_operation_type, 1)
                )
             )
             OR
             -- Did Rev_Items call this procedure, that is,
             -- if revised item exists, then is this record a child ?

             (l_item_parent_exists AND
               (l_rev_op_resource_rec.ECO_Name
                                                = p_change_notice AND
                l_rev_op_res_unexp_rec.organization_id
                                              = p_organization_id AND
                l_rev_op_resource_rec.revised_item_name
                                            = p_revised_item_name AND
                NVL(l_rev_op_resource_rec.alternate_routing_code, FND_API.G_MISS_CHAR )
                                            = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR) AND --Added for bug 13329115
                l_rev_op_resource_rec.op_start_effective_date
                                             = p_effectivity_date AND
                NVL(l_rev_op_resource_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             = NVL(p_routing_revision, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
                NVL(l_rev_op_resource_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             = NVL(p_from_end_item_number, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
                NVL(l_rev_op_resource_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                                  = NVL(p_item_revision, FND_API.G_MISS_CHAR ) )
             )

             OR

             (NOT l_item_parent_exists AND
              NOT l_op_parent_exists)
         )

      THEN
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_rev_op_resource_rec.return_status := FND_API.G_RET_STS_SUCCESS;

         -- Bug 6657209
           IF (l_op_parent_exists and ENG_Default_Revised_Item.G_OLD_SCHED_DATE is not null) THEN
              l_rev_op_resource_rec.op_start_effective_date := p_effectivity_date;
           END IF;

         --
         -- Process Flow step 3 :Check if transaction_type is valid
         -- Transaction_Type must be CRATE, UPDATE, DELETE or CANCEL(in only ECO for Rrg)
         -- Call the Bom_Rtg_Globals.Transaction_Type_Validity
         --

         Eng_Globals.Transaction_Type_Validity
         (   p_transaction_type => l_rev_op_resource_rec.transaction_type
         ,   p_entity           => 'Op_Res'
         ,   p_entity_id        => l_rev_op_resource_rec.resource_sequence_number
         ,   x_valid            => l_valid
         ,   x_mesg_token_tbl   => l_mesg_token_tbl
         ) ;

         IF NOT l_valid
         THEN
            RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         --
         -- Process Flow step 4(a): Convert user unique index to unique
         -- index I
         -- Call Rtg_Val_To_Id.Op_Resource_UUI_To_UI Shared Utility Package
         --

         Bom_Rtg_Val_To_Id.Rev_Op_Resource_UUI_To_UI
         ( p_rev_op_resource_rec    => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec   => l_rev_op_res_unexp_rec
         , x_rev_op_res_unexp_rec   => l_rev_op_res_unexp_rec
         , x_mesg_token_tbl         => l_mesg_token_tbl
         , x_return_status          => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_RES_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_op_resource_rec.resource_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;


         -- Added by MK on 12/03/00 to resolve ECO dependency
         ENG_Val_To_Id.RtgAndRevitem_UUI_To_UI
           ( p_revised_item_name        => l_rev_op_resource_rec.revised_item_name
           , p_revised_item_id          => l_rev_op_res_unexp_rec.revised_item_id
           , p_item_revision            => l_rev_op_resource_rec.new_revised_item_revision
           , p_effective_date           => l_rev_op_resource_rec.op_start_effective_date
           , p_change_notice            => l_rev_op_resource_rec.eco_name
           , p_organization_id          => l_rev_op_res_unexp_rec.organization_id
           , p_new_routing_revision     => l_rev_op_resource_rec.new_routing_revision
           , p_from_end_item_number     => l_rev_op_resource_rec.from_end_item_unit_number
           , p_entity_processed         => 'RES'
           , p_operation_sequence_number => l_rev_op_resource_rec.operation_sequence_number
           , p_resource_sequence_number  => l_rev_op_resource_rec.resource_sequence_number
           , p_alternate_routing_code    => l_rev_op_resource_rec.alternate_routing_code    -- Added for bug 13329115
           , x_revised_item_sequence_id  => l_rev_op_res_unexp_rec.revised_item_sequence_id
           , x_routing_sequence_id       => l_rev_op_res_unexp_rec.routing_sequence_id
           , x_operation_sequence_id     => l_rev_op_res_unexp_rec.operation_sequence_id
           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
           , x_other_message            => l_other_message
           , x_other_token_tbl          => l_other_token_tbl
           , x_Return_Status            => l_return_status
          ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 for Rtg and Rev Item Seq completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_RES_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_op_resource_rec.resource_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;


         --
         -- Process Flow step 4(b): Convert user unique index to unique
         -- index II
         -- Call the Rtg_Val_To_Id.Operation_UUI_To_UI2
         --
         /*
         Bom_Rtg_Val_To_Id.Rev_Op_Resource_UUI_To_UI2
         ( p_rev_op_resource_rec    => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec   => l_rev_op_res_unexp_rec
         , x_rev_op_res_unexp_rec   => l_rev_op_res_unexp_rec
         , x_mesg_token_tbl         => l_mesg_token_tbl
         , x_other_message          => l_other_message
         , x_other_token_tbl        => l_other_token_tbl
         , x_return_status          => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
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
                   l_rev_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;
         */
         --
         -- Process Flow step 5: Verify Operation Resource's existence
         -- Call the Bom_Validate_Op_Seq.Check_Existence
         --
         --

         Bom_Validate_Op_Res.Check_Existence
         (  p_rev_op_resource_rec        => l_rev_op_resource_rec
         ,  p_rev_op_res_unexp_rec       => l_rev_op_res_unexp_rec
         ,  x_old_rev_op_resource_rec    => l_old_rev_op_resource_rec
         ,  x_old_rev_op_res_unexp_rec   => l_old_rev_op_res_unexp_rec
         ,  x_mesg_token_tbl             => l_mesg_token_tbl
         ,  x_return_status              => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check Existence completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_RES_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
            l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_rev_op_resource_rec.revised_item_name ;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
            l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_rev_op_resource_rec.revised_item_name ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

         --
         -- Process Flow step 6: Is Operation Resource record an orphan ?
         --

         IF NOT l_op_parent_exists
         THEN

            --
            -- Process Flow step 7: Check lineage
            --
            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');     END IF;

            BOM_Validate_Op_Seq.Check_Lineage
            ( p_routing_sequence_id       =>
                             l_rev_op_res_unexp_rec.routing_sequence_id
            , p_operation_sequence_number =>
                             l_rev_op_resource_rec.operation_sequence_number
            , p_effectivity_date          =>
                             l_rev_op_resource_rec.op_start_effective_date
            , p_operation_type            =>
                             l_rev_op_resource_rec.operation_type
            , p_revised_item_sequence_id  =>
                             l_rev_op_res_unexp_rec.revised_item_sequence_id
            , x_mesg_token_tbl            => l_mesg_token_tbl
            , x_return_status             => l_return_status
            ) ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
                l_Token_Tbl(1).token_name  := 'RES_SEQ_NUMBER' ;
                l_Token_Tbl(1).token_value := l_rev_op_resource_rec.resource_sequence_number ;
                l_Token_Tbl(2).token_name  := 'OP_SEQ_NUMBER' ;
                l_Token_Tbl(2).token_value := l_rev_op_resource_rec.operation_sequence_number ;
                l_Token_Tbl(3).token_name  := 'REVISED_ITEM_NAME' ;
                l_Token_Tbl(3).token_value := l_rev_op_resource_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                ( p_Message_Name  => 'BOM_RES_REV_ITEM_MISMATCH'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                ) ;


                l_other_message := 'BOM_RES_LIN_SEV_SKIP';
                l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                               l_rev_op_resource_rec.resource_sequence_number ;
                RAISE EXC_SEV_QUIT_BRANCH;

            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
                l_other_message := 'BOM_RES_LIN_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
                RAISE EXC_UNEXP_SKIP_OBJECT;
            END IF;

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;


                -- Process Flow step 8(a and b): Is ECO impl/cancl, or in wkflw process ?
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check ECO access'); END IF;

                ENG_Validate_ECO.Check_Access
                ( p_change_notice       => l_rev_op_resource_rec.ECO_Name
                , p_organization_id     =>
                                        l_rev_op_res_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RES_ECOACC_FAT_FATAL' ;
                        l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                               l_rev_op_resource_rec.operation_sequence_number;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RES_ECOACC_UNEXP_SKIP' ;
                        l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                               l_rev_op_resource_rec.resource_sequence_number;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                --
                -- Process Flow step 9(a and b): check that user has access to revised item
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Revised item access'); END IF;
                ENG_Validate_Revised_Item.Check_Access
                (  p_change_notice   => l_rev_op_resource_rec.ECO_Name
                ,  p_organization_id => l_rev_op_res_unexp_rec.organization_id
                ,  p_revised_item_id => l_rev_op_res_unexp_rec.revised_item_id
                ,  p_new_item_revision  =>
                               l_rev_op_resource_rec.new_revised_item_revision
                ,  p_effectivity_date   =>
                               l_rev_op_resource_rec.op_start_effective_date
                ,  p_new_routing_revsion   => l_rev_op_resource_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_rev_op_resource_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  =>
                               l_rev_op_resource_rec.revised_item_name
                ,  p_entity_processed   => 'RES'                                             -- Added by MK
                ,  p_operation_seq_num  =>  l_rev_op_resource_rec.operation_sequence_number  -- Added by MK
                ,  p_routing_sequence_id => l_rev_op_res_unexp_rec.routing_sequence_id       -- Added by MK

                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RES_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                               l_rev_op_resource_rec.resource_sequence_number;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RES_RITACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                               l_rev_op_resource_rec.resource_sequence_number;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;


            --
            -- Process Flow step 10(b) : Check that user has access to revised
            -- operation
            -- BOM_Validate_Op_Seq.Check_Access

            IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Operation sequence item access'); END IF;
                BOM_Validate_Op_Seq.Check_Access
                (  p_change_notice     => l_rev_op_resource_rec.ECO_Name
                ,  p_organization_id   => l_rev_op_res_unexp_rec.organization_id
                ,  p_revised_item_id   => l_rev_op_res_unexp_rec.revised_item_id
                ,  p_revised_item_name => l_rev_op_resource_rec.revised_item_name
                ,  p_new_item_revision =>
                                l_rev_op_resource_rec.new_revised_item_revision
                ,  p_effectivity_date  =>
                                l_rev_op_resource_rec.op_start_effective_date
                ,  p_new_routing_revsion   => l_rev_op_resource_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_rev_op_resource_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_operation_seq_num =>
                                l_rev_op_resource_rec.operation_sequence_number
                ,  p_routing_sequence_id=>
                                l_rev_op_res_unexp_rec.routing_sequence_id
                ,  p_operation_type    =>
                                l_rev_op_resource_rec.operation_type
                ,  p_entity_processed  => 'RES'
                ,  p_resource_seq_num  =>
                                l_rev_op_resource_rec.resource_sequence_number
                ,  p_sub_resource_code => NULL
                ,  p_sub_group_num     => NULL
                ,  p_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,  x_return_status     => l_Return_Status
                );

               IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RES_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                l_rev_op_resource_rec.resource_sequence_number;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RES_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                               l_rev_op_resource_rec.resource_sequence_number;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

         END IF; -- parent op does not exist

         --
         -- Process Flow step 11 : Check if the parent operation is
         -- non-referencing operation of type: Event
         --
         Bom_Validate_Op_Res.Check_NonRefEvent
            (  p_operation_sequence_id     => l_rev_op_res_unexp_rec.operation_sequence_id
            ,  p_operation_type            => l_rev_op_resource_rec.operation_type
            ,  p_entity_processed          => 'RES'
            ,  x_mesg_token_tbl            => l_mesg_token_tbl
            ,  x_return_status             => l_return_status
            ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Check non-ref operation completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
               IF  l_rev_op_resource_rec.operation_type IN (2,3) -- Process or Line Op
               THEN

                  l_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
                  l_token_tbl(2).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          l_rev_op_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_RES_OPTYPE_NOT_EVENT'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;

               ELSE
                  l_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
                  l_token_tbl(2).token_name := 'OP_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                          l_rev_op_resource_rec.operation_sequence_number ;

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
                                l_rev_op_resource_rec.resource_sequence_number;
               RAISE EXC_FAT_QUIT_SIBLINGS ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
               l_other_message := 'BOM_RES_ACCESS_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;


         --
         -- Process Flow step 11: Value to Id conversions
         -- Call Rtg_Val_To_Id.Rev_Op_Resource_VID
         --
         Bom_Rtg_Val_To_Id.Rev_Op_Resource_VID
         (  p_rev_op_resource_rec        => l_rev_op_resource_rec
         ,  p_rev_op_res_unexp_rec       => l_rev_op_res_unexp_rec
         ,  x_rev_op_res_unexp_rec       => l_rev_op_res_unexp_rec
         ,  x_mesg_token_tbl             => l_mesg_token_tbl
         ,  x_return_status              => l_return_status
         );

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Value-id conversions completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_rev_op_resource_rec.transaction_type = 'CREATE'
            THEN
               l_other_message := 'BOM_RES_VID_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_RES_VID_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <>0
         THEN
            ECO_Error_Handler.Log_Error
            (  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
            ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_RES_LEVEL
            ,  p_entity_index        => I
            ,  x_ECO_rec             => l_ECO_rec
            ,  x_eco_revision_tbl    => l_eco_revision_tbl
            ,  x_revised_item_tbl    => l_revised_item_tbl
            ,  x_rev_component_tbl   => l_rev_component_tbl
            ,  x_ref_designator_tbl  => l_ref_designator_tbl
            ,  x_sub_component_tbl   => l_sub_component_tbl
            ,  x_rev_operation_tbl   => l_rev_operation_tbl
            ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
            ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
            ) ;
         END IF;


         --
         -- Process Flow step 13 : Check required fields exist
         -- (also includes a part of conditionally required fields)
         --

         -- No required fields checking


         --
         -- Process Flow step 14 : Attribute Validation for CREATE and UPDATE
         -- Call Bom_Validate_Op_Res.Check_Attributes
         --
         IF l_rev_op_resource_rec.transaction_type IN
            (Bom_Rtg_Globals.G_OPR_CREATE, Bom_Rtg_Globals.G_OPR_UPDATE)
         THEN
            Bom_Validate_Op_Res.Check_Attributes
            ( p_rev_op_resource_rec   => l_rev_op_resource_rec
            , p_rev_op_res_unexp_rec  => l_rev_op_res_unexp_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

            IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Attribute validation completed with return_status: ' || l_return_status) ;
            END IF ;


            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               IF l_rev_op_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
               THEN
                  l_other_message := 'BOM_RES_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_RES_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl.COUNT <> 0
            THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
               ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_RES_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => l_rev_operation_tbl
               ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ) ;
           END IF;
        END IF;

        --
        -- Process flow step: Query the operation resource  record using by Res Seq Num
        -- Call Bom_Res_Seq_Util.Query_Row
        --

        IF (l_rev_op_resource_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
            AND l_rev_op_resource_rec.acd_type IN ( 2, 3 )) -- ACD Type: Change or Disable
        THEN

            Bom_Op_Res_Util.Query_Row
            ( p_resource_sequence_number  =>  l_rev_op_resource_rec.resource_sequence_number
            , p_operation_sequence_id     =>  l_rev_op_res_unexp_rec.operation_sequence_id
            , p_acd_type                  =>  FND_API.G_MISS_NUM
            , p_mesg_token_tbl            =>  l_mesg_token_tbl
            , x_rev_op_resource_rec       =>  l_old_rev_op_resource_rec
            , x_rev_op_res_unexp_rec      =>  l_old_rev_op_res_unexp_rec
            , x_mesg_token_tbl            =>  l_mesg_token_tbl
            , x_return_status             =>  l_return_status
            ) ;

            IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Query the original op res for rev op res with acd type : change or delete completed with return_status: ' || l_return_status) ;
            END IF ;

            IF l_return_status <> Eng_Globals.G_RECORD_FOUND
            THEN
                  l_return_status := Error_Handler.G_STATUS_ERROR ;
                  l_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
                  l_token_tbl(2).token_name  := 'OP_SEQ_NUMBER';
                  l_token_tbl(2).token_value :=
                           l_rev_op_resource_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                  ( p_message_name       => 'BOM_RES_CREATE_REC_NOT_FOUND'
                  , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                  , p_token_tbl          => l_Token_Tbl
                  , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  );

                  l_other_message := 'BOM_RES_QRY_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
                  RAISE EXC_SEV_SKIP_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                  l_other_message := 'BOM_RES_QRY_UNEXP_SKIP';
                  l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
                  RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

        END IF;


        IF (l_rev_op_resource_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
           AND l_rev_op_resource_rec.acd_type IN ( 2, 3 ) ) -- ACD Type : Change or Disable
        OR
           l_rev_op_resource_rec.transaction_type IN (ENG_GLOBALS.G_OPR_UPDATE ,
                                                      ENG_GLOBALS.G_OPR_DELETE)
        THEN

        --
        -- Process flow step 12: Populate NULL columns for Update and Delete
        -- Call Bom_Default_Op_Res.Populate_Null_Columns
        --

           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns') ;
           END IF ;

           Bom_Default_Op_Res.Populate_Null_Columns
           (   p_rev_op_resource_rec     => l_rev_op_resource_rec
           ,   p_old_rev_op_resource_rec => l_old_rev_op_resource_rec
           ,   p_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
           ,   p_old_rev_op_res_unexp_rec=> l_old_rev_op_res_unexp_rec
           ,   x_rev_op_resource_rec     => l_rev_op_resource_rec
           ,   x_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
           ) ;


        ELSIF l_rev_op_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
        THEN
        --
        -- Process Flow step 13 : Default missing values for Op Resource (CREATE)
        -- Call Bom_Default_Op_Res.Attribute_Defaulting
        --

           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting') ;
           END IF ;

           Bom_Default_Op_res.Attribute_Defaulting
           (   p_rev_op_resource_rec     => l_rev_op_resource_rec
           ,   p_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
           ,   p_control_rec             => Bom_Rtg_Pub.G_Default_Control_Rec
           ,   x_rev_op_resource_rec     => l_rev_op_resource_rec
           ,   x_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
           ,   x_mesg_token_tbl          => l_mesg_token_tbl
           ,   x_return_status           => l_return_status
           ) ;


           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
              l_other_message := 'BOM_RES_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'BOM_RES_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
               ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_RES_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => l_rev_operation_tbl
               ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ) ;
          END IF;
       END IF;

       --
       -- Process Flow step 17: Conditionally Required Attributes
       --
       --
       -- No Conditionally Required Attributes


       --
       -- Process Flow step 18: Entity defaulting for CREATE and UPDATE
       --
       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting') ;
       END IF ;
       IF l_rev_op_resource_rec.transaction_type IN ( Bom_Rtg_Globals.G_OPR_CREATE
                                                , Bom_Rtg_Globals.G_OPR_UPDATE )
       THEN
          Bom_Default_Op_res.Entity_Defaulting
              (   p_rev_op_resource_rec   => l_rev_op_resource_rec
              ,   p_rev_op_res_unexp_rec  => l_rev_op_res_unexp_rec
              ,   p_control_rec           => Bom_Rtg_Pub.G_Default_Control_Rec
              ,   x_rev_op_resource_rec   => l_rev_op_resource_rec
              ,   x_rev_op_res_unexp_rec  => l_rev_op_res_unexp_rec
              ,   x_mesg_token_tbl        => l_mesg_token_tbl
              ,   x_return_status         => l_return_status
              ) ;

          IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Entity defaulting completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_rev_op_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_RES_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.operation_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_RES_ENTDEF_UNEXP_SKIP';
             l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             ECO_Error_Handler.Log_Error
             (  p_rev_op_resource_tbl         => x_rev_op_resource_tbl
             ,  p_rev_sub_resource_tbl        => x_rev_sub_resource_tbl
             ,  p_mesg_token_tbl          => l_mesg_token_tbl
             ,  p_error_status            => 'W'
             ,  p_error_level             => Error_Handler.G_RES_LEVEL
             ,  p_entity_index            => I
             ,  x_ECO_rec                 => l_ECO_rec
             ,  x_eco_revision_tbl        => l_eco_revision_tbl
             ,  x_revised_item_tbl        => l_revised_item_tbl
             ,  x_rev_component_tbl       => l_rev_component_tbl
             ,  x_ref_designator_tbl      => l_ref_designator_tbl
             ,  x_sub_component_tbl       => l_sub_component_tbl
             ,  x_rev_operation_tbl       => l_rev_operation_tbl
             ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
             ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
             ) ;
          END IF ;
       END IF ;

       --
       -- Process Flow step 16 - Entity Level Validation
       -- Call Bom_Validate_Op_Res.Check_Entity
       --
       IF Bom_Rtg_Globals.Get_Debug = 'Y'
       THEN Error_Handler.Write_Debug('Starting with Op Resources entity validation . . . ') ;
       END IF ;

          Bom_Validate_Op_Res.Check_Entity
          (  p_rev_op_resource_rec       => l_rev_op_resource_rec
          ,  p_rev_op_res_unexp_rec      => l_rev_op_res_unexp_rec
          ,  p_old_rev_op_resource_rec   => l_old_rev_op_resource_rec
          ,  p_old_rev_op_res_unexp_rec  => l_old_rev_op_res_unexp_rec
          ,  p_control_rec               => Bom_Rtg_Pub.G_Default_Control_Rec
          ,  x_rev_op_resource_rec       => l_rev_op_resource_rec
          ,  x_rev_op_res_unexp_rec      => l_rev_op_res_unexp_rec
          ,  x_mesg_token_tbl            => l_mesg_token_tbl
          ,  x_return_status             => l_return_status
          ) ;


       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          IF l_rev_op_resource_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
          THEN
             l_other_message := 'BOM_RES_ENTVAL_CSEV_SKIP';
             l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                           l_rev_op_resource_rec.resource_sequence_number ;
             RAISE EXC_SEV_SKIP_BRANCH ;
          ELSE
             RAISE EXC_SEV_QUIT_RECORD ;
          END IF;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_RES_ENTVAL_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                        l_rev_op_resource_rec.resource_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
       THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_op_resource_tbl  => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl       => l_mesg_token_tbl
          ,  p_error_status         => 'W'
          ,  p_error_level          => Error_Handler.G_RES_LEVEL
          ,  p_entity_index         => I
          ,  x_ECO_rec              => l_ECO_rec
          ,  x_eco_revision_tbl     => l_eco_revision_tbl
          ,  x_revised_item_tbl     => l_revised_item_tbl
          ,  x_rev_component_tbl    => l_rev_component_tbl
          ,  x_ref_designator_tbl   => l_ref_designator_tbl
          ,  x_sub_component_tbl    => l_sub_component_tbl
          ,  x_rev_operation_tbl    => l_rev_operation_tbl
          ,  x_rev_op_resource_tbl  => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl => x_rev_sub_resource_tbl
          ) ;
       END IF;

       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation completed with '
             || l_return_Status || ' proceeding for database writes . . . ') ;
       END IF;

       --
       -- Process Flow step 16 : Database Writes
       --
       Bom_Op_Res_Util.Perform_Writes
          (   p_rev_op_resource_rec     => l_rev_op_resource_rec
          ,   p_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
          ,   p_control_rec             => Bom_Rtg_Pub.G_Default_Control_Rec
          ,   x_mesg_token_tbl          => l_mesg_token_tbl
          ,   x_return_status           => l_return_status
          ) ;

       IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_RES_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                          l_rev_op_resource_rec.resource_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl .COUNT <>0
       THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => 'W'
          ,  p_error_level         => Error_Handler.G_RES_LEVEL
          ,  p_entity_index        => I
          ,  x_ECO_rec             => l_ECO_rec
          ,  x_eco_revision_tbl    => l_eco_revision_tbl
          ,  x_revised_item_tbl    => l_revised_item_tbl
          ,  x_rev_component_tbl   => l_rev_component_tbl
          ,  x_ref_designator_tbl  => l_ref_designator_tbl
          ,  x_sub_component_tbl   => l_sub_component_tbl
          ,  x_rev_operation_tbl   => l_rev_operation_tbl
          ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ) ;
       END IF;

       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Database writes completed with status:  ' || l_return_status);
       END IF;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    x_rev_op_resource_tbl(I)  := l_rev_op_resource_rec;


    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => FND_API.G_RET_STS_ERROR
          ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level         => Error_Handler.G_RES_LEVEL
          ,  p_entity_index        => I
          ,  x_ECO_rec             => l_ECO_rec
          ,  x_eco_revision_tbl    => l_eco_revision_tbl
          ,  x_revised_item_tbl    => l_revised_item_tbl
          ,  x_rev_component_tbl   => l_rev_component_tbl
          ,  x_ref_designator_tbl  => l_ref_designator_tbl
          ,  x_sub_component_tbl   => l_sub_component_tbl
          ,  x_rev_operation_tbl   => l_rev_operation_tbl
          ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status := l_return_status ;
         END IF;

         x_return_status           := l_bo_return_status;
         x_mesg_token_tbl          := l_mesg_token_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
      --   x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_SEV_QUIT_BRANCH THEN

         ECO_Error_Handler.Log_Error
         (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;


         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status  := l_return_status;
         END IF;

         x_return_status        := l_bo_return_status;
         x_mesg_token_tbl       := l_mesg_token_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl := l_rev_sub_resource_tbl ;

      WHEN EXC_SEV_SKIP_BRANCH THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

        IF l_bo_return_status = 'S'
        THEN
           l_bo_return_status     := l_return_status ;
        END IF;
        x_return_status           := l_bo_return_status;
        x_mesg_token_tbl          := l_mesg_token_tbl ;
        --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
        --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

     WHEN EXC_SEV_QUIT_SIBLINGS THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_ERROR
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_ERROR
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         IF l_bo_return_status = 'S'
         THEN
           l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status       := l_bo_return_status;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl := l_rev_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_BRANCH THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         x_return_status       := Error_Handler.G_STATUS_FATAL;
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_SIBLINGS
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

        x_return_status       := Error_Handler.G_STATUS_FATAL;
        x_mesg_token_tbl      := l_mesg_token_tbl ;
        --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
        --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

    WHEN EXC_FAT_QUIT_OBJECT THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  p_rev_sub_resource_tbl => x_rev_sub_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_FATAL
         ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
         ,  p_other_status        => Error_Handler.G_STATUS_FATAL
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  p_entity_index        => I
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         l_return_status       := 'Q';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
         ECO_Error_Handler.Log_Error
         (  p_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  p_mesg_token_tbl      => l_mesg_token_tbl
         ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
         ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
         ,  p_other_message       => l_other_message
         ,  p_other_token_tbl     => l_other_token_tbl
         ,  p_error_level         => Error_Handler.G_RES_LEVEL
         ,  x_ECO_rec             => l_ECO_rec
         ,  x_eco_revision_tbl    => l_eco_revision_tbl
         ,  x_revised_item_tbl    => l_revised_item_tbl
         ,  x_rev_component_tbl   => l_rev_component_tbl
         ,  x_ref_designator_tbl  => l_ref_designator_tbl
         ,  x_sub_component_tbl   => l_sub_component_tbl
         ,  x_rev_operation_tbl   => l_rev_operation_tbl
         ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
         ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
         ) ;

         l_return_status       := 'U';
         x_mesg_token_tbl      := l_mesg_token_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;

   END IF; -- End of processing records for which the return status is null
   END LOOP; -- END Operation Resources processing loop

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status    := l_return_status;
   END IF;

   x_mesg_token_tbl          := l_mesg_token_tbl ;
   --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
   --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;
   x_mesg_token_tbl          := l_mesg_token_tbl ;

END Rev_Operation_Resources ;


PROCEDURE Rev_Operation_Sequences
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER   := NULL
,   p_revised_item_name             IN  VARCHAR2 := NULL
,   p_effectivity_date              IN  DATE     := NULL
,   p_item_revision                 IN  VARCHAR2 := NULL
,   p_routing_revision              IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number          IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_alternate_routing_code        IN  VARCHAR2 := NULL -- Added for bug 13329115
,   p_rev_operation_tbl             IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type
,   p_rev_op_resource_tbl           IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
,   p_rev_sub_resource_tbl          IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type
,   x_rev_op_resource_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
,   x_rev_sub_resource_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
,   x_mesg_token_tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
)

IS

/* Exposed and Unexposed record */
l_rev_operation_rec         Bom_Rtg_Pub.Rev_Operation_Rec_Type ;
--l_rev_operation_tbl         Bom_Rtg_Pub.Rev_Operation_Tbl_Type ;
l_rev_op_unexp_rec          Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type ;
l_old_rev_operation_rec     Bom_Rtg_Pub.Rev_Operation_Rec_Type ;
l_old_rev_op_unexp_rec      Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type ;

/* Other Entities */
l_eco_rec                ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl       ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_tbl       ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_rec      BOM_BO_PUB.Rev_Component_Rec_Type;
l_rev_component_tbl      BOM_BO_PUB.Rev_Component_Tbl_Type;
l_rev_comp_unexp_rec     BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_old_rev_component_rec  BOM_BO_PUB.Rev_Component_Rec_Type;
l_old_rev_comp_unexp_rec BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_ref_designator_tbl     BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl      BOM_BO_PUB.Sub_Component_Tbl_Type;
--l_rev_op_resource_tbl    Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type   := p_rev_op_resource_tbl ;
--l_rev_sub_resource_tbl   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type  := p_rev_sub_resource_tbl ;

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_process_children      BOOLEAN := TRUE ;
l_item_parent_exists    BOOLEAN := FALSE ;
l_valid                 BOOLEAN := TRUE ;
l_dummy                 NUMBER ;

/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

EXC_SEV_QUIT_RECORD     EXCEPTION ;
EXC_SEV_QUIT_BRANCH     EXCEPTION ;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION ;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION ;
EXC_SEV_SKIP_BRANCH     EXCEPTION ;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION ;
EXC_FAT_QUIT_BRANCH     EXCEPTION ;
EXC_FAT_QUIT_OBJECT     EXCEPTION ;

BEGIN

   --  Init local table variables.
   l_return_status        := FND_API.G_RET_STS_SUCCESS ;
   l_bo_return_status     := FND_API.G_RET_STS_SUCCESS ;
   x_return_status        := FND_API.G_RET_STS_SUCCESS;  -- Bug 7606951
   x_rev_operation_tbl    := p_rev_operation_tbl ;
   x_rev_op_resource_tbl  := p_rev_op_resource_tbl ;
   x_rev_sub_resource_tbl := p_rev_sub_resource_tbl ;

   l_rev_op_unexp_rec.organization_id := Eng_Globals.Get_Org_Id;


   FOR I IN 1..x_rev_operation_tbl.COUNT LOOP

   IF (x_rev_operation_tbl(I).return_status IS NULL OR
        x_rev_operation_tbl(I).return_status = FND_API.G_MISS_CHAR) THEN

   BEGIN

       --  Load local records.
       l_rev_operation_rec := x_rev_operation_tbl(I);

       l_rev_operation_rec.transaction_type :=
       UPPER(l_rev_operation_rec.transaction_type);

       /* make sure to set process_children to false at the start of
          every iteration */

       l_process_children := FALSE;    /* Bug 6485168 */

        --
        -- Initialize the Unexposed Record for every iteration of the Loop
        -- so that sequence numbers get generated for every new row.
        --
        l_rev_op_unexp_rec.Revised_Item_Sequence_Id    := NULL ;
        l_rev_op_unexp_rec.Operation_Sequence_Id       := NULL ;
        l_rev_op_unexp_rec.Old_Operation_Sequence_Id   := NULL ;
        l_rev_op_unexp_rec.Routing_Sequence_Id         := NULL ;
        l_rev_op_unexp_rec.Revised_Item_Id             := NULL ;
        l_rev_op_unexp_rec.Department_Id               := NULL ;
        l_rev_op_unexp_rec.Standard_Operation_Id       := NULL ;

        IF p_revised_item_name IS NOT NULL AND
           p_effectivity_date  IS NOT NULL AND
           p_change_notice     IS NOT NULL AND
           p_organization_id   IS NOT NULL
        THEN
                -- revised item parent exists
                l_item_parent_exists := TRUE;
        END IF;


        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

          IF --(l_rev_operation_rec.return_status IS NULL OR
            --l_rev_operation_rec.return_status = FND_API.G_MISS_CHAR)
           --AND

            -- Did Rev_Items call this procedure, that is,
            -- if revised item exists, then is this record a child ?

            (NOT l_item_parent_exists
             OR
             (l_item_parent_exists AND
              (l_rev_operation_rec.ECO_Name = p_change_notice AND
               l_rev_op_unexp_rec.organization_id = p_organization_id AND
               l_rev_operation_rec.revised_item_name = p_revised_item_name AND
               NVL(l_rev_operation_rec.alternate_routing_code, FND_API.G_MISS_CHAR )
                                             = NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR ) AND    -- Added for bug 13329115
               l_rev_operation_rec.start_effective_date = nvl(ENG_Default_Revised_Item.G_OLD_SCHED_DATE,p_effectivity_date) AND -- Bug 6657209
               NVL(l_rev_operation_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision, FND_API.G_MISS_CHAR )     AND -- Added by MK on 11/02/00
               NVL(l_rev_operation_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
               NVL(l_rev_operation_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             = NVL(p_item_revision, FND_API.G_MISS_CHAR) ))
            )
        THEN

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_rev_operation_rec.return_status := FND_API.G_RET_STS_SUCCESS;

         -- Bug 6657209
           IF (l_item_parent_exists and ENG_Default_Revised_Item.G_OLD_SCHED_DATE is not null) THEN
              l_rev_operation_rec.start_effective_date := p_effectivity_date;
           END IF;

         --
         -- Process Flow step 3 :Check if transaction_type is valid
         -- Transaction_Type must be CRATE, UPDATE, DELETE or CANCEL
         -- Call the Bom_Rtg_Globals.Transaction_Type_Validity
         --

         ENG_GLOBALS.Transaction_Type_Validity
         (   p_transaction_type => l_rev_operation_rec.transaction_type
         ,   p_entity           => 'Op_Seq'
         ,   p_entity_id        => l_rev_operation_rec.operation_sequence_number
         ,   x_valid            => l_valid
         ,   x_mesg_token_tbl   => l_mesg_token_tbl
         ) ;

         IF NOT l_valid
         THEN
            RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         --
         -- Process Flow step 4(a): Convert user unique index to unique
         -- index I
         -- Call Rtg_Val_To_Id.Operation_UUI_To_UI Shared Utility Package
         --
         Bom_Rtg_Val_To_Id.Rev_Operation_UUI_To_UI
         ( p_rev_operation_rec  => l_rev_operation_rec
         , p_rev_op_unexp_rec   => l_rev_op_unexp_rec
         , x_rev_op_unexp_rec   => l_rev_op_unexp_rec
         , x_mesg_token_tbl     => l_mesg_token_tbl
         , x_return_status      => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_OP_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;


         -- Added by MK on 12/03/00 to resolve ECO dependency
         ENG_Val_To_Id.RtgAndRevitem_UUI_To_UI
           ( p_revised_item_name        => l_rev_operation_rec.revised_item_name
           , p_revised_item_id          => l_rev_op_unexp_rec.revised_item_id
           , p_item_revision            => l_rev_operation_rec.new_revised_item_revision
           , p_effective_date           => l_rev_operation_rec.start_effective_date
           , p_change_notice            => l_rev_operation_rec.eco_name
           , p_organization_id          => l_rev_op_unexp_rec.organization_id
           , p_new_routing_revision     => l_rev_operation_rec.new_routing_revision
           , p_from_end_item_number     => l_rev_operation_rec.from_end_item_unit_number
           , p_entity_processed         => 'ROP'
           , p_operation_sequence_number => l_rev_operation_rec.operation_sequence_number
           , p_alternate_routing_code    => l_rev_operation_rec.alternate_routing_code    -- Added for bug 13329115
           , x_revised_item_sequence_id  => l_rev_op_unexp_rec.revised_item_sequence_id
           , x_routing_sequence_id       => l_rev_op_unexp_rec.routing_sequence_id
           , x_operation_sequence_id    => l_dummy
           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
           , x_other_message            => l_other_message
           , x_other_token_tbl          => l_other_token_tbl
           , x_Return_Status            => l_return_status
          ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index1 for Rtg and Rev Item Seq completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_OP_UUI_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_SEV_QUIT_BRANCH ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                        l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;


         --
         -- Process Flow step 4(b): Convert user unique index to unique
         -- index II
         -- Call the Rtg_Val_To_Id.Operation_UUI_To_UI2
         --
         /*
         Bom_Rtg_Val_To_Id.Rev_Operation_UUI_To_UI2
         ( p_rev_operation_rec  => l_rev_operation_rec
         , p_rev_op_unexp_rec   => l_rev_op_unexp_rec
         , x_rev_op_unexp_rec   => l_rev_op_unexp_rec
         , x_mesg_token_tbl     => l_mesg_token_tbl
         , x_other_message      => l_other_message
         , x_other_token_tbl    => l_other_token_tbl
         , x_return_status      => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Convert to User Unique Index to Index2 completed with return_status: ' || l_return_status) ;
         END IF;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            RAISE EXC_SEV_QUIT_SIBLINGS ;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_UUI_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                   l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF ;
         */

         -- Set Unit Controlled Item
         Bom_Rtg_Globals.Set_Unit_Controlled_Item
           ( p_inventory_item_id => l_rev_comp_unexp_rec.revised_item_id
           , p_organization_id   => l_rev_comp_unexp_rec.organization_id
           );

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Set unit controlled item flag . . .' ) ;
         END IF ;

         --
         -- Process Flow step 5 : Check the parent revised item is controlled
         -- by model unit effectivity
         --
         --
         IF Bom_Rtg_Globals.Get_Unit_Controlled_Item THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
             l_token_tbl(1).token_value := l_rev_operation_rec.operation_sequence_number ;
             l_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
             l_token_tbl(2).token_value := l_rev_operation_rec.revised_item_name ;

             Error_Handler.Add_Error_Token
             ( p_Message_Name   => 'BOM_OP_ECO_MDLUNITEFFECT'
             , p_mesg_token_tbl => l_mesg_token_tbl
             , x_mesg_token_tbl => l_mesg_token_tbl
             , p_Token_Tbl      => l_token_tbl
             ) ;

             l_return_status := 'F';
             RAISE EXC_FAT_QUIT_SIBLINGS ; -- RAISE EXC_FAT_QUIT_BRANCH
         END IF;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check if the parent item is unit controlled item with return_status: ' || l_return_status) ;
         END IF ;

         --
         -- Process Flow step 6: Verify Operation Sequence's existence
         -- Call the Bom_Validate_Op_Seq.Check_Existence
         --
         --
         Bom_Validate_Op_Seq.Check_Existence
         (  p_rev_operation_rec          => l_rev_operation_rec
         ,  p_rev_op_unexp_rec           => l_rev_op_unexp_rec
         ,  x_old_rev_operation_rec      => l_old_rev_operation_rec
         ,  x_old_rev_op_unexp_rec       => l_old_rev_op_unexp_rec
         ,  x_mesg_token_tbl             => l_mesg_token_tbl
         ,  x_return_status              => l_return_status
         ) ;


         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check Existence completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            l_other_message := 'BOM_OP_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
            l_other_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_rev_operation_rec.revised_item_name ;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
            l_other_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
            l_other_token_tbl(2).token_value :=
                          l_rev_operation_rec.revised_item_name ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

         --
         -- Process Flow step 7: Check lineage
         --
         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage'); END IF;
         IF l_rev_operation_rec.transaction_type IN
            (Bom_Rtg_Globals.G_OPR_UPDATE, Bom_Rtg_Globals.G_OPR_DELETE,
            Bom_Rtg_Globals.G_OPR_CANCEL)
         THEN

             BOM_Validate_Op_Seq.Check_Lineage
             ( p_routing_sequence_id       =>
                                   l_rev_op_unexp_rec.routing_sequence_id
             , p_operation_sequence_number =>
                                   l_rev_operation_rec.operation_sequence_number
             , p_effectivity_date          =>
                                   l_rev_operation_rec.start_effective_date
             , p_operation_type            =>
                                   l_rev_operation_rec.operation_type
             , p_revised_item_sequence_id  =>
                                   l_rev_op_unexp_rec.revised_item_sequence_id
             , x_mesg_token_tbl            => l_mesg_token_tbl
             , x_return_status             => l_return_status
             ) ;

             IF l_return_status = Error_Handler.G_STATUS_ERROR
             THEN

                  l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
                  l_Token_Tbl(1).token_value :=
                               l_rev_operation_rec.operation_sequence_number ;
                  l_Token_Tbl(2).token_name  := 'REVISED_ITEM_NAME';
                  l_Token_Tbl(2).token_value :=
                               l_rev_operation_rec.revised_item_name ;
                  l_token_tbl(3).token_name  := 'ECO_NAME' ;
                  l_token_tbl(3).token_value := l_rev_operation_rec.eco_name ;

                  Error_Handler.Add_Error_Token
                  ( p_Message_Name   => 'BOM_OP_REV_ITEM_MISMATCH'
                  , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , x_mesg_token_tbl => l_Mesg_Token_Tbl
                  , p_Token_Tbl      => l_Token_Tbl
                  ) ;

                  l_other_message := 'BOM_OP_LIN_SEV_SKIP';
                  l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                              l_rev_operation_rec.operation_sequence_number ;
                  RAISE EXC_SEV_QUIT_BRANCH;

             ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
             THEN
                  l_other_message := 'BOM_OP_LIN_UNEXP_SKIP';
                  l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                              l_rev_operation_rec.operation_sequence_number ;
                  RAISE EXC_UNEXP_SKIP_OBJECT;
             END IF;
         END IF ;

         --
         -- Process Flow step 8: Is Operation Sequence record an orphan ?
         --

         IF NOT l_item_parent_exists
         THEN


                --
                -- Process Flow step 9(a and b): Is ECO impl/cancl, or in wkflw process ?
                --
              IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('ECO Check access'); END IF;
                ENG_Validate_ECO.Check_Access
                ( p_change_notice       => l_rev_operation_rec.ECO_Name
                , p_organization_id     => l_rev_op_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_OP_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                        l_rev_operation_rec.operation_sequence_number ;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_OP_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                        l_rev_operation_rec.operation_sequence_number ;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;


                -- Process Flow step 10(a and b): check that user has access to revised item
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item Check access'); END IF;
                ENG_Validate_Revised_Item.Check_Access
                (  p_change_notice      => l_rev_operation_rec.ECO_Name
                ,  p_organization_id    => l_rev_op_unexp_rec.organization_id
                ,  p_revised_item_id    => l_rev_op_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_rev_operation_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_rev_operation_rec.start_effective_date
                ,  p_new_routing_revsion   => l_rev_operation_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_rev_operation_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_rev_operation_rec.revised_item_name
                ,  p_entity_processed   => 'ROP'  -- Added by MK on 12/03 to resolve Eco dependency
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_OP_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                        l_rev_operation_rec.operation_sequence_number;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_OP_RITACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                                        l_rev_operation_rec.operation_sequence_number ;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                --
                -- Process Flow step  : Check Assembly Item Operability for Operation
                -- BOM_Validate_Op_Seq.Check_Access
                --
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Operation Check access'); END IF;
                BOM_Validate_Op_Seq.Check_Access
                (  p_change_notice     => l_rev_operation_rec.ECO_Name
                ,  p_organization_id   => l_rev_op_unexp_rec.organization_id
                ,  p_revised_item_id   => l_rev_op_unexp_rec.revised_item_id
                ,  p_revised_item_name => l_rev_operation_rec.revised_item_name
                ,  p_new_item_revision =>
                                  l_rev_operation_rec.new_revised_item_revision
                ,  p_effectivity_date  =>
                                  l_rev_operation_rec.start_effective_date
                ,  p_new_routing_revsion   => l_rev_operation_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_rev_operation_rec.from_end_item_unit_number -- Added by MK on 11/02/00

                ,  p_operation_seq_num  =>
                                  l_rev_operation_rec.operation_sequence_number
                ,  p_routing_sequence_id =>
                                  l_rev_op_unexp_rec.routing_sequence_id
                ,  p_operation_type   =>
                                  l_rev_operation_rec.operation_type
                ,  p_entity_processed => 'OP'
                ,  p_resource_seq_num  => NULL
                ,  p_sub_resource_code => NULL
                ,  p_sub_group_num     => NULL
                ,  p_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,  x_return_status     => l_Return_Status
                );

               IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('In check access of operations, return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'BOM_OP_ACCESS_FAT_FATAL';
                   l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                   l_other_token_tbl(1).token_value :=
                         l_rev_operation_rec.operation_sequence_number ;
                   l_return_status := 'F' ;
                   RAISE EXC_FAT_QUIT_SIBLINGS ; -- Check EXC_FAT_QUIT_OBJECT
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                        THEN
                        l_other_message := 'BOM_OP_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                              l_rev_operation_rec.operation_sequence_number ;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;


                --
                -- Process Flow step 11 : Check the routing does not have a common
                --

                Bom_Validate_Op_Seq.Check_CommonRtg
                (  p_routing_sequence_id  =>
                                        l_rev_op_unexp_rec.routing_sequence_id
                ,  x_mesg_token_tbl       => l_mesg_token_tbl
                ,  x_return_status        => l_return_status
                ) ;

                IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                ('Check the routing non-referenced common completed with return_status: ' || l_return_status) ;
                END IF ;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        l_token_tbl(1).token_value :=
                                l_rev_operation_rec.operation_sequence_number ;
                        l_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                l_rev_operation_rec.revised_item_name ;
                        Error_Handler.Add_Error_Token
                        ( p_Message_Name   => 'BOM_OP_RTG_HAVECOMMON'
                        , p_mesg_token_tbl => l_mesg_token_tbl
                        , x_mesg_token_tbl => l_mesg_token_tbl
                        , p_Token_Tbl      => l_token_tbl
                        ) ;

                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS ; -- RAISE EXC_FAT_QUIT_BRANCH ;

                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_OP_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                        l_other_token_tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

         END IF ;  -- End of process for an orphan


         /* In future release If ECO for Flow Routing is supported,
            this step should be implemented.

         -- Process Flow Step  : Check parent CFM Routing Flag
         -- Validate Non-Operated Columns using CFM Routing Flag
         -- Standard Routing, Flow Routing, Lot Based Routing.
         -- If a non-operated column is not null, the procedure set it to null
         -- and occur Warning.
         --
         BOM_Validate_Op_Seq.Check_NonOperated_Attribute
         ( p_rev_operation_rec    => l_rev_operation_rec
         , p_rev_op_unexp_rec     => l_rev_op_unexp_rec
         , x_rev_operation_rec    => l_rev_operation_rec
         , x_rev_op_unexp_rec     => l_rev_op_unexp_rec
         , x_mesg_token_tbl       => l_mesg_token_tbl
         , x_return_status        => l_return_status
         ) ;

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check non-operating columns completed with return_status: ' || l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_NOPATTR_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <>0
         THEN
            ECO_Error_Handler.Log_Error
            (  p_rev_operation_tbl   => l_rev_operation_tbl
            ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl
            ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_OP_LEVEL
            ,  p_entity_index        => I
            ,  x_ECO_rec             => l_ECO_rec
            ,  x_eco_revision_tbl    => l_eco_revision_tbl
            ,  x_revised_item_tbl    => l_revised_item_tbl
            ,  x_rev_component_tbl   => l_rev_component_tbl
            ,  x_ref_designator_tbl  => l_ref_designator_tbl
            ,  x_sub_component_tbl   => l_sub_component_tbl
            ,  x_rev_operation_tbl   => l_rev_operation_tbl
            ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
            ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl
            ) ;
         END IF;
         */


         --
         -- Process Flow step 12: Value to Id conversions
         -- Call Rtg_Val_To_Id.Operation_VID
         --
         Bom_Rtg_Val_To_Id.Rev_Operation_VID
         (  p_rev_operation_rec          => l_rev_operation_rec
         ,  p_rev_op_unexp_rec           => l_rev_op_unexp_rec
         ,  x_rev_op_unexp_rec           => l_rev_op_unexp_rec
         ,  x_mesg_token_tbl             => l_mesg_token_tbl
         ,  x_return_status              => l_return_status
         );

         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Value-id conversions completed with return_status: ' ||
                                               l_return_status) ;
         END IF ;

         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_rev_operation_rec.transaction_type = 'CREATE'
            THEN
               l_other_message := 'BOM_OP_VID_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF ;

         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_VID_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT;

         ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <>0
         THEN
            ECO_Error_Handler.Log_Error
            (  p_rev_operation_tbl       => x_rev_operation_tbl
            ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
            ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
            ,  p_mesg_token_tbl      => l_mesg_token_tbl
            ,  p_error_status        => 'W'
            ,  p_error_level         => Error_Handler.G_OP_LEVEL
            ,  p_entity_index        => I
            ,  x_ECO_rec             => l_ECO_rec
            ,  x_eco_revision_tbl    => l_eco_revision_tbl
            ,  x_revised_item_tbl    => l_revised_item_tbl
            ,  x_rev_component_tbl   => l_rev_component_tbl
            ,  x_ref_designator_tbl  => l_ref_designator_tbl
            ,  x_sub_component_tbl   => l_sub_component_tbl
            ,  x_rev_operation_tbl   => x_rev_operation_tbl
            ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
            ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
            ) ;
         END IF;

         --
         -- Process Flow step 13 : Check required fields exist
         -- (also includes a part of conditionally required fields)
         --

         Bom_Validate_Op_Seq.Check_Required
         ( p_rev_operation_rec          => l_rev_operation_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;


         IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Check required completed with return_status: ' || l_return_status) ;
         END IF ;


         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            IF l_rev_operation_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
            THEN
               l_other_message := 'BOM_OP_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'BOM_OP_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


         --
         -- Process Flow step 14 : Attribute Validation for CREATE and UPDATE
         --
         --
         IF l_rev_operation_rec.transaction_type IN
            (Bom_Rtg_Globals.G_OPR_CREATE, Bom_Rtg_Globals.G_OPR_UPDATE)
         THEN
            Bom_Validate_Op_Seq.Check_Attributes
            ( p_rev_operation_rec => l_rev_operation_rec
            , p_rev_op_unexp_rec  => l_rev_op_unexp_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

            IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Attribute validation completed with return_status: ' || l_return_status) ;
            END IF ;

            IF l_return_status = Error_Handler.G_STATUS_ERROR
            THEN
               IF l_rev_operation_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
               THEN
                  l_other_message := 'BOM_OP_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'BOM_OP_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_operation_tbl   => x_rev_operation_tbl
               ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_OP_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => x_rev_operation_tbl
               ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ) ;
           END IF;
        END IF;

        --
        -- Process flow step: Query the operation record using by Old Op Seq Num
        -- and Old Effectivity Date Call Bom_Op_Seq_Util.Query_Row
        --

        IF (l_rev_operation_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
            AND l_rev_operation_rec.acd_type IN (2 ,3)    ) -- ACD Type: Change or Disable
        THEN

            IF l_rev_operation_rec.old_operation_sequence_number IS NULL OR
               l_rev_operation_rec.old_operation_sequence_number = FND_API.G_MISS_NUM
            THEN
               l_rev_operation_rec.old_operation_sequence_number
                   := l_rev_operation_rec.operation_sequence_number ;
            END IF ;

            Bom_Op_Seq_Util.Query_Row
            ( p_operation_sequence_number =>
                              l_rev_operation_rec.old_operation_sequence_number
            , p_effectivity_date          =>
                              l_rev_operation_rec.old_start_effective_date
            , p_routing_sequence_id       =>
                              l_rev_op_unexp_rec.routing_sequence_id
            , p_operation_type            => l_rev_operation_rec.operation_type
            , p_mesg_token_tbl            => l_mesg_token_tbl
            , x_rev_operation_rec         => l_old_rev_operation_rec
            , x_rev_op_unexp_rec          => l_old_rev_op_unexp_rec
            , x_mesg_token_tbl            => l_mesg_token_tbl
            , x_return_status             => l_return_status
            ) ;

            IF l_return_status <> Eng_Globals.G_RECORD_FOUND
            THEN
                  l_return_status := Error_Handler.G_STATUS_ERROR ;
                  l_Token_Tbl(1).token_name := 'OP_SEQ_NUMBER';
                  l_Token_Tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;

                  Error_Handler.Add_Error_Token
                  ( p_message_name       => 'BOM_OP_CREATE_REC_NOT_FOUND'
                  , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                  , p_token_tbl          => l_Token_Tbl
                  , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  );

                  l_other_message := 'BOM_OP_QRY_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;
                  RAISE EXC_SEV_SKIP_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                    l_other_message := 'BOM_OP_QRY_UNEXP_SKIP';
                    l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                    l_other_token_tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;
        END IF;


        IF (l_rev_operation_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
           AND l_rev_operation_rec.acd_type IN ( 2,3 ) ) -- ACD Type : Change or Disable
        OR
           l_rev_operation_rec.transaction_type IN (ENG_GLOBALS.G_OPR_UPDATE ,
                                                    ENG_GLOBALS.G_OPR_DELETE ,
                                                    ENG_GLOBALS.G_OPR_CANCEL)
        THEN

        --
        -- Process flow step 15: Populate NULL columns for Update and Delete
        -- and Creates with ACD_Type 'Add'.
        -- Call Bom_Default_Op_Seq.Populate_Null_Columns
        --

           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns') ;
           END IF ;


           Bom_Default_Op_Seq.Populate_Null_Columns
           (   p_rev_operation_rec     => l_rev_operation_rec
           ,   p_old_rev_operation_Rec => l_old_rev_operation_rec
           ,   p_rev_op_unexp_rec      => l_rev_op_unexp_rec
           ,   p_old_rev_op_unexp_rec  => l_old_rev_op_unexp_rec
           ,   x_rev_operation_rec     => l_rev_operation_rec
           ,   x_rev_op_unexp_rec      => l_rev_op_unexp_rec
           ) ;


        ELSIF l_rev_operation_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
              AND l_rev_operation_rec.acd_type <> 2  -- ACD Type : Not Change
        THEN
        --
        -- Process Flow step 16 : Default missing values for Operation (CREATE)
        -- (also includes Entity Defaulting)
        -- Call Bom_Default_Op_Seq.Attribute_Defaulting
        --

           Bom_Default_Op_Seq.Attribute_Defaulting
           (   p_rev_operation_rec   => l_rev_operation_rec
           ,   p_rev_op_unexp_rec    => l_rev_op_unexp_rec
           ,   p_control_rec         => Bom_Rtg_Pub.G_Default_Control_Rec
           ,   x_rev_operation_rec   => l_rev_operation_rec
           ,   x_rev_op_unexp_rec    => l_rev_op_unexp_rec
           ,   x_mesg_token_tbl      => l_mesg_token_tbl
           ,   x_return_status       => l_return_status
           ) ;

           IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
              l_other_message := 'BOM_OP_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'BOM_OP_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_operation_tbl   => x_rev_operation_tbl
               ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_OP_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => x_rev_operation_tbl
               ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
              ) ;
          END IF;
       END IF;


       --
       -- Process Flow step 17: Conditionally Required Attributes
       --
       --
       IF l_rev_operation_rec.transaction_type IN ( Bom_Rtg_Globals.G_OPR_CREATE
                                                  , Bom_Rtg_Globals.G_OPR_UPDATE )
       THEN
          Bom_Validate_Op_Seq.Check_Conditionally_Required
          ( p_rev_operation_rec          => l_rev_operation_rec
          , p_rev_op_unexp_rec           => l_rev_op_unexp_rec
          , x_return_status              => l_return_status
          , x_mesg_token_tbl             => l_mesg_token_tbl
          ) ;

          IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check Conditionally Required Attr. completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_rev_operation_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_OP_CONREQ_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_OP_CONREQ_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             ECO_Error_Handler.Log_Error
             (  p_rev_operation_tbl   => x_rev_operation_tbl
             ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl
             ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
             ,  p_mesg_token_tbl      => l_mesg_token_tbl
             ,  p_error_status        => 'W'
             ,  p_error_level         => Error_Handler.G_OP_LEVEL
             ,  p_entity_index        => I
             ,  x_ECO_rec             => l_ECO_rec
             ,  x_eco_revision_tbl    => l_eco_revision_tbl
             ,  x_revised_item_tbl    => l_revised_item_tbl
             ,  x_rev_component_tbl   => l_rev_component_tbl
             ,  x_ref_designator_tbl  => l_ref_designator_tbl
             ,  x_sub_component_tbl   => l_sub_component_tbl
             ,  x_rev_operation_tbl   => x_rev_operation_tbl
             ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
             ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
             ) ;
          END IF;
       END IF;


       --
       -- Process Flow step 18: Entity defaulting for CREATE and UPDATE
       -- Merged into Process Flow step 13 : Default missing values
       --

       IF l_rev_operation_rec.transaction_type IN ( Bom_Rtg_Globals.G_OPR_CREATE
                                                  , Bom_Rtg_Globals.G_OPR_UPDATE )
       THEN
          Bom_Default_Op_Seq.Entity_Defaulting
              (   p_rev_operation_rec   => l_rev_operation_rec
              ,   p_rev_op_unexp_rec    => l_rev_op_unexp_rec
              ,   p_control_rec         => Bom_Rtg_Pub.G_Default_Control_Rec
              ,   x_rev_operation_rec   => l_rev_operation_rec
              ,   x_rev_op_unexp_rec    => l_rev_op_unexp_rec
              ,   x_mesg_token_tbl  => l_mesg_token_tbl
              ,   x_return_status   => l_return_status
              ) ;

          IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Entity defaulting completed with return_status: ' || l_return_status) ;
          END IF ;

          IF l_return_status = Error_Handler.G_STATUS_ERROR
          THEN
             IF l_rev_operation_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
             THEN
                l_other_message := 'BOM_OP_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
                RAISE EXC_SEV_SKIP_BRANCH ;
             ELSE
                RAISE EXC_SEV_QUIT_RECORD ;
             END IF;
          ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
          THEN
             l_other_message := 'BOM_OP_ENTDEF_UNEXP_SKIP';
             l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
             RAISE EXC_UNEXP_SKIP_OBJECT ;
          ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
          THEN
             ECO_Error_Handler.Log_Error
             (  p_rev_operation_tbl   => x_rev_operation_tbl
             ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl
             ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
             ,  p_mesg_token_tbl      => l_mesg_token_tbl
             ,  p_error_status        => 'W'
             ,  p_error_level         => Error_Handler.G_OP_LEVEL
             ,  p_entity_index        => I
             ,  x_ECO_rec             => l_ECO_rec
             ,  x_eco_revision_tbl    => l_eco_revision_tbl
             ,  x_revised_item_tbl    => l_revised_item_tbl
             ,  x_rev_component_tbl   => l_rev_component_tbl
             ,  x_ref_designator_tbl  => l_ref_designator_tbl
             ,  x_sub_component_tbl   => l_sub_component_tbl
             ,  x_rev_operation_tbl   => x_rev_operation_tbl
             ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
             ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
             ) ;
          END IF ;
       END IF ;


       --
       -- Process Flow step 19 - Entity Level Validation
       -- Call Bom_Validate_Op_Seq.Check_Entity
       --

       IF Bom_Rtg_Globals.Get_Debug = 'Y'
       THEN Error_Handler.Write_Debug('Starting with Revised Operatin Entity Validation . . . ') ;
       END IF ;

          Bom_Validate_Op_Seq.Check_Entity
          (  p_rev_operation_rec     => l_rev_operation_rec
          ,  p_rev_op_unexp_rec      => l_rev_op_unexp_rec
          ,  p_old_rev_operation_rec => l_old_rev_operation_rec
          ,  p_old_rev_op_unexp_rec  => l_old_rev_op_unexp_rec
          ,  p_control_rec           => Bom_Rtg_Pub.G_Default_Control_Rec
          ,  x_rev_operation_rec     => l_rev_operation_rec
          ,  x_rev_op_unexp_rec      => l_rev_op_unexp_rec
          ,  x_mesg_token_tbl        => l_mesg_token_tbl
          ,  x_return_status         => l_return_status
          ) ;


       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
          IF l_rev_operation_rec.transaction_type = Bom_Rtg_Globals.G_OPR_CREATE
          THEN
             l_other_message := 'BOM_OP_ENTVAL_CSEV_SKIP';
             l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
             l_other_token_tbl(1).token_value :=
                           l_rev_operation_rec.operation_sequence_number ;
             RAISE EXC_SEV_SKIP_BRANCH ;
          ELSE
             RAISE EXC_SEV_QUIT_RECORD ;
          END IF;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'BOM_OP_ENTVAL_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                        l_rev_operation_rec.operation_sequence_number ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
       THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl   => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl      => l_mesg_token_tbl
          ,  p_error_status        => 'W'
          ,  p_error_level         => Error_Handler.G_OP_LEVEL
          ,  p_entity_index        => I
          ,  x_ECO_rec             => l_ECO_rec
          ,  x_eco_revision_tbl    => l_eco_revision_tbl
          ,  x_revised_item_tbl    => l_revised_item_tbl
          ,  x_rev_component_tbl   => l_rev_component_tbl
          ,  x_ref_designator_tbl  => l_ref_designator_tbl
          ,  x_sub_component_tbl   => l_sub_component_tbl
          ,  x_rev_operation_tbl   => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
          ) ;
       END IF;

       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation completed with '
             || l_return_Status || ' proceeding for database writes . . . ') ;
       END IF;

       --
       -- Process Flow step 20 : Database Writes
       --
       IF l_rev_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CANCEL
       THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
('Operatin Sequence: Perform Cancel Operation . . .') ;
END IF ;

           ENG_Globals.Cancel_Operation
           ( p_operation_sequence_id  => l_rev_op_unexp_rec.operation_sequence_id
           , p_cancel_comments        => l_rev_operation_rec.cancel_comments
           , p_op_seq_num             => l_rev_operation_rec.operation_sequence_number
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

       ELSE
           /*
           Added If condition for bug#13601838, If alternate_routing_code is not NULL
           then calling  ENG_Globals.Perform_Writes_For_Alt_Rtg.
           */
           IF(l_rev_operation_rec.alternate_routing_code is NULL)
           THEN
             ENG_Globals.Perform_Writes_For_Primary_Rtg
             (   p_rev_operation_rec       => l_rev_operation_rec
             ,   p_rev_op_unexp_rec        => l_rev_op_unexp_rec
             ,   x_mesg_token_tbl          => l_mesg_token_tbl
             ,   x_return_status           => l_return_status
             ) ;
           ELSE
             ENG_Globals.Perform_Writes_For_Alt_Rtg
             (   p_rev_operation_rec       => l_rev_operation_rec
             ,   p_rev_op_unexp_rec        => l_rev_op_unexp_rec
             ,   x_mesg_token_tbl          => l_mesg_token_tbl
             ,   x_return_status           => l_return_status
             ) ;
           END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
               l_other_message := 'BOM_OP_WRITES_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND
               l_mesg_token_tbl .COUNT <>0
           THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_operation_tbl   => x_rev_operation_tbl
               ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_OP_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => x_rev_operation_tbl
               ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ) ;
           END IF;

           Bom_Op_Seq_Util.Perform_Writes
              (   p_rev_operation_rec       => l_rev_operation_rec
              ,   p_rev_op_unexp_rec        => l_rev_op_unexp_rec
              ,   p_control_rec             => Bom_Rtg_Pub.G_Default_Control_Rec
              ,   x_mesg_token_tbl          => l_mesg_token_tbl
              ,   x_return_status           => l_return_status
              ) ;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
               l_other_message := 'BOM_OP_WRITES_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND
               l_mesg_token_tbl .COUNT <>0
           THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_operation_tbl   => x_rev_operation_tbl
               ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_OP_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => x_rev_operation_tbl
               ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl
               ) ;
           END IF;

       END IF ;


       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Database writes completed with status  ' || l_return_status);
       END IF;

     /*Bug 6485168. l_process_children should be set inside the if clause. In the else set it to false
     END IF; -- END IF statement that checks RETURN STATUS
     */
    --  Load tables.
    x_rev_operation_tbl(I)          := l_rev_operation_rec;

    -- Indicate that children need to be processed
    l_process_children := TRUE;

     ELSE

     l_process_children := FALSE;

    END IF; -- END IF statement that checks RETURN STATUS

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => FND_API.G_RET_STS_ERROR
          ,  p_error_scope             => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ) ;

         l_process_children := TRUE;

         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status := l_return_status;
         END IF;

         x_return_status           := l_bo_return_status;
         x_mesg_token_tbl          := l_mesg_token_tbl ;

         --x_rev_operation_tbl       := l_rev_operation_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_SEV_QUIT_BRANCH THEN

          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => FND_API.G_RET_STS_ERROR
          ,  p_error_scope             => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          );

         l_process_children := FALSE;

         IF l_bo_return_status = 'S'
         THEN
            l_bo_return_status  := l_return_status;
         END IF;

         x_return_status           := l_bo_return_status;
         x_mesg_token_tbl          := l_mesg_token_tbl ;

         --x_rev_operation_tbl       := l_rev_operation_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_SEV_SKIP_BRANCH THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => FND_API.G_RET_STS_ERROR
          ,  p_error_scope             => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ) ;

        l_process_children    := FALSE ;
        IF l_bo_return_status = 'S'
        THEN
           l_bo_return_status := l_return_status ;
        END IF;

         x_return_status           := l_bo_return_status;
         x_mesg_token_tbl          := l_mesg_token_tbl ;

         --x_rev_operation_tbl       := l_rev_operation_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => FND_API.G_RET_STS_ERROR
          ,  p_error_scope             => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ) ;


         l_process_children    := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
           l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status           := l_bo_return_status;
         x_mesg_token_tbl          := l_mesg_token_tbl ;

         --x_rev_operation_tbl       := l_rev_operation_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;



      WHEN EXC_FAT_QUIT_BRANCH THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => FND_API.G_RET_STS_ERROR
          ,  p_error_scope             => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ) ;

         l_process_children    := FALSE ;
         x_return_status       := Error_Handler.G_STATUS_FATAL;
         x_mesg_token_tbl      := l_mesg_token_tbl ;

         --x_rev_operation_tbl       := l_rev_operation_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;



      WHEN EXC_FAT_QUIT_SIBLINGS THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => FND_API.G_RET_STS_ERROR
          ,  p_error_scope             => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ) ;


        l_process_children    := FALSE ;
        x_return_status       := Error_Handler.G_STATUS_FATAL;
        x_mesg_token_tbl      := l_mesg_token_tbl ;

        --x_rev_operation_tbl       := l_rev_operation_tbl ;
        --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
        --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


    WHEN EXC_FAT_QUIT_OBJECT THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => FND_API.G_RET_STS_ERROR
          ,  p_error_scope             => Error_Handler.G_SCOPE_RECORD
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ) ;

         l_return_status       := 'Q';
         x_mesg_token_tbl      := l_mesg_token_tbl ;

         --x_rev_operation_tbl       := l_rev_operation_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;


      WHEN EXC_UNEXP_SKIP_OBJECT THEN
          ECO_Error_Handler.Log_Error
          (  p_rev_operation_tbl       => x_rev_operation_tbl
          ,  p_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  p_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ,  p_mesg_token_tbl          => l_mesg_token_tbl
          ,  p_error_status            => Error_Handler.G_STATUS_UNEXPECTED
          ,  p_error_level             => Error_Handler.G_OP_LEVEL
          ,  p_entity_index            => I
          ,  p_other_status            => Error_Handler.G_STATUS_NOT_PICKED
          ,  p_other_message           => l_other_message
          ,  p_other_token_tbl         => l_other_token_tbl
          ,  x_eco_rec                 => l_eco_rec
          ,  x_eco_revision_tbl        => l_eco_revision_tbl
          ,  x_revised_item_tbl        => l_revised_item_tbl
          ,  x_rev_component_tbl       => l_rev_component_tbl
          ,  x_ref_designator_tbl      => l_ref_designator_tbl
          ,  x_sub_component_tbl       => l_sub_component_tbl
          ,  x_rev_operation_tbl       => x_rev_operation_tbl
          ,  x_rev_op_resource_tbl     => x_rev_op_resource_tbl
          ,  x_rev_sub_resource_tbl    => x_rev_sub_resource_tbl
          ) ;
         l_return_status       := 'U';
         x_mesg_token_tbl      := l_mesg_token_tbl ;

         --x_rev_operation_tbl       := l_rev_operation_tbl ;
         --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
         --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

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
      Rev_Operation_Resources
      (   p_validation_level         => p_validation_level
      ,   p_change_notice            => l_rev_operation_rec.eco_name
      ,   p_organization_id          =>
                       l_rev_op_unexp_rec.organization_id
      ,   p_revised_item_name        =>
                       l_rev_operation_rec.revised_item_name
      ,   p_alternate_routing_code   =>
                       l_rev_operation_rec.alternate_routing_code    -- Uncommented for bug 13329115
      ,   p_operation_seq_num        =>
                       l_rev_operation_rec.operation_sequence_number
      ,   p_item_revision            =>
                       l_rev_operation_rec.new_revised_item_revision
      ,   p_effectivity_date         =>
                       l_rev_operation_rec.start_effective_date
      ,   p_routing_revision         =>
                       l_rev_operation_rec.new_routing_revision   -- Added by MK on 11/02/00
      ,   p_from_end_item_number     =>
                       l_rev_operation_rec.from_end_item_unit_number -- Added by MK on 11/02/0
      ,   p_operation_type           =>
                       l_rev_operation_rec.operation_type
      ,   p_rev_op_resource_tbl      => x_rev_op_resource_tbl
      ,   p_rev_sub_resource_tbl     => x_rev_sub_resource_tbl
      ,   x_rev_op_resource_tbl      => x_rev_op_resource_tbl
      ,   x_rev_sub_resource_tbl     => x_rev_sub_resource_tbl
      ,   x_mesg_token_tbl           => l_mesg_token_tbl
      ,   x_return_status            => l_return_status
      ) ;

       -- Bug 7606951. Populate l_bo_return_status if l_return_status is not S
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
          l_bo_return_status := l_return_status;
       END IF;
      -- Process Substitute Operation Resources that are direct children of this
      -- operation

     Rev_Sub_Operation_Resources
      (   p_validation_level         => p_validation_level
      ,   p_change_notice            => l_rev_operation_rec.eco_name
      ,   p_organization_id          =>
                       l_rev_op_unexp_rec.organization_id
      ,   p_revised_item_name        =>
                       l_rev_operation_rec.revised_item_name
      ,   p_alternate_routing_code   =>
                       l_rev_operation_rec.alternate_routing_code    -- Uncommented for bug 13329115
      ,   p_operation_seq_num        =>
                       l_rev_operation_rec.operation_sequence_number
      ,   p_item_revision            =>
                       l_rev_operation_rec.new_revised_item_revision
      ,   p_effectivity_date         =>
                       l_rev_operation_rec.start_effective_date
      ,   p_routing_revision         =>
                       l_rev_operation_rec.new_routing_revision   -- Added by MK on 11/02/00
      ,   p_from_end_item_number     =>
                       l_rev_operation_rec.from_end_item_unit_number -- Added by MK on 11/02/00
      ,   p_operation_type           => l_rev_operation_rec.operation_type
      ,   p_rev_sub_resource_tbl         => x_rev_sub_resource_tbl
      ,   x_rev_sub_resource_tbl         => x_rev_sub_resource_tbl
      ,   x_mesg_token_tbl           => l_mesg_token_tbl
      ,   x_return_status            => l_return_status
      ) ;

     -- Bug 7606951. Populate l_bo_return_status if l_return_status is not S
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        l_bo_return_status := l_return_status;
     END IF;

    END IF;   -- Process children
   END IF;
   END LOOP; -- END Operation Sequences processing loop

   --  Load OUT parameters
   /*  Bug 7606951. Changed l_return_status to l_bo_return_status
   IF NVL(l_return_status, 'S') <> 'S' */
   IF NVL(l_bo_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_bo_return_status;
   END IF;

   x_mesg_token_tbl          := l_mesg_token_tbl ;
   --x_rev_operation_tbl       := l_rev_operation_tbl ;
   --x_rev_op_resource_tbl     := l_rev_op_resource_tbl ;
   --x_rev_sub_resource_tbl    := l_rev_sub_resource_tbl ;

END Rev_Operation_Sequences ;


--  L1:  The above part is for ECO enhancement


--  Sub_Comps

PROCEDURE Sub_Comps
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   p_revised_item_name             IN  VARCHAR2 := NULL
,   p_alternate_bom_code            IN  VARCHAR2 := NULL  -- Bug 3991176
,   p_effectivity_date              IN  DATE := NULL
,   p_item_revision                 IN  VARCHAR2 := NULL
,   p_routing_revision              IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number          IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_component_item_name           IN  VARCHAR2 := NULL
,   p_operation_seq_num             IN  NUMBER := NULL
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_item_parent_exists    BOOLEAN := FALSE;
l_comp_parent_exists    BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_rec               ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_rec     BOM_BO_PUB.Sub_Component_Rec_Type;
--l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
l_old_sub_component_rec BOM_BO_PUB.Sub_Component_Rec_Type;
l_sub_comp_unexp_rec    BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_old_sub_comp_unexp_rec BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

l_rev_operation_tbl      Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl    Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;


EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    l_return_status := 'S';
    l_bo_return_status := 'S';

    l_comp_parent_exists := FALSE;
    l_item_parent_exists := FALSE;

    --  Init local table variables.

    x_sub_component_tbl            := p_sub_component_tbl;

    l_sub_comp_unexp_rec.organization_id := ENG_GLOBALS.Get_org_id;

    FOR I IN 1..x_sub_component_tbl.COUNT LOOP

    IF (x_sub_component_tbl(I).return_status IS NULL OR
            x_sub_component_tbl(I).return_status = FND_API.G_MISS_CHAR) THEN

    BEGIN

        --  Load local records.

        l_sub_component_rec := x_sub_component_tbl(I);

        l_sub_component_rec.transaction_type :=
                UPPER(l_sub_component_rec.transaction_type);

        IF p_component_item_name IS NOT NULL AND
           p_operation_seq_num IS NOT NULL AND
           p_revised_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                -- revised comp parent exists

                l_comp_parent_exists := TRUE;
        ELSIF p_revised_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           --p_item_revision IS NOT NULL    AND   (Commented for bug 3766816 - Forward porting for bug 3747487)
           p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                -- revised item parent exists

                l_item_parent_exists := TRUE;
        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

        IF --(l_sub_component_rec.return_status IS NULL OR
            --l_sub_component_rec.return_status = FND_API.G_MISS_CHAR)
           --AND

           -- Did Rev_Comps call this procedure, that is,
           -- if revised comp exists, then is this record a child ?

           ((l_comp_parent_exists AND
               (l_sub_component_rec.ECO_Name = p_change_notice AND
                l_sub_comp_unexp_rec.organization_id = p_organization_id AND
                l_sub_component_rec.start_effective_date = nvl(ENG_Default_Revised_Item.G_OLD_SCHED_DATE,p_effectivity_date) AND  -- Bug 6657209
                NVL(l_sub_component_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR ) AND
                l_sub_component_rec.revised_item_name = p_revised_item_name AND
                NVL(l_sub_component_rec.alternate_bom_code,'NULL') = NVL(p_alternate_bom_code,'NULL') AND -- Bug 3991176
                NVL(l_sub_component_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision, FND_API.G_MISS_CHAR )     AND -- Added by MK on 11/02/00
                NVL(l_sub_component_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
                l_sub_component_rec.component_item_name = p_component_item_name AND
                l_sub_component_rec.operation_sequence_number = p_operation_seq_num))

            OR

            -- Did Rev_Items call this procedure, that is,
            -- if revised item exists, then is this record a child ?

            (l_item_parent_exists AND
               (l_sub_component_rec.ECO_Name = p_change_notice AND
                l_sub_comp_unexp_rec.organization_id = p_organization_id AND
                l_sub_component_rec.revised_item_name = p_revised_item_name AND
                NVL(l_sub_component_rec.alternate_bom_code,'NULL') = NVL(p_alternate_bom_code,'NULL') AND -- Bug 3991176
                l_sub_component_rec.start_effective_date = p_effectivity_date AND
                NVL(l_sub_component_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision, FND_API.G_MISS_CHAR )     AND -- Added by MK on 11/02/00
                NVL(l_sub_component_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/0
                NVL(l_sub_component_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR ) ))

             OR

             (NOT l_comp_parent_exists AND
              NOT l_item_parent_exists))
        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_sub_component_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing substitite component: ' || l_sub_component_rec.substitute_component_name); END IF;

           -- Bug 6657209
           IF (l_comp_parent_exists and ENG_Default_Revised_Item.G_OLD_SCHED_DATE is not null) THEN
              l_sub_component_rec.start_effective_date := p_effectivity_date;
           END IF;

           -- Check if transaction_type is valid
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check transaction_type validity'); END IF;
           ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_sub_component_rec.transaction_type
           ,   p_entity                 => 'Sub_Comps'
           ,   p_entity_id              => l_sub_component_rec.revised_item_name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           -- Process Flow step 4(a): Convert user unique index to unique index I
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index I'); END IF;
           Bom_Val_To_Id.Sub_Component_UUI_To_UI
                ( p_sub_component_rec  => l_sub_component_rec
                , p_sub_comp_unexp_rec => l_sub_comp_unexp_rec
                , x_sub_comp_unexp_rec => l_sub_comp_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_SBC_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 4(b): Convert user unique index to unique index II
           --


           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index II'); END IF;
           Bom_Val_To_Id.Sub_Component_UUI_To_UI2
                ( p_sub_component_rec  => l_sub_component_rec
                , p_sub_comp_unexp_rec => l_sub_comp_unexp_rec
                , x_sub_comp_unexp_rec => l_sub_comp_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_other_message      => l_other_message
                , x_other_token_tbl    => l_other_token_tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_SBC_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           IF Bom_Globals.Get_Debug = 'Y' THEN
               Error_Handler.Write_Debug('Converting user unique index to unique index II for Bill and Rev Item Seq Id');
           END IF;
           -- Added by MK on 12/03/00 to resolve ECO dependency
           ENG_Val_To_Id.BillAndRevitem_UUI_To_UI
           ( p_revised_item_name        => l_sub_component_rec.revised_item_name
           , p_alternate_bom_code       => l_sub_component_rec.alternate_bom_code -- Bug 3991176
           , p_revised_item_id          => l_sub_comp_unexp_rec.revised_item_id
           , p_item_revision            => l_sub_component_rec.new_revised_item_revision
           , p_effective_date           => l_sub_component_rec.start_effective_date
           , p_change_notice            => l_sub_component_rec.eco_name
           , p_organization_id          => l_sub_comp_unexp_rec.organization_id
           , p_new_routing_revision     => l_sub_component_rec.new_routing_revision
           , p_from_end_item_number     => l_sub_component_rec.from_end_item_unit_number
           , p_entity_processed         => 'SBC'
           , p_component_item_name      => l_sub_component_rec.component_item_name
           , p_component_item_id        => l_sub_comp_unexp_rec.component_item_id
           , p_operation_sequence_number => l_sub_component_rec.operation_sequence_number
           , p_rfd_sbc_name             => l_sub_component_rec.substitute_component_name
           , p_transaction_type         => l_sub_component_rec.transaction_type
           , x_revised_item_sequence_id => l_sub_comp_unexp_rec.revised_item_sequence_id
           , x_bill_sequence_id         => l_sub_comp_unexp_rec.bill_sequence_id
           , x_component_sequence_id    => l_sub_comp_unexp_rec.component_sequence_id
           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
           , x_other_message            => l_other_message
           , x_other_token_tbl          => l_other_token_tbl
           , x_Return_Status            => l_return_status
          ) ;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_SBC_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;




           -- Process Flow step 5: Verify Substitute Component's existence
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check existence'); END IF;
           Bom_Validate_Sub_Component.Check_Existence
                (  p_sub_component_rec          => l_sub_component_rec
                ,  p_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
                ,  x_old_sub_component_rec      => l_old_sub_component_rec
                ,  x_old_sub_comp_unexp_rec     => l_old_sub_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_SBC_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                l_other_token_tbl(2).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(2).token_value := l_sub_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 7: Is Subsitute Component record an orphan ?

           IF NOT l_comp_parent_exists
           THEN

                -- Process Flow step 6: Check lineage
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');     END IF;
                Bom_Validate_Sub_Component.Check_Lineage
                (  p_sub_component_rec          => l_sub_component_rec
                ,  p_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_SBC_LIN_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 8(a and b): Is ECO impl/cancl, or in wkflw process ?
                --

                ENG_Validate_ECO.Check_Access
                (  p_change_notice      => l_sub_component_rec.ECO_Name
                ,  p_organization_id    => l_sub_comp_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_SBC_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_SBC_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 9(a and b): check that user has access to revised item
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                ENG_Validate_Revised_Item.Check_Access
                (  p_change_notice      => l_sub_component_rec.ECO_Name
                ,  p_organization_id    => l_sub_comp_unexp_rec.organization_id
                ,  p_revised_item_id    => l_sub_comp_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_sub_component_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_sub_component_rec.start_effective_date
                ,  p_new_routing_revsion   => l_sub_component_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_sub_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_sub_component_rec.revised_item_name
                ,  p_entity_processed   => 'SBC' -- Bug 4210718
                ,  p_alternate_bom_code => l_sub_component_rec.alternate_bom_code -- Bug 4210718
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_SBC_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_SBC_RITACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 10: check that user has access to revised component
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                Bom_Validate_Bom_Component.Check_Access
                (  p_change_notice      => l_sub_component_rec.ECO_Name
                ,  p_organization_id    => l_sub_comp_unexp_rec.organization_id
                ,  p_revised_item_id    => l_sub_comp_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_sub_component_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_sub_component_rec.start_effective_date
                ,  p_new_routing_revsion  => l_sub_component_rec.new_routing_revision -- Added by MK on 11/02/00
                ,  p_from_end_item_number => l_sub_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_sub_component_rec.revised_item_name
                ,  p_component_item_id  => l_sub_comp_unexp_rec.component_item_id
                ,  p_operation_seq_num  => l_sub_component_rec.operation_sequence_number
                ,  p_bill_sequence_id   => l_sub_comp_unexp_rec.bill_sequence_id
                ,  p_component_name     => l_sub_component_rec.component_item_name
                ,  p_entity_processed   => 'SBC'
                ,  p_rfd_sbc_name       => l_sub_component_rec.substitute_component_name
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_SBC_CMPACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        l_other_token_tbl(2).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(2).token_value := l_sub_component_rec.component_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_SBC_CMPACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        l_other_token_tbl(2).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(2).token_value := l_sub_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 11: does user have access to substitute component ?
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                Bom_Validate_Sub_Component.Check_Access
                (  p_sub_component_rec => l_sub_component_rec
                ,  p_sub_comp_unexp_rec => l_sub_comp_unexp_rec
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_SBC_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_SBC_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;

           -- Process Flow step 12: Attribute Validation for CREATE and UPDATE
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation'); END IF;
           IF l_sub_component_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                Bom_Validate_Sub_Component.Check_Attributes
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_sub_component_rec          => l_sub_component_rec
                , p_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'BOM_SBC_ATTVAL_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                   l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status = 'S' AND
                      x_Mesg_Token_Tbl.COUNT <>0
                THEN
                   Eco_Error_Handler.Log_Error
                        (  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 6
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => l_rev_component_tbl
                        ,  x_ref_designator_tbl => l_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           IF l_sub_component_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

                -- Process flow step 13 - Populate NULL columns for Update and
                -- Delete.

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
                Bom_Default_Sub_Component.Populate_NULL_Columns
                (   p_sub_component_rec         => l_sub_component_rec
                ,   p_old_sub_component_rec     => l_old_sub_component_rec
                ,   p_sub_comp_unexp_rec        => l_sub_comp_unexp_rec
                ,   p_old_sub_comp_unexp_rec    => l_old_sub_comp_unexp_rec
                ,   x_sub_component_rec         => l_sub_component_rec
                ,   x_sub_comp_unexp_rec        => l_sub_comp_unexp_rec
                );

           ELSIF l_sub_component_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

                -- Process Flow step 14: Default missing values for Operation CREATE
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
                Bom_Default_Sub_Component.Attribute_Defaulting
                (   p_sub_component_rec         => l_sub_component_rec
                ,   p_sub_comp_unexp_rec        => l_sub_comp_unexp_rec
                ,   x_sub_component_rec         => l_sub_component_rec
                ,   x_sub_comp_unexp_rec        => l_sub_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_SBC_ATTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_sub_component_tbl   => x_sub_component_tbl
                        ,  p_mesg_token_tbl      => l_mesg_token_tbl
                        ,  p_error_status        => 'W'
                        ,  p_error_level         => 6
                        ,  p_entity_index        => I
                        ,  x_eco_rec             => l_eco_rec
                        ,  x_eco_revision_tbl    => l_eco_revision_tbl
                        ,  x_revised_item_tbl    => l_revised_item_tbl
                        ,  x_rev_component_tbl   => l_rev_component_tbl
                        ,  x_ref_designator_tbl  => l_ref_designator_tbl
                        ,  x_sub_component_tbl   => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           -- Process Flow step 15 - Entity Level Validation
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;
           Bom_Validate_Sub_Component.Check_Entity
                (  p_sub_component_rec          => l_sub_component_rec
                ,  p_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_SBC_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 6
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

           -- Process Flow step 16 : Database Writes
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
           Bom_Sub_Component_Util.Perform_Writes
                (   p_sub_component_rec         => l_sub_component_rec
                ,   p_sub_comp_unexp_rec        => l_sub_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_SBC_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_sub_component_rec.substitute_component_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 6
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        x_sub_component_tbl(I)          := l_sub_component_rec;

    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level         => 6
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 6
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 6
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        RETURN;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 6
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        RETURN;

       WHEN EXC_FAT_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 6
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_ALL
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 6
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 6
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_return_status                := l_bo_return_status;
        --x_sub_component_tbl            := l_sub_component_tbl;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        l_return_status := 'U';

        END; -- END block
     END IF;
     END LOOP; -- END Substitute Components processing loop

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     --x_sub_component_tbl        := l_sub_component_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Sub_Comps;


--  Ref_Desgs

PROCEDURE Ref_Desgs
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   p_revised_item_name             IN  VARCHAR2 := NULL
,   p_alternate_bom_code            IN  VARCHAR2 := NULL  -- Bug 3991176
,   p_effectivity_date              IN  DATE := NULL
,   p_item_revision                 IN  VARCHAR2 := NULL
,   p_routing_revision              IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number          IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_component_item_name           IN  VARCHAR2 := NULL
,   p_operation_seq_num             IN  NUMBER := NULL
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_item_parent_exists    BOOLEAN := FALSE;
l_comp_parent_exists    BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_rec               ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_rec    BOM_BO_PUB.Ref_Designator_Rec_Type;
--l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
l_old_ref_designator_rec BOM_BO_PUB.Ref_Designator_Rec_Type;
l_ref_desg_unexp_rec    BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_old_ref_desg_unexp_rec BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
--l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

l_rev_operation_tbl      Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl    Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    --  Init local table variables.

    l_return_status := 'S';
    l_bo_return_status := 'S';

    x_ref_designator_tbl           := p_ref_designator_tbl;
    x_sub_component_tbl            := p_sub_component_tbl;

    l_ref_desg_unexp_rec.organization_id := ENG_GLOBALS.Get_org_id;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within processing Ref Designators . . . '); END IF;


    FOR I IN 1..x_ref_designator_tbl.COUNT LOOP
    IF (x_ref_designator_tbl(I).return_status IS NULL OR
         x_ref_designator_tbl(I).return_status = FND_API.G_MISS_CHAR) THEN

    BEGIN

        --  Load local records.

        l_ref_designator_rec := x_ref_designator_tbl(I);

        l_ref_designator_rec.transaction_type :=
                UPPER(l_ref_designator_rec.transaction_type);

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Ref Designator . . . ' || l_ref_designator_rec.reference_designator_name || 'at count ' || to_char(i)); END IF;

        IF p_component_item_name IS NOT NULL AND
           p_operation_seq_num IS NOT NULL AND
           p_revised_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                -- revised comp parent exists

                l_comp_parent_exists := TRUE;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Called by Rev_Comps . . .'); END IF;

        ELSIF p_revised_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           --p_item_revision IS NOT NULL AND	(Commented for bug 3766816 - Forward porting for bug 3747487)
           p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                -- revised item parent exists

                l_item_parent_exists := TRUE;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Called by Rev_Items . . .'); END IF;

        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                        ('ECO Name: ' || p_change_notice ||
                         ' Org     : ' || p_organization_id ||
                         ' Eff. Dt : ' || to_char(p_effectivity_date) ||
                         ' Revision: ' || p_item_revision ||
                         ' Rev Item: ' || p_revised_item_name ||
                         ' Rev Comp: ' || p_component_item_name ||
                         ' Op. Seq : ' || p_operation_seq_num); END IF;

        IF --(l_ref_designator_rec.return_status IS NULL OR
            --l_ref_designator_rec.return_status = FND_API.G_MISS_CHAR)
           --AND

           -- Did Rev_Comps call this procedure, that is,
           -- if revised comp exists, then is this record a child ?

           ((l_comp_parent_exists AND
               (l_ref_designator_rec.ECO_Name = p_change_notice AND
                l_ref_desg_unexp_rec.organization_id = p_organization_id AND
                l_ref_designator_rec.start_effective_date = nvl(ENG_Default_Revised_Item.G_OLD_SCHED_DATE,p_effectivity_date) AND -- bug 6657209
                NVL(l_ref_designator_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR )     AND
                NVL(l_ref_designator_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision, FND_API.G_MISS_CHAR )  AND -- Added by MK on 11/02/00
                NVL(l_ref_designator_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number, FND_API.G_MISS_CHAR )  AND -- Added by MK on 11/02/00
                l_ref_designator_rec.revised_item_name = p_revised_item_name AND
                NVL(l_ref_designator_rec.alternate_bom_code,'NULL') = NVL(p_alternate_bom_code,'NULL') AND -- Bug 3991176
                l_ref_designator_rec.component_item_name = p_component_item_name AND
                l_ref_designator_rec.operation_sequence_number = p_operation_seq_num))

             OR

             -- Did Rev_Items call this procedure, that is,
             -- if revised item exists, then is this record a child ?

             (l_item_parent_exists AND
               (l_ref_designator_rec.ECO_Name = p_change_notice AND
                l_ref_desg_unexp_rec.organization_id = p_organization_id AND
                l_ref_designator_rec.revised_item_name = p_revised_item_name AND
                NVL(l_ref_designator_rec.alternate_bom_code,'NULL') = NVL(p_alternate_bom_code,'NULL') AND -- Bug 3991176
                l_ref_designator_rec.start_effective_date = p_effectivity_date AND
                NVL(l_ref_designator_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision, FND_API.G_MISS_CHAR )  AND -- Added by MK on 11/02/00
                NVL(l_ref_designator_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number, FND_API.G_MISS_CHAR )  AND -- Added by MK on 11/02/00
                NVL(l_ref_designator_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR ) ))

             OR

             (NOT l_item_parent_exists AND
              NOT l_comp_parent_exists))
        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_ref_designator_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           -- Bug 6657209
           IF (l_comp_parent_exists and ENG_Default_Revised_Item.G_OLD_SCHED_DATE is not null) THEN
              l_ref_designator_rec.start_effective_date := p_effectivity_date;
           END IF;

           -- Check if transaction_type is valid
           --

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check transaction_type validity'); END IF;


	   ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_ref_designator_rec.transaction_type
           ,   p_entity                 => 'Ref_Desgs'
           ,   p_entity_id              => l_ref_designator_rec.revised_item_name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           -- Process Flow step 4(a): Convert user unique index to unique index I
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index I'); END IF;
           Bom_Val_To_Id.Ref_Designator_UUI_To_UI
                ( p_ref_designator_rec => l_ref_designator_rec
                , p_ref_desg_unexp_rec => l_ref_desg_unexp_rec
                , x_ref_desg_unexp_rec => l_ref_desg_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RFD_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 4(b): Convert user unique index to unique index II
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index II'); END IF;
           Bom_Val_To_Id.Ref_Designator_UUI_To_UI2
                ( p_ref_designator_rec => l_ref_designator_rec
                , p_ref_desg_unexp_rec => l_ref_desg_unexp_rec
                , x_ref_desg_unexp_rec => l_ref_desg_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_other_message      => l_other_message
                , x_other_token_tbl    => l_other_token_tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RFD_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           IF Bom_Globals.Get_Debug = 'Y' THEN
           Error_Handler.Write_Debug('Converting user unique index to unique index II for Bill and Rev Item Seq Id');
           END IF;

           -- Added by MK on 12/03/00 to resolve ECO dependency
           ENG_Val_To_Id.BillAndRevitem_UUI_To_UI
           ( p_revised_item_name        => l_ref_designator_rec.revised_item_name
           , p_alternate_bom_code       => l_ref_designator_rec.alternate_bom_code -- Bug 3991176
           , p_revised_item_id          => l_ref_desg_unexp_rec.revised_item_id
           , p_item_revision            => l_ref_designator_rec.new_revised_item_revision
           , p_effective_date           => l_ref_designator_rec.start_effective_date
           , p_change_notice            => l_ref_designator_rec.eco_name
           , p_organization_id          => l_ref_desg_unexp_rec.organization_id
           , p_new_routing_revision     => l_ref_designator_rec.new_routing_revision
           , p_from_end_item_number     => l_ref_designator_rec.from_end_item_unit_number
           , p_entity_processed         => 'RFD'
           , p_component_item_name      => l_ref_designator_rec.component_item_name
           , p_component_item_id        => l_ref_desg_unexp_rec.component_item_id
           , p_operation_sequence_number => l_ref_designator_rec.operation_sequence_number
           , p_rfd_sbc_name             => l_ref_designator_rec.reference_designator_name
           , p_transaction_type         => l_ref_designator_rec.transaction_type
           , x_revised_item_sequence_id => l_ref_desg_unexp_rec.revised_item_sequence_id
           , x_bill_sequence_id         => l_ref_desg_unexp_rec.bill_sequence_id
           , x_component_sequence_id    => l_ref_desg_unexp_rec.component_sequence_id
           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
           , x_other_message            => l_other_message
           , x_other_token_tbl          => l_other_token_tbl
           , x_Return_Status            => l_return_status
          ) ;


           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RFD_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           -- Process Flow step 5: Verify Reference Designator's existence
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check existence'); END IF;
           Bom_Validate_Ref_Designator.Check_Existence
                (  p_ref_designator_rec         => l_ref_designator_rec
                ,  p_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
                ,  x_old_ref_designator_rec     => l_old_ref_designator_rec
                ,  x_old_ref_desg_unexp_rec     => l_old_ref_desg_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RFD_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                l_other_token_tbl(2).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(2).token_value := l_ref_designator_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 6: Is Revised Component record an orphan ?

           IF NOT l_comp_parent_exists
           THEN

                -- Process Flow step 7: Check lineage
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');     END IF;
                Bom_Validate_Ref_Designator.Check_Lineage
                (  p_ref_designator_rec         => l_ref_designator_rec
                ,  p_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RFD_LIN_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                        l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 8(a and b): Is ECO impl/cancl, or in wkflw process ?
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' Check ECO access'); END IF;

                ENG_Validate_ECO.Check_Access
                ( p_change_notice       => l_ref_designator_rec.ECO_Name
                , p_organization_id     => l_ref_desg_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RFD_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                        l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RFD_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                        l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 9(a and b): check that user has access to revised item
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                ENG_Validate_Revised_Item.Check_Access
                (  p_change_notice      => l_ref_designator_rec.ECO_Name
                ,  p_organization_id    => l_ref_desg_unexp_rec.organization_id
                ,  p_revised_item_id    => l_ref_desg_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_ref_designator_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_ref_designator_rec.start_effective_date
                ,  p_new_routing_revsion  => l_ref_designator_rec.new_routing_revision -- Added by MK on 11/02/00
                ,  p_from_end_item_number => l_ref_designator_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_ref_designator_rec.revised_item_name
                ,  p_entity_processed   => 'RFD' -- Bug 4210718
                ,  p_alternate_bom_code => l_ref_designator_rec.alternate_bom_code -- Bug 4210718
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RFD_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                        l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RFD_RITACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                        l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 10: check that user has access to revised component
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                Bom_Validate_Bom_Component.Check_Access
                (  p_change_notice      => l_ref_designator_rec.ECO_Name
                ,  p_organization_id    => l_ref_desg_unexp_rec.organization_id
                ,  p_revised_item_id    => l_ref_desg_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_ref_designator_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_ref_designator_rec.start_effective_date
                ,  p_new_routing_revsion  => l_ref_designator_rec.new_routing_revision -- Added by MK on 11/02/00
                ,  p_from_end_item_number => l_ref_designator_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_ref_designator_rec.revised_item_name
                ,  p_component_item_id  => l_ref_desg_unexp_rec.component_item_id
                ,  p_operation_seq_num  => l_ref_designator_rec.operation_sequence_number
                ,  p_bill_sequence_id   => l_ref_desg_unexp_rec.bill_sequence_id
                ,  p_component_name     => l_ref_designator_rec.component_item_name
                ,  p_entity_processed   => 'RFD'
                ,  p_rfd_sbc_name       => l_ref_designator_rec.reference_designator_name
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_RFD_CMPACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                        l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_RFD_CMPACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                        l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 8(b): check that user has access to ECO
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                Bom_Validate_Ref_Designator.Check_Access
                (  p_ref_designator_rec => l_ref_designator_rec
                ,  p_ref_desg_unexp_rec => l_ref_desg_unexp_rec
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;

           IF l_ref_designator_rec.transaction_type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

                -- Process flow step 11 - Populate NULL columns for Update and
                -- Delete.

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
                Bom_Default_Ref_Designator.Populate_NULL_Columns
                (   p_ref_designator_rec        => l_ref_designator_rec
                ,   p_old_ref_designator_rec    => l_old_ref_designator_rec
                ,   p_ref_desg_unexp_rec        => l_ref_desg_unexp_rec
                ,   p_old_ref_desg_unexp_rec    => l_old_ref_desg_unexp_rec
                ,   x_ref_designator_rec        => l_ref_designator_rec
                ,   x_ref_desg_unexp_rec        => l_ref_desg_unexp_rec
                );

           END IF;

           -- Process Flow step 12 - Entity Level Validation
           -- Added Check_Entity_Delete by MK on 11/14/00
           --
           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;

           IF l_ref_designator_rec.transaction_type = 'DELETE'
           THEN

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Calling Entity Delete validation'); END IF;

                Bom_Validate_Ref_Designator.Check_Entity_Delete
                (  p_ref_designator_rec         => l_ref_designator_rec
                ,  p_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );
           ELSE
                Bom_Validate_Ref_Designator.Check_Entity
                (  p_ref_designator_rec         => l_ref_designator_rec
                ,  p_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );
           END IF ;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RFD_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Log Error For Warning '); END IF;
           END IF;

           -- Process Flow step 14 : Database Writes
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
           Bom_Ref_Designator_Util.Perform_Writes
                (   p_ref_designator_rec        => l_ref_designator_rec
                ,   p_ref_desg_unexp_rec        => l_ref_desg_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RFD_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                l_other_token_tbl(1).token_value := l_ref_designator_rec.reference_designator_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        x_ref_designator_tbl(I)          := l_ref_designator_rec;

    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        RETURN;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        RETURN;

       WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_ALL
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 5
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        l_return_status := 'U';

        END; -- END block

        IF l_return_status in ('Q', 'U')
        THEN
                x_return_status := l_return_status;
                RETURN;
        END IF;
     END IF; -- End of processing records for which the return status is null
     END LOOP; -- END Reference Designator processing loop

    --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     --x_ref_designator_tbl       := l_ref_designator_tbl;
     --x_sub_component_tbl        := l_sub_component_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;


END Ref_Desgs;

PROCEDURE Process_Rev_Comp
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   p_revised_item_name             IN  VARCHAR2 := NULL
,   p_alternate_bom_code            IN  VARCHAR2 := NULL -- Bug 2429272 Change4(cont..of..ENGSVIDB.pls)
,   p_effectivity_date              IN  DATE := NULL
,   p_item_revision                 IN  VARCHAR2 := NULL
,   p_routing_revision              IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number          IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   I                               IN  NUMBER
,   p_rev_component_rec             IN  BOM_BO_PUB.Rev_Component_Rec_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_comp_unexp_rec            OUT NOCOPY BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
-- Bug 2941096 // kamohan
,   x_bill_sequence_id           IN NUMBER := NULL
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_item_parent_exists    BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_rec               ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_rec     BOM_BO_PUB.Rev_Component_Rec_Type;
--l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type := p_rev_component_tbl;
l_rev_comp_unexp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_old_rev_component_rec BOM_BO_PUB.Rev_Component_Rec_Type;
l_old_rev_comp_unexp_rec BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
--l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
--l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
l_return_value          NUMBER;
l_process_children      BOOLEAN := TRUE;
l_dummy                 NUMBER ;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_structure_type_id     NUMBER ;
l_strc_cp_not_allowed   NUMBER ;

l_rev_operation_tbl      Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl    Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_bo_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_ref_designator_tbl := p_ref_designator_tbl;
    x_sub_component_tbl := p_sub_component_tbl;
    l_rev_comp_unexp_rec.organization_id := ENG_GLOBALS.Get_org_id;

    BEGIN

        --
        --  Load local records.
        --
        l_rev_component_rec := x_rev_component_tbl(I);

        l_rev_component_rec.transaction_type :=
                UPPER(l_rev_component_rec.transaction_type);


        --
        -- make sure to set process_children to false at the start of
        -- every iteration
        --
        l_process_children := FALSE;

        --
        -- Initialize the Unexposed Record for every iteration of the Loop
        -- so that sequence numbers get generated for every new row.
        --
        l_rev_comp_unexp_rec.Component_Item_Id          := NULL;
        l_rev_comp_unexp_rec.Old_Component_Sequence_Id  := NULL;
        l_rev_comp_unexp_rec.Component_Sequence_Id      := NULL;
        l_rev_comp_unexp_rec.Pick_Components            := NULL;
        l_rev_comp_unexp_rec.Supply_Locator_Id          := NULL;
        l_rev_comp_unexp_rec.Revised_Item_Sequence_Id   := NULL;
        l_rev_comp_unexp_rec.Bom_Item_Type              := NULL;
        l_rev_comp_unexp_rec.Revised_Item_Id            := NULL;
        l_rev_comp_unexp_rec.Include_On_Bill_Docs       := NULL;

	-- Bug 2941096 // kamohan
	-- Start changes

	IF x_bill_sequence_id IS NOT NULL THEN
		l_rev_comp_unexp_rec.Bill_Sequence_Id           := x_bill_sequence_id;
	ELSE
		l_rev_comp_unexp_rec.Bill_Sequence_Id           := NULL;
	END IF;

	-- End Changes

        IF p_revised_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                -- revised item parent exists

                l_item_parent_exists := TRUE;
        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

        IF --(l_rev_component_rec.return_status IS NULL OR
            --l_rev_component_rec.return_status = FND_API.G_MISS_CHAR)
           --AND

            -- Did Rev_Items call this procedure, that is,
            -- if revised item exists, then is this record a child ?

            (NOT l_item_parent_exists
             OR
             (l_item_parent_exists AND
              (l_rev_component_rec.ECO_Name = p_change_notice AND
               l_rev_comp_unexp_rec.organization_id = p_organization_id AND
               l_rev_component_rec.revised_item_name = p_revised_item_name AND
               NVL(l_rev_component_rec.alternate_bom_code,'NULL') = NVL(p_alternate_bom_code,'NULL') AND
                                                                          -- Bug 2429272 Change 4
               l_rev_component_rec.start_effective_date = nvl(ENG_Default_Revised_Item.G_OLD_SCHED_DATE,p_effectivity_date) AND -- Bug 6657209
               NVL(l_rev_component_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
               NVL(l_rev_component_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
               NVL(l_rev_component_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR) )))

        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_rev_component_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing component: ' || l_rev_component_rec.component_item_name); END IF;
           -- Check if transaction_type is valid
           --
           -- Bug 6657209
           IF (l_item_parent_exists and ENG_Default_Revised_Item.G_OLD_SCHED_DATE is not null ) THEN
              l_rev_component_rec.start_effective_date := p_effectivity_date;
           END IF;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check transaction_type validity'); END IF;
           ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_rev_component_rec.transaction_type
           ,   p_entity                 => 'Rev_Comps'
           ,   p_entity_id              => l_rev_component_rec.revised_item_name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           -- Process Flow step 4(a): Convert user unique index to unique index I
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index I'); END IF;
           Bom_Val_To_Id.Rev_Component_UUI_To_UI
                ( p_rev_component_rec  => l_rev_component_rec
                , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 4(b): Convert user unique index to unique index II
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index II'); END IF;
           Bom_Val_To_Id.Rev_Component_UUI_To_UI2
                ( p_rev_component_rec  => l_rev_component_rec
                , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_other_message      => l_other_message
                , x_other_token_tbl    => l_other_token_tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CMP_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           IF Bom_Globals.Get_Debug = 'Y' THEN
           Error_Handler.Write_Debug('Converting user unique index to unique index II for Bill And Rev Seq Id');
           END IF;

           ENG_Val_To_Id.BillAndRevitem_UUI_To_UI
           ( p_revised_item_name        => l_rev_component_rec.revised_item_name
           , p_revised_item_id          => l_rev_comp_unexp_rec.revised_item_id
           , p_alternate_bom_code       => l_rev_component_rec.alternate_bom_code -- Bug 2429272 Change 4
           , p_item_revision            => l_rev_component_rec.new_revised_item_revision
           , p_effective_date           => l_rev_component_rec.start_effective_date
           , p_change_notice            => l_rev_component_rec.eco_name
           , p_organization_id          => l_rev_comp_unexp_rec.organization_id
           , p_new_routing_revision     => l_rev_component_rec.new_routing_revision
           , p_from_end_item_number     => l_rev_component_rec.from_end_item_unit_number
           , p_entity_processed         => 'RC'
           , p_component_item_name      => l_rev_component_rec.component_item_name
           , p_transaction_type         => l_rev_component_rec.transaction_type
           , x_revised_item_sequence_id => l_rev_comp_unexp_rec.revised_item_sequence_id
           , x_bill_sequence_id         => l_rev_comp_unexp_rec.bill_sequence_id
           , x_component_sequence_id    => l_dummy
           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
           , x_other_message            => l_other_message
           , x_other_token_tbl          => l_other_token_tbl
           , x_Return_Status            => l_return_status
          ) ;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status) ;
           END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CMP_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           BOM_Globals.Set_Unit_Controlled_Item
           ( p_inventory_item_id => l_rev_comp_unexp_rec.revised_item_id
           , p_organization_id  => l_rev_comp_unexp_rec.organization_id
           );

           BOM_Globals.Set_Unit_Controlled_Component
           ( p_inventory_item_id => l_rev_comp_unexp_rec.component_item_id
           , p_organization_id  => l_rev_comp_unexp_rec.organization_id
           );

           -- Process Flow step 5: Verify Revised Component's existence
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check existence'); END IF;
           Bom_Validate_Bom_Component.Check_Existence
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  x_old_rev_component_rec      => l_old_rev_component_rec
                ,  x_old_rev_comp_unexp_rec     => l_old_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_CMP_EXS_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(2).token_value := l_rev_component_rec.revised_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(2).token_value := l_rev_component_rec.revised_item_name
;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 6: Check lineage
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');          END IF;
           Bom_Validate_Bom_Component.Check_Lineage
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                   l_other_message := 'BOM_CMP_LIN_SEV_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                   l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                   l_other_message := 'ENG_CMP_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                   l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 7: Is Revised Component record an orphan ?

           IF NOT l_item_parent_exists
           THEN

                -- Process Flow step 8(a and b): Is ECO impl/cancl, or in wkflw process ?
                --

                ENG_Validate_ECO.Check_Access
                (  p_change_notice      => l_rev_component_rec.ECO_Name
                ,  p_organization_id    => l_rev_comp_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 9(a and b): check that user has access to revised item
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                ENG_Validate_Revised_Item.Check_Access
                (  p_change_notice      => l_rev_component_rec.ECO_Name
                ,  p_organization_id    => l_rev_comp_unexp_rec.organization_id
                ,  p_revised_item_id    => l_rev_comp_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_rev_component_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_rev_component_rec.start_effective_date
                ,  p_new_routing_revsion   => l_rev_component_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_rev_component_rec.revised_item_name
                ,  p_entity_processed   => 'RC'
                ,  p_alternate_bom_code => l_rev_component_rec.alternate_bom_code -- Bug 4210718
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;
                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_RITACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 10: check that user has access to revised component
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                Bom_Validate_Bom_Component.Check_Access
                (  p_change_notice      => l_rev_component_rec.ECO_Name
                ,  p_organization_id    => l_rev_comp_unexp_rec.organization_id
                ,  p_revised_item_id    => l_rev_comp_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_rev_component_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_rev_component_rec.start_effective_date
                ,  p_new_routing_revsion  => l_rev_component_rec.new_routing_revision -- Added by MK on 11/02/00
                ,  p_from_end_item_number => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_rev_component_rec.revised_item_name
                ,  p_component_item_id  => l_rev_comp_unexp_rec.component_item_id
                ,  p_operation_seq_num  => l_rev_component_rec.operation_sequence_number
                ,  p_bill_sequence_id   => l_rev_comp_unexp_rec.bill_sequence_id
                ,  p_component_name     => l_rev_component_rec.component_item_name
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           ELSE
           -- Bug No: 5246049
           -- Structure policy check should happen even if parent exists
                l_structure_type_id := NULL;
                l_strc_cp_not_allowed := 2;

                ENG_Validate_Revised_Item.Check_Structure_Type_Policy
                    ( p_inventory_item_id   => l_rev_comp_unexp_rec.revised_item_id
                    , p_organization_id     => l_rev_comp_unexp_rec.organization_id
                    , p_alternate_bom_code  => l_rev_component_rec.alternate_bom_code
                    , x_structure_type_id   => l_structure_type_id
                    , x_strc_cp_not_allowed => l_strc_cp_not_allowed
                    );
                IF l_strc_cp_not_allowed = 1
                THEN
                        l_return_status := Error_Handler.G_STATUS_ERROR ;
                        l_Token_Tbl.DELETE;
                        l_Token_Tbl(1).token_name := 'STRUCTURE_NAME';
                        l_Token_Tbl(1).token_value := l_rev_component_rec.alternate_bom_code;

                        Error_Handler.Add_Error_Token
                        ( p_message_name       => 'ENG_BILL_CHANGES_NOT_ALLOWED'
                        , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl          => l_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );

                        l_other_message := 'BOM_CMP_QRY_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                END IF;


           END IF;

           -- Process Flow step 11: Value to Id conversions
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Value-id conversions'); END IF;
           Bom_Val_To_Id.Rev_Component_VID
                ( x_Return_Status       => l_return_status
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , p_rev_comp_unexp_Rec  => l_rev_comp_unexp_rec
                , x_rev_comp_unexp_Rec  => l_rev_comp_unexp_rec
                , p_rev_component_Rec   => l_rev_component_rec
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_rev_component_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'BOM_CMP_VID_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_VID_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

           -- Process Flow step 12: Check required fields exist
           -- (also includes conditionally required fields)
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check required fields'); END IF;
           Bom_Validate_Bom_Component.Check_Required
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_rev_component_rec          => l_rev_component_rec
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_rev_component_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'BOM_CMP_REQ_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_REQ_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

           -- Process Flow step 13: Attribute Validation for CREATE and UPDATE
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation'); END IF;
           IF l_rev_component_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                Bom_Validate_Bom_Component.Check_Attributes
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_rev_component_rec          => l_rev_component_rec
                , p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_rev_component_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'BOM_CMP_ATTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_QUIT_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'BOM_CMP_ATTVAL_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                   l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                   Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 4
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           IF (l_rev_component_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
               AND l_rev_component_rec.acd_type IN ( 2, 3 ))
           THEN

                Bom_Bom_Component_Util.Query_Row
                   ( p_component_item_id
                                => l_rev_comp_unexp_rec.component_item_id
                   , p_operation_sequence_number
                                => l_rev_component_rec.old_operation_sequence_number
                   , p_effectivity_date
                                => l_rev_component_rec.old_effectivity_date
                   , p_from_end_item_number
                               => l_rev_component_rec.old_from_end_item_unit_number
                   , p_bill_sequence_id
                                => l_rev_comp_unexp_rec.bill_sequence_id
                   , x_Rev_Component_Rec
                                => l_old_rev_component_rec
                   , x_Rev_Comp_Unexp_Rec
                                => l_old_rev_comp_unexp_rec
                   , x_return_status
                                => l_return_status
                   , p_mesg_token_tbl   =>
                        l_mesg_token_tbl
                   , x_mesg_token_tbl   => l_mesg_token_tbl
                   );

                IF l_return_status <> Eng_Globals.G_RECORD_FOUND
                THEN
                        l_return_status := Error_Handler.G_STATUS_ERROR ;
                        l_Token_Tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_Token_Tbl(1).token_value := l_rev_component_rec.component_item_name;

                        Error_Handler.Add_Error_Token
                        ( p_message_name       => 'ENG_CMP_CREATE_REC_NOT_FOUND' --'BOM_CMP_CREATE_REC_NOT_FOUND' -- Bug 3612008 :Modified incorrect message_name
                        , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl          => l_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );

                        l_other_message := 'BOM_CMP_QRY_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_QRY_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
            END IF;

            -- Process flow step 15 - Populate NULL columns for Update and
            -- Delete, and Creates with ACD_Type 'Add'.

            IF (l_rev_component_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                AND l_rev_component_rec.acd_type = 2)
               OR
               l_rev_component_rec.transaction_type IN (ENG_GLOBALS.G_OPR_UPDATE,
                                                        ENG_GLOBALS.G_OPR_DELETE)
            THEN
                    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns'); END IF;
                    Bom_Default_Bom_Component.Populate_Null_Columns
                    (   p_rev_component_rec     => l_rev_Component_Rec
                    ,   p_old_rev_Component_Rec => l_old_rev_Component_Rec
                    ,   p_rev_comp_unexp_rec    => l_rev_comp_unexp_rec
                    ,   p_old_rev_comp_unexp_rec=> l_old_rev_comp_unexp_rec
                    ,   x_rev_Component_Rec     => l_rev_Component_Rec
                    ,   x_rev_comp_unexp_rec    => l_rev_comp_unexp_rec
                    );

           ELSIF l_rev_component_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

                -- Process Flow step 16: Default missing values for Operation CREATE
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
                Bom_Default_Bom_Component.Attribute_Defaulting
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_rev_component_rec         => l_rev_component_rec
                ,   x_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_ATTDEF_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ATTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 4
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           -- Process Flow step 17: Entity defaulting for CREATE and UPDATE
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting'); END IF;
           IF l_rev_component_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                Bom_Default_Bom_Component.Entity_Defaulting
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_old_rev_component_rec     => l_old_rev_component_rec
                ,   x_rev_component_rec         => l_rev_component_rec
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_rev_component_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'BOM_CMP_ENTDEF_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ENTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 4
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           -- Process Flow step 18 - Entity Level Validation
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;
           Bom_Validate_Bom_Component.Check_Entity
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  p_old_rev_component_rec      => l_old_rev_component_rec
                ,  p_old_rev_comp_unexp_rec     => l_old_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           --IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_rev_component_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'BOM_CMP_ENTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_QUIT_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

           -- Process Flow step 16 : Database Writes
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
           BOM_Globals.Set_BO_Identifier('ECO');  --bug 13849573
           Bom_Bom_Component_Util.Perform_Writes
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;


                -- END IF; -- END IF statement that checks RETURN STATUS

                --  Load tables.

                x_rev_component_tbl(I)          := l_rev_component_rec;

                -- Indicate that children need to be processed

                l_process_children := TRUE;
                -- END IF;


        ELSE


IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('This record does not patch with the parent that called it . . .  ') ;
    Error_Handler.Write_Debug('so may be this is an comp in another branch . . . '
                               || l_rev_component_rec.component_item_name ) ;
END IF ;

                l_process_children := FALSE;

        END IF; -- END IF statement that checks RETURN STATUS


    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => FND_API.G_RET_STS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := TRUE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rev_comp_unexp_rec           := l_rev_comp_unexp_rec;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rev_comp_unexp_rec           := l_rev_comp_unexp_rec;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_SKIP_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rev_comp_unexp_rec           := l_rev_comp_unexp_rec;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rev_comp_unexp_rec           := l_rev_comp_unexp_rec;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_FAT_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rev_comp_unexp_rec           := l_rev_comp_unexp_rec;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_rev_comp_unexp_rec           := l_rev_comp_unexp_rec;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
       WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_ALL
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected error caught in Rev Comps . . . '); END IF;

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        l_return_status := 'U';

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected error in Rev Comps . . .'); END IF;

        END; -- END block

        IF l_return_status in ('Q', 'U')
        THEN
                x_return_status := l_return_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rev Comps returning with status ' || l_return_status ); END IF;

                RETURN;
        END IF;

   IF l_process_children
   THEN
        -- Process Reference Designators that are direct children of this
        -- component

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Now processing direct children for the Rev Comp '
                              || l_rev_component_rec.component_item_name || '. . .'  );
    Error_Handler.Write_Debug('Now processing Ref Desig as direct children for the Rev Comp ') ;
END IF;


        Ref_Desgs
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_rev_component_rec.ECO_Name
        ,   p_organization_id           => l_rev_comp_unexp_rec.organization_id
        ,   p_revised_item_name         => l_rev_component_rec.revised_item_name
        ,   p_alternate_bom_code        => l_rev_component_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_rev_component_rec.start_effective_date
        ,   p_item_revision             => l_rev_component_rec.new_revised_item_revision
        ,   p_routing_revision          => l_rev_component_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_component_item_name       => l_rev_component_rec.component_item_name
        ,   p_operation_seq_num         => l_rev_component_rec.operation_sequence_number
        ,   p_ref_designator_tbl        => x_ref_designator_tbl
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_ref_designator_tbl        => x_ref_designator_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

        -- Process Substitute Components that are direct children of this
        -- component

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Now processing Ref Desig as direct children for the Rev Comp ') ;
END IF ;

        Sub_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_rev_component_rec.ECO_Name
        ,   p_organization_id           => l_rev_comp_unexp_rec.organization_id
        ,   p_revised_item_name         => l_rev_component_rec.revised_item_name
        ,   p_alternate_bom_code        => l_rev_component_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_rev_component_rec.start_effective_date
        ,   p_item_revision             => l_rev_component_rec.new_revised_item_revision
        ,   p_routing_revision          => l_rev_component_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_component_item_name       => l_rev_component_rec.component_item_name
        ,   p_operation_seq_num         => l_rev_component_rec.operation_sequence_number
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished processing children for ' || l_rev_component_rec.component_item_name || ' . . . ' || l_return_status ); END IF;

    END IF;  -- Process children
    x_return_status            := l_bo_return_status;
    x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;
    x_rev_comp_unexp_rec       := l_rev_comp_unexp_rec;


END Process_Rev_Comp;

--  Rev_Comps

PROCEDURE Rev_Comps
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   p_revised_item_name             IN  VARCHAR2 := NULL
,   p_alternate_bom_code            IN  VARCHAR2 := NULL -- Bug 2429272 Change4(cont..of..ENGSVIDB.pls)
,   p_effectivity_date              IN  DATE := NULL
,   p_item_revision                 IN  VARCHAR2 := NULL
,   p_routing_revision              IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_from_end_item_number          IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
-- Bug 2941096 // kamohan
,   x_bill_sequence_id           IN NUMBER := NULL
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_item_parent_exists    BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_rec               ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_rec     BOM_BO_PUB.Rev_Component_Rec_Type;
--l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type := p_rev_component_tbl;
l_rev_comp_unexp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_old_rev_component_rec BOM_BO_PUB.Rev_Component_Rec_Type;
l_old_rev_comp_unexp_rec BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
--l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
--l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
l_return_value          NUMBER;
l_process_children      BOOLEAN := TRUE;
l_dummy                 NUMBER ;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_structure_type_id     NUMBER ;
l_strc_cp_not_allowed   NUMBER ;

l_rev_operation_tbl      Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl    Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    --  Init local table variables.

    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_bo_return_status := FND_API.G_RET_STS_SUCCESS;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --l_rev_component_tbl            := p_rev_component_tbl;
    x_rev_component_tbl            := p_rev_component_tbl;
    x_ref_designator_tbl           := p_ref_designator_tbl;
    x_sub_component_tbl            := p_sub_component_tbl;

    l_rev_comp_unexp_rec.organization_id := ENG_GLOBALS.Get_org_id;

    FOR I IN 1..x_rev_component_tbl.COUNT LOOP
    IF (x_rev_component_tbl(I).return_status IS NULL OR
         x_rev_component_tbl(I).return_status = FND_API.G_MISS_CHAR) THEN

    BEGIN

        --
        --  Load local records.
        --
        l_rev_component_rec := x_rev_component_tbl(I);

        l_rev_component_rec.transaction_type :=
                UPPER(l_rev_component_rec.transaction_type);


        --
        -- make sure to set process_children to false at the start of
        -- every iteration
        --
        l_process_children := FALSE;

        --
        -- Initialize the Unexposed Record for every iteration of the Loop
        -- so that sequence numbers get generated for every new row.
        --
        l_rev_comp_unexp_rec.Component_Item_Id          := NULL;
        l_rev_comp_unexp_rec.Old_Component_Sequence_Id  := NULL;
        l_rev_comp_unexp_rec.Component_Sequence_Id      := NULL;
        l_rev_comp_unexp_rec.Pick_Components            := NULL;
        l_rev_comp_unexp_rec.Supply_Locator_Id          := NULL;
        l_rev_comp_unexp_rec.Revised_Item_Sequence_Id   := NULL;
        l_rev_comp_unexp_rec.Bom_Item_Type              := NULL;
        l_rev_comp_unexp_rec.Revised_Item_Id            := NULL;
        l_rev_comp_unexp_rec.Include_On_Bill_Docs       := NULL;

	-- Bug 2941096 // kamohan
	-- Start changes

	IF x_bill_sequence_id IS NOT NULL THEN
		l_rev_comp_unexp_rec.Bill_Sequence_Id           := x_bill_sequence_id;
	ELSE
		l_rev_comp_unexp_rec.Bill_Sequence_Id           := NULL;
	END IF;

	-- End Changes

        IF p_revised_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                -- revised item parent exists

                l_item_parent_exists := TRUE;
        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

        IF --(l_rev_component_rec.return_status IS NULL OR
            --l_rev_component_rec.return_status = FND_API.G_MISS_CHAR)
           --AND

            -- Did Rev_Items call this procedure, that is,
            -- if revised item exists, then is this record a child ?

            (NOT l_item_parent_exists
             OR
             (l_item_parent_exists AND
              (l_rev_component_rec.ECO_Name = p_change_notice AND
               l_rev_comp_unexp_rec.organization_id = p_organization_id AND
               l_rev_component_rec.revised_item_name = p_revised_item_name AND
               NVL(l_rev_component_rec.alternate_bom_code,'NULL') = NVL(p_alternate_bom_code,'NULL') AND
                                                                          -- Bug 2429272 Change 4
               l_rev_component_rec.start_effective_date = nvl(ENG_Default_Revised_Item.G_OLD_SCHED_DATE,p_effectivity_date) AND -- Bug 6657209
               NVL(l_rev_component_rec.new_routing_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_routing_revision, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
               NVL(l_rev_component_rec.from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                             =   NVL(p_from_end_item_number, FND_API.G_MISS_CHAR ) AND -- Added by MK on 11/02/00
               NVL(l_rev_component_rec.new_revised_item_revision, FND_API.G_MISS_CHAR )
                                             =   NVL(p_item_revision, FND_API.G_MISS_CHAR) )))

        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_rev_component_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing component: ' || l_rev_component_rec.component_item_name); END IF;
           -- Check if transaction_type is valid
           --
           -- Bug 6657209
           IF (l_item_parent_exists and ENG_Default_Revised_Item.G_OLD_SCHED_DATE is not null ) THEN
              l_rev_component_rec.start_effective_date := p_effectivity_date;
           END IF;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check transaction_type validity'); END IF;
           ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_rev_component_rec.transaction_type
           ,   p_entity                 => 'Rev_Comps'
           ,   p_entity_id              => l_rev_component_rec.revised_item_name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           -- Process Flow step 4(a): Convert user unique index to unique index I
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index I'); END IF;
           Bom_Val_To_Id.Rev_Component_UUI_To_UI
                ( p_rev_component_rec  => l_rev_component_rec
                , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_CMP_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 4(b): Convert user unique index to unique index II
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index II'); END IF;
           Bom_Val_To_Id.Rev_Component_UUI_To_UI2
                ( p_rev_component_rec  => l_rev_component_rec
                , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_other_message      => l_other_message
                , x_other_token_tbl    => l_other_token_tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CMP_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           IF Bom_Globals.Get_Debug = 'Y' THEN
           Error_Handler.Write_Debug('Converting user unique index to unique index II for Bill And Rev Seq Id');
           END IF;

           ENG_Val_To_Id.BillAndRevitem_UUI_To_UI
           ( p_revised_item_name        => l_rev_component_rec.revised_item_name
           , p_revised_item_id          => l_rev_comp_unexp_rec.revised_item_id
           , p_alternate_bom_code       => l_rev_component_rec.alternate_bom_code -- Bug 2429272 Change 4
           , p_item_revision            => l_rev_component_rec.new_revised_item_revision
           , p_effective_date           => l_rev_component_rec.start_effective_date
           , p_change_notice            => l_rev_component_rec.eco_name
           , p_organization_id          => l_rev_comp_unexp_rec.organization_id
           , p_new_routing_revision     => l_rev_component_rec.new_routing_revision
           , p_from_end_item_number     => l_rev_component_rec.from_end_item_unit_number
           , p_entity_processed         => 'RC'
           , p_component_item_name      => l_rev_component_rec.component_item_name
           , p_transaction_type         => l_rev_component_rec.transaction_type
           , x_revised_item_sequence_id => l_rev_comp_unexp_rec.revised_item_sequence_id
           , x_bill_sequence_id         => l_rev_comp_unexp_rec.bill_sequence_id
           , x_component_sequence_id    => l_dummy
           , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
           , x_other_message            => l_other_message
           , x_other_token_tbl          => l_other_token_tbl
           , x_Return_Status            => l_return_status
          ) ;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status) ;
           END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_SIBLINGS;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CMP_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           BOM_Globals.Set_Unit_Controlled_Item
           ( p_inventory_item_id => l_rev_comp_unexp_rec.revised_item_id
           , p_organization_id  => l_rev_comp_unexp_rec.organization_id
           );

           BOM_Globals.Set_Unit_Controlled_Component
           ( p_inventory_item_id => l_rev_comp_unexp_rec.component_item_id
           , p_organization_id  => l_rev_comp_unexp_rec.organization_id
           );

           -- Process Flow step 5: Verify Revised Component's existence
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check existence'); END IF;
           Bom_Validate_Bom_Component.Check_Existence
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  x_old_rev_component_rec      => l_old_rev_component_rec
                ,  x_old_rev_comp_unexp_rec     => l_old_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_CMP_EXS_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(2).token_value := l_rev_component_rec.revised_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(2).token_value := l_rev_component_rec.revised_item_name
;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 6: Check lineage
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');          END IF;
           Bom_Validate_Bom_Component.Check_Lineage
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                   l_other_message := 'BOM_CMP_LIN_SEV_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                   l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                   l_other_message := 'ENG_CMP_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                   l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 7: Is Revised Component record an orphan ?

           IF NOT l_item_parent_exists
           THEN

                -- Process Flow step 8(a and b): Is ECO impl/cancl, or in wkflw process ?
                --

                ENG_Validate_ECO.Check_Access
                (  p_change_notice      => l_rev_component_rec.ECO_Name
                ,  p_organization_id    => l_rev_comp_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 9(a and b): check that user has access to revised item
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                ENG_Validate_Revised_Item.Check_Access
                (  p_change_notice      => l_rev_component_rec.ECO_Name
                ,  p_organization_id    => l_rev_comp_unexp_rec.organization_id
                ,  p_revised_item_id    => l_rev_comp_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_rev_component_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_rev_component_rec.start_effective_date
                ,  p_new_routing_revsion   => l_rev_component_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_rev_component_rec.revised_item_name
                ,  p_entity_processed   => 'RC'
                ,  p_alternate_bom_code => l_rev_component_rec.alternate_bom_code -- Bug 4210718
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;
                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_RITACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_SIBLINGS;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_RITACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 10: check that user has access to revised component
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                Bom_Validate_Bom_Component.Check_Access
                (  p_change_notice      => l_rev_component_rec.ECO_Name
                ,  p_organization_id    => l_rev_comp_unexp_rec.organization_id
                ,  p_revised_item_id    => l_rev_comp_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_rev_component_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_rev_component_rec.start_effective_date
                ,  p_new_routing_revsion  => l_rev_component_rec.new_routing_revision -- Added by MK on 11/02/00
                ,  p_from_end_item_number => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_rev_component_rec.revised_item_name
                ,  p_component_item_id  => l_rev_comp_unexp_rec.component_item_id
                ,  p_operation_seq_num  => l_rev_component_rec.operation_sequence_number
                ,  p_bill_sequence_id   => l_rev_comp_unexp_rec.bill_sequence_id
                ,  p_component_name     => l_rev_component_rec.component_item_name
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           ELSE
           -- Bug No: 5246049
           -- Structure policy check should happen even if parent exists
                l_structure_type_id := NULL;
                l_strc_cp_not_allowed := 2;

                ENG_Validate_Revised_Item.Check_Structure_Type_Policy
                    ( p_inventory_item_id   => l_rev_comp_unexp_rec.revised_item_id
                    , p_organization_id     => l_rev_comp_unexp_rec.organization_id
                    , p_alternate_bom_code  => l_rev_component_rec.alternate_bom_code
                    , x_structure_type_id   => l_structure_type_id
                    , x_strc_cp_not_allowed => l_strc_cp_not_allowed
                    );
                IF l_strc_cp_not_allowed = 1
                THEN
                        l_return_status := Error_Handler.G_STATUS_ERROR ;
                        l_Token_Tbl.DELETE;
                        l_Token_Tbl(1).token_name := 'STRUCTURE_NAME';
                        l_Token_Tbl(1).token_value := l_rev_component_rec.alternate_bom_code;

                        Error_Handler.Add_Error_Token
                        ( p_message_name       => 'ENG_BILL_CHANGES_NOT_ALLOWED'
                        , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl          => l_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );

                        l_other_message := 'BOM_CMP_QRY_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                END IF;
           END IF;

           -- Process Flow step 11: Value to Id conversions
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Value-id conversions'); END IF;
           Bom_Val_To_Id.Rev_Component_VID
                ( x_Return_Status       => l_return_status
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , p_rev_comp_unexp_Rec  => l_rev_comp_unexp_rec
                , x_rev_comp_unexp_Rec  => l_rev_comp_unexp_rec
                , p_rev_component_Rec   => l_rev_component_rec
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_rev_component_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'BOM_CMP_VID_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_VID_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

           -- Process Flow step 12: Check required fields exist
           -- (also includes conditionally required fields)
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check required fields'); END IF;
           Bom_Validate_Bom_Component.Check_Required
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_rev_component_rec          => l_rev_component_rec
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_rev_component_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'BOM_CMP_REQ_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_REQ_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

           -- Process Flow step 13: Attribute Validation for CREATE and UPDATE
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation'); END IF;
           IF l_rev_component_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                Bom_Validate_Bom_Component.Check_Attributes
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_rev_component_rec          => l_rev_component_rec
                , p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_rev_component_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'BOM_CMP_ATTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_QUIT_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'BOM_CMP_ATTVAL_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                   l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                   Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 4
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           IF (l_rev_component_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
               AND l_rev_component_rec.acd_type IN ( 2, 3 ))
           THEN

                Bom_Bom_Component_Util.Query_Row
                   ( p_component_item_id
                                => l_rev_comp_unexp_rec.component_item_id
                   , p_operation_sequence_number
                                => l_rev_component_rec.old_operation_sequence_number
                   , p_effectivity_date
                                => l_rev_component_rec.old_effectivity_date
                   , p_from_end_item_number
                               => l_rev_component_rec.old_from_end_item_unit_number
                   , p_bill_sequence_id
                                => l_rev_comp_unexp_rec.bill_sequence_id
                   , x_Rev_Component_Rec
                                => l_old_rev_component_rec
                   , x_Rev_Comp_Unexp_Rec
                                => l_old_rev_comp_unexp_rec
                   , x_return_status
                                => l_return_status
                   , p_mesg_token_tbl   =>
                        l_mesg_token_tbl
                   , x_mesg_token_tbl   => l_mesg_token_tbl
                   );

                IF l_return_status <> Eng_Globals.G_RECORD_FOUND
                THEN
                        l_return_status := Error_Handler.G_STATUS_ERROR ;
                        l_Token_Tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_Token_Tbl(1).token_value := l_rev_component_rec.component_item_name;

                        Error_Handler.Add_Error_Token
                        ( p_message_name       => 'ENG_CMP_CREATE_REC_NOT_FOUND' --'BOM_CMP_CREATE_REC_NOT_FOUND' -- Bug 3612008 :Modified incorrect message_name
                        , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl          => l_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );

                        l_other_message := 'BOM_CMP_QRY_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_QRY_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
            END IF;

            -- Process flow step 15 - Populate NULL columns for Update and
            -- Delete, and Creates with ACD_Type 'Add'.

            IF (l_rev_component_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                AND l_rev_component_rec.acd_type = 2)
               OR
               l_rev_component_rec.transaction_type IN (ENG_GLOBALS.G_OPR_UPDATE,
                                                        ENG_GLOBALS.G_OPR_DELETE)
            THEN
                    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns'); END IF;
                    Bom_Default_Bom_Component.Populate_Null_Columns
                    (   p_rev_component_rec     => l_rev_Component_Rec
                    ,   p_old_rev_Component_Rec => l_old_rev_Component_Rec
                    ,   p_rev_comp_unexp_rec    => l_rev_comp_unexp_rec
                    ,   p_old_rev_comp_unexp_rec=> l_old_rev_comp_unexp_rec
                    ,   x_rev_Component_Rec     => l_rev_Component_Rec
                    ,   x_rev_comp_unexp_rec    => l_rev_comp_unexp_rec
                    );

           ELSIF l_rev_component_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

                -- Process Flow step 16: Default missing values for Operation CREATE
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
                Bom_Default_Bom_Component.Attribute_Defaulting
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_rev_component_rec         => l_rev_component_rec
                ,   x_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'BOM_CMP_ATTDEF_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ATTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 4
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           -- Process Flow step 17: Entity defaulting for CREATE and UPDATE
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting'); END IF;
           IF l_rev_component_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                Bom_Default_Bom_Component.Entity_Defaulting
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_old_rev_component_rec     => l_old_rev_component_rec
                ,   x_rev_component_rec         => l_rev_component_rec
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_rev_component_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'BOM_CMP_ENTDEF_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'BOM_CMP_ENTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 4
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                        );
                END IF;
           END IF;

           -- Process Flow step 18 - Entity Level Validation
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;
           Bom_Validate_Bom_Component.Check_Entity
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  p_old_rev_component_rec      => l_old_rev_component_rec
                ,  p_old_rev_comp_unexp_rec     => l_old_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           --IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_rev_component_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'BOM_CMP_ENTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                        RAISE EXC_SEV_QUIT_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;

           -- Process Flow step 16 : Database Writes
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
           BOM_Globals.Set_BO_Identifier('ECO');  --bug 13849573
           Bom_Bom_Component_Util.Perform_Writes
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_CMP_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(1).token_value := l_rev_component_rec.component_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );
           END IF;


                -- END IF; -- END IF statement that checks RETURN STATUS

                --  Load tables.

                x_rev_component_tbl(I)          := l_rev_component_rec;

                -- Indicate that children need to be processed

                l_process_children := TRUE;
                -- END IF;


        ELSE


IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('This record does not patch with the parent that called it . . .  ') ;
    Error_Handler.Write_Debug('so may be this is an comp in another branch . . . '
                               || l_rev_component_rec.component_item_name ) ;
END IF ;

                l_process_children := FALSE;

        END IF; -- END IF statement that checks RETURN STATUS


    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => FND_API.G_RET_STS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := TRUE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_SKIP_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_FAT_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        l_process_children := FALSE;

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

       WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope        => Error_Handler.G_SCOPE_ALL
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected error caught in Rev Comps . . . '); END IF;

        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 4
                ,  p_entity_index       => I
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl   --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl--L1
                );

        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        l_return_status := 'U';

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected error in Rev Comps . . .'); END IF;

        END; -- END block

        IF l_return_status in ('Q', 'U')
        THEN
                x_return_status := l_return_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rev Comps returning with status ' || l_return_status ); END IF;

                RETURN;
        END IF;

   IF l_process_children
   THEN
        -- Process Reference Designators that are direct children of this
        -- component

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Now processing direct children for the Rev Comp '
                              || l_rev_component_rec.component_item_name || '. . .'  );
    Error_Handler.Write_Debug('Now processing Ref Desig as direct children for the Rev Comp ') ;
END IF;


        Ref_Desgs
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_rev_component_rec.ECO_Name
        ,   p_organization_id           => l_rev_comp_unexp_rec.organization_id
        ,   p_revised_item_name         => l_rev_component_rec.revised_item_name
        ,   p_alternate_bom_code        => l_rev_component_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_rev_component_rec.start_effective_date
        ,   p_item_revision             => l_rev_component_rec.new_revised_item_revision
        ,   p_routing_revision          => l_rev_component_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_component_item_name       => l_rev_component_rec.component_item_name
        ,   p_operation_seq_num         => l_rev_component_rec.operation_sequence_number
        ,   p_ref_designator_tbl        => x_ref_designator_tbl
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_ref_designator_tbl        => x_ref_designator_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

        -- Process Substitute Components that are direct children of this
        -- component

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Now processing Ref Desig as direct children for the Rev Comp ') ;
END IF ;

        Sub_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_rev_component_rec.ECO_Name
        ,   p_organization_id           => l_rev_comp_unexp_rec.organization_id
        ,   p_revised_item_name         => l_rev_component_rec.revised_item_name
        ,   p_alternate_bom_code        => l_rev_component_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_rev_component_rec.start_effective_date
        ,   p_item_revision             => l_rev_component_rec.new_revised_item_revision
        ,   p_routing_revision          => l_rev_component_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_rev_component_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_component_item_name       => l_rev_component_rec.component_item_name
        ,   p_operation_seq_num         => l_rev_component_rec.operation_sequence_number
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished processing children for ' || l_rev_component_rec.component_item_name || ' . . . ' || l_return_status ); END IF;

    END IF;  -- Process children
    END IF; -- End of processing records for which the return status is null
    END LOOP; -- END Revised Components processing loop

    --  Load OUT parameters

        IF NVL(l_bo_return_status, 'S') <> 'S'
     THEN
IF Bom_Globals.Get_Debug = 'Y' THEN
        Error_Handler.write_Debug('Return status before returning from Rev Comps: ' || l_bo_return_status);
END IF;
        x_return_status     := l_bo_return_status;

     END IF;

     --x_rev_component_tbl        := l_rev_component_tbl;
     --x_ref_designator_tbl       := l_ref_designator_tbl;
     --x_sub_component_tbl        := l_sub_component_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Rev_Comps;

--  Process_Rev_Item
PROCEDURE Process_Rev_Item
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   I                               IN  NUMBER
,   p_revised_item_rec              IN  ENG_Eco_PUB.Revised_Item_Rec_Type
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl             IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   p_rev_op_resource_tbl           IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   p_rev_sub_resource_tbl          IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   x_rev_op_resource_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   x_rev_sub_resource_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_revised_item_unexp_rec        OUT NOCOPY ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_disable_revision              OUT NOCOPY NUMBER --Bug no:3034642
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_eco_parent_exists     BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_rec               ENG_Eco_PUB.Eco_Rec_Type;
l_old_eco_rec           ENG_Eco_PUB.Eco_Rec_Type;
l_old_eco_unexp_rec     ENG_Eco_PUB.Eco_Unexposed_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_rec      ENG_Eco_PUB.Revised_Item_Rec_Type;
--l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type := p_revised_item_tbl;
l_rev_item_unexp_rec    ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type;
l_rev_item_miss_rec     ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type;
l_old_revised_item_rec  ENG_Eco_PUB.Revised_Item_Rec_Type;
l_old_rev_item_unexp_rec ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type;
--l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type := p_rev_component_tbl;
--l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
--l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
--l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type := p_rev_operation_tbl;  --L1
--l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type :=p_rev_op_resource_tbl; --L1
--l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type :=p_rev_sub_resource_tbl; --L1
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

l_process_children      BOOLEAN := TRUE;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_QUIT_OBJECT     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

	-- Bug 2918350 // kamohan
	-- Start Changes

	l_chk_co_sch eng_engineering_changes.status_type%TYPE;

	-- End Changes

BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_bo_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_rev_component_tbl    := p_rev_component_tbl;
    x_ref_designator_tbl   := p_ref_designator_tbl;
    x_sub_component_tbl    := p_sub_component_tbl;
    x_rev_operation_tbl    := p_rev_operation_tbl;  --L1
    x_rev_op_resource_tbl  := p_rev_op_resource_tbl; --L1
    x_rev_sub_resource_tbl := p_rev_sub_resource_tbl; --L1
    BEGIN
        --  Load local records.

        l_revised_item_rec := p_revised_item_rec;



        -- make sure that the unexposed record does not have remains of
        -- any previous processing. This could be possible in the consequent
        -- iterations of this loop
        l_rev_item_unexp_rec := l_rev_item_miss_rec;
        l_Rev_Item_Unexp_Rec.organization_id := ENG_GLOBALS.Get_org_id;


        l_revised_item_rec.transaction_type :=
                UPPER(l_revised_item_rec.transaction_type);

        --
        -- be sure to set the process_children to false at the start of each
        -- iteration to avoid faulty processing of children at the end of the loop
        --
        l_process_children := FALSE;

        IF p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                l_eco_parent_exists := TRUE;
        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Revised Item . . . ' || l_revised_item_rec.revised_item_name); END IF;

        IF --(l_revised_item_rec.return_status IS NULL OR
            --l_revised_item_rec.return_status = FND_API.G_MISS_CHAR)
           --AND
           (NOT l_eco_parent_exists
            OR
            (l_eco_parent_exists AND
             (l_revised_item_rec.ECO_Name = p_change_notice AND
              l_rev_item_unexp_rec.organization_id = p_organization_id)))
        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_revised_item_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           -- Check if transaction_type is valid
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check transaction_type validity'); END IF;
           ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_revised_item_rec.transaction_type
           ,   p_entity                 => 'Rev_Items'
           ,   p_entity_id              => l_revised_item_rec.revised_item_name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           -- Process Flow step 4: Convert user unique index to unique index
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index'); END IF;
           ENG_Val_To_Id.Revised_Item_UUI_To_UI
                ( p_revised_item_rec   => l_revised_item_rec
                , p_rev_item_unexp_rec => l_rev_item_unexp_rec
                , x_rev_item_unexp_rec => l_rev_item_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'ENG_RIT_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           BOM_Globals.Set_Unit_Controlled_Item
           ( p_inventory_item_id => l_rev_item_unexp_rec.revised_item_id
           , p_organization_id  => l_rev_item_unexp_rec.organization_id
           );

           -- Process Flow step 5: Verify ECO's existence in database, if
           -- the revised item is being created on an ECO and the business
           -- object does not carry the ECO header

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check parent existence'); END IF;

           IF l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
              AND
              NOT l_eco_parent_exists
           THEN
                ENG_Validate_ECO.Check_Existence
                ( p_change_notice       => l_revised_item_rec.ECO_Name
                , p_organization_id     => l_rev_item_unexp_rec.organization_id
                , p_organization_code   => l_revised_item_rec.organization_code
                , p_calling_entity      => 'CHILD'
                , p_transaction_type    => 'XXX'
                , x_eco_rec             => l_old_eco_rec
                , x_eco_unexp_rec       => l_old_eco_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'ENG_PARENTECO_NOT_EXIST';
                   l_other_token_tbl(1).token_name := 'ECO_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.ECO_Name;
                   l_other_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                   l_other_token_tbl(2).token_value := l_revised_item_rec.organization_code;
                   RAISE EXC_SEV_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'ENG_RIT_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;

         IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

	-- Bug 2918350
	-- Start Changes
	IF p_change_notice IS NOT NULL AND p_organization_id IS NOT NULL THEN
		l_chk_co_sch := ret_co_status ( p_change_notice, p_organization_id);
	ELSE
		l_chk_co_sch := ret_co_status ( l_revised_item_rec.eco_name, l_rev_item_unexp_rec.organization_id);
	END IF;

	IF l_chk_co_sch = 4 THEN
		l_return_status := error_handler.g_status_error;
		error_handler.add_error_token (p_message_name        => 'ENG_REV_ITM_NOT_UPD',
			p_mesg_token_tbl      => l_mesg_token_tbl,
			x_mesg_token_tbl      => l_mesg_token_tbl,
			p_token_tbl           => l_token_tbl
			);
		RAISE exc_sev_quit_record;
	END IF;

	-- End Changes
       END IF;

          -- Bug No.:3614144 added by sseraphi to convert  new revision in small case to upper case while import
          -- adding this conversion before validations start.
	   IF l_revised_item_rec.New_Revised_Item_Revision IS NOT null
	   THEN
                l_revised_item_rec.New_Revised_Item_Revision := UPPER(l_revised_item_rec.New_Revised_Item_Revision);
	   END IF;
	    IF l_revised_item_rec.Updated_Revised_Item_Revision IS NOT null
	   THEN
                l_revised_item_rec.Updated_Revised_Item_Revision := UPPER(l_revised_item_rec.Updated_Revised_Item_Revision);
	   END IF;
           -- Process Flow step 5: Verify Revised Item's existence
           --

	   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check existence'); END IF;
           ENG_Validate_Revised_Item.Check_Existence
                (  p_revised_item_rec           => l_revised_item_rec
                ,  p_rev_item_unexp_rec         => l_rev_item_unexp_rec
                ,  x_old_revised_item_rec       => l_old_revised_item_rec
                ,  x_old_rev_item_unexp_rec     => l_old_rev_item_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
		,  x_disable_revision           => x_disable_revision  --BUG 3034642
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'ENG_RIT_EXS_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                l_other_token_tbl(2).token_name := 'ECO_NAME';
                l_other_token_tbl(2).token_value := l_revised_item_rec.eco_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                l_other_token_tbl(2).token_name := 'ECO_NAME';
                l_other_token_tbl(2).token_value := l_revised_item_rec.eco_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           -- Process Flow step 6: Is Revised Item record an orphan ?

           IF NOT l_eco_parent_exists
           THEN

                -- Process Flow step 7(a): Is ECO impl/cancl, or in wkflw process ?
                --

                ENG_Validate_ECO.Check_Access
                ( p_change_notice       => l_revised_item_rec.ECO_Name
                , p_organization_id     => l_rev_item_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_RIT_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

                -- Process Flow step 7(b): check that user has access to revised item
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
                ENG_Validate_Revised_Item.Check_Access
                (  p_change_notice      => l_revised_item_rec.ECO_Name
                ,  p_organization_id    => l_rev_item_unexp_rec.organization_id
                ,  p_revised_item_id    => l_rev_item_unexp_rec.revised_item_id
                ,  p_new_item_revision  => l_revised_item_rec.new_revised_item_revision
                ,  p_effectivity_date   => l_revised_item_rec.start_effective_date
                ,  p_new_routing_revsion   => l_revised_item_rec.new_routing_revision  -- Added by MK on 11/02/00
                ,  p_from_end_item_number  => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
                ,  p_revised_item_name  => l_revised_item_rec.revised_item_name
                ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_RIT_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;

           /****  Following Process Flow is for ECO Routing ***/
           --
           -- Process Flow step 8:  Flow Routing's operability for routing.
           -- (for future release, flow routing is not supported in current release
           -- Added by MK on 08/24/2000
           --
           /* Comment out for current release
           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Non-Flow Routing'); END IF;

           Bom_Validate_Rtg_Header.Check_flow_routing_operability ;
           (  p_assembly_item_name  =>  l_revised_item_rec.revised_item_name
            , p_cfm_routing_flag    =>  l_rev_item_unexp_rec.cfm_routing_flag
                                        -- in future, this shoud be exposed column
            , p_organization_id     =>  l_rev_item_unexp_rec.organization_id
            , x_mesg_token_tbl      =>  l_mesg_token_tbl
            , x_return_status       =>  l_return_status
            );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;


           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_RTG_FRACC_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_revised_item_rec.revised_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RTG_FRACC_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;
           */



           -- Process Flow step 9: Value to Id conversions
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Value-id conversions'); END IF;
           ENG_Val_To_Id.Revised_Item_VID
                ( x_Return_Status       => l_return_status
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , p_rev_item_unexp_Rec  => l_rev_item_unexp_rec
                , x_rev_item_unexp_Rec  => l_rev_item_unexp_rec
                , p_revised_item_Rec    => l_revised_item_rec
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_revised_item_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'ENG_RIT_VID_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl   => x_revised_item_tbl
                ,  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 3
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => x_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

	   -- Process Flow step 10: Attribute Validation for CREATE and UPDATE
           --


           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation'); END IF;
           IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                ENG_Validate_Revised_Item.Check_Attributes
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_revised_item_rec           => l_revised_item_rec
                , p_rev_item_unexp_rec         => l_rev_item_unexp_rec
                , p_old_revised_item_rec       => l_old_revised_item_rec
                , p_old_rev_item_unexp_rec     => l_old_rev_item_unexp_rec
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_revised_item_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'ENG_RIT_ATTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'ENG_RIT_ATTVAL_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                   Eco_Error_Handler.Log_Error
                        (  p_revised_item_tbl   => x_revised_item_tbl
                        ,  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        ,  p_mesg_token_tbl     =>  l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 3
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => x_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        );
                END IF;
           END IF;

           IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

                -- Process flow step 11 - Populate NULL columns for Update and
                -- Delete.

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
                Eng_Default_Revised_Item.Populate_NULL_Columns
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_old_revised_item_rec      => l_old_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   p_old_rev_item_unexp_rec    => l_old_rev_item_unexp_rec
                ,   x_revised_item_rec          => l_revised_item_rec
                ,   x_rev_item_unexp_rec        => l_rev_item_unexp_rec
                );

           ELSIF l_revised_item_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

                -- Process Flow step 12: Default missing values for Operation CREATE
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
                Eng_Default_Revised_Item.Attribute_Defaulting
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_revised_item_rec          => l_revised_item_rec
                ,   x_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_RIT_ATTDEF_SEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ATTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_revised_item_tbl   => x_revised_item_tbl
                        ,  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'S'
                        ,  p_error_level        => 3
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => x_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        );
                END IF;
           END IF;

           -- Process Flow step 13 - Conditionally required attributes check
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Conditionally required attributes check'); END IF;

           --
           -- Put conditionally required check procedure here
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           ENG_Validate_Revised_Item.Check_Required
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_revised_item_rec           => l_revised_item_rec
                );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_revised_item_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'ENG_RIT_CONREQ_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_CONREQ_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

           -- Process Flow step 14: Entity defaulting for CREATE and UPDATE
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting'); END IF;
           IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                ENG_Default_Revised_Item.Entity_Defaulting
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   p_old_revised_item_rec      => l_old_revised_item_rec
                ,   p_old_rev_item_unexp_rec    => l_old_rev_item_unexp_rec
                ,   x_revised_item_rec          => l_revised_item_rec
                ,   x_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_revised_item_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'ENG_RIT_ENTDEF_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ENTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_revised_item_tbl    => x_revised_item_tbl
                        ,  p_rev_component_tbl   => x_rev_component_tbl
                        ,  p_ref_designator_tbl  => x_ref_designator_tbl
                        ,  p_sub_component_tbl   => x_sub_component_tbl
                        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        ,  p_mesg_token_tbl      => l_mesg_token_tbl
                        ,  p_error_status        => 'W'
                        ,  p_error_level         => 3
                        ,  p_entity_index        => I
                        ,  x_eco_rec             => l_eco_rec
                        ,  x_eco_revision_tbl    => l_eco_revision_tbl
                        ,  x_revised_item_tbl    => x_revised_item_tbl
                        ,  x_rev_component_tbl   => x_rev_component_tbl
                        ,  x_ref_designator_tbl  => x_ref_designator_tbl
                        ,  x_sub_component_tbl   => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        );
                END IF;
           END IF;

           -- Process Flow step 15 - Entity Level Validation
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;

           IF l_revised_item_rec.transaction_type = 'DELETE'
           THEN
                Eng_Validate_Revised_Item.Check_Entity_Delete
                (  p_revised_item_rec     => l_revised_item_rec
                ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  x_return_status        => l_Return_Status
                );
           ELSE
                Eng_Validate_Revised_Item.Check_Entity
                (  p_revised_item_rec     => l_revised_item_rec
                ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                ,  p_old_revised_item_rec => l_old_revised_item_rec
                ,  p_old_rev_item_unexp_rec => l_old_rev_item_unexp_rec
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  x_return_status        => l_Return_Status
                );
           END IF;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_revised_item_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'ENG_RIT_ENTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

           -- Process Flow step 16 : Database Writes
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
           ENG_Revised_Item_Util.Perform_Writes
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Writing to the database for Rev Item is completed with '||l_return_status );
END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        x_revised_item_tbl(I)          := l_revised_item_rec;

        --
        -- If everything goes well then, process children
        --
        l_process_children := TRUE;

     -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => FND_API.G_RET_STS_ERROR
                ,  p_error_scope            => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );

        l_process_children := TRUE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status        => Error_Handler.G_STATUS_ERROR
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_SEV_SKIP_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

        WHEN EXC_SEV_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
            (  p_revised_item_tbl       => x_revised_item_tbl
             , p_rev_component_tbl      => x_rev_component_tbl
             , p_ref_designator_tbl     => x_ref_designator_tbl
             , p_sub_component_tbl      => x_sub_component_tbl
             , p_rev_operation_tbl      => x_rev_operation_tbl    --L1
             , p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
             , p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
             , p_error_status           => Error_Handler.G_STATUS_ERROR
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_BO_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_ERROR
             , p_other_token_tbl        => l_other_token_tbl
             , x_eco_rec                => l_eco_rec
             , x_eco_revision_tbl       => l_eco_revision_tbl
             , x_revised_item_tbl       => x_revised_item_tbl
             , x_rev_component_tbl      => x_rev_component_tbl
             , x_ref_designator_tbl     => x_ref_designator_tbl
             , x_sub_component_tbl      => x_sub_component_tbl
             , x_rev_operation_tbl   => x_rev_operation_tbl    --L1
             , x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
             , x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
             );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_FAT_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status        => Error_Handler.G_STATUS_FATAL
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        l_process_children := FALSE;

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
                ,  p_other_status        => Error_Handler.G_STATUS_FATAL
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

        l_return_status := 'U';

        END; -- END block

        IF l_return_status in ('Q', 'U')
        THEN
                x_return_status := l_return_status;
                RETURN;
        END IF;

    IF l_process_children
    THEN


        -- L1: The following is for ECO enhancement
        -- Process operations that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item
        --
        -- Modified by MK on 11/30/00 Moved eco for routing procedure before BOMs.
        --

-- IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Rev Op children of Revised item . . . ' || l_revised_item_rec.revised_item_name); END IF;

        Rev_Operation_Sequences
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision -- Added by MK on 11/02/00
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_alternate_routing_code    => l_revised_item_rec.alternate_bom_code        -- Added for bug 13329115
        ,   p_rev_operation_tbl         => x_rev_operation_tbl
        ,   p_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_rev_operation_tbl         => x_rev_operation_tbl
        ,   x_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;



        -- Process resource that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

-- IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Rev Op Res children of Revised item . . . ' || l_revised_item_rec.revised_item_name); END IF;


        Rev_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision -- Added by MK on 11/02/00
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_alternate_routing_code    => l_revised_item_rec.alternate_bom_code        -- Added for bug 13329115
        ,   p_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
                l_bo_return_status := l_return_status;
       END IF;

        -- Process substitute resources that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

-- IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Rev Sub Op Res children of Revised item . . . ' || l_revised_item_rec.revised_item_name); END IF;


       Rev_Sub_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision -- Added by MK on 11/02/00
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_alternate_routing_code    => l_revised_item_rec.alternate_bom_code        -- Added for bug 13329115
        ,   p_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

        -- L1: The above is for ECO enhancement


        -- Process Revised Components that are direct children of this item

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Now processing direct children for the Rev Item '
                              || l_revised_item_rec.revised_item_name || '. . .'  );
    Error_Handler.Write_Debug('Processing Rev Comp as children of Revised item ' || l_revised_item_rec.revised_item_name);
END IF;

        Rev_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_alternate_bom_code        => l_revised_item_rec.alternate_bom_code -- Bug 2429272 Change 4
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_rev_component_tbl         => x_rev_component_tbl
        ,   p_ref_designator_tbl        => x_ref_designator_tbl
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_rev_component_tbl         => x_rev_component_tbl
        ,   x_ref_designator_tbl        => x_ref_designator_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
	,   x_bill_sequence_id          => l_rev_item_unexp_rec.bill_sequence_id
        );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rev_Comps return status ' || l_return_status); END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
        Error_Handler.Write_Debug('Rev_Comps returned in Rev_Items . . .BO Status: ' || l_return_status);
END IF;

                l_bo_return_status := l_return_status;
        END IF;

        -- Process Reference Designators that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Processing Ref Desgs as children of Revised item ' || l_revised_item_rec.revised_item_name);
END IF;


        Ref_Desgs
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_alternate_bom_code        => l_revised_item_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_ref_designator_tbl        => x_ref_designator_tbl
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_ref_designator_tbl        => x_ref_designator_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        -- Process Substitute Components that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Processing Sub Comps children of Revised item ' || l_revised_item_rec.revised_item_name);
END IF;

        Sub_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_alternate_bom_code        => l_revised_item_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;


    END IF; -- END Process children
    x_revised_item_unexp_rec := l_rev_item_unexp_rec;
    x_return_status := l_bo_return_status;

END Process_Rev_Item;


--  Rev_Items

PROCEDURE Rev_Items
(   p_validation_level              IN  NUMBER
,   p_change_notice                 IN  VARCHAR2 := NULL
,   p_organization_id               IN  NUMBER := NULL
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl             IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   p_rev_op_resource_tbl           IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   p_rev_sub_resource_tbl          IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   x_rev_op_resource_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   x_rev_sub_resource_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_disable_revision              OUT NOCOPY NUMBER --Bug no:3034642
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_eco_parent_exists     BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_rec               ENG_Eco_PUB.Eco_Rec_Type;
l_old_eco_rec           ENG_Eco_PUB.Eco_Rec_Type;
l_old_eco_unexp_rec     ENG_Eco_PUB.Eco_Unexposed_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.ECO_Revision_Tbl_Type;
l_revised_item_rec      ENG_Eco_PUB.Revised_Item_Rec_Type;
--l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type := p_revised_item_tbl;
l_rev_item_unexp_rec    ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type;
l_rev_item_miss_rec     ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type;
l_old_revised_item_rec  ENG_Eco_PUB.Revised_Item_Rec_Type;
l_old_rev_item_unexp_rec ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type;
--l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type := p_rev_component_tbl;
--l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
--l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
--l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type := p_rev_operation_tbl;  --L1
--l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type :=p_rev_op_resource_tbl; --L1
--l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type :=p_rev_sub_resource_tbl; --L1
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

l_rev_comp_flag         VARCHAR2(1);

l_process_children      BOOLEAN := TRUE;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_QUIT_OBJECT     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

	-- Bug 2918350 // kamohan
	-- Start Changes

	l_chk_co_sch eng_engineering_changes.status_type%TYPE;

	-- End Changes

BEGIN

    --  Init local table variables.

    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_bo_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_revised_item_tbl             := p_revised_item_tbl;
    x_rev_component_tbl            := p_rev_component_tbl;
    x_ref_designator_tbl           := p_ref_designator_tbl;
    x_sub_component_tbl            := p_sub_component_tbl;
    x_rev_operation_tbl            := p_rev_operation_tbl;  --L1
    x_rev_op_resource_tbl          := p_rev_op_resource_tbl; --L1
    x_rev_sub_resource_tbl         := p_rev_sub_resource_tbl; --L1

    -- l_Rev_Item_Unexp_Rec.organization_id := ENG_GLOBALS.Get_org_id;

    FOR I IN 1..x_revised_item_tbl.COUNT LOOP
    IF (x_revised_item_tbl(I).return_status IS NULL OR
         x_revised_item_tbl(I).return_status = FND_API.G_MISS_CHAR) THEN

    BEGIN

        --  Load local records.

        l_revised_item_rec := x_revised_item_tbl(I);



        -- make sure that the unexposed record does not have remains of
        -- any previous processing. This could be possible in the consequent
        -- iterations of this loop
        l_rev_item_unexp_rec := l_rev_item_miss_rec;
        l_Rev_Item_Unexp_Rec.organization_id := ENG_GLOBALS.Get_org_id;


        l_revised_item_rec.transaction_type :=
                UPPER(l_revised_item_rec.transaction_type);

        --
        -- be sure to set the process_children to false at the start of each
        -- iteration to avoid faulty processing of children at the end of the loop
        --
        l_process_children := FALSE;

        IF p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                l_eco_parent_exists := TRUE;
        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Revised Item . . . ' || l_revised_item_rec.revised_item_name); END IF;

        IF --(l_revised_item_rec.return_status IS NULL OR
            --l_revised_item_rec.return_status = FND_API.G_MISS_CHAR)
           --AND
           (NOT l_eco_parent_exists
            OR
            (l_eco_parent_exists AND
             (l_revised_item_rec.ECO_Name = p_change_notice AND
              l_rev_item_unexp_rec.organization_id = p_organization_id)))
        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_revised_item_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           -- Check if transaction_type is valid
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check transaction_type validity'); END IF;
           ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_revised_item_rec.transaction_type
           ,   p_entity                 => 'Rev_Items'
           ,   p_entity_id              => l_revised_item_rec.revised_item_name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           -- Process Flow step 4: Convert user unique index to unique index
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index'); END IF;
           ENG_Val_To_Id.Revised_Item_UUI_To_UI
                ( p_revised_item_rec   => l_revised_item_rec
                , p_rev_item_unexp_rec => l_rev_item_unexp_rec
                , x_rev_item_unexp_rec => l_rev_item_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'ENG_RIT_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           BOM_Globals.Set_Unit_Controlled_Item
           ( p_inventory_item_id => l_rev_item_unexp_rec.revised_item_id
           , p_organization_id  => l_rev_item_unexp_rec.organization_id
           );

           -- Process Flow step 5: Verify ECO's existence in database, if
           -- the revised item is being created on an ECO and the business
           -- object does not carry the ECO header

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check parent existence'); END IF;

           IF l_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
              AND
              NOT l_eco_parent_exists
           THEN
                ENG_Validate_ECO.Check_Existence
                ( p_change_notice       => l_revised_item_rec.ECO_Name
                , p_organization_id     => l_rev_item_unexp_rec.organization_id
                , p_organization_code   => l_revised_item_rec.organization_code
                , p_calling_entity      => 'CHILD'
                , p_transaction_type    => 'XXX'
                , x_eco_rec             => l_old_eco_rec
                , x_eco_unexp_rec       => l_old_eco_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'ENG_PARENTECO_NOT_EXIST';
                   l_other_token_tbl(1).token_name := 'ECO_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.ECO_Name;
                   l_other_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                   l_other_token_tbl(2).token_value := l_revised_item_rec.organization_code;
                   RAISE EXC_SEV_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'ENG_RIT_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;

         IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

	-- Bug 2918350
	-- Start Changes
	IF p_change_notice IS NOT NULL AND p_organization_id IS NOT NULL THEN
		l_chk_co_sch := ret_co_status ( p_change_notice, p_organization_id);
	ELSE
		l_chk_co_sch := ret_co_status ( l_revised_item_rec.eco_name, l_rev_item_unexp_rec.organization_id);
	END IF;

	-- Added for bug 5756870
	-- The update case when the CO is in scheduled status is handled saperately
	IF  (l_revised_item_rec.Transaction_Type <> ENG_GLOBALS.G_OPR_UPDATE )
		AND (l_chk_co_sch = 4) THEN
		l_return_status := error_handler.g_status_error;
		error_handler.add_error_token (p_message_name        => 'ENG_REV_ITM_NOT_UPD',
			p_mesg_token_tbl      => l_mesg_token_tbl,
			x_mesg_token_tbl      => l_mesg_token_tbl,
			p_token_tbl           => l_token_tbl
			);
		RAISE exc_sev_quit_record;
	END IF;

	-- End Changes
       END IF;

          -- Bug No.:3614144 added by sseraphi to convert  new revision in small case to upper case while import
          -- adding this conversion before validations start.
	   IF l_revised_item_rec.New_Revised_Item_Revision IS NOT null
	   THEN
                l_revised_item_rec.New_Revised_Item_Revision := UPPER(l_revised_item_rec.New_Revised_Item_Revision);
	   END IF;
	    IF l_revised_item_rec.Updated_Revised_Item_Revision IS NOT null
	   THEN
                l_revised_item_rec.Updated_Revised_Item_Revision := UPPER(l_revised_item_rec.Updated_Revised_Item_Revision);
	   END IF;
           -- Process Flow step 5: Verify Revised Item's existence
           --

	   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check existence'); END IF;
           ENG_Validate_Revised_Item.Check_Existence
                (  p_revised_item_rec           => l_revised_item_rec
                ,  p_rev_item_unexp_rec         => l_rev_item_unexp_rec
                ,  x_old_revised_item_rec       => l_old_revised_item_rec
                ,  x_old_rev_item_unexp_rec     => l_old_rev_item_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
		,  x_disable_revision           => x_disable_revision  --BUG 3034642
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'ENG_RIT_EXS_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                l_other_token_tbl(2).token_name := 'ECO_NAME';
                l_other_token_tbl(2).token_value := l_revised_item_rec.eco_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                l_other_token_tbl(2).token_name := 'ECO_NAME';
                l_other_token_tbl(2).token_value := l_revised_item_rec.eco_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           -- Process Flow step 6: Is Revised Item record an orphan ?

           IF NOT l_eco_parent_exists
           THEN

                -- Process Flow step 7(a): Is ECO impl/cancl, or in wkflw process ?
                --
		-- Added for bug 5756870
		-- In case if the transaciton is update, pass parameter to avoid scheduled date validations
		IF  (l_revised_item_rec.Transaction_Type = ENG_GLOBALS.G_OPR_UPDATE ) THEN
			ENG_Validate_ECO.Check_Access
			( p_change_notice       => l_revised_item_rec.ECO_Name
			, p_organization_id     => l_rev_item_unexp_rec.organization_id
			, p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
			, x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
			, x_Return_Status       => l_return_status
			, p_check_scheduled_status  => FALSE -- bug 5756870 , don't check for scheduled date validation..
			);
		ELSE

			-- If the transaction is not update, fire the default validations...
			ENG_Validate_ECO.Check_Access
			( p_change_notice       => l_revised_item_rec.ECO_Name
			, p_organization_id     => l_rev_item_unexp_rec.organization_id
			, p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
			, x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
			, x_Return_Status       => l_return_status
			, p_check_scheduled_status  => TRUE -- bug 5756870
			);
		END IF;

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_RIT_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;

           -- Process Flow step 7(b): check that user has access to revised item
           --
           -- Bug No: 5246049
           -- Moved validation outside 'IF NOT l_eco_parent_exists' as validation should happen in all cases

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
		IF  (l_revised_item_rec.Transaction_Type = ENG_GLOBALS.G_OPR_UPDATE ) THEN
		   ENG_Validate_Revised_Item.Check_Access
		   (  p_change_notice      => l_revised_item_rec.ECO_Name
		   ,  p_organization_id    => l_rev_item_unexp_rec.organization_id
		   ,  p_revised_item_id    => l_rev_item_unexp_rec.revised_item_id
		   ,  p_new_item_revision  => l_revised_item_rec.new_revised_item_revision
		   ,  p_effectivity_date   => l_revised_item_rec.start_effective_date
		   ,  p_new_routing_revsion   => l_revised_item_rec.new_routing_revision  -- Added by MK on 11/02/00
		   ,  p_from_end_item_number  => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
		   ,  p_revised_item_name  => l_revised_item_rec.revised_item_name
		   ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
		   ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
		   ,  x_return_status      => l_Return_Status
		   , p_check_scheduled_status  => FALSE -- bug 5756870 , don't check for scheduled date validation..
		   );
		ELSE
			ENG_Validate_Revised_Item.Check_Access
		   (  p_change_notice      => l_revised_item_rec.ECO_Name
		   ,  p_organization_id    => l_rev_item_unexp_rec.organization_id
		   ,  p_revised_item_id    => l_rev_item_unexp_rec.revised_item_id
		   ,  p_new_item_revision  => l_revised_item_rec.new_revised_item_revision
		   ,  p_effectivity_date   => l_revised_item_rec.start_effective_date
		   ,  p_new_routing_revsion   => l_revised_item_rec.new_routing_revision  -- Added by MK on 11/02/00
		   ,  p_from_end_item_number  => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
		   ,  p_revised_item_name  => l_revised_item_rec.revised_item_name
		   ,  p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
		   ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
		   ,  x_return_status      => l_Return_Status
		   , p_check_scheduled_status  => TRUE -- bug 5756870 , don't check for scheduled date validation..
		   );

		END IF;


           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                   l_other_message := 'ENG_RIT_ACCESS_FAT_FATAL';
                   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                   l_return_status := 'F';
                   RAISE EXC_FAT_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                   l_other_message := 'ENG_RIT_ACCESS_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;



           /****  Following Process Flow is for ECO Routing ***/
           --
           -- Process Flow step 8:  Flow Routing's operability for routing.
           -- (for future release, flow routing is not supported in current release
           -- Added by MK on 08/24/2000
           --
           /* Comment out for current release
           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Non-Flow Routing'); END IF;

           Bom_Validate_Rtg_Header.Check_flow_routing_operability ;
           (  p_assembly_item_name  =>  l_revised_item_rec.revised_item_name
            , p_cfm_routing_flag    =>  l_rev_item_unexp_rec.cfm_routing_flag
                                        -- in future, this shoud be exposed column
            , p_organization_id     =>  l_rev_item_unexp_rec.organization_id
            , x_mesg_token_tbl      =>  l_mesg_token_tbl
            , x_return_status       =>  l_return_status
            );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;


           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'BOM_RTG_FRACC_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_revised_item_rec.revised_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'BOM_RTG_FRACC_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;
           */



           -- Process Flow step 9: Value to Id conversions
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Value-id conversions'); END IF;
           ENG_Val_To_Id.Revised_Item_VID
                ( x_Return_Status       => l_return_status
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , p_rev_item_unexp_Rec  => l_rev_item_unexp_rec
                , x_rev_item_unexp_Rec  => l_rev_item_unexp_rec
                , p_revised_item_Rec    => l_revised_item_rec
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_revised_item_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'ENG_RIT_VID_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl   => x_revised_item_tbl
                ,  p_rev_component_tbl  => x_rev_component_tbl
                ,  p_ref_designator_tbl => x_ref_designator_tbl
                ,  p_sub_component_tbl  => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => 'W'
                ,  p_error_level        => 3
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => x_revised_item_tbl
                ,  x_rev_component_tbl  => x_rev_component_tbl
                ,  x_ref_designator_tbl => x_ref_designator_tbl
                ,  x_sub_component_tbl  => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

	     -- Check for access if the status is scheduled...
	   -- Added for bug 5756870
	   --Note: we need not check if the transaction type is anything other than update
	   -- because it has been check above, and execution will not make it to this line in such cases

	   IF(l_chk_co_sch = 4 OR l_old_revised_item_rec.status_type = 4) THEN
		   ENG_Validate_Revised_Item.Check_Access_Scheduled(
			  x_Return_Status       => l_return_status
			, x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
			, p_rev_item_unexp_Rec  => l_rev_item_unexp_rec
			, p_revised_item_Rec    => l_revised_item_rec
			);


			   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

			   IF l_return_status = Error_Handler.G_STATUS_ERROR
			   THEN

				   l_other_message := 'ENG_RIT_SCHEDULE_ACCESS_FATAL';
				   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
				   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
				   l_return_status := 'F';
				   RAISE EXC_FAT_QUIT_BRANCH;
			   ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
			   THEN

				   l_other_message := 'ENG_RIT_SCHEDULE_ACCESS_UNEXP';
				   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
				   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
				   RAISE EXC_UNEXP_SKIP_OBJECT;
			   END IF;

			   if( p_rev_component_tbl.COUNT <> 0
			      OR   p_ref_designator_tbl.COUNT<> 0
			      OR   p_sub_component_tbl.COUNT<> 0
			      OR   p_rev_operation_tbl.COUNT<> 0
			      OR    p_rev_op_resource_tbl.COUNT<> 0
			      OR   p_rev_sub_resource_tbl.COUNT<> 0 ) THEN

				l_other_message := 'ENG_RIT_NO_CHILD_IN_SCHEDULED';
				l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
				l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
				l_return_status := 'F';
				RAISE EXC_FAT_QUIT_BRANCH;
			   END IF;

	   END IF;


	   -- Process Flow step 10: Attribute Validation for CREATE and UPDATE
           --


           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation'); END IF;
           IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                ENG_Validate_Revised_Item.Check_Attributes
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_revised_item_rec           => l_revised_item_rec
                , p_rev_item_unexp_rec         => l_rev_item_unexp_rec
                , p_old_revised_item_rec       => l_old_revised_item_rec
                , p_old_rev_item_unexp_rec     => l_old_rev_item_unexp_rec
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_revised_item_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'ENG_RIT_ATTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'ENG_RIT_ATTVAL_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                   l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                   Eco_Error_Handler.Log_Error
                        (  p_revised_item_tbl   => x_revised_item_tbl
                        ,  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        ,  p_mesg_token_tbl     =>  l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 3
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => x_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        );
                END IF;
           END IF;

           IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

                -- Process flow step 11 - Populate NULL columns for Update and
                -- Delete.

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
                Eng_Default_Revised_Item.Populate_NULL_Columns
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_old_revised_item_rec      => l_old_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   p_old_rev_item_unexp_rec    => l_old_rev_item_unexp_rec
                ,   x_revised_item_rec          => l_revised_item_rec
                ,   x_rev_item_unexp_rec        => l_rev_item_unexp_rec
                );

           ELSIF l_revised_item_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

                -- Process Flow step 12: Default missing values for Operation CREATE
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
                Eng_Default_Revised_Item.Attribute_Defaulting
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_revised_item_rec          => l_revised_item_rec
                ,   x_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_RIT_ATTDEF_SEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ATTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_revised_item_tbl   => x_revised_item_tbl
                        ,  p_rev_component_tbl  => x_rev_component_tbl
                        ,  p_ref_designator_tbl => x_ref_designator_tbl
                        ,  p_sub_component_tbl  => x_sub_component_tbl
                        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'S'
                        ,  p_error_level        => 3
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => x_revised_item_tbl
                        ,  x_rev_component_tbl  => x_rev_component_tbl
                        ,  x_ref_designator_tbl => x_ref_designator_tbl
                        ,  x_sub_component_tbl  => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        );
                END IF;
           END IF;

           -- Process Flow step 13 - Conditionally required attributes check
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Conditionally required attributes check'); END IF;

           --
           -- Put conditionally required check procedure here
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           ENG_Validate_Revised_Item.Check_Required
                ( x_return_status              => l_return_status
                , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                , p_revised_item_rec           => l_revised_item_rec
                );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_revised_item_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'ENG_RIT_CONREQ_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_CONREQ_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

           -- Process Flow step 14: Entity defaulting for CREATE and UPDATE
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting'); END IF;
           IF l_revised_item_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                ENG_Default_Revised_Item.Entity_Defaulting
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   p_old_revised_item_rec      => l_old_revised_item_rec
                ,   p_old_rev_item_unexp_rec    => l_old_rev_item_unexp_rec
                ,   x_revised_item_rec          => l_revised_item_rec
                ,   x_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_revised_item_rec.transaction_type = 'CREATE'
                   THEN
                        l_other_message := 'ENG_RIT_ENTDEF_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ENTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_revised_item_tbl    => x_revised_item_tbl
                        ,  p_rev_component_tbl   => x_rev_component_tbl
                        ,  p_ref_designator_tbl  => x_ref_designator_tbl
                        ,  p_sub_component_tbl   => x_sub_component_tbl
                        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        ,  p_mesg_token_tbl      => l_mesg_token_tbl
                        ,  p_error_status        => 'W'
                        ,  p_error_level         => 3
                        ,  p_entity_index        => I
                        ,  x_eco_rec             => l_eco_rec
                        ,  x_eco_revision_tbl    => l_eco_revision_tbl
                        ,  x_revised_item_tbl    => x_revised_item_tbl
                        ,  x_rev_component_tbl   => x_rev_component_tbl
                        ,  x_ref_designator_tbl  => x_ref_designator_tbl
                        ,  x_sub_component_tbl   => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        );
                END IF;
           END IF;

           -- Process Flow step 15 - Entity Level Validation
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;

           IF l_revised_item_rec.transaction_type = 'DELETE'
           THEN
                Eng_Validate_Revised_Item.Check_Entity_Delete
                (  p_revised_item_rec     => l_revised_item_rec
                ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  x_return_status        => l_Return_Status
                );
           ELSE
                Eng_Validate_Revised_Item.Check_Entity
                (  p_revised_item_rec     => l_revised_item_rec
                ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                ,  p_old_revised_item_rec => l_old_revised_item_rec
                ,  p_old_rev_item_unexp_rec => l_old_rev_item_unexp_rec
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  x_return_status        => l_Return_Status
                );
           END IF;

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_revised_item_rec.transaction_type = 'CREATE'
                THEN
                        l_other_message := 'ENG_RIT_ENTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                        l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

/*           -- Fixed Bug 12870702 begin --commented by bug 14571849
           l_rev_comp_flag := 'N';

           FOR rev_comp_index IN 1..x_rev_component_tbl.COUNT LOOP
             IF (x_rev_component_tbl(rev_comp_index).eco_name = x_revised_item_tbl(I).eco_name
                  AND x_rev_component_tbl(rev_comp_index).organization_code = x_revised_item_tbl(I).organization_code
                  AND x_rev_component_tbl(rev_comp_index).revised_item_name = x_revised_item_tbl(I).revised_item_name
                  AND NVL(x_rev_component_tbl(rev_comp_index).new_revised_item_revision, FND_API.G_MISS_CHAR) = NVL(x_revised_item_tbl(I).new_revised_item_revision, FND_API.G_MISS_CHAR) -- Bug: 13427175
                  AND (x_rev_component_tbl(rev_comp_index).component_item_name is not NULL
                        or x_rev_component_tbl(rev_comp_index).component_item_name <> FND_API.G_MISS_CHAR)
                 ) THEN
                    l_rev_comp_flag := 'Y';
                    EXIT;
              END IF;
           END LOOP;

           -- Bug 12870702, if there is no revised component, the bill_sequence_id = null, and save null into Eng_revised_items.bill_sequence_id
           IF l_rev_comp_flag = 'N' THEN
             l_rev_item_unexp_rec.bill_sequence_id := NULL;
           END IF;

           -- Fixed Bug 12870702 end; */

           -- Process Flow step 16 : Database Writes
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
           ENG_Revised_Item_Util.Perform_Writes
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_RIT_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(1).token_value := l_revised_item_rec.revised_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Writing to the database for Rev Item is completed with '||l_return_status );
END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        x_revised_item_tbl(I)          := l_revised_item_rec;

        --
        -- If everything goes well then, process children
        --
        l_process_children := TRUE;

     -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => FND_API.G_RET_STS_ERROR
                ,  p_error_scope            => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level            => 3
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );

        l_process_children := TRUE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status        => Error_Handler.G_STATUS_ERROR
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_SEV_SKIP_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

        WHEN EXC_SEV_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
            (  p_revised_item_tbl       => x_revised_item_tbl
             , p_rev_component_tbl      => x_rev_component_tbl
             , p_ref_designator_tbl     => x_ref_designator_tbl
             , p_sub_component_tbl      => x_sub_component_tbl
             , p_rev_operation_tbl      => x_rev_operation_tbl    --L1
             , p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
             , p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
             , p_error_status           => Error_Handler.G_STATUS_ERROR
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_BO_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_ERROR
             , p_other_token_tbl        => l_other_token_tbl
             , x_eco_rec                => l_eco_rec
             , x_eco_revision_tbl       => l_eco_revision_tbl
             , x_revised_item_tbl       => x_revised_item_tbl
             , x_rev_component_tbl      => x_rev_component_tbl
             , x_ref_designator_tbl     => x_ref_designator_tbl
             , x_sub_component_tbl      => x_sub_component_tbl
             , x_rev_operation_tbl   => x_rev_operation_tbl    --L1
             , x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
             , x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
             );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_FAT_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status        => Error_Handler.G_STATUS_FATAL
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        l_process_children := FALSE;

        x_return_status                := Error_Handler.G_STATUS_FATAL;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

       WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
                ,  p_other_status        => Error_Handler.G_STATUS_FATAL
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 3
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        -- Reset system_information flags

     ENG_GLOBALS.Set_RITEM_Impl( p_ritem_impl   => NULL);
     ENG_GLOBALS.Set_RITEM_Cancl( p_ritem_cancl => NULL);
     ENG_GLOBALS.Set_Bill_Sequence_Id( p_bill_sequence_id => NULL);
     ENG_GLOBALS.Set_Current_Revision( p_current_revision => NULL);

        l_return_status := 'U';

        END; -- END block

        IF l_return_status in ('Q', 'U')
        THEN
                x_return_status := l_return_status;
                RETURN;
        END IF;

    IF l_process_children
    THEN


        -- L1: The following is for ECO enhancement
        -- Process operations that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item
        --
        -- Modified by MK on 11/30/00 Moved eco for routing procedure before BOMs.
        --

-- IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Rev Op children of Revised item . . . ' || l_revised_item_rec.revised_item_name); END IF;

        Rev_Operation_Sequences
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision -- Added by MK on 11/02/00
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_alternate_routing_code    => l_revised_item_rec.alternate_bom_code        -- Added for bug 13329115
        ,   p_rev_operation_tbl         => x_rev_operation_tbl
        ,   p_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_rev_operation_tbl         => x_rev_operation_tbl
        ,   x_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;



        -- Process resource that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

-- IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Rev Op Res children of Revised item . . . ' || l_revised_item_rec.revised_item_name); END IF;


        Rev_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision -- Added by MK on 11/02/00
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_alternate_routing_code    => l_revised_item_rec.alternate_bom_code        -- Added for bug 13329115
        ,   p_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_rev_op_resource_tbl       => x_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
                l_bo_return_status := l_return_status;
       END IF;

        -- Process substitute resources that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

-- IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Rev Sub Op Res children of Revised item . . . ' || l_revised_item_rec.revised_item_name); END IF;


       Rev_Sub_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision -- Added by MK on 11/02/00
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_alternate_routing_code    => l_revised_item_rec.alternate_bom_code        -- Added for bug 13329115
        ,   p_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

        -- L1: The above is for ECO enhancement


        -- Process Revised Components that are direct children of this item

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Now processing direct children for the Rev Item '
                              || l_revised_item_rec.revised_item_name || '. . .'  );
    Error_Handler.Write_Debug('Processing Rev Comp as children of Revised item ' || l_revised_item_rec.revised_item_name);
END IF;

        Rev_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_alternate_bom_code        => l_revised_item_rec.alternate_bom_code -- Bug 2429272 Change 4
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_rev_component_tbl         => x_rev_component_tbl
        ,   p_ref_designator_tbl        => x_ref_designator_tbl
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_rev_component_tbl         => x_rev_component_tbl
        ,   x_ref_designator_tbl        => x_ref_designator_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
	,   x_bill_sequence_id          => l_rev_item_unexp_rec.bill_sequence_id
        );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rev_Comps return status ' || l_return_status); END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN
        Error_Handler.Write_Debug('Rev_Comps returned in Rev_Items . . .BO Status: ' || l_return_status);
END IF;

                l_bo_return_status := l_return_status;
        END IF;

        -- Process Reference Designators that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Processing Ref Desgs as children of Revised item ' || l_revised_item_rec.revised_item_name);
END IF;


        Ref_Desgs
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_alternate_bom_code        => l_revised_item_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_ref_designator_tbl        => x_ref_designator_tbl
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_ref_designator_tbl        => x_ref_designator_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        -- Process Substitute Components that are orphans
        -- (without immediate revised component parents) but are
        -- indirect children of this item

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('***********************************************************') ;
    Error_Handler.Write_Debug('Processing Sub Comps children of Revised item ' || l_revised_item_rec.revised_item_name);
END IF;

        Sub_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_revised_item_rec.ECO_Name
        ,   p_organization_id           => l_rev_item_unexp_rec.organization_id
        ,   p_revised_item_name         => l_revised_item_rec.revised_item_name
        ,   p_alternate_bom_code        => l_revised_item_rec.alternate_bom_code  -- Bug 3991176
        ,   p_effectivity_date          => l_revised_item_rec.start_effective_date
        ,   p_item_revision             => l_revised_item_rec.new_revised_item_revision
        ,   p_routing_revision          => l_revised_item_rec.new_routing_revision      -- Added by MK on 11/02/00
        ,   p_from_end_item_number      => l_revised_item_rec.from_end_item_unit_number -- Added by MK on 11/02/00
        ,   p_sub_component_tbl         => x_sub_component_tbl
        ,   x_sub_component_tbl         => x_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                l_bo_return_status := l_return_status;
        END IF;


    END IF; -- END Process children
    END IF; -- End of processing records for which the return status is null
    END LOOP; -- END Revised Items processing loop

    --  Load OUT parameters

    IF NVL(l_bo_return_status, 'S') <> 'S'
    THEN
        x_return_status        := l_bo_return_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Rev Items returning with ' || l_bo_return_status); END IF;

    END IF;
    --x_revised_item_tbl         := l_revised_item_tbl;
    --x_rev_component_tbl        := l_rev_component_tbl;
    --x_ref_designator_tbl       := l_ref_designator_tbl;
    --x_sub_component_tbl        := l_sub_component_tbl;
    --x_rev_operation_tbl        := l_rev_operation_tbl;     --L1
    --x_rev_op_resource_tbl      := l_rev_op_resource_tbl;   --L1
    --x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;  --L1
    x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Rev_Items;


-- Eng Change Enhancement: Change Line
/****************************************************************************
* Procedure : Change_Line
* Parameters IN   : Change Line Table and all the other entities
* Parameters OUT  : Change Line Table and all the other entities
* Purpose   : This procedure will process all the Change Line records.
*****************************************************************************/
PROCEDURE Change_Line
(   p_validation_level            IN  NUMBER
,   p_change_notice               IN  VARCHAR2 := NULL
,   p_organization_id             IN  NUMBER := NULL
,   p_change_line_tbl             IN  ENG_Eco_PUB.Change_Line_Tbl_Type -- Eng Change
,   p_revised_item_tbl            IN  ENG_Eco_PUB.Revised_Item_Tbl_Type
,   p_rev_component_tbl           IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl          IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl           IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl           IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   p_rev_op_resource_tbl         IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   p_rev_sub_resource_tbl        IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_change_line_tbl             IN OUT NOCOPY ENG_Eco_PUB.Change_Line_Tbl_Type      -- Eng Change
,   x_revised_item_tbl            IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl           IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl          IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl           IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status               OUT NOCOPY VARCHAR2
)
IS

/* Exposed and Unexposed record */
l_eco_rec               ENG_Eco_PUB.Eco_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.ECO_Revision_Tbl_Type;

l_change_line_rec            Eng_Eco_Pub.Change_Line_Rec_Type ;
l_change_line_unexp_rec      Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type;
l_old_change_line_rec        Eng_Eco_Pub.Change_Line_Rec_Type ;
l_old_change_line_unexp_rec  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type;

/* Error Handling Variables */
l_token_tbl             Error_Handler.Token_Tbl_Type ;
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_old_eco_rec           ENG_Eco_PUB.Eco_Rec_Type;
l_old_eco_unexp_rec     ENG_Eco_PUB.Eco_Unexposed_Rec_Type;

l_return_status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_parent_exists     BOOLEAN := FALSE;
l_process_children      BOOLEAN := TRUE;
l_valid                 BOOLEAN := TRUE;

/* Error handler definations */
EXC_SEV_QUIT_RECORD     EXCEPTION ;
EXC_SEV_QUIT_BRANCH     EXCEPTION ;
EXC_SEV_SKIP_BRANCH     EXCEPTION ;
EXC_FAT_QUIT_OBJECT     EXCEPTION ;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION ;

EXC_FAT_QUIT_BRANCH     EXCEPTION ;
EXC_SEV_QUIT_OBJECT     EXCEPTION;

l_chk_co_sch eng_engineering_changes.status_type%TYPE;
l_change_subject_unexp_rec  Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type;

BEGIN


  --  Init local table variables.
  l_return_status        := FND_API.G_RET_STS_SUCCESS ;
  l_bo_return_status     := FND_API.G_RET_STS_SUCCESS ;
  --l_change_line_tbl      := p_change_line_tbl ;
  x_change_line_tbl      := p_change_line_tbl;
  x_revised_item_tbl     := p_revised_item_tbl;
  x_rev_component_tbl    := p_rev_component_tbl;
  x_ref_designator_tbl   := p_ref_designator_tbl;
  x_sub_component_tbl    := p_sub_component_tbl ;
  x_rev_operation_tbl    := p_rev_operation_tbl;
  x_rev_op_resource_tbl  := p_rev_op_resource_tbl;
  x_rev_sub_resource_tbl := p_rev_sub_resource_tbl;


  -- Begin block that processes Change Lines. This block holds the exception handlers
  -- for change line errors.
  FOR I IN 1..x_change_line_tbl.COUNT LOOP
  -- Process Flow Step 2: Check if record has not yet been processed and
  -- that it is the child of the parent that called this procedure
  --
  IF (x_change_line_tbl(I).return_status IS NULL OR
       x_change_line_tbl(I).return_status = FND_API.G_MISS_CHAR)
  THEN

  BEGIN

        --  Load local records.
        l_change_line_rec := x_change_line_tbl(I);
        l_change_line_rec.transaction_type :=
        UPPER(l_change_line_rec.transaction_type);
        --l_change_line_unexp_rec.organization_id := Eng_Globals.Get_Org_Id;

        --
        -- Initialize the Unexposed Record for every iteration of the Loop
        -- so that sequence numbers get generated for every new row.
        --

             l_change_line_unexp_rec := NULL;

        --l_change_line_unexp_rec.change_line_id   := NULL ;
        --l_change_line_unexp_rec.change_type_id   := NULL ;
        --l_change_line_unexp_rec.item_id          := NULL ;
        --l_change_line_unexp_rec.item_revision_id := NULL ;

          --Organization_id is required for validations when we attach revised_items/lines to already existing ECO's
          l_change_line_unexp_rec.organization_id := Eng_Globals.Get_Org_Id;



        --
        -- be sure to set the process_children to false at the start of each
        -- iteration to avoid faulty processing of children at the end of the loop
        --
        l_process_children := FALSE;

        IF p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                l_eco_parent_exists := TRUE;
        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Processing Change Line . . . ' || l_change_line_rec.name); END IF;

        --IF (l_change_line_rec.return_status IS NULL OR
            --l_change_line_rec.return_status = FND_API.G_MISS_CHAR)
        --THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;
           l_change_line_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           -- Check if transaction_type is valid
           --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check transaction_type validity'); END IF;

           ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_change_line_rec.transaction_type
           ,   p_entity                 => 'Change_Lines'
           ,   p_entity_id              => l_change_line_rec.name
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           --
           -- Process Flow step 4: Convert user unique index to unique index
           --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Converting user unique index to unique index'); END IF;

           ENG_Val_To_Id.Change_Line_UUI_To_UI
           ( p_change_line_rec       => l_change_line_rec
           , p_change_line_unexp_rec => l_change_line_unexp_rec
           , x_change_line_unexp_rec => l_change_line_unexp_rec
           , x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
           , x_Return_Status         => l_return_status
           );


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN

                l_other_message := 'ENG_CL_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'LINE_NAME';
                l_other_token_tbl(1).token_value := l_change_line_rec.name ;
                RAISE EXC_SEV_QUIT_BRANCH;

           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CL_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'LINE_NAME';
                l_other_token_tbl(1).token_value := l_change_line_rec.name ;
                RAISE EXC_UNEXP_SKIP_OBJECT;

           END IF;

           --
           -- Process Flow step 4(b): Check required fields exist
           --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Required'); END IF;
           ENG_Validate_Change_Line.Check_Required
                ( x_return_status        => l_return_status
                , x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                , p_change_line_rec      => l_change_line_rec
                );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                THEN
                        l_other_message := 'ENG_CL_REQ_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CL_REQ_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                RAISE EXC_UNEXP_SKIP_OBJECT;

           ELSIF l_return_status ='S' AND
                 l_Mesg_Token_Tbl.COUNT <>0
           THEN
                    Eco_Error_Handler.Log_Error
                    (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  p_revised_item_tbl    => x_revised_item_tbl
                    ,  p_rev_component_tbl   => x_rev_component_tbl
                    ,  p_ref_designator_tbl  => x_ref_designator_tbl
                    ,  p_sub_component_tbl   => x_sub_component_tbl
                    ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    ,  p_mesg_token_tbl      => l_mesg_token_tbl
                    ,  p_error_status        => 'W'
                    ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                    ,  p_entity_index        => I
                    ,  x_ECO_rec             => l_eco_rec
                    ,  x_eco_revision_tbl    => l_eco_revision_tbl
                    ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  x_revised_item_tbl    => x_revised_item_tbl
                    ,  x_rev_component_tbl   => x_rev_component_tbl
                    ,  x_ref_designator_tbl  => x_ref_designator_tbl
                    ,  x_sub_component_tbl   => x_sub_component_tbl
                    ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    );

           END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;


           -- Process Flow step 5: Verify ECO's existence in database, if
           -- the revised item is being created on an ECO and the business
           -- object does not carry the ECO header

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check parent existence'); END IF;

           IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
           AND  NOT l_eco_parent_exists
           THEN
                ENG_Validate_ECO.Check_Existence
                ( p_change_notice       => l_change_line_rec.eco_name
                , p_organization_id     => l_change_line_unexp_rec.organization_id
                , p_organization_code   => l_change_line_rec.organization_code
                , p_calling_entity      => 'CHILD'
                , p_transaction_type    => 'XXX'
                , x_eco_rec             => l_old_eco_rec
                , x_eco_unexp_rec       => l_old_eco_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
                );

		IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'ENG_PARENTECO_NOT_EXIST';
                   l_other_token_tbl(1).token_name := 'ECO_NAME';
                   l_other_token_tbl(1).token_value := l_change_line_rec.ECO_Name;
                   l_other_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                   l_other_token_tbl(2).token_value := l_change_line_rec.organization_code;
                   RAISE EXC_SEV_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'ENG_CL_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'LINE_NAME';
                   l_other_token_tbl(1).token_value := l_change_line_rec.name;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;

	   IF l_change_line_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN
		-- Bug 2918350
		-- Start Changes

		IF p_change_notice IS NOT NULL AND p_organization_id IS NOT NULL THEN
			l_chk_co_sch := ret_co_status ( p_change_notice, p_organization_id);
		ELSE
			l_chk_co_sch := ret_co_status (l_change_line_rec.eco_name, l_change_line_unexp_rec.organization_id);
		END IF;

		IF l_chk_co_sch = 4 THEN
			l_return_status := error_handler.g_status_error;
			error_handler.add_error_token (p_message_name        => 'ENG_CHG_LN_NOT_UPD',
				p_mesg_token_tbl      => l_mesg_token_tbl,
				x_mesg_token_tbl      => l_mesg_token_tbl,
				p_token_tbl           => l_token_tbl
			);
			RAISE exc_sev_quit_record;
		END IF;
    	  END IF;
		-- End Changes

		-- Process Flow step 5: Verify Revised Item's existence
	        --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check existence'); END IF;

           ENG_Validate_Change_Line.Check_Existence
                (  p_change_line_rec            => l_change_line_rec
                ,  p_change_line_unexp_rec      => l_change_line_unexp_rec
                ,  x_old_change_line_rec        => l_old_change_line_rec
                ,  x_old_change_line_unexp_rec  => l_old_change_line_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                l_other_message := 'ENG_CL_EXS_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'LINE_NAME';
                l_other_token_tbl(1).token_value := l_change_line_rec.name;
                l_other_token_tbl(2).token_name := 'ECO_NAME';
                l_other_token_tbl(2).token_value := l_change_line_rec.eco_name;
                RAISE EXC_SEV_QUIT_BRANCH;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CL_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'LINE_NAME';
                l_other_token_tbl(1).token_value := l_change_line_rec.name;
                l_other_token_tbl(2).token_name := 'ECO_NAME';
                l_other_token_tbl(2).token_value := l_change_line_rec.eco_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           -- Process Flow step 6: Is Revised Item record an orphan ?

           IF NOT l_eco_parent_exists
           THEN

                -- Process Flow step 7: Is ECO impl/cancl, or in wkflw process ?
                --

                ENG_Validate_ECO.Check_Access
                ( p_change_notice       => l_change_line_rec.ECO_Name
                , p_organization_id     => l_change_line_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_CL_ECOACC_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_RIT_ECOACC_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;


           -- Process Flow step 7: Value to Id conversions
           --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Value-id conversions'); END IF;

           ENG_Val_To_Id.Change_Line_VID
                ( p_change_line_rec       => l_change_line_rec
                , p_change_line_unexp_rec => l_change_line_unexp_rec
                , x_change_line_unexp_rec => l_change_line_unexp_rec
                , x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
                , x_Return_Status         => l_return_status
                );


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                THEN
                        l_other_message := 'ENG_RIT_VID_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                ,  p_entity_index        => I
                ,  x_ECO_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

           END IF;


           -- Process Flow step8: check that user has access to item associated to change line
           --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check access'); END IF;
           IF l_change_line_unexp_rec.pk1_value IS NOT NULL THEN

                ENG_Validate_Change_Line.Check_Access
                (  p_change_line_rec        => l_change_line_rec
                ,  p_change_line_unexp_rec  => l_change_line_unexp_rec
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  x_return_status          => l_Return_Status
                );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_CL_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'OBJECT_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.pk1_name;
                        l_other_token_tbl(2).token_name := 'LINE_NAME';
                        l_other_token_tbl(2).token_value := l_change_line_rec.name;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_CL_ACCESS_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'OBJECT_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.pk1_name;
                        l_other_token_tbl(2).token_name := 'LINE_NAME';
                        l_other_token_tbl(2).token_value := l_change_line_rec.name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF ;

           --
           -- Process Flow step 10: Attribute Validation for CREATE and UPDATE
           --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation'); END IF;
           IF l_change_line_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN
                ENG_Validate_Change_Line.Check_Attributes
                ( x_return_status             => l_return_status
                , x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                , p_change_line_rec           => l_change_line_rec
                , p_change_line_unexp_rec     => l_change_line_unexp_rec
                , p_old_change_line_rec       => l_old_change_line_rec
                , p_old_change_line_unexp_rec => l_old_change_line_unexp_rec
                );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                   THEN
                        l_other_message := 'ENG_RIT_ATTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;

                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN

                   l_other_message := 'ENG_RIT_ATTVAL_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'LINE_NAME';
                   l_other_token_tbl(1).token_value := l_change_line_rec.name;

                   RAISE EXC_UNEXP_SKIP_OBJECT;

                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN

                    Eco_Error_Handler.Log_Error
                    (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  p_revised_item_tbl    => x_revised_item_tbl
                    ,  p_rev_component_tbl   => x_rev_component_tbl
                    ,  p_ref_designator_tbl  => x_ref_designator_tbl
                    ,  p_sub_component_tbl   => x_sub_component_tbl
                    ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    ,  p_mesg_token_tbl      => l_mesg_token_tbl
                    ,  p_error_status        => 'W'
                    ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                    ,  p_entity_index        => I
                    ,  x_ECO_rec             => l_eco_rec
                    ,  x_eco_revision_tbl    => l_eco_revision_tbl
                    ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  x_revised_item_tbl    => x_revised_item_tbl
                    ,  x_rev_component_tbl   => x_rev_component_tbl
                    ,  x_ref_designator_tbl  => x_ref_designator_tbl
                    ,  x_sub_component_tbl   => x_sub_component_tbl
                    ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    );

                END IF;

           END IF;

           IF l_change_line_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

                -- Process flow step 11 - Populate NULL columns for Update and
                -- Delete.

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;

                Eng_Default_Change_Line.Populate_NULL_Columns
                ( p_change_line_rec           => l_change_line_rec
                , p_change_line_unexp_rec     => l_change_line_unexp_rec
                , p_old_change_line_rec       => l_old_change_line_rec
                , p_old_change_line_unexp_rec => l_old_change_line_unexp_rec
                , x_change_line_rec           => l_change_line_rec
                , x_change_line_unexp_rec     => l_change_line_unexp_rec
                );

           ELSIF l_change_line_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

                -- Process Flow step 12: Default missing values for Operation CREATE
                --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
                Eng_Default_Change_Line.Attribute_Defaulting
                ( p_change_line_rec           => l_change_line_rec
                , p_change_line_unexp_rec     => l_change_line_unexp_rec
                , x_change_line_rec           => l_change_line_rec
                , x_change_line_unexp_rec     => l_change_line_unexp_rec
                , x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                , x_return_status             => l_return_status
                );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_CL_ATTDEF_SEV_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_CL_ATTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;

                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                    Eco_Error_Handler.Log_Error
                    (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  p_revised_item_tbl    => x_revised_item_tbl
                    ,  p_rev_component_tbl   => x_rev_component_tbl
                    ,  p_ref_designator_tbl  => x_ref_designator_tbl
                    ,  p_sub_component_tbl   => x_sub_component_tbl
                    ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    ,  p_mesg_token_tbl      => l_mesg_token_tbl
                    ,  p_error_status        => 'W'
                    ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                    ,  p_entity_index        => I
                    ,  x_ECO_rec             => l_eco_rec
                    ,  x_eco_revision_tbl    => l_eco_revision_tbl
                    ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  x_revised_item_tbl    => x_revised_item_tbl
                    ,  x_rev_component_tbl   => x_rev_component_tbl
                    ,  x_ref_designator_tbl  => x_ref_designator_tbl
                    ,  x_sub_component_tbl   => x_sub_component_tbl
                    ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    );

                END IF;
           END IF;

           -- Process Flow step 13 - Conditionally required attributes check
           --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Conditionally required attributes check'); END IF;

           --
           -- Put conditionally required check procedure here
           --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           ENG_Validate_Change_Line.Check_Conditionally_Required
               (  p_change_line_rec           => l_change_line_rec
                , p_change_line_unexp_rec     => l_change_line_unexp_rec
                , x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                , x_return_status             => l_return_status
                );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                THEN
                        l_other_message := 'ENG_CL_CONREQ_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CL_CONREQ_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'LINE_NAME';
                l_other_token_tbl(1).token_value := l_change_line_rec.name;
                RAISE EXC_UNEXP_SKIP_OBJECT;

           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                    Eco_Error_Handler.Log_Error
                    (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  p_revised_item_tbl    => x_revised_item_tbl
                    ,  p_rev_component_tbl   => x_rev_component_tbl
                    ,  p_ref_designator_tbl  => x_ref_designator_tbl
                    ,  p_sub_component_tbl   => x_sub_component_tbl
                    ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    ,  p_mesg_token_tbl      => l_mesg_token_tbl
                    ,  p_error_status        => 'W'
                    ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                    ,  p_entity_index        => I
                    ,  x_ECO_rec             => l_eco_rec
                    ,  x_eco_revision_tbl    => l_eco_revision_tbl
                    ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  x_revised_item_tbl    => x_revised_item_tbl
                    ,  x_rev_component_tbl   => x_rev_component_tbl
                    ,  x_ref_designator_tbl  => x_ref_designator_tbl
                    ,  x_sub_component_tbl   => x_sub_component_tbl
                    ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    );

           END IF;

           -- Process Flow step 14: Entity defaulting for CREATE and UPDATE
           --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting'); END IF;

           IF l_change_line_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_CREATE, ENG_GLOBALS.G_OPR_UPDATE)
           THEN

                ENG_Default_Change_Line.Entity_Defaulting
                ( p_change_line_rec           => l_change_line_rec
                , p_change_line_unexp_rec     => l_change_line_unexp_rec
                , p_old_change_line_rec       => l_old_change_line_rec
                , p_old_change_line_unexp_rec => l_old_change_line_unexp_rec
                , x_change_line_rec           => l_change_line_rec
                , x_change_line_unexp_rec     => l_change_line_unexp_rec
                , x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                , x_return_status             => l_return_status
                );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                   THEN
                        l_other_message := 'ENG_CL_ENTDEF_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                   ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                   END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_CL_ENTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                    Eco_Error_Handler.Log_Error
                    (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  p_revised_item_tbl    => x_revised_item_tbl
                    ,  p_rev_component_tbl   => x_rev_component_tbl
                    ,  p_ref_designator_tbl  => x_ref_designator_tbl
                    ,  p_sub_component_tbl   => x_sub_component_tbl
                    ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    ,  p_mesg_token_tbl      => l_mesg_token_tbl
                    ,  p_error_status        => 'W'
                    ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                    ,  p_entity_index        => I
                    ,  x_ECO_rec             => l_eco_rec
                    ,  x_eco_revision_tbl    => l_eco_revision_tbl
                    ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  x_revised_item_tbl    => x_revised_item_tbl
                    ,  x_rev_component_tbl   => x_rev_component_tbl
                    ,  x_ref_designator_tbl  => x_ref_designator_tbl
                    ,  x_sub_component_tbl   => x_sub_component_tbl
                    ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    );

                END IF;
           END IF;

           -- Process Flow step 15 - Entity Level Validation
           --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;

           IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_DELETE
           THEN
                ENG_Validate_Change_Line.Check_Entity_Delete
                (  p_change_line_rec       => l_change_line_rec
                ,  p_change_line_unexp_rec => l_change_line_unexp_rec
                ,  x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
                ,  x_return_status         => l_Return_Status
                );
           ELSE
                ENG_Validate_Change_Line.Check_Entity
                (  p_change_line_rec           => l_change_line_rec
                ,  p_change_line_unexp_rec     => l_change_line_unexp_rec
                ,  p_old_change_line_rec       => l_old_change_line_rec
                ,  p_old_change_line_unexp_rec => l_old_change_line_unexp_rec
                ,  x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,  x_return_status             => l_Return_Status
                );
           END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                THEN
                        l_other_message := 'ENG_CL_ENTVAL_CSEV_SKIP';
                        l_other_token_tbl(1).token_name := 'LINE_NAME';
                        l_other_token_tbl(1).token_value := l_change_line_rec.name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CL_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'LINE_NAME';
                l_other_token_tbl(1).token_value := l_change_line_rec.name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                    Eco_Error_Handler.Log_Error
                    (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  p_revised_item_tbl    => x_revised_item_tbl
                    ,  p_rev_component_tbl   => x_rev_component_tbl
                    ,  p_ref_designator_tbl  => x_ref_designator_tbl
                    ,  p_sub_component_tbl   => x_sub_component_tbl
                    ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    ,  p_mesg_token_tbl      => l_mesg_token_tbl
                    ,  p_error_status        => 'W'
                    ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                    ,  p_entity_index        => I
                    ,  x_ECO_rec             => l_eco_rec
                    ,  x_eco_revision_tbl    => l_eco_revision_tbl
                    ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  x_revised_item_tbl    => x_revised_item_tbl
                    ,  x_rev_component_tbl   => x_rev_component_tbl
                    ,  x_ref_designator_tbl  => x_ref_designator_tbl
                    ,  x_sub_component_tbl   => x_sub_component_tbl
                    ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    );

           END IF;

           -- Process Flow step 16 : Database Writes
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;

           ENG_Change_Line_Util.Perform_Writes
                (  p_change_line_rec       => l_change_line_rec
                ,  p_change_line_unexp_rec => l_change_line_unexp_rec
                ,  x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
                ,  x_return_status         => l_Return_Status
                );
           IF l_return_status ='S' THEN
               --11.5.10 subjects
               ENG_Change_Line_Util.Change_Subjects(
                   p_change_line_rec          => l_change_line_rec
                 , p_change_line_unexp_rec    => l_change_line_unexp_rec
                 , x_change_subject_unexp_rec => l_change_subject_unexp_rec
                 , x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                 , x_return_status            => l_Return_Status);
               --11.5.10
           END IF;
           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;
           -- Bug 4033384: Added error handling for subject validation for l_return_status G_STATUS_ERROR
           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                IF l_change_line_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
                THEN
                    l_other_message := 'ENG_CL_ENTVAL_CSEV_SKIP';
                    l_other_token_tbl(1).token_name := 'LINE_NAME';
                    l_other_token_tbl(1).token_value := l_change_line_rec.name;
                    RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                    RAISE EXC_SEV_QUIT_RECORD;
                END IF;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_CL_WRITES_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'LINE_NAME';
                l_other_token_tbl(1).token_value := l_change_line_rec.name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                    Eco_Error_Handler.Log_Error
                    (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  p_revised_item_tbl    => x_revised_item_tbl
                    ,  p_rev_component_tbl   => x_rev_component_tbl
                    ,  p_ref_designator_tbl  => x_ref_designator_tbl
                    ,  p_sub_component_tbl   => x_sub_component_tbl
                    ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    ,  p_mesg_token_tbl      => l_mesg_token_tbl
                    ,  p_error_status        => 'W'
                    ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
                    ,  p_entity_index        => I
                    ,  x_ECO_rec             => l_eco_rec
                    ,  x_eco_revision_tbl    => l_eco_revision_tbl
                    ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                    ,  x_revised_item_tbl    => x_revised_item_tbl
                    ,  x_rev_component_tbl   => x_rev_component_tbl
                    ,  x_ref_designator_tbl  => x_ref_designator_tbl
                    ,  x_sub_component_tbl   => x_sub_component_tbl
                    ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                    ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                    ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                    );

           END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Writing to the database for Change Line is completed with '||l_return_status );
END IF;

        --END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        x_change_line_tbl(I)          := l_change_line_rec;

  --  For loop exception handler.

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
        (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  p_revised_item_tbl    => x_revised_item_tbl
        ,  p_rev_component_tbl   => x_rev_component_tbl
        ,  p_ref_designator_tbl  => x_ref_designator_tbl
        ,  p_sub_component_tbl   => x_sub_component_tbl
        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        ,  p_mesg_token_tbl      => l_mesg_token_tbl
        ,  p_error_status        => FND_API.G_RET_STS_ERROR
        ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
        ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
        ,  p_entity_index        => I
        ,  x_ECO_rec             => l_ECO_rec
        ,  x_eco_revision_tbl    => l_eco_revision_tbl
        ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  x_revised_item_tbl    => x_revised_item_tbl
        ,  x_rev_component_tbl   => x_rev_component_tbl
        ,  x_ref_designator_tbl  => x_ref_designator_tbl
        ,  x_sub_component_tbl   => x_sub_component_tbl
        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        );


        IF l_bo_return_status = 'S'
        THEN
            l_bo_return_status  := l_return_status;
        END IF;

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

    WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
        (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  p_revised_item_tbl    => x_revised_item_tbl
        ,  p_rev_component_tbl   => x_rev_component_tbl
        ,  p_ref_designator_tbl  => x_ref_designator_tbl
        ,  p_sub_component_tbl   => x_sub_component_tbl
        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        ,  p_mesg_token_tbl      => l_mesg_token_tbl
        ,  p_error_status        => Error_Handler.G_STATUS_ERROR
        ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
        ,  p_other_status        => Error_Handler.G_STATUS_ERROR
        ,  p_other_message       => l_other_message
        ,  p_other_token_tbl     => l_other_token_tbl
        ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
        ,  p_entity_index        => I
        ,  x_eco_rec             => l_eco_rec
        ,  x_eco_revision_tbl    => l_eco_revision_tbl
        ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  x_revised_item_tbl    => x_revised_item_tbl
        ,  x_rev_component_tbl   => x_rev_component_tbl
        ,  x_ref_designator_tbl  => x_ref_designator_tbl
        ,  x_sub_component_tbl   => x_sub_component_tbl
        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        );

        IF l_bo_return_status = 'S'
        THEN
            l_bo_return_status  := l_return_status;
        END IF;


        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        RETURN;

    WHEN EXC_SEV_SKIP_BRANCH THEN

        Eco_Error_Handler.Log_Error
        (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  p_revised_item_tbl    => x_revised_item_tbl
        ,  p_rev_component_tbl   => x_rev_component_tbl
        ,  p_ref_designator_tbl  => x_ref_designator_tbl
        ,  p_sub_component_tbl   => x_sub_component_tbl
        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        ,  p_mesg_token_tbl      => l_mesg_token_tbl
        ,  p_error_status        => Error_Handler.G_STATUS_ERROR
        ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
        ,  p_other_message       => l_other_message
        ,  p_other_token_tbl     => l_other_token_tbl
        ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
        ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
        ,  p_entity_index        => I
        ,  x_ECO_rec             => l_ECO_rec
        ,  x_eco_revision_tbl    => l_eco_revision_tbl
        ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  x_revised_item_tbl    => x_revised_item_tbl
        ,  x_rev_component_tbl   => x_rev_component_tbl
        ,  x_ref_designator_tbl  => x_ref_designator_tbl
        ,  x_sub_component_tbl   => x_sub_component_tbl
        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        );

        IF l_bo_return_status = 'S'
        THEN
           l_bo_return_status          := l_return_status ;
        END IF;

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

        RETURN;

    WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
        (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  p_revised_item_tbl    => x_revised_item_tbl
        ,  p_rev_component_tbl   => x_rev_component_tbl
        ,  p_ref_designator_tbl  => x_ref_designator_tbl
        ,  p_sub_component_tbl   => x_sub_component_tbl
        ,  p_mesg_token_tbl      => l_mesg_token_tbl
        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        ,  p_error_status        => Error_Handler.G_STATUS_FATAL
        ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
        ,  p_other_message       => l_other_message
        ,  p_other_status        => Error_Handler.G_STATUS_FATAL
        ,  p_other_token_tbl     => l_other_token_tbl
        ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
        ,  p_entity_index        => I
        ,  x_ECO_rec             => l_ECO_rec
        ,  x_eco_revision_tbl    => l_eco_revision_tbl
        ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  x_revised_item_tbl    => x_revised_item_tbl
        ,  x_rev_component_tbl   => x_rev_component_tbl
        ,  x_ref_designator_tbl  => x_ref_designator_tbl
        ,  x_sub_component_tbl   => x_sub_component_tbl
        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        );

        l_return_status := 'Q';

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1


    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        Eco_Error_Handler.Log_Error
        (  p_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  p_revised_item_tbl    => x_revised_item_tbl
        ,  p_rev_component_tbl   => x_rev_component_tbl
        ,  p_ref_designator_tbl  => x_ref_designator_tbl
        ,  p_sub_component_tbl   => x_sub_component_tbl
        ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        ,  p_mesg_token_tbl      => l_mesg_token_tbl
        ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
        ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
        ,  p_other_message       => l_other_message
        ,  p_other_token_tbl     => l_other_token_tbl
        ,  p_error_level         => ECO_Error_Handler.G_CL_LEVEL
        ,  x_ECO_rec             => l_ECO_rec
        ,  x_eco_revision_tbl    => l_eco_revision_tbl
        ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
        ,  x_revised_item_tbl    => x_revised_item_tbl
        ,  x_rev_component_tbl   => x_rev_component_tbl
        ,  x_ref_designator_tbl  => x_ref_designator_tbl
        ,  x_sub_component_tbl   => x_sub_component_tbl
        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
        );

        l_return_status := 'U';

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;

        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1

  END; -- END Change Line processing block
  END IF; -- End of processing records for which the return status is null
  END LOOP; -- END Change Line processing loop

  IF l_return_status in ('Q', 'U')
  THEN
        x_return_status := l_return_status;
        RETURN;
  END IF;


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Change Line returning with ' || l_bo_return_status); END IF;

  IF NVL(l_bo_return_status, 'S') <> 'S'
  THEN
        x_return_status        := l_bo_return_status;

  END IF;

  --  Load OUT parameters
  --x_change_line_tbl          := l_change_line_tbl ;      -- Eng Change
  --x_revised_item_tbl         := l_revised_item_tbl;
  --x_rev_component_tbl        := l_rev_component_tbl;
  --x_ref_designator_tbl       := l_ref_designator_tbl;
  --x_sub_component_tbl        := l_sub_component_tbl;
  --x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;
  --x_rev_operation_tbl        := l_rev_operation_tbl;     --L1
  --x_rev_op_resource_tbl      := l_rev_op_resource_tbl;   --L1
  --x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;  --L1

END Change_Line ;



--  Eco_Rev
PROCEDURE Eco_Rev
(   p_validation_level            IN  NUMBER
,   p_change_notice               IN  VARCHAR2 := NULL
,   p_organization_id             IN  NUMBER := NULL
,   p_eco_revision_tbl            IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   p_change_line_tbl             IN  ENG_Eco_PUB.Change_Line_Tbl_Type    -- Eng Change
,   p_revised_item_tbl            IN  ENG_Eco_PUB.Revised_Item_Tbl_Type
,   p_rev_component_tbl           IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl          IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl           IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl           IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   p_rev_op_resource_tbl         IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   p_rev_sub_resource_tbl        IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_eco_revision_tbl            IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_change_line_tbl             IN OUT NOCOPY ENG_Eco_PUB.Change_Line_Tbl_Type      -- Eng Change
,   x_revised_item_tbl            IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl           IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl          IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl           IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   x_rev_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   x_rev_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status               OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_eco_parent_exists     BOOLEAN := FALSE;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_old_eco_rec           ENG_Eco_PUB.Eco_Rec_Type;
l_old_eco_unexp_rec     ENG_Eco_PUB.Eco_Unexposed_Rec_Type;
l_eco_revision_rec      ENG_Eco_PUB.Eco_Revision_Rec_Type;
--l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type := p_eco_revision_tbl;
l_eco_rev_unexp_rec     ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type;
l_old_eco_rev_rec       ENG_Eco_PUB.Eco_Revision_Rec_Type := NULL;
l_old_eco_rev_unexp_rec ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type := NULL;
--l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type := p_revised_item_tbl;
--l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type := p_rev_component_tbl;
--l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
--l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
--l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type := p_rev_operation_tbl;  --L1
--l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type :=p_rev_op_resource_tbl; --L1
--l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type :=p_rev_sub_resource_tbl; --L1
--l_change_line_tbl       Eng_Eco_Pub.Change_Line_Tbl_Type := p_change_line_tbl; -- Eng Change


l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_OBJECT     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

	-- Bug 2918350 // kamohan
	-- Start Changes

	l_chk_co_sch eng_engineering_changes.status_type%TYPE;

	-- Bug 2918350 // kamohan
	-- End Changes

BEGIN


    l_return_status := 'S';
    l_bo_return_status := 'S';

    --  Init local table variables.

    x_eco_revision_tbl                  := p_eco_revision_tbl;
    x_revised_item_tbl                  := p_revised_item_tbl;
    x_rev_component_tbl                 := p_rev_component_tbl;
    x_ref_designator_tbl                := p_ref_designator_tbl;
    x_sub_component_tbl                 := p_sub_component_tbl;
    x_rev_operation_tbl                 := p_rev_operation_tbl;
    x_rev_op_resource_tbl               := p_rev_op_resource_tbl;
    x_rev_sub_resource_tbl              := p_rev_sub_resource_tbl;
    x_change_line_tbl                   := p_change_line_tbl;

    l_eco_rev_unexp_rec.organization_id := ENG_GLOBALS.Get_org_id;

    FOR I IN 1..x_eco_revision_tbl.COUNT LOOP
    IF (x_eco_revision_tbl(I).return_status IS NULL OR
         x_eco_revision_tbl(I).return_status = FND_API.G_MISS_CHAR) THEN

    BEGIN

        --  Load local records.

        l_eco_revision_rec := x_eco_revision_tbl(I);

        l_eco_revision_rec.transaction_type :=
                UPPER(l_eco_revision_rec.transaction_type);

        IF p_change_notice IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
                l_eco_parent_exists := TRUE;
        END IF;

        -- Process Flow Step 2: Check if record has not yet been processed and
        -- that it is the child of the parent that called this procedure
        --

        IF --(l_eco_revision_rec.return_status IS NULL OR
            --l_eco_revision_rec.return_status = FND_API.G_MISS_CHAR)
           --AND
           (NOT l_eco_parent_exists
            OR
            (l_eco_parent_exists AND
             (l_eco_revision_rec.ECO_Name = p_change_notice AND
              l_eco_rev_unexp_rec.organization_id = p_organization_id)))
        THEN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_eco_revision_rec.return_status := FND_API.G_RET_STS_SUCCESS;

           -- Check if transaction_type is valid
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Transaction Type validity'); END IF;
           ENG_GLOBALS.Transaction_Type_Validity
           (   p_transaction_type       => l_eco_revision_rec.transaction_type
           ,   p_entity                 => 'ECO_Rev'
           ,   p_entity_id              => l_eco_revision_rec.revision
           ,   x_valid                  => l_valid
           ,   x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
           );

           IF NOT l_valid
           THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
           END IF;

           -- Process Flow step 3: Value-to-ID conversions
           --

           ENG_Val_To_Id.ECO_Revision_UUI_To_UI
               (  p_eco_revision_rec   => l_eco_revision_rec
                , p_eco_rev_unexp_rec  => l_eco_rev_unexp_rec
                , x_eco_rev_unexp_rec  => l_eco_rev_unexp_rec
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
               );

           -- Process Flow step 4: Verify that Revision is not NULL or MISSING
          --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check if Revision is missing or null'); END IF;
           ENG_Validate_Eco_Revision.Check_Required
                (  x_return_status              => l_return_status
                ,  p_eco_revision_rec           => l_eco_revision_rec
                ,  x_mesg_token_tbl             => l_Mesg_Token_Tbl
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_REV_KEYCOL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_eco_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;

           -- Process Flow step 5: Verify ECO's existence in database, if
           -- the revised item is being created on an ECO and the business
           -- object does not carry the ECO header

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check parent existence'); END IF;

           IF l_eco_revision_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
              AND
              NOT l_eco_parent_exists
           THEN
                ENG_Validate_ECO.Check_Existence
                ( p_change_notice       => l_eco_revision_rec.ECO_Name
                , p_organization_id     => l_eco_rev_unexp_rec.organization_id
                , p_organization_code   => l_eco_revision_rec.organization_code
                , p_calling_entity      => 'CHILD'
                , p_transaction_type    => 'XXX'
                , x_eco_rec             => l_old_eco_rec
                , x_eco_unexp_rec       => l_old_eco_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'ENG_PARENTECO_NOT_EXIST';
                   l_other_token_tbl(1).token_name := 'ECO_NAME';
                   l_other_token_tbl(1).token_value := l_eco_revision_rec.ECO_Name;
                   l_other_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                   l_other_token_tbl(2).token_value := l_eco_revision_rec.organization_code;
                   RAISE EXC_SEV_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'ENG_REV_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISION';
                   l_other_token_tbl(1).token_value := l_eco_revision_rec.revision;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;

	-- Bug 2918350
	-- Start Changes
	 IF l_eco_revision_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

	IF p_change_notice IS NOT NULL AND p_organization_id IS NOT NULL THEN
		l_chk_co_sch := ret_co_status ( p_change_notice, p_organization_id);
	ELSE
		l_chk_co_sch := ret_co_status (l_eco_revision_rec.eco_name, l_eco_rev_unexp_rec.organization_id);
	END IF;

	IF l_chk_co_sch = 4 THEN
		l_return_status := error_handler.g_status_error;
		error_handler.add_error_token (p_message_name        => 'ENG_ECO_REV_NOT_UPD',
			p_mesg_token_tbl      => l_mesg_token_tbl,
			x_mesg_token_tbl      => l_mesg_token_tbl,
			p_token_tbl           => l_token_tbl
			);
		RAISE exc_sev_quit_record;
	END IF;
        end if;
	-- End Changes

           -- Process Flow step 4: Verify Revision's existence
           --

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check Existence'); END IF;
           ENG_Validate_ECO_Revision.Check_Existence
                (  p_eco_revision_rec           => l_eco_revision_rec
                ,  p_eco_rev_unexp_rec          => l_eco_rev_unexp_rec
                ,  x_old_eco_revision_rec       => l_old_eco_rev_rec
                ,  x_old_eco_rev_unexp_rec      => l_old_eco_rev_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_REV_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_eco_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           END IF;


           -- Process Flow step 5: Is ECO Revision record an orphan ?

           IF NOT l_eco_parent_exists
           THEN

                -- Process Flow step 6(a and b): Is ECO impl/cancl,
                -- or in wkflw process ?
                --

                ENG_Validate_ECO.Check_Access
                ( p_change_notice       => l_eco_revision_rec.ECO_Name
                , p_organization_id     => l_eco_rev_unexp_rec.organization_id
                , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_Return_Status       => l_return_status
                );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        l_other_message := 'ENG_REV_ACCESS_FAT_FATAL';
                        l_other_token_tbl(1).token_name := 'REVISION';
                        l_other_token_tbl(1).token_value := l_eco_revision_rec.revision;
                        l_return_status := 'F';
                        RAISE EXC_FAT_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_REV_ACCESS_UNEXP_ERROR';
                        l_other_token_tbl(1).token_name := 'REVISION';
                        l_other_token_tbl(1).token_value := l_eco_revision_rec.revision;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;

           END IF;

           IF l_eco_revision_rec.Transaction_Type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
           THEN

                -- Process flow step 7 - Populate NULL columns for Update and
                -- Delete.

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
                Eng_Default_ECO_Revision.Populate_NULL_Columns
                (   p_eco_revision_rec          => l_eco_revision_rec
                ,   p_eco_rev_unexp_rec         => l_eco_rev_unexp_rec
                ,   p_old_eco_revision_rec      => l_old_eco_rev_rec
                ,   p_old_eco_rev_unexp_rec     => l_old_eco_rev_unexp_rec
                ,   x_eco_revision_rec          => l_eco_revision_rec
                ,   x_eco_rev_unexp_rec         => l_eco_rev_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                );

           ELSIF l_eco_revision_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

                -- Process Flow step 8: Default missing values for Operation CREATE

                 IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
                 Eng_Default_ECO_revision.Attribute_Defaulting
                        (   p_eco_revision_rec          => l_eco_revision_rec
                        ,   p_eco_rev_unexp_rec         => l_eco_rev_unexp_rec
                        ,   x_eco_revision_rec          => l_eco_revision_rec
                        ,   x_eco_rev_unexp_rec         => l_eco_rev_unexp_Rec
                        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                        ,   x_return_status             => l_Return_Status
                        );

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_REV_ATTDEF_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'REVISION';
                        l_other_token_tbl(1).token_value :=
                                                 l_eco_revision_rec.revision;
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_eco_revision_tbl    => x_eco_revision_tbl
                        ,  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                        ,  p_revised_item_tbl    => x_revised_item_tbl
                        ,  p_rev_component_tbl   => x_rev_component_tbl
                        ,  p_ref_designator_tbl  => x_ref_designator_tbl
                        ,  p_sub_component_tbl   => x_sub_component_tbl
                        ,  p_rev_operation_tbl   => x_rev_operation_tbl   --L1
                        ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl --L1
                        ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl--L1
                        ,  p_mesg_token_tbl      => l_mesg_token_tbl
                        ,  p_error_status        => 'W'
                        ,  p_error_level         => 2
                        ,  p_entity_index        => I
                        ,  x_eco_rec             => l_eco_rec
                        ,  x_eco_revision_tbl    => x_eco_revision_tbl
                        ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                        ,  x_revised_item_tbl    => x_revised_item_tbl
                        ,  x_rev_component_tbl   => x_rev_component_tbl
                        ,  x_ref_designator_tbl  => x_ref_designator_tbl
                        ,  x_sub_component_tbl   => x_sub_component_tbl
                        ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                        );
                END IF;
           END IF;

           -- Process Flow step 10 - Entity Level Validation

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;
           Eng_Validate_ECO_Revision.Check_Entity
                (  x_return_status        => l_Return_Status
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  p_eco_revision_rec     => l_eco_revision_rec
                ,  p_eco_rev_unexp_rec    => l_eco_rev_unexp_rec
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_REV_ENTVAL_UNEXP_ERROR';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_eco_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_eco_revision_tbl       => x_eco_revision_tbl
                ,  p_change_line_tbl        => x_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 2
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => x_eco_revision_tbl
                ,  x_change_line_tbl        => x_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );
           END IF;

           -- Process Flow step 11 : Database Writes

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
           ENG_ECO_Revision_Util.Perform_Writes
                (   p_eco_revision_rec          => l_eco_revision_rec
                ,   p_eco_rev_unexp_rec         => l_eco_rev_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
                l_other_message := 'ENG_REV_WRITES_UNEXP_ERROR';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_eco_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
           ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
           THEN
                Eco_Error_Handler.Log_Error
                (  p_eco_revision_tbl      => x_eco_revision_tbl
                ,  p_change_line_tbl       => x_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl      => x_revised_item_tbl
                ,  p_rev_component_tbl     => x_rev_component_tbl
                ,  p_ref_designator_tbl    => x_ref_designator_tbl
                ,  p_sub_component_tbl     => x_sub_component_tbl
                ,  p_rev_operation_tbl     => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl   => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl  => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => 2
                ,  x_eco_rec               => l_eco_rec
                ,  x_eco_revision_tbl      => x_eco_revision_tbl
                ,  x_change_line_tbl       => x_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl      => x_revised_item_tbl
                ,  x_rev_component_tbl     => x_rev_component_tbl
                ,  x_ref_designator_tbl    => x_ref_designator_tbl
                ,  x_sub_component_tbl     => x_sub_component_tbl
                ,  x_rev_operation_tbl     => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl   => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl  => x_rev_sub_resource_tbl --L1
                );
           END IF;

        END IF; -- End IF that checks RETURN STATUS AND PARENT-CHILD RELATIONSHIP

        --  Load tables.

        x_eco_revision_tbl(I)          := l_eco_revision_rec;

        --  For loop exception handler.


     EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_eco_revision_tbl       => x_eco_revision_tbl
                ,  p_change_line_tbl        => x_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl       => x_revised_item_tbl
                ,  p_rev_component_tbl      => x_rev_component_tbl
                ,  p_ref_designator_tbl     => x_ref_designator_tbl
                ,  p_sub_component_tbl      => x_sub_component_tbl
                ,  p_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => FND_API.G_RET_STS_ERROR
                ,  p_error_scope            => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level            => 2
                ,  p_entity_index           => I
                ,  x_eco_rec                => l_eco_rec
                ,  x_eco_revision_tbl       => x_eco_revision_tbl
                ,  x_change_line_tbl        => x_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl       => x_revised_item_tbl
                ,  x_rev_component_tbl      => x_rev_component_tbl
                ,  x_ref_designator_tbl     => x_ref_designator_tbl
                ,  x_sub_component_tbl      => x_sub_component_tbl
                ,  x_rev_operation_tbl      => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_eco_revision_tbl             := l_eco_revision_tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        WHEN EXC_SEV_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
            (  p_eco_revision_tbl       => x_eco_revision_tbl
             , p_change_line_tbl        => x_change_line_tbl -- Eng Change
             , p_revised_item_tbl       => x_revised_item_tbl
             , p_rev_component_tbl      => x_rev_component_tbl
             , p_ref_designator_tbl     => x_ref_designator_tbl
             , p_sub_component_tbl      => x_sub_component_tbl
             , p_rev_operation_tbl      => x_rev_operation_tbl    --L1
             , p_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
             , p_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
             , p_error_status           => Error_Handler.G_STATUS_ERROR
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_BO_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_ERROR
             , p_other_token_tbl        => l_other_token_tbl
             , x_eco_rec                => l_eco_rec
             , x_eco_revision_tbl       => x_eco_revision_tbl
             , x_change_line_tbl        => x_change_line_tbl -- Eng Change
             , x_revised_item_tbl       => x_revised_item_tbl
             , x_rev_component_tbl      => x_rev_component_tbl
             , x_ref_designator_tbl     => x_ref_designator_tbl
             , x_sub_component_tbl      => x_sub_component_tbl
             , x_rev_operation_tbl      => x_rev_operation_tbl    --L1
             , x_rev_op_resource_tbl    => x_rev_op_resource_tbl  --L1
             , x_rev_sub_resource_tbl   => x_rev_sub_resource_tbl --L1
             );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_eco_revision_tbl             := l_eco_revision_tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

       WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_eco_revision_tbl    => x_eco_revision_tbl
                ,  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
                ,  p_other_status        => Error_Handler.G_STATUS_FATAL
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 2
                ,  p_entity_index        => I
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => x_eco_revision_tbl
                ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_eco_revision_tbl             := l_eco_revision_tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_eco_revision_tbl    => x_eco_revision_tbl
                ,  p_change_line_tbl     => x_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => x_revised_item_tbl
                ,  p_rev_component_tbl   => x_rev_component_tbl
                ,  p_ref_designator_tbl  => x_ref_designator_tbl
                ,  p_sub_component_tbl   => x_sub_component_tbl
                ,  p_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 2
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => x_eco_revision_tbl
                ,  x_change_line_tbl     => x_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => x_revised_item_tbl
                ,  x_rev_component_tbl   => x_rev_component_tbl
                ,  x_ref_designator_tbl  => x_ref_designator_tbl
                ,  x_sub_component_tbl   => x_sub_component_tbl
                ,  x_rev_operation_tbl   => x_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => x_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> x_rev_sub_resource_tbl --L1
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        --x_eco_revision_tbl             := l_eco_revision_tbl;
        --x_revised_item_tbl             := l_revised_item_tbl;
        --x_rev_component_tbl            := l_rev_component_tbl;
        --x_ref_designator_tbl           := l_ref_designator_tbl;
        --x_sub_component_tbl            := l_sub_component_tbl;
        --x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        --x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        --x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        --x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        l_return_status := 'U';

        END; -- END block
     END IF; -- End of processing records for which the return status is null
     END LOOP; -- END Revisions processing loop

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

     --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     --x_eco_revision_tbl         := l_eco_revision_tbl;
     --x_revised_item_tbl         := l_revised_item_tbl;
     --x_rev_component_tbl        := l_rev_component_tbl;
     --x_ref_designator_tbl       := l_ref_designator_tbl;
     --x_sub_component_tbl        := l_sub_component_tbl;
     --x_rev_operation_tbl        := l_rev_operation_tbl;     --L1
     --x_rev_op_resource_tbl      := l_rev_op_resource_tbl;   --L1
     --x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;  --L1
     --x_change_line_tbl          := l_change_line_tbl ;      -- Eng Change

     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Eco_Rev;

PROCEDURE Create_Change_Lifecycle (
	p_change_id	 IN	NUMBER,
	p_change_type_id IN	NUMBER,
	p_user_id        IN	NUMBER,
	p_login_id       IN	NUMBER,
	x_Mesg_Token_Tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type,
	x_return_status	 IN OUT NOCOPY VARCHAR2 )
IS

  l_lifecycle_status_id NUMBER;
  l_return_status       VARCHAR2(1);
  l_err_text            VARCHAR2(2000) ;
  l_Mesg_Token_Tbl      Error_Handler.Mesg_Token_Tbl_Type ;

  /* Cursor to Fetch all the life cycle Statuses for corresponding Type. */
  CURSOR c_lifecycle_statuses IS
  SELECT *
  FROM eng_lifecycle_statuses
  WHERE entity_name = 'ENG_CHANGE_TYPE'
  AND entity_id1 = p_change_type_id;

BEGIN
	 FOR cls IN c_lifecycle_statuses
	 LOOP
                  -- fetch the CHANGE_LIFECYCLE_STATUS_ID from sequence
		SELECT ENG_LIFECYCLE_STATUSES_S.NEXTVAL
		INTO l_lifecycle_status_id
		FROM dual;

		  -- Insert the Statuses data
		INSERT INTO ENG_LIFECYCLE_STATUSES
		(   CHANGE_LIFECYCLE_STATUS_ID
		  , ENTITY_NAME
		  , ENTITY_ID1
		  , ENTITY_ID2
		  , ENTITY_ID3
		  , ENTITY_ID4
		  , ENTITY_ID5
		  , SEQUENCE_NUMBER
		  , STATUS_CODE
		  , START_DATE
		  , COMPLETION_DATE
		  , CHANGE_WF_ROUTE_ID
		  , AUTO_PROMOTE_STATUS
		  , AUTO_DEMOTE_STATUS
		  , WORKFLOW_STATUS
		  , CHANGE_EDITABLE_FLAG
		  , CREATION_DATE
		  , CREATED_BY
		  , LAST_UPDATE_DATE
		  , LAST_UPDATED_BY
		  , LAST_UPDATE_LOGIN
		  , ITERATION_NUMBER
		  , ACTIVE_FLAG
		  , CHANGE_WF_ROUTE_TEMPLATE_ID
		)
		VALUES
		(   l_lifecycle_status_id
		  , 'ENG_CHANGE'
		  , p_change_id
		  , NULL -- cls.ENTITY_ID2
		  , NULL -- cls.ENTITY_ID3
		  , NULL -- cls.ENTITY_ID4
		  , NULL -- cls.ENTITY_ID5
		  , cls.SEQUENCE_NUMBER
		  , cls.STATUS_CODE
		  , NULL -- cls.START_DATE
		  , NULL -- cls.COMPLETION_DATE
		  , NULL -- cls.CHANGE_WF_ROUTE_ID
		  , cls.AUTO_PROMOTE_STATUS
		  , cls.AUTO_DEMOTE_STATUS
		  , NULL -- cls.WORKFLOW_STATUS
		  , cls.CHANGE_EDITABLE_FLAG
		  , SYSDATE
		  , p_user_id
		  , SYSDATE
		  , p_user_id
		  , p_login_id
		  , 0 -- cls.ITERATION_NUMBER
		  , 'Y' -- cls.ACTIVE_FLAG
		  , cls.CHANGE_WF_ROUTE_ID -- cls.CHANGE_WF_ROUTE_TEMPLATE_ID
		);

		-- Inserting the status properties
		INSERT INTO  eng_status_properties(
		   CHANGE_LIFECYCLE_STATUS_ID
		 , STATUS_CODE
		 , PROMOTION_STATUS_FLAG
		 , CREATION_DATE
		 , CREATED_BY
		 , LAST_UPDATE_DATE
		 , LAST_UPDATED_BY
		 , LAST_UPDATE_LOGIN
		) SELECT l_lifecycle_status_id, status_code, PROMOTION_STATUS_FLAG,
		         sysdate, p_user_id, sysdate, p_user_id, p_login_id
		  FROM eng_status_properties
		  WHERE CHANGE_LIFECYCLE_STATUS_ID = cls.CHANGE_LIFECYCLE_STATUS_ID;
	 END LOOP; -- End loop c_lifecycle_statuses
EXCEPTION
WHEN OTHERS THEN

	IF BOM_Globals.Get_Debug = 'Y'
	THEN
		Error_Handler.Write_Debug('Unexpected Error occured in Insert in Create_Change_Lifecycle . . .' || SQLERRM);
	END IF;

	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		l_err_text := G_PKG_NAME||' : Utility (Create_Change_Lifecycle Lifecycle Insert) '||SUBSTR(SQLERRM, 1, 200);

		Error_Handler.Add_Error_Token
		(  p_message_name   => NULL
		 , p_message_text   => l_err_text
		 , p_mesg_token_tbl => l_mesg_token_tbl
		 , x_mesg_token_tbl => l_mesg_token_tbl
		);
	END IF ;

	-- Return the status and message table.
	x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
	x_mesg_token_tbl := l_mesg_token_tbl ;

END Create_Change_Lifecycle;

PROCEDURE Create_Tasks
(   p_change_id                IN  NUMBER
,   p_change_type_id           IN  NUMBER
,   p_organization_id          IN  NUMBER
,   p_transaction_type         IN VARCHAR2
,   p_approval_status_type	IN NUMBER	-- Bug 3436684
,   x_Mesg_Token_Tbl           OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status            OUT NOCOPY VARCHAR2
)
IS


CURSOR c_change_tasks (v_change_type_id    IN NUMBER,
                       v_organization_id   IN NUMBER)
IS
  SELECT tsk.sequence_number,
         tsk.required_flag,
	 tsk.default_assignee_id,
         tsk.default_assignee_type,
	 tsk.task_name,
	 tsk.description,
         typtsk.complete_before_status_code,
	 typtsk.start_after_status_code,
         typtsk.change_type_id
   FROM eng_change_tasks_vl tsk,
        eng_change_type_org_tasks typtsk
   WHERE tsk.organization_id = typtsk.organization_id
   AND typtsk.organization_id = v_organization_id
   AND tsk.change_template_id = typtsk.change_template_or_task_id
   AND typtsk.template_or_task_flag ='E'
   AND typtsk.change_type_id = v_change_type_id;

/*CURSOR c_grp_assignee ( v_default_assignee_id IN NUMBER)
IS
  SELECT member_person_id
  FROM ego_group_members_v
  WHERE group_id = v_default_assignee_id;
*/-- Commented for Bug 3311072
CURSOR c_role_assignee (v_assignee_id IN NUMBER,
		        v_assignee_type IN VARCHAR)
IS
  SELECT fg.grantee_orig_system_id
  FROM fnd_grants fg,
       fnd_menus_tl tl,
       fnd_menus m,
       (SELECT distinct f.object_id,
               e.menu_id
        FROM fnd_form_functions f,
	     fnd_menu_entries e
	WHERE e.function_id = f.function_id) r,
	fnd_objects o
  WHERE fg.grantee_orig_system='HZ_PARTY'
  AND fg.grantee_type = 'USER'
  AND fg.menu_id = tl.menu_id
  AND fg.object_id = o.object_id
  AND tl.menu_id = r.menu_id
  AND m.menu_id = tl.menu_id
  AND tl.menu_id = v_assignee_id
  AND tl.LANGUAGE= USERENV('LANG')
  AND r.object_id = o.object_id
  AND o.obj_name = v_assignee_type;

    v_assignee_id               NUMBER;
    v_assignee_type		VARCHAR2(80);
    l_change_line_rec           Eng_Eco_Pub.Change_Line_Rec_Type;
    l_change_line_unexp_rec     Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type;
    l_dest_change_id            NUMBER;
    l_msg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
    l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_sql_stmt			VARCHAR2(1000);

BEGIN




    IF p_transaction_type = 'CREATE'
    THEN

      BOM_globals.set_debug('N');



      FOR change_line IN c_change_tasks(p_change_type_id, p_organization_id)
      LOOP

        SELECT eng_change_lines_s.nextval INTO l_change_line_unexp_rec.change_line_id FROM SYS.DUAL;
        l_change_line_unexp_rec.change_id := p_change_id;
        l_change_line_unexp_rec.change_type_id := -1;
        l_change_line_rec.sequence_number := change_line.sequence_number;
        l_change_line_rec.name := change_line.task_name;
        l_change_line_rec.description := change_line.description;
        l_change_line_rec.complete_before_status_code := change_line.complete_before_status_code;
        l_change_line_rec.start_after_status_code := change_line.start_after_status_code;
        l_change_line_rec.required_flag := change_line.required_flag;
	l_change_line_unexp_rec.Approval_Status_Type := p_approval_status_type; -- Bug 3436684
	l_change_line_unexp_rec.status_code := 1; -- Bug 3436684

	--setting the Assignee_Id
	IF change_line.default_assignee_type = 'PERSON' or change_line.default_assignee_type = 'GROUP'
	THEN
	  l_change_line_unexp_rec.assignee_id := change_line.default_assignee_id;

	/*ELSIF change_line.default_assignee_type = 'GROUP'
	THEN
		--
		-- Changes Added for bug 3311072

		l_sql_stmt := ' SELECT member_person_id '
			|| ' FROM ego_group_members_v '
			|| ' WHERE group_id = :1 ';
		BEGIN
			EXECUTE IMMEDIATE l_sql_stmt INTO v_assignee_id USING change_line.default_assignee_id;
			l_change_line_unexp_rec.assignee_id := v_assignee_id;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_change_line_unexp_rec.assignee_id := NULL;
		WHEN OTHERS THEN
			IF BOM_Globals.Get_Debug = 'Y'
			THEN
				Error_Handler.Write_Debug('Unexpected Error occured in Insert . . .' || SQLERRM);
			END IF;
		END;*/
	   /*OPEN c_grp_assignee(change_line.default_assignee_id);
	   FETCH c_grp_assignee INTO v_assignee_id;
	   IF (c_grp_assignee%FOUND)
	   THEN
	     l_change_line_unexp_rec.assignee_id := v_assignee_id;
	   END IF;
	   CLOSE c_grp_assignee;*/-- Commented for bug 3311072
	   -- End changes for bug 3311072

	ELSE
	   OPEN c_role_assignee(change_line.default_assignee_id, change_line.default_assignee_type);
	   FETCH c_role_assignee INTO v_assignee_id;
	   IF (c_role_assignee%FOUND)
	   THEN
	     l_change_line_unexp_rec.assignee_id := v_assignee_id;
	   END IF;
	   CLOSE c_role_assignee;

	END IF;
	Eng_Change_Line_Util.Insert_Row
        (  p_change_line_rec => l_change_line_rec
         , p_change_line_unexp_rec => l_change_line_unexp_rec
         , x_Mesg_Token_Tbl => l_msg_token_tbl
         , x_return_status => l_return_status
        );
     x_return_status :=l_return_status ;
      END LOOP;
    END IF;


END Create_Tasks;


PROCEDURE Create_Relation(
    p_change_id                IN  NUMBER
,   p_organization_id          IN  NUMBER
,   x_Mesg_Token_Tbl           OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status            OUT NOCOPY VARCHAR2
)
is
-- Error Handlig Variables
    l_return_status       VARCHAR2(1);
    l_err_text            VARCHAR2(2000) ;
    l_Mesg_Token_Tbl      Error_Handler.Mesg_Token_Tbl_Type ;
    l_new_prop_relation   NUMBER;
  begin

 select ENG_CHANGE_OBJ_RELATIONSHIPS_S.nextval
  into l_new_prop_relation
  from dual;

  insert into eng_change_obj_relationships (
  CHANGE_RELATIONSHIP_ID,
  CHANGE_ID,
  RELATIONSHIP_CODE,
  OBJECT_TO_NAME,
  OBJECT_TO_ID1,
  OBJECT_TO_ID2,
  OBJECT_TO_ID3,
  OBJECT_TO_ID4,
  OBJECT_TO_ID5,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN )
  values(
   l_new_prop_relation,
   ENGECOBO.GLOBAL_CHANGE_ID,
   'PROPAGATED_TO',
   'ENG_CHANGE',
   p_change_id,
   ENGECOBO.GLOBAL_ORG_ID,
   p_organization_id,
   null,
   null,
   sysdate,
   Eng_Globals.Get_User_Id,
   sysdate,
   Eng_Globals.Get_User_Id,
   Eng_Globals.Get_Login_id
  );


EXCEPTION

    WHEN OTHERS THEN
       IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Unexpected Error occured in Insert . . .' || SQLERRM);
       END IF;



        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Relationship  Insert) ' ||
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

end Create_Relation;













PROCEDURE Eco_Header
(   p_validation_level            IN  NUMBER
,   p_ECO_rec                     IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_eco_revision_tbl            IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   p_change_line_tbl             IN  ENG_Eco_PUB.Change_Line_Tbl_Type    -- Eng Change
,   p_revised_item_tbl            IN  ENG_Eco_PUB.Revised_Item_Tbl_Type
,   p_rev_component_tbl           IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl          IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl           IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl           IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type   --L1
,   p_rev_op_resource_tbl         IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type --L1
,   p_rev_sub_resource_tbl        IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type--L1
,   x_ECO_rec                     IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_eco_revision_tbl            IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_change_line_tbl             IN OUT NOCOPY ENG_Eco_PUB.Change_Line_Tbl_Type      -- Eng Change
,   x_revised_item_tbl            IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl           IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl          IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl           IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status               OUT NOCOPY VARCHAR2
,   x_disable_revision            OUT NOCOPY NUMBER --Bug no:3034642
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_ECO_Rec               Eng_Eco_Pub.ECO_Rec_Type;
l_ECO_Unexp_Rec         Eng_Eco_Pub.ECO_Unexposed_Rec_Type;
l_Old_ECO_Rec           Eng_Eco_Pub.ECO_Rec_Type := NULL;
l_Old_ECO_Unexp_Rec     Eng_Eco_Pub.ECO_Unexposed_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type := p_eco_revision_tbl;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type := p_revised_item_tbl;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type := p_rev_component_tbl;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;

l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type
                                                := p_rev_operation_tbl;  --L1
l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
                                                :=p_rev_op_resource_tbl; --L1
l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
                                                :=p_rev_sub_resource_tbl;--L1

l_change_line_tbl       Eng_Eco_Pub.Change_Line_Tbl_Type := p_change_line_tbl; -- Eng Change
l_status_check_required BOOLEAN := TRUE; -- Added for enhancement 541
    -- Bug 2916558 // kamohan
    -- Start Changes

    CURSOR check_co_type ( p_change_notice VARCHAR2, p_organization_id NUMBER) IS
     SELECT ecot.type_name CHANGE_ORDER_TYPE, eec.assignee_id
       FROM eng_engineering_changes eec, eng_change_order_types_vl ecot
      WHERE eec.change_notice =p_change_notice
           AND eec.organization_id = p_organization_id
	   AND eec.change_order_type_id = ecot.change_order_type_id;

    chk_co_type check_co_type%ROWTYPE;

    l_organization_id NUMBER;

    -- Bug 2916558 // kamohan
    -- End Changes

l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;
l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;
l_profile_exist     BOOLEAN;
l_package_name   varchar2(100) :='EGO_CHANGETYPE_EXPLOSION.explodeTemplates';
l_change_subject_unexp_rec  Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type;

-- Changes for bug 3426896
l_pls_msg_count			NUMBER;
l_pls_msg_data			VARCHAR2(3000);
l_plsql_block			VARCHAR2(1000);
-- End changes for bug 3426896

-- Bug 16655761 start
l_old_sequence_number           NUMBER;
l_new_sequence_number           NUMBER;
-- Bug 16655761 end

BEGIN

    -- Begin block that processes header. This block holds the exception handlers
    -- for header errors.

    BEGIN

        --  Load entity and record-specific details into system_information record
	l_ECO_Unexp_rec.organization_id := ENG_GLOBALS.Get_Org_Id;
	l_ECO_rec := p_ECO_rec;
        l_ECO_rec.transaction_type := UPPER(l_eco_rec.transaction_type);

        -- Process Flow Step 2: Check if record has not yet been processed
        --

        IF l_ECO_rec.return_status IS NOT NULL AND
           l_ECO_rec.return_status <> FND_API.G_MISS_CHAR
        THEN
                x_return_status                := l_return_status;
                x_ECO_rec                      := l_ECO_rec;
                x_eco_revision_tbl             := l_eco_revision_tbl;
                x_revised_item_tbl             := l_revised_item_tbl;
                x_rev_component_tbl            := l_rev_component_tbl;
                x_ref_designator_tbl           := l_ref_designator_tbl;
                x_sub_component_tbl            := l_sub_component_tbl;
                x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
                x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
                x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
                x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

                RETURN;
        END IF;

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_eco_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check if transaction_type is valid
        --

        ENG_GLOBALS.Transaction_Type_Validity
        (   p_transaction_type  => l_ECO_rec.transaction_type
        ,   p_entity            => 'ECO_Header'
        ,   p_entity_id         => l_ECO_rec.ECO_Name
        ,   x_valid             => l_valid
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
        );
	IF NOT l_valid
        THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
                RAISE EXC_SEV_QUIT_RECORD;
        END IF;


        -- Process Flow step 3: Verify ECO's existence
        --
        ENG_Validate_Eco.Check_Existence
                ( p_change_notice       => l_eco_rec.ECO_Name
                , p_organization_id     => l_eco_unexp_rec.organization_id
                , p_organization_code   => l_eco_rec.organization_code
                , p_calling_entity      => 'ECO'
                , p_transaction_type    => l_eco_rec.transaction_type
                , x_eco_rec             => l_old_eco_rec
                , x_eco_unexp_rec       => l_old_eco_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
                );
	IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'ENG_ECO_EXS_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'ENG_ECO_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

        -- Process Flow step : Convert User unique index to unique index
        -- Added for bug 3591992

        ENG_Val_To_Id.ECO_Header_UUI_To_UI
        (  p_eco_rec        => l_ECO_rec
         , p_eco_unexp_rec  => l_eco_unexp_rec
         , x_eco_unexp_rec  => l_eco_unexp_rec
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Return_Status  => l_return_status
        );
	-- Process Flow step 4: Change Order Value-Id conversion
        --
	 ENG_Val_To_Id.Change_Order_VID
	 (p_ECO_rec               => l_ECO_rec
	 ,p_old_eco_unexp_rec     => l_old_eco_unexp_rec
         ,P_eco_unexp_rec         => l_eco_unexp_rec
	 ,x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
         ,x_return_status         => l_return_status
	 );
	IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
            IF l_ECO_rec.transaction_type = 'CREATE'
            THEN
                l_other_message := 'ENG_ECO_CHGVID_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
                RAISE EXC_SEV_QUIT_RECORD;
            END IF;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'ENG_ECO_CHGVID_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

        -- Process Flow step 5(a): Is ECO implemented/canceled, or in wkflw process
        -- AND
        -- Process Flow step 5(b): Does user have access to change order type
        --

	-- Added for enhancement 5414834
	IF(l_eco_unexp_rec.Status_Type = 5)
	THEN
	   l_status_check_required := FALSE;
	END IF;

        ENG_Validate_ECO.Check_Access
        ( p_change_notice       => l_ECO_rec.ECO_Name
        , p_organization_id     => l_eco_unexp_rec.organization_id
        , p_change_type_code    => l_eco_rec.change_type_code
        , p_change_order_type_id=> l_eco_unexp_rec.change_order_type_id
        , p_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
        , x_Return_Status       => l_return_status
	, p_status_check_required => l_status_check_required
        );

       -- Bug 2916558 // kamohan
	-- Start Changes

	-- Check if the CO record is updated
	IF l_eco_rec.transaction_type = eng_launch_eco_oi_pk.g_update THEN

		-- Find the Organization ID corresponding to the Organization Code
		l_organization_id := eng_val_to_id.organization
					( l_eco_rec.organization_code, l_err_text);

		-- Get the system change_order_type along with the assignee id
		OPEN check_co_type(l_eco_rec.eco_name, l_organization_id);
		FETCH check_co_type INTO chk_co_type;
		CLOSE check_co_type;

		-- If it is PLM CO and when the user tries to change the change order type
		-- raise an error and stop processing the record
		IF ( NVL(chk_co_type.change_order_type, '***') <> l_eco_rec.change_type_code AND chk_co_type.assignee_id IS NOT NULL) THEN
			l_return_status := error_handler.g_status_error;
			error_handler.add_error_token (p_message_name        => 'ENG_CHG_ORD_TYP_CNUPD',
				p_mesg_token_tbl      => l_mesg_token_tbl,
				x_mesg_token_tbl      => l_mesg_token_tbl,
				p_token_tbl           => l_token_tbl
				);
			RAISE exc_sev_quit_record;
		END IF;
	END IF;
	-- Bug 2916558 // kamohan
	-- End Changes

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'ENG_ECO_ACCESS_FAT_FATAL';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                l_return_status := 'F';
                RAISE EXC_FAT_QUIT_OBJECT;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'ENG_ECO_ACCESS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

        -- Process Flow step 6: Value-to-ID conversions
        --

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Value-Id conversions'); END IF;

        ENG_Val_To_Id.ECO_Header_VID
        (  x_Return_Status   => l_return_status
        ,  x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
        ,  p_ECO_Rec         => l_ECO_Rec
        ,  p_ECO_Unexp_Rec   => l_ECO_Unexp_Rec
        ,  x_ECO_Unexp_Rec   => l_ECO_Unexp_Rec
        );
	IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
            IF l_ECO_rec.transaction_type = 'CREATE'
            THEN
                l_other_message := 'ENG_ECO_VID_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
                RAISE EXC_SEV_QUIT_RECORD;
            END IF;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'ENG_ECO_VID_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
        THEN
                Eco_Error_Handler.Log_Error
                (  p_ECO_rec                => l_ECO_rec
                ,  p_eco_revision_tbl       => l_eco_revision_tbl
                ,  p_change_line_tbl        => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl       => l_revised_item_tbl
                ,  p_rev_component_tbl      => l_rev_component_tbl
                ,  p_ref_designator_tbl     => l_ref_designator_tbl
                ,  p_sub_component_tbl      => l_sub_component_tbl
                ,  p_rev_operation_tbl      => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl    => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl   => l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => 1
                ,  x_ECO_rec                => l_ECO_rec
                ,  x_eco_revision_tbl       => l_eco_revision_tbl
                ,  x_change_line_tbl        => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl       => l_revised_item_tbl
                ,  x_rev_component_tbl      => l_rev_component_tbl
                ,  x_ref_designator_tbl     => l_ref_designator_tbl
                ,  x_sub_component_tbl      => l_sub_component_tbl
                ,  x_rev_operation_tbl      => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl    => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl --L1
                );
        END IF;

        -- Process Flow step 7: Attribute Validation for Create and Update
        --

        IF l_ECO_rec.transaction_type IN
                (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_CREATE)
        THEN
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute validation'); END IF;

                ENG_Validate_ECO.Check_Attributes
                (   x_return_status            => l_return_status
                ,   x_err_text                 => l_err_text
                ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                ,   p_ECO_rec                  => l_ECO_rec
                ,   p_Unexp_ECO_rec            => l_ECO_Unexp_Rec
                ,   p_old_ECO_rec              => l_Old_ECO_Rec
                ,   p_old_Unexp_ECO_rec        => l_Old_ECO_Unexp_Rec
		,   p_change_line_tbl          => l_change_line_tbl --Bug no:2908248
		,   p_revised_item_tbl         => l_revised_item_tbl --Bug 2908248
                );
		IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        IF l_ECO_rec.transaction_type = 'CREATE'
                        THEN
                                l_other_message := 'ENG_ECO_ATTVAL_CSEV_SKIP';
                                l_other_token_tbl(1).token_name := 'ECO_NAME';
                                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                                RAISE EXC_SEV_SKIP_BRANCH;
                        ELSE
                                RAISE EXC_SEV_QUIT_RECORD;
                        END IF;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        l_other_message := 'ENG_ECO_ATTVAL_UNEXP_SKIP';
                        l_other_token_tbl(1).token_name := 'ECO_NAME';
                        l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;

                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                        l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec             => l_ECO_rec
                        ,  p_eco_revision_tbl    => l_eco_revision_tbl
                        ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                        ,  p_revised_item_tbl    => l_revised_item_tbl
                        ,  p_rev_component_tbl   => l_rev_component_tbl
                        ,  p_ref_designator_tbl  => l_ref_designator_tbl
                        ,  p_sub_component_tbl   => l_sub_component_tbl
                        ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                        ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                        ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                        ,  p_mesg_token_tbl      => l_mesg_token_tbl
                        ,  p_error_status        => 'W'
                        ,  p_error_level         => 1
                        ,  x_ECO_rec             => l_ECO_rec
                        ,  x_eco_revision_tbl    => l_eco_revision_tbl
                        ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                        ,  x_revised_item_tbl    => l_revised_item_tbl
                        ,  x_rev_component_tbl   => l_rev_component_tbl
                        ,  x_ref_designator_tbl  => l_ref_designator_tbl
                        ,  x_sub_component_tbl   => l_sub_component_tbl
                        ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                        ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                        ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                        );
                END IF;
        END IF;

        IF l_ECO_Rec.Transaction_Type IN
           (ENG_GLOBALS.G_OPR_UPDATE, ENG_GLOBALS.G_OPR_DELETE)
        THEN

         -- Process flow step 8 - Populate NULL columns for Update and
         -- Delete.

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
         Eng_Default_ECO.Populate_NULL_Columns
                (   p_ECO_rec           => l_ECO_Rec
                ,   p_Unexp_ECO_rec     => l_ECO_Unexp_Rec
                ,   p_Old_ECO_rec       => l_Old_ECO_Rec
                ,   p_Old_Unexp_ECO_rec => l_Old_ECO_Unexp_Rec
                ,   x_ECO_rec           => l_ECO_Rec
                ,   x_Unexp_ECO_rec     => l_ECO_Unexp_Rec
                );

     ELSIF l_ECO_Rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE THEN

         -- Process Flow step 9: Default missing values for Operation CREATE

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
         Eng_Default_ECO.Attribute_Defaulting
                (   p_ECO_rec           => l_ECO_Rec
                ,   p_Unexp_ECO_Rec     => l_ECO_Unexp_Rec
                ,   x_ECO_rec           => l_ECO_Rec
                ,   x_Unexp_ECO_Rec     => l_ECO_Unexp_Rec
                ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,   x_return_status     => l_Return_Status
                );

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
            IF l_ECO_rec.transaction_type = 'CREATE'
            THEN
                l_other_message := 'ENG_ECO_ATTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
                RAISE EXC_SEV_QUIT_RECORD;
            END IF;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'ENG_ECO_ATTDEF_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        ELSIF l_return_status ='S' AND
              l_Mesg_Token_Tbl.COUNT <>0
        THEN
                Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );
        END IF;
     END IF;

     -- Process Flow step 10 - Check Conditionally Required Fields
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check conditionally required attributes'); END IF;
     ENG_Validate_ECO.Conditionally_Required
                (   x_return_status     => l_return_status
                ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,   p_ECO_rec           => l_ECO_rec
                ,   p_Unexp_ECO_rec     => l_ECO_Unexp_Rec
                ,   p_old_ECO_rec       => l_old_ECO_rec
                ,   p_old_Unexp_ECO_rec => l_old_ECO_unexp_rec
                );
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        IF l_ECO_rec.transaction_type = 'CREATE'
        THEN
                l_other_message := 'ENG_ECO_CONREQ_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_SEV_SKIP_BRANCH;
        ELSE
                RAISE EXC_SEV_QUIT_RECORD;
        END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
        l_other_message := 'ENG_ECO_CONREQ_UNEXP_SKIP';
        l_other_token_tbl(1).token_name := 'ECO_NAME';
        l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
        RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
           l_Mesg_Token_Tbl.COUNT <>0
     THEN
        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );
     END IF;

     -- Process Flow step 11 - Entity Level Defaulting
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Defaulting'); END IF;
     ENG_Default_ECO.Entity_Defaulting
                (   p_ECO_rec            => l_ECO_rec
                ,   p_Unexp_ECO_rec      => l_ECO_unexp_rec
                ,   p_Old_ECO_rec        => l_old_ECO_rec
                ,   p_Old_Unexp_ECO_rec  => l_old_ECO_unexp_rec
                ,   x_ECO_rec            => l_ECO_rec
                ,   x_Unexp_ECO_rec      => l_ECO_unexp_rec
                ,   x_return_status      => l_return_status
                ,   x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        IF l_ECO_rec.transaction_type = 'CREATE'
        THEN
                l_other_message := 'ENG_ECO_ENTDEF_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_SEV_SKIP_BRANCH;
        ELSE
                RAISE EXC_SEV_QUIT_RECORD;
        END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
        l_other_message := 'ENG_ECO_ENTDEF_UNEXP_SKIP';
        l_other_token_tbl(1).token_name := 'ECO_NAME';
        l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
        RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
           l_Mesg_Token_Tbl.COUNT <>0
     THEN
        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );
     END IF;

     -- Process Flow step 12 - Entity Level Validation

     IF l_eco_rec.transaction_type = 'DELETE'
     THEN
       IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Calling Check_Delete...'); END IF;
       ENG_Validate_ECO.Check_Delete
               ( p_eco_rec             => l_eco_rec
               , p_Unexp_ECO_rec       => l_ECO_Unexp_Rec
               , x_return_status       => l_return_status
               , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
               );
     END IF;


     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;
     Eng_Validate_ECO.Check_Entity
                (  x_return_status        => l_Return_Status
                ,  x_err_text             => l_err_text
                ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                ,  p_ECO_rec              => l_ECO_Rec
                ,  p_Unexp_ECO_Rec        => l_ECO_Unexp_Rec
                ,  p_old_ECO_rec          => l_old_ECO_rec
                ,  p_old_unexp_ECO_rec    => l_old_ECO_unexp_rec
                );

     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        IF l_ECO_rec.transaction_type = 'CREATE'
        THEN
                l_other_message := 'ENG_ECO_ENTVAL_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
                RAISE EXC_SEV_SKIP_BRANCH;
        ELSE
                RAISE EXC_SEV_QUIT_RECORD;
        END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
                l_other_message := 'ENG_ECO_ENTVAL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ECO_NAME';
                l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
        RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
           l_Mesg_Token_Tbl.COUNT <>0
     THEN
        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );
     END IF;

     --Process Flow Step 12.5: Promote/Demote Change Order Workflow steps.
     -- Bug 16655761 start
     /* Note: Update Lifecycle table before Change Order Header
           In case of l_eco_rec.tracsaction_type is UPDATE, we need to take care of promote/demote lifecycles (WF steps)
           If l_old_sequence_number = l_new_sequence_number, we do not need to promte/demote lifecycles (WF steps)
     */

      IF ( l_return_status ='S' and (nvl(l_ECO_rec.plm_or_erp_change,'PLM')='PLM')
           and l_ECO_rec.transaction_type = Eng_Globals.G_OPR_UPDATE) THEN

          SELECT sequence_number into l_old_sequence_number
          FROM eng_lifecycle_statuses
          WHERE entity_name = 'ENG_CHANGE'
            AND entity_id1 = l_eco_unexp_rec.change_id
            AND status_code = l_old_eco_unexp_rec.status_code
            AND active_flag = 'Y';

          SELECT sequence_number into l_new_sequence_number
          FROM eng_lifecycle_statuses
          WHERE entity_name = 'ENG_CHANGE'
            AND entity_id1 = l_eco_unexp_rec.change_id
            AND status_code = l_eco_unexp_rec.status_code
            AND active_flag = 'Y';

          IF Bom_Globals.Get_Debug = 'Y'
          THEN Error_Handler.Write_Debug('Calling ENG_CHANGE_LIFECHCYLE_UTIL.Change_Phase () from seq_num:' || l_old_sequence_number  || ' to: ' || l_new_sequence_number);
          END IF;

          l_pls_msg_count := 0;
        -- Promote
          IF ( l_new_sequence_number > l_old_sequence_number)
          THEN
              ENG_CHANGE_LIFECYCLE_UTIL.Change_Phase(
                   p_api_version               => 1.0
                  ,p_commit                    => FND_API.g_false
                  ,p_object_name               => 'ENG_CHANGE'
                  ,p_change_id                 => l_eco_unexp_rec.change_id
                  ,p_status_code               => l_eco_unexp_rec.status_code
                  ,p_action_type               => ENG_CHANGE_LIFECYCLE_UTIL.G_ENG_PROMOTE -- promote/demote
                  ,p_api_caller                => 'WF'
                  ,x_return_status             => l_return_status
                  ,x_msg_count                 => l_pls_msg_count
                  ,x_msg_data                  => l_pls_msg_data
              );
         -- Demote
           ELSIF ( l_new_sequence_number < l_old_sequence_number)
           THEN
              ENG_CHANGE_LIFECYCLE_UTIL.Change_Phase(
                   p_api_version               => 1.0
                  ,p_commit                    => FND_API.g_false
                  ,p_object_name               => 'ENG_CHANGE'
                  ,p_change_id                 => l_eco_unexp_rec.change_id
                  ,p_status_code               => l_eco_unexp_rec.status_code
                  ,p_action_type               => ENG_CHANGE_LIFECYCLE_UTIL.G_ENG_DEMOTE -- promote/demote
                  ,p_api_caller                => 'WF'
                  ,x_return_status             => l_return_status
                  ,x_msg_count                 => l_pls_msg_count
                  ,x_msg_data                  => l_pls_msg_data
              );
           END IF; -- sequence_number

           /* Note: ENG_CHANGE_LIFECYCLE_UTIL.Change_Phase return x_return_status
              1) FND_API.G_RET_STS_SUCCESS = 'S'
              2) FND_API.G_RET_STS_UNEXP_ERROR = 'U'
              3) FND_API.G_RET_STS_ERROR = 'E'
           */

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

           -- Need to add routines to take care of errors.
	   IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED --'U'
	   THEN
	   	l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
	   	l_other_token_tbl(1).token_name := 'ECO_NAME';
		l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
		RAISE EXC_UNEXP_SKIP_OBJECT;
	   ELSIF l_return_status ='S' AND l_pls_msg_count <> 0
	   THEN
		FOR I IN 1..l_pls_msg_count
           	LOOP
		    Error_Handler.Add_Error_Token ( p_Message_Text => FND_MSG_PUB.get(I, 'F')
                               		      , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                               	              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                      	      );
            	END LOOP;
		Eco_Error_Handler.Log_Error
		(  p_ECO_rec             => l_ECO_rec
		,  p_eco_revision_tbl    => l_eco_revision_tbl
		,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
		,  p_revised_item_tbl    => l_revised_item_tbl
		,  p_rev_component_tbl   => l_rev_component_tbl
		,  p_ref_designator_tbl  => l_ref_designator_tbl
		,  p_sub_component_tbl   => l_sub_component_tbl
		,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
		,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
		,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
		,  p_mesg_token_tbl      => l_mesg_token_tbl
		,  p_error_status        => 'W'
		,  p_error_level         => 1
		,  x_ECO_rec             => l_ECO_rec
		,  x_eco_revision_tbl    => l_eco_revision_tbl
		,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
		,  x_revised_item_tbl    => l_revised_item_tbl
		,  x_rev_component_tbl   => l_rev_component_tbl
		,  x_ref_designator_tbl  => l_ref_designator_tbl
		,  x_sub_component_tbl   => l_sub_component_tbl
		,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
		,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
		,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
		);
	   END IF; -- if l_return_status
      END IF; -- if transaction = Eng_Globals.G_OPR_UPDATE
      -- Bug 16655761 end

     -- Process Flow step 13 : Database Writes
     SAVEPOINT EngEcoPvt_Eco_Header; -- bug 3572721
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
     ENG_ECO_Util.Perform_Writes
                (   p_ECO_rec          => l_ECO_rec
                ,   p_Unexp_ECO_rec    => l_ECO_unexp_rec
                ,   p_old_ECO_rec      => l_old_ECO_rec
                ,   x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                ,   x_return_status    => l_return_status
                );

     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
        l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
        l_other_token_tbl(1).token_name := 'ECO_NAME';
        l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
        RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
           l_Mesg_Token_Tbl.COUNT <>0
     THEN
        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );
     END IF;

     --
     -- Subjects Handling
     --
     IF l_return_status = 'S' AND nvl(l_ECO_rec.plm_or_erp_change, 'PLM')='PLM'
     THEN
         ENG_Eco_Util.Change_Subjects
         ( p_eco_rec             =>       l_ECO_rec
         , p_ECO_Unexp_Rec       =>       l_ECO_unexp_rec
         , x_change_subject_unexp_rec  =>l_change_subject_unexp_rec
         , x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl --bug 3572721
         , x_return_status  => l_return_status);

	 -- Added subjects error Handling for bug 3572721
         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Subjects created with status  ' || l_return_status);
         END IF;
         IF l_return_status = Error_Handler.G_STATUS_ERROR
         THEN
            Rollback TO EngEcoPvt_Eco_Header; -- bug 3572721
            RAISE EXC_SEV_SKIP_BRANCH;
         ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'ECO_NAME';
            l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;
     END IF;

   l_profile_exist := FND_PROFILE.DEFINED ( 'EGO_ITEM_RESTRICT_INV_ACTIONS' );

  if 	 l_return_status ='S'and  l_ECO_rec.plm_or_erp_change='PLM' and
         l_ECO_rec.transaction_type = Eng_Globals.G_OPR_CREATE  then

--    if l_profile_exist = TRUE    then
         /*    The procedure first explodes and inserts the Statuses for
              the given Type, Routes for each Status, Steps for each Route,
          People for each Step, and Persons for each Group and Role. */

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;

    /*
       --subjects handling

     ENG_Eco_Util.Change_Subjects
        ( p_eco_rec             =>       l_ECO_rec
        , p_ECO_Unexp_Rec       =>       l_ECO_unexp_rec
        , x_change_subject_unexp_rec  =>l_change_subject_unexp_rec
        , x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl --bug 3572721
        , x_return_status  => l_return_status);

     -- Added subjects error Handling for bug 3572721
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Subjects created with status  ' || l_return_status);
     END IF;
     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        Rollback TO EngEcoPvt_Eco_Header; -- bug 3572721
        RAISE EXC_SEV_SKIP_BRANCH;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
        l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
        l_other_token_tbl(1).token_name := 'ECO_NAME';
        l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
        RAISE EXC_UNEXP_SKIP_OBJECT;
     END IF;
     */

       --tasks craetion
       Create_Tasks
		(   p_change_id           => l_eco_unexp_rec.change_id
		,   p_change_type_id      => l_ECO_unexp_rec.change_order_type_id
		,   p_organization_id     => l_eco_unexp_rec.organization_id
		,   p_transaction_type    => l_ECO_rec.transaction_type
		,   p_approval_status_type=> l_eco_unexp_rec.approval_status_type  -- Bug 3436684
		,   x_Mesg_Token_Tbl      => l_mesg_token_tbl
		,   x_return_status       => l_return_status
		);

	-- Changes for bug 3547737
      /*execute immediate 'begin ' || l_package_name || '(:1,:2, :3,:4,:5,:6,:7,:8); end;'
           using
	    in l_ECO_unexp_rec.change_id ,
	    in l_ECO_unexp_rec.change_order_type_id,
	   in l_user_id ,
	   in l_login_id,
	   in l_prog_appid,
	   in l_prog_id ,
	   in l_request_id,
	   in out l_err_text;*/ -- Commented.

	-- Creating the lifecycle for the change object from its header level definition

	Create_Change_Lifecycle(
	   p_change_id		=> l_eco_unexp_rec.change_id
	 , p_change_type_id	=> l_ECO_unexp_rec.change_order_type_id
	 , p_user_id		=> l_user_id
	 , p_login_id		=> l_login_id
	 , x_Mesg_Token_Tbl	=> l_mesg_token_tbl
	 , x_return_status	=> l_return_status);

	IF (l_return_status = Error_Handler.G_STATUS_UNEXPECTED)
	THEN
		l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
		l_other_token_tbl(1).token_name := 'ECO_NAME';
		l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
		RAISE EXC_UNEXP_SKIP_OBJECT;
	END IF;
	-- End Changes for bug 3547737

   IF l_ECO_Unexp_Rec.Status_Type <> 0 AND l_ECO_Unexp_Rec.Status_Code <> 0
      AND l_ECO_Unexp_Rec.Status_Code <> 7
      -- Bug# 12791511, creating ECO in released status, if uses Init_Lifecycle, if will reset the status_code to Open
      -- also since in API creation, we all need explode workflow manually, so Init_Lifecycle is not needed with release status.
   THEN
	-- Changes for bug 3426896
	-- Initializing the lifecycle
	BEGIN
		l_pls_msg_count := 0;
		l_plsql_block := 'BEGIN '
			|| 'ENG_CHANGE_LIFECYCLE_UTIL.Init_Lifecycle('
			|| '  p_api_version		=> :1'
			|| ', p_change_id		=> :2'
			|| ', x_return_status	=> :3'
			|| ', x_msg_count		=> :4'
			|| ', x_msg_data		=> :5'
			|| ', p_api_caller		=> :6'
			|| '); END;';
		EXECUTE IMMEDIATE l_plsql_block USING IN 1.0, IN l_eco_unexp_rec.change_id,
		OUT l_return_status, OUT l_pls_msg_count, OUT l_pls_msg_data, IN 'CP';

		IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
		THEN
			l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
			l_other_token_tbl(1).token_name := 'ECO_NAME';
			l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
			RAISE EXC_UNEXP_SKIP_OBJECT;
		ELSIF l_return_status ='S' AND l_pls_msg_count <> 0
		THEN

			FOR I IN 1..l_pls_msg_count
            LOOP
				Error_Handler.Add_Error_Token
                                ( p_Message_Text => FND_MSG_PUB.get(I, 'F')
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );

            END LOOP;
			Eco_Error_Handler.Log_Error
				(  p_ECO_rec             => l_ECO_rec
				,  p_eco_revision_tbl    => l_eco_revision_tbl
				,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
				,  p_revised_item_tbl    => l_revised_item_tbl
				,  p_rev_component_tbl   => l_rev_component_tbl
				,  p_ref_designator_tbl  => l_ref_designator_tbl
				,  p_sub_component_tbl   => l_sub_component_tbl
				,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
				,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
				,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
				,  p_mesg_token_tbl      => l_mesg_token_tbl
				,  p_error_status        => 'W'
				,  p_error_level         => 1
				,  x_ECO_rec             => l_ECO_rec
				,  x_eco_revision_tbl    => l_eco_revision_tbl
				,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
				,  x_revised_item_tbl    => l_revised_item_tbl
				,  x_rev_component_tbl   => l_rev_component_tbl
				,  x_ref_designator_tbl  => l_ref_designator_tbl
				,  x_sub_component_tbl   => l_sub_component_tbl
				,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
				,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
				,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
				);
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
		IF Bom_Globals.Get_Debug = 'Y'
		THEN
			Error_Handler.Write_Debug('Lifecycle initialized with status ' || l_return_status);
		END IF;
		l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
		l_other_token_tbl(1).token_name := 'ECO_NAME';
		l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
		RAISE EXC_UNEXP_SKIP_OBJECT;

	END;
   END IF;
	-- End changes for bug 3426896
	IF (ENGECOBO.GLOBAL_CHANGE_ID <> -1)
	THEN
      --relationship creation
        Create_Relation(
            p_change_id           =>  l_eco_unexp_rec.change_id
          , p_organization_id     => l_eco_unexp_rec.organization_id
          , x_Mesg_Token_Tbl      => l_mesg_token_tbl
          , x_return_status       => l_return_status);
        -- Fix for Bug 4517503
        -- Resetting the global value of ENGECOBO.GLOBAL_CHANGE_ID which is used to
        -- detaermine whether a relation is to be created or not.
        -- ECO BO is also being called by IOI in the same session when auto-enabling
        -- component items and since the value  was retained , ended up creating a
        -- relationship for NIR.
        -- So as to avaoid this it has to be reset once the relation has been created.
        ENGECOBO.GLOBAL_CHANGE_ID := -1;
        -- End of Fix for Bug 4517503

	END IF;


  --  end if; --end of if

  end if;



     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Tasks created with status  ' || l_return_status);
     END IF;

     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
        l_other_message := 'ENG_ECO_WRITES_UNEXP_SKIP';
        l_other_token_tbl(1).token_name := 'ECO_NAME';
        l_other_token_tbl(1).token_value := l_ECO_rec.ECO_Name;
        RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
           l_Mesg_Token_Tbl.COUNT <>0
     THEN
     Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => 'W'
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );
       END IF;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => FND_API.G_RET_STS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status        => Error_Handler.G_STATUS_ERROR
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 1
                ,  x_eco_rec             => l_eco_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eco_rec                      := l_eco_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        RETURN;

    WHEN EXC_SEV_SKIP_BRANCH THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope         => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        RETURN;

    WHEN EXC_FAT_QUIT_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_error_status        => Error_Handler.G_STATUS_FATAL
                ,  p_error_scope         => Error_Handler.G_SCOPE_ALL
                ,  p_other_message       => l_other_message
                ,  p_other_status        => Error_Handler.G_STATUS_FATAL
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change
        l_return_status := 'Q';

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec             => l_ECO_rec
                ,  p_eco_revision_tbl    => l_eco_revision_tbl
                ,  p_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl    => l_revised_item_tbl
                ,  p_rev_component_tbl   => l_rev_component_tbl
                ,  p_ref_designator_tbl  => l_ref_designator_tbl
                ,  p_sub_component_tbl   => l_sub_component_tbl
                ,  p_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl      => l_mesg_token_tbl
                ,  p_error_status        => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status        => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message       => l_other_message
                ,  p_other_token_tbl     => l_other_token_tbl
                ,  p_error_level         => 1
                ,  x_ECO_rec             => l_ECO_rec
                ,  x_eco_revision_tbl    => l_eco_revision_tbl
                ,  x_change_line_tbl     => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl    => l_revised_item_tbl
                ,  x_rev_component_tbl   => l_rev_component_tbl
                ,  x_ref_designator_tbl  => l_ref_designator_tbl
                ,  x_sub_component_tbl   => l_sub_component_tbl
                ,  x_rev_operation_tbl   => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl --L1
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change
        l_return_status := 'U';

  END; -- END Header processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

    -- Process ECO Revisions that are chilren of this header

    Eco_Rev
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_eco_revision_tbl          => l_eco_revision_tbl
        ,   p_change_line_tbl           => l_change_line_tbl -- Eng Change
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_change_line_tbl           => l_change_line_tbl -- Eng Change
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

   -- Process Change Line that are chilren of this header
   Change_Line
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


    -- Process Revised Items that are chilren of this header

    Rev_Items
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
	,    x_disable_revision          => x_disable_revision        --Bug no:3034642
        );

    -- Bug 6657209. Reset the global variable after Rev_items are processed.
    Eng_Default_Revised_Item.G_OLD_SCHED_DATE := NULL;

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


   -- L1: The following is for ECO enhancement
   -- Process operations that are orphans (without immediate revised
   -- item parents) but are indirect children of this header
    Rev_Operation_Sequences
       (    p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_rev_operation_tbl         => l_rev_operation_tbl
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
     );
    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

   -- Process operation resources that are orphans (without immediate revised
   -- operation parents) but are indirect children of this header
       Rev_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    -- Process substitute resources that are orphans (without immediate revised
    -- operaion parents) but are indirect children of this header
      Rev_Sub_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


    -- Process Revised Components that are orphans (without immediate revised
    -- item parents) but are indirect children of this header

    Rev_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    -- Process Reference Designators that are orphans (without immediate revised
    -- component parents) but are indirect children of this header

    Ref_Desgs
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

   -- Process Substitute Components that are orphans (without immediate revised
   -- component parents) but are indirect children of this header

    Sub_Comps
        (   p_validation_level          => p_validation_level
        ,   p_change_notice             => l_eco_rec.ECO_Name
        ,   p_organization_id           => l_eco_unexp_rec.organization_id
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


  -- The above is for ECO enhancement
  --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;     --L1
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;   --L1
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;  --L1
     x_change_line_tbl          := l_change_line_tbl ;      -- Eng Change

END Eco_Header;


--  Start of Comments
--  API name    Process_Eco
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Eco
(   p_api_version_number        IN  NUMBER
,   p_validation_level          IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec               IN  ENG_GLOBALS.Control_Rec_Type :=
                                    ENG_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_msg_count                 OUT NOCOPY NUMBER
,   p_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                    ENG_Eco_PUB.G_MISS_ECO_REC
,   p_eco_revision_tbl          IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                    ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
,   p_change_line_tbl           IN  ENG_Eco_PUB.Change_Line_Tbl_Type :=   -- Eng Change
                                    ENG_Eco_PUB.G_MISS_CHANGE_LINE_TBL
,   p_revised_item_tbl          IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                    ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl         IN  BOM_BO_PUB.Rev_Component_Tbl_Type :=
                                    BOM_BO_PUB.G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl        IN  BOM_BO_PUB.Ref_Designator_Tbl_Type :=
                                    BOM_BO_PUB.G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl         IN  BOM_BO_PUB.Sub_Component_Tbl_Type :=
                                    BOM_BO_PUB.G_MISS_SUB_COMPONENT_TBL
,   p_rev_operation_tbl         IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type:=    --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL
,   p_rev_op_resource_tbl       IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type := --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL --L1
,   p_rev_sub_resource_tbl      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type:= --L1
                                    Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL --L1
,   x_ECO_rec                   IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_eco_revision_tbl          IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_change_line_tbl           IN OUT NOCOPY ENG_Eco_PUB.Change_Line_Tbl_Type      -- Eng Change
,   x_revised_item_tbl          IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl         IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl        IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl         IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   x_disable_revision          OUT NOCOPY NUMBER --Bug no:3034642
,   p_skip_nir_expl             IN VARCHAR2 DEFAULT FND_API.G_FALSE -- bug 15831337: skip nir explosion flag
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Eco';
l_err_text                    VARCHAR2(240);
l_return_status               VARCHAR2(1);
/* Added variable to hold business object status
   Added by AS on 03/17/99 to fix bug 852322
*/
l_bo_return_status            VARCHAR2(1);

l_organization_id       NUMBER;  -- Ehn 13727612

l_control_rec                 ENG_GLOBALS.Control_Rec_Type;

l_ECO_rec                     ENG_Eco_PUB.Eco_Rec_Type := p_ECO_rec;
l_eco_revision_rec            ENG_Eco_PUB.Eco_Revision_Rec_Type;
l_eco_revision_tbl            ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_rec            ENG_Eco_PUB.Revised_Item_Rec_Type;
l_revised_item_tbl            ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_rec           BOM_BO_PUB.Rev_Component_Rec_Type;
l_rev_component_tbl           BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_rec          BOM_BO_PUB.Ref_Designator_Rec_Type;
l_ref_designator_tbl          BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_rec           BOM_BO_PUB.Sub_Component_Rec_Type;
l_sub_component_tbl           BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl           Bom_Rtg_Pub.Rev_Operation_Tbl_Type;     -- L1--
l_rev_op_resource_tbl         Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;   -- L1--
l_rev_sub_resource_tbl        Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;  -- L1--
l_rev_operation_rec           Bom_Rtg_Pub.Rev_Operation_Rec_Type;     -- L1--
l_rev_op_resource_rec         Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type;   -- L1--
l_rev_sub_resource_rec        Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type;  -- L1--
l_change_line_rec             ENG_Eco_PUB.Change_Line_Rec_Type ;      -- Eng Change
l_change_line_tbl             ENG_Eco_PUB.Change_Line_Tbl_Type ;      -- Eng Change

l_mesg_token_tbl              Error_Handler.Mesg_Token_Tbl_Type;
l_other_message               VARCHAR2(2000);
l_other_token_tbl             Error_Handler.Token_Tbl_Type;

EXC_ERR_PVT_API_MAIN          EXCEPTION;

BEGIN

    --dbms_output.enable(1000000);


    --  Standard call to check for call compatibility

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('The following objects will be processed as part of the same business object'); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| ECO           : ' || l_ECO_rec.eco_name); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| ECO REVISIONS : ' || to_char(p_eco_revision_tbl.COUNT)); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| CHANGE LINES  : ' || to_char(p_change_line_tbl.COUNT)); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| REVISED ITEMS : ' || to_char(p_revised_item_tbl.COUNT)); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| REVISED COMPS : ' || to_char(p_rev_component_tbl.COUNT)); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| SUBS. COMPS   : ' || to_Char(p_sub_component_tbl.COUNT)); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| REFD. DESGS   : ' || to_char(p_ref_designator_tbl.COUNT)); END IF;

--L1--
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| OPERATION     : ' || to_char(p_rev_operation_tbl.COUNT)); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| RESOURCE      : ' || to_char(p_rev_op_resource_tbl.COUNT)); END IF;
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('| SUB RESOURCE  : ' || to_char(p_rev_sub_resource_tbl.COUNT)); END IF;
--L1--


    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('|----------------------------------------------------');  END IF;

/*------------------------------------
-- Not used

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE EXC_ERR_PVT_API_MAIN;
    END IF;
------------------------------------*/


    --  Init local variables

    l_ECO_rec                      := p_ECO_rec;

    --  Init local table variables.

    l_eco_revision_tbl             := p_eco_revision_tbl;
    l_revised_item_tbl             := p_revised_item_tbl;
    l_rev_component_tbl            := p_rev_component_tbl;
    l_ref_designator_tbl           := p_ref_designator_tbl;
    l_sub_component_tbl            := p_sub_component_tbl;
    l_rev_operation_tbl            := p_rev_operation_tbl;     --L1
    l_rev_op_resource_tbl          := p_rev_op_resource_tbl;   --L1
    l_rev_sub_resource_tbl         := p_rev_sub_resource_tbl;  --L1
    l_change_line_tbl              := p_change_line_tbl ;      -- Eng Change


--  Added by AS on 03/17/99 to fix bug 852322
    l_bo_return_status := 'S';

    -- Load environment information into the SYSTEM_INFORMATION record
    -- (USER_ID, LOGIN_ID, PROG_APPID, PROG_ID)


    ENG_GLOBALS.Init_System_Info_Rec
                        (  x_mesg_token_tbl => l_mesg_token_tbl
                        ,  x_return_status  => l_return_status
                        );

    -- Initialize System_Information Unit_Effectivity flag
    -- Modified on Sep 27,2001 by bzhang
   /* IF FND_PROFILE.DEFINED('PJM:PJM_UNITEFF_NO_EFFECT') AND
       FND_PROFILE.VALUE('PJM:PJM_UNITEFF_NO_EFFECT') = 'Y'
   */
    IF PJM_UNIT_EFF.Enabled = 'Y'
    THEN
        BOM_Globals.Set_Unit_Effectivity (TRUE);
        ENG_Globals.Set_Unit_Effectivity (TRUE);
    ELSE
        BOM_Globals.Set_Unit_Effectivity (FALSE);
        ENG_Globals.Set_Unit_Effectivity (FALSE);
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        RAISE EXC_ERR_PVT_API_MAIN;
    END IF;
    --  Eco
    IF  (l_ECO_rec.ECO_Name <> FND_API.G_MISS_CHAR
         AND l_ECO_rec.ECO_Name IS NOT NULL)
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling ECO_Header'); END IF;

        Eco_Header
        (   p_validation_level          => p_validation_level
        ,   p_ECO_rec                   => l_ECO_rec
        ,   p_eco_revision_tbl          => l_eco_revision_tbl
        ,   p_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
	 ,   x_disable_revision          =>x_disable_revision --Bug no:3034642
        );
	IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('eco hdr return status: ' || l_eco_rec.return_status); END IF;

        -- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

   --  Eco Revisions
   IF l_eco_revision_tbl.Count <> 0
   THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling ECO_Rev'); END IF;

        Eco_Rev
        (   p_validation_level          => p_validation_level
        ,   p_eco_revision_tbl          => l_eco_revision_tbl
        ,   p_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
	-- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;


   --  Change Lines
   IF l_change_line_tbl.Count <> 0
   THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling Change_Line'); END IF;

        Change_Line
        (   p_validation_level          => p_validation_level
        ,   p_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_change_line_tbl           => l_change_line_tbl      -- Eng Change
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
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

    END IF;

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

    --  Revised Items

    IF p_revised_item_tbl.COUNT <> 0
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling Rev_Items'); END IF;

        Rev_Items
        (   p_validation_level          => p_validation_level
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl    --L1
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl  --L1
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl --L1
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
	,    x_disable_revision          => x_disable_revision        --Bug no:3034642
        );

       -- Bug 6657209. Reset the global variable after Rev_items are processed.
       Eng_Default_Revised_Item.G_OLD_SCHED_DATE := NULL;

	-- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

    --  Revised Components

    IF l_rev_component_tbl.Count <> 0
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling Rev_Comps'); END IF;

        Rev_Comps
        (   p_validation_level          => p_validation_level
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
	-- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

    --  Reference Designators

    IF l_ref_designator_tbl.Count <> 0
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling Ref_Desgs'); END IF;

        Ref_Desgs
        (   p_validation_level          => p_validation_level
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
	-- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

    --  Substitute Components

    IF l_Sub_Component_Tbl.Count <> 0
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling Sub_Comps'); END IF;

        Sub_Comps
        (   p_validation_level          => p_validation_level
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );
	-- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;


  --  L1:  Operation

    IF l_rev_operation_tbl.Count <> 0
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling ECO operation'); END IF;

       Rev_Operation_Sequences
        (   p_validation_level          => p_validation_level
        ,   p_rev_operation_tbl         => l_rev_operation_tbl
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
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

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

--  L1:  Operation Resource

    IF l_rev_op_resource_tbl.Count <> 0
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling ECO resource'); END IF;

        Rev_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
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

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

--  L1: Substitute resource

    IF l_rev_sub_resource_tbl.Count <> 0
    THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(' '); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('PVT API: Calling ECO substitute resource'); END IF;

      Rev_Sub_Operation_Resources
        (   p_validation_level          => p_validation_level
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
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

    END IF;

   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BO error status: ' || l_bo_return_status); END IF;

    --  Done processing, load OUT parameters.

    --  Added by AS on 03/17/99 to fix bug 852322
    x_return_status                := l_bo_return_status;

    x_ECO_rec                      := l_ECO_rec;
    x_eco_revision_tbl             := l_eco_revision_tbl;
    x_revised_item_tbl             := l_revised_item_tbl;
    x_rev_component_tbl            := l_rev_component_tbl;
    x_ref_designator_tbl           := l_ref_designator_tbl;
    x_sub_component_tbl            := l_sub_component_tbl;
    x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
    x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
    x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
    x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change



    -- Initialize System_Information Unit_Effectivity flag


    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN

        NULL;

    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN

        NULL;

    END IF;

    -- Reset system_information business object flags

    ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
    ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
    ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
    ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
    ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

    -- Find the Organization ID corresponding to the Organization Code
    l_organization_id := eng_val_to_id.organization
        ( l_eco_rec.organization_code, l_err_text);

    -- bug 15831337: skip nir explosion flag
    G_Skip_NIR_Expl := p_skip_nir_expl;
    if (G_Skip_NIR_Expl = FND_API.G_TRUE) then
      null;
    else

	    -- Ehn 10647772: Change Order Workflow Auto Explosion and Submission
	    Explode_WF_Routing(p_change_notice => l_ECO_rec.eco_name,
	            p_org_id => l_organization_id,
	            x_return_status => l_return_status,
	            x_Mesg_Token_Tbl => l_Mesg_Token_Tbl);
    end if;

    --Bug No: 3737881
    --Commenting out the following code as no 'Commit' should
    --be done in this API.
    --IF ENG_GLOBALS.G_ENG_LAUNCH_IMPORT = 1 THEN
    --       Error_Handler.Write_To_ConcurrentLog;
    --       Error_Handler.WRITE_TO_INTERFACETABLE;
    --       COMMIT;
    --END IF;

EXCEPTION

    WHEN EXC_ERR_PVT_API_MAIN THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec            => l_ECO_rec
                ,  p_eco_revision_tbl   => l_eco_revision_tbl
                ,  p_change_line_tbl    => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl   => l_revised_item_tbl
                ,  p_rev_component_tbl  => l_rev_component_tbl
                ,  p_ref_designator_tbl => l_ref_designator_tbl
                ,  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => FND_API.G_RET_STS_UNEXP_ERROR
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 0
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_change_line_tbl    => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
                );

        x_return_status                := l_return_status;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        -- Reset system_information business object flags

    ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
    ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
    ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
    ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
    ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN G_EXC_QUIT_IMPORT THEN

        x_return_status                := l_return_status;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        -- Reset system_information business object flags

    ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
    ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
    ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
    ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
    ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME || ' : Process ECO '
                        || substrb(SQLERRM,1,200);
                Error_Handler.Add_Error_Token
                        ( p_Message_Text => l_err_text
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        );
        END IF;

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec            => l_ECO_rec
                ,  p_eco_revision_tbl   => l_eco_revision_tbl
                ,  p_change_line_tbl    => l_change_line_tbl -- Eng Change
                ,  p_revised_item_tbl   => l_revised_item_tbl
                ,  p_rev_component_tbl  => l_rev_component_tbl
                ,  p_ref_designator_tbl => l_ref_designator_tbl
                ,  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --L1
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => FND_API.G_RET_STS_UNEXP_ERROR
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 0
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_change_line_tbl    => l_change_line_tbl -- Eng Change
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --L1
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --L1
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --L1
                );

        x_return_status                := l_return_status;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --L1
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --L1
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --L1
        x_change_line_tbl              := l_change_line_tbl ;      -- Eng Change

        -- Reset system_information business object flags

    ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
    ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
    ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
    ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
    ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

END Process_Eco;

--  Start of Comments
--  API name    Lock_Eco
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Eco
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REC
,   p_eco_revision_tbl              IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_SUB_COMPONENT_TBL
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_err_text                      OUT NOCOPY VARCHAR2
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Eco';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_eco_revision_rec            ENG_Eco_PUB.Eco_Revision_Rec_Type;
l_revised_item_rec            ENG_Eco_PUB.Revised_Item_Rec_Type;
l_rev_component_rec           BOM_BO_PUB.Rev_Component_Rec_Type;
l_ref_designator_rec          BOM_BO_PUB.Ref_Designator_Rec_Type;
l_sub_component_rec           BOM_BO_PUB.Sub_Component_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

NULL;

/*********************** Temporarily commented *****************************

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Eco_PVT;

    --  Lock ECO

    IF p_ECO_rec.operation = ENG_GLOBALS.G_OPR_LOCK THEN

        ENG_Eco_Util.Lock_Row
        (   p_ECO_rec                     => p_ECO_rec
        ,   x_ECO_rec                     => x_ECO_rec
        ,   x_return_status               => l_return_status
        ,   x_err_text                    => x_err_text
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock eco_revision

    FOR I IN 1..p_eco_revision_tbl.COUNT LOOP

        IF p_eco_revision_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Eco_Revision_Util.Lock_Row
            (   p_eco_revision_rec            => p_eco_revision_tbl(I)
            ,   x_eco_revision_rec            => l_eco_revision_rec
            ,   x_return_status               => l_return_status
            ,   x_err_text                          => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_eco_revision_tbl(I)          := l_eco_revision_rec;

        END IF;

    END LOOP;

    --  Lock revised_item

    FOR I IN 1..p_revised_item_tbl.COUNT LOOP

        IF p_revised_item_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Revised_Item_Util.Lock_Row
            (   p_revised_item_rec            => p_revised_item_tbl(I)
            ,   x_revised_item_rec            => l_revised_item_rec
            ,   x_return_status               => l_return_status
            ,   x_err_text                    => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_revised_item_tbl(I)          := l_revised_item_rec;

        END IF;

    END LOOP;

    --  Lock rev_component

    FOR I IN 1..p_rev_component_tbl.COUNT LOOP

        IF p_rev_component_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            Bom_Bom_Component_Util.Lock_Row
            (   p_rev_component_rec           => p_rev_component_tbl(I)
            ,   x_rev_component_rec           => l_rev_component_rec
            ,   x_return_status               => l_return_status
                ,   x_err_text                      => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_rev_component_tbl(I)         := l_rev_component_rec;

        END IF;

    END LOOP;

    --  Lock ref_designator

    FOR I IN 1..p_ref_designator_tbl.COUNT LOOP

        IF p_ref_designator_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            Bom_Ref_Designator_Util.Lock_Row
            (   p_ref_designator_rec          => p_ref_designator_tbl(I)
            ,   x_ref_designator_rec          => l_ref_designator_rec
            ,   x_return_status               => l_return_status
            ,   x_err_text                    => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_ref_designator_tbl(I)        := l_ref_designator_rec;

        END IF;

    END LOOP;

    --  Lock sub_component

    FOR I IN 1..p_sub_component_tbl.COUNT LOOP

        IF p_sub_component_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Sub_Component_Util.Lock_Row
            (   p_sub_component_rec           => p_sub_component_tbl(I)
            ,   x_sub_component_rec           => l_sub_component_rec
            ,   x_return_status               => l_return_status
            ,   x_err_text                    => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_sub_component_tbl(I)         := l_sub_component_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Eco_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Eco_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Eco'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Eco_PVT;

****************************************************************************/

END Lock_Eco;

 -- Ehn 13727612: Change Order Workflow Auto Explosion and Submission
PROCEDURE Explode_WF_Routing(p_change_notice IN VARCHAR2,
                    p_org_id        IN NUMBER,
                    x_return_status IN  OUT NOCOPY   VARCHAR2,
                    x_Mesg_Token_Tbl  IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type ) IS

    TYPE Items_Org_Role_Rec_Type IS RECORD(
      Grantee_Type VARCHAR2(1) := EGO_ITEM_PUB.G_MISS_CHAR,
      Role_Id      NUMBER := EGO_ITEM_PUB.G_MISS_NUM,
      Party_Id     NUMBER := EGO_ITEM_PUB.G_MISS_NUM);

    TYPE Items_Org_Role_Tbl_Type IS TABLE OF Items_Org_Role_Rec_Type INDEX BY BINARY_INTEGER;

    l_return_status               VARCHAR2(1);
    l_to_route_id NUMBER;
    l_people_id   NUMBER;

    l_instance_set_id      number := EGO_ITEM_PUB.G_MISS_NUM;
    l_item_role_type_id    number := EGO_ITEM_PUB.G_MISS_NUM;
    l_items_org_role_table Items_Org_Role_Tbl_Type;
    c_index                number := 1;
    t_index                number := 1;

    l_people_existed_flag number := 0;
    l_row_inserted_flag number := 0;  -- bug 13860012
    l_submit_flag varchar(1) := 1;      -- 1: Yes; 2: No
    l_change_mgmt_type_code VARCHAR2(50) := EGO_ITEM_PUB.G_MISS_CHAR;

    l_change_id number;

    -- bug 13921167 start
    l_menu_name    VARCHAR2(30) default null;
    l_menu_id      number;
    l_assignee_id  number;
    l_requestor_id NUMBER;

    l_row_count NUMBER default 0;
   -- bug 13921167 end

    CURSOR c_get_items_org_roles(cp_instance_set_id IN NUMBER) IS
      SELECT 'A' grantee_type,
             'A1' name_link,
             grants.grant_guid grant_guid,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             ltrim(grantee_global.party_name, '* ') party_name,
             NULL company_name,
             -1 company_id,
             grantee_global.party_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             LTRIM(grantee_global.party_name, '* ') as decoded_party_name
        FROM fnd_grants   grants,
             hz_parties   grantee_global,
             fnd_menus    granted_menu,
             fnd_objects  obj,
             fnd_menus_tl menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'GLOBAL'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND menutl.language = USERENV('LANG')
         AND grantee_global.party_id = -1000
         AND grants.instance_type = 'INSTANCE'
         AND grants.instance_pk1_value = '*NULL*'
         AND grants.instance_pk2_value = '*NULL*'
         AND grants.instance_pk3_value = '*NULL*'
         AND grants.instance_pk4_value = '*NULL*'
         AND grants.instance_pk5_value = '*NULL*'
      union all
      SELECT 'A' grantee_type,
             'A1' name_link,
             grants.grant_guid grant_guid,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             ltrim(grantee_global.party_name, '* ') party_name,
             NULL company_name,
             -1 company_id,
             grantee_global.party_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             LTRIM(grantee_global.party_name, '* ') as decoded_party_name
        FROM fnd_grants   grants,
             hz_parties   grantee_global,
             fnd_menus    granted_menu,
             fnd_objects  obj,
             fnd_menus_tl menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'GLOBAL'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND menutl.language = USERENV('LANG')
         AND grantee_global.party_id = -1000
         AND grants.instance_type = 'SET'
         AND grants.instance_set_id = cp_instance_set_id
      union all
      SELECT 'G' grantee_type,
             'G1' name_link,
             grants.grant_guid grant_guid,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             grantee_group.group_name party_name,
             NULL company_name,
             -1 company_id,
             grantee_group.group_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             grantee_group.group_name as decoded_party_name
        FROM fnd_grants   grants,
             ego_groups_v grantee_group,
             fnd_menus    granted_menu,
             fnd_objects  obj,
             fnd_menus_tl menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'GROUP'
         AND TO_NUMBER(REPLACE(grants.grantee_key, 'HZ_GROUP:', '')) =
             grantee_group.group_id
         AND grantee_key like 'HZ_GROUP%'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND menutl.language = USERENV('LANG')
         AND grants.instance_type = 'INSTANCE'
         AND grants.instance_pk1_value = '*NULL*'
         AND grants.instance_pk2_value = '*NULL*'
         AND grants.instance_pk3_value = '*NULL*'
         AND grants.instance_pk4_value = '*NULL*'
         AND grants.instance_pk5_value = '*NULL*'
      union all
      SELECT 'G' grantee_type,
             'G1' name_link,
             grants.grant_guid grant_guid,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             grantee_group.group_name party_name,
             NULL company_name,
             -1 company_id,
             grantee_group.group_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             grantee_group.group_name decoded_party_name
        FROM fnd_grants   grants,
             ego_groups_v grantee_group,
             fnd_menus    granted_menu,
             fnd_objects  obj,
             fnd_menus_tl menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'GROUP'
         AND TO_NUMBER(REPLACE(grants.grantee_key, 'HZ_GROUP:', '')) =
             grantee_group.group_id
         AND grantee_key like 'HZ_GROUP%'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND menutl.language = USERENV('LANG')
         AND grants.instance_type = 'SET'
         AND grants.instance_set_id = cp_instance_set_id
      union all
      SELECT 'P' grantee_type,
             'P1' name_link,
             grants.grant_guid grant_guid,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             ltrim(grantee_person.person_name, '* ') party_name,
             grantee_person.company_name company_name,
             grantee_person.company_id company_id,
             grantee_person.person_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             LTRIM(grantee_person.person_name, '* ') as decoded_party_name
        FROM fnd_grants           grants,
             ego_person_company_v grantee_person,
             fnd_menus            granted_menu,
             fnd_objects          obj,
             fnd_menus_tl         menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'USER'
         AND TO_NUMBER(REPLACE(grants.grantee_key, 'HZ_PARTY:', '')) =
             grantee_person.person_id
         AND grantee_key like 'HZ_PARTY%'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND menutl.language = USERENV('LANG')
         AND grants.instance_type = 'INSTANCE'
         AND grants.instance_pk1_value = '*NULL*'
         AND grants.instance_pk2_value = '*NULL*'
         AND grants.instance_pk3_value = '*NULL*'
         AND grants.instance_pk4_value = '*NULL*'
         AND grants.instance_pk5_value = '*NULL*'
      union all
      SELECT 'P' grantee_type,
             'P1' name_link,
             grants.grant_guid grant_guid,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             ltrim(grantee_person.person_name, '* ') party_name,
             grantee_person.company_name company_name,
             grantee_person.company_id company_id,
             grantee_person.person_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             LTRIM(grantee_person.person_name, '* ') as decoded_party_name
        FROM fnd_grants           grants,
             ego_person_company_v grantee_person,
             fnd_menus            granted_menu,
             fnd_objects          obj,
             fnd_menus_tl         menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'USER'
         AND TO_NUMBER(REPLACE(grants.grantee_key, 'HZ_PARTY:', '')) =
             grantee_person.person_id
         AND grantee_key like 'HZ_PARTY%'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND menutl.language = USERENV('LANG')
         AND grants.instance_type = 'SET'
         AND grants.instance_set_id = cp_instance_set_id
      union all
      SELECT 'C' grantee_type,
             'C1' name_link,
             grants.grant_guid grant_id,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             grantee_company.company_name party_name,
             grantee_company.company_name company_name,
             grantee_company.company_id company_id,
             grantee_company.company_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             grantee_company.company_name decoded_party_name
        FROM fnd_grants      grants,
             ego_companies_v grantee_company,
             fnd_menus       granted_menu,
             fnd_objects     obj,
             fnd_menus_tl    menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'COMPANY'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND TO_NUMBER(REPLACE(grants.grantee_key, 'HZ_COMPANY:', '')) =
             grantee_company.company_id
         AND grantee_key like 'HZ_COMPANY%'
         AND menutl.language = USERENV('LANG')
         AND grants.instance_type = 'INSTANCE'
         AND grants.instance_pk1_value = '*NULL*'
         AND grants.instance_pk2_value = '*NULL*'
         AND grants.instance_pk3_value = '*NULL*'
         AND grants.instance_pk4_value = '*NULL*'
         AND grants.instance_pk5_value = '*NULL*'
      union all
      SELECT 'C' grantee_type,
             'C1' name_link,
             grants.grant_guid grant_id,
             grants.start_date start_date,
             grants.end_date end_date,
             grants.instance_type object_key_type,
             grants.instance_pk1_value object_key,
             grantee_company.company_name party_name,
             grantee_company.company_name company_name,
             grantee_company.company_id company_id,
             grantee_company.company_id party_id,
             granted_menu.menu_name role_name,
             granted_menu.menu_name role_description,
             obj.obj_name object_name,
             granted_menu.menu_id menu_id,
             'egorolegranttableviewrolename' switcherCol,
             menutl.user_menu_name roleNameLink,
             grants.instance_pk1_value pk1_value,
             grants.instance_pk2_value pk2_value,
             grants.instance_pk3_value pk3_value,
             grants.instance_pk4_value pk4_value,
             grants.instance_pk5_value pk5_value,
             grants.instance_set_id instance_set_id,
             grants.ROWID as row_id,
             grantee_company.company_name decoded_party_name
        FROM fnd_grants      grants,
             ego_companies_v grantee_company,
             fnd_menus       granted_menu,
             fnd_objects     obj,
             fnd_menus_tl    menutl
       WHERE obj.obj_name = 'EGO_ITEM'
         AND grants.object_id = obj.object_id
         AND grants.grantee_type = 'COMPANY'
         AND NVL(grants.end_date, SYSDATE + 1) >= TRUNC(SYSDATE)
         AND grants.menu_id = granted_menu.menu_id
         AND grants.menu_id = menutl.menu_id
         AND TO_NUMBER(REPLACE(grants.grantee_key, 'HZ_COMPANY:', '')) =
             grantee_company.company_id
         AND grantee_key like 'HZ_COMPANY%'
         AND menutl.language = USERENV('LANG')
         AND grants.instance_type = 'SET'
         AND grants.instance_set_id = cp_instance_set_id;

    CURSOR C_GET_PARENT_ROLES(cp_role_id IN NUMBER, cp_change_mgmt_type_code IN VARCHAR2) IS
      SELECT DISTINCT map.PARENT_OBJECT_ID,
                      map.PARENT_ROLE_ID,
                      map.CHILD_OBJECT_ID,
                      map.CHILD_OBJECT_TYPE,
                      map.CHILD_ROLE_ID,
                      menus.MENU_NAME CHILD_ROLE,
                      decode(e.created_by,
                             1,
                             menus.description,
                             menus.user_menu_name) CHILD_ROLE_NAME,
                      lookup.change_mgmt_type_code CHANGE_MGMT_TYPE,
                      lookup.name CHANGE_MGMT_TYPE_NAME,
                      'ENG_CHANGE'
        FROM EGO_OBJ_ROLE_MAPPINGS    map,
             fnd_menus_vl             menus,
             eng_change_mgmt_types_vl lookup,
             fnd_menu_entries         e,
             fnd_objects              fo
       WHERE menus.menu_id(+) = map.child_role_id
         AND e.menu_id(+) = menus.menu_id
         AND map.CHILD_OBJECT_TYPE(+) = lookup.change_mgmt_type_code
         AND lookup.disable_flag = 'N'
         AND lookup.base_change_mgmt_type_code <> 'DOM_DOCUMENT_LIFECYCLE'
         AND lookup.change_mgmt_type_code = cp_change_mgmt_type_code
         AND fo.obj_name = 'EGO_ITEM'
         AND map.PARENT_OBJECT_ID = fo.object_id
         AND map.CHILD_ROLE_ID(+) = cp_role_id;

    CURSOR C_CHANGES IS
      SELECT CHANGE_LIFECYCLE_STATUS_ID,
             ENTITY_NAME,
             ENTITY_ID1,
             SEQUENCE_NUMBER,
             STATUS_CODE,
             START_DATE,
             COMPLETION_DATE,
             CHANGE_WF_ROUTE_ID,
             CHANGE_WF_ROUTE_TEMPLATE_ID,
             AUTO_PROMOTE_STATUS,
             WORKFLOW_STATUS,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY
        FROM ENG_LIFECYCLE_STATUSES
       WHERE ENTITY_ID1 IN
             (SELECT CHANGE_ID
                FROM ENG_ENGINEERING_CHANGES
               WHERE CHANGE_NOTICE = p_change_notice
                 AND ORGANIZATION_ID = p_org_id)
         and change_wf_route_id is null
         and change_wf_route_template_id is not null --needed for part with workflow
       ORDER BY ENTITY_ID1, SEQUENCE_NUMBER;

    l_msg_count           number;
    l_msg_data            varchar2(1000);
    l_classification_code VARCHAR2(150);

    -- Get the copied role id or group id of Role/Group type as Route assignee
    -- When Eng_Change_Route_Util.COPY_ROUTE, it only copied role_id or group_id, but not doing the people assginment.
    -- Hence, we need to find out these id to do people assignment
    CURSOR C_GET_ROUTE_STEP_ASSIGNEE(cp_route_id IN NUMBER) IS
      SELECT *
        FROM ENG_CHANGE_ROUTE_PEOPLE
       WHERE STEP_ID IN (SELECT STEP_ID
                           FROM ENG_CHANGE_ROUTE_STEPS
                          WHERE ROUTE_ID IN (cp_route_id))
         AND ORIGINAL_ASSIGNEE_TYPE_CODE IS NULL
         AND ORIGINAL_ASSIGNEE_ID IS NULL
         AND ASSIGNEE_TYPE_CODE <> 'PERSON'
       ORDER BY STEP_ID;

    CURSOR C_GET_GROUP_MEMBER(cp_group_id IN NUMBER) IS
      SELECT MEMBER_PERSON_ID
        FROM ENG_SECURITY_GROUP_MEMBERS_V
       WHERE GROUP_ID = cp_group_id
       ORDER BY MEMBER_PERSON_ID;

    CURSOR c_propagated_change_order(cp_change_notice eng_engineering_changes.change_notice%type, cp_local_organization_id eng_change_obj_relationships.object_to_id3%type)
    IS
      SELECT eec.change_id
      FROM eng_engineering_changes eec ,
        eng_change_obj_relationships ecor
      WHERE eec.change_id         = ecor.object_to_id1
      AND ecor.relationship_code IN ( 'PROPAGATED_TO', 'TRANSFERRED_TO' )
      AND ecor.object_to_name     ='ENG_CHANGE'
      AND ecor.object_to_id3      = cp_local_organization_id
      AND eec.change_notice       = cp_change_notice;
  BEGIN

    SELECT CHANGE_MGMT_TYPE_CODE
      INTO l_change_mgmt_type_code
      FROM ENG_ENGINEERING_CHANGES
     WHERE CHANGE_NOTICE = p_change_notice
       AND ORGANIZATION_ID = p_org_id;

    FOR C_CHANGES_REC IN C_CHANGES LOOP

       -- Get new ROute Id
      SELECT ENG_CHANGE_ROUTES_S.NEXTVAL into l_to_route_id FROM DUAL;

      IF Bom_Globals.Get_Debug = 'Y' THEN
         Error_Handler.Write_Debug('Inside Loop Template_id: ' ||
                   C_CHANGES_REC.CHANGE_WF_ROUTE_TEMPLATE_ID);
      END IF;

      --This is a Oracle API which will copy the Routes needed
      Eng_Change_Route_Util.COPY_ROUTE(X_TO_ROUTE_ID   => l_to_route_id,
                                       P_FROM_ROUTE_ID => C_CHANGES_REC.CHANGE_WF_ROUTE_TEMPLATE_ID,
                                       P_USER_ID       => FND_GLOBAL.USER_ID,
                                       P_API_CALLER    => NULL);

      IF Bom_Globals.Get_Debug = 'Y' THEN
         Error_Handler.Write_Debug('New Route Id Created is ' || l_to_route_id);
      END IF;

      --Will need to update the various related tables  along with the ENG_LIFECYCLE_STATUSES
      UPDATE ENG_LIFECYCLE_STATUSES
         SET CHANGE_WF_ROUTE_ID = l_to_route_id,
             WORKFLOW_STATUS    = 'NOT_STARTED'
       WHERE ENTITY_ID1 = C_CHANGES_REC.ENTITY_ID1
         AND CHANGE_LIFECYCLE_STATUS_ID =
             C_CHANGES_REC.CHANGE_LIFECYCLE_STATUS_ID;

      SELECT to_char(status_code)
        INTO l_classification_code
        FROM eng_lifecycle_statuses
       WHERE change_wf_route_id = l_to_route_id;

      UPDATE ENG_CHANGE_ROUTES
         SET OBJECT_ID1          = C_CHANGES_REC.ENTITY_ID1,
             CLASSIFICATION_CODE = l_classification_code,
             OWNER_ID            = FND_GLOBAL.USER_ID,
             APPLIED_TEMPLATE_ID = C_CHANGES_REC.CHANGE_WF_ROUTE_TEMPLATE_ID
       WHERE ROUTE_ID = l_to_route_id;

      UPDATE ENG_CHANGE_ROUTE_PEOPLE -- bug 13860012
         SET ORIGINAL_ASSIGNEE_TYPE_CODE = 'PERSON'
         WHERE ASSIGNEE_TYPE_CODE = 'PERSON'
         AND STEP_ID IN ( SELECT STEP_ID FROM ENG_CHANGE_ROUTE_STEPS_VL WHERE ROUTE_ID = l_to_route_id );
      /** === Part: Populate Route People  ===  **/

      -- pre-populate the item role in this organization
      l_instance_set_id := EGO_SECURITY_PUB.CREATE_INSTANCE_SET(p_instance_set_name => 'EGO_ORG_ITEM_' ||
                                                                                       p_org_id,
                                                                p_object_name       => 'EGO_ITEM',
                                                                p_predicate         => 'ORGANIZATION_ID = ' ||
                                                                                       p_org_id,
                                                                P_display_name      => 'EGO_ORG_ITEM_' ||
                                                                                       p_org_id,
                                                                p_description       => 'EGO_ORG_ITEM_' ||
                                                                                       p_org_id);

      FOR cr IN c_get_items_org_roles(cp_instance_set_id => l_instance_set_id) LOOP
        l_items_org_role_table(c_index).Grantee_Type := cr.grantee_type;
        l_items_org_role_table(c_index).Role_Id := cr.menu_id;
        l_items_org_role_table(c_index).Party_Id := cr.party_id;

        c_index := c_index + 1;
      END LOOP;

      FOR cr IN C_GET_ROUTE_STEP_ASSIGNEE(cp_route_id => l_to_route_id) LOOP
    ---bug 13921167 start
        l_menu_id := cr.assignee_id;
        select count(1)
          into l_row_count
          from fnd_menus
         where menu_id = l_menu_id;

        if (l_row_count > 0) then
          select menu_name
            into l_menu_name
            from fnd_menus
           where menu_id = l_menu_id;
        else
          l_menu_name := null;
        end if;

        --When workflow is assigned to change role 'Assignee'
        IF (l_menu_name is not null and 'ENG_CHANGE_ASSIGNEE' = l_menu_name) THEN

          SELECT ASSIGNEE_ID
            into l_assignee_id
            FROM ENG_ENGINEERING_CHANGES
           WHERE CHANGE_NOTICE = p_change_notice
             AND ORGANIZATION_ID = p_org_id;
          IF (l_assignee_id is not null) THEN
            -- check if the person is created in current step, if l_people_existed_flag = 0, then create
            SELECT COUNT(1)
              INTO l_people_existed_flag
              FROM ENG_CHANGE_ROUTE_PEOPLE
             WHERE step_id = cr.step_id
               AND assignee_id = l_assignee_id;

            IF (l_people_existed_flag = 0) THEN
              -- generate new people id
              SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
                into l_people_id
                FROM DUAL;

              INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                (route_people_id,
                 step_id,
                 assignee_id,
                 assignee_type_code,
                 adhoc_people_flag,
                 wf_notification_id,
                 response_code,
                 response_date,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 request_id,
                 program_id,
                 program_application_id,
                 program_update_date,
                 original_system_reference,
                 original_assignee_id,
                 original_assignee_type_code,
                 response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                 parent_route_people_id)
              VALUES
                (l_people_id,
                 cr.step_id,
                 l_assignee_id,
                 'PERSON',
                 cr.adhoc_people_flag,
                 cr.wf_notification_id,
                 cr.response_code,
                 cr.response_date,
                 cr.creation_date,
                 cr.created_by,
                 cr.last_update_date,
                 cr.last_updated_by,
                 cr.last_update_login,
                 cr.request_id,
                 cr.program_id,
                 cr.program_application_id,
                 cr.program_update_date,
                 cr.original_system_reference,
                 cr.assignee_id,
                 cr.assignee_type_code,
                 cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                 cr.route_people_id);

              insert into ENG_CHANGE_ROUTE_PEOPLE_TL
                (ROUTE_PEOPLE_ID,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 RESPONSE_DESCRIPTION,
                 LANGUAGE,
                 SOURCE_LANG)
                select l_people_id,
                       cr.creation_date,
                       cr.created_by,
                       cr.last_update_date,
                       cr.last_updated_by,
                       cr.last_update_login,
                       NULL,
                       L.LANGUAGE_CODE,
                       userenv('LANG')
                  from FND_LANGUAGES L
                 where L.INSTALLED_FLAG in ('I', 'B')
                   and not exists
                 (select NULL
                          from ENG_CHANGE_ROUTE_PEOPLE_TL T
                         where T.ROUTE_PEOPLE_ID = l_people_id
                           and T.LANGUAGE = L.LANGUAGE_CODE);

            END IF;

          ELSE
            -- generate new people id
            SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
              into l_people_id
              FROM DUAL;

            --insert an 'Unassigned' assignee record
            INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
              (route_people_id,
               step_id,
               assignee_id,
               assignee_type_code,
               adhoc_people_flag,
               wf_notification_id,
               response_code,
               response_date,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               request_id,
               program_id,
               program_application_id,
               program_update_date,
               original_system_reference,
               original_assignee_id,
               original_assignee_type_code,
               response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--               parent_route_people_id)
            VALUES
              (l_people_id,
               cr.step_id,
               -1,
               'PERSON',
               cr.adhoc_people_flag,
               cr.wf_notification_id,
               cr.response_code,
               cr.response_date,
               cr.creation_date,
               cr.created_by,
               cr.last_update_date,
               cr.last_updated_by,
               cr.last_update_login,
               cr.request_id,
               cr.program_id,
               cr.program_application_id,
               cr.program_update_date,
               cr.original_system_reference,
               cr.assignee_id,
               cr.assignee_type_code,
               cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--               cr.route_people_id);

            insert into ENG_CHANGE_ROUTE_PEOPLE_TL
              (ROUTE_PEOPLE_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               RESPONSE_DESCRIPTION,
               LANGUAGE,
               SOURCE_LANG)
              select l_people_id,
                     cr.creation_date,
                     cr.created_by,
                     cr.last_update_date,
                     cr.last_updated_by,
                     cr.last_update_login,
                     NULL,
                     L.LANGUAGE_CODE,
                     userenv('LANG')
                from FND_LANGUAGES L
               where L.INSTALLED_FLAG in ('I', 'B')
                 and not exists
               (select NULL
                        from ENG_CHANGE_ROUTE_PEOPLE_TL T
                       where T.ROUTE_PEOPLE_ID = l_people_id
                         and T.LANGUAGE = L.LANGUAGE_CODE);

          END IF;

          --when workflow is assigned to change role 'Requestor'
        ELSIF (l_menu_name is not null and
              'ENG_CHANGE_REQUESTOR' = l_menu_name) THEN

          SELECT REQUESTOR_ID
            into l_requestor_id
            FROM ENG_ENGINEERING_CHANGES
           WHERE CHANGE_NOTICE = p_change_notice
             AND ORGANIZATION_ID = p_org_id;
          IF (l_requestor_id is not null) THEN
            -- check if the person is created in current step, if l_people_existed_flag = 0, then create
            SELECT COUNT(1)
              INTO l_people_existed_flag
              FROM ENG_CHANGE_ROUTE_PEOPLE
             WHERE step_id = cr.step_id
               AND assignee_id = l_requestor_id;

            IF (l_people_existed_flag = 0) THEN
              -- generate new people id
              SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
                into l_people_id
                FROM DUAL;

              INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                (route_people_id,
                 step_id,
                 assignee_id,
                 assignee_type_code,
                 adhoc_people_flag,
                 wf_notification_id,
                 response_code,
                 response_date,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 request_id,
                 program_id,
                 program_application_id,
                 program_update_date,
                 original_system_reference,
                 original_assignee_id,
                 original_assignee_type_code,
                 response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                 parent_route_people_id)
              VALUES
                (l_people_id,
                 cr.step_id,
                 l_requestor_id,
                 'PERSON',
                 cr.adhoc_people_flag,
                 cr.wf_notification_id,
                 cr.response_code,
                 cr.response_date,
                 cr.creation_date,
                 cr.created_by,
                 cr.last_update_date,
                 cr.last_updated_by,
                 cr.last_update_login,
                 cr.request_id,
                 cr.program_id,
                 cr.program_application_id,
                 cr.program_update_date,
                 cr.original_system_reference,
                 cr.assignee_id,
                 cr.assignee_type_code,
                 cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                 cr.route_people_id);

              insert into ENG_CHANGE_ROUTE_PEOPLE_TL
                (ROUTE_PEOPLE_ID,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 RESPONSE_DESCRIPTION,
                 LANGUAGE,
                 SOURCE_LANG)
                select l_people_id,
                       cr.creation_date,
                       cr.created_by,
                       cr.last_update_date,
                       cr.last_updated_by,
                       cr.last_update_login,
                       NULL,
                       L.LANGUAGE_CODE,
                       userenv('LANG')
                  from FND_LANGUAGES L
                 where L.INSTALLED_FLAG in ('I', 'B')
                   and not exists
                 (select NULL
                          from ENG_CHANGE_ROUTE_PEOPLE_TL T
                         where T.ROUTE_PEOPLE_ID = l_people_id
                           and T.LANGUAGE = L.LANGUAGE_CODE);

            END IF;

          ELSE
            -- generate new people id
            SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
              into l_people_id
              FROM DUAL;

            --insert an 'Unassigned' assignee record
            INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
              (route_people_id,
               step_id,
               assignee_id,
               assignee_type_code,
               adhoc_people_flag,
               wf_notification_id,
               response_code,
               response_date,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               request_id,
               program_id,
               program_application_id,
               program_update_date,
               original_system_reference,
               original_assignee_id,
               original_assignee_type_code,
               response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--               parent_route_people_id)
            VALUES
              (l_people_id,
               cr.step_id,
               -1,
               'PERSON',
               cr.adhoc_people_flag,
               cr.wf_notification_id,
               cr.response_code,
               cr.response_date,
               cr.creation_date,
               cr.created_by,
               cr.last_update_date,
               cr.last_updated_by,
               cr.last_update_login,
               cr.request_id,
               cr.program_id,
               cr.program_application_id,
               cr.program_update_date,
               cr.original_system_reference,
               cr.assignee_id,
               cr.assignee_type_code,
               cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--               cr.route_people_id);

            insert into ENG_CHANGE_ROUTE_PEOPLE_TL
              (ROUTE_PEOPLE_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               RESPONSE_DESCRIPTION,
               LANGUAGE,
               SOURCE_LANG)
              select l_people_id,
                     cr.creation_date,
                     cr.created_by,
                     cr.last_update_date,
                     cr.last_updated_by,
                     cr.last_update_login,
                     NULL,
                     L.LANGUAGE_CODE,
                     userenv('LANG')
                from FND_LANGUAGES L
               where L.INSTALLED_FLAG in ('I', 'B')
                 and not exists
               (select NULL
                        from ENG_CHANGE_ROUTE_PEOPLE_TL T
                       where T.ROUTE_PEOPLE_ID = l_people_id
                         and T.LANGUAGE = L.LANGUAGE_CODE);

          END IF;
        ELSE

          ---bug 13921167 end


        IF (cr.ASSIGNEE_TYPE_CODE = 'GROUP') THEN
          FOR cr2 IN C_GET_GROUP_MEMBER(cp_group_id => cr.assignee_id) LOOP

            -- check if the person is created in current step, if l_people_existed_flag = 0, then create
            SELECT COUNT(1)
              INTO l_people_existed_flag
              FROM ENG_CHANGE_ROUTE_PEOPLE
             WHERE step_id = cr.step_id
            AND assignee_id = cr2.member_person_id;

            IF (l_people_existed_flag = 0) THEN
              -- generate new people id
              SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
                into l_people_id
                FROM DUAL;

              INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                (route_people_id,
                 step_id,
                 assignee_id,
                 assignee_type_code,
                 adhoc_people_flag,
                 wf_notification_id,
                 response_code,
                 response_date,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 request_id,
                 program_id,
                 program_application_id,
                 program_update_date,
                 original_system_reference,
                 original_assignee_id,
                 original_assignee_type_code,
                 response_condition_code,
                 parent_route_people_id)
              VALUES
                (l_people_id,
                 cr.step_id,
                 cr2.member_person_id,
                 'PERSON',
                 cr.adhoc_people_flag,
                 cr.wf_notification_id,
                 cr.response_code,
                 cr.response_date,
                 cr.creation_date,
                 cr.created_by,
                 cr.last_update_date,
                 cr.last_updated_by,
                 cr.last_update_login,
                 cr.request_id,
                 cr.program_id,
                 cr.program_application_id,
                 cr.program_update_date,
                 cr.original_system_reference,
                 cr.assignee_id,
                 cr.assignee_type_code,
                 cr.response_condition_code,
                 --cr.route_people_id
                null );

              insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
                ROUTE_PEOPLE_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                RESPONSE_DESCRIPTION,
                LANGUAGE,
                SOURCE_LANG
              ) select
                l_people_id,
                cr.creation_date,
                cr.created_by,
                cr.last_update_date,
                cr.last_updated_by,
                cr.last_update_login,
                NULL,
                L.LANGUAGE_CODE,
                userenv('LANG')
              from FND_LANGUAGES L
              where L.INSTALLED_FLAG in ('I', 'B')
              and not exists
                (select NULL
                from ENG_CHANGE_ROUTE_PEOPLE_TL T
                where T.ROUTE_PEOPLE_ID = l_people_id
                and T.LANGUAGE = L.LANGUAGE_CODE);

            END IF;
          END LOOP; -- end cr2 in cursor C_GET_GROUP_MEMBER
        ELSIF (cr.ASSIGNEE_TYPE_CODE = 'ROLE') THEN

          l_row_inserted_flag := 0;  -- bug 13860012
          FOR t_index in 1 .. l_items_org_role_table.last LOOP
            IF (l_items_org_role_table(t_index).role_id = cr.assignee_id) THEN

              -- if the role_id is in organization role ,
              IF (l_items_org_role_table(t_index).Grantee_Type = 'P') THEN

                -- if the role's type = 'PERSON', then start to create the people

                -- check if the person is created in current step, if l_people_existed_flag = 0, then create
                SELECT COUNT(1)
                  INTO l_people_existed_flag
                  FROM ENG_CHANGE_ROUTE_PEOPLE
                 WHERE step_id = cr.step_id
                AND assignee_id = l_items_org_role_table(t_index).party_id;

                IF (l_people_existed_flag = 0) THEN
                  -- generate new people id
                  SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
                    into l_people_id
                    FROM DUAL;

                  INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                    (route_people_id,
                     step_id,
                     assignee_id,
                     assignee_type_code,
                     adhoc_people_flag,
                     wf_notification_id,
                     response_code,
                     response_date,
                     creation_date,
                     created_by,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     request_id,
                     program_id,
                     program_application_id,
                     program_update_date,
                     original_system_reference,
                     original_assignee_id,
                     original_assignee_type_code,
                     response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                     parent_route_people_id)
                  VALUES
                    (l_people_id,
                     cr.step_id,
                     l_items_org_role_table(t_index).party_id,
                     'PERSON',
                     cr.adhoc_people_flag,
                     cr.wf_notification_id,
                     cr.response_code,
                     cr.response_date,
                     cr.creation_date,
                     cr.created_by,
                     cr.last_update_date,
                     cr.last_updated_by,
                     cr.last_update_login,
                     cr.request_id,
                     cr.program_id,
                     cr.program_application_id,
                     cr.program_update_date,
                     cr.original_system_reference,
                     cr.assignee_id,
                     cr.assignee_type_code,
                     cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                     cr.route_people_id);

                  insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
                    ROUTE_PEOPLE_ID,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    RESPONSE_DESCRIPTION,
                    LANGUAGE,
                    SOURCE_LANG
                  ) select
                    l_people_id,
                    cr.creation_date,
                    cr.created_by,
                    cr.last_update_date,
                    cr.last_updated_by,
                    cr.last_update_login,
                    NULL,
                    L.LANGUAGE_CODE,
                    userenv('LANG')
                  from FND_LANGUAGES L
                  where L.INSTALLED_FLAG in ('I', 'B')
                  and not exists
                    (select NULL
                    from ENG_CHANGE_ROUTE_PEOPLE_TL T
                    where T.ROUTE_PEOPLE_ID = l_people_id
                    and T.LANGUAGE = L.LANGUAGE_CODE);

                l_row_inserted_flag := 1;  -- bug 13860012
                END IF; -- End if l_people_existed_flag = 0
              ELSIF (l_items_org_role_table(t_index).Grantee_Type = 'G') THEN
                -- when role_type = 'GROUP'
                FOR cr2 IN C_GET_GROUP_MEMBER(cp_group_id => l_items_org_role_table(t_index).party_id) LOOP
                  -- check if the person is created in current step, if l_people_existed_flag = 0, then create
                  SELECT COUNT(1)
                    INTO l_people_existed_flag
                    FROM ENG_CHANGE_ROUTE_PEOPLE
                   WHERE step_id = cr.step_id
                  AND assignee_id = cr2.member_person_id;

                  IF (l_people_existed_flag = 0) THEN
                    -- generate new people id
                    SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
                      into l_people_id
                      FROM DUAL;

                    INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                      (route_people_id,
                       step_id,
                       assignee_id,
                       assignee_type_code,
                       adhoc_people_flag,
                       wf_notification_id,
                       response_code,
                       response_date,
                       creation_date,
                       created_by,
                       last_update_date,
                       last_updated_by,
                       last_update_login,
                       request_id,
                       program_id,
                       program_application_id,
                       program_update_date,
                       original_system_reference,
                       original_assignee_id,
                       original_assignee_type_code,
                       response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                       parent_route_people_id)
                    VALUES
                      (l_people_id,
                       cr.step_id,
                       cr2.member_person_id,
                       'PERSON',
                       cr.adhoc_people_flag,
                       cr.wf_notification_id,
                       cr.response_code,
                       cr.response_date,
                       cr.creation_date,
                       cr.created_by,
                       cr.last_update_date,
                       cr.last_updated_by,
                       cr.last_update_login,
                       cr.request_id,
                       cr.program_id,
                       cr.program_application_id,
                       cr.program_update_date,
                       cr.original_system_reference,
                       cr.assignee_id,
                       cr.assignee_type_code,
                       cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                       cr.route_people_id);

                    insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
                      ROUTE_PEOPLE_ID,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      RESPONSE_DESCRIPTION,
                      LANGUAGE,
                      SOURCE_LANG
                    ) select
                      l_people_id,
                      cr.creation_date,
                      cr.created_by,
                      cr.last_update_date,
                      cr.last_updated_by,
                      cr.last_update_login,
                      NULL,
                      L.LANGUAGE_CODE,
                      userenv('LANG')
                    from FND_LANGUAGES L
                    where L.INSTALLED_FLAG in ('I', 'B')
                    and not exists
                      (select NULL
                      from ENG_CHANGE_ROUTE_PEOPLE_TL T
                      where T.ROUTE_PEOPLE_ID = l_people_id
                      and T.LANGUAGE = L.LANGUAGE_CODE);

                  l_row_inserted_flag := 1;  -- bug 13860012
                  END IF;
                END LOOP; -- end loop for cr2

              END IF; -- end IF l_items_org_role_table(t_index).Grantee_Type

            ELSE
              -- if the role id is as child role object of organization role, such as Change/Document object
              FOR cr2 IN C_GET_PARENT_ROLES(cp_role_id              => cr.assignee_id,
                                            cp_change_mgmt_type_code => l_change_mgmt_type_code) LOOP
                FOR t_index in 1 .. l_items_org_role_table.last LOOP
                  IF (l_items_org_role_table(t_index).role_id = cr2.parent_role_id) THEN
                    -- if the parent_role_id is in organization role ,
                    IF (l_items_org_role_table(t_index).Grantee_Type = 'P') THEN
                      -- if the role's type = 'PERSON', then start to create the people
                      -- check if the person is created in current step, if l_people_existed_flag = 0, then create
                      SELECT COUNT(1)
                        INTO l_people_existed_flag
                        FROM ENG_CHANGE_ROUTE_PEOPLE
                       WHERE step_id = cr.step_id
                      AND assignee_id = l_items_org_role_table(t_index).party_id;

                      IF (l_people_existed_flag = 0) THEN
                        -- generate new people id
                        SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
                          into l_people_id
                          FROM DUAL;

                        INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                          (route_people_id,
                           step_id,
                           assignee_id,
                           assignee_type_code,
                           adhoc_people_flag,
                           wf_notification_id,
                           response_code,
                           response_date,
                           creation_date,
                           created_by,
                           last_update_date,
                           last_updated_by,
                           last_update_login,
                           request_id,
                           program_id,
                           program_application_id,
                           program_update_date,
                           original_system_reference,
                           original_assignee_id,
                           original_assignee_type_code,
                           response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                           parent_route_people_id)
                        VALUES
                          (l_people_id,
                           cr.step_id,
                           l_items_org_role_table(t_index).party_id,
                           'PERSON',
                           cr.adhoc_people_flag,
                           cr.wf_notification_id,
                           cr.response_code,
                           cr.response_date,
                           cr.creation_date,
                           cr.created_by,
                           cr.last_update_date,
                           cr.last_updated_by,
                           cr.last_update_login,
                           cr.request_id,
                           cr.program_id,
                           cr.program_application_id,
                           cr.program_update_date,
                           cr.original_system_reference,
                           cr.assignee_id,
                           cr.assignee_type_code,
                           cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                           cr.route_people_id);

                        insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
                          ROUTE_PEOPLE_ID,
                          CREATION_DATE,
                          CREATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          LAST_UPDATE_LOGIN,
                          RESPONSE_DESCRIPTION,
                          LANGUAGE,
                          SOURCE_LANG
                        ) select
                          l_people_id,
                          cr.creation_date,
                          cr.created_by,
                          cr.last_update_date,
                          cr.last_updated_by,
                          cr.last_update_login,
                          NULL,
                          L.LANGUAGE_CODE,
                          userenv('LANG')
                        from FND_LANGUAGES L
                        where L.INSTALLED_FLAG in ('I', 'B')
                        and not exists
                          (select NULL
                          from ENG_CHANGE_ROUTE_PEOPLE_TL T
                          where T.ROUTE_PEOPLE_ID = l_people_id
                          and T.LANGUAGE = L.LANGUAGE_CODE);

                      l_row_inserted_flag := 1;  -- bug 13860012
                      END IF; -- End IF l_people_existed_flag = 0
                    ELSIF (l_items_org_role_table(t_index).Grantee_Type = 'G') THEN
                      -- when role_type = 'GROUP'
                      FOR cr2 IN C_GET_GROUP_MEMBER(cp_group_id => l_items_org_role_table(t_index).party_id) LOOP
                        -- check if the person is created in current step, if l_people_existed_flag = 0, then create
                        SELECT COUNT(1)
                          INTO l_people_existed_flag
                          FROM ENG_CHANGE_ROUTE_PEOPLE
                         WHERE step_id = cr.step_id
                        AND assignee_id = cr2.member_person_id;

                        IF (l_people_existed_flag = 0) THEN
                          -- generate new people id
                          SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
                            into l_people_id
                            FROM DUAL;

                          INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                            (route_people_id,
                             step_id,
                             assignee_id,
                             assignee_type_code,
                             adhoc_people_flag,
                             wf_notification_id,
                             response_code,
                             response_date,
                             creation_date,
                             created_by,
                             last_update_date,
                             last_updated_by,
                             last_update_login,
                             request_id,
                             program_id,
                             program_application_id,
                             program_update_date,
                             original_system_reference,
                             original_assignee_id,
                             original_assignee_type_code,
                             response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                             parent_route_people_id)
                          VALUES
                            (l_people_id,
                             cr.step_id,
                             cr2.member_person_id,
                             'PERSON',
                             cr.adhoc_people_flag,
                             cr.wf_notification_id,
                             cr.response_code,
                             cr.response_date,
                             cr.creation_date,
                             cr.created_by,
                             cr.last_update_date,
                             cr.last_updated_by,
                             cr.last_update_login,
                             cr.request_id,
                             cr.program_id,
                             cr.program_application_id,
                             cr.program_update_date,
                             cr.original_system_reference,
                             cr.assignee_id,
                             cr.assignee_type_code,
                             cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                             cr.route_people_id);

                          insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
                            ROUTE_PEOPLE_ID,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN,
                            RESPONSE_DESCRIPTION,
                            LANGUAGE,
                            SOURCE_LANG
                          ) select
                            l_people_id,
                            cr.creation_date,
                            cr.created_by,
                            cr.last_update_date,
                            cr.last_updated_by,
                            cr.last_update_login,
                            NULL,
                            L.LANGUAGE_CODE,
                            userenv('LANG')
                          from FND_LANGUAGES L
                          where L.INSTALLED_FLAG in ('I', 'B')
                          and not exists
                            (select NULL
                            from ENG_CHANGE_ROUTE_PEOPLE_TL T
                            where T.ROUTE_PEOPLE_ID = l_people_id
                            and T.LANGUAGE = L.LANGUAGE_CODE);

                        l_row_inserted_flag := 1;  -- bug 13860012
                        END IF;
                      END LOOP; -- end loop for cr2
                    END IF; -- End IF (l_items_org_role_table(t_index).Grantee_Type = 'P')
                  END IF; -- End IF l_items_org_role_table(t_index).role_id = cr2.parent_role_id

                END LOOP; -- FOR t_index in 1..l_items_org_role_table.last
              END LOOP; -- FOR cr2 IN C_GET_PARENT_ROLES

            END IF;
          END LOOP; -- FOR t_index in 1..l_items_org_role_table.last

          IF(l_row_inserted_flag = 0) THEN -- bug 13860012
            -- generate new people id
            SELECT ENG_CHANGE_ROUTE_PEOPLE_S.NEXTVAL
              into l_people_id
              FROM DUAL;

            --insert an 'Unassigned' assignee record
            INSERT INTO ENG_CHANGE_ROUTE_PEOPLE
                            (route_people_id,
                             step_id,
                             assignee_id,
                             assignee_type_code,
                             adhoc_people_flag,
                             wf_notification_id,
                             response_code,
                             response_date,
                             creation_date,
                             created_by,
                             last_update_date,
                             last_updated_by,
                             last_update_login,
                             request_id,
                             program_id,
                             program_application_id,
                             program_update_date,
                             original_system_reference,
                             original_assignee_id,
                             original_assignee_type_code,
                             response_condition_code)
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                             parent_route_people_id)
                          VALUES
                            (l_people_id,
                             cr.step_id,
                             -1,
                             'PERSON',
                             cr.adhoc_people_flag,
                             cr.wf_notification_id,
                             cr.response_code,
                             cr.response_date,
                             cr.creation_date,
                             cr.created_by,
                             cr.last_update_date,
                             cr.last_updated_by,
                             cr.last_update_login,
                             cr.request_id,
                             cr.program_id,
                             cr.program_application_id,
                             cr.program_update_date,
                             cr.original_system_reference,
                             cr.assignee_id,
                             cr.assignee_type_code,
                             cr.response_condition_code);
-- bug fix bug 16594678. parent_route_people_id is using for transferred assignee by ntf reassignment
--                             cr.route_people_id);

                          insert into ENG_CHANGE_ROUTE_PEOPLE_TL (
                            ROUTE_PEOPLE_ID,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN,
                            RESPONSE_DESCRIPTION,
                            LANGUAGE,
                            SOURCE_LANG
                          ) select
                            l_people_id,
                            cr.creation_date,
                            cr.created_by,
                            cr.last_update_date,
                            cr.last_updated_by,
                            cr.last_update_login,
                            NULL,
                            L.LANGUAGE_CODE,
                            userenv('LANG')
                          from FND_LANGUAGES L
                          where L.INSTALLED_FLAG in ('I', 'B')
                          and not exists
                            (select NULL
                            from ENG_CHANGE_ROUTE_PEOPLE_TL T
                            where T.ROUTE_PEOPLE_ID = l_people_id
                            and T.LANGUAGE = L.LANGUAGE_CODE);
          END IF;
        END IF; -- IF GROUP/ROLE
      END IF; --IF Assignee:  bug 13921167


        -- Remove the original copied assignee object (Group/Role)
        DELETE FROM ENG_CHANGE_ROUTE_PEOPLE
        WHERE route_people_id = cr.route_people_id;

        DELETE FROM ENG_CHANGE_ROUTE_PEOPLE_TL
        WHERE route_people_id = cr.route_people_id;

      END LOOP; -- end cursor C_GET_ROUTE_STEP_ASSIGNEE

    END LOOP;

    IF Bom_Globals.Get_Debug = 'Y' THEN
       Error_Handler.Write_Debug('ENG_ECO_PVT API: Calling ENG_CHANGE_LIFECYCLE_UTIL.Init_Lifecycle');
    END IF;

    -- Get the profile: ENG: Allow Auto-Submit Workflow, 1: Yes; 2: No

    FND_PROFILE.Get('ENG_AUTO_SUBMIT_WF', l_submit_flag);

    -- fix bug 13956277, if the ECO is propagate ECO, skip auto submission as propagate ECO will submit accordingly
    OPEN c_propagated_change_order (cp_change_notice => p_change_notice, cp_local_organization_id => p_org_id);
    FETCH c_propagated_change_order INTO l_change_id;
    CLOSE c_propagated_change_order;
    IF (l_submit_flag = 1 AND l_change_id is null) THEN
    --After the explosion is done then the workflow needs to be started
        SELECT change_id
         INTO l_change_id
        FROM eng_engineering_changes WHERE change_notice = p_change_notice
         AND organization_id = p_org_id;

        ENG_CHANGE_LIFECYCLE_UTIL.Init_Lifecycle(
            p_api_version          =>    1.0,
            p_init_msg_list        =>    FND_API.G_TRUE,
            p_commit               =>    FND_API.G_FALSE,
            p_validation_level     =>    FND_API.G_VALID_LEVEL_FULL,
            p_debug                =>    FND_API.G_FALSE,
            p_output_dir           =>    null,
            p_debug_filename       =>    null,
            x_return_status        =>    l_return_status,
            x_msg_count            =>    l_msg_count,
            x_msg_data             =>    l_msg_data,
            p_change_id            =>    l_change_id,
            p_api_caller           =>    'UI'
          );

        IF Bom_Globals.Get_Debug = 'Y' THEN
           Error_Handler.Write_Debug('ENG_CHANGE_LIFECYCLE_UTIL.Init_Lifecycle: Return Status: ' || l_return_status ||
                                      '; Message data: ' || l_msg_data);
        END IF;
     END IF; -- IF (l_submit_flag = 1)
  EXCEPTION
    WHEN OTHERS THEN
        Error_Handler.Add_Error_Token
          (  p_Message_Name  => NULL
            ,p_Message_Text  => 'Error in ENG_ECO_PVT.Explode_WF_Routing: '|| SUBSTR(SQLERRM, 1, 30) || ' ' ||to_char(SQLCODE)
            ,x_Mesg_Token_Tbl  => x_Mesg_Token_Tbl
           , p_Mesg_Token_Tbl  => x_Mesg_Token_Tbl
           );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Explode_WF_Routing;


END ENG_Eco_PVT;

/
