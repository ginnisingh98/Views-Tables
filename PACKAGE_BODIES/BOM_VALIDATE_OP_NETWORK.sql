--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_OP_NETWORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_OP_NETWORK" AS
/* $Header: BOMLONWB.pls 115.23 2004/03/19 12:37:16 earumuga ship $*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--    BOMLONWB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Op_Network
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Biao Zhang Initial Creation
--
****************************************************************************/

        G_Pkg_Name      VARCHAR2(30) := 'BOM_Validate_Op_Network';



        /*******************************************************************
        * Procedure     : Check_Eam_Rtg_Network
        * Parameters IN : Operation Network Exposed Record
        *                 Operation Network Unexposed Record
        *                 Old Operation Network exposed Record
        *                 Old Operation Network Unexposed Record
        *                 Mesg Token Table
        * Parameters OUT: Mesg Token Table
        *                 Return Status
        * Purpose       : Procedure will validate for eAM Rtg Network.
        *                 This procedure is called internally by Check_Entity2.
        *
        *********************************************************************/
        PROCEDURE Check_Eam_Rtg_Network
        (  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_old_op_network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_old_op_network_unexp_rec
                                  IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_mesg_token_tbl       IN  Error_Handler.Mesg_Token_Tbl_Type
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
        )
        IS

        l_mesg_token_tbl               Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status                VARCHAR2(1);
        l_err_msg                      VARCHAR2(2000);
        l_common_routing_sequence_id   NUMBER;


        BEGIN

           l_return_status := FND_API.G_RET_STS_SUCCESS;
           x_return_status := FND_API.G_RET_STS_SUCCESS;
           l_mesg_token_tbl := p_mesg_token_tbl;

           IF BOM_Rtg_Globals.Get_Debug = 'Y'
           THEN Error_Handler.Write_Debug
                   ('Within Operation Network Check Eam Rtg Network. . . ');
           END IF;


           -- Get Common Routing Seq Id from System Info Rec.
           -- If the value is Null, set Common Routing Seq Id.
           l_common_routing_sequence_id := BOM_Rtg_Globals.Get_Common_Rtg_Seq_id ;

           IF l_common_routing_sequence_id IS NULL OR
              l_common_routing_sequence_id = FND_API.G_MISS_NUM
           THEN
              BEGIN
                 SELECT  common_routing_sequence_id
                 INTO    l_common_routing_sequence_id
                 FROM    bom_operational_routings
                 WHERE   routing_sequence_id =
                                  p_op_network_unexp_rec.routing_sequence_id ;
              END ;

              BOM_Rtg_Globals.Set_Common_Rtg_Seq_id
                     ( p_common_rtg_seq_id => l_common_routing_sequence_id );

           END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Call eAM Rtg Network validation API. . . ');
END IF;

           -- Call Routing eAM API for eAM Rtg Network validation
           Bom_Rtg_Eam_Util.Check_Eam_Rtg_Network
           ( p_routing_sequence_id => p_op_network_unexp_rec.routing_sequence_id
           , x_err_msg             => l_err_msg
           , x_return_status       => l_return_status
           ) ;

           IF  l_return_status =  FND_API.G_RET_STS_ERROR THEN

              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                  Error_Handler.Add_Error_Token
                  (  p_message_name   => NULL
                   , p_message_text   => l_err_msg
                   , p_mesg_token_tbl => l_mesg_token_tbl
                   , x_mesg_token_tbl => x_mesg_token_tbl
                  ) ;

               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR ;
            ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS AND
                   l_err_msg IS NOT NULL THEN
                 Error_Handler.Add_Error_Token
                 (
                   p_message_name => NULL,
                   p_message_text => l_err_msg,
                   p_mesg_token_tbl => l_mesg_token_tbl,
                   x_mesg_token_tbl => x_mesg_token_tbl
                 );

            END IF ;

        END  Check_Eam_Rtg_Network ;


        /*******************************************************************
        * Procedure     : Check_Existence
        * Returns       : None
        * Parameters IN : Operation Network Exposed Record
        *                 Operation Network Unexposed Record
        * Parameters OUT: Old Operation Network exposed Record
        *                 Old Operation Network Unexposed Record
        *                 Mesg Token Table
        *                 Return Status
        * Purpose       : Procedure will query the routing revision
        *                 record and return it in old record variables. If the
        *                 Transaction Type is Create and the record already
        *                 exists the return status would be error or if the
        *                 transaction type is Update or Delete and the record
        *                 does not exist then the return status would be an
        *                 error as well. Mesg_Token_Table will carry the
        *                 error messsage and the tokens associated with the
        *                 message.
        *********************************************************************/
        PROCEDURE Check_Existence
        (  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_old_op_network_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_old_op_network_unexp_rec
                                  IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
        )
        IS
                l_token_tbl      Error_Handler.Token_Tbl_Type;
                l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
                l_return_status  VARCHAR2(1);
                cfm_flag         NUMBER := NULL ;
        BEGIN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Quering Op Network . . .' ) ;
END IF;

                Bom_Op_Network_Util.Query_Row
                (  p_from_op_seq_id     =>
                        p_op_network_unexp_rec.from_op_seq_id
                 , p_to_op_seq_id       =>
                        p_op_network_unexp_rec.to_op_seq_id
                 , x_op_network_rec     => x_old_op_network_rec
                 , x_op_network_unexp_rec => x_old_op_network_unexp_rec
                 , x_return_status      => l_return_status
                 );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Query Row Returned with : ' || l_return_status);
END IF;

                IF l_return_status = BOM_Rtg_Globals.G_RECORD_FOUND AND
                   p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                THEN
                        l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                        l_token_tbl(1).token_value :=
                                        p_op_network_rec.from_op_seq_number;
                        l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                        l_token_tbl(2).token_value :=
                                        p_op_network_rec.to_op_seq_number;
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'BOM_OP_NWK_ALREADY_EXISTS'
                         , p_token_tbl      => l_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                ELSIF l_return_status = BOM_Rtg_Globals.G_RECORD_NOT_FOUND AND
                      p_op_network_rec.transaction_type IN
                         ( BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
                THEN
                        l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                        l_token_tbl(1).token_value :=
                                        p_op_network_rec.from_op_seq_number;
                        l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                        l_token_tbl(2).token_value :=
                                        p_op_network_rec.to_op_seq_number;
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name  => 'BOM_OP_NWK_DOESNOT_EXISTS'
                         , p_token_tbl     => l_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
                THEN
                        l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                        l_token_tbl(1).token_value :=
                                        p_op_network_rec.from_op_seq_number;
                        l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                        l_token_tbl(2).token_value :=
                                        p_op_network_rec.to_op_seq_number;
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_message_name       => NULL
                         , p_message_text       =>
                         'Unexpected error while existence verification of ' ||
                         'operation network'||
                         p_op_network_rec.assembly_item_name
                         , p_token_tbl          => l_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS
                THEN
                      l_return_status := FND_API.G_RET_STS_SUCCESS;
                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;


        END Check_Existence;



        /**********************************************************************
        * Procedure     : Check_Acces
        * Returns       : None
        * Parameters IN : Operation Network Exposed Record
        *                 Operation Network Unexposed Record
        * Parameters OUT: Old Operation Network exposed Record
        *                 Old Operation Network Unexposed Record
        *                 Mesg Token Table
        *                 Return Status
        * Purpose       : This procedure will check if the user has access to
        *                 the operations for Op Network.
        **********************************************************************/
        PROCEDURE Check_Access
        (  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
        )
        IS
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1);
                l_err_text              VARCHAR2(2000);
                l_cfm_flag              NUMBER ;

                -- Check if Department is valid
                CURSOR  l_nwkop_csr (  p_op_seq_id NUMBER
                                     )
                IS
                     SELECT standard_operation_id
                           ,disable_date
                     FROM  BOM_OPERATION_SEQUENCES bos
                     WHERE  bos.operation_sequence_id = p_op_seq_id ;

        BEGIN

           l_return_status := FND_API.G_RET_STS_SUCCESS;

           IF BOM_Rtg_Globals.Get_Debug = 'Y'
           THEN Error_Handler.Write_Debug
                   ('Within Operation Network Check Access. . . ');
           END IF;

           -- Set Token Value
           l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
           l_token_tbl(1).token_value :=
                          NVL( p_op_network_rec.new_from_op_seq_number
                             , p_op_network_rec.from_op_seq_number)  ;
           l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
           l_token_tbl(2).token_value :=
                          NVL( p_op_network_rec.new_to_op_seq_number
                             , p_op_network_rec.to_op_seq_number)  ;



           -- Check if operation is valid on current date when the current operation
           -- is for Lot Based routing.
           l_cfm_flag := BOM_Rtg_Globals.Get_CFM_Rtg_Flag ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Cfm Routing Flag is ' || to_char(l_cfm_flag) ||
     '. . . Eam Item Type is ' || to_char(BOM_Rtg_Globals.Get_Eam_Item_Type) ) ;
END IF ;

           IF l_cfm_flag IS NULL OR
              l_cfm_flag = FND_API.G_MISS_NUM
           THEN
               l_cfm_flag := Bom_Rtg_Validate.Get_Flow_Routing_Flag
                                 (p_op_network_unexp_rec.routing_sequence_id) ;
               BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type => l_cfm_flag) ;
           END IF;

           IF  l_cfm_flag  =  BOM_Rtg_Globals.G_FLOW_RTG
           THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check flow routing network . . . ' ) ;
END IF ;

                   -- In current release, validations for Check Access
                   -- in Flow Rtg's Op Network do not exist.
                   NULL ;

           ELSIF   l_cfm_flag  = BOM_Rtg_Globals.G_LOT_RTG
           THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check WSM routing network . . . ' ) ;
END IF ;
    if BOM_Rtg_GLobals.Get_CFM_Rtg_Flag <> BOM_Rtg_Globals.G_Lot_Rtg then --for bug 3132411
                 FOR l_nwkop_rec IN l_nwkop_csr
                 ( p_op_seq_id => NVL(p_op_network_unexp_rec.new_from_op_seq_id,
                                      p_op_network_unexp_rec.from_op_seq_id )
                 )
                 LOOP
                     IF l_nwkop_rec.standard_operation_id IS NULL THEN
                         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => 'BOM_OP_NWK_STDOP_REQUIRED'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => l_Token_Tbl
                            ) ;
                         END IF ;
                         l_return_status := FND_API.G_RET_STS_ERROR ;
                     END IF ;

                     IF NVL(l_nwkop_rec.disable_date , TRUNC(sysdate)+1 )
                            <=  TRUNC(sysdate)
                     THEN
                         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => 'BOM_OP_NWK_ALREADY_DISABLED'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => l_Token_Tbl
                            ) ;
                         END IF ;
                         l_return_status := FND_API.G_RET_STS_ERROR ;
                     END IF ;

                 END LOOP ;

                 IF l_return_status <>  FND_API.G_RET_STS_ERROR
                 THEN
                     FOR l_nwkop_rec IN l_nwkop_csr
                     ( p_op_seq_id => NVL(  p_op_network_unexp_rec.new_to_op_seq_id
                                          , p_op_network_unexp_rec.to_op_seq_id )
                     )
                     LOOP
                         IF l_nwkop_rec.standard_operation_id IS NULL THEN
                             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                             THEN
                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_OP_NWK_STDOP_REQUIRED'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                ) ;
                             END IF ;
                             l_return_status := FND_API.G_RET_STS_ERROR ;
                         END IF ;

                         IF NVL(l_nwkop_rec.disable_date , TRUNC(sysdate) + 1)
                            <=  TRUNC(sysdate)
                         THEN
                             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                             THEN
                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_OP_NWK_ALREADY_DISABLED'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                ) ;
                             END IF ;
                             l_return_status := FND_API.G_RET_STS_ERROR ;
                          END IF ;

                      END LOOP ;

                 END IF ;
    end if; --for bug 3132411

           -- For eAM enhancement
           -- Check access for network of Maintenace Routings
           ELSIF   l_cfm_flag  = BOM_Rtg_Globals.G_STD_RTG
           AND     BOM_Rtg_Globals.Get_Eam_Item_Type =  BOM_Rtg_Globals.G_ASSET_ACTIVITY
           THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check maintenance routing network . . . Eam Item Type is ' || to_char(BOM_Rtg_Globals.Get_Eam_Item_Type) ) ;
END IF ;

                 -- Check if the from operation has been disabled
                 FOR l_nwkop_rec IN l_nwkop_csr
                 ( p_op_seq_id => NVL(  p_op_network_unexp_rec.new_from_op_seq_id
                                      , p_op_network_unexp_rec.from_op_seq_id )
                  )
                 LOOP

                     IF NVL(l_nwkop_rec.disable_date , TRUNC(sysdate)+1 )
                            <=  TRUNC(sysdate)
                     THEN
                         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => 'BOM_OP_NWK_ALREADY_DISABLED'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => l_Token_Tbl
                            ) ;
                         END IF ;
                         l_return_status := FND_API.G_RET_STS_ERROR ;
                     END IF ;

                 END LOOP ;


                 IF l_return_status <>  FND_API.G_RET_STS_ERROR
                 THEN
                     -- Check if the to operation has been disabled
                     FOR l_nwkop_rec IN l_nwkop_csr
                     ( p_op_seq_id => NVL( p_op_network_unexp_rec.new_to_op_seq_id
                                         , p_op_network_unexp_rec.to_op_seq_id)
                     )
                     LOOP

                         IF NVL(l_nwkop_rec.disable_date , TRUNC(sysdate) + 1)
                            <=  TRUNC(sysdate)
                         THEN
                             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                             THEN
                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_OP_NWK_ALREADY_DISABLED'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => l_Token_Tbl
                                ) ;
                             END IF ;
                             l_return_status := FND_API.G_RET_STS_ERROR ;
                          END IF ;

                      END LOOP ;

                 END IF ;


           -- For  eAM enhancement, following cfm routing flag validation
           -- is moved from BOM_RTG_Val_To_Id.OP_Network_UUI_To_UI procedure
           -- and added condition for maintenance routing
           ELSIF  l_cfm_flag  <> BOM_Rtg_Globals.G_FLOW_RTG
           AND    l_cfm_flag  <> BOM_Rtg_Globals.G_LOT_RTG
           AND    BOM_Rtg_Globals.Get_Eam_Item_Type <> BOM_Rtg_Globals.G_ASSET_ACTIVITY
           THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check if parenet routing is a standard routing. ' || l_return_status) ;
END IF ;
                     l_token_tbl.delete ;
                     l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                     l_token_tbl(1).token_value :=
                                          p_op_network_rec.assembly_item_name;
                     Error_Handler.Add_Error_Token
                     (  p_Message_Name       => 'BOM_OP_NWK_RTG_INVALID'
                      , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                      , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                      , p_Token_Tbl          => l_Token_Tbl
                     );
                     l_return_status := FND_API.G_RET_STS_ERROR ;

           END IF ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Check if operations for network are valid. ' || l_return_status) ;
END IF ;
           -- Return Status and Message Token
           x_return_status  := l_return_status;
           x_mesg_token_tbl := l_mesg_token_tbl;

        EXCEPTION
            WHEN OTHERS THEN
                 IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                 ('Some unknown error in Check Access. . .' || SQLERRM );
                  END IF ;


                 l_err_text := G_PKG_NAME || ' Validation (Check Access) '
                                || substrb(SQLERRM,1,200);

                  Error_Handler.Add_Error_Token
                  (  p_message_name   => NULL
                   , p_message_text   => l_err_text
                   , p_mesg_token_tbl => l_mesg_token_tbl
                   , x_mesg_token_tbl => l_mesg_token_tbl
                 ) ;

                 -- Return the status and message table.
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 x_mesg_token_tbl := l_mesg_token_tbl ;


        END Check_Access ;


        /********************************************************************
        * Procedure     : Check_Attributes
        * Parameters IN : Operation Network Exposed Column record
        *                 Operation Network Unexposed Column record
        *                 Old Operation Network Exposed Column record
        *                 Old Operation Network unexposed column record
        * Parameters OUT: Return Status
        *                 Mesg Token Table
        * Purpose       : Check_Attrbibutes procedure will validate every
        *                 Operation Network attrbiute in its entirety.
        **********************************************************************/
        PROCEDURE Check_Attributes
        (  x_return_status        IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         --, p_op_network_tbl       IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
         , p_op_network_Rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_old_op_network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_old_op_network_unexp_rec  IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        )
        IS
            l_err_text              VARCHAR2(2000) := NULL;
            l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
            l_Token_Tbl             Error_Handler.Token_Tbl_Type;
            l_cfm_flag              NUMBER := NULL ;

        BEGIN

           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF BOM_Rtg_Globals.Get_Debug = 'Y'
           THEN Error_Handler.Write_Debug
                   ('Within Operation Network Check Attributes . . . ');
           END IF;

           -- Set Token Value
           l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
           l_token_tbl(1).token_value :=
                                p_op_network_rec.from_op_seq_number;
           l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
           l_token_tbl(2).token_value :=
                                p_op_network_rec.to_op_seq_number;


            --
            -- Check if the user is trying to update a record with
            -- missing value when the column value is required.
            --

            IF p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
            THEN


            IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Operation Attr Validation: Missing Value. . . ' || x_return_status) ;
            END IF;

                -- Connection(Transition) Type
                IF p_op_network_rec.connection_type = FND_API.G_MISS_NUM
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'BOM_OP_NWK_CNTTYPE_MISSING'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                     );
                    x_return_status := FND_API.G_RET_STS_ERROR;
                END IF ;


                -- Planning Percent
                IF p_op_network_rec.planning_percent = FND_API.G_MISS_NUM
                THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'BOM_OP_NWK_PLNPCT_MISSING'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                     );
                    x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
           END IF ;

           IF ( p_op_network_rec.From_X_Coordinate <> FND_API.G_MISS_NUM
                AND p_op_network_rec.From_X_Coordinate < 0 )
           OR ( p_op_network_rec.From_Y_Coordinate <> FND_API.G_MISS_NUM
                AND p_op_network_rec.From_Y_Coordinate < 0 )
           OR ( p_op_network_rec.To_X_Coordinate <> FND_API.G_MISS_NUM
                AND p_op_network_rec.To_X_Coordinate < 0 )
           OR ( p_op_network_rec.To_Y_Coordinate <> FND_API.G_MISS_NUM
                AND p_op_network_rec.To_Y_Coordinate < 0 ) THEN
             Error_Handler.Add_Error_Token
             (  p_message_name       => 'BOM_OP_NWK_COORD_NEGATIVE'
             , p_token_tbl          => l_token_tbl
             , p_mesg_token_tbl     => l_mesg_token_tbl
             , x_mesg_token_tbl     => l_mesg_token_tbl
             );

             x_return_status := FND_API.G_RET_STS_ERROR;

          END IF;
/*
          FOR I in 1..p_op_network_tbl.COUNT LOOP
            IF ((p_op_network_tbl(I).from_op_seq_number =
                p_op_network_rec.from_op_seq_number) AND
               ((p_op_network_tbl(I).From_X_Coordinate <>
                p_op_network_rec.From_X_Coordinate) OR
               (p_op_network_tbl(I).From_Y_Coordinate <>
                p_op_network_rec.From_Y_Coordinate))) OR
              ((p_op_network_tbl(I).from_op_seq_number =
                p_op_network_rec.to_op_seq_number) AND
               ((p_op_network_tbl(I).From_X_Coordinate <>
                p_op_network_rec.To_X_Coordinate) OR
               (p_op_network_tbl(I).From_Y_Coordinate <>
                p_op_network_rec.To_Y_Coordinate))) OR
              ((p_op_network_tbl(I).To_op_seq_number =
                p_op_network_rec.from_op_seq_number) AND
               ((p_op_network_tbl(I).To_X_Coordinate <>
                p_op_network_rec.From_X_Coordinate) OR
               (p_op_network_tbl(I).To_Y_Coordinate <>
                p_op_network_rec.From_Y_Coordinate))) OR
              ((p_op_network_tbl(I).To_op_seq_number =
                p_op_network_rec.To_op_seq_number) AND
               ((p_op_network_tbl(I).To_X_Coordinate <>
                p_op_network_rec.To_X_Coordinate) OR
               (p_op_network_tbl(I).To_Y_Coordinate <>
                p_op_network_rec.To_Y_Coordinate))) THEN

             Error_Handler.Add_Error_Token
             (  p_message_name       => 'BOM_OP_NWK_COORD_MISMATCH'
             , p_token_tbl          => l_token_tbl
             , p_mesg_token_tbl     => l_mesg_token_tbl
             , x_mesg_token_tbl     => l_mesg_token_tbl
             );

             x_return_status := FND_API.G_RET_STS_ERROR;

          END IF;

          END LOOP;
*/
           l_cfm_flag := BOM_Rtg_Globals.Get_CFM_Rtg_Flag ;


           IF l_cfm_flag IS NULL OR
              l_cfm_flag = FND_API.G_MISS_NUM
           THEN
               l_cfm_flag := Bom_Rtg_Validate.Get_Flow_Routing_Flag
                                 (p_op_network_unexp_rec.routing_sequence_id) ;
               BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type => l_cfm_flag) ;
           END IF;

           IF  p_op_network_rec.connection_type NOT IN (1, 2)
           AND p_op_network_rec.connection_type is NOT NULL
           AND p_op_network_rec.connection_type <> FND_API.G_MISS_NUM
           AND l_cfm_flag  =  BOM_Rtg_Globals.G_LOT_RTG
           THEN
                Error_Handler.Add_Error_Token
                  (  p_message_name       => 'BOM_OP_NWK_CNTYPE_INVALID'
                   , p_token_tbl          => l_token_tbl
                   , p_mesg_token_tbl     => l_mesg_token_tbl
                   , x_mesg_token_tbl     => l_mesg_token_tbl
                 );

                x_return_status := FND_API.G_RET_STS_ERROR;

           -- Flow Routing's Network can have connetion type : 3 - Rework
           ELSIF  p_op_network_rec.connection_type NOT IN (1, 2, 3)
           AND p_op_network_rec.connection_type is NOT NULL
           AND p_op_network_rec.connection_type <> FND_API.G_MISS_NUM
           AND l_cfm_flag  =  BOM_Rtg_Globals.G_FLOW_RTG
           THEN

                Error_Handler.Add_Error_Token
                  (  p_message_name       => 'BOM_OP_NWK_CNTYPE_INVALID'
                   , p_token_tbl          => l_token_tbl
                   , p_mesg_token_tbl     => l_mesg_token_tbl
                   , x_mesg_token_tbl     => l_mesg_token_tbl
                 );

                x_return_status := FND_API.G_RET_STS_ERROR;

           END IF;

           IF  (p_op_network_rec.planning_percent      > 100
                OR  p_op_network_rec.planning_percent  < 0)
           AND p_op_network_rec.planning_percent IS NOT NULL
           AND p_op_network_rec.planning_percent <> FND_API.G_MISS_NUM
           THEN

                Error_Handler.Add_Error_Token
                (  p_message_name       => 'BOM_OP_NWK_PLNPCT_INVALID'
                 , p_token_tbl          => l_token_tbl
                 , p_mesg_token_tbl     => l_mesg_token_tbl
                 , x_mesg_token_tbl     => l_mesg_token_tbl
                );
                  x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        EXCEPTION
            WHEN OTHERS THEN
                 IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                 ('Some unknown error in Attribute Validation . . .' || SQLERRM );
                  END IF ;


                 l_err_text := G_PKG_NAME || ' Validation (Attr. Validation) '
                                || substrb(SQLERRM,1,200);

                  Error_Handler.Add_Error_Token
                  (  p_message_name   => NULL
                   , p_message_text   => l_err_text
                   , p_mesg_token_tbl => l_mesg_token_tbl
                   , x_mesg_token_tbl => l_mesg_token_tbl
                 ) ;

                 -- Return the status and message table.
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 x_mesg_token_tbl := l_mesg_token_tbl ;


        END Check_Attributes;

        /********************************************************************
        * Procedure     : Check_Entity1
        * Parameters IN : operation network Exposed column record
        *                 operation network Unexposed column record
        *                 Old operation network exposed column record
        *                 Old operation network unexposed column record
        * Parameters OUT: Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform the business logic
        *                 validation for the operation network Entity.It will
        *                 perform any cross entity validations and make sure
        *                 that the user is not entering values which may
        *                 disturb the integrity of the data.
        *********************************************************************/
        PROCEDURE Check_Entity1
        ( p_op_network_rec        IN  Bom_Rtg_Pub.Op_Network_Rec_Type
        , p_op_network_unexp_rec  IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , p_old_op_network_rec    IN  Bom_Rtg_Pub.Op_Network_Rec_Type
        , p_old_op_network_unexp_rec IN Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , x_return_status         IN OUT NOCOPY VARCHAR2
         )
        IS

        Cursor    c_op_network
        (  P_From_Op_Seq_Id number
         , P_To_Op_Seq_Id number
        )
        IS
        SELECT 'x' dummy
        FROM DUAL
        WHERE EXISTS
        ( SELECT NULL
          FROM   bom_operation_networks a
          WHERE  a.from_op_seq_id = P_From_Op_Seq_Id
          AND    a.to_op_seq_id   <>   P_To_Op_Seq_Id
          AND    a.transition_type = 1
        );


        CURSOR check_unique_network_csr ( p_from_op_seq_id NUMBER
                                        , p_to_op_seq_id   NUMBER )
        IS
           SELECT 'Not Unique'
           FROM SYS.DUAL
           WHERE EXISTS ( SELECT NULL
                          FROM   bom_operation_networks a
                          WHERE  a.from_op_seq_id = p_from_op_seq_id
                          AND    a.to_op_seq_id   = p_to_op_seq_id
                          );


        l_total_planning_pct NUMBER :=0;
        l_planning_pct       NUMBER :=0;
        l_token_tbl          Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl     Error_Handler.Mesg_Token_Tbl_Type;
        l_dummy              NUMBER;
        l_err_text           VARCHAR2(2000) ;
        l_return_status      VARCHAR2(1);
        l_err_code           NUMBER;

        PASS_CHECK_ENTITY1_FOR_EAM EXCEPTION ;


        BEGIN


           x_return_status := FND_API.G_RET_STS_SUCCESS;

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug ('Within Operation Network Check Entity1 . . . ');
END IF;

           -- Set Token Value
           l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
           l_token_tbl(1).token_value :=
                                NVL( p_op_network_rec.new_from_op_seq_number
                                   , p_op_network_rec.from_op_seq_number ) ;
           l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
           l_token_tbl(2).token_value :=
                                NVL( p_op_network_rec.new_to_op_seq_number
                                   , p_op_network_rec.to_op_seq_number ) ;

           IF  p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
           AND ( p_op_network_unexp_rec.new_from_op_seq_id IS NOT NULL OR
                 p_op_network_unexp_rec.new_to_op_seq_id IS NOT NULL  )
           THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check op network uniqueness for UPDATE . . . ');
END IF;

               FOR l_uniqe_rec in check_unique_network_csr
               ( P_From_Op_Seq_Id => NVL(p_op_network_unexp_rec.new_from_op_seq_id,
                                         p_op_network_unexp_rec.from_op_seq_id) ,
                 P_To_Op_Seq_Id   => NVL(p_op_network_unexp_rec.new_to_op_seq_id,
                                         p_op_network_unexp_rec.to_op_seq_id)
                )
               LOOP

                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'BOM_OP_NWK_ALREADY_EXISTS'
                         , p_token_tbl      => l_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;

                END LOOP ;
           END IF ;


           -- For eAM enhancement.
           IF   BOM_Rtg_Globals.Get_Eam_Item_Type = BOM_Rtg_Globals.G_ASSET_ACTIVITY
           THEN
              NULL ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Call eAM Rtg Network validation API. . . ');
END IF;
              /*
               --  This validation no longer used
               -- Call Routing eAM API for eAM Rtg Network validation
               Bom_Rtg_Eam_Util.Check_Eam_Nwk_FromOp
               ( p_from_op_seq_num  => p_op_network_rec.from_op_seq_number
               , p_from_op_seq_id   => p_op_network_unexp_rec.from_op_seq_id
               , p_to_op_seq_num    => p_op_network_rec.to_op_seq_number
               , p_to_op_seq_id     => p_op_network_unexp_rec.to_op_seq_id
               , x_err_msg          => l_err_text
               , x_return_status    => l_return_status
               ) ;

               IF  l_return_status =  FND_API.G_RET_STS_ERROR THEN

                  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name   => NULL
                       , p_message_text   => l_err_text
                       , p_mesg_token_tbl => l_mesg_token_tbl
                       , x_mesg_token_tbl => l_mesg_token_tbl
                      ) ;

                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR ;
                END IF ;

                 -- If operation network is for maintenance routing,
                 -- pass through followings validations.

IF BOM_Rtg_Globals.Get_Debug = 'Y'  THEN
    Error_Handler.Write_Debug ('Pass Operation Network Check Entity1 in maintenance routings . . . ');
END IF;
               */

                RAISE PASS_CHECK_ENTITY1_FOR_EAM ;


           END IF ;

           --
           -- Merge step 12 into this procedure
           -- Check conditionally required attributes
           --
           IF  p_op_network_rec.planning_percent IS NULL
           OR  p_op_network_rec.planning_percent = FND_API.G_MISS_NUM
           THEN

                Error_Handler.Add_Error_Token
                  (  p_message_name       => 'BOM_OP_NWK_PLNPCT_REQUIRED'
                   , p_token_tbl          => l_token_tbl
                   , p_mesg_token_tbl     => l_mesg_token_tbl
                   , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
                   x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

           --
           -- If connection type =1, there must be only one primary from operation.        --
           --
           IF p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE AND
              p_op_network_rec.connection_type = 1
           THEN
               FOR l_opnet_rec in c_op_network
               ( P_From_Op_Seq_Id => NVL(p_op_network_unexp_rec.new_from_op_seq_id,
                                         p_op_network_unexp_rec.from_op_seq_id) ,
                 P_To_Op_Seq_Id   => p_op_network_unexp_rec.to_op_seq_id
                )
               LOOP

                   l_token_tbl.DELETE(2) ;

                   IF p_op_network_rec.operation_type = 1
                   THEN

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_OP_NWK_PMOP_NOTUNIQUE'
                         , p_token_tbl          => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;

                   ELSIF p_op_network_rec.operation_type = 2
                   THEN

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_OP_NWK_PMPRCS_NOTUNIQUE'
                         , p_token_tbl          => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                   ELSIF p_op_network_rec.operation_type = 3
                   THEN

                      Error_Handler.Add_Error_Token
                       (  p_message_name       => 'BOM_OP_NWK_PMLO_NOTUNIQUE'
                        , p_token_tbl          => l_token_tbl
                        , p_mesg_token_tbl     => l_mesg_token_tbl
                        , x_mesg_token_tbl     => l_mesg_token_tbl
                       );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

               END LOOP;
           END IF;


           --
           -- Check planning percentage.
           -- For update or create, total of Planning Percent for  Operation
           -- Network must be smaller than 100%.
           --

           -- Changed the condition to support updating from op and to op id
           -- IF  p_op_network_rec.transaction_type IN (BOM_Rtg_Globals.G_OPR_CREATE ,
           --                                           BOM_Rtg_Globals.G_OPR_UPDATE)
           -- Added similar validation in Check_Entity2 for updating.

           IF  p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
           AND p_op_network_rec.connection_type  IN (1, 2)
           THEN
               SELECT  NVL(SUM(planning_pct), 0)
               INTO    l_total_planning_pct
               FROM    bom_operation_networks
               WHERE   from_op_seq_id =  p_op_network_unexp_rec.from_op_seq_id
               AND     to_op_seq_id <>   p_op_network_unexp_rec.to_op_seq_id
               AND     transition_type IN (1, 2);

               -- select planning percent for update process
               IF p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
               THEN
                 SELECT NVL(planning_pct,0)
                 INTO  l_planning_pct
                 FROM  bom_operation_networks
                 WHERE   from_op_seq_id =  p_op_network_unexp_rec.from_op_seq_id
                 AND     to_op_seq_id =    p_op_network_unexp_rec.to_op_seq_id
                 AND   transition_type IN (1, 2);
               END IF;


              l_total_planning_pct := l_total_planning_pct
                                      + p_op_network_rec.planning_percent ;


              /*
              l_total_planning_pct := l_total_planning_pct
                                      + p_op_network_rec.planning_percent
                                      - l_planning_pct ;
              */


              IF (l_total_planning_pct > 100)
              THEN

                 l_token_tbl.DELETE(2) ;

                 IF p_op_network_rec.operation_type IN (1,2)
                 THEN
                      Error_Handler.Add_Error_Token
                      (  p_message_name     => 'BOM_OP_NWK_PRCS_PLNPCT_INVALID'
                       , p_token_tbl        => l_token_tbl
                       , p_mesg_token_tbl   => l_mesg_token_tbl
                       , x_mesg_token_tbl   => l_mesg_token_tbl
                      );
                     x_return_status := FND_API.G_RET_STS_ERROR;
                  ELSIF p_op_network_rec.operation_type = 3
                  THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name  => 'BOM_OP_NWK_LO_PLNLPCT_INVALID'
                         , p_token_tbl     => l_token_tbl
                         , p_mesg_token_tbl=> l_mesg_token_tbl
                         , x_mesg_token_tbl=> l_mesg_token_tbl
                        );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;

               END IF;
             END IF;

     --For Delete Link OSFM constraint

     IF p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE
     AND BOM_RTG_Globals.Is_Osfm_NW_Calc_Flag
     AND
     WSMPUTIL.JOBS_WITH_QTY_AT_FROM_OP (x_err_code => l_err_code,
                                        x_err_msg => l_err_text,
                                        p_routing_sequence_id => p_op_network_unexp_rec.Routing_Sequence_Id,
                                        p_operation_seq_num => p_op_network_rec.From_Op_Seq_Number)
     THEN
     l_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
     l_token_tbl(1).token_value := p_op_network_rec.From_Op_Seq_Number;
     Error_Handler.Add_Error_Token(p_message_name => 'BOM_WSM_FROM_OP_ACTIVE_JOB',
                                   p_mesg_token_tbl => l_mesg_token_tbl,
                                   p_token_tbl      => l_token_tbl,
                                   x_mesg_token_tbl => l_mesg_token_tbl);
     x_return_status := Error_Handler.G_Status_Error;
     END IF;
     --End of Delete Link OSFM Constraint

     x_mesg_token_tbl := l_mesg_token_tbl;

        EXCEPTION
           WHEN PASS_CHECK_ENTITY1_FOR_EAM THEN
                x_mesg_token_tbl := l_mesg_token_tbl;

           WHEN OTHERS THEN
              IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
              ('Some unknown error in Entity Validation1. . .' || SQLERRM );
              END IF ;


              l_err_text := G_PKG_NAME || ' Validation (Entity Validation1) '
                                    || substrb(SQLERRM,1,200);

              Error_Handler.Add_Error_Token
              (  p_message_name   => NULL
               , p_message_text   => l_err_text
               , p_mesg_token_tbl => l_mesg_token_tbl
               , x_mesg_token_tbl => l_mesg_token_tbl
              ) ;

              -- Return the status and message table.
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              x_mesg_token_tbl := l_mesg_token_tbl ;


        END Check_Entity1;


        /********************************************************************
        * Procedure     : Check_Entity2
        * Parameters IN : Operation Network Exposed column record
        *                 Operation Network Unexposed column record
        *                 Old operation network exposed column record
        *                 Old operation network unexposed column record
        * Parameters OUT: Message Token Table
        *                 Return Status
        * Purpose       : This procedure will call network validation API
        *                 to check  the routing network created with processes
        *                 or line-operations for existing loops. Check the
        *                 routing network to see if there exist any broken
        *links in the network that was created
        *********************************************************************/
        PROCEDURE Check_Entity2
        ( p_op_network_rec        IN  Bom_Rtg_Pub.Op_Network_Rec_Type
        , p_op_network_unexp_rec  IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , p_old_op_network_rec    IN  Bom_Rtg_Pub.Op_Network_Rec_Type
        , p_old_op_network_unexp_rec IN Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , x_return_status         IN OUT NOCOPY VARCHAR2
       )
       IS
        x_status         VARCHAR2(1);
        x_message        VARCHAR2(255);

        l_total_planning_pct NUMBER :=0;
        l_err_text       VARCHAR2(2000) ;
        l_token_tbl      Error_Handler.Token_Tbl_Type;
        l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
        l_dummy          NUMBER;

       BEGIN


           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF BOM_Rtg_Globals.Get_Debug = 'Y'
           THEN Error_Handler.Write_Debug
                   ('Within operation network entity level check2 . . . ');
           END IF;

           -- Set Token Value
           l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
           l_token_tbl(1).token_value :=
                                NVL( p_op_network_rec.new_from_op_seq_number
                                   , p_op_network_rec.from_op_seq_number ) ;
           l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
           l_token_tbl(2).token_value :=
                                NVL( p_op_network_rec.new_to_op_seq_number
                                   , p_op_network_rec.to_op_seq_number ) ;

           -- Operation Network regarding eAM enhancement
           -- The routing networks can be defined for flow manufacturing routings
           -- and lot based (defined in WSM) routings.
           -- Currently, the network defined for lot based routings cannot have
           -- multiple start nodes. It should be a single network with only one start node.
           -- But the maintenance routing defined for an asset activity can have
           -- multiple small network of operations
           -- ( i.e the routings can have more  than one start node).
           --  Both lot based and EAM routings does not allow looping within the network.
           --  In both the cases all the operations in a routing may not be totally connected.
           --  There can be some operations not included in the network.


           --
           -- Check planning percentage.
           -- For update, total of Planning Percent for Operation
           -- Network must be smaller than 100%.
           -- Added to support updating from op and to op id

           IF  p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
           AND p_op_network_rec.connection_type  IN (1, 2)
           AND   BOM_Rtg_Globals.Get_Eam_Item_Type <> BOM_Rtg_Globals.G_ASSET_ACTIVITY
           THEN

               SELECT  NVL(SUM(planning_pct), 0)
               INTO    l_total_planning_pct
               FROM    bom_operation_networks
               WHERE   from_op_seq_id = NVL(  p_op_network_unexp_rec.new_from_op_seq_id
                                            , p_op_network_unexp_rec.from_op_seq_id)
               AND     to_op_seq_id <>  NVL(  p_op_network_unexp_rec.new_to_op_seq_id
                                            , p_op_network_unexp_rec.to_op_seq_id)
               AND     transition_type IN (1, 2);

              --l_total_planning_pct := l_total_planning_pct;
              --                        + p_op_network_rec.planning_percent ;


              IF BOM_Rtg_Globals.Get_Debug = 'Y'
              THEN Error_Handler.Write_Debug
                   ('Check planning percentage '|| to_char(l_total_planning_pct) );
              END IF;

               IF (l_total_planning_pct > 100)
               THEN

                   l_token_tbl.DELETE(2) ;

                   IF p_op_network_rec.operation_type IN (1,2)
                   THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name     => 'BOM_OP_NWK_PRCS_PLNPCT_INVALID'
                         , p_token_tbl        => l_token_tbl
                         , p_mesg_token_tbl   => l_mesg_token_tbl
                         , x_mesg_token_tbl   => l_mesg_token_tbl
                        );
                       x_return_status := FND_API.G_RET_STS_ERROR;
                   ELSIF p_op_network_rec.operation_type = 3
                   THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name  => 'BOM_OP_NWK_LO_PLNLPCT_INVALID'
                         , p_token_tbl     => l_token_tbl
                         , p_mesg_token_tbl=> l_mesg_token_tbl
                         , x_mesg_token_tbl=> l_mesg_token_tbl
                        );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

                   l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                   l_token_tbl(2).token_value :=
                                NVL( p_op_network_rec.new_to_op_seq_number
                                   , p_op_network_rec.to_op_seq_number ) ;

               END IF;
           END IF;

/* Following code needs to be called when the whole network has been created and
 not at the creation/modification of each link. Although the code checks a link
attributes , it should run after the entire netowrk has been created/modified
           -- Added condition for eAM enhancement
           IF    p_op_network_rec.connection_type <> 3  -- Not Rework
           AND   BOM_Rtg_Globals.Get_Eam_Item_Type <> BOM_Rtg_Globals.G_ASSET_ACTIVITY
           THEN

               bom_rtg_network_validate_api.validate_routing_network
               ( p_rtg_sequence_id => p_op_network_unexp_rec.routing_sequence_id
               , p_assy_item_id    => p_op_network_unexp_rec.assembly_item_id
               , p_org_id          => p_op_network_unexp_rec.organization_id
               , p_alt_rtg_desig   => p_op_network_rec.alternate_routing_code
               , p_operation_type  => p_op_network_rec.operation_type
               , x_status          => x_status
               , x_message         => x_message
               ) ;

              IF BOM_Rtg_Globals.Get_Debug = 'Y'
              THEN Error_Handler.Write_Debug
                   ('After calling Rtg Network Validate API. Retrun status is '|| x_status );
              END IF;

           END IF ;



           IF  x_status = 'F' AND x_message IS NOT NULL
           THEN

              IF  UPPER( RTRIM(x_message) ) =
                  UPPER('A loop has been detected in this Routing Network.')
              THEN
                Error_Handler.Add_Error_Token
                  (  p_message_name       => 'BOM_OP_NWK_LOOP_EXIT'
                   , p_token_tbl          => l_token_tbl
                   , p_mesg_token_tbl     => l_mesg_token_tbl
                   , x_mesg_token_tbl     => l_mesg_token_tbl
                 );
                x_return_status := FND_API.G_RET_STS_ERROR;
              ELSIF  UPPER( RTRIM(x_message) ) =
                UPPER('A broken link exists in this routing Network.')
                THEN

                Error_Handler.Add_Error_Token
                  (  p_message_name       => 'BOM_OP_NWK_BROEKN_LINK_EXIT'
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
           END IF;
*/
           -- For eAM enhancement
           -- Maintenance Routing Network Validation
           IF    p_op_network_rec.operation_type = 1
           AND   BOM_Rtg_Globals.Get_Eam_Item_Type =  BOM_Rtg_Globals.G_ASSET_ACTIVITY
           THEN

               Check_Eam_Rtg_Network
               ( p_op_network_rec        => p_op_network_rec
               , p_op_network_unexp_rec  => p_op_network_unexp_rec
               , p_old_op_network_rec    => p_old_op_network_rec
               , p_old_op_network_unexp_rec => p_old_op_network_unexp_rec
               , p_mesg_token_tbl        => l_mesg_token_tbl
               , x_mesg_token_tbl        => l_mesg_token_tbl
               , x_return_status         => x_status
               ) ;

               IF  x_status =  FND_API.G_RET_STS_ERROR THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
               END IF ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug
    ('Validation for eAM Op Network is completed with status '|| x_return_status);
END IF;


           END IF ; -- eAM Operation Network Validation


           x_mesg_token_tbl := l_mesg_token_tbl;

       EXCEPTION
           WHEN OTHERS THEN
              IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
              ('Some unknown error in Entity Validation2. . .' || SQLERRM );
              END IF ;


              l_err_text := G_PKG_NAME || ' Validation (Entity Validation2) '
                                    || substrb(SQLERRM,1,200);

              Error_Handler.Add_Error_Token
              (  p_message_name   => NULL
               , p_message_text   => l_err_text
               , p_mesg_token_tbl => l_mesg_token_tbl
               , x_mesg_token_tbl => l_mesg_token_tbl
              ) ;

              -- Return the status and message table.
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              x_mesg_token_tbl := l_mesg_token_tbl ;


       END Check_Entity2;
  /*********************************************************************
  * Procedure     : Check_WSM_Netowrk_Attribs
  * Parameters IN : Assembly item id
  *                 Organization Id
  *                 Alternate_Rtg_Code
  *                 previous start id as found before the whole update
  *                 previous end id as found before the whole update
  * Parameters OUT:
  *                 Mesg token Table
  *                 Return Status
  * Purpose       : Procedure will varify that the routing start and
  *                 end are unchanged
  ***********************************************************************/
  PROCEDURE Check_WSM_Netowrk_Attribs
  ( p_routing_sequence_id        IN  NUMBER
  , p_prev_start_id              IN  NUMBER
  , p_prev_end_id                IN NUMBER
  , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_status              IN OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR cur_op_seq_num( p_routing_id NUMBER,
                           p_operation_seq_id NUMBER) IS
    select operation_seq_num from bom_operation_sequences
    WHERE routing_sequence_id = p_routing_id
    AND   operation_sequence_id = p_operation_seq_id;

    l_routing_sequence_id  NUMBER :=0;
    l_common_routing_sequence_id NUMBER :=0;
    l_cfm_routing_flag     NUMBER :=0;
    l_mesg_token_tbl       Error_Handler.Mesg_Token_Tbl_Type ;
    l_post_start_id        NUMBER :=0;
    l_post_end_id          NUMBER :=0;
    err_code               NUMBER:=0;
    err_msg                VARCHAR2(2000);
    l_token_tbl      Error_Handler.Token_Tbl_Type;
    x_success              NUMBER:=0;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select routing_sequence_id, cfm_routing_flag
    into   l_routing_sequence_id,l_cfm_routing_flag
    from bom_operational_routings where
         routing_sequence_id = p_routing_sequence_id;

    -- Get Common Routing Seq Id from System Info Rec.
    -- If the value is Null, set Common Routing Seq Id.
    l_common_routing_sequence_id := BOM_Rtg_Globals.Get_Common_Rtg_Seq_id ;
    IF l_common_routing_sequence_id IS NULL OR
       l_common_routing_sequence_id = FND_API.G_MISS_NUM THEN
      BEGIN
        SELECT  common_routing_sequence_id
        INTO    l_common_routing_sequence_id
        FROM    bom_operational_routings
        WHERE   routing_sequence_id = l_routing_sequence_id;
      END ;
      BOM_Rtg_Globals.Set_Common_Rtg_Seq_id
      ( p_common_rtg_seq_id => l_common_routing_sequence_id );
    END IF;
        IF nvl(l_cfm_routing_flag,2) = 3 THEN
        --IF ( p_prev_start_id IS NOT NULL AND p_prev_start_id <> 0 ) THEN --  commented for bug3134027
      WSMPUTIL.FIND_ROUTING_START(l_common_routing_sequence_id,
      l_post_start_id,
      err_code,
      err_msg );

      IF err_code = -1 THEN  --for OSFM routings
        RETURN;
      END IF;

      IF err_msg IS NOT NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => err_msg
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	x_mesg_token_tbl := l_mesg_token_tbl ; --for bug 3134027

        RETURN;
      END IF;

      IF p_prev_start_id is not null and p_prev_start_id <> 0 then
      IF (l_post_start_id <> p_prev_start_id) THEN
      -- Set Token Value

        l_token_tbl(1).token_name  := 'START_OP_SEQ_NUM';
        FOR rec_op_seq_num in cur_op_seq_num(l_routing_sequence_id,
                                             l_post_start_id) LOOP
          l_token_tbl(1).token_value := rec_op_seq_num.operation_seq_num;
        END LOOP;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          Error_Handler.Add_Error_Token
          ( p_message_name   => 'WSM_START_CANNOT_BE_CHANGED'
          , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
          , p_token_tbl      => l_token_tbl
          ) ;
        END IF ;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	x_mesg_token_tbl := l_mesg_token_tbl ; --for bug 3134027

        RETURN;
      END IF;
      end if; -- for bug3134027


     -- IF ( p_prev_end_id IS NOT NULL AND p_prev_end_id <> 0 ) THEN --  commented for bug3134027
      WSMPUTIL.FIND_ROUTING_END(l_common_routing_sequence_id,
      l_post_end_id,
      err_code,
      err_msg );

      IF err_code = -1 THEN  --for OSFM routings
        RETURN;
      END IF;

      IF err_msg IS NOT NULL THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => err_msg
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	x_mesg_token_tbl := l_mesg_token_tbl ; --for bug 3134027

        RETURN;
      END IF;
      IF p_prev_end_id is not null and p_prev_end_id <> 0 then
       if (l_post_end_id <> p_prev_end_id) THEN
      -- Set Token Value
        l_token_tbl(1).token_name  := 'END_OP_SEQ_NUM';
        FOR rec_op_seq_num in cur_op_seq_num(l_routing_sequence_id,
                                             l_post_end_id) LOOP
          l_token_tbl(1).token_value := rec_op_seq_num.operation_seq_num;
        END LOOP;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            Error_Handler.Add_Error_Token
          ( p_message_name   => 'WSM_END_CANNOT_BE_CHANGED'
          , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
          , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
          , p_token_tbl      => l_token_tbl
          ) ;
        END IF ;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	x_mesg_token_tbl := l_mesg_token_tbl ; --for bug 3134027

        RETURN;
      END IF;

    END IF;-- If prev end has some value --  commented for bug3134027

      err_msg := NULL;
      err_code := 0;
      x_success := WSMPUTIL.PRIMARY_LOOP_TEST
                  (l_common_routing_sequence_id,
                   l_post_start_id,
                   l_post_end_id,
		   err_code,
		   err_msg );

      IF err_msg IS NOT NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
          , p_message_text   => err_msg
          , p_mesg_token_tbl => l_mesg_token_tbl
          , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	x_mesg_token_tbl := l_mesg_token_tbl ; --for bug 3134027

        RETURN ;

      END IF;

      err_msg := NULL;
      err_code := 0;
      x_success:= WSMPUTIL.CHECK_100_PERCENT (
                  l_common_routing_sequence_id,
                  err_code,
                  err_msg );

      IF err_msg IS NOT NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
          , p_message_text   => err_msg
          , p_mesg_token_tbl => l_mesg_token_tbl
          , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	x_mesg_token_tbl := l_mesg_token_tbl ; --for bug 3134027

        RETURN ;
      END IF;
    END IF;-- ONLY if CFM_ROUTING_FLAG=3(OSFM ROUTING)


    -- Return messages
    x_mesg_token_tbl := l_mesg_token_tbl ;


  END Check_WSM_Netowrk_Attribs;


END BOM_Validate_Op_Network;

/
