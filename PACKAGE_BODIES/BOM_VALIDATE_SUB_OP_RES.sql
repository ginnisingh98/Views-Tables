--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_SUB_OP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_SUB_OP_RES" AS
/* $Header: BOMLSORB.pls 120.5.12010000.2 2011/12/06 10:35:46 rambkond ship $ */

/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMLSORB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Sub_Op_Res
--
--  NOTES
--
--  HISTORY
--
--  22-AUG-00   Masanori Kimizuka Initial Creation
--  08-DEC-2005 Bhavnesh Patel    4689856:Validation for new column new_basis_type
****************************************************************************/

    G_Pkg_Name      VARCHAR2(30) := 'BOM_Validate_Sub_Op_Res';

    l_ACD_ADD                     CONSTANT NUMBER := 1 ;
    l_ACD_CHANGE                  CONSTANT NUMBER := 2 ;
    l_ACD_DISABLE                 CONSTANT NUMBER := 3 ;
    l_NO_SCHEDULE                 CONSTANT NUMBER := 2 ;
    l_PRIOR                       CONSTANT NUMBER := 3 ;
    l_NEXT                        CONSTANT NUMBER := 4 ;
    l_PO_RECEIPT                  CONSTANT NUMBER := 3 ;
    l_PO_MOVE                     CONSTANT NUMBER := 4 ;


    /******************************************************************
    * OTHER LOCAL FUNCTION AND PROCEDURES
    * Purpose       : Called by Check_Entity or something
    *********************************************************************/
    --
    -- Function: Check if Op Seq Num exists in Work Order
    --           in ECO by Lot, Wo, Cum Qty
    --
    FUNCTION Check_ECO_By_WO_Effectivity
             ( p_revised_item_sequence_id IN  NUMBER
             , p_operation_seq_num        IN  NUMBER
             , p_resource_id              IN  NUMBER
             , p_sub_group_num            IN  NUMBER )

    RETURN BOOLEAN
    IS
       l_ret_status BOOLEAN := TRUE ;

       l_lot_number varchar2(30) := NULL;
       l_from_wip_entity_id NUMBER :=0;
       l_to_wip_entity_id NUMBER :=0;
       l_from_cum_qty  NUMBER :=0;

/*     Rewrote the cursor for BUG 4918694
       CURSOR  l_check_lot_num_csr ( p_lot_number         NUMBER
                                   , p_operation_seq_num  NUMBER
                                   , p_resource_id        NUMBER
                                   , p_sub_group_num      NUMBER )
       IS
          SELECT 'Sub Res does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE   wdj.lot_number = p_lot_number
                         AND     (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_SUB_OPERATION_RESOURCES wsor
                                             WHERE  substitute_group_num = p_sub_group_num
                                             AND    resource_id          = p_resource_id
                                             AND    operation_seq_num = p_operation_seq_num
                                             AND    wip_entity_id     = wdj.wip_entity_id)
                                  )
                         AND      wdj.lot_number = p_lot_number
                        ) ;
*/

       CURSOR  l_check_lot_num_csr ( p_lot_number         NUMBER
                                   , p_operation_seq_num  NUMBER
                                   , p_resource_id        NUMBER
                                   , p_sub_group_num      NUMBER )
       IS
          SELECT 'Sub Res does not exist'
          FROM  DUAL
          WHERE NOT EXISTS ( SELECT  NULL
                             FROM    WIP_DISCRETE_JOBS  wdj
                             WHERE   wdj.lot_number = p_lot_number
                             AND     wdj.status_type = 1
                             AND EXISTS ( SELECT NULL
                                          FROM   WIP_SUB_OPERATION_RESOURCES wsor
                                          WHERE  substitute_group_num = p_sub_group_num
                                          AND    resource_id          = p_resource_id
                                          AND    operation_seq_num    = p_operation_seq_num
                                          AND    wip_entity_id        = wdj.wip_entity_id
                                        )
                           );

       CURSOR  l_check_wo_csr (  p_from_wip_entity_id NUMBER
                               , p_to_wip_entity_id   NUMBER
                               , p_operation_seq_num  NUMBER
                               , p_resource_id        NUMBER
                               , p_sub_group_num      NUMBER )
       IS
          SELECT 'Sub Res does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                               , WIP_ENTITIES       we
                               , WIP_ENTITIES       we1
                               , WIP_ENTITIES       we2
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS (SELECT NULL
                                              FROM   WIP_SUB_OPERATION_RESOURCES wsor
                                              WHERE  substitute_group_num = p_sub_group_num
                                              AND    resource_id          = p_resource_id
                                              AND    operation_seq_num = p_operation_seq_num
                                              AND    wip_entity_id     = wdj.wip_entity_id)
                                 )
                         AND     wdj.wip_entity_id = we.wip_entity_id
                         AND     we.wip_entity_name >= we1.wip_entity_name
                         AND     we.wip_entity_name <= we2.wip_entity_name
                         AND     we1.wip_entity_id = p_from_wip_entity_id
                         AND     we2.wip_entity_id = NVL(p_to_wip_entity_id, p_from_wip_entity_id)
                         ) ;

      CURSOR  l_check_cum_csr (  p_from_wip_entity_id NUMBER
                               , p_operation_seq_num  NUMBER
                               , p_resource_id        NUMBER
                               , p_sub_group_num      NUMBER )


       IS
          SELECT 'Sub Res does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_SUB_OPERATION_RESOURCES wsor
                                             WHERE  substitute_group_num = p_sub_group_num
                                             AND    resource_id          = p_resource_id
                                             AND    operation_seq_num = p_operation_seq_num
                                             AND    wip_entity_id     = wdj.wip_entity_id)
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

             FOR l_lot_num_rec IN l_check_lot_num_csr
                               ( p_lot_number        => l_lot_number
                               , p_operation_seq_num => p_operation_seq_num
                               , p_resource_id       => p_resource_id
                               , p_sub_group_num     => p_sub_group_num )
             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          -- Check if Op Seq Num is exist  in ECO by Cum
          ELSIF   l_lot_number         IS NULL
           AND    l_from_wip_entity_id IS NOT NULL
           AND    l_to_wip_entity_id   IS NULL
           AND    l_from_cum_qty       IS NOT NULL
          THEN

             FOR l_lot_num_rec IN l_check_cum_csr
                               ( p_from_wip_entity_id => l_from_wip_entity_id
                               , p_operation_seq_num  => p_operation_seq_num
                               , p_resource_id        => p_resource_id
                               , p_sub_group_num      => p_sub_group_num )
             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          -- Check if Op Seq Num is exist  in ECO by WO
          ELSIF   l_lot_number         IS NULL
           AND    l_from_wip_entity_id IS NOT NULL
           AND    l_from_cum_qty       IS NULL
          THEN

             FOR l_lot_num_rec IN l_check_wo_csr
                               ( p_from_wip_entity_id => l_from_wip_entity_id
                               , p_to_wip_entity_id   => l_to_wip_entity_id
                               , p_operation_seq_num  => p_operation_seq_num
                               , p_resource_id        => p_resource_id
                               , p_sub_group_num      => p_sub_group_num )
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


    /*******************************************************************
    *Others    :     Following Procedures and Functions are called by
    *                Check_Entity in Op Resource and Sub Op Resource
    *Purpose   :     These Shared Logic validate the values on
    *                inter-dependent columns or get values to validate entity.
    *******************************************************************/
    PROCEDURE   Val_Scheduled_Sub_Resource
    ( p_op_seq_id     IN  NUMBER
    , p_resource_id   IN  NUMBER
    , p_sub_group_num IN  NUMBER
    , p_schedule_flag IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS

       CURSOR l_rel_schedule_csr
                             ( p_op_seq_id      NUMBER
                             , p_sub_group_num  NUMBER
                             , p_schedule_flag  NUMBER
                             )
       IS
          SELECT 'Related Schedule Resource does not exist'
          FROM   SYS.DUAL
          WHERE  NOT EXISTS( SELECT NULL
                             FROM   BOM_OPERATION_RESOURCES
                             WHERE  schedule_flag         = p_schedule_flag
                             AND    substitute_group_num  = p_sub_group_num
                             AND    operation_sequence_id = p_op_seq_id
                            ) ;

       CURSOR l_sub_schedule_csr
                             ( p_op_seq_id      NUMBER
                             , p_resource_id    NUMBER
                             , p_sub_group_num  NUMBER
                             , p_schedule_flag  NUMBER
                             )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_SUB_OPERATION_RESOURCES
                         WHERE  schedule_flag         =  p_schedule_flag
                         AND    resource_id           <> p_resource_id
                         AND    substitute_group_num  =  p_sub_group_num
                         AND    operation_sequence_id =  p_op_seq_id
                        ) ;


    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_rel_schedule_rec IN l_rel_schedule_csr
                                        ( p_op_seq_id
                                        , p_sub_group_num
                                        , p_schedule_flag
                                        )
       LOOP
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;

       IF x_return_status <> FND_API.G_RET_STS_ERROR
       THEN
          FOR l_sub_schedule_rec IN l_sub_schedule_csr
                                           (  p_op_seq_id
                                            , p_resource_id
                                            , p_sub_group_num
                                            , p_schedule_flag
                                            )
          LOOP
             x_return_status := FND_API.G_RET_STS_ERROR ;
          END LOOP ;
       END IF ;

    END Val_Scheduled_Sub_Resource ;


    PROCEDURE   Val_Sub_PO_Move
    ( p_op_seq_id     IN  NUMBER
    , p_resource_id   IN  NUMBER
    , p_sub_group_num IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS

       CURSOR l_rel_pomove_csr
                             ( p_op_seq_id      NUMBER
                             , p_sub_group_num  NUMBER
                             )
       IS
          SELECT 'Related PO Move Resource does not exist'
          FROM   SYS.DUAL
          WHERE  NOT EXISTS( SELECT NULL
                             FROM   BOM_OPERATION_RESOURCES
                             WHERE  autocharge_type       = l_PO_MOVE
                             AND    substitute_group_num  = p_sub_group_num
                             AND    operation_sequence_id = p_op_seq_id
                            ) ;

       CURSOR l_sub_pomove_csr(  p_op_seq_id     NUMBER
                               , p_resource_id   NUMBER
                               , p_sub_group_num NUMBER )

       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_SUB_OPERATION_RESOURCES
                         WHERE  autocharge_type       =  l_PO_MOVE
                         AND    resource_id           <> p_resource_id
                         AND    substitute_group_num  =  p_sub_group_num
                         AND    operation_sequence_id =  p_op_seq_id
                        ) ;


    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_rel_pomove_rec IN l_rel_pomove_csr
                                        ( p_op_seq_id
                                        , p_sub_group_num
                                        )
       LOOP
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;

       IF x_return_status <> FND_API.G_RET_STS_ERROR
       THEN
          FOR l_sub_pomove_rec IN l_sub_pomove_csr (  p_op_seq_id
                                                    , p_resource_id
                                                    , p_sub_group_num
                                                    )
          LOOP
                 x_return_status := FND_API.G_RET_STS_ERROR ;
          END LOOP ;
       END IF ;

    END Val_Sub_PO_Move ;

    --
    -- Function: Get_Old_Op_Seq_Id
    --
    FUNCTION  Get_Old_Op_Seq_Id(p_op_seq_id IN NUMBER )
       RETURN NUMBER
    IS
        l_old_op_seq_id NUMBER := NULL ;
    BEGIN

        SELECT old_operation_sequence_id
        INTO   l_old_op_seq_id
        FROM   BOM_OPERATION_SEQUENCES
        WHERE  operation_sequence_id = p_op_seq_id ;

        RETURN l_old_op_seq_id ;

        /* Error should be processed as Unexpected Error */

    END ;

-- Added for bug 2689249
    -- bug:4689856 Included a check on basis type for identifying sub resource
    PROCEDURE Val_Principal_Sub_Res_Unique
    ( p_op_seq_id     IN NUMBER
    , p_res_id	      IN NUMBER
    , p_sub_group_num IN NUMBER
    , p_rep_group_num IN NUMBER
    , p_basis_type    IN NUMBER
    , p_schedule_flag IN NUMBER  /* Added new parameter for bug 13005178 */
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR l_principal_csr   ( p_op_seq_id     NUMBER
                               , p_res_id	  NUMBER
                               , p_sub_group_num  NUMBER
                               , p_rep_group_num  NUMBER
                               , p_basis_type     NUMBER
                               , p_schedule_flag  NUMBER  /* Added for bug 13005178 */
                               )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_SUB_OPERATION_RESOURCES
                         WHERE  principle_flag = 1 -- Yes
                         AND    NVL(acd_type, l_ACD_ADD) <> l_ACD_DISABLE
                         AND    (
                                    ( resource_id <> p_res_id )
                                OR  ( ( resource_id = p_res_id )
                                      AND ( basis_type <> p_basis_type
                                           OR schedule_flag <> p_schedule_flag ) ) /* Added for bug 13005178 */
                                )
                         AND    substitute_group_num  = p_sub_group_num
                         AND    replacement_group_num = p_rep_group_num
                         AND    operation_sequence_id = p_op_seq_id
                        ) ;

    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_principal_rec IN l_principal_csr ( p_op_seq_id
                                            , p_res_id
                                            , p_sub_group_num
                                            , p_rep_group_num
                                            , p_basis_type
                                            , p_schedule_flag  /* Added for bug 13005178 */
                                            )
       LOOP
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;

/*
       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN
	  null; -- Substitute resources cannot be added from ECOs
       END IF ;
*/

    END Val_Principal_Sub_Res_Unique ;

  /*Fix for bug 6074930 -Added below procedure Val_schedule_flag.
     It is called by procedure Check_Entity.
     Purpose: Scheduled simultaneous resources/sub-resources should have the
     same scheduling flag. Resources/sub-resources with schedule flag 'No'
     are unscheduled and hence exempt for this validation.*/

     PROCEDURE Val_Schedule_Flag
    (  p_op_seq_id     IN  NUMBER
     , p_res_seq_num   IN  NUMBER
     , p_sch_seq_num   IN  NUMBER
     , p_sch_flag      IN  NUMBER
     , p_sub_grp_num   IN  NUMBER
     , p_rep_grp_num   IN  NUMBER
     , p_basis_type    IN  NUMBER
     , p_in_res_id     IN  NUMBER
     , p_ret_res_id    IN OUT NOCOPY NUMBER
     , x_return_status IN OUT NOCOPY VARCHAR2
     )
     IS
       l_resource_id number;

       CURSOR l_sch_res_cur IS
       SELECT resource_id
       FROM   bom_operation_resources
       WHERE  operation_sequence_id = p_op_seq_id
       AND    nvl(schedule_seq_num,resource_seq_num) = p_sch_seq_num
       AND    schedule_flag not in (p_sch_flag,l_NO_SCHEDULE)
       AND    rownum=1;

       CURSOR l_sch_sub_res_cur IS
       SELECT resource_id
       FROM   bom_sub_operation_resources
       WHERE  operation_sequence_id = p_op_seq_id
       AND    schedule_seq_num      = p_sch_seq_num
       AND    schedule_flag not in (p_sch_flag,l_NO_SCHEDULE)
       AND    (
                   substitute_group_num  <> p_sub_grp_num
               OR  replacement_group_num <> p_rep_grp_num
               OR        basis_type              <> p_basis_type
               OR        resource_id              <> p_in_res_id
               )
       AND    rownum=1;

     BEGIN
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_resource_id   := FND_API.G_MISS_NUM;

            /* Verify whether the current sub-resource violates the validation w.r.t to
               any existing resource. */
            OPEN  l_sch_res_cur;
            FETCH l_sch_res_cur INTO l_resource_id;

            /* Return error status if violation occurs */
            IF l_sch_res_cur%FOUND THEN
                   p_ret_res_id        := l_resource_id;
                   x_return_status := Error_Handler.G_STATUS_ERROR;
            END IF;

            IF l_sch_res_cur%ISOPEN THEN
                    CLOSE l_sch_res_cur;
            END IF;

            /* If no violated resource is found above, then verify whether the current sub-resource
               violates the validation w.r.t to any existing sub-resource. */
           IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

                   OPEN  l_sch_sub_res_cur;
                   FETCH l_sch_sub_res_cur INTO l_resource_id;

                   /* Return error status if violation occurs */
                   IF l_sch_sub_res_cur%FOUND THEN
                           p_ret_res_id        := l_resource_id;
                           x_return_status := Error_Handler.G_STATUS_ERROR;
                   END IF;

                   IF l_sch_sub_res_cur%ISOPEN THEN
                           CLOSE l_sch_sub_res_cur;
                   END IF;

           END IF;

     END Val_Schedule_Flag;


    /******************************************************************
    * Procedure     : Check_Existence used by RTG BO
    * Parameters IN : Sub Operation Resource exposed column record
    *                 Sub Operation Resource unexposed column record
    * Parameters out: Old Sub Operation Resource exposed column record
    *                 Old Sub Operation Resource unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Routing Sub Op Resource to Revised Sub Op
    *                 Resource and Call Check_Existence for ECO Bo.
    *                 After calling Check_Existence, convert old Revised
    *                 Op Resource record back to Routing Op Resource
    *********************************************************************/
    PROCEDURE Check_Existence
    (  p_sub_resource_rec        IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_sub_res_unexp_rec       IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_old_sub_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , x_old_sub_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status           IN OUT NOCOPY VARCHAR2
    )

   IS
        l_rev_sub_resource_rec      Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
        l_rev_sub_res_unexp_rec     Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;
        l_old_rev_sub_resource_rec  Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
        l_old_rev_sub_res_unexp_rec Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to ECO Operation
        Bom_Rtg_Pub.Convert_RtgSubRes_To_EcoSubRes
        (  p_rtg_sub_resource_rec      => p_sub_resource_rec
         , p_rtg_sub_res_unexp_rec     => p_sub_res_unexp_rec
         , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
         , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
        ) ;

        -- Call Check_Existence
        Bom_Validate_Sub_Op_Res.Check_Existence
        (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
         , x_old_rev_sub_resource_rec  => l_old_rev_sub_resource_rec
         , x_old_rev_sub_res_unexp_rec => l_old_rev_sub_res_unexp_rec
         , x_return_status             => x_return_status
         , x_mesg_token_tbl            => x_mesg_token_tbl
        ) ;

        -- Convert old Eco Opeartion Record back to Routing Operation
        Bom_Rtg_Pub.Convert_EcoSubRes_To_RtgSubRes
        (  p_rev_sub_resource_rec      => l_old_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec     => l_old_rev_sub_res_unexp_rec
         , x_rtg_sub_resource_rec      => x_old_sub_resource_rec
         , x_rtg_sub_res_unexp_rec     => x_old_sub_res_unexp_rec
         ) ;


    END Check_Existence ;


    /******************************************************************
    * Procedure     : Check_Existence used by ECO BO
    *                                   and internally called by RTG BO
    * Parameters IN : Sub Revised operation resource exposed column record
    *                 Sub Revised operation resource unexposed column record
    * Parameters out: Old Sub Revised operation resource exposed column record
    *                 Old Sub Revised operation resource unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Check_Existence will query using the primary key
    *                 information and return a success if the operation
    *                 resource is CREATE and the record EXISTS or will
    *                 return an error if the substitute operation resource
    *                 is UPDATE and record DOES NOT EXIST.
    *                 In case of UPDATE if record exists, then the procedure
    *                 will return old record in the old entity parameters
    *                 with a success status.
    *********************************************************************/

    PROCEDURE Check_Existence
    (  p_rev_sub_resource_rec        IN  Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type
     , p_rev_sub_res_unexp_rec       IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , x_old_rev_sub_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type
     , x_old_rev_sub_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status               IN OUT NOCOPY VARCHAR2
    )
    IS
       l_Token_Tbl      Error_Handler.Token_Tbl_Type;
       l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
       l_return_status  VARCHAR2(1);
       l_default_basis_type NUMBER;

    BEGIN

       l_return_status := FND_API.G_RET_STS_SUCCESS;
       x_return_status := FND_API.G_RET_STS_SUCCESS;


       l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
       l_Token_Tbl(1).token_value :=
                        p_rev_sub_resource_rec.sub_resource_code ;
       l_Token_Tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
       l_Token_Tbl(2).token_value :=
                        nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number) ;
       l_Token_Tbl(3).token_name  := 'REVISED_ITEM_NAME';
       l_Token_Tbl(3).token_value := p_rev_sub_resource_rec.revised_item_name;

       -- If basis type is null then take the resource's default basis type
       IF (   p_rev_sub_resource_rec.basis_type IS NULL
          OR  p_rev_sub_resource_rec.basis_type = FND_API.G_MISS_NUM )
       THEN
         BEGIN
           SELECT  br.DEFAULT_BASIS_TYPE
           INTO    l_default_basis_type
           FROM    BOM_RESOURCES br
           WHERE   br.RESOURCE_ID = p_rev_sub_res_unexp_rec.resource_id;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_default_basis_type := 1;
         END;
       ELSE
         l_default_basis_type := p_rev_sub_resource_rec.basis_type;
       END IF;

       Bom_Sub_Op_Res_Util.Query_Row
       ( p_resource_id               =>  p_rev_sub_res_unexp_rec.resource_id
       , p_substitute_group_number   =>  nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number)
       , p_operation_sequence_id     =>  p_rev_sub_res_unexp_rec.operation_sequence_id
       , p_replacement_group_number  =>  p_rev_sub_resource_rec.replacement_group_number--bug 2489765
       , p_basis_type                =>  l_default_basis_type
       , p_schedule_flag             =>  p_rev_sub_resource_rec.schedule_flag  /* Added for bug 13005178 */
       , p_acd_type                  =>  p_rev_sub_resource_rec.acd_type
       , p_mesg_token_tbl            =>  l_mesg_token_tbl
       , x_rev_sub_resource_rec      =>  x_old_rev_sub_resource_rec
       , x_rev_sub_res_unexp_rec     =>  x_old_rev_sub_res_unexp_rec
       , x_mesg_token_tbl            =>  l_mesg_token_tbl
       , x_return_status             =>  l_return_status
       ) ;

            IF l_return_status = BOM_Rtg_Globals.G_RECORD_FOUND AND
               p_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
            THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'BOM_SUB_RES_ALREADY_EXISTS'
                     , p_token_tbl      => l_token_tbl
                     ) ;
                    l_return_status := FND_API.G_RET_STS_ERROR ;

            ELSIF l_return_status = BOM_Rtg_Globals.G_RECORD_NOT_FOUND AND
               p_rev_sub_resource_rec.transaction_type IN
                    (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
            THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'BOM_SUB_RES_DOESNOT_EXIST'
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
                                               || 'Sub Operation Resources '
                                               || p_rev_sub_resource_rec.sub_resource_code
                                               || ': Schedule Seq Num '
                                               || nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number)
                     , p_token_tbl          => l_token_tbl
                     ) ;
            ELSE
                    l_return_status := FND_API.G_RET_STS_SUCCESS;
            END IF ;

            x_return_status  := l_return_status;
            x_mesg_token_tbl := l_Mesg_Token_Tbl;

    END Check_Existence;



    /********************************************************************
    * Procedure : Check_Attributes used by RTG BO
    * Parameters IN : Sub Operation Resource exposed column record
    *                 Sub Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Sub Operation Resource to ECO Sub Operation
    *             Resource and Call Check_Attributes for ECO BO.
    *             Check_Attributes will verify the exposed attributes
    *             of the operation resource record in their own entirety.
    *             No cross entity validations will be performed.
    ********************************************************************/
    PROCEDURE Check_Attributes
    (  p_sub_resource_rec    IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_sub_res_unexp_rec   IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status       IN OUT NOCOPY VARCHAR2
    )
    IS

       l_rev_sub_resource_rec    Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
       l_rev_sub_res_unexp_rec   Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;

    BEGIN

       -- Convert Routing Operation to ECO Operation
       Bom_Rtg_Pub.Convert_RtgSubRes_To_EcoSubRes
        (  p_rtg_sub_resource_rec      => p_sub_resource_rec
         , p_rtg_sub_res_unexp_rec     => p_sub_res_unexp_rec
         , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
         , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
        ) ;

       -- Call Check Attributes procedure
       Bom_Validate_Sub_Op_Res.Check_Attributes
        (  p_rev_sub_resource_rec  => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec => l_rev_sub_res_unexp_rec
         , x_return_status         => x_return_status
         , x_mesg_token_tbl        => x_mesg_token_tbl
        ) ;

    END Check_Attributes ;


    /***************************************************************
    * Procedure : Check_Attribute (Validation) for CREATE and UPDATE
    *             by ECO BO  and internally called by RTG BO
    * Parameters IN : Revised Sub Operation Resource exposed column record
    *                 Revised Sub Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Attribute validation procedure will validate each
    *             attribute of Sub Revised operation resource in its entirety.
    *             If the validation of a column requires looking at some
    *             other columns value then the validation is done at
    *             the Entity level instead.
    *             All errors in the attribute validation are accumulated
    *             before the procedure returns with a Return_Status
    *             of 'E'.
    *********************************************************************/
    PROCEDURE Check_Attributes
    (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type
     , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    )
    IS

    l_return_status     VARCHAR2(1) ;
    l_err_text          VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;
    l_Token_Tbl         Error_Handler.Token_Tbl_Type ;

    BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Set the first token to be equal to the operation sequence number
       l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
       l_Token_Tbl(1).token_value :=
                        p_rev_sub_resource_rec.sub_resource_code ;
       l_Token_Tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
       l_Token_Tbl(2).token_value :=
                        nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number) ;

        --
        -- Check if the user is trying to update a record with
        -- missing value when the column value is required.
        --
        IF p_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
        THEN

        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Sub Operation Resource Attr Validation: Missing Value. . . ' ) ;
        END IF;

            -- New Sub Resource Code
            IF p_rev_sub_resource_rec.new_sub_resource_code = FND_API.G_MISS_CHAR
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RESCODE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;



            -- Replacement Group Number
            IF p_rev_sub_resource_rec.replacement_group_number = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_RPLAC_GNUM_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- New Replacement Group Number -- bug 3741570
            IF p_rev_sub_resource_rec.new_replacement_group_number = FND_API.G_MISS_NUM
            THEN
               Error_Handler.Add_Error_Token
               (  p_Message_Name       => 'BOM_SUB_RES_RPLAC_GNUM_MISSING'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_Token_Tbl          => l_Token_Tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Standard Rate Flag
            IF p_rev_sub_resource_rec.standard_rate_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_STD_RATE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Assigned Units
            IF p_rev_sub_resource_rec.assigned_units = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_ASGND_UNTS_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Usage Rate or Amount
            IF p_rev_sub_resource_rec.usage_rate_or_amount = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_RATE_AMT_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Usage Rate or Amount Inverse
            IF p_rev_sub_resource_rec.usage_rate_or_amount_inverse = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_RTAMT_INVR_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Basis Type
            IF p_rev_sub_resource_rec.basis_type = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_BASISTYPE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- New Basis Type
            IF p_rev_sub_resource_rec.new_basis_type = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_BASISTYPE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Schedule Flag
            IF p_rev_sub_resource_rec.schedule_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_SCHED_FLAG_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

            -- Added for bug 13005178, New Schedule Flag validation
            IF p_rev_sub_resource_rec.new_schedule_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_SCHED_FLAG_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

            -- Autocharge Type
            IF p_rev_sub_resource_rec.autocharge_type = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_ACHRG_TYPE_MISSING'
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
        ('Sub Operation Resource Attr Validation: Invalid Value. . . ' || l_return_status) ;
        END IF;


            -- New Sub Resource Code
            IF p_rev_sub_resource_rec.new_sub_resource_code IS NOT NULL
               AND p_rev_sub_resource_rec.new_sub_resource_code <> FND_API.G_MISS_CHAR
               AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_CODE_NOTUPDATE'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Replacement Group Num
            IF p_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               AND (p_rev_sub_resource_rec.replacement_group_number IS NULL
                   OR p_rev_sub_resource_rec.replacement_group_number = FND_API.G_MISS_NUM)
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_REPLCMNT_GNUM_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR ;

            ELSIF p_rev_sub_resource_rec.replacement_group_number IS NOT NULL AND
                  p_rev_sub_resource_rec.replacement_group_number <> FND_API.G_MISS_NUM AND
                 ( p_rev_sub_resource_rec.replacement_group_number < 1
                 OR  p_rev_sub_resource_rec.replacement_group_number > 9999 )
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_RPLMT_GNUM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;


            -- New Replacement Group Number -- bug 3741570
            IF p_rev_sub_resource_rec.replacement_group_number IS NOT NULL
               AND p_rev_sub_resource_rec.replacement_group_number <> FND_API.G_MISS_NUM
               AND ( p_rev_sub_resource_rec.replacement_group_number < 1
                  OR p_rev_sub_resource_rec.replacement_group_number > 9999 )
            THEN
               Error_Handler.Add_Error_Token
               (  p_Message_Name       => 'BOM_SUB_RES_RPLMT_GNUM_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_Token_Tbl          => l_Token_Tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;


            -- Standard Rate Flag
            IF  p_rev_sub_resource_rec.standard_rate_flag IS NOT NULL
            AND p_rev_sub_resource_rec.standard_rate_flag NOT IN (1,2)
            AND p_rev_sub_resource_rec.standard_rate_flag <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_STD_RATE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Principle Flag
            IF  p_rev_sub_resource_rec.principle_flag IS NOT NULL
            AND p_rev_sub_resource_rec.principle_flag NOT IN (1,2)
            AND p_rev_sub_resource_rec.principle_flag <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_PCLFLAG_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Resource Offset Percent
            IF  p_rev_sub_resource_rec.resource_offset_percent IS NOT NULL
            AND (p_rev_sub_resource_rec.resource_offset_percent < 0
                 OR  p_rev_sub_resource_rec.resource_offset_percent > 100 )
            AND  p_rev_sub_resource_rec.resource_offset_percent <> FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                   Error_Handler.Add_Error_Token
                   ( p_Message_Name   => 'BOM_SUB_RES_OFFSET_PCT_INVALID'
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_Token_Tbl      => l_Token_Tbl
                   ) ;
               END IF ;
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Assigned Units
            IF  p_rev_sub_resource_rec.assigned_units IS NOT NULL
            AND p_rev_sub_resource_rec.assigned_units  <= 0.00001
            AND p_rev_sub_resource_rec.assigned_units <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_ASSGN_UNTS_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Basis Type
            IF  p_rev_sub_resource_rec.basis_type IS NOT NULL
            AND p_rev_sub_resource_rec.basis_type NOT IN (1,2)
            AND p_rev_sub_resource_rec.basis_type <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_BASISTYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- New Basis Type
            IF  p_rev_sub_resource_rec.new_basis_type IS NOT NULL
            AND p_rev_sub_resource_rec.new_basis_type NOT IN (1,2)
            AND p_rev_sub_resource_rec.new_basis_type <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_BASISTYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Schedule Flag
            IF  p_rev_sub_resource_rec.schedule_flag IS NOT NULL
            AND p_rev_sub_resource_rec.schedule_flag NOT IN (1,2,3,4)
            AND p_rev_sub_resource_rec.schedule_flag <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_SCHED_FLAG_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

            -- Added for bug 13005178, New Schedule Flag Validation Added
            IF  p_rev_sub_resource_rec.new_schedule_flag IS NOT NULL
            AND p_rev_sub_resource_rec.new_schedule_flag NOT IN (1,2,3,4)
            AND p_rev_sub_resource_rec.new_schedule_flag <> FND_API.G_MISS_NUM
            THEN
               Error_Handler.Add_Error_Token
               (  p_Message_Name       => 'BOM_SUB_RES_SCHED_FLAG_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_Token_Tbl          => l_Token_Tbl
                );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;

            -- Autocharge Type
            IF  p_rev_sub_resource_rec.autocharge_type IS NOT NULL
            AND p_rev_sub_resource_rec.autocharge_type NOT IN (1,2,3,4)
            AND p_rev_sub_resource_rec.autocharge_type <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_ACHRG_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- ACD Type
            IF p_rev_sub_resource_rec.acd_type IS NOT NULL
               AND p_rev_sub_resource_rec.acd_type NOT IN
                        (l_ACD_ADD, l_ACD_DISABLE)
               AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
            THEN

               l_token_tbl(2).token_name  := 'ACD_TYPE';
               l_token_tbl(2).token_value := p_rev_sub_resource_rec.acd_type;

               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SUB_RES_ACD_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
               l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF ;

            -- Schedule Sequence Number
            IF (p_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                AND p_rev_sub_resource_rec.schedule_sequence_number IS NULL)
              OR (p_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
                  AND p_rev_sub_resource_rec.schedule_sequence_number = FND_API.G_MISS_NUM)
              OR p_rev_sub_resource_rec.schedule_sequence_number = 0
            THEN
               Error_Handler.Add_Error_Token
               (  p_Message_Name       => 'BOM_SSN_ZERO_VALUE'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                --, p_Token_Tbl          => l_Token_Tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;

       --  Done validating attributes
        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Sub Operation Resource Attr Validation completed with return_status: ' || l_return_status) ;
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


    /*******************************************************************
    * Procedure : Check_Entity used by RTG BO
    * Parameters IN : Sub Operation Resource exposed column record
    *                 Sub Operation Resource unexposed column record
    *                 Old Sub Operation Resource exposed column record
    *                 Old Sub Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Convert Routing Op Resource to ECO Op Resource and
    *                 Call Check_Entity for ECO BO.
    *                 Procedure will execute the business logic and will
    *                 also perform any required cross entity validations
    *******************************************************************/
    PROCEDURE Check_Entity
    (  p_sub_resource_rec      IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_sub_res_unexp_rec     IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , p_old_sub_resource_rec  IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_old_sub_res_unexp_rec IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_sub_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , x_sub_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    )
    IS
        l_rev_sub_resource_rec      Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
        l_rev_sub_res_unexp_rec     Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;
        l_old_rev_sub_resource_rec  Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
        l_old_rev_sub_res_unexp_rec Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to ECO Operation
        Bom_Rtg_Pub.Convert_RtgSubRes_To_EcoSubRes
        (  p_rtg_sub_resource_rec      => p_sub_resource_rec
         , p_rtg_sub_res_unexp_rec     => p_sub_res_unexp_rec
         , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
         , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
        ) ;


        -- Also Convert Old Routing Operation to Old ECO Operation
        Bom_Rtg_Pub.Convert_RtgSubRes_To_EcoSubRes
        (  p_rtg_sub_resource_rec      => p_old_sub_resource_rec
         , p_rtg_sub_res_unexp_rec     => p_old_sub_res_unexp_rec
         , x_rev_sub_resource_rec      => l_old_rev_sub_resource_rec
         , x_rev_sub_res_unexp_rec     => l_old_rev_sub_res_unexp_rec
        ) ;

        -- Call Check_Entity
        Bom_Validate_Sub_Op_Res.Check_Entity
       (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
        , p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
        , p_old_rev_sub_resource_rec  => l_old_rev_sub_resource_rec
        , p_old_rev_sub_res_unexp_rec => l_old_rev_sub_res_unexp_rec
        , p_control_rec => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
        , x_rev_sub_resource_rec      => l_rev_sub_resource_rec
        , x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
        , x_return_status            => x_return_status
        , x_mesg_token_tbl           => x_mesg_token_tbl
        ) ;


        -- Convert Eco Op Resource Record back to Routing Op Resource
        Bom_Rtg_Pub.Convert_EcoSubRes_To_RtgSubRes
        (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
         , p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
         , x_rtg_sub_resource_rec      => x_sub_resource_rec
         , x_rtg_sub_res_unexp_rec     => x_sub_res_unexp_rec
         ) ;


    END Check_Entity ;


    /*******************************************************************
    * Procedure : Check_Entity used by RTG BO and internally called by RTG BO
    * Parameters IN : Revised Sub Op Resource exposed column record
    *                 Revised Sub Op Resource unexposed column record
    *                 Old Revised Sub Op Resource exposed column record
    *                 Old Revised Sub Op Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Check_Entity validate the entity for the correct
    *                 business logic. It will verify the values by running
    *                 checks on inter-dependent columns.
    *                 It will also verify that changes in one column value
    *                 does not invalidate some other columns.
    *******************************************************************/
    PROCEDURE Check_Entity
    (  p_rev_sub_resource_rec      IN  Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type
     , p_rev_sub_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , p_old_rev_sub_resource_rec  IN  Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type
     , p_old_rev_sub_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_sub_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type
     , x_rev_sub_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status             IN OUT NOCOPY VARCHAR2
    )
    IS

    -- Variables
    l_eco_processed     BOOLEAN ;      -- Indicate ECO has been processed

    l_hour_uom_code     VARCHAR2(3) ;  -- Hour UOM Code
    l_hour_uom_class    VARCHAR2(10) ; -- Hour UOM Class
    l_res_uom_code      VARCHAR2(3) ;  -- Resource UOM Code
    l_res_uom_class     VARCHAR2(10) ; -- Resource UOM Class
    l_temp_status       VARCHAR2(1)  ;  -- Temp Error Status
    l_old_op_seq_id     NUMBER := NULL ;  -- Old Operation Sequence Id
    /* Added below 3 vars for fixing bug 6074930 */
    l_res_code        VARCHAR2(10);
    l_res_code_2      VARCHAR2(10);
    l_res_id          NUMBER;

    l_rev_sub_resource_rec        Bom_Rtg_Pub.Rev_Sub_Resource_rec_Type ;
    l_rev_sub_res_unexp_rec       Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_token_tbl       Error_Handler.Token_Tbl_Type;

    l_get_setups        NUMBER;
    l_batchable         NUMBER;

    CURSOR   get_setups (  p_resource_id NUMBER
                         , p_org_id NUMBER
			 )
    IS
	SELECT count(setup_id)
	FROM bom_resource_setups
	WHERE resource_id = p_resource_id
	AND organization_id = p_org_id;



    -- Check Rev Sub Op Resource exists
    CURSOR  l_disable_subres_exist_csr
                                (   p_resource_id    NUMBER
                                   , p_sub_group_num  NUMBER
                                   , p_op_seq_id      NUMBER
                                 )
    IS
       SELECT 'Rev Sub Op Resource Not Exists'
       FROM   DUAL
       WHERE NOT EXISTS (SELECT NULL
                         FROM  BOM_OPERATION_SEQUENCES bos
                             , BOM_SUB_OPERATION_RESOURCES bsor
                         WHERE bsor.substitute_group_num  = p_sub_group_num
                         AND   bsor.resource_id           = p_resource_id
                         AND   bsor.operation_sequence_id = bos.operation_sequence_id
                         AND   bos.operation_sequence_id  = p_op_seq_id
                         ) ;

    -- Check Uniqueness
    CURSOR l_duplicate_csr (   p_resource_id             NUMBER
                             , p_substitute_group_number  NUMBER
                             , p_replacement_group_number NUMBER -- bug 3741570
                             , p_op_seq_id               NUMBER
                             , p_acd_type                NUMBER
                             , p_basis_type              NUMBER
                             , p_schedule_flag           NUMBER  /* Added for bug 13005178 */
                            )
    IS
        SELECT 'Sub Res Duplicate'
        FROM   DUAL
        WHERE  EXISTS  ( SELECT NULL
                         FROM   BOM_SUB_OPERATION_RESOURCES
                         WHERE  NVL(ACD_TYPE, 1)         = NVL(p_acd_type, 1)
                         AND    BASIS_TYPE               = p_basis_type
                         AND    RESOURCE_ID              = p_resource_id
                         AND    SUBSTITUTE_GROUP_NUM     = p_substitute_group_number
                         AND    REPLACEMENT_GROUP_NUM    = p_replacement_group_number -- bug 3741570
                         AND    OPERATION_SEQUENCE_ID    = p_op_seq_id
                         AND    SCHEDULE_FLAG            = p_schedule_flag  /* Added filter for bug 13005178 */
                        ) ;



    BEGIN
       --
       -- Initialize Common Record and Status
       --

       l_rev_sub_resource_rec    := p_rev_sub_resource_rec ;
       l_rev_sub_res_unexp_rec   := p_rev_sub_res_unexp_rec ;
       l_return_status := FND_API.G_RET_STS_SUCCESS;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Performing Sub Op Resource Check Entitity Validation . . .') ;
       END IF ;

       --
       -- Set the 1st token of Token Table to Revised Operation value
       --
       l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
       l_Token_Tbl(1).token_value :=
                        p_rev_sub_resource_rec.sub_resource_code ;
       l_Token_Tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
       l_Token_Tbl(2).token_value :=
                        nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number) ;


       -- The ECO can be updated but a warning needs to be generated and
       -- scheduled revised items need to be update to Open
       -- and the ECO status need to be changed to Not Submitted for Approval

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Check if ECO has been approved and has a workflow process. . . ' || l_return_status) ;
       END IF ;

       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN
          BOM_Rtg_Globals.Check_Approved_For_Process
          ( p_change_notice    => l_rev_sub_resource_rec.eco_name
          , p_organization_id  => l_rev_sub_res_unexp_rec.organization_id
          , x_processed        => l_eco_processed
          , x_err_text         => l_err_text
          ) ;

          IF l_eco_processed THEN
           -- If the above process returns true then set the ECO approval.
                BOM_Rtg_Globals.Set_Request_For_Approval
                ( p_change_notice    => l_rev_sub_resource_rec.eco_name
                , p_organization_id  => l_rev_sub_res_unexp_rec.organization_id
                , x_err_text         => l_err_text
                ) ;

          END IF ;
       END IF;


       --
       -- Performing Entity Validation in Revised Sub Op Resource(ECO BO)
       --
       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Performing Entitity Validation for Eco Routing :ACD Type. . .') ;
          END IF ;

          --
          -- ACD Type
          -- If the Transaction Type is CREATE and the ACD_Type = Disable, then
          -- the sub operation resource should already exist for the revised operation.
          --
          IF l_rev_sub_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
            AND ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD ) = l_ACD_DISABLE )
          THEN

             FOR l_disable_subres_exist_rec IN l_disable_subres_exist_csr -- add replacement_group_num to this check??
                  (   p_resource_id    => l_rev_sub_res_unexp_rec.resource_id
                    , p_sub_group_num  => nvl(l_rev_sub_resource_rec.substitute_group_number, l_rev_sub_res_unexp_rec.substitute_group_number)
                    , p_op_seq_id      => l_rev_sub_res_unexp_rec.operation_sequence_id
                  )

             LOOP
                l_token_tbl(3).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(3).token_value := l_rev_sub_resource_rec.operation_sequence_number ;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_SUB_RES_DSBL_RES_NOT_FOUND'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                ) ;
                l_token_tbl.delete(3) ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
             END LOOP ;
          END IF ;


          --
          -- ACD Type,
          -- If the Transaction Type is CREATE and the ACD_Type of parent revised
          -- operation is Add then,the ACD_Type must be Add.
          -- Call BOM_Validate_Op_Res.Get_Rev_Op_ACD(p_op_seq_id to get parent revised
          -- operation's ACD Type
          --
          IF l_rev_sub_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
          THEN
             IF
               l_ACD_ADD =
               BOM_Validate_Op_Res.Get_Rev_Op_ACD(p_op_seq_id
                              => l_rev_sub_res_unexp_rec.operation_sequence_id)
              AND  NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD ) <> l_ACD_ADD
             THEN
                l_token_tbl(3).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(3).token_value := l_rev_sub_resource_rec.operation_sequence_number ;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_SUB_RES_ACD_NOT_COMPATIBLE'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                ) ;

                l_token_tbl.delete(3) ;
                l_return_status := FND_API.G_RET_STS_ERROR ;
              END IF ;
           END IF ;


          --
          -- For UPDATE, ACD Type not updateable
          --
          IF  l_rev_sub_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_UPDATE
              AND l_rev_sub_resource_rec.acd_type <> p_old_rev_sub_resource_rec.acd_type
          THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                ( p_message_name    => 'BOM_SUB_RES_ACDTPNT_UPDATEABLE'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_token_tbl      => l_token_tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR ;
          END IF ;


          --
          -- Verify the ECO by WO Effectivity, If ECO by WO, Lot Num, Or Cum Qty, then
          -- Check if the operation resource exist in the WO or Lot Num.
          --
          IF   l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
          THEN
             IF NOT Check_ECO_By_WO_Effectivity
                    ( p_revised_item_sequence_id => l_rev_sub_res_unexp_rec.revised_item_sequence_id
                    , p_operation_seq_num        => l_rev_sub_resource_rec.operation_sequence_number
                    , p_resource_id              => l_rev_sub_res_unexp_rec.resource_id
                    , p_sub_group_num            => nvl(l_rev_sub_resource_rec.substitute_group_number, l_rev_sub_res_unexp_rec.substitute_group_number) )
             THEN
                l_token_tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                l_token_tbl(1).token_value :=
                        p_rev_sub_resource_rec.sub_resource_code ;
                l_token_tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
                l_token_tbl(2).token_value :=
                        nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number) ;
                l_token_tbl(3).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(3).token_value := l_rev_sub_resource_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_SUB_RES_RITECOWOEF_INVALID'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;

                l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                l_Token_Tbl(1).token_value :=
                                p_rev_sub_resource_rec.sub_resource_code ;
                l_Token_Tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
                l_Token_Tbl(2).token_value :=
                                nvl(p_rev_sub_resource_rec.substitute_group_number, p_rev_sub_res_unexp_rec.substitute_group_number) ;
                l_token_tbl.delete(3) ;
             END IF ;
          END IF ;


       END IF ; -- ECO BO Validation


	-- Validation for Assigned Units
	IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
	  Error_Handler.Write_Debug ('Validating the Assigned Units for a Batchable Alternate Resource . . .') ;
	END IF;

	IF l_rev_sub_resource_rec.Transaction_Type IN
	(BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
	THEN
	--
	-- APS Enhancement for Routings.
	-- Verify that if a resource has setups defined, or is Batchable then
	-- the Assigned Units for that Resource have to be 1.
	--
	  IF p_rev_sub_resource_rec.assigned_units <> FND_API.G_MISS_NUM THEN
		OPEN get_setups (p_rev_sub_res_unexp_rec.resource_id, p_rev_sub_res_unexp_rec.organization_id);
		FETCH get_setups INTO l_get_setups;
		CLOSE get_setups;
		SELECT nvl(batchable,2) INTO l_batchable
		FROM bom_resources
		WHERE resource_id = p_rev_sub_res_unexp_rec.resource_id;
		IF (l_get_setups > 0 or l_batchable = 1) THEN
			IF p_rev_sub_resource_rec.assigned_units <> 1 THEN
			    l_Token_Tbl(2).token_name  := 'RES_SEQ_NUMBER';
			    --l_Token_Tbl(2).token_value  := p_rev_sub_resource_rec.Sub_Resource_Code;
			    l_Token_Tbl(2).token_value  := p_rev_sub_resource_rec.Schedule_Sequence_Number;
			    Error_Handler.Add_Error_Token
			    (  p_Message_Name       => 'BOM_SUBRES_ASSIGND_UNITS_WRONG'
			     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
			     , p_Token_Tbl          => l_Token_Tbl
			    );
			    l_return_status := FND_API.G_RET_STS_ERROR ;
			END IF;
		END IF;
	  END IF;
	END IF;


       --
       -- For UPDATE
       -- Validation specific to the Transaction Type of Update
       --
       IF l_rev_sub_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_UPDATE

          -- In this release, Acd type : Change is not allowed.
          --
          -- OR
          -- (l_rev_sub_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
          --  AND  l_rev_sub_resource_rec.acd_type    = l_ACD_CHANGE
          --  )
       THEN
            NULL ;
       END IF ;  --  Transation: UPDATE


       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('End of Validation specific to the Transaction Type of Update' || l_return_status) ;
       END IF ;

       --
       -- Validation for Transaction Type : Create and Update
       --
       IF l_rev_sub_resource_rec.transaction_type IN
         ( BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE )
       THEN

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Common Validateion for Transaction Type : Create and Update . . . . ' || l_return_status) ;
       END IF ;

          --
          -- Resource Id
          -- Check if valid resource id exists and belongs to depatment
          -- Call BOM_Validate_Op_Res.Val_Resource_Id
          --

          IF ( (  NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
               OR  l_rev_sub_res_unexp_rec.resource_id <>
                   NVL(l_rev_sub_res_unexp_rec.new_resource_id, l_rev_sub_res_unexp_rec.resource_id )
             )
          THEN


             /* Call Val_Resource_Id */
             BOM_Validate_Op_Res.Val_Resource_Id
                             (  p_resource_id   => NVL(l_rev_sub_res_unexp_rec.new_resource_id,
                                                       l_rev_sub_res_unexp_rec.resource_id )
                             ,  p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                             ,  x_return_status => l_temp_status
                             ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_SUB_RES_RESID_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Resource is enabled. . . . ' || l_return_status) ;
          END IF ;

             END IF ;
          END IF ;

          --
          -- Check Uniqueness of Sub Op Resource Record
          --
          IF ( (  NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
               OR  l_rev_sub_res_unexp_rec.resource_id <>
                   NVL(l_rev_sub_res_unexp_rec.new_resource_id, l_rev_sub_res_unexp_rec.resource_id )
               OR  l_rev_sub_resource_rec.replacement_Group_number <>  -- bug 3741570
                   NVL(l_rev_sub_resource_rec.new_replacement_Group_number, l_rev_sub_resource_rec.replacement_Group_number)
               OR  l_rev_sub_resource_rec.basis_type <>
                   NVL(l_rev_sub_resource_rec.new_basis_type, l_rev_sub_resource_rec.basis_type)
               OR  l_rev_sub_resource_rec.schedule_flag <>
 	                    NVL(l_rev_sub_resource_rec.new_schedule_flag,  l_rev_sub_resource_rec.schedule_flag)  /* Added for bug 13005178 */
             )
          THEN
             IF     BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO
                AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
             THEN

                 FOR l_duplicate_rec  IN  l_duplicate_csr
                 (    p_resource_id            => NVL(l_rev_sub_res_unexp_rec.new_resource_id,
                                                      l_rev_sub_res_unexp_rec.resource_id )
                    , p_substitute_group_number => nvl(l_rev_sub_resource_rec.substitute_group_number,
                                                       l_rev_sub_res_unexp_rec.substitute_group_number)
                    , p_replacement_group_number => NVL(l_rev_sub_resource_rec.new_replacement_Group_number, -- bug 3741570
                                                        l_rev_sub_resource_rec.replacement_Group_number)
                    , p_op_seq_id              => l_rev_sub_res_unexp_rec.operation_sequence_id
                    , p_acd_type               => l_rev_sub_resource_rec.acd_type
                    , p_basis_type             => NVL(l_rev_sub_resource_rec.new_basis_type,
                                                      l_rev_sub_resource_rec.basis_type)
                    , p_schedule_flag          => NVL(l_rev_sub_resource_rec.new_schedule_flag,
 	                                                       l_rev_sub_resource_rec.schedule_flag)      /* Added for bug 13005178 */
                  )

                 LOOP
                    l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                    l_Token_Tbl(1).token_value :=
                                p_rev_sub_resource_rec.new_sub_resource_code ;
                    l_token_tbl(3).token_name  := 'OP_SEQ_NUMBER';
                    l_token_tbl(3).token_value := l_rev_sub_resource_rec.operation_sequence_number ;

                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       Error_Handler.Add_Error_Token
                       (  p_message_name   => 'BOM_SUB_RES_NOTUNIQUE'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                       ) ;
                    END IF ;

                    l_return_status := FND_API.G_RET_STS_ERROR ;

                    l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                    l_Token_Tbl(1).token_value :=
                                p_rev_sub_resource_rec.sub_resource_code ;
                    l_token_tbl.delete(3) ;
                 END LOOP ;
             ELSIF     BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
             THEN
                 l_old_op_seq_id := Get_Old_Op_Seq_Id
                                    (p_op_seq_id =>
                                     l_rev_sub_res_unexp_rec.operation_sequence_id ) ;


                 FOR l_duplicate_rec  IN  l_duplicate_csr
                 (    p_resource_id            => NVL(l_rev_sub_res_unexp_rec.new_resource_id,
                                                      l_rev_sub_res_unexp_rec.resource_id )
                    , p_substitute_group_number => nvl(l_rev_sub_resource_rec.substitute_group_number,
                                                       l_rev_sub_res_unexp_rec.substitute_group_number)
                    , p_replacement_group_number => l_rev_sub_resource_rec.replacement_Group_number -- bug 3741570
                    , p_op_seq_id              => l_old_op_seq_id
                    , p_acd_type               => l_rev_sub_resource_rec.acd_type
                    , p_basis_type             => l_rev_sub_resource_rec.basis_type
                    , p_schedule_flag          => l_rev_sub_resource_rec.schedule_flag   /* Added for bug 13005178 */
                  )

                 LOOP
                    l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                    l_Token_Tbl(1).token_value :=
                                NVL(p_rev_sub_resource_rec.new_sub_resource_code,
                                    p_rev_sub_resource_rec.sub_resource_code    ) ;
                    l_token_tbl(3).token_name  := 'OP_SEQ_NUMBER';
                    l_token_tbl(3).token_value := l_rev_sub_resource_rec.operation_sequence_number ;

                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       Error_Handler.Add_Error_Token
                       (  p_message_name   => 'BOM_SUB_RES_NOTUNIQUE'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                       ) ;
                    END IF ;

                    l_return_status := FND_API.G_RET_STS_ERROR ;

                    l_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
                    l_Token_Tbl(1).token_value := p_rev_sub_resource_rec.sub_resource_code ;

                    l_token_tbl.delete(3) ;

                 END LOOP ;

                 IF l_old_op_seq_id IS NULL THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => 'Unexpected error occurred. Sinse
                                                    Parent Revised Operation does not have old operation
                                                    sequence id'  || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 END IF;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check uniquness of Sub Op Resource Record. . . . ' || l_return_status) ;
          END IF ;

          END IF ;

          --
          -- Activity Id
          -- Check if Activity is enabled
          -- BOM_Validate_Op_Res.Val_Activity_Id
          --
          IF ( (  NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
                  OR NVL(l_rev_sub_res_unexp_rec.activity_id, FND_API.G_MISS_NUM)
                      <> NVL(p_old_rev_sub_res_unexp_rec.activity_id, FND_API.G_MISS_NUM)
              )
             AND ( l_rev_sub_res_unexp_rec.activity_id IS NOT NULL AND
                   l_rev_sub_res_unexp_rec.activity_id <> FND_API.G_MISS_NUM )
          THEN

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Activity_Id : ' || to_char(l_rev_sub_res_unexp_rec.activity_id)) ;
          END IF ;


             /* Call Val_Activity_Id */
             BOM_Validate_Op_Res.Val_Activity_Id
                             (  p_activity_id   => l_rev_sub_res_unexp_rec.activity_id
                             ,  p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                             ,  x_return_status => l_temp_status
                             ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_SUB_RES_ACTID_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Activity is enabled. . . . ' || l_return_status) ;
          END IF ;

          END IF ;


          --
          -- Activity Id
          -- Check if Activity is enabled
          -- BOM_Validate_Op_Res.Val_Activity_Id
          --
          IF ( (  NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
                  OR NVL(l_rev_sub_res_unexp_rec.setup_Id , FND_API.G_MISS_NUM)
                      <> NVL(p_old_rev_sub_res_unexp_rec.setup_id, FND_API.G_MISS_NUM)
              )
             AND ( l_rev_sub_res_unexp_rec.setup_id IS NOT NULL AND
                   l_rev_sub_res_unexp_rec.setup_Id <> FND_API.G_MISS_NUM )
          THEN

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Setup_Id : ' || to_char(l_rev_sub_res_unexp_rec.setup_id )) ;
          END IF ;


             /* Call Val_Activity_Id */
             BOM_Validate_Op_Res.Val_Setup_Id
             (  p_setup_id          => l_rev_sub_res_unexp_rec.setup_id
             ,  p_resource_id       =>  NVL(l_rev_sub_res_unexp_rec.new_resource_id,
                                            l_rev_sub_res_unexp_rec.resource_id )
             ,  p_organization_id   => l_rev_sub_res_unexp_rec.organization_id
             ,  x_return_status     => l_temp_status
             ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN


                   l_token_tbl(3).token_name  := 'SETUP_CODE';
                   l_token_tbl(3).token_value :=
                                        l_rev_sub_resource_rec.setup_type ;

                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_SUB_RES_SETUPID_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_token_tbl.delete(3) ;
                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Setup is enabled. . . . ' || l_return_status) ;
          END IF ;

          END IF ;


          --
          -- Schedule Flag
          -- Schedule Flag must be 2:No in following case
          -- 1. Resource UOM <> Hour UOM code(if they're the same, class would be
          --    same
          -- 2. Resource UOM class <> Hour UOM class
          -- 3. No conversion between resource UOM and Hour UOM
          --
          -- Call BOM_Validate_Op_Res.Get_Resource_Uom
          --      and BOM_Validate_Op_Res.Val_Res_UOM_For_Schedule
          --
          IF  p_rev_sub_resource_rec.schedule_flag <> l_NO_SCHEDULE -- 2: No
          THEN

             IF ( l_hour_uom_code   IS NULL OR
                  l_hour_uom_class  IS NULL OR
                  l_res_uom_code    IS NULL OR
                  l_res_uom_class   IS NULL
                 )
             THEN
                BOM_Validate_Op_Res.Get_Resource_Uom
                                 ( p_resource_id
                                  => NVL(l_rev_sub_res_unexp_rec.new_resource_id,
                                         l_rev_sub_res_unexp_rec.resource_id)
                                 , x_hour_uom_code  => l_hour_uom_code
                                 , x_hour_uom_class => l_hour_uom_class
                                 , x_res_uom_code   => l_res_uom_code
                                 , x_res_uom_class  => l_res_uom_class ) ;
             END IF ;

             /* Call Val_Scheduled_Resource */
             BOM_Validate_Op_Res.Val_Res_UOM_For_Schedule
                ( p_hour_uom_class  => l_hour_uom_class
                , p_res_uom_class   => l_res_uom_class
                , p_hour_uom_code   => l_hour_uom_code
                , p_res_uom_code    => l_res_uom_code
                , x_return_status   => l_temp_status
                ) ;

             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_SUB_RES_SCHEDULE_MUSTBE_NO'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if schedule flag is valid. . . . ' || l_return_status) ;
END IF ;

          END IF ;

          --
          -- Scheduled Resource
          -- Cannot have more than one next or prior sheduled resource for
          -- an operation.
          -- Hence, there must be related one next or prior sheduled resource
          -- in operation resource
          -- and cannot have more than one next or prior sheduled sub resource
          -- whitin substitute group num.
          --
          IF  ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_sub_resource_rec.schedule_flag
                                     <> p_old_rev_sub_resource_rec.schedule_flag
              )
          THEN

             IF p_rev_sub_resource_rec.schedule_flag  = l_PRIOR -- 3: Prior
             THEN
                /* Call Val_Scheduled_Sub_Resource
                -- From does not have this validation, then comment out
                Val_Scheduled_Sub_Resource
                ( p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                , p_resource_id   => l_rev_sub_res_unexp_rec.resource_id
                , p_sub_group_num => l_rev_sub_res_unexp_rec.substitute_group_number
                , p_schedule_flag => l_rev_sub_resource_rec.schedule_flag
                , x_return_status => l_temp_status
                ) ;
               */


                IF  l_temp_status = FND_API.G_RET_STS_ERROR
                THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_SUB_RES_PRIOR_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                   END IF ;

                   l_return_status := FND_API.G_RET_STS_ERROR ;

                END IF ;

             ELSIF p_rev_sub_resource_rec.schedule_flag  = l_NEXT -- 4: Next
             THEN

                /* Call Val_Scheduled_Sub_Resource
                -- From does not have this validation, then comment out
                Val_Scheduled_Sub_Resource
                ( p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                , p_resource_id   => l_rev_sub_res_unexp_rec.resource_id
                , p_sub_group_num => l_rev_sub_res_unexp_rec.substitute_group_number
                , p_schedule_flag => l_rev_sub_resource_rec.schedule_flag
                , x_return_status => l_temp_status
                ) ;
                */

                IF  l_temp_status = FND_API.G_RET_STS_ERROR
                THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_SUB_RES_NEXT_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                   END IF ;

                   l_return_status := FND_API.G_RET_STS_ERROR ;

                END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check next or prior scheduled resource. . . . ' || l_return_status) ;
END IF ;

             END IF ;

          END IF ;

          --
          -- Autocharge Type
          -- Autocharge type cannot be PO Receipt if the
          -- department has no location.
          -- Call BOM_Validate_Op_Res.Val_Dept_Has_Location
          --
          IF ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR  l_rev_sub_resource_rec.autocharge_type <> p_old_rev_sub_resource_rec.autocharge_type
             )
             AND l_rev_sub_resource_rec.autocharge_type = l_PO_RECEIPT
          THEN

                /* Call Val_Dept_Has_Location */
                BOM_Validate_Op_Res.Val_Dept_Has_Location
                ( p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                , x_return_status => l_temp_status
                ) ;

             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_SUB_RES_POAUTO_LOC_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
     ('Check if Dept has a location for PO Receipt Res. . . . ' || l_return_status) ;
END IF ;

          END IF ;


          --
          -- Autocharge Type
          -- Autocharge Type cannot be PO Move or PO Receipt if the resource
          -- is non-OSP resource
          -- Call BOM_Validate_Op_Res.Val_Autocharge_for_OSP_Res
          --
          IF ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR  l_rev_sub_resource_rec.autocharge_type <> p_old_rev_sub_resource_rec.autocharge_type
             )
             AND l_rev_sub_resource_rec.autocharge_type IN (l_PO_RECEIPT, l_PO_MOVE )
          THEN

                /* Call Val_Autocharge_for_OSP_Res */
                BOM_Validate_Op_Res.Val_Autocharge_for_OSP_Res
                ( p_resource_id     => NVL(l_rev_sub_res_unexp_rec.new_resource_id,
                                         l_rev_sub_res_unexp_rec.resource_id)
                , p_organization_id => l_rev_sub_res_unexp_rec.organization_id
                , x_return_status   => l_temp_status
                ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_SUB_RES_AUTO_CSTCD_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
     ('Check if resource is OSP resource when autocharge is PO Move or PO Receipt. . . . ' || l_return_status) ;
END IF ;

          END IF ;

          --
          -- Autocharge Type
          -- Cannnot have more than one PO Move per an operation
          -- Hence, there must be related PO Move resource in operation resource
          -- and cannot have more than one PO Move whitin substitute group num.
          --
          IF ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR  l_rev_sub_resource_rec.autocharge_type <> p_old_rev_sub_resource_rec.autocharge_type
             )
             AND l_rev_sub_resource_rec.autocharge_type = l_PO_MOVE
          THEN

                /* Call Val_Sub_PO_Move
                -- From does not have this validation, then comment out
                Val_Sub_PO_Move
                ( p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                , p_resource_id   => l_rev_sub_res_unexp_rec.resource_id
                , p_sub_group_num => l_rev_sub_res_unexp_rec.substitute_group_number
                , x_return_status => l_temp_status
                ) ;
                */

             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_SUB_RES_POMOVE_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Autocharge Type is enabled. . . . ' || l_return_status) ;
END IF ;


          END IF ;


          --
          -- Usage Rate or Amount
          -- Check round values for Usage Rate or Amount and the Inverse.
          -- Call BOM_Validate_Op_Res.Val_Usage_Rate_or_Amount
          --
          IF ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR  l_rev_sub_resource_rec.usage_rate_or_amount
                                        <> p_old_rev_sub_resource_rec.usage_rate_or_amount
             OR  l_rev_sub_resource_rec.usage_rate_or_amount_inverse
                                        <> p_old_rev_sub_resource_rec.usage_rate_or_amount_inverse
             )
          THEN

             /* Call Val_Usage_Rate_or_Amount */
             BOM_Validate_Op_Res.Val_Usage_Rate_or_Amount
              (  p_usage_rate_or_amount          => l_rev_sub_resource_rec.usage_rate_or_amount
              ,  p_usage_rate_or_amount_inverse  => l_rev_sub_resource_rec.usage_rate_or_amount_inverse
              ,  x_return_status                 => l_temp_status
              ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_SUB_RES_RATEORAMT_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
     ('Check round value for Usage Rate or Amount and the Inverse . . . ' || l_return_status) ;
END IF ;

          END IF ;


          --
          -- Usage Rate or Amount
          -- Cannot have negative usage rate or amount in following case
          -- 1. Autocharge Type = 3: PO Receipt or 4: PO Move
          -- 2. Schedul Flag <> 2
          -- comment out 3. Resource UOM Class = Hour UOM Class
          -- Form allows No.3
          --

          IF ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR  l_rev_sub_resource_rec.usage_rate_or_amount
                                        <> p_old_rev_sub_resource_rec.usage_rate_or_amount
             OR  l_rev_sub_resource_rec.usage_rate_or_amount_inverse
                                        <> p_old_rev_sub_resource_rec.usage_rate_or_amount_inverse
             OR  l_rev_sub_resource_rec.schedule_flag <> p_old_rev_sub_resource_rec.schedule_flag
             OR  l_rev_sub_resource_rec.autocharge_type <> p_old_rev_sub_resource_rec.autocharge_type
             )
             AND l_rev_sub_resource_rec.usage_rate_or_amount < 0
          THEN
             IF ( l_hour_uom_code   IS NULL OR
                  l_hour_uom_class  IS NULL OR
                  l_res_uom_code    IS NULL OR
                  l_res_uom_class   IS NULL
                 )
             THEN
                BOM_Validate_Op_Res.Get_Resource_Uom
                      ( p_resource_id    => NVL(l_rev_sub_res_unexp_rec.new_resource_id,
                                               l_rev_sub_res_unexp_rec.resource_id)
                      , x_hour_uom_code  => l_hour_uom_code
                      , x_hour_uom_class => l_hour_uom_class
                      , x_res_uom_code   => l_res_uom_code
                      , x_res_uom_class  => l_res_uom_class ) ;
             END IF ;


             /* Call Val_Negative_Usage_Rate */
             BOM_Validate_Op_Res.Val_Negative_Usage_Rate
               ( p_autocharge_type => l_rev_sub_resource_rec.autocharge_type
               , p_schedule_flag   => l_rev_sub_resource_rec.schedule_flag
               , p_hour_uom_class  => l_hour_uom_class
               , p_res_uom_class   => l_res_uom_class
               , x_return_status   => l_temp_status
               ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_SUB_RES_NEG_USAGRT_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check negative usage rate. . . . ' || l_return_status) ;
END IF ;

          END IF ;

	  -- Principal Flag
          -- Cannot have one more principal resource in a group of simulatenous
          -- resources
          --
	  /* Added by deepu. Validation for Principal flag is required for patchset I Bug 2689249*/

          IF  ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_sub_resource_rec.principle_flag
                                           <> p_old_rev_sub_resource_rec.principle_flag
              OR  l_rev_sub_resource_rec.replacement_group_number
                                           <> p_old_rev_sub_resource_rec.replacement_group_number
              OR  l_rev_sub_resource_rec.basis_type
                                           <> p_old_rev_sub_resource_rec.basis_type
              OR  l_rev_sub_resource_rec.schedule_flag
 	                    <> p_old_rev_sub_resource_rec.schedule_flag  /* Added for bug 13005178 */
                  )
              AND l_rev_sub_resource_rec.principle_flag = 1 -- Yes
          THEN
             -- Call Val_Principal_Res_Unique
             Val_Principal_Sub_Res_Unique
                ( p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                , p_res_id        => l_rev_sub_res_unexp_rec.resource_id
                , p_sub_group_num => nvl(l_rev_sub_resource_rec.substitute_group_number, l_rev_sub_res_unexp_rec.substitute_group_number)
                , p_rep_group_num => l_rev_sub_resource_rec.replacement_group_number
                , p_basis_type    => l_rev_sub_resource_rec.basis_type
                , p_schedule_flag => l_rev_sub_resource_rec.schedule_flag   /* Added for bug 13005178 */
                , x_return_status => l_temp_status
                ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
-- dbms_output.put_line('found error in principal flag for sub resources');
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_SUB_RES_PCFLAG_DUPLICATE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check principal flag . . . . ' || l_return_status) ;
          END IF ;

          END IF ;

 /*Fix for bug 6074930- Scheduled simultaneous resources/sub-resources must have the same scheduling flag.
             Added below code to do this validation. Sub-Resources with scheduling flag 'NO' are exempt
             for this validation. Call Val_Schedule_Flag procedure both while creating/updating a sub-resource.
             For sub-resources schedule_sequence_number is a mandatory column.*/

             IF ( l_rev_sub_resource_rec.schedule_flag <> l_NO_SCHEDULE)
                AND
                ( ( NVL(l_rev_sub_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                    AND l_rev_sub_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
                OR  l_rev_sub_resource_rec.schedule_sequence_number <> p_old_rev_sub_resource_rec.schedule_sequence_number
                OR  l_rev_sub_resource_rec.schedule_flag <>  p_old_rev_sub_resource_rec.schedule_flag
                )
             THEN
                   l_res_id := FND_API.G_MISS_NUM;

                   Val_Schedule_Flag
                   ( p_op_seq_id     => l_rev_sub_res_unexp_rec.operation_sequence_id
                   , p_res_seq_num          => null
                   , p_sch_seq_num   => l_rev_sub_resource_rec.schedule_sequence_number
                   , p_sch_flag          => l_rev_sub_resource_rec.schedule_flag
                   , p_sub_grp_num   => l_rev_sub_resource_rec.substitute_group_number
                   , p_rep_grp_num   => l_rev_sub_resource_rec.replacement_group_number
                   , p_basis_type    => l_rev_sub_resource_rec.basis_type
                   , p_in_res_id          => l_rev_sub_res_unexp_rec.resource_id
                   , p_ret_res_id          => l_res_id
                   , x_return_status => l_temp_status
                   );

                   IF l_temp_status = FND_API.G_RET_STS_ERROR THEN
                           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             If (l_rev_sub_resource_rec.sub_resource_code is not null) Then
                                   l_res_code := l_rev_sub_resource_rec.sub_resource_code;
                             Else
                                   Select resource_code into l_res_code
                                   from bom_resources_v
                                   where resource_id=l_rev_sub_res_unexp_rec.resource_id;
                             End If;

                                   Select resource_code into l_res_code_2
                                   from bom_resources_v
                                   where resource_id=l_res_id;

                             l_Token_Tbl(1).Token_Name  := 'RES_SEQ_1';
                             l_Token_Tbl(1).Token_Value:=  l_res_code;
                             l_Token_Tbl(2).Token_Name  := 'RES_SEQ_2';
                             l_Token_Tbl(2).Token_Value:=  l_res_code_2;
                             l_Token_Tbl(3).Token_Name  := 'OP_SEQ';
                             l_Token_Tbl(3).Token_Value := l_rev_sub_resource_rec.operation_sequence_number;

                             Error_Handler.Add_Error_Token
                             ( p_message_name   => 'BOM_SIM_RES_SAME_PRIOR_NEXT'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => l_Token_Tbl
                             );
                           END IF; /* end of check_msg_level */
                         l_return_status := FND_API.G_RET_STS_ERROR ;
                  END IF; /* end of l_temp_status */
             END IF; /* end of validation on resource and ssn*/
           /*End of fix for bug 6074930 */


       END IF ; -- Transaction Type : Create and Update


      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Entity Validation was processed. . . ' || l_return_status);
      END IF ;



       --
       -- Return Records
       --
       x_rev_sub_resource_rec    := l_rev_sub_resource_rec ;
       x_rev_sub_res_unexp_rec   := l_rev_sub_res_unexp_rec ;

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

END BOM_Validate_Sub_Op_Res ;

/
