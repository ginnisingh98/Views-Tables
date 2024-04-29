--------------------------------------------------------
--  DDL for Package Body BOM_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BO_PVT" AS
/* $Header: BOMVBOMB.pls 120.9.12010000.3 2010/02/13 03:09:21 vbrobbey ship $ */
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMVBOMB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Bo_Pvt
--
--  NOTES
--
--  HISTORY
--
--  02-AUG-1999 Rahul Chitko  Initial Creation
--
--  08-MAY-2001 Refai Farook  EAM related changes
--
--  28-AUG-01   Refai Farook    One To Many support changes
--
--  05-May-05   Abhishek Rudresh       Common BOM attr updates
--
--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'Bom_Bo_PVT';
G_EXC_QUIT_IMPORT       EXCEPTION;

/* --4306013  */
G_SUB_COMP_FLAG   NUMBER :=0;         --4306013
G_Comp_Op_Flag    NUMBER :=0;         --4306013
G_Ref_Desig_Flag  NUMBER :=0;         --4306013
G_Comp_Flag   NUMBER :=0;         --4306013
Entity_Name   VARCHAR2(100) := '';      --4306013

G_Bill_Seq_Id NUMBER := 0;
--Global constant holding the bill_seq_id value for the entity

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_SEV_QUIT_OBJECT EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;

PROCEDURE Component_Operations
(   p_validation_level              IN  NUMBER
,   p_organization_id       IN  NUMBER := NULL
,   p_assembly_item_name      IN  VARCHAR2 := NULL
,   p_alternate_bom_code      IN  VARCHAR2 := NULL
,   p_effectivity_date            IN  DATE := NULL
,   p_component_item_name     IN  VARCHAR2 := NULL
,   p_operation_seq_num       IN  NUMBER := NULL
,   p_bom_comp_ops_tbl              IN  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
,   x_bom_comp_ops_tbl              IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
,   x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status       IN OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid     BOOLEAN := TRUE;
l_item_parent_exists  BOOLEAN := FALSE;
l_comp_parent_exists  BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);

l_bom_header_rec      Bom_Bo_Pub.Bom_Head_Rec_Type;
l_bom_revision_tbl      Bom_Bo_Pub.Bom_Revision_Tbl_Type;
l_bom_component_tbl         Bom_Bo_Pub.Bom_Comps_Tbl_Type;
l_bom_ref_designator_tbl    Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
l_bom_sub_component_tbl     Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
l_bom_comp_ops_tbl          Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type :=
          p_bom_comp_ops_tbl;
l_bom_comp_ops_rec          Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;
l_bom_comp_ops_unexp_rec    Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type;

l_old_bom_comp_ops_rec       Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;
l_old_bom_comp_ops_unexp_rec Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type;

l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_comp_ops_processed    BOOLEAN := FALSE;
BEGIN

    --  Init local table variables.

    l_return_status := 'S';
    l_bo_return_status := 'S';

    l_bom_comp_ops_tbl           := p_bom_comp_ops_tbl;

    l_bom_comp_ops_unexp_rec.organization_id := Bom_Globals.Get_org_id;


    FOR I IN 1..l_bom_comp_ops_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_bom_comp_ops_rec := l_bom_comp_ops_tbl(I);

        l_bom_comp_ops_rec.transaction_type :=
          UPPER(l_bom_comp_ops_rec.transaction_type);

        IF p_component_item_name IS NOT NULL AND
           p_operation_seq_num IS NOT NULL AND
           p_assembly_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
          -- Inventory Component parent exists

          l_comp_parent_exists := TRUE;

        ELSIF p_assembly_item_name IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
          -- Assembly item parent exists

          l_item_parent_exists := TRUE;
        END IF;

      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF (l_bom_comp_ops_rec.return_status IS NULL OR
          l_bom_comp_ops_rec.return_status = FND_API.G_MISS_CHAR)
         AND

         -- Did Revised_Components call this procedure, that is,
         -- if revised comp exists, then is this record a child ?

     ((l_comp_parent_exists AND
         (l_bom_comp_ops_rec.assembly_item_name =
          p_assembly_item_name AND
          l_bom_comp_ops_unexp_rec.organization_id = p_organization_id
    AND
          l_bom_comp_ops_rec.component_item_name =
    p_component_item_name AND
          l_bom_comp_ops_rec.operation_sequence_number =
    p_operation_seq_num
         )
       )
           OR
           -- Did Bom_Header call this procedure, that is,
           -- if revised item exists, then is this record a child ?

       (l_item_parent_exists AND
         (l_bom_comp_ops_rec.assembly_item_name =
      p_assembly_item_name AND
          l_bom_comp_ops_unexp_rec.organization_id =
      p_organization_id AND
    l_bom_comp_ops_rec.alternate_bom_code =
      p_alternate_bom_code
    )
        )
       OR
           (NOT l_item_parent_exists AND
        NOT l_comp_parent_exists))
      THEN
         l_comp_ops_processed := TRUE;
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_bom_comp_ops_rec.return_status := FND_API.G_RET_STS_SUCCESS;

     --
     -- Check if transaction_type is valid
     --

     Bom_Globals.Transaction_Type_Validity
     (   p_transaction_type => l_bom_comp_ops_rec.transaction_type
     ,   p_entity   => 'Bom_Comp_Ops'
     ,   p_entity_id  => l_bom_comp_ops_rec.assembly_item_name
     ,   x_valid    => l_valid
     ,   x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     );

     IF NOT l_valid
     THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
        RAISE EXC_SEV_QUIT_RECORD;
     END IF;

     --
     -- Process Flow step 4(a): Convert user unique index to unique
     -- index I
     --
     Bom_Val_To_Id.Bom_Comp_Operation_UUI_To_UI
    ( p_bom_comp_ops_rec => l_bom_comp_ops_rec
    , p_bom_comp_ops_unexp_rec => l_bom_comp_ops_unexp_rec
    , x_bom_comp_ops_unexp_rec => l_bom_comp_ops_unexp_rec
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_Return_Status      => l_return_status
    );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_COPS_UUI_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_comp_ops_rec.component_item_name;
    l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
    l_other_token_tbl(2).token_value :=
      l_bom_comp_ops_rec.operation_sequence_number;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
     -- Process Flow step 4(b): Convert user unique index to unique
     -- index II
     --

     Bom_Val_To_Id.Bom_Comp_Operation_UUI_To_UI2
    ( p_bom_comp_ops_rec => l_bom_comp_ops_rec
    , p_bom_comp_ops_unexp_rec => l_bom_comp_ops_unexp_rec
    , x_bom_comp_ops_unexp_rec => l_bom_comp_ops_unexp_rec
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_other_message      => l_other_message
                , x_other_token_tbl    => l_other_token_tbl
    , x_Return_Status      => l_return_status
    );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_SIBLINGS;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_COPS_UUI_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_comp_ops_rec.component_item_name;
    l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
    l_other_token_tbl(2).token_value :=
      l_bom_comp_ops_rec.operation_sequence_number;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
     -- Process Flow step 5: Verify Component Operation's existence
     --

     Bom_Validate_Comp_Operation.Check_Existence
      (  p_bom_comp_ops_rec   => l_bom_comp_ops_rec
      ,  p_bom_comp_ops_unexp_rec   => l_bom_comp_ops_unexp_rec
    ,  x_old_bom_comp_ops_rec => l_old_bom_comp_ops_rec
                ,  x_old_bom_comp_ops_unexp_rec => l_old_bom_comp_ops_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_COPS_EXS_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_comp_ops_rec.component_item_name;
    l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
    l_other_token_tbl(2).token_value :=
      l_bom_comp_ops_rec.operation_sequence_number;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

           /* Assign the correct transaction type for SYNC operations */

           IF l_bom_comp_ops_rec.transaction_type = 'SYNC' THEN
             l_bom_comp_ops_rec.transaction_type :=
                 l_old_bom_comp_ops_rec.transaction_type;
           END IF;

     --
     -- Process Flow step 6: Is Revised Component record an orphan ?
     --

     IF NOT l_comp_parent_exists
     THEN

      -- Process Flow step 7: Check lineage
      --
           /* Check lineage is not necessary for a component operation */

         /*   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');     END IF;
      Bom_Validate_Comp_Operation.Check_Lineage
      (  p_bom_comp_ops_rec   => l_bom_comp_ops_rec
      ,  p_bom_comp_ops_unexp_rec   => l_bom_comp_ops_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
          RAISE EXC_SEV_QUIT_BRANCH;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_COPS_LIN_UNEXP_SKIP';
      l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_comp_ops_rec.component_item_name;
      l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
      l_other_token_tbl(2).token_value :=
        l_bom_comp_ops_rec.operation_sequence_number;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;
               */

    --
      -- Process Flow step 8(a and b): check that user has access to
          -- Assembly item
      --
      Bom_Validate_Bom_Header.Check_Access
    (  p_organization_id=>l_bom_comp_ops_unexp_rec.organization_id
          ,  p_assembly_item_id=>l_bom_comp_ops_unexp_rec.assembly_item_id
    ,  p_alternate_bom_code=>
        l_bom_comp_ops_rec.alternate_bom_code
    ,  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
    ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          ,  x_return_status      => l_Return_Status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_COPS_RITACC_FAT_FATAL';
      l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_comp_ops_rec.assembly_item_name;
      l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
      l_other_token_tbl(2).token_value :=
        l_bom_comp_ops_rec.operation_sequence_number;
                        l_return_status := 'F';
      RAISE EXC_FAT_QUIT_SIBLINGS;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_COPS_RITACC_UNEXP_SKIP';
      l_other_token_tbl(1).token_name := 'REVISED_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_comp_ops_rec.assembly_item_name;
      l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
      l_other_token_tbl(2).token_value :=
        l_bom_comp_ops_rec.operation_sequence_number;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

       END IF;  -- Check if Not Compononent Parents Exist Ends

    --
    -- Process Flow step:Check that user has access to Bom component
    --

    Bom_Validate_Bom_Component.Check_Access
    (  p_organization_id  =>
          l_bom_comp_ops_unexp_rec.organization_id
    ,  p_component_item_id =>
        l_bom_comp_ops_unexp_rec.component_item_id
    ,  p_component_name     =>
        l_bom_comp_ops_rec.component_item_name
    ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          ,  x_return_status      => l_Return_Status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_COPS_CMPACC_FAT_FATAL';
      l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_comp_ops_rec.component_item_name;
      l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
      l_other_token_tbl(2).token_value :=
        l_bom_comp_ops_rec.operation_sequence_number;
                        l_return_status := 'F';
          RAISE EXC_FAT_QUIT_SIBLINGS;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_COPS_CMPACC_UNEXP_SKIP';
      l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_comp_ops_rec.component_item_name;
      l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
      l_other_token_tbl(2).token_value :=
        l_bom_comp_ops_rec.operation_sequence_number;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

  --
      -- Process Flow step 9: Attribute Validation for Create and Update
      --

      IF l_bom_comp_ops_rec.transaction_type IN
        (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_CREATE)
      THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Component Operation: Check Attributes . . .'); END IF;

          Bom_Validate_Comp_Operation.Check_Attributes
                (   x_return_status            => l_return_status
                ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                ,   p_bom_comp_ops_rec           => l_bom_comp_ops_rec
                ,   p_bom_comp_ops_unexp_rec     => l_bom_comp_ops_unexp_rec
                );

    IF l_return_status = Error_Handler.G_STATUS_ERROR
    THEN
            RAISE EXC_SEV_QUIT_RECORD;
    ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
    THEN
      RAISE EXC_UNEXP_SKIP_OBJECT;
    END IF;
      END IF;

            -- Process flow step 10 - Populate NULL columns for Update and
            -- Delete

      IF l_bom_comp_ops_rec.transaction_type IN
    (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
            THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns'); END IF;
        Bom_Default_Comp_Operation.Populate_Null_Columns
                    (   p_bom_comp_ops_rec     => l_bom_Comp_ops_Rec
                    ,   p_old_bom_Comp_ops_Rec => l_old_bom_Comp_ops_Rec
                    ,   p_bom_comp_ops_unexp_rec    => l_bom_comp_ops_unexp_rec
                    ,   p_old_bom_comp_ops_unexp_rec=> l_old_bom_comp_ops_unexp_rec
                    ,   x_bom_comp_ops_Rec     => l_bom_Comp_ops_Rec
                    ,   x_bom_comp_ops_unexp_rec    => l_bom_comp_ops_unexp_rec
                    );

         ELSIF l_bom_comp_ops_rec.Transaction_Type = Bom_Globals.G_OPR_CREATE
     THEN

    --
          -- Process Flow step 11 : Default missing values for Operation
    -- CREATE
    --

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
          Bom_Default_Comp_Operation.Attribute_Defaulting
                (   p_bom_comp_ops_rec    => l_bom_comp_ops_rec
                ,   p_bom_comp_ops_unexp_rec  => l_bom_comp_ops_unexp_rec
                ,   x_bom_comp_ops_rec    => l_bom_comp_ops_rec
                ,   x_bom_comp_ops_unexp_rec  => l_bom_comp_ops_unexp_rec
                ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                ,   x_return_status   => l_return_status
                );

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

    IF l_return_status = Error_Handler.G_STATUS_ERROR
    THEN
      l_other_message := 'BOM_COPS_ATTDEF_CSEV_SKIP';
      l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_comp_ops_rec.component_item_name;
      l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
      l_other_token_tbl(2).token_value :=
        l_bom_comp_ops_rec.operation_sequence_number;
          RAISE EXC_SEV_SKIP_BRANCH;
    ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
    THEN
      l_other_message := 'BOM_COPS_ATTDEF_UNEXP_SKIP';
      l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_comp_ops_rec.component_item_name;
      l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
      l_other_token_tbl(2).token_value :=
        l_bom_comp_ops_rec.operation_sequence_number;
      RAISE EXC_UNEXP_SKIP_OBJECT;
    END IF;
     END IF;


         -- Process Flow step 12- Entity Level Validation
     --

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;

           IF l_bom_comp_ops_rec.transaction_type <> 'DELETE'
           THEN

              Bom_Validate_Comp_Operation.Check_Entity
          (  p_bom_comp_ops_rec     => l_bom_comp_ops_rec
          ,  p_bom_comp_ops_unexp_rec     => l_bom_comp_ops_unexp_rec
          ,  x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
      ,  x_return_status          => l_Return_Status
          );
           END IF ;

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_COPS_ENTVAL_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_comp_ops_rec.component_item_name;
    l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
    l_other_token_tbl(2).token_value :=
      l_bom_comp_ops_rec.operation_sequence_number;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
         -- Process Flow step 13 : Database Writes
     --

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
         Bom_Comp_Operation_Util.Perform_Writes
          (   p_bom_comp_ops_rec => l_bom_comp_ops_rec
          ,   p_bom_comp_ops_unexp_rec => l_bom_comp_ops_unexp_rec
          ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
          ,   x_return_status     => l_return_status
          );

     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_COPS_WRITES_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_comp_ops_rec.component_item_name;
    l_other_token_tbl(2).token_name := 'OPERATION_SEQUENCE_NUM';
    l_other_token_tbl(2).token_value :=
      l_bom_comp_ops_rec.operation_sequence_number;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        l_bom_comp_ops_tbl(I)          := l_bom_comp_ops_rec;

    --  For loop exception handler.

    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  Error_Handler.Log_Error
    (
       p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_RECORD
    ,  p_error_level  => Error_Handler.G_COP_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_comp_ops_tbl            := l_bom_comp_ops_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
        Error_Handler.Log_Error
                (  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => Error_Handler.G_COP_LEVEL
                ,  p_entity_index       => I
                ,  x_bom_header_rec     => l_bom_header_rec
                ,  x_bom_revision_tbl   => l_bom_revision_tbl
                ,  x_bom_component_tbl  => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
                );
        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_bom_comp_ops_tbl            := l_bom_comp_ops_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN
        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  Error_Handler.Log_Error
    (  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status => Error_Handler.G_STATUS_ERROR
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_COP_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_comp_ops_tbl            := l_bom_comp_ops_tbl;

      RETURN;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN
        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
  Error_Handler.Log_Error
    (  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_COP_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        x_return_status                := Error_Handler.G_STATUS_FATAL;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_comp_ops_tbl            := l_bom_comp_ops_tbl;

      RETURN;

       WHEN EXC_FAT_QUIT_OBJECT THEN

        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
  Error_Handler.Log_Error
    (  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_ALL
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_COP_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_comp_ops_tbl            := l_bom_comp_ops_tbl;

  l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN
        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  Error_Handler.Log_Error
    (  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_UNEXPECTED
    ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RD_LEVEL
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

      x_bom_comp_ops_tbl            := l_bom_comp_ops_tbl;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;

  l_return_status := 'U';

     END; -- END block

      IF l_return_status in ('Q', 'U')
      THEN
          x_return_status := l_return_status;
    RETURN;
      END IF;

  --4306013
  IF( l_bom_comp_ops_tbl(I).transaction_type in ( Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_CREATE )
      AND l_return_status = 'S' )
  THEN
    G_Comp_Op_Flag := 1;
  END IF;

   END LOOP; -- END Component Operations processing loop
   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('after end loop');     END IF;

     /*********Business Event************/
      IF ( G_Comp_Op_Flag = 1 AND l_comp_ops_processed) THEN
           Bom_Business_Event_PKG.Raise_Component_Event(
           p_event_load_type          => 'Bulk'
           , p_request_identifier      => FND_GLOBAL.CONC_REQUEST_ID
           , p_batch_identifier        => BOM_GLOBALS.G_BATCH_ID
           , p_event_entity_name       => 'Component Operation'
           , p_event_name              => Bom_Business_Event_PKG.G_COMPONENT_MODIFIED_EVENT
           , p_last_update_date        => sysdate
           , p_last_updated_by         => fnd_global.user_id
        );
       END IF;
       G_Comp_Op_Flag := 0;
   /*********Business Event************/


    --  Load out parameters

     x_return_status          := l_bo_return_status;
     x_bom_comp_ops_tbl       := l_bom_comp_ops_tbl;
     x_Mesg_Token_Tbl     := l_Mesg_Token_Tbl;


END Component_Operations;

PROCEDURE Substitute_Components
(   p_validation_level              IN  NUMBER
,   p_assembly_item_name      IN  VARCHAR2 := NULL
,   p_organization_id       IN  NUMBER := NULL
,   p_alternate_bom_code      IN  VARCHAR2 := NULL
,   p_effectivity_date            IN  DATE := NULL
,   p_component_item_name     IN  VARCHAR2 := NULL
,   p_operation_seq_num       IN  NUMBER := NULL
,   p_bom_sub_component_tbl         IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_bom_sub_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status       IN OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl            Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl           Error_Handler.Token_Tbl_Type;
l_other_message             VARCHAR2(2000);
l_err_text                  VARCHAR2(2000);
l_valid         BOOLEAN := TRUE;
l_item_parent_exists      BOOLEAN := FALSE;
l_comp_parent_exists      BOOLEAN := FALSE;
l_Return_Status             VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_bom_header_rec      Bom_Bo_Pub.Bom_Head_Rec_Type;
l_bom_revision_tbl      Bom_Bo_Pub.Bom_Revision_Tbl_Type;
l_bom_component_tbl         Bom_Bo_Pub.Bom_Comps_Tbl_Type;
l_bom_ref_designator_tbl    Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
l_bom_sub_component_rec     Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
l_bom_sub_component_tbl     Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
        := p_bom_sub_component_tbl;
l_old_bom_sub_component_rec Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
l_bom_sub_comp_unexp_rec    Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type;
l_old_bom_sub_comp_unexp_rec Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type;
l_return_value              NUMBER;
l_Token_Tbl                 Error_Handler.Token_Tbl_Type;
l_sub_comp_processed        BOOLEAN := FALSE;
BEGIN

    l_return_status := 'S';
    l_bo_return_status := 'S';

    l_comp_parent_exists := FALSE;
    l_item_parent_exists := FALSE;

    --  Init local table variables.

    l_bom_sub_component_tbl            := p_bom_sub_component_tbl;

    l_bom_sub_comp_unexp_rec.organization_id := Bom_Globals.Get_org_id;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within Substitute Components . . . will process records: ' || l_bom_sub_component_tbl.COUNT); END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Input parameters '); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Assembly : ' || p_assembly_item_name);
END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Organization: ' || p_organization_id);END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Alternate: ' || p_alternate_bom_code);END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Component: ' || p_component_item_name);END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Op Seq: ' || p_operation_seq_num); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Eff Dt: ' || to_char(p_effectivity_date)); END IF;

    FOR I IN 1..l_bom_sub_component_tbl.COUNT LOOP
    BEGIN

  --  Load local records.

        l_bom_sub_component_rec := l_bom_sub_component_tbl(I);
  l_bom_sub_comp_unexp_rec := Bom_Bo_Pub.G_MISS_BOM_SUB_COMP_UNEXP_REC;
  l_bom_sub_comp_unexp_rec.organization_id := Bom_Globals.Get_org_id;


IF Bom_Globals.Get_Debug = 'Y' THEN
  Error_Handler.Write_Debug('Substitute Component Record values:');
  Error_Handler.Write_Debug('Component Item Name: ' || l_bom_sub_component_rec.component_item_name);
  Error_Handler.Write_Debug('Op Seq Num: ' || l_bom_sub_component_rec.operation_sequence_number);
  Error_Handler.Write_Debug('Effectivity Date: ' || l_bom_sub_component_rec.start_effective_date);
  Error_Handler.Write_Debug('Organization Id: ' || l_bom_sub_comp_unexp_rec.organization_id);
END IF;

        l_bom_sub_component_rec.transaction_type :=
          UPPER(l_bom_sub_component_rec.transaction_type);

  IF p_component_item_name IS NOT NULL AND
           p_operation_seq_num IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
          -- revised comp parent exists

    l_comp_parent_exists := TRUE;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps called by Component . . .'); END IF;

  ELSIF p_assembly_item_name IS NOT NULL AND
              p_organization_id IS NOT NULL
        THEN
          -- revised item parent exists

    l_item_parent_exists := TRUE;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps called by Header. . .'); END IF;

        END IF;

  -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comp Status prior to start of processing: ' || l_bom_sub_component_rec.return_status);
END IF;

      IF ( l_bom_sub_component_rec.return_status IS NULL OR
           l_bom_sub_component_rec.return_status = FND_API.G_MISS_CHAR
      )
           AND
          -- Did Bom_Components call this procedure ?
          -- i.e. if Bom comp exists, then is this record a child ?
     ((l_comp_parent_exists AND
         (l_bom_sub_component_rec.component_item_name =
        p_component_item_name AND
          l_bom_sub_comp_unexp_rec.organization_id =
        p_organization_id AND
          l_bom_sub_component_rec.start_effective_date =
        p_effectivity_date AND
          l_bom_sub_component_rec.operation_sequence_number =
        p_operation_seq_num
    )
        )
            OR
            -- Did Bom Header call this procedure, that is,
            -- is this record an indirect child ?
        (l_item_parent_exists AND
           (  l_bom_sub_component_rec.assembly_item_name =
            p_assembly_item_name AND
              l_bom_sub_comp_unexp_rec.organization_id =
            p_organization_id AND
              NVL(l_bom_sub_component_rec.alternate_bom_code, 'NONE') =
            NVL(p_alternate_bom_code, 'NONE')
            )
         )
         OR
         (  NOT l_comp_parent_exists AND
            NOT l_item_parent_exists
          )
       )
      THEN
         l_sub_comp_processed   := TRUE;
         l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_bom_sub_component_rec.return_status := FND_API.G_RET_STS_SUCCESS;

     --
     -- Check if transaction_type is valid
     --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps: Transaction Type Validity . . .'); END IF;
     Bom_Globals.Transaction_Type_Validity
     (   p_transaction_type => l_bom_sub_component_rec.transaction_type
     ,   p_entity   => 'Sub_Comps'
     ,   p_entity_id  => l_bom_sub_component_rec.assembly_item_name
     ,   x_valid    => l_valid
     ,   x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     );

     IF NOT l_valid
     THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
        RAISE EXC_SEV_QUIT_RECORD;
     END IF;

     --
     -- Process Flow step 4(a): Convert user unique index to unique
     -- index I
     --
     --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps: UUI-UI Conversion . . .'); END IF;

     Bom_Val_To_Id.Sub_Component_UUI_To_UI
    ( p_bom_sub_component_rec  => l_bom_sub_component_rec
    , p_bom_sub_comp_unexp_rec => l_bom_sub_comp_unexp_rec
    , x_bom_sub_comp_unexp_rec => l_bom_sub_comp_unexp_rec
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
    l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
     -- Process Flow step 4(b): Convert user unique index to unique
     -- index II
     --

     Bom_Val_To_Id.Sub_Component_UUI_To_UI2
    ( p_bom_sub_component_rec  => l_bom_sub_component_rec
    , p_bom_sub_comp_unexp_rec => l_bom_sub_comp_unexp_rec
    , x_bom_sub_comp_unexp_rec => l_bom_sub_comp_unexp_rec
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_other_message      => l_other_message
    , x_other_token_tbl    => l_other_token_tbl
    , x_Return_Status      => l_return_status
    );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_SIBLINGS;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_SBC_UUI_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     Error_Handler.Write_Debug ('SCOMP: Transaction type before SYNC is '||l_bom_sub_component_rec.transaction_type);

     --
     -- Process Flow step 5: Verify Substitute Component's existence
     --

     Bom_Validate_Sub_Component.Check_Existence
      (  p_bom_sub_component_rec    => l_bom_sub_component_rec
      ,  p_bom_sub_comp_unexp_rec   => l_bom_sub_comp_unexp_rec
    ,  x_old_bom_sub_component_rec  => l_old_bom_sub_component_rec
                ,  x_old_bom_sub_comp_unexp_rec => l_old_bom_sub_comp_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_SBC_EXS_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
    l_other_token_tbl(2).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(2).token_value :=
        l_bom_sub_component_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     Error_Handler.Write_Debug ('SCOMP: Transaction type After check exist '||l_bom_sub_component_rec.transaction_type);
           /* Assign the correct transaction type for SYNC operations */

           IF l_bom_sub_component_rec.transaction_type = 'SYNC' THEN
             l_bom_sub_component_rec.transaction_type :=
                 l_old_bom_sub_component_rec.transaction_type;
           END IF;
     Error_Handler.Write_Debug ('SCOMP: Transaction type after SYNC is '||l_bom_sub_component_rec.transaction_type);
     -- Process Flow step 7: Is Subsitute Component record an orphan ?

     IF NOT l_comp_parent_exists
     THEN

    --
      -- Process Flow step 6: Check lineage
      --

      Bom_Validate_Sub_Component.Check_Lineage
      (  p_bom_sub_component_rec    => l_bom_sub_component_rec
      ,  p_bom_sub_comp_unexp_rec   => l_bom_sub_comp_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
          RAISE EXC_SEV_QUIT_BRANCH;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_SBC_LIN_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
        'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

    --
    -- Process Flow Step: 6a - Check Assembly Item Accessibility
    --
      Bom_Validate_Bom_Header.Check_Access
    (  p_organization_id =>l_bom_sub_comp_unexp_rec.organization_id
          ,  p_assembly_item_id=>l_bom_sub_comp_unexp_rec.assembly_item_id
    ,  p_alternate_bom_code=>
        l_bom_sub_component_rec.alternate_bom_code
    ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          ,  x_return_status      => l_Return_Status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_SBC_RITACC_FAT_FATAL';
      l_other_token_tbl(1).token_name :=
          'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
          l_bom_sub_component_rec.substitute_component_name;
                        l_return_status := 'F';
      RAISE EXC_FAT_QUIT_SIBLINGS;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_SBC_RITACC_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

    --
    -- Process Flow step 6b: Check that user has access to revised
    -- component
    --

    Bom_Validate_Bom_Component.Check_Access
    (  p_organization_id  =>
        l_bom_sub_comp_unexp_rec.organization_id
    ,  p_component_item_id  =>
        l_bom_sub_comp_unexp_rec.component_item_id
    ,  p_component_name     =>
        l_bom_sub_component_rec.component_item_name
    ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          ,  x_return_status      => l_Return_Status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_SBC_CMPACC_FAT_FATAL';
      l_other_token_tbl(1).token_name :=
            'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
      l_other_token_tbl(2).token_name :=
            'REVISED_COMPONENT_NAME';
      l_other_token_tbl(2).token_value :=
      l_bom_sub_component_rec.component_item_name;
                        l_return_status := 'F';
          RAISE EXC_FAT_QUIT_SIBLINGS;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_SBC_CMPACC_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
            'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
      l_other_token_tbl(2).token_name :=
            'REVISED_COMPONENT_NAME';
                        l_other_token_tbl(2).token_value :=
        l_bom_sub_component_rec.component_item_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

    --
    -- Process Flow step 7: Does user have access to substitute
    -- component ?
    --

    Bom_Validate_Sub_Component.Check_Access
    (  p_bom_sub_component_rec => l_bom_sub_component_rec
    ,  p_bom_sub_comp_unexp_rec => l_bom_sub_comp_unexp_rec
    ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          ,  x_return_status      => l_Return_Status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_SBC_ACCESS_FAT_FATAL';
      l_other_token_tbl(1).token_name :=
            'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
                        l_return_status := 'F';
          RAISE EXC_FAT_QUIT_BRANCH;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_SBC_ACCESS_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

     END IF;

  --
      -- Process Flow step 8: Attribute Validation for Create and Update
      --

      IF l_bom_sub_component_rec.transaction_type IN
        (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_CREATE)
      THEN
    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Substitute Component: Check Attributes . . .'); END IF;

          Bom_Validate_Sub_Component.Check_Attributes
          (  p_bom_sub_component_rec      => l_bom_sub_component_rec
          ,  p_bom_sub_comp_unexp_rec     => l_bom_sub_comp_unexp_rec
          ,  x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
      ,  x_return_status          => l_Return_Status
          );

    IF l_return_status = Error_Handler.G_STATUS_ERROR
    THEN
            RAISE EXC_SEV_QUIT_RECORD;
    ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
    THEN
      RAISE EXC_UNEXP_SKIP_OBJECT;
    END IF;
      END IF;

     -- peform Populate_null_columns if the Transaction Type is
     -- not INSERT.

     IF l_bom_sub_component_rec.Transaction_Type IN
            (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
         THEN

          -- Process flow step 8  - Populate NULL columns for Update and
          -- Delete.

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Comp Seq: ' || l_bom_sub_comp_unexp_rec.component_sequence_id); END IF;

    Bom_Default_Sub_Component.Populate_NULL_Columns
                (   p_bom_sub_component_rec   => l_bom_sub_component_rec
                ,   p_old_bom_sub_component_rec => l_old_bom_sub_component_rec
                ,   p_bom_sub_comp_unexp_rec  => l_bom_sub_comp_unexp_rec
                ,   p_old_bom_sub_comp_unexp_rec=> l_old_bom_sub_comp_unexp_rec
                ,   x_bom_sub_component_rec   => l_bom_sub_component_rec
                ,   x_bom_sub_comp_unexp_rec  => l_bom_sub_comp_unexp_rec
                );
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Comp Seq after populate: ' || l_bom_sub_comp_unexp_rec.component_sequence_id); END IF;


         ELSIF l_bom_sub_component_rec.Transaction_Type =
          Bom_Globals.G_OPR_CREATE
     THEN

    --
          -- Process Flow step 9: Default missing values for Operation
    -- CREATE
    --

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps: Attribute Defaulting, comp seq: '|| l_bom_sub_comp_unexp_rec.component_sequence_id); END IF;
          Bom_Default_Sub_Component.Attribute_Defaulting
                (   p_bom_sub_component_rec   => l_bom_sub_component_rec
                ,   p_bom_sub_comp_unexp_rec  => l_bom_sub_comp_unexp_rec
                ,   x_bom_sub_component_rec   => l_bom_sub_component_rec
                ,   x_bom_sub_comp_unexp_rec  => l_bom_sub_comp_unexp_rec
                ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                ,   x_return_status   => l_return_status
                );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps: Comp Seq after defaulting ' || l_bom_sub_comp_unexp_rec.component_sequence_id); END IF;

    IF l_return_status = Error_Handler.G_STATUS_ERROR
    THEN
          RAISE EXC_SEV_QUIT_RECORD;
    ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
    THEN
      l_other_message := 'BOM_SBC_ATTDEF_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'SUBSTITUTE_ITEM_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
    END IF;

     END IF; -- Process flow step 8 Ends

     --
         -- Process Flow step 9 - Entity Level Validation
     --
         Bom_Validate_Sub_Component.Check_Entity
          (  p_bom_sub_component_rec      => l_bom_sub_component_rec
          ,  p_bom_sub_comp_unexp_rec     => l_bom_sub_comp_unexp_rec
          ,  x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
      ,  x_return_status          => l_Return_Status
          );

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_SBC_ENTVAL_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

           --
         -- Process Flow step 10 : Database Writes
     --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps: Performing Database write...'); END IF;

         Bom_Sub_Component_Util.Perform_Writes
          (   p_bom_sub_component_rec   => l_bom_sub_component_rec
          ,   p_bom_sub_comp_unexp_rec  => l_bom_sub_comp_unexp_rec
          ,   x_Mesg_Token_Tbl          => l_Mesg_Token_Tbl
          ,   x_return_status           => l_return_status
          );

     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_SBC_WRITES_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_sub_component_rec.substitute_component_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

  --l_bom_sub_component_rec.return_status := l_return_status;

        l_bom_sub_component_tbl(I)          := l_bom_sub_component_rec;

        IF( l_bom_sub_component_tbl(I).transaction_type in ( Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_CREATE )
        AND l_return_status = 'S')
        THEN
          G_SUB_COMP_FLAG := 1;
        END IF;

        x_return_status := l_return_status;

    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

    Error_Handler.Log_Error
    (  p_bom_sub_component_tbl => l_bom_sub_component_tbl
           , p_Mesg_Token_tbl => l_mesg_token_tbl
           , p_error_status => Error_Handler.G_STATUS_ERROR
           , p_error_scope  => Error_Handler.G_SCOPE_RECORD
           , p_error_level  => Error_Handler.G_SC_LEVEL
           , p_entity_index => I
           , x_bom_header_rec => l_bom_header_rec
           , x_bom_revision_tbl => l_bom_revision_tbl
           , x_bom_component_tbl  => l_bom_component_tbl
           , x_bom_ref_Designator_tbl => l_bom_ref_designator_tbl
           , x_bom_sub_component_tbl  => l_bom_sub_component_tbl
           );
        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

          Error_Handler.Log_Error
                (  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => Error_Handler.G_SC_LEVEL
                ,  p_entity_index       => I
                ,  x_bom_header_rec     => l_bom_header_rec
                ,  x_bom_revision_tbl   => l_bom_revision_tbl
                ,  x_bom_component_tbl  => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN

    Error_Handler.Log_Error
    (  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status => Error_Handler.G_STATUS_ERROR
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_SC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

      RETURN;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN

    Error_Handler.Log_Error
    (  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_SC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

      RETURN;

       WHEN EXC_FAT_QUIT_BRANCH THEN

  Error_Handler.Log_Error
    (  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_CHILDREN
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_SC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

       WHEN EXC_FAT_QUIT_OBJECT THEN

  Error_Handler.Log_Error
    (  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_ALL
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_SC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

  l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

  Error_Handler.Log_Error
    (  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_UNEXPECTED
    ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_SC_LEVEL
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        x_return_status                := l_bo_return_status;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;

  l_return_status := 'U';

        END; -- END block

     END LOOP; -- END Substitute Components processing loop

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
  RETURN;
    END IF;

    --  Load out parameters

 /*********Business Event************/
   IF ( G_SUB_COMP_FLAG = 1 AND l_sub_comp_processed) THEN
        Bom_Business_Event_PKG.Raise_Component_Event(
          p_event_load_type          => 'Bulk'
        , p_request_identifier      => FND_GLOBAL.CONC_REQUEST_ID
        , p_batch_identifier        => BOM_GLOBALS.G_BATCH_ID
        , p_event_entity_name       => 'Substitute Component'
        , p_event_name              => Bom_Business_Event_PKG.G_COMPONENT_MODIFIED_EVENT
        , p_last_update_date        => sysdate
        , p_last_updated_by         => fnd_global.user_id
    );
   END IF;
   G_SUB_COMP_FLAG := 0;
   /*********Business Event************/

     x_return_status          := l_bo_return_status;
     x_bom_sub_component_tbl    := l_bom_sub_component_tbl;
     x_Mesg_Token_Tbl     := l_Mesg_Token_Tbl;

END Substitute_Components;


--  Ref_Desgs

PROCEDURE Reference_Designators
(   p_validation_level              IN  NUMBER
,   p_organization_id       IN  NUMBER := NULL
,   p_assembly_item_name      IN  VARCHAR2 := NULL
,   p_alternate_bom_code      IN  VARCHAR2 := NULL
,   p_effectivity_date            IN  DATE := NULL
,   p_component_item_name     IN  VARCHAR2 := NULL
,   p_operation_seq_num       IN  NUMBER := NULL
,   p_bom_ref_designator_tbl        IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   p_bom_sub_component_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_bom_ref_designator_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   x_bom_sub_component_tbl     IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status       IN OUT NOCOPY VARCHAR2
)
IS
TYPE Bom_Comp_Details_Rec_Type IS RECORD
(  Component_Item_Name       VARCHAR2(240)
 , Component_Sequence_Id     NUMBER
 , Entity_Index              NUMBER
);
TYPE Bom_Comp_Details_Tbl_Type IS TABLE OF Bom_Comp_Details_Rec_Type
    INDEX BY BINARY_INTEGER;
l_Comp_Seq_Id           NUMBER;
l_Comp_Item_Name        VARCHAR2(240);
l_Bom_Comp_Details_Tbl  Bom_Comp_Details_Tbl_Type;
l_Rec_Index             NUMBER;

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid     BOOLEAN := TRUE;
l_item_parent_exists  BOOLEAN := FALSE;
l_comp_parent_exists  BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);
l_bom_header_rec  Bom_Bo_Pub.Bom_Head_Rec_Type;
l_bom_revision_tbl  Bom_Bo_Pub.Bom_Revision_Tbl_Type;
l_bom_component_tbl     Bom_Bo_Pub.Bom_Comps_Tbl_Type;
l_bom_ref_designator_rec    Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
l_bom_ref_designator_tbl    Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type :=
          p_bom_ref_designator_tbl;
l_old_bom_ref_designator_rec Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
l_bom_ref_desg_unexp_rec    Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type;
l_old_bom_ref_desg_unexp_rec Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type;
l_bom_sub_component_tbl     Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
          p_bom_sub_component_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_ref_desig_processed   BOOLEAN := FALSE;
BEGIN

    --  Init local table variables.

    l_return_status := 'S';
    l_bo_return_status := 'S';

    l_bom_ref_designator_tbl           := p_bom_ref_designator_tbl;

    l_bom_ref_desg_unexp_rec.organization_id := Bom_Globals.Get_org_id;


    FOR I IN 1..l_bom_ref_designator_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_bom_ref_designator_rec := l_bom_ref_designator_tbl(I);

        l_bom_ref_designator_rec.transaction_type :=
          UPPER(l_bom_ref_designator_rec.transaction_type);

        IF p_component_item_name IS NOT NULL AND
           p_operation_seq_num IS NOT NULL AND
           p_assembly_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
          -- Inventory Component parent exists

          l_comp_parent_exists := TRUE;

        ELSIF p_assembly_item_name IS NOT NULL AND
           p_effectivity_date IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
          -- Assembly item parent exists

          l_item_parent_exists := TRUE;
        END IF;

      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF (l_bom_ref_designator_rec.return_status IS NULL OR
          l_bom_ref_designator_rec.return_status = FND_API.G_MISS_CHAR)
         AND

         -- Did Revised_Components call this procedure, that is,
         -- if revised comp exists, then is this record a child ?

     ((l_comp_parent_exists AND
         (l_bom_ref_designator_rec.assembly_item_name =
          p_assembly_item_name AND
          l_bom_ref_desg_unexp_rec.organization_id = p_organization_id
    AND
          l_bom_ref_designator_rec.component_item_name =
    p_component_item_name AND
          l_bom_ref_designator_rec.operation_sequence_number =
    p_operation_seq_num
    AND l_bom_ref_designator_rec.start_effective_date =
          p_effectivity_date   -- Bug 4519366. Effectivity date needed to identify parent
         )
       )
           OR
           -- Did Bom_Header call this procedure, that is,
           -- if revised item exists, then is this record a child ?

       (l_item_parent_exists AND
         (l_bom_ref_designator_rec.assembly_item_name =
      p_assembly_item_name AND
          l_bom_ref_desg_unexp_rec.organization_id =
      p_organization_id AND
    l_bom_ref_designator_rec.alternate_bom_code =
      p_alternate_bom_code
    )
        )
       OR
           (NOT l_item_parent_exists AND
        NOT l_comp_parent_exists))
      THEN
         l_ref_desig_processed := TRUE;
         l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_bom_ref_designator_rec.return_status := FND_API.G_RET_STS_SUCCESS;

     --
     -- Check if transaction_type is valid
     --

     Bom_Globals.Transaction_Type_Validity
     (   p_transaction_type => l_bom_ref_designator_rec.transaction_type
     ,   p_entity   => 'Ref_Desgs'
     ,   p_entity_id  => l_bom_ref_designator_rec.assembly_item_name
     ,   x_valid    => l_valid
     ,   x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     );

     IF NOT l_valid
     THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
        RAISE EXC_SEV_QUIT_RECORD;
     END IF;

     --
     -- Process Flow step 4(a): Convert user unique index to unique
     -- index I
     --
     Bom_Val_To_Id.Ref_Designator_UUI_To_UI
    ( p_bom_ref_designator_rec => l_bom_ref_designator_rec
    , p_bom_ref_desg_unexp_rec => l_bom_ref_desg_unexp_rec
    , x_bom_ref_desg_unexp_rec => l_bom_ref_desg_unexp_rec
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_Return_Status      => l_return_status
    );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_RFD_UUI_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
     -- Process Flow step 4(b): Convert user unique index to unique
     -- index II
     --

     Bom_Val_To_Id.Ref_Designator_UUI_To_UI2
    ( p_bom_ref_designator_rec => l_bom_ref_designator_rec
    , p_bom_ref_desg_unexp_rec => l_bom_ref_desg_unexp_rec
    , x_bom_ref_desg_unexp_rec => l_bom_ref_desg_unexp_rec
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_other_message      => l_other_message
                , x_other_token_tbl    => l_other_token_tbl
    , x_Return_Status      => l_return_status
    );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_SIBLINGS;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_RFD_UUI_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
     -- Process Flow step 5: Verify Reference Designator's existence
     --

     Bom_Validate_Ref_Designator.Check_Existence
      (  p_bom_ref_designator_rec   => l_bom_ref_designator_rec
      ,  p_bom_ref_desg_unexp_rec   => l_bom_ref_desg_unexp_rec
    ,  x_old_bom_ref_designator_rec => l_old_bom_ref_designator_rec
                ,  x_old_bom_ref_desg_unexp_rec => l_old_bom_ref_desg_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_RFD_EXS_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
                l_other_token_tbl(2).token_name := 'REVISED_COMPONENT_NAME';
                l_other_token_tbl(2).token_value :=
      l_bom_ref_designator_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

           /* Assign the correct transaction type for SYNC operations */

           IF l_bom_ref_designator_rec.transaction_type = 'SYNC' THEN
             l_bom_ref_designator_rec.transaction_type :=
                 l_old_bom_ref_designator_rec.transaction_type;
           END IF;

     --
     -- Process Flow step 6: Is Revised Component record an orphan ?
     --

     IF NOT l_comp_parent_exists
     THEN

      -- Process Flow step 7: Check lineage
      --

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');     END IF;
      Bom_Validate_Ref_Designator.Check_Lineage
      (  p_bom_ref_designator_rec   => l_bom_ref_designator_rec
      ,  p_bom_ref_desg_unexp_rec   => l_bom_ref_desg_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
          RAISE EXC_SEV_QUIT_BRANCH;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_RFD_LIN_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'REFERENCE_DESIGNATOR_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

    --
      -- Process Flow step 9(a and b): check that user has access to
          -- Assembly item
      --
      Bom_Validate_Bom_Header.Check_Access
    (  p_organization_id=>l_bom_ref_desg_unexp_rec.organization_id
          ,  p_assembly_item_id=>l_bom_ref_desg_unexp_rec.assembly_item_id
    ,  p_alternate_bom_code=>
        l_bom_ref_designator_rec.alternate_bom_code
    ,  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
    ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          ,  x_return_status      => l_Return_Status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_RFD_RITACC_FAT_FATAL';
      l_other_token_tbl(1).token_name :=
          'REFERENCE_DESIGNATOR_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
                        l_return_status := 'F';
      RAISE EXC_FAT_QUIT_SIBLINGS;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_RFD_RITACC_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'REFERENCE_DESIGNATOR_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

       END IF;  -- Check if Not Compononent Parents Exist Ends

    --
    -- Process Flow step:Check that user has access to Bom component
    --

    Bom_Validate_Bom_Component.Check_Access
    (  p_organization_id  =>
          l_bom_ref_desg_unexp_rec.organization_id
    ,  p_component_item_id =>
        l_bom_ref_desg_unexp_rec.component_item_id
    ,  p_component_name     =>
        l_bom_ref_designator_rec.component_item_name
    ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          ,  x_return_status      => l_Return_Status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_RFD_CMPACC_FAT_FATAL';
      l_other_token_tbl(1).token_name :=
        'REFERENCE_DESIGNATOR_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
                        l_return_status := 'F';
          RAISE EXC_FAT_QUIT_SIBLINGS;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_RFD_CMPACC_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
        'REFERENCE_DESIGNATOR_NAME';
      l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

     IF l_bom_ref_designator_rec.transaction_type IN
            (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
         THEN

          -- Process flow step 11 - Populate NULL columns for Update and
          -- Delete.

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populating NULL Columns'); END IF;
    Bom_Default_Ref_Designator.Populate_NULL_Columns
                (   p_bom_ref_designator_rec    => l_bom_ref_designator_rec
                ,   p_old_bom_ref_designator_rec=> l_old_bom_ref_designator_rec
                ,   p_bom_ref_desg_unexp_rec  => l_bom_ref_desg_unexp_rec
                ,   p_old_bom_ref_desg_unexp_rec=> l_old_bom_ref_desg_unexp_rec
                ,   x_bom_ref_designator_rec    => l_bom_ref_designator_rec
                ,   x_bom_ref_desg_unexp_rec  => l_bom_ref_desg_unexp_rec
                );

     END IF;

         -- Process Flow step 12 - Entity Level Validation
     --

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation'); END IF;

           IF l_bom_ref_designator_rec.transaction_type = 'DELETE'
           THEN

           IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Calling Entity Delete validation'); END IF;

                Bom_Validate_Ref_Designator.Check_Entity_Delete
          (  p_bom_ref_designator_rec     => l_bom_ref_designator_rec
          ,  p_bom_ref_desg_unexp_rec     => l_bom_ref_desg_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );
           ELSE
              Bom_Validate_Ref_Designator.Check_Entity
          (  p_bom_ref_designator_rec     => l_bom_ref_designator_rec
          ,  p_bom_ref_desg_unexp_rec     => l_bom_ref_desg_unexp_rec
          ,  x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
      ,  x_return_status          => l_Return_Status
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
    l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
            ELSIF l_return_status ='S' AND
                    l_Mesg_Token_Tbl.COUNT <>0
            THEN
              Error_Handler.Log_Error
                (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl => l_mesg_token_tbl
                ,  p_error_status => 'W'
                ,  p_error_level  => Error_Handler.G_RD_LEVEL
                ,  p_entity_index => I
                ,  x_bom_header_rec     => l_bom_header_rec
                ,  x_bom_revision_tbl => l_bom_revision_tbl
                ,  x_bom_component_tbl  => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
                );
            END IF;

     --
         -- Process Flow step 14 : Database Writes
     --

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing to the database'); END IF;
         Bom_Ref_Designator_Util.Perform_Writes
          (   p_bom_ref_designator_rec => l_bom_ref_designator_rec
          ,   p_bom_ref_desg_unexp_rec => l_bom_ref_desg_unexp_rec
          ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
          ,   x_return_status     => l_return_status
          );

     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_RFD_WRITES_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_ref_designator_rec.reference_designator_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        l_Comp_Seq_Id    := l_bom_ref_desg_unexp_rec.Component_Sequence_Id;
        l_Comp_Item_Name := l_bom_ref_designator_rec.Component_Item_Name;
        IF NOT l_comp_parent_exists THEN
          l_Bom_Comp_Details_Tbl(l_Comp_Seq_Id).Component_Sequence_Id := l_Comp_Seq_Id;
          l_Bom_Comp_Details_Tbl(l_Comp_Seq_Id).Component_Item_Name := l_Comp_Item_Name;
          l_Bom_Comp_Details_Tbl(l_Comp_Seq_Id).Entity_Index := I;
        END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        l_bom_ref_designator_tbl(I)          := l_bom_ref_designator_rec;
        --4306013
        IF( l_bom_ref_designator_tbl(I).transaction_type in ( Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_CREATE )
        AND l_return_status = 'S')
        THEN
          G_Ref_Desig_Flag := 1;
       END IF;

    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

    Error_Handler.Log_Error
    (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_RECORD
    ,  p_error_level  => Error_Handler.G_RD_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

        Error_Handler.Log_Error
                (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status       => Error_Handler.G_STATUS_ERROR
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => Error_Handler.G_RD_LEVEL
                ,  p_entity_index       => I
                ,  x_bom_header_rec     => l_bom_header_rec
                ,  x_bom_revision_tbl   => l_bom_revision_tbl
                ,  x_bom_component_tbl  => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN

  Error_Handler.Log_Error
    (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status => Error_Handler.G_STATUS_ERROR
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RD_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

      RETURN;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN

  Error_Handler.Log_Error
    (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RD_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

        x_return_status                := Error_Handler.G_STATUS_FATAL;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

      RETURN;

       WHEN EXC_FAT_QUIT_OBJECT THEN

  Error_Handler.Log_Error
    (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_ALL
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RD_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;

  l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

  Error_Handler.Log_Error
    (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_UNEXPECTED
    ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RD_LEVEL
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );

      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;

  l_return_status := 'U';

     END; -- END block

      IF l_return_status in ('Q', 'U')
      THEN
          x_return_status := l_return_status;
    RETURN;
      END IF;

  END LOOP; -- END Reference Designator processing loop

    l_Rec_Index := l_Bom_Comp_Details_Tbl.FIRST;
    WHILE l_Rec_Index IS NOT NULL LOOP
      Bom_Validate_Ref_Designator.check_quantity
        ( x_return_status         => l_return_status
        , x_mesg_token_tbl        => l_Mesg_Token_Tbl
        , p_component_sequence_id => l_Bom_Comp_Details_Tbl(l_Rec_Index).component_sequence_id
        , p_component_item_name   => l_Bom_Comp_Details_Tbl(l_Rec_Index).component_item_name
        );
      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
        Error_Handler.Log_Error
        (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
        ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
        ,  p_mesg_token_tbl => l_mesg_token_tbl
        ,  p_error_status => Error_Handler.G_STATUS_WARNING
        ,  p_error_scope  => Error_Handler.G_SCOPE_RECORD
        ,  p_error_level  => Error_Handler.G_RD_LEVEL
        ,  p_entity_index => l_Bom_Comp_Details_Tbl(l_Rec_Index).Entity_Index
        ,  x_bom_header_rec => l_bom_header_rec
        ,  x_bom_revision_tbl => l_bom_revision_tbl
        ,  x_bom_component_tbl  => l_bom_component_tbl
        ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
        ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
        );
      END IF;
        l_Rec_Index := l_Bom_Comp_Details_Tbl.NEXT(l_Rec_Index);
      END LOOP; -- END proceesing components for orphan ref desigs

   /*********Business Event************/
   IF ( G_Ref_Desig_Flag = 1 AND l_ref_desig_processed) THEN
        Bom_Business_Event_PKG.Raise_Component_Event(
        p_event_load_type          => 'Bulk'
        , p_request_identifier      => FND_GLOBAL.CONC_REQUEST_ID
        , p_batch_identifier        => BOM_GLOBALS.G_BATCH_ID
        , p_event_entity_name       => 'Reference Designator'
        , p_event_name              => Bom_Business_Event_PKG.G_COMPONENT_MODIFIED_EVENT
        , p_last_update_date        => sysdate
        , p_last_updated_by         => fnd_global.user_id
    );
   END IF;
   G_Ref_Desig_Flag := 0;
   /*********Business Event************/

    --  Load out parameters

     x_return_status          := l_bo_return_status;
     x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
     x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
     x_Mesg_Token_Tbl     := l_Mesg_Token_Tbl;


END Reference_Designators;

--  Bom _Components

PROCEDURE Bom_Components
(   p_validation_level              IN  NUMBER
,   p_organization_id       IN  NUMBER := NULL
,   p_assembly_item_name      IN  VARCHAR2 := NULL
,   p_alternate_bom_code      IN  VARCHAR2 := NULL
,   p_effectivity_date            IN  DATE := NULL
,   p_bom_component_tbl             IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type
,   p_bom_ref_designator_tbl      IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   p_bom_sub_component_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   p_bom_comp_ops_tbl            IN  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
,   x_bom_component_tbl             IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
,   x_bom_ref_designator_tbl      IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   x_bom_sub_component_tbl     IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_bom_comp_ops_tbl            IN OUT NOCOPY  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
,   x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status       IN OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid     BOOLEAN := TRUE;
l_item_parent_exists  BOOLEAN := FALSE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status      VARCHAR2(1);

l_bom_header_rec  Bom_Bo_Pub.Bom_Head_Rec_Type;
l_bom_revision_tbl  Bom_Bo_Pub.Bom_Revision_Tbl_Type;
l_bom_component_rec     Bom_Bo_Pub.Bom_Comps_Rec_Type;
l_bom_component_tbl     Bom_Bo_Pub.Bom_Comps_Tbl_Type := p_bom_component_tbl;
l_bom_comp_unexp_rec    Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type;
l_old_bom_component_rec Bom_Bo_Pub.Bom_Comps_Rec_Type;
l_old_bom_comp_unexp_rec Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type;
l_bom_ref_designator_tbl    Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type :=
          p_bom_ref_designator_tbl;
l_bom_sub_component_tbl     Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
          p_bom_sub_component_tbl;
l_bom_comp_ops_tbl      Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type :=
          p_bom_comp_ops_tbl;
l_return_value          NUMBER;
l_process_children  BOOLEAN := TRUE;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
create_rec_flag    VARCHAR2(1) :='N';
l_comps_processed BOOLEAN := FALSE;
BEGIN

    --  Init local table variables.

    l_return_status := 'S';
    l_bo_return_status := 'S';

    l_bom_component_tbl            := p_bom_component_tbl;

    l_bom_comp_unexp_rec.organization_id := Bom_Globals.Get_org_id;

    FOR I IN 1..l_bom_component_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_bom_component_rec := l_bom_component_tbl(I);

  l_process_children := false;

  -- Initialize the unexposed record;
  l_bom_comp_unexp_rec := Bom_Bo_Pub.G_MISS_BOM_COMP_UNEXP_REC;
  l_bom_comp_unexp_rec.organization_id := Bom_Globals.Get_org_id;


        l_bom_component_rec.transaction_type :=
          UPPER(l_bom_component_rec.transaction_type);

        IF p_assembly_item_name IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
          -- revised item parent exists

          l_item_parent_exists := TRUE;
        END IF;

      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF (l_bom_component_rec.return_status IS NULL OR
          l_bom_component_rec.return_status = FND_API.G_MISS_CHAR)
         AND

          -- Did Rev_Items call this procedure, that is,
          -- if revised item exists, then is this record a child ?

      (NOT l_item_parent_exists
       OR
       (l_item_parent_exists AND
        (l_bom_component_rec.assembly_item_name = p_assembly_item_name AND
         l_bom_comp_unexp_rec.organization_id = p_organization_id
         )
        )
       )
      THEN
         l_comps_processed := TRUE;
         l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_bom_component_rec.return_status := FND_API.G_RET_STS_SUCCESS;

     --
     -- Check if transaction_type is valid
     --

     Bom_Globals.Transaction_Type_Validity
     (   p_transaction_type => l_bom_component_rec.transaction_type
     ,   p_entity   => 'Rev_Comps'
     ,   p_entity_id  => l_bom_component_rec.assembly_item_name
     ,   x_valid    => l_valid
     ,   x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     );

     IF NOT l_valid
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     END IF;

     --
     -- Process Flow step 4(a): Convert user unique index to unique
     -- index I
     --

     Bom_Val_To_Id.Bom_Component_UUI_To_UI
    ( p_bom_component_rec  => l_bom_component_rec
    , p_bom_comp_unexp_rec => l_bom_comp_unexp_rec
    , x_bom_comp_unexp_rec => l_bom_comp_unexp_rec
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_Return_Status      => l_return_status
    );

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
    l_other_message := 'BOM_CMP_UUI_SEV_ERROR';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
        RAISE EXC_SEV_QUIT_BRANCH;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_CMP_UUI_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
      l_bom_component_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
     -- Process Flow step 4(b): Convert user unique index to unique
     -- index II
     --

     Bom_Val_To_Id.Bom_Component_UUI_To_UI2
    ( p_bom_component_rec  => l_bom_component_rec
    , p_bom_comp_unexp_rec => l_bom_comp_unexp_rec
    , x_bom_comp_unexp_rec => l_bom_comp_unexp_rec
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_other_message      => l_other_message
    , x_other_token_tbl    => l_other_token_tbl
    , x_Return_Status      => l_return_status
    );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_SIBLINGS;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_CMP_UUI_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_component_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;
           Bom_Globals.Set_Unit_Controlled_Item (
               p_inventory_item_id => l_bom_comp_unexp_rec.assembly_item_id,
               p_organization_id   => l_bom_comp_unexp_rec.organization_id);

     --
     -- Process Flow step 5: Verify Revised Component's existence
     --
     Bom_Validate_Bom_Component.Check_Existence
      (  p_bom_component_rec    => l_bom_component_rec
      ,  p_bom_comp_unexp_rec   => l_bom_comp_unexp_rec
    ,  x_old_bom_component_rec    => l_old_bom_component_rec
                ,  x_old_bom_comp_unexp_rec   => l_old_bom_comp_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
    l_other_message := 'BOM_CMP_EXS_SEV_ERROR';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
        l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
    l_other_token_tbl(2).token_value :=
      l_bom_component_rec.assembly_item_name;
    RAISE EXC_SEV_QUIT_BRANCH;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_CMP_EXS_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
                l_other_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                l_other_token_tbl(2).token_value :=
      l_bom_component_rec.assembly_item_name;

    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

           /* Assign the correct transaction type for SYNC operations */

           IF l_bom_component_rec.transaction_type = 'SYNC' THEN
             l_bom_component_rec.transaction_type :=
                 l_old_bom_component_rec.transaction_type;
           END IF;

     -- 5a.Check for the count of components if the current transaction is CREATE

     IF l_bom_component_rec.transaction_type = Bom_Globals.G_OPR_CREATE
     THEN
           create_rec_flag := 'Y';
       END IF;

       IF (I = l_bom_component_tbl.COUNT AND create_rec_flag='Y')
       THEN
       -- We will check for the component count only once per bill

       Bom_Validate_Bom_Component.Check_ComponentCount
      (  p_bom_component_rec          => l_bom_component_rec
       , p_bom_comp_unexp_rec   => l_bom_comp_unexp_rec
           , x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
           , x_return_status        => l_Return_Status);

       IF l_return_status = Error_Handler.G_STATUS_ERROR
       THEN
       l_other_message := 'BOM_CMP_LIN_SEV_SKIP';
       l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
       l_other_token_tbl(1).token_value :=
      l_bom_component_rec.component_item_name;
           RAISE EXC_SEV_QUIT_BRANCH;
       ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
       THEN
       l_other_message := 'BOM_CMP_LIN_UNEXP_SKIP';
       l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
       l_other_token_tbl(1).token_value :=
      l_bom_component_rec.component_item_name;
       RAISE EXC_UNEXP_SKIP_OBJECT;
       ELSIF l_return_status ='S' AND
             l_Mesg_Token_Tbl.COUNT <>0
       THEN
       Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
       Error_Handler.Log_Error
      (  p_bom_component_tbl  => l_bom_component_tbl
      ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
      ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
      ,  p_mesg_token_tbl => l_mesg_token_tbl
      ,  p_error_status => 'W'
      ,  p_error_level  => Error_Handler.G_RC_LEVEL
      ,  p_entity_index => I
      ,  x_bom_header_rec => l_bom_header_rec
      ,  x_bom_revision_tbl => l_bom_revision_tbl
      ,  x_bom_component_tbl  => l_bom_component_tbl
      ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
      ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
      );
             Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
           END IF;

     END IF;

     -- Process Flow step 6: Check lineage
     --

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Check lineage');      END IF;
     Bom_Validate_Bom_Component.Check_Lineage
      (  p_bom_component_rec    => l_bom_component_rec
      ,  p_bom_comp_unexp_rec   => l_bom_comp_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
       l_other_message := 'BOM_CMP_LIN_SEV_SKIP';
       l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
       l_other_token_tbl(1).token_value :=
      l_bom_component_rec.component_item_name;
           RAISE EXC_SEV_QUIT_BRANCH;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
       l_other_message := 'BOM_CMP_LIN_UNEXP_SKIP';
       l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
       l_other_token_tbl(1).token_value :=
      l_bom_component_rec.component_item_name;
       RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     -- Process Flow step 7: Is Revised Component record an orphan ?

     IF NOT l_item_parent_exists
     THEN
      Bom_Validate_Bom_Header.Check_Access
                ( p_assembly_item_id   => l_bom_comp_unexp_rec.assembly_item_id
                , p_organization_id    => l_bom_comp_unexp_rec.organization_id
                , p_alternate_bom_code => l_bom_component_rec.alternate_bom_code
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Return_Status      => l_return_status
                );
      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_CMP_RITACC_FAT_FATAL';
        l_other_token_tbl(1).token_name :=
        'REVISED_COMPONENT_NAME';
        l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
                        l_return_status := 'F';
      RAISE EXC_FAT_QUIT_SIBLINGS;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_CMP_RITACC_UNEXP_SKIP';
        l_other_token_tbl(1).token_name :=
        'REVISED_COMPONENT_NAME';
        l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

    --
    -- Process Flow step: Check that user has access to Bom
    -- component
    --

    Bom_Validate_Bom_Component.Check_Access
    (  p_organization_id    =>
                                l_bom_comp_unexp_rec.organization_id
                ,  p_component_item_id  =>
                                l_bom_comp_unexp_rec.component_item_id
                ,  p_component_name     =>
                                l_bom_component_rec.component_item_name
                ,  x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,  x_return_status      => l_Return_Status
                );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_CMP_ACCESS_FAT_FATAL';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
                        l_return_status := 'F';
          RAISE EXC_FAT_QUIT_BRANCH;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_CMP_ACCESS_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

     END IF;

     -- Process Flow step 9: Check and validate the direct items specific attributes
     --
     IF BOM_EAMUTIL.Enabled = 'Y' THEN --- checking if EAM is installed
     --- Check if org is eAM enabled?
    Bom_Validate_Bom_Component.Check_Direct_item_comps
    ( p_bom_component_rec       => l_bom_component_rec
    , p_bom_comp_unexp_rec      => l_bom_comp_unexp_rec
    , x_bom_component_rec       => l_bom_component_rec
    , x_Mesg_Token_Tbl          => l_Mesg_Token_Tbl
    , x_Return_Status           => l_Return_Status
    );

                /* Commented as part of bug fix 3741040
    IF l_return_status = Error_Handler.G_STATUS_ERROR --- the direct item component is being
    THEN                                              --- tried to be added to a non-EAM BOM
      Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_DIRECT_FOR_MAINT_ONLY'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
      RAISE EXC_SEV_QUIT_BRANCH;
    ELS
    */
    IF l_return_status ='S' AND
            l_Mesg_Token_Tbl.COUNT <>0
    THEN
      Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
      Error_Handler.Log_Error
      (  p_bom_component_tbl  => l_bom_component_tbl
      ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
      ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
      ,  p_mesg_token_tbl => l_mesg_token_tbl
      ,  p_error_status => 'W'
      ,  p_error_level  => Error_Handler.G_RC_LEVEL
      ,  p_entity_index => I
      ,  x_bom_header_rec => l_bom_header_rec
      ,  x_bom_revision_tbl => l_bom_revision_tbl
      ,  x_bom_component_tbl  => l_bom_component_tbl
      ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
      ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
      );
      Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    END IF;
     END IF;

     -- Process Flow step 11: Value to Id conversions
     --

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Value-id conversions'); END IF;
     Bom_Val_To_Id.Bom_Component_VID
    ( x_Return_Status       => l_return_status
    , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
    , p_bom_comp_unexp_Rec  => l_bom_comp_unexp_rec
    , x_bom_comp_unexp_Rec  => l_bom_comp_unexp_rec
    , p_bom_component_Rec   => l_bom_component_rec
    );

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        IF l_bom_component_rec.transaction_type = 'CREATE'
        THEN
      l_other_message := 'BOM_CMP_VID_CSEV_SKIP';
      l_other_token_tbl(1).token_name :=
        'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
      RAISE EXC_SEV_SKIP_BRANCH;
          ELSE
          RAISE EXC_SEV_QUIT_RECORD;
        END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_CMP_VID_UNEXP_SKIP';
    l_other_token_tbl(1).token_name :=
        'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
          l_Mesg_Token_Tbl.COUNT <>0
     THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => 'W'
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
         END IF;

     -- Process Flow step 12: Check required fields exist
     -- (also includes conditionally required fields)
     --

     Bom_Validate_Bom_Component.Check_Required
    ( x_return_status              => l_return_status
    , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
    , p_bom_component_rec          => l_bom_component_rec
      );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        IF l_bom_component_rec.transaction_type = 'CREATE'
        THEN
      l_other_message := 'BOM_CMP_REQ_CSEV_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
          l_bom_component_rec.component_item_name;
      RAISE EXC_SEV_SKIP_BRANCH;
          ELSE
          RAISE EXC_SEV_QUIT_RECORD;
        END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_CMP_REQ_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
     -- Process Flow step : Attribute Validation for CREATE and UPDATE
     --

     IF l_bom_component_rec.Transaction_Type IN
            (Bom_Globals.G_OPR_CREATE, Bom_Globals.G_OPR_UPDATE)
         THEN
    Bom_Validate_Bom_Component.Check_Attributes
    ( x_return_status              => l_return_status
    , x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
    , p_bom_component_rec          => l_bom_component_rec
    , p_bom_comp_unexp_rec         => l_bom_comp_unexp_rec
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
           IF l_bom_component_rec.transaction_type = 'CREATE'
           THEN
      l_other_message := 'BOM_CMP_ATTVAL_CSEV_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
      RAISE EXC_SEV_SKIP_BRANCH;
             ELSE
          RAISE EXC_SEV_QUIT_RECORD;
           END IF;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
       l_other_message := 'BOM_CMP_ATTVAL_UNEXP_SKIP';
       l_other_token_tbl(1).token_name :=
        'REVISED_COMPONENT_NAME';
       l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
       RAISE EXC_UNEXP_SKIP_OBJECT;
      ELSIF l_return_status ='S' AND
                l_Mesg_Token_Tbl.COUNT <>0
      THEN
             Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
       Error_Handler.Log_Error
        (  p_bom_component_tbl  => l_bom_component_tbl
        ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
        ,  p_bom_sub_component_tbl=> l_bom_sub_component_tbl
        ,  p_mesg_token_tbl => l_mesg_token_tbl
        ,  p_error_status => 'W'
        ,  p_error_level  => Error_Handler.G_RC_LEVEL
      ,  p_entity_index => I
      ,  x_bom_header_rec => l_bom_header_rec
      ,  x_bom_revision_tbl => l_bom_revision_tbl
      ,  x_bom_component_tbl  => l_bom_component_tbl
      ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
      ,  x_bom_sub_component_tbl=> l_bom_sub_component_tbl
      );
            Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    END IF;
         END IF;

            -- Process flow step - Populate NULL columns for Update and
            -- Delete, and Creates with ACD_Type 'Add'.

      IF l_bom_component_rec.transaction_type IN
    (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
            THEN
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Populate NULL columns'); END IF;
        Bom_Default_Bom_Component.Populate_Null_Columns
                    (   p_bom_component_rec     => l_bom_Component_Rec
                    ,   p_old_bom_Component_Rec => l_old_bom_Component_Rec
                    ,   p_bom_comp_unexp_rec    => l_bom_comp_unexp_rec
                    ,   p_old_bom_comp_unexp_rec=> l_old_bom_comp_unexp_rec
                    ,   x_bom_Component_Rec     => l_bom_Component_Rec
                    ,   x_bom_comp_unexp_rec    => l_bom_comp_unexp_rec
                    );

         ELSIF l_bom_component_rec.Transaction_Type = Bom_Globals.G_OPR_CREATE
     THEN

    --
          -- Process Flow step : Default missing values for Operation
    -- CREATE
    --

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Defaulting'); END IF;
          Bom_Default_Bom_Component.Attribute_Defaulting
                (   p_bom_component_rec   => l_bom_component_rec
                ,   p_bom_comp_unexp_rec  => l_bom_comp_unexp_rec
                ,   x_bom_component_rec   => l_bom_component_rec
                ,   x_bom_comp_unexp_rec  => l_bom_comp_unexp_rec
                ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                ,   x_return_status   => l_return_status
                );

          IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('return_status: ' || l_return_status); END IF;

    IF l_return_status = Error_Handler.G_STATUS_ERROR
    THEN
      l_other_message := 'BOM_CMP_ATTDEF_CSEV_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
          RAISE EXC_SEV_SKIP_BRANCH;
    ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
    THEN
      l_other_message := 'BOM_CMP_ATTDEF_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
          l_bom_component_rec.component_item_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
    ELSIF l_return_status ='S' AND
            l_Mesg_Token_Tbl.COUNT <>0
    THEN
            Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
      Error_Handler.Log_Error
      (  p_bom_component_tbl  => l_bom_component_tbl
      ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
      ,  p_bom_sub_component_tbl=> l_bom_sub_component_tbl
      ,  p_mesg_token_tbl => l_mesg_token_tbl
      ,  p_error_status => 'W'
      ,  p_error_level  => Error_Handler.G_RC_LEVEL
      ,  p_entity_index => I
      ,  x_bom_header_rec => l_bom_header_rec
      ,  x_bom_revision_tbl => l_bom_revision_tbl
      ,  x_bom_component_tbl  => l_bom_component_tbl
      ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
      ,  x_bom_sub_component_tbl=> l_bom_sub_component_tbl
      );
            Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    END IF;
     END IF;

     --
         -- Process Flow step 17: Entity defaulting for CREATE and UPDATE
         --

         IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity defaulting'); END IF;
     IF l_bom_component_rec.Transaction_Type IN
            (Bom_Globals.G_OPR_CREATE, Bom_Globals.G_OPR_UPDATE)
         THEN
    Bom_Default_Bom_Component.Entity_Defaulting
    (   p_bom_component_rec         => l_bom_component_rec
    ,   p_old_bom_component_rec     => l_old_bom_component_rec
    ,   x_bom_component_rec         => l_bom_component_rec
    );

    IF l_return_status = Error_Handler.G_STATUS_ERROR
    THEN
           IF l_bom_component_rec.transaction_type = 'CREATE'
           THEN
      l_other_message := 'BOM_CMP_ENTDEF_CSEV_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
      RAISE EXC_SEV_SKIP_BRANCH;
             ELSE
          RAISE EXC_SEV_QUIT_RECORD;
           END IF;
    ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
    THEN
      l_other_message := 'BOM_CMP_ENTDEF_UNEXP_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
      RAISE EXC_UNEXP_SKIP_OBJECT;
    ELSIF l_return_status ='S' AND
            l_Mesg_Token_Tbl.COUNT <>0
    THEN
            Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
      Error_Handler.Log_Error
      (  p_bom_component_tbl  => l_bom_component_tbl
      ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
      ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
      ,  p_mesg_token_tbl => l_mesg_token_tbl
      ,  p_error_status => 'W'
      ,  p_error_level  => Error_Handler.G_RC_LEVEL
      ,  p_entity_index => I
      ,  x_bom_header_rec => l_bom_header_rec
      ,  x_bom_revision_tbl => l_bom_revision_tbl
      ,  x_bom_component_tbl  => l_bom_component_tbl
      ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
      ,  x_bom_sub_component_tbl=> l_bom_sub_component_tbl
      );
            Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    END IF;
     END IF;

     --
         -- Process Flow step 18 - Entity Level Validation
     --
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Defaulting completed with ' || l_return_Status || ' starting with Components entity validation . . . '); END IF;

         Bom_Validate_Bom_Component.Check_Entity
          (  p_bom_component_rec      => l_bom_component_rec
          ,  p_bom_comp_unexp_rec     => l_bom_comp_unexp_rec
          ,  p_old_bom_component_rec  => l_old_bom_component_rec
          ,  p_old_bom_comp_unexp_rec   => l_old_bom_comp_unexp_rec
          ,  x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
      ,  x_return_status          => l_Return_Status
          );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        IF l_bom_component_rec.transaction_type = 'CREATE'
        THEN
      l_other_message := 'BOM_CMP_ENTVAL_CSEV_SKIP';
      l_other_token_tbl(1).token_name :=
          'REVISED_COMPONENT_NAME';
      l_other_token_tbl(1).token_value :=
          l_bom_component_rec.component_item_name;
      RAISE EXC_SEV_SKIP_BRANCH;
          ELSE
          RAISE EXC_SEV_QUIT_RECORD;
        END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_CMP_ENTVAL_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_component_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
          l_Mesg_Token_Tbl.COUNT <>0
     THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => 'W'
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
         END IF;
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity validation completed with ' || l_return_Status || ' proceeding for database writes . . . '); END IF;

     --
         -- Process Flow step 16 : Database Writes
     --
         Bom_Bom_Component_Util.Perform_Writes
          (   p_bom_component_rec         => l_bom_component_rec
          ,   p_bom_comp_unexp_rec      => l_bom_comp_unexp_rec
          ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
          ,   x_return_status       => l_return_status
          );

     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_CMP_WRITES_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
    l_other_token_tbl(1).token_value :=
        l_bom_component_rec.component_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
        l_Mesg_Token_Tbl.COUNT <>0
     THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => 'W'
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
         END IF;

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Database writes completed with status. . . ' || l_return_status); END IF;

        END IF; -- END IF statement that checks RETURN STATUS

        --  Load tables.

        l_bom_component_tbl(I)          := l_bom_component_rec;

  -- Indicate that children need to be processed

  l_process_children := TRUE;

    --  For loop exception handler.


    EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => FND_API.G_RET_STS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_RECORD
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  l_process_children := TRUE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_CHILDREN
    ,  p_other_status => Error_Handler.G_STATUS_ERROR
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_SEV_SKIP_BRANCH THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_CHILDREN
    ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_SEV_QUIT_SIBLINGS THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status => Error_Handler.G_STATUS_ERROR
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        l_process_children := FALSE;

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_FAT_QUIT_BRANCH THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_CHILDREN
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        l_process_children := FALSE;

        x_return_status                := Error_Handler.G_STATUS_FATAL;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_FAT_QUIT_SIBLINGS THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_SIBLINGS
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        l_process_children := FALSE;

        x_return_status                := Error_Handler.G_STATUS_FATAL;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_FAT_QUIT_OBJECT THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_ALL
    ,  p_other_status       => Error_Handler.G_STATUS_FATAL
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

  l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_UNEXPECTED
    ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_RC_LEVEL
    ,  x_bom_header_rec     => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl           := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl            := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;

  l_return_status := 'U';

        END; -- END block

  IF l_return_status in ('Q', 'U')
      THEN
          x_return_status := l_return_status;
          RETURN;
      END IF;

  --4306013
  IF( l_bom_component_tbl(I).transaction_type in ( Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_CREATE )
      AND l_return_status = 'S')
  THEN
    G_Comp_Flag := 1;
  END IF;

   IF l_process_children
   THEN
IF Bom_Globals.Get_Debug = 'Y' THEN
  Error_Handler.Write_Debug('Component processing completed, process_child true so proceeding with ref desg and then sub comps. . . ' || l_return_status); END IF;

  -- Process Reference Designators that are direct children of this
      -- component

      Reference_Designators
  (   p_validation_level      => p_validation_level
  ,   p_organization_id => l_bom_comp_unexp_rec.organization_id
  ,   p_assembly_item_name=> l_bom_component_rec.assembly_item_name
  ,   p_effectivity_date  => l_bom_component_rec.start_effective_date
  ,   p_component_item_name=> l_bom_component_rec.component_item_name
  ,   p_operation_seq_num => l_bom_component_rec.operation_sequence_number
  ,   p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
  ,   p_bom_sub_component_tbl=> l_bom_sub_component_tbl
  ,   x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
  ,   x_bom_sub_component_tbl=> l_bom_sub_component_tbl
  ,   x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
  ,   x_return_status => l_return_status
  );

      -- Check the quantity related validations.
      Bom_Validate_Ref_Designator.check_quantity
        ( x_return_status         => l_return_status
        , x_mesg_token_tbl        => l_Mesg_Token_Tbl
        , p_component_sequence_id => l_bom_comp_unexp_rec.component_sequence_id
        , p_component_item_name   => l_bom_component_rec.component_item_name
        );
      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
        Error_Handler.Log_Error
        (  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
        ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
        ,  p_mesg_token_tbl => l_mesg_token_tbl
        ,  p_error_status => Error_Handler.G_STATUS_WARNING
        ,  p_error_scope  => Error_Handler.G_SCOPE_RECORD
        ,  p_error_level  => Error_Handler.G_RC_LEVEL
        ,  p_entity_index => I
        ,  x_bom_header_rec => l_bom_header_rec
        ,  x_bom_revision_tbl => l_bom_revision_tbl
        ,  x_bom_component_tbl  => l_bom_component_tbl
        ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
        ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
        );
      END IF;

    -- Process Substitute Components that are direct children of this
      -- component

  Substitute_Components
      (   p_validation_level  => p_validation_level
  ,   p_organization_id => l_bom_comp_unexp_rec.organization_id
  ,   p_assembly_item_name=> l_bom_component_rec.assembly_item_name
  ,   p_effectivity_date  => l_bom_component_rec.start_effective_date
  ,   p_component_item_name=> l_bom_component_rec.component_item_name
  ,   p_operation_seq_num => l_bom_component_rec.operation_sequence_number
  ,   p_bom_sub_component_tbl=> l_bom_sub_component_tbl
  ,   x_bom_sub_component_tbl=> l_bom_sub_component_tbl
  ,   x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
  ,   x_return_status => l_return_status
  );

    -- Process Component Operations that are direct children of this
      -- component

  Component_Operations
      (   p_validation_level  => p_validation_level
  ,   p_organization_id => l_bom_comp_unexp_rec.organization_id
  ,   p_assembly_item_name=> l_bom_component_rec.assembly_item_name
  ,   p_effectivity_date  => l_bom_component_rec.start_effective_date
  ,   p_component_item_name=> l_bom_component_rec.component_item_name
  ,   p_operation_seq_num => l_bom_component_rec.operation_sequence_number
  ,   p_bom_comp_ops_tbl=> l_bom_comp_ops_tbl
  ,   x_bom_comp_ops_tbl=> l_bom_comp_ops_tbl
  ,   x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
  ,   x_return_status => l_return_status
  );

    END IF;  -- Process children

    END LOOP; -- END Revised Components processing loop

    --  Load out parameters

     IF NVL(l_return_status, 'S') <> 'S'
     THEN
      x_return_status     := l_return_status;
     END IF;

    /*********Business Event************/
     IF ( G_Comp_Flag = 1 and (Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO)
         AND  l_comps_processed
     ) THEN
       Bom_Business_Event_PKG.Raise_Bill_Event(
        p_event_load_type          => 'Bulk'
      , p_request_identifier      => FND_GLOBAL.CONC_REQUEST_ID
      , p_batch_identifier        => BOM_GLOBALS.G_BATCH_ID
      , p_event_entity_name       => 'Component'
      , p_event_name              => Bom_Business_Event_PKG.G_STRUCTURE_MODIFIED_EVENT
      , p_last_update_date        => sysdate
      , p_last_updated_by         => fnd_global.user_id
      );
      END IF;
      G_Comp_Flag := 0;
     /*********Business Event************/

     x_bom_component_tbl        := l_bom_component_tbl;
     x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
     x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
     x_bom_comp_ops_tbl         := l_bom_comp_ops_tbl;
     x_Mesg_Token_Tbl     := l_Mesg_Token_Tbl;
END Bom_Components;


/****************************************************************************
* Procedure : Bom_Revisions
* Parameters IN : BOM Revision Table and all the other entities
* Parameters OUT: BOM Revision Table and all the other entities
* Purpose : This procedure will process all the BOM revision records.
*     Although the other entities are not children of this entity
*     the are taken as parameters so that the error handler could
*     set the records to appropriate status if a fatal or severity
*     1 error occurs.
*****************************************************************************/
PROCEDURE Bom_Revisions
(   p_validation_level     IN  NUMBER
 ,  p_assembly_item_name   IN  VARCHAR2   := NULL
 ,  p_assembly_item_id     IN  NUMBER := NULL
 ,  p_organization_id      IN  NUMBER := NULL
 ,  p_alternate_bom_code   IN  VARCHAR2 := NULL
 ,  p_bom_revision_tbl     IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type
 ,  p_bom_component_tbl    IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type
 ,  p_bom_ref_designator_tbl   IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
 ,  p_bom_sub_component_tbl  IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
 ,  p_bom_comp_ops_tbl           IN  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
 ,  x_bom_revision_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
 ,  x_bom_component_tbl    IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
 ,  x_bom_ref_designator_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
 ,  x_bom_sub_component_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
 ,  x_bom_comp_ops_tbl           IN OUT NOCOPY  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
 ,  x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status    IN OUT NOCOPY VARCHAR2
 )
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_valid     BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1);
l_bo_return_status  VARCHAR2(1);
l_bom_parent_exists BOOLEAN := FALSE;

l_bom_header_rec  Bom_Bo_Pub.Bom_Head_Rec_Type;
l_bom_header_unexp_rec  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type;
l_old_bom_header_rec  Bom_Bo_Pub.Bom_Head_Rec_Type;
l_old_bom_header_unexp_rec Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type;

l_bom_revision_rec      Bom_Bo_Pub.Bom_Revision_Rec_Type;
l_bom_revision_tbl      Bom_Bo_Pub.Bom_Revision_Tbl_Type := p_bom_revision_tbl;
l_bom_rev_unexp_rec   Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type;
l_old_bom_revision_rec  Bom_Bo_Pub.Bom_Revision_Rec_Type := NULL;
l_old_bom_rev_unexp_rec Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type := NULL;

l_bom_component_tbl     Bom_Bo_Pub.Bom_Comps_Tbl_Type := p_bom_component_tbl;
l_bom_ref_designator_tbl Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
          := p_bom_ref_designator_tbl;
l_bom_sub_component_tbl     Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
          := p_bom_sub_component_tbl;
l_bom_comp_ops_tbl      Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
          := p_bom_comp_ops_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

BEGIN


    l_return_status := 'S';
    l_bo_return_status := 'S';

    --  Init local table variables.

    l_bom_revision_tbl             := p_bom_revision_tbl;

    l_bom_rev_unexp_rec.organization_id := Bom_Globals.Get_org_id;

    FOR I IN 1..l_bom_revision_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_bom_revision_rec := l_bom_revision_tbl(I);

        l_bom_revision_rec.transaction_type :=
          UPPER(l_bom_revision_rec.transaction_type);

        IF p_assembly_item_name IS NOT NULL AND
           p_organization_id IS NOT NULL
        THEN
          l_bom_parent_exists := TRUE;
        END IF;

  --
      -- Process Flow Step 2: Check if record has not yet been processed and
      -- that it is the child of the parent that called this procedure
      --

      IF (l_bom_revision_rec.return_status IS NULL OR
          l_bom_revision_rec.return_status = FND_API.G_MISS_CHAR)
         AND
         (NOT l_bom_parent_exists
          OR
          (l_bom_parent_exists AND
        ( l_bom_revision_rec.assembly_item_name = p_assembly_item_name AND
          l_bom_rev_unexp_rec.organization_id = p_organization_id AND
    NVL(l_bom_revision_rec.alternate_bom_code, 'NONE') =
    NVL(p_alternate_bom_code, 'NONE')
         )
       )
      )
      THEN

         l_return_status := FND_API.G_RET_STS_SUCCESS;

           l_bom_revision_rec.return_status := FND_API.G_RET_STS_SUCCESS;

     --
     -- Check if transaction_type is valid
     --

     Bom_Globals.Transaction_Type_Validity
     (   p_transaction_type   => l_bom_revision_rec.transaction_type
     ,   p_entity     => 'Bom_Rev'
     ,   p_entity_id    => l_bom_revision_rec.revision
     ,   x_valid      => l_valid
     ,   x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
     );

     IF NOT l_valid
     THEN
                l_return_status := Error_Handler.G_STATUS_ERROR;
        RAISE EXC_SEV_QUIT_RECORD;
     END IF;

     --
     -- Process Flow step 4: Verify that Revision is not NULL or MISSING
     --
     Bom_Validate_Bom_Revision.Check_Required
    (  x_return_status    => l_return_status
    ,  p_bom_revision_rec   => l_bom_revision_rec
    ,  x_mesg_token_tbl   => l_Mesg_Token_Tbl
    );

           IF l_return_status = Error_Handler.G_STATUS_ERROR
           THEN
                RAISE EXC_SEV_QUIT_RECORD;
           ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
    l_other_message := 'BOM_REV_KEYCOL_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_bom_revision_rec.revision;
                RAISE EXC_UNEXP_SKIP_OBJECT;
     END IF;


     --
     -- Process Flow Step: 5 Convert User Unique Index
     --
     Bom_Val_To_Id.Bom_Revision_UUI_To_UI2
     (  p_bom_revision_rec  => l_bom_revision_rec
      , p_bom_rev_unexp_rec => l_bom_rev_unexp_rec
      , x_bom_rev_unexp_rec => l_bom_rev_unexp_rec
      , x_mesg_token_tbl    => l_mesg_token_tbl
      , x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
    l_other_message := 'BOM_REV_UUI_SEV_ERROR';
    l_other_token_tbl(1).token_name := 'REVISION';
    l_other_token_tbl(1).token_value := l_bom_revision_rec.revision;
    l_other_token_tbl(2).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(2).token_value := l_bom_revision_rec.assembly_item_name;
    RAISE EXC_SEV_QUIT_OBJECT;
            ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
            THEN
                 l_other_message := 'BOM_REV_UUI_UNEXP_SKIP';
                 l_other_token_tbl(1).token_name := 'REVISION';
                 l_other_token_tbl(1).token_value :=
                      l_bom_revision_rec.revision;
                 RAISE EXC_UNEXP_SKIP_OBJECT;
      END IF;

           -- Verify Bom Header's existence in database.
     -- If revision is being created and the business object does not
     -- carry the BOM header, then it is imperative to check for the
     -- BOM Header's existence

           IF l_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE
              AND
              NOT l_bom_parent_exists
           THEN
    l_bom_header_rec.alternate_bom_code := p_alternate_bom_code;
    l_bom_header_unexp_rec.organization_id := p_organization_id;
    l_bom_header_unexp_rec.assembly_item_id := p_assembly_item_id;
    l_bom_header_rec.transaction_type := 'XXX';

                Bom_Validate_Bom_Header.Check_Existence
    ( p_bom_header_rec  => l_bom_header_rec
    , p_bom_head_unexp_rec  => l_bom_header_unexp_rec
                , x_old_bom_header_rec  => l_old_bom_header_rec
                , x_old_bom_head_unexp_rec=> l_old_bom_header_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
                );
                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                   l_other_message := 'BOM_BOM_HEADER_NOT_EXIST';
                   l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                   l_other_token_tbl(1).token_value :=
          l_bom_revision_rec.assembly_item_name;
                   l_other_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                   l_other_token_tbl(2).token_value :=
          l_bom_revision_rec.organization_code;
                   RAISE EXC_SEV_QUIT_OBJECT;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                   l_other_message := 'BOM_REV_LIN_UNEXP_SKIP';
                   l_other_token_tbl(1).token_name := 'REVISION';
                   l_other_token_tbl(1).token_value :=
            l_bom_revision_rec.revision;
                   RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
           END IF;

           /* Assign the correct transaction type for SYNC operations */

           IF l_bom_header_rec.transaction_type = 'SYNC' THEN
             l_bom_header_rec.transaction_type :=
                 l_old_bom_header_rec.transaction_type;
           END IF;

     --
     -- Process Flow step 5: Verify Revision's existence
     --
     Bom_Validate_Bom_Revision.Check_Existence
      (  p_bom_revision_rec     => l_bom_revision_rec
      ,  p_bom_rev_unexp_rec    => l_bom_rev_unexp_rec
    ,  x_old_bom_revision_rec     => l_old_bom_revision_rec
                ,  x_old_bom_rev_unexp_rec  => l_old_bom_rev_unexp_rec
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  x_return_status        => l_Return_Status
      );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
                l_other_message := 'BOM_REV_EXS_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'REVISION';
                l_other_token_tbl(1).token_value := l_bom_revision_rec.revision;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

           /* Assign the correct transaction type for SYNC operations */

           IF l_bom_revision_rec.transaction_type = 'SYNC' THEN
             l_bom_revision_rec.transaction_type :=
                 l_old_bom_revision_rec.transaction_type;
           END IF;


     -- Process Flow step 5: Is Revision record an orphan ?

     IF NOT l_bom_parent_exists
     THEN

    Bom_Validate_Bom_Header.Check_Access
    ( p_assembly_item_id  => l_bom_rev_unexp_rec.assembly_item_id
    , p_organization_id => l_bom_rev_unexp_rec.organization_id
    , p_alternate_bom_code  => l_bom_revision_rec.alternate_bom_code
    , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
    , x_Return_Status       => l_return_status
    );

      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      l_other_message := 'BOM_REV_BOMACC_FAT_FATAL';
      l_other_token_tbl(1).token_name := 'REVISION';
      l_other_token_tbl(1).token_value :=
            l_bom_revision_rec.revision;
                        l_return_status := 'F';
          RAISE EXC_FAT_QUIT_OBJECT;
      ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
      THEN
      l_other_message := 'BOM_REV_ACCESS_UNEXP_ERROR';
      l_other_token_tbl(1).token_name := 'REVISION';
      l_other_token_tbl(1).token_value :=
            l_bom_revision_rec.revision;
      RAISE EXC_UNEXP_SKIP_OBJECT;
          END IF;

     END IF;

     IF l_bom_revision_rec.Transaction_Type IN
            (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
         THEN

          -- Process flow step 7 - Populate NULL columns for Update and
          -- Delete.

    Bom_Default_Bom_Revision.Populate_NULL_Columns
                (   p_bom_revision_rec    => l_bom_revision_rec
                ,   p_bom_rev_unexp_rec   => l_bom_rev_unexp_rec
                ,   p_old_bom_revision_rec    => l_old_bom_revision_rec
                ,   p_old_bom_rev_unexp_rec   => l_old_bom_rev_unexp_rec
                ,   x_bom_revision_rec    => l_bom_revision_rec
                ,   x_bom_rev_unexp_rec   => l_bom_rev_unexp_rec
                );

         ELSIF l_bom_revision_rec.Transaction_Type = Bom_Globals.G_OPR_CREATE
     THEN

    --
          -- Process Flow step 8: Default missing values for Operation
    -- CREATE
    --
      NULL;
    /*
    ** There is not attribute defualting for BOM Revisions
    */

     END IF;

     --
         -- Process Flow step 10 - Entity Level Validation
     --

         Bom_Validate_Bom_Revision.Check_Entity
          (  x_return_status        => l_Return_Status
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  p_bom_revision_rec     => l_bom_revision_rec
          ,  p_bom_rev_unexp_rec    => l_bom_rev_unexp_rec
    ,  p_old_bom_revision_rec => l_old_bom_revision_rec
    ,  p_old_bom_rev_unexp_rec=> l_old_bom_rev_unexp_rec
          );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
        RAISE EXC_SEV_QUIT_RECORD;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_REV_ENTVAL_UNEXP_ERROR';
    l_other_token_tbl(1).token_name := 'REVISION';
    l_other_token_tbl(1).token_value := l_bom_revision_rec.revision;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

     --
         -- Process Flow step 11 : Database Writes
     --
         Bom_Bom_Revision_Util.Perform_Writes
          (   p_bom_revision_rec          => l_bom_revision_rec
          ,   p_bom_rev_unexp_rec     => l_bom_rev_unexp_rec
          ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
          ,   x_return_status       => l_return_status
          );

     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
    l_other_message := 'BOM_REV_WRITES_UNEXP_ERROR';
    l_other_token_tbl(1).token_name := 'REVISION';
    l_other_token_tbl(1).token_value := l_bom_revision_rec.revision;
    RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        END IF;
  -- End IF that checks RETURN STATUS AND PARENT-CHILD RELATIONSHIP

        --  Load tables.

        l_bom_revision_tbl(I)          := l_bom_revision_rec;

        --  For loop exception handler.
     EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_revision_tbl => l_bom_revision_tbl
    ,  p_bom_component_tbl  => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => FND_API.G_RET_STS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_RECORD
    ,  p_error_level  => Error_Handler.G_REV_LEVEL
    ,  p_entity_index => I
    ,  x_bom_header_rec => l_bom_header_rec
    ,  x_bom_revision_tbl => l_bom_revision_tbl
    ,  x_bom_component_tbl  => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);


        IF l_bo_return_status = 'S'
  THEN
    l_bo_return_status     := l_return_status;
  END IF;
  x_return_status          := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_revision_tbl             := l_bom_revision_tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

        WHEN EXC_SEV_QUIT_OBJECT THEN

            Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
            Error_Handler.Log_Error
            (  p_bom_revision_tbl     => l_bom_revision_tbl
             , p_bom_component_tbl      => l_bom_component_tbl
             , p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
             , p_bom_sub_component_tbl  => l_bom_sub_component_tbl
             , p_mesg_token_tbl       => l_mesg_token_tbl
             , p_error_status           => Error_Handler.G_STATUS_ERROR
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             --, p_error_level            => Error_Handler.G_BO_LEVEL
             , p_error_level            => Error_Handler.G_REV_LEVEL	-- BUG 5368107
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_ERROR
             , p_other_token_tbl        => l_other_token_tbl
             , x_bom_header_rec         => l_bom_header_rec
             , x_bom_revision_tbl       => l_bom_revision_tbl
             , x_bom_component_tbl      => l_bom_component_tbl
             , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
             , x_bom_sub_component_tbl  => l_bom_sub_component_tbl
             );
            Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_bom_revision_tbl             := l_bom_revision_tbl;
        x_bom_component_tbl            := l_bom_component_tbl;
        x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_FAT_QUIT_OBJECT THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
            (  p_bom_revision_tbl       => l_bom_revision_tbl
             , p_bom_component_tbl      => l_bom_component_tbl
             , p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
             , p_bom_sub_component_tbl  => l_bom_sub_component_tbl
       , p_mesg_token_tbl         => l_mesg_token_tbl
             , p_error_status           => Error_Handler.G_STATUS_FATAL
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_REV_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_FATAL
             , p_other_token_tbl        => l_other_token_tbl
             , x_bom_header_rec         => l_bom_header_rec
             , x_bom_revision_tbl       => l_bom_revision_tbl
             , x_bom_component_tbl      => l_bom_component_tbl
             , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
             , x_bom_sub_component_tbl  => l_bom_sub_component_tbl
             );
            Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_revision_tbl             := l_bom_revision_tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

  l_return_status := 'Q';

       WHEN EXC_UNEXP_SKIP_OBJECT THEN

            Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
            Error_Handler.Log_Error
            (  p_bom_revision_tbl       => l_bom_revision_tbl
             , p_bom_component_tbl      => l_bom_component_tbl
             , p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
             , p_bom_sub_component_tbl  => l_bom_sub_component_tbl
             , p_mesg_token_tbl         => l_mesg_token_tbl
       , p_error_status           => Error_Handler.G_STATUS_UNEXPECTED
             , p_error_scope            => Error_Handler.G_SCOPE_ALL
             , p_error_level            => Error_Handler.G_REV_LEVEL
             , p_other_message          => l_other_message
             , p_other_status           => Error_Handler.G_STATUS_NOT_PICKED
             , p_other_token_tbl        => l_other_token_tbl
             , x_bom_header_rec         => l_bom_header_rec
             , x_bom_revision_tbl       => l_bom_revision_tbl
             , x_bom_component_tbl      => l_bom_component_tbl
             , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
             , x_bom_sub_component_tbl  => l_bom_sub_component_tbl
             );
             Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_revision_tbl             := l_bom_revision_tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

  l_return_status := 'U';

        END; -- END block

     END LOOP; -- END Revisions processing loop

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

     --  Load out parameters

     x_return_status          := l_bo_return_status;
     x_bom_revision_tbl         := l_bom_revision_tbl;
     x_bom_component_tbl        := l_bom_component_tbl;
     x_bom_ref_designator_tbl   := l_bom_ref_designator_tbl;
     x_bom_sub_component_tbl    := l_bom_sub_component_tbl;
     x_bom_comp_ops_tbl         := l_bom_comp_ops_tbl;
     x_Mesg_Token_Tbl     := l_Mesg_Token_Tbl;

END Bom_Revisions;

/***************************************************************************
* Procedure : Bom_Header (Unexposed)
* Parameters IN : Bom Header Record and all the child entities
* Parameters OUT: Bom Header Record and all the child entities
* Purpose : This procedure will validate and perform the appropriate
*     action on the BOM Header record.
*     It will process the entities that are children of this header.
***************************************************************************/

PROCEDURE Bom_Header
(   p_validation_level              IN  NUMBER
,   p_bom_header_rec                IN  Bom_Bo_Pub.Bom_Head_Rec_Type
,   p_bom_revision_tbl        IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type
,   p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type
,   p_bom_ref_designator_tbl      IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   p_bom_sub_component_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   p_bom_comp_ops_tbl              IN  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
,   x_bom_header_rec                IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
,   x_bom_revision_tbl              IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
,   x_bom_component_tbl             IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
,   x_bom_ref_designator_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   x_bom_sub_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_bom_comp_ops_tbl              IN OUT NOCOPY  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
,   x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status       IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid     BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status  VARCHAR2(1) := 'S';

l_bom_header_rec        Bom_Bo_Pub.Bom_Head_Rec_Type;
l_old_bom_header_rec  Bom_Bo_Pub.Bom_Head_Rec_Type;
l_old_bom_header_unexp_rec Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type;
l_bom_header_Unexp_Rec  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type;

l_bom_revision_tbl      Bom_Bo_Pub.Bom_Revision_Tbl_Type := p_bom_revision_tbl;
l_bom_component_tbl     Bom_Bo_Pub.Bom_Comps_Tbl_Type := p_bom_component_tbl;
l_bom_ref_designator_tbl    Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type :=
        p_bom_ref_designator_tbl;
l_bom_sub_component_tbl     Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
        p_bom_sub_component_tbl;
l_bom_comp_ops_tbl      Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type :=
        p_bom_comp_ops_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

BEGIN

  -- Begin block that processes header.
  -- This block holds the exception handlers for header errors.

    BEGIN

      --  Load entity and record-specific details into system_information
  -- record

      l_bom_header_Unexp_rec.organization_id := Bom_Globals.Get_Org_Id;


      l_bom_header_rec := p_bom_header_rec;
        l_bom_header_rec.transaction_type :=
        UPPER(l_bom_header_rec.transaction_type);

        -- Process Flow Step 2: Check if record has not yet been processed
        --

        IF l_bom_header_rec.return_status IS NOT NULL AND
           l_bom_header_rec.return_status <> FND_API.G_MISS_CHAR
        THEN
                x_return_status                := l_return_status;
                x_bom_header_rec               := l_bom_header_rec;
                x_bom_revision_tbl             := l_bom_revision_tbl;
                x_bom_component_tbl            := l_bom_component_tbl;
                x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
                x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
                RETURN;
        END IF;

        l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_bom_header_rec.return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Process Flow Step 3: Check if transaction_type is valid
  --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header: Transaction Type Validity . . . '); END IF;

  Bom_Globals.Transaction_Type_Validity
  (   p_transaction_type  => l_bom_header_rec.transaction_type
  ,   p_entity    => 'Bom_Header'
  ,   p_entity_id   => l_bom_header_rec.assembly_item_name
  ,   x_valid   => l_valid
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
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header: UUI-"UI Conversion . . .'); END IF;

  Bom_Val_To_Id.BOM_Header_UUI_To_UI
  (  p_bom_header_rec   => l_bom_header_rec
   , p_bom_header_unexp_rec => l_bom_header_unexp_rec
   , x_bom_header_unexp_rec => l_bom_header_unexp_rec
   , x_return_status    => l_return_status
   , x_mesg_token_tbl   => l_mesg_token_tbl
  );
        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'BOM_BOM_UUI_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_bom_header_rec.assembly_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'BOM_BOM_UUI_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_bom_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

  --
      -- Process Flow step 5: Verify Bom Header's existence
      --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header: Check Existence . . .'); END IF;

      Bom_Validate_Bom_Header.Check_Existence
        (   p_bom_header_rec  => l_bom_header_rec
    , p_bom_head_unexp_rec=> l_bom_header_unexp_rec
    , x_old_bom_header_rec  => l_old_bom_header_rec
    , x_old_bom_head_unexp_rec=> l_old_bom_header_unexp_rec
                , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                , x_return_status => l_Return_Status
                );

  IF l_return_status = Error_Handler.G_STATUS_ERROR
  THEN
    l_other_message := 'BOM_BOM_EXS_SEV_ERROR';
    l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
    RAISE EXC_SEV_QUIT_BRANCH;
  ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
  THEN
    l_other_message := 'BOM_BOM_EXS_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
  END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_bom_header_rec.transaction_type = 'SYNC' THEN
          l_bom_header_rec.transaction_type :=
                 l_old_bom_header_rec.transaction_type;
        END IF;


  --
  -- Process Flow Step:6 Check Access to the Bill Item's Bom Item Type
  --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header: Check Access . . .'); END IF;

  Bom_Validate_Bom_Header.Check_Access
  (  p_assembly_item_id => l_bom_header_unexp_rec.assembly_item_id
   , p_alternate_bom_code => l_bom_header_rec.alternate_bom_code
   , p_organization_id  => l_bom_header_unexp_rec.organization_id
   , p_mesg_token_tbl => l_mesg_token_tbl
   , x_mesg_token_tbl => l_mesg_token_tbl
   , x_return_status  => l_return_status
   );
        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                l_other_message := 'BOM_BOM_ACC_SEV_ERROR';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_bom_header_rec.assembly_item_name;
                RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'BOM_BOM_ACC_UNEXP_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_bom_header_rec.assembly_item_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

  --
  -- Process Flow Step: 7 Value to ID Conversion
  --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header: Value-Id Conversion . . .'); END IF;
      Bom_Val_To_Id.Bom_Header_VID
        (  x_Return_Status    => l_return_status
        ,  x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
        ,  p_bom_header_rec   => l_bom_header_rec
        ,  p_bom_head_unexp_rec  => l_bom_header_unexp_rec
        ,  x_bom_head_unexp_rec  => l_bom_header_unexp_rec
        );
  IF l_return_status = Error_Handler.G_STATUS_ERROR
  THEN
      IF l_bom_header_rec.transaction_type = 'CREATE'
      THEN
    l_other_message := 'BOM_BOM_VID_CSEV_SKIP';
    l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
    RAISE EXC_SEV_SKIP_BRANCH;
      ELSE
        RAISE EXC_SEV_QUIT_RECORD;
      END IF;
  ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
  THEN
    l_other_message := 'BOM_BOM_VID_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
  ELSIF l_return_status ='S' AND
        l_Mesg_Token_Tbl.COUNT <>0
  THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_header_rec   => l_bom_header_rec
    ,  p_bom_revision_tbl   => l_bom_revision_tbl
    ,  p_bom_component_tbl    => l_bom_component_tbl
    ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl   => l_mesg_token_tbl
    ,  p_error_status   => 'W'
    ,  p_error_level    => Error_Handler.G_BH_LEVEL
    ,  x_bom_header_rec   => l_bom_header_rec
    ,  x_bom_revision_tbl   => l_bom_revision_tbl
    ,  x_bom_component_tbl    => l_bom_component_tbl
    ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
    ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
  END IF;

  --
      -- Process Flow step 8: Attribute Validation for Create and Update
      --

      IF l_bom_header_rec.transaction_type IN
        (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_CREATE)
      THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header: Check Attributes . . .'); END IF;

          Bom_Validate_Bom_Header.Check_Attributes
                (   x_return_status            => l_return_status
                ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
                ,   p_bom_header_rec           => l_bom_header_rec
                ,   p_bom_head_unexp_rec     => l_bom_header_unexp_rec
                ,   p_old_bom_header_rec       => l_Old_bom_header_rec
                ,   p_old_bom_head_unexp_rec => l_Old_bom_header_unexp_rec
                );

    IF l_return_status = Error_Handler.G_STATUS_ERROR
    THEN
          IF l_bom_header_rec.transaction_type = 'CREATE'
          THEN
        l_other_message := 'BOM_BOM_ATTVAL_CSEV_SKIP';
        l_other_token_tbl(1).token_name
            := 'ASSEMBLY_ITEM_NAME';
        l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
        RAISE EXC_SEV_SKIP_BRANCH;
          ELSE
            RAISE EXC_SEV_QUIT_RECORD;
          END IF;
    ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
    THEN
      l_other_message := 'BOM_BOM_ATTVAL_UNEXP_SKIP';
      l_other_token_tbl(1).token_name
        := 'ASSEMBLY_ITEM_NAME';
      l_other_token_tbl(1).token_value
        := l_bom_header_rec.assembly_item_name;

      RAISE EXC_UNEXP_SKIP_OBJECT;
    ELSIF l_return_status ='S' AND
            l_Mesg_Token_Tbl.COUNT <>0
    THEN
            Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
      Error_Handler.Log_Error
                   (  p_bom_header_rec        => l_bom_header_rec
                   ,  p_bom_revision_tbl      => l_bom_revision_tbl
                   ,  p_bom_component_tbl     => l_bom_component_tbl
                   ,  p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                   ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
                   ,  p_mesg_token_tbl        => l_mesg_token_tbl
                   ,  p_error_status          => 'W'
                   ,  p_error_level           => Error_Handler.G_BH_LEVEL
                   ,  x_bom_header_rec        => l_bom_header_rec
                   ,  x_bom_revision_tbl      => l_bom_revision_tbl
                   ,  x_bom_component_tbl     => l_bom_component_tbl
                   ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                   ,  x_bom_sub_component_tbl => l_bom_sub_component_tbl
                   );
            Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    END IF;
      END IF;

  --
  -- Process Flow Step:9
  -- If the Transaction Type is Update/Delete, then Populate_Null_Columns
  -- Else Attribute_Defaulting
  --
      IF l_bom_header_rec.Transaction_Type IN
           (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
      THEN

   --
         -- Process flow step 9 - Populate NULL columns for Update and
         -- Delete.
   --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header:  Populate Null Columns . . .'); END IF;

          Bom_Default_Bom_Header.Populate_NULL_Columns
                (   p_bom_header_rec      => l_bom_header_rec
                ,   p_bom_head_unexp_rec  => l_bom_header_unexp_rec
                ,   p_Old_bom_header_rec  => l_Old_bom_header_rec
                ,   p_Old_bom_head_unexp_rec  => l_Old_bom_header_unexp_rec
                ,   x_bom_header_rec    => l_bom_header_rec
                ,   x_bom_head_unexp_rec  => l_bom_header_unexp_rec
                );

     ELSIF l_bom_header_rec.Transaction_Type = Bom_Globals.G_OPR_CREATE THEN

   --
         -- Process Flow step 9: Default missing values for Operation CREATE
   --

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bom Header: Attribute Defaulting . . .'); END IF;

          Bom_Default_Bom_Header.Attribute_Defaulting
                (   p_bom_header_rec      => l_bom_header_rec
                ,   p_bom_head_unexp_rec  => l_bom_header_unexp_rec
                ,   x_bom_header_rec      => l_bom_header_rec
                ,   x_bom_head_unexp_rec  => l_bom_header_unexp_rec
                ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                ,   x_return_status       => l_Return_Status
                );

  IF l_return_status = Error_Handler.G_STATUS_ERROR
  THEN
      IF l_bom_header_rec.transaction_type = 'CREATE'
      THEN
    l_other_message := 'BOM_BOM_ATTDEF_CSEV_SKIP';
    l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
    RAISE EXC_SEV_SKIP_BRANCH;
      ELSE
        RAISE EXC_SEV_QUIT_RECORD;
      END IF;
  ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
  THEN
    l_other_message := 'BOM_BOM_ATTDEF_UNEXP_SKIP';
    l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
    RAISE EXC_UNEXP_SKIP_OBJECT;
  ELSIF l_return_status ='S' AND
        l_Mesg_Token_Tbl.COUNT <>0
  THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
                (  p_bom_header_rec        => l_bom_header_rec
                ,  p_bom_revision_tbl      => l_bom_revision_tbl
                ,  p_bom_component_tbl     => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec        => l_bom_header_rec
                ,  x_bom_revision_tbl      => l_bom_revision_tbl
                ,  x_bom_component_tbl     => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl => l_bom_sub_component_tbl
                );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
  END IF;
     END IF;

  --
  -- Process Flow step 10 - Check Conditionally Required Fields
  --

      Bom_Validate_Bom_Header.Check_Required
        (   x_return_status       => l_return_status
        ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
        ,   p_bom_header_rec      => l_bom_header_rec
  );

     IF l_return_status = Error_Handler.G_STATUS_ERROR
     THEN
  IF l_bom_header_rec.transaction_type = Bom_Globals.G_OPR_CREATE
  THEN
    l_other_message := 'BOM_BOM_CONREQ_CSEV_SKIP';
    l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
    l_other_token_tbl(1).token_value :=
          l_bom_header_rec.assembly_item_name;
    RAISE EXC_SEV_SKIP_BRANCH;
        ELSE
        RAISE EXC_SEV_QUIT_RECORD;
  END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
  l_other_message := 'BOM_BOM_CONREQ_UNEXP_SKIP';
  l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
  l_other_token_tbl(1).token_value := l_bom_header_rec.assembly_item_name;
  RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
     l_Mesg_Token_Tbl.COUNT <>0
     THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_header_rec        => l_bom_header_rec
                ,  p_bom_revision_tbl      => l_bom_revision_tbl
                ,  p_bom_component_tbl     => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec        => l_bom_header_rec
                ,  x_bom_revision_tbl      => l_bom_revision_tbl
                ,  x_bom_component_tbl     => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl => l_bom_sub_component_tbl
                );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
     END IF;

  --
  -- Process Flow step 11 - Entity Level Defaulting
  --
  -- BOM Header does not have any entity level defaulting.

  --
  -- Process Flow step 12 - Entity Level Validation
  --

--  IF l_bom_header_rec.transaction_type <> ENG_Globals.G_OPR_DELETE
  IF l_bom_header_rec.transaction_type <> 'DELETE'
  THEN
        Bom_Validate_Bom_Header.Check_Entity
          (  x_return_status        => l_Return_Status
          ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
          ,  p_bom_header_rec       => l_bom_header_rec
          ,  p_bom_head_unexp_rec => l_bom_header_unexp_rec
          ,  p_old_bom_head_rec   => l_bom_header_rec
          ,  p_old_bom_head_unexp_rec => l_old_bom_header_unexp_rec
          );
  ELSE
                Bom_Validate_Bom_Header.Check_Entity_Delete
                ( x_return_status       => l_return_status
                , x_Mesg_Token_Tbl      => l_mesg_token_tbl
                , p_bom_header_rec    => l_bom_header_rec
                , p_bom_head_Unexp_Rec  => l_bom_header_unexp_rec
    , x_bom_head_unexp_rec  => l_bom_header_unexp_rec
                );
  END IF;
        IF l_return_status = Error_Handler.G_STATUS_ERROR
        THEN
                IF l_bom_header_rec.transaction_type = Bom_Globals.G_OPR_CREATE
                THEN
                l_other_message := 'BOM_BOM_CHECKENT_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                l_other_token_tbl(1).token_value :=
                                        l_bom_header_rec.assembly_item_name;
                        RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                        RAISE EXC_SEV_QUIT_RECORD;
                END IF;
     ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
        l_other_message := 'BOM_BOM_CHKENT_UNEXP_SKIP';
        l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
        l_other_token_tbl(1).token_value := l_bom_header_rec.assembly_item_name;
        RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
           l_Mesg_Token_Tbl.COUNT <>0
     THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
                Error_Handler.Log_Error
                (  p_bom_header_rec        => l_bom_header_rec
                ,  p_bom_revision_tbl      => l_bom_revision_tbl
                ,  p_bom_component_tbl     => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl=> l_bom_REF_DEsignator_tbl
                ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec        => l_bom_header_rec
                ,  x_bom_revision_tbl      => l_bom_revision_tbl
                ,  x_bom_component_tbl     => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl => l_bom_sub_component_tbl
                );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
     END IF;

  --
  -- Process Flow step 13 : Database Writes
  --
      G_Bill_Seq_Id := l_bom_header_unexp_rec.bill_sequence_id;

      Bom_Bom_Header_Util.Perform_Writes
        (   p_bom_header_rec    => l_bom_header_rec
        ,   p_bom_head_unexp_rec  => l_bom_header_unexp_rec
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
        ,   x_return_status   => l_return_status
        );

     IF l_bom_header_unexp_rec.source_bill_sequence_id <>
                                nvl(l_bom_header_unexp_rec.common_bill_sequence_id, l_bom_header_unexp_rec.bill_sequence_id)
     THEN
     --Replicate component.
      BOMPCMBM.Replicate_Components(
                          p_src_bill_sequence_id   => l_bom_header_unexp_rec.source_bill_sequence_id,
                          p_dest_bill_sequence_id  => l_bom_header_unexp_rec.bill_sequence_id,
                          x_Mesg_Token_Tbl => l_Mesg_Token_Tbl,
                          x_Return_Status => l_return_status);
      IF l_return_status = Error_Handler.G_STATUS_ERROR
      THEN
      --arudresh_debug('error -> BOM_UNIT_COMM_NO_EDIT');
        /*l_other_message := 'BOM_UNIT_COMM_NO_EDIT';
        l_other_token_tbl(1).token_name := null;
        l_other_token_tbl(1).token_value := null;*/
        RAISE EXC_SEV_SKIP_BRANCH;
      END IF;

     END iF;


     IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
     THEN
  l_other_message := 'BOM_BOM_WRITES_UNEXP_SKIP';
  l_other_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
  l_other_token_tbl(1).token_value :=
        l_bom_header_rec.assembly_item_name;
  RAISE EXC_UNEXP_SKIP_OBJECT;
     ELSIF l_return_status ='S' AND
     l_Mesg_Token_Tbl.COUNT <>0
     THEN
          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
                (  p_bom_header_rec        => l_bom_header_rec
                ,  p_bom_revision_tbl      => l_bom_revision_tbl
                ,  p_bom_component_tbl     => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => 'W'
                ,  p_error_level           => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec        => l_bom_header_rec
                ,  x_bom_revision_tbl      => l_bom_revision_tbl
                ,  x_bom_component_tbl     => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl => l_bom_sub_component_tbl
                );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
     END IF;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
                (  p_bom_header_rec        => l_bom_header_rec
                ,  p_bom_revision_tbl      => l_bom_revision_tbl
                ,  p_bom_component_tbl     => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl    => l_mesg_token_tbl
    ,  p_error_status    => FND_API.G_RET_STS_ERROR
    ,  p_error_scope     => Error_Handler.G_SCOPE_RECORD
    ,  p_error_level     => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec        => l_bom_header_rec
                ,  x_bom_revision_tbl      => l_bom_revision_tbl
                ,  x_bom_component_tbl     => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl => l_bom_sub_component_tbl

    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        x_return_status          := l_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
      x_bom_header_rec               := l_bom_header_rec;
      x_bom_revision_tbl             := l_bom_revision_tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

       WHEN EXC_SEV_QUIT_BRANCH THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
          Error_Handler.Log_Error
                (  p_bom_header_rec         => l_bom_header_rec
                ,  p_bom_revision_tbl       => l_bom_revision_tbl
                ,  p_bom_component_tbl      => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => Error_Handler.G_STATUS_ERROR
                ,  p_error_scope            => Error_Handler.G_SCOPE_CHILDREN
                ,  p_other_status           => Error_Handler.G_STATUS_ERROR
                ,  p_other_message          => l_other_message
                ,  p_other_token_tbl        => l_other_token_tbl
                ,  p_error_level            => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec         => l_bom_header_rec
                ,  x_bom_revision_tbl       => l_bom_revision_tbl
                ,  x_bom_component_tbl      => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
                );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_bom_header_rec               := l_bom_header_rec;
        x_bom_revision_tbl             := l_bom_revision_tbl;
        x_bom_component_tbl            := l_bom_component_tbl;
        x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

  RETURN;

    WHEN EXC_SEV_SKIP_BRANCH THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
    (  p_bom_header_rec         => l_bom_header_rec
                ,  p_bom_revision_tbl       => l_bom_revision_tbl
                ,  p_bom_component_tbl      => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_ERROR
    ,  p_error_scope  => Error_Handler.G_SCOPE_CHILDREN
    ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
    ,  p_error_level  => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec         => l_bom_header_rec
                ,  x_bom_revision_tbl       => l_bom_revision_tbl
                ,  x_bom_component_tbl      => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        x_return_status          := l_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
        x_bom_header_rec               := l_bom_header_rec;
        x_bom_revision_tbl             := l_bom_revision_tbl;
        x_bom_component_tbl            := l_bom_component_tbl;
        x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

  RETURN;

    WHEN EXC_FAT_QUIT_OBJECT THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
                (  p_bom_header_rec         => l_bom_header_rec
                ,  p_bom_revision_tbl       => l_bom_revision_tbl
                ,  p_bom_component_tbl      => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_FATAL
    ,  p_error_scope  => Error_Handler.G_SCOPE_ALL
    ,  p_other_message  => l_other_message
                ,  p_other_status       => Error_Handler.G_STATUS_FATAL
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec         => l_bom_header_rec
                ,  x_bom_revision_tbl       => l_bom_revision_tbl
                ,  x_bom_component_tbl      => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl

    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
        x_bom_header_rec               := l_bom_header_rec;
        x_bom_revision_tbl             := l_bom_revision_tbl;
        x_bom_component_tbl            := l_bom_component_tbl;
        x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

  l_return_status := 'Q';

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

          Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
    Error_Handler.Log_Error
                (  p_bom_header_rec         => l_bom_header_rec
                ,  p_bom_revision_tbl       => l_bom_revision_tbl
                ,  p_bom_component_tbl      => l_bom_component_tbl
                ,  p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
    ,  p_mesg_token_tbl => l_mesg_token_tbl
    ,  p_error_status => Error_Handler.G_STATUS_UNEXPECTED
    ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message  => l_other_message
    ,  p_other_token_tbl  => l_other_token_tbl
    ,  p_error_level  => Error_Handler.G_BH_LEVEL
                ,  x_bom_header_rec         => l_bom_header_rec
                ,  x_bom_revision_tbl       => l_bom_revision_tbl
                ,  x_bom_component_tbl      => l_bom_component_tbl
                ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
    );
          Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        x_return_status          := l_return_status;
  x_Mesg_Token_Tbl         := l_Mesg_Token_Tbl;
        x_bom_header_rec               := l_bom_header_rec;
        x_bom_revision_tbl             := l_bom_revision_tbl;
        x_bom_component_tbl            := l_bom_component_tbl;
        x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
      x_bom_comp_ops_tbl             := l_bom_comp_ops_tbl;

  l_return_status := 'U';

  END; -- END Header processing block

    IF l_return_status in ('Q', 'U')
    THEN
    x_return_status := l_return_status;
  RETURN;
    END IF;

    l_bo_return_status := l_return_status;

  --
  -- Process BOM Revisions that are chilren of this header
  --

  Bom_Revisions
      (   p_validation_level      => p_validation_level
      ,   p_assembly_item_name    => l_bom_header_rec.assembly_item_name
      ,   p_organization_id     => l_bom_header_unexp_rec.organization_id
  ,   p_alternate_bom_code    => l_bom_header_rec.alternate_bom_code
      ,   p_bom_revision_tbl      => l_bom_revision_tbl
        ,   p_bom_component_tbl     => l_bom_component_tbl
        ,   p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
        ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   p_bom_comp_ops_tbl      => l_bom_comp_ops_tbl
      ,   x_bom_revision_tbl      => l_bom_revision_tbl
      ,   x_bom_component_tbl     => l_bom_component_tbl
      ,   x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
      ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   x_bom_comp_ops_tbl      => l_bom_comp_ops_tbl
      ,   x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
      ,   x_return_status       => l_return_status
      );
    IF l_return_status <> 'S'
    THEN
  l_bo_return_status := l_return_status;
    END IF;

    -- Process Components that are orphans (without immediate revised
    -- item parents) but are indirect children of this header

      Bom_Components
  (   p_validation_level      => p_validation_level
        ,   p_assembly_item_name    => l_bom_header_rec.assembly_item_name
        ,   p_organization_id       => l_bom_header_unexp_rec.organization_id
        ,   p_alternate_bom_code    => l_bom_header_rec.alternate_bom_code
        ,   p_bom_component_tbl     => l_bom_component_tbl
        ,   p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
        ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   p_bom_comp_ops_tbl      => l_bom_comp_ops_tbl
        ,   x_bom_component_tbl     => l_bom_component_tbl
        ,   x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
        ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   x_bom_comp_ops_tbl      => l_bom_comp_ops_tbl
  ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
  ,   x_return_status   => l_return_status
  );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    -- Process Reference Designators that are orphans (without immediate revised
    -- component parents) but are indirect children of this header

      Reference_Designators
  (   p_validation_level          => p_validation_level
        ,   p_assembly_item_name    => l_bom_header_rec.assembly_item_name
        ,   p_organization_id       => l_bom_header_unexp_rec.organization_id
        ,   p_alternate_bom_code    => l_bom_header_rec.alternate_bom_code
        ,   p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
        ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
        ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
  ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
  ,   x_return_status   => l_return_status
  );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    -- Process Substitute Components that are orphans (without immediate revised
    -- component parents) but are indirect children of this header

      Substitute_Components
  (   p_validation_level          => p_validation_level
        ,   p_assembly_item_name    => l_bom_header_rec.assembly_item_name
        ,   p_organization_id       => l_bom_header_unexp_rec.organization_id
        ,   p_alternate_bom_code    => l_bom_header_rec.alternate_bom_code
        ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
  ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
  ,   x_return_status   => l_return_status
  );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    -- Process Component Operations that are orphans (without immediate revised
    -- component parents) but are indirect children of this header

      Component_Operations
  (   p_validation_level          => p_validation_level
        ,   p_assembly_item_name    => l_bom_header_rec.assembly_item_name
        ,   p_organization_id       => l_bom_header_unexp_rec.organization_id
        ,   p_alternate_bom_code    => l_bom_header_rec.alternate_bom_code
        ,   p_bom_comp_ops_tbl      => l_bom_comp_ops_tbl
        ,   x_bom_comp_ops_tbl      => l_bom_comp_ops_tbl
  ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
  ,   x_return_status   => l_return_status
  );

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

 /*****************Business Event*********/
    IF ( l_return_status = 'S') THEN
      if (Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_BOM_BO) then
       IF l_bom_header_rec.transaction_type in ( Bom_Globals.G_OPR_CREATE) THEN
        Bom_Business_Event_PKG.Raise_Bill_Event
       (p_Event_Load_Type => 'Bulk'
        ,p_Request_Identifier => FND_GLOBAL.CONC_REQUEST_ID
        ,p_batch_identifier        => BOM_GLOBALS.G_BATCH_ID
        ,p_Event_Entity_Name => 'Structure'
        ,p_Event_Entity_Parent_Id  => G_Bill_Seq_Id
        ,p_Event_Name => Bom_Business_Event_PKG.G_STRUCTURE_CREATION_EVENT
        ,p_last_update_date => sysdate
        ,p_last_updated_by => FND_GLOBAL.user_id
        );
      ELSIF l_bom_header_rec.transaction_type in ( Bom_Globals.G_OPR_UPDATE) THEN
        Bom_Business_Event_PKG.Raise_Bill_Event
         (p_Event_Load_Type => 'Bulk'
        ,p_Request_Identifier => FND_GLOBAL.CONC_REQUEST_ID
        ,p_batch_identifier        => BOM_GLOBALS.G_BATCH_ID
        ,p_Event_Entity_Name => 'Structure'
        ,p_Event_Entity_Parent_Id  => G_Bill_Seq_Id
        ,p_Event_Name => Bom_Business_Event_PKG.G_STRUCTURE_MODIFIED_EVENT
        ,p_last_update_date => sysdate
        ,p_last_updated_by => FND_GLOBAL.user_id
        );
      END IF;
    end if;
   END IF;
  /****************Business Event*********/


     --  Load out parameters

     x_return_status          := l_bo_return_status;
     x_bom_header_rec   := l_bom_header_rec;
     x_bom_revision_tbl         := l_bom_revision_tbl;
     x_bom_component_tbl        := l_bom_component_tbl;
     x_bom_ref_designator_tbl   := l_bom_ref_designator_tbl;
     x_bom_sub_component_tbl    := l_bom_sub_component_tbl;
     x_bom_comp_ops_tbl         := l_bom_comp_ops_tbl;
     x_Mesg_Token_Tbl     := l_Mesg_Token_Tbl;

END Bom_Header;


/***************************************************************************
* Procedure : Process_Bom
* Parameters IN : BOM Business Object Entities, Record for Header and tables
*     for the remaining entities
* Parameters OUT: BOM Business Object Entities, Record for Header and tables
*     for the remaining entities
* Returns : None
* Purpose : This is the only exposed procedure in the PVT API.
*     Process_BOM will drive the business object processing. It
*     will take each entity and call individual procedure that will
*     handle the processing of that entity and its children.
****************************************************************************/
PROCEDURE Process_Bom
(   p_api_version_number       IN  NUMBER
,   p_validation_level         IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   x_return_status            IN OUT NOCOPY VARCHAR2
,   x_msg_count                IN OUT NOCOPY NUMBER
,   p_bom_header_rec           IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
,   p_bom_revision_tbl         IN  Bom_Bo_PUB.Bom_Revision_Tbl_Type :=
                                        Bom_Bo_PUB.G_MISS_BOM_REVISION_TBL
,   p_bom_component_tbl        IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
,   p_bom_ref_designator_tbl    IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
                                    :=  Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
,   p_bom_sub_component_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
                                    :=  Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
,   p_bom_comp_ops_tbl          IN  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
                                    :=  Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
,   x_bom_header_rec            IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
,   x_bom_revision_tbl          IN OUT NOCOPY Bom_Bo_PUB.Bom_Revision_Tbl_Type
,   x_bom_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
,   x_bom_ref_designator_tbl    IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
,   x_bom_sub_component_tbl     IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
,   x_bom_comp_ops_tbl          IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Bom';
l_err_text          VARCHAR2(240);
l_return_status               VARCHAR2(1);

l_bo_return_status        VARCHAR2(1);

l_bom_header_rec    Bom_Bo_Pub.Bom_Head_Rec_Type;
l_bom_component_rec   Bom_Bo_Pub.Bom_Comps_Rec_Type;
l_bom_revision_tbl    Bom_Bo_Pub.Bom_Revision_Tbl_Type;
l_bom_ref_designator_rec  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
l_bom_sub_component_rec         Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
l_bom_comp_ops_rec          Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;
l_bom_component_tbl   Bom_Bo_Pub.Bom_Comps_Tbl_Type;
l_bom_ref_designator_tbl  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
l_bom_sub_component_tbl         Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
l_bom_comp_ops_tbl          Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_message         VARCHAR2(2000);
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
bill_seq_id number;    -- 4306013

EXC_ERR_PVT_API_MAIN        EXCEPTION;

BEGIN

  --  Init local variables.
  l_bom_header_rec  := p_bom_header_rec;
  l_bom_revision_tbl  := p_bom_revision_tbl;
  l_bom_component_tbl := p_bom_component_tbl;
  l_bom_ref_designator_tbl:= p_bom_ref_designator_tbl;
  l_bom_sub_component_tbl := p_bom_sub_component_tbl;
  l_bom_comp_ops_tbl  := p_bom_comp_ops_tbl;

  -- Business Object starts with a status of Success
  l_bo_return_status := 'S';

  --Load environment information into the SYSTEM_INFORMATION record
  -- (USER_ID, LOGIN_ID, PROG_APPID, PROG_ID)

  Bom_Globals.Init_System_Info_Rec
          (  x_mesg_token_tbl => l_mesg_token_tbl
          ,  x_return_status  => l_return_status
          );

  -- Initialize System_Information Unit_Effectivity flag

  IF (FND_PROFILE.DEFINED('PJM:PJM_UNITEFF_NO_EFFECT') AND
               FND_PROFILE.VALUE('PJM:PJM_UNITEFF_NO_EFFECT') = 'Y')
           OR (BOM_EAMUTIL.Enabled = 'Y')
  THEN
    Bom_Globals.Set_Unit_Effectivity (TRUE);
      ELSE
    Bom_Globals.Set_Unit_Effectivity (FALSE);
      END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE EXC_ERR_PVT_API_MAIN;
      END IF;

  --
  -- Start with processing of the Bill Header.
  --
      IF  (l_bom_header_rec.assembly_item_name <> FND_API.G_MISS_CHAR
        AND l_bom_header_rec.assembly_item_name IS NOT NULL)
      THEN
        Bom_Header
        (   p_validation_level          => p_validation_level
    ,   p_bom_header_rec    => l_bom_header_rec
    ,   p_bom_revision_tbl    => l_bom_revision_tbl
    ,   p_bom_component_tbl   => l_bom_component_tbl
    ,   p_bom_ref_designator_tbl    => l_bom_ref_designator_tbl
    ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,   p_bom_comp_ops_tbl    => l_bom_comp_ops_tbl
    ,   x_bom_header_rec    => l_bom_header_rec
    ,   x_bom_revision_tbl    => l_bom_revision_tbl
    ,   x_bom_component_tbl   => l_bom_component_tbl
    ,   x_bom_ref_designator_tbl    => l_bom_ref_designator_tbl
    ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,   x_bom_comp_ops_tbl    => l_bom_comp_ops_tbl
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
        ,   x_return_status     => l_return_status
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

    END IF;  -- Processing Bom Header Ends

  --
  -- Process BOM Revisions
  --
    IF l_bom_revision_tbl.Count <> 0
  THEN
    Bom_Revisions
        (   p_validation_level          => p_validation_level
    ,   p_bom_revision_tbl    => l_bom_revision_tbl
    ,   p_bom_component_tbl   => l_bom_component_tbl
    ,   p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
    ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,   p_bom_comp_ops_tbl    => l_bom_comp_ops_tbl
    ,   x_bom_revision_tbl    => l_bom_revision_tbl
    ,   x_bom_component_tbl   => l_bom_component_tbl
    ,   x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
    ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,   x_bom_comp_ops_tbl    => l_bom_comp_ops_tbl
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
        ,   x_return_status     => l_return_status
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

  END IF;  -- Processing of BOM revisions Ends

  --
  --  Process Inventory Components
  --

  IF l_bom_component_tbl.Count <> 0
  THEN
        Bom_Components
        (   p_validation_level          => p_validation_level
        ,   p_bom_component_tbl         => l_bom_component_tbl
          ,   p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
          ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,   p_bom_comp_ops_tbl    => l_bom_comp_ops_tbl
        ,   x_bom_component_tbl         => l_bom_component_tbl
        ,   x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
        ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
    ,   x_bom_comp_ops_tbl    => l_bom_comp_ops_tbl
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
    ,   x_return_status   => l_return_status
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
      END IF; -- Processing of Inventory Components Ends

  -- Process Reference Designators
  --
  IF l_bom_ref_designator_tbl.Count <> 0
      THEN
        Reference_Designators
        (   p_validation_level          => p_validation_level
        ,   p_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
          ,   p_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   x_bom_ref_designator_tbl=> l_bom_ref_designator_tbl
        ,   x_bom_sub_component_tbl => l_bom_sub_component_tbl
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
    ,   x_return_status   => l_return_status
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
  END IF; -- Processing of Reference Designator Ends

  IF l_bom_Sub_Component_Tbl.Count <> 0
  THEN
        Substitute_Components
        (   p_validation_level          => p_validation_level
        ,   p_bom_sub_component_tbl     => l_bom_sub_component_tbl
        ,   x_bom_sub_component_tbl     => l_bom_sub_component_tbl
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
    ,   x_return_status   => l_return_status
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

  END IF;  -- Processing of Substitute Components Ends

  IF l_Bom_Comp_Ops_Tbl.Count <> 0
  THEN
        Component_Operations
        (   p_validation_level          => p_validation_level
        ,   x_bom_comp_ops_tbl          => l_bom_comp_ops_tbl
        ,   p_bom_comp_ops_tbl          => l_bom_comp_ops_tbl
        ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
    ,   x_return_status   => l_return_status
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


  END IF;  -- Processing of Component Operations Ends

    x_return_status   := l_bo_return_status;

    x_bom_header_rec    := l_bom_header_rec;
    x_bom_revision_tbl    := l_bom_revision_tbl;
    x_bom_component_tbl   := l_bom_component_tbl;
    x_bom_ref_designator_tbl  := l_bom_ref_designator_tbl;
    x_bom_sub_component_tbl := l_bom_sub_component_tbl;
    x_bom_comp_ops_tbl    := l_bom_comp_ops_tbl;

    -- Reset system_information business object flags

    Bom_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    Bom_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    Bom_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    Bom_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

EXCEPTION

    WHEN EXC_ERR_PVT_API_MAIN THEN

        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
  Error_Handler.Log_Error
  (  p_bom_header_rec   => l_bom_header_rec
  ,  p_bom_revision_tbl   => l_bom_revision_tbl
  ,  p_bom_component_tbl    => l_bom_component_tbl
  ,  p_bom_ref_designator_tbl   => l_bom_ref_designator_tbl
  ,  p_bom_sub_component_tbl  => l_bom_sub_component_tbl
  ,  p_mesg_token_tbl   => l_mesg_token_tbl
  ,  p_error_status   => FND_API.G_RET_STS_UNEXP_ERROR
  ,  p_other_status         => Error_Handler.G_STATUS_NOT_PICKED
        ,  p_other_message    => l_other_message
  ,  p_other_token_tbl    => l_other_token_tbl
  ,  p_error_level    => 0
  ,  x_bom_header_rec   => l_bom_header_rec
  ,  x_bom_revision_tbl   => l_bom_revision_tbl
  ,  x_bom_component_tbl    => l_bom_component_tbl
  ,  x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
  ,  x_bom_sub_component_tbl  => l_bom_sub_component_tbl
  );
        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        x_return_status          := l_return_status;
      x_bom_header_rec         := l_bom_header_rec;
      x_bom_revision_tbl             := l_bom_revision_tbl;
      x_bom_component_tbl            := l_bom_component_tbl;
      x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
      x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
        x_bom_comp_ops_tbl         := l_bom_comp_ops_tbl;

      -- Reset system_information business object flags

    Bom_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    Bom_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    Bom_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    Bom_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN G_EXC_QUIT_IMPORT THEN

        x_return_status          := l_return_status;
        x_bom_header_rec               := l_bom_header_rec;
        x_bom_revision_tbl             := l_bom_revision_tbl;
        x_bom_component_tbl            := l_bom_component_tbl;
        x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
        x_bom_comp_ops_tbl         := l_bom_comp_ops_tbl;

      -- Reset system_information business object flags

    Bom_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    Bom_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    Bom_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    Bom_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN OTHERS THEN

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME || ' : Process BOM '
                  || substrb(SQLERRM,1,200);
    Error_Handler.Add_Error_Token
                  ( p_Message_Text => l_err_text
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        );
  END IF;

        Error_Handler.Set_Bom_Specific(p_bom_comp_ops_tbl => l_bom_comp_ops_tbl);
  Error_Handler.Log_Error
        (  p_bom_header_rec             => l_bom_header_rec
        ,  p_bom_revision_tbl           => l_bom_revision_tbl
        ,  p_bom_component_tbl          => l_bom_component_tbl
        ,  p_bom_ref_designator_tbl     => l_bom_ref_designator_tbl
        ,  p_bom_sub_component_tbl      => l_bom_sub_component_tbl
        ,  p_mesg_token_tbl             => l_mesg_token_tbl
        ,  p_error_status               => FND_API.G_RET_STS_UNEXP_ERROR
        ,  p_other_status               => Error_Handler.G_STATUS_NOT_PICKED
        ,  p_other_message              => l_other_message
        ,  p_other_token_tbl            => l_other_token_tbl
        ,  p_error_level                => 0
        ,  x_bom_header_rec             => l_bom_header_rec
        ,  x_bom_revision_tbl           => l_bom_revision_tbl
        ,  x_bom_component_tbl          => l_bom_component_tbl
        ,  x_bom_ref_designator_tbl     => l_bom_ref_designator_tbl
        ,  x_bom_sub_component_tbl      => l_bom_sub_component_tbl
        );
        Error_Handler.Get_Bom_Specific(x_bom_comp_ops_tbl => l_bom_comp_ops_tbl);

        x_return_status          := l_return_status;
        x_bom_header_rec               := l_bom_header_rec;
        x_bom_revision_tbl             := l_bom_revision_tbl;
        x_bom_component_tbl            := l_bom_component_tbl;
        x_bom_ref_designator_tbl       := l_bom_ref_designator_tbl;
        x_bom_sub_component_tbl        := l_bom_sub_component_tbl;
        x_bom_comp_ops_tbl         := l_bom_comp_ops_tbl;

      -- Reset system_information business object flags

    Bom_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    Bom_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    Bom_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    Bom_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

 END Process_BOM;
END Bom_Bo_Pvt;

/
