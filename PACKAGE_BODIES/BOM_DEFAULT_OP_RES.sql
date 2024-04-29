--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_OP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_OP_RES" AS
/* $Header: BOMDRESB.pls 120.3.12010000.2 2008/11/14 16:14:11 snandana ship $ */

/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMDRESS.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Op_Res
--
--  NOTES
--
--  HISTORY
--
--  18-AUG-00 Masanori Kimizuka Initial Creation
--
****************************************************************************/

        G_Pkg_Name      VARCHAR2(30)    := 'BOM_Default_Op_Res';
        l_ACD_ADD       CONSTANT NUMBER := 1 ;

    /*******************************************************************
    * Following are all get functions which will be used by the attribute
    * defaulting procedure. Each column needing to be defaulted has one GET
    * function.
    ********************************************************************/

    -- Assigned_Units
    FUNCTION Get_Assigned_Units
    RETURN NUMBER
    IS
    BEGIN

            RETURN 1 ;   -- Return 1 unit

    END Get_Assigned_Units ;


    -- Schedule_Flag
    FUNCTION Get_Schedule_Flag
    RETURN NUMBER
    IS
    BEGIN

            RETURN 2 ;   -- Return No: 2

    END Get_Schedule_Flag ;


    -- Principle_Flag
    FUNCTION Get_Principle_Flag
    RETURN NUMBER
    IS
    BEGIN

            RETURN 2 ;   -- Return No: 2

    END Get_Principle_Flag ;


    -- Get Flex Operation Resource
    PROCEDURE Get_Flex_Op_Res
    (  p_rev_op_resource_rec    IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
    )
    IS
        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec       Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    BEGIN
       --  Initialize operation exp and unexp record
       l_rev_op_resource_rec  := p_rev_op_resource_rec ;

        --  In the future call Flex APIs for defaults

        IF l_rev_op_resource_rec.attribute_category = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute_category := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute1 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute1 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute2 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute2 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute3 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute3 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute4 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute4 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute5 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute5 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute6 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute6 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute7 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute7 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute8 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute8 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute9 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute9 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute10 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute10 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute11 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute11 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute12 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute12 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute13 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute13 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute14 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute14 := NULL;
        END IF;

        IF l_rev_op_resource_rec.attribute15 = FND_API.G_MISS_CHAR THEN
            l_rev_op_resource_rec.attribute15 := NULL;
        END IF;

        x_rev_op_resource_rec := l_rev_op_resource_rec ;

    END Get_Flex_Op_Res ;



    -- Get Usage Rate or Amount
    PROCEDURE  Get_Usage_Rate_Or_Amount
             ( p_usage_rate_or_amount         IN  NUMBER
             , p_usage_rate_or_amount_inverse IN  NUMBER
             , x_usage_rate_or_amount         IN OUT NOCOPY NUMBER
             , x_usage_rate_or_amount_inverse IN OUT NOCOPY NUMBER
             )
    IS
        x_usage         NUMBER := NULL ;
        x_usage_inverse NUMBER := NULL ;

    BEGIN

       IF  (   ( NVL(p_usage_rate_or_amount, FND_API.G_MISS_NUM)
                     = FND_API.G_MISS_NUM )
           AND ( NVL(p_usage_rate_or_amount_inverse, FND_API.G_MISS_NUM)
                     = FND_API.G_MISS_NUM)
           )
       THEN
          x_usage_rate_or_amount := 1 ;
          x_usage_rate_or_amount_inverse := 1 ;

       ELSIF
          ( p_usage_rate_or_amount_inverse IS NULL )
          OR ((p_usage_rate_or_amount_inverse = FND_API.G_MISS_NUM)
              AND(p_usage_rate_or_amount <> FND_API.G_MISS_NUM)
             )
       THEN
          IF p_usage_rate_or_amount = 0 THEN
             x_usage_rate_or_amount := p_usage_rate_or_amount ;
             x_usage_rate_or_amount_inverse := 0 ;
          ELSE
	     -- BUG 5896587
	     -- In ROUND function the decimal places have increased from 6 to 10 for Usage and Inverse Usage
             /* Bug 7322996 */
             -- In ROUND function the decimal places rounding off value changed with G_round_off_val(profile value)
             x_usage  := ROUND(p_usage_rate_or_amount, G_round_off_val)  ;

             IF x_usage = 0 THEN
                x_usage_rate_or_amount_inverse := 0 ;
             ELSE
                --
                -- Usate Rate or Amound and Inverse 's length is 42 in FORM
                --
                x_usage_rate_or_amount := to_number(SUBSTR(to_char(x_usage), 1, 42)) ;
                x_usage_rate_or_amount_inverse :=  to_number(SUBSTR(to_char(ROUND( 1/x_usage ,G_round_off_val)) , 1, 42))  ;/* Bug 7322996 */
             END IF ;

          END IF ;

       ELSIF
          ( p_usage_rate_or_amount IS NULL )
          OR ((p_usage_rate_or_amount = FND_API.G_MISS_NUM)
              AND(p_usage_rate_or_amount_inverse <> FND_API.G_MISS_NUM )
             )
       THEN
          IF p_usage_rate_or_amount_inverse = 0 THEN
             x_usage_rate_or_amount := 0 ;
             x_usage_rate_or_amount_inverse := p_usage_rate_or_amount_inverse ;
          ELSE
             x_usage_inverse  := ROUND(p_usage_rate_or_amount_inverse ,G_round_off_val)  ;/* Bug 7322996 */

             IF x_usage_inverse = 0 THEN
                x_usage_rate_or_amount := 0 ;
             ELSE
                --
                -- Usate Rate or Amound and Inverse 's length is 42 in FORM
                --
                x_usage_rate_or_amount_inverse :=  to_number(SUBSTR(to_char(x_usage_inverse), 1, 42)) ;
                x_usage_rate_or_amount := to_number( SUBSTR(to_char(ROUND( 1/ x_usage_inverse ,G_round_off_val )), 1, 42 ))  ; /* Bug 7322996 */
             END IF ;
          END IF ;
       ELSE
             x_usage_rate_or_amount := p_usage_rate_or_amount ;
             x_usage_rate_or_amount_inverse :=  p_usage_rate_or_amount_inverse ;
       END IF ;

    END Get_Usage_Rate_Or_Amount ;


    -- Get Resource Attributes
    PROCEDURE  Get_Res_Attributes
               (  p_operation_sequence_id  IN  NUMBER
                , p_resource_id            IN  NUMBER
                , p_activity_id            IN  NUMBER
                , p_autocharge_type        IN  NUMBER
                , p_basis_type             IN  NUMBER
                , p_standard_rate_flag     IN  NUMBER
                , p_org_id                 IN  NUMBER
                , x_activity_id            IN OUT NOCOPY NUMBER
                , x_autocharge_type        IN OUT NOCOPY NUMBER
                , x_basis_type             IN OUT NOCOPY NUMBER
                , x_standard_rate_flag     IN OUT NOCOPY NUMBER
               )
    IS

       CURSOR l_res_attr_csr( p_op_seq_id NUMBER
                            , p_res_id    NUMBER )
       IS
           SELECT  br.default_basis_type
                 , ca.activity_id
                 , DECODE ( bd.location_id,
                               NULL, DECODE(br.AUTOCHARGE_TYPE,
                                            NULL, 2,
                                               3, 2,
                                               br.AUTOCHARGE_TYPE),
                               NVL(br.AUTOCHARGE_TYPE, 2)
                          ) default_autocharge
                 , NVL(br.standard_rate_flag, 1) standard_rate_flag
           FROM    BOM_RESOURCES br
                 , BOM_DEPARTMENTS bd
                 , BOM_OPERATION_SEQUENCES bos
                 , CST_ACTIVITIES_VAL_V    ca
           WHERE   bd.department_id = bos.department_id
           AND     ca.activity_id (+) = br.default_activity_id
           AND     NVL(ca.organization_id, p_org_id) = p_org_id
           AND     br.resource_id = p_resource_id
           AND     bos.operation_sequence_id = p_operation_sequence_id ;



    BEGIN
       FOR l_res_attr_rec IN l_res_attr_csr ( p_op_seq_id => p_operation_sequence_id
                                            , p_res_id    => p_resource_id )
       LOOP
          IF ( p_activity_id IS NULL OR p_activity_id = FND_API.G_MISS_NUM )
          THEN
             x_activity_id := l_res_attr_rec.activity_id ;
          ELSE
             x_activity_id := p_activity_id ;
          END IF ;

          IF p_autocharge_type IS NULL OR p_autocharge_type = FND_API.G_MISS_NUM
          THEN
             x_autocharge_type := l_res_attr_rec.default_autocharge ;
          ELSE
             x_autocharge_type := p_autocharge_type ;
          END IF ;

          IF p_basis_type IS NULL OR p_basis_type = FND_API.G_MISS_NUM
          THEN
             x_basis_type := NVL(l_res_attr_rec.default_basis_type,1) ;
          ELSE
             x_basis_type := p_basis_type ;
          END IF ;

          IF p_standard_rate_flag IS NULL OR p_standard_rate_flag = FND_API.G_MISS_NUM
          THEN

             x_standard_rate_flag := NVL(l_res_attr_rec.standard_rate_flag,1)  ;

          ELSE
             x_standard_rate_flag := p_standard_rate_flag ;

          END IF ;
       END LOOP ;

    END Get_Res_Attributes ;

/*** Added for bug 2683529 ***/
    FUNCTION  Get_Res_Batchable ( p_resource_id IN  NUMBER
                                       ) RETURN NUMBER
    IS
       CURSOR l_res_csr( p_resource_id NUMBER)
       IS
          SELECT   nvl(br.batchable,2) batchable
          FROM     BOM_RESOURCES br
          WHERE  br.resource_id           = p_resource_id;

    BEGIN
       FOR l_res_rec IN l_res_csr (p_resource_id)
       LOOP
          RETURN l_res_rec.batchable;
       END LOOP ;

       RETURN NULL ;

    END Get_Res_Batchable ;

/*** This is not being used anymore ***/
    FUNCTION  Get_Available_24hs_flag ( p_resource_id IN  NUMBER
                                      , p_op_seq_id   IN  NUMBER
                                       ) RETURN NUMBER
    IS


       CURSOR l_deptres_csr( p_resource_id NUMBER
                           , p_op_seq_id   NUMBER
                           )
       IS
          SELECT   bdr.available_24_hours_flag
          FROM     BOM_OPERATION_SEQUENCES  bos
                 , BOM_DEPARTMENT_RESOURCES bdr
          WHERE  bdr.department_id         = bos.department_id
          AND    bdr.resource_id           = p_resource_id
          AND    bos.operation_sequence_id = p_op_seq_id ;

    BEGIN
       FOR l_deptres_rec IN l_deptres_csr ( p_resource_id
                                          , p_op_seq_id   )
       LOOP
          RETURN l_deptres_rec.available_24_hours_flag ;
       END LOOP ;

       RETURN NULL ;

    END Get_Available_24hs_flag ;


    /*********************************************************************
    * Procedure : Attribute_Defaulting by RTG BO
    * Parameters IN : Operation Resource exposed column record
    *                 Operation Resource unexposed column record
    * Parameters OUT: Operation Resource exposed column record after defaulting
    *                 Operation Resource unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Op Resource to ECO Op Resource  and
    *             Call Attribute_Defaulting for ECO Bo
    *             This procedure will default values in all the operation
    *             resource fields that the user has left unfilled.
    **********************************************************************/
    PROCEDURE Attribute_Defaulting
    (  p_op_resource_rec   IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec  IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_op_resource_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_op_res_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status     IN OUT NOCOPY VARCHAR2
    )
    IS
        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Convert Routing Op Resource to ECO Op Resource
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        ) ;


        -- Once the record transfer is done call the common
        -- operation attribute defaulting
        --
        BOM_Default_Op_Res.Attribute_Defaulting
        (  p_rev_op_resource_rec     => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
         , p_control_Rec             => Bom_Rtg_Pub.G_Default_Control_Rec
         , x_rev_op_resource_rec     => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
         , x_return_status           => x_return_status
         , x_mesg_token_tbl          => x_mesg_token_tbl
        ) ;


        -- Convert the Common record to Routing Record
        Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
        (  p_rev_op_resource_rec      => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
         , x_rtg_op_resource_rec      => x_op_resource_rec
         , x_rtg_op_res_unexp_rec     => x_op_res_unexp_rec
         ) ;


    END Attribute_Defaulting ;

    /********************************************************************
    * Procedure : Attribute_Defaulting by ECO BO
    * Parameters IN : Revised Op Resource exposed column record
    *                 Revised Op Resource unexposed column record
    * Parameters OUT: Revised Op Resource exposed column record after defaulting
    *                 Revised Op Resource unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Attribute defaulting proc. defualts columns to
    *             appropriate values. Defualting will happen for
    *             exposed as well as unexposed columns.
    *********************************************************************/
    PROCEDURE Attribute_Defaulting
    (  p_rev_op_resource_rec    IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_control_Rec            IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    )

    IS

        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;


    BEGIN

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Operation Resource Attr. Defaulting...') ;
       END IF ;

       x_return_status := FND_API.G_RET_STS_SUCCESS ;

       --  Initialize operation exp and unexp record
       l_rev_op_resource_rec    := p_rev_op_resource_rec ;
       l_rev_op_res_unexp_rec   := p_rev_op_res_unexp_rec ;


            /***********************************************************
            --
            -- Default Assigned_Units
            --
            ***********************************************************/
            IF l_rev_op_resource_rec.assigned_units IS NULL OR
               l_rev_op_resource_rec.assigned_units = FND_API.G_MISS_NUM
            THEN
                l_rev_op_resource_rec.assigned_units :=
                Get_Assigned_Units ;
            END IF ;



            /*********************************************************
            --
            -- Default Schedule_Flag
            --
            ***********************************************************/

            IF l_rev_op_resource_rec.schedule_flag IS NULL OR
               l_rev_op_resource_rec.schedule_flag =  FND_API.G_MISS_NUM
            THEN
                l_rev_op_resource_rec.schedule_flag :=
                    Get_Schedule_Flag ;
            END IF;

            /************************************************************
            --
            -- Default Principle_Flag
            --
            ************************************************************/

            IF l_rev_op_resource_rec.principle_flag IS NULL OR
               l_rev_op_resource_rec.principle_flag = FND_API.G_MISS_NUM
            THEN
               l_rev_op_resource_rec.principle_flag :=
                    Get_Principle_Flag ;
            END IF;



            /************************************************************
            --
            -- Default Operation Sequence's FlexFields
            --
            ************************************************************/

            IF  l_rev_op_resource_rec.attribute_category = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute1  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute2  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute3  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute4  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute5  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute6  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute7  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute8  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute9  = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute10 = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute11 = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute12 = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute13 = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute14 = FND_API.G_MISS_CHAR
            OR  l_rev_op_resource_rec.attribute15 = FND_API.G_MISS_CHAR
            THEN

                Get_Flex_Op_Res(  p_rev_op_resource_rec => l_rev_op_resource_rec
                                , x_rev_op_resource_rec => l_rev_op_resource_rec ) ;

            END IF;

        x_rev_op_resource_rec  := l_rev_op_resource_rec ;
        x_rev_op_res_unexp_rec := l_rev_op_res_unexp_rec ;

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
         Error_Handler.Write_Debug('Getting out of Operation Resource Attribute Defualting...');
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
    * Parameters IN : Operation Resource exposed column record
    *                 Operation Resource unexposed column record
    *                 Old Operation Resource exposed column record
    *                 Old Operation Resource unexposed column record
    * Parameters OUT: Op Resource exposed column record after
    *                 populating null columns
    *                 Op Resource unexposed column record after
    *                 populating null columns
    * Purpose   : Convert Routing Op Resource to ECO Op Resource and
    *             Call Populate_Null_Columns for ECO BO.
    *             The procedure will populate the NULL columns from the
    *             record that is queried from the database.
    ********************************************************************/
    PROCEDURE Populate_Null_Columns
    (  p_op_resource_rec          IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec         IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , p_old_op_resource_rec      IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_old_op_res_unexp_rec     IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_op_resource_rec          IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_op_res_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
    )

    IS
        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
        l_old_rev_op_resource_rec  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_old_rev_op_res_unexp_rec Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;


    BEGIN

        -- Convert Routing Op Resource to Revised Op Resource
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        ) ;

        -- Also Convert Old Rtg Op Resource to Old Revised Op Resource
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_old_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_old_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_old_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_old_rev_op_res_unexp_rec
        ) ;

        --
        -- Once the record transfer is done call the common
        -- operation populate null columns
        --
        Bom_Default_Op_Res.Populate_Null_Columns
        (  p_rev_op_resource_rec       => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec      => l_rev_op_res_unexp_rec
         , p_old_rev_op_resource_rec   => l_old_rev_op_resource_rec
         , p_old_rev_op_res_unexp_rec  => l_old_rev_op_res_unexp_rec
         , x_rev_op_resource_rec       => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec      => l_rev_op_res_unexp_rec
        ) ;

        --
        -- On return from the populate null columns, save the defaulted
        -- record back in the RTG BO's records
        --

        -- Convert the Common record to Routing Record
        Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
        (  p_rev_op_resource_rec      => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
         , x_rtg_op_resource_rec      => x_op_resource_rec
         , x_rtg_op_res_unexp_rec     => x_op_res_unexp_rec
         ) ;

    END Populate_Null_Columns;


    /******************************************************************
    * Procedure : Populate_Null_Columns used
    *            used by ECO BO(Update, Delete or Create with ACD_Type:2 Change)
    * Parameters IN : Revised Op Resource exposed column record
    *                 Revised Op Resource unexposed column record
    *                 Old Revised Op Resource exposed column record
    *                 Old Revised Op Resource unexposed column record
    * Parameters OUT: Revised Op Resource exposed column record
    *                 after populating null columns
    *                 Revised Op Resource unexposed column record
    *                 after populating null columns
    * Purpose   : Complete record will compare the database record with
    *             the user given record and will complete the user
    *             record with values from the database record, for all
    *             columns that the user has left NULL.
    ********************************************************************/
    PROCEDURE Populate_Null_Columns
    (  p_rev_op_resource_rec      IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_old_rev_op_resource_rec  IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_old_rev_op_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_rev_op_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
    )
    IS

       l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
       l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

    BEGIN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Operation Resource Populate null columns...') ;
       END IF ;

       --  Initialize operation exp and unexp record
       l_rev_op_resource_rec  := p_rev_op_resource_rec ;
       l_rev_op_res_unexp_rec := p_rev_op_res_unexp_rec ;

       -- Exposed Column
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Populate null exposed columns......') ;
       END IF ;

            IF l_rev_op_resource_rec.ACD_Type IS NULL
            THEN
               l_rev_op_resource_rec.ACD_Type
               := p_old_rev_op_resource_rec.ACD_Type ;
            END IF ;

            IF l_rev_op_resource_rec.Resource_Sequence_Number IS NULL
            THEN
               l_rev_op_resource_rec.Resource_Sequence_Number
               := p_old_rev_op_resource_rec.Resource_Sequence_Number ;
            END IF ;

            IF l_rev_op_resource_rec.Standard_Rate_Flag IS NULL
            THEN
               l_rev_op_resource_rec.Standard_Rate_Flag
               := p_old_rev_op_resource_rec.Standard_Rate_Flag ;
            END IF ;


            IF l_rev_op_resource_rec.Assigned_Units IS NULL
            THEN
               l_rev_op_resource_rec.Assigned_Units
               := p_old_rev_op_resource_rec.Assigned_Units ;
            END IF;

            --  Usage Rate and Inverse are not same as others because
            --  of defaulting.
            IF l_rev_op_resource_rec.Usage_Rate_Or_Amount IS NULL AND
               l_rev_op_resource_rec.Usage_Rate_Or_Amount_Inverse IS NULL
            THEN
               l_rev_op_resource_rec.Usage_Rate_Or_Amount
               := p_old_rev_op_resource_rec.Usage_Rate_Or_Amount ;

               l_rev_op_resource_rec.Usage_Rate_Or_Amount_Inverse
               := p_old_rev_op_resource_rec.Usage_Rate_Or_Amount_Inverse ;

            END IF ;


            IF l_rev_op_resource_rec.Basis_Type IS NULL
            THEN
               l_rev_op_resource_rec.Basis_Type
               := p_old_rev_op_resource_rec.Basis_Type ;
            END IF ;

            IF l_rev_op_resource_rec.Schedule_Flag IS NULL
            THEN
               l_rev_op_resource_rec.Schedule_Flag
               := p_old_rev_op_resource_rec.Schedule_Flag ;
            END IF ;

            IF l_rev_op_resource_rec.Resource_Offset_Percent IS NULL
            THEN
               l_rev_op_resource_rec.Resource_Offset_Percent
               := p_old_rev_op_resource_rec.Resource_Offset_Percent ;
            END IF ;

            IF l_rev_op_resource_rec.Autocharge_Type IS NULL
            THEN
               l_rev_op_resource_rec.Autocharge_Type
               := p_old_rev_op_resource_rec.Autocharge_Type ;
            END IF ;

            IF l_rev_op_resource_rec.Schedule_Sequence_Number IS NULL
            THEN
               l_rev_op_resource_rec.Schedule_Sequence_Number
               := p_old_rev_op_resource_rec.Schedule_Sequence_Number ;
            END IF ;

	    IF l_rev_op_resource_rec.Substitute_Group_Number IS NULL
	    THEN
              l_rev_op_resource_rec.Substitute_Group_Number
              := p_old_rev_op_resource_rec.Substitute_Group_Number;
            END IF ;

            IF l_rev_op_resource_rec.Principle_Flag IS NULL
            THEN
               l_rev_op_resource_rec.Principle_Flag
               := p_old_rev_op_resource_rec.Principle_Flag ;
            END IF ;

            -- Populate Null Columns for FlexFields
            IF l_rev_op_resource_rec.attribute_category IS NULL THEN
                l_rev_op_resource_rec.attribute_category :=
                p_old_rev_op_resource_rec.attribute_category;
            END IF;

            IF l_rev_op_resource_rec.attribute1 IS NULL THEN
                l_rev_op_resource_rec.attribute1 :=
                p_old_rev_op_resource_rec.attribute1;
            END IF;

            IF l_rev_op_resource_rec.attribute2  IS NULL THEN
                l_rev_op_resource_rec.attribute2 :=
                p_old_rev_op_resource_rec.attribute2;
            END IF;

            IF l_rev_op_resource_rec.attribute3 IS NULL THEN
                l_rev_op_resource_rec.attribute3 :=
                p_old_rev_op_resource_rec.attribute3;
            END IF;

            IF l_rev_op_resource_rec.attribute4 IS NULL THEN
                l_rev_op_resource_rec.attribute4 :=
                p_old_rev_op_resource_rec.attribute4;
            END IF;

            IF l_rev_op_resource_rec.attribute5 IS NULL THEN
                l_rev_op_resource_rec.attribute5 :=
                p_old_rev_op_resource_rec.attribute5;
            END IF;

            IF l_rev_op_resource_rec.attribute6 IS NULL THEN
                l_rev_op_resource_rec.attribute6 :=
                p_old_rev_op_resource_rec.attribute6;
            END IF;

            IF l_rev_op_resource_rec.attribute7 IS NULL THEN
                l_rev_op_resource_rec.attribute7 :=
                p_old_rev_op_resource_rec.attribute7;
            END IF;

            IF l_rev_op_resource_rec.attribute8 IS NULL THEN
                l_rev_op_resource_rec.attribute8 :=
                p_old_rev_op_resource_rec.attribute8;
            END IF;

            IF l_rev_op_resource_rec.attribute9 IS NULL THEN
                l_rev_op_resource_rec.attribute9 :=
                p_old_rev_op_resource_rec.attribute9;
            END IF;

            IF l_rev_op_resource_rec.attribute10 IS NULL THEN
                l_rev_op_resource_rec.attribute10 :=
                p_old_rev_op_resource_rec.attribute10;
            END IF;

            IF l_rev_op_resource_rec.attribute11 IS NULL THEN
                l_rev_op_resource_rec.attribute11 :=
                p_old_rev_op_resource_rec.attribute11;
            END IF;

            IF l_rev_op_resource_rec.attribute12 IS NULL THEN
                l_rev_op_resource_rec.attribute12 :=
                p_old_rev_op_resource_rec.attribute12;
            END IF;

            IF l_rev_op_resource_rec.attribute13 IS NULL THEN
                l_rev_op_resource_rec.attribute13 :=
                p_old_rev_op_resource_rec.attribute13;
            END IF;

            IF l_rev_op_resource_rec.attribute14 IS NULL THEN
                l_rev_op_resource_rec.attribute14 :=
                p_old_rev_op_resource_rec.attribute14;
            END IF;

            IF l_rev_op_resource_rec.attribute15 IS NULL THEN
                l_rev_op_resource_rec.attribute15 :=
                p_old_rev_op_resource_rec.attribute15;
            END IF;


            --
            -- Also copy the Unexposed Columns from Database to New record
            --


       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Populate Null Unexposed columns......') ;
       END IF ;


           IF l_rev_op_resource_rec.transaction_type <> BOM_Rtg_Globals.G_OPR_CREATE
           THEN

              l_rev_op_res_unexp_rec.Revised_Item_Sequence_Id
              := p_old_rev_op_res_unexp_rec.Revised_Item_Sequence_Id ;

              l_rev_op_res_unexp_rec.Operation_Sequence_Id
              := p_old_rev_op_res_unexp_rec.Operation_Sequence_Id ;

           END IF;


           IF l_rev_op_resource_rec.Substitute_Group_Number IS NULL
              OR l_rev_op_resource_rec.Substitute_Group_Number = FND_API.G_MISS_NUM
           THEN
              l_rev_op_resource_rec.Substitute_Group_Number
              := p_old_rev_op_resource_rec.Substitute_Group_Number ;
           END IF ;
              l_rev_op_res_unexp_rec.Substitute_Group_Number := l_rev_op_resource_rec.Substitute_Group_Number;

           IF l_rev_op_res_unexp_rec.Resource_Id IS NULL
              OR l_rev_op_res_unexp_rec.Resource_Id = FND_API.G_MISS_NUM
           THEN
              l_rev_op_res_unexp_rec.Resource_Id
              := p_old_rev_op_res_unexp_rec.Resource_Id ;
           END IF ;

           IF l_rev_op_res_unexp_rec.Activity_Id IS NULL
              OR l_rev_op_res_unexp_rec.Activity_Id = FND_API.G_MISS_NUM
           THEN
              l_rev_op_res_unexp_rec.Activity_Id
              := p_old_rev_op_res_unexp_rec.Activity_Id ;
           END IF ;


           IF l_rev_op_res_unexp_rec.Setup_Id IS NULL
              OR l_rev_op_res_unexp_rec.Setup_Id = FND_API.G_MISS_NUM
           THEN
              l_rev_op_res_unexp_rec.Setup_Id
              := p_old_rev_op_res_unexp_rec.Setup_Id ;
           END IF ;


           --  Return rev operation resource exp and unexp record
           x_rev_op_resource_rec  := l_rev_op_resource_rec ;
           x_rev_op_res_unexp_rec := l_rev_op_res_unexp_rec ;

    END Populate_Null_Columns;


    /*********************************************************************
    * Procedure : Entity_Defaulting by RTG BO
    * Parameters IN : Operation Resource exposed column record
    *                 Operation Resource unexposed column record
    * Parameters OUT: Operation Resource exposed column record after defaulting
    *                 Operation Resource unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Convert Routing Op Resource to Revised Op Resource and
    *             Call Entity_Defaulting for ECO Bo
    *             This procedure will entity default values in all the op resource.
    *             fields that the user has left unfilled.
    **********************************************************************/
    PROCEDURE Entity_Defaulting
    (  p_op_resource_rec     IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec    IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_op_resource_rec     IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status       IN OUT NOCOPY VARCHAR2
    )
    IS
        l_rev_op_resource_rec      Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec     Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- The record definition of Revised Op Resource in ECO BO is
        -- slightly different than the Op Resource definition of RTG BO
        -- So, we will copy the values of RTG BO Record into an ECO
        -- BO compatible record before we make a call to the
        -- Entity Defaulting procedure.
        --

        -- Convert Routing Op Resource to ECO Op Resource
        Bom_Rtg_Pub.Convert_RtgRes_To_EcoRes
        (  p_rtg_op_resource_rec      => p_op_resource_rec
         , p_rtg_op_res_unexp_rec     => p_op_res_unexp_rec
         , x_rev_op_resource_rec      => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
        ) ;


        -- Once the record transfer is done call the
        -- Revised operation resource entity defaulting
        --
        BOM_Default_Op_Res.Entity_Defaulting
        (  p_rev_op_resource_rec     => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
         , p_control_Rec             => Bom_Rtg_Pub.G_Default_Control_Rec
         , x_rev_op_resource_rec     => l_rev_op_resource_rec
         , x_rev_op_res_unexp_rec    => l_rev_op_res_unexp_rec
         , x_return_status           => x_return_status
         , x_mesg_token_tbl          => x_mesg_token_tbl
        ) ;

        -- Convert the ECO record to Routing Record
        Bom_Rtg_Pub.Convert_EcoRes_To_RtgRes
        (  p_rev_op_resource_rec      => l_rev_op_resource_rec
         , p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
         , x_rtg_op_resource_rec      => x_op_resource_rec
         , x_rtg_op_res_unexp_rec     => x_op_res_unexp_rec
         ) ;

    END Entity_Defaulting ;


    /*********************************************************************
    * Procedure : Entity_Defaulting by ECOBO
    * Parameters IN : Revised Op Resource exposed column record
    *                 Revised Op Resource unexposed column record
    * Parameters OUT: Revised Op Resource exposed column record after defaulting
    *                 Revised Op Resource unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Entity defaulting proc. defualts columns to
    *             appropriate values. Defualting will happen for
    *             exposed as well as unexposed columns.
    **********************************************************************/
    PROCEDURE Entity_Defaulting
    (  p_rev_op_resource_rec    IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_control_Rec            IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    )

    IS
        l_rev_op_resource_rec        Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
        l_rev_op_res_unexp_rec       Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;

        l_return_status VARCHAR2(1);
        l_err_text  VARCHAR2(2000) ;
        l_Token_Tbl         Error_Handler.Token_Tbl_Type ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;

    BEGIN

       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Operation Resource Entity Defaulting...') ;
       END IF ;

       l_return_status := FND_API.G_RET_STS_SUCCESS;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       --  Initialize operation exp and unexp record
       l_rev_op_resource_rec    := p_rev_op_resource_rec ;
       l_rev_op_res_unexp_rec   := p_rev_op_res_unexp_rec ;


            /************************************************************
            --
            -- Default Schedule_Sequence_Number and Substitute_Group_Number
            -- ( Copy from Schedule_Sequence_Number )
            ************************************************************/

            IF l_rev_op_resource_rec.schedule_sequence_number = FND_API.G_MISS_NUM
            THEN
               l_rev_op_resource_rec.schedule_sequence_number := NULL ;
            END IF ;
              l_rev_op_res_unexp_rec.substitute_group_number := l_rev_op_resource_rec.substitute_group_number;

           -- l_rev_op_res_unexp_rec.substitute_group_number
           --            := l_rev_op_resource_rec.schedule_sequence_number ;

            /************************************************************
            --
            -- Default Usage_Rate_Or_Amount and Usage_Rate_Or_Amount_Inverse
            --
            ************************************************************/
            Get_Usage_Rate_Or_Amount
             ( p_usage_rate_or_amount
               => l_rev_op_resource_rec.usage_rate_or_amount
             , p_usage_rate_or_amount_inverse
               => l_rev_op_resource_rec.usage_rate_or_amount_inverse
             , x_usage_rate_or_amount
               => l_rev_op_resource_rec.usage_rate_or_amount
             , x_usage_rate_or_amount_inverse
               => l_rev_op_resource_rec.usage_rate_or_amount_inverse
            ) ;


            /************************************************************
            --
            -- Default Activity_Id,
            --         Autocharge_Type,
            --         Basis_Type,
            --         Standard_Rate_Flag
            --
            ************************************************************/
            IF l_rev_op_resource_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
               AND
               ( l_rev_op_res_unexp_rec.activity_id       IS NULL OR
                 l_rev_op_res_unexp_rec.activity_id       = FND_API.G_MISS_NUM OR
                 l_rev_op_resource_rec.autocharge_type    IS NULL OR
                 l_rev_op_resource_rec.autocharge_type = FND_API.G_MISS_NUM OR
                 l_rev_op_resource_rec.basis_type IS NULL OR
                 l_rev_op_resource_rec.basis_type  = FND_API.G_MISS_NUM OR
                 l_rev_op_resource_rec.standard_rate_flag IS NULL OR
                 l_rev_op_resource_rec.standard_rate_flag  = FND_API.G_MISS_NUM
               )
            THEN
               Get_Res_Attributes
               (  p_operation_sequence_id  => l_rev_op_res_unexp_rec.operation_sequence_id
                , p_resource_id            => l_rev_op_res_unexp_rec.resource_id
                , p_activity_id            => l_rev_op_res_unexp_rec.activity_id
                , p_autocharge_type        => l_rev_op_resource_rec.autocharge_type
                , p_basis_type             => l_rev_op_resource_rec.basis_type
                , p_standard_rate_flag     => l_rev_op_resource_rec.standard_rate_flag
                , p_org_id                 => l_rev_op_res_unexp_rec.organization_id
                , x_activity_id            => l_rev_op_res_unexp_rec.activity_id
                , x_autocharge_type        => l_rev_op_resource_rec.autocharge_type
                , x_basis_type             => l_rev_op_resource_rec.basis_type
                , x_standard_rate_flag     => l_rev_op_resource_rec.standard_rate_flag ) ;

            END IF ;


	    /************************************************************
            --
            -- Default Assigned Units
            --         Check if resource is availabel 24hours.
            --          If so, Assigned Units must be 1.
            --
            --
            ************************************************************/
	    /**** Commenting the following validation as per bug 2661684
            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Default Assigned Units. . . . ' || l_return_status) ;
            END IF ;

            IF   NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_op_resource_rec.assigned_units <> 1
            THEN


               IF Get_Available_24hs_flag
                 ( p_resource_id => l_rev_op_res_unexp_rec.resource_id
                 , p_op_seq_id   => l_rev_op_res_unexp_rec.operation_sequence_id
                 )  = 1  -- Yes
               THEN

                  -- Set Assigned Units to 1
                  l_rev_op_resource_rec.assigned_units := 1 ;


                  l_Token_Tbl(1).token_name  := 'RES_SEQ_NUMBER';
                  l_Token_Tbl(1).token_value :=
                                   p_rev_op_resource_rec.resource_sequence_number ;
                  -- Set Warning Message
                  Error_Handler.Add_Error_Token
                  ( p_message_name   => 'BOM_RES_DEF_ASSGN_UNIT'
                  , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , p_Token_Tbl      => l_Token_Tbl
                  , p_Message_Type   => 'W'
                  ) ;

               END IF ;
            END IF ;
	    End of commenting for bug 2661684 ****/

	    /************************************************************
            --
            -- Check value of basis type -- bug 2683529
            --   If resource is batchable, basis type should always be LOT
            --
            ************************************************************/

            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Default Basis type. . . . ' || l_return_status) ;
            END IF ;

            IF   NVL(l_rev_op_resource_rec.acd_type,l_ACD_ADD) = l_ACD_ADD
                 AND l_rev_op_resource_rec.basis_type <> 2 -- If basis_type is not LOT
            THEN

               IF Get_Res_Batchable
                 ( p_resource_id => l_rev_op_res_unexp_rec.resource_id
                 )  = 1  -- Batchable
               THEN

                  -- Set basis type to 2
                  l_rev_op_resource_rec.basis_type := 2;  -- default to LOT basis type

                  l_Token_Tbl(1).token_name  := 'RES_SEQ_NUMBER';
                  l_Token_Tbl(1).token_value :=
                                   p_rev_op_resource_rec.resource_sequence_number ;
                  -- Set Warning Message
                  Error_Handler.Add_Error_Token
                  ( p_message_name   => 'BOM_RES_DEF_BASIS_TYPE' -- new message
                  , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                  , p_Token_Tbl      => l_Token_Tbl
                  , p_Message_Type   => 'W'
                  ) ;

               END IF ;
            END IF ;


            /************************************************************
            --
            -- Set missing column values to Null
            --
            ************************************************************/
            IF  l_rev_op_resource_rec.activity  = FND_API.G_MISS_CHAR
                OR l_rev_op_res_unexp_rec.activity_id = FND_API.G_MISS_NUM
            THEN
               l_rev_op_resource_rec.activity     := NULL ;
               l_rev_op_res_unexp_rec.activity_id := NULL ;
            END IF ;


            IF  l_rev_op_resource_rec.setup_type = FND_API.G_MISS_CHAR
                OR l_rev_op_res_unexp_rec.setup_id = FND_API.G_MISS_NUM
            THEN
               l_rev_op_resource_rec.setup_type := NULL ;
               l_rev_op_res_unexp_rec.setup_id  := NULL ;
            END IF ;


            IF l_rev_op_resource_rec.resource_offset_percent  = FND_API.G_MISS_NUM
            THEN
               l_rev_op_resource_rec.resource_offset_percent := NULL ;
            END IF ;

            IF  l_rev_op_resource_rec.principle_flag = FND_API.G_MISS_NUM
            THEN
                l_rev_op_resource_rec.principle_flag := NULL ;
            END IF ;


            -- FlexFields
            IF l_rev_op_resource_rec.attribute_category = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute_category := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute1 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute2  = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute2 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute3 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute4 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute5 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute6 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute7 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute8 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute9 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute10 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute11 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute12 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute13 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute14 := NULL ;
            END IF;

            IF l_rev_op_resource_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                    l_rev_op_resource_rec.attribute15 := NULL ;
            END IF;

            -- Return the status and message table.
            x_return_status  := l_return_status ;
            x_mesg_token_tbl := l_mesg_token_tbl ;

            -- Return the common operation records after entity defaulting.
            x_rev_op_resource_rec    := l_rev_op_resource_rec ;
            x_rev_op_res_unexp_rec   := l_rev_op_res_unexp_rec ;

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


END BOM_Default_Op_Res;

/
