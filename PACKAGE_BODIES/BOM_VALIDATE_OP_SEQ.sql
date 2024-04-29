--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_OP_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_OP_SEQ" AS
/* $Header: BOMLOPSB.pls 120.7.12010000.3 2012/08/06 22:41:33 umajumde ship $ */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMLOPSB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Op_Seq
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Masanori Kimizuka Initial Creation
--
****************************************************************************/

   G_Pkg_Name      VARCHAR2(30) := 'BOM_Validate_Op_Seq';


    l_MODEL                       CONSTANT NUMBER := 1 ;
    l_OPTION_CLASS                CONSTANT NUMBER := 2 ;
    l_PLANNING                    CONSTANT NUMBER := 3 ;
    l_STANDARD                    CONSTANT NUMBER := 4 ;
    l_PRODFAMILY                  CONSTANT NUMBER := 5 ;
    l_EVENT                       CONSTANT NUMBER := 1 ;
    l_PROCESS                     CONSTANT NUMBER := 2 ;
    l_LINE_OP                     CONSTANT NUMBER := 3 ;
    l_ACD_ADD                     CONSTANT NUMBER := 1 ;
    l_ACD_CHANGE                  CONSTANT NUMBER := 2 ;
    l_ACD_DISABLE                 CONSTANT NUMBER := 3 ;




    /******************************************************************
    * OTHER LOCAL FUNCTION AND PROCEDURES
    * Purpose       : Called by Check_Entity or something
    *********************************************************************/
    --
    -- Function Check Prrimary Routing
    --
    FUNCTION Check_Primary_Routing( p_revised_item_id  IN  NUMBER
                                  , p_organization_id  IN  NUMBER )
       RETURN BOOLEAN
    IS
       CURSOR l_primary_rtg_csr ( p_revised_item_id  NUMBER
                                 ,p_organization_id  NUMBER )
       IS
          SELECT 'Primary not Exists'
          FROM   bom_operational_routings
          WHERE  assembly_item_id = p_revised_item_id
          AND    organization_id  = p_organization_id
          AND    NVL(alternate_routing_designator, 'NONE') = 'NONE' ;

       l_ret_status BOOLEAN := FALSE ;

    BEGIN
       FOR l_primary_rtg_rec IN l_primary_rtg_csr( p_revised_item_id
                                                 , p_organization_id )
       LOOP
          l_ret_status  := TRUE ;
       END LOOP;

        -- If the loop does not execute then
        -- return false
          RETURN l_ret_status ;

    END Check_Primary_Routing ;


    --
    -- Function: Check if unimplemented Rev Comp referencing Op Seq Num
    --           exists for Transaction Type : Cancel
    --
    FUNCTION Check_Ref_Rev_Comp
            ( p_operation_seq_num    IN  NUMBER
            , p_start_effective_date IN  DATE
            , p_rev_item_seq_id      IN  NUMBER
            )
       RETURN BOOLEAN
    IS
       CURSOR l_ref_rev_cmp_csr ( p_operation_seq_num    NUMBER
                                , p_start_effective_date DATE
                                , p_rev_item_seq_id      NUMBER
                                )

       IS
          SELECT 'Rev Comp referencing Seq Num exists'
          FROM    SYS.DUAL
          WHERE   EXISTS (SELECT NULL
                          FROM   BOM_INVENTORY_COMPONENTS bic
                               , ENG_REVISED_ITEMS        eri
                          WHERE  TRUNC(bic.effectivity_date) >=  TRUNC(p_start_effective_date)
                          AND    bic.implementation_date  IS NULL
                          AND    bic.operation_seq_num = p_operation_seq_num
                          AND    bic.bill_sequence_id   = eri.bill_sequence_id
                          AND    eri.revised_item_sequence_id = p_rev_item_seq_id
                          ) ;

       l_ret_status BOOLEAN := TRUE ;

    BEGIN
       FOR l_ref_rev_cmp_rec IN l_ref_rev_cmp_csr
                                ( p_operation_seq_num
                                , p_start_effective_date
                                , p_rev_item_seq_id
                                )
       LOOP
          l_ret_status  := FALSE ;
       END LOOP;

        -- If the loop does not execute then
        -- return false
          RETURN l_ret_status ;

    END Check_Ref_Rev_Comp ;


    --
    -- Function: Check if Op Seq Num exists in Work Order
    --           in ECO by Lot, Wo, Cum Qty
    --
    FUNCTION Check_ECO_By_WO_Effectivity
             ( p_revised_item_sequence_id IN  NUMBER
             , p_operation_seq_num        IN  NUMBER
             , p_organization_id          IN  NUMBER
             , p_rev_item_id              IN  NUMBER
             )

    RETURN BOOLEAN
    IS
       l_ret_status BOOLEAN := TRUE ;

       l_lot_number varchar2(30) := NULL;
       l_from_wip_entity_id NUMBER :=0;
       l_to_wip_entity_id NUMBER :=0;
       l_from_cum_qty  NUMBER :=0;


       CURSOR  l_check_lot_num_csr ( p_lot_number        VARCHAR2
                                   , p_operation_seq_num NUMBER
                                   , p_organization_id   NUMBER
                                   , p_rev_item_id       NUMBER
                                   )
       IS
          SELECT 'Op Seq does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE  (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_OPERATIONS     wo
                                             WHERE  operation_seq_num = p_operation_seq_num
                                             AND    wip_entity_id     = wdj.wip_entity_id)
                                  )
                         AND    wdj.lot_number = p_lot_number
                         AND    wdj.organization_id = p_organization_id
                         AND    wdj.primary_item_id = p_rev_item_id
                        ) ;

       CURSOR  l_check_wo_csr (  p_from_wip_entity_id NUMBER
                               , p_to_wip_entity_id   NUMBER
                               , p_operation_seq_num  NUMBER
                               , p_organization_id    NUMBER )
       IS
          SELECT 'Op Seq does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                               , WIP_ENTITIES       we
                               , WIP_ENTITIES       we1
                               , WIP_ENTITIES       we2
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS (SELECT NULL
                                              FROM   WIP_OPERATIONS     wo
                                              WHERE  operation_seq_num = p_operation_seq_num
                                              AND    wip_entity_id     = wdj.wip_entity_id  )
                                 )
                         AND     wdj.wip_entity_id = we.wip_entity_id
                         AND     we.organization_Id =  p_organization_id
                         AND     we.wip_entity_name >= we1.wip_entity_name
                         AND     we.wip_entity_name <= we2.wip_entity_name
                         AND     we1.wip_entity_id = p_from_wip_entity_id
                         AND     we2.wip_entity_id = NVL(p_to_wip_entity_id, p_from_wip_entity_id)
                         ) ;

      CURSOR  l_check_cum_csr (  p_from_wip_entity_id NUMBER
                               , p_operation_seq_num  NUMBER)
       IS
          SELECT 'Op Seq does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_OPERATIONS     wo
                                             WHERE  operation_seq_num = p_operation_seq_num
                                             AND    wip_entity_id     = wdj.wip_entity_id  )
                                 )
                         AND     wdj.wip_entity_id = p_from_wip_entity_id
                         ) ;

    BEGIN


       l_lot_number := BOM_Rtg_Globals.Get_Lot_Number;
       l_from_wip_entity_id := BOM_Rtg_Globals.Get_From_Wip_Entity_Id;
       l_to_wip_entity_id := BOM_Rtg_Globals.Get_To_Wip_Entity_Id;
       l_from_cum_qty := BOM_Rtg_Globals.Get_From_Cum_Qty;


          -- Check if Op Seq Num is exist in ECO by Lot
          IF    l_lot_number         IS NOT NULL
           AND  l_from_wip_entity_id IS NULL
           AND  l_to_wip_entity_id   IS NULL
           AND  l_from_cum_qty       IS NULL
          THEN

             -- Modified bug for 1611803
             FOR l_lot_num_rec IN l_check_lot_num_csr
                               ( p_lot_number        => l_lot_number
                               , p_operation_seq_num => p_operation_seq_num
                               , p_organization_Id   => p_organization_id
                               , p_rev_item_id       => p_rev_item_id
                               )
             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          -- Check if Op Seq Num is exist  in ECO by Cum
          ELSIF   l_lot_number         IS NULL
           AND    l_from_wip_entity_id IS NOT NULL
           AND    l_to_wip_entity_id   IS NULL
           AND    l_from_cum_qty       IS NOT NULL
          THEN

             FOR l_cum_rec IN l_check_cum_csr
                               ( p_from_wip_entity_id => l_from_wip_entity_id
                               , p_operation_seq_num  => p_operation_seq_num )
             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          -- Check if Op Seq Num is exist  in ECO by WO
          ELSIF   l_lot_number         IS NULL
           AND    l_from_wip_entity_id IS NOT NULL
           AND    l_from_cum_qty       IS NULL
          THEN

             FOR l_wo_rec IN l_check_wo_csr
                               ( p_from_wip_entity_id => l_from_wip_entity_id
                               , p_to_wip_entity_id   => l_to_wip_entity_id
                               , p_operation_seq_num  => p_operation_seq_num
                               , p_organization_id    => p_organization_id)
             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          ELSIF   l_lot_number         IS NULL
           AND    l_from_wip_entity_id IS NULL
           AND    l_to_wip_entity_id   IS NULL
           AND    l_from_cum_qty       IS NULL
          THEN
             NULL ;

          --  ELSE
          --     l_ret_status  := FALSE ;
          --

          END IF ;

       RETURN l_ret_status ;

    END Check_ECO_By_WO_Effectivity ;


    -- Function Check_RevItem_Alternate
    -- Added by MK on 11/01/2000
    -- Called from Check_Access
    --
    -- Comment out  to resolve Odf dependency

    --
    -- Function Check_ResExists
    -- Added by MK on 11/28/2000
    -- Called from Check_Entity
    FUNCTION Check_ResExists (  p_op_seq_id               IN  NUMBER
                              , p_old_op_seq_id           IN  NUMBER
                              , p_acd_type                IN  NUMBER
                              )
    RETURN BOOLEAN
    IS


        -- Check if the operatin already has resources
        CURSOR l_exist_res_cur (x_op_seq_id NUMBER)
        IS
           SELECT 'Resource Exist'
           FROM   DUAL
           WHERE EXISTS ( SELECT NULL
                          FROM   BOM_OPERATION_RESOURCES
                          WHERE  operation_sequence_id = p_op_seq_id
                        ) ;
    BEGIN

        FOR l_exist_res_rec IN l_exist_res_cur(x_op_seq_id => p_op_seq_id)
        LOOP
           RETURN TRUE ;
        END LOOP ;

        IF NVL(p_acd_type, l_ACD_ADD)  = l_ACD_CHANGE
        THEN

            FOR l_exist_res_rec IN l_exist_res_cur(x_op_seq_id => p_old_op_seq_id)
            LOOP
                RETURN TRUE ;
            END LOOP ;
        END IF ;

        RETURN FALSE ;

    END  Check_ResExists ;



    /******************************************************************
    * Procedure     : Check_Existence used by RTG BO
    * Parameters IN : Operation exposed column record
    *                 Operation unexposed column record
    * Parameters out: Old Operation exposed column record
    *                 Old Operation unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Routing Operation to Common Operation and
    *                 Call Check_Existence for Common Operation.
    *                 After calling Check_Existence, convert old Common
    *                 operation record back to Routing Operation Record
    *********************************************************************/
    PROCEDURE Check_Existence
    (  p_operation_rec     IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec      IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_old_operation_rec IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_old_op_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status     IN OUT NOCOPY VARCHAR2
    )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
        l_old_com_operation_rec  Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_old_com_op_unexp_rec   Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
        (  p_rtg_operation_rec      => p_operation_rec
         , p_rtg_op_unexp_rec       => p_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;

        -- Call Check_Existence
        Bom_Validate_Op_Seq.Check_Existence
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_old_com_operation_rec => l_old_com_operation_rec
         , x_old_com_op_unexp_rec  => l_old_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

        -- Convert old Common Opeartion Record back to Routing Operation
        Bom_Rtg_Pub.Convert_ComOp_To_RtgOp
        (  p_com_operation_rec  => l_old_com_operation_rec
         , p_com_op_unexp_rec   => l_old_com_op_unexp_rec
         , x_rtg_operation_rec  => x_old_operation_rec
         , x_rtg_op_unexp_rec   => x_old_op_unexp_rec
         ) ;

    END Check_Existence ;


    /******************************************************************
    * Procedure     : Check_Existence used by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    * Parameters out: Revised Old Operation exposed column record
    *                 Revised Old Operation unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Revised Operation to Common Operation and
    *                 Call Check_Existence for Common Operation.
    *                 After calling Check_Existence, convert old Common
    *                 operation record back to Revised Operation Record
    *********************************************************************/
    PROCEDURE Check_Existence
    (  p_rev_operation_rec     IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec      IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_old_rev_operation_rec IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_old_rev_op_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status         IN OUT NOCOPY VARCHAR2
    )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
        l_old_com_operation_rec  Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_old_com_op_unexp_rec   Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
        (  p_rev_operation_rec      => p_rev_operation_rec
         , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;

        -- Call Check_Existence
        Bom_Validate_Op_Seq.Check_Existence
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_old_com_operation_rec => l_old_com_operation_rec
         , x_old_com_op_unexp_rec  => l_old_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

        -- Convert old Common Opeartion Record back to Routing Operation
        Bom_Rtg_Pub.Convert_ComOp_To_EcoOp
        (  p_com_operation_rec  => l_old_com_operation_rec
         , p_com_op_unexp_rec   => l_old_com_op_unexp_rec
         , x_rev_operation_rec  => x_old_rev_operation_rec
         , x_rev_op_unexp_rec   => x_old_rev_op_unexp_rec
         ) ;

    END Check_Existence ;


    /******************************************************************
    * Procedure     : Check_Existence called by RTG BO and by ECO BO
    *
    * Parameters IN : Common operation exposed column record
    *                 Common operation unexposed column record
    * Parameters out: Old Common operation exposed column record
    *                 Old Common operation unexposed column record
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
    (  p_com_operation_rec      IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec       IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_old_com_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_old_com_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    )
    IS
       l_token_tbl      Error_Handler.Token_Tbl_Type;
       l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
       l_return_status  VARCHAR2(1);

    BEGIN

       l_Token_Tbl(1).Token_Name  := 'OP_SEQ_NUMBER';
       l_Token_Tbl(1).Token_Value := p_com_operation_rec.operation_sequence_number;
       l_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
       l_Token_Tbl(2).Token_Value := p_com_operation_rec.revised_item_name;

       Bom_Op_Seq_Util.Query_Row
       ( p_operation_sequence_number =>  p_com_operation_rec.operation_sequence_number
       , p_effectivity_date          =>  p_com_operation_rec.start_effective_date
       , p_routing_sequence_id       =>  p_com_op_unexp_rec.routing_sequence_id
       , p_operation_type            =>  p_com_operation_rec.operation_type
       , p_mesg_token_tbl            =>  l_mesg_token_tbl
       , x_com_operation_rec         =>  x_old_com_operation_rec
       , x_com_op_unexp_rec          =>  x_old_com_op_unexp_rec
       , x_mesg_token_tbl            =>  l_mesg_token_tbl
       , x_return_status             =>  l_return_status
       ) ;

            IF l_return_status = BOM_Rtg_Globals.G_RECORD_FOUND AND
               p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
            THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'BOM_OP_ALREADY_EXISTS'
                     , p_token_tbl      => l_token_tbl
                     ) ;
                    l_return_status := FND_API.G_RET_STS_ERROR ;

            ELSIF l_return_status = BOM_Rtg_Globals.G_RECORD_NOT_FOUND AND
               p_com_operation_rec.transaction_type IN
                    (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE, BOM_Rtg_Globals.G_OPR_CANCEL)
            THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'BOM_OP_DOESNOT_EXIST'
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
                                               || 'Operation Sequences '
                                               || p_com_operation_rec.operation_sequence_number
                     , p_token_tbl          => l_token_tbl
                     ) ;
            ELSE
                    l_return_status := FND_API.G_RET_STS_SUCCESS;
            END IF ;

            x_return_status  := l_return_status;
            x_mesg_token_tbl := l_Mesg_Token_Tbl;

    END Check_Existence;


    /******************************************************************
    * Prcoedure     : Check_Lineage used by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    * Parameters out: Mesg_Token_Tbl
    *                 Return_Status
    * Purpose   : Check_Lineage procedure will verify that the entity
    *             record that the user has passed is for the right
    *             parent and that the parent exists.
    *********************************************************************/
    PROCEDURE Check_Lineage
    ( p_routing_sequence_id       IN   NUMBER
    , p_operation_sequence_number IN   NUMBER
    , p_effectivity_date          IN   DATE
    , p_operation_type            IN   NUMBER
    , p_revised_item_sequence_id  IN   NUMBER
    , x_mesg_token_tbl            IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
    , x_return_status             IN OUT NOCOPY  VARCHAR2 )

    IS

        CURSOR l_ger_rev_op_cur( p_routing_sequence_id       NUMBER
                               , p_operation_sequence_number NUMBER
                               , p_effectivity_date          DATE
                               , p_operation_type            NUMBER )
        IS

        SELECT revised_item_sequence_id
        FROM  BOM_OPERATION_SEQUENCES
        WHERE NVL(OPERATION_TYPE, 1)  = NVL(p_operation_type , 1)
        AND   OPERATION_SEQ_NUM       = p_operation_sequence_number
        AND   EFFECTIVITY_DATE = p_effectivity_date   -- Changed for bug 2647027
--      AND   TRUNC(EFFECTIVITY_DATE) = TRUNC(p_effectivity_date)
        AND   routing_sequence_id     = p_routing_sequence_id
        ;

        l_return_status     VARCHAR2(1);
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
        l_err_text          VARCHAR(2000) ;

    BEGIN
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        /*************************************************************
        --
        -- In case of an update, based on the revised item information
        -- Routing Sequence Id and Revised Item Sequence Id is queried from
        -- the database. The revised item sequence id can however be
        -- different from that in the database and should be checked
        -- and given an error.
        *************************************************************/
        FOR l_get_rev_op_rec IN l_ger_rev_op_cur
                   ( p_routing_sequence_id       => p_routing_sequence_id
                   , p_operation_sequence_number => p_operation_sequence_number
                   , p_effectivity_date          => p_effectivity_date
                   , p_operation_type            => p_operation_type )
        LOOP
           IF NVL(l_get_rev_op_rec.revised_item_sequence_id, 0) <>
                NVL(p_revised_item_sequence_id,0)
           THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END LOOP;

        x_return_status  := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;

    EXCEPTION
       WHEN OTHERS THEN

          l_err_text := G_PKG_NAME || ' Validation (Check Lineage) '
                                || substrb(SQLERRM,1,200);
--        dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;


    END Check_Lineage;


    /******************************************************************
    * Prcoedure     : Check_CommonRtg used by ECO Bo and Rtg Bo
    * Parameters IN : Routing Sequence Id
    * Parameters out: Mesg_Token_Tbl
    *                 Return_Status
    * Purpose   : Check_CommonRtg procedure will verify that the parent
    *             routing does not have a common.
    *********************************************************************/

   PROCEDURE Check_CommonRtg
   (  p_routing_sequence_id        IN  NUMBER
   ,  x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   ,  x_return_status              IN OUT NOCOPY VARCHAR2
   )
   IS

     CURSOR l_get_common_cur (p_routing_sequence_id NUMBER) IS
        SELECT 'common exists'
        FROM  bom_operational_routings
        WHERE common_routing_sequence_id <> routing_sequence_id
        AND   routing_sequence_id = p_routing_sequence_id ;


        l_Token_Tbl         Error_Handler.Token_Tbl_Type ;
        l_return_status     VARCHAR2(1) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;
        l_err_text          VARCHAR(2000) ;

    BEGIN
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        FOR l_get_common_rec IN l_get_common_cur(p_routing_sequence_id)
        LOOP
              l_return_status := FND_API.G_RET_STS_ERROR ;
        END LOOP;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;

    EXCEPTION
       WHEN OTHERS THEN

          l_err_text := G_PKG_NAME || ' Validation (Check CommonRouting) '
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

    END Check_CommonRtg ;


    /******************************************************************
    * Procedure     : Check_Required used by RTG BO
    * Parameters IN : Operation exposed column record
    * Parameters out: Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Routing Operation to Common Operation and
    *                 Call Check_Required for Common Operation.
    *
    *********************************************************************/
    PROCEDURE Check_Required
    ( p_operation_rec       IN  Bom_Rtg_Pub.Operation_Rec_Type
    , x_return_status       IN OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    )

    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

        p_op_unexp_rec           Bom_Rtg_Pub.Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
        (  p_rtg_operation_rec      => p_operation_rec
         , p_rtg_op_unexp_rec       => p_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;

        Bom_Validate_Op_Seq.Check_required
        (  p_com_operation_rec  => l_com_operation_rec
         , x_return_status      => x_return_status
         , x_mesg_token_tbl     => x_mesg_token_tbl
         );

    END Check_Required ;

    /******************************************************************
    * Procedure     : Check_Required used by ECO BO
    * Parameters IN : Operation exposed column record
    * Parameters out: Mesg Token Table
    *                 Return Status
    * Purpose       :  Convert Revised Operation to Common Operation and
    *                 Call Check_Required for Common Operation.
    *
    *********************************************************************/
    PROCEDURE Check_Required
    ( p_rev_operation_rec   IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
    , x_return_status       IN OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    )

    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

        p_rev_op_unexp_rec       Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Revised Operation to Common Operation
        Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
        (  p_rev_operation_rec      => p_rev_operation_rec
         , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;

        Bom_Validate_Op_Seq.Check_required
        (  p_com_operation_rec  => l_com_operation_rec
         , x_return_status      => x_return_status
         , x_mesg_token_tbl     => x_mesg_token_tbl
         );

    END Check_Required ;

    /*****************************************************************
    * Procedure     : Check_Required for Common
    *                          internally called by RTG BO and ECO BO
    * Parameters IN : Revised Operation exposed column record
    * Paramaters out: Return Status
    *                 Mesg Token Table
    * Purpose       : Procedure will check if the user has given all the
    *                 required columns for the type of operation user is
    *                 trying to perform. If the required columns are not
    *                 filled in, then the record would get an error.
    ********************************************************************/
    PROCEDURE Check_Required
    ( p_com_operation_rec   IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
    , x_return_status       IN OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    )
    IS

       l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;
       l_err_text          VARCHAR(2000) ;
       l_Token_Tbl         Error_Handler.Token_Tbl_Type;

    BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
       l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;


       -- ACD_TYPE
       IF ( p_com_operation_rec.acd_type IS NULL OR
            p_com_operation_rec.acd_type = FND_API.G_MISS_NUM
          ) AND
          BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN
          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_OP_ACD_TYPE_MISSING'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          ) ;

          x_return_status := FND_API.G_RET_STS_ERROR ;

       END IF;

       -- Standard Operation Id and Operation Type
       IF ( p_com_operation_rec.operation_type IN (2, 3)
       AND  p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
       AND ( p_com_operation_rec.standard_operation_code IS NULL OR
             p_com_operation_rec.standard_operation_code = FND_API.G_MISS_CHAR )
           )
       THEN
           Error_Handler.Add_Error_Token
           (  p_message_name   => 'BOM_FLM_OP_STDOP_REQUIRED'
            , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
            , p_Token_Tbl      => l_Token_Tbl
           ) ;

          x_return_status := FND_API.G_RET_STS_ERROR ;


       -- Department Code for CREATEs
       ELSIF
         ( p_com_operation_rec.department_code IS NULL OR
            p_com_operation_rec.department_code = FND_API.G_MISS_CHAR
          )
       AND  p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
       AND  NVL(p_com_operation_rec.acd_type, 1)  =  l_ACD_ADD
       AND ( p_com_operation_rec.standard_operation_code IS NULL OR
             p_com_operation_rec.standard_operation_code = FND_API.G_MISS_CHAR )
       AND BOM_Rtg_Globals.Get_CFM_Rtg_Flag <> BOM_Rtg_Globals.G_Lot_Rtg
       THEN
          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_OP_DEPT_REQUIRED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          ) ;

          x_return_status := FND_API.G_RET_STS_ERROR ;

       END IF;


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


    /********************************************************************
    * Procedure : Check_Attributes used by RTG BO
    * Parameters IN : Operation exposed column record
    *                 Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Operation to Common Operation and
    *             Call Check_Attributes for Common.
    *             Check_Attributes will verify the exposed attributes
    *             of the operation record in their own entirety. No
    *             cross entity validations will be performed.
    ********************************************************************/
    PROCEDURE Check_Attributes
    (  p_operation_rec      IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec       IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status      IN OUT NOCOPY VARCHAR2
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

        -- Call Check Attributes procedure
        Bom_Validate_Op_Seq.Check_Attributes
        (  p_com_operation_rec  => l_com_operation_rec
         , p_com_op_unexp_rec   => l_com_op_unexp_rec
         , x_return_status      => x_return_status
         , x_mesg_token_tbl     => x_mesg_token_tbl
         ) ;

    END Check_Attributes ;


    /********************************************************************
    * Procedure : Check_Attributes used by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Convert Revised Operation to Common Operation and
    *             Call Check_Attributes for Common.
    *             Check_Attributes will verify the exposed attributes
    *             of the operation record in their own entirety. No
    *             cross entity validations will be performed.
    ********************************************************************/
    PROCEDURE Check_Attributes
    (  p_rev_operation_rec      IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec       IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
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

        -- Call Check Attributes procedure
        Bom_Validate_Op_Seq.Check_Attributes
        (  p_com_operation_rec  => l_com_operation_rec
         , p_com_op_unexp_rec   => l_com_op_unexp_rec
         , x_return_status      => x_return_status
         , x_mesg_token_tbl     => x_mesg_token_tbl
         ) ;

    END Check_Attributes ;



    /***************************************************************
    * Procedure : Check_Attribute (Validation) for CREATE and UPDATE
    *               internally called by RTG BO and ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Attribute validation procedure will validate each
    *             attribute of operation in its entirety. If
    *             the validation of a column requires looking at some
    *             other columns value then the validation is done at
    *             the Entity level instead.
    *             All errors in the attribute validation are accumulated
    *             before the procedure returns with a Return_Status
    *             of 'E'.
    *********************************************************************/
    PROCEDURE Check_Attributes
    (  p_com_operation_rec  IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec   IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status      IN OUT NOCOPY VARCHAR2
    )
    IS

    l_return_status VARCHAR2(1);
    l_err_text  VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
    l_Token_Tbl         Error_Handler.Token_Tbl_Type;

    BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Set the first token to be equal to the operation sequence number
        l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
        l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;

        --
        -- Check if the user is trying to update a record with
        -- missing value when the column value is required.
        --

        IF p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
        THEN


        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Operation Attr Validation: Missing Value. . . ' || l_return_status) ;
        END IF;

            -- Operation Type
            IF p_com_operation_rec.operation_type = FND_API.G_MISS_NUM
            THEN
            Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_OPTYPE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Department Code
            IF p_com_operation_rec.department_code = FND_API.G_MISS_CHAR
            THEN
            Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_DEPT_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Count Point Type
            IF p_com_operation_rec.count_point_type = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_CNTPOINT_TYPE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Option Dependent Flag
            IF p_com_operation_rec.option_dependent_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_DPTFLAG_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Reference Flag
            IF p_com_operation_rec.reference_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_REFERENCE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Include In RollUp
            IF p_com_operation_rec.include_in_rollup = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_ICDROLLUP_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Op Yild Enabled Flag
            IF p_com_operation_rec.op_yield_enabled_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_YIELDENABLED_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Backfluch Flag
            IF p_com_operation_rec.backflush_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_BKFLUSH_FLAG_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;



            -- Standard Operation Code
            IF p_com_operation_rec.standard_operation_code = FND_API.G_MISS_CHAR
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_STD_OP_NOTUPDATABLE'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;



            -- New Operation Sequence Number
            IF p_com_operation_rec.new_operation_sequence_number = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_SEQNUM_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

            -- New Start  Effective Date for RTG_Bo Only
            IF p_com_operation_rec.new_start_effective_date = FND_API.G_MISS_DATE
               AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_Rtg_BO
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_EFFECTDATE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

        END IF ;

        --
        -- Check if the user is trying to create/update a record with
        -- invalid value.
        --
        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Operation Attr Validation: Invalid Value. . . ' || l_return_status) ;
        END IF;

            -- Start Effective Date
	    /*	Commented entire code for BUG 5282656, as this check is no longer reqd after we started
		allowing past effective operations through BUG 4666512.
            IF    p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
            AND   p_com_operation_rec.start_effective_date < SYSDATE   -- Changed for bug 2647027
--          AND   TRUNC(p_com_operation_rec.start_effective_date) < TRUNC(SYSDATE)
	    AND   nvl(Bom_Globals.get_caller_type(),'') <> 'MIGRATION'  -- Bug 2871039
            AND   BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_Rtg_BO
            THEN
	       IF TRUNC(p_com_operation_rec.start_effective_date) >= TRUNC(SYSDATE) THEN
               /*Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_EFFECTIVE_DATE_PAST'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
	       ELSE Commented for bug 4666512 Also changed the condition to >= instead of <
	          BOM_RTG_Globals.G_Init_Eff_Date_Op_Num_Flag := TRUE; -- Added for bug 2767019
	       END IF;
            END IF ;
	    */


            -- ACD Type
            IF p_com_operation_rec.acd_type IS NOT NULL
               AND p_com_operation_rec.acd_type NOT IN
                    (l_ACD_ADD, l_ACD_CHANGE, l_ACD_DISABLE)
               AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
            THEN

               l_token_tbl(2).token_name  := 'ACD_TYPE';
               l_token_tbl(2).token_value := p_com_operation_rec.acd_type;

               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_ACD_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
               l_return_status := FND_API.G_RET_STS_ERROR ;
               l_token_tbl.DELETE(2)  ;

            END IF ;


            -- Operation Type
            IF   BOM_Rtg_Globals.Get_CFM_Rtg_Flag =  BOM_Rtg_Globals.G_FLOW_RTG
            THEN
               IF (p_com_operation_rec.operation_type IS NULL
                OR p_com_operation_rec.operation_type = FND_API.G_MISS_NUM )
                OR p_com_operation_rec.operation_type NOT IN (1, 2, 3)
               THEN
               -- Flow Routing
                  IF p_com_operation_rec.operation_type <>  FND_API.G_MISS_NUM
                  THEN
                      l_token_tbl(2).token_name  := 'OPERATION_TYPE';
                      l_token_tbl(2).token_value := p_com_operation_rec.operation_type;

                  ELSIF p_com_operation_rec.operation_type IS NULL
                  THEN
                      l_token_tbl(2).token_name  := 'OPERATION_TYPE';
                      l_token_tbl(2).token_value := '';

                  END IF ;

                  Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_FLM_OP_OPTYPE_INVALID'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , p_Token_Tbl          => l_Token_Tbl
                   );
                  l_return_status := FND_API.G_RET_STS_ERROR ;
                  l_token_tbl.DELETE(2)  ;

               END IF ;
            ELSE
               -- Non Flow Routing
               IF  p_com_operation_rec.operation_type IS NOT NULL
               AND p_com_operation_rec.operation_type <>  FND_API.G_MISS_NUM
               AND p_com_operation_rec.operation_type <> 1
               THEN

                  IF p_com_operation_rec.operation_type <>  FND_API.G_MISS_NUM
                  THEN
                      l_token_tbl(2).token_name  := 'OPERATION_TYPE';
                      l_token_tbl(2).token_value := p_com_operation_rec.operation_type;
                  END IF ;

                  Error_Handler.Add_Error_Token
                   (  p_Message_Name       => 'BOM_STD_OP_OPTYPE_INVALID'
                    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                    , p_Token_Tbl          => l_Token_Tbl
                   );
                  l_return_status := FND_API.G_RET_STS_ERROR ;
                  l_token_tbl.DELETE(2)  ;

               END IF ;
            END IF ;


            -- Operation Sequence Number and New Operation Sequence Number
            IF p_com_operation_rec.operation_sequence_number IS NOT NULL
               AND(   p_com_operation_rec.operation_sequence_number <= 0
                   OR p_com_operation_rec.operation_sequence_number > 9999
                   )
            THEN

               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_SEQNUM_LESSTHAN_ZERO'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
            l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;

            IF p_com_operation_rec.new_operation_sequence_number IS NOT NULL
               AND p_com_operation_rec.new_operation_sequence_number <>  FND_API.G_MISS_NUM
               AND (  p_com_operation_rec.new_operation_sequence_number <= 0
                   OR p_com_operation_rec.new_operation_sequence_number > 9999
                   )
            THEN

               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_OP_SEQNUM_LESSTHAN_ZERO'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
               l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF ;

            /*
            -- Moved to BOMRVIDB.pls
            -- Old Operation Sequence Number
            */

            -- Operation Lead Time Percent
            IF  p_com_operation_rec.op_lead_time_percent IS NOT NULL
            AND p_com_operation_rec.op_lead_time_percent <>  FND_API.G_MISS_NUM
            AND (p_com_operation_rec.op_lead_time_percent < 0
                 OR  p_com_operation_rec.op_lead_time_percent > 100 )
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_LT_PERCENT_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Minimum Transfer Quantity
            IF  p_com_operation_rec.minimum_transfer_quantity IS NOT NULL
            AND p_com_operation_rec.minimum_transfer_quantity < 0
            AND p_com_operation_rec.minimum_transfer_quantity <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_MINI_TRANS_QTY_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Count Point Type
            IF  p_com_operation_rec.count_point_type IS NOT NULL
            AND p_com_operation_rec.count_point_type NOT IN (1,2,3)
            AND p_com_operation_rec.count_point_type <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_CNTPOINT_TYPE_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;



            -- Backflush Flag
            IF  p_com_operation_rec.backflush_flag IS NOT NULL
            AND p_com_operation_rec.backflush_flag   NOT IN (1,2)
            AND p_com_operation_rec.backflush_flag <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_BKFLUSH_FLAG_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Option Dependent Flag
            IF  p_com_operation_rec.option_dependent_flag IS NOT NULL
            AND p_com_operation_rec.option_dependent_flag   NOT IN (1,2)
            AND p_com_operation_rec.option_dependent_flag <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_DPTFLAG_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Reference Flag
            IF  p_com_operation_rec.reference_flag IS NOT NULL
            AND p_com_operation_rec.reference_flag   NOT IN (1,2)
            AND p_com_operation_rec.reference_flag <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_REFERENCE_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Include In Rollup
            IF  p_com_operation_rec.include_in_rollup IS NOT NULL
            AND p_com_operation_rec.include_in_rollup   NOT IN (1,2)
            AND p_com_operation_rec.include_in_rollup <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_ICDROLLUP_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Op Yield Enabled Flag
            IF  p_com_operation_rec.op_yield_enabled_flag IS NOT NULL
            AND p_com_operation_rec.op_yield_enabled_flag   NOT IN (1,2)
            AND p_com_operation_rec.op_yield_enabled_flag <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_YILEDENABLED_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Yield
            IF  p_com_operation_rec.yield IS NOT NULL AND
                (p_com_operation_rec.yield <= 0
                 OR p_com_operation_rec.yield > 1 )
            AND  p_com_operation_rec.yield <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_YIELD_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Cumulative Yield
            IF  p_com_operation_rec.cumulative_yield IS NOT NULL AND
                (p_com_operation_rec.cumulative_yield < 0
                 OR p_com_operation_rec.cumulative_yield > 1 )
            AND  p_com_operation_rec.cumulative_yield <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_CUM_YIELD_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Reverse Cumulative Yield
            IF  p_com_operation_rec.reverse_cum_yield IS NOT NULL AND
                (p_com_operation_rec.reverse_cum_yield < 0
                 OR p_com_operation_rec.reverse_cum_yield > 1 )
            AND  p_com_operation_rec.reverse_cum_yield  <>  FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_OP_REVCUM_YIELD_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Net Planning Percent
            IF  p_com_operation_rec.net_planning_percent IS NOT NULL AND
                (p_com_operation_rec.net_planning_percent < 0
                 OR p_com_operation_rec.net_planning_percent > 100 )
            AND p_com_operation_rec.net_planning_percent <> FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_FLM_OP_NETPLNPCT_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

            -- For eAM enhancement
            -- Shutdown Type
            IF  p_com_operation_rec.shutdown_type IS NOT NULL
            AND p_com_operation_rec.shutdown_type <> FND_API.G_MISS_CHAR
            AND BOM_Rtg_Globals.Get_Eam_Item_Type =  BOM_Rtg_Globals.G_ASSET_ACTIVITY
            AND NOT Bom_Rtg_Eam_Util.CheckShutdownType
                    (p_shutdown_type => p_com_operation_rec.shutdown_type )
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                   Error_Handler.Add_Error_Token
                   ( p_Message_Name   => 'BOM_EAM_SHUTDOWN_TYPE_INVALID'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_Token_Tbl      => l_Token_Tbl
                   ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

	    -- BUG 5330942
	    -- Validation to ensure that a pending routing header cannot be modified without an ECO
	    IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
	       Error_Handler.Write_Debug ('Checking if the Routing header is implemented . . .') ;
	    END IF;

	    IF BOM_RTG_GLOBALS.Get_Routing_Header_ECN(p_com_op_unexp_rec.Routing_Sequence_Id) IS NOT NULL
	       AND (p_com_operation_rec.eco_name IS NULL OR p_com_operation_rec.eco_name = FND_API.G_MISS_CHAR)
	    THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
		   l_Token_Tbl(1).token_name  := 'ALTERNATE';
		   l_Token_Tbl(1).token_value  := nvl(p_com_operation_rec.Alternate_Routing_Code, bom_globals.retrieve_message('BOM', 'BOM_PRIMARY'));
		   l_Token_Tbl(2).token_name  := 'ASSY_ITEM';
		   l_Token_Tbl(2).token_value  := p_com_operation_rec.Revised_Item_Name;
		   l_Token_Tbl(3).token_name  := 'CHANGE_NOTICE';
		   l_Token_Tbl(3).token_value  := BOM_RTG_GLOBALS.Get_Routing_Header_ECN(p_com_op_unexp_rec.Routing_Sequence_Id);

                   Error_Handler.Add_Error_Token
                   ( p_Message_Name   => 'BOM_RTG_HEADER_UNIMPLEMENTED'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                   l_return_status := FND_API.G_RET_STS_ERROR;
               END IF ;
	    END IF;

       --  Done validating attributes
        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Operation Attr Validation completed with return_status: ' || l_return_status) ;
        END IF;

       x_return_status := l_return_status;
       x_mesg_token_tbl := l_Mesg_Token_Tbl;

    EXCEPTION
       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
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

    /******************************************************************
    * Procedure     : Check_Conditionally_Required used by RTG BO
    * Parameters IN : Operation exposed column record
    *                 Operation Unexposed column record
    * Parameters out: Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Routing Operation to Common Operation and
    *                 Call Check_Required for Common.
    *
    *********************************************************************/
    PROCEDURE Check_Conditionally_Required
    ( p_operation_rec       IN  Bom_Rtg_Pub.Operation_Rec_Type
    , p_op_unexp_rec        IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
    , x_return_status       IN OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
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

        Bom_Validate_Op_Seq.Check_Conditionally_Required
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

    END Check_Conditionally_Required ;

    /******************************************************************
    * Procedure     : Check_Conditionally_Required used by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation Unexposed column record
    * Parameters out: Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Revised Operation to Common Operation and
    *                 Call Check_Required for Common.
    *
    *********************************************************************/
    PROCEDURE Check_Conditionally_Required
    ( p_rev_operation_rec   IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
    , p_rev_op_unexp_rec    IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
    , x_return_status       IN OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
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

        Bom_Validate_Op_Seq.Check_Conditionally_Required
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

    END Check_Conditionally_Required ;

    /*****************************************************************
    * Procedure     : Check_Conditionally_Required for Common
    *                           internally called by RTG BO and ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation Unexposed column record
    * Paramaters out: Return Status
    *                 Mesg Token Table
    * Purpose       : Check Conditionally Required Columns
    *
    ********************************************************************/
    PROCEDURE Check_Conditionally_Required
    ( p_com_operation_rec   IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
    , p_com_op_unexp_rec    IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
    , x_return_status       IN OUT NOCOPY VARCHAR2
    , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    )
    IS

       l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;
       l_err_text          VARCHAR(2000) ;
       l_token_tbl      Error_Handler.Token_Tbl_Type;

    BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
       l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;

       /* Moved to Check_Required
       -- Standard Operation Id and Operation Type
       */

       -- Return the message table.
       x_mesg_token_tbl := l_Mesg_Token_Tbl ;


    EXCEPTION
       WHEN OTHERS THEN

          l_err_text := G_PKG_NAME || ' Validation (Check Conditionally Required) '
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

    END Check_Conditionally_Required ;


    /******************************************************************
    * Procedure     : Check_NonOperated_Attribute used by RTG BO
    * Parameters IN : Operation exposed column record
    *                 Operation unexposed column record
    * Parameters out: Operation exposed column record
    *                 Operation unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Routing Operation to Common Operation and
    *                 Call Check_NonOperated_Attribute for common opeartion
    *                 After calling Check_NonOperated_Attribute,
    *                 convert Common record back to Routing Operation Record
    *
    *********************************************************************/
    PROCEDURE Check_NonOperated_Attribute
    (  p_operation_rec        IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec         IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
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


        -- Call Check_NonOperated_Attribute
        Bom_Validate_Op_Seq.Check_NonOperated_Attribute
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_com_operation_rec     => l_com_operation_rec
         , x_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

        -- Convert old Eco Opeartion Record back to Routing Operation
        Bom_Rtg_Pub.Convert_ComOp_To_RtgOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rtg_operation_rec      => x_operation_rec
         , x_rtg_op_unexp_rec       => x_op_unexp_rec
         ) ;

    END Check_NonOperated_Attribute ;


    /******************************************************************
    * Procedure     : Check_NonOperated_Attribute used by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    * Parameters out: Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Revised Operation to Common Operation and
    *                 Call Check_NonOperated_Attribute for common opeartion
    *                 After calling Check_NonOperated_Attribute,
    *                 convert Common record back to Revised Operation Record
    *
    *********************************************************************/
    PROCEDURE Check_NonOperated_Attribute
    (  p_rev_operation_rec        IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec         IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_rev_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
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

        -- Call Check_NonOperated_Attribute
        Bom_Validate_Op_Seq.Check_NonOperated_Attribute
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_com_operation_rec     => l_com_operation_rec
         , x_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

        -- Convert the Common record to Revised Operation record
        Bom_Rtg_Pub.Convert_ComOp_To_EcoOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rev_operation_rec      => x_rev_operation_rec
         , x_rev_op_unexp_rec       => x_rev_op_unexp_rec
         ) ;

    END Check_NonOperated_Attribute ;


    /******************************************************************
    * Procedure     : Check_NonOperated_Attribute for Common
    *                            internally called by RTG BO and ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Common Operation exposed column record
    *                 Common Operation unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Check_NonOperated_Attribute will check parent routing's
    *                 CFM Routing Flag and if non-operated column is null.
    *                 If so, the procedure set the values to Null and
    *                 and warning messages
    *
    *********************************************************************/
    PROCEDURE Check_NonOperated_Attribute
    (  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_com_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    )
    IS

    l_return_status     VARCHAR2(1);
    l_err_text          VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
    l_token_tbl         Error_Handler.Token_Tbl_Type;

    l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
    l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN

       l_return_status := FND_API.G_RET_STS_SUCCESS;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Peforming the Operation Check NonOperated Attr . . .')  ;
       END IF ;

       --  Initialize operation exp and unexp record
       l_com_operation_rec  := p_com_operation_rec ;
       l_com_op_unexp_rec   := p_com_op_unexp_rec ;

       -- Set the first token to be equal to the operation sequence number
       l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
       l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;

       --
       -- Following Fields are available in only Flow Routing.
       --
       -- Start Effective Date and Disable Date
       IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag =  BOM_Rtg_Globals.G_FLOW_RTG
           AND l_com_operation_rec.operation_type IN (l_PROCESS, l_LINE_OP))
       AND((l_com_operation_rec.start_effective_date IS NOT NULL OR
            l_com_operation_rec.start_effective_date <> FND_API.G_MISS_DATE)
            OR
           (l_com_operation_rec.disable_date IS NOT NULL OR
            l_com_operation_rec.disable_date <> FND_API.G_MISS_DATE)
            OR
           (l_com_operation_rec.New_Start_Effective_Date IS NOT NULL OR
            l_com_operation_rec.New_Start_Effective_Date <> FND_API.G_MISS_DATE)
            )
       THEN

          l_com_operation_rec.start_effective_date := '' ;
          l_com_operation_rec.new_start_effective_date := '' ;
          l_com_operation_rec.disable_date := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_FLOW_OP_DATE_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;


       -- Process Seq Num and Code
       IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag <>  BOM_Rtg_Globals.G_FLOW_RTG
            OR (BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_FLOW_RTG
                AND l_com_operation_rec.operation_type IN (l_PROCESS, l_LINE_OP))
          )
       AND
          (l_com_operation_rec.process_seq_number IS NOT NULL OR
           l_com_operation_rec.process_seq_number <> FND_API.G_MISS_NUM)
       THEN

          l_com_operation_rec.process_seq_number := '' ;
          l_com_op_unexp_rec.Process_Op_Seq_Id := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_PRCSEQNUM_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;

       IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag <>  BOM_Rtg_Globals.G_FLOW_RTG
            OR (BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_FLOW_RTG
                AND l_com_operation_rec.operation_type IN (l_PROCESS, l_LINE_OP))
          )
       AND
          (l_com_operation_rec.process_code IS NOT NULL OR
           l_com_operation_rec.process_code <> FND_API.G_MISS_CHAR)
       THEN

          l_com_operation_rec.process_code := '' ;
          l_com_op_unexp_rec.Process_Op_Seq_Id := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_PRCCODE_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;

       -- Line Op Num and Code
       IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag <>  BOM_Rtg_Globals.G_FLOW_RTG
            OR (BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_FLOW_RTG
                AND l_com_operation_rec.operation_type IN (l_PROCESS, l_LINE_OP))
          )
       AND
          (l_com_operation_rec.line_op_seq_number IS NOT NULL OR
           l_com_operation_rec.line_op_seq_number <> FND_API.G_MISS_NUM)
       THEN

          l_com_operation_rec.line_op_seq_number := '' ;
          l_com_op_unexp_rec.line_op_seq_Id := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_LNOPSEQNUM_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;

       IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag <>  BOM_Rtg_Globals.G_FLOW_RTG
            OR (BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_FLOW_RTG
                AND l_com_operation_rec.operation_type IN (l_PROCESS, l_LINE_OP))
          )
       AND
           ( l_com_operation_rec.line_op_code IS NOT NULL OR
             l_com_operation_rec.line_op_code <> FND_API.G_MISS_CHAR )
       THEN

          l_com_operation_rec.line_op_code := '' ;
          l_com_op_unexp_rec.line_op_seq_Id := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_LNOPCODE_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;


       -- User_Labor_Time
       IF  BOM_Rtg_Globals.Get_CFM_Rtg_Flag <>  BOM_Rtg_Globals.G_FLOW_RTG AND
           ( l_com_operation_rec.user_labor_time <> 0 AND
             (l_com_operation_rec.user_labor_time IS NOT NULL OR
              l_com_operation_rec.user_labor_time <> FND_API.G_MISS_NUM ))
       THEN

          l_com_operation_rec.user_labor_time := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_USERLABTIME_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;

       -- User_Machine_Time
       IF  BOM_Rtg_Globals.Get_CFM_Rtg_Flag <>  BOM_Rtg_Globals.G_FLOW_RTG AND
           ( l_com_operation_rec.user_machine_time <> 0 AND
             (l_com_operation_rec.user_machine_time IS NOT NULL OR
              l_com_operation_rec.user_machine_time <> FND_API.G_MISS_NUM ))
       THEN

          l_com_operation_rec.user_machine_time := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_USERMCTIME_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;


       /* Comment Out Following calc op times columns adn user elapsed time
       -- Calculated_Labor_Time
       -- Calculated_Machine_Time
       -- Calculated_Elapsed_Time
       -- User_Elapsed_Time
       */  -- End of Comment out


       -- Net_Planning_Percent
       IF  BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_STD_RTG AND
           ( l_com_operation_rec.net_planning_percent IS NOT NULL OR
             l_com_operation_rec.net_planning_percent <> FND_API.G_MISS_NUM )
       THEN

          l_com_operation_rec.net_planning_percent := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_NETPLNPCT_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;


       --
       -- Following Fields are available in only Lot Based Routing.
       --

       -- Include_In_Rollup
        IF  BOM_Rtg_Globals.Get_CFM_Rtg_Flag NOT IN  (BOM_Rtg_Globals.G_LOT_RTG, BOM_Rtg_Globals.G_STD_RTG) AND
	/*Bug 6523550 even for standard routings the value shouldnt be defaulted to 1*/
           ( l_com_operation_rec.include_in_rollup IS NOT NULL OR
             l_com_operation_rec.include_in_rollup <> FND_API.G_MISS_NUM )
       AND  l_com_operation_rec.include_in_rollup <> 1 -- Not default. Bug1744254
       THEN

          l_com_operation_rec.include_in_rollup := 1 ; -- Set default 1. Bug1744254

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_ICDROLLUP_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;

       -- Op_Yield_Enabled_Flag
       IF  BOM_Rtg_Globals.Get_CFM_Rtg_Flag <> BOM_Rtg_Globals.G_LOT_RTG AND
           ( l_com_operation_rec.op_yield_enabled_flag IS NOT NULL OR
             l_com_operation_rec.op_yield_enabled_flag <> FND_API.G_MISS_NUM )
       AND  l_com_operation_rec.op_yield_enabled_flag <> 1 -- Not default. Bug1744254
       THEN

          l_com_operation_rec.op_yield_enabled_flag := 1 ; -- Set default 1. Bug1744254

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_YLD_ENABLED_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;


       --
       -- Following Fields are not available in Flow Routing.
       -- And In Std Routing, The Values in Yield and Cum Yield would be
       -- ignored if Profile MRP: i2 Check if FP installed is not Yes.
       --


       /* Comment Out because followings are based on Routing OIF program
       -- Yield
       -- Cumulative_Yield
       -- Reverse_CUM_Yield
       -- End of Comment Out */

       -- Yield
       IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag =  BOM_Rtg_Globals.G_STD_RTG  AND
           ( l_com_operation_rec.yield IS NOT NULL OR
             l_com_operation_rec.yield <> FND_API.G_MISS_NUM )
       THEN
          /*IF NVL(FND_PROFILE.VALUE('MRP_I2_P_CHECK_FOR_FP'), 'N') <> 'Y'	-- BUG 4729535
          THEN
             l_com_operation_rec.yield := '' ;

             Error_Handler.Add_Error_Token
             ( p_message_name       => 'BOM_STD_OP_YIELD_IGNORED'
             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
             , p_Token_Tbl          => l_Token_Tbl
             , p_message_type       => 'W'
             ) ;
          END IF ;*/
	  NULL;


       END IF ;

       -- Cumulative_Yield
       IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag =  BOM_Rtg_Globals.G_STD_RTG  AND
           ( l_com_operation_rec.cumulative_yield IS NOT NULL OR
             l_com_operation_rec.cumulative_yield <> FND_API.G_MISS_NUM )
       THEN
	  NULL;
          /*IF NVL(FND_PROFILE.VALUE('MRP_I2_P_CHECK_FOR_FP'), 'N') <> 'Y'	-- BUG 4729535
          THEN
             l_com_operation_rec.cumulative_yield := '' ;

             Error_Handler.Add_Error_Token
             ( p_message_name       => 'BOM_STD_OP_CUM_YIELD_IGNORED'
             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
             , p_Token_Tbl          => l_Token_Tbl
             , p_message_type       => 'W'
             ) ;
          END IF ;*/
       END IF ;

       -- Reverse_CUM_Yield
       IF  BOM_Rtg_Globals.Get_CFM_Rtg_Flag =  BOM_Rtg_Globals.G_STD_RTG AND
           ( l_com_operation_rec.reverse_cum_yield IS NOT NULL OR
             l_com_operation_rec.reverse_cum_yield  <> FND_API.G_MISS_NUM )
       THEN

          l_com_operation_rec.reverse_cum_yield  := '' ;

          Error_Handler.Add_Error_Token
          ( p_message_name       => 'BOM_STD_OP_REVCUM_YLD_IGNORED'
          , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
          , p_Token_Tbl          => l_Token_Tbl
          , p_message_type       => 'W'
          ) ;
       END IF ;


       -- For eAM enhancement
       -- Followings are not operated in maintenance routings for eAM
       -- and Shutdown Type is only for maintenance routings for eAM
       IF  BOM_Rtg_Globals.Get_Eam_Item_Type =  BOM_Rtg_Globals.G_ASSET_ACTIVITY
       THEN
            -- BACKFLUSH_FLAG and MINIMUM_TRANSFER_QUANTITY
            -- are not enterable in maintenance routings for eAM

            IF  (  NVL(l_com_operation_rec.Minimum_Transfer_Quantity,0)  <> 0 OR
                   l_com_operation_rec.Minimum_Transfer_Quantity <> FND_API.G_MISS_NUM )
            OR  (  NVL(l_com_operation_rec.Backflush_Flag,1)  <> 1  OR
                   l_com_operation_rec.Backflush_Flag <> FND_API.G_MISS_NUM )
            THEN

               l_com_operation_rec.Minimum_Transfer_Quantity := 0 ;
               l_com_operation_rec.Backflush_Flag := 1 ;

               Error_Handler.Add_Error_Token
               ( p_message_name       => 'BOM_EAM_WIP_ATTR_IGNORED'
               , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , p_Token_Tbl          => l_Token_Tbl
               , p_message_type       => 'W'
               ) ;

            END IF ;

       ELSE

           -- Shutdown Type is not operated in other routings
           IF  ( l_com_operation_rec.shutdown_type IS NOT NULL OR
                 l_com_operation_rec.shutdown_Type <> FND_API.G_MISS_CHAR )
           THEN

               l_com_operation_rec.shutdown_Type := '' ;

               Error_Handler.Add_Error_Token
               ( p_message_name       => 'BOM_EAM_SHUTDOWN_TYPE_IGNORED'
               , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , p_Token_Tbl          => l_Token_Tbl
               , p_message_type       => 'W'
               ) ;


           END IF ;
--- Added for long description project (Bug 2689249)
	   -- Long description is not used by other routings
           IF  ( l_com_operation_rec.long_description IS NOT NULL OR
                 l_com_operation_rec.long_description <> FND_API.G_MISS_CHAR )
           THEN

               l_com_operation_rec.long_description := '' ;
               Error_Handler.Add_Error_Token
               ( p_message_name       => 'BOM_EAM_LONG_DESC_IGNORED'
               , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
               , p_Token_Tbl          => l_Token_Tbl
               , p_message_type       => 'W'
               ) ;

           END IF ;

       END IF ;


       --  Return operation exp and unexp record
       x_com_operation_rec  := l_com_operation_rec ;
       x_com_op_unexp_rec   := l_com_op_unexp_rec ;

       -- Return the status and message table.
       x_return_status  := l_return_status ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

    EXCEPTION
       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Check NonOperated Attr. . . .' || SQLERRM );
          END IF ;


          l_err_text := G_PKG_NAME || ' Validation (NonOperated Attr.) '
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

          --  Return operation exp and unexp record
          x_com_operation_rec  := l_com_operation_rec ;
          x_com_op_unexp_rec   := l_com_op_unexp_rec ;


    END Check_NonOperated_Attribute ;


    /******************************************************************
    * Procedure : Check_Ref_Std_Operation internally
    *                     called by RTG BO and by ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    *                 Common Old Operation exposed column record
    *                 Common Old Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Check_Ref_Operation validate Reference flag and
    *                 Standard Operation. If Std Op is not null
    *                 Set Standard Operation infor to exposed and unexposed
    *                 coulumns regarding reference flag
    **********************************************************************/
    PROCEDURE Check_Ref_Std_Operation
    (  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_old_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_old_com_op_unexp_rec     IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_control_rec              IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_com_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    )
   IS
    -- Variables
    --l_std_op_found      BOOLEAN ; -- Indicate Std OP is found
    l_copy_std_op       BOOLEAN ; -- Indicate Copy Std Op has been proceeded
    l_std_op_invalid    BOOLEAN ; -- Indicate Std OP is invalid

    l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type;
    l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type;

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_token_tbl       Error_Handler.Token_Tbl_Type;

    -- Exception
    EXIT_CHECK_REF_STD_OP EXCEPTION ;

    -- Check if the operatin already has resources
    CURSOR l_exist_res_cur (p_op_seq_id NUMBER)
    IS
       SELECT 'Resource Exist'
       FROM   DUAL
       WHERE EXISTS ( SELECT NULL
                      FROM   BOM_OPERATION_RESOURCES
                      WHERE  operation_sequence_id = p_op_seq_id
                    ) ;

    CURSOR c_std_sub_res (p_std_op_id NUMBER)
    IS
       SELECT 'Sub Resources Exist'
       FROM  DUAL
       WHERE EXISTS (SELECT NULL
                     FROM  BOM_STD_SUB_OP_RESOURCES
                     WHERE standard_operation_id = p_std_op_id
		     AND Schedule_Seq_Num IS NULL); -- Bug 7370692

    -- Get Standard Operation Info.
    CURSOR l_stdop_csr(   p_std_op_id      NUMBER
                        , p_op_type        NUMBER
                        , p_rtg_seq_id     NUMBER
                        , p_org_id         NUMBER
                        , p_dept_id        NUMBER
                        , p_rit_seq_id     NUMBER
                      )
    IS
       SELECT  'Std Op Invalid'
       FROM DUAL
       WHERE NOT EXISTS  (SELECT NULL
                          FROM     BOM_STANDARD_OPERATIONS  bso
                                 , bom_operational_routings bor
                          WHERE   NVL(bso.operation_type,1 )
                                  = DECODE(   p_op_type, FND_API.G_MISS_NUM, 1
                                            , NVL(p_op_type, 1))
                          AND     NVL(bso.line_id, FND_API.G_MISS_NUM)
                                  = NVL(bor.line_id, FND_API.G_MISS_NUM)
                          AND    bor.routing_sequence_id   = p_rtg_seq_id
                          AND    bso.department_id         = p_dept_id
                          AND    bso.organization_id       = p_org_id
                          AND    bso.standard_operation_id = p_std_op_id
                          UNION
                          SELECT  NULL
                          FROM     BOM_STANDARD_OPERATIONS  bso
                                 , ENG_REVISED_ITEMS        eri
                          WHERE   NVL(bso.operation_type, 1)
                                  = DECODE( p_op_type, FND_API.G_MISS_NUM, 1
                                          , NVL(p_op_type, 1 ) )
                          -- AND     NVL(bso.line_id, FND_API.G_MISS_NUM)
                          --                      = NVL(eri.line_id, FND_API.G_MISS_NUM)
                          -- AND    BOM_Rtg_Globals.Get_Routing_Sequence_Id   IS NULL
                          AND    NOT EXISTS -- Added for bug 3578057, to check if it is a new routing being created through the ECO
                                 (SELECT 1 FROM BOM_OPERATIONAL_ROUTINGS
                                  WHERE routing_sequence_id = p_rtg_seq_id)
                          AND    eri.revised_item_sequence_id  = p_rit_seq_id
                          AND    bso.department_id         = p_dept_id
                          AND    bso.organization_id       = p_org_id
                          AND    bso.standard_operation_id = p_std_op_id
                         )  ;
    BEGIN

          --  Initialize operation exp and unexp record
          l_com_operation_rec  := p_com_operation_rec ;
          l_com_op_unexp_rec   := p_com_op_unexp_rec ;

          -- Set the first token to be equal to the operation sequence number
          l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
          l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;

          l_return_status            := FND_API.G_RET_STS_SUCCESS;

          --
          -- Standard Operation is not updatable
          --
          IF (  l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_UPDATE
                OR ( l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
                     AND l_com_operation_rec.acd_type = l_ACD_CHANGE )
             )
          AND (  NVL(p_old_com_op_unexp_rec.standard_operation_id, FND_API.G_MISS_NUM ) <>
                 NVL(l_com_op_unexp_rec.standard_operation_id, FND_API.G_MISS_NUM )
               )
          THEN
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN

                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_OP_STD_OP_NOTUPDATABLE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
              END IF ;
              l_return_status := FND_API.G_RET_STS_ERROR ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Std operation is not updatable. Return Status is  '|| l_return_status  ) ;
END IF ;

              RAISE  EXIT_CHECK_REF_STD_OP ;

          END IF ;

          --
          -- Entities of a referenced operation is not updatable -- Added for bug 2762681
          --
          IF (  l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_UPDATE
                OR ( l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
                     AND l_com_operation_rec.acd_type = l_ACD_CHANGE )
             )
          AND ( l_com_operation_rec.reference_flag = 1
              )
          THEN
              IF (nvl(p_old_com_operation_rec.Minimum_Transfer_Quantity,-1) <>
	          nvl(l_com_operation_rec.Minimum_Transfer_Quantity,-1))
	      THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		   Error_Handler.Add_Error_Token
		   (  p_message_name   => 'BOM_STD_MTQ_NOT_UPDATABLE'
		    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , p_Token_Tbl      => l_Token_Tbl
		   ) ;
		END IF ;
		l_return_status := FND_API.G_RET_STS_ERROR ;
	      END IF;

              IF (p_old_com_operation_rec.Count_Point_Type <> l_com_operation_rec.Count_Point_Type)
	      THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		   Error_Handler.Add_Error_Token
		   (  p_message_name   => 'BOM_STD_CPT_NOT_UPDATABLE'
		    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , p_Token_Tbl      => l_Token_Tbl
		   ) ;
		END IF ;
		l_return_status := FND_API.G_RET_STS_ERROR ;
	      END IF;

              IF (p_old_com_operation_rec.Backflush_Flag <> l_com_operation_rec.Backflush_Flag)
	      THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		   Error_Handler.Add_Error_Token
		   (  p_message_name   => 'BOM_STD_BFF_NOT_UPDATABLE'
		    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , p_Token_Tbl      => l_Token_Tbl
		   ) ;
		END IF ;
		l_return_status := FND_API.G_RET_STS_ERROR ;
	      END IF;

              IF (p_old_com_operation_rec.Option_Dependent_Flag <> l_com_operation_rec.Option_Dependent_Flag)
	      THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		   Error_Handler.Add_Error_Token
		   (  p_message_name   => 'BOM_STD_ODF_NOT_UPDATABLE'
		    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , p_Token_Tbl      => l_Token_Tbl
		   ) ;
		END IF ;
		l_return_status := FND_API.G_RET_STS_ERROR ;
	      END IF;

              IF (nvl(p_old_com_operation_rec.Operation_Description,'None') <>
	          nvl(l_com_operation_rec.Operation_Description,'None'))
	      THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		   Error_Handler.Add_Error_Token
		   (  p_message_name   => 'BOM_STD_OPD_NOT_UPDATABLE'
		    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , p_Token_Tbl      => l_Token_Tbl
		   ) ;
		END IF ;
		l_return_status := FND_API.G_RET_STS_ERROR ;
	      END IF;

              IF (nvl(p_old_com_operation_rec.Long_Description,'NONE') <>
	          nvl(l_com_operation_rec.Long_Description,'NONE'))
	      THEN
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN

		   Error_Handler.Add_Error_Token
		   (  p_message_name   => 'BOM_STD_LD_NOT_UPDATABLE'
		    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
		    , p_Token_Tbl      => l_Token_Tbl
		   ) ;
		END IF ;
		l_return_status := FND_API.G_RET_STS_ERROR ;
	      END IF;

              RAISE  EXIT_CHECK_REF_STD_OP ;

          END IF ;

          --
          -- Standard Operation has changed to not null value
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND (( NVL(p_old_com_op_unexp_rec.standard_operation_id, -1) <>
                 NVL(l_com_op_unexp_rec.standard_operation_id, -1)
                 AND(p_old_com_op_unexp_rec.standard_operation_id <> FND_API.G_MISS_NUM
                     OR p_old_com_op_unexp_rec.standard_operation_id IS NULL)
               ) OR
               ( p_old_com_op_unexp_rec.standard_operation_id = FND_API.G_MISS_NUM
                 AND ( l_com_op_unexp_rec.standard_operation_id IS NOT NULL
                       AND l_com_op_unexp_rec.standard_operation_id <> FND_API.G_MISS_NUM )
               ))
          THEN

             --
             -- Check if the operation already has resources
             --
             l_copy_std_op   := TRUE ;
             FOR l_exist_res_rec IN l_exist_res_cur
                  (  p_op_seq_id  => l_com_op_unexp_rec.operation_sequence_id )
             LOOP
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_OP_CANNOT_COPY_STD_OP'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;
                l_copy_std_op   := FALSE ;
             END LOOP ;


             IF l_com_operation_rec.acd_type = l_ACD_CHANGE
             THEN
                  FOR l_exist_res_rec IN l_exist_res_cur
                  (  p_op_seq_id  => l_com_op_unexp_rec.old_operation_sequence_id )
                  LOOP
                     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_OP_CANNOT_COPY_STD_OP'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                        ) ;
                     END IF ;

                     l_return_status := FND_API.G_RET_STS_ERROR ;
                     l_copy_std_op   := FALSE ;
                  END LOOP ;
             END IF ;


             IF l_copy_std_op
             THEN
                --l_std_op_found := FALSE ;

                --
                -- Get Standard Operatin Information
                --

                FOR l_stdop_rec IN l_stdop_csr
                      (   p_std_op_id  => l_com_op_unexp_rec.standard_operation_id
                        , p_op_type    => l_com_operation_rec.operation_type
                        , p_rtg_seq_id => l_com_op_unexp_rec.routing_sequence_id
                        , p_org_id     => l_com_op_unexp_rec.organization_id
                        , p_dept_id    => l_com_op_unexp_rec.department_id
                        , p_rit_seq_id => l_com_op_unexp_rec.revised_item_sequence_id
                      )
                LOOP

                   -- invalid standard op code
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                       Error_Handler.Add_Error_Token
                       (  p_message_name   => 'BOM_OP_STD_OP_INVALID'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                       ) ;
                   END IF ;

                   l_return_status := FND_API.G_RET_STS_ERROR ;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Std operation is invalid. Return Status is  '|| l_return_status  ) ;
       END IF ;


                END LOOP ;  -- copy standard operation
                FOR l_std_sub_res_rec IN c_std_sub_res (p_std_op_id  => l_com_op_unexp_rec.standard_operation_id)
                LOOP
                  -- The standard operation contains alternate resources
                  -- We need to warn the user to change the schedule sequence number which will be defaulted to 0
                  -- We will also unreference this standard operation as the user still has to enter the SSN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                       Error_Handler.Add_Error_Token
                       (  p_message_name   => 'BOM_SSN_ZERO_VALUE'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                        , p_message_type   => 'W'
                       ) ;
                   END IF ;
                   l_com_operation_rec.reference_flag := 2;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Std operation has alternate resources');
       END IF;
                END LOOP;
             END IF ;
          END IF ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check Reference Standard Operation was processed. . . ' || l_return_status);
END IF ;

       --
       -- Return Common Operation Record
       --
       x_com_operation_rec  := l_com_operation_rec ;
       x_com_op_unexp_rec   := l_com_op_unexp_rec ;

       --
       -- Return Error Status
       --
       x_return_status  := l_return_status;
       x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;


    EXCEPTION
       WHEN EXIT_CHECK_REF_STD_OP THEN

          --
          -- Return Common Operation Record
          --
          x_com_operation_rec  := l_com_operation_rec ;
          x_com_op_unexp_rec   := l_com_op_unexp_rec ;

          --
          -- Return Error Status
          --
          x_return_status  := l_return_status;
          x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Entity Validation(Check Ref Std Op) . . .' || SQLERRM );
          END IF ;


          l_err_text := G_PKG_NAME || ' Validation (Entity Validation(Check Ref Std Op)) '
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

    END Check_Ref_Std_Operation ;



    /*******************************************************************
    * Procedure : Check_Entity used by RTG BO
    * Parameters IN : Operation exposed column record
    *                 Operation unexposed column record
    *                 Old Operation exposed column record
    *                 Old Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Convert Routing Operation to Common Operation and
    *                 Call Check_Entity for Common Operation.
    *                 Procedure will execute the business logic and will
    *                 also perform any required cross entity validations
    *******************************************************************/
    PROCEDURE Check_Entity
    (  p_operation_rec      IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec       IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , p_old_operation_rec  IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_old_op_unexp_rec   IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec      IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status      IN OUT NOCOPY VARCHAR2
    )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
        l_old_com_operation_rec  Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_old_com_op_unexp_rec   Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
        (  p_rtg_operation_rec      => p_operation_rec
         , p_rtg_op_unexp_rec       => p_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;

        -- Also Convert Old Routing Operation to Old Common Operation
        Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
        (  p_rtg_operation_rec      => p_old_operation_rec
         , p_rtg_op_unexp_rec       => p_old_op_unexp_rec
         , x_com_operation_rec      => l_old_com_operation_rec
         , x_com_op_unexp_rec       => l_old_com_op_unexp_rec
        ) ;


        -- Call Check_Entity
        Bom_Validate_Op_Seq.Check_Entity
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_rec           => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , p_old_com_operation_rec => l_old_com_operation_rec
         , p_old_com_op_unexp_rec  => l_old_com_op_unexp_rec
         , x_com_operation_rec     => l_com_operation_rec
         , x_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

        -- Convert the Common record to Routing Record
        Bom_Rtg_Pub.Convert_ComOp_To_RtgOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rtg_operation_rec      => x_operation_rec
         , x_rtg_op_unexp_rec       => x_op_unexp_rec
         ) ;

    END Check_Entity ;


    /*******************************************************************
    * Procedure : Check_Entity used by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    *                 Revised Old Operation exposed column record
    *                 Revised Old Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Convert ECO Operation to Common Operation and
    *                 Call Check_Entity for Common Operation.
    *                 Procedure will execute the business logic and will
    *                 also perform any required cross entity validations
    *******************************************************************/
    PROCEDURE Check_Entity
    (  p_rev_operation_rec        IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec         IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_old_rev_operation_rec    IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_old_rev_op_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_control_rec              IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    )

    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
        l_old_com_operation_rec  Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_old_com_op_unexp_rec   Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Revised Operation to Common Operation
        Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
        (  p_rev_operation_rec      => p_rev_operation_rec
         , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;

        -- Also Convert Old Revised Operation to Old Common Operation
        Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
        (  p_rev_operation_rec      => p_old_rev_operation_rec
         , p_rev_op_unexp_rec       => p_old_rev_op_unexp_rec
         , x_com_operation_rec      => l_old_com_operation_rec
         , x_com_op_unexp_rec       => l_old_com_op_unexp_rec
        ) ;

        -- Call Check_Entity
        Bom_Validate_Op_Seq.Check_Entity
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_rec           => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , p_old_com_operation_rec => l_old_com_operation_rec
         , p_old_com_op_unexp_rec  => l_old_com_op_unexp_rec
         , x_com_operation_rec     => l_com_operation_rec
         , x_com_op_unexp_rec      => l_com_op_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

        -- Convert the Common record to Revised Operation record
        Bom_Rtg_Pub.Convert_ComOp_To_EcoOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rev_operation_rec      => x_rev_operation_rec
         , x_rev_op_unexp_rec       => x_rev_op_unexp_rec
         ) ;

    END Check_Entity ;


    /******************************************************************
    * Procedure : Check_Entity internally called by RTG BO and by ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    *                 Common Old Operation exposed column record
    *                 Common Old Operation unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Check_Entity validate the entity for the correct
    *                 business logic. It will verify the values by running
    *                 checks on inter-dependent columns.
    *                 It will also verify that changes in one column value
    *                 does not invalidate some other columns.
    **********************************************************************/
    PROCEDURE Check_Entity
    (  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_old_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_old_com_op_unexp_rec     IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_control_rec              IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_com_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    )
   IS
    -- Variables
    l_eco_processed     BOOLEAN ; -- Indicate ECO has been processed
    l_bom_item_type     NUMBER ;  -- Bom_Item_Type of Assembly
    l_pto_flag          CHAR ;    -- PTO flag for Assembly
    l_eng_item_flag     CHAR ;    -- Is assembly an Engineering Item
    l_bom_enabled_flag  CHAR ;    -- Assembly's bom_enabled_flag

    l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
    l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    -- Error Handlig Variables
    l_return_status VARCHAR2(1);
    l_temp_return_status VARCHAR2(1);
    l_err_text  VARCHAR2(2000) ;
    l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type ;
    l_temp_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type ;
    l_token_tbl      Error_Handler.Token_Tbl_Type;
    l_err_code  NUMBER;

    -- Get Assembly or Revised Item Attr. Value
    CURSOR   l_item_cur (p_org_id NUMBER, p_item_id NUMBER) IS
       SELECT   bom_item_type
              , pick_components_flag
              , bom_enabled_flag
              , eng_item_flag
       FROM MTL_SYSTEM_ITEMS
       WHERE organization_id   = p_org_id
       AND   inventory_item_id = p_item_id
       ;

    -- Check if Old Op Seq is not implemented
    CURSOR   l_old_op_seq_csr (p_old_op_seq_id NUMBER) IS
       SELECT 'implemented'
       FROM   BOM_OPERATION_SEQUENCES
       WHERE  implementation_date IS NULL
       AND    operation_sequence_id = p_old_op_seq_id
       ;

    -- Check if Rtg is referencing another a rtg as a common
    CURSOR   l_rtg_cur (p_rtg_seq_id NUMBER) IS
       SELECT 'implemented'
       FROM   DUAL
       WHERE  EXISTS ( SELECT NULL
                       FROM bom_operational_routings
                       WHERE  common_routing_sequence_id <> p_rtg_seq_id
                      ) ;

    -- Check if Parent Operation has resource
    CURSOR  l_parents_csr(p_parent_seq_id NUMBER) IS
       SELECT 'resources exist' dummy
       FROM   BOM_OPERATION_RESOURCES
       WHERE  operation_sequence_id = p_parent_seq_id ;


    -- Check if Uniqueness
    CURSOR  l_duplicate_csr( p_op_seq_id      NUMBER
                           , p_rtg_seq_id     NUMBER
                           , p_op_seq_num     NUMBER
                           , p_op_type        NUMBER
                           , p_start_effective_date DATE  )
    IS
       SELECT 'Duplicate Operation'
       FROM   DUAL
       WHERE EXISTS (SELECT NULL
                     FROM BOM_OPERATION_SEQUENCES
                     WHERE  ( (   effectivity_date  = p_start_effective_date   -- Changed for bug 2647027
--                   WHERE  ( (   TRUNC(effectivity_date)  = TRUNC(p_start_effective_date)
                                  AND operation_type = l_EVENT )
                               OR p_op_type <> l_EVENT
                             )
                     AND    NVL(operation_type, l_EVENT) = NVL(p_op_type, l_EVENT)
                     -- AND    implementation_date IS NOT NULL
                     AND    operation_seq_num = p_op_seq_num
                     AND    operation_sequence_id <> p_op_seq_id
                     AND    routing_sequence_id = p_rtg_seq_id
                     ) ;

    /* No Loger Used ----------------------------------------
    -- Check if Uniqueness in unimplemented revised operations
    ----------------------------------------------------------  */

    -- Check if there is no overlapping operations
    CURSOR  l_overlap_csr(   p_op_seq_id      NUMBER
                           , p_rtg_seq_id     NUMBER
                           , p_op_seq_num     NUMBER
                           , p_op_type        NUMBER
                           , p_start_effective_date DATE
                           , p_disable_date         DATE )
    IS
       SELECT 'Overlapping'
       FROM   DUAL
       WHERE EXISTS (SELECT NULL
                     FROM BOM_OPERATION_SEQUENCES
                     WHERE  NVL(operation_type, l_EVENT) = NVL(p_op_type, l_EVENT)
                     AND    ((effectivity_date <
                                   NVL(p_disable_date, p_start_effective_date + 1)
                              AND  NVL(disable_date, p_start_effective_date  + 1)
                                     > p_start_effective_date) --Changed the condition for bug 14286614: when disable_date of one operation is the same as effective date of another it is not a true overlap

                            OR
                            ( p_start_effective_date <
                                   NVL(disable_date, effectivity_date + 1)
                              AND NVL(p_disable_date, effectivity_date+ 1)
                                     > effectivity_date) --Changed the condition for bug 14286614
 /** Changed for bug 2647027  AND    ((TRUNC(effectivity_date) <
                                   NVL(TRUNC(p_disable_date), TRUNC(p_start_effective_date + 1))
                              AND  NVL(TRUNC(disable_date), TRUNC(p_start_effective_date)  + 1)
                                     >= TRUNC(p_start_effective_date))
                            OR
                            ( TRUNC(p_start_effective_date) <
                                   NVL(TRUNC(disable_date) , TRUNC(effectivity_date + 1))
                              AND NVL(TRUNC(p_disable_date) , TRUNC(effectivity_date)+ 1)
                                     >= TRUNC(effectivity_date))
**/                            )
                     AND    implementation_date IS NOT NULL
                     AND    routing_sequence_id = p_rtg_seq_id
                     AND    operation_seq_num = p_op_seq_num
                     AND    operation_sequence_id <> p_op_seq_id
                     ) ;

    -- Check if there is no overlapping revised operations in another eco.
    CURSOR  l_rev_overlap_csr(   p_op_seq_id      NUMBER
                               , p_rtg_seq_id     NUMBER
                               , p_op_seq_num     NUMBER
                               , p_op_type        NUMBER
                               , p_start_effective_date DATE
                               , p_disable_date         DATE )
    IS
       SELECT 'Overlapping'
       FROM   DUAL
       WHERE EXISTS (SELECT NULL
                     FROM BOM_OPERATION_SEQUENCES
                     WHERE  NVL(operation_type, l_EVENT) = NVL(p_op_type, l_EVENT)
                     AND    ((effectivity_date <
                                   NVL(p_disable_date, p_start_effective_date + 1)
                              AND  NVL(disable_date, p_start_effective_date + 1)
                                     >= p_start_effective_date)
                            OR
                            ( p_start_effective_date <
                                   NVL(disable_date, effectivity_date + 1)
                              AND NVL(p_disable_date, effectivity_date+ 1)
                                     >= effectivity_date)
/** Changed for bug 2647027   AND    ((TRUNC(effectivity_date) <
                                   NVL(TRUNC(p_disable_date) , TRUNC(p_start_effective_date + 1))
                              AND  NVL(TRUNC(disable_date) , TRUNC(p_start_effective_date)  + 1)
                                     >= TRUNC(p_start_effective_date))
                            OR
                            ( TRUNC(p_start_effective_date) <
                                   NVL(TRUNC(disable_date) , TRUNC(effectivity_date + 1))
                              AND NVL(TRUNC(p_disable_date) , TRUNC(effectivity_date)+ 1)
                                     >= TRUNC(effectivity_date))
**/                            )
                     AND    implementation_date IS NULL
                     AND    NVL(acd_type, l_ACD_ADD) IN  (l_ACD_ADD, l_ACD_CHANGE)
                     AND    routing_sequence_id = p_rtg_seq_id
                     AND    operation_seq_num = p_op_seq_num
                     AND    operation_sequence_id <> p_op_seq_id
                     ) ;




    -- Check if Department is valid
    CURSOR  l_dept_csr (     p_organization_id      NUMBER
                           , p_dept_id              NUMBER
                           , p_start_effective_date DATE
                       )
    IS
       SELECT 'Dept is invalid'
       FROM   DUAL
       WHERE NOT EXISTS (SELECT NULL
                         FROM  BOM_DEPARTMENTS bd
                         WHERE NVL(TRUNC(bd.disable_date) , TRUNC(p_start_effective_date) + 1)
                                               > TRUNC(p_start_effective_date)
                         AND   bd.organization_id = p_organization_id
                         AND   bd.department_id = p_dept_id
                         ) ;



    -- Added by MK on 02/02/2001
    -- Form has this validation LOV for Operation Sequence Number
    l_eco_for_production NUMBER ;

    CURSOR l_val_old_op_seq_csr
                         ( p_rtg_seq_id         NUMBER ,
                           p_effectivity_date   DATE   ,
                           p_eco_name           VARCHAR2,
                           p_rev_item_seq_id    NUMBER ,
                           p_old_op_seq_id      NUMBER ,
                           p_eco_for_production NUMBER )
    IS
        SELECT 'Old Op Seq is invalid'
        FROM   SYS.DUAL
        WHERE  NOT EXISTS ( SELECT NULL
                            FROM   BOM_OPERATION_SEQUENCES bos
                            WHERE  routing_sequence_id =
                                   ( SELECT  common_routing_sequence_id
                                     FROM    bom_operational_routings bor
                                     WHERE   routing_sequence_id = p_rtg_seq_id
                                   )
                            AND   bos.effectivity_date <= p_effectivity_date
                            AND   NVL(bos.disable_date,p_effectivity_date+1)
                                                 > p_effectivity_date
/** Changed for bug 2647027   AND   TRUNC(bos.effectivity_date) <=
                                                TRUNC(p_effectivity_date)
                            AND   NVL(bos.disable_date,TRUNC(p_effectivity_date)+1)
                                                 > p_effectivity_date
**/                            AND   NVL(bos.disable_date , SYSDATE + 1) > SYSDATE
                            AND   ((    p_eco_for_production = 2
                                    AND NVL(bos.eco_for_production, 2) <> 1
                                    )
                                   OR
                                   (    p_eco_for_production = 1
                                        AND bos.implementation_date IS NOT NULL
                                    )
                                  )
                            AND     NVL(bos.revised_item_sequence_id, -999)
                                                  <> nvl(p_rev_item_seq_id, -100)
                            AND     NOT EXISTS (SELECT NULL
                                                FROM  BOM_OPERATION_SEQUENCES bos2
                                                WHERE bos2.revised_item_sequence_id
                                                      = NVL(p_rev_item_seq_id, -888)
                                                AND decode(bos2.implementation_date,
                                                           null,
                                                           bos2.old_operation_sequence_id,
                                                           bos2.operation_sequence_id) =
                                                    decode(bos.implementation_date,
                                                           null,
                                                           bos.old_operation_sequence_id,
                                                           bos.operation_sequence_id)
                                                )
                            AND   bos.operation_sequence_id = p_old_op_seq_id
                            ) ;
    CURSOR get_ssos_csr (p_rtg_seq_id NUMBER) IS
	SELECT serialization_start_op
	FROM BOM_OPERATIONAL_ROUTINGS
	WHERE routing_sequence_id = p_rtg_seq_id
	AND serialization_start_op IS NOT NULL;

    BEGIN
       --
       -- Initialize Common Record and Status
       --

       l_com_operation_rec  := p_com_operation_rec ;
       l_com_op_unexp_rec   := p_com_op_unexp_rec ;
       l_return_status      := FND_API.G_RET_STS_SUCCESS ;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Performing Operation Check Entitity Validation . . .') ;
       END IF ;


       --
       -- Set the 1st token of Token Table to Revised Operation value
       --
       l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
       l_Token_Tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;



       -- First Query all the attributes for the Assembly item used Entity Validation
       FOR l_item_rec IN l_item_cur(  p_org_id  => l_com_op_unexp_rec.organization_id
                                    , p_item_id => l_com_op_unexp_rec.revised_item_id
                                    )
       LOOP

          l_bom_item_type    := l_item_rec.bom_item_type ;
          l_pto_flag         := l_item_rec.pick_components_flag ;
          l_eng_item_flag    := l_item_rec.eng_item_flag ;
          l_bom_enabled_flag := l_item_rec.bom_enabled_flag ;
       END LOOP ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
       Error_Handler.Write_Debug('Business Object is') ;
       Error_Handler.Write_Debug(BOM_Rtg_Globals.Get_Bo_Identifier) ;
END IF;


       --
       -- Performing Entity Validation in Revised Operatin(ECO BO)
       --
       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Performing Entitity Validation for Eco Routing :ACD Type, Old Op Seq Num, Old Effect Date etc. . .') ;
          END IF;

          --
          -- Check Revised Item Attributes for Revised Operation
          -- For CREATE and ACD Type : Add
          --
          IF l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
            AND ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD ) = l_ACD_ADD )
          THEN

             --
             -- Verify that the Parent has BOM Enabled
             --
             IF l_bom_enabled_flag <> 'Y'
             THEN
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value := l_com_operation_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_RITEM_BOM_NOT_ALLOWED'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
                l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
             END IF ;

             --
             -- Verify that the Parent Item on Routing is not PTO Item
             --
             IF l_pto_flag <> 'N'
             THEN
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value := l_com_operation_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_RITEM_PTO_ITEM'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
                l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
             END IF ;

             --
             -- Verify that the Parent BOM Item Type is not 3:Planning Item
             --
             IF l_bom_item_type = l_PLANNING
             THEN
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value := l_com_operation_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_RITEM_PLANNING_ITEM'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );

                l_return_status := FND_API.G_RET_STS_ERROR;
                l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
             END IF ;

          END IF ;  -- For CREATE and ACD Type : Add

          --
          -- If the revised operation would be created with an Acd_Type of Change or Disable
          -- the old operation must already be implemented.
          -- ( Find old operation record using Old_Operation_Sequence_Id.
          --   Implemention_Date must not be null in the record.)
          --
          /* Comment out by MK.
          -- This is allowed in Rev Component and should be allowed in Rev Op as well
          */



          /********************************************************************
          -- Added by MK on 02/02/2001
          -- If the rev operation is created with an Acd_Type of Change or Disable
          -- then operation pointed to by old_operation_sequence_id should
          -- be valid against cusror l_val_old_op_seq_csr's conditions.
          *********************************************************************/
          IF l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE AND
             l_com_operation_rec.acd_type  IN (2, 3)
          THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Checking old operation : '|| to_char(l_com_op_unexp_rec.old_operation_sequence_id));
END IF;

               l_eco_for_production  := NVL(BOM_Rtg_Globals.Get_Eco_For_Production,2)  ;

               FOR old_op_seq_rec IN l_val_old_op_seq_csr
                   ( p_rtg_seq_id         => l_com_op_unexp_rec.routing_sequence_id ,
                     p_effectivity_date   => l_com_operation_rec.start_effective_date ,
                     p_eco_name           => l_com_operation_rec.eco_name ,
                     p_rev_item_seq_id    => l_com_op_unexp_rec.revised_item_sequence_id ,
                     p_old_op_seq_id      => l_com_op_unexp_rec.old_operation_sequence_id ,
                     p_eco_for_production => l_eco_for_production
                    )
               LOOP
                   -- operation is invalid
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                       Error_Handler.Add_Error_Token
                       (  p_message_name   => 'BOM_OP_OLD_OPSEQ_INVALID'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                       );
                   END IF;
                   l_return_status := FND_API.G_RET_STS_ERROR;
               END LOOP ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('After checking old operation. Return status is  '|| l_return_status);
END IF;
          END IF ;


          IF NOT Check_Primary_Routing( p_revised_item_id => l_com_op_unexp_rec.revised_item_id
                                      , p_organization_id => l_com_op_unexp_rec.organization_id )
          THEN


             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
               ('ACD type to be add if primary routing does not exist . . .') ;
             END IF;

             IF NVL(l_com_operation_rec.acd_type, l_ACD_ADD) <> l_ACD_ADD AND
                BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
             THEN

             --
             -- If the primary routing does not exist then the acd type
             -- of the operation must not be Add.
             --

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                   l_token_tbl(1).token_value := l_com_operation_rec.revised_item_name;

                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_OP_ACD_TYPE_ADD'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_token_tbl      => l_token_tbl
                   ) ;

                   l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                   l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;
          END IF ;

          --
          -- Verify the ECO Effectivity, If ECO by WO, Lot Num, Or Cum Qty, then
          -- Check if the operation exist in the WO or Lot Num.
          --
          IF   l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
          AND  l_com_operation_rec.acd_type  IN (l_ACD_CHANGE, l_ACD_DISABLE)
          THEN
             IF NOT Check_ECO_By_WO_Effectivity
                    ( p_revised_item_sequence_id => l_com_op_unexp_rec.revised_item_sequence_id
                    , p_operation_seq_num        => l_com_operation_rec.old_operation_sequence_number
                    , p_organization_id          => l_com_op_unexp_rec.organization_id
                    , p_rev_item_id              => l_com_op_unexp_rec.revised_item_id
                    )
             THEN
                l_token_tbl(1).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(1).token_value := l_com_operation_rec.revised_item_name;
                l_token_tbl(2).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(2).token_value := l_com_operation_rec.operation_sequence_number ;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_RIT_ECO_WO_EFF_INVALID'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;

                l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
             END IF ;
          END IF ;

          --
          -- Entity Validation for UPDATEs ONLY in ECO Bo
          --
          IF l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
          THEN

             --
             -- Verify that the user is not trying to update an operation which
             -- is Disabled on the ECO
             --
             IF p_old_com_operation_rec.acd_type = l_ACD_DISABLE
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   ( p_message_name    => 'BOM_OP_DISABLED'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_token_tbl      => l_token_tbl
                   ) ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;

             --
             -- For UPDATE, ACD Type not updateable
             --
             IF  l_com_operation_rec.acd_type <> p_old_com_operation_rec.acd_type
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   ( p_message_name    => 'BOM_OP_ACD_TYPE_NOT_UPDATEABLE'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_token_tbl      => l_token_tbl
                   ) ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;

             --
             -- For UPDATE, Old Operatin Number not updateable
             --
             IF l_com_operation_rec.old_operation_sequence_number <>
                p_old_com_operation_rec.old_operation_sequence_number
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   ( p_message_name    => 'BOM_OP_OLDOPSQNM_NT_UPDATEABLE'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_token_tbl      => l_token_tbl
                   ) ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;

             --
             -- For UPDATE, Old Effectivity Date not updateable
             --
             IF l_com_operation_rec.old_start_effective_date <>
                p_old_com_operation_rec.old_start_effective_date
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   ( p_message_name    => 'BOM_OP_OLDEFFDT_NOT_UPDATEABLE'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_token_tbl      => l_token_tbl
                   ) ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;
          END IF ; -- Validation for Update Only

          --
          -- For CANCEL,
          -- If there is an unimplemented revised component referencing this
          -- operation squence number, cannot cancel this reivised operation.
          --
          --
          IF l_com_operation_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CANCEL
                                                      ,BOM_Rtg_Globals.G_OPR_DELETE )
             AND l_com_operation_rec.acd_type = l_ACD_ADD
          THEN

             IF NOT Check_Ref_Rev_Comp
                    ( p_operation_seq_num    => l_com_operation_rec.operation_sequence_number
                    , p_start_effective_date => l_com_operation_rec.start_effective_date
                    , p_rev_item_seq_id      => l_com_op_unexp_rec.revised_item_sequence_id
                    )
             THEN

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_OP_CANNOT_CANCL_FOR_REVCMP'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR;

             END IF ;
          END IF ; -- For Cancel

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('End of Validation specific to ECO BO :  ' || l_return_status) ;
       END IF ;


       END IF ; -- ECO BO Validation


       --
       -- For UPDATE or ACD type : Change.
       -- Validation specific to the Transaction Type of Update
       --
       IF l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_UPDATE
          OR ( l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
               AND l_com_operation_rec.acd_type = l_ACD_CHANGE )
       THEN
          --
          -- If Start Effective Date or New Start Effective Date is past,
          -- Effective_Date is not updatable
          --
          -- Added condition to check start_eff_date <> new_start_eff_date for bug 4666512
          IF  BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO
           AND l_com_operation_rec.new_start_effective_date IS NOT NULL
           AND l_com_operation_rec.new_start_effective_date <> FND_API.G_MISS_DATE
           AND l_com_operation_rec.new_start_effective_date <>
			l_com_operation_rec.start_effective_date
           AND ( l_com_operation_rec.start_effective_date < sysdate
                 OR l_com_operation_rec.new_start_effective_date < sysdate
/** Changed for bug 2647027
	  AND ( trunc(l_com_operation_rec.start_effective_date) < trunc(sysdate)
                 OR trunc(l_com_operation_rec.new_start_effective_date) < trunc(sysdate)
**/               )
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_EFFDATE_NOT_UPDATABLE'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR;
          END IF ;


          --
          -- If Standard Operation Id is not null, Department Id is not updatable
          --
          -- For eAM enhancenment, added Eam Item condidtions for this validation.
          -- Also in maintenace routing, we allow eam users to update the dept code
          -- if the dept resources that have been assigned to the current operation
          -- should also exist in the dept to which the user changes.

          IF   p_old_com_op_unexp_rec.department_id <> l_com_op_unexp_rec.department_id
          AND (l_com_op_unexp_rec.standard_operation_id IS NOT NULL
               OR  Check_ResExists
                   (  p_op_seq_id     => l_com_op_unexp_rec.operation_sequence_id
                    , p_old_op_seq_id => l_com_op_unexp_rec.old_operation_sequence_id
                    , p_acd_type      => l_com_operation_rec.acd_type
                    )
               )
          AND BOM_Rtg_Globals.Get_Eam_Item_Type <>  BOM_Rtg_Globals.G_ASSET_ACTIVITY
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_DEPT_NOT_UPDATABLE'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR;

          ELSIF  p_old_com_op_unexp_rec.department_id <> l_com_op_unexp_rec.department_id
          AND    BOM_Rtg_Globals.Get_Eam_Item_Type  =  BOM_Rtg_Globals.G_ASSET_ACTIVITY
          AND    NOT Bom_Rtg_Eam_Util.Check_UpdateDept
                 ( p_op_seq_id     => l_com_op_unexp_rec.operation_sequence_id
                 , p_org_id        => l_com_op_unexp_rec.organization_id
                 , p_dept_id       => l_com_op_unexp_rec.department_id
                 )
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_EAM_OP_DEPT_NOT_UPDATABLE'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR;

          END IF ;

          --
          -- Reference Flag Validation.
          -- If once reference flag is set to NO, cannot update to Yes
          -- for reference to copied operation.
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND p_old_com_operation_rec.reference_flag = 2 -- 2:No
           AND l_com_operation_rec.reference_flag = 1  -- 1:Yes
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_REF_NOT_ALLOWED'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR;
          END IF ;
       END IF ;  --  Transation: UPDATE

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('End of Validation specific to the Transaction Type of Update : ' || l_return_status) ;
       END IF ;

       --
       -- Validateion for Transaction Type : Create and Update
       --
       IF BOM_Rtg_Globals.Get_Debug = 'Y'
        THEN
             Error_Handler.Write_Debug ('The Transaction Type is ');
             Error_Handler.Write_Debug (l_com_operation_rec.transaction_type);
       END IF ;

       IF l_com_operation_rec.transaction_type IN
         (BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
       THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Common Validateion for Transaction Type : Create and Update . . . . ' || l_return_status) ;
END IF ;

          --
          -- Reference Flag Validation.
          -- If standard operation id is null, It is unable to reference
          -- missing stanadrd op. So, It must be 2: No.
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND l_com_op_unexp_rec.standard_operation_id IS NULL
           AND l_com_operation_rec.reference_flag <> 2  -- 2:No
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_REFFLAG_MUST_BE_NO'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR ;

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('Reference Flag Validation, If Std Op is null, It must be No . . . ' || l_return_status) ;
             END IF ;

          END IF ;

          -- Validate Standard Operation and Reference flag
          -- If Standard Operation has changed to not null value
          -- If OK, Copy Std Operation and Std Resource
          -- Info regarding with Reference Flag.
          --
          Check_Ref_Std_Operation
              (  p_com_operation_rec     => l_com_operation_rec
               , p_com_op_unexp_rec      => l_com_op_unexp_rec
               , p_control_rec           => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
               , p_old_com_operation_rec => p_old_com_operation_rec
               , p_old_com_op_unexp_rec  => p_old_com_op_unexp_rec
               , x_com_operation_rec     => l_com_operation_rec
               , x_com_op_unexp_rec      => l_com_op_unexp_rec
               , x_return_status         => l_temp_return_status
               , x_mesg_token_tbl        => l_temp_mesg_token_tbl
              ) ;

          IF l_temp_return_status = FND_API.G_RET_STS_ERROR
          THEN
                 l_mesg_token_tbl := l_temp_mesg_token_tbl ;
                 l_return_status  := FND_API.G_RET_STS_ERROR ;
          ELSIF l_temp_mesg_token_tbl.COUNT > 0 -- if warnings are logged
          THEN
                 l_mesg_token_tbl := l_temp_mesg_token_tbl ;
          END IF ;

          --
          -- Operation Type
          -- Only Events(Operation Type 1) have parents
          --
          IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag =  BOM_Rtg_Globals.G_FLOW_RTG AND
             l_com_operation_rec.operation_type <> l_EVENT AND
             ( l_com_op_unexp_rec.process_op_seq_id IS NOT NULL OR
               l_com_op_unexp_rec.line_op_seq_id IS NOT NULL )
          THEN
             l_token_tbl(2).token_name  := 'OPERATION_TYPE';
             l_token_tbl(2).token_value := l_com_operation_rec.operation_type ;

             Error_Handler.Add_Error_Token
             (  p_message_name       => 'BOM_FLM_OP_CANNOT_HAVE_PARENTS'
              , p_mesg_token_tbl     => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , p_token_tbl          => l_token_tbl
             ) ;

             l_return_status := FND_API.G_RET_STS_ERROR;


             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('In Flow Routing Only Events(Operation Type 1) have parents. . . . ' || l_return_status) ;
             END IF ;

          END IF ;

          --
          -- Disable Date and Start Effective Date(New Effective Date)
          -- Effective_Date must be past or equal Disable_Date.
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND l_com_operation_rec.disable_date <
               NVL(  l_com_operation_rec.new_start_effective_date
                   , l_com_operation_rec.start_effective_date)
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_DISABLE_DATE_INVALID'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR;

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('Effective_Date must be past than or equal to Disable_Date. . . . ' || l_return_status) ;
             END IF ;

          END IF ;


          --
          -- Backfluch Flag Validation.
          -- If Count Point Type : 3, Backflush Flag must be 1:Yes
          --
          IF ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND l_com_operation_rec.count_point_type = 3 -- 3:Non-Direct
           AND l_com_operation_rec.backflush_flag <> 1  -- 1:Yes
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_BKFFLAG_CPNTYPE_INVALID'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR;

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             (' Backfluch Flag Validation. If Count Point Type : 3, Backflush Flag must be 1:Yes . . . '
             || l_return_status) ;
             END IF ;

          END IF ;

          --
          -- Option Dependent Flag Validation.
          -- If Rev Item or Assem Item's BOM Item Type is Standard,
          -- Operation Dependent Flag must be 2: No.
          --

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Option Dependent Flag : ' || to_char(l_com_operation_rec.option_dependent_flag)) ;
END IF ;

          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND l_bom_item_type = l_STANDARD -- 4:Standard
           AND l_com_operation_rec.option_dependent_flag <> 2  -- 2:No
          THEN

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_OP_DPTFLAG_MUST_BE_NO'
                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_Token_Tbl      => l_Token_Tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR;

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('If Item : BOM Item Type is Std, Option Dependent Flag must be 2 - No . . .'
             || l_return_status) ;
             END IF ;

          END IF ;

          --
          -- Check if Department is valid
          --
          IF l_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
            AND ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 OR ( l_com_operation_rec.acd_type = l_ACD_CHANGE
                     AND l_com_op_unexp_rec.department_id <>
                         p_old_com_op_unexp_rec.department_id
                     )
                )
          THEN
if BOM_Rtg_GLobals.Get_CFM_Rtg_Flag <> BOM_Rtg_Globals.G_Lot_Rtg then --for bug 3132411
                 FOR l_dept_rec IN l_dept_csr
                                         ( p_organization_id=> l_com_op_unexp_rec.organization_id
                                          , p_dept_id       => l_com_op_unexp_rec.department_id
                                          , p_start_effective_date => l_com_operation_rec.start_effective_date
                                          )

                 LOOP

                     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_OP_DEPT_ID_INVALID'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                        ) ;
                     END IF ;
                     l_return_status := FND_API.G_RET_STS_ERROR ;
                 END LOOP ;
end if;

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('Check if Department is valid. ' || l_return_status) ;
             END IF ;

          END IF ;


          --
          -- Process Op Seq Id Validation.
          -- Check if process operation does not have resources
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND l_com_op_unexp_rec.process_op_seq_id IS NOT NULL
          THEN
             FOR l_parenets_rec IN l_parents_csr(p_parent_seq_id
                                              => l_com_op_unexp_rec.process_op_seq_id )
             LOOP

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_FLM_OP_PRT_PCSOP_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END LOOP ;

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('Check if process operation does not have resources. . . ' || l_return_status) ;
             END IF ;

          END IF ;

          --
          -- Line Op Seq Id Validation.
          -- Check if line operation does not have resources
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
           AND l_com_op_unexp_rec.line_op_seq_id IS NOT NULL
          THEN
             FOR l_parenets_rec IN l_parents_csr(p_parent_seq_id
                                              => l_com_op_unexp_rec.line_op_seq_id)
             LOOP

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_FLM_OP_PRT_LINEOP_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END LOOP ;

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
             ('Check if line operation does not have resources. . . ' || l_return_status) ;
             END IF ;

          END IF ;

          --
          -- Check uniquness of the operation.
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              OR l_com_operation_rec.acd_type = l_ACD_CHANGE)
          THEN

             FOR  l_duplicate_rec IN l_duplicate_csr
                     ( p_op_seq_id  => l_com_op_unexp_rec.operation_sequence_id
                     , p_rtg_seq_id => l_com_op_unexp_rec.routing_sequence_id
                     , p_op_seq_num => NVL( l_com_operation_rec.new_operation_sequence_number
                                          , l_com_operation_rec.operation_sequence_number)
                     , p_op_type    => l_com_operation_rec.operation_type
                     , p_start_effective_date => NVL( l_com_operation_rec.new_start_effective_date
                                                    , l_com_operation_rec.start_effective_date)
                     )
             LOOP
                l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(1).token_value := NVL( l_com_operation_rec.new_operation_sequence_number
                                                 , l_com_operation_rec.operation_sequence_number) ;

                Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_OP_NOT_UNIQUE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                l_return_status := FND_API.G_RET_STS_ERROR ;

                l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
             END LOOP ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Check uniqueness of the operation. . . ' || l_return_status) ;
END IF ;

          END IF ;


          --
          -- Check if there is no overlapping operations
          --
          IF  ( NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                AND l_com_operation_rec.operation_type NOT IN (l_PROCESS, l_LINE_OP)
                --  OR l_com_operation_rec.acd_type = l_ACD_CHANGE
              )
          THEN


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
  Error_Handler.Write_Debug('Rtg Seq Id :  ' || to_char(l_com_op_unexp_rec.routing_sequence_id) ) ;
  Error_Handler.Write_Debug('Op  Seq Id :  ' || to_char(l_com_op_unexp_rec.operation_sequence_id) ) ;
  Error_Handler.Write_Debug('Op Type    :  ' || to_char(l_com_operation_rec.operation_type) ) ;
  Error_Handler.Write_Debug('New Op Seq :  ' || to_char(l_com_operation_rec.new_operation_sequence_number) ) ;
  Error_Handler.Write_Debug('Op Seq Num :  ' || to_char(l_com_operation_rec.operation_sequence_number) ) ;
  Error_Handler.Write_Debug('New Effect Date : ' || to_char(l_com_operation_rec.new_start_effective_date) ) ;
  Error_Handler.Write_Debug('Effect Date : ' || to_char(l_com_operation_rec.start_effective_date) ) ;
  Error_Handler.Write_Debug('Disable Date: ' || to_char(l_com_operation_rec.disable_date) ) ;
END IF ;


             IF NVL(BOM_Rtg_Globals.Get_Eco_For_Production,2) <> 1 THEN

                FOR  l_overlap_rec IN l_overlap_csr
                     ( p_op_seq_id  => l_com_op_unexp_rec.operation_sequence_id
                     , p_rtg_seq_id => l_com_op_unexp_rec.routing_sequence_id
                     , p_op_seq_num => NVL( l_com_operation_rec.new_operation_sequence_number
                                          , l_com_operation_rec.operation_sequence_number)
                     , p_op_type    => l_com_operation_rec.operation_type
                     , p_start_effective_date => NVL( l_com_operation_rec.new_start_effective_date
                                                    , l_com_operation_rec.start_effective_date)
                     , p_disable_date => l_com_operation_rec.disable_date
                     )
                LOOP
                   l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                   l_token_tbl(1).token_value := NVL( l_com_operation_rec.new_operation_sequence_number
                                                    , l_com_operation_rec.operation_sequence_number) ;

                   Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_OP_OVERLAP'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                   l_return_status := FND_API.G_RET_STS_ERROR ;

                   l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                   l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
                END LOOP ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Check if there is no overlapping operations. . . ' || l_return_status) ;
END IF ;
             END IF ;

          END IF ;


          --
          -- Check if there is a unimplemented revised operation that
          -- has same op seqnumber
          -- If so, Generate Warning
          --
          /* If necessary, remove comment out, and create new message
          */

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Check uniqueness for unimplemented revised operations. . . ' || l_return_status) ;
END IF ;

          --
          -- Check if there is no overlapping for unimplemented revised operations
          --
          --
          IF  (   NVL(l_com_operation_rec.acd_type,l_ACD_ADD) IN (l_ACD_CHANGE, l_ACD_ADD)
              AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO )
          THEN

             IF NVL(BOM_Rtg_Globals.Get_Eco_For_Production,2) <> 1 THEN


                FOR  l_rev_overlap_rec IN l_rev_overlap_csr
                     ( p_op_seq_id  => l_com_op_unexp_rec.operation_sequence_id
                     , p_rtg_seq_id => l_com_op_unexp_rec.routing_sequence_id
                     , p_op_seq_num => NVL( l_com_operation_rec.new_operation_sequence_number
                                          , l_com_operation_rec.operation_sequence_number)
                     , p_op_type    => l_com_operation_rec.operation_type
                     , p_start_effective_date => NVL( l_com_operation_rec.new_start_effective_date
                                                    , l_com_operation_rec.start_effective_date)
                     , p_disable_date => l_com_operation_rec.disable_date
                     )
                LOOP
                   l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                   l_token_tbl(1).token_value := NVL( l_com_operation_rec.new_operation_sequence_number
                                                    , l_com_operation_rec.operation_sequence_number) ;

                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_REV_OP_OVERLAP'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                    , p_message_type   => 'W'
                   ) ;

                   -- l_return_status := FND_API.G_RET_STS_ERROR ;

                   l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                   l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number ;
                END LOOP ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Check if there is no overlapping operations for unimplemented revised operations. . . '
                   || l_return_status) ;
END IF ;
             END IF ;
          END IF ;


       END IF ; -- Transaction Type : Create and Update

       -- The ECO can be updated but a warning needs to be generated and
       -- scheduled revised items need to be update to Open
       -- and the ECO status need to be changed to Not Submitted for Approval

       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN

          BOM_Rtg_Globals.Check_Approved_For_Process
          ( p_change_notice    => l_com_operation_rec.eco_name
          , p_organization_id  => l_com_op_unexp_rec.organization_id
          , x_processed        => l_eco_processed
          , x_err_text         => l_err_text
          ) ;

          IF l_eco_processed THEN
           -- If the above process returns true then set the ECO approval.
                BOM_Rtg_Globals.Set_Request_For_Approval
                ( p_change_notice    => l_com_operation_rec.eco_name
                , p_organization_id  => l_com_op_unexp_rec.organization_id
                , x_err_text         => l_err_text
                ) ;

          END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check if ECO has been approved and has a workflow process. . . ' || l_return_status) ;
END IF ;

       END IF;

       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO AND
          p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE
       THEN
                IF p_com_operation_rec.Delete_Group_Name IS NULL OR
                   p_com_operation_rec.Delete_Group_Name = FND_API.G_MISS_CHAR
                THEN

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_DG_NAME_MISSING'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check if Delete Group is missing . . . ' || l_return_status) ;
END IF ;

       END IF ;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Entity Validation was processed. . . ' || l_return_status);
       END IF ;

       -- Check if an operation designated as SSOS is being deleted  -- Added for SSOS (bug 2689249)
       -- or its op seq num is being changed. This is not allowed
       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO THEN
	  FOR get_ssos_rec IN get_ssos_csr(p_rtg_seq_id => l_com_op_unexp_rec.routing_Sequence_id) LOOP
	      IF p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE THEN
		IF l_com_operation_rec.operation_sequence_number = get_ssos_rec.serialization_start_op THEN
                       l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                       l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number;

			Error_Handler.Add_Error_Token
			(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
			, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			, p_message_name   => 'BOM_OP_SSOS'
			, p_token_tbl      => l_token_tbl
			);
                        l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	      ELSIF p_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE THEN
	        IF l_com_operation_rec.operation_sequence_number = get_ssos_rec.serialization_start_op AND
		   l_com_operation_rec.new_operation_sequence_number <> l_com_operation_rec.operation_sequence_number THEN
                       l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                       l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number;

			Error_Handler.Add_Error_Token
			(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
			, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			, p_message_name   => 'BOM_OP_SSOS'
			, p_token_tbl      => l_token_tbl
			);
                        l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	     END IF;
	  END LOOP;
       END IF;

--For checking that OSFM operation is not a po_move
   IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_Lot_Rtg
       AND WSMPUTIL.CHECK_PO_MOVE(p_sequence_id => p_com_op_unexp_rec.Operation_Sequence_Id,
                                                                p_sequence_id_type => 'O',
                                                                p_routing_rev_date => SYSDATE,
                                                                x_err_code => l_err_code,
                                                                x_err_msg => l_err_text)
       THEN
       Error_Handler.Add_Error_Token(p_message_name => 'WSM_ROUTING_PO_MOVE',
                                     p_mesg_token_tbl => l_mesg_token_tbl,
                                     x_mesg_token_tbl => l_mesg_token_tbl,
                                     p_token_tbl => l_token_tbl);
        END IF;
--End of PO_MOVE changes for OSFM operation

--For Delete Operation OSFM constraint
   IF p_com_operation_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_DELETE
   AND BOM_RTG_Globals.Is_Osfm_NW_Calc_Flag
   AND
   WSMPUTIL.JOBS_WITH_QTY_AT_FROM_OP (x_err_code => l_err_code,
                                      x_err_msg => l_err_text,
                                      p_operation_sequence_id => p_com_op_unexp_rec.Operation_Sequence_Id)
   THEN
   l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
   l_token_tbl(1).token_value := l_com_operation_rec.operation_sequence_number;
   Error_Handler.Add_Error_Token(p_message_name => 'BOM_WSM_OP_ACTIVE_JOB',
                                 p_mesg_token_tbl => l_mesg_token_tbl,
                                 p_token_tbl      => l_token_tbl,
                                 x_mesg_token_tbl => l_mesg_token_tbl);
  l_return_status := Error_Handler.G_Status_Error;

  END IF;
--End of Delete Operation OSFM constraint

       --
       -- Return Common Operation Record
       --
       x_com_operation_rec  := l_com_operation_rec ;
       x_com_op_unexp_rec   := l_com_op_unexp_rec ;

       --
       -- Return Error Status
       --
       x_return_status  := l_return_status;
       x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;


    EXCEPTION
       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Entity Validation . . .' || SQLERRM );
          END IF ;


          l_err_text := G_PKG_NAME || ' Validation (Entity Validation) '
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
    END Check_Entity ;



    /*************************************************************
    * Procedure     : Check_Access
    * Parameters IN : Revised Item Unique Key
    *                 Revised Operation unique key
    * Parameters out: Mesg_Token_Tbl
    *                 Return_Status
    * Purpose       : Procedure will verify that the revised item and the
    *                 revised operation is accessible to the user.
    ********************************************************************/
    PROCEDURE Check_Access
     (  p_revised_item_name          IN  VARCHAR2
      , p_revised_item_id            IN  NUMBER
      , p_organization_id            IN  NUMBER
      , p_change_notice              IN  VARCHAR2
      , p_new_item_revision          IN  VARCHAR2
      , p_effectivity_date           IN  DATE
      , p_new_routing_revsion        IN  VARCHAR2 -- Added by MK on 11/02/00
      , p_from_end_item_number       IN  VARCHAR2 -- Added by MK on 11/02/00
      , p_operation_seq_num          IN  NUMBER
      , p_routing_sequence_id        IN  NUMBER
      , p_operation_type             IN  NUMBER
      , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type
      , p_entity_processed           IN  VARCHAR2
      , p_resource_seq_num           IN  NUMBER
      , p_sub_resource_code          IN  VARCHAR2
      , p_sub_group_num              IN  NUMBER
      , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
      , x_Return_Status              IN OUT NOCOPY VARCHAR2
     )
     IS
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type :=
                                p_Mesg_Token_Tbl;
        l_return_status         VARCHAR2(1);
        l_error_name            VARCHAR2(30);
        l_is_comp_unit_controlled BOOLEAN := FALSE;
        l_is_item_unit_controlled BOOLEAN := FALSE;


         CURSOR c_CheckDisabled IS
            SELECT NULL
            FROM   BOM_OPERATION_SEQUENCES
            WHERE  NVL(operation_type, 1) = NVL(p_operation_type, 1)
            AND    effectivity_date = p_effectivity_date   -- Changed for bug 2647027
--	    AND    TRUNC(effectivity_date) = TRUNC(p_effectivity_date)
            AND    routing_sequence_id  = p_routing_sequence_id
            AND    operation_seq_num    = p_operation_seq_num
            AND    acd_type = 3;

    BEGIN
       l_return_status := FND_API.G_RET_STS_SUCCESS;

   /* The code has been moved to ENGLRITB.pls because of ODF dependany
   unnecessarily created.
   Commenting the following code so that we can reuse in release 12 */

        /****************************************************************
        --
        -- Check if the revised operation is not cancelled.
        -- This check will not prove useful for the revised item itself,
        -- since the check existence for a cancelled operation would fail.
        -- But this procedure can be called by the
        -- child records of the revised operation and make sure that the
        -- parent record is not cancelled.
        --

        ********************************************************************/



        /**************************************************************
        -- Added by MK on 11/01/2000
        -- If routing sequence id is null(Trans Type : CREATE) and this
        -- revised item does not have primary routing, verify that parent revised
        -- item does not have bill sequence id which has alternate code.
        -- (Verify this eco is not only for alternate bill )
        --
        **************************************************************/


        /**************************************************************
        --
        -- If the Entity being processed is Rev Operation Resource
        -- or Rev Sub Operation then check if the parent Rev Operation is
        -- disabled. If it is then Error this record and also all the
        -- siblings
        --
        **************************************************************/
        IF p_entity_processed IN ('RES', 'SR')
        THEN
           FOR isDisabled IN c_CheckDisabled LOOP

               IF p_entity_processed = 'RES'
               THEN
                   l_error_name := 'BOM_RES_OP_ACD_TYPE_DISABLE';
                   l_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
                   l_token_tbl(1).token_value :=  p_resource_seq_num ;
                   l_token_tbl(2).token_name  := 'OP_SEQ_NUMBER';
                   l_token_tbl(2).token_value := p_operation_seq_num;

               ELSE
                   l_error_name := 'BOM_SUB_RES_OP_ACDTYPE_DISABLE';
                   l_token_tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                   l_token_tbl(1).token_value :=  p_sub_resource_code ;
                   l_token_tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
                   l_token_tbl(2).token_value := p_sub_group_num ;
                   l_token_tbl(3).token_name  := 'OP_SEQ_NUMBER';
                   l_token_tbl(3).token_value := p_operation_seq_num;

               END IF;

               l_return_status := FND_API.G_RET_STS_ERROR;

               Error_Handler.Add_Error_Token
               (  p_Message_Name       => l_error_name
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_Token_Tbl          => l_token_tbl
               );
           END LOOP;
        END IF;

        x_Return_Status := l_return_status;
        x_Mesg_Token_Tbl := l_mesg_token_tbl;
END Check_Access;


END BOM_Validate_Op_Seq ;

/
