--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_OP_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_OP_SEQ" AS
/* $Header: BOMDOPSB.pls 120.1 2005/06/06 06:14:47 appldev  $ */

/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMDOPSB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Op_Seq
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Masanori Kimizuka Initial Creation
--
****************************************************************************/

    G_Pkg_Name      VARCHAR2(30) := 'BOM_Default_Op_Seq';
    l_EVENT                       CONSTANT NUMBER := 1 ;
    l_PROCESS                     CONSTANT NUMBER := 2 ;
    l_LINE_OP                     CONSTANT NUMBER := 3 ;
    l_ACD_ADD                     CONSTANT NUMBER := 1 ;
    l_ACD_CHANGE                  CONSTANT NUMBER := 2 ;
    l_ACD_DISABLE                 CONSTANT NUMBER := 3 ;
    l_MODEL                       CONSTANT NUMBER := 1 ;
    l_OPTION_CLASS                CONSTANT NUMBER := 2 ;


    /*******************************************************************
    * Following are all get functions which will be used by the attribute
    * defaulting procedure. Each column needing to be defaulted has one GET
    * function.
    ********************************************************************/

    -- Operation_Sequence_Id
    FUNCTION Get_Operation_Sequence_Id RETURN NUMBER
    IS
       CURSOR l_op_seq_cur IS
       SELECT Bom_Operation_Sequences_S.NEXTVAL Op_Seq_Id
       FROM SYS.DUAL ;
    BEGIN
       FOR l_op_seq_rec IN l_op_seq_cur LOOP
          RETURN l_op_seq_rec.Op_Seq_Id ;
       END LOOP ;
       RETURN NULL ;
    END Get_Operation_Sequence_Id ;


    -- Routing_Sequence_Id
    FUNCTION Get_Routing_Sequence_Id(  p_revised_item_id        IN  NUMBER
                                     , p_organization_id        IN  NUMBER
                                     , p_alternate_routing_code IN  VARCHAR2 )
    RETURN NUMBER
    IS
    /*******************************************************************
    * Check if revised_item has a routing_sequence_id.
    * If it does then retun that as the default value, if not then
    * generate the Routing_Sequence_Id from the Sequence.
    **********************************************************************/
        CURSOR l_check_for_new_csr(  p_revised_item_id NUMBER
                                   , p_organization_id NUMBER
                                   , p_alternate_routing_code VARCHAR2 )
        IS
           SELECT routing_sequence_id
           FROM   bom_operational_routings bor
           WHERE  bor.assembly_item_id = p_revised_item_id
           AND    bor.organization_id  = p_organization_id
           AND    NVL(bor.alternate_routing_designator, FND_API.G_MISS_CHAR) =
                  NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR);


        CURSOR l_rtg_seq_csr  IS
        SELECT Bom_Operational_Routings_S.NEXTVAL Rtg_Seq_Id
        FROM SYS.DUAL ;

        l_routing_sequence_id  NUMBER;

    BEGIN

        --
        -- Check if routing sequence id exists in Eng_Revised_Items
        -- but through global record. Hopefully the ECO object
        -- will have set this.
        IF BOM_Rtg_Globals.Get_Routing_Sequence_Id IS NOT NULL THEN
          l_routing_sequence_id :=
          BOM_Rtg_Globals.Get_Routing_Sequence_Id;
          RETURN l_routing_sequence_id ;
        END IF;

        --
        -- If routing sequence id is not found in Eng_Revised_Items
        -- Only then go to the Rtg Table to look for Bill_Sequence_Id
        --

        OPEN  l_check_for_new_csr(   p_revised_item_id
                                   , p_organization_id
                                   , p_alternate_routing_code)  ;
        FETCH l_check_for_new_csr INTO l_routing_sequence_id;
        CLOSE l_check_for_new_csr ;

        --
        -- If routing sequence id is not found in Rtg Table
        -- generate the Routing_Sequence_Id from the Sequence.
        --

        IF l_routing_sequence_id IS NULL
        THEN
           FOR l_rtg_seq_rec IN l_rtg_seq_csr LOOP
              RETURN l_rtg_seq_rec.Rtg_Seq_Id ;
           END LOOP ;
        ELSE
           RETURN l_routing_sequence_id ;
        END IF;

        RETURN NULL ;

    END Get_Routing_Sequence_Id ;

    -- Operation_Type
    FUNCTION Get_Operation_Type
    RETURN NUMBER
    IS
    BEGIN

            RETURN 1 ;   -- Return 1 : Event

    END Get_Operation_Type ;

    -- Start_Effective_Date
    FUNCTION Get_Start_Effective_Date
    RETURN DATE
    IS
       l_current_date DATE := NULL ;
    BEGIN
/** time **/
        SELECT SYSDATE   -- Changed for bug 2647027
--        SELECT TRUNC(SYSDATE)
        INTO l_current_date
        FROM SYS.DUAL ;

        RETURN l_current_date ;

    END  Get_Start_Effective_Date ;



    -- Count_Point_Type
    FUNCTION Get_Count_Point_Type
    RETURN NUMBER
    IS
    BEGIN

            RETURN 1 ;   -- Return Yes-Autocharge which is 1

    END Get_Count_Point_Type ;


    -- BackFlush_Flag
    FUNCTION Get_BackFlush_Flag
    RETURN NUMBER
    IS
    BEGIN

            RETURN 1 ;   -- Return Yes which is 1

    END Get_BackFlush_Flag ;

    -- Reference_Flag
    FUNCTION Get_Reference_Flag(p_std_op_code IN VARCHAR2)
    RETURN NUMBER
    IS
    BEGIN

       IF ( p_std_op_code IS NULL
            OR p_std_op_code = FND_API.G_MISS_CHAR )
       THEN
            RETURN 2 ;   -- Return No which is 2

       ELSE
            RETURN 1 ;   -- Return Yes which is 1
       END IF ;

    END Get_Reference_Flag  ;


    -- Option_Dependent_Flag
    FUNCTION Get_Option_Dependent_Flag
                    (  p_revised_item_id   IN NUMBER
                     , p_organization_id   IN NUMBER
                    )

    RETURN NUMBER
    IS

         g_assy_item_type NUMBER ;

    BEGIN
          -- If Assembly Item Type = Model or Option, Return 1:Yes
          -- Else If Assembly Item Type = Standard, Return 2:No
          SELECT  bom_item_type
          INTO    g_assy_item_type
          FROM    MTL_SYSTEM_ITEMS
          WHERE   organization_id   = p_organization_id
          AND     inventory_item_id = p_revised_item_id ;

          IF g_assy_item_type in ( l_MODEL,l_OPTION_CLASS )
          THEN
              RETURN 1 ;   -- Return Yes which is 1
          ELSE
              RETURN 2 ;   -- Return No which is 2
          END IF;

    END Get_Option_Dependent_Flag ;


    -- Minimum_Transfer_Quantity
    FUNCTION Get_Minimum_Transfer_Quantity
    RETURN NUMBER
    IS
    BEGIN

            RETURN 0 ;   -- Return 0 : 0 qty

    END Get_Minimum_Transfer_Quantity ;

    -- User_Labor_Time
    FUNCTION Get_User_Labor_Time
    RETURN NUMBER
    IS
    BEGIN

            RETURN 0 ;   -- Return 0 : 0 time

    END Get_User_Labor_Time ;

    -- User_Machine_Time
    FUNCTION Get_User_Machine_Time
    RETURN NUMBER
    IS
    BEGIN

            RETURN 0 ;   -- Return 0 : 0 time

    END Get_User_Machine_Time ;

    -- User_Elapsed_Time
    FUNCTION Get_User_Elapsed_Time
             (  p_user_labor_time   IN NUMBER
              , p_user_machine_time IN NUMBER )
    RETURN NUMBER
    IS
        l_user_elapsed_time NUMBER := NULL ;

    BEGIN
            l_user_elapsed_time :=
              NVL(p_user_labor_time , 0 )  +
              NVL(p_user_machine_time, 0 ) ;


            RETURN l_user_elapsed_time  ;

    END Get_User_Elapsed_Time ;


    -- Include_In_Rollup
    FUNCTION Get_Include_In_Rollup
    RETURN NUMBER
    IS
    BEGIN

            RETURN 1 ;   -- Return 1 : Yes

    END Get_Include_In_Rollup ;


    -- Get_Op_Yield_Enabled_Flag
    FUNCTION Get_Op_Yield_Enabled_Flag
    RETURN NUMBER
    IS
    BEGIN

            RETURN 1 ;   -- Return 1 : Yes

    END Get_Op_Yield_Enabled_Flag ;


    PROCEDURE Get_Flex_Op_Seq
    (  p_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
    )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
       --  Initialize operation exp and unexp record
       l_com_operation_rec  := p_com_operation_rec ;

        --  In the future call Flex APIs for defaults

        IF l_com_operation_rec.attribute_category = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute_category := NULL;
        END IF;

        IF l_com_operation_rec.attribute1 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute1 := NULL;
        END IF;

        IF l_com_operation_rec.attribute2 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute2 := NULL;
        END IF;

        IF l_com_operation_rec.attribute3 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute3 := NULL;
        END IF;

        IF l_com_operation_rec.attribute4 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute4 := NULL;
        END IF;

        IF l_com_operation_rec.attribute5 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute5 := NULL;
        END IF;

        IF l_com_operation_rec.attribute6 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute6 := NULL;
        END IF;

        IF l_com_operation_rec.attribute7 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute7 := NULL;
        END IF;

        IF l_com_operation_rec.attribute8 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute8 := NULL;
        END IF;

        IF l_com_operation_rec.attribute9 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute9 := NULL;
        END IF;

        IF l_com_operation_rec.attribute10 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute10 := NULL;
        END IF;

        IF l_com_operation_rec.attribute11 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute11 := NULL;
        END IF;

        IF l_com_operation_rec.attribute12 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute12 := NULL;
        END IF;

        IF l_com_operation_rec.attribute13 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute13 := NULL;
        END IF;

        IF l_com_operation_rec.attribute14 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute14 := NULL;
        END IF;

        IF l_com_operation_rec.attribute15 = FND_API.G_MISS_CHAR THEN
            l_com_operation_rec.attribute15 := NULL;
        END IF;

        x_com_operation_rec := l_com_operation_rec ;

    END Get_Flex_Op_Seq ;


    /******************************************************************
    * Procedure : Default_Std_Op_Attributes internally
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
    PROCEDURE Default_Std_Op_Attributes
    (  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_com_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    )
   IS
    -- Variables
    l_std_op_found      BOOLEAN ; -- Indicate Std OP is found
    l_copy_std_op       BOOLEAN ; -- Indicate Copy Std Op has been proceeded

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

    -- Get Standard Operation Info.
    CURSOR l_stdop_csr(   p_std_op_id      NUMBER
                        , p_op_type        NUMBER
                        , p_rtg_seq_id     NUMBER
                        , p_org_id         NUMBER
                        , p_dept_id        NUMBER
                        , p_rit_seq_id     NUMBER
                      )
    IS
       SELECT   bso.department_id
              , bso.minimum_transfer_quantity
              , bso.count_point_type
              , bso.operation_description
              , bso.backflush_flag
              , bso.option_dependent_flag
              , bso.attribute_category
              , bso.attribute1
              , bso.attribute2
              , bso.attribute3
              , bso.attribute4
              , bso.attribute5
              , bso.attribute6
              , bso.attribute7
              , bso.attribute8
              , bso.attribute9
              , bso.attribute10
              , bso.attribute11
              , bso.attribute12
              , bso.attribute13
              , bso.attribute14
              , bso.attribute15
              , bso.operation_yield_enabled
              , bso.shutdown_type
              , bso.yield  --bug 3572770
	      , bso.lowest_acceptable_yield  -- Added for MES Enhancement
	      ,	bso.use_org_settings
	      ,	bso.queue_mandatory_flag
	      ,	bso.run_mandatory_flag
	      ,	bso.to_move_mandatory_flag
	      ,	bso.show_next_op_by_default
	      ,	bso.show_scrap_code
	      ,	bso.show_lot_attrib
	      ,	bso.track_multiple_res_usage_dates  -- End of MES Changes
       FROM     BOM_STANDARD_OPERATIONS  bso
              , bom_operational_routings bor
       WHERE   NVL(bso.operation_type,1 )
                               = DECODE(p_op_type, FND_API.G_MISS_NUM, 1
                                        , NVL(p_op_type, 1))
       AND     NVL(bso.line_id, FND_API.G_MISS_NUM)
                               = NVL(bor.line_id, FND_API.G_MISS_NUM)
       AND    bor.routing_sequence_id   = p_rtg_seq_id
       AND    bso.organization_id       = p_org_id
       AND    bso.standard_operation_id = p_std_op_id
       UNION
       SELECT   bso.department_id
              , bso.minimum_transfer_quantity
              , bso.count_point_type
              , bso.operation_description
              , bso.backflush_flag
              , bso.option_dependent_flag
              , bso.attribute_category
              , bso.attribute1
              , bso.attribute2
              , bso.attribute3
              , bso.attribute4
              , bso.attribute5
              , bso.attribute6
              , bso.attribute7
              , bso.attribute8
              , bso.attribute9
              , bso.attribute10
              , bso.attribute11
              , bso.attribute12
              , bso.attribute13
              , bso.attribute14
              , bso.attribute15
              , bso.operation_yield_enabled
              , bso.shutdown_type
              , bso.yield  --bug 3572770
	      , bso.lowest_acceptable_yield  -- Added for MES Enhancement
	      ,	bso.use_org_settings
	      ,	bso.queue_mandatory_flag
	      ,	bso.run_mandatory_flag
	      ,	bso.to_move_mandatory_flag
	      ,	bso.show_next_op_by_default
	      ,	bso.show_scrap_code
	      ,	bso.show_lot_attrib
	      ,	bso.track_multiple_res_usage_dates  -- End of MES Changes
       FROM     BOM_STANDARD_OPERATIONS  bso
             -- , ENG_REVISED_ITEMS        eri   --Bug : 3640944 By AMALVIYA
       WHERE   NVL(bso.operation_type, 1)
                 = DECODE( p_op_type, FND_API.G_MISS_NUM, 1
                         , NVL(p_op_type, 1 ) )
       -- AND     NVL(bso.line_id, FND_API.G_MISS_NUM)
       --                      = NVL(eri.line_id, FND_API.G_MISS_NUM)
       -- AND     eri.revised_item_sequence_id =  p_rev_item_sequence_id
       AND    BOM_Rtg_Globals.Get_Routing_Sequence_Id   IS NULL
       AND    bso.organization_id       = p_org_id
       AND    bso.standard_operation_id = p_std_op_id
       ;


    BEGIN

          --  Initialize operation exp and unexp record
          l_com_operation_rec  := p_com_operation_rec ;
          l_com_op_unexp_rec   := p_com_op_unexp_rec ;

          -- Set the first token to be equal to the operation sequence number
          l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
          l_Token_Tbl(1).token_value := p_com_operation_rec.operation_sequence_number ;

          l_return_status            := FND_API.G_RET_STS_SUCCESS;

          --
          -- Standard Operation has changed to not null value
          --
          IF  NVL(l_com_operation_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
              -- OR l_com_operation_rec.acd_type = l_ACD_CHANGE
          THEN

             l_copy_std_op   := TRUE ;
             --
             -- Check if the operation already has resources
             --
             /*******************************************************
             -- This check is no longer used.
             --
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

             *******************************************************/


             IF l_copy_std_op AND l_com_operation_rec.reference_flag <> 1 -- Yes
             THEN
                l_std_op_found := FALSE ;
                --
                -- Get Standard Operatin Information
                --

/*
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
       Error_Handler.Write_Debug('std op id  '||to_char(l_com_op_unexp_rec.standard_operation_id) ) ;
       Error_Handler.Write_Debug('op type    '||to_char(l_com_operation_rec.operation_type) ) ;
       Error_Handler.Write_Debug('rtg seq id  '||to_char(l_com_op_unexp_rec.routing_sequence_id) ) ;
       Error_Handler.Write_Debug('org id  '||to_char(l_com_op_unexp_rec.organization_id) ) ;
       Error_Handler.Write_Debug('dept id  '||to_char(l_com_op_unexp_rec.department_id) ) ;
       Error_Handler.Write_Debug('rev seq id  '||to_char(l_com_op_unexp_rec.revised_item_sequence_id) ) ;
END IF ;
*/


                FOR l_stdop_rec IN l_stdop_csr
                      (   p_std_op_id  => l_com_op_unexp_rec.standard_operation_id
                        , p_op_type    => l_com_operation_rec.operation_type
                        , p_rtg_seq_id => l_com_op_unexp_rec.routing_sequence_id
                        , p_org_id     => l_com_op_unexp_rec.organization_id
                        , p_dept_id    => l_com_op_unexp_rec.department_id
                        , p_rit_seq_id => l_com_op_unexp_rec.revised_item_sequence_id
                      )
                LOOP
                   l_std_op_found := TRUE ;

                   --
                   -- Set Standard Operation Value to Operation Exp and Unexp Rec.
                   --
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Set Standard Operation Value to Null Operation columns.. . . ' ) ;
       END IF ;


                   IF  l_com_op_unexp_rec.department_id IS NULL OR
                       l_com_op_unexp_rec.department_id = FND_API.G_MISS_NUM
                   THEN
                       l_com_op_unexp_rec.department_id := l_stdop_rec.department_id ;
                   END IF ;

                   IF  l_com_operation_rec.count_point_type  IS NULL OR
                       l_com_operation_rec.count_point_type  = FND_API.G_MISS_NUM
                   THEN
                       l_com_operation_rec.count_point_type  := l_stdop_rec.count_point_type  ;
                   END IF ;

                   IF  l_com_operation_rec.backflush_flag  IS NULL OR
                       l_com_operation_rec.backflush_flag   = FND_API.G_MISS_NUM
                   THEN
                       l_com_operation_rec.backflush_flag := l_stdop_rec.backflush_flag ;
                   END IF ;

                   IF  l_com_operation_rec.minimum_transfer_quantity IS NULL OR
                       l_com_operation_rec.minimum_transfer_quantity = FND_API.G_MISS_NUM
                   THEN
                       l_com_operation_rec.minimum_transfer_quantity := l_stdop_rec.minimum_transfer_quantity ;
                   END IF ;

                   IF  l_com_operation_rec.option_dependent_flag IS NULL OR
                       l_com_operation_rec.option_dependent_flag  = FND_API.G_MISS_NUM
                   THEN
                       l_com_operation_rec.option_dependent_flag := l_stdop_rec.option_dependent_flag ;
                   END IF ;


                   IF  l_com_operation_rec.operation_description  IS NULL OR
                       l_com_operation_rec.operation_description   = FND_API.G_MISS_CHAR
                   THEN
                       l_com_operation_rec.operation_description := l_stdop_rec.operation_description ;
                   END IF ;

                   -- Added condition for Bug1744254
                   IF  ( l_com_operation_rec.op_yield_enabled_flag IS NULL OR
                         l_com_operation_rec.op_yield_enabled_flag = FND_API.G_MISS_NUM )
                   AND  BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_LOT_RTG
                   THEN
                       l_com_operation_rec.op_yield_enabled_flag := l_stdop_rec.operation_yield_enabled ;
                       l_com_operation_rec.yield := l_stdop_rec.yield; --bug 3572770
                   END IF ;

                   -- Added by MK on 04/10/2001 for eAM changes
                   IF  l_com_operation_rec.shutdown_type IS NULL OR
                       l_com_operation_rec.shutdown_type = FND_API.G_MISS_CHAR
                   THEN
                       l_com_operation_rec.shutdown_type := l_stdop_rec.shutdown_type ;
                   END IF ;

                   l_com_operation_rec.attribute_category        := NVL(l_com_operation_rec.attribute_category
                                                                       ,l_stdop_rec.attribute_category) ;
                   l_com_operation_rec.attribute1   := NVL(l_com_operation_rec.attribute1,l_stdop_rec.attribute1) ;
                   l_com_operation_rec.attribute2   := NVL(l_com_operation_rec.attribute2,l_stdop_rec.attribute2) ;
                   l_com_operation_rec.attribute3   := NVL(l_com_operation_rec.attribute3,l_stdop_rec.attribute3) ;
                   l_com_operation_rec.attribute4   := NVL(l_com_operation_rec.attribute4,l_stdop_rec.attribute4) ;
                   l_com_operation_rec.attribute5   := NVL(l_com_operation_rec.attribute5,l_stdop_rec.attribute5) ;
                   l_com_operation_rec.attribute6   := NVL(l_com_operation_rec.attribute6,l_stdop_rec.attribute6) ;
                   l_com_operation_rec.attribute7   := NVL(l_com_operation_rec.attribute7,l_stdop_rec.attribute7) ;
                   l_com_operation_rec.attribute8   := NVL(l_com_operation_rec.attribute8,l_stdop_rec.attribute8) ;
                   l_com_operation_rec.attribute9   := NVL(l_com_operation_rec.attribute9,l_stdop_rec.attribute9) ;
                   l_com_operation_rec.attribute10  := NVL(l_com_operation_rec.attribute10,l_stdop_rec.attribute10) ;
                   l_com_operation_rec.attribute11  := NVL(l_com_operation_rec.attribute11,l_stdop_rec.attribute11) ;
                   l_com_operation_rec.attribute12  := NVL(l_com_operation_rec.attribute12,l_stdop_rec.attribute12) ;
                   l_com_operation_rec.attribute13  := NVL(l_com_operation_rec.attribute13,l_stdop_rec.attribute13) ;
                   l_com_operation_rec.attribute14  := NVL(l_com_operation_rec.attribute14,l_stdop_rec.attribute14) ;
                   l_com_operation_rec.attribute15  := NVL(l_com_operation_rec.attribute15,l_stdop_rec.attribute15) ;

                   l_com_op_unexp_rec.Lowest_acceptable_yield         := NVL(l_com_op_unexp_rec.Lowest_acceptable_yield,l_stdop_rec.Lowest_acceptable_yield) ; -- Added for MES Enhancement
                   l_com_op_unexp_rec.Use_org_settings                := NVL(l_com_op_unexp_rec.Use_org_settings,l_stdop_rec.Use_org_settings) ;
		   l_com_op_unexp_rec.Queue_mandatory_flag            := NVL(l_com_op_unexp_rec.Queue_mandatory_flag,l_stdop_rec.Queue_mandatory_flag) ;
		   l_com_op_unexp_rec.Run_mandatory_flag              := NVL(l_com_op_unexp_rec.Run_mandatory_flag,l_stdop_rec.Run_mandatory_flag) ;
		   l_com_op_unexp_rec.To_move_mandatory_flag          := NVL(l_com_op_unexp_rec.To_move_mandatory_flag,l_stdop_rec.To_move_mandatory_flag) ;
		   l_com_op_unexp_rec.Show_next_op_by_default         := NVL(l_com_op_unexp_rec.Show_next_op_by_default,l_stdop_rec.Show_next_op_by_default) ;
		   l_com_op_unexp_rec.Show_scrap_code	              := NVL(l_com_op_unexp_rec.Show_scrap_code,l_stdop_rec.Show_scrap_code) ;
		   l_com_op_unexp_rec.Show_lot_attrib	              := NVL(l_com_op_unexp_rec.Show_lot_attrib,l_stdop_rec.Show_lot_attrib) ;
		   l_com_op_unexp_rec.Track_multiple_res_usage_dates  := NVL(l_com_op_unexp_rec.Track_multiple_res_usage_dates,l_stdop_rec.Track_multiple_res_usage_dates) ; -- End of MES Changes

                END LOOP ;  -- copy standard operation

          --
          --  If reference flag is Yes( operation columns corresponding to
          --  columns in Standard Operations), the values should not be changed
          --  when referenced.
          --
          ELSIF l_copy_std_op AND  l_com_operation_rec.reference_flag = 1 -- Yes
          THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Reference flag is Yes, then the operation columns corresponding to in Standard Operations . . . ' ) ;
END IF ;
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

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Std operation info should be copied over to the columns. . . ' ) ;
END IF ;

                -- Set Standard Operation Info.
                IF  l_com_op_unexp_rec.department_id IS NULL OR
                       l_com_op_unexp_rec.department_id = FND_API.G_MISS_NUM
                THEN
                       l_com_op_unexp_rec.department_id := l_stdop_rec.department_id ;
                END IF ;

                l_com_operation_rec.minimum_transfer_quantity := l_stdop_rec.minimum_transfer_quantity;
                l_com_operation_rec.count_point_type := l_stdop_rec.count_point_type ;
                l_com_operation_rec.operation_description := l_stdop_rec.operation_description ;


                -- l_com_operation_rec.option_dependent_flag := l_stdop_rec.option_dependent_flag ;
                IF  l_com_operation_rec.option_dependent_flag IS NULL OR
                    l_com_operation_rec.option_dependent_flag  = FND_API.G_MISS_NUM
                THEN
                    l_com_operation_rec.option_dependent_flag := l_stdop_rec.option_dependent_flag ;
                END IF ;

                -- Added by MK on 04/10/2001 for eAM changes
                l_com_operation_rec.shutdown_type := l_stdop_rec.shutdown_type ;

                l_com_operation_rec.attribute_category := l_stdop_rec.attribute_category ;
                l_com_operation_rec.attribute1  := l_stdop_rec.attribute1 ;
                l_com_operation_rec.attribute2  := l_stdop_rec.attribute2 ;
                l_com_operation_rec.attribute3  := l_stdop_rec.attribute3 ;
                l_com_operation_rec.attribute4  := l_stdop_rec.attribute4 ;
                l_com_operation_rec.attribute5  := l_stdop_rec.attribute5 ;
                l_com_operation_rec.attribute6  := l_stdop_rec.attribute6 ;
                l_com_operation_rec.attribute7  := l_stdop_rec.attribute7 ;
                l_com_operation_rec.attribute8  := l_stdop_rec.attribute8 ;
                l_com_operation_rec.attribute9  := l_stdop_rec.attribute9 ;
                l_com_operation_rec.attribute10 := l_stdop_rec.attribute10 ;
                l_com_operation_rec.attribute11 := l_stdop_rec.attribute11 ;
                l_com_operation_rec.attribute12 := l_stdop_rec.attribute12 ;
                l_com_operation_rec.attribute13 := l_stdop_rec.attribute13 ;
                l_com_operation_rec.attribute14 := l_stdop_rec.attribute14 ;
                l_com_operation_rec.attribute15 := l_stdop_rec.attribute15 ;
                l_com_operation_rec.backflush_flag := l_stdop_rec.backflush_flag;

                l_com_op_unexp_rec.Lowest_acceptable_yield         := l_stdop_rec.Lowest_acceptable_yield ; -- Added for MES Enhancement
                l_com_op_unexp_rec.Use_org_settings                := l_stdop_rec.Use_org_settings ;
                l_com_op_unexp_rec.Queue_mandatory_flag            := l_stdop_rec.Queue_mandatory_flag ;
	        l_com_op_unexp_rec.Run_mandatory_flag              := l_stdop_rec.Run_mandatory_flag ;
	        l_com_op_unexp_rec.To_move_mandatory_flag          := l_stdop_rec.To_move_mandatory_flag ;
	        l_com_op_unexp_rec.Show_next_op_by_default         := l_stdop_rec.Show_next_op_by_default ;
	        l_com_op_unexp_rec.Show_scrap_code	           := l_stdop_rec.Show_scrap_code ;
	        l_com_op_unexp_rec.Show_lot_attrib	           := l_stdop_rec.Show_lot_attrib ;
   	        l_com_op_unexp_rec.Track_multiple_res_usage_dates  := l_stdop_rec.Track_multiple_res_usage_dates ; -- End of MES Changes


                -- Added condition for Bug1744254
                IF BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_LOT_RTG THEN
                    l_com_operation_rec.op_yield_enabled_flag := l_stdop_rec.operation_yield_enabled;
                    l_com_operation_rec.yield := l_stdop_rec.yield; --bug 3572770
                END IF ;

             END LOOP ; -- copy standard operation

          END IF ; -- Ref Flag is Yes

       END IF ; -- Acd Type : Add

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Default Standard Operation Attributes  was processed. . . ' || l_return_status);
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
          ('Some unknown error in Entity Validation(Default Std Op) . . .' || SQLERRM );
          END IF ;


          l_err_text := G_PKG_NAME || ' Validation (Entity Validation(Default Std Op)) '
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

    END Default_Std_Op_Attributes;

    /*********************************************************************
    * Procedure : Attribute_Defaulting by RTG BO
    * Parameters IN : Operation exposed column record
    *                 Operation unexposed column record
    * Parameters out: Operation exposed column record after defaulting
    *                 Operation unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Operation to Common Operation and
    *             Call Attribute_Defaulting for Common
    *             This procedure will default values in all the operation
    *             fields that the user has left unfilled.
    **********************************************************************/
    PROCEDURE Attribute_Defaulting
    (  p_operation_rec     IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec      IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec     IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status     IN OUT NOCOPY VARCHAR2
    )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
        (  p_rtg_operation_rec      => p_operation_rec
         , p_rtg_op_unexp_rec       => p_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;


        -- Once the record transfer is done call the common
        -- operation attribute defaulting
        --
        BOM_Default_Op_Seq.Attribute_Defaulting
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_Rec => Bom_Rtg_Pub.G_Default_Control_Rec
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


    END Attribute_Defaulting ;

    /********************************************************************
    * Procedure : Attribute_Defaulting by ECO BO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    * Parameters out: Revised Operation exposed column record after defaulting
    *                 Revised Operation unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Operation to Common Operation and
    *             Call Attribute_Defaulting for Common
    *             This procedure will default values in all the operation.
    *             fields that the user has left unfilled.
    *********************************************************************/
    PROCEDURE Attribute_Defaulting
    (  p_rev_operation_rec    IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        -- Convert Revised Operation to Common Operation
        Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
        (  p_rev_operation_rec      => p_rev_operation_rec
         , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;


        -- Once the record transfer is done call the common
        -- operation attribute defaulting
        --
        BOM_Default_Op_Seq.Attribute_Defaulting
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_Rec => Bom_Rtg_Pub.G_Default_Control_Rec
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

    END Attribute_Defaulting ;



    /********************************************************************
    * Procedure : Attribute_Defaulting for Common
    *                       and internally called by RTG BO and ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Common Operation exposed column record after defaulting
    *                 Common Operation unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Attribute defaulting proc. defualts columns to
    *             appropriate values. Defualting will happen for
    *             exposed as well as unexposed columns.
    *********************************************************************/
    PROCEDURE Attribute_Defaulting
    (  p_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec     IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_com_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    )

    IS

        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_temp_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
        l_Temp_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;


    BEGIN

            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Rev. Operation Attr. Defaulting...') ;
            END IF ;

            l_return_status := FND_API.G_RET_STS_SUCCESS ;
            x_return_status := FND_API.G_RET_STS_SUCCESS ;

            --  Initialize operation exp and unexp record
            l_com_operation_rec  := p_com_operation_rec ;
            l_com_op_unexp_rec   := p_com_op_unexp_rec ;

            /***********************************************************
            --
            -- Default ACD Type
            --
            ***********************************************************/

            IF l_com_operation_rec.acd_type  =  FND_API.G_MISS_NUM
            THEN
                l_com_operation_rec.acd_type  := NULL ;
            END IF;



            /***********************************************************
            --
            -- Default Operation_Sequence_Id
            --
            ***********************************************************/
            IF l_com_op_unexp_rec.operation_sequence_id IS NULL OR
               l_com_op_unexp_rec.operation_sequence_id = FND_API.G_MISS_NUM
            THEN

                l_com_op_unexp_rec.operation_sequence_id :=
                Get_Operation_Sequence_Id ;
            END IF ;

            /***********************************************************
            --
            -- Default Operation_Type
            --
            ***********************************************************/
            IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag <> BOM_Rtg_Globals.G_FLOW_RTG
                 OR BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
               )
               AND (  l_com_operation_rec.operation_type IS NULL
                   OR l_com_operation_rec.operation_type =  FND_API.G_MISS_NUM
                  )
            THEN
               l_com_operation_rec.operation_type :=
               Get_Operation_Type ;
            END IF ;


            /***********************************************************
            --
            -- Default Effectivity_Date for Process/Line Op in Flow Rtg
            --
            ***********************************************************/
            IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_FLOW_RTG
                 OR BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_RTG_BO)
            AND  l_com_operation_rec.operation_type IN (l_PROCESS ,l_LINE_OP )
            THEN
               l_com_operation_rec.start_effective_date :=
               Get_Start_Effective_Date ;
            END IF ;


            /************************************************************
            --
            -- Default Reference_Flag
            --
            ************************************************************/

            IF l_com_operation_rec.reference_flag IS NULL OR
               l_com_operation_rec.reference_flag = FND_API.G_MISS_NUM
            THEN
               l_com_operation_rec.reference_flag :=
                    Get_Reference_Flag
                    (p_std_op_code => l_com_operation_rec.standard_operation_code ) ;
            END IF ;

            /************************************************************
            --
            -- Default Option_Dependent_Flag
            --
            ************************************************************/

            IF l_com_operation_rec.option_dependent_flag IS NULL OR
               l_com_operation_rec.option_dependent_flag = FND_API.G_MISS_NUM
            THEN
                l_com_operation_rec.option_dependent_flag :=
                    Get_Option_Dependent_Flag
                    (  p_revised_item_id        => l_com_op_unexp_rec.revised_item_id
                     , p_organization_id        => l_com_op_unexp_rec.organization_id
                    ) ;
            END IF;



            IF ( l_com_operation_rec.standard_operation_code IS NULL
                OR l_com_operation_rec.standard_operation_code = FND_API.G_MISS_CHAR
               )
            THEN

                /*********************************************************
                --
                -- Default Count_Point_Type
                --
                ***********************************************************/

                IF l_com_operation_rec.count_point_type IS NULL OR
                 l_com_operation_rec.count_point_type =  FND_API.G_MISS_NUM
                THEN

                    l_com_operation_rec.count_point_type :=
                    Get_Count_Point_Type ;
                END IF;

                /************************************************************
                --
                -- Default BackFlush_Flag
                --
                ************************************************************/

                IF l_com_operation_rec.backflush_flag IS NULL OR
                   l_com_operation_rec.backflush_flag = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.backflush_flag :=
                    Get_BackFlush_Flag ;
                END IF;

                /************************************************************
                -- Option Dependent should be defaulted even if Std Op is not NULL
                -- Default Option_Dependent_Flag
                --
                IF l_com_operation_rec.option_dependent_flag IS NULL OR
                   l_com_operation_rec.option_dependent_flag = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.option_dependent_flag :=
                    Get_Option_Dependent_Flag
                    (  p_revised_item_id        => l_com_op_unexp_rec.revised_item_id
                     , p_organization_id        => l_com_op_unexp_rec.organization_id
                    ) ;
                END IF;

                ************************************************************/

                /************************************************************
                --
                -- Default Minimum_Transfer_Quantity
                --
                ************************************************************/

                IF l_com_operation_rec.minimum_transfer_quantity IS NULL OR
                   l_com_operation_rec.minimum_transfer_quantity = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.minimum_transfer_quantity :=
                    Get_Minimum_Transfer_Quantity ;
                END IF;


            ELSE

                /************************************************************
                --
                -- Defualt Std Op Attributes
                --
                ************************************************************/
               Default_Std_Op_Attributes
               ( p_com_operation_rec     => l_com_operation_rec
               , p_com_op_unexp_rec      => l_com_op_unexp_rec
               , x_com_operation_rec     => l_com_operation_rec
               , x_com_op_unexp_rec      => l_com_op_unexp_rec
               , x_return_status         => l_temp_return_status
               , x_mesg_token_tbl        => l_temp_mesg_token_tbl
               ) ;


               IF l_temp_return_status = FND_API.G_RET_STS_ERROR
               THEN
                   l_mesg_token_tbl := l_temp_mesg_token_tbl ;
                   l_return_status  := FND_API.G_RET_STS_ERROR ;
               END IF ;


            END IF ; -- if Std Op is null or not null



            -- Check if the parent routing is Flow Routing
            IF    BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_FLOW_RTG
            THEN
               IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                ('Attr. Defaulting for Flow Routing...' || to_char(l_com_op_unexp_rec.routing_sequence_id)) ;
               END IF ;

               /************************************************************
               --
               -- Default User_Labor_Time
               --
               ************************************************************/

                IF l_com_operation_rec.user_labor_time IS NULL OR
                   l_com_operation_rec.user_labor_time = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.user_labor_time := Get_User_Labor_Time ;
                END IF ;


               /************************************************************
               --
               -- Default User_Machine_Time
               --
               ************************************************************/

                IF l_com_operation_rec.user_machine_time IS NULL OR
                   l_com_operation_rec.user_machine_time = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.user_machine_time := Get_User_Machine_Time ;
                END IF ;


               /************************************************************
               --
               -- Default User_Elapsed_Time
               --
               -- Defaulting User_Elapsed Time is moved to Entity Defaulting
                IF l_com_operation_rec.user_elapsed_time IS NULL OR
                   l_com_operation_rec.user_elapsed_time = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.user_elapsed_time :=
                      Get_User_Elapsed_Time ;
                END IF ;
               ************************************************************/
            END IF ;


            -- Removed condition for Bug1744254
            -- Include_In_Rollup and Op_Yield_Enabled_Flag are not
            -- only for Lot Based Routing

            -- Check if the parent routing is Lot Based Routing
            -- IF    BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_LOT_RTG
            -- THEN

            --   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            --    ('Attr. Defaulting for Lot Based Routing...' || to_char(l_com_op_unexp_rec.routing_sequence_id)) ;
            --   END IF ;

               /************************************************************
               --
               -- Default Include_In_Rollup
               --
               ************************************************************/

                IF l_com_operation_rec.include_in_rollup IS NULL OR
                   l_com_operation_rec.include_in_rollup = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.include_in_rollup := Get_Include_In_Rollup ;
                END IF ;


               /************************************************************
               --
               -- Default Op_Yield_Enabled_Flag
               --
               ************************************************************/

                IF l_com_operation_rec.op_yield_enabled_flag IS NULL OR
                   l_com_operation_rec.op_yield_enabled_flag = FND_API.G_MISS_NUM
                THEN
                   l_com_operation_rec.op_yield_enabled_flag := Get_Op_Yield_Enabled_Flag ;
                END IF ;

            -- END IF ;


            /*************************************************************
            --
            -- Default Routing_Sequence_Id
            --
            --
            **************************************************************/

            IF l_com_op_unexp_rec.routing_sequence_id IS NULL
               AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
               AND l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               AND l_com_operation_rec.acd_type = 1 -- Add
            THEN
                l_com_op_unexp_rec.routing_sequence_id :=
                Get_Routing_Sequence_Id
                  (  p_revised_item_id        => l_com_op_unexp_rec.revised_item_id
                   , p_organization_id        => l_com_op_unexp_rec.organization_id
                   , p_alternate_routing_code => l_com_operation_rec.alternate_routing_code) ;


               IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                ('Generated Routing_Sequence_Id...' || to_char(l_com_op_unexp_rec.routing_sequence_id)) ;
               END IF ;
            END IF ;


            /***********************************************************
            --
            -- Default Old_Operation_Sequence_Number
            --
            ***********************************************************/
            IF ( BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
               )
               AND (  l_com_operation_rec.old_operation_sequence_number IS NULL
                   OR l_com_operation_rec.old_operation_sequence_number =  FND_API.G_MISS_NUM
                  )
               AND l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               AND l_com_operation_rec.acd_type IN (2,3 )  -- Add
            THEN
               l_com_operation_rec.old_operation_sequence_number :=
                   l_com_operation_rec.operation_sequence_number ;
            END IF ;
/* Added for Bug 3117219  */

          IF  BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
            AND l_com_operation_rec.disable_date is NULL
             AND l_com_operation_rec.acd_type = 3 then

              l_com_operation_rec.disable_date :=
                                    l_com_operation_rec.start_effective_date;


          END IF;
/* end of Bug 3117219 */
            /*************************************************************
            --
            -- Default Old_Operation_Sequence_Id
            --
            --
            **************************************************************/

            IF (l_com_op_unexp_rec.old_operation_sequence_id IS NULL
                OR l_com_op_unexp_rec.old_operation_sequence_id = FND_API.G_MISS_NUM)
               AND BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
               AND l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               AND l_com_operation_rec.acd_type = 1 -- Add
            THEN
                l_com_op_unexp_rec.old_operation_sequence_id :=  l_com_op_unexp_rec.operation_sequence_id ;

               IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                ('Set current op seq id to old op seq id as default value.')  ;
               END IF ;
            END IF ;

            /************************************************************
            --
            -- Default Operation Sequence's FlexFields
            --
            ************************************************************/

            IF  l_com_operation_rec.attribute_category = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute1  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute2  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute3  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute4  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute5  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute6  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute7  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute8  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute9  = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute10 = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute11 = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute12 = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute13 = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute14 = FND_API.G_MISS_CHAR
            OR  l_com_operation_rec.attribute15 = FND_API.G_MISS_CHAR
            THEN

                Get_Flex_Op_Seq(  p_com_operation_rec => l_com_operation_rec
                                , x_com_operation_rec => l_com_operation_rec ) ;

            END IF;

        x_com_operation_rec := l_com_operation_rec ;
        x_com_op_unexp_rec  := l_com_op_unexp_rec ;
        x_return_status     := l_return_status ;
        x_mesg_token_tbl    := l_mesg_token_tbl ;

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
         Error_Handler.Write_Debug('Getting out of Operation Attribute Defualting...');
        END IF ;


    EXCEPTION
       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Attribute Defaulting . . .' || SQLERRM );
          END IF ;


          l_err_text := G_PKG_NAME || ' Default (Attr. Defaulting) '
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


    END Attribute_Defaulting ;



    /******************************************************************
    * Procedure : Populate_Null_Columns used by Rtg BO(Update or Delete)
    * Parameters IN : Operation exposed column record
    *                 Operation unexposed column record
    *                 Old Operation exposed column record
    *                 Old Operation unexposed column record
    * Parameters out: Operation exposed column record after populating null columns
    *                 Operation unexposed column record after populating null columns
    * Purpose   : Convert Routing Operation to Common Operation and
    *             Call Populate_Null_Columns for Common.
    *             The procedure will populate the NULL columns from the record that
    *             is queried from the database.
    ********************************************************************/
    PROCEDURE Populate_Null_Columns
    (  p_operation_rec          IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec           IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , p_old_operation_rec      IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_old_op_unexp_rec       IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec          IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec           IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
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

        --
        -- Once the record transfer is done call the common
        -- operation populate null columns
        --
        Bom_Default_Op_Seq.Populate_Null_Columns
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_old_com_operation_rec => l_old_com_operation_rec
         , p_old_com_op_unexp_rec  => l_old_com_op_unexp_rec
         , x_com_operation_rec     => l_com_operation_rec
         , x_com_op_unexp_rec      => l_com_op_unexp_rec
        ) ;

        --
        -- On return from the populate null columns, save the defaulted
        -- record back in the RTG BO's records
        --

        -- Convert the Common record to Routing Record
        Bom_Rtg_Pub.Convert_ComOp_To_RtgOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rtg_operation_rec      => x_operation_rec
         , x_rtg_op_unexp_rec       => x_op_unexp_rec
         ) ;

    END Populate_Null_Columns;




    /******************************************************************
    * Procedure : Populate_Null_Columns used
    *            used by ECO BO(Update, Delete or Create with ACD_Type:2 Change)
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    *                 Old Revised Operation exposed column record
    *                 Old Revised Operation unexposed column record
    * Parameters out: Revised Operation exposed column record after
    *                 populating null columns
    *                 Revised Operation unexposed column record after
    *                 populating null columns
    * Purpose   : Convert Revised Operation to Common Operation and
    *             Call Populate_Null_Columns for Common.
    *             The procedure will populate the NULL columns from the record that
    *             is queried from the database.
    ********************************************************************/
    PROCEDURE Populate_Null_Columns
    (  p_rev_operation_rec      IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec       IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_old_rev_operation_rec  IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_old_rev_op_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_rev_operation_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type )
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


        --
        -- Once the record transfer is done call the
        -- common operation populate null columns
        --
        Bom_Default_Op_Seq.Populate_Null_Columns
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_old_com_operation_rec => l_old_com_operation_rec
         , p_old_com_op_unexp_rec  => l_old_com_op_unexp_rec
         , x_com_operation_rec     => l_com_operation_rec
         , x_com_op_unexp_rec      => l_com_op_unexp_rec
        ) ;

        --
        -- On return from the populate null columns, save the defaulted
        -- record back in the RTG BO's records
        --

        -- Convert the Common record to Revised Operation record
        Bom_Rtg_Pub.Convert_ComOp_To_EcoOp
        (  p_com_operation_rec      => l_com_operation_rec
         , p_com_op_unexp_rec       => l_com_op_unexp_rec
         , x_rev_operation_rec      => x_rev_operation_rec
         , x_rev_op_unexp_rec       => x_rev_op_unexp_rec
         ) ;

    END Populate_Null_Columns;


    /*******************************************************************
    * Procedure : Populate_Null_Columns for Common
    *             and internally called by RTG BO and ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    *                 Old Common Operation exposed column record
    *                 Old Common Operation unexposed column record
    * Parameters out: Common Operation exposed column record after populating null columns
    *                 Common Operation unexposed column record after populating null columns
    * Purpose   : Complete record will compare the database record with
    *             the user given record and will complete the user
    *             record with values from the database record, for all
    *             columns that the user has left NULL.
    ********************************************************************/
    PROCEDURE Populate_Null_Columns
    (  p_com_operation_rec      IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec       IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_old_com_operation_rec  IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_old_com_op_unexp_rec   IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_com_operation_rec      IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
    )
    IS

       l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
       l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

    BEGIN
            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                 ('Within the Rev. Operation Populate null columns...') ;
            END IF ;

            --  Initialize operation exp and unexp record
            l_com_operation_rec  := p_com_operation_rec ;
            l_com_op_unexp_rec   := p_com_op_unexp_rec ;


            -- Exposed Column
            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                 ('Populate null exposed columns......') ;
            END IF ;

            IF l_com_operation_rec.operation_type IN (l_PROCESS, l_LINE_OP)
            THEN
               l_com_operation_rec.start_effective_date
               := p_old_com_operation_rec.start_effective_date ;
            END IF ;

            IF l_com_operation_rec.ACD_Type IS NULL
            THEN
               l_com_operation_rec.ACD_Type
               := p_old_com_operation_rec.ACD_Type ;
            END IF ;

            IF l_com_operation_rec.Op_Lead_Time_Percent IS NULL
            THEN
               l_com_operation_rec.Op_Lead_Time_Percent
               := p_old_com_operation_rec.Op_Lead_Time_Percent ;
            END IF ;

            IF l_com_operation_rec.Minimum_Transfer_Quantity IS NULL
            THEN
               l_com_operation_rec.Minimum_Transfer_Quantity
               := p_old_com_operation_rec.Minimum_Transfer_Quantity ;
            END IF ;


            IF l_com_operation_rec.Count_Point_Type IS NULL
            THEN
               l_com_operation_rec.Count_Point_Type
               := p_old_com_operation_rec.Count_Point_Type ;
            END IF;

            IF l_com_operation_rec.Operation_Description IS NULL
            THEN
               l_com_operation_rec.Operation_Description
               := p_old_com_operation_rec.Operation_Description ;
            END IF ;

            IF l_com_operation_rec.Disable_Date IS NULL
            THEN
               l_com_operation_rec.Disable_Date
               := p_old_com_operation_rec.Disable_Date ;
            END IF ;

            IF l_com_operation_rec.Backflush_Flag IS NULL
            THEN
               l_com_operation_rec.Backflush_Flag
               := p_old_com_operation_rec.Backflush_Flag ;
            END IF ;

            IF l_com_operation_rec.Option_Dependent_Flag IS NULL
            THEN
               l_com_operation_rec.Option_Dependent_Flag
               := p_old_com_operation_rec.Option_Dependent_Flag ;
            END IF ;

            IF l_com_operation_rec.Reference_Flag IS NULL
            THEN
               l_com_operation_rec.Reference_Flag
               := p_old_com_operation_rec.Reference_Flag ;
            END IF ;

            IF l_com_operation_rec.Yield IS NULL
            THEN
               l_com_operation_rec.Yield
               := p_old_com_operation_rec.Yield ;
            END IF ;

            IF l_com_operation_rec.Cumulative_Yield IS NULL
            THEN
               l_com_operation_rec.Cumulative_Yield
               := p_old_com_operation_rec.Cumulative_Yield ;
            END IF ;

            IF l_com_operation_rec.Reverse_CUM_Yield IS NULL
            THEN
               l_com_operation_rec.Reverse_CUM_Yield
               := p_old_com_operation_rec.Reverse_CUM_Yield ;
            END IF ;


            /* Comment out calculated op times columns and
            -- User Elapsed Time.

            IF l_com_operation_rec.Calculated_Labor_Time IS NULL
            THEN
               l_com_operation_rec.Calculated_Labor_Time
               := p_old_com_operation_rec.Calculated_Labor_Time ;
            END IF ;

            IF l_com_operation_rec.Calculated_Machine_Time IS NULL
            THEN
               l_com_operation_rec.Calculated_Machine_Time
               := p_old_com_operation_rec.Calculated_Machine_Time ;
            END IF ;

            IF l_com_operation_rec.Calculated_Elapsed_Time IS NULL
            THEN
               l_com_operation_rec.Calculated_Elapsed_Time
               := p_old_com_operation_rec.Calculated_Elapsed_Time ;
            END IF ;
            */

            IF l_com_operation_rec.User_Labor_Time IS NULL
            THEN
               l_com_operation_rec.User_Labor_Time
               := p_old_com_operation_rec.User_Labor_Time ;
            END IF ;

            IF l_com_operation_rec.User_Machine_Time IS NULL
            THEN
               l_com_operation_rec.User_Machine_Time
               := p_old_com_operation_rec.User_Machine_Time ;
            END IF ;

            IF l_com_operation_rec.Net_Planning_Percent IS NULL
            THEN
               l_com_operation_rec.Net_Planning_Percent
               := p_old_com_operation_rec.Net_Planning_Percent ;
            END IF ;


            IF l_com_operation_rec.Include_In_Rollup IS NULL
            THEN
               l_com_operation_rec.Include_In_Rollup
               := p_old_com_operation_rec.Include_In_Rollup ;
            END IF ;

            IF l_com_operation_rec.Op_Yield_Enabled_Flag IS NULL
            THEN
               l_com_operation_rec.Op_Yield_Enabled_Flag
               := p_old_com_operation_rec.Op_Yield_Enabled_Flag ;
            END IF ;

            -- Added by MK on 04/10/2001 for eAM changes
            IF l_com_operation_rec.Shutdown_Type IS NULL
            THEN
               l_com_operation_rec.Shutdown_Type
               := p_old_com_operation_rec.Shutdown_Type ;
            END IF ;

            -- Added for long description (Bug 2689249)
	    IF l_com_operation_rec.long_description IS NULL
            THEN
               l_com_operation_rec.long_description
               := p_old_com_operation_rec.long_description ;
            END IF ;


            -- Populate Null Columns for FlexFields
            IF l_com_operation_rec.attribute_category IS NULL THEN
                l_com_operation_rec.attribute_category :=
                p_old_com_operation_rec.attribute_category;
            END IF;

            IF l_com_operation_rec.attribute1 IS NULL THEN
                l_com_operation_rec.attribute1 :=
                p_old_com_operation_rec.attribute1;
            END IF;

            IF l_com_operation_rec.attribute2  IS NULL THEN
                l_com_operation_rec.attribute2 :=
                p_old_com_operation_rec.attribute2;
            END IF;

            IF l_com_operation_rec.attribute3 IS NULL THEN
                l_com_operation_rec.attribute3 :=
                p_old_com_operation_rec.attribute3;
            END IF;

            IF l_com_operation_rec.attribute4 IS NULL THEN
                l_com_operation_rec.attribute4 :=
                p_old_com_operation_rec.attribute4;
            END IF;

            IF l_com_operation_rec.attribute5 IS NULL THEN
                l_com_operation_rec.attribute5 :=
                p_old_com_operation_rec.attribute5;
            END IF;

            IF l_com_operation_rec.attribute6 IS NULL THEN
                l_com_operation_rec.attribute6 :=
                p_old_com_operation_rec.attribute6;
            END IF;

            IF l_com_operation_rec.attribute7 IS NULL THEN
                l_com_operation_rec.attribute7 :=
                p_old_com_operation_rec.attribute7;
            END IF;

            IF l_com_operation_rec.attribute8 IS NULL THEN
                l_com_operation_rec.attribute8 :=
                p_old_com_operation_rec.attribute8;
            END IF;

            IF l_com_operation_rec.attribute9 IS NULL THEN
                l_com_operation_rec.attribute9 :=
                p_old_com_operation_rec.attribute9;
            END IF;

            IF l_com_operation_rec.attribute10 IS NULL THEN
                l_com_operation_rec.attribute10 :=
                p_old_com_operation_rec.attribute10;
            END IF;

            IF l_com_operation_rec.attribute11 IS NULL THEN
                l_com_operation_rec.attribute11 :=
                p_old_com_operation_rec.attribute11;
            END IF;

            IF l_com_operation_rec.attribute12 IS NULL THEN
                l_com_operation_rec.attribute12 :=
                p_old_com_operation_rec.attribute12;
            END IF;

            IF l_com_operation_rec.attribute13 IS NULL THEN
                l_com_operation_rec.attribute13 :=
                p_old_com_operation_rec.attribute13;
            END IF;

            IF l_com_operation_rec.attribute14 IS NULL THEN
                l_com_operation_rec.attribute14 :=
                p_old_com_operation_rec.attribute14;
            END IF;

            IF l_com_operation_rec.attribute15 IS NULL THEN
                l_com_operation_rec.attribute15 :=
                p_old_com_operation_rec.attribute15;
            END IF;


            --
            -- Also copy the Unexposed Columns from Database to New record
            --
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Populate Null Unexposed columns......') ;
       END IF ;


           IF l_com_operation_rec.transaction_type <> BOM_Rtg_Globals.G_OPR_CREATE
           THEN

              l_com_op_unexp_rec.Revised_Item_Sequence_Id
              := p_old_com_op_unexp_rec.Revised_Item_Sequence_Id ;

              l_com_op_unexp_rec.Operation_Sequence_Id
              := p_old_com_op_unexp_rec.Operation_Sequence_Id ;

              l_com_op_unexp_rec.Old_Operation_Sequence_Id
              := p_old_com_op_unexp_rec.Old_Operation_Sequence_Id ;


              IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Op Seq: ' ||
                 to_char(l_com_op_unexp_rec.operation_sequence_id)) ;
              END IF ;

           ELSIF l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
           THEN
              /***********************************************************
              --
              -- Default Operation_Sequence_Id
              --
              ***********************************************************/
              IF l_com_op_unexp_rec.operation_sequence_id IS NULL OR
                 l_com_op_unexp_rec.operation_sequence_id = FND_API.G_MISS_NUM
              THEN
                  l_com_op_unexp_rec.operation_sequence_id :=
                  Get_Operation_Sequence_Id ;
              END IF ;
           END IF;


           IF l_com_op_unexp_rec.Standard_Operation_Id IS NULL OR
              l_com_op_unexp_rec.Standard_Operation_Id = FND_API.G_MISS_NUM

           THEN
              l_com_op_unexp_rec.Standard_Operation_Id
              := p_old_com_op_unexp_rec.Standard_Operation_Id ;
           END IF ;

           IF l_com_op_unexp_rec.Department_Id IS NULL OR
              l_com_op_unexp_rec.Department_Id = FND_API.G_MISS_NUM
           THEN
              l_com_op_unexp_rec.Department_Id
              := p_old_com_op_unexp_rec.Department_Id ;
           END IF ;

           IF l_com_op_unexp_rec.Process_Op_Seq_Id IS NULL OR
              l_com_op_unexp_rec.Process_Op_Seq_Id = FND_API.G_MISS_NUM
           THEN
              l_com_op_unexp_rec.Process_Op_Seq_Id
              := p_old_com_op_unexp_rec.Process_Op_Seq_Id ;
           END IF ;

           IF l_com_op_unexp_rec.Line_Op_Seq_Id IS NULL OR
              l_com_op_unexp_rec.Line_Op_Seq_Id = FND_API.G_MISS_NUM
           THEN
              l_com_op_unexp_rec.Line_Op_Seq_Id
              := p_old_com_op_unexp_rec.Line_Op_Seq_Id ;
           END IF ;


           IF l_com_op_unexp_rec.User_Elapsed_Time IS NULL OR
              l_com_op_unexp_rec.Line_Op_Seq_Id = FND_API.G_MISS_NUM
           THEN
               l_com_op_unexp_rec.User_Elapsed_Time
               := p_old_com_op_unexp_rec.User_Elapsed_Time ;
           END IF ;


           /***********************************************************
           -- Rev Op:  Trans Type : CREATE
           --          Acd Type - Change , Disable
           --          Old Op's Reference Flag - Yes
           -- Default  Old Operatio's Std Op Attrributes
           ***********************************************************/
           IF   l_com_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
           AND  p_old_com_operation_rec.Reference_Flag = 1 -- Yes
           THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Set Op attr. of old operation to current rev op. . .') ;
END IF ;
                l_com_op_unexp_rec.department_id
                := p_old_com_op_unexp_rec.department_id ;
                l_com_operation_rec.minimum_transfer_quantity
                := p_old_com_operation_rec.minimum_transfer_quantity;
                l_com_operation_rec.count_point_type
                := p_old_com_operation_rec.count_point_type ;
                l_com_operation_rec.operation_description
                := p_old_com_operation_rec.operation_description ;
                l_com_operation_rec.option_dependent_flag
                := p_old_com_operation_rec.option_dependent_flag ;
                l_com_operation_rec.attribute_category
                := p_old_com_operation_rec.attribute_category ;
                l_com_operation_rec.attribute1
                := p_old_com_operation_rec.attribute1 ;
                l_com_operation_rec.attribute2
                := p_old_com_operation_rec.attribute2 ;
                l_com_operation_rec.attribute3
                := p_old_com_operation_rec.attribute3 ;
                l_com_operation_rec.attribute4
                := p_old_com_operation_rec.attribute4 ;
                l_com_operation_rec.attribute5
                := p_old_com_operation_rec.attribute5 ;
                l_com_operation_rec.attribute6
                := p_old_com_operation_rec.attribute6 ;
                l_com_operation_rec.attribute7
                := p_old_com_operation_rec.attribute7 ;
                l_com_operation_rec.attribute8
                := p_old_com_operation_rec.attribute8 ;
                l_com_operation_rec.attribute9
                := p_old_com_operation_rec.attribute9 ;
                l_com_operation_rec.attribute10
                := p_old_com_operation_rec.attribute10 ;
                l_com_operation_rec.attribute11
                := p_old_com_operation_rec.attribute11 ;
                l_com_operation_rec.attribute12
                := p_old_com_operation_rec.attribute12 ;
                l_com_operation_rec.attribute13
                := p_old_com_operation_rec.attribute13 ;
                l_com_operation_rec.attribute14
                := p_old_com_operation_rec.attribute14 ;
                l_com_operation_rec.attribute15
                := p_old_com_operation_rec.attribute15 ;
                l_com_operation_rec.backflush_flag
                := p_old_com_operation_rec.backflush_flag;
                l_com_operation_rec.include_in_rollup
                := p_old_com_operation_rec.include_in_rollup;
                l_com_operation_rec.op_yield_enabled_flag
                := p_old_com_operation_rec.op_yield_enabled_flag;


           END IF ;

           --  Return operation exp and unexp record
           x_com_operation_rec  := l_com_operation_rec ;
           x_com_op_unexp_rec   := l_com_op_unexp_rec ;

    END Populate_Null_Columns;


    /*********************************************************************
    * Procedure : Entity_Defaulting by RTG BO
    * Parameters IN : Operation exposed column record
    *                 Operation unexposed column record
    * Parameters out: Operation exposed column record after defaulting
    *                 Operation unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Operation to Common Operation and
    *             Call Entity_Defaulting for Common
    *             This procedure will entity default values in all the operation.
    *             fields that the user has left unfilled.
    **********************************************************************/
    PROCEDURE Entity_Defaulting
    (  p_operation_rec     IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec      IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec     IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status     IN OUT NOCOPY VARCHAR2
    )
    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- The record definition of Revised Operation in ECO BO is
        -- slightly different than the operation definition of RTG BO
        -- So, we will copy the values of RTG BO Record into an Common
        -- BO compatible record before we make a call to the
        -- Entity Defaulting procedure.
        --

        -- Convert Routing Operation to Common Operation
        Bom_Rtg_Pub.Convert_RtgOp_To_ComOp
        (  p_rtg_operation_rec      => p_operation_rec
         , p_rtg_op_unexp_rec       => p_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;


        -- Once the record transfer is done call the
        -- common operation attribute defaulting
        --
        BOM_Default_Op_Seq.Entity_Defaulting
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_Rec => Bom_Rtg_Pub.G_Default_Control_Rec
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

    END Entity_Defaulting ;

    /*********************************************************************
    * Procedure : Entity_Defaulting by ECOBO
    * Parameters IN : Revised Operation exposed column record
    *                 Revised Operation unexposed column record
    * Parameters out: Revised Operation exposed column record after defaulting
    *                 Revised Operation unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Operation to ECO Operation and
    *             Call Entity_Defaulting for ECO BO.
    *             This procedure will entity default values in all the operation.
    *             fields that the user has left unfilled.
    **********************************************************************/
    PROCEDURE Entity_Defaulting
    (  p_rev_operation_rec    IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    )

    IS
        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- The record definition of Revised Operation in ECO BO is
        -- slightly different than the operation definition of RTG BO
        -- So, we will copy the values of RTG BO Record into a common
        -- BO compatible record before we make a call to the
        -- Entity Defaulting procedure.
        --

        -- Convert Revised Operation to Common Operation
        Bom_Rtg_Pub.Convert_EcoOp_To_ComOp
        (  p_rev_operation_rec      => p_rev_operation_rec
         , p_rev_op_unexp_rec       => p_rev_op_unexp_rec
         , x_com_operation_rec      => l_com_operation_rec
         , x_com_op_unexp_rec       => l_com_op_unexp_rec
        ) ;


        -- Once the record transfer is done call the ECO BO's
        -- revised operation attribute defaulting
        --
        BOM_Default_Op_Seq.Entity_Defaulting
        (  p_com_operation_rec     => l_com_operation_rec
         , p_com_op_unexp_rec      => l_com_op_unexp_rec
         , p_control_Rec => Bom_Rtg_Pub.G_Default_Control_Rec
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


    END Entity_Defaulting ;



    /********************************************************************
    * Procedure : Entity_Defaulting for Common
    *               internally called by RTG BO and ECO BO
    * Parameters IN : Common Operation exposed column record
    *                 Common Operation unexposed column record
    * Parameters out: Common Operation exposed column record after defaulting
    *                 Commond Operation unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Entity defaulting proc. defualts columns to
    *             appropriate values. Defualting will happen for
    *             exposed as well as unexposed columns.
    *********************************************************************/
    PROCEDURE Entity_Defaulting
    (  p_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec     IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_com_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    )

    IS

        l_com_operation_rec      Bom_Rtg_Pub.Com_Operation_Rec_Type ;
        l_com_op_unexp_rec       Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;


    BEGIN

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Rev. Operation Entity Defaulting...') ;
        END IF ;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        --  Initialize operation exp and unexp record
        l_com_operation_rec  := p_com_operation_rec ;
        l_com_op_unexp_rec   := p_com_op_unexp_rec ;

        IF  BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO
        THEN
           l_com_operation_rec.new_start_effective_date := NULL ;
        END IF ;

        IF l_com_operation_rec.alternate_routing_code = FND_API.G_MISS_CHAR
        THEN
            l_com_operation_rec.alternate_routing_code := NULL ;
        END IF ;

        IF ( BOM_Rtg_Globals.Get_CFM_Rtg_Flag <>  BOM_Rtg_Globals.G_FLOW_RTG
            OR  BOM_Rtg_Globals.Get_Bo_Identifier = BOM_Rtg_Globals.G_ECO_BO)
        AND (l_com_operation_rec.operation_type = NULL OR
            l_com_operation_rec.operation_type = FND_API.G_MISS_NUM )
        THEN
           l_com_operation_rec.operation_type := l_EVENT ;
        END IF ;


        IF l_com_operation_rec.User_Labor_Time = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.User_Labor_Time := NULL ;
        END IF ;

        IF l_com_operation_rec.User_Machine_Time = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.User_Machine_Time := NULL ;
        END IF ;

        -- Set User Elapsed Time
        l_com_op_unexp_rec.User_Elapsed_Time :=
             Get_User_Elapsed_Time
             (  p_user_labor_time   => l_com_operation_rec.User_Labor_Time
              , p_user_machine_time => l_com_operation_rec.User_Machine_Time
             ) ;

        -- Set missing column values to Null
        IF l_com_op_unexp_rec.department_id = FND_API.G_MISS_NUM
        THEN
           l_com_op_unexp_rec.department_id := NULL ;
        END IF;

        IF l_com_op_unexp_rec.standard_operation_id = FND_API.G_MISS_NUM
        THEN
           l_com_op_unexp_rec.standard_operation_id := NULL ;
        END IF;

        IF (l_com_operation_rec.Process_Seq_Number  = FND_API.G_MISS_NUM
            AND l_com_operation_rec.Process_Code = FND_API.G_MISS_CHAR )
        OR  l_com_op_unexp_rec.process_op_seq_id = FND_API.G_MISS_NUM
        THEN
               l_com_op_unexp_rec.process_op_seq_id := NULL ;
        END IF ;

        IF (l_com_operation_rec.Line_Op_Seq_Number  = FND_API.G_MISS_NUM
            AND l_com_operation_rec.Line_Op_Code = FND_API.G_MISS_CHAR)
        OR l_com_op_unexp_rec.line_op_seq_id = FND_API.G_MISS_NUM
        THEN
               l_com_op_unexp_rec.line_op_seq_id := NULL ;
        END IF ;

        IF l_com_operation_rec.new_operation_sequence_number = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.new_operation_sequence_number := NULL ;
        END IF ;

        IF l_com_operation_rec.new_start_effective_date = FND_API.G_MISS_DATE
        THEN
               l_com_operation_rec.new_start_effective_date := NULL ;
        END IF ;

        IF l_com_operation_rec.Disable_Date = FND_API.G_MISS_DATE
        THEN
               l_com_operation_rec.Disable_Date := NULL ;
        END IF ;

        IF l_com_operation_rec.Op_Lead_Time_Percent = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Op_Lead_Time_Percent := NULL ;
        END IF ;

        IF l_com_operation_rec.Minimum_Transfer_Quantity = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Minimum_Transfer_Quantity := NULL ;
        END IF ;

        IF l_com_operation_rec.Operation_Description = FND_API.G_MISS_CHAR
        THEN
               l_com_operation_rec.Operation_Description := NULL ;
        END IF ;

        IF l_com_operation_rec.Yield = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Yield := NULL ;
        END IF ;

        IF l_com_operation_rec.Cumulative_Yield = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Cumulative_Yield := NULL ;
        END IF ;

        IF l_com_operation_rec.Reverse_CUM_Yield = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Reverse_CUM_Yield := NULL ;
        END IF ;

        /* Following calc op times columns no longer used
        IF l_com_operation_rec.Calculated_Labor_Time = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Calculated_Labor_Time := NULL ;
        END IF ;

        IF l_com_operation_rec.Calculated_Machine_Time = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Calculated_Machine_Time := NULL ;
        END IF ;

        IF l_com_operation_rec.Calculated_Elapsed_Time = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Calculated_Elapsed_Time := NULL ;
        END IF ;
        */


        IF l_com_operation_rec.Net_Planning_Percent = FND_API.G_MISS_NUM
        THEN
               l_com_operation_rec.Net_Planning_Percent := NULL ;
        END IF ;

        IF l_com_operation_rec.original_system_reference = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.original_system_reference := NULL ;
        END IF;

        -- Added by MK on 04/10/2001 for eAM changes
        IF l_com_operation_rec.Shutdown_Type = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.Shutdown_Type := NULL ;
        END IF;

        -- Added for long description (Bug 2689249)
	IF l_com_operation_rec.long_description = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.long_description := NULL ;
        END IF;


        -- FlexFields
        IF l_com_operation_rec.attribute_category = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute_category := NULL ;
        END IF;

        IF l_com_operation_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute1 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute2  = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute2 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute3 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute4 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute5 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute6 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute7 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute8 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute9 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute10 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute11 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute12 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute13 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute14 := NULL ;
        END IF;

        IF l_com_operation_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                l_com_operation_rec.attribute15 := NULL ;
        END IF;

        -- Return the status and message table.
        x_return_status  := l_return_status ;
        x_mesg_token_tbl := l_mesg_token_tbl ;

        -- Return the common operation records after entity defaulting.
        x_com_operation_rec  := l_com_operation_rec ;
        x_com_op_unexp_rec   := l_com_op_unexp_rec ;


    EXCEPTION
       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Entity Defaulting . . .' || SQLERRM );
          END IF ;


          l_err_text := G_PKG_NAME || ' Defaulting (Entity Defaulting) '
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

    END Entity_Defaulting ;



END BOM_Default_Op_Seq ;

/
