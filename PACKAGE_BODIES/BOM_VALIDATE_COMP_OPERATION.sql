--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_COMP_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_COMP_OPERATION" AS
/* $Header: BOMLCOPB.pls 120.6.12010000.2 2010/02/03 17:06:40 umajumde ship $ */
/**********************************************************************
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLCOPB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Comp_Operation
--
--  NOTES
--
--  HISTORY
--
--  27-AUG-2001   Refai Farook  Initial Creation
--
--
**************************************************************************/
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'BOM_Validate_Comp_Operation';
ret_code     NUMBER;
l_dummy      VARCHAR2(80);



        /*******************************************************************
        * Function      : Check_Overlap_Dates
        * Parameter IN  : Effectivity Date
        *                 Disable Date
        *                 Bill Sequence Id
        *                 Component Item Id
        * Return        : True if dates are overlapping else false.
        * Purpose       : The function will check if the same component is
        *                 entered with overlapping dates. Components with
        *                 overlapping dates will get an error.
        ******************************************************************/
        FUNCTION Check_Overlap_Dates
                ( p_Effectivity_Date DATE,
                  p_Disable_Date     DATE,
                  p_Component_Item_Id   NUMBER,
                  p_Bill_Sequence_Id NUMBER,
                  p_component_sequence_id   IN NUMBER := NULL,
                  p_comp_operation_seq_id   IN NUMBER := NULL,
                  p_Rowid            VARCHAR2 := NULL,
                  p_Operation_Seq_Num NUMBER,
                  p_entity           VARCHAR2 := 'COPS')
        RETURN BOOLEAN
        IS
                l_Count NUMBER := 0;
                CURSOR All_Dates IS
                        SELECT 'X' date_available FROM sys.dual
                        WHERE EXISTS (
                                SELECT 1 from BOM_Component_All_Operations_V
                                 WHERE Component_Item_Id = p_Component_Item_Id
                                   AND Bill_Sequence_Id  = p_Bill_Sequence_Id
                                   AND Operation_Seq_Num = p_Operation_Seq_Num
                                /* AND
                                   (
                                     ( p_entity = 'COPS'
                                       AND
                                       (p_comp_operation_seq_id IS NULL
                                        OR
                                        p_comp_operation_seq_id = FND_API.G_MISS_NUM
                                        OR
                                        comp_operation_seq_id <> p_comp_operation_seq_id)
                                     )
                                       OR
                                     ( p_entity = 'RC'
                                       AND
                                       (p_component_sequence_id IS NULL
                                        OR
                                        p_component_sequence_id = FND_API.G_MISS_NUM
                                        OR
                                        comp_operation_seq_id <> 0 -- row belongs to comp ops
                                        OR
                                        component_sequence_id <> p_component_sequence_id)
                                     )
                                   )
                                 */

                                 /*    AND
                                     (
                                      p_RowId IS NULL
                                      or
                                      p_Rowid = FND_API.G_MISS_CHAR
                                      or
                                      ( decode(p_entity,'COPS',bco_rowid,
                                                         'RC',bic_RowId,' ') <> p_RowID )
                                      )
                                 */
                                     AND
                                     (
                                      p_RowId IS NULL
                                      or
                                      p_Rowid = FND_API.G_MISS_CHAR
                                      or
                                      row_id <> p_Rowid)
                                   AND ( p_Disable_Date IS NULL
                                        OR ( to_char(p_Disable_Date,'YYYY/MM/DD HH24:MI:SS') > to_char(Effectivity_Date,'YYYY/MM/DD HH24:MI:SS'))) -- 5954279
                                   AND ( to_char(p_Effectivity_Date,'YYYY/MM/DD HH24:MI:SS') < to_char(Disable_Date,'YYYY/MM/DD HH24:MI:SS') -- 5954279
                                         OR Disable_Date IS NULL
                                        )
                                   AND implementation_date IS NOT NULL  -- Bug 3182080
                               );
        BEGIN

                FOR l_Date IN All_Dates LOOP
                        l_Count := l_Count + 1;
                END LOOP;

                -- If count <> 0 that means the current date is overlapping with
                -- some record.
                IF l_Count <> 0 THEN
                        RETURN TRUE;
                ELSE
                        RETURN FALSE;
                END IF;

        END Check_Overlap_Dates;


        /*******************************************************************
        * Function    : Check_Overlap_Numbers
        * Parameter IN: from end item unit number
        *               to end item unit number
        *               Bill Sequence Id
        *               Component Item Id
        * Return      : True if unit numbers are overlapping, else false.
        * Purpose     : The function will check if the same component is entered
        *               with overlapping unit numbers. Components with
        *               overlapping unit numbers will get an error.
        *********************************************************************/
        FUNCTION Check_Overlap_Numbers
                 (  p_From_End_Item_Number VARCHAR2
                  , p_To_End_Item_Number VARCHAR2
                  , p_Component_Item_Id   NUMBER
                  , p_Bill_Sequence_Id NUMBER
                  , p_component_sequence_id   IN NUMBER := NULL
                  , p_comp_operation_seq_id   IN NUMBER := NULL
                  , p_Rowid            VARCHAR2 := NULL
                  , p_Operation_Seq_Num NUMBER
                  , p_entity           VARCHAR2 := 'COPS')
        RETURN BOOLEAN
        IS
                l_Count NUMBER := 0;
                CURSOR All_Numbers_BIC IS
                        SELECT 'X' unit_available FROM sys.dual
                        WHERE EXISTS (
                                SELECT 1 from BOM_INVENTORY_COMPONENTS
                                 WHERE Component_Item_Id = p_Component_Item_Id
                                   AND Bill_Sequence_Id  = p_Bill_Sequence_Id
                                   AND Operation_Seq_Num = p_Operation_Seq_Num
                                   /* AND
                                   (
                                     ( p_entity = 'COPS'
                                       AND
                                       (p_comp_operation_seq_id IS NULL
                                        OR
                                        p_comp_operation_seq_id = FND_API.G_MISS_NUM
                                        OR
                                        comp_operation_seq_id <> p_comp_operation_seq_id)
                                     )
                                       OR
                                     ( p_entity = 'RC'
                                       AND
                                       (p_component_sequence_id IS NULL
                                        OR
                                        p_component_sequence_id = FND_API.G_MISS_NUM
                                        OR
                                        comp_operation_seq_id <> 0
                                        OR
                                        component_sequence_id <> p_component_sequence_id)
                                     )
                                   ) */

                                  /*
                                   AND
                                     (
                                      p_RowId IS NULL
                                      or
                                      p_Rowid = FND_API.G_MISS_CHAR
                                      or
                                      ( decode(p_entity,'COPS',bco_rowid,
                                                         'RC',bic_RowId,' ') <> p_RowID )
                                      )
                                   */
                                   AND
                                     (
                                      p_RowId IS NULL
                                      or
                                      p_Rowid = FND_API.G_MISS_CHAR
                                      or
                                      rowid <> p_Rowid)
                                   AND (p_To_End_Item_Number IS NULL
                                        OR p_To_End_Item_Number >=
                                           From_End_Item_Unit_Number)
                                   AND (p_From_End_Item_Number <=
                                         To_End_Item_Unit_Number
                                         OR To_End_Item_Unit_Number IS NULL
                                        )
                                   AND  ( IMPLEMENTATION_DATE IS NOT NULL )
                                   AND  ( DISABLE_DATE IS NULL ) --bug:5347036 Consider enabled components only
                               );

                CURSOR All_Numbers_BCO IS
                        SELECT 'X' unit_available FROM sys.dual
                        WHERE EXISTS (
                                SELECT 1 from BOM_COMPONENT_OPERATIONS BCO,
                                              BOM_INVENTORY_COMPONENTS BIC
                                 WHERE BCO.COMPONENT_SEQUENCE_ID = BIC.COMPONENT_SEQUENCE_ID
                                 AND BIC.Component_Item_Id = p_Component_Item_Id
                                   AND BIC.Bill_Sequence_Id  = p_Bill_Sequence_Id
                                   AND BCO.Operation_Seq_Num = p_Operation_Seq_Num
                                   /* AND
                                   (
                                     ( p_entity = 'COPS'
                                       AND
                                       (p_comp_operation_seq_id IS NULL
                                        OR
                                        p_comp_operation_seq_id = FND_API.G_MISS_NUM
                                        OR
                                        comp_operation_seq_id <> p_comp_operation_seq_id)
                                     )
                                       OR
                                     ( p_entity = 'RC'
                                       AND
                                       (p_component_sequence_id IS NULL
                                        OR
                                        p_component_sequence_id = FND_API.G_MISS_NUM
                                        OR
                                        comp_operation_seq_id <> 0
                                        OR
                                        component_sequence_id <> p_component_sequence_id)
                                     )
                                   ) */

                                  /*
                                   AND
                                     (
                                      p_RowId IS NULL
                                      or
                                      p_Rowid = FND_API.G_MISS_CHAR
                                      or
                                      ( decode(p_entity,'COPS',bco_rowid,
                                                         'RC',bic_RowId,' ') <> p_RowID )
                                      )
                                   */
                                   AND
                                     (
                                      p_RowId IS NULL
                                      or
                                      p_Rowid = FND_API.G_MISS_CHAR
                                      or
                                      bco.rowid <> p_Rowid)
                                   AND (p_To_End_Item_Number IS NULL
                                        OR p_To_End_Item_Number >=
                                           BIC.From_End_Item_Unit_Number)
                                   AND (p_From_End_Item_Number <=
                                         BIC.To_End_Item_Unit_Number
                                         OR BIC.To_End_Item_Unit_Number IS NULL
                                        )
                                   AND  ( bic.IMPLEMENTATION_DATE IS NOT NULL )
                                   AND  ( bic.DISABLE_DATE IS NULL ) --bug:5347036 Consider enabled components only
                               );
        BEGIN

                FOR l_Unit IN All_Numbers_BIC LOOP
                        l_Count := l_Count + 1;
                END LOOP;

                IF (l_count <> 0) THEN
                  FOR l_Unit IN All_Numbers_BCO LOOP
                        l_Count := l_Count + 1;
                  END LOOP;
                END IF;


                -- If count <> 0 that means the unit numbers are overlapping
                IF l_Count <> 0 THEN
                        RETURN TRUE;
                ELSE
                        RETURN FALSE;
                END IF;

        END Check_Overlap_Numbers;

/********************************************************************
*
* Procedure     : Check_Entity
* Parameters IN : Component Operation Record as given by the User
*                 Component Operation Unexposed Record
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Entity validate procedure will execute the business
*     validations for the component operation entity
*     Any errors are loaded in the Mesg_Token_Tbl and
*     a return status value is set.
********************************************************************/

PROCEDURE Check_Entity
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_comp_ops_rec          IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
,   p_bom_comp_ops_Unexp_Rec    IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
)
IS

l_disable_date                Date;
l_token_tbl         Error_Handler.Token_tbl_Type;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_Additional_Op_Seq_Number    NUMBER;
l_temp_var          NUMBER :=0;
p_dummy     NUMBER;
l_assy_bom_enabled  VARCHAR2(1);

BEGIN

      BEGIN
       IF Bom_Globals.Get_Caller_Type <> 'MIGRATION' THEN
        SELECT 1
        INTO p_dummy
        FROM bom_bill_of_materials
        WHERE bill_sequence_id = source_bill_sequence_id
        AND bill_sequence_id = p_bom_comp_ops_unexp_rec.bill_Sequence_id;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Error_Handler.Add_Error_Token
          (  p_Message_Name       => 'BOM_COMMON_COMP_OP'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          );
          x_Return_Status := FND_API.G_RET_STS_ERROR;
      END;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Validation for Comp. Operation begins . . .'); END IF;


 SELECT msi.bom_enabled_flag
 INTO l_assy_bom_enabled
 FROM mtl_system_items_b msi,
 bom_bill_of_materials bbom
 WHERE bbom.bill_sequence_id = p_bom_comp_ops_Unexp_Rec.bill_sequence_id
 AND bbom.assembly_item_id = msi.inventory_item_id
 AND bbom.organization_id = msi.organization_id;

 IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Assy Bom Enabled flag : ' || l_assy_bom_enabled); END IF;

 IF l_assy_bom_enabled <> 'Y'
 THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
       l_token_tbl(1).token_value :=
         p_bom_comp_ops_rec.assembly_Item_Name;
                         Error_Handler.Add_Error_Token
                         (  x_Mesg_Token_tbl => l_Mesg_Token_Tbl
                          , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                          , p_message_name   => 'BOM_REV_ITEM_BOM_NOT_ENABLED'
        , p_token_tbl      => l_token_tbl
                          );
                 END IF;
     RAISE FND_API.G_EXC_ERROR;
 END IF;


  /* Select the didsable date which is one of the key parameters */

  SELECT disable_date INTO l_disable_date FROM bom_inventory_components WHERE
   component_sequence_id = p_bom_comp_ops_unexp_rec.component_sequence_id;

  /* Validate for Duplicate entries/Overlapping of the component */

  /* While creating a new row, additional_operation_sequence_number should be checked and
    while updating the existing additional_operation_sequence_number, new_addtional_op_sequence_number
     should be checked for Overlapping entries */

     l_Additional_Op_Seq_Number := p_bom_comp_ops_rec.additional_operation_seq_num;

  If( p_bom_comp_ops_rec.transaction_type = BOM_globals.G_OPR_UPDATE and
       p_bom_comp_ops_rec.new_additional_op_seq_num is not null
       and  p_bom_comp_ops_rec.new_additional_op_seq_num <> FND_API.G_MISS_NUM) then
     l_Additional_Op_Seq_Number := p_bom_comp_ops_rec.new_additional_op_seq_num;
  End if;

  IF p_bom_comp_ops_rec.from_end_item_unit_number IS NULL or
     p_bom_comp_ops_rec.from_end_item_unit_number = FND_API.G_MISS_CHAR THEN

    IF Check_Overlap_Dates ( p_Effectivity_Date => p_bom_comp_ops_rec.start_effective_date,
                    p_Disable_Date     => l_disable_date,
                    p_Component_Item_Id  =>p_bom_comp_ops_unexp_rec.component_item_id,
                    p_Bill_Sequence_Id   => p_bom_comp_ops_unexp_rec.bill_sequence_id,
                        p_comp_operation_seq_id => p_bom_comp_ops_unexp_rec.comp_operation_seq_id,
                    p_Rowid              => p_bom_comp_ops_unexp_rec.rowid,
                    p_Operation_Seq_Num => l_Additional_Op_Seq_Number) THEN

  l_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
  l_token_tbl(1).token_value := p_bom_comp_ops_rec.component_item_name;
  l_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
  l_token_tbl(2).token_value := p_bom_comp_ops_rec.additional_operation_seq_num;
  Error_Handler.Add_Error_Token
  (  x_Mesg_Token_tbl => l_Mesg_Token_tbl
   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_message_name => 'BOM_COPS_DATES_OVERLAP'
         , p_token_tbl    => l_token_tbl
   );

        RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE

    IF Check_Overlap_Numbers ( p_From_End_Item_Number => p_bom_comp_ops_rec.from_end_item_unit_number,
                    p_To_End_Item_Number     => p_bom_comp_ops_rec.to_end_item_unit_number,
                    p_Component_Item_Id  =>p_bom_comp_ops_unexp_rec.component_item_id,
                    p_Bill_Sequence_Id   => p_bom_comp_ops_unexp_rec.bill_sequence_id,
                        p_comp_operation_seq_id => p_bom_comp_ops_unexp_rec.comp_operation_seq_id,
                    p_Rowid              => p_bom_comp_ops_unexp_rec.rowid,
                    p_Operation_Seq_Num => l_Additional_Op_Seq_Number) THEN

  l_token_tbl(1).token_name := 'COMPONENT_ITEM_NAME';
  l_token_tbl(1).token_value := p_bom_comp_ops_rec.component_item_name;
  l_token_tbl(2).token_name := 'OPERATION_SEQ_NUM';
  l_token_tbl(2).token_value := p_bom_comp_ops_rec.additional_operation_seq_num;
  Error_Handler.Add_Error_Token
  (  x_Mesg_Token_tbl => l_Mesg_Token_tbl
   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_message_name => 'BOM_COPS_NUMBERS_OVERLAP'
         , p_token_tbl    => l_token_tbl
   );
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

  END IF;

/* When the component operation is updated with new Component operation, It should be checked that
 the New Component operation does not exists already */

     IF ( p_bom_comp_ops_rec.new_additional_op_seq_num is not null
         and  p_bom_comp_ops_rec.new_additional_op_seq_num <> FND_API.G_MISS_NUM
            and p_bom_comp_ops_rec.transaction_type = Bom_Globals.G_OPR_UPDATE) THEN

        select count(*) into l_temp_var
          FROM    BOM_COMPONENT_OPERATIONS
          WHERE   OPERATION_SEQ_NUM = p_bom_comp_ops_rec.new_additional_op_seq_num
          AND     COMPONENT_SEQUENCE_ID = p_bom_Comp_ops_Unexp_Rec.component_sequence_id;

        IF (l_temp_var <>0) then
        l_Token_Tbl(1).Token_Name  := 'OPERATION_SEQUENCE_NUMBER';
        l_Token_Tbl(1).Token_Value :=
                        p_bom_comp_ops_rec.new_additional_op_seq_num;
        l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
        l_token_tbl(2).token_value := p_bom_comp_ops_rec.component_item_name;

                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'BOM_COMP_OPS_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );

          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

IF BOm_GlobalS.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verified New addtional Component operation ...  '); END IF;

IF Bom_GlobalS.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Verifying Operation Seq Num in Editable common Bills ...  '); END IF;
   --The op seq num being used must be valid for the editable common bills commoning this bill.
    IF NOT BOMPCMBM.Check_Op_Seq_In_Ref_Boms(p_src_bill_seq_id => p_bom_comp_ops_unexp_rec.bill_sequence_id,
                                             p_op_seq => nvl(p_bom_comp_ops_rec.new_additional_op_seq_num,
                                                              p_bom_comp_ops_rec.additional_operation_seq_num)
                                            )
    THEN
         Error_Handler.Add_Error_Token
        (  p_Message_Name   => 'BOM_COMMON_OP_SEQ_INVALID'
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_Token_Tbl      => l_Token_Tbl
         );
         RAISE FND_API.G_EXC_ERROR;
    END IF;




  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Expected Error in Comp Operations. Entity Validation '); END IF;

  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status  := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('UNExpected Error in Comp. Operations Entity Validation '); END IF;
  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Entity;

/********************************************************************
*
* Procedure     : Check_Attributes
* Parameters IN : Component Operation Record as given by the User
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Attribute validation will validate individual attributes
*     and any errors will be populated in the Mesg_Token_Tbl
*     and returned with a return_status.
********************************************************************/

PROCEDURE Check_Attributes
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_comp_ops_rec           IN Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
,   p_bom_comp_ops_unexp_rec     IN Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
)
IS

l_original_routing      VARCHAR2(1) := 'N';
l_valid                 Number := 0;
l_token_tbl   Error_Handler.Token_tbl_Type;
l_Mesg_token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
l_err_text              VARCHAR2(240);

CURSOR OpSeq_In_Original IS
 SELECT operation_seq_num
  FROM bom_operation_sequences bos
  WHERE routing_sequence_id =
      (SELECT common_routing_sequence_id
         FROM bom_operational_routings bor
         WHERE assembly_item_id = p_bom_comp_ops_unexp_rec.assembly_item_id
          and organization_id = p_bom_comp_ops_unexp_rec.organization_id
          and nvl(alternate_routing_designator,'NONE') =
                 nvl(p_bom_comp_ops_rec.alternate_bom_code, 'NONE')
        )
   and nvl(trunc(disable_date), trunc(sysdate)+1) > trunc(sysdate) and nvl(operation_type,1) = 1;

CURSOR Opseq_In_Primary IS
 SELECT operation_seq_num
  FROM bom_operation_sequences bos
  WHERE routing_sequence_id =
      (SELECT common_routing_sequence_id
         FROM bom_operational_routings bor
         WHERE assembly_item_id = p_bom_comp_ops_unexp_rec.assembly_item_id
          and organization_id = p_bom_comp_ops_unexp_rec.organization_id
          and alternate_routing_designator IS NULL
       )
   and nvl(trunc(disable_date), trunc(sysdate)+1) > trunc(sysdate) and nvl(operation_type,1) = 1;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute Validation Starts . . . '); END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Additional Operation Sequence Number is '||to_char(p_bom_comp_ops_rec.additional_operation_seq_num)); END IF;

    /* Check for the existence of OpSeq in the original routing which is defined for this item */

    FOR r1 IN OpSeq_In_Original
    LOOP
      l_original_routing := 'Y';

      IF r1.operation_seq_num = p_bom_comp_ops_rec.additional_operation_seq_num THEN
        l_valid := 1;
        Exit;
      END IF;
    END LOOP;

    /* If there is no original routing, then check in the primary routing */

    IF l_original_routing = 'N' THEN
      FOR r2 IN OpSeq_In_Primary
      LOOP

        IF r2.operation_seq_num = p_bom_comp_ops_rec.additional_operation_seq_num THEN
          l_valid := 1;
          Exit;
        END IF;

      END LOOP;
    END IF;

    IF l_valid = 0 THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
    l_token_tbl(1).token_name := 'OPERATION_SEQ_NUM';
    l_token_tbl(1).token_value := p_bom_comp_ops_rec.additional_operation_seq_num;

    Error_Handler.Add_Error_Token
    (  x_Mesg_Token_tbl => l_Mesg_Token_tbl
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name => 'BOM_COPS_OPSEQ_INVALID'
                 , p_token_tbl    => l_token_tbl
     );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;


EXCEPTION

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME ||
                              'Attribute Validate (Component Operation)' ||
                              SUBSTR(SQLERRM, 1, 100);

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => NULL
                 , p_Message_Text       => l_err_text
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
                );
        END IF;
  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Attributes;

/*****************************************************************************
* Procedure     : Check_Existence
* Parameters IN : Component Operation exposed column record
*                 Component Operation unexposed column record
* Parameters OUT: Old Component Operation exposed column record
*                 Old Component Operation unexposed column record
*                 Mesg Token Table
*                 Return Status
* Purpose       : Check_Existence will perform a query using the primary key
*                 information and will return a success if the operation is
*                 CREATE and the record EXISTS or will return an
*                 error if the operation is UPDATE and the record DOES NOT
*                 EXIST.
*                 In case of UPDATE if the record exists then the procedure
*                 will return the old record in the old entity parameters
*                 with a success status.
****************************************************************************/
PROCEDURE Check_Existence
(  p_bom_comp_ops_rec            IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , p_bom_comp_ops_unexp_rec      IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_old_bom_comp_ops_rec        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , x_old_bom_comp_ops_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status               IN OUT NOCOPY VARCHAR2
)
IS
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_Return_Status   VARCHAR2(1);
  l_Token_Tbl   Error_Handler.Token_Tbl_Type;
BEGIN
        l_Token_Tbl(1).Token_Name  := 'OPERATION_SEQUENCE_NUMBER';
        l_Token_Tbl(1).Token_Value :=
      p_bom_comp_ops_rec.additional_operation_seq_num;
  l_token_tbl(2).token_name  := 'REVISED_COMPONENT_NAME';
  l_token_tbl(2).token_value := p_bom_comp_ops_rec.component_item_name;

        BOM_Comp_Operation_Util.Query_Row
  (   p_component_sequence_id=>
        p_bom_comp_ops_unexp_rec.component_sequence_id
,p_additional_operation_seq_num =>p_bom_comp_ops_rec.additional_operation_seq_num
  ,   x_bom_comp_ops_rec    => x_old_bom_comp_ops_rec
  ,   x_bom_comp_ops_unexp_rec  => x_old_bom_comp_ops_unexp_rec
  ,   x_Return_Status   => l_return_status
  );

        IF l_return_status = Bom_Globals.G_RECORD_FOUND AND
           p_bom_comp_ops_rec.transaction_type = Bom_Globals.G_OPR_CREATE
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'BOM_COMP_OPS_ALREADY_EXISTS'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = Bom_Globals.G_RECORD_NOT_FOUND AND
              p_bom_comp_ops_rec.transaction_type IN
                 (Bom_Globals.G_OPR_UPDATE, Bom_Globals.G_OPR_DELETE)
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_name  => 'BOM_COMP_OPS_DOESNOT_EXIST'
                 , p_token_tbl     => l_token_tbl
                 );
                 l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                Error_Handler.Add_Error_Token
                (  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_message_name       => NULL
                 , p_message_text       =>
                   'Unexpected error while existence verification of ' ||
                   'Component Operation '||
                   p_bom_comp_ops_rec.operation_sequence_number
                 , p_token_tbl          => l_token_tbl
                 );
        ELSE

                 /* Assign the relevant transaction type for SYNC operations */

                 IF p_bom_comp_ops_rec.transaction_type = 'SYNC' THEN
                   IF l_return_status = Bom_Globals.G_RECORD_FOUND THEN
                     x_old_bom_comp_ops_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_UPDATE;
                   ELSE
                     x_old_bom_comp_ops_rec.transaction_type :=
                                                   Bom_Globals.G_OPR_CREATE;
                   END IF;
                 END IF;
                 l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Check_Existence;

PROCEDURE Check_Lineage
(  p_bom_comp_ops_rec           IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , p_bom_comp_ops_unexp_rec     IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
  l_token_tbl     Error_Handler.Token_Tbl_Type;
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;

  CURSOR c_GetComponent IS
  SELECT component_sequence_id
    FROM bom_inventory_components
   WHERE component_item_id= p_bom_comp_ops_unexp_rec.component_item_id
     AND operation_seq_num=p_bom_comp_ops_rec.operation_sequence_number
     AND effectivity_date = p_bom_comp_ops_rec.start_effective_date
     AND bill_sequence_id = p_bom_comp_ops_unexp_rec.bill_sequence_id;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR Component IN c_GetComponent LOOP
    IF Component.component_sequence_id <>
      p_bom_comp_ops_unexp_rec.component_sequence_id
    THEN
                                l_Token_Tbl(1).token_name  :=
          'REVISED_COMPONENT_NAME';
                                l_Token_Tbl(1).token_value :=
                                     p_bom_comp_ops_rec.component_item_name;
                                l_Token_Tbl(2).token_name  :=
          'OPERATION_SEQUENCE_NUMBER';
                                l_Token_Tbl(2).token_value :=
                                 p_bom_comp_ops_rec.operation_sequence_number;
         l_Token_Tbl(3).token_name  :=
                                        'ASSEMBLY_ITEM_NAME';
                                l_Token_Tbl(3).token_value :=
                                 p_bom_comp_ops_rec.assembly_item_name;

                                Error_Handler.Add_Error_Token
                                (  p_Message_Name => 'BOM_COPS_REV_ITEM_MISMATCH'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                 );
                                x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END LOOP;

  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END CHECK_LINEAGE;



END BOM_Validate_Comp_Operation;

/
