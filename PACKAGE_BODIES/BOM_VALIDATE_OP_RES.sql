--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_OP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_OP_RES" AS
/* $Header: BOMLRESB.pls 120.8.12010000.2 2008/11/14 16:28:54 snandana ship $ */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLRESB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Op_Res
--
--  NOTES
--
--  HISTORY
--  18-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/

    G_Pkg_Name      VARCHAR2(30) := 'BOM_Validate_Op_Res';

    l_EVENT                       CONSTANT NUMBER := 1 ;
    l_ACD_ADD                     CONSTANT NUMBER := 1 ;
    l_ACD_CHANGE                  CONSTANT NUMBER := 2 ;
    l_ACD_DISABLE                 CONSTANT NUMBER := 3 ;
    l_YES_SCHEDULE                CONSTANT NUMBER := 1 ;
    l_NO_SCHEDULE                 CONSTANT NUMBER := 2 ;
    l_PRIOR                       CONSTANT NUMBER := 3 ;
    l_NEXT                        CONSTANT NUMBER := 4 ;
    l_PO_RECEIPT                  CONSTANT NUMBER := 3 ;
    l_PO_MOVE                     CONSTANT NUMBER := 4 ;
    l_OSP                         CONSTANT NUMBER := 4 ; -- 4 : Outside Processing



    /******************************************************************
    * OTHER LOCAL FUNCTION AND PROCEDURES
    * Purpose       : Called by Check_Entity or something
    *********************************************************************/
    --
    -- Function: Check if Op Seq Num exists in Work Order
    --           in ECO by Lot, Wo, Cum Qty
    --
    FUNCTION Check_ECO_By_WO_Effectivity
         ( p_revised_item_sequence_id  IN  NUMBER
         , p_operation_seq_num         IN  NUMBER
         , p_resource_seq_num          IN  NUMBER
         , p_organization_id           IN  NUMBER
         , p_rev_item_id               IN  NUMBER
          )

    RETURN BOOLEAN
    IS
       l_ret_status BOOLEAN := TRUE ;

       l_lot_number varchar2(30) := NULL;
       l_from_wip_entity_id NUMBER :=0;
       l_to_wip_entity_id NUMBER :=0;
       l_from_cum_qty  NUMBER :=0;


       CURSOR  l_check_lot_num_csr ( p_lot_number         VARCHAR2
                                   , p_operation_seq_num  NUMBER
                                   , p_resource_seq_num   NUMBER
                                   , p_organization_id    NUMBER
                                   , p_rev_item_id        NUMBER
                                   )
       IS
          SELECT 'Op Res does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE  (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_OPERATION_RESOURCES wor
                                             WHERE  wor.resource_seq_num  = p_resource_seq_num
                                             AND    wor.operation_seq_num = p_operation_seq_num
                                             AND    wor.wip_entity_id     = wdj.wip_entity_id)
                                 )
                         AND     wdj.lot_number = p_lot_number
                         AND     wdj.organization_id = p_organization_id
                         AND     wdj.primary_item_id = p_rev_item_id
                        ) ;

       CURSOR  l_check_wo_csr (  p_from_wip_entity_id NUMBER
                               , p_to_wip_entity_id   NUMBER
                               , p_operation_seq_num  NUMBER
                               , p_resource_seq_num   NUMBER
                               , p_organization_Id    NUMBER  )
       IS
          SELECT 'Op Res does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                               , WIP_ENTITIES       we
                               , WIP_ENTITIES       we1
                               , WIP_ENTITIES       we2
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS (SELECT NULL
                                              FROM   WIP_OPERATION_RESOURCES wor
                                              WHERE  resource_seq_num  = p_resource_seq_num
                                              AND    operation_seq_num = p_operation_seq_num
                                              AND    wip_entity_id     = wdj.wip_entity_id)
                                 )
                         AND     wdj.wip_entity_id = we.wip_entity_id
                         AND     we.organization_Id =  p_organization_id
                         AND     we.wip_entity_name >= we1.wip_entity_name
                         AND     we.wip_entity_name <= we2.wip_entity_name
                         AND     we1.wip_entity_id = p_from_wip_entity_id
                         AND     we2.wip_entity_id = NVL(p_to_wip_entity_id, p_from_wip_entity_id)
                         ) ;

      CURSOR  l_check_cum_csr (  p_from_wip_entity_id NUMBER
                               , p_operation_seq_num  NUMBER
                               , p_resource_seq_num   NUMBER )


       IS
          SELECT 'Op Res does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_OPERATION_RESOURCES wor
                                             WHERE  resource_seq_num  = p_resource_seq_num
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

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check if the rev op resource is valid in Eco by Prod. . .' );
    Error_Handler.Write_Debug('Lot Number in parent rev item : ' || l_lot_number );
    Error_Handler.Write_Debug('From WIP Entity Id  in parent rev item : ' || to_char(l_from_wip_entity_id) );
    Error_Handler.Write_Debug('To WIP Entity Id  in parent rev item : ' || to_char(l_to_wip_entity_id) );
    Error_Handler.Write_Debug('Cum Qty in parent rev item : ' || to_char(l_from_cum_qty) );
END IF;


          -- Check if Op Seq Num is exist in ECO by Lot
          IF    l_lot_number IS NOT NULL
           AND  l_from_wip_entity_id IS NULL
           AND  l_to_wip_entity_id IS NULL
           AND  l_from_cum_qty IS NULL
          THEN

             FOR l_lot_num_rec IN l_check_lot_num_csr
                               ( p_lot_number        => l_lot_number
                               , p_operation_seq_num => p_operation_seq_num
                               , p_resource_seq_num  => p_resource_seq_num
                               , p_organization_id   => p_organization_id
                               , p_rev_item_id       => p_rev_item_id
                               )
             LOOP

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Resource Seq Num : ' || to_char(p_resource_seq_num) );
    Error_Handler.Write_Debug('Op Seq Num : ' || to_char(p_operation_seq_num) );
    Error_Handler.Write_Debug('In Eco by Lot Number, this rev op res is invalid. . .' );
END IF;
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
                               , p_operation_seq_num  => p_operation_seq_num
                               , p_resource_seq_num   => p_resource_seq_num
                               )
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
                               , p_resource_seq_num   => p_resource_seq_num
                               , p_organization_id    => p_organization_id
                               )
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

    -- Get parent opertion Acd type.
    FUNCTION Get_Rev_Op_ACD (p_op_seq_id IN NUMBER) RETURN NUMBER

    IS
        CURSOR l_get_acdtype_csr(p_op_seq_id NUMBER)
        IS
           SELECT acd_type
           FROM   BOM_OPERATION_SEQUENCES
           WHERE  operation_sequence_id = p_op_seq_id ;
    BEGIN

        FOR l_get_acdtype_rec IN l_get_acdtype_csr(p_op_seq_id => p_op_seq_id)
        LOOP
           RETURN l_get_acdtype_rec.acd_type ;
        END LOOP ;
           RETURN NULL ;
    END Get_Rev_Op_ACD  ;

    /* No Longer used
    -- Check if the operation resource's attribute is updated when ACD Type is changed
    -- If updated, return False.
    FUNCTION Check_Res_Attr_changed
    (  p_rev_op_resource_rec      IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_old_rev_op_resource_rec  IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_old_rev_op_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
    ) RETURN BOOLEAN

    IS

    BEGIN

           IF  (p_rev_op_res_unexp_rec.resource_id   = p_old_rev_op_res_unexp_rec.resource_id
                  OR ( p_rev_op_res_unexp_rec.resource_id IS NULL
                     AND p_old_rev_op_res_unexp_rec.resource_id IS NULL )
                  )
              AND (p_rev_op_res_unexp_rec.activity_id   = p_old_rev_op_res_unexp_rec.activity_id
                  OR ( p_rev_op_res_unexp_rec.activity_id IS NULL
                      AND p_old_rev_op_res_unexp_rec.activity_id IS NULL )
                  )
              AND (p_rev_op_resource_rec.standard_rate_flag = p_old_rev_op_resource_rec.standard_rate_flag
                  OR ( p_rev_op_resource_rec.standard_rate_flag IS NULL
                    AND  p_old_rev_op_resource_rec.standard_rate_flag IS NULL )
                  )
              AND (p_rev_op_resource_rec.assigned_units = p_old_rev_op_resource_rec.assigned_units
                   OR ( p_rev_op_resource_rec.assigned_units IS NULL
                      AND  p_old_rev_op_resource_rec.assigned_units IS NULL )
                  )
              AND (p_rev_op_resource_rec.usage_rate_or_amount = p_old_rev_op_resource_rec.usage_rate_or_amount
                    OR ( p_rev_op_resource_rec.usage_rate_or_amount IS NULL
                       AND  p_old_rev_op_resource_rec.usage_rate_or_amount IS NULL )
                  )
              AND (p_rev_op_resource_rec.usage_rate_or_amount_inverse = p_old_rev_op_resource_rec.usage_rate_or_amount_inverse
                  OR ( p_rev_op_resource_rec.usage_rate_or_amount_inverse IS NULL
                     AND  p_old_rev_op_resource_rec.usage_rate_or_amount_inverse IS NULL )
                  )
              AND (p_rev_op_resource_rec.basis_type = p_old_rev_op_resource_rec.basis_type
                  OR ( p_rev_op_resource_rec.basis_type IS NULL
                      AND  p_old_rev_op_resource_rec.basis_type IS NULL )
                  )
              AND (p_rev_op_resource_rec.schedule_flag = p_old_rev_op_resource_rec.schedule_flag
                  OR ( p_rev_op_resource_rec.schedule_flag IS NULL
                     AND p_old_rev_op_resource_rec.schedule_flag IS NULL )
                  )
              AND (p_rev_op_resource_rec.resource_offset_percent = p_old_rev_op_resource_rec.resource_offset_percent
                  OR ( p_rev_op_resource_rec.resource_offset_percent IS NULL
                     AND  p_old_rev_op_resource_rec.resource_offset_percent IS NULL )
                  )
              AND (p_rev_op_resource_rec.autocharge_type = p_old_rev_op_resource_rec.autocharge_type
                  OR ( p_rev_op_resource_rec.autocharge_type IS NULL
                      AND  p_old_rev_op_resource_rec.autocharge_type IS NULL )
                  )
              AND (p_rev_op_resource_rec.attribute_category = p_old_rev_op_resource_rec.attribute_category
                  OR ( p_rev_op_resource_rec.attribute_category IS NULL
                      AND  p_old_rev_op_resource_rec.attribute_category IS NULL )
                  )
              AND (p_rev_op_resource_rec.attribute1  = p_old_rev_op_resource_rec.attribute1
                  OR ( p_rev_op_resource_rec.attribute1  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute1 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute2  = p_old_rev_op_resource_rec.attribute2
                  OR ( p_rev_op_resource_rec.attribute2  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute2 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute3  = p_old_rev_op_resource_rec.attribute3
                  OR ( p_rev_op_resource_rec.attribute3  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute3 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute4  = p_old_rev_op_resource_rec.attribute4
                  OR ( p_rev_op_resource_rec.attribute4  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute4 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute5  = p_old_rev_op_resource_rec.attribute5
                  OR ( p_rev_op_resource_rec.attribute5  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute5 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute6  = p_old_rev_op_resource_rec.attribute6
                  OR ( p_rev_op_resource_rec.attribute6  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute6 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute7  = p_old_rev_op_resource_rec.attribute7
                  OR ( p_rev_op_resource_rec.attribute7  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute7 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute8  = p_old_rev_op_resource_rec.attribute8
                  OR ( p_rev_op_resource_rec.attribute8  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute8 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute9  = p_old_rev_op_resource_rec.attribute9
                  OR ( p_rev_op_resource_rec.attribute9  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute9 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute10  = p_old_rev_op_resource_rec.attribute10
                  OR ( p_rev_op_resource_rec.attribute10  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute10 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute11  = p_old_rev_op_resource_rec.attribute11
                  OR ( p_rev_op_resource_rec.attribute11  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute11 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute12  = p_old_rev_op_resource_rec.attribute12
                  OR ( p_rev_op_resource_rec.attribute12  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute12 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute13  = p_old_rev_op_resource_rec.attribute13
                  OR ( p_rev_op_resource_rec.attribute13  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute13 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute14  = p_old_rev_op_resource_rec.attribute14
                  OR ( p_rev_op_resource_rec.attribute14  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute14 IS NULL)
                  )
              AND (p_rev_op_resource_rec.attribute15  = p_old_rev_op_resource_rec.attribute15
                  OR ( p_rev_op_resource_rec.attribute15  IS NULL
                      AND  p_old_rev_op_resource_rec.attribute15 IS NULL)
                  )
              AND (p_rev_op_resource_rec.schedule_sequence_number  = p_old_rev_op_resource_rec.schedule_sequence_number
                  OR ( p_rev_op_resource_rec.schedule_sequence_number  IS NULL
                      AND  p_old_rev_op_resource_rec.schedule_sequence_number IS NULL)
              AND (p_rev_op_resource_rec.substitute_group_number  =
		   p_old_rev_op_resource_rec.substitute_group_number
                   OR (
                	 p_rev_op_resource_rec.substitute_group_number
					 IS NULL
					                       AND
							       p_old_rev_op_resource_rec.substitute_group_number
							       IS NULL)

                  )
           THEN
                RETURN TRUE ;

           ELSE
                RETURN FALSE ;
           END IF ;

    END Check_Res_Attr_changed ;
    */ -- Comment out by MK

    -- Validate resoruce id.
    PROCEDURE   Val_Resource_Id
       (  p_resource_id             IN  NUMBER
       ,  p_op_seq_id               IN  NUMBER
       ,  x_return_status           IN OUT NOCOPY VARCHAR2
       )
    IS
        CURSOR l_resource_csr( p_resource_id NUMBER
                             , p_op_seq_id   NUMBER
                             )
        IS
           SELECT 'Resource is invalid'
           FROM   DUAL
           WHERE  NOT EXISTS(
                             SELECT  NULL
                             FROM    BOM_OPERATION_SEQUENCES  bos
                                   , BOM_DEPARTMENT_RESOURCES bdr
                                   , BOM_RESOURCES            br
                             WHERE NVL(br.disable_date, bos.effectivity_date + 1)
                                      > bos.effectivity_date
                             AND   NVL(br.disable_date, sysdate + 1)
                                      > trunc(sysdate)
                             AND   bdr.department_id         = bos.department_id
                             AND   bos.operation_sequence_id = p_op_seq_id
                             AND   bdr.resource_id           = br.resource_id
                             AND   br.resource_id            = p_resource_id ) ;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        FOR l_resource_rec IN l_resource_csr( p_resource_id
                                            , p_op_seq_id   )
        LOOP
           x_return_status := FND_API.G_RET_STS_ERROR ;
        END LOOP ;

    END Val_Resource_Id  ;

    -- Validate activity id.
    PROCEDURE   Val_Activity_Id
       (  p_activity_id             IN  NUMBER
       ,  p_op_seq_id               IN  NUMBER
       ,  x_return_status           IN OUT NOCOPY VARCHAR2
       )
    IS
        CURSOR l_activity_csr( p_activity_id NUMBER
                             , p_op_seq_id   NUMBER
                            )
        IS
           SELECT 'Activity is invalid'
           FROM   DUAL
           WHERE  NOT EXISTS(
                             SELECT  NULL
                             FROM    bom_operational_routings bor
                                   , BOM_OPERATION_SEQUENCES  bos
                                   , CST_ACTIVITIES           ca
                             WHERE bor.organization_id =
                                      NVL(ca.organization_id, bor.organization_id)
                             AND   NVL(TRUNC(ca.disable_date), TRUNC(bos.effectivity_date) + 1)
                                      > TRUNC(bos.effectivity_date)
                             AND   bor.routing_sequence_id   = bos.routing_sequence_id
                             AND   bos.operation_sequence_id = p_op_seq_id
                             AND   ca.activity_id            = p_activity_id ) ;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        FOR l_activity_rec IN l_activity_csr( p_activity_id
                                             , p_op_seq_id   )
        LOOP
           x_return_status := FND_API.G_RET_STS_ERROR ;
        END LOOP ;

    END Val_Activity_Id  ;


    -- Validate setup id.
    PROCEDURE   Val_Setup_Id
       (  p_setup_id              IN  NUMBER
       ,  p_resource_id           IN  NUMBER
       ,  p_organization_id       IN  NUMBER
       ,  x_return_status         IN OUT NOCOPY VARCHAR2
       )
    IS
        CURSOR l_setup_csr(  p_setup_id          NUMBER
                           , p_resource_id       NUMBER
                           , p_organization_id   NUMBER
                            )
        IS

           SELECT 'Setup Id is invalid'
           FROM   DUAL
           WHERE  NOT EXISTS(
                             SELECT  NULL
                             FROM    BOM_RESOURCE_SETUPS      brs
                                   , BOM_SETUP_TYPES          bst
                             WHERE   brs.setup_id        = bst.setup_id
                             AND     brs.organization_id = bst.organization_id
                             AND     brs.resource_id     = p_resource_id
                             AND     bst.organization_id = p_organization_id
                             AND     bst.setup_id        = p_setup_id
                             ) ;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        FOR l_setup_rec IN l_setup_csr
                          (  p_setup_id
                           , p_resource_id
                           , p_organization_id
                           )
        LOOP
           x_return_status := FND_API.G_RET_STS_ERROR ;
        END LOOP ;

    END Val_Setup_Id  ;


    -- Validate usage rate or amount and inverse
    PROCEDURE   Val_Usage_Rate_or_Amount
      (  p_usage_rate_or_amount          IN  NUMBER
      ,  p_usage_rate_or_amount_inverse  IN  NUMBER
      ,  x_return_status                 IN OUT NOCOPY VARCHAR2
      )
    IS


         x_usage         NUMBER  := NULL ;
         x_usage_inverse NUMBER  := NULL ;
         l_temp_status   BOOLEAN := TRUE ;

-- Bug 2624883
         x_usage_resiprocal NUMBER := NULL;
         x_usage_inv_resiprocal NUMBER := NULL;
-- Bug 2624883

    BEGIN

       x_return_status  := FND_API.G_RET_STS_SUCCESS ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug ('Usage : ' || to_char(p_usage_rate_or_amount) );
     Error_Handler.Write_Debug ('Usage Inv : ' || to_char(p_usage_rate_or_amount_inverse ) );
END IF ;

--
-- Bug 2624883
-- Major change in this validation
--

   -- BUG 5896587
   -- In ROUND function the decimal places have increased from 6 to 10 for Usage and Inverse Usage
   /* For bug#7322996 , In ROUND function the decimal places rounding off value changed with G_round_off_val(profile value) */
   x_usage := ROUND(p_usage_rate_or_amount, G_round_off_val);
   x_usage_inverse := ROUND(p_usage_rate_or_amount_inverse, G_round_off_val);

   if (p_usage_rate_or_amount = 0) then
      x_usage_resiprocal := 0;
   else
       x_usage_resiprocal := ROUND((1/p_usage_rate_or_amount),G_round_off_val); /* Bug 7322996 */
   end if;

   if (p_usage_rate_or_amount_inverse = 0) then
      x_usage_inv_resiprocal := 0;
   else
      x_usage_inv_resiprocal := ROUND((1/p_usage_rate_or_amount_inverse),G_round_off_val); /* Bug 7322996 */
   end if;


       -- Check usage rate and usage rate inverse
       IF ( p_usage_rate_or_amount = 0 and p_usage_rate_or_amount_inverse = 0)
       THEN
            NULL;
       ELSIF  (p_usage_rate_or_amount = 0 AND
               p_usage_rate_or_amount_inverse <> 0)
       THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
       ELSIF (p_usage_rate_or_amount_inverse = 0 AND
              p_usage_rate_or_amount <> 0)
       THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
       ELSIF (round(p_usage_rate_or_amount,G_round_off_val) <> x_usage_inv_resiprocal) /* Bug 7322996 */
               and
             (x_usage_resiprocal <> round(p_usage_rate_or_amount_inverse,G_round_off_val)) /* Bug 7322996 */
       THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;

       END IF;
/*
       x_usage  := ROUND(p_usage_rate_or_amount, 6)  ;
       -- Check usage rate and usage rate inverse
       IF  x_usage = 0
       AND p_usage_rate_or_amount_inverse  <> 0
       THEN
             l_temp_status := FALSE ;

       --
       -- Usate Rate or Amound and Inverse 's length is 42 in FORM
       --
       ELSE
           IF  p_usage_rate_or_amount
                 <> to_number(SUBSTR(to_char(x_usage), 1, 42))
           OR  p_usage_rate_or_amount_inverse
                 <>  to_number(SUBSTR(to_char(ROUND( 1/x_usage , 6)) , 1, 42))
           THEN
                l_temp_status := FALSE  ;
           END IF ;

       END IF ;


       x_usage_inverse  := ROUND(p_usage_rate_or_amount_inverse , 6)  ;

       IF   NOT l_temp_status
       AND  x_usage_inverse = 0
       AND  p_usage_rate_or_amount <> 0
       THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;

       --
       -- Usate Rate or Amound and Inverse 's length is 42 in FORM
       --
       ELSIF NOT l_temp_status
       THEN
           IF p_usage_rate_or_amount_inverse
                <>  to_number(SUBSTR(to_char(x_usage_inverse), 1, 42))
           OR    p_usage_rate_or_amount
                <>  to_number( SUBSTR(to_char(ROUND( 1/ x_usage_inverse , 6 )), 1, 42 ))
           THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;
           END IF ;

       END IF ;
*/
       /****  Comment out old validation for usage rate
       -- Check usage rate and usage rate inverse
       IF p_usage_rate_or_amount <> 0 THEN
          IF ROUND(p_usage_rate_or_amount, 6) <>
             ROUND((1 / p_usage_rate_or_amount_inverse), 6) THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF ;
       ELSIF p_usage_rate_or_amount = 0 then
          IF p_usage_rate_or_amount_inverse <> 0 THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF ;
       END IF ;
       ***************************************************/


    END Val_Usage_Rate_or_Amount ;


    -- Validate scheduled resource
    PROCEDURE   Val_Scheduled_Resource
    ( p_op_seq_id     IN  NUMBER
    , p_res_seq_num   IN  NUMBER
    , p_schedule_flag IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR l_schedule_csr ( p_op_seq_id      NUMBER
                             , p_res_seq_num    NUMBER
                             , p_schedule_flag  NUMBER
                             )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES
                         WHERE  schedule_flag         = p_schedule_flag
                         AND    resource_seq_num     <> p_res_seq_num
                         AND    operation_sequence_id = p_op_seq_id
                        ) ;


       CURSOR l_rev_schedule_csr ( p_op_seq_id      NUMBER
                                 , p_res_seq_num    NUMBER
                                 , p_schedule_flag  NUMBER
                                  )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES bor
                              , BOM_OPERATION_SEQUENCES bos
                         WHERE  bor.schedule_flag         = p_schedule_flag
                         AND    bor.resource_seq_num     <> p_res_seq_num
                         AND    bor.operation_sequence_id = old_operation_sequence_id
                         AND    bos.acd_type              = l_ACD_CHANGE
                         AND    bos.operation_sequence_Id = p_op_seq_id
                        ) ;



    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_schedule_rec IN l_schedule_csr ( p_op_seq_id
                                            , p_res_seq_num
                                            , p_schedule_flag
                                            )
       LOOP
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;


       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN

           FOR l_rev_schedule_rec IN l_rev_schedule_csr ( p_op_seq_id
                                                        , p_res_seq_num
                                                        , p_schedule_flag
                                                         )
           LOOP
              x_return_status := FND_API.G_RET_STS_ERROR ;
           END LOOP ;
       END IF ;


    END Val_Scheduled_Resource ;


    -- Validate scheduled resource
    PROCEDURE   Val_Scheduled_Resource
    ( p_op_seq_id     IN  NUMBER
    , p_res_seq_num   IN  NUMBER
    , p_sch_seq_num   IN  NUMBER
    , p_schedule_flag IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR l_schedule_csr ( p_op_seq_id      NUMBER
                             , p_res_seq_num    NUMBER
                             , p_sch_seq_num    NUMBER
                             , p_schedule_flag  NUMBER
                             )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES
                         WHERE  schedule_flag         NOT IN (p_schedule_flag, l_NO_SCHEDULE)
                         AND    operation_sequence_id = p_op_seq_id
                         AND    resource_seq_num     <> p_res_seq_num
                         AND    schedule_seq_num     =  p_sch_seq_num
                        ) ;


       CURSOR l_rev_schedule_csr ( p_op_seq_id      NUMBER
                                 , p_res_seq_num    NUMBER
                                 , p_sch_seq_num    NUMBER
                                 , p_schedule_flag  NUMBER
                                  )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES bor
                              , BOM_OPERATION_SEQUENCES bos
                         WHERE  bor.schedule_flag        NOT IN (p_schedule_flag, l_NO_SCHEDULE)
                         AND    bor.resource_seq_num     <> p_res_seq_num
                         AND    bor.operation_sequence_id = old_operation_sequence_id
                         AND    bor.schedule_seq_num      = p_sch_seq_num
                         AND    bos.acd_type              = l_ACD_CHANGE
                         AND    bos.operation_sequence_Id = p_op_seq_id
                        ) ;

       CURSOR l_yes_csr ( p_op_seq_id      NUMBER
                        , p_res_seq_num    NUMBER
                        , p_sch_seq_num    NUMBER
                        , p_schedule_flag  NUMBER
                        )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES
                         WHERE  schedule_flag         IN (L_PRIOR, L_NEXT)
                         AND    operation_sequence_id = p_op_seq_id
                         AND    resource_seq_num     <> p_res_seq_num
                         AND    schedule_seq_num     =  p_sch_seq_num
                        ) ;


       CURSOR l_rev_yes_csr ( p_op_seq_id      NUMBER
                            , p_res_seq_num    NUMBER
                            , p_sch_seq_num    NUMBER
                            , p_schedule_flag  NUMBER
                            )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES bor
                              , BOM_OPERATION_SEQUENCES bos
                         WHERE  bor.schedule_flag        IN (L_PRIOR, L_NEXT)
                         AND    bor.resource_seq_num     <> p_res_seq_num
                         AND    bor.operation_sequence_id = old_operation_sequence_id
                         AND    bor.schedule_seq_num      = p_sch_seq_num
                         AND    bos.acd_type              = l_ACD_CHANGE
                         AND    bos.operation_sequence_Id = p_op_seq_id
                        ) ;

    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;
       IF p_schedule_flag IN (L_PRIOR, L_NEXT) THEN
         FOR l_schedule_rec IN l_schedule_csr ( p_op_seq_id
                                              , p_res_seq_num
                                              , p_sch_seq_num
                                              , p_schedule_flag
                                              )
         LOOP
            x_return_status := FND_API.G_RET_STS_ERROR ;
         END LOOP ;

         IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
         THEN

           FOR l_rev_schedule_rec IN l_rev_schedule_csr ( p_op_seq_id
                                                        , p_res_seq_num
                                                        , p_sch_seq_num
                                                        , p_schedule_flag
                                                         )
           LOOP
              x_return_status := FND_API.G_RET_STS_ERROR ;
           END LOOP ;
         END IF ;
       ELSIF p_schedule_flag = L_YES_SCHEDULE THEN
         FOR l_schedule_rec IN l_yes_csr ( p_op_seq_id
                                         , p_res_seq_num
                                         , p_sch_seq_num
                                         , p_schedule_flag
                                         )
         LOOP
            x_return_status := FND_API.G_RET_STS_ERROR ;
         END LOOP ;

         IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
         THEN

           FOR l_rev_schedule_rec IN l_rev_yes_csr ( p_op_seq_id
                                                   , p_res_seq_num
                                                   , p_sch_seq_num
                                                   , p_schedule_flag
                                                   )
           LOOP
              x_return_status := FND_API.G_RET_STS_ERROR ;
           END LOOP ;
         END IF ;
       END IF;

    END Val_Scheduled_Resource ;

    -- Validate autocharge for OSP resource
    PROCEDURE   Val_Autocharge_for_OSP_Res
    ( p_resource_id     IN  NUMBER
    , p_organization_id IN  NUMBER
    , x_return_status   IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR l_res_osp_csr ( p_resource_id      NUMBER
                            , p_organization_id  NUMBER
                             )
       IS
          SELECT 'Not OSP Resource'
          FROM   SYS.DUAL
          WHERE  EXISTS    ( SELECT NULL
                             FROM   BOM_RESOURCES
                             WHERE  resource_id     =  p_resource_id
                             AND    organization_id =  p_organization_id
                             AND    cost_code_type  <> l_OSP -- 4 : Outside Processing
                            ) ;


    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_res_osp_rec IN l_res_osp_csr ( p_resource_id
                                          , p_organization_id
                                          )
       LOOP
           x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;


    END Val_Autocharge_for_OSP_Res ;


    -- Validate autocharge: PO Move
    PROCEDURE   Val_PO_Move
    ( p_op_seq_id     IN  NUMBER
    , p_res_seq_num   IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR l_pomove_csr   ( p_op_seq_id      NUMBER
                             , p_res_seq_num    NUMBER
                             )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES
                         WHERE  autocharge_type       = l_PO_MOVE
                         AND    resource_seq_num     <> p_res_seq_num
                         AND    operation_sequence_id = p_op_seq_id
                        ) ;


       CURSOR l_rev_pomove_csr   ( p_op_seq_id      NUMBER
                                 , p_res_seq_num    NUMBER
                                 )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES bor
                              , BOM_OPERATION_SEQUENCES bos
                         WHERE  bor.autocharge_type       = l_PO_MOVE
                         AND    bor.resource_seq_num     <> p_res_seq_num
                         AND    bor.operation_sequence_id = old_operation_sequence_id
                         AND    bos.acd_type              = l_ACD_CHANGE
                         AND    bos.operation_sequence_id = p_op_seq_id
                        ) ;



    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_pomove_rec IN l_pomove_csr ( p_op_seq_id
                                         , p_res_seq_num
                                         )
       LOOP
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;


       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN

           FOR l_rev_pomove_rec IN l_rev_pomove_csr ( p_op_seq_id
                                                    , p_res_seq_num
                                                     )
           LOOP
              x_return_status := FND_API.G_RET_STS_ERROR ;
           END LOOP ;

       END IF ;

    END Val_PO_Move ;


    -- Check if dept has location
    PROCEDURE   Val_Dept_Has_Location
    ( p_op_seq_id     IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR l_dept_loc_csr ( p_op_seq_id      NUMBER)
       IS
          SELECT 'No Dept Location'
          FROM   SYS.DUAL
          WHERE  NOT EXISTS( SELECT NULL
                             FROM   BOM_OPERATION_SEQUENCES bos
                                  , BOM_DEPARTMENTS         bd
                             WHERE  bd.location_id  IS NOT NULL
                             AND    bd.department_id          = bos.department_id
                             AND    bos.operation_sequence_id = p_op_seq_id
                             ) ;


    BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_dept_loc_rec IN l_dept_loc_csr ( p_op_seq_id )
       LOOP
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;


    END Val_Dept_Has_Location ;


    PROCEDURE  Get_Resource_Uom
    ( p_resource_id    IN  NUMBER
    , x_hour_uom_code  IN OUT NOCOPY VARCHAR2
    , x_hour_uom_class IN OUT NOCOPY VARCHAR2
    , x_res_uom_code   IN OUT NOCOPY VARCHAR2
    , x_res_uom_class  IN OUT NOCOPY VARCHAR2
    )
    IS

       CURSOR  l_class_csr(p_uom_code VARCHAR2)
       IS
          SELECT uom_class
          FROM   MTL_UNITS_OF_MEASURE
          WHERE  uom_code = p_uom_code ;


       CURSOR  l_uom_csr ( p_resource_id NUMBER )
       IS
           SELECT unit_of_measure
           FROM   BOM_RESOURCES
           WHERE  resource_id = p_resource_id ;

    BEGIN

       -- Get Hour UOM Code from Profile Opetion
       x_hour_uom_code := FND_PROFILE.VALUE('BOM:HOUR_UOM_CODE') ;

       -- Get Hour UOM Class
       FOR l_class_rec IN l_class_csr(p_uom_code => x_hour_uom_code)
       LOOP
           x_hour_uom_class := l_class_rec.uom_class ;
       END LOOP ;

       -- Get Resource UOM Code
       FOR l_uom_rec in l_uom_csr(p_resource_id)
       LOOP
          x_res_uom_code := l_uom_rec.unit_of_measure ;
       END LOOP ;

       -- Get Resource UOM Class
       FOR l_class_rec IN l_class_csr(p_uom_code => x_res_uom_code)
       LOOP
           x_res_uom_class := l_class_rec.uom_class ;
       END LOOP ;

    END Get_Resource_Uom ;



    PROCEDURE   Val_Res_UOM_For_Schedule
    ( p_hour_uom_class  IN  VARCHAR2
    , p_res_uom_class   IN  VARCHAR2
    , p_hour_uom_code   IN  VARCHAR2
    , p_res_uom_code    IN  VARCHAR2
    , x_return_status   IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR   l_conversion_csr ( p_res_uom_code   VARCHAR2
                                 , p_res_uom_class  VARCHAR2
                                 , p_hour_uom_code  VARCHAR2
                                 )
       IS
          SELECT 'Unable to convert'
          FROM   SYS.DUAL
          WHERE  NOT EXISTS(
                            SELECT NULL
                            FROM   MTL_UOM_CONVERSIONS muc1,
                                   MTL_UOM_CONVERSIONS muc2
                            WHERE  muc1.uom_code  = p_res_uom_code
                            AND    muc1.uom_class = p_res_uom_class
                            AND    muc1.inventory_item_id = 0
                            AND    NVL(muc1.disable_date, SYSDATE + 1) > SYSDATE
                            AND    muc2.uom_code = p_hour_uom_code
                            AND    muc2.inventory_item_id = 0
                            AND    muc2.uom_class = muc1.uom_class ) ;

    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;


       IF p_hour_uom_class <> p_res_uom_class THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
       ELSE
          FOR l_conversion_rec IN l_conversion_csr
                                 ( p_res_uom_code
                                 , p_res_uom_class
                                 , p_hour_uom_code )

          LOOP
             x_return_status := FND_API.G_RET_STS_ERROR ;
          END LOOP ;
       END IF ;

    END Val_Res_UOM_For_Schedule ;


    PROCEDURE  Val_Negative_Usage_Rate
    ( p_autocharge_type IN  NUMBER
    , p_schedule_flag   IN  NUMBER
    , p_hour_uom_class  IN  VARCHAR2
    , p_res_uom_class   IN  VARCHAR2
    , x_return_status   IN OUT NOCOPY VARCHAR2
    )
    IS

    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       IF (   p_autocharge_type IN (l_PO_RECEIPT, l_PO_MOVE)
          OR  p_schedule_flag   <> l_NO_SCHEDULE
          -- OR  p_hour_uom_class = p_res_uom_class -- Form allows this case
          )
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END IF ;

    END  Val_Negative_Usage_Rate ;

    PROCEDURE   Val_Principal_Res_Unique
    ( p_op_seq_id     IN  NUMBER
    , p_res_seq_num   IN  NUMBER
    , p_sub_group_num IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS
       CURSOR l_principal_csr   ( p_op_seq_id      NUMBER
                               , p_res_seq_num    NUMBER
                               , p_sub_group_num  NUMBER
                               )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES
                         WHERE  principle_flag        = 1 -- Yes
                         AND    NVL(acd_type, l_ACD_ADD) <> l_ACD_DISABLE
                         AND    nvl(substitute_group_num, resource_seq_num) = nvl(p_sub_group_num, p_res_seq_num)
                         AND    resource_seq_num      <> p_res_seq_num
                         AND    operation_sequence_id = p_op_seq_id
                        ) ;

       CURSOR l_rev_principal_csr   ( p_op_seq_id      NUMBER
                                   , p_res_seq_num    NUMBER
                                   , p_sub_group_num  NUMBER
                                   )
       IS
          SELECT 'Already exists'
          FROM   SYS.DUAL
          WHERE  EXISTS( SELECT NULL
                         FROM   BOM_OPERATION_RESOURCES  bor
                              , BOM_OPERATION_SEQUENCES  bos
                         WHERE  bor.principle_flag        = 1 -- Yes
                         AND    bor.substitute_group_num  = p_sub_group_num
                         AND    bor.resource_seq_num      <> p_res_seq_num
                         AND    bor.operation_sequence_id = bos.old_operation_sequence_id
                         AND    bos.acd_type              = l_ACD_CHANGE
                         AND    bos.operation_sequence_id = p_op_seq_id
                        ) ;



    BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       FOR l_principal_rec IN l_principal_csr ( p_op_seq_id
                                            , p_res_seq_num
                                            , p_sub_group_num
                                            )
       LOOP
          x_return_status := FND_API.G_RET_STS_ERROR ;
       END LOOP ;


       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN

           FOR l_rev_principal_rec IN l_rev_principal_csr ( p_op_seq_id
                                                        , p_res_seq_num
                                                        , p_sub_group_num
                                                         )
           LOOP
              x_return_status := FND_API.G_RET_STS_ERROR ;
           END LOOP ;
       END IF ;
    END Val_Principal_Res_Unique ;


    -- Simultaneous resources should have the same SGN to share the same alternates
    -- i.e for one SSN, there can be only one SGN associated
 /* Fix for bug 4506885 - Added parameter p_sub_grp_num to Val_Schedule_Seq_Num procedure.  */
    PROCEDURE Val_Schedule_Seq_Num
    ( p_op_seq_id     IN NUMBER
    , p_res_seq_num   IN  NUMBER
    , p_sch_seq_num   IN  NUMBER
    , p_sub_grp_num   IN  NUMBER
    , x_return_status IN OUT NOCOPY VARCHAR2
    )
    IS
     /* Fix for bug 4506885 - Modified the cursor c_same_sign to check for substitute_group_num <> p_sub_grp_num.
	Previously it was checking for substitute_group_num is not null. */
      cursor c_same_sgn is
        select 1 from dual
        where exists (select 1 --schedule_seq_num, count(distinct(substitute_group_num)) sgn_count
                  from bom_operation_resources
                  where operation_sequence_id = p_op_seq_id
                  and schedule_seq_num = p_sch_seq_num
                  and substitute_group_num <> p_sub_grp_num /* is not null*/
                  and resource_seq_num <> p_res_seq_num);
    BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       FOR c1 in c_same_sgn LOOP
         x_return_status := Error_Handler.G_STATUS_ERROR;
       END LOOP;

    END Val_Schedule_Seq_Num;


    PROCEDURE Val_Sgn_Order
    ( p_op_seq_id              IN NUMBER
    , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    , x_return_status          IN OUT NOCOPY VARCHAR2
    )
    IS
      Cursor Check1 is
        select substitute_group_num,
               min(schedule_seq_num) mn_ssn1, min(resource_seq_num) mn_rsn1,
               max(schedule_seq_num) mx_ssn1, max(resource_seq_num) mx_rsn1
        from bom_operation_resources
        where operation_sequence_id = p_op_seq_id
        and substitute_group_num is not null
        group by substitute_group_num
        order by substitute_group_num;

      Cursor Check2 (l_sgn number) is
        select substitute_group_num,
               min(schedule_seq_num) mn_ssn2, --min(resource_seq_num) mn_rsn2,
               max(schedule_seq_num) mx_ssn2 --max(resource_seq_num) mx_rsn2
        from bom_sub_operation_resources
        where operation_sequence_id = p_op_seq_id
        and substitute_group_num = l_sgn
        group by substitute_group_num
        order by substitute_group_num;

        first_row_outer boolean;
        first_row_inner boolean;
        temp_outer number;
        temp_inner number;
        init Check2%rowtype;

    BEGIN
     first_row_outer := false;
     first_row_inner := false;
     temp_outer := 0;
     temp_inner := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     FOR i IN Check1 LOOP
        IF first_row_outer = TRUE THEN
          IF nvl(i.mn_ssn1, i.mn_rsn1) > temp_outer
          AND nvl(i.mn_ssn1, i.mn_rsn1) > temp_inner THEN
            FOR j IN Check2(i.substitute_group_num) LOOP
                IF j.mn_ssn2 <= temp_inner
                OR j.mn_ssn2 <= temp_outer THEN
                  Error_Handler.Add_Error_Token
                   ( p_Message_Name   => 'BOM_LARGE_SGN_SSN'
                   , p_mesg_token_tbl => x_mesg_token_tbl
                   , x_mesg_token_tbl => x_mesg_token_tbl
                   --, p_Token_Tbl      => l_token_tbl
                   ) ;
                  x_return_status := Error_Handler.G_STATUS_ERROR;
                  return;
                END IF; --nvl(j)
                temp_inner := nvl(j.mx_ssn2, 0);
             END LOOP;
          ELSE
             Error_Handler.Add_Error_Token
              ( p_Message_Name   => 'BOM_LARGE_SGN_SSN'
              , p_mesg_token_tbl => x_mesg_token_tbl
              , x_mesg_token_tbl => x_mesg_token_tbl
              --, p_Token_Tbl      => l_token_tbl
              ) ;
              x_return_status := Error_Handler.G_STATUS_ERROR;
              return;
          END IF; --nvl(i)
          temp_outer := nvl(i.mx_ssn1, i.mx_rsn1);
        ELSE
          temp_outer := nvl(i.mx_ssn1, i.mx_rsn1);
          first_row_outer := TRUE;
          OPEN Check2(i.substitute_group_num);
          FETCH Check2 INTO init;
          temp_inner := nvl(init.mx_ssn2, 0);
          CLOSE Check2;
        END IF;
     END LOOP;
   END Val_Sgn_Order;

    /******************************************************************
    * Procedure     : Check_Existence used by RTG BO
    * Parameters IN : Operation Resource exposed column record
    *                 Operation Resource unexposed column record
    * Parameters out: Old Operation Resource exposed column record
    *                 Old Operation Resource unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Convert Routing Op Resource to Revised Op Resource and
    *                 Call Check_Existence for ECO Bo.
    *                 After calling Check_Existence, convert old Revised
    *                 Op Resource record back to Routing Op Resource
    *********************************************************************/
    PROCEDURE Check_Existence
    (  p_op_resource_rec        IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec       IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_old_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_old_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    )

   IS
        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
        l_old_rev_op_resource_rec  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_old_rev_op_res_unexp_rec Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to ECO Operation
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        ) ;

        -- Call Check_Existence
        Bom_Validate_Op_Res.Check_Existence
        (  p_rev_op_resource_rec      => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
         , x_old_rev_op_resource_rec  => l_old_rev_op_resource_rec
         , x_old_rev_op_res_unexp_rec => l_old_rev_op_res_unexp_rec
         , x_return_status            => x_return_status
         , x_mesg_token_tbl           => x_mesg_token_tbl
        ) ;

        -- Convert old Eco Opeartion Record back to Routing Operation
        Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
        (  p_rev_op_resource_rec      => l_old_rev_op_resource_rec
         , p_rev_op_res_unexp_rec     => l_old_rev_op_res_unexp_rec
         , x_rtg_op_resource_rec      => x_old_op_resource_rec
         , x_rtg_op_res_unexp_rec     => x_old_op_res_unexp_rec
         ) ;


    END Check_Existence ;


    /******************************************************************
    * Procedure     : Check_Existence used by ECO BO
    *                                   and internally called by RTG BO
    * Parameters IN : Revised operation resource exposed column record
    *                 Revised operation resource unexposed column record
    * Parameters out: Old Revised operation resource exposed column record
    *                 Old Revised operation resource unexposed column record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose       : Check_Existence will query using the primary key
    *                 information and return a success if the operation
    *                 resource is CREATE and the record EXISTS or will
    *                 return an error if the operation resource is UPDATE
    *                 and record DOES NOT EXIST.
    *                 In case of UPDATE if record exists, then the procedure
    *                 will return old record in the old entity parameters
    *                 with a success status.
    *********************************************************************/

    PROCEDURE Check_Existence
    (  p_rev_op_resource_rec        IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec       IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_old_rev_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_old_rev_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status              IN OUT NOCOPY VARCHAR2
    )
    IS
       l_Token_Tbl      Error_Handler.Token_Tbl_Type;
       l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
       l_return_status  VARCHAR2(1);

    BEGIN

       l_Token_Tbl(1).Token_Name  := 'RES_SEQ_NUMBER';
       l_Token_Tbl(1).Token_Value := p_rev_op_resource_rec.resource_sequence_number ;
       l_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
       l_Token_Tbl(2).Token_Value := p_rev_op_resource_rec.revised_item_name;

       Bom_Op_Res_Util.Query_Row
       ( p_resource_sequence_number  =>  p_rev_op_resource_rec.resource_sequence_number
       , p_operation_sequence_id     =>  p_rev_op_res_unexp_rec.operation_sequence_id
       , p_acd_type                  =>  p_rev_op_resource_rec.acd_type
       , p_mesg_token_tbl            =>  l_mesg_token_tbl
       , x_rev_op_resource_rec       =>  x_old_rev_op_resource_rec
       , x_rev_op_res_unexp_rec      =>  x_old_rev_op_res_unexp_rec
       , x_mesg_token_tbl            =>  l_mesg_token_tbl
       , x_return_status             =>  l_return_status
       ) ;

            IF l_return_status = BOM_Rtg_Globals.G_RECORD_FOUND AND
               p_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE  THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'BOM_RES_ALREADY_EXISTS'
                     , p_token_tbl      => l_token_tbl
                     ) ;
                    l_return_status := FND_API.G_RET_STS_ERROR ;

            ELSIF l_return_status = BOM_Rtg_Globals.G_RECORD_NOT_FOUND AND
               p_rev_op_resource_rec.transaction_type IN
                    ( BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
            THEN
                    Error_Handler.Add_Error_Token
                    (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_message_name   => 'BOM_RES_DOESNOT_EXIST'
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
                                               || 'Operation Resources '
                                               || p_rev_op_resource_rec.resource_sequence_number
                     , p_token_tbl          => l_token_tbl
                     ) ;
            ELSE
                    l_return_status := FND_API.G_RET_STS_SUCCESS;
            END IF ;

            x_return_status  := l_return_status;
            x_mesg_token_tbl := l_Mesg_Token_Tbl;

    END Check_Existence;


    /******************************************************************
    * Procedure     : Check_NonRefEvent used by RTG BO and ECO BO
    * Parameters IN : Operation Sequence Id, Resource Seq Num, Op Seq Num
    *                 Operation Type
    * Parameters out: Error  Code
    *                 Return Status
    * Purpose       : Convert Routing Op Resource to Revised Op Resource and
    *                 Call Check_Existence for ECO Bo.
    *                 After calling Check_Existence, convert old Revised
    *                 Op Resource record back to Routing Op Resource
    *********************************************************************/

   PROCEDURE Check_NonRefEvent
   (   p_operation_sequence_id      IN  NUMBER
    ,  p_operation_type             IN  NUMBER
    ,  p_entity_processed           IN  VARCHAR2
    ,  x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
    ,  x_return_status              IN OUT NOCOPY VARCHAR2
    )
   IS


       l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
       l_return_status  VARCHAR2(1);
       l_err_text       VARCHAR2(2000) ;

       -- Get ref flag and operation type
       CURSOR l_event_cur (p_op_seq_id NUMBER)
       IS
          SELECT  reference_flag
          FROM    BOM_OPERATION_SEQUENCES
          WHERE   operation_sequence_id = p_op_seq_id ;

       l_event_rec l_event_cur%ROWTYPE ;

   PRT_OP_NOT_EVENT EXCEPTION ;
   EAM_SUB_RES_NOT_ACCESS EXCEPTION ;  -- Added for eAM enhancement

   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      -- For eAM enhancement, currently maintenance routings do not
      -- support sub operation resources fanctionality.
      -- This validation will be removed in future.
      IF BOM_Rtg_Globals.Get_Eam_Item_Type = BOM_Rtg_Globals.G_ASSET_ACTIVITY
      AND  p_entity_processed = 'SR' -- called from sub resources entity
      THEN

           RAISE EAM_SUB_RES_NOT_ACCESS ;

      END IF ; --  end of eAM enhancement


      IF NVL(p_operation_type, 1) <> l_EVENT
         AND p_operation_type <> FND_API.G_MISS_NUM
      THEN
         RAISE PRT_OP_NOT_EVENT ;
      END IF ;

      OPEN l_event_cur( p_op_seq_id => p_operation_sequence_id) ;
      FETCH l_event_cur INTO l_event_rec ;

      IF l_event_cur%FOUND THEN
         IF l_event_rec.reference_flag = 1
         THEN
            l_return_status := FND_API.G_RET_STS_ERROR ;
         END IF ;
      ELSE
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      END IF ;

      CLOSE l_event_cur ;

      x_return_status  := l_return_status ;
      x_mesg_token_tbl := l_mesg_token_tbl ;

   EXCEPTION
       -- Added for eAM enhancement
       WHEN EAM_SUB_RES_NOT_ACCESS THEN

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Maintenance routings do not support sub operation resources fanctionality') ;
          END IF ;

           -- Return the 'EAM'.
           x_return_status := 'EAM' ;


       WHEN PRT_OP_NOT_EVENT THEN
           -- Return the status and message table.
           x_return_status := FND_API.G_RET_STS_ERROR ;


       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Check non-ref operation . . .' || SQLERRM );
          END IF ;


          l_err_text := G_PKG_NAME || ' Validation (Check Non-Ref Op of Event) '
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

    END Check_NonRefEvent ;


    /********************************************************************
    * Procedure : Check_Attributes used by RTG BO
    * Parameters IN : Operation Resource exposed column record
    *                 Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Operation Resource to ECO Operation
    *             Resource and Call Check_Attributes for ECO BO.
    *             Check_Attributes will verify the exposed attributes
    *             of the operation resource record in their own entirety.
    *             No cross entity validations will be performed.
    ********************************************************************/
    PROCEDURE Check_Attributes
    (  p_op_resource_rec    IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec   IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status      IN OUT NOCOPY VARCHAR2
    )
    IS

       l_rev_op_resource_rec    Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
       l_rev_op_res_unexp_rec   Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    BEGIN

       -- Convert Routing Operation to ECO Operation
       Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        ) ;

       -- Call Check Attributes procedure
       Bom_Validate_Op_Res.Check_Attributes
        (  p_rev_op_resource_rec  => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec => l_rev_op_res_unexp_rec
         , x_return_status        => x_return_status
         , x_mesg_token_tbl       => x_mesg_token_tbl
        ) ;

    END Check_Attributes ;


    /***************************************************************
    * Procedure : Check_Attribute (Validation) for CREATE and UPDATE
    *             by ECO BO  and internally called by RTG BO
    * Parameters IN : Revised Operation Resource exposed column record
    *                 Revised Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   : Attribute validation procedure will validate each
    *             attribute of Revised operation resource in its entirety.
    *             If the validation of a column requires looking at some
    *             other columns value then the validation is done at
    *             the Entity level instead.
    *             All errors in the attribute validation are accumulated
    *             before the procedure returns with a Return_Status
    *             of 'E'.
    *********************************************************************/
    PROCEDURE Check_Attributes
    (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status         IN OUT NOCOPY VARCHAR2
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
        l_Token_Tbl(1).token_name  := 'RES_SEQ_NUMBER';
        l_Token_Tbl(1).token_value := p_rev_op_resource_rec.resource_sequence_number ;

        --
        -- Check if the user is trying to update a record with
        -- missing value when the column value is required.
        --

        IF p_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
        THEN

        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Operation Resource Attr Validation: Missing Value. . . ' || l_return_status) ;
        END IF;

            -- Resource Code
            IF p_rev_op_resource_rec.resource_code = FND_API.G_MISS_CHAR
            THEN
            Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_RESCODE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Standard Rate Flag
            IF p_rev_op_resource_rec.standard_rate_flag = FND_API.G_MISS_NUM
            THEN
            Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_STD_RATE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Assigned Units
            IF p_rev_op_resource_rec.assigned_units = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_ASSIGNED_UNITS_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Usage Rate or Amount
            IF p_rev_op_resource_rec.usage_rate_or_amount = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_RATE_AMT_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Usage Rate or Amount Inverse
            IF p_rev_op_resource_rec.usage_rate_or_amount_inverse = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_RATE_AMT_INVRS_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Basis Type
            IF p_rev_op_resource_rec.basis_type = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_BASISTYPE_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Schedule Flag
            IF p_rev_op_resource_rec.schedule_flag = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_SCHEDULEFLAG_MISSING'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Autocharge Type
            IF p_rev_op_resource_rec.autocharge_type = FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_ACHARGE_TYPE_MISSING'
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
        ('Operation Resource Attr Validation: Invalid Value. . . ' || l_return_status) ;
        END IF;

            -- Resource Code or Resource Id
            IF p_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               AND NVL(p_rev_op_resource_rec.acd_type, l_ACD_ADD) = l_ACD_ADD
               AND ( p_rev_op_res_unexp_rec.resource_id IS NULL
                   OR  p_rev_op_res_unexp_rec.resource_id = FND_API.G_MISS_NUM)
            THEN

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_RESCODE_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Standard Rate Flag
            IF p_rev_op_resource_rec.standard_rate_flag IS NOT NULL AND
               p_rev_op_resource_rec.standard_rate_flag NOT IN (1,2)
            AND p_rev_op_resource_rec.standard_rate_flag  <> FND_API.G_MISS_NUM
            THEN
            Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_STD_RATE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Principle Flag
            IF p_rev_op_resource_rec.principle_flag IS NOT NULL AND
               p_rev_op_resource_rec.principle_flag NOT IN (1,2)
            AND  p_rev_op_resource_rec.principle_flag <> FND_API.G_MISS_NUM
            THEN
            Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_PCLFLAG_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- Resource Offset Percent
            IF  p_rev_op_resource_rec.resource_offset_percent IS NOT NULL AND
                (p_rev_op_resource_rec.resource_offset_percent < 0
                 OR  p_rev_op_resource_rec.resource_offset_percent > 100 )
            AND p_rev_op_resource_rec.resource_offset_percent <> FND_API.G_MISS_NUM
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
               Error_Handler.Add_Error_Token
               ( p_Message_Name   => 'BOM_RES_OFFSET_PCT_INVALID'
               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
               , p_Token_Tbl      => l_Token_Tbl
               ) ;
               END IF ;
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Assigned Units
            IF p_rev_op_resource_rec.assigned_units IS NOT NULL AND
               p_rev_op_resource_rec.assigned_units  <= 0.00001
            AND p_rev_op_resource_rec.assigned_units <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_ASSIGNED_UNITS_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Basis Type
            IF p_rev_op_resource_rec.basis_type IS NOT NULL AND
               p_rev_op_resource_rec.basis_type NOT IN (1,2)
            AND p_rev_op_resource_rec.basis_type  <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_BASISTYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


            -- Schedule Flag
            IF p_rev_op_resource_rec.schedule_flag IS NOT NULL AND
               p_rev_op_resource_rec.schedule_flag NOT IN (1,2,3,4)
            AND p_rev_op_resource_rec.schedule_flag <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_SCHEDULEFLAG_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- Autocharge Type
            IF p_rev_op_resource_rec.autocharge_type IS NOT NULL AND
               p_rev_op_resource_rec.autocharge_type NOT IN (1,2,3,4)
            AND  p_rev_op_resource_rec.autocharge_type <> FND_API.G_MISS_NUM
            THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_ACHARGE_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                 );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF ;


            -- ACD Type
            IF( ( p_rev_op_resource_rec.acd_type IS NOT NULL
                 AND p_rev_op_resource_rec.acd_type NOT IN
                        (l_ACD_ADD, l_ACD_CHANGE, l_ACD_DISABLE) )
               OR p_rev_op_resource_rec.acd_type IS NULL
               )
               AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
            THEN

               l_token_tbl(2).token_name  := 'ACD_TYPE';

               IF p_rev_op_resource_rec.acd_type <> FND_API.G_MISS_NUM
               THEN
                  l_token_tbl(2).token_value := p_rev_op_resource_rec.acd_type;
               ELSE
                  l_token_tbl(2).token_value := '' ;
               END IF ;

               Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RES_ACD_TYPE_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl
                );
               l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF ;



       --  Done validating attributes
        IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Operation Resource Attr Validation completed with return_status: ' || l_return_status) ;
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
    * Parameters IN : Operation Resource exposed column record
    *                 Operation Resource unexposed column record
    *                 Old Operation Resource exposed column record
    *                 Old Operation Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Convert Routing Op Resource to ECO Op Resource and
    *                 Call Check_Entity for ECO BO.
    *                 Procedure will execute the business logic and will
    *                 also perform any required cross entity validations
    *******************************************************************/
    PROCEDURE Check_Entity
    (  p_op_resource_rec      IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec     IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , p_old_op_resource_rec  IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_old_op_res_unexp_rec IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_op_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_op_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    )
    IS
        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
        l_old_rev_op_resource_rec  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_old_rev_op_res_unexp_rec Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    BEGIN
        -- Convert Routing Operation to ECO Operation
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        ) ;


        -- Also Convert Old Routing Operation to Old ECO Operation
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_old_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_old_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_old_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_old_rev_op_res_unexp_rec
        ) ;

        -- Call Check_Entity
        Bom_Validate_Op_Res.Check_Entity
       (  p_rev_op_resource_rec      => l_rev_op_resource_rec
        , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        , p_old_rev_op_resource_rec  => l_old_rev_op_resource_rec
        , p_old_rev_op_res_unexp_rec => l_old_rev_op_res_unexp_rec
        , p_control_rec              => Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
        , x_rev_op_resource_rec      => l_rev_op_resource_rec
        , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        , x_return_status            => x_return_status
        , x_mesg_token_tbl           => x_mesg_token_tbl
        ) ;


        -- Convert Eco Op Resource Record back to Routing Op Resource
        Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
        (  p_rev_op_resource_rec      => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
         , x_rtg_op_resource_rec      => x_op_resource_rec
         , x_rtg_op_res_unexp_rec     => x_op_res_unexp_rec
         ) ;


    END Check_Entity ;


    /*******************************************************************
    * Procedure : Check_Entity used by RTG BO and internally called by RTG BO
    * Parameters IN : Revised Op Resource exposed column record
    *                 Revised Op Resource unexposed column record
    *                 Old Revised Op Resource exposed column record
    *                 Old Revised Op Resource unexposed column record
    * Parameters out: Return Status
    *                 Message Token Table
    * Purpose   :     Check_Entity validate the entity for the correct
    *                 business logic. It will verify the values by running
    *                 checks on inter-dependent columns.
    *                 It will also verify that changes in one column value
    *                 does not invalidate some other columns.
    *******************************************************************/
    PROCEDURE Check_Entity
    (  p_rev_op_resource_rec      IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_old_rev_op_resource_rec  IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_old_rev_op_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_control_rec              IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_op_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    )
    IS

    -- Variables
    l_eco_processed     BOOLEAN ;      -- Indicate ECO has been processed
    l_hour_uom_code     VARCHAR2(3) ;  -- Hour UOM Code
    l_hour_uom_class    VARCHAR2(10) ; -- Hour UOM Class
    l_res_uom_code      VARCHAR2(3) ;  -- Resource UOM Code
    l_res_uom_class     VARCHAR2(10) ; -- Resource UOM Class
    l_temp_status       VARCHAR2(1)  ; -- Temp Error Status
    l_res_code          BOM_RESOURCES_V.RESOURCE_CODE%TYPE;

    l_rev_op_resource_rec        Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
    l_rev_op_res_unexp_rec       Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_token_tbl       Error_Handler.Token_Tbl_Type;

    l_get_setups        NUMBER;			            --APS Enhancement for Routings
    l_batchable         NUMBER;                             --APS Enhancement for Routings
    /* Added below two variables for fixing bug 6074930*/
    l_res_code_2      VARCHAR2(10);
    l_res_id          NUMBER;

    CURSOR   get_setups (  p_resource_id NUMBER             --APS Enhancement for Routings
                         , p_org_id NUMBER
			 )
    IS
	SELECT count(setup_id)
	FROM bom_resource_setups
	WHERE resource_id = p_resource_id
	AND organization_id = p_org_id;


    -- Check Rev Op Resource exists
    CURSOR  l_opres_exist_csr (   p_res_seq_num    NUMBER
                                , p_op_seq_id      NUMBER
                              )
    IS
       SELECT 'Rev Op Resource Not Exists'
       FROM   DUAL
       WHERE NOT EXISTS (SELECT NULL
                         FROM  BOM_OPERATION_SEQUENCES bos
                             , BOM_OPERATION_RESOURCES bor
                         WHERE bor.resource_seq_num      = p_res_seq_num
                         AND   bor.operation_sequence_id = bos.old_operation_sequence_id
                         AND   bos.operation_sequence_id = p_op_seq_id
                         ) ;

    -- Check if there is an associated sub resource
    CURSOR l_subres_exist_csr ( p_op_seq_id      IN NUMBER
                              , p_sub_group_num  IN NUMBER
                              , p_res_seq_num    IN NUMBER)
    IS
       SELECT 'Sub Res Exists'
       FROM   SYS.DUAL
       WHERE  EXISTS ( SELECT   NULL
                       FROM     BOM_SUB_OPERATION_RESOURCES
                       WHERE    operation_sequence_id = p_op_seq_id
                       AND      substitute_group_num   = p_sub_group_num )
       AND    NOT EXISTS ( SELECT NULL
                          FROM   BOM_OPERATION_RESOURCES
                          WHERE  substitute_group_num   = p_sub_group_num
                          AND    resource_seq_num       <> p_res_seq_num
                          AND    operation_sequence_id  = p_op_seq_id ) ;


    CURSOR l_rev_subres_exist_csr ( p_op_seq_id      IN NUMBER
                                  , p_sub_group_num  IN NUMBER
                                  , p_res_seq_num    IN NUMBER)
    IS
       SELECT 'Sub Res Exists'
       FROM   SYS.DUAL
       WHERE  EXISTS ( SELECT   NULL
                       FROM     BOM_SUB_OPERATION_RESOURCES bsor
                             ,  BOM_OPERATION_SEQUENCES     bos
                       WHERE    bsor.substitute_group_num   = p_sub_group_num
                       AND      bsor.operation_sequence_id  = bos.old_operation_sequence_id
                       AND      bos.operation_sequence_id   = p_op_seq_id )
       AND    NOT EXISTS (SELECT NULL
                          FROM     BOM_OPERATION_RESOURCES     bor
                                ,  BOM_OPERATION_SEQUENCES     bos
                          WHERE    bor.substitute_group_num   = p_sub_group_num
                          AND      resource_seq_num           <>  p_res_seq_num
                          AND      bor.operation_sequence_id  = bos.old_operation_sequence_id
                          AND      bos.operation_sequence_id  = p_op_seq_id ) ;


    -- Check if there is an associated Sub PO Move Resource
    -- on this resource
    CURSOR l_subres_pomove_csr ( p_op_seq_id      IN NUMBER
                              ,  p_sub_group_num  IN NUMBER )
    IS
       SELECT 'Sub PO Move Exists'
       FROM   SYS.DUAL
       WHERE  EXISTS ( SELECT   NULL
                       FROM     BOM_SUB_OPERATION_RESOURCES
                       WHERE    autocharge_type        = l_PO_MOVE
                       AND      substitute_group_num   = p_sub_group_num
                       AND      operation_sequence_id = p_op_seq_id ) ;

    CURSOR l_rev_subres_pomove_csr ( p_op_seq_id      IN NUMBER
                                  ,  p_sub_group_num  IN NUMBER )
    IS
       SELECT 'Sub PO Move Exists'
       FROM   SYS.DUAL
       WHERE  EXISTS ( SELECT   NULL
                       FROM     BOM_SUB_OPERATION_RESOURCES bsor
                             ,  BOM_OPERATION_SEQUENCES     bos
                       WHERE    autocharge_type        = l_PO_MOVE
                       AND      bsor.substitute_group_num   = p_sub_group_num
                       AND      bsor.operation_sequence_id  = bos.old_operation_sequence_id
                       AND      bos.operation_sequence_id   = p_op_seq_id ) ;


    -- Check if there is an associated Sub Next or Prior resource
    -- on this resource
    CURSOR l_subres_schedule_csr ( p_op_seq_id      IN NUMBER
                                ,  p_sub_group_num  IN NUMBER
                                ,  p_schedule_flag  IN NUMBER )
    IS
       SELECT 'Sub PO Move Exists'
       FROM   SYS.DUAL
       WHERE  EXISTS ( SELECT   NULL
                       FROM     BOM_SUB_OPERATION_RESOURCES
                       WHERE    schedule_flag          = p_schedule_flag
                       AND      substitute_group_num   = p_sub_group_num
                       AND      operation_sequence_id  = p_op_seq_id ) ;


    CURSOR l_rev_subres_schedule_csr ( p_op_seq_id      IN NUMBER
                                    ,  p_sub_group_num  IN NUMBER
                                    ,  p_schedule_flag  IN NUMBER )
    IS
       SELECT 'Sub PO Move Exists'
       FROM   SYS.DUAL
       WHERE  EXISTS ( SELECT   NULL
                       FROM     BOM_SUB_OPERATION_RESOURCES bsor
                             ,  BOM_OPERATION_SEQUENCES     bos
                       WHERE    bsor.schedule_flag          = p_schedule_flag
                       AND      bsor.substitute_group_num   = p_sub_group_num
                       AND      bsor.operation_sequence_id  = bos.old_operation_sequence_id
                       AND      bos.operation_sequence_id   = p_op_seq_id ) ;



    BEGIN
       --
       -- Initialize Common Record and Status
       --

       l_rev_op_resource_rec    := p_rev_op_resource_rec ;
       l_rev_op_res_unexp_rec   := p_rev_op_res_unexp_rec ;
       l_return_status          := FND_API.G_RET_STS_SUCCESS ;
       x_return_status          := FND_API.G_RET_STS_SUCCESS ;

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Performing Op Resource Check Entity Validation . . .') ;
       END IF ;

       --
       -- Set the 1st token of Token Table to Revised Operation value
       --
       l_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
       l_token_tbl(1).token_value := l_rev_op_resource_rec.resource_sequence_number ;


       -- The ECO can be updated but a warning needs to be generated and
       -- scheduled revised items need to be update to Open
       -- and the ECO status need to be changed to Not Submitted for Approval

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Check if ECO has been approved and has a workflow process. . . ' || l_return_status) ;
       END IF ;

       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN
          BOM_Rtg_Globals.Check_Approved_For_Process
          ( p_change_notice    => l_rev_op_resource_rec.eco_name
          , p_organization_id  => l_rev_op_res_unexp_rec.organization_id
          , x_processed        => l_eco_processed
          , x_err_text         => l_err_text
          ) ;

          IF l_eco_processed THEN
           -- If the above process returns true then set the ECO approval.
                BOM_Rtg_Globals.Set_Request_For_Approval
                ( p_change_notice    => l_rev_op_resource_rec.eco_name
                , p_organization_id  => l_rev_op_res_unexp_rec.organization_id
                , x_err_text         => l_err_text
                ) ;

          END IF ;
       END IF;


       --
       -- Performing Entity Validation in Revised Op Resource(ECO BO)
       --
       IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
       THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Performing Entitity Validation for Eco Routing :ACD Type. . .') ;
          END IF ;

          --
          -- ACD Type
          -- If the Transaction Type is CREATE and the ACD_Type = Disable, then
          -- the operation resource should already exist for the revised operation.
          --
          /* This validation has been done in Rev_Operation_Resource procedure
          IF l_rev_op_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
            AND ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD ) IN (l_ACD_CHANGE, l_ACD_DISABLE ))
          THEN

             FOR l_opres_exist_rec IN l_opres_exist_csr
                                      (  p_res_seq_num => l_rev_op_resource_rec.resource_sequence_number
                                       , p_op_seq_id   => l_rev_op_res_unexp_rec.operation_sequence_id
                                       )
             LOOP
                l_token_tbl(2).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(2).token_value := l_rev_op_resource_rec.operation_sequence_number ;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_RES_DISABLE_RES_NOT_FOUND'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                ) ;

                l_return_status := FND_API.G_RET_STS_ERROR ;
             END LOOP ;
          END IF ;
          */



          --
          -- ACD Type,
          -- If the Transaction Type is CREATE and the ACD_Type of parent revised
          -- operation is Add then,the ACD_Type must be Add.
          --
          --
          IF l_rev_op_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
          THEN
             IF
               l_ACD_ADD =
               Get_Rev_Op_ACD(p_op_seq_id
                              => l_rev_op_res_unexp_rec.operation_sequence_id)
              AND  NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD ) <> l_ACD_ADD
             THEN
                l_token_tbl(2).token_name  := 'OP_SEQ_NUMBER';
                l_token_tbl(2).token_value := l_rev_op_resource_rec.operation_sequence_number ;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_RES_ACD_NOT_COMPATIBLE'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                ) ;

                l_return_status := FND_API.G_RET_STS_ERROR ;
              END IF ;
           END IF ;



          --
          -- For CREATE, ACD Type is CHANGE, Operation Resource's
          -- Attribute can not be update.
          --
          /* User is allowed to update res attributes
          IF  l_rev_op_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
              AND l_rev_op_resource_rec.acd_type = l_ACD_CHANGE
          THEN
             IF NOT Check_Res_Attr_changed
                    (  p_rev_op_resource_rec       => l_rev_op_resource_rec
                    ,  p_rev_op_res_unexp_rec      => l_rev_op_res_unexp_rec
                    ,  p_old_rev_op_resource_rec   => p_old_rev_op_resource_rec
                    ,  p_old_rev_op_res_unexp_rec  => p_old_rev_op_res_unexp_rec )
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    Error_Handler.Add_Error_Token
                    ( p_message_name    => 'BOM_RES_NOT_UPDATE_IN_CHANGE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_token_tbl      => l_token_tbl
                    ) ;
                 END IF ;
                 l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;
          END IF ;
          */

          --
          -- For UPDATE, ACD Type not updateable
          --
          IF  l_rev_op_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_UPDATE
              AND l_rev_op_resource_rec.acd_type <> p_old_rev_op_resource_rec.acd_type
          THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                ( p_message_name   => 'BOM_RES_ACD_TYPENOT_UPDATEABLE'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_token_tbl      => l_token_tbl
                ) ;
             END IF ;
             l_return_status := FND_API.G_RET_STS_ERROR ;
          END IF ;

/*	  Moved the validation out of the If block as part of UT for R12.
	  --
	  -- APS Enhancement for Routings.
	  -- Verify that if a resource has setups defined, or is Batchable then
	  -- the Assigned Units for that Resource have to be 1.
	  --
	  OPEN get_setups (p_rev_op_res_unexp_rec.resource_id, p_rev_op_res_unexp_rec.organization_id);
	  FETCH get_setups INTO l_get_setups;
	  CLOSE get_setups;
	  SELECT nvl(batchable,2) INTO l_batchable
	  FROM bom_resources
	  WHERE resource_id = p_rev_op_res_unexp_rec.resource_id;
	    IF (l_get_setups IS NOT NULL or l_batchable = 1) THEN
	    	IF p_rev_op_resource_rec.assigned_units <> 1 THEN
		Error_Handler.Add_Error_Token
		(  p_Message_Name       => 'BOM_RES_ASSIGNED_UNIT_INCORRECT'
		 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
		 , p_Token_Tbl          => l_Token_Tbl
		);
	        END IF;
            END IF;
*/

          --
          -- Verify the ECO by WO Effectivity, If ECO by WO, Lot Num, Or Cum Qty, then
          -- Check if the operation resource exist in the WO or Lot Num.
          --
          IF   p_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
          AND  l_rev_op_resource_rec.acd_type  IN (l_ACD_CHANGE, l_ACD_DISABLE )
          THEN

             IF NOT Check_ECO_By_WO_Effectivity
                    ( p_revised_item_sequence_id => p_rev_op_res_unexp_rec.revised_item_sequence_id
                    , p_operation_seq_num        => p_rev_op_resource_rec.operation_sequence_number
                    , p_resource_seq_num         => p_rev_op_resource_rec.resource_sequence_number
                    , p_organization_Id          => p_rev_op_res_unexp_rec.organization_id
                    , p_rev_item_id              => p_rev_op_res_unexp_rec.revised_item_id
                    )
             THEN
                l_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
                l_token_tbl(2).token_value := p_rev_op_resource_rec.revised_item_name;

                Error_Handler.Add_Error_Token
                (  p_message_name   => 'BOM_RES_RIT_ECO_WO_EFF_INVALID'
                 , p_mesg_token_tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_token_tbl      => l_token_tbl
                );
                l_return_status := FND_API.G_RET_STS_ERROR;

             END IF ;
          END IF ;


       END IF ; -- ECO BO Validation


	-- Modified validation for Assigned Units
	IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
	  Error_Handler.Write_Debug ('Validating the Assigned Units for a Batchable Resource . . .') ;
	END IF;

	IF l_rev_op_resource_rec.transaction_type IN
	(BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
	THEN
	--
	-- APS Enhancement for Routings.
	-- Verify that if a resource has setups defined, or is Batchable then
	-- the Assigned Units for that Resource have to be 1.
	--
	  IF p_rev_op_resource_rec.assigned_units <> FND_API.G_MISS_NUM THEN
		OPEN get_setups (p_rev_op_res_unexp_rec.resource_id, p_rev_op_res_unexp_rec.organization_id);
		FETCH get_setups INTO l_get_setups;
		CLOSE get_setups;
		SELECT nvl(batchable,2) INTO l_batchable
		FROM bom_resources
		WHERE resource_id = p_rev_op_res_unexp_rec.resource_id;
		IF (l_get_setups > 0 or l_batchable = 1) THEN
			IF p_rev_op_resource_rec.assigned_units <> 1 THEN
			    l_Token_Tbl(2).token_name  := 'RES_SEQ_NUMBER';
			    --l_Token_Tbl(2).token_value  := p_rev_op_resource_rec.Resource_Code;
			    l_Token_Tbl(2).token_value  := p_rev_op_resource_rec.Resource_Sequence_Number;
			    Error_Handler.Add_Error_Token
			    (  p_Message_Name       => 'BOM_RES_ASSIGNED_UNITS_WRONG'
			     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
			     , p_Token_Tbl          => l_Token_Tbl
			    );
			    l_return_status := FND_API.G_RET_STS_ERROR ;
			END IF;
		END IF;
	  END IF;
	END IF;
	-- Modified validation for Assigned Units

       --
       -- For UPDATE or ( For CREATE and acd type is change)
       -- Validation specific to the Transaction Type of Update
       --
       IF l_rev_op_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_UPDATE
          OR
          (l_rev_op_resource_rec.Transaction_Type = BOM_Rtg_Globals.G_OPR_CREATE
           AND  l_rev_op_resource_rec.acd_type    = l_ACD_CHANGE
           )
       THEN



          /****     This validation is not required ****
          --
          -- Scheduled Resource
          -- Check if there are associated sub Next or Prior resources on
          -- this resource
          --
          IF   (    l_rev_op_resource_rec.schedule_flag         <> l_NEXT
                   OR  ( l_rev_op_res_unexp_rec.substitute_group_number
                         <> p_old_rev_op_res_unexp_rec.substitute_group_number ))
               AND p_old_rev_op_resource_rec.schedule_flag =  l_NEXT
          THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if you can update Next or Prior Schedule Res to others. . . . ' || l_return_status) ;
END IF ;

             FOR l_subres_schedule_rec IN l_subres_schedule_csr
                 ( p_op_seq_id       => p_rev_op_res_unexp_rec.operation_sequence_id
                 , p_sub_group_num   => p_old_rev_op_res_unexp_rec.substitute_group_number
                 , p_schedule_flag   => l_NEXT )
             LOOP

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_NEXTPRIOR_NOT_UPDATE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END LOOP ;

             IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
             AND  l_rev_op_resource_rec.acd_type    = l_ACD_CHANGE
             THEN
                  FOR l_rev_subres_schedule_rec IN l_rev_subres_schedule_csr
                     ( p_op_seq_id       => p_rev_op_res_unexp_rec.operation_sequence_id
                     , p_sub_group_num   => p_old_rev_op_res_unexp_rec.substitute_group_number
                     , p_schedule_flag   => l_NEXT )
                  LOOP

                     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_RES_NEXTPRIOR_NOT_UPDATE'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                        ) ;
                     END IF ;

                     l_return_status := FND_API.G_RET_STS_ERROR ;

                  END LOOP ;
              END IF ;

          ELSIF (    l_rev_op_resource_rec.schedule_flag         <> l_PRIOR
                     OR    ( l_rev_op_res_unexp_rec.substitute_group_number
                             <> p_old_rev_op_res_unexp_rec.substitute_group_number ))
                 AND p_old_rev_op_resource_rec.schedule_flag     =  l_PRIOR
          THEN
             FOR l_subres_schedule_rec IN l_subres_schedule_csr
                 ( p_op_seq_id       => p_rev_op_res_unexp_rec.operation_sequence_id
                 , p_sub_group_num   => p_old_rev_op_res_unexp_rec.substitute_group_number
                 , p_schedule_flag   => l_PRIOR )
             LOOP

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_NEXTPRIOR_NOT_UPDATE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END LOOP ;

             IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
             AND  l_rev_op_resource_rec.acd_type    = l_ACD_CHANGE
             THEN
                  FOR l_rev_subres_schedule_rec IN l_rev_subres_schedule_csr
                     ( p_op_seq_id       => p_rev_op_res_unexp_rec.operation_sequence_id
                     , p_sub_group_num   => p_old_rev_op_res_unexp_rec.substitute_group_number
                     , p_schedule_flag   => l_PRIOR)
                  LOOP

                     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_RES_NEXTPRIOR_NOT_UPDATE'
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_Token_Tbl      => l_Token_Tbl
                        ) ;
                     END IF ;

                     l_return_status := FND_API.G_RET_STS_ERROR ;

                  END LOOP ;
              END IF ;

          END IF ;
          ****     This validation is not required  ****/


          /****     This validation is not required ****
          --
          -- Autocharge Type
          -- If you update Autocharge Type : PO Move to the orhters
          -- there must be no associated sub PO Move resource
          --
          IF  ( l_rev_op_resource_rec.autocharge_type      <> l_PO_MOVE
                OR  ( l_rev_op_res_unexp_rec.substitute_group_number
                           <> p_old_rev_op_res_unexp_rec.substitute_group_number ))
                AND  p_old_rev_op_resource_rec.autocharge_type  =  l_PO_MOVE
          THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if you can update PO Move to others. . . . ' || l_return_status) ;
END IF ;

             FOR l_subres_pomove_rec IN l_subres_pomove_csr
                 ( p_op_seq_id     => p_rev_op_res_unexp_rec.operation_sequence_id
                 , p_sub_group_num => p_old_rev_op_res_unexp_rec.substitute_group_number
                )
             LOOP

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_POMOVE_NOT_UPDATE'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END LOOP ;

             IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
             AND  l_rev_op_resource_rec.acd_type    = l_ACD_CHANGE
             THEN

                 FOR l_rev_subres_pomove_rec IN l_rev_subres_pomove_csr
                     ( p_op_seq_id     => p_rev_op_res_unexp_rec.operation_sequence_id
                     , p_sub_group_num => p_old_rev_op_res_unexp_rec.substitute_group_number
                    )
                 LOOP

                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       Error_Handler.Add_Error_Token
                       (  p_message_name   => 'BOM_RES_POMOVE_NOT_UPDATE'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                       ) ;
                    END IF ;
                    l_return_status := FND_API.G_RET_STS_ERROR ;
                 END LOOP ;
             END IF ;
          END IF ;
          ****     This validation is not required ****  */


          --
          -- Schedule Sequence Number and Sub Group Num
          -- Check if there are associated sub resources to OLD
          -- Substitute Group Number
          --
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if you can change Schedule Seq Num. . . . ' || l_return_status) ;
          END IF ;

          IF  ( nvl(l_rev_op_resource_rec.substitute_group_number, l_rev_op_res_unexp_rec.substitute_group_number)
                      <> nvl(p_old_rev_op_resource_rec.substitute_group_number, p_old_rev_op_res_unexp_rec.substitute_group_number) )
          THEN

             FOR l_subres_exist_rec IN l_subres_exist_csr
                 ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                 , p_sub_group_num => nvl(p_old_rev_op_resource_rec.substitute_group_number, p_old_rev_op_res_unexp_rec.substitute_group_number)
                 , p_res_seq_num   => l_rev_op_resource_rec.resource_sequence_number
                )
             LOOP

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_SUBRES_EXIST'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END LOOP ;

             IF BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
             AND  l_rev_op_resource_rec.acd_type    = l_ACD_CHANGE
             THEN
                 FOR l_rev_subres_exist_rec IN l_rev_subres_exist_csr
                     ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                     , p_sub_group_num => nvl(p_old_rev_op_resource_rec.substitute_group_number, p_old_rev_op_res_unexp_rec.substitute_group_number)
                     , p_res_seq_num   => l_rev_op_resource_rec.resource_sequence_number
                    )
                 LOOP

                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       Error_Handler.Add_Error_Token
                       (  p_message_name   => 'BOM_RES_SUBRES_EXIST'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                       ) ;
                    END IF ;

                    l_return_status := FND_API.G_RET_STS_ERROR ;

                 END LOOP ;
             END IF ;

          END IF ;

       END IF ;  --  Transation: UPDATE


       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('End of Validation specific to the Transaction Type of Update : ' || l_return_status) ;
       END IF ;

       --
       -- Validateion for Transaction Type : Create and Update
       --
       IF l_rev_op_resource_rec.transaction_type IN
         (BOM_Rtg_Globals.G_OPR_CREATE, BOM_Rtg_Globals.G_OPR_UPDATE)
       THEN

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Common Validateion for Transaction Type : Create and Update . . . . ' || l_return_status) ;
       END IF ;

          --
          -- Resource Id
          -- Check if valid resource id exists and belongs to depatment
          --
          IF ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR  l_rev_op_res_unexp_rec.resource_id <> p_old_rev_op_res_unexp_rec.resource_id
             )
          THEN

             /* Call Val_Resource_Id */
             Val_Resource_Id (  p_resource_id   => l_rev_op_res_unexp_rec.resource_id
                             ,  p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                             ,  x_return_status => l_temp_status
                             ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_RESID_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Resource is valid. . . . ' || l_return_status) ;
          END IF ;

          END IF ;


          --
          -- Activity Id
          -- Check if Activity is enabled
          --
          IF ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR (NVL(l_rev_op_res_unexp_rec.activity_id, FND_API.G_MISS_NUM)
                     <> NVL(p_old_rev_op_res_unexp_rec.activity_id, FND_API.G_MISS_NUM))
             )
             AND ( l_rev_op_res_unexp_rec.activity_id IS NOT NULL AND
                   l_rev_op_res_unexp_rec.activity_id <> FND_API.G_MISS_NUM )
          THEN

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Activity_Id : ' || to_char(l_rev_op_res_unexp_rec.activity_id)) ;
          END IF ;

             /* Call Val_Activity_Id */
             Val_Activity_Id (  p_activity_id   => l_rev_op_res_unexp_rec.activity_id
                             ,  p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                             ,  x_return_status => l_temp_status
                             ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_ACTID_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Activity is valid. . . . ' || l_return_status) ;
          END IF ;

          END IF ;



          --
          -- Setup Id
          -- Check if Setup Id is valid on this operation resource
          --
          IF ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR (NVL(l_rev_op_res_unexp_rec.setup_id , FND_API.G_MISS_NUM)
                     <> NVL(p_old_rev_op_res_unexp_rec.setup_id, FND_API.G_MISS_NUM))
             )
             AND ( l_rev_op_res_unexp_rec.setup_id IS NOT NULL AND
                   l_rev_op_res_unexp_rec.setup_id <> FND_API.G_MISS_NUM )
          THEN

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Setup Id : ' || to_char(l_rev_op_res_unexp_rec.setup_id)) ;
          END IF ;

             /* Call Val_Activity_Id */
             Val_Setup_Id (  p_setup_id         => l_rev_op_res_unexp_rec.setup_id
                          ,  p_resource_id      => l_rev_op_res_unexp_rec.resource_id
                          ,  p_organization_id  => l_rev_op_res_unexp_rec.organization_id
                          ,  x_return_status    => l_temp_status
                             ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                   l_token_tbl(2).token_name  := 'SETUP_CODE';
                   l_token_tbl(2).token_value :=
                                         l_rev_op_resource_rec.setup_type ;
                   l_token_tbl(3).token_name  := 'RESOURCE_CODE';
                   l_token_tbl(3).token_value :=
                                         l_rev_op_resource_rec.resource_code ;

                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_SETUP_ID_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_token_tbl.delete(2) ;
                l_token_tbl.delete(3) ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Setup is valid. . . . ' || l_return_status) ;
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

          IF p_rev_op_resource_rec.schedule_flag <> l_NO_SCHEDULE -- 2: No
          THEN

             IF ( l_hour_uom_code   IS NULL OR
                  l_hour_uom_class  IS NULL OR
                  l_res_uom_code    IS NULL OR
                  l_res_uom_class   IS NULL
                 )
             THEN
                Get_Resource_Uom ( p_resource_id
                                  => l_rev_op_res_unexp_rec.resource_id
                                 , x_hour_uom_code  => l_hour_uom_code
                                 , x_hour_uom_class => l_hour_uom_class
                                 , x_res_uom_code   => l_res_uom_code
                                 , x_res_uom_class  => l_res_uom_class ) ;
             END IF ;

             /* Call Val_Res_UOM_For_Schedule */
             Val_Res_UOM_For_Schedule
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
                      (  p_message_name   => 'BOM_RES_SCHEDULE_MUSTBE_NO'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Schedule flag is valid. . . . ' || l_return_status) ;
          END IF ;

          END IF ;

          --
          -- Scheduled Resource
          -- Cannot have more than one next or prior sheduled resource for
          -- an operation
          --

          IF  ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_op_resource_rec.schedule_flag <> p_old_rev_op_resource_rec.schedule_flag
              )
          THEN
                /* Call Val_Scheduled_Resource */
                Val_Scheduled_Resource
                ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                , p_res_seq_num   => l_rev_op_resource_rec.resource_sequence_number
                , p_sch_seq_num   => l_rev_op_resource_rec.schedule_sequence_number
                , p_schedule_flag => l_rev_op_resource_rec.schedule_flag
                , x_return_status => l_temp_status
                ) ;

                IF  l_temp_status = FND_API.G_RET_STS_ERROR
                AND FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   IF p_rev_op_resource_rec.schedule_flag  = l_YES_SCHEDULE -- 1: Yes
                   THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_RES_YES_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                   ELSIF p_rev_op_resource_rec.schedule_flag  = l_PRIOR -- 3: Prior
                   THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_RES_PRIOR_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                   ELSIF p_rev_op_resource_rec.schedule_flag  = l_NEXT -- 4: Next
                   THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_RES_NEXT_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                   END IF ;
                   l_return_status := FND_API.G_RET_STS_ERROR ;
                END IF ; -- If Error

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check next or prior scheduled resource. . . . ' || l_return_status) ;
          END IF ;

          END IF ;

          --
          -- Autocharge Type
          -- Autocharge type cannot be PO Recedipt if the
          -- department has no location.
          --
          IF  ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_op_resource_rec.autocharge_type <> p_old_rev_op_resource_rec.autocharge_type
              )
              AND l_rev_op_resource_rec.autocharge_type = l_PO_RECEIPT
          THEN

                -- Call Val_Dept_Has_Location
                Val_Dept_Has_Location
                ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                , x_return_status => l_temp_status
                ) ;

             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_RES_PO_ATHARGE_LOC_INVALID'
                       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                       , p_Token_Tbl      => l_Token_Tbl
                      ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;

             END IF ;

          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if Autocharge type is valid. . . . ' || l_return_status) ;
          END IF ;

          END IF ;


          --
          -- Autocharge Type
          -- Autocharge Type cannot be PO Move or PO Receipt if the resource
          -- is non-OSP resource
          --
          IF  ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_op_resource_rec.autocharge_type <> p_old_rev_op_resource_rec.autocharge_type
              )
             AND l_rev_op_resource_rec.autocharge_type IN (l_PO_RECEIPT, l_PO_MOVE )
          THEN

                /* Call Val_Autocharge_for_OSP_Res */
                Val_Autocharge_for_OSP_Res
                ( p_resource_id     => l_rev_op_res_unexp_rec.resource_id
                , p_organization_id => l_rev_op_res_unexp_rec.organization_id
                , x_return_status   => l_temp_status
                ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => 'BOM_RES_ATCHRG_CSTCODE_INVALID'
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
          -- Cannot have more than one PO Move per an operation
          --
          IF  ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_op_resource_rec.autocharge_type <> p_old_rev_op_resource_rec.autocharge_type
              )
              AND l_rev_op_resource_rec.autocharge_type = l_PO_MOVE
          THEN

                /* Call Val_PO_Move */
                Val_PO_Move
                ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                , p_res_seq_num   => l_rev_op_resource_rec.resource_sequence_number
                , x_return_status => l_temp_status
                ) ;

             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_POMOVE_INVALID'
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , p_Token_Tbl      => l_Token_Tbl
                   ) ;
                END IF ;

                l_return_status := FND_API.G_RET_STS_ERROR ;
             END IF ;


          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Check if parent operation can have the Po Move resource . . . . ' || l_return_status) ;
          END IF ;

          END IF ;


          --
          -- Usage Rate or Amount
          -- Check round values for Usage Rate or Amount and the Inverse.
          --
          IF  ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_op_resource_rec.usage_rate_or_amount
                                           <> p_old_rev_op_resource_rec.usage_rate_or_amount
              OR  l_rev_op_resource_rec.usage_rate_or_amount_inverse
                                           <> p_old_rev_op_resource_rec.usage_rate_or_amount_inverse
              )
          THEN

             /* Call Val_Usage_Rate_or_Amount */
             Val_Usage_Rate_or_Amount
              (  p_usage_rate_or_amount          => l_rev_op_resource_rec.usage_rate_or_amount
              ,  p_usage_rate_or_amount_inverse  => l_rev_op_resource_rec.usage_rate_or_amount_inverse
              ,  x_return_status                 => l_temp_status
              ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_RATEORAMOUNT_INVALID'
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
          -- comment out : 3. Resource UOM Class = Hour UOM Class
          -- Form is allowed case 3.
          --
          IF  ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_op_resource_rec.usage_rate_or_amount
                                           <> p_old_rev_op_resource_rec.usage_rate_or_amount
              OR  l_rev_op_resource_rec.usage_rate_or_amount_inverse
                                           <> p_old_rev_op_resource_rec.usage_rate_or_amount_inverse
              OR  l_rev_op_resource_rec.schedule_flag
                                           <> p_old_rev_op_resource_rec.schedule_flag
              OR  l_rev_op_resource_rec.autocharge_type
                                           <> p_old_rev_op_resource_rec.autocharge_type
              )
              AND l_rev_op_resource_rec.usage_rate_or_amount < 0
          THEN
             IF ( l_hour_uom_code   IS NULL OR
                  l_hour_uom_class  IS NULL OR
                  l_res_uom_code    IS NULL OR
                  l_res_uom_class   IS NULL
                 )
             THEN
                Get_Resource_Uom ( p_resource_id
                                  => l_rev_op_res_unexp_rec.resource_id
                                 , x_hour_uom_code  => l_hour_uom_code
                                 , x_hour_uom_class => l_hour_uom_class
                                 , x_res_uom_code   => l_res_uom_code
                                 , x_res_uom_class  => l_res_uom_class ) ;
             END IF ;


             /* Call Val_Negative_Usage_Rate */
             Val_Negative_Usage_Rate
               ( p_autocharge_type => l_rev_op_resource_rec.autocharge_type
               , p_schedule_flag   => l_rev_op_resource_rec.schedule_flag
               , p_hour_uom_class  => l_hour_uom_class
               , p_res_uom_class   => l_res_uom_class
               , x_return_status   => l_temp_status
               ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_NEGATIVE_USAGE_INVALID'
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



          --
          -- Principal Flag
          -- Cannot have one more principal resource in a group of simulatenous
          -- resources
          --
          /*  Comment out by MK. This validation is not required.
          */ -- Comment Out validation for priciple flag
	  /* Uncommented by deepu. Validation for Principal flag is required for patchset I Bug 2689249 */

          IF  ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                  AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
              OR  l_rev_op_resource_rec.principle_flag
                                           <> p_old_rev_op_resource_rec.principle_flag
              OR  nvl(l_rev_op_resource_rec.substitute_group_number, l_rev_op_res_unexp_rec.substitute_group_number)
                                           <> nvl(p_old_rev_op_resource_rec.substitute_group_number, p_old_rev_op_res_unexp_rec.substitute_group_number)
              )
              AND l_rev_op_resource_rec.principle_flag = 1 -- Yes
          THEN
             -- Call Val_Principal_Res_Unique
             Val_Principal_Res_Unique
                ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                , p_res_seq_num   => l_rev_op_resource_rec.resource_sequence_number
                , p_sub_group_num => nvl(l_rev_op_resource_rec.substitute_group_number, l_rev_op_res_unexp_rec.substitute_group_number)
                , x_return_status => l_temp_status
                ) ;


             IF  l_temp_status = FND_API.G_RET_STS_ERROR
             THEN
--dbms_output.put_line('found error in principal flag for resources');
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   Error_Handler.Add_Error_Token
                   (  p_message_name   => 'BOM_RES_PCFLAG_DUPLICATE'
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

          --
          -- Validate SSN
          --
          IF ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
             OR  l_rev_op_resource_rec.schedule_sequence_number <> p_old_rev_op_resource_rec.schedule_sequence_number
             OR  l_rev_op_resource_rec.substitute_group_number  <> p_old_rev_op_resource_rec.substitute_group_number)
          THEN
            -- Call Val_schedule_seq_num
	  /* Fix for bug 4506885 - Added parameter p_sub_grp_num to Val_Schedule_Seq_Num procedure call.*/
            Val_Schedule_Seq_Num
               ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
               , p_res_seq_num   => l_rev_op_resource_rec.resource_sequence_number
               , p_sch_seq_num   => l_rev_op_resource_rec.schedule_sequence_number
	       , p_sub_grp_num	 => l_rev_op_resource_rec.substitute_group_number
               , x_return_status => l_temp_status
               );

            IF l_temp_status = FND_API.G_RET_STS_ERROR
            THEN
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
		/* Fix for bug 4506885 - Changed the error msg shown to 'BOM_SAME_SUB_GRP_NUM' from 'BOM_LARGE_SGN_SSN'.
		   Also set the appropriate token to be shown in the error. */

		  l_Token_Tbl(1).Token_Name  := 'VALUE';
	          l_Token_Tbl(1).Token_Value := l_rev_op_resource_rec.schedule_sequence_number;

                  Error_Handler.Add_Error_Token
                  ( p_message_name   => 'BOM_SAME_SUB_GRP_NUM'
                  , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , p_Token_Tbl      => l_Token_Tbl
                  );
               END IF;

               l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
          END IF;

          /* bug:4638695 For an operation, do not allow same resource to be added more than once with same SSN */

          IF (
              (     NVL(l_rev_op_resource_rec.acd_type, l_ACD_ADD) = l_ACD_ADD
               AND  l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               )
              OR  l_rev_op_resource_rec.schedule_sequence_number <> p_old_rev_op_resource_rec.schedule_sequence_number
              OR
                (    p_old_rev_op_resource_rec.schedule_sequence_number IS NULL
                AND  l_rev_op_resource_rec.schedule_sequence_number IS NOT NULL
                )
              OR l_rev_op_res_unexp_rec.resource_id <>  p_old_rev_op_res_unexp_rec.resource_id
              )
          THEN
            Val_Resource_SSN
                          ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                          , p_res_seq_num   => l_rev_op_resource_rec.resource_sequence_number
                          , p_sch_seq_num   => l_rev_op_resource_rec.schedule_sequence_number
                          , p_resource_id  => l_rev_op_res_unexp_rec.resource_id
                          , x_return_status => l_temp_status
                          );

            IF l_temp_status = FND_API.G_RET_STS_ERROR THEN
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                IF ( l_rev_op_resource_rec.resource_code IS NOT NULL )
                THEN
                  l_res_code := l_rev_op_resource_rec.resource_code;
                ELSE
                  SELECT RESOURCE_CODE
                  INTO l_res_code
                  FROM BOM_RESOURCES_V
                  WHERE RESOURCE_ID = l_rev_op_res_unexp_rec.resource_id;
                END IF;

                l_Token_Tbl(1).Token_Name  := 'RESOURCE_CODE';
                l_Token_Tbl(1).Token_Value:=  l_res_code;
                l_Token_Tbl(2).Token_Name  := 'SCH_SEQ_NUM';
                l_Token_Tbl(2).Token_Value := l_rev_op_resource_rec.schedule_sequence_number;
                l_Token_Tbl(3).Token_Name  := 'OP_SEQ_NUM';
                l_Token_Tbl(3).Token_Value := l_rev_op_resource_rec.operation_sequence_number;

                Error_Handler.Add_Error_Token
                                        ( p_message_name   => 'BOM_RES_SSN_ALREADY_EXISTS'
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , p_Token_Tbl      => l_Token_Tbl
                                        );
              END IF; /* end of check_msg_level */
              l_return_status := FND_API.G_RET_STS_ERROR ;
            END IF; /* end of l_temp_status */

          END IF; /* end of validation on resource and ssn*/

        /*Fix for bug 6074930- Scheduled simultaneous resources must have the same scheduling flag.
             Added below code to do this validation. Resources with scheduling flag 'NO' are exempt
             for this validation. Call Val_Schedule_Flag procedure both while creating/updating a resource.*/

             IF ( l_rev_op_resource_rec.schedule_flag <> l_NO_SCHEDULE)
                AND
               ( ( NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                    AND l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE )
                OR  l_rev_op_resource_rec.schedule_sequence_number <> p_old_rev_op_resource_rec.schedule_sequence_number
                OR  (p_old_rev_op_resource_rec.schedule_sequence_number is null
                       and  l_rev_op_resource_rec.schedule_sequence_number is not null)
                OR  (p_old_rev_op_resource_rec.schedule_sequence_number is not null
                       and  l_rev_op_resource_rec.schedule_sequence_number is null)
                OR  ( l_rev_op_resource_rec.schedule_flag <>  p_old_rev_op_resource_rec.schedule_flag)
                )
             THEN
                   l_res_id := FND_API.G_MISS_NUM;

                   Val_Schedule_Flag
                   ( p_op_seq_id     => l_rev_op_res_unexp_rec.operation_sequence_id
                   , p_res_seq_num          => l_rev_op_resource_rec.resource_sequence_number
                   , p_sch_seq_num   => l_rev_op_resource_rec.schedule_sequence_number
                   , p_sch_flag          => l_rev_op_resource_rec.schedule_flag
                   , p_ret_res_id          => l_res_id
                   , x_return_status => l_temp_status
                   );

                   IF l_temp_status = FND_API.G_RET_STS_ERROR THEN
                           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             If (l_rev_op_resource_rec.resource_code is not null) Then
                                   l_res_code := l_rev_op_resource_rec.resource_code;
                             Else
                                   Select resource_code into l_res_code
                                   from bom_resources_v
                                   where resource_id=l_rev_op_res_unexp_rec.resource_id;
                             End If;

                                   Select resource_code into l_res_code_2
                                   from bom_resources_v
                                   where resource_id=l_res_id;

                             l_Token_Tbl(1).Token_Name  := 'RES_SEQ_1';
                             l_Token_Tbl(1).Token_Value:=  l_res_code;
                             l_Token_Tbl(2).Token_Name  := 'RES_SEQ_2';
                             l_Token_Tbl(2).Token_Value:=  l_res_code_2;
                             l_Token_Tbl(3).Token_Name  := 'OP_SEQ';
                             l_Token_Tbl(3).Token_Value := l_rev_op_resource_rec.operation_sequence_number;

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
       -- Return revised operation records
       --
       x_rev_op_resource_rec    := l_rev_op_resource_rec ;
       x_rev_op_res_unexp_rec   := l_rev_op_res_unexp_rec ;

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

  /* bug:4638695 For an operation do not allow same resource to be added more than once with same SSN */
  PROCEDURE Val_Resource_SSN
                            (  p_op_seq_id     IN   NUMBER
                            ,  p_res_seq_num   IN   NUMBER
                            ,  p_sch_seq_num   IN   NUMBER
                            ,  p_resource_id   IN   NUMBER
                            ,  x_return_status IN OUT NOCOPY VARCHAR2
                            )
  IS
   l_same_rsc_ssn NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_same_rsc_ssn := 0;

    SELECT COUNT(1)
    INTO  l_same_rsc_ssn
    FROM  BOM_OPERATION_RESOURCES
    WHERE
          SCHEDULE_SEQ_NUM = p_sch_seq_num
    AND   p_sch_seq_num IS NOT NULL
    AND   SCHEDULE_SEQ_NUM IS NOT NULL
    AND   RESOURCE_SEQ_NUM <> p_res_seq_num
    AND   RESOURCE_ID = p_resource_id
    AND   OPERATION_SEQUENCE_ID = p_op_seq_id ;

    IF ( l_same_rsc_ssn > 0 ) THEN
      x_return_status := Error_Handler.G_STATUS_ERROR;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

  END Val_Resource_SSN;

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
     , p_ret_res_id    IN OUT NOCOPY NUMBER
     , x_return_status IN OUT NOCOPY VARCHAR2
     )
     IS
       l_resource_id number;

       CURSOR l_sch_res_cur IS
       SELECT resource_id
       FROM   bom_operation_resources
       WHERE  operation_sequence_id = p_op_seq_id
       AND    resource_seq_num <> p_res_seq_num
       AND    nvl(schedule_seq_num,resource_seq_num) = nvl(p_sch_seq_num,p_res_seq_num)
       AND    schedule_flag not in (p_sch_flag,l_NO_SCHEDULE)
       AND    rownum=1;

       CURSOR l_sch_sub_res_cur IS
       SELECT resource_id
       FROM   bom_sub_operation_resources
       WHERE  operation_sequence_id = p_op_seq_id
       AND    schedule_seq_num      = nvl(p_sch_seq_num,p_res_seq_num)
       AND    schedule_flag not in (p_sch_flag,l_NO_SCHEDULE)
       AND    rownum=1;

     BEGIN
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_resource_id   := FND_API.G_MISS_NUM;

            /* Verify whether the current resource violates the validation w.r.t to
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

            /* If no violated resource is found above, then verify whether the current resource
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


END BOM_Validate_Op_Res ;

/
