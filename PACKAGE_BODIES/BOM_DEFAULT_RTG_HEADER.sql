--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_RTG_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_RTG_HEADER" AS
/* $Header: BOMDRTGB.pls 120.1.12010000.2 2010/01/22 05:55:57 ybabulal ship $*/
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDRTGB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Rtg_Header
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Biao Zhang    Initial Creation
--
****************************************************************************/
        G_PKG_NAME      CONSTANT VARCHAR2(30) := 'Rtg_Default_Rtg_Header';


        /********************************************************************
        * Function      : Get_Routing_Sequence
        * Return        : NUMBER
        * Purpose       : Function will return the routing_sequence_id.
        *
        **********************************************************************/
        FUNCTION Get_Routing_Sequence
        RETURN NUMBER
        IS
                l_routing_sequence_id      NUMBER := NULL;
        BEGIN

                SELECT bom_operational_routings_s.nextval
                  INTO l_routing_sequence_id
                  FROM sys.dual;

                RETURN l_routing_sequence_id;

                EXCEPTION

                WHEN OTHERS THEN
                        RETURN NULL;

        END Get_routing_Sequence;

        PROCEDURE Get_Flex_Rtg_Header
          (  p_rtg_header_rec IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
           , x_rtg_header_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_rtg_header_rec := p_rtg_header_rec;

                IF p_rtg_header_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute_category := NULL;
                END IF;

                IF p_rtg_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute1  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute2  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute3  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute4  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute5  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute6  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute7  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute8  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute9  := NULL;
                END IF;

                IF p_rtg_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute10 := NULL;
                END IF;

                IF p_rtg_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute11 := NULL;
                END IF;

                IF p_rtg_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute12 := NULL;
                END IF;

                IF p_rtg_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute13 := NULL;
                END IF;

                IF p_rtg_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute14 := NULL;
                END IF;

                IF p_rtg_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_rtg_header_rec.attribute15 := NULL;
                END IF;


        END Get_Flex_Rtg_Header;

        -- Get_Cfm_Routing_Flag
        FUNCTION Get_Cfm_Routing_Flag
        RETURN NUMBER
        IS
        BEGIN
            RETURN 2 ;   -- Return 2 : Standard Routing
        END Get_Cfm_Routing_Flag ;

        -- Get_Mixed_Model_Map_Flag
        FUNCTION  Get_Mixed_Model_Map_Flag
        RETURN NUMBER
        IS
        BEGIN
            RETURN 2 ;   -- Return 2 : No
        END Get_Mixed_Model_Map_Flag ;

        -- Get_Ctp_Flag
        FUNCTION   Get_Ctp_Flag
        RETURN NUMBER
        IS
        BEGIN
            RETURN 2 ;   -- Return 2 : No
        END Get_Ctp_Flag ;


        -- Get_Eng_Routing_Flag
        FUNCTION   Get_Eng_Routing_Flag( p_assembly_item_id  NUMBER
                                       , p_org_id            NUMBER)
        RETURN NUMBER
        IS
            p_eng_routng_flag NUMBER ;
            CURSOR get_routing_flag_csr (  p_assembly_item_id  NUMBER
                                         , p_org_id            NUMBER )
            IS
                SELECT DECODE(eng_item_flag, 'Y', 1, 2)  eng_routing_flag
                FROM mtl_system_items
                WHERE inventory_item_id = p_assembly_item_id
                AND   organization_id = p_org_id;




        BEGIN

            FOR get_routing_flag_rec  IN get_routing_flag_csr
                                         (  p_assembly_item_id
                                          , p_org_id )
            LOOP

                 RETURN get_routing_flag_rec.eng_routing_flag ;

            END LOOP ;

            RETURN 2 ;   -- Return 2 : No - Mfg Routing

        END Get_Eng_Routing_Flag ;

-- Added for SSOS (bug 2689249)
	FUNCTION   Get_Ser_Num_Control_Code( p_assembly_item_id  NUMBER
						, p_org_id            NUMBER)
        RETURN NUMBER
        IS
            p_serial_number_control_code NUMBER ;
            CURSOR GET_SER_NUM_CONTROL_CODE_csr (  p_assembly_item_id  NUMBER
							, p_org_id            NUMBER )
            IS
                SELECT serial_number_control_code
                FROM mtl_system_items
                WHERE inventory_item_id = p_assembly_item_id
                AND   organization_id = p_org_id;

        BEGIN

            FOR GET_SER_NUM_CONTROL_CODE_rec  IN GET_SER_NUM_CONTROL_CODE_csr
							(  p_assembly_item_id
							, p_org_id )
            LOOP

                 RETURN GET_SER_NUM_CONTROL_CODE_rec.serial_number_control_code ;

            END LOOP ;

        END Get_Ser_Num_Control_Code ;


        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Rtg Header exposed record
        *                 Rtg Header unexposed record
        * Parameters out: Rtg Header exposed record after defaulting
        *                 Rtg Header unexposed record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/
        PROCEDURE Attribute_Defaulting
        (  p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec    IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , x_rtg_header_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         )
        IS
          --bug:4285921 Cursor to get completion subinventory and locator id.
          CURSOR  l_CommonRtg_csr (P_CommRtgSeqId NUMBER, P_OrgId NUMBER, P_Alt VARCHAR2) IS
            SELECT
              COMPLETION_SUBINVENTORY,
              COMPLETION_LOCATOR_ID
            FROM
              BOM_OPERATIONAL_ROUTINGS
            WHERE
                ROUTING_SEQUENCE_ID = P_CommRtgSeqId
            AND ORGANIZATION_ID     = P_OrgId
            AND NVL(ALTERNATE_ROUTING_DESIGNATOR, 'primary alternate') =
                  NVL(P_Alt, 'primary alternate');
        BEGIN

                x_rtg_header_rec := p_rtg_header_rec;
                x_rtg_header_unexp_rec := p_rtg_header_unexp_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                IF p_rtg_header_unexp_rec.routing_sequence_id IS NULL OR
                   p_rtg_header_unexp_rec.routing_sequence_id = FND_API.G_MISS_NUM
                THEN
                        x_rtg_header_unexp_rec.routing_sequence_id :=
                                Get_Routing_Sequence;

                        IF BOM_Rtg_Globals.Get_Debug = 'Y'
                        THEN Error_Handler.Write_Debug('New Routing Sequence Id :  '
                             || to_char(x_rtg_header_unexp_rec.routing_sequence_id));
                        END IF;

                END IF;

                IF  p_rtg_header_rec.cfm_routing_flag = FND_API.G_MISS_NUM
                OR  p_rtg_header_rec.cfm_routing_flag IS NULL
                THEN
                        x_rtg_header_rec.cfm_routing_flag  := Get_Cfm_Routing_Flag ;
                END IF;

                IF p_rtg_header_rec.mixed_model_map_flag =FND_API.G_MISS_NUM
                OR p_rtg_header_rec.mixed_model_map_flag IS NULL
                THEN
                        x_rtg_header_rec.mixed_model_map_flag  := Get_Mixed_Model_Map_Flag ;
                END IF;

                IF p_rtg_header_rec.ctp_flag =FND_API.G_MISS_NUM
                OR p_rtg_header_rec.ctp_flag IS NULL
                THEN
                        x_rtg_header_rec.ctp_flag  := Get_Ctp_Flag ;
                END IF;

                IF p_rtg_header_rec.eng_routing_flag = FND_API.G_MISS_NUM
                OR p_rtg_header_rec.eng_routing_flag IS NULL
                THEN
                        x_rtg_header_rec.eng_routing_flag
                           := Get_Eng_Routing_Flag
                              ( p_assembly_item_id => p_rtg_header_unexp_rec.assembly_item_id
                              , p_org_id => p_rtg_header_unexp_rec.organization_id )   ;

                END IF ;

                IF p_rtg_header_rec.total_cycle_time = FND_API.G_MISS_NUM THEN
                        x_rtg_header_rec.total_cycle_time := NULL  ;
                END IF;

                Get_Flex_Rtg_Header(  p_rtg_header_rec => x_rtg_header_rec
                                    , x_rtg_header_rec => x_rtg_header_rec
                                    );

                --bug:4285921 begins
                -- Called for CREATE.
                -- Take values of completion_subinventory and completion_locator_id
                -- from input if specified, else take it from common routing.
                IF NVL(p_rtg_header_unexp_rec.common_routing_sequence_id, FND_API.G_MISS_NUM) <>
                      FND_API.G_MISS_NUM
                THEN
                  FOR l_CommonRtg_rec IN
                        l_CommonRtg_csr
                          (
                            P_CommRtgSeqId => p_rtg_header_unexp_rec.common_routing_sequence_id,
                            P_OrgId => p_rtg_header_unexp_rec.organization_id,
                            P_Alt => p_rtg_header_rec.alternate_routing_code
                           )
                  LOOP
                    x_rtg_header_rec.completion_subinventory :=
                      NVL(p_rtg_header_rec.completion_subinventory,l_CommonRtg_rec.completion_subinventory);
                    x_rtg_header_unexp_rec.completion_locator_id :=
                      NVL(p_rtg_header_unexp_rec.completion_locator_id,l_CommonRtg_rec.completion_locator_id);
                  END LOOP; -- common routing
                END IF; -- set common routing info
                --bug:4285921 ends

        END Attribute_Defaulting;

        /*********************************************************************
        * Procedure     : Entity_Attribute_Defaulting
        * Parameters IN : Rtg Header exposed record
        *                 Rtg Header unexposed record
        * Parameters out: Rtg Header exposed record after defaulting
        *                 Rtg Header unexposed record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Entity Attribute Defaulting will default the necessary
        *                 entity level attribute with appropriate values.
        **********************************************************************/
        PROCEDURE Entity_Attribute_Defaulting
        (  p_rtg_header_rec             IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec       IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_rec             IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , x_rtg_header_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status              IN OUT NOCOPY VARCHAR2
         )
        IS

                l_token_tbl      Error_Handler.Token_Tbl_Type;
                l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;

        BEGIN

                x_rtg_header_rec := p_rtg_header_rec;
                x_rtg_header_unexp_rec := p_rtg_header_unexp_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                IF   (p_rtg_header_unexp_rec.routing_sequence_id IS NOT NULL
                      AND   p_rtg_header_unexp_rec.routing_sequence_id <> FND_API.G_MISS_NUM)
                AND  ( p_rtg_header_unexp_rec.common_routing_sequence_id IS NULL
                      OR p_rtg_header_unexp_rec.common_routing_sequence_id
                                                          =  FND_API.G_MISS_NUM )
                THEN
                     x_rtg_header_unexp_rec.common_routing_sequence_id :=
                                p_rtg_header_unexp_rec.routing_sequence_id;
                END IF;

                IF p_rtg_header_unexp_rec.common_routing_sequence_id
                          =  p_rtg_header_unexp_rec.routing_sequence_id
                THEN
                        x_rtg_header_unexp_rec.common_assembly_item_id := NULL ;

                ELSIF p_rtg_header_unexp_rec.common_assembly_item_id = FND_API.G_MISS_NUM
                THEN
                        x_rtg_header_unexp_rec.common_assembly_item_id := NULL ;
                END IF ;

                IF  p_rtg_header_rec.eng_routing_flag IS NOT NULL
                AND p_rtg_header_rec.eng_routing_flag <> FND_API.G_MISS_NUM
                AND ( p_rtg_header_unexp_rec.routing_type IS NULL
                      OR  p_rtg_header_unexp_rec.routing_type = FND_API.G_MISS_NUM)
                THEN
                    SELECT DECODE(p_rtg_header_rec.eng_routing_flag, 1, 2, 1)
                    INTO  x_rtg_header_unexp_rec.routing_type
                    FROM SYS.DUAL ;
                END IF;


                IF p_rtg_header_rec.total_cycle_time = FND_API.G_MISS_NUM THEN
                        x_rtg_header_rec.total_cycle_time := NULL   ;
                END IF;

                IF p_rtg_header_rec.alternate_routing_code = FND_API.G_MISS_CHAR
                THEN
                        x_rtg_header_rec.alternate_routing_code := NULL ;
                END IF ;

                IF p_rtg_header_rec.completion_subinventory = FND_API.G_MISS_CHAR
                THEN
                        x_rtg_header_rec.completion_subinventory := NULL ;
                END IF ;

                IF p_rtg_header_unexp_rec.completion_locator_id = FND_API.G_MISS_NUM
                THEN
                        x_rtg_header_unexp_rec.completion_locator_id := NULL ;
                END IF ;

                IF p_rtg_header_unexp_rec.line_id = FND_API.G_MISS_NUM
                OR p_rtg_header_unexp_rec.line_id IS NULL
                THEN
                        x_rtg_header_unexp_rec.line_id := NULL ;
                        x_rtg_header_rec.line_code := NULL ;
                END IF ;

                IF p_rtg_header_rec.priority = FND_API.G_MISS_NUM THEN
                        x_rtg_header_rec.priority := NULL ;
                END IF ;

                IF p_rtg_header_rec.total_cycle_time =  FND_API.G_MISS_NUM THEN
                        x_rtg_header_rec.total_cycle_time := NULL ;
                END IF ;

                IF p_rtg_header_rec.routing_comment = FND_API.G_MISS_CHAR
                THEN
                        x_rtg_header_rec.routing_comment := NULL ;
                END IF ;

                IF p_rtg_header_rec.ser_start_op_seq = FND_API.G_MISS_NUM   -- Added for SSOS (bug 2689249)
                THEN
                        x_rtg_header_rec.ser_start_op_seq := NULL ;
                ELSIF p_rtg_header_rec.ser_start_op_seq IS NOT NULL THEN
      --bug:5137686 Allow SSOS for network routing also.
			IF (     ( BOM_Rtg_Globals.Get_Cfm_Rtg_Flag <> BOM_Rtg_Globals.G_STD_RTG )
           AND ( BOM_Rtg_Globals.Get_Cfm_Rtg_Flag <> BOM_Rtg_Globals.G_LOT_RTG ) )
         AND
			    ( BOM_Rtg_Globals.Get_Eam_Item_Type <>  BOM_Rtg_Globals.G_ASSET_ACTIVITY ) THEN -- SSOS is for Std routings only
			    x_rtg_header_rec.ser_start_op_seq := NULL ;
			    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			    THEN
/*
			    l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
			    l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
*/
				Error_Handler.Add_Error_Token
				(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
				, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				, p_message_name   => 'BOM_NON_STD_RTG_SSOS_IGNORED'
				, p_token_tbl      => l_token_tbl
				, p_message_type   => 'W'
				);
			    END IF ;
			END IF;
			IF Get_Ser_Num_Control_Code
                              ( p_assembly_item_id => p_rtg_header_unexp_rec.assembly_item_id
                              , p_org_id => p_rtg_header_unexp_rec.organization_id ) <> 2 THEN
			    x_rtg_header_rec.ser_start_op_seq := NULL ;
/*
			    l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
			    l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
*/
			    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			    THEN

				Error_Handler.Add_Error_Token
				(  x_Mesg_token_tbl => l_Mesg_Token_Tbl
				, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
				, p_message_name   => 'BOM_NON_PREDEF_SSOS_IGNORED'
				, p_token_tbl      => l_token_tbl
				, p_message_type   => 'W'
				);
			    END IF ;
			END IF;
		END IF ;


                --
                -- Defaulting for non operated columns in
                -- Standard Routing and Lot Based Routing
                --
                IF p_rtg_header_rec.cfm_routing_flag IN ( 2 , 3)
                AND  (x_rtg_header_rec.line_code IS NOT NULL
                     OR  x_rtg_header_rec.mixed_model_map_flag <> 2
                     OR  x_rtg_header_rec.total_cycle_time IS NOT NULL)
                THEN
                     x_rtg_header_rec.line_code := NULL ;
                     x_rtg_header_rec.mixed_model_map_flag:= 2 ;
                     x_rtg_header_rec.total_cycle_time := NULL;


                     l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                     l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;

                     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN

                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'BOM_RTG_FLOW_ATTR_IGNORED'
                         , p_token_tbl      => l_token_tbl
                         , p_message_type   => 'W'
                         );
                     END IF ;

                END IF;

                x_mesg_token_tbl := l_Mesg_Token_Tbl ;

        END Entity_Attribute_Defaulting;

        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Rtg Header Exposed column record
        *                 Rtg Header Unexposed column record
        *                 Old Rtg Header Exposed Column Record
        *                 Old Rtg Header Unexposed Column Record
        * Parameters out: Rtg Header Exposed column record after populating
        *                 Rtg Header Unexposed Column record after  populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_rtg_header_rec           IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec     IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , p_old_rtg_header_rec       IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_old_rtg_header_unexp_rec IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_rec           IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , x_rtg_header_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
        )
        IS
          --bug:4285921 Cursor to get completion subinventory and locator id.
          CURSOR  l_CommonRtg_csr (P_CommRtgSeqId NUMBER, P_OrgId NUMBER, P_Alt VARCHAR2) IS
            SELECT
              COMPLETION_SUBINVENTORY,
              COMPLETION_LOCATOR_ID
            FROM
              BOM_OPERATIONAL_ROUTINGS
            WHERE
                ROUTING_SEQUENCE_ID = P_CommRtgSeqId
            AND ORGANIZATION_ID     = P_OrgId
            AND NVL(ALTERNATE_ROUTING_DESIGNATOR, 'primary alternate') =
                  NVL(P_Alt, 'primary alternate');
               l_rtg_header_rec    Bom_Rtg_Pub.Rtg_Header_Rec_Type;     /* bug 7581065*/
        BEGIN
                x_rtg_header_rec := p_rtg_header_rec;
                x_rtg_header_unexp_rec := p_rtg_header_unexp_rec;


                IF( p_rtg_header_rec.eng_routing_flag IS NULL  OR
                    p_rtg_header_rec.eng_routing_flag  = FND_API.G_MISS_NUM )
                THEN
                        x_rtg_header_unexp_rec.routing_type :=
                                p_old_rtg_header_unexp_rec.routing_type ;
                END IF;


                IF p_rtg_header_rec.Routing_Comment IS NULL
                THEN
                        x_rtg_header_rec.Routing_Comment :=
                                p_old_rtg_header_rec.Routing_Comment ;
                END IF;

                IF p_rtg_header_rec.CFM_Routing_Flag IS NULL
                OR p_rtg_header_rec.CFM_Routing_Flag = FND_API.G_MISS_NUM
                THEN
                        x_rtg_header_rec.CFM_Routing_Flag :=
                                p_old_rtg_header_rec.CFM_Routing_Flag ;
                END IF ;

                IF p_rtg_header_rec.Mixed_Model_Map_Flag IS NULL
                OR p_rtg_header_rec.Mixed_Model_Map_Flag = FND_API.G_MISS_NUM
                THEN
                        x_rtg_header_rec.Mixed_Model_Map_Flag :=
                                p_old_rtg_header_rec.Mixed_Model_Map_Flag ;
                END IF ;

                IF p_rtg_header_rec.CTP_Flag IS NULL
                OR p_rtg_header_rec.CTP_Flag = FND_API.G_MISS_NUM
                THEN
                        x_rtg_header_rec.CTP_Flag :=
                                p_old_rtg_header_rec.CTP_Flag ;
                END IF ;

                IF p_rtg_header_rec.Priority IS NULL
                THEN
                        x_rtg_header_rec.Priority :=
                                p_old_rtg_header_rec.Priority ;
                END IF ;

                IF p_rtg_header_rec.Total_Cycle_Time IS NULL
                THEN
                        x_rtg_header_rec.Total_Cycle_Time :=
                                p_old_rtg_header_rec.Total_Cycle_Time ;
                END IF ;

                IF p_rtg_header_rec.ser_start_op_seq IS NULL  -- Added for SSOS (bug 2689249)
                THEN
                        x_rtg_header_rec.ser_start_op_seq :=
                                p_old_rtg_header_rec.ser_start_op_seq;
                END IF ;

                --
                -- Populate Null or missng flex field columns
                --
                IF p_rtg_header_rec.attribute_category IS NULL OR
                   p_rtg_header_rec.attribute_category = FND_API.G_MISS_CHAR
                THEN
                        x_rtg_header_rec.attribute_category :=
                                p_old_rtg_header_rec.attribute_category;

                END IF;

                IF /*p_rtg_header_rec.attribute1 = FND_API.G_MISS_CHAR OR /*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute1 IS NULL
                THEN
                        x_rtg_header_rec.attribute1  :=
                                p_old_rtg_header_rec.attribute1;
                END IF;

                IF /*p_rtg_header_rec.attribute2 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute2 IS NULL
                THEN
                        x_rtg_header_rec.attribute2  :=
                                p_old_rtg_header_rec.attribute2;
                END IF;

                IF /*p_rtg_header_rec.attribute3 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute3 IS NULL
                THEN
                        x_rtg_header_rec.attribute3  :=
                                p_old_rtg_header_rec.attribute3;
                END IF;

                IF /*p_rtg_header_rec.attribute4 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute4 IS NULL
                THEN
                        x_rtg_header_rec.attribute4  :=
                                p_old_rtg_header_rec.attribute4;
                END IF;

                IF /*p_rtg_header_rec.attribute5 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute5 IS NULL
                THEN
                        x_rtg_header_rec.attribute5  :=
                                p_old_rtg_header_rec.attribute5;
                END IF;

                IF /*p_rtg_header_rec.attribute6 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute6 IS NULL
                THEN
                        x_rtg_header_rec.attribute6  :=
                                p_old_rtg_header_rec.attribute6;
                END IF;

                IF /*p_rtg_header_rec.attribute7 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute7 IS NULL
                THEN
                        x_rtg_header_rec.attribute7  :=
                                p_old_rtg_header_rec.attribute7;
                END IF;

                IF /*p_rtg_header_rec.attribute8 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute8 IS NULL
                THEN
                        x_rtg_header_rec.attribute8  :=
                                p_old_rtg_header_rec.attribute8;
                END IF;

                IF /*p_rtg_header_rec.attribute9 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute9 IS NULL
                THEN
                        x_rtg_header_rec.attribute9  :=
                                p_old_rtg_header_rec.attribute9;
                END IF;

                IF /*p_rtg_header_rec.attribute10 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute10 IS NULL
                THEN
                        x_rtg_header_rec.attribute10 :=
                                p_old_rtg_header_rec.attribute10;
                END IF;

                IF /*p_rtg_header_rec.attribute11 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute11 IS NULL
                THEN
                        x_rtg_header_rec.attribute11 :=
                                p_old_rtg_header_rec.attribute11;
                END IF;

                IF /*p_rtg_header_rec.attribute12 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute12 IS NULL
                THEN
                        x_rtg_header_rec.attribute12 :=
                                p_old_rtg_header_rec.attribute12;
                END IF;

                IF /*p_rtg_header_rec.attribute13 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute13 IS NULL
                THEN
                        x_rtg_header_rec.attribute13 :=
                                p_old_rtg_header_rec.attribute13;
                END IF;

                IF /*p_rtg_header_rec.attribute14 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute14 IS NULL
                THEN
                        x_rtg_header_rec.attribute14 :=
                                p_old_rtg_header_rec.attribute14;
                END IF;

                IF /*p_rtg_header_rec.attribute15 = FND_API.G_MISS_CHAR OR/*Commented condition bug 7581065*/
                   p_rtg_header_rec.attribute15 IS NULL
                THEN
                        x_rtg_header_rec.attribute15 :=
                                p_old_rtg_header_rec.attribute15;
                END IF;
                --
                -- Get the unexposed columns from the database and return
                -- them as the unexposed columns for the current record.
                --
                x_rtg_header_unexp_rec.routing_sequence_id
                         := p_old_rtg_header_unexp_rec.routing_sequence_id;

                IF p_rtg_header_unexp_rec.Common_Assembly_Item_Id = FND_API.G_MISS_NUM
                OR p_rtg_header_unexp_rec.Common_Assembly_Item_Id IS NULL
                THEN
                    x_rtg_header_unexp_rec.Common_Assembly_Item_Id
                         := p_old_rtg_header_unexp_rec.Common_Assembly_Item_Id ;
                END IF ;

                IF p_rtg_header_unexp_rec.Common_Routing_Sequence_Id = FND_API.G_MISS_NUM
                OR p_rtg_header_unexp_rec.Common_Routing_Sequence_Id IS NULL
                THEN
                    x_rtg_header_unexp_rec.Common_Routing_Sequence_Id
                         := p_old_rtg_header_unexp_rec.Common_Routing_Sequence_Id ;
                END IF ;

                IF p_rtg_header_unexp_rec.Line_Id = FND_API.G_MISS_NUM
                OR p_rtg_header_unexp_rec.Line_Id IS NULL
                THEN

                     x_rtg_header_unexp_rec.Line_Id
                         := p_old_rtg_header_unexp_rec.Line_Id ;
                END IF ;


                --bug:4285921 begins
                -- Called during Update.
                -- Take values of completion_subinventory and completion_locator_id
                -- from input if specified, else from common routing.

                FOR l_CommonRtg_rec IN
                        l_CommonRtg_csr
                          (
                            P_CommRtgSeqId => p_rtg_header_unexp_rec.common_routing_sequence_id,
                            P_OrgId => p_rtg_header_unexp_rec.organization_id,
                            P_Alt => p_rtg_header_rec.alternate_routing_code
                           )
                LOOP
                  x_rtg_header_rec.completion_subinventory :=
                    NVL(p_rtg_header_rec.completion_subinventory,l_CommonRtg_rec.completion_subinventory);

                  IF       ( p_rtg_header_rec.Completion_Subinventory IS NOT NULL )
                      AND  ( p_rtg_header_rec.Completion_Subinventory <>
                               p_old_rtg_header_rec.Completion_Subinventory )
                      AND
                       (
                          (
                                p_rtg_header_unexp_rec.Completion_Locator_Id IS NOT NULL
                           AND  p_old_rtg_header_unexp_rec.Completion_Locator_Id IS NOT NULL
                          )
                        AND
                          (
                              p_rtg_header_unexp_rec.Completion_Locator_Id =
                                  p_old_rtg_header_unexp_rec.Completion_Locator_Id
                          OR
                            (
                                p_rtg_header_unexp_rec.Completion_Locator_Id IS NOT NULL
                            AND p_rtg_header_unexp_rec.Completion_Locator_Id = FND_API.G_MISS_NUM
                            )
                          )
                        )
                  THEN
                    x_rtg_header_unexp_rec.Completion_Locator_Id := NULL;
                  ELSIF
                    (
                          p_rtg_header_rec.Completion_Subinventory IS NOT NULL
                      AND p_rtg_header_rec.Completion_Subinventory <>
                            p_old_rtg_header_rec.Completion_Subinventory
                      AND p_rtg_header_unexp_rec.Completion_Locator_Id = FND_API.G_MISS_NUM
                    )
                  THEN
                     x_rtg_header_unexp_rec.Completion_Locator_Id := NULL;
                  ELSIF
                    (
                          p_rtg_header_rec.Completion_Subinventory IS NOT NULL
                    AND   p_rtg_header_rec.Completion_Subinventory =
                            p_old_rtg_header_rec.Completion_Subinventory
                    AND   p_rtg_header_unexp_rec.Completion_Locator_Id IS NULL
                    )
                  THEN
                    x_rtg_header_unexp_rec.Completion_Locator_Id :=
                      NVL(p_rtg_header_unexp_rec.Completion_Locator_Id,l_CommonRtg_rec.completion_locator_id);
                  ELSIF p_rtg_header_rec.Completion_Location_Name IS NULL
                  THEN
                    x_rtg_header_unexp_rec.Completion_Locator_Id :=
                      NVL(p_rtg_header_unexp_rec.Completion_Locator_Id,l_CommonRtg_rec.completion_locator_id);
                  END IF;
                END LOOP; -- common routing
                --bug:4285921 ends
      l_rtg_header_rec := x_rtg_header_rec; /* bug 7581065*/
      /* bug 7581065 Assign NULL on DFF if the values are MISSING */
      Get_Flex_Rtg_Header(  p_rtg_header_rec => l_rtg_header_rec
                          , x_rtg_header_rec => x_rtg_header_rec
                          );
     /* end bug 7581065*/

        END Populate_Null_Columns;

END BOM_Default_Rtg_Header;

/
